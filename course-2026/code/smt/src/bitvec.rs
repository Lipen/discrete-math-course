//! A bitvector solver by bit-blasting.
//!
//! Fixed-width bitvector expressions are translated into boolean clauses --
//! one SAT variable per bit -- and decided by the internal DPLL SAT solver
//! (the [`sat`](crate::sat) module). Supported operations: constants,
//! variables, `Not`, `And`, `Or`, `Add`, `Sub` (two's complement, modular
//! arithmetic), `Extract`, and equality/disequality of bitvectors as the
//! top-level literals. `Mul` and `Shl` are recognised but deliberately not
//! implemented: they fail with an explicit [`BitvecError::UnsupportedOp`]
//! instead of silently misbehaving.
//!
//! Widths from 1 to 64 bits are accepted; the operands of a binary operation
//! must have equal width. Variables are numbered from 0, and the model
//! returned by [`solve`] is indexed by variable number.
//!
//! ```
//! use smt::bitvec::{solve, BoolExpr, Expr};
//!
//! // x + 1 == 5 in 4 bits: x must be 4.
//! let eq = BoolExpr::Eq(
//!     Box::new(Expr::Add(Box::new(Expr::Var(0, 4)), Box::new(Expr::Const(1, 4)))),
//!     Box::new(Expr::Const(5, 4)),
//! );
//! let m = solve(&[eq]).unwrap().unwrap();
//! assert_eq!(m[0], 4);
//!
//! // Multiplication is not implemented: an explicit error, not a wrong answer.
//! let mul = BoolExpr::Eq(
//!     Box::new(Expr::Mul(Box::new(Expr::Var(0, 4)), Box::new(Expr::Var(1, 4)))),
//!     Box::new(Expr::Const(6, 4)),
//! );
//! assert!(solve(&[mul]).is_err());
//! ```

use std::collections::HashMap;
use std::fmt;

use crate::sat;

/// A bitvector expression of a fixed width.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum Expr {
    /// A constant: `Const(value, width)`; the value is truncated to the width.
    Const(u64, u32),
    /// A variable: `Var(number, width)`; the model is indexed by number.
    Var(usize, u32),
    /// Bitwise NOT.
    Not(Box<Expr>),
    /// Bitwise AND.
    And(Box<Expr>, Box<Expr>),
    /// Bitwise OR.
    Or(Box<Expr>, Box<Expr>),
    /// Modular addition (two's complement).
    Add(Box<Expr>, Box<Expr>),
    /// Modular subtraction (two's complement).
    Sub(Box<Expr>, Box<Expr>),
    /// Multiplication. Recognised but not implemented: solving fails with
    /// [`BitvecError::UnsupportedOp`].
    Mul(Box<Expr>, Box<Expr>),
    /// Left shift. Recognised but not implemented: solving fails with
    /// [`BitvecError::UnsupportedOp`].
    Shl(Box<Expr>, Box<Expr>),
    /// Extract bits `hi..=lo` as a narrower bitvector.
    Extract(u32, u32, Box<Expr>),
}

/// A top-level boolean literal over bitvectors: an equation or disequation.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum BoolExpr {
    /// `left == right`.
    Eq(Box<Expr>, Box<Expr>),
    /// `left != right`.
    Neq(Box<Expr>, Box<Expr>),
}

/// Why a bitvector problem cannot be solved.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum BitvecError {
    /// The operation is outside the implemented set.
    UnsupportedOp(&'static str),
    /// The two operands of a binary operation have different widths.
    WidthMismatch(u32, u32),
    /// The width is 0 or more than 64 bits.
    BadWidth(u32),
    /// `Extract(hi, lo, _)` is out of range for the operand width.
    BadExtract { hi: u32, lo: u32, width: u32 },
}

impl fmt::Display for BitvecError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            BitvecError::UnsupportedOp(op) => write!(
                f,
                "bitvector operation `{op}` is not implemented (supported: \
                 Not, And, Or, Add, Sub, Extract, Eq, Neq)"
            ),
            BitvecError::WidthMismatch(a, b) => {
                write!(f, "bitvector width mismatch: {a} bits vs {b} bits")
            }
            BitvecError::BadWidth(w) => {
                write!(f, "bitvector width {w} is not supported (accepted: 1..=64)")
            }
            BitvecError::BadExtract { hi, lo, width } => {
                write!(
                    f,
                    "extract bits {hi}..={lo} is out of range for width {width}"
                )
            }
        }
    }
}

impl std::error::Error for BitvecError {}

/// A bit: a SAT variable with a polarity (`true` = the bit itself).
type Lit = (i32, bool);

/// Solve a conjunction of bitvector literals.
///
/// Returns `Ok(Some(model))` when satisfiable, `Ok(None)` when unsatisfiable,
/// and `Err` when the problem uses an unsupported operation or a bad width.
/// `model[i]` is the value of variable `i` (variables that never occur are 0).
pub fn solve(literals: &[BoolExpr]) -> Result<Option<Vec<u64>>, BitvecError> {
    // Flatten the expression trees into an arena; identical subexpressions
    // are shared, so the same circuit is never built twice.
    let mut nodes: Vec<BNode> = vec![];
    let mut widths: Vec<u32> = vec![];
    let mut cache: HashMap<Expr, usize> = HashMap::new();
    let mut var_numbers: Vec<usize> = vec![];
    let mut var_widths: HashMap<usize, u32> = HashMap::new();
    let mut eq_nodes: Vec<usize> = vec![];
    for lit in literals {
        let (a, b) = match lit {
            BoolExpr::Eq(a, b) | BoolExpr::Neq(a, b) => (a, b),
        };
        let ia = flatten(
            a,
            &mut nodes,
            &mut widths,
            &mut cache,
            &mut var_numbers,
            &mut var_widths,
        )?;
        let ib = flatten(
            b,
            &mut nodes,
            &mut widths,
            &mut cache,
            &mut var_numbers,
            &mut var_widths,
        )?;
        if widths[ia] != widths[ib] {
            return Err(BitvecError::WidthMismatch(widths[ia], widths[ib]));
        }
        eq_nodes.push(nodes.len());
        nodes.push(BNode::Eq(ia, ib));
        widths.push(1);
    }

    // Bit-blast: each node gets one SAT variable per bit; each operation
    // emits the clauses that define its output bits.
    let mut blaster = Blaster::new();
    let mut bits: Vec<Vec<Lit>> = vec![vec![]; nodes.len()];
    let mut model_bits: Vec<(usize, Vec<Lit>)> = vec![];
    for i in 0..nodes.len() {
        let bs = match nodes[i] {
            BNode::Const(v, w) => (0..w).map(|k| (0, (v >> k) & 1 == 1)).collect(),
            BNode::Var(id, w) => {
                let bs: Vec<Lit> = (0..w).map(|_| (blaster.fresh(), true)).collect();
                model_bits.push((id, bs.clone()));
                bs
            }
            BNode::Not(e) => bits[e].iter().map(|&(v, p)| (v, !p)).collect(),
            BNode::And(a, b) => blast_and_or(&mut blaster, &bits[a], &bits[b], true),
            BNode::Or(a, b) => blast_and_or(&mut blaster, &bits[a], &bits[b], false),
            BNode::Add(a, b) => blast_adder(&mut blaster, &bits[a], &bits[b], (0, false)),
            BNode::Sub(a, b) => {
                let neg_b: Vec<Lit> = bits[b].iter().map(|&(v, p)| (v, !p)).collect();
                blast_adder(&mut blaster, &bits[a], &neg_b, (0, true))
            }
            BNode::Extract(hi, lo, e) => bits[e][lo as usize..=hi as usize].to_vec(),
            BNode::Eq(a, b) => blast_eq(&mut blaster, &bits[a], &bits[b]),
        };
        bits[i] = bs;
    }

    // Assert the top-level literals: an equation forces its boolean bit true,
    // a disequation forces it false.
    for (i, lit) in literals.iter().enumerate() {
        let (var, pos) = bits[eq_nodes[i]][0];
        match lit {
            BoolExpr::Eq(..) => blaster.emit(vec![(var, pos)]),
            BoolExpr::Neq(..) => blaster.emit(vec![(var, !pos)]),
        }
    }

    let mut solver = sat::Solver::new(blaster.next_var as usize - 1);
    for clause in &blaster.clauses {
        solver.add_clause(clause);
    }
    let Some(model) = solver.solve() else {
        return Ok(None);
    };

    let max_var = var_numbers.iter().max().map(|&x| x + 1).unwrap_or(0);
    let mut out = vec![0u64; max_var];
    for (id, bs) in model_bits {
        let mut value = 0u64;
        for (k, &(v, pos)) in bs.iter().enumerate() {
            if pos && model[v as usize - 1] {
                value |= 1 << k;
            }
        }
        out[id] = value;
    }
    Ok(Some(out))
}

/// An arena node: a subexpression with its children as indices.
#[derive(Debug, Clone, Copy)]
enum BNode {
    Const(u64, u32),
    Var(usize, u32),
    Not(usize),
    And(usize, usize),
    Or(usize, usize),
    Add(usize, usize),
    Sub(usize, usize),
    Extract(u32, u32, usize),
    Eq(usize, usize),
}

/// Flatten an expression into the arena, returning its node index.
fn flatten(
    e: &Expr,
    nodes: &mut Vec<BNode>,
    widths: &mut Vec<u32>,
    cache: &mut HashMap<Expr, usize>,
    var_numbers: &mut Vec<usize>,
    var_widths: &mut HashMap<usize, u32>,
) -> Result<usize, BitvecError> {
    if let Some(&i) = cache.get(e) {
        return Ok(i);
    }
    let (node, width) = match e {
        Expr::Const(v, w) => {
            check_width(*w)?;
            let mask = if *w == 64 { u64::MAX } else { (1u64 << *w) - 1 };
            (BNode::Const(v & mask, *w), *w)
        }
        Expr::Var(id, w) => {
            check_width(*w)?;
            // A variable has one fixed width in a well-formed problem;
            // using it at two widths would make the two bit-sets
            // independent, silently producing an inconsistent model.
            if let Some(&prev) = var_widths.get(id) {
                if prev != *w {
                    return Err(BitvecError::WidthMismatch(prev, *w));
                }
            } else {
                var_widths.insert(*id, *w);
            }
            var_numbers.push(*id);
            (BNode::Var(*id, *w), *w)
        }
        Expr::Not(x) => {
            let ix = flatten(x, nodes, widths, cache, var_numbers, var_widths)?;
            (BNode::Not(ix), widths[ix])
        }
        Expr::And(a, b) | Expr::Or(a, b) | Expr::Add(a, b) | Expr::Sub(a, b) => {
            let ia = flatten(a, nodes, widths, cache, var_numbers, var_widths)?;
            let ib = flatten(b, nodes, widths, cache, var_numbers, var_widths)?;
            if widths[ia] != widths[ib] {
                return Err(BitvecError::WidthMismatch(widths[ia], widths[ib]));
            }
            let node = match e {
                Expr::And(..) => BNode::And(ia, ib),
                Expr::Or(..) => BNode::Or(ia, ib),
                Expr::Add(..) => BNode::Add(ia, ib),
                _ => BNode::Sub(ia, ib),
            };
            (node, widths[ia])
        }
        Expr::Mul(..) => return Err(BitvecError::UnsupportedOp("Mul")),
        Expr::Shl(..) => return Err(BitvecError::UnsupportedOp("Shl")),
        Expr::Extract(hi, lo, x) => {
            let ix = flatten(x, nodes, widths, cache, var_numbers, var_widths)?;
            let w = widths[ix];
            if *hi >= w || *lo > *hi {
                return Err(BitvecError::BadExtract {
                    hi: *hi,
                    lo: *lo,
                    width: w,
                });
            }
            (BNode::Extract(*hi, *lo, ix), *hi - *lo + 1)
        }
    };
    // The children were pushed during the match above, so the node's own
    // index is the current length of the arena.
    let index = nodes.len();
    nodes.push(node);
    widths.push(width);
    cache.insert(e.clone(), index);
    Ok(index)
}

fn check_width(w: u32) -> Result<(), BitvecError> {
    if w == 0 || w > 64 {
        Err(BitvecError::BadWidth(w))
    } else {
        Ok(())
    }
}

/// Collects the generated clauses and hands out fresh SAT variables.
struct Blaster {
    next_var: i32,
    clauses: Vec<Vec<i32>>,
}

impl Blaster {
    fn new() -> Blaster {
        Blaster {
            next_var: 1,
            clauses: vec![],
        }
    }

    fn fresh(&mut self) -> i32 {
        let v = self.next_var;
        self.next_var += 1;
        v
    }

    /// Emit a clause of bits, treating variable 0 as a constant: a `(0, true)`
    /// literal makes the clause always true (skip it), a `(0, false)` literal
    /// is dropped. Real variables (1 and up) become signed literals.
    fn emit(&mut self, clause: Vec<Lit>) {
        let mut out: Vec<i32> = vec![];
        for (v, p) in clause {
            if v == 0 {
                if p {
                    return; // constant true: the clause is satisfied
                }
                continue; // constant false: drop the literal
            }
            out.push(if p { v } else { -v });
        }
        self.clauses.push(out);
    }
}

/// Define `out = a AND b` (or `out = a OR b`) bit by bit.
fn blast_and_or(blaster: &mut Blaster, a: &[Lit], b: &[Lit], is_and: bool) -> Vec<Lit> {
    a.iter()
        .zip(b)
        .map(|(&(av, ap), &(bv, bp))| {
            let o = blaster.fresh();
            if is_and {
                // out = a AND b: (out -> a), (out -> b), (a AND b -> out).
                blaster.emit(vec![(o, false), (av, ap)]);
                blaster.emit(vec![(o, false), (bv, bp)]);
                blaster.emit(vec![(o, true), (av, !ap), (bv, !bp)]);
            } else {
                // out = a OR b: (a -> out), (b -> out), (out -> a OR b).
                blaster.emit(vec![(o, true), (av, !ap)]);
                blaster.emit(vec![(o, true), (bv, !bp)]);
                blaster.emit(vec![(o, false), (av, ap), (bv, bp)]);
            }
            (o, true)
        })
        .collect()
}

/// A ripple-carry adder: `out = a + b + carry_in` bit by bit.
///
/// For each bit, a helper variable holds `a xor b`, the sum bit holds
/// `(a xor b) xor carry`, and the next carry is the majority of the three
/// inputs. `carry_in` as `(0, true)` makes the same circuit a subtractor.
fn blast_adder(blaster: &mut Blaster, a: &[Lit], b: &[Lit], carry_in: Lit) -> Vec<Lit> {
    let mut carry = carry_in;
    let mut out = vec![];
    for (&(av, ap), &(bv, bp)) in a.iter().zip(b) {
        // t = a xor b: the four clauses exclude the four rows that are not
        // in the truth table (t = 1 exactly when the two bits differ).
        let t = blaster.fresh();
        blaster.emit(vec![(t, false), (av, ap), (bv, bp)]);
        blaster.emit(vec![(t, true), (av, ap), (bv, !bp)]);
        blaster.emit(vec![(t, true), (av, !ap), (bv, bp)]);
        blaster.emit(vec![(t, false), (av, !ap), (bv, !bp)]);
        // s = t xor carry, same four clauses.
        let (tv, tp) = (t, true);
        let (cv, cp) = carry;
        let s = blaster.fresh();
        blaster.emit(vec![(s, false), (tv, tp), (cv, cp)]);
        blaster.emit(vec![(s, true), (tv, tp), (cv, !cp)]);
        blaster.emit(vec![(s, true), (tv, !tp), (cv, cp)]);
        blaster.emit(vec![(s, false), (tv, !tp), (cv, !cp)]);
        // next carry = majority(a, b, carry): the clauses exclude the rows
        // outside the truth table (carry is 1 when at least two inputs are 1;
        // the last clause also rules out carry = 1 with all inputs 0).
        let next = blaster.fresh();
        blaster.emit(vec![(next, true), (av, !ap), (bv, !bp)]);
        blaster.emit(vec![(next, true), (av, !ap), (cv, !cp)]);
        blaster.emit(vec![(next, true), (bv, !bp), (cv, !cp)]);
        blaster.emit(vec![(next, false), (av, !ap), (bv, bp), (cv, cp)]);
        blaster.emit(vec![(next, false), (av, ap), (bv, !bp), (cv, cp)]);
        blaster.emit(vec![(next, false), (av, ap), (bv, bp), (cv, !cp)]);
        blaster.emit(vec![(next, false), (av, ap), (bv, bp), (cv, cp)]);
        carry = (next, true);
        out.push((s, true));
    }
    out
}

/// Define a boolean bit `a == b`: true exactly when every bit agrees.
fn blast_eq(blaster: &mut Blaster, a: &[Lit], b: &[Lit]) -> Vec<Lit> {
    let r = blaster.fresh();
    let mut differ: Vec<Lit> = vec![];
    for (&(av, ap), &(bv, bp)) in a.iter().zip(b) {
        // d = a xor b: a bit where the two inputs differ.
        let d = blaster.fresh();
        blaster.emit(vec![(d, false), (av, ap), (bv, bp)]);
        blaster.emit(vec![(d, true), (av, ap), (bv, !bp)]);
        blaster.emit(vec![(d, true), (av, !ap), (bv, bp)]);
        blaster.emit(vec![(d, false), (av, !ap), (bv, !bp)]);
        differ.push((d, true));
        // r = true forces this bit equal.
        blaster.emit(vec![(r, false), (av, !ap), (bv, bp)]);
        blaster.emit(vec![(r, false), (av, ap), (bv, !bp)]);
    }
    // r = false forces some bit to differ.
    let mut wide = vec![(r, true)];
    wide.extend_from_slice(&differ);
    blaster.emit(wide);
    vec![(r, true)]
}

#[cfg(test)]
mod tests {
    use super::*;

    fn var(id: usize, w: u32) -> Expr {
        Expr::Var(id, w)
    }

    fn cnst(v: u64, w: u32) -> Expr {
        Expr::Const(v, w)
    }

    fn eq(a: Expr, b: Expr) -> BoolExpr {
        BoolExpr::Eq(Box::new(a), Box::new(b))
    }

    fn neq(a: Expr, b: Expr) -> BoolExpr {
        BoolExpr::Neq(Box::new(a), Box::new(b))
    }

    /// Evaluate an expression under a model; used to re-check the circuits.
    /// Results are masked to the expression width, matching the modular
    /// (two's complement) semantics of the bit-blasted circuit.
    fn eval(e: &Expr, m: &[u64]) -> (u64, u32) {
        fn mask(v: u64, w: u32) -> u64 {
            if w == 64 {
                v
            } else {
                v & ((1u64 << w) - 1)
            }
        }
        match e {
            Expr::Const(v, w) => (*v, *w),
            Expr::Var(id, w) => (m[*id], *w),
            Expr::Not(x) => {
                let (v, w) = eval(x, m);
                (mask(!v, w), w)
            }
            Expr::And(a, b) => {
                let (v1, w) = eval(a, m);
                let (v2, _) = eval(b, m);
                (v1 & v2, w)
            }
            Expr::Or(a, b) => {
                let (v1, w) = eval(a, m);
                let (v2, _) = eval(b, m);
                (v1 | v2, w)
            }
            Expr::Add(a, b) => {
                let (v1, w) = eval(a, m);
                let (v2, _) = eval(b, m);
                (mask(v1.wrapping_add(v2), w), w)
            }
            Expr::Sub(a, b) => {
                let (v1, w) = eval(a, m);
                let (v2, _) = eval(b, m);
                (mask(v1.wrapping_sub(v2), w), w)
            }
            Expr::Extract(hi, lo, x) => {
                let (v, _) = eval(x, m);
                let w = hi - lo + 1;
                (((v >> lo) & ((1u64 << w) - 1)), w)
            }
            Expr::Mul(..) | Expr::Shl(..) => unreachable!("not blasted"),
        }
    }

    /// A found model must satisfy every literal: this re-checks the circuits
    /// independently of the SAT result.
    fn check_model(literals: &[BoolExpr], m: &[u64]) {
        for lit in literals {
            let (a, b) = match lit {
                BoolExpr::Eq(a, b) | BoolExpr::Neq(a, b) => (a, b),
            };
            let (va, _) = eval(a, m);
            let (vb, _) = eval(b, m);
            match lit {
                BoolExpr::Eq(..) => assert_eq!(va, vb, "model violates an equation"),
                BoolExpr::Neq(..) => assert_ne!(va, vb, "model violates a disequation"),
            }
        }
    }

    #[test]
    fn add_is_solved() {
        // x + 1 == 5: x = 4.
        let lit = eq(
            Expr::Add(Box::new(var(0, 4)), Box::new(cnst(1, 4))),
            cnst(5, 4),
        );
        let m = solve(std::slice::from_ref(&lit)).unwrap().unwrap();
        assert_eq!(m[0], 4);
        check_model(&[lit], &m);
    }

    #[test]
    fn sub_and_carry() {
        // x - 1 == 0 in 4 bits: x = 1.
        let lit = eq(
            Expr::Sub(Box::new(var(0, 4)), Box::new(cnst(1, 4))),
            cnst(0, 4),
        );
        let m = solve(std::slice::from_ref(&lit)).unwrap().unwrap();
        assert_eq!(m[0], 1);
        check_model(&[lit], &m);
        // x + 15 == 0 wraps around: x = 1.
        let lit = eq(
            Expr::Add(Box::new(var(0, 4)), Box::new(cnst(15, 4))),
            cnst(0, 4),
        );
        let m = solve(std::slice::from_ref(&lit)).unwrap().unwrap();
        assert_eq!(m[0], 1);
        check_model(&[lit], &m);
    }

    #[test]
    fn and_or_not() {
        // (x AND 0b1100) == 0b1000 forces x3 = 1 and x2 = 0; together with
        // (x OR 0b0001) == 0b1001 that leaves x = 0b1000 or 0b1001.
        let lits = vec![
            eq(
                Expr::And(Box::new(var(0, 4)), Box::new(cnst(0b1100, 4))),
                cnst(0b1000, 4),
            ),
            eq(
                Expr::Or(Box::new(var(0, 4)), Box::new(cnst(0b0001, 4))),
                cnst(0b1001, 4),
            ),
        ];
        let m = solve(&lits).unwrap().unwrap();
        assert!(m[0] == 0b1000 || m[0] == 0b1001);
        check_model(&lits, &m);
        // NOT x == 0b0011: x = 0b1100.
        let lit = eq(Expr::Not(Box::new(var(0, 4))), cnst(0b0011, 4));
        let m = solve(std::slice::from_ref(&lit)).unwrap().unwrap();
        assert_eq!(m[0], 0b1100);
        check_model(&[lit], &m);
    }

    #[test]
    fn extract_is_solved() {
        // Extract bits 3..=2 of x == 0b10, and bits 1..=0 of x == 0b01:
        // x = 0b1001.
        let lits = vec![
            eq(Expr::Extract(3, 2, Box::new(var(0, 4))), cnst(0b10, 2)),
            eq(Expr::Extract(1, 0, Box::new(var(0, 4))), cnst(0b01, 2)),
        ];
        let m = solve(&lits).unwrap().unwrap();
        assert_eq!(m[0], 0b1001);
        check_model(&lits, &m);
    }

    #[test]
    fn disequality_is_solved() {
        // x == 3 with x == 5 is impossible; x != 3 with x != 5 is satisfiable.
        assert_eq!(
            solve(&[eq(var(0, 4), cnst(3, 4)), eq(var(0, 4), cnst(5, 4))]).unwrap(),
            None
        );
        let lits = vec![neq(var(0, 4), cnst(3, 4)), neq(var(0, 4), cnst(5, 4))];
        let m = solve(&lits).unwrap().unwrap();
        check_model(&lits, &m);
    }

    #[test]
    fn unsat_contradiction() {
        // x == 1 AND x == 2.
        assert_eq!(
            solve(&[eq(var(0, 4), cnst(1, 4)), eq(var(0, 4), cnst(2, 4))]).unwrap(),
            None
        );
    }

    #[test]
    fn unsupported_operations_error() {
        let mul = eq(
            Expr::Mul(Box::new(var(0, 4)), Box::new(var(1, 4))),
            cnst(6, 4),
        );
        assert_eq!(
            solve(&[mul]).unwrap_err(),
            BitvecError::UnsupportedOp("Mul")
        );
        let shl = eq(
            Expr::Shl(Box::new(var(0, 4)), Box::new(cnst(1, 4))),
            cnst(2, 4),
        );
        assert_eq!(
            solve(&[shl]).unwrap_err(),
            BitvecError::UnsupportedOp("Shl")
        );
    }

    #[test]
    fn width_errors() {
        assert_eq!(
            solve(&[eq(var(0, 4), var(1, 8))]).unwrap_err(),
            BitvecError::WidthMismatch(4, 8)
        );
        assert_eq!(
            solve(&[eq(var(0, 0), var(1, 4))]).unwrap_err(),
            BitvecError::BadWidth(0)
        );
        assert_eq!(
            solve(&[eq(var(0, 65), var(1, 4))]).unwrap_err(),
            BitvecError::BadWidth(65)
        );
        let bad = eq(Expr::Extract(7, 0, Box::new(var(0, 4))), cnst(0, 8));
        assert!(matches!(
            solve(&[bad]).unwrap_err(),
            BitvecError::BadExtract {
                hi: 7,
                lo: 0,
                width: 4
            }
        ));
    }

    #[test]
    fn sixteen_bit_arithmetic() {
        // x + 1000 == 50000 with 16-bit wrap-around: 50000 - 1000 = 49000.
        let lit = eq(
            Expr::Add(Box::new(var(0, 16)), Box::new(cnst(1000, 16))),
            cnst(50000, 16),
        );
        let m = solve(std::slice::from_ref(&lit)).unwrap().unwrap();
        assert_eq!(m[0], 49000);
        check_model(&[lit], &m);
    }

    #[test]
    fn two_variable_constraint() {
        // x + y == 6 AND x == 3 AND y == 3.
        let lits = vec![
            eq(
                Expr::Add(Box::new(var(0, 4)), Box::new(var(1, 4))),
                cnst(6, 4),
            ),
            eq(var(0, 4), cnst(3, 4)),
            eq(var(1, 4), cnst(3, 4)),
        ];
        let m = solve(&lits).unwrap().unwrap();
        assert_eq!(m[0], 3);
        assert_eq!(m[1], 3);
        check_model(&lits, &m);
    }

    #[test]
    fn equations_hold_for_every_found_model() {
        // A chain of operations: (x AND 0b1111) + 1 == (y OR 0b0000) - 2.
        let lits = vec![eq(
            Expr::Add(
                Box::new(Expr::And(
                    Box::new(var(0, 8)),
                    Box::new(cnst(0b1111_1111, 8)),
                )),
                Box::new(cnst(1, 8)),
            ),
            Expr::Sub(
                Box::new(Expr::Or(Box::new(var(1, 8)), Box::new(cnst(0, 8)))),
                Box::new(cnst(2, 8)),
            ),
        )];
        let m = solve(&lits).unwrap().unwrap();
        check_model(&lits, &m);
    }
}

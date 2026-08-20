//! A DPLL(T) driver for quantifier-free mixed formulas.
//!
//! The driver combines the Boolean core with the theory solvers:
//!
//! 1. Every distinct theory atom is abstracted to a Boolean variable, and
//!    the formula is converted to clauses (Tseitin encoding).
//! 2. The internal SAT solver produces a model.
//! 3. The atoms that the model makes true -- and the negations of those it
//!    makes false -- are handed to the matching theory solver, one theory at
//!    a time (difference, linear, integers, bitvectors).
//! 4. If a theory rejects the assignment, the driver learns the negation of
//!    that assignment as a new clause (naive learning: the whole offending
//!    set is blocked) and re-solves. Each learned clause eliminates at least
//!    one Boolean model, so the loop terminates.
//! 5. When every theory accepts, the formula is satisfiable; when the SAT
//!    core runs out of models, it is unsatisfiable.
//!
//! Strong assumptions, documented rather than hidden:
//!
//! - Every atom belongs to exactly one theory, and the theories do not share
//!   variables (no Nelson--Oppen combination): `Atom::Diff` uses the
//!   difference-logic numbering, `Atom::Linear` and `Atom::Integer` their
//!   own, and `Atom::Bitvec` the bitvector numbering.
//! - Linear equality atoms are rejected. Their negation is a disjunction
//!   (`sum > b` or `sum < b`), which a single theory check cannot decide;
//!   write `sum == b` as the two atoms `sum <= b` and `-sum <= -b` instead.
//!
//! ```
//! use smt::{check, Atom, Formula, Verdict};
//! use smt::difference::Constraint as Diff;
//!
//! // (x0 - x1 <= 2) OR (x1 - x0 <= -3): a task that takes at most 2 time
//! // units or at least 3. The second disjunct alone is satisfiable.
//! let f = Formula::Or(
//!     Box::new(Formula::Atom(Atom::Diff(Diff { x: 0, y: 1, c: 2 }))),
//!     Box::new(Formula::Atom(Atom::Diff(Diff { x: 1, y: 0, c: -3 }))),
//! );
//! assert_eq!(check(&f).unwrap(), Verdict::Sat);
//!
//! // (x0 - x1 <= 2 AND x1 - x0 <= -3) OR (0x <= -1):
//! // the first branch is a negative cycle, the second is arithmetically
//! // impossible, so the whole formula is unsatisfiable.
//! let g = Formula::Or(
//!     Box::new(Formula::And(
//!         Box::new(Formula::Atom(Atom::Diff(Diff { x: 0, y: 1, c: 2 }))),
//!         Box::new(Formula::Atom(Atom::Diff(Diff { x: 1, y: 0, c: -3 }))),
//!     )),
//!     Box::new(Formula::Atom(Atom::Integer(
//!         smt::integers::Constraint { coeffs: vec![0], b: -1 },
//!     ))),
//! );
//! assert_eq!(check(&g).unwrap(), Verdict::Unsat);
//! ```

use crate::bitvec;
use crate::difference;
use crate::integers;
use crate::linear;
use crate::sat;

/// A theory atom: one literal of the mixed signature.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Atom {
    /// A difference-logic constraint `x - y <= c`.
    Diff(difference::Constraint),
    /// A linear real constraint `sum <rel> b` (equalities are not allowed
    /// here, see the module documentation).
    Linear(linear::Constraint),
    /// An integer linear constraint `sum <= b`.
    Integer(integers::Constraint),
    /// A bitvector equation or disequation.
    Bitvec(bitvec::BoolExpr),
}

/// A quantifier-free Boolean formula over theory atoms.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Formula {
    /// A theory atom.
    Atom(Atom),
    /// Negation.
    Not(Box<Formula>),
    /// Conjunction.
    And(Box<Formula>, Box<Formula>),
    /// Disjunction.
    Or(Box<Formula>, Box<Formula>),
}

/// The outcome of [`check`].
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Verdict {
    /// A model exists: every theory accepted the Boolean assignment.
    Sat,
    /// No model exists: the SAT core exhausted all assignments.
    Unsat,
}

/// Why a mixed formula cannot be decided.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Error {
    /// A literal that a theory cannot express as a single constraint.
    UnsupportedNegation(String),
    /// A bitvector literal is malformed or uses an unsupported operation.
    Bitvec(bitvec::BitvecError),
}

impl From<bitvec::BitvecError> for Error {
    fn from(e: bitvec::BitvecError) -> Error {
        Error::Bitvec(e)
    }
}

impl std::fmt::Display for Error {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Error::UnsupportedNegation(msg) => write!(f, "{msg}"),
            Error::Bitvec(e) => write!(f, "{e}"),
        }
    }
}

impl std::error::Error for Error {}

/// Decide a quantifier-free mixed formula: `Ok(Sat)` or `Ok(Unsat)`, or an
/// error when the formula uses a construct outside the supported signature.
pub fn check(formula: &Formula) -> Result<Verdict, Error> {
    // Collect the distinct atoms; linear equality atoms are rejected here so
    // that no theory check ever has to decide their negation.
    let mut atoms: Vec<Atom> = vec![];
    collect(formula, &mut atoms)?;

    // Tseitin encoding: each subformula gets a fresh Boolean variable, with
    // clauses relating it to its children; the root is asserted true.
    let mut clauses: Vec<Vec<i32>> = vec![];
    let mut next_var = atoms.len();
    let root = tseitin(formula, &atoms, &mut clauses, &mut next_var);
    clauses.push(vec![root]);
    let num_vars = next_var;

    // DPLL(T) loop: SAT model, theory checks, naive conflict learning.
    let mut learned: Vec<Vec<i32>> = vec![];
    loop {
        let mut solver = sat::Solver::new(num_vars);
        for clause in &clauses {
            solver.add_clause(clause);
        }
        for clause in &learned {
            solver.add_clause(clause);
        }
        let Some(model) = solver.solve() else {
            return Ok(Verdict::Unsat);
        };

        // Split the atoms by theory, keeping each truth value: a false atom
        // still constrains its theory (through its negation).
        let mut diff: Vec<(usize, bool)> = vec![];
        let mut lin: Vec<(usize, bool)> = vec![];
        let mut int: Vec<(usize, bool)> = vec![];
        let mut bv: Vec<(usize, bool)> = vec![];
        for (i, atom) in atoms.iter().enumerate() {
            let holds = model[i];
            match atom {
                Atom::Diff(..) => diff.push((i, holds)),
                Atom::Linear(..) => lin.push((i, holds)),
                Atom::Integer(..) => int.push((i, holds)),
                Atom::Bitvec(..) => bv.push((i, holds)),
            }
        }

        if let Some(clause) = theory_conflict(&diff, &atoms)? {
            learned.push(clause);
            continue;
        }
        if let Some(clause) = theory_conflict(&lin, &atoms)? {
            learned.push(clause);
            continue;
        }
        if let Some(clause) = theory_conflict(&int, &atoms)? {
            learned.push(clause);
            continue;
        }
        if let Some(clause) = theory_conflict(&bv, &atoms)? {
            learned.push(clause);
            continue;
        }
        return Ok(Verdict::Sat);
    }
}

/// Walk the formula, collecting each distinct atom once. Rejects linear
/// equality atoms, whose negation is a disjunction no theory check can
/// decide (see the module documentation).
fn collect(formula: &Formula, atoms: &mut Vec<Atom>) -> Result<(), Error> {
    match formula {
        Formula::Atom(atom) => {
            if let Atom::Linear(c) = atom {
                if c.rel == linear::Rel::Eq {
                    return Err(Error::UnsupportedNegation(
                        "linear equality atoms are not supported in the driver; \
                         write `sum = b` as the two atoms `sum <= b` and `-sum <= -b`"
                            .to_string(),
                    ));
                }
            }
            if !atoms.contains(atom) {
                atoms.push(atom.clone());
            }
            Ok(())
        }
        Formula::Not(g) => collect(g, atoms),
        Formula::And(g, h) | Formula::Or(g, h) => {
            collect(g, atoms)?;
            collect(h, atoms)
        }
    }
}

/// Tseitin encoding: return the literal that stands for `formula` and append
/// the clauses that define it. `next` counts the auxiliary variables.
fn tseitin(
    formula: &Formula,
    atoms: &[Atom],
    clauses: &mut Vec<Vec<i32>>,
    next: &mut usize,
) -> i32 {
    match formula {
        Formula::Atom(atom) => {
            let i = atoms
                .iter()
                .position(|a| a == atom)
                .expect("atom collected");
            i as i32 + 1
        }
        Formula::Not(g) => {
            let g = tseitin(g, atoms, clauses, next);
            let v = fresh(next);
            clauses.push(vec![-v, -g]); // v -> not g
            clauses.push(vec![v, g]); // not g -> v
            v
        }
        Formula::And(g, h) => {
            let g = tseitin(g, atoms, clauses, next);
            let h = tseitin(h, atoms, clauses, next);
            let v = fresh(next);
            clauses.push(vec![-v, g]); // v -> g
            clauses.push(vec![-v, h]); // v -> h
            clauses.push(vec![v, -g, -h]); // g and h -> v
            v
        }
        Formula::Or(g, h) => {
            let g = tseitin(g, atoms, clauses, next);
            let h = tseitin(h, atoms, clauses, next);
            let v = fresh(next);
            clauses.push(vec![-v, g, h]); // v -> g or h
            clauses.push(vec![v, -g]); // g -> v
            clauses.push(vec![v, -h]); // h -> v
            v
        }
    }
}

fn fresh(next: &mut usize) -> i32 {
    let v = *next as i32 + 1;
    *next += 1;
    v
}

/// Check one theory's share of the model. Returns the clause to learn when
/// the theory rejects the assignment (the negation of the offending set), or
/// `None` when the theory accepts.
fn theory_conflict(lits: &[(usize, bool)], atoms: &[Atom]) -> Result<Option<Vec<i32>>, Error> {
    let Some(&(first, _)) = lits.first() else {
        return Ok(None); // the theory has no atoms in this formula
    };
    let unsat = match &atoms[first] {
        Atom::Diff(..) => {
            let mut cs = vec![];
            for &(i, holds) in lits {
                let c = match &atoms[i] {
                    Atom::Diff(c) => c,
                    _ => unreachable!("grouped by theory"),
                };
                // NOT (x - y <= c) is y - x <= -(c + 1) over the integers.
                cs.push(if holds {
                    *c
                } else {
                    difference::Constraint {
                        x: c.y,
                        y: c.x,
                        c: -c.c - 1,
                    }
                });
            }
            difference::solve(&cs).is_none()
        }
        Atom::Linear(..) => {
            let mut cs = vec![];
            for &(i, holds) in lits {
                let c = match &atoms[i] {
                    Atom::Linear(c) => c,
                    _ => unreachable!("grouped by theory"),
                };
                if holds {
                    cs.push(c.clone());
                } else {
                    let neg: Vec<i64> = c.coeffs.iter().map(|&v| -v).collect();
                    // NOT (sum <= b) is -sum < -b; NOT (sum < b) is -sum <= -b.
                    let rel = match c.rel {
                        linear::Rel::Le => linear::Rel::Lt,
                        linear::Rel::Lt => linear::Rel::Le,
                        linear::Rel::Eq => {
                            return Err(Error::UnsupportedNegation(
                                "linear equality atoms are not supported in the driver; \
                                 write `sum = b` as the two atoms `sum <= b` and \
                                 `-sum <= -b`"
                                    .to_string(),
                            ))
                        }
                    };
                    cs.push(linear::Constraint {
                        coeffs: neg,
                        b: -c.b,
                        rel,
                    });
                }
            }
            linear::solve(&cs).is_none()
        }
        Atom::Integer(..) => {
            let mut cs = vec![];
            for &(i, holds) in lits {
                let c = match &atoms[i] {
                    Atom::Integer(c) => c,
                    _ => unreachable!("grouped by theory"),
                };
                // NOT (sum <= b) is -sum <= -(b + 1) over the integers.
                cs.push(if holds {
                    c.clone()
                } else {
                    integers::Constraint {
                        coeffs: c.coeffs.iter().map(|&v| -v).collect(),
                        b: -c.b - 1,
                    }
                });
            }
            integers::solve(&cs).is_none()
        }
        Atom::Bitvec(..) => {
            let mut literals = vec![];
            for &(i, holds) in lits {
                let be = match &atoms[i] {
                    Atom::Bitvec(be) => be,
                    _ => unreachable!("grouped by theory"),
                };
                literals.push(if holds {
                    be.clone()
                } else {
                    match be {
                        bitvec::BoolExpr::Eq(a, b) => bitvec::BoolExpr::Neq(a.clone(), b.clone()),
                        bitvec::BoolExpr::Neq(a, b) => bitvec::BoolExpr::Eq(a.clone(), b.clone()),
                    }
                });
            }
            bitvec::solve(&literals)?.is_none()
        }
    };
    if unsat {
        // Learn: not all of these literals can be true at once.
        Ok(Some(
            lits.iter()
                .map(
                    |&(i, holds)| {
                        if holds {
                            -(i as i32 + 1)
                        } else {
                            i as i32 + 1
                        }
                    },
                )
                .collect(),
        ))
    } else {
        Ok(None)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn d(x: usize, y: usize, c: i64) -> Atom {
        Atom::Diff(difference::Constraint { x, y, c })
    }

    #[test]
    fn disjunction_of_satisfiable_atoms() {
        let f = Formula::Or(
            Box::new(Formula::Atom(d(0, 1, 2))),
            Box::new(Formula::Atom(d(1, 0, -3))),
        );
        assert_eq!(check(&f).unwrap(), Verdict::Sat);
    }

    #[test]
    fn conjunction_is_theory_checked() {
        // x0 - x1 <= 2 AND x1 - x0 <= -3: a negative cycle, unsat.
        let f = Formula::And(
            Box::new(Formula::Atom(d(0, 1, 2))),
            Box::new(Formula::Atom(d(1, 0, -3))),
        );
        assert_eq!(check(&f).unwrap(), Verdict::Unsat);
    }

    #[test]
    fn negation_is_theory_checked() {
        // NOT (x0 - x1 <= 2) AND NOT (x1 - x0 <= 2): x0 - x1 >= 3 and
        // x1 - x0 >= 3 at once: unsat.
        let f = Formula::And(
            Box::new(Formula::Not(Box::new(Formula::Atom(d(0, 1, 2))))),
            Box::new(Formula::Not(Box::new(Formula::Atom(d(1, 0, 2))))),
        );
        assert_eq!(check(&f).unwrap(), Verdict::Unsat);
        // NOT (x0 - x1 <= 2) alone: x0 - x1 >= 3, satisfiable.
        let g = Formula::Not(Box::new(Formula::Atom(d(0, 1, 2))));
        assert_eq!(check(&g).unwrap(), Verdict::Sat);
    }

    #[test]
    fn boolean_tautology_is_sat() {
        // (a OR NOT a) over a diff atom: satisfiable without the theory.
        let f = Formula::Or(
            Box::new(Formula::Atom(d(0, 1, 2))),
            Box::new(Formula::Not(Box::new(Formula::Atom(d(0, 1, 2))))),
        );
        assert_eq!(check(&f).unwrap(), Verdict::Sat);
    }

    #[test]
    fn boolean_contradiction_is_unsat() {
        // a AND NOT a: unsat without touching the theory.
        let f = Formula::And(
            Box::new(Formula::Atom(d(0, 1, 2))),
            Box::new(Formula::Not(Box::new(Formula::Atom(d(0, 1, 2))))),
        );
        assert_eq!(check(&f).unwrap(), Verdict::Unsat);
    }

    #[test]
    fn learning_visits_several_models() {
        // (x0 - x1 <= 2 AND x1 - x0 <= -3) OR (0x <= -1):
        // the first branch is a negative cycle, the second is a constant
        // contradiction; both Boolean models get rejected.
        let cycle = Formula::And(
            Box::new(Formula::Atom(d(0, 1, 2))),
            Box::new(Formula::Atom(d(1, 0, -3))),
        );
        let f = Formula::Or(
            Box::new(cycle),
            Box::new(Formula::Atom(Atom::Integer(integers::Constraint {
                coeffs: vec![0],
                b: -1,
            }))),
        );
        assert_eq!(check(&f).unwrap(), Verdict::Unsat);
    }

    #[test]
    fn mixed_difference_and_bitvector() {
        use crate::bitvec::{BoolExpr, Expr};
        // (x0 - x1 <= 2) AND (bv0 + 1 == 5): both theories accept.
        let bv = BoolExpr::Eq(
            Box::new(Expr::Add(
                Box::new(Expr::Var(0, 4)),
                Box::new(Expr::Const(1, 4)),
            )),
            Box::new(Expr::Const(5, 4)),
        );
        let f = Formula::And(
            Box::new(Formula::Atom(d(0, 1, 2))),
            Box::new(Formula::Atom(Atom::Bitvec(bv))),
        );
        assert_eq!(check(&f).unwrap(), Verdict::Sat);

        // (x0 - x1 <= 2 AND x1 - x0 <= -3) OR (bv0 + 1 == 5 AND bv0 == 1):
        // both disjuncts are theory-unsat, so the formula is unsat.
        let bv_contra = Formula::And(
            Box::new(Formula::Atom(Atom::Bitvec(BoolExpr::Eq(
                Box::new(Expr::Add(
                    Box::new(Expr::Var(0, 4)),
                    Box::new(Expr::Const(1, 4)),
                )),
                Box::new(Expr::Const(5, 4)),
            )))),
            Box::new(Formula::Atom(Atom::Bitvec(BoolExpr::Eq(
                Box::new(Expr::Var(0, 4)),
                Box::new(Expr::Const(1, 4)),
            )))),
        );
        let cycle = Formula::And(
            Box::new(Formula::Atom(d(0, 1, 2))),
            Box::new(Formula::Atom(d(1, 0, -3))),
        );
        let f = Formula::Or(Box::new(cycle), Box::new(bv_contra));
        assert_eq!(check(&f).unwrap(), Verdict::Unsat);
    }

    #[test]
    fn linear_atoms_are_supported() {
        use crate::linear::{Constraint as Lin, Rel};
        // (x + y <= 1) OR (x + y >= 3): satisfiable via the first atom.
        let f = Formula::Or(
            Box::new(Formula::Atom(Atom::Linear(Lin {
                coeffs: vec![1, 1],
                b: 1,
                rel: Rel::Le,
            }))),
            Box::new(Formula::Atom(Atom::Linear(Lin {
                coeffs: vec![-1, -1],
                b: -3,
                rel: Rel::Le,
            }))),
        );
        assert_eq!(check(&f).unwrap(), Verdict::Sat);
        // The conjunction of the two is unsat (x + y <= 1 AND x + y >= 3).
        let g = Formula::And(
            Box::new(Formula::Atom(Atom::Linear(Lin {
                coeffs: vec![1, 1],
                b: 1,
                rel: Rel::Le,
            }))),
            Box::new(Formula::Atom(Atom::Linear(Lin {
                coeffs: vec![-1, -1],
                b: -3,
                rel: Rel::Le,
            }))),
        );
        assert_eq!(check(&g).unwrap(), Verdict::Unsat);
    }

    #[test]
    fn linear_equality_atoms_are_rejected() {
        use crate::linear::{Constraint as Lin, Rel};
        let f = Formula::Atom(Atom::Linear(Lin {
            coeffs: vec![2],
            b: 1,
            rel: Rel::Eq,
        }));
        assert!(matches!(check(&f), Err(Error::UnsupportedNegation(_))));
    }

    #[test]
    fn integer_atoms_are_supported() {
        use crate::integers::Constraint as Int;
        // (2x >= 1) AND (2x <= 1): no integer x, unsat.
        let f = Formula::And(
            Box::new(Formula::Atom(Atom::Integer(Int {
                coeffs: vec![-2],
                b: -1,
            }))),
            Box::new(Formula::Atom(Atom::Integer(Int {
                coeffs: vec![2],
                b: 1,
            }))),
        );
        assert_eq!(check(&f).unwrap(), Verdict::Unsat);
    }
}

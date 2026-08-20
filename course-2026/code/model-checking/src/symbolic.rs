//! A pedagogical symbolic model-checking engine.
//!
//! Sets of states are represented **as Boolean formulas** rather than
//! explicit state lists, and the transition relation is a formula over
//! the current bits and the next bits (variable `i` of the next state is
//! `nvars + i`). Pre-image operators are implemented by *quantifier
//! elimination by enumeration*: `∃ next. trans ∧ set[next]` is expanded
//! into one disjunct per next-state assignment, and every operator
//! simplifies eagerly. This is deliberately NOT a BDD package: formulas
//! can blow up exponentially, and all operations enumerate the whole
//! state space. It exists to show the fixed-point structure of symbolic
//! reachability — `EF p` and `AG p` as least/greatest fixed points over
//! formulas — on small (2–6 bit) models.
//!
//! ```
//! use model_checking::symbolic::{BoolExpr as B, System, sat_count};
//!
//! // A 2-bit saturating counter: 00 -> 01 -> 10 -> 11 -> 11.
//! let x = 0; let y = 1;    // current bits
//! let x1 = 2; let y1 = 3;  // next bits
//! let trans = B::and(
//!     B::iff(B::Var(x1), B::or(B::Var(x), B::Var(y))),
//!     B::iff(B::Var(y1), B::or(B::Var(x), B::not(B::Var(y)))),
//! );
//! let sys = System {
//!     nvars: 2,
//!     init: B::and(B::not(B::Var(x)), B::not(B::Var(y))),
//!     trans,
//! };
//!
//! // EF top, by least-fixed-point iteration over formulas: Y = p ∨ pre(Y).
//! let top = B::and(B::Var(x), B::Var(y));
//! let reach = sys.ef(&top);
//! assert_eq!(sat_count(&reach, 2), 4); // every state reaches 11
//!
//! // AG top, by greatest-fixed-point iteration: Y = p ∧ pre∀(Y).
//! let always = sys.ag(&top);
//! assert_eq!(sat_count(&always, 2), 1); // only 11 keeps top forever
//! ```

/// A Boolean formula over state bits.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum BoolExpr {
    /// The constant.
    Const(bool),
    /// A state bit, indexed `0..nvars` (current) or `nvars..2·nvars`
    /// (next).
    Var(usize),
    /// Negation.
    Not(Box<BoolExpr>),
    /// Conjunction.
    And(Box<BoolExpr>, Box<BoolExpr>),
    /// Disjunction.
    Or(Box<BoolExpr>, Box<BoolExpr>),
}

impl BoolExpr {
    /// A state bit.
    pub fn var(i: usize) -> BoolExpr {
        BoolExpr::Var(i)
    }

    /// The constant `true`.
    pub fn t() -> BoolExpr {
        BoolExpr::Const(true)
    }

    /// The constant `false`.
    pub fn f() -> BoolExpr {
        BoolExpr::Const(false)
    }

    /// Negation, simplified.
    pub fn not(a: BoolExpr) -> BoolExpr {
        simplify(BoolExpr::Not(Box::new(a)))
    }

    /// Conjunction, simplified.
    pub fn and(a: BoolExpr, b: BoolExpr) -> BoolExpr {
        simplify(BoolExpr::And(Box::new(a), Box::new(b)))
    }

    /// Disjunction, simplified.
    pub fn or(a: BoolExpr, b: BoolExpr) -> BoolExpr {
        simplify(BoolExpr::Or(Box::new(a), Box::new(b)))
    }

    /// `a -> b`, simplified.
    pub fn imp(a: BoolExpr, b: BoolExpr) -> BoolExpr {
        BoolExpr::or(BoolExpr::not(a), b)
    }

    /// `a <-> b`, simplified.
    pub fn iff(a: BoolExpr, b: BoolExpr) -> BoolExpr {
        BoolExpr::and(BoolExpr::imp(a.clone(), b.clone()), BoolExpr::imp(b, a))
    }

    /// `a ⊕ b`, simplified.
    pub fn xor(a: BoolExpr, b: BoolExpr) -> BoolExpr {
        BoolExpr::or(
            BoolExpr::and(a.clone(), BoolExpr::not(b.clone())),
            BoolExpr::and(BoolExpr::not(a), b),
        )
    }

    /// Evaluate the formula over a bit vector (`bits[i]` is the value of
    /// bit `i`).
    pub fn eval(&self, bits: &[bool]) -> bool {
        match self {
            BoolExpr::Const(b) => *b,
            BoolExpr::Var(i) => bits[*i],
            BoolExpr::Not(a) => !a.eval(bits),
            BoolExpr::And(a, b) => a.eval(bits) && b.eval(bits),
            BoolExpr::Or(a, b) => a.eval(bits) || b.eval(bits),
        }
    }
}

/// Push constants through the formula (and cancel double negations).
fn simplify(f: BoolExpr) -> BoolExpr {
    match f {
        BoolExpr::Not(a) => match *a {
            BoolExpr::Const(b) => BoolExpr::Const(!b),
            BoolExpr::Not(x) => simplify(*x),
            x => BoolExpr::Not(Box::new(simplify(x))),
        },
        BoolExpr::And(a, b) => {
            let (a, b) = (simplify(*a), simplify(*b));
            match (&a, &b) {
                (BoolExpr::Const(false), _) | (_, BoolExpr::Const(false)) => BoolExpr::Const(false),
                (BoolExpr::Const(true), _) => b,
                (_, BoolExpr::Const(true)) => a,
                _ if a == b => a,
                _ => BoolExpr::And(Box::new(a), Box::new(b)),
            }
        }
        BoolExpr::Or(a, b) => {
            let (a, b) = (simplify(*a), simplify(*b));
            match (&a, &b) {
                (BoolExpr::Const(true), _) | (_, BoolExpr::Const(true)) => BoolExpr::Const(true),
                (BoolExpr::Const(false), _) => b,
                (_, BoolExpr::Const(false)) => a,
                _ if a == b => a,
                _ => BoolExpr::Or(Box::new(a), Box::new(b)),
            }
        }
        other => other,
    }
}

/// A synchronous symbolic system: `nvars` state bits, an initial-state
/// formula, and a transition relation over current and next bits.
#[derive(Debug, Clone)]
pub struct System {
    /// The number of state bits.
    pub nvars: usize,
    /// A formula over the current bits: the initial states.
    pub init: BoolExpr,
    /// A formula over the current bits `0..nvars` and the next bits
    /// `nvars..2·nvars`: the transition relation.
    pub trans: BoolExpr,
}

impl System {
    /// The predecessor image of `set` under one transition:
    /// `{ s : ∃ t ∈ set, (s, t) ∈ trans }`, as a formula over the
    /// current bits. `set` is a formula over the *current* bits; it is
    /// shifted onto the next bits before the existential quantification.
    /// Computed by enumerating the next-state assignments.
    pub fn pre_exists(&self, set: &BoolExpr) -> BoolExpr {
        let set_next = shift_vars(set, self.nvars);
        let mut out = BoolExpr::f();
        for mask in 0..(1usize << self.nvars) {
            let mut conjunct = self.trans.clone();
            let mut next_set = set_next.clone();
            for i in 0..self.nvars {
                let bit = (mask >> i) & 1 == 1;
                let next_var = self.nvars + i;
                conjunct = subst(&conjunct, next_var, bit);
                next_set = subst(&next_set, next_var, bit);
            }
            out = BoolExpr::or(out, BoolExpr::and(conjunct, next_set));
        }
        out
    }

    /// The universal predecessor image of `set`:
    /// `{ s : every successor of s lies in set }` (vacuously true at dead
    /// ends), as a formula over the current bits.
    pub fn pre_forall(&self, set: &BoolExpr) -> BoolExpr {
        BoolExpr::not(self.pre_exists(&BoolExpr::not(set.clone())))
    }

    /// `EF p` — the least fixed point `Y = p ∨ pre_exists(Y)`, iterated
    /// over formulas until the set of satisfying states stops growing.
    pub fn ef(&self, p: &BoolExpr) -> BoolExpr {
        let mut y = p.clone();
        loop {
            let next = BoolExpr::or(p.clone(), self.pre_exists(&y));
            if equivalent(&next, &y, self.nvars) {
                return y;
            }
            y = next;
        }
    }

    /// `AG p` — the greatest fixed point `Y = p ∧ pre_forall(Y)`,
    /// iterated over formulas until the set of satisfying states stops
    /// shrinking.
    pub fn ag(&self, p: &BoolExpr) -> BoolExpr {
        let mut y = BoolExpr::t();
        loop {
            let next = BoolExpr::and(p.clone(), self.pre_forall(&y));
            if equivalent(&next, &y, self.nvars) {
                return y;
            }
            y = next;
        }
    }
}

/// Shift every variable index by `n` (used to move a current-state
/// formula onto the next-state variables).
fn shift_vars(f: &BoolExpr, n: usize) -> BoolExpr {
    match f {
        BoolExpr::Const(_) => f.clone(),
        BoolExpr::Var(i) => BoolExpr::Var(i + n),
        BoolExpr::Not(a) => BoolExpr::not(shift_vars(a, n)),
        BoolExpr::And(a, b) => BoolExpr::and(shift_vars(a, n), shift_vars(b, n)),
        BoolExpr::Or(a, b) => BoolExpr::or(shift_vars(a, n), shift_vars(b, n)),
    }
}

/// Substitute bit `var` by the constant `val`, simplified.
fn subst(f: &BoolExpr, var: usize, val: bool) -> BoolExpr {
    match f {
        BoolExpr::Const(_) => f.clone(),
        BoolExpr::Var(i) => {
            if *i == var {
                BoolExpr::Const(val)
            } else {
                f.clone()
            }
        }
        BoolExpr::Not(a) => BoolExpr::not(subst(a, var, val)),
        BoolExpr::And(a, b) => BoolExpr::and(subst(a, var, val), subst(b, var, val)),
        BoolExpr::Or(a, b) => BoolExpr::or(subst(a, var, val), subst(b, var, val)),
    }
}

/// Are the two formulas satisfied by exactly the same bit vectors?
pub fn equivalent(a: &BoolExpr, b: &BoolExpr, nvars: usize) -> bool {
    (0..(1usize << nvars)).all(|mask| {
        let bits = bits_of(mask, nvars);
        a.eval(&bits) == b.eval(&bits)
    })
}

/// The number of bit vectors that satisfy `f`.
pub fn sat_count(f: &BoolExpr, nvars: usize) -> usize {
    (0..(1usize << nvars))
        .filter(|&mask| f.eval(&bits_of(mask, nvars)))
        .count()
}

/// All bit vectors that satisfy `f`, each as a `Vec<bool>` indexed by
/// bit number.
pub fn models(f: &BoolExpr, nvars: usize) -> Vec<Vec<bool>> {
    (0..(1usize << nvars))
        .filter(|&mask| f.eval(&bits_of(mask, nvars)))
        .map(|mask| bits_of(mask, nvars))
        .collect()
}

fn bits_of(mask: usize, nvars: usize) -> Vec<bool> {
    (0..nvars).map(|i| (mask >> i) & 1 == 1).collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::symbolic::BoolExpr as B;

    /// The 2-bit saturating counter from the doctest.
    fn counter() -> System {
        let trans = B::and(
            B::iff(B::Var(2), B::or(B::Var(0), B::Var(1))),
            B::iff(B::Var(3), B::or(B::Var(0), B::not(B::Var(1)))),
        );
        System {
            nvars: 2,
            init: B::and(B::not(B::Var(0)), B::not(B::Var(1))),
            trans,
        }
    }

    fn top() -> BoolExpr {
        B::and(B::Var(0), B::Var(1))
    }

    #[test]
    fn eval_and_sat_count() {
        let p = B::Var(0);
        let q = B::Var(1);
        assert!(p.eval(&[true, false]));
        assert!(!q.eval(&[true, false]));
        assert!(B::or(p.clone(), q.clone()).eval(&[false, true]));
        assert!(B::not(B::and(p.clone(), q.clone())).eval(&[false, false]));

        assert_eq!(sat_count(&B::or(p.clone(), q.clone()), 2), 3);
        assert_eq!(sat_count(&B::and(p, B::not(q)), 2), 1);
        assert_eq!(sat_count(&B::or(B::Var(0), B::not(B::Var(0))), 2), 4);
        assert_eq!(sat_count(&B::and(B::Var(0), B::not(B::Var(0))), 2), 0);
    }

    #[test]
    fn pre_exists_is_one_step_backwards_reachability() {
        let sys = counter();
        // States with a successor at the top: 10 (-> 11) and 11 (-> 11).
        // bits_of(mask, 2) lists bit 0 first: state 10 = bits [1, 0]
        // corresponds to mask 1, state 11 to mask 3.
        let pre = sys.pre_exists(&top());
        assert_eq!(sat_count(&pre, 2), 2);
        assert!(pre.eval(&bits_of(1, 2))); // state 10
        assert!(pre.eval(&bits_of(3, 2))); // state 11
        assert!(!pre.eval(&bits_of(0, 2)));
    }

    #[test]
    fn pre_forall_is_the_dual() {
        let sys = counter();
        // 10's only successor is 11, and 11's is 11: both states qualify.
        // State 01 (mask 2) goes to 10, which is not top.
        let all = sys.pre_forall(&top());
        assert_eq!(sat_count(&all, 2), 2);
        assert!(!all.eval(&bits_of(2, 2))); // state 01
    }

    #[test]
    fn ef_reaches_every_state() {
        let sys = counter();
        assert_eq!(sat_count(&sys.ef(&top()), 2), 4);
    }

    #[test]
    fn ag_keeps_only_the_saturating_state() {
        let sys = counter();
        let always = sys.ag(&top());
        assert_eq!(sat_count(&always, 2), 1);
        assert!(always.eval(&bits_of(3, 2)));
        assert!(!always.eval(&bits_of(1, 2))); // 10 -> 11: p fails at 10
    }

    #[test]
    fn models_lists_satisfying_vectors() {
        let p = B::Var(0);
        let q = B::Var(1);
        let f = B::or(p, q);
        let ms = models(&f, 2);
        assert_eq!(ms.len(), 3);
        assert!(ms.contains(&vec![false, true]));
        assert!(ms.contains(&vec![true, false]));
        assert!(ms.contains(&vec![true, true]));
    }

    #[test]
    fn iteration_converges_by_semantic_comparison() {
        // One bit that toggles: 0 -> 1 -> 0. From state 0, p = "bit 1"
        // is reached in one step, so EF p needs one iteration.
        let trans = B::iff(B::Var(1), B::not(B::Var(0)));
        let sys = System {
            nvars: 1,
            init: B::f(),
            trans,
        };
        let p = B::Var(0);
        let mut y = p.clone();
        let mut rounds = 0;
        loop {
            let next = B::or(p.clone(), sys.pre_exists(&y));
            if equivalent(&next, &y, 1) {
                break;
            }
            y = next;
            rounds += 1;
        }
        assert_eq!(rounds, 1);
        assert_eq!(sat_count(&y, 1), 2);
    }
}

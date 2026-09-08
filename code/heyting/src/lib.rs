//! Finite Heyting algebras and intuitionistic validity.
//!
//! A Heyting algebra is a distributive lattice with a relative pseudo-complement `a -> b`: the weakest `c` with `a ∧ c <= b`.
//! The formulas valid in *every* Heyting algebra are exactly the theorems of intuitionistic logic, so finite Heyting algebras are the standard counterexample semantics: a formula that fails in one of them is not intuitionistically provable.
//!
//! This crate has five layers:
//!
//! - [`Value`], the three-element algebra `{0, 1/2, 1}`, the simplest non-Boolean Heyting algebra and the flagship example.
//!   It stays first-class: `!!a = a` fails at `1/2`, so the law of excluded middle is not a tautology.
//!
//! ```
//! use heyting::Value;
//! use std::ops::Not;
//!
//! // Law of excluded middle fails: 1/2 ∨ ¬1/2 = 1/2 ≠ 1.
//! assert_ne!(Value::Mid.join(!Value::Mid), Value::Top);
//!
//! // But its double negation is a tautology: ¬¬(1/2 ∨ ¬1/2) = 1.
//! let lem = Value::Mid.join(!Value::Mid);
//! assert_eq!(lem.not().not(), Value::Top);
//! ```
//!
//! - [`Algebra`], a general table-driven finite Heyting algebra: elements `0..n` with meet/join/implies tables, bottom and top.
//!   It can be built from lattice tables ([`Algebra::from_meet_join`]) or from a small poset via its downsets ([`Poset::downset_algebra`]), and Boolean algebras are constructed with [`bool_algebra`].
//!
//! - [`Poset`] and the downset (order ideal) construction, the key link between partial orders and intuitionistic semantics: the downsets of a poset form a Heyting algebra, and every finite Heyting algebra is (up to isomorphism) a subalgebra of one of these.
//!
//! - [`Formula`], a tiny propositional formula type (atoms, and/or/implies/not/top/bottom) evaluated in any [`Algebra`] under a valuation.
//!
//! - [`valid`], an exhaustive validity check over all finite Heyting algebras with up to 5 elements, plus larger algebras from the same enumeration (up to 16 elements).
//!   It is a small-scale decision procedure for intuitionistic validity.
//!
//! ```
//! use heyting::{Formula, valid};
//!
//! let p = Formula::atom(0);
//! let lem = p.clone().or(!p.clone());            // p ∨ ¬p
//! let dne = (!(!p.clone())).implies(p.clone());  // ¬¬p -> p
//! let _ = &p;
//!
//! assert!(!valid(&lem), "excluded middle is not intuitionistically valid");
//! assert!(!valid(&dne), "double-negation elimination is not intuitionistically valid");
//! assert!(valid(&p.clone().implies(!(!p.clone()))), "p -> ¬¬p is valid");
//! ```

pub mod algebra;
pub mod formula;
pub mod poset;
pub mod valid;

pub use algebra::{bool_algebra, chain_three, Algebra};
pub use formula::{all_valuations, Formula};
pub use poset::Poset;
pub use valid::{all_finite_heyting_algebras, valid, valid_in};

use std::ops::Not;

/// Elements of the three-element Heyting algebra, ordered `Bot < Mid < Top`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum Value {
    /// Falsehood, `0`.
    Bot,
    /// "Not yet constructed", `1/2`.
    Mid,
    /// Truth, `1`.
    Top,
}

impl Value {
    /// Meet (greatest lower bound): `min`.
    pub fn meet(self, other: Value) -> Value {
        self.min(other)
    }

    /// Join (least upper bound): `max`.
    pub fn join(self, other: Value) -> Value {
        self.max(other)
    }

    /// Relative pseudo-complement: `a -> b` is `Top` when `a <= b`, else `b`.
    pub fn implies(self, other: Value) -> Value {
        if self <= other {
            Value::Top
        } else {
            other
        }
    }
}

/// Negation: `!a = a -> Bot`.
impl Not for Value {
    type Output = Value;

    fn not(self) -> Value {
        self.implies(Value::Bot)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn double_negation_fails_at_mid() {
        // !!(1/2) = !(!(1/2)) = !(0) = 1, so !!(1/2) = 1 ≠ 1/2.
        assert_eq!(!Value::Mid, Value::Bot);
        assert_eq!(!Value::Mid.not(), Value::Top);
        assert_ne!(!Value::Mid.not(), Value::Mid);
    }

    #[test]
    fn excluded_middle_not_tautology() {
        // p ∨ ¬p = 1/2 for p = 1/2.
        assert_eq!(Value::Mid.join(!Value::Mid), Value::Mid);
        // For p = Bot and p = Top, LEM holds.
        assert_eq!(Value::Bot.join(!Value::Bot), Value::Top);
        assert_eq!(Value::Top.join(!Value::Top), Value::Top);
    }

    #[test]
    fn double_negation_of_lem_is_tautology() {
        // !!(p ∨ !p) = 1 for every p.
        for p in [Value::Bot, Value::Mid, Value::Top] {
            let lem = p.join(!p);
            assert_eq!(lem.not().not(), Value::Top);
        }
    }

    #[test]
    fn boolean_case_is_a_sublattice() {
        // On {Bot, Top}, negation is an involution: Boolean algebra.
        assert_eq!(Value::Bot.not().not(), Value::Bot);
        assert_eq!(Value::Top.not().not(), Value::Top);
    }
}

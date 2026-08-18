//! The three-element Heyting algebra.
//!
//! A Heyting algebra is a distributive lattice with a relative
//! pseudo-complement `a -> b`. The three-element algebra `{0, 1/2, 1}` is the
//! simplest non-Boolean one: `!!a = a` fails at `1/2`, so the law of excluded
//! middle is not a tautology.
//!
//! ```
//! use heyting::Value;
//!
//! // Law of excluded middle fails: 1/2 ∨ ¬1/2 = 1/2 ≠ 1.
//! assert_ne!(Value::Mid.join(!Value::Mid), Value::Top);
//!
//! // But its double negation is a tautology: ¬¬(1/2 ∨ ¬1/2) = 1.
//! let lem = Value::Mid.join(!Value::Mid);
//! assert_eq!(!!lem, Value::Top);
//! ```

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

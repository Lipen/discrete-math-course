//! Goals: what a logic program is asked to prove.
//!
//! A query is a goal, and the body of a rule is a goal.
//! The solver reduces a goal to the empty goal by resolving its leftmost atom against program clauses.

use std::fmt::{self, Display};

use crate::term::Term;

/// A goal: an atomic call, a conjunction of subgoals, or the empty goal.
///
/// The body of a fact is the empty goal `True`.
/// A query like `?- parent(X, bob).` is `Call(parent(_0, bob))`, and a rule body like `parent(X, Z), ancestor(Z, Y)` is a conjunction.
///
/// ```
/// use prolog::term::Term;
/// use prolog::goal::Goal;
///
/// let g = Goal::conj(vec![
///     Goal::call(Term::struct_("parent", vec![Term::var(0), Term::var(2)])),
///     Goal::call(Term::struct_("ancestor", vec![Term::var(2), Term::var(1)])),
/// ]);
/// assert_eq!(g.to_string(), "parent(_0, _2), ancestor(_2, _1)");
/// ```
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Goal {
    /// The empty goal: already satisfied, the body of a fact.
    True,
    /// An atomic goal: prove this term against the program.
    Call(Term),
    /// Prove every subgoal, left to right.
    Conj(Vec<Goal>),
}

impl Goal {
    /// The empty goal.
    ///
    /// ```
    /// use prolog::goal::Goal;
    /// assert!(Goal::true_().is_empty());
    /// ```
    pub fn true_() -> Self {
        Goal::True
    }

    /// An atomic goal.
    ///
    /// ```
    /// use prolog::goal::Goal;
    /// use prolog::term::Term;
    /// let g = Goal::call(Term::atom("alice"));
    /// assert_eq!(g.to_string(), "alice");
    /// ```
    pub fn call(term: Term) -> Self {
        Goal::Call(term)
    }

    /// A conjunction of goals, flattened and simplified.
    ///
    /// An empty list of goals is `True`, and a single goal is that goal itself.
    ///
    /// ```
    /// use prolog::goal::Goal;
    /// use prolog::term::Term;
    /// let g = Goal::conj(vec![
    ///     Goal::call(Term::atom("p")),
    ///     Goal::true_(),
    /// ]);
    /// assert_eq!(g.to_string(), "p");
    /// ```
    pub fn conj(goals: Vec<Goal>) -> Self {
        let mut flat = Vec::new();
        for goal in goals {
            match goal {
                Goal::True => {}
                Goal::Conj(inner) => flat.extend(inner),
                other => flat.push(other),
            }
        }
        match flat.len() {
            0 => Goal::True,
            1 => flat.into_iter().next().expect("one element"),
            _ => Goal::Conj(flat),
        }
    }

    /// Whether this is the empty goal.
    ///
    /// ```
    /// use prolog::goal::Goal;
    /// use prolog::term::Term;
    /// assert!(Goal::true_().is_empty());
    /// assert!(!Goal::call(Term::atom("p")).is_empty());
    /// ```
    pub fn is_empty(&self) -> bool {
        matches!(self, Goal::True)
    }
}

impl Display for Goal {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Goal::True => write!(f, "true"),
            Goal::Call(term) => write!(f, "{}", term),
            Goal::Conj(goals) => {
                let parts = goals
                    .iter()
                    .map(ToString::to_string)
                    .collect::<Vec<_>>()
                    .join(", ");
                write!(f, "{}", parts)
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn conjunction_flattens() {
        let inner = Goal::conj(vec![
            Goal::call(Term::atom("a")),
            Goal::call(Term::atom("b")),
        ]);
        let g = Goal::conj(vec![inner, Goal::call(Term::atom("c"))]);
        assert_eq!(g.to_string(), "a, b, c");
    }

    #[test]
    fn true_goal_is_absorbed() {
        let g = Goal::conj(vec![Goal::true_(), Goal::call(Term::atom("a"))]);
        assert_eq!(g.to_string(), "a");
    }
}

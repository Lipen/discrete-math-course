//! Substitutions: finite maps from variables to terms.
//!
//! A substitution is the answer that a logic-programming query produces and
//! the instrument that unification builds. Applying a substitution replaces
//! every bound variable in a term by its binding.

use std::collections::HashMap;

use crate::goal::Goal;
use crate::term::Term;

/// A substitution: a finite map from variable ids to terms.
///
/// For example, the substitution `{X -> alice, Y -> f(Z)}` is the map
/// `{0 -> alice, 1 -> f(_2)}` when `X = 0`, `Y = 1`, and `Z = 2`.
pub type Subst = HashMap<usize, Term>;

/// Apply a substitution to a term, replacing bound variables.
///
/// The application is recursive: a variable bound to a term that itself
/// contains bound variables is resolved all the way down.
///
/// ```
/// use prolog::term::Term;
/// use prolog::subst::{Subst, apply};
///
/// let mut subst = Subst::new();
/// subst.insert(0, Term::atom("alice"));
/// subst.insert(1, Term::struct_("f", vec![Term::var(2)]));
/// let term = Term::struct_("g", vec![Term::var(0), Term::var(1)]);
/// assert_eq!(apply(&term, &subst).to_string(), "g(alice, f(_2))");
/// ```
pub fn apply(term: &Term, subst: &Subst) -> Term {
    match term {
        Term::Var(id) => match subst.get(id) {
            Some(bound) => apply(bound, subst),
            None => term.clone(),
        },
        Term::Struct(functor, args) => {
            let new_args = args.iter().map(|arg| apply(arg, subst)).collect();
            Term::Struct(functor.clone(), new_args)
        }
        Term::Atom(_) => term.clone(),
    }
}

/// Apply a substitution to every atom of a goal.
///
/// Used by the solver to instantiate the current goal with the bindings
/// accumulated so far.
///
/// ```
/// use prolog::term::Term;
/// use prolog::goal::Goal;
/// use prolog::subst::{Subst, apply_goal};
///
/// let mut subst = Subst::new();
/// subst.insert(0, Term::atom("alice"));
/// let goal = Goal::call(Term::struct_("parent", vec![Term::var(0), Term::var(1)]));
/// assert_eq!(apply_goal(&goal, &subst).to_string(), "parent(alice, _1)");
/// ```
pub fn apply_goal(goal: &Goal, subst: &Subst) -> Goal {
    match goal {
        Goal::True => Goal::True,
        Goal::Call(term) => Goal::Call(apply(term, subst)),
        Goal::Conj(goals) => Goal::Conj(goals.iter().map(|g| apply_goal(g, subst)).collect()),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn apply_is_recursive() {
        let mut subst = Subst::new();
        subst.insert(0, Term::var(1));
        subst.insert(1, Term::atom("x"));
        // _0 -> _1 -> x, resolved in one pass.
        assert_eq!(apply(&Term::var(0), &subst), Term::atom("x"));
    }

    #[test]
    fn unbound_variable_survives() {
        let subst = Subst::new();
        assert_eq!(apply(&Term::var(7), &subst), Term::var(7));
    }
}

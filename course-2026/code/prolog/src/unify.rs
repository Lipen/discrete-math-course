//! Unification: solving equations between terms.
//!
//! Two terms unify when there is a substitution that makes them equal.
//! Unification is the single engine of Prolog: matching a goal against a
//! clause head is one call to `unify`.

use std::fmt::{self, Display};

use crate::subst::{apply, Subst};
use crate::term::Term;

/// Why two terms could not be unified.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum UnifyError {
    /// The terms have different structure: different constants, functors,
    /// or arities.
    Mismatch,
    /// Binding a variable to a term would create a cycle: the variable
    /// occurs inside the term (the occurs check).
    OccursCheck { var: usize, term: Term },
}

impl Display for UnifyError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            UnifyError::Mismatch => write!(f, "cannot unify: different structure"),
            UnifyError::OccursCheck { var, term } => {
                write!(
                    f,
                    "occurs check: variable _{} would be bound to {}",
                    var, term
                )
            }
        }
    }
}

/// Unify two terms, extending `subst` into a common unifier.
///
/// This is Robinson's algorithm (1965) with the occurs check: a variable is
/// never bound to a term that contains it. On success the substitution maps
/// both terms to one and the same term; on failure the reason is returned.
/// A failure does not roll back bindings already made, so `subst` may be
/// left partially extended.
///
/// ```
/// use prolog::term::Term;
/// use prolog::unify::{unify, UnifyError};
/// use prolog::subst::Subst;
///
/// // f(_0, _1) and f(a, _2) unify: {_0 -> a, _1 -> _2}.
/// let mut subst = Subst::new();
/// let t1 = Term::struct_("f", vec![Term::var(0), Term::var(1)]);
/// let t2 = Term::struct_("f", vec![Term::atom("a"), Term::var(2)]);
/// assert!(unify(&t1, &t2, &mut subst).is_ok());
/// assert_eq!(subst[&0], Term::atom("a"));
/// assert_eq!(subst[&1], Term::var(2));
///
/// // _0 = f(_0) must fail: the occurs check rejects a cycle.
/// let mut subst = Subst::new();
/// let err = unify(&Term::var(0), &Term::struct_("f", vec![Term::var(0)]), &mut subst)
///     .unwrap_err();
/// assert_eq!(
///     err,
///     UnifyError::OccursCheck { var: 0, term: Term::struct_("f", vec![Term::var(0)]) }
/// );
/// ```
pub fn unify(t1: &Term, t2: &Term, subst: &mut Subst) -> Result<(), UnifyError> {
    let t1 = apply(t1, subst);
    let t2 = apply(t2, subst);
    match (&t1, &t2) {
        (Term::Var(a), Term::Var(b)) if a == b => Ok(()),
        (Term::Var(a), t) => bind(*a, t, subst),
        (t, Term::Var(a)) => bind(*a, t, subst),
        (Term::Atom(a), Term::Atom(b)) if a == b => Ok(()),
        (Term::Struct(f, args1), Term::Struct(g, args2))
            if f == g && args1.len() == args2.len() =>
        {
            for (a, b) in args1.iter().zip(args2.iter()) {
                unify(a, b, subst)?;
            }
            Ok(())
        }
        _ => Err(UnifyError::Mismatch),
    }
}

/// Bind a variable to a term, rejecting cyclic bindings.
///
/// The occurs check consults the variable against the fully applied term,
/// so a binding like `_0 -> _1` followed by `_1 -> f(_0)` is also caught.
fn bind(var: usize, term: &Term, subst: &mut Subst) -> Result<(), UnifyError> {
    if term.contains(var) {
        return Err(UnifyError::OccursCheck {
            var,
            term: term.clone(),
        });
    }
    subst.insert(var, term.clone());
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn var(id: usize) -> Term {
        Term::var(id)
    }

    #[test]
    fn identical_variables_need_no_binding() {
        let mut subst = Subst::new();
        assert!(unify(&var(0), &var(0), &mut subst).is_ok());
        assert!(subst.is_empty());
    }

    #[test]
    fn distinct_constants_mismatch() {
        let mut subst = Subst::new();
        assert_eq!(
            unify(&Term::atom("a"), &Term::atom("b"), &mut subst),
            Err(UnifyError::Mismatch)
        );
    }

    #[test]
    fn arity_mismatch_fails() {
        let mut subst = Subst::new();
        let t1 = Term::struct_("f", vec![Term::atom("a")]);
        let t2 = Term::struct_("f", vec![Term::atom("a"), Term::atom("b")]);
        assert_eq!(unify(&t1, &t2, &mut subst), Err(UnifyError::Mismatch));
    }

    #[test]
    fn occurs_check_through_an_existing_binding() {
        // _0 -> _1, then unify _1 with f(_0): the cycle is indirect.
        let mut subst = Subst::new();
        subst.insert(0, var(1));
        let err = unify(&var(1), &Term::struct_("f", vec![var(0)]), &mut subst).unwrap_err();
        assert!(matches!(err, UnifyError::OccursCheck { .. }));
    }

    #[test]
    fn nested_unification_propagates() {
        let mut subst = Subst::new();
        let t1 = Term::struct_("g", vec![var(0), Term::struct_("h", vec![var(0)])]);
        let t2 = Term::struct_("g", vec![Term::atom("a"), var(1)]);
        assert!(unify(&t1, &t2, &mut subst).is_ok());
        assert_eq!(subst[&0], Term::atom("a"));
        assert_eq!(subst[&1], Term::struct_("h", vec![Term::atom("a")]));
    }
}

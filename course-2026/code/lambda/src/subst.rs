//! Capture-avoiding substitution and α-conversion.
//!
//! Substitution `M[x := N]` replaces every *free* occurrence of `x` in `M`
//! with `N`. The subtlety is capture: if `N` has a free variable `y` and `M`
//! binds `y` somewhere around an occurrence of `x`, a naive replacement would
//! make that `y` bound -- changing the meaning of the term. The fix is to
//! α-rename the binder first (see [`Term::substitute`]).
//!
//! [`Term::rename`] performs a single α-conversion: renaming a bound
//! variable everywhere inside its scope, leaving free variables alone.

use std::collections::HashSet;

use crate::term::Term;

// ===========================================================================
// Fresh names
// ===========================================================================

/// Generate a fresh variable name not in `avoid`, derived from `base`.
fn fresh_var(avoid: &HashSet<String>, base: &str) -> String {
    let mut name = base.to_string();
    while avoid.contains(&name) {
        name = format!("{name}'");
    }
    name
}

// ===========================================================================
// Substitution and alpha-conversion
// ===========================================================================

impl Term {
    /// Capture-avoiding substitution: `self[x := replacement]`.
    ///
    /// Replaces every free occurrence of `x` with `replacement`.
    /// When `replacement` contains a free variable that would be captured by
    /// a binder in `self`, the binder is α-renamed to a fresh name first.
    ///
    /// ```
    /// use lambda::Term;
    /// // (λy. y x)[x := y] must avoid capturing the free y
    /// // After alpha-renaming: (λy'. y' y)
    /// let t = Term::abs("y", Term::app(Term::var("y"), Term::var("x")));
    /// let result = t.substitute("x", &Term::var("y"));
    /// assert_eq!(result.to_string(), "λy'. y' y");
    /// ```
    pub fn substitute(&self, x: &str, replacement: &Term) -> Term {
        match self {
            Term::Var(y) if y == x => replacement.clone(),
            Term::Var(_) => self.clone(),
            Term::Abs(y, _) if y == x => self.clone(),
            Term::Abs(y, body) => {
                // Rename only when the substitution really reaches under this
                // binder (x occurs free in the body) AND the replacement's
                // free variables would be captured. Renaming otherwise is not
                // just wasted work: the fresh name could collide with `x`,
                // and the recursive substitution below would then clobber the
                // freshly renamed occurrences before the new binder wraps them.
                if replacement.free_vars().contains(y) && body.free_vars().contains(x) {
                    // α-convert the bound variable to avoid capture.
                    // The fresh name must avoid every name in the body (free
                    // or bound), not just the free ones: a name bound deeper
                    // in the body would otherwise stop the renaming and leave
                    // dangling occurrences.
                    let mut avoid = body.all_vars();
                    avoid.extend(replacement.free_vars().iter().cloned());
                    let fresh = fresh_var(&avoid, y);
                    let renamed = body.subst_var(y, &fresh);
                    Term::Abs(fresh, Box::new(renamed.substitute(x, replacement)))
                } else {
                    Term::Abs(y.clone(), Box::new(body.substitute(x, replacement)))
                }
            }
            Term::App(fun, arg) => Term::App(
                Box::new(fun.substitute(x, replacement)),
                Box::new(arg.substitute(x, replacement)),
            ),
        }
    }

    /// α-conversion: rename the bound variable `from` to `to`.
    ///
    /// Only occurrences bound by a matching `Abs(from, _)` are renamed;
    /// free variables are left alone. `to` must be fresh: it must not occur
    /// (free or bound) anywhere in the term, otherwise the renamed binder
    /// captures those occurrences and changes the meaning of the term.
    ///
    /// ```
    /// use lambda::Term;
    /// // α-convert λx. x y  to  λz. z y
    /// let t = Term::abs("x", Term::app(Term::var("x"), Term::var("y")));
    /// let renamed = t.rename("x", "z");
    /// assert_eq!(renamed.to_string(), "λz. z y");
    /// ```
    pub fn rename(&self, from: &str, to: &str) -> Term {
        match self {
            // Free variables are never renamed.
            Term::Var(_) => self.clone(),
            Term::Abs(y, body) if y == from => {
                // Enter the scope of the binder being α-converted.
                // Rename the binder and then rename all bound occurrences.
                Term::Abs(to.to_string(), Box::new(body.subst_var(from, to)))
            }
            Term::Abs(y, body) if y == to => {
                // The binder already uses `to` -- the inner `from` is
                // shadowed; stop.
                Term::Abs(y.clone(), body.clone())
            }
            Term::Abs(y, body) => Term::Abs(y.clone(), Box::new(body.rename(from, to))),
            Term::App(fun, arg) => Term::App(
                Box::new(fun.rename(from, to)),
                Box::new(arg.rename(from, to)),
            ),
        }
    }

    /// Rename all occurrences of `from` to `to` (no capture semantics).
    ///
    /// This is a low-level helper called inside the scope of a matching
    /// binder where all `from` variables are bound. Stops at shadow
    /// boundaries (`Abs(from, _)` or `Abs(to, _)`).
    fn subst_var(&self, from: &str, to: &str) -> Term {
        match self {
            Term::Var(y) if y == from => Term::Var(to.to_string()),
            Term::Var(_) => self.clone(),
            Term::Abs(y, body) if y == from || y == to => {
                // Shadow boundary -- stop.
                Term::Abs(y.clone(), body.clone())
            }
            Term::Abs(y, body) => Term::Abs(y.clone(), Box::new(body.subst_var(from, to))),
            Term::App(fun, arg) => Term::App(
                Box::new(fun.subst_var(from, to)),
                Box::new(arg.subst_var(from, to)),
            ),
        }
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    // -- Substitution ========================================================

    #[test]
    fn substitute_var_same() {
        let result = Term::var("x").substitute("x", &Term::var("z"));
        assert_eq!(result, Term::var("z"));
    }

    #[test]
    fn substitute_var_different() {
        let result = Term::var("y").substitute("x", &Term::var("z"));
        assert_eq!(result, Term::var("y"));
    }

    #[test]
    fn substitute_under_abstraction_no_capture() {
        // [x := z] (λy. x y)  →  λy. z y
        let t = Term::abs("y", Term::app(Term::var("x"), Term::var("y")));
        let result = t.substitute("x", &Term::var("z"));
        assert_eq!(result.to_string(), "λy. z y");
    }

    #[test]
    fn substitute_avoids_capture_by_alpha_conversion() {
        // [x := y] (λy. y x)  →  λy'. (y' y)
        // The bound `y` is renamed to avoid capturing the free `y` from the
        // replacement.
        let t = Term::abs("y", Term::app(Term::var("y"), Term::var("x")));
        let result = t.substitute("x", &Term::var("y"));
        // The result should be something like λy'. (y' y) -- we just check
        // that the bound variable changed and that no capture happened.
        match &result {
            Term::Abs(bound, _) => {
                assert_ne!(bound, "y"); // must have been alpha-renamed
            }
            _ => panic!("expected abstraction"),
        }
        // The original free `y` (now the argument) and the bound variable must
        // be different names.
        assert_eq!(result.free_vars().len(), 1);
        assert!(result.free_vars().contains("y"));
    }

    #[test]
    fn substitute_does_not_rename_when_safe() {
        // [x := z] (λy. y x)  →  λy. y z   (no rename needed; z ≠ y)
        let t = Term::abs("y", Term::app(Term::var("y"), Term::var("x")));
        let result = t.substitute("x", &Term::var("z"));
        assert_eq!(result.to_string(), "λy. y z");
    }

    #[test]
    fn substitute_avoids_capture_by_nested_bound_name() {
        // [x := y] (λy. λy'. y x)
        // The outer `y` binds the `y` in `y x`; the fresh name chosen for the
        // α-renamed binder must not collide with the inner bound `y'`.
        // Correct result: λy''. λy'. y'' y  (up to α).
        let t = Term::abs(
            "y",
            Term::abs("y'", Term::app(Term::var("y"), Term::var("x"))),
        );
        let result = t.substitute("x", &Term::var("y"));
        match &result {
            Term::Abs(outer, inner) => {
                assert_ne!(outer, "y");
                assert_ne!(outer, "y'");
                match inner.as_ref() {
                    Term::Abs(inner_name, _) => assert_eq!(inner_name, "y'"),
                    other => panic!("expected inner abstraction, got {other}"),
                }
            }
            other => panic!("expected abstraction, got {other}"),
        }
        // The substituted `y` stays free; only it is a free variable.
        assert_eq!(result.free_vars().len(), 1);
        assert!(result.free_vars().contains("y"));
    }

    // -- Rename (alpha-conversion) ===========================================

    #[test]
    fn rename_bound_variable() {
        let t = Term::abs("x", Term::app(Term::var("x"), Term::var("y")));
        let renamed = t.rename("x", "z");
        assert_eq!(renamed.to_string(), "λz. z y");
    }

    #[test]
    fn rename_does_not_touch_free_variable() {
        // λx. x y  →  rename "y" to "w"  has no effect (y is free)
        let t = Term::abs("x", Term::app(Term::var("x"), Term::var("y")));
        let renamed = t.rename("y", "w");
        assert_eq!(renamed, t);
    }
}

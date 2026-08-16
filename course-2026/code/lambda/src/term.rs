//! Lambda terms: variables, abstraction, and application.
//!
//! The core data type of untyped lambda calculus. Every computation is a term
//! built from variables, abstractions, and applications.
//!
//! The only computation rule is β-reduction: `(λx.M) N → M[x:=N]`.
//! Substitution is capture-avoiding -- when a free variable of `N` would be
//! captured by a binder in `M`, the binder is α-renamed first.
//!
//! ```
//! use lambda::Term;
//!
//! // (λx. x) y  →  y
//! let id = Term::abs("x", Term::var("x"));
//! let term = Term::app(id, Term::var("y"));
//! let reduced = term.normalize(10);
//! assert_eq!(reduced, Term::var("y"));
//! ```

use std::collections::HashSet;
use std::fmt;

/// A term of untyped lambda calculus.
///
/// # Constructors
///
/// | Variant | Meaning | Example |
/// |=========|=========|=========|
/// | `Var(x)` | Variable `x` | `x` |
/// | `Abs(x, M)` | Abstraction `λx. M` | `λx. x` |
/// | `App(M, N)` | Application `M N` | `(λx. x) y` |
///
/// Terms are constructed through the helper methods [`var`](Term::var),
/// [`abs`](Term::abs), and [`app`](Term::app) so that `Box`-wrapping is
/// handled internally.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Term {
    /// A variable.
    Var(String),
    /// Abstraction `λx. M` -- `x` is the bound variable, `body` is `M`.
    Abs(String, Box<Term>),
    /// Application `M N` -- `M` is the function, `N` is the argument.
    App(Box<Term>, Box<Term>),
}

// ===========================================================================
// Constructors
// ===========================================================================

impl Term {
    /// Create a variable term.
    ///
    /// ```
    /// use lambda::Term;
    /// assert_eq!(Term::var("x"), Term::Var("x".into()));
    /// ```
    pub fn var(x: &str) -> Term {
        Term::Var(x.to_string())
    }

    /// Create an abstraction `λx. body`.
    ///
    /// ```
    /// use lambda::Term;
    /// // λx. x  -- the identity function
    /// let id = Term::abs("x", Term::var("x"));
    /// assert_eq!(id.to_string(), "λx. x");
    /// ```
    pub fn abs(x: &str, body: Term) -> Term {
        Term::Abs(x.to_string(), Box::new(body))
    }

    /// Create an application `fun arg`.
    ///
    /// ```
    /// use lambda::Term;
    /// // (λx. x) y
    /// let app = Term::app(Term::abs("x", Term::var("x")), Term::var("y"));
    /// assert_eq!(app.to_string(), "(λx. x) y");
    /// ```
    pub fn app(fun: Term, arg: Term) -> Term {
        Term::App(Box::new(fun), Box::new(arg))
    }
}

// ===========================================================================
// Display
// ===========================================================================

impl fmt::Display for Term {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        self.fmt_prec(f, 0)
    }
}

impl Term {
    /// Pretty-print with precedence to avoid redundant parentheses.
    ///
    /// Precedence levels:
    /// - 0 -- top-level or body of an abstraction (no parens needed).
    /// - 1 -- left side of application (abstractions need parens here;
    ///   applications are left-associative so they stay flat).
    /// - 2 -- right side of application (both abstractions and applications
    ///   need parens).
    fn fmt_prec(&self, f: &mut fmt::Formatter<'_>, prec: usize) -> fmt::Result {
        match self {
            Term::Var(x) => write!(f, "{}", x),
            Term::Abs(x, body) => {
                if prec > 0 {
                    write!(f, "(")?;
                }
                write!(f, "λ{}. ", x)?;
                body.fmt_prec(f, 0)?;
                if prec > 0 {
                    write!(f, ")")?;
                }
                Ok(())
            }
            Term::App(fun, arg) => {
                if prec > 1 {
                    write!(f, "(")?;
                }
                fun.fmt_prec(f, 1)?;
                write!(f, " ")?;
                arg.fmt_prec(f, 2)?;
                if prec > 1 {
                    write!(f, ")")?;
                }
                Ok(())
            }
        }
    }
}

// ===========================================================================
// Free variables
// ===========================================================================

impl Term {
    /// Compute the set of free variables of the term.
    ///
    /// A variable occurrence is *free* if it is not bound by an enclosing
    /// abstraction. Free variables determine which substitutions are safe.
    ///
    /// ```
    /// use lambda::Term;
    /// // λx. x y  -- y is free, x is bound
    /// let t = Term::abs("x", Term::app(Term::var("x"), Term::var("y")));
    /// let fv = t.free_vars();
    /// assert!(fv.contains("y"));
    /// assert!(!fv.contains("x"));
    /// ```
    pub fn free_vars(&self) -> HashSet<String> {
        match self {
            Term::Var(x) => {
                let mut s = HashSet::new();
                s.insert(x.clone());
                s
            }
            Term::Abs(x, body) => {
                let mut fv = body.free_vars();
                fv.remove(x);
                fv
            }
            Term::App(fun, arg) => {
                let mut fv = fun.free_vars();
                fv.extend(arg.free_vars());
                fv
            }
        }
    }

    /// Collect every variable name occurring anywhere in the term, free or
    /// bound. Used to pick a name that is fresh with respect to the whole
    /// body during capture-avoiding α-renaming.
    fn all_vars(&self) -> HashSet<String> {
        match self {
            Term::Var(x) => {
                let mut s = HashSet::new();
                s.insert(x.clone());
                s
            }
            Term::Abs(x, body) => {
                let mut s = body.all_vars();
                s.insert(x.clone());
                s
            }
            Term::App(fun, arg) => {
                let mut s = fun.all_vars();
                s.extend(arg.all_vars());
                s
            }
        }
    }
}

// ===========================================================================
// Substitution and alpha-conversion
// ===========================================================================

/// Generate a fresh variable name not in `avoid`, derived from `base`.
fn fresh_var(avoid: &HashSet<String>, base: &str) -> String {
    let mut name = base.to_string();
    while avoid.contains(&name) {
        name = format!("{name}'");
    }
    name
}

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
                if replacement.free_vars().contains(y) {
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
// Beta reduction
// ===========================================================================

impl Term {
    /// One step of **normal-order** β-reduction (leftmost outermost redex).
    ///
    /// Returns `None` if the term is already in β-normal form -- i.e., no
    /// subterm has the shape `(λx.M) N`.
    ///
    /// ```
    /// use lambda::Term;
    /// // (λx. x) y  →  y
    /// let id = Term::abs("x", Term::var("x"));
    /// let term = Term::app(id, Term::var("y"));
    /// assert_eq!(term.beta_reduce(), Some(Term::var("y")));
    /// ```
    pub fn beta_reduce(&self) -> Option<Term> {
        match self {
            Term::App(fun, arg) => match fun.as_ref() {
                // (λx. body) arg  →  body[x := arg]
                Term::Abs(x, body) => Some(body.substitute(x, arg)),
                // Reduce the function part first (leftmost outermost).
                _ => {
                    if let Some(fun_reduced) = fun.beta_reduce() {
                        Some(Term::App(Box::new(fun_reduced), arg.clone()))
                    } else {
                        arg.beta_reduce()
                            .map(|arg_reduced| Term::App(fun.clone(), Box::new(arg_reduced)))
                    }
                }
            },
            // Reduce inside the body of an abstraction.
            Term::Abs(x, body) => body
                .beta_reduce()
                .map(|b| Term::Abs(x.clone(), Box::new(b))),
            Term::Var(_) => None,
        }
    }

    /// Reduce to normal form, stopping after `max_steps` iterations.
    ///
    /// The step guard prevents infinite loops on non-terminating terms such as
    /// `Ω = (λx. x x)(λx. x x)`.
    ///
    /// ```
    /// use lambda::Term;
    /// // (λx. x) a  →  a  in one step
    /// let term = Term::app(Term::abs("x", Term::var("x")), Term::var("a"));
    /// assert_eq!(term.normalize(10), Term::var("a"));
    /// ```
    pub fn normalize(&self, max_steps: usize) -> Term {
        let mut t = self.clone();
        for _ in 0..max_steps {
            match t.beta_reduce() {
                Some(next) => t = next,
                None => break,
            }
        }
        t
    }

    /// Check whether the term is in β-normal form -- no redex exists.
    ///
    /// ```
    /// use lambda::Term;
    /// assert!(Term::var("x").is_normal_form());
    /// assert!(Term::abs("x", Term::var("x")).is_normal_form());
    /// // (λx. x) y  is NOT in normal form
    /// let redex = Term::app(Term::abs("x", Term::var("x")), Term::var("y"));
    /// assert!(!redex.is_normal_form());
    /// ```
    pub fn is_normal_form(&self) -> bool {
        match self {
            Term::Var(_) => true,
            Term::Abs(_, body) => body.is_normal_form(),
            Term::App(fun, arg) => {
                // If the left part is an abstraction, it's a redex.
                if matches!(fun.as_ref(), Term::Abs(..)) {
                    return false;
                }
                fun.is_normal_form() && arg.is_normal_form()
            }
        }
    }

    /// Full reduction trace: records each intermediate term from start to
    /// normal form (or until `max_steps` is exhausted).
    ///
    /// ```
    /// use lambda::Term;
    /// // (λx. x) (λy. y) a  →  two steps
    /// let id = Term::abs("x", Term::var("x"));
    /// let term = Term::app(Term::app(id, Term::abs("y", Term::var("y"))), Term::var("a"));
    /// let trace = term.trace(10);
    /// assert_eq!(trace.len(), 3); // initial + two reductions
    /// assert_eq!(trace[2], Term::var("a"));
    /// ```
    pub fn trace(&self, max_steps: usize) -> Vec<Term> {
        let mut steps = vec![self.clone()];
        let mut t = self.clone();
        for _ in 0..max_steps {
            match t.beta_reduce() {
                Some(next) => {
                    steps.push(next.clone());
                    t = next;
                }
                None => break,
            }
        }
        steps
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    // -- Constructors ========================================================

    #[test]
    fn var_construction() {
        assert_eq!(Term::var("x"), Term::Var("x".into()));
    }

    #[test]
    fn abs_construction() {
        assert_eq!(
            Term::abs("x", Term::var("x")),
            Term::Abs("x".into(), Box::new(Term::Var("x".into())))
        );
    }

    #[test]
    fn app_construction() {
        assert_eq!(
            Term::app(Term::var("f"), Term::var("a")),
            Term::App(
                Box::new(Term::Var("f".into())),
                Box::new(Term::Var("a".into()))
            )
        );
    }

    // -- Display =============================================================

    #[test]
    fn display_variable() {
        assert_eq!(Term::var("x").to_string(), "x");
    }

    #[test]
    fn display_abstraction() {
        let id = Term::abs("x", Term::var("x"));
        assert_eq!(id.to_string(), "λx. x");
    }

    #[test]
    fn display_application_of_variables() {
        let t = Term::app(Term::var("f"), Term::var("a"));
        assert_eq!(t.to_string(), "f a");
    }

    #[test]
    fn display_application_with_abs_on_left() {
        let t = Term::app(Term::abs("x", Term::var("x")), Term::var("y"));
        assert_eq!(t.to_string(), "(λx. x) y");
    }

    #[test]
    fn display_application_with_abs_on_right() {
        let t = Term::app(Term::var("f"), Term::abs("x", Term::var("x")));
        assert_eq!(t.to_string(), "f (λx. x)");
    }

    #[test]
    fn display_left_associative_app() {
        // ((f a) b)  →  "f a b"
        let t = Term::app(Term::app(Term::var("f"), Term::var("a")), Term::var("b"));
        assert_eq!(t.to_string(), "f a b");
    }

    #[test]
    fn display_church_two() {
        // λf. λx. f (f x)
        let c2 = Term::abs(
            "f",
            Term::abs(
                "x",
                Term::app(Term::var("f"), Term::app(Term::var("f"), Term::var("x"))),
            ),
        );
        assert_eq!(c2.to_string(), "λf. λx. f (f x)");
    }

    // -- Free variables ======================================================

    #[test]
    fn free_vars_var() {
        let fv = Term::var("x").free_vars();
        assert_eq!(fv.len(), 1);
        assert!(fv.contains("x"));
    }

    #[test]
    fn free_vars_bound_variable_is_not_free() {
        let t = Term::abs("x", Term::var("x"));
        assert!(t.free_vars().is_empty());
    }

    #[test]
    fn free_vars_nested_abstractions() {
        // λx. λy. x y z  -- z is the only free variable
        let t = Term::abs(
            "x",
            Term::abs(
                "y",
                Term::app(Term::app(Term::var("x"), Term::var("y")), Term::var("z")),
            ),
        );
        let fv = t.free_vars();
        assert_eq!(fv.len(), 1);
        assert!(fv.contains("z"));
        assert!(!fv.contains("x"));
        assert!(!fv.contains("y"));
    }

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

    // -- Beta reduction ======================================================

    #[test]
    fn beta_reduce_simple_redex() {
        // (λx. x) a  →  a
        let redex = Term::app(Term::abs("x", Term::var("x")), Term::var("a"));
        assert_eq!(redex.beta_reduce(), Some(Term::var("a")));
    }

    #[test]
    fn beta_reduce_nested_redex_leftmost_outermost() {
        // (λx. (λy. y) x) z  →  (λy. y) z  (not λx. x z)
        let inner = Term::app(Term::abs("y", Term::var("y")), Term::var("x"));
        let outer = Term::abs("x", inner);
        let redex = Term::app(outer, Term::var("z"));
        // Leftmost outermost redex is the whole term.
        let result = redex.beta_reduce().unwrap();
        // After one step: ((λy. y) z)
        assert_eq!(result.to_string(), "(λy. y) z");
    }

    #[test]
    fn beta_reduce_variable_is_normal_form() {
        assert!(Term::var("x").beta_reduce().is_none());
    }

    #[test]
    fn beta_reduce_abstraction_reduces_body() {
        // λx. ((λy. y) x)  →  λx. x
        let body = Term::app(Term::abs("y", Term::var("y")), Term::var("x"));
        let t = Term::abs("x", body);
        assert_eq!(t.beta_reduce(), Some(Term::abs("x", Term::var("x"))));
    }

    // -- Normalization =======================================================

    #[test]
    fn normalize_stops_at_normal_form() {
        // (λx. x) a  →  a  (one step, then stops)
        let redex = Term::app(Term::abs("x", Term::var("x")), Term::var("a"));
        assert_eq!(redex.normalize(10), Term::var("a"));
    }

    #[test]
    fn normalize_respects_step_limit_on_non_terminating_term() {
        // Ω = (λx. x x)(λx. x x) stays the same shape; the step limit
        // prevents an infinite loop.
        let self_app = Term::abs("x", Term::app(Term::var("x"), Term::var("x")));
        let omega = Term::app(self_app.clone(), self_app);
        let result = omega.normalize(3);
        // After 3 reductions of Ω, it's still not in normal form.
        assert!(!result.is_normal_form());
    }

    // -- Trace ===============================================================

    #[test]
    fn trace_records_all_intermediate_steps() {
        // (λx. x) ((λy. y) a)  →  two steps
        let id = Term::abs("x", Term::var("x"));
        let inner = Term::app(Term::abs("y", Term::var("y")), Term::var("a"));
        let redex = Term::app(id, inner);
        let trace = redex.trace(10);
        assert_eq!(trace.len(), 3); // initial + inner redex + final
    }

    // -- is_normal_form ======================================================

    #[test]
    fn variable_is_normal_form() {
        assert!(Term::var("x").is_normal_form());
    }

    #[test]
    fn abstraction_of_normal_form_is_normal_form() {
        assert!(Term::abs("x", Term::var("x")).is_normal_form());
    }

    #[test]
    fn application_with_abs_on_left_is_not_normal_form() {
        let redex = Term::app(Term::abs("x", Term::var("x")), Term::var("a"));
        assert!(!redex.is_normal_form());
    }

    #[test]
    fn application_of_normal_forms_is_normal_form() {
        let t = Term::app(Term::var("f"), Term::var("a"));
        assert!(t.is_normal_form());
    }
}

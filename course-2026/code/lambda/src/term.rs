//! Lambda terms: variables, abstraction, and application.
//!
//! The core data type of untyped lambda calculus. Every computation is a term
//! built from variables, abstractions, and applications.
//!
//! The only computation rule is β-reduction: `(λx.M) N -> M[x := N]`.
//! Substitution is capture-avoiding -- when a free variable of `N` would be
//! captured by a binder in `M`, the binder is α-renamed first (the
//! substitution itself lives in [`crate::subst`], the reduction strategies
//! in [`crate::eval`]).
//!
//! ```
//! use lambda::Term;
//!
//! // (λx. x) y  ->  y
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
    pub(crate) fn all_vars(&self) -> HashSet<String> {
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
        // ((f a) b)  ->  "f a b"
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
}

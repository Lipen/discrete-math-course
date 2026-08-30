//! Untyped lambda terms.
//!
//! A term is a variable, an abstraction, or an application. This is the
//! syntax on which type inference ([`crate::infer`]) runs: the same `Term`
//! the lambda crate uses, but self-contained here.
//!
//! ```
//! use type_theory::Term;
//! // λx. x  -- the identity function
//! let id = Term::abs("x", Term::var("x"));
//! assert_eq!(id.to_string(), "λx. x");
//! // (λx. x) y  reduces to  y
//! let app = Term::app(id, Term::var("y"));
//! assert_eq!(app.beta_reduce(), Some(Term::var("y")));
//! ```

use std::collections::HashSet;
use std::fmt;

/// A term of the untyped lambda calculus.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Term {
    /// A variable `x`.
    Var(String),
    /// Abstraction `λx. body`.
    Abs(String, Box<Term>),
    /// Application `fun arg`.
    App(Box<Term>, Box<Term>),
}

impl Term {
    /// Create a variable term.
    pub fn var(x: &str) -> Term {
        Term::Var(x.to_string())
    }

    /// Create an abstraction `λx. body`.
    pub fn abs(x: &str, body: Term) -> Term {
        Term::Abs(x.to_string(), Box::new(body))
    }

    /// Create an application `fun arg`.
    pub fn app(fun: Term, arg: Term) -> Term {
        Term::App(Box::new(fun), Box::new(arg))
    }

    /// The set of free variables of the term.
    ///
    /// A variable is *free* if it is not bound by an enclosing abstraction.
    /// ```
    /// use type_theory::Term;
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

    /// Every variable name occurring anywhere in the term, free or bound.
    ///
    /// Used to choose a fresh name during capture-avoiding α-renaming.
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

    /// Capture-avoiding substitution `self[x := replacement]`.
    ///
    /// Replaces every free occurrence of `x` with `replacement`. When the
    /// replacement has a free variable that would be captured by a binder in
    /// `self`, the binder is α-renamed to a fresh name first.
    ///
    /// ```
    /// use type_theory::Term;
    /// // [x := y] (λy. y x)  -- the bound y is renamed to avoid capture.
    /// let t = Term::abs("y", Term::app(Term::var("y"), Term::var("x")));
    /// let r = t.substitute("x", &Term::var("y"));
    /// assert_eq!(r.to_string(), "λy'. y' y");
    /// ```
    pub fn substitute(&self, x: &str, replacement: &Term) -> Term {
        match self {
            Term::Var(y) if y == x => replacement.clone(),
            Term::Var(_) => self.clone(),
            Term::Abs(y, _) if y == x => self.clone(),
            Term::Abs(y, body) => {
                // Rename only when the substitution reaches under this binder
                // AND the replacement's free variables would be captured.
                if replacement.free_vars().contains(y) && body.free_vars().contains(x) {
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

    /// Rename all occurrences of `from` to `to` inside the scope of a matching
    /// binder. Stops at shadow boundaries. Low-level helper for α-conversion.
    fn subst_var(&self, from: &str, to: &str) -> Term {
        match self {
            Term::Var(y) if y == from => Term::Var(to.to_string()),
            Term::Var(_) => self.clone(),
            Term::Abs(y, body) if y == from || y == to => Term::Abs(y.clone(), body.clone()),
            Term::Abs(y, body) => Term::Abs(y.clone(), Box::new(body.subst_var(from, to))),
            Term::App(fun, arg) => Term::App(
                Box::new(fun.subst_var(from, to)),
                Box::new(arg.subst_var(from, to)),
            ),
        }
    }

    /// One β-step (leftmost outermost). Returns `None` at a normal form.
    ///
    /// `(λx. M) N →β M[x := N]`.
    pub fn beta_reduce(&self) -> Option<Term> {
        match self {
            Term::App(fun, arg) => {
                if let Term::Abs(x, body) = fun.as_ref() {
                    Some(body.substitute(x, arg))
                } else {
                    fun.beta_reduce()
                        .map(|f2| Term::app(f2, (**arg).clone()))
                        .or_else(|| arg.beta_reduce().map(|a2| Term::app((**fun).clone(), a2)))
                }
            }
            Term::Abs(x, body) => body.beta_reduce().map(|b2| Term::abs(x, b2)),
            Term::Var(_) => None,
        }
    }

    /// Is the term in normal form (no redex)?
    pub fn is_normal_form(&self) -> bool {
        self.beta_reduce().is_none()
    }

    /// Reduce to normal form, fuel-limited so diverging terms cannot hang.
    pub fn normalize(&self, fuel: usize) -> Term {
        let mut t = self.clone();
        for _ in 0..fuel {
            match t.beta_reduce() {
                Some(t2) => t = t2,
                None => break,
            }
        }
        t
    }

    fn fmt_prec(&self, f: &mut fmt::Formatter<'_>, prec: usize) -> fmt::Result {
        match self {
            Term::Var(x) => write!(f, "{x}"),
            Term::Abs(x, body) => {
                if prec > 0 {
                    write!(f, "(")?;
                }
                write!(f, "λ{x}. ")?;
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

impl fmt::Display for Term {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        self.fmt_prec(f, 0)
    }
}

/// Generate a fresh variable name not in `avoid`, derived from `base`.
fn fresh_var(avoid: &HashSet<String>, base: &str) -> String {
    let mut name = base.to_string();
    while avoid.contains(&name) {
        name = format!("{name}'");
    }
    name
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn constructors() {
        assert_eq!(Term::var("x"), Term::Var("x".into()));
        assert_eq!(
            Term::abs("x", Term::var("x")),
            Term::Abs("x".into(), Box::new(Term::Var("x".into())))
        );
    }

    #[test]
    fn display() {
        assert_eq!(Term::abs("x", Term::var("x")).to_string(), "λx. x");
        assert_eq!(
            Term::app(Term::abs("x", Term::var("x")), Term::var("y")).to_string(),
            "(λx. x) y"
        );
        assert_eq!(
            Term::app(Term::var("f"), Term::abs("x", Term::var("x"))).to_string(),
            "f (λx. x)"
        );
        // Left-associative application stays flat.
        assert_eq!(
            Term::app(Term::app(Term::var("f"), Term::var("a")), Term::var("b")).to_string(),
            "f a b"
        );
    }

    #[test]
    fn free_vars() {
        let id = Term::abs("x", Term::var("x"));
        assert!(id.free_vars().is_empty());
        let t = Term::abs("x", Term::app(Term::var("x"), Term::var("y")));
        let fv = t.free_vars();
        assert!(fv.contains("y"));
        assert!(!fv.contains("x"));
    }

    #[test]
    fn substitute_simple() {
        let t = Term::abs("x", Term::var("x"));
        // [x := z] (λx. x)  ->  λx. x  (no free x, substitution is a no-op)
        assert_eq!(t.substitute("x", &Term::var("z")), t);
    }

    #[test]
    fn substitute_avoids_capture() {
        // [x := y] (λy. y x)  ->  λy'. y' y
        let t = Term::abs("y", Term::app(Term::var("y"), Term::var("x")));
        let r = t.substitute("x", &Term::var("y"));
        match &r {
            Term::Abs(bound, _) => assert_ne!(bound, "y"),
            _ => panic!("expected abstraction"),
        }
        assert_eq!(r.free_vars().len(), 1);
        assert!(r.free_vars().contains("y"));
    }

    #[test]
    fn beta_reduce_applies_identity() {
        let app = Term::app(Term::abs("x", Term::var("x")), Term::var("y"));
        assert_eq!(app.beta_reduce(), Some(Term::var("y")));
    }

    #[test]
    fn beta_reduce_normal_form_is_none() {
        assert_eq!(Term::var("y").beta_reduce(), None);
        assert_eq!(Term::abs("x", Term::var("x")).beta_reduce(), None);
    }

    #[test]
    fn omega_reduces_to_itself_indefinitely() {
        // Ω = (λx. x x)(λx. x x) is a normal-order loop.
        let self_app = Term::abs("x", Term::app(Term::var("x"), Term::var("x")));
        let omega = Term::app(self_app.clone(), self_app);
        assert_eq!(omega.beta_reduce(), Some(omega.clone()));
        assert!(!omega.is_normal_form());
    }

    #[test]
    fn normalize_reduces_to_normal_form() {
        let app = Term::app(Term::abs("x", Term::var("x")), Term::var("y"));
        assert_eq!(app.normalize(10), Term::var("y"));
    }
}

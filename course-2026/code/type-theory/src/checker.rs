//! Church-style typed terms and the three typing rules of λ→.
//!
//! A typed term [`STerm`] carries its binder annotations: `λx:σ. M`.
//! [`STerm::check`] implements the three rules against a [`Context`]:
//!
//! - **var**: `Γ, x:σ ⊢ x : σ`.
//! - **app**: `Γ ⊢ M : σ→τ` and `Γ ⊢ N : σ` give `Γ ⊢ M N : τ`.
//! - **abs**: `Γ, x:σ ⊢ M : τ` gives `Γ ⊢ λx:σ. M : σ→τ`.
//!
//! Because a redex kept in annotated form β-reduces while preserving annotations ([`STerm::beta_reduce`]), the same module demonstrates **subject reduction**: if `Γ ⊢ M : σ` and `M →β M'`, then `Γ ⊢ M' : σ`.
//!
//! ```
//! use type_theory::checker::STerm;
//! use type_theory::ty::Type;
//! // λx:Nat. x : Nat -> Nat
//! let id = STerm::abs("x", Type::nat(), STerm::var("x"));
//! assert_eq!(id.type_of().unwrap(), Type::arrow(Type::nat(), Type::nat()));
//! // λx:Nat. x x is rejected: x would need to be both Nat and a function.
//! let bad = STerm::abs("x", Type::nat(), STerm::app(STerm::var("x"), STerm::var("x")));
//! assert!(bad.type_of().is_err());
//! ```

use std::collections::HashSet;
use std::fmt;

use crate::term::Term;
use crate::ty::{Context, Type};

/// A term of the simply-typed lambda calculus, with binder annotations.
///
/// `Abs(x, ty, body)` is `λx:ty. body`.
/// Built through the helper methods [`var`](STerm::var), [`abs`](STerm::abs), and [`app`](STerm::app).
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum STerm {
    /// A variable.
    Var(String),
    /// Abstraction `λx:ty. body` -- the binder carries its type `ty`.
    Abs(String, Type, Box<STerm>),
    /// Application `fun arg`.
    App(Box<STerm>, Box<STerm>),
}

impl STerm {
    /// Create a variable.
    pub fn var(x: &str) -> STerm {
        STerm::Var(x.to_string())
    }

    /// Create an abstraction `λx:ty. body`.
    pub fn abs(x: &str, ty: Type, body: STerm) -> STerm {
        STerm::Abs(x.to_string(), ty, Box::new(body))
    }

    /// Create an application `fun arg`.
    pub fn app(fun: STerm, arg: STerm) -> STerm {
        STerm::App(Box::new(fun), Box::new(arg))
    }

    /// Type check `self` in the context `ctx`, returning its type.
    ///
    /// This is the algorithmic form of the three rules var/app/abs.
    /// The context lists the types of the free variables, and a later assumption of the same name shadows an earlier one.
    ///
    /// ```
    /// use type_theory::checker::STerm;
    /// use type_theory::ty::{Context, Type};
    /// // (λx:Nat. x) a with a : Nat  ->  Nat
    /// let id = STerm::abs("x", Type::nat(), STerm::var("x"));
    /// let app = STerm::app(id, STerm::var("a"));
    /// let ctx = Context::new().extend("a", Type::nat());
    /// assert_eq!(app.check(&ctx), Ok(Type::nat()));
    /// // Without the assumption, `a` is unbound.
    /// assert_eq!(app.check(&Context::new()), Err(type_theory::TypeError::UnboundVariable("a".into())));
    /// ```
    pub fn check(&self, ctx: &Context) -> Result<Type, TypeError> {
        match self {
            STerm::Var(x) => ctx
                .lookup(x)
                .cloned()
                .ok_or_else(|| TypeError::UnboundVariable(x.clone())),
            STerm::Abs(x, ty, body) => {
                let cod = body.check(&ctx.extend(x.clone(), ty.clone()))?;
                Ok(Type::arrow(ty.clone(), cod))
            }
            STerm::App(fun, arg) => {
                let fun_ty = fun.check(ctx)?;
                let arg_ty = arg.check(ctx)?;
                match fun_ty {
                    Type::Arrow(dom, cod) => {
                        if *dom == arg_ty {
                            Ok(*cod)
                        } else {
                            Err(TypeError::Mismatch {
                                expected: *dom,
                                found: arg_ty,
                            })
                        }
                    }
                    other => Err(TypeError::NotAFunction { ty: other }),
                }
            }
        }
    }

    /// Type check a closed term in the empty context.
    ///
    /// Shortcut for [`check`](STerm::check) with no assumptions.
    pub fn type_of(&self) -> Result<Type, TypeError> {
        self.check(&Context::new())
    }

    /// Erase all binder annotations, producing the untyped [`Term`].
    ///
    /// This is the syntax on which inference ([`crate::infer`]) runs.
    pub fn erase(&self) -> Term {
        match self {
            STerm::Var(x) => Term::var(x),
            STerm::Abs(x, _, body) => Term::abs(x, body.erase()),
            STerm::App(fun, arg) => Term::app(fun.erase(), arg.erase()),
        }
    }

    /// The set of free variables.
    fn free_vars(&self) -> HashSet<String> {
        match self {
            STerm::Var(x) => {
                let mut s = HashSet::new();
                s.insert(x.clone());
                s
            }
            STerm::Abs(x, _, body) => {
                let mut fv = body.free_vars();
                fv.remove(x);
                fv
            }
            STerm::App(fun, arg) => {
                let mut fv = fun.free_vars();
                fv.extend(arg.free_vars());
                fv
            }
        }
    }

    /// Every variable name occurring anywhere in the term, free or bound.
    fn all_vars(&self) -> HashSet<String> {
        match self {
            STerm::Var(x) => {
                let mut s = HashSet::new();
                s.insert(x.clone());
                s
            }
            STerm::Abs(x, _, body) => {
                let mut s = body.all_vars();
                s.insert(x.clone());
                s
            }
            STerm::App(fun, arg) => {
                let mut s = fun.all_vars();
                s.extend(arg.all_vars());
                s
            }
        }
    }

    /// Capture-avoiding substitution on typed terms, keeping annotations.
    ///
    /// `self[x := replacement]`. When the replacement has a free variable that
    /// would be captured by a binder in `self`, the binder is α-renamed first.
    fn substitute(&self, x: &str, replacement: &STerm) -> STerm {
        match self {
            STerm::Var(y) if y == x => replacement.clone(),
            STerm::Var(_) => self.clone(),
            STerm::Abs(y, _, _) if y == x => self.clone(),
            STerm::Abs(y, ty, body) => {
                if replacement.free_vars().contains(y) && body.free_vars().contains(x) {
                    let mut avoid = body.all_vars();
                    avoid.extend(replacement.free_vars().iter().cloned());
                    let fresh = fresh_var(&avoid, y);
                    let renamed = body.subst_var(y, &fresh);
                    STerm::Abs(
                        fresh,
                        ty.clone(),
                        Box::new(renamed.substitute(x, replacement)),
                    )
                } else {
                    STerm::Abs(
                        y.clone(),
                        ty.clone(),
                        Box::new(body.substitute(x, replacement)),
                    )
                }
            }
            STerm::App(fun, arg) => STerm::App(
                Box::new(fun.substitute(x, replacement)),
                Box::new(arg.substitute(x, replacement)),
            ),
        }
    }

    /// Rename all occurrences of `from` to `to` inside the scope of a matching
    /// binder. Stops at shadow boundaries. Low-level helper for α-conversion.
    fn subst_var(&self, from: &str, to: &str) -> STerm {
        match self {
            STerm::Var(y) if y == from => STerm::Var(to.to_string()),
            STerm::Var(_) => self.clone(),
            STerm::Abs(y, ty, body) if y == from || y == to => {
                STerm::Abs(y.clone(), ty.clone(), body.clone())
            }
            STerm::Abs(y, ty, body) => {
                STerm::Abs(y.clone(), ty.clone(), Box::new(body.subst_var(from, to)))
            }
            STerm::App(fun, arg) => STerm::App(
                Box::new(fun.subst_var(from, to)),
                Box::new(arg.subst_var(from, to)),
            ),
        }
    }

    /// One β-step (leftmost outermost), keeping annotations.
    ///
    /// Returns `None` at a normal form.
    /// Because annotations are preserved, checking before and after a step gives the same type -- subject reduction.
    pub fn beta_reduce(&self) -> Option<STerm> {
        match self {
            STerm::App(fun, arg) => {
                if let STerm::Abs(x, _, body) = fun.as_ref() {
                    Some(body.substitute(x, arg))
                } else {
                    fun.beta_reduce()
                        .map(|f2| STerm::app(f2, (**arg).clone()))
                        .or_else(|| arg.beta_reduce().map(|a2| STerm::app((**fun).clone(), a2)))
                }
            }
            STerm::Abs(x, ty, body) => body.beta_reduce().map(|b2| STerm::abs(x, ty.clone(), b2)),
            STerm::Var(_) => None,
        }
    }

    /// Is the term in normal form (no redex)?
    pub fn is_normal_form(&self) -> bool {
        self.beta_reduce().is_none()
    }

    /// Reduce to normal form keeping annotations, fuel-limited.
    pub fn normalize(&self, fuel: usize) -> STerm {
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
            STerm::Var(x) => write!(f, "{x}"),
            STerm::Abs(x, ty, body) => {
                if prec > 0 {
                    write!(f, "(")?;
                }
                write!(f, "λ{x}:{ty}. ")?;
                body.fmt_prec(f, 0)?;
                if prec > 0 {
                    write!(f, ")")?;
                }
                Ok(())
            }
            STerm::App(fun, arg) => {
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

impl fmt::Display for STerm {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        self.fmt_prec(f, 0)
    }
}

/// Why a typed term failed to type check.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum TypeError {
    /// A free variable that is not in the typing context.
    UnboundVariable(String),
    /// The function part of an application is not of arrow type.
    NotAFunction { ty: Type },
    /// The argument's type does not match the function's domain.
    Mismatch { expected: Type, found: Type },
}

impl fmt::Display for TypeError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            TypeError::UnboundVariable(x) => write!(f, "unbound variable `{x}`"),
            TypeError::NotAFunction { ty } => {
                write!(f, "cannot apply a value of non-function type `{ty}`")
            }
            TypeError::Mismatch { expected, found } => {
                write!(f, "type mismatch: expected `{expected}`, found `{found}`")
            }
        }
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

    fn nat() -> Type {
        Type::nat()
    }

    fn arrow(a: Type, b: Type) -> Type {
        Type::arrow(a, b)
    }

    // -- Display ==============================================================

    #[test]
    fn display_annotated_abstraction() {
        let id = STerm::abs("x", nat(), STerm::var("x"));
        assert_eq!(id.to_string(), "λx:Nat. x");
    }

    #[test]
    fn display_application() {
        let id = STerm::abs("x", nat(), STerm::var("x"));
        let app = STerm::app(id, STerm::var("a"));
        assert_eq!(app.to_string(), "(λx:Nat. x) a");
    }

    // -- Typing rules =========================================================

    #[test]
    fn identity_types_as_arrow() {
        // λx:Nat. x : Nat -> Nat
        let id = STerm::abs("x", nat(), STerm::var("x"));
        assert_eq!(id.type_of(), Ok(arrow(nat(), nat())));
    }

    #[test]
    fn identity_types_as_sigma_sigma_for_any_sigma() {
        // The identity types as σ -> σ for any base σ. Here σ = Nat and σ = Bool.
        for s in [nat(), Type::boolean()] {
            let id = STerm::abs("x", s.clone(), STerm::var("x"));
            assert_eq!(id.type_of(), Ok(arrow(s.clone(), s)));
        }
    }

    #[test]
    fn k_types_as_sigma_tau_sigma() {
        // λx:Nat. λy:Bool. x : Nat -> Bool -> Nat
        let k = STerm::abs(
            "x",
            nat(),
            STerm::abs("y", Type::boolean(), STerm::var("x")),
        );
        assert_eq!(k.type_of(), Ok(arrow(nat(), arrow(Type::boolean(), nat()))));
    }

    #[test]
    fn application_checks_against_context() {
        let id = STerm::abs("x", nat(), STerm::var("x"));
        let app = STerm::app(id, STerm::var("a"));
        let ctx = Context::new().extend("a", nat());
        assert_eq!(app.check(&ctx), Ok(nat()));
    }

    #[test]
    fn unbound_variable_is_rejected() {
        let app = STerm::app(STerm::abs("x", nat(), STerm::var("x")), STerm::var("a"));
        assert_eq!(app.type_of(), Err(TypeError::UnboundVariable("a".into())));
    }

    #[test]
    fn mismatched_argument_is_rejected() {
        // (λx:Nat. x) a with a : Nat -> Nat -- expected Nat, found Nat -> Nat.
        let id = STerm::abs("x", nat(), STerm::var("x"));
        let app = STerm::app(id, STerm::var("a"));
        let ctx = Context::new().extend("a", arrow(nat(), nat()));
        assert_eq!(
            app.check(&ctx),
            Err(TypeError::Mismatch {
                expected: nat(),
                found: arrow(nat(), nat()),
            })
        );
    }

    #[test]
    fn self_application_is_rejected() {
        // λx:Nat. x x -- no type: x would need Nat = Nat -> σ.
        let bad = STerm::abs("x", nat(), STerm::app(STerm::var("x"), STerm::var("x")));
        assert_eq!(bad.type_of(), Err(TypeError::NotAFunction { ty: nat() }));
    }

    #[test]
    fn shadowing_uses_the_innermost_binder() {
        // λx:Nat. λx:Nat->Nat. x : Nat -> (Nat->Nat) -> (Nat->Nat)
        let t = STerm::abs(
            "x",
            nat(),
            STerm::abs("x", arrow(nat(), nat()), STerm::var("x")),
        );
        assert_eq!(
            t.type_of(),
            Ok(arrow(
                nat(),
                arrow(arrow(nat(), nat()), arrow(nat(), nat()))
            ))
        );
    }

    // -- Erasure ==============================================================

    #[test]
    fn erase_identity_is_untyped_identity() {
        let id = STerm::abs("x", nat(), STerm::var("x"));
        assert_eq!(id.erase(), Term::abs("x", Term::var("x")));
    }

    #[test]
    fn erased_term_reduces_like_untyped() {
        // (λx:Nat. x) a erases to (λx. x) a -> a.
        let id = STerm::abs("x", nat(), STerm::var("x"));
        let app = STerm::app(id, STerm::var("a"));
        assert_eq!(app.erase().beta_reduce(), Some(Term::var("a")));
    }

    // -- Subject reduction ====================================================

    #[test]
    fn subject_reduction_preserves_type() {
        // M = (λf:Nat->Nat. λx:Nat. f x)(λx:Nat. x) : Nat->Nat
        // M →β λx:Nat. x : Nat->Nat. The type does not change.
        let f = STerm::var("f");
        let x = STerm::var("x");
        let m0 = STerm::abs(
            "f",
            arrow(nat(), nat()),
            STerm::abs("x", nat(), STerm::app(f, x)),
        );
        let id = STerm::abs("x", nat(), STerm::var("x"));
        let app = STerm::app(m0, id);

        let ty_before = app.type_of().unwrap();
        let nf = app.normalize(100);
        let ty_after = nf.type_of().unwrap();

        assert_eq!(ty_before, arrow(nat(), nat()));
        assert_eq!(ty_after, arrow(nat(), nat()));
        assert_eq!(ty_before, ty_after);
    }

    #[test]
    fn subject_reduction_one_step() {
        // (λx:Nat. x) a →β a, both : Nat  (a : Nat, a free in the context).
        let id = STerm::abs("x", nat(), STerm::var("x"));
        let app = STerm::app(id, STerm::var("a"));
        let ctx = Context::new().extend("a", nat());

        let ty_before = app.check(&ctx).unwrap();
        let reduced = app.beta_reduce().unwrap();
        let ty_after = reduced.check(&ctx).unwrap();

        assert_eq!(ty_before, nat());
        assert_eq!(ty_after, nat());
        assert_eq!(reduced, STerm::var("a"));
    }

    #[test]
    fn subject_reduction_composition_steps() {
        // The detour example, step by step:
        //   M = (λf:A→A. λx:A. f x)(λx:A. x)  →β  λx:A. (λx:A. x) x  →β  λx:A. x
        let a = Type::base("A");
        let f = STerm::var("f");
        let x = STerm::var("x");
        let m0 = STerm::abs(
            "f",
            arrow(a.clone(), a.clone()),
            STerm::abs("x", a.clone(), STerm::app(f, x.clone())),
        );
        let id = STerm::abs("x", a.clone(), STerm::var("x"));
        let app = STerm::app(m0, id);
        let expected = arrow(a.clone(), a.clone());

        let must_be = app.type_of().unwrap();
        assert_eq!(must_be, expected);

        let step1 = app.beta_reduce().unwrap();
        assert_eq!(step1.type_of().unwrap(), expected);

        let step2 = step1.beta_reduce().unwrap();
        // After the inner β-step: λx:A. x -- up to the renamed binder.
        assert_eq!(step2.type_of().unwrap(), expected);
        assert!(step2.is_normal_form());
    }
}

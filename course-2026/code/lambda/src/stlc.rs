//! A tiny simply-typed lambda calculus.
//!
//! Types are built from a base type `o` and function arrows `τ → σ`. Typed
//! terms ([`STerm`]) carry type annotations on binders; [`STerm::erase`]
//! forgets them and produces the untyped [`Term`]. [`STerm::infer`] type
//! checks a term against a typing context and returns its type, or a
//! [`TypeError`].
//!
//! The type system is deliberately small: with only `o` and `→` there is no
//! type for self-application, so terms like `λx. x x` are rejected. That is
//! why the untyped Y combinator cannot be typed here -- recursion needs an
//! explicit fixed-point rule (see the type-theory chapter of the book).

use std::fmt;

use crate::term::Term;

/// A type of the simply-typed lambda calculus.
///
/// Two forms only: the base type `o` and function arrows `τ → σ`.
///
/// ```
/// use lambda::stlc::Ty;
/// assert_eq!(Ty::Base.to_string(), "o");
/// assert_eq!(Ty::arrow(Ty::Base, Ty::Base).to_string(), "o → o");
/// ```
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Ty {
    /// The base type `o` -- a primitive value with no further structure.
    Base,
    /// Function type `dom → cod`.
    Arrow(Box<Ty>, Box<Ty>),
}

impl Ty {
    /// The base type `o`.
    pub fn base() -> Ty {
        Ty::Base
    }

    /// The function type `dom → cod`.
    pub fn arrow(dom: Ty, cod: Ty) -> Ty {
        Ty::Arrow(Box::new(dom), Box::new(cod))
    }
}

impl fmt::Display for Ty {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Ty::Base => write!(f, "o"),
            // Arrow domains that are themselves arrows need parentheses:
            // (o → o) → o, not o → o → o.
            Ty::Arrow(dom, cod) => match dom.as_ref() {
                Ty::Arrow(..) => write!(f, "({dom}) → {cod}"),
                _ => write!(f, "{dom} → {cod}"),
            },
        }
    }
}

/// A term of the simply-typed lambda calculus.
///
/// Like [`Term`], but every binder carries its type annotation. Terms are
/// built with the helper methods [`var`](STerm::var), [`abs`](STerm::abs),
/// and [`app`](STerm::app).
///
/// ```
/// use lambda::stlc::{STerm, Ty};
/// // λx:o. x -- the typed identity
/// let id = STerm::abs("x", Ty::Base, STerm::var("x"));
/// assert_eq!(id.type_of(), Ok(Ty::arrow(Ty::Base, Ty::Base)));
/// // Erasing the annotations gives the untyped identity.
/// assert_eq!(id.erase().to_string(), "λx. x");
/// ```
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum STerm {
    /// A variable.
    Var(String),
    /// Abstraction `λx:τ. body` -- the binder carries its type `τ`.
    Abs(String, Ty, Box<STerm>),
    /// Application `fun arg`.
    App(Box<STerm>, Box<STerm>),
}

impl STerm {
    /// Create a variable.
    pub fn var(x: &str) -> STerm {
        STerm::Var(x.to_string())
    }

    /// Create an abstraction `λx:ty. body`.
    pub fn abs(x: &str, ty: Ty, body: STerm) -> STerm {
        STerm::Abs(x.to_string(), ty, Box::new(body))
    }

    /// Create an application `fun arg`.
    pub fn app(fun: STerm, arg: STerm) -> STerm {
        STerm::App(Box::new(fun), Box::new(arg))
    }

    /// Erase all type annotations, producing the untyped [`Term`].
    ///
    /// ```
    /// use lambda::stlc::{STerm, Ty};
    /// // (λx:o. x) a erases to (λx. x) a.
    /// let id = STerm::abs("x", Ty::Base, STerm::var("x"));
    /// let t = STerm::app(id, STerm::var("a")).erase();
    /// assert_eq!(t.to_string(), "(λx. x) a");
    /// ```
    pub fn erase(&self) -> Term {
        match self {
            STerm::Var(x) => Term::var(x),
            STerm::Abs(x, _, body) => Term::abs(x, body.erase()),
            STerm::App(fun, arg) => Term::app(fun.erase(), arg.erase()),
        }
    }

    /// Type check a closed term in the empty context.
    ///
    /// Shortcut for [`infer`](STerm::infer) with no assumptions.
    pub fn type_of(&self) -> Result<Ty, TypeError> {
        self.infer(&[])
    }

    /// Type check `self` in the context `ctx`, returning its type.
    ///
    /// The context lists the types of the free variables, in order; a
    /// variable later in the list shadows an earlier one of the same name.
    ///
    /// ```
    /// use lambda::stlc::{STerm, Ty};
    /// // (λx:o. x) a with a : o  →  o
    /// let id = STerm::abs("x", Ty::Base, STerm::var("x"));
    /// let app = STerm::app(id, STerm::var("a"));
    /// assert_eq!(
    ///     app.infer(&[("a".to_string(), Ty::Base)]),
    ///     Ok(Ty::Base)
    /// );
    /// // Without the assumption, `a` is unbound.
    /// assert_eq!(app.type_of(), Err(lambda::stlc::TypeError::UnboundVariable("a".into())));
    /// ```
    pub fn infer(&self, ctx: &[(String, Ty)]) -> Result<Ty, TypeError> {
        match self {
            STerm::Var(x) => ctx
                .iter()
                .rev()
                .find(|(name, _)| name == x)
                .map(|(_, ty)| ty.clone())
                .ok_or_else(|| TypeError::UnboundVariable(x.clone())),
            STerm::Abs(x, ty, body) => {
                let mut extended = ctx.to_vec();
                extended.push((x.clone(), ty.clone()));
                let cod = body.infer(&extended)?;
                Ok(Ty::arrow(ty.clone(), cod))
            }
            STerm::App(fun, arg) => {
                let fun_ty = fun.infer(ctx)?;
                let arg_ty = arg.infer(ctx)?;
                match fun_ty {
                    Ty::Arrow(dom, cod) => {
                        if *dom == arg_ty {
                            Ok(*cod)
                        } else {
                            Err(TypeError::Mismatch {
                                expected: *dom,
                                found: arg_ty,
                            })
                        }
                    }
                    other => Err(TypeError::NotAFunction { fun: other }),
                }
            }
        }
    }
}

/// Why a term failed to type check.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum TypeError {
    /// A free variable that is not in the typing context.
    UnboundVariable(String),
    /// The function part of an application is not of arrow type.
    NotAFunction { fun: Ty },
    /// The argument's type does not match the function's domain.
    Mismatch { expected: Ty, found: Ty },
}

impl fmt::Display for TypeError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            TypeError::UnboundVariable(x) => write!(f, "unbound variable `{x}`"),
            TypeError::NotAFunction { fun } => {
                write!(f, "cannot apply a value of non-function type `{fun}`")
            }
            TypeError::Mismatch { expected, found } => {
                write!(f, "type mismatch: expected `{expected}`, found `{found}`")
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

    fn o() -> Ty {
        Ty::Base
    }

    // -- Ty display ==========================================================

    #[test]
    fn ty_display_parenthesizes_arrow_domains() {
        assert_eq!(o().to_string(), "o");
        assert_eq!(Ty::arrow(o(), o()).to_string(), "o → o");
        assert_eq!(
            Ty::arrow(Ty::arrow(o(), o()), o()).to_string(),
            "(o → o) → o"
        );
        assert_eq!(Ty::arrow(o(), Ty::arrow(o(), o())).to_string(), "o → o → o");
    }

    // -- Type checking =======================================================

    #[test]
    fn identity_types_as_arrow() {
        let id = STerm::abs("x", o(), STerm::var("x"));
        assert_eq!(id.type_of(), Ok(Ty::arrow(o(), o())));
    }

    #[test]
    fn erase_of_identity_is_untyped_identity() {
        let id = STerm::abs("x", o(), STerm::var("x"));
        assert_eq!(id.erase(), Term::abs("x", Term::var("x")));
    }

    #[test]
    fn application_checks_against_context() {
        // (λx:o. x) a, a : o  →  o
        let id = STerm::abs("x", o(), STerm::var("x"));
        let app = STerm::app(id, STerm::var("a"));
        assert_eq!(app.infer(&[("a".into(), o())]), Ok(o()));
    }

    #[test]
    fn unbound_variable_is_rejected() {
        let app = STerm::app(STerm::abs("x", o(), STerm::var("x")), STerm::var("a"));
        assert_eq!(app.type_of(), Err(TypeError::UnboundVariable("a".into())));
    }

    #[test]
    fn shadowing_uses_the_innermost_binder() {
        // λx:o. λx:o→o. x : o → (o → o) → (o → o) -- the inner x wins.
        let t = STerm::abs(
            "x",
            o(),
            STerm::abs("x", Ty::arrow(o(), o()), STerm::var("x")),
        );
        assert_eq!(
            t.type_of(),
            Ok(Ty::arrow(
                o(),
                Ty::arrow(Ty::arrow(o(), o()), Ty::arrow(o(), o()))
            ))
        );
    }

    #[test]
    fn self_application_is_rejected() {
        // λx:o. x x -- no type for this: x would need o = o → σ.
        // This is why the untyped Y combinator cannot be typed.
        let bad = STerm::abs("x", o(), STerm::app(STerm::var("x"), STerm::var("x")));
        assert_eq!(bad.type_of(), Err(TypeError::NotAFunction { fun: o() }));
    }

    #[test]
    fn mismatched_argument_is_rejected() {
        // (λx:o. x) a with a : o → o -- expected o, found o → o.
        let id = STerm::abs("x", o(), STerm::var("x"));
        let app = STerm::app(id, STerm::var("a"));
        assert_eq!(
            app.infer(&[("a".into(), Ty::arrow(o(), o()))]),
            Err(TypeError::Mismatch {
                expected: o(),
                found: Ty::arrow(o(), o()),
            })
        );
    }

    // -- Erasure round trip ==================================================

    #[test]
    fn erased_terms_reduce_like_untyped_terms() {
        // (λx:o. x) a erases to (λx. x) a, which normalizes to a.
        let id = STerm::abs("x", o(), STerm::var("x"));
        let app = STerm::app(id, STerm::var("a"));
        assert_eq!(app.erase().normalize(10), Term::var("a"));
    }
}

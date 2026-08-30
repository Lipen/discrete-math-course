//! Types and typing contexts for the simply-typed lambda calculus (λ→).
//!
//! A type is a named base type (`Nat`, `Bool`, ...) or a function type
//! `dom -> cod`. Types are written right-associative: `Nat -> Nat -> Nat` is
//! `Nat -> (Nat -> Nat)`.
//!
//! ```
//! use type_theory::ty::Type;
//! assert_eq!(Type::nat().to_string(), "Nat");
//! assert_eq!(
//!     Type::arrow(Type::nat(), Type::boolean()).to_string(),
//!     "Nat -> Bool"
//! );
//! // Arrow domains that are themselves arrows need parentheses.
//! let f = Type::arrow(Type::arrow(Type::nat(), Type::nat()), Type::nat());
//! assert_eq!(f.to_string(), "(Nat -> Nat) -> Nat");
//! ```

use std::fmt;

/// A type of the simply-typed lambda calculus (λ→).
///
/// Three forms:
/// - `Base` -- a named base type such as `Nat` or `Bool`;
/// - `Arrow` -- a function type `dom -> cod`;
/// - `Var` -- a type variable. After generalization the name is a schematic
///   variable (`a`, `b`, ...); during unification-based inference the name is
///   a metavariable (`?0`, `?1`, ...).
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Type {
    /// A named base type, e.g. `Nat` or `Bool`.
    Base(String),
    /// Function type `dom -> cod`.
    Arrow(Box<Type>, Box<Type>),
    /// A type variable -- schematic after generalization, an inference
    /// metavariable during unification.
    Var(String),
}

impl Type {
    /// The base type whose name is `name`.
    pub fn base(name: impl Into<String>) -> Type {
        Type::Base(name.into())
    }

    /// The `Nat` base type.
    pub fn nat() -> Type {
        Type::Base("Nat".into())
    }

    /// The `Bool` base type.
    pub fn boolean() -> Type {
        Type::Base("Bool".into())
    }

    /// The function type `dom -> cod`.
    pub fn arrow(dom: Type, cod: Type) -> Type {
        Type::Arrow(Box::new(dom), Box::new(cod))
    }

    /// A type variable named `name`.
    pub fn var(name: impl Into<String>) -> Type {
        Type::Var(name.into())
    }

    /// Is this a function type?
    pub fn is_arrow(&self) -> bool {
        matches!(self, Type::Arrow(..))
    }

    /// Is this a type variable?
    pub fn is_var(&self) -> bool {
        matches!(self, Type::Var(_))
    }

    /// Is this a base type?
    pub fn is_base(&self) -> bool {
        matches!(self, Type::Base(_))
    }

    /// The domain, if this is an arrow type.
    pub fn dom(&self) -> Option<&Type> {
        match self {
            Type::Arrow(dom, _) => Some(dom),
            _ => None,
        }
    }

    /// The codomain (result type), if this is an arrow type.
    pub fn cod(&self) -> Option<&Type> {
        match self {
            Type::Arrow(_, cod) => Some(cod),
            _ => None,
        }
    }
}

impl fmt::Display for Type {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Type::Base(name) => write!(f, "{name}"),
            Type::Var(name) => write!(f, "{name}"),
            // Arrow domains that are themselves arrows need parentheses:
            // (Nat -> Nat) -> Nat, not Nat -> Nat -> Nat.
            Type::Arrow(dom, cod) => match dom.as_ref() {
                Type::Base(..) | Type::Var(..) => write!(f, "{dom} -> {cod}"),
                Type::Arrow(..) => write!(f, "({dom}) -> {cod}"),
            },
        }
    }
}

/// A typing context `Γ`: a list of variable -> type assumptions.
///
/// Contexts display as `x : Nat, f : Nat -> Bool`. The context is a list;
/// a later assumption of the same name shadows an earlier one, so the
/// innermost binder wins.
///
/// ```
/// use type_theory::ty::{Context, Type};
/// let ctx = Context::new().extend("x", Type::nat());
/// assert_eq!(ctx.lookup("x"), Some(&Type::nat()));
/// assert_eq!(ctx.to_string(), "x : Nat");
/// ```
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct Context(Vec<(String, Type)>);

impl Context {
    /// An empty context.
    pub fn new() -> Context {
        Context(Vec::new())
    }

    /// Extend with `var : ty`, returning a new context (the old is unchanged).
    pub fn extend(&self, var: impl Into<String>, ty: Type) -> Context {
        let mut entries = self.0.clone();
        entries.push((var.into(), ty));
        Context(entries)
    }

    /// Look up the type of `var`, innermost binding first.
    pub fn lookup(&self, var: &str) -> Option<&Type> {
        self.0
            .iter()
            .rev()
            .find(|(name, _)| name == var)
            .map(|(_, ty)| ty)
    }

    /// Iterate the assumptions, outermost binding first.
    pub fn iter(&self) -> std::slice::Iter<'_, (String, Type)> {
        self.0.iter()
    }

    /// Is the context empty?
    pub fn is_empty(&self) -> bool {
        self.0.is_empty()
    }

    /// The number of assumptions.
    pub fn len(&self) -> usize {
        self.0.len()
    }
}

impl fmt::Display for Context {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        for (i, (name, ty)) in self.0.iter().enumerate() {
            if i > 0 {
                write!(f, ", ")?;
            }
            write!(f, "{name} : {ty}")?;
        }
        Ok(())
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    // -- Type construction and display ========================================

    #[test]
    fn base_type_display() {
        assert_eq!(Type::nat().to_string(), "Nat");
        assert_eq!(Type::boolean().to_string(), "Bool");
    }

    #[test]
    fn arrow_type_is_right_associative() {
        // Nat -> Nat -> Nat  is  Nat -> (Nat -> Nat)
        let a = Type::arrow(Type::nat(), Type::arrow(Type::nat(), Type::nat()));
        assert_eq!(a.to_string(), "Nat -> Nat -> Nat");
    }

    #[test]
    fn arrow_domain_gets_parentheses() {
        let f = Type::arrow(Type::arrow(Type::nat(), Type::nat()), Type::nat());
        assert_eq!(f.to_string(), "(Nat -> Nat) -> Nat");
    }

    #[test]
    fn type_var_displays_as_its_name() {
        assert_eq!(Type::var("a").to_string(), "a");
        assert_eq!(Type::var("?0").to_string(), "?0");
    }

    #[test]
    fn accessors() {
        let f = Type::arrow(Type::nat(), Type::boolean());
        assert_eq!(f.dom(), Some(&Type::nat()));
        assert_eq!(f.cod(), Some(&Type::boolean()));
        assert!(f.is_arrow());
        assert!(!Type::nat().is_arrow());
        assert!(Type::var("a").is_var());
        assert!(!Type::nat().is_var());
    }

    // -- Context ==============================================================

    #[test]
    fn empty_context_is_empty() {
        assert!(Context::new().is_empty());
    }

    #[test]
    fn extend_and_lookup() {
        let ctx = Context::new().extend("x", Type::nat());
        assert_eq!(ctx.lookup("x"), Some(&Type::nat()));
        assert_eq!(ctx.len(), 1);
    }

    #[test]
    fn lookup_shadows_outermost() {
        let ctx = Context::new()
            .extend("x", Type::nat())
            .extend("x", Type::boolean());
        assert_eq!(ctx.lookup("x"), Some(&Type::boolean()));
    }

    #[test]
    fn context_display() {
        let ctx = Context::new()
            .extend("x", Type::nat())
            .extend("f", Type::arrow(Type::nat(), Type::boolean()));
        assert_eq!(ctx.to_string(), "x : Nat, f : Nat -> Bool");
    }

    #[test]
    fn lookup_unknown_returns_none() {
        let ctx = Context::new().extend("x", Type::nat());
        assert_eq!(ctx.lookup("y"), None);
    }
}

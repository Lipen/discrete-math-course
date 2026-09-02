//! Simply-typed lambda calculus (λ→).
//!
//! Types ([`ty`]) are base types and function types, and contexts list the assumptions on free variables.
//! Untyped [`Term`]s -- variables, abstractions, applications -- carry no annotations: they are the syntax on which inference runs.
//! Church-style [`STerm`]s carry annotations on their binders and are checked by the three rules var/app/abs ([`checker`], which also demonstrates **subject reduction**: a typed term β-reduces preserving its type).
//! [`infer`] infers the most general type of an untyped term by unification with metavariables, and rejects self-application `λx. x x`, since that needs `σ = σ -> τ`.
//!
//! ```
//! use type_theory::{infer, Term};
//!
//! // λx. x  -- the identity, inferred as the scheme a -> a.
//! let id = Term::abs("x", Term::var("x"));
//! assert_eq!(infer(&id).unwrap().to_string(), "a -> a");
//!
//! // λx. x x  -- self-application, rejected: it would need σ = σ -> τ.
//! let omega = Term::abs("x", Term::app(Term::var("x"), Term::var("x")));
//! assert!(infer(&omega).is_err());
//! ```

pub mod checker;
pub mod infer;
pub mod term;
pub mod ty;

pub use checker::{STerm, TypeError};
pub use infer::{infer, infer_in, InferError};
pub use term::Term;
pub use ty::{Context, Type};

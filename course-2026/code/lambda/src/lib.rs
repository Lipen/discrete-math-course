//! Untyped lambda calculus.
//!
//! Terms ([`term`]), capture-avoiding substitution and α-conversion
//! ([`subst`]), reduction strategies -- normal order, applicative order, and
//! weak head normal form, all fuel-limited with step counters ([`eval`]) --
//! Church encodings ([`church`]), well-known combinators ([`combinators`]),
//! fixed-point combinators Y and Z with a factorial built from Z
//! ([`fixpoint`]), and a tiny simply-typed layer ([`stlc`]).
//!
//! ```
//! use lambda::{Term, church};
//!
//! // Build the term `(λx. x) (church 3)` and normalize it.
//! let id = Term::abs("x", Term::var("x"));
//! let term = Term::app(id, church(3));
//! let result = term.normalize(100);
//! assert_eq!(church::to_nat(&result), Some(3));
//! ```

pub mod church;
pub mod combinators;
pub mod eval;
pub mod fixpoint;
pub mod stlc;
pub mod subst;
pub mod term;

pub use church::{
    add, church, church_false, church_to_bool, church_true, is_zero, mult, power, pred, succ,
    to_nat,
};
pub use combinators::{i, k, omega, s, self_app, y};
pub use eval::Reduction;
pub use fixpoint::{fact, fact_step, z};
pub use term::Term;

//! Untyped lambda calculus.
//!
//! The crate provides terms ([`term`]), capture-avoiding substitution and α-conversion ([`subst`]), and fuel-limited reduction strategies with step counters ([`eval`]): normal order, applicative order, and weak head normal form.
//! Church encodings ([`church`]) and the SKI combinators ([`combinators`]) are pure λ-terms, and a tiny simply-typed layer ([`stlc`]) sits on top.
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
pub mod stlc;
pub mod subst;
pub mod term;

pub use church::{
    add, church, church_false, church_to_bool, church_true, is_zero, mult, power, pred, succ,
    to_nat,
};
pub use combinators::{i, k, s};
pub use eval::Reduction;
pub use term::Term;

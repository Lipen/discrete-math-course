//! Untyped lambda calculus.
//!
//! Terms, capture-avoiding substitution, β-reduction, Church encodings,
//! and well-known combinators. A teaching crate for the lambda-calculus
//! chapter.
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
pub mod term;

pub use church::{
    add, church, church_false, church_to_bool, church_true, mult, power, succ, to_nat,
};
pub use combinators::{i, k, omega, s, self_app, y};
pub use term::Term;

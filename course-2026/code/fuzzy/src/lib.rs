//! Fuzzy sets, fuzzy numbers, and fuzzy relations.
//!
//! A fuzzy set replaces the crisp characteristic function `chi: U -> {0, 1}`
//! with a membership function `mu: U -> [0, 1]`: an element belongs to the
//! set *to some degree*. This crate models the standard shapes (triangular,
//! trapezoidal, and any polyline) as piecewise-linear functions, implements
//! Zadeh's operations (union `max`, intersection `min`, complement `1 - mu`),
//! the three classical t-norm/t-conorm families, fuzzy numbers with their
//! alpha-cuts, and fuzzy relations with max-min composition.

pub mod number;
pub mod relation;
pub mod set;
pub mod tnorm;

pub use number::{Trapezoidal, Triangular};
pub use relation::FuzzyRelation;
pub use set::FuzzySet;
pub use tnorm::TNorm;

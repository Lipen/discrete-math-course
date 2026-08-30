//! Fuzzy sets, fuzzy numbers, fuzzy relations, and a Mamdani inference engine.
//!
//! A fuzzy set replaces the crisp characteristic function `chi: U -> {0, 1}`
//! with a membership function `mu: U -> [0, 1]`: an element belongs to the
//! set *to some degree*. This crate models the standard shapes (triangular,
//! trapezoidal, and any polyline) as piecewise-linear functions, implements
//! Zadeh's operations (union `max`, intersection `min`, complement `1 - mu`),
//! the three classical t-norm/t-conorm families, fuzzy numbers with their
//! alpha-cuts, fuzzy relations with max-min composition, and a Mamdani
//! controller that turns crisp inputs into a crisp output via fuzzification,
//! a rule base, aggregation, and defuzzification.

pub mod inference;
pub mod number;
pub mod relation;
pub mod set;
pub mod tnorm;

pub use inference::{defuzzify, Defuzzifier, Mamdani, Rule, Term, Variable};
pub use number::{Trapezoidal, Triangular};
pub use relation::FuzzyRelation;
pub use set::FuzzySet;
pub use tnorm::TNorm;

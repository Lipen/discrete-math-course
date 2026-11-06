//! Truncated formal power series and the sequences they encode.
//!
//! A formal power series is an infinite sum `a_0 + a_1 x + a_2 x^2 + ...` read as a sequence of coefficients.
//! The variable `x` is a marker that records position, and no convergence question arises.
//! [`Series`] keeps the coefficients from degree `0` through a fixed degree `N` and discards higher terms.
//! That is enough for every construction here: one more coefficient of a sum, a product, or a quotient needs only one more coefficient of the inputs.
//!
//! ```
//! use generating_functions::Series;
//!
//! // 1/(1 - x) = 1 + x + x^2 + ...
//! let denominator = Series::constant(1, 2).sub(&Series::x(2));
//! let geometric = denominator.inverse().expect("constant term is 1");
//! assert_eq!(geometric.coefficients(), &[1, 1, 1]);
//! ```

pub mod sequences;
pub mod series;

pub use sequences::{
    catalan_numbers, catalan_series, fibonacci_numbers, fibonacci_series, partition_numbers,
    partition_series,
};
pub use series::Series;

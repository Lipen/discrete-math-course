//! Discrete probability: four distributions and sample covariance.
//!
//! A single trial with success probability `p` generates Bernoulli, binomial,
//! and geometric distributions. The Poisson distribution is the limit of the
//! binomial one when trials are many and successes are rare.
//!
//! ```
//! use probability::Distribution;
//!
//! let calls = Distribution::Poisson { lambda: 3.0 };
//! // P(X = 5) for three calls per minute.
//! assert!((calls.pmf(5) - 0.1008).abs() < 0.001);
//! assert_eq!(calls.mean(), 3.0);
//! ```
//!
//! The statistics module works with finite data sets: mean, variance,
//! covariance, and the Pearson correlation coefficient.

pub mod distribution;
pub mod statistics;

pub use distribution::Distribution;
pub use statistics::{correlation, covariance, mean, variance};

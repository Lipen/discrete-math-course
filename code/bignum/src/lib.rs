//! Arbitrary-precision integers built the schoolbook way: a sign flag plus a
//! magnitude stored as limbs of base `2^32`, least significant first.
//!
//! The crate shows the classic column algorithms on numbers of any width:
//! addition ripples the carry upward, comparison reads from the most
//! significant limb, subtraction borrows limb by limb, and multiplication
//! turns every limb pair into one double-width product. Division works by
//! shift-subtract and also powers the decimal conversion, nine digits at a
//! time. On top of the two layers, [`factorial`] and [`fibonacci`] produce
//! values far beyond 64 bits, and a seeded generator drives randomized
//! property checks against the built-in types.
//!
//! ```
//! use bignum::BigInt;
//!
//! let a = BigInt::from_i64(-1_000_000);
//! let b = BigInt::from_u64(2_500_000);
//! assert_eq!((a.clone() + b.clone()).to_string(), "1500000");
//! assert_eq!((a * b).to_string(), "-2500000000000");
//! ```

pub mod integer;
pub mod magnitude;
pub mod rng;

pub use integer::{factorial, fibonacci, BigInt, Sign};
pub use magnitude::{Magnitude, BASE, BASE_BITS};

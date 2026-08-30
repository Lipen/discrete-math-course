//! Combinatorial object generators.
//!
//! Four families of combinatorial objects -- permutations, combinations,
//! derangements, and integer partitions -- each enumerated in lexicographic
//! order. The counts match the theory: `n!`, `C(n, k)`, and the subfactorial
//! `!n`.
//!
//! ```
//! use combinatorics::{next_permutation, permutations};
//!
//! let mut p = vec![2, 4, 1, 3];
//! next_permutation(&mut p);
//! assert_eq!(p, vec![2, 4, 3, 1]);
//!
//! assert_eq!(permutations(4).len(), 24);
//! ```

pub mod combination;
pub mod derangement;
pub mod partition;
pub mod permutation;

pub use combination::{binomial, combinations, count_combinations};
pub use derangement::{derangements, subfactorial};
pub use partition::partitions;
pub use permutation::{factorial, next_permutation, permutations};

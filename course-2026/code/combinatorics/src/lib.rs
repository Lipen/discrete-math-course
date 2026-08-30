//! Combinatorial object generators.
//!
//! Four families of combinatorial objects -- permutations, combinations,
//! derangements, and integer partitions -- each enumerated in lexicographic
//! order with a rank/unrank pairing. The counts match the theory: `n!`,
//! `C(n, k)`, the subfactorial `!n`, and the partition number `p(n)`.
//!
//! Rank assigns each object its position in the lexicographic enumeration,
//! starting at 0; unrank returns the object with a given rank. Together they
//! form a bijection `rank(unrank(r)) == r` and `unrank(rank(x)) == x`.
//!
//! ```
//! use combinatorics::{next_permutation, permutations, unrank_permutation};
//!
//! let mut p = vec![2, 4, 1, 3];
//! next_permutation(&mut p);
//! assert_eq!(p, vec![2, 4, 3, 1]);
//!
//! assert_eq!(permutations(4).len(), 24);
//! assert_eq!(unrank_permutation(4, 0), vec![0, 1, 2, 3]);
//! ```

pub mod combination;
pub mod derangement;
pub mod partition;
pub mod permutation;

pub use combination::{
    binomial, combinations, count_combinations, rank_combination, unrank_combination,
};
pub use derangement::{
    derangements, rank_derangement, subfactorial, unrank_derangement,
};
pub use partition::{partition_count, partitions, rank_partition, unrank_partition};
pub use permutation::{
    factorial, next_permutation, permutations, rank_permutation, unrank_permutation,
};

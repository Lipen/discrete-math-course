//! Permutations: next_permutation, lexicographic enumeration, rank, unrank.
//!
//! The three classic steps of `next_permutation`: the longest decreasing
//! suffix, the pivot swap, and the reversal. Then the whole list and the
//! rank/unrank bijection.

use combinatorics::{next_permutation, permutations, rank_permutation, unrank_permutation};

fn main() {
    // Step through: (2, 4, 1, 3) -> (2, 4, 3, 1).
    let mut p = vec![2, 4, 1, 3];
    println!("before:   {:?}", p);
    next_permutation(&mut p);
    println!("next:     {:?}", p);

    // Enumerate all permutations of 0..3.
    let all = permutations(3);
    println!("\nall permutations of 0..3 ({} of them):", all.len());
    for q in &all {
        println!("  {:?}", q);
    }

    // Rank every permutation, and unrank it back.
    println!("\nrank <-> unrank for 0..4:");
    for r in 0..24 {
        let q = unrank_permutation(4, r);
        assert_eq!(rank_permutation(&q), r);
        println!("  rank {:2} -> {:?} -> rank {}", r, q, rank_permutation(&q));
    }

    println!("\ncount: {} permutations of 0..5 (5!)", permutations(5).len());
}

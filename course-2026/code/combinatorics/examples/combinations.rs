//! Combinations: lexicographic enumeration, rank, and unrank of k-subsets.
//!
//! Ranking subtracts prefix blocks: at position i we drop every subset whose
//! i-th element is smaller than the current one.

use combinatorics::{combinations, count_combinations, rank_combination, unrank_combination};

fn main() {
    // Enumerate the 2-subsets of 0..4.
    let cs = combinations(4, 2);
    println!("2-subsets of 0..4 ({} of them):", cs.len());
    for c in &cs {
        println!("  {:?}", c);
    }

    // C(10, 5) = 252.
    println!("\nC(10, 5) = {}", count_combinations(10, 5));

    // Rank every 3-subset of 0..5 and unrank it back.
    println!("\nrank <-> unrank for 3-subsets of 0..5:");
    for (r, c) in combinations(5, 3).iter().enumerate() {
        assert_eq!(rank_combination(c, 5) as usize, r);
        let back = unrank_combination(5, 3, r as u64);
        assert_eq!(back, *c);
        println!("  rank {:2} -> {:?}", r, c);
    }
}

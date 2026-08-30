//! Derangements: subfactorial, enumeration, rank, and unrank.
//!
//! A derangement is a permutation with no fixed point. The count is the
//! subfactorial !n = (n-1)(!(n-1) + !(n-2)).

use combinatorics::{derangements, rank_derangement, subfactorial, unrank_derangement};

fn main() {
    // Subfactorial values !1..!6 = 0, 1, 2, 9, 44, 265.
    println!("subfactorial !n:");
    for n in 1..=6 {
        println!("  !{} = {}", n, subfactorial(n));
    }

    // Enumerate the derangements of 0..3.
    let ds = derangements(3);
    println!("\nderangements of 0..3 ({} of them):", ds.len());
    for d in &ds {
        println!("  {:?}", d);
    }

    // The number of enumerated derangements matches the subfactorial.
    for n in 0..=5 {
        assert_eq!(derangements(n).len() as u64, subfactorial(n));
    }

    // Rank and unrank over all derangements of 0..4.
    println!("\nrank <-> unrank for derangements of 0..4:");
    for r in 0..9 {
        let d = unrank_derangement(4, r);
        assert_eq!(rank_derangement(&d), r);
        println!("  rank {} -> {:?} -> rank {}", r, d, rank_derangement(&d));
    }
}

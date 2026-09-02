//! Permutations: next_permutation and lexicographic enumeration.
//!
//! The three classic steps of `next_permutation`: the longest decreasing suffix, the pivot swap, and the reversal.
//! Then the whole list.

use combinatorics::{next_permutation, permutations};

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

    println!(
        "\ncount: {} permutations of 0..5 (5!)",
        permutations(5).len()
    );
}

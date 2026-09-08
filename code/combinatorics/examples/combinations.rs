//! Combinations: lexicographic enumeration of k-subsets.

use combinatorics::{combinations, count_combinations};

fn main() {
    // Enumerate the 2-subsets of 0..4.
    let cs = combinations(4, 2);
    println!("2-subsets of 0..4 ({} of them):", cs.len());
    for c in &cs {
        println!("  {:?}", c);
    }

    // C(10, 5) = 252.
    println!("\nC(10, 5) = {}", count_combinations(10, 5));
}

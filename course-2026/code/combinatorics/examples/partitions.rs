//! Integer partitions: lexicographic enumeration.
//!
//! A partition is written as a non-increasing list, and the enumeration walks
//! those in lexicographic order.

use combinatorics::partitions;

fn main() {
    // Count partitions of n by enumerating them (this is p(n)).
    println!("partition counts p(n) by enumeration:");
    for n in 0..=10 {
        println!("  p({}) = {}", n, partitions(n).len());
    }

    // Enumerate the partitions of 5.
    let ps = partitions(5);
    println!("\npartitions of 5 ({} of them):", ps.len());
    for p in &ps {
        println!("  {:?}", p);
    }
}

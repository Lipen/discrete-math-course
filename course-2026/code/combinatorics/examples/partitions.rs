//! Integer partitions: p(n), enumeration, rank, and unrank.
//!
//! p(n) uses Euler's pentagonal recurrence. A partition is written as a
//! non-increasing list, and the enumeration walks those in lexicographic
//! order.

use combinatorics::{partition_count, partitions, rank_partition, unrank_partition};

fn main() {
    // p(n) for small n, including the check p(10) = 42.
    println!("partition numbers p(n):");
    for n in 0..=10 {
        println!("  p({}) = {}", n, partition_count(n));
    }
    assert_eq!(partition_count(10), 42);

    // Enumerate the partitions of 5.
    let ps = partitions(5);
    println!("\npartitions of 5 ({} of them):", ps.len());
    for p in &ps {
        println!("  {:?}", p);
    }

    // The enumerated count matches p(n).
    for n in 0..=10 {
        assert_eq!(partitions(n).len() as u64, partition_count(n));
    }

    // Rank and unrank over the partitions of 5.
    println!("\nrank <-> unrank for the partitions of 5:");
    for (r, p) in ps.iter().enumerate() {
        assert_eq!(rank_partition(p) as usize, r);
        let back = unrank_partition(5, r as u64);
        assert_eq!(back, *p);
        println!("  rank {} -> {:?}", r, p);
    }
}

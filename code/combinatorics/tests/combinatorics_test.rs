//! Cross-family checks: each enumeration counts exactly the matching formula.

use combinatorics::{
    combinations, count_combinations, derangements, partitions, permutations, subfactorial,
};

#[test]
fn permutations_count_is_factorial() {
    for n in 0usize..7 {
        let fact: usize = (1..=n).product();
        assert_eq!(permutations(n).len(), fact);
    }
}

#[test]
fn combinations_count_is_binomial() {
    for n in 0usize..8 {
        for k in 0..=n {
            assert_eq!(combinations(n, k).len() as u64, count_combinations(n, k));
        }
    }
    assert_eq!(count_combinations(10, 5), 252);
}

#[test]
fn derangements_count_is_subfactorial() {
    for n in 0usize..7 {
        assert_eq!(derangements(n).len() as u64, subfactorial(n));
    }
    // !1..!6 = 0, 1, 2, 9, 44, 265.
    assert_eq!(subfactorial(1), 0);
    assert_eq!(subfactorial(2), 1);
    assert_eq!(subfactorial(3), 2);
    assert_eq!(subfactorial(4), 9);
    assert_eq!(subfactorial(5), 44);
    assert_eq!(subfactorial(6), 265);
}

#[test]
fn partitions_count_by_enumeration_length() {
    // p(0)..p(11), checked by counting the enumerated list rather than by
    // Euler's pentagonal recurrence.
    let p = [1u64, 1, 2, 3, 5, 7, 11, 15, 22, 30, 42, 56];
    for (n, &expected) in p.iter().enumerate() {
        assert_eq!(partitions(n).len() as u64, expected);
    }
}

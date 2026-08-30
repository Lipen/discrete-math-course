//! Cross-family checks: each enumeration counts exactly the matching formula,
//! and every rank/unrank pair is a bijection.

use combinatorics::{
    combinations, count_combinations, derangements, partition_count, partitions, permutations,
    rank_combination, rank_derangement, rank_partition, rank_permutation, subfactorial,
    unrank_combination, unrank_derangement, unrank_partition, unrank_permutation,
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
            assert_eq!(
                combinations(n, k).len() as u64,
                count_combinations(n, k)
            );
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
fn partitions_count_is_p() {
    for n in 0usize..12 {
        assert_eq!(partitions(n).len() as u64, partition_count(n));
    }
    assert_eq!(partition_count(10), 42);
}

#[test]
fn permutation_rank_unrank_bijection() {
    for n in 0usize..6 {
        let count = permutations(n).len();
        for r in 0..count {
            let p = unrank_permutation(n, r as u64);
            assert_eq!(rank_permutation(&p) as usize, r);
        }
        // The enumeration is exactly unrank(0..n!).
        let all = permutations(n);
        for (i, p) in all.iter().enumerate() {
            assert_eq!(unrank_permutation(n, i as u64), *p);
        }
    }
}

#[test]
fn combination_rank_unrank_bijection() {
    for n in 0usize..7 {
        for k in 0..=n {
            let count = count_combinations(n, k);
            for r in 0..count {
                let c = unrank_combination(n, k, r);
                assert_eq!(rank_combination(&c, n), r);
            }
            let all = combinations(n, k);
            for (i, c) in all.iter().enumerate() {
                assert_eq!(unrank_combination(n, k, i as u64), *c);
            }
        }
    }
}

#[test]
fn derangement_rank_unrank_bijection() {
    for n in 0usize..7 {
        let count = subfactorial(n);
        for r in 0..count {
            let d = unrank_derangement(n, r);
            assert_eq!(rank_derangement(&d), r);
        }
        let all = derangements(n);
        for (i, d) in all.iter().enumerate() {
            assert_eq!(unrank_derangement(n, i as u64), *d);
        }
    }
}

#[test]
fn partition_rank_unrank_bijection() {
    for n in 0usize..10 {
        let count = partition_count(n);
        for r in 0..count {
            let p = unrank_partition(n, r);
            assert_eq!(rank_partition(&p), r);
        }
        let all = partitions(n);
        for (i, p) in all.iter().enumerate() {
            assert_eq!(unrank_partition(n, i as u64), *p);
        }
    }
}

//! Permutations: lexicographic enumeration, rank, and unrank.
//!
//! A permutation of `0..n` is a list of the `n` values, each used exactly
//! once. The classic `next_permutation` advances to the next permutation in
//! lexicographic order in three steps: find the longest decreasing suffix,
//! swap the pivot just before it with the smallest element of the suffix that
//! is larger than the pivot, and reverse the suffix.
//!
//! Ranking uses the factorial number system: at position `i`, the number of
//! still-unused values smaller than `p[i]` contributes to the rank, each
//! scaled by `(n - 1 - i)!`.

/// The number of permutations of `n` items, `n!`.
///
/// `n!` fits in `u64` for `n <= 20`; larger `n` overflows and panics in debug
/// builds.
pub fn factorial(n: usize) -> u64 {
    (1..=n).fold(1u64, |acc, k| acc * k as u64)
}

/// Advance `p` to the next permutation in lexicographic order.
///
/// Returns `true` when `p` was advanced and `false` when `p` was already the
/// last permutation (the strictly decreasing sequence), in which case `p` is
/// left unchanged.
///
/// ```
/// use combinatorics::next_permutation;
/// let mut p = vec![2, 4, 1, 3];
/// next_permutation(&mut p);
/// assert_eq!(p, vec![2, 4, 3, 1]);
/// ```
pub fn next_permutation(p: &mut [usize]) -> bool {
    if p.len() < 2 {
        return false;
    }

    // Longest decreasing suffix: p[i..] is decreasing, p[i-1] is the pivot.
    let mut i = p.len() - 1;
    while i > 0 && p[i - 1] >= p[i] {
        i -= 1;
    }
    if i == 0 {
        return false; // the whole sequence is decreasing: last permutation.
    }

    // Swap the pivot with the smallest element of the suffix that exceeds it.
    let pivot = i - 1;
    let mut j = p.len() - 1;
    while p[j] <= p[pivot] {
        j -= 1;
    }
    p.swap(pivot, j);

    // Reverse the remainder of the suffix.
    p[pivot + 1..].reverse();
    true
}

/// All permutations of `0..n` in lexicographic order.
///
/// Returns exactly `n!` permutations.
///
/// ```
/// use combinatorics::permutations;
/// let all = permutations(3);
/// assert_eq!(all, vec![
///     vec![0, 1, 2], vec![0, 2, 1], vec![1, 0, 2],
///     vec![1, 2, 0], vec![2, 0, 1], vec![2, 1, 0],
/// ]);
/// ```
pub fn permutations(n: usize) -> Vec<Vec<usize>> {
    let mut out = Vec::new();
    let mut p: Vec<usize> = (0..n).collect();
    loop {
        out.push(p.clone());
        if !next_permutation(&mut p) {
            break;
        }
    }
    out
}

/// The lexicographic rank of a permutation of `0..n`, from `0` to `n! - 1`.
///
/// ```
/// use combinatorics::{permutations, rank_permutation};
/// for (r, p) in permutations(4).iter().enumerate() {
///     assert_eq!(rank_permutation(p) as usize, r);
/// }
/// ```
pub fn rank_permutation(p: &[usize]) -> u64 {
    let n = p.len();
    let mut rank = 0u64;
    let mut used = vec![false; n];

    for i in 0..n {
        // Count unused values smaller than p[i] at this position.
        let mut smaller = 0u64;
        for is_used in &used[..p[i]] {
            if !is_used {
                smaller += 1;
            }
        }
        rank += smaller * factorial(n - 1 - i);
        used[p[i]] = true;
    }
    rank
}

/// The permutation of `0..n` with the given lexicographic rank.
///
/// `rank` must lie in `0..n!`.
///
/// ```
/// use combinatorics::{rank_permutation, unrank_permutation};
/// for r in 0..24 {
///     let p = unrank_permutation(4, r);
///     assert_eq!(rank_permutation(&p), r);
/// }
/// ```
pub fn unrank_permutation(n: usize, rank: u64) -> Vec<usize> {
    let mut p = Vec::with_capacity(n);
    let mut available: Vec<usize> = (0..n).collect();
    let mut r = rank;

    for i in 0..n {
        let block = factorial(n - 1 - i);
        let idx = (r / block) as usize;
        r %= block;
        p.push(available.remove(idx));
    }
    p
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn factorial_small() {
        assert_eq!(factorial(0), 1);
        assert_eq!(factorial(1), 1);
        assert_eq!(factorial(5), 120);
        assert_eq!(factorial(6), 720);
    }

    #[test]
    fn next_permutation_example() {
        let mut p = vec![2, 4, 1, 3];
        assert!(next_permutation(&mut p));
        assert_eq!(p, vec![2, 4, 3, 1]);
    }

    #[test]
    fn next_permutation_is_last() {
        let mut p = vec![2, 1, 0];
        assert!(!next_permutation(&mut p));
        assert_eq!(p, vec![2, 1, 0]);
    }

    #[test]
    fn permutations_count_matches_factorial() {
        for n in 0..8 {
            let all = permutations(n);
            assert_eq!(all.len() as u64, factorial(n));
            // Each permutation is a permutation: distinct values 0..n.
            for p in &all {
                let mut sorted = p.clone();
                sorted.sort_unstable();
                assert_eq!(sorted, (0..n).collect::<Vec<_>>());
            }
        }
    }

    #[test]
    fn permutations_are_lexicographic() {
        let all = permutations(4);
        for w in all.windows(2) {
            assert!(w[0] < w[1]);
        }
    }

    #[test]
    fn rank_unrank_round_trip() {
        for n in 0..6 {
            for r in 0..factorial(n) {
                let p = unrank_permutation(n, r);
                assert_eq!(rank_permutation(&p), r);
            }
        }
    }
}

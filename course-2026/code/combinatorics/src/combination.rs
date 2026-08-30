//! Combinations: lexicographic enumeration of `k`-subsets, rank, and unrank.
//!
//! A `k`-subset of `0..n` is a strictly increasing list of `k` values. The
//! enumeration walks the choices in lexicographic order. Ranking is by
//! "subtract prefix blocks": at position `i`, every subset whose `i`-th
//! element is smaller than the current one is counted and dropped.

/// The binomial coefficient `C(n, k)`, as the number of `k`-subsets of `n`.
///
/// `C(n, k)` fits in `u64` for `n <= 67`.
pub fn binomial(n: usize, k: usize) -> u64 {
    if k > n {
        return 0;
    }
    let k = k.min(n - k);
    let mut r = 1u64;
    for i in 0..k {
        r = r * (n - i) as u64 / (i + 1) as u64;
    }
    r
}

/// The number of `k`-subsets of `0..n`, `C(n, k)`.
pub fn count_combinations(n: usize, k: usize) -> u64 {
    binomial(n, k)
}

/// All `k`-subsets of `0..n` in lexicographic order.
///
/// Returns exactly `C(n, k)` subsets.
///
/// ```
/// use combinatorics::combinations;
/// assert_eq!(combinations(4, 2), vec![
///     vec![0, 1], vec![0, 2], vec![0, 3],
///     vec![1, 2], vec![1, 3], vec![2, 3],
/// ]);
/// ```
pub fn combinations(n: usize, k: usize) -> Vec<Vec<usize>> {
    let mut out = Vec::new();
    let mut cur = Vec::new();
    fn rec(n: usize, k: usize, start: usize, cur: &mut Vec<usize>, out: &mut Vec<Vec<usize>>) {
        if cur.len() == k {
            out.push(cur.clone());
            return;
        }
        for v in start..=n - (k - cur.len()) {
            cur.push(v);
            rec(n, k, v + 1, cur, out);
            cur.pop();
        }
    }
    if k <= n {
        rec(n, k, 0, &mut cur, &mut out);
    }
    out
}

/// The lexicographic rank of a `k`-subset `c` of `0..n`, from `0` to `C(n,k)-1`.
///
/// At position `i` every subset whose `i`-th element is smaller than `c[i]`
/// (with the same prefix) is counted and dropped.
///
/// ```
/// use combinatorics::{combinations, rank_combination};
/// for (r, c) in combinations(5, 3).iter().enumerate() {
///     assert_eq!(rank_combination(c, 5) as usize, r);
/// }
/// ```
pub fn rank_combination(c: &[usize], n: usize) -> u64 {
    let k = c.len();
    let mut rank = 0u64;

    for i in 0..k {
        let lo = if i == 0 { 0 } else { c[i - 1] + 1 };
        for x in lo..c[i] {
            // Fix the prefix c[0..i], put x at position i, choose the rest
            // from {x+1..n-1}, which has (n-1-x) elements.
            rank += binomial(n - 1 - x, k - i - 1);
        }
    }
    rank
}

/// The `k`-subset of `0..n` with the given lexicographic rank.
///
/// `rank` must lie in `0..C(n,k)`.
///
/// ```
/// use combinatorics::{rank_combination, unrank_combination};
/// for r in 0..10 {
///     let c = unrank_combination(5, 2, r);
///     assert_eq!(rank_combination(&c, 5), r);
/// }
/// ```
pub fn unrank_combination(n: usize, k: usize, rank: u64) -> Vec<usize> {
    let mut c = Vec::with_capacity(k);
    let mut r = rank;
    let mut lo = 0;

    for i in 0..k {
        let mut x = lo;
        loop {
            let block = binomial(n - 1 - x, k - i - 1);
            if r < block {
                break;
            }
            r -= block;
            x += 1;
        }
        c.push(x);
        lo = x + 1;
    }
    c
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn binomial_values() {
        assert_eq!(binomial(0, 0), 1);
        assert_eq!(binomial(5, 2), 10);
        assert_eq!(binomial(10, 5), 252);
        assert_eq!(binomial(6, 0), 1);
        assert_eq!(binomial(6, 6), 1);
        assert_eq!(binomial(3, 5), 0);
    }

    #[test]
    fn combinations_count_matches_binomial() {
        for n in 0..8 {
            for k in 0..=n {
                let cs = combinations(n, k);
                assert_eq!(cs.len() as u64, count_combinations(n, k));
                // Each is a strictly increasing k-subset of 0..n.
                for c in &cs {
                    assert_eq!(c.len(), k);
                    for w in c.windows(2) {
                        assert!(w[0] < w[1]);
                    }
                    assert!(c.iter().all(|&v| v < n));
                }
            }
        }
    }

    #[test]
    fn combinations_are_lexicographic() {
        let cs = combinations(6, 3);
        for w in cs.windows(2) {
            assert!(w[0] < w[1]);
        }
    }

    #[test]
    fn rank_unrank_round_trip() {
        for n in 0..7 {
            for k in 0..=n {
                for r in 0..count_combinations(n, k) {
                    let c = unrank_combination(n, k, r);
                    assert_eq!(rank_combination(&c, n), r);
                }
            }
        }
    }
}

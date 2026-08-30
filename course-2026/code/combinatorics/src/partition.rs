//! Integer partitions: enumeration, rank, and unrank.
//!
//! A partition of `n` is a non-increasing list of positive integers summing
//! to `n` (e.g. `3 + 1` and `2 + 2` for `n = 4`). The count `p(n)` comes from
//! Euler's pentagonal recurrence, and the enumeration walks the non-increasing
//! sequences in lexicographic order.
//!
//! Ranking and unranking count "partitions of a remainder with parts bounded
//! by a maximum" via a simple recurrence, so they avoid materializing the
//! whole list.

use std::collections::HashMap;

/// The partition number `p(n)`: the number of non-increasing partitions of `n`.
///
/// Uses Euler's pentagonal recurrence
/// `p(n) = sum_k (-1)^(k+1) (p(n - g1(k)) + p(n - g2(k)))` with the
/// generalized pentagonal numbers `g1(k) = k(3k-1)/2` and `g2(k) = k(3k+1)/2`.
///
/// ```
/// use combinatorics::partition_count;
/// assert_eq!(partition_count(5), 7);
/// assert_eq!(partition_count(10), 42);
/// ```
pub fn partition_count(n: usize) -> u64 {
    let mut p = vec![0i128; n + 1];
    p[0] = 1;

    for i in 1..=n {
        let mut total = 0i128;
        let mut k = 1;
        loop {
            let g1 = k * (3 * k - 1) / 2;
            let g2 = k * (3 * k + 1) / 2;
            if g1 > i && g2 > i {
                break;
            }
            let mut term = 0i128;
            if g1 <= i {
                term += p[i - g1];
            }
            if g2 <= i {
                term += p[i - g2];
            }
            if k % 2 == 1 {
                total += term;
            } else {
                total -= term;
            }
            k += 1;
        }
        p[i] = total;
    }
    p[n] as u64
}

/// Number of partitions of `rem` into parts each at most `max`.
///
/// Recurrence: `count(rem, max) = count(rem, max-1) + count(rem-max, max)`.
fn count_partitions(rem: usize, max: usize, memo: &mut HashMap<(usize, usize), u64>) -> u64 {
    if rem == 0 {
        return 1;
    }
    if max == 0 {
        return 0;
    }
    if max > rem {
        return count_partitions(rem, rem, memo);
    }
    if let Some(&c) = memo.get(&(rem, max)) {
        return c;
    }
    let c = count_partitions(rem, max - 1, memo) + count_partitions(rem - max, max, memo);
    memo.insert((rem, max), c);
    c
}

/// All non-increasing partitions of `n` in lexicographic order.
///
/// Returns exactly `p(n)` partitions.
///
/// ```
/// use combinatorics::partitions;
/// assert_eq!(partitions(4), vec![
///     vec![1, 1, 1, 1], vec![2, 1, 1], vec![2, 2],
///     vec![3, 1], vec![4],
/// ]);
/// ```
pub fn partitions(n: usize) -> Vec<Vec<usize>> {
    let mut out = Vec::new();
    let mut cur = Vec::new();
    fn rec(rem: usize, max: usize, cur: &mut Vec<usize>, out: &mut Vec<Vec<usize>>) {
        if rem == 0 {
            out.push(cur.clone());
            return;
        }
        for d in 1..=max.min(rem) {
            cur.push(d);
            rec(rem - d, d, cur, out);
            cur.pop();
        }
    }
    rec(n, n, &mut cur, &mut out);
    out
}

/// The lexicographic rank of a non-increasing partition `p`, from `0` to `p(n)-1`.
///
/// `p` must be a non-increasing partition of `n` (the parts sum to `n`).
///
/// ```
/// use combinatorics::{partitions, rank_partition};
/// for (r, p) in partitions(4).iter().enumerate() {
///     assert_eq!(rank_partition(p) as usize, r);
/// }
/// ```
pub fn rank_partition(p: &[usize]) -> u64 {
    let mut memo = HashMap::new();
    let mut rank = 0u64;
    let mut rem: usize = p.iter().sum();

    for &part in p {
        // Every partition with a smaller part at this position and the same
        // prefix is smaller than `p`.
        for d in 1..part {
            rank += count_partitions(rem - d, d, &mut memo);
        }
        rem -= part;
    }
    rank
}

/// The non-increasing partition of `n` with the given lexicographic rank.
///
/// `rank` must lie in `0..p(n)`.
///
/// ```
/// use combinatorics::{rank_partition, unrank_partition};
/// for r in 0..7 {
///     let p = unrank_partition(5, r);
///     assert_eq!(rank_partition(&p), r);
/// }
/// ```
pub fn unrank_partition(n: usize, rank: u64) -> Vec<usize> {
    let mut out = Vec::new();
    let mut memo = HashMap::new();
    let mut rem = n;
    let mut r = rank;

    while rem > 0 {
        let mut d = 1;
        loop {
            let block = count_partitions(rem - d, d, &mut memo);
            if r < block {
                out.push(d);
                rem -= d;
                break;
            }
            r -= block;
            d += 1;
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn pentagonal_values() {
        assert_eq!(partition_count(0), 1);
        assert_eq!(partition_count(1), 1);
        assert_eq!(partition_count(2), 2);
        assert_eq!(partition_count(3), 3);
        assert_eq!(partition_count(4), 5);
        assert_eq!(partition_count(5), 7);
        assert_eq!(partition_count(10), 42);
    }

    #[test]
    fn partitions_count_matches_p() {
        for n in 0..12 {
            let ps = partitions(n);
            assert_eq!(ps.len() as u64, partition_count(n));
            // Each is non-increasing and sums to n.
            for p in &ps {
                assert_eq!(p.iter().sum::<usize>(), n);
                assert!(p.iter().all(|&x| x > 0));
                for w in p.windows(2) {
                    assert!(w[0] >= w[1]);
                }
            }
        }
    }

    #[test]
    fn partitions_are_lexicographic() {
        let ps = partitions(6);
        for w in ps.windows(2) {
            assert!(w[0] < w[1]);
        }
    }

    #[test]
    fn rank_unrank_round_trip() {
        for n in 0..10 {
            let count = partition_count(n);
            for r in 0..count {
                let p = unrank_partition(n, r);
                assert_eq!(rank_partition(&p), r);
            }
        }
    }
}

//! Integer partitions: lexicographic enumeration.
//!
//! A partition of `n` is a non-increasing list of positive integers summing to `n` (e.g. `3 + 1` and `2 + 2` for `n = 4`).
//! The enumeration walks the non-increasing sequences in lexicographic order.

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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn partitions_count_by_enumeration_length() {
        // p(0)..p(11), checked by counting the enumerated list rather than by
        // Euler's pentagonal recurrence.
        let p = [1u64, 1, 2, 3, 5, 7, 11, 15, 22, 30, 42, 56];
        for (n, &expected) in p.iter().enumerate() {
            let ps = partitions(n);
            assert_eq!(ps.len() as u64, expected);
            // Each is non-increasing and sums to n.
            for q in &ps {
                assert_eq!(q.iter().sum::<usize>(), n);
                assert!(q.iter().all(|&x| x > 0));
                for w in q.windows(2) {
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
}

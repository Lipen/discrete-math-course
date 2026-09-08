//! Derangements: permutations with no fixed point.
//!
//! A derangement of `0..n` is a permutation in which no element stays in its own position (`p[i] != i` for every `i`).
//! The count is the subfactorial `!n`, given by the recurrence `!n = (n - 1) * (!(n-1) + !(n-2))` with `!0 = 1` and `!1 = 0`.
//!
//! Enumeration walks the positions in lexicographic order, skipping the fixed-point value at each step.

/// The subfactorial `!n`: the number of derangements of `0..n`.
///
/// Uses `!n = (n - 1) * (!(n-1) + !(n-2))`.
///
/// ```
/// use combinatorics::subfactorial;
/// assert_eq!(subfactorial(0), 1);
/// assert_eq!(subfactorial(4), 9);
/// ```
pub fn subfactorial(n: usize) -> u64 {
    match n {
        0 => 1,
        1 => 0,
        _ => {
            // a = !(i-2), b = !(i-1), stepped up to !n.
            let (mut a, mut b) = (1u64, 0u64);
            for i in 2..=n {
                let c = (i - 1) as u64 * (a + b);
                a = b;
                b = c;
            }
            b
        }
    }
}

/// All derangements of `0..n` in lexicographic order.
///
/// Returns exactly `!n` derangements.
///
/// ```
/// use combinatorics::derangements;
/// assert_eq!(derangements(3), vec![vec![1, 2, 0], vec![2, 0, 1]]);
/// ```
#[allow(clippy::needless_range_loop)]
pub fn derangements(n: usize) -> Vec<Vec<usize>> {
    let mut out = Vec::new();
    let mut p = vec![0usize; n];
    let mut used = vec![false; n];

    #[allow(clippy::needless_range_loop)]
    fn rec(pos: usize, n: usize, p: &mut [usize], used: &mut [bool], out: &mut Vec<Vec<usize>>) {
        if pos == n {
            out.push(p.to_vec());
            return;
        }
        for v in 0..n {
            if v == pos || used[v] {
                continue;
            }
            used[v] = true;
            p[pos] = v;
            rec(pos + 1, n, p, used, out);
            used[v] = false;
        }
    }

    rec(0, n, &mut p, &mut used, &mut out);
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn subfactorial_sequence() {
        assert_eq!(subfactorial(0), 1);
        // !1..!6 = 0, 1, 2, 9, 44, 265.
        assert_eq!(subfactorial(1), 0);
        assert_eq!(subfactorial(2), 1);
        assert_eq!(subfactorial(3), 2);
        assert_eq!(subfactorial(4), 9);
        assert_eq!(subfactorial(5), 44);
        assert_eq!(subfactorial(6), 265);
    }

    #[test]
    fn derangements_count_matches_subfactorial() {
        for n in 0..8 {
            let ds = derangements(n);
            assert_eq!(ds.len() as u64, subfactorial(n));
            // No fixed point in any of them.
            for p in &ds {
                for (i, v) in p.iter().enumerate() {
                    assert_ne!(*v, i);
                }
            }
        }
    }

    #[test]
    fn derangements_are_lexicographic() {
        let ds = derangements(5);
        for w in ds.windows(2) {
            assert!(w[0] < w[1]);
        }
    }
}

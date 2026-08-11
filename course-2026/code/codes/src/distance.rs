//! Hamming distance and code capability.
//!
//! The Hamming distance between two equal-length bit strings is the number of
//! positions where they differ. A code's minimum distance `d` determines its
//! error-handling power: it detects up to `d - 1` errors and corrects up to
//! `floor((d - 1) / 2)`.

/// The number of positions where two equal-length bit slices differ.
///
/// ```
/// assert_eq!(codes::hamming_distance(&[false, true, false], &[true, true, false]), 1);
/// assert_eq!(codes::hamming_distance(&[false, false], &[true, true]), 2);
/// assert_eq!(codes::hamming_distance(&[true, false], &[true, false]), 0);
/// ```
///
/// ```should_panic
/// // Different lengths panic.
/// codes::hamming_distance(&[false], &[false, true]);
/// ```
pub fn hamming(a: &[bool], b: &[bool]) -> usize {
    assert_eq!(
        a.len(),
        b.len(),
        "hamming_distance: bit strings must have equal length"
    );
    a.iter().zip(b).filter(|(x, y)| x != y).count()
}

/// The smallest Hamming distance between any two distinct codewords.
///
/// Requires at least two codewords of equal length.
///
/// ```
/// let words = vec![
///     vec![false, false, false],
///     vec![true, true, true],
/// ];
/// assert_eq!(codes::min_distance(&words), 3);
/// ```
pub fn min_distance(words: &[Vec<bool>]) -> usize {
    assert!(
        words.len() >= 2,
        "min_distance: need at least two codewords"
    );
    let mut best = usize::MAX;
    for i in 0..words.len() {
        for j in (i + 1)..words.len() {
            best = best.min(hamming(&words[i], &words[j]));
        }
    }
    best
}

/// How many errors a code of minimum distance `d` detects: `d - 1`.
///
/// ```
/// assert_eq!(codes::detects_up_to(3), 2);
/// assert_eq!(codes::detects_up_to(4), 3);
/// assert_eq!(codes::detects_up_to(0), 0);
/// ```
pub fn detects_up_to(d: usize) -> usize {
    d.saturating_sub(1)
}

/// How many errors a code of minimum distance `d` corrects: `(d - 1) / 2`.
///
/// ```
/// assert_eq!(codes::corrects_up_to(3), 1);
/// assert_eq!(codes::corrects_up_to(4), 1);
/// assert_eq!(codes::corrects_up_to(2), 0);
/// ```
pub fn corrects_up_to(d: usize) -> usize {
    d.saturating_sub(1) / 2
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn hamming_matches_hand_computed() {
        assert_eq!(hamming(&[false, true, false], &[true, true, false]), 1);
        assert_eq!(hamming(&[false; 3], &[true; 3]), 3);
        assert_eq!(hamming(&[true, false], &[true, false]), 0);
    }

    #[test]
    #[should_panic]
    fn hamming_panics_on_different_lengths() {
        hamming(&[false], &[false, true]);
    }

    #[test]
    fn min_distance_same_word_is_zero() {
        let words = vec![vec![false, true, false], vec![false, true, false]];
        assert_eq!(min_distance(&words), 0);
    }

    #[test]
    fn capability_helpers() {
        assert_eq!(detects_up_to(2), 1);
        assert_eq!(corrects_up_to(2), 0);
        assert_eq!(detects_up_to(3), 2);
        assert_eq!(corrects_up_to(3), 1);
        assert_eq!(detects_up_to(4), 3);
        assert_eq!(corrects_up_to(4), 1);
        assert_eq!(detects_up_to(0), 0);
        assert_eq!(corrects_up_to(0), 0);
    }
}

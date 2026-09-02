//! Repetition code (3, 1, 3): each bit sent three times, majority vote.
//!
//! Distance 3 means one error is outvoted.
//! Two errors flip the vote.
//! The code is the honest naive answer to noise -- it works, but spends three
//! bits to protect one (rate 1/3).

/// Encodes one bit as three identical bits.
///
/// ```
/// assert_eq!(codes::repetition::encode(true), [true, true, true]);
/// assert_eq!(codes::repetition::encode(false), [false, false, false]);
/// ```
pub fn encode(bit: bool) -> [bool; 3] {
    [bit, bit, bit]
}

/// Decodes a 3-bit word by majority vote.
///
/// Two out of three equal bits win, so any single error is outvoted.
/// Two errors flip the vote -- the price of the naive code.
///
/// ```
/// // Clean.
/// assert!(codes::repetition::decode([true, true, true]));
/// assert!(!codes::repetition::decode([false, false, false]));
///
/// // One error: outvoted.
/// assert!(codes::repetition::decode([true, true, false]));
/// assert!(codes::repetition::decode([false, true, true]));
///
/// // Two errors: vote flipped (original true -> decoded false).
/// assert!(!codes::repetition::decode([false, false, true]));
/// assert!(!codes::repetition::decode([true, false, false]));
/// ```
pub fn decode(word: [bool; 3]) -> bool {
    let ones = word.iter().filter(|&&b| b).count();
    ones >= 2
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn majority_outvotes_single_error() {
        for word in [
            [false, false, false],
            [false, false, true],
            [false, true, false],
            [true, false, false],
        ] {
            assert!(!decode(word), "word {word:?} should decode to 0");
        }
        for word in [
            [true, true, true],
            [true, true, false],
            [true, false, true],
            [false, true, true],
        ] {
            assert!(decode(word), "word {word:?} should decode to 1");
        }
    }

    #[test]
    fn two_errors_flip_the_vote() {
        // majority of 011 is 1 -> two errors go uncorrected
        assert!(decode([false, true, true]));
        assert!(!decode([true, false, false]));
    }

    #[test]
    fn all_eight_patterns() {
        // Exhaustive check of all 3-bit inputs.
        for (word, expected) in [
            ([false, false, false], false),
            ([false, false, true], false),
            ([false, true, false], false),
            ([false, true, true], true),
            ([true, false, false], false),
            ([true, false, true], true),
            ([true, true, false], true),
            ([true, true, true], true),
        ] {
            assert_eq!(decode(word), expected, "word {word:?}");
        }
    }

    #[test]
    fn min_distance_is_three() {
        let words = vec![encode(false).to_vec(), encode(true).to_vec()];
        assert_eq!(crate::min_distance(&words), 3);
    }
}

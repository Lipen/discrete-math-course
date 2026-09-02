//! Parity code (n + 1, n, 2): detect a single error, correct nothing.
//!
//! One parity bit is appended so the word has an even number of ones. Any odd
//! number of flipped bits breaks the check, so a single error is detected -- but
//! the check says nothing about *where* the error is. Two errors slip through
//! unnoticed.

/// Returns `true` when `data` has an odd number of ones.
///
/// Appending this bit makes the total number of ones even.
///
/// ```
/// assert!(!codes::parity::bit(&[false, false, true, true])); // two ones
/// assert!(codes::parity::bit(&[false, true, true, true]));   // three ones
/// assert!(!codes::parity::bit(&[]));                          // zero ones
/// ```
pub fn bit(data: &[bool]) -> bool {
    data.iter().filter(|&&b| b).count() % 2 == 1
}

/// Appends the parity bit to `data` -- an (n + 1, n, 2) code.
///
/// ```
/// let word = codes::parity::encode(&[true, false, true, false]);
/// // data has two ones, parity bit is 0.
/// assert_eq!(word, vec![true, false, true, false, false]);
/// ```
pub fn encode(data: &[bool]) -> Vec<bool> {
    let mut word = data.to_vec();
    word.push(bit(data));
    word
}

/// True when `word` passes the even-parity check.
///
/// Any odd number of errors fails the check.
/// An even number slips through.
///
/// ```
/// let word = codes::parity::encode(&[true, false, true, false]);
/// assert!(codes::parity::ok(&word));
///
/// let mut corrupted = word.clone();
/// corrupted[0] = !corrupted[0];
/// assert!(!codes::parity::ok(&corrupted));
/// ```
pub fn ok(word: &[bool]) -> bool {
    word.iter().filter(|&&b| b).count() % 2 == 0
}

/// Strips the parity bit if the check passes, returns `None` otherwise.
///
/// ```
/// let word = codes::parity::encode(&[true, false, true, false]);
/// assert_eq!(codes::parity::decode(&word), Some(vec![true, false, true, false]));
///
/// let mut corrupted = word.clone();
/// corrupted[2] = !corrupted[2];
/// assert_eq!(codes::parity::decode(&corrupted), None);
/// ```
pub fn decode(word: &[bool]) -> Option<Vec<bool>> {
    if ok(word) {
        Some(word[..word.len() - 1].to_vec())
    } else {
        None
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn bit_pattern(d: usize) -> [bool; 4] {
        [d & 8 != 0, d & 4 != 0, d & 2 != 0, d & 1 != 0]
    }

    #[test]
    fn parity_bit_makes_total_even() {
        assert!(!bit(&[false, false, true, true])); // two ones
        assert!(bit(&[false, true, true, true])); // three ones
        for m in 0..16 {
            let data = bit_pattern(m);
            assert!(ok(&encode(&data)), "msg {m}");
        }
    }

    #[test]
    fn detects_any_single_error() {
        for m in 0..16 {
            let word = encode(&bit_pattern(m));
            for i in 0..word.len() {
                let mut corrupted = word.clone();
                corrupted[i] = !corrupted[i];
                assert!(!ok(&corrupted), "msg {m} bit {i}");
            }
        }
    }

    #[test]
    fn two_errors_go_unnoticed() {
        let mut word = encode(&[true, false, true, false]);
        word[0] = !word[0];
        word[2] = !word[2];
        assert!(ok(&word));
    }

    #[test]
    fn decode_returns_data_when_check_passes() {
        let data = vec![true, false, true, true];
        let word = encode(&data);
        assert_eq!(decode(&word), Some(data));
    }

    #[test]
    fn decode_returns_none_when_check_fails() {
        let data = vec![true, false, true, true];
        let mut word = encode(&data);
        word[3] = !word[3]; // flip one bit
        assert_eq!(decode(&word), None);
    }

    #[test]
    fn empty_data() {
        assert!(!bit(&[]));
        assert_eq!(encode(&[]), vec![false]);
        assert!(ok(&[false]));
        assert_eq!(decode(&[false]), Some(vec![]));
        assert_eq!(decode(&[true]), None);
    }

    #[test]
    fn min_distance_is_two() {
        let words: Vec<Vec<bool>> = (0..16).map(|m| encode(&bit_pattern(m))).collect();
        assert_eq!(crate::min_distance(&words), 2);
    }
}

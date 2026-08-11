//! Extended Hamming(8, 4, 4): Hamming(7,4) plus an overall parity bit.
//!
//! The extra bit makes every codeword have an even number of ones, raising the
//! minimum distance from 3 to 4. The decoder still corrects a single error and
//! now also detects a double error -- the case that Hamming(7,4) silently
//! miscorrects.
//!
//! ## Decoding logic
//!
//! | syndrome | overall parity | what happened |
//! |----------|----------------|---------------|
//! | 0        | even           | no error |
//! | 0        | odd            | the parity bit (position 8) was flipped |
//! | nonzero  | odd            | a single error at the position the syndrome points at |
//! | nonzero  | even           | two errors: detected, not corrected |

use crate::hamming;

/// Encodes 4 data bits into an 8-bit extended Hamming codeword.
///
/// The first 7 bits are the Hamming(7,4) codeword; bit 8 is the overall parity,
/// chosen so that the whole word has an even number of ones.
///
/// ```
/// let word = codes::extended::encode([true, false, true, true]);
/// // Hamming(7,4) of 1011 is 0100111; it has four ones (even), so parity bit is 0.
/// assert_eq!(word, [false, true, true, false, false, true, true, false]);
/// ```
pub fn encode(data: [bool; 4]) -> [bool; 8] {
    let word = hamming::encode(data);
    let mut out = [false; 8];
    out[..7].copy_from_slice(&word);
    out[7] = crate::parity_bit(&word);
    out
}

/// The outcome of decoding an 8-bit extended Hamming word.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Outcome {
    /// No error: the word is a valid codeword.
    Clean,
    /// A single error was corrected at `position` (1-based, 8 = the parity bit).
    Corrected { position: u8 },
    /// Two errors: detected, but not correctable -- the data is untrusted.
    Double,
}

/// The result of decoding an 8-bit extended Hamming word.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Decoded {
    /// The data bits (meaningful unless the outcome is `Double`).
    pub data: [bool; 4],
    /// What the decoder found.
    pub outcome: Outcome,
}

/// Decodes an 8-bit word: corrects a single error, detects a double one.
///
/// The syndrome says where a single error would be; the overall parity says
/// whether the number of errors is odd (one) or even (zero or two). When both
/// indicate trouble -- nonzero syndrome with even parity -- it is two errors,
/// and the decoder reports `Double` instead of correcting the wrong bit.
///
/// ```
/// let data = [true, false, true, true];
/// let word = codes::extended::encode(data);
///
/// // Clean.
/// let d = codes::extended::decode(word);
/// assert_eq!(d.outcome, codes::extended::Outcome::Clean);
/// assert_eq!(d.data, data);
///
/// // Single error at position 4.
/// let mut corrupted = word;
/// corrupted[3] = !corrupted[3];
/// let d = codes::extended::decode(corrupted);
/// assert_eq!(d.outcome, codes::extended::Outcome::Corrected { position: 4 });
/// assert_eq!(d.data, data);
///
/// // Two errors.
/// let mut two = word;
/// two[3] = !two[3];
/// two[5] = !two[5];
/// let d = codes::extended::decode(two);
/// assert_eq!(d.outcome, codes::extended::Outcome::Double);
/// ```
pub fn decode(word: [bool; 8]) -> Decoded {
    let hamming_word = [
        word[0], word[1], word[2], word[3], word[4], word[5], word[6],
    ];
    let s = hamming::syndrome(hamming_word);
    let even = crate::parity_ok(&word);

    let outcome = match (s, even) {
        (0, true) => Outcome::Clean,
        (0, false) => Outcome::Corrected { position: 8 },
        (_, false) => Outcome::Corrected { position: s },
        (_, true) => Outcome::Double,
    };

    let mut fixed = hamming_word;
    if let Outcome::Corrected { position } = outcome {
        if position <= 7 {
            fixed[(position - 1) as usize] = !fixed[(position - 1) as usize];
        }
    }
    Decoded {
        data: hamming::data_bits(fixed),
        outcome,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn bit_pattern(d: usize) -> [bool; 4] {
        [d & 8 != 0, d & 4 != 0, d & 2 != 0, d & 1 != 0]
    }

    #[test]
    fn codewords_have_even_parity() {
        for m in 0..16 {
            let word = encode(bit_pattern(m));
            assert!(crate::parity_ok(&word), "data {m}");
            assert_eq!(decode(word).outcome, Outcome::Clean, "data {m}");
        }
    }

    #[test]
    fn corrects_every_single_error() {
        for m in 0..16 {
            let data = bit_pattern(m);
            let word = encode(data);
            for pos in 1..=8u8 {
                let mut corrupted = word;
                corrupted[(pos - 1) as usize] = !corrupted[(pos - 1) as usize];
                let decoded = decode(corrupted);
                assert_eq!(
                    decoded.outcome,
                    Outcome::Corrected { position: pos },
                    "data {m} pos {pos}"
                );
                assert_eq!(decoded.data, data, "data {m} pos {pos}");
            }
        }
    }

    #[test]
    fn detects_every_double_error() {
        for m in 0..16 {
            let data = bit_pattern(m);
            let word = encode(data);
            for i in 1..=8u8 {
                for j in (i + 1)..=8u8 {
                    let mut corrupted = word;
                    corrupted[(i - 1) as usize] = !corrupted[(i - 1) as usize];
                    corrupted[(j - 1) as usize] = !corrupted[(j - 1) as usize];
                    let decoded = decode(corrupted);
                    assert_eq!(decoded.outcome, Outcome::Double, "data {m} errors {i},{j}");
                }
            }
        }
    }

    #[test]
    fn min_distance_is_four() {
        let words: Vec<Vec<bool>> = (0..16).map(|m| encode(bit_pattern(m)).to_vec()).collect();
        assert_eq!(crate::min_distance(&words), 4);
    }

    #[test]
    fn parity_bit_only_error_is_corrected() {
        // Flip only bit 8 (the overall parity bit). Syndrome is 0, parity is odd.
        let data = [true, false, true, true];
        let mut word = encode(data);
        word[7] = !word[7];
        let d = decode(word);
        assert_eq!(d.outcome, Outcome::Corrected { position: 8 });
        assert_eq!(d.data, data);
    }

    #[test]
    fn data_bit_and_parity_bit_is_double_error() {
        // Flip a data bit and the parity bit: two errors.
        let data = [true, false, true, true];
        let mut word = encode(data);
        word[2] = !word[2]; // flip d1 (position 3)
        word[7] = !word[7]; // flip parity (position 8)
        let d = decode(word);
        assert_eq!(d.outcome, Outcome::Double);
    }
}

//! Error-correcting codes: parity, repetition, and Hamming(7,4).
//!
//! Three code families over a binary channel, from the cheapest protection to
//! the clever one:
//!
//! - parity appends one bit so a word has an even number of ones: distance 2,
//!   so it detects a single error but cannot locate it;
//! - repetition says each bit three times and lets the majority vote:
//!   distance 3, one error corrected, but the rate is a poor 1/3;
//! - Hamming(7,4) packs 4 data bits with 3 parity bits into a 7-bit codeword:
//!   the same distance 3 at the better rate 4/7;
//! - extended Hamming(8,4,4) adds an overall parity bit to the Hamming word:
//!   still one error corrected, and a double error now *detected* instead of
//!   being miscorrected.
//!
//! The Hamming(7,4) code: data bits sit at positions 3, 5, 6, 7; parity bits
//! `p1`, `p2`, `p4` at positions 1, 2, 4. Each parity bit is the xor of the
//! data bits it covers:
//!
//! - `p1 = d1 ^ d2 ^ d4`,
//! - `p2 = d1 ^ d3 ^ d4`,
//! - `p4 = d2 ^ d3 ^ d4`.
//!
//! The shared metric is the Hamming distance: a code with minimum distance d
//! detects up to d - 1 errors and corrects up to (d - 1) / 2.

/// The 4 data bits and the 3 parity bits of a Hamming(7,4) codeword.
///
/// Data bits are ordered `d1 d2 d3 d4` and land at positions 3, 5, 6, 7.
pub fn encode(data: [bool; 4]) -> [bool; 7] {
    let [d1, d2, d3, d4] = data;
    let p1 = d1 ^ d2 ^ d4; // covers {1, 3, 5, 7}
    let p2 = d1 ^ d3 ^ d4; // covers {2, 3, 6, 7}
    let p4 = d2 ^ d3 ^ d4; // covers {4, 5, 6, 7}
    [p1, p2, d1, p4, d2, d3, d4]
}

/// The 3-bit syndrome of a 7-bit word.
///
/// A syndrome of 0 means the word is a valid codeword; any other value is the
/// position (1-based) of a single error. This is the trick that makes Hamming
/// codes work: one check per parity group, and the three bits spell the position.
pub fn syndrome(word: [bool; 7]) -> u8 {
    let [b1, b2, b3, b4, b5, b6, b7] = word;
    let s1 = b1 ^ b3 ^ b5 ^ b7;
    let s2 = b2 ^ b3 ^ b6 ^ b7;
    let s4 = b4 ^ b5 ^ b6 ^ b7;
    (s4 as u8) << 2 | (s2 as u8) << 1 | (s1 as u8)
}

/// The data bits of a 7-bit word: positions 3, 5, 6, 7.
pub fn data_bits(word: [bool; 7]) -> [bool; 4] {
    [word[2], word[4], word[5], word[6]]
}

/// The result of decoding a possibly corrupted word.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Decoded {
    /// The recovered data bits.
    pub data: [bool; 4],
    /// How many errors were corrected: 0 or 1.
    pub corrected: usize,
    /// The position (1-based) of the corrected error, if any.
    pub error_position: Option<u8>,
}

/// Decodes a 7-bit word, correcting a single error if present.
///
/// The correction is the inverse of the encoding: flip the bit whose position
/// the syndrome points at. A double error also gives a nonzero syndrome, but
/// pointing at a wrong position, so it is silently miscorrected -- the price
/// of a code of distance 3.
pub fn decode(word: [bool; 7]) -> Decoded {
    let s = syndrome(word);
    if s == 0 {
        return Decoded {
            data: data_bits(word),
            corrected: 0,
            error_position: None,
        };
    }
    let mut fixed = word;
    fixed[(s - 1) as usize] = !fixed[(s - 1) as usize];
    Decoded {
        data: data_bits(fixed),
        corrected: 1,
        error_position: Some(s),
    }
}

/// Extended Hamming (8, 4, 4): the Hamming(7,4) word plus an overall parity bit.
///
/// The extra bit is chosen so that the whole 8-bit word has an even number of
/// ones. The minimum distance grows to 4: the code still corrects one error,
/// but now it can also tell a double error apart and refuse to miscorrect.
pub fn extended_encode(data: [bool; 4]) -> [bool; 8] {
    let word = encode(data);
    let mut out = [false; 8];
    out[..7].copy_from_slice(&word);
    out[7] = parity_bit(&word);
    out
}

/// The outcome of decoding an 8-bit extended Hamming word.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ExtendedOutcome {
    /// No error: the word is a valid codeword.
    Clean,
    /// A single error was found and corrected; it sat at `position` (1-based,
    /// 8 = the overall parity bit).
    Corrected { position: u8 },
    /// Two errors: detected, but not correctable.
    Double,
}

/// The result of decoding an 8-bit extended Hamming word.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ExtendedDecoded {
    /// The data bits (meaningful unless the outcome is `Double`).
    pub data: [bool; 4],
    /// What the decoder found.
    pub outcome: ExtendedOutcome,
}

/// Decodes an 8-bit word: corrects a single error, detects a double one.
///
/// The syndrome says where a single error would be; the overall parity says
/// whether the number of errors is odd (one) or even (two). With two errors
/// the syndrome points at a wrong bit, so the decoder reports `Double`
/// instead of "correcting" it.
pub fn extended_decode(word: [bool; 8]) -> ExtendedDecoded {
    let hamming = [
        word[0], word[1], word[2], word[3], word[4], word[5], word[6],
    ];
    let s = syndrome(hamming);
    let even = parity_ok(&word);

    let outcome = match (s, even) {
        (0, true) => ExtendedOutcome::Clean,
        (0, false) => ExtendedOutcome::Corrected { position: 8 },
        (_, false) => ExtendedOutcome::Corrected { position: s },
        (_, true) => ExtendedOutcome::Double,
    };

    let mut fixed = hamming;
    if let ExtendedOutcome::Corrected { position } = outcome {
        if position <= 7 {
            fixed[(position - 1) as usize] = !fixed[(position - 1) as usize];
        }
    }
    ExtendedDecoded {
        data: data_bits(fixed),
        outcome,
    }
}

/// Repetition code (3, 1, 3): one bit sent three times.
pub fn repeat_encode(bit: bool) -> [bool; 3] {
    [bit, bit, bit]
}

/// Decodes a 3-bit word by majority vote.
///
/// Two out of three equal bits win, so any single error is outvoted. Two
/// errors flip the vote -- the price of the naive code.
pub fn repeat_decode(word: [bool; 3]) -> bool {
    let ones = word.iter().filter(|&&b| b).count();
    ones >= 2
}

/// Parity bit: 1 when `data` has an odd number of ones.
///
/// Appending it to `data` makes the total number of ones even, so a single
/// flipped bit is detected by the parity check.
pub fn parity_bit(data: &[bool]) -> bool {
    data.iter().filter(|&&b| b).count() % 2 == 1
}

/// Appends the parity bit to `data` -- a (n + 1, n, 2) code.
pub fn parity_encode(data: &[bool]) -> Vec<bool> {
    let mut word = data.to_vec();
    word.push(parity_bit(data));
    word
}

/// True when `word` passes the even-parity check.
///
/// Any odd number of errors fails the check; two errors slip through.
pub fn parity_ok(word: &[bool]) -> bool {
    word.iter().filter(|&&b| b).count() % 2 == 0
}

/// The Hamming distance between two equal-length bit strings.
pub fn hamming_distance(a: &[bool], b: &[bool]) -> usize {
    assert_eq!(
        a.len(),
        b.len(),
        "hamming_distance: bit strings must have equal length"
    );
    a.iter().zip(b).filter(|(x, y)| x != y).count()
}

/// The minimum distance of a code: the smallest Hamming distance between any
/// two distinct codewords in `words`.
///
/// Requires at least two codewords of equal length. A code with minimum
/// distance d detects up to d - 1 errors and corrects up to (d - 1) / 2.
pub fn min_distance(words: &[Vec<bool>]) -> usize {
    assert!(
        words.len() >= 2,
        "min_distance: need at least two codewords"
    );
    let mut best = usize::MAX;
    for i in 0..words.len() {
        for j in (i + 1)..words.len() {
            best = best.min(hamming_distance(&words[i], &words[j]));
        }
    }
    best
}

/// How many errors a code of minimum distance `d` detects: d - 1.
pub fn detects_up_to(d: usize) -> usize {
    d.saturating_sub(1)
}

/// How many errors a code of minimum distance `d` corrects: (d - 1) / 2.
pub fn corrects_up_to(d: usize) -> usize {
    d.saturating_sub(1) / 2
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn valid_codewords_have_zero_syndrome() {
        for d in 0..16 {
            let data = bit_pattern(d);
            let word = encode(data);
            assert_eq!(syndrome(word), 0, "data {data:?}");
            assert_eq!(data_bits(word), data);
        }
    }

    #[test]
    fn every_single_error_is_corrected() {
        for d in 0..16 {
            let data = bit_pattern(d);
            let word = encode(data);
            for pos in 1..=7 {
                let mut corrupted = word;
                corrupted[pos - 1] = !corrupted[pos - 1];
                assert_eq!(syndrome(corrupted), pos as u8, "data {data:?} pos {pos}");
                let decoded = decode(corrupted);
                assert_eq!(decoded.data, data, "data {data:?} pos {pos}");
                assert_eq!(decoded.corrected, 1);
                assert_eq!(decoded.error_position, Some(pos as u8));
            }
        }
    }

    #[test]
    fn uncorrupted_word_has_no_error() {
        let data = [true, false, true, true];
        let decoded = decode(encode(data));
        assert_eq!(decoded.corrected, 0);
        assert_eq!(decoded.error_position, None);
        assert_eq!(decoded.data, data);
    }

    #[test]
    fn minimum_distance_is_three() {
        // Any two distinct codewords differ in at least 3 positions.
        for a in 0..16 {
            for b in (a + 1)..16 {
                let wa = encode(bit_pattern(a));
                let wb = encode(bit_pattern(b));
                assert!(hamming_distance(&wa, &wb) >= 3, "{a} vs {b}");
            }
        }
    }

    fn bit_pattern(d: usize) -> [bool; 4] {
        [d & 8 != 0, d & 4 != 0, d & 2 != 0, d & 1 != 0]
    }

    // --- repetition ---

    #[test]
    fn repetition_majority_vote_outvotes_a_single_error() {
        for word in [
            [false, false, false],
            [false, false, true],
            [false, true, false],
            [true, false, false],
        ] {
            assert!(!repeat_decode(word), "word {word:?} should decode to 0");
        }
        for word in [
            [true, true, true],
            [true, true, false],
            [true, false, true],
            [false, true, true],
        ] {
            assert!(repeat_decode(word), "word {word:?} should decode to 1");
        }
    }

    #[test]
    fn repetition_two_errors_flip_the_vote() {
        // The majority of 011 is 1, so two errors go uncorrected.
        assert!(repeat_decode([false, true, true]));
        assert!(!repeat_decode([true, false, false]));
    }

    // --- parity ---

    #[test]
    fn parity_bit_makes_the_total_even() {
        assert!(!parity_bit(&[false, false, true, true])); // two ones
        assert!(parity_bit(&[false, true, true, true])); // three ones
        for m in 0..16 {
            let data = bit_pattern(m);
            assert!(parity_ok(&parity_encode(&data)), "msg {m}");
        }
    }

    #[test]
    fn parity_detects_any_single_error() {
        for m in 0..16 {
            let word = parity_encode(&bit_pattern(m));
            for i in 0..word.len() {
                let mut corrupted = word.clone();
                corrupted[i] = !corrupted[i];
                assert!(!parity_ok(&corrupted), "msg {m} bit {i}");
            }
        }
    }

    #[test]
    fn parity_two_errors_go_unnoticed() {
        let mut word = parity_encode(&[true, false, true, false]);
        word[0] = !word[0];
        word[2] = !word[2];
        assert!(parity_ok(&word));
    }

    // --- distance and capability ---

    #[test]
    fn min_distance_of_the_three_codes() {
        let parity_words: Vec<Vec<bool>> =
            (0..16).map(|m| parity_encode(&bit_pattern(m))).collect();
        assert_eq!(min_distance(&parity_words), 2);

        let repeat_words = vec![repeat_encode(false).to_vec(), repeat_encode(true).to_vec()];
        assert_eq!(min_distance(&repeat_words), 3);

        let hamming_words: Vec<Vec<bool>> =
            (0..16).map(|m| encode(bit_pattern(m)).to_vec()).collect();
        assert_eq!(min_distance(&hamming_words), 3);
    }

    // --- extended hamming ---

    #[test]
    fn extended_codewords_have_even_parity() {
        for m in 0..16 {
            let word = extended_encode(bit_pattern(m));
            assert!(parity_ok(&word), "data {m}");
            assert_eq!(
                extended_decode(word).outcome,
                ExtendedOutcome::Clean,
                "data {m}"
            );
        }
    }

    #[test]
    fn extended_corrects_every_single_error() {
        for m in 0..16 {
            let data = bit_pattern(m);
            let word = extended_encode(data);
            for pos in 1..=8u8 {
                let mut corrupted = word;
                corrupted[(pos - 1) as usize] = !corrupted[(pos - 1) as usize];
                let decoded = extended_decode(corrupted);
                assert_eq!(
                    decoded.outcome,
                    ExtendedOutcome::Corrected { position: pos },
                    "data {m} pos {pos}"
                );
                assert_eq!(decoded.data, data, "data {m} pos {pos}");
            }
        }
    }

    #[test]
    fn extended_detects_every_double_error() {
        for m in 0..16 {
            let data = bit_pattern(m);
            let word = extended_encode(data);
            for i in 1..=8u8 {
                for j in (i + 1)..=8u8 {
                    let mut corrupted = word;
                    corrupted[(i - 1) as usize] = !corrupted[(i - 1) as usize];
                    corrupted[(j - 1) as usize] = !corrupted[(j - 1) as usize];
                    let decoded = extended_decode(corrupted);
                    assert_eq!(
                        decoded.outcome,
                        ExtendedOutcome::Double,
                        "data {m} errors {i},{j}"
                    );
                }
            }
        }
    }

    #[test]
    fn extended_minimum_distance_is_four() {
        let words: Vec<Vec<bool>> = (0..16)
            .map(|m| extended_encode(bit_pattern(m)).to_vec())
            .collect();
        assert_eq!(min_distance(&words), 4);
    }

    #[test]
    fn capability_helpers_follow_the_distance() {
        assert_eq!(detects_up_to(2), 1);
        assert_eq!(corrects_up_to(2), 0);
        assert_eq!(detects_up_to(3), 2);
        assert_eq!(corrects_up_to(3), 1);
        assert_eq!(detects_up_to(0), 0);
        assert_eq!(corrects_up_to(0), 0);
    }
}

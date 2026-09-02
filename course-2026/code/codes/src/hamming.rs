//! Hamming(7,4) code: encode, detect, and correct a single error.
//!
//! Data bits `d1 d2 d3 d4` sit at positions 3, 5, 6, 7; parity bits `p1`, `p2`,
//! `p4` at positions 1, 2, 4. Each parity bit is the xor of the data bits it
//! covers:
//!
//! ```text
//! p1 = d1 ^ d2 ^ d4    (covers positions 1, 3, 5, 7)
//! p2 = d1 ^ d3 ^ d4    (covers positions 2, 3, 6, 7)
//! p4 = d2 ^ d3 ^ d4    (covers positions 4, 5, 6, 7)
//! ```
//!
//! The syndrome -- recomputed parity of the received word -- forms a 3-bit
//! number `(s4 s2 s1)`: zero for a valid codeword, else the 1-based position of
//! the flipped bit. This works because each parity bit covers a unique subset,
//! so the three checks together pinpoint the error.

/// Encodes 4 data bits into a 7-bit Hamming codeword.
///
/// Positions: `[p1, p2, d1, p4, d2, d3, d4]`.
///
/// ```
/// let word = codes::hamming::encode([true, false, true, true]);
/// // p1 = 1 ^ 0 ^ 1 = 0
/// // p2 = 1 ^ 1 ^ 1 = 1
/// // p4 = 0 ^ 1 ^ 1 = 0
/// assert_eq!(word, [false, true, true, false, false, true, true]);
/// ```
pub fn encode(data: [bool; 4]) -> [bool; 7] {
    let [d1, d2, d3, d4] = data;
    let p1 = d1 ^ d2 ^ d4; // covers {1, 3, 5, 7}
    let p2 = d1 ^ d3 ^ d4; // covers {2, 3, 6, 7}
    let p4 = d2 ^ d3 ^ d4; // covers {4, 5, 6, 7}
    [p1, p2, d1, p4, d2, d3, d4]
}

/// The 3-bit syndrome of a 7-bit word.
///
/// Zero means a valid codeword.
/// Any other value is the 1-based position of a single error.
///
/// ```
/// let word = codes::hamming::encode([true, false, true, true]);
/// assert_eq!(codes::hamming::syndrome(word), 0);
///
/// let mut corrupted = word;
/// corrupted[3] = !corrupted[3]; // flip position 4
/// assert_eq!(codes::hamming::syndrome(corrupted), 4);
/// ```
pub fn syndrome(word: [bool; 7]) -> u8 {
    let [b1, b2, b3, b4, b5, b6, b7] = word;
    let s1 = b1 ^ b3 ^ b5 ^ b7;
    let s2 = b2 ^ b3 ^ b6 ^ b7;
    let s4 = b4 ^ b5 ^ b6 ^ b7;
    (s4 as u8) << 2 | (s2 as u8) << 1 | (s1 as u8)
}

/// Extracts the 4 data bits from a 7-bit word: positions 3, 5, 6, 7.
///
/// ```
/// let word = codes::hamming::encode([true, false, true, true]);
/// assert_eq!(codes::hamming::data_bits(word), [true, false, true, true]);
/// ```
pub fn data_bits(word: [bool; 7]) -> [bool; 4] {
    [word[2], word[4], word[5], word[6]]
}

/// The result of decoding a possibly corrupted Hamming(7,4) word.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Decoded {
    /// The recovered data bits.
    pub data: [bool; 4],
    /// How many errors were corrected: 0 or 1.
    pub corrected: usize,
    /// The 1-based position of the corrected error, if any.
    pub error_position: Option<u8>,
}

/// Decodes a 7-bit word, correcting a single error if present.
///
/// The syndrome points at the flipped bit. With two errors it points at a wrong
/// position -- the decoder still "corrects" something, so the result is wrong.
///
/// ```
/// let data = [true, false, true, true];
/// let word = codes::hamming::encode(data);
///
/// // No error.
/// let d = codes::hamming::decode(word);
/// assert_eq!(d.data, data);
/// assert_eq!(d.corrected, 0);
///
/// // One error.
/// let mut corrupted = word;
/// corrupted[5] = !corrupted[5]; // flip position 6 (d3)
/// let d = codes::hamming::decode(corrupted);
/// assert_eq!(d.data, data);
/// assert_eq!(d.corrected, 1);
/// assert_eq!(d.error_position, Some(6));
/// ```
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

#[cfg(test)]
mod tests {
    use super::*;

    fn bit_pattern(d: usize) -> [bool; 4] {
        [d & 8 != 0, d & 4 != 0, d & 2 != 0, d & 1 != 0]
    }

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
                let dist = crate::hamming_distance(&wa, &wb);
                assert!(dist >= 3, "{a} vs {b}: distance {dist}");
            }
        }
    }

    #[test]
    fn double_error_is_miscorrected() {
        // Two errors produce a nonzero syndrome that points at a wrong position.
        let data = [true, false, true, true]; // 1011
        let word = encode(data);
        // Flip bits 4 (p4) and 6 (d3).
        let mut corrupted = word;
        corrupted[3] = !corrupted[3];
        corrupted[5] = !corrupted[5];
        let s = syndrome(corrupted);
        assert_ne!(s, 0, "syndrome should be nonzero for a double error");
        let decoded = decode(corrupted);
        // The data should NOT match because the correction was at the wrong position.
        assert_ne!(decoded.data, data, "double error should be miscorrected");
    }

    #[test]
    fn syndrome_table_covers_all_single_error_positions() {
        // For any position 1..7, there exists a codeword whose syndrome at that
        // position equals the position number.
        let data = [false, false, false, false];
        let word = encode(data); // all zeros -> parity bits are 0, codeword is all zeros
        for pos in 1..=7 {
            let mut corrupted = word;
            corrupted[pos - 1] = true; // flip from 0 to 1
            assert_eq!(syndrome(corrupted), pos as u8, "position {pos}");
        }
    }

    #[test]
    fn encode_one_hand_computed() {
        // Manual check: data 0001 (d1=0, d2=0, d3=0, d4=1).
        // p1 = 0 ^ 0 ^ 1 = 1
        // p2 = 0 ^ 0 ^ 1 = 1
        // p4 = 0 ^ 0 ^ 1 = 1
        // Word: [p1, p2, d1, p4, d2, d3, d4] = [1,1,0,1,0,0,1].
        assert_eq!(
            encode([false, false, false, true]),
            [true, true, false, true, false, false, true]
        );
    }

    #[test]
    fn syndrome_zero_for_all_sixteen_codewords() {
        for d in 0..16 {
            assert_eq!(syndrome(encode(bit_pattern(d))), 0);
        }
    }
}

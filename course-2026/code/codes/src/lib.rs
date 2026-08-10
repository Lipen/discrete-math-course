//! Hamming codes and single-error correction.
//!
//! The canonical Hamming(7,4) code: 4 data bits are protected by 3 parity
//! bits into a 7-bit codeword. Data bits sit at positions 3, 5, 6, 7;
//! parity bits `p1`, `p2`, `p4` at positions 1, 2, 4. A parity bit covers
//! every position whose number has that bit set:
//!
//! - `p1` covers {1, 3, 5, 7},
//! - `p2` covers {2, 3, 6, 7},
//! - `p4` covers {4, 5, 6, 7}.
//!
//! The code has minimum distance 3, so it corrects any single bit error and
//! detects any double error (a nonzero syndrome, but at the wrong position).

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
/// pointing at a wrong position, so it is silently miscorrected --- the price
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

/// The Hamming distance between two equal-length bit strings.
pub fn hamming_distance(a: &[bool], b: &[bool]) -> usize {
    assert_eq!(
        a.len(),
        b.len(),
        "hamming_distance: bit strings must have equal length"
    );
    a.iter().zip(b).filter(|(x, y)| x != y).count()
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
}

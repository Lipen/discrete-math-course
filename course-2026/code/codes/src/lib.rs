//! Error-correcting codes: parity, repetition, and Hamming.
//!
//! Three code families over a binary channel, from the cheapest protection to
//! the clever one:
//!
//! - **parity** appends one bit so a word has an even number of ones: distance 2,
//!   so it detects a single error but cannot locate it.
//! - **repetition** sends each bit three times and lets the majority vote:
//!   distance 3, one error corrected, but the rate is a poor 1/3.
//! - **Hamming(7,4)** packs 4 data bits with 3 parity bits into a 7-bit
//!   codeword: the same distance 3 at the better rate 4/7.
//! - **extended Hamming(8,4,4)** adds an overall parity bit: distance grows to 4,
//!   still corrects one error, and now *detects* a double error instead of
//!   silently miscorrecting it.
//!
//! # Quick example
//!
//! ```
//! let data = [true, false, true, true]; // 1011
//!
//! // Encode, corrupt one bit, decode.
//! let word = codes::encode(data);
//! let mut received = word;
//! received[3] = !received[3]; // flip position 4
//!
//! let decoded = codes::decode(received);
//! assert_eq!(decoded.data, data);
//! assert_eq!(decoded.corrected, 1);
//! assert_eq!(decoded.error_position, Some(4));
//! ```
//!
//! # Distance and capability
//!
//! A code with minimum distance `d` detects up to `d - 1` errors and corrects up
//! to `(d - 1) / 2`:
//!
//! ```
//! assert_eq!(codes::detects_up_to(3), 2);
//! assert_eq!(codes::corrects_up_to(3), 1);
//! ```

pub mod distance;
pub mod extended;
pub mod hamming;
pub mod parity;
pub mod repetition;

// Flat re-exports -- the original API for backward compatibility.
pub use distance::{corrects_up_to, detects_up_to, hamming as hamming_distance, min_distance};
pub use extended::{
    decode as extended_decode, encode as extended_encode, Decoded as ExtendedDecoded,
    Outcome as ExtendedOutcome,
};
pub use hamming::{data_bits, decode, encode, syndrome, Decoded};
pub use parity::{
    bit as parity_bit, decode as parity_decode, encode as parity_encode, ok as parity_ok,
};
pub use repetition::{decode as repeat_decode, encode as repeat_encode};

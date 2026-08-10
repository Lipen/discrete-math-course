//! Hamming(7,4) in action: encode, corrupt one bit, correct it.
//!
//! The demo walks through the whole pipeline on a single word so the syndrome
//! trick is visible: a nonzero syndrome is exactly the position of the error.
//! The flipped bit is drawn in red when the terminal supports it.

use codes::{decode, encode, syndrome};
use std::io::IsTerminal;

fn bits(word: [bool; 7]) -> String {
    word.iter().map(|&b| if b { '1' } else { '0' }).collect()
}

/// The word with the flipped position (1-based) drawn in red.
fn bits_colored(word: &[bool; 7], flipped: usize) -> String {
    if !std::io::stdout().is_terminal() {
        return bits(*word);
    }
    word.iter()
        .enumerate()
        .map(|(i, &b)| {
            let ch = if b { '1' } else { '0' };
            if i + 1 == flipped {
                format!("\x1b[1;31m{ch}\x1b[0m")
            } else {
                ch.to_string()
            }
        })
        .collect()
}

/// The syndrome as its bits (s4 s2 s1), as a binary number, and in decimal.
fn syndrome_bits(s: u8) -> String {
    let s4 = (s >> 2) & 1;
    let s2 = (s >> 1) & 1;
    let s1 = s & 1;
    format!("(s₄ s₂ s₁) = ({s4} {s2} {s1})₂ = {s}")
}

fn main() {
    let data = [true, false, true, true]; // 1011
    let word = encode(data);
    println!("data     = 1011");
    println!("codeword = {}   (parity at positions 1, 2, 4)", bits(word));

    // Flip the bit at position 4 (the p4 parity bit).
    let mut received = word;
    received[3] = !received[3];
    let s = syndrome(received);
    println!(
        "\ncorrupt bit 4 -> received = {}",
        bits_colored(&received, 4)
    );
    println!(
        "syndrome = {}   (the position of the error)",
        syndrome_bits(s)
    );

    let decoded = decode(received);
    println!(
        "\ncorrected bit at position {}",
        decoded.error_position.unwrap()
    );
    println!("codeword after correction = {}", bits(encode(decoded.data)));
    println!(
        "recovered data = {}{}{}{}   matches the original: {}",
        decoded.data[0] as u8,
        decoded.data[1] as u8,
        decoded.data[2] as u8,
        decoded.data[3] as u8,
        decoded.data == data
    );
}

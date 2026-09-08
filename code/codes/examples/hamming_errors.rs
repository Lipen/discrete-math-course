//! What happens at 0, 1, 2, or 3 flipped bits: the limits of Hamming(7,4).
//!
//! Hamming(7,4) has minimum distance 3, so it corrects any single error and
//! flags a double error with a nonzero syndrome. But a double error makes the
//! syndrome point at the wrong position -- the decoder "corrects" a healthy
//! bit -- and three flipped bits can land on another valid codeword and go
//! unnoticed. Flipped bits are drawn in red when the terminal supports it.

use codes::{decode, encode, syndrome, Decoded};
use std::io::IsTerminal;

fn bits(word: &[bool]) -> String {
    word.iter().map(|&b| if b { '1' } else { '0' }).collect()
}

/// The word with the flipped positions (1-based) drawn in red.
fn bits_colored(word: &[bool], flips: &[usize]) -> String {
    let colored = std::io::stdout().is_terminal();
    word.iter()
        .enumerate()
        .map(|(i, &b)| {
            let ch = if b { '1' } else { '0' };
            if colored && flips.contains(&(i + 1)) {
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

/// Flips the given 1-based positions in place.
fn flip(word: &mut [bool], positions: &[usize]) {
    for &p in positions {
        word[p - 1] = !word[p - 1];
    }
}

/// What the decoder's report means, given how many bits were flipped.
fn verdict(data: &[bool; 4], decoded: &Decoded, errors: usize) -> &'static str {
    match (errors, decoded.corrected, decoded.data == *data) {
        (0, 0, true) => "clean: no error reported, data intact",
        (1, 1, true) => "corrected: the single error was found and fixed",
        (2, 1, false) => {
            "miscorrected: a double error looks like a single error at the wrong position"
        }
        (_, 0, false) => "undetected: the errors landed on another valid codeword",
        (_, 1, false) => "miscorrected: the errors produced a wrong single-error fix",
        _ => "unexpected outcome",
    }
}

fn main() {
    let data = [true, false, true, true]; // 1011
    let word = encode(data);
    println!("Hamming(7, 4), distance 3: corrects 1 error, flags 2");
    println!();
    println!("data 1011 -> codeword {}", bits(&word));
    println!();

    let scenarios: &[(&str, &[usize])] = &[
        ("0 errors", &[]),
        ("1 error at bit 4 (a parity bit)", &[4]),
        ("1 error at bit 6 (a data bit)", &[6]),
        ("2 errors at bits 4 and 6", &[4, 6]),
        ("3 errors at bits 1, 2, 3 (a codeword)", &[1, 2, 3]),
    ];

    for (label, flips) in scenarios {
        let mut received = word;
        flip(&mut received, flips);
        let s = syndrome(received);
        let decoded = decode(received);
        let at = match decoded.error_position {
            Some(p) => format!("bit {p}"),
            None => "nowhere".to_string(),
        };
        println!("case {label}");
        println!(
            "  received = {}, syndrome = {}",
            bits_colored(&received, flips),
            syndrome_bits(s)
        );
        println!(
            "  decoder: corrected {}, error at {}, data = {}",
            decoded.corrected,
            at,
            bits(&decoded.data)
        );
        println!("  -> {}", verdict(&data, &decoded, flips.len()));
        println!();
    }
}

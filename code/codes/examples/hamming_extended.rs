//! Extended Hamming(8, 4, 4): one extra parity bit tells single from double
//! errors.
//!
//! The 8-bit word is the Hamming(7,4) codeword plus an overall parity bit, so
//! the minimum distance grows to 4. The decoder still corrects one error, but
//! it now recognizes two: a nonzero syndrome with even parity means "two
//! errors", and the decoder refuses to "correct" the bit the syndrome points
//! at -- that correction would be wrong. Flipped bits are drawn in red when
//! the terminal supports it.

use codes::{
    extended_decode, extended_encode, parity_ok, syndrome, ExtendedDecoded, ExtendedOutcome,
};
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

/// A human verdict for the decoder's report.
fn outcome_text(decoded: &ExtendedDecoded) -> String {
    match decoded.outcome {
        ExtendedOutcome::Clean => "clean: no error reported, data intact".to_string(),
        ExtendedOutcome::Corrected { position } => {
            format!("corrected: single error at bit {position}, data intact")
        }
        ExtendedOutcome::Double => {
            "double error detected: the syndrome points at a wrong bit, left uncorrected"
                .to_string()
        }
    }
}

fn main() {
    let data = [true, false, true, true]; // 1011
    let word = extended_encode(data);
    println!("Extended Hamming(8, 4, 4), distance 4: corrects 1 error, detects 2");
    println!();
    println!(
        "data 1011 -> codeword {}   (bit 8 = overall parity)",
        bits(&word)
    );
    println!();

    let scenarios: &[(&str, &[usize])] = &[
        ("0 errors", &[]),
        ("1 error at bit 4 (a hamming bit)", &[4]),
        ("1 error at bit 8 (the parity bit)", &[8]),
        ("2 errors at bits 4 and 6", &[4, 6]),
        ("2 errors at bits 2 and 8", &[2, 8]),
    ];

    for (label, flips) in scenarios {
        let mut received = word;
        flip(&mut received, flips);
        let s = syndrome([
            received[0],
            received[1],
            received[2],
            received[3],
            received[4],
            received[5],
            received[6],
        ]);
        let even = parity_ok(&received);
        let decoded = extended_decode(received);
        println!("case {label}");
        println!(
            "  received = {}, syndrome = {}, parity = {}",
            bits_colored(&received, flips),
            syndrome_bits(s),
            if even { "ok" } else { "FAIL" }
        );
        println!("  -> {}", outcome_text(&decoded));
        println!();
    }
}

//! What happens at 0, 1, 2, or 3 flipped bits: the limits of each code.
//!
//! A code with minimum distance d guarantees detection of up to d - 1 errors
//! and correction of up to (d - 1) / 2. Beyond that the decoder cannot tell
//! what happened: it may "correct" the wrong bit, or even report no error at
//! all. This demo feeds the same message through all three code families and
//! corrupts 0, 1, 2, or 3 bits, printing what each decoder reports and what
//! that means for the recovered data. Flipped bits are drawn in red when the
//! terminal supports it.

use codes::{
    decode, encode, parity_encode, parity_ok, repeat_decode, repeat_encode, syndrome, Decoded,
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

/// Flips the given 1-based positions in place.
fn flip(word: &mut [bool], positions: &[usize]) {
    for &p in positions {
        word[p - 1] = !word[p - 1];
    }
}

/// What the Hamming decoder's report means, given how many bits were flipped.
fn hamming_verdict(data: &[bool; 4], decoded: &Decoded, errors: usize) -> &'static str {
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

/// What the repetition majority vote means, given how many bits were flipped.
fn repetition_verdict(original: bool, decoded: bool, errors: usize) -> &'static str {
    match (errors, decoded == original) {
        (0, true) => "clean: the bit comes through unchanged",
        (1, true) => "corrected: the single error is outvoted",
        (2, false) => "miscorrected: two errors flip the majority",
        (3, false) => "undetected: the word is the other valid codeword",
        _ => "unexpected outcome",
    }
}

/// What the parity check means for the data part of the word.
fn parity_verdict(check_ok: bool, data_ok: bool) -> &'static str {
    match (check_ok, data_ok) {
        (true, true) => "clean: even parity, data intact",
        (false, _) => "detected: odd parity, but parity cannot correct anything",
        (true, false) => "undetected: even parity again, the errors slipped through",
    }
}

fn main() {
    let data = [true, false, true, true]; // 1011

    println!("=== Hamming(7, 4): distance 3, corrects 1, detects 2 ===");
    println!();
    hamming_section(&data);

    println!("=== Repetition(3, 1, 3): distance 3, corrects 1 ===");
    println!();
    repetition_section(data[0]);

    println!("=== Parity(5, 4, 2): distance 2, detects 1, corrects nothing ===");
    println!();
    parity_section(&data);
}

fn hamming_section(data: &[bool; 4]) {
    let word = encode(*data);
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
            "  received = {}, syndrome = {s}",
            bits_colored(&received, flips)
        );
        println!(
            "  decoder: corrected {}, error at {}, data = {}",
            decoded.corrected,
            at,
            bits(&decoded.data)
        );
        println!("  -> {}", hamming_verdict(data, &decoded, flips.len()));
        println!();
    }
}

fn repetition_section(bit: bool) {
    let word = repeat_encode(bit);
    println!("bit {} -> {}", bit as u8, bits(&word));
    println!();

    let scenarios: &[(&str, &[usize])] = &[
        ("0 errors", &[]),
        ("1 error at bit 1", &[1]),
        ("1 error at bit 3", &[3]),
        ("2 errors at bits 2 and 3", &[2, 3]),
        ("3 errors at bits 1, 2, 3", &[1, 2, 3]),
    ];

    for (label, flips) in scenarios {
        let mut received = word;
        flip(&mut received, flips);
        let vote = repeat_decode(received);
        println!("case {label}");
        println!(
            "  received = {}, majority vote = {}",
            bits_colored(&received, flips),
            vote as u8
        );
        println!("  -> {}", repetition_verdict(bit, vote, flips.len()));
        println!();
    }
}

fn parity_section(data: &[bool; 4]) {
    let word = parity_encode(data);
    println!("data 1011 -> word {}", bits(&word));
    println!();

    let scenarios: &[(&str, &[usize])] = &[
        ("0 errors", &[]),
        ("1 error at bit 3 (a data bit)", &[3]),
        ("1 error at bit 5 (the parity bit)", &[5]),
        ("2 errors at bits 3 and 4", &[3, 4]),
        ("3 errors at bits 1, 2, 3", &[1, 2, 3]),
    ];

    for (label, flips) in scenarios {
        let mut received = word.clone();
        flip(&mut received, flips);
        let check_ok = parity_ok(&received);
        let data_ok = received[..4] == data[..];
        let check = if check_ok { "ok" } else { "FAIL" };
        println!("case {label}");
        println!(
            "  received = {}, parity check = {check}, data = {}",
            bits_colored(&received, flips),
            bits(&received[..4])
        );
        println!("  -> {}", parity_verdict(check_ok, data_ok));
        println!();
    }
}

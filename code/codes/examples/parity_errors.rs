//! What happens at 0, 1, 2, or 3 flipped bits: the limits of the parity code.
//!
//! The appended parity bit makes the word have an even number of ones, so any
//! odd number of errors fails the check -- and an even number slips through
//! unnoticed. Parity detects, but never corrects. Flipped bits are drawn in
//! red when the terminal supports it.

use codes::{parity_encode, parity_ok};
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

/// What the parity check means for the data part of the word.
fn verdict(check_ok: bool, data_ok: bool) -> &'static str {
    match (check_ok, data_ok) {
        (true, true) => "clean: even parity, data intact",
        (false, _) => "detected: odd parity, but parity cannot correct anything",
        (true, false) => "undetected: even parity again, the errors slipped through",
    }
}

fn main() {
    let data = [true, false, true, true]; // 1011
    let word = parity_encode(&data);
    println!("Parity(5, 4, 2), distance 2: detects 1 error, corrects nothing");
    println!();
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
        println!("  -> {}", verdict(check_ok, data_ok));
        println!();
    }
}

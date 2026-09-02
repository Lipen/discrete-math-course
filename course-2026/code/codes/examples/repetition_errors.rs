//! What happens at 0, 1, 2, or 3 flipped bits: the limits of repetition (3,1,3).
//!
//! Each bit is sent three times and the receiver takes a majority vote.
//! One error is outvoted.
//! Two errors flip the vote and silently corrupt the data.
//! Three errors turn the word into the other valid codeword.
//! Flipped bits are drawn in red when the terminal supports it.

use codes::{repeat_decode, repeat_encode};
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

/// What the majority vote means, given how many bits were flipped.
fn verdict(original: bool, decoded: bool, errors: usize) -> &'static str {
    match (errors, decoded == original) {
        (0, true) => "clean: the bit comes through unchanged",
        (1, true) => "corrected: the single error is outvoted",
        (2, false) => "miscorrected: two errors flip the majority",
        (3, false) => "undetected: the word is the other valid codeword",
        _ => "unexpected outcome",
    }
}

fn main() {
    let bit = true;
    let word = repeat_encode(bit);
    println!("Repetition(3, 1, 3), distance 3: corrects 1 error");
    println!();
    println!("bit 1 -> {}", bits(&word));
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
        println!("  -> {}", verdict(bit, vote, flips.len()));
        println!();
    }
}

//! Frequency analysis.
//!
//! In English text the letter "e" is the most frequent. If a simple substitution
//! cipher replaces each letter with a fixed one, the most frequent ciphertext
//! letter most likely corresponds to the most frequent letter of the language --
//! and the substitution can be recovered from the frequencies.

use std::collections::HashMap;

fn main() {
    // Simple substitution ciphertext (Atbash: each letter mirrored around the
    // middle of the alphabet). The most frequent English letter "e" was
    // replaced by "v", so "v" dominates the counts below.
    let cipher = "GSV GIVVH ZIV TIVVM ZMW GSV HVZ RH WVVK ZMW UIVV";

    let mut counts: HashMap<char, usize> = HashMap::new();
    for c in cipher.chars().filter(|c| c.is_alphabetic()) {
        *counts.entry(c).or_default() += 1;
    }

    let mut freq: Vec<(char, usize)> = counts.into_iter().collect();
    freq.sort_by_key(|&(_, n)| std::cmp::Reverse(n));

    println!("Ciphertext: {cipher}\n");
    println!("Ciphertext letter frequencies:");
    for (c, n) in &freq {
        println!("  {c}: {n}");
    }

    let top = freq[0].0;
    println!("\nThe most frequent is {top}: in English text this is most likely \"e\".");
    println!("Substituting the hypothesis {top} -> e and trying the remaining pairs recovers the plaintext: the trees are green and the sea is deep and free.");
}

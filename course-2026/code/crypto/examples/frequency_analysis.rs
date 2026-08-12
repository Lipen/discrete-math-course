//! Frequency analysis (the chapter, section "Breaking").
//!
//! In Russian text the letter "о" is the most frequent. If a simple substitution cipher
//! replaces each letter with a fixed one, the most frequent ciphertext letter
//! most likely corresponds to the most frequent letter of the language -- and the
//! substitution can be recovered from the frequencies.

use std::collections::HashMap;

fn main() {
    // Simple substitution ciphertext: "о" is replaced by "щ", "е" by "м", "а" by "к".
    let cipher = "МЩЙЩС ЛГЧШМГМУ ЙМКМЩЗ ЩМКЩВМЩРУ ЩММРГУ";

    let mut counts: HashMap<char, usize> = HashMap::new();
    for c in cipher.chars().filter(|c| c.is_alphabetic()) {
        *counts.entry(c).or_default() += 1;
    }

    let mut freq: Vec<(char, usize)> = counts.into_iter().collect();
    freq.sort_by_key(|&(_, n)| std::cmp::Reverse(n));

    println!("Ciphertext letter frequencies:");
    for (c, n) in &freq {
        println!("  {c}: {n}");
    }

    let top = freq[0].0;
    println!("The most frequent is {top}; in Russian text this is most likely «о».");
    println!("Substituting the hypothesis {top} → о and trying the remaining pairs recovers the substitution.");
}

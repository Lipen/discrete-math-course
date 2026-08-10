//! Three code families, one trade-off: parity, repetition, Hamming.
//!
//! The demo protects the same 4 data bits with each code, prints their
//! parameters -- length n, dimension k, minimum distance d -- and then walks
//! one word through each family: encode, corrupt, recover or detect.

use codes::{
    corrects_up_to, decode, detects_up_to, encode, min_distance, parity_encode, parity_ok,
    repeat_decode, repeat_encode, syndrome,
};

fn bits(word: &[bool]) -> String {
    word.iter().map(|&b| if b { '1' } else { '0' }).collect()
}

/// All messages of k bits, in binary order.
fn all_messages(k: usize) -> Vec<Vec<bool>> {
    (0..(1usize << k))
        .map(|m| (0..k).rev().map(|i| m & (1 << i) != 0).collect())
        .collect()
}

/// Repetition over a whole message: each of the k bits sent three times.
fn repeat_block(msg: &[bool]) -> Vec<bool> {
    msg.iter().flat_map(|&b| repeat_encode(b)).collect()
}

fn report(name: &str, words: &[Vec<bool>], k: usize) {
    let n = words[0].len();
    let d = min_distance(words);
    let rate = format!("{k}/{n}");
    println!(
        "{name:<10} ({n}, {k}, {d})  {rate:<6}{:<7} {:<7}",
        detects_up_to(d),
        corrects_up_to(d)
    );
}

fn main() {
    let k = 4;
    let message = [true, false, true, true]; // 1011

    let parity_words: Vec<Vec<bool>> = all_messages(k).iter().map(|m| parity_encode(m)).collect();
    let repeat_words: Vec<Vec<bool>> = all_messages(k).iter().map(|m| repeat_block(m)).collect();
    let hamming_words: Vec<Vec<bool>> = all_messages(k)
        .iter()
        .map(|m| encode([m[0], m[1], m[2], m[3]]).to_vec())
        .collect();

    println!("protecting k = {k} data bits:");
    println!("code        (n, k, d)  rate   detects  corrects");
    report("parity", &parity_words, k);
    report("repetition", &repeat_words, k);
    report("hamming", &hamming_words, k);

    // Parity: detect a single error, correct nothing.
    let mut pw = parity_encode(&message);
    pw[0] = !pw[0];
    println!(
        "\nparity: {} -> {}, flip bit 0 -> {}, parity_ok = {}",
        bits(&message),
        bits(&parity_encode(&message)),
        bits(&pw),
        parity_ok(&pw)
    );

    // Repetition: outvote a single error.
    let rw = repeat_encode(message[0]);
    let mut rw_corrupt = rw;
    rw_corrupt[2] = !rw_corrupt[2];
    println!(
        "\nrepetition: bit {} -> {}, flip bit 2 -> {}, majority = {}",
        message[0] as u8,
        bits(&rw),
        bits(&rw_corrupt),
        repeat_decode(rw_corrupt) as u8
    );

    // Hamming: correct a single error.
    let hw = encode(message);
    let mut hw_corrupt = hw;
    hw_corrupt[3] = !hw_corrupt[3];
    let s = syndrome(hw_corrupt);
    let decoded = decode(hw_corrupt);
    println!(
        "\nhamming: {} -> {}, flip bit 4 -> {}, syndrome = {s}, recovered {}",
        bits(&message),
        bits(&hw),
        bits(&hw_corrupt),
        bits(&decoded.data)
    );
}

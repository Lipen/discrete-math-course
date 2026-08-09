//! Hamming(7,4) in action: encode, corrupt one bit, correct it.
//!
//! The demo walks through the whole pipeline on a single word so the syndrome
//! trick is visible: a nonzero syndrome is exactly the position of the error.

use codes::{decode, encode, syndrome};

fn bits(word: [bool; 7]) -> String {
    word.iter().map(|&b| if b { '1' } else { '0' }).collect()
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
    println!("\ncorrupt bit 4 -> received = {}", bits(received));
    println!("syndrome = {s}   (the position of the error)");

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

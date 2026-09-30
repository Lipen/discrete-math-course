//! Breaking the Caesar cipher by brute force.
//!
//! The cipher key is a shift from 1 to 25.
//! Every shift is tried, and the meaningful word "HELLO" appears at a
//! shift of 3 positions.

/// English alphabet (26 letters).
const ENG: &str = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

fn main() {
    let cipher = "KHOOR";
    println!("Ciphertext: {cipher}");
    println!("All shifts (decryption):");

    let letters: Vec<char> = ENG.chars().collect();
    let n = letters.len();
    for k in 1..n {
        let decrypted: String = cipher
            .chars()
            .map(|c| {
                let Some(i) = letters.iter().position(|&x| x == c) else {
                    return c;
                };
                letters[(i + n - k) % n]
            })
            .collect();
        println!("shift {k:>2}: {decrypted}");
    }

    println!("One of the lines is meaningful -- that is the plaintext.");
}

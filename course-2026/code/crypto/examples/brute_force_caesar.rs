//! Breaking the Caesar cipher by brute force.
//!
//! The cipher key is a shift from 1 to 32.
//! Every shift is tried, and the meaningful word "ШИФР" appears at a
//! shift of 3 positions.

/// Russian alphabet (33 letters, with Ё).
const RUS: &str = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ";

fn main() {
    let cipher = "ЫЛЧУ";
    println!("Ciphertext: {cipher}");
    println!("All shifts (decryption):");

    let letters: Vec<char> = RUS.chars().collect();
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

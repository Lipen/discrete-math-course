//! RSA malleability (the chapter, section "Breaking").
//!
//! The product of ciphertexts is the ciphertext of the product of the messages:
//! $c_1 c_2 = (m_1 m_2)^e mod n$. The attacker does not read the messages
//! but can forge their values --- which is why bare RSA is not used.

use crypto::attacks::malleable_product;
use crypto::{mod_inverse, mod_pow};

fn main() {
    let p = 61;
    let q = 53;
    let n = p * q;
    let phi = (p - 1) * (q - 1);
    let e = 17;
    let d = mod_inverse(e, phi).unwrap();

    let m1 = 7;
    let m2 = 11;
    let c1 = mod_pow(m1, e, n);
    let c2 = mod_pow(m2, e, n);

    // The attacker knows only (n, e) and the ciphertexts.
    let forged = malleable_product(c1, c2, n);
    let honest = mod_pow(m1 * m2 % n, e, n);

    println!("c1 = {c1}, c2 = {c2}");
    println!("c1 * c2 mod n = {forged}");
    println!("(m1 * m2)^e mod n = {honest}");
    println!("Match: {}", forged == honest);

    // The key owner decrypts the forgery as the product of the messages.
    let dec = mod_pow(forged, d, n);
    println!(
        "Decryption of the forgery: {dec} (expected {})",
        m1 * m2 % n
    );
    println!("Hence randomness (OAEP padding) in the standards, not bare RSA.");
}

//! Teaching RSA on small keys.
//!
//! p = 61, q = 53, e = 17 -- the classic example; modulus n = 3233.
//! Real keys require arbitrary precision and padding.

use crypto::Rsa;

fn main() {
    let rsa = Rsa::new(61, 53, 17);
    println!("Key: n = {}, e = {}", rsa.n, rsa.e);

    // Encryption / decryption.
    let msg = 65; // the character 'A'
    let cipher = rsa.encrypt(msg);
    let back = rsa.decrypt(cipher);
    println!("Encrypt: {msg} -> {cipher}, decrypt: {cipher} -> {back}");

    // Signing / verification.
    let doc = 100;
    let sig = rsa.sign(doc);
    println!();
    println!("Sign:   sign({doc}) = {sig}");
    println!("Verify: verify({doc}, {sig}) = {}", rsa.verify(doc, sig));
    println!(
        "Verify: verify({doc}, {}) = {}  (tampered -- should be false)",
        sig + 1,
        rsa.verify(doc, sig + 1)
    );
}

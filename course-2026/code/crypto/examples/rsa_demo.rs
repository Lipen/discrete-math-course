//! Teaching RSA from the chapter on small keys.
//!
//! p = 61, q = 53, e = 17 --- the classic example; modulus n = 3233.
//! Real keys require arbitrary precision.

use crypto::Rsa;

fn main() {
    let rsa = Rsa::new(61, 53, 17);
    println!("n = {}, e = {}", rsa.n, rsa.e);

    let msg = 65; // the character 'A'
    let cipher = rsa.encrypt(msg);
    println!(
        "msg = {msg}, cipher = {cipher}, back = {}",
        rsa.decrypt(cipher)
    );
}

//! Учебный RSA из главы m13 на малых ключах.
//!
//! p = 61, q = 53, e = 17 --- классический пример; модуль n = 3233.
//! Реальные ключи требуют произвольной точности.

use crypto::Rsa;

fn main() {
    let rsa = Rsa::new(61, 53, 17);
    println!("n = {}, e = {}", rsa.n, rsa.e);

    let msg = 65; // символ 'A'
    let cipher = rsa.encrypt(msg);
    println!(
        "msg = {msg}, cipher = {cipher}, back = {}",
        rsa.decrypt(cipher)
    );
}

//! Маллобильность RSA (глава m13, раздел «Взлом»).
//!
//! Произведение шифротекстов --- шифротекст произведения сообщений:
//! $c_1 c_2 = (m_1 m_2)^e mod n$. Злоумышленник не читает сообщения,
//! но может подделывать их значения --- поэтому "голый" RSA не используют.

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

    // Злоумышленник знает только (n, e) и шифротексты.
    let forged = malleable_product(c1, c2, n);
    let honest = mod_pow(m1 * m2 % n, e, n);

    println!("c1 = {c1}, c2 = {c2}");
    println!("c1 * c2 mod n = {forged}");
    println!("(m1 * m2)^e mod n = {honest}");
    println!("Совпадают: {}", forged == honest);

    // Владелец ключа расшифрует подделку как произведение сообщений.
    let dec = mod_pow(forged, d, n);
    println!("Расшифровка подделки: {dec} (ожидается {})", m1 * m2 % n);
    println!("Отсюда --- случайность (padding OAEP) в стандартах, а не «голый» RSA.");
}

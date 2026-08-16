//! Common modulus attack on RSA.
//!
//! Two users share the modulus $n$, and the exponents $e_1$, $e_2$ are coprime.
//! The extended Euclidean algorithm gives $u, v$ with $e_1 u + e_2 v = 1$, and
//! $c_1^u c_2^v = m$ -- no private keys are needed.

use crypto::attacks::common_modulus_attack;
use crypto::mod_pow;

fn main() {
    let p = 61;
    let q = 53;
    let n = p * q;
    let e1 = 17;
    let e2 = 7; // gcd(17, 7) = 1

    let m = 42;
    let c1 = mod_pow(m, e1, n);
    let c2 = mod_pow(m, e2, n);

    println!("n = {n}, e1 = {e1}, e2 = {e2}, m = {m}");
    println!("c1 = m^e1 = {c1}");
    println!("c2 = m^e2 = {c2}");

    let recovered = common_modulus_attack(n, e1, c1, e2, c2).expect("the attack must succeed");
    println!("The attack recovered: {recovered}");
    println!("Private exponents were not needed: each user must have their own modulus.");
}

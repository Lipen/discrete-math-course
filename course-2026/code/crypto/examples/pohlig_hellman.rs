//! Pohlig--Hellman attack on DLOG (the chapter, section "Breaking").
//!
//! If the group order $p - 1$ is smooth, the discrete logarithm reduces
//! to logarithms in subgroups of small orders and is assembled via CRT.
//! For $p = 29$ the order $28 = 2^2 dot 7$ is smooth, and the logarithm
//! is found almost instantly.

use crypto::attacks::pohlig_hellman;
use crypto::mod_pow;

fn main() {
    let p = 29;
    let g = 2; // generator of ZZ_29^*
    let x = 13;
    let h = mod_pow(g, x, p);

    println!("Group order p - 1 = {} = 2^2 * 7 (smooth)", p - 1);
    println!("Find x in g^x = {h} (mod {p}), where g = {g}");

    let recovered = pohlig_hellman(p, g, h).expect("smooth order -- the attack must succeed");
    println!("Pohlig--Hellman found x = {recovered}");
    println!("This is why the order is chosen with a large prime factor (safe prime p - 1 = 2q).");
}

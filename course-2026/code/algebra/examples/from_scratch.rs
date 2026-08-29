//! From-scratch layer: Peano naturals and the Euclidean algorithm.
//!
//! `Nat` builds numbers from `Zero` and `Succ` and adds by recursion, with
//! no `u32` arithmetic. `extended_gcd` is the hand-rolled core that later
//! yields modular inverses.

use algebra::arithmetic::{extended_gcd, gcd, mod_inverse};
use algebra::nat::Nat;
use algebra::traits::{Monoid, Semigroup};

fn main() {
    // Peano addition and multiplication, entirely by recursion.
    let three = Nat::from_u32(3);
    let four = Nat::from_u32(4);
    println!("3 + 4 = {}", three.op(&four).to_u32());
    println!("3 * 4 = {}", three.mul(&four).to_u32());
    println!(
        "0 + 3 = {} (identity leaves 3 unchanged)",
        Nat::identity().op(&three).to_u32()
    );

    // Hand-rolled Euclid.
    println!("gcd(12, 8) = {}", gcd(12, 8));
    let (g, x, y) = extended_gcd(12, 8);
    println!("extended_gcd(12, 8) = ({g}, {x}, {y}); check 12*{x} + 8*{y} = {g}");

    // Modular inverse via Bezout: 3 * 2 = 6 = 1 mod 5, so 2 inverts 3 mod 5.
    println!("inverse of 3 mod 5 = {}", mod_inverse(3, 5).unwrap());
    println!("inverse of 2 mod 6 = none (2 and 6 are not coprime)");

    assert_eq!(three.op(&four).to_u32(), 7);
    assert_eq!(three.mul(&four).to_u32(), 12);
    assert_eq!(mod_inverse(3, 5), Some(2));
    assert_eq!(mod_inverse(2, 6), None);
}

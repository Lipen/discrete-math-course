//! Column arithmetic on values the built-in types cannot hold.
//!
//! The demo builds two 39-digit numbers from small factors, then adds,
//! subtracts, multiplies and divides them, printing every result in full.

use bignum::BigInt;

/// The value of `base^exp` by repeated multiplication.
fn pow(base: u64, exp: u32) -> BigInt {
    let mut result = BigInt::from_u64(1);
    for _ in 0..exp {
        result = result * BigInt::from_u64(base);
    }
    result
}

fn main() {
    let a = pow(2, 128);
    let b = pow(3, 80);
    println!("two numbers beyond 64 bits, built from small factors");
    println!("  a = 2^128 = {}", a);
    println!("  b = 3^80  = {}", b);
    println!(
        "  a has {} decimal digits, b has {}",
        a.to_string().len(),
        b.to_string().len()
    );

    println!();
    println!("addition and subtraction, one column at a time");
    println!("  a + b = {}", a.clone() + b.clone());
    println!("  a - b = {}", a.clone() - b.clone());

    println!();
    println!("multiplication: every limb pair contributes one product");
    let product = a.clone() * b.clone();
    println!("  a * b = {}", product);
    println!(
        "  the product has {} decimal digits",
        product.to_string().len()
    );

    println!();
    println!("division with remainder inverts the product");
    let (q, r) = product.magnitude().divmod(a.magnitude());
    println!("  (a * b) / a = {}", q);
    println!("  remainder   = {}", r);
    assert_eq!(&q, b.magnitude());
    assert!(r.is_zero());
    println!("  check: the quotient is b and the remainder is zero -- ok");

    println!();
    println!("the sign follows the larger magnitude");
    println!("  a < b is {}", a < b);
    println!("  b - a = {}", b - a);
}

//! The finite field GF(4) and the byte field GF(256) behind AES.

use algebra::gf::{Gf256, Gf4};
use algebra::traits::{Field, Ring};

fn main() {
    // GF(4) = GF(2)[x] / (x^2 + x + 1). Elements: 0, 1, alpha = x, alpha + 1.
    let a = Gf4::new(2); // alpha = x
    let ap1 = Gf4::new(3); // alpha + 1

    println!("GF(4) = GF(2)[x] / (x^2 + x + 1), with alpha = x.");
    println!("The rule x^2 + x + 1 = 0 gives alpha^2 = alpha + 1:");
    println!("  alpha * alpha = {}", a.mul(&a).coeffs());
    println!("  alpha * (alpha + 1) = {}", a.mul(&ap1).coeffs());

    let elems = Gf4::elements();

    // Addition table (XOR of coefficients).
    println!("\naddition table (coefficient bits):");
    print!("  +");
    for b in &elems {
        print!(" {:>2}", b.coeffs());
    }
    println!();
    for x in &elems {
        print!("{:>3}", x.coeffs());
        for y in &elems {
            print!(" {:>2}", x.add(y).coeffs());
        }
        println!();
    }

    // Multiplication table.
    println!("\nmultiplication table:");
    print!("  *");
    for b in &elems {
        print!(" {:>2}", b.coeffs());
    }
    println!();
    for x in &elems {
        print!("{:>3}", x.coeffs());
        for y in &elems {
            print!(" {:>2}", x.mul(y).coeffs());
        }
        println!();
    }

    // Every nonzero element has an inverse.
    println!("\ninverses:");
    for x in &elems {
        if !x.is_zero() {
            let xi = x.inv().unwrap();
            println!("  {}^-1 = {}", x.coeffs(), xi.coeffs());
        }
    }

    // The primitive element alpha: order 3 = q - 1.
    println!(
        "\norder(alpha) = {} = q - 1, so alpha is primitive",
        a.order().unwrap()
    );
    println!(
        "powers of alpha: a^1 = {}, a^2 = {}, a^3 = {}",
        a.pow(1).coeffs(),
        a.pow(2).coeffs(),
        a.pow(3).coeffs()
    );

    // GF(256): the byte field of AES, x^8 + x^4 + x^3 + x + 1.
    let x = Gf256::new(2);
    let xp1 = Gf256::new(3);
    println!("\nGF(256) = GF(2)[x] / (x^8 + x^4 + x^3 + x + 1): the byte field of AES.");
    println!("order(x)   = {} (x is not primitive)", x.order().unwrap());
    println!("order(x+1) = {} (x + 1 is primitive)", xp1.order().unwrap());
    println!("inverse of x in GF(256) = {}", x.inv().unwrap().coeffs());

    assert_eq!(a.mul(&a), ap1);
    assert_eq!(a.mul(&ap1), Gf4::one());
    assert_eq!(a.order(), Some(3));
    assert_eq!(x.order(), Some(51));
    assert_eq!(xp1.order(), Some(255));
    assert_eq!(x.mul(&x.inv().unwrap()), Gf256::one());
}

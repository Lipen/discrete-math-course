//! The exact spots where `u64` arithmetic breaks, and the same values computed exactly.
//!
//! Built-in addition and multiplication wrap or panic past `2^64 - 1`.
//! The demo locates the first overflow in the factorial and Fibonacci
//! sequences, then recomputes the same sequences with the crate.

use bignum::integer::{factorial, fibonacci, BigInt};

fn main() {
    println!("the ceiling: u64 holds 0 .. 2^64 - 1");
    println!("  u64::MAX = {}", u64::MAX);
    println!("  u64::MAX.checked_add(1) = {:?}", u64::MAX.checked_add(1));
    let wide = BigInt::from_u64(u64::MAX) + BigInt::from_u64(u64::MAX);
    println!("  the crate: u64::MAX + u64::MAX = {}", wide);

    println!();
    println!("factorial: 20! still fits, 21! does not");
    let mut value: u64 = 1;
    let mut k = 1;
    while let Some(next) = value.checked_mul((k + 1) as u64) {
        value = next;
        k += 1;
    }
    println!("  {}! = {} still fits u64", k, value);
    let true_next = value as u128 * (k as u64 + 1) as u128;
    println!("  {}! = {} no longer fits", k + 1, true_next);
    let exact = factorial(30);
    println!(
        "  the crate computes 30! = {} ({} decimal digits)",
        exact,
        exact.to_string().len()
    );

    println!();
    println!("fibonacci: F_93 still fits, F_94 does not");
    let (mut p, mut q) = (1u64, 1u64);
    let mut n = 2u32;
    while let Some(next) = p.checked_add(q) {
        p = q;
        q = next;
        n += 1;
    }
    println!("  F_{} = {} still fits u64", n, q);
    let (mut wide_p, mut wide_q) = (1u128, 1u128);
    for _ in 2..n {
        let next = wide_p + wide_q;
        wide_p = wide_q;
        wide_q = next;
    }
    println!("  F_{} = {} no longer fits", n + 1, wide_p + wide_q);
    let far = fibonacci(200);
    println!(
        "  the crate computes F_200 = {} ({} decimal digits)",
        far,
        far.to_string().len()
    );
}

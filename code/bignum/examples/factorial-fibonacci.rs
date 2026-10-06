//! Two records far beyond 64 bits: 100! and the thousandth Fibonacci number.
//!
//! The demo prints the inputs, the digit counts along the way, both full
//! decimal records, and the checks: exactly 24 trailing zeros in 100!, and
//! divisibility of Fibonacci numbers by their index divisors.

use bignum::integer::{factorial, fibonacci};

fn main() {
    println!("factorial by repeated multiplication");
    println!("  input: n = 100");
    for k in (10..=100).step_by(10) {
        println!(
            "  step: {}! has {} decimal digits",
            k,
            factorial(k).to_string().len()
        );
    }
    let record = factorial(100);
    println!("  100! = {}", record);
    let text = record.to_string();
    println!("  decimal digits: {}", text.len());
    let trailing = text.len() - text.trim_end_matches('0').len();
    assert_eq!(trailing, 24, "100! must end in exactly 24 zeros");
    println!("  check: trailing zeros = 24, expected 24 -- ok");

    println!();
    println!("fibonacci by iteration on pairs, F_1 = F_2 = 1");
    println!("  input: n = 1000");
    for k in (100..=1000).step_by(100) {
        println!(
            "  step: F_{} has {} decimal digits",
            k,
            fibonacci(k).to_string().len()
        );
    }
    println!("  F_1000 = {}", fibonacci(1000));
    println!("  decimal digits: {}", fibonacci(1000).to_string().len());

    println!();
    println!("divisibility: F_m divides F_n whenever m divides n");
    let (q300, r300) = fibonacci(300)
        .magnitude()
        .divmod(fibonacci(100).magnitude());
    assert!(r300.is_zero(), "F_300 must be divisible by F_100");
    println!("  F_300 / F_100 = {} (remainder 0)", q300);
    let (q1000, r1000) = fibonacci(1000)
        .magnitude()
        .divmod(fibonacci(500).magnitude());
    assert!(r1000.is_zero(), "F_1000 must be divisible by F_500");
    println!("  F_1000 / F_500 = {} (remainder 0)", q1000);
}

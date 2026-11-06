//! Fibonacci numbers as coefficients of `1/(1 - x - x^2)`.
//!
//! The denominator has constant term `1`, so it is invertible as a truncated series.
//! The coefficients of the inverse obey `F_k = F_(k - 1) + F_(k - 2)`.

use generating_functions::{fibonacci_numbers, Series};

fn main() {
    let n = 20;
    let x = Series::x(n);
    let one = Series::constant(1, n);
    let denominator = one.sub(&x).sub(&x.mul(&x));
    let series = denominator.inverse().expect("constant term is 1");

    println!("1 - x - x^2 = {:?}", denominator.coefficients());
    println!();
    println!("1/(1 - x - x^2) = {:?}", series.coefficients());
    println!();
    println!("Fibonacci numbers:");
    for (k, value) in series.coefficients().iter().enumerate() {
        println!("  F_{:<2} = {}", k, value);
    }

    let last = series.coeff(n) as f64;
    let previous = series.coeff(n - 1) as f64;
    println!();
    println!("F_{}/F_{} = {:.6}", n, n - 1, last / previous);

    assert_eq!(series.coefficients(), fibonacci_numbers(n).as_slice());
}

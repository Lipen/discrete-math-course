//! Catalan numbers from the fixed point of `C = 1 + x C^2`.
//!
//! Starting at `C = 1` and applying `C -> 1 + x C^2` fixes one more coefficient per step.
//! After `n` steps the series holds the Catalan numbers `C_0` through `C_n`.

use generating_functions::{catalan_numbers, Series};

fn main() {
    let n = 20;
    let x = Series::x(n);
    let mut c = Series::constant(1, n);

    println!("fixed point of C = 1 + x C^2, truncated at degree {}", n);
    println!();
    for step in 0..=n {
        if step <= 5 {
            println!("step {}: {:?}", step, c.coefficients());
        }
        if step < n {
            c = Series::constant(1, n).add(&x.mul(&c.mul(&c)));
        }
    }

    println!();
    println!("Catalan numbers:");
    for (k, value) in c.coefficients().iter().enumerate() {
        println!("  C_{:<2} = {}", k, value);
    }

    let expected = catalan_numbers(n);
    assert_eq!(c.coefficients(), expected.as_slice());
    println!();
    println!("checked against catalan_numbers({})", n);
}

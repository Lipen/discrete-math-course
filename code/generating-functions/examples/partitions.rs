//! Partition numbers as coefficients of `prod 1/(1 - x^k)`.
//!
//! Each factor is a geometric series `1 + x^k + x^(2k) + ...`.
//! Multiplying the factors lets every part size contribute any number of times, so the coefficient of `x^n` counts the partitions of `n`.

use generating_functions::{partition_numbers, Series};

fn main() {
    let n = 20;
    let mut product = Series::constant(1, n);

    println!("multiplying factors 1/(1 - x^k), truncated at degree {}", n);
    println!();
    for k in 1..=n {
        let mut coeffs = vec![0; n + 1];
        coeffs[0] = 1;
        coeffs[k] = -1;
        let factor = Series::from_coeffs(&coeffs)
            .inverse()
            .expect("constant term is 1");
        product = product.mul(&factor);
        if k <= 5 || k == n {
            println!("after k = {:>2}: {:?}", k, product.coefficients());
        }
    }

    println!();
    println!("partition numbers:");
    for (k, value) in product.coefficients().iter().enumerate() {
        println!("  p({:<2}) = {}", k, value);
    }

    assert_eq!(product.coefficients(), partition_numbers(n).as_slice());
    println!();
    println!("checked against partition_numbers({})", n);
}

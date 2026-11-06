//! Three sequences read off their generating functions.
//!
//! Each function builds a [`Series`] from the equation that defines the sequence, then returns the coefficients.
//! The construction is the whole argument: once the series is known, the coefficients are the sequence.

use crate::Series;

/// Catalan numbers `C_0` through `C_n`.
///
/// The generating function satisfies `C(x) = 1 + x C(x)^2`, and its coefficients are `C_k = binom(2k, k)/(k + 1)`.
///
/// ```
/// use generating_functions::catalan_numbers;
/// assert_eq!(catalan_numbers(5), vec![1, 1, 2, 5, 14, 42]);
/// ```
pub fn catalan_numbers(n: usize) -> Vec<i64> {
    catalan_series(n).coefficients().to_vec()
}

/// The Catalan generating function truncated at degree `n`, the fixed point of `C = 1 + x C^2`.
///
/// The iteration starts at `C = 1` and applies the map `C -> 1 + x C^2` exactly `n` times.
/// Every application fixes one more coefficient, so `n` applications determine degrees `0` through `n`.
///
/// ```
/// use generating_functions::catalan_series;
/// assert_eq!(catalan_series(4).coefficients(), &[1, 1, 2, 5, 14]);
/// ```
pub fn catalan_series(n: usize) -> Series {
    let x = Series::x(n);
    let mut c = Series::constant(1, n);
    for _ in 0..n {
        c = Series::constant(1, n).add(&x.mul(&c.mul(&c)));
    }
    c
}

/// Fibonacci numbers `F_0` through `F_n`, with `F_0 = F_1 = 1`.
///
/// They are the coefficients of `1/(1 - x - x^2)`, so `F_k = F_(k - 1) + F_(k - 2)` for `k >= 2`.
///
/// ```
/// use generating_functions::fibonacci_numbers;
/// assert_eq!(fibonacci_numbers(6), vec![1, 1, 2, 3, 5, 8, 13]);
/// ```
pub fn fibonacci_numbers(n: usize) -> Vec<i64> {
    fibonacci_series(n).coefficients().to_vec()
}

/// The expansion of `1/(1 - x - x^2)` truncated at degree `n`.
///
/// ```
/// use generating_functions::fibonacci_series;
/// assert_eq!(fibonacci_series(5).coefficients(), &[1, 1, 2, 3, 5, 8]);
/// ```
pub fn fibonacci_series(n: usize) -> Series {
    let x = Series::x(n);
    let denominator = Series::constant(1, n).sub(&x).sub(&x.mul(&x));
    denominator.inverse().expect("constant term is 1")
}

/// Partition numbers `p(0)` through `p(n)`.
///
/// `p(k)` counts the ways to write `k` as an unordered sum of positive integers, so `p(4) = 5`:
/// `4`, `3 + 1`, `2 + 2`, `2 + 1 + 1`, `1 + 1 + 1 + 1`.
///
/// ```
/// use generating_functions::partition_numbers;
/// assert_eq!(partition_numbers(6), vec![1, 1, 2, 3, 5, 7, 11]);
/// ```
pub fn partition_numbers(n: usize) -> Vec<i64> {
    partition_series(n).coefficients().to_vec()
}

/// The partition generating function truncated at degree `n`, the product of `1/(1 - x^k)` over `k = 1..=n`.
///
/// Factors with `k > n` cannot contribute a term of degree at most `n`, so the finite product is exact through degree `n`.
///
/// ```
/// use generating_functions::partition_series;
/// assert_eq!(partition_series(7).coefficients(), &[1, 1, 2, 3, 5, 7, 11, 15]);
/// ```
pub fn partition_series(n: usize) -> Series {
    let mut product = Series::constant(1, n);
    for k in 1..=n {
        let mut coeffs = vec![0; n + 1];
        coeffs[0] = 1;
        coeffs[k] = -1;
        let factor = Series::from_coeffs(&coeffs)
            .inverse()
            .expect("constant term is 1");
        product = product.mul(&factor);
    }
    product
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn first_sequence_values() {
        assert_eq!(catalan_numbers(5), vec![1, 1, 2, 5, 14, 42]);
        assert_eq!(fibonacci_numbers(6), vec![1, 1, 2, 3, 5, 8, 13]);
        assert_eq!(partition_numbers(6), vec![1, 1, 2, 3, 5, 7, 11]);
    }

    #[test]
    fn catalan_series_is_the_fixed_point() {
        let n = 12;
        let c = catalan_series(n);
        let rhs = Series::constant(1, n).add(&Series::x(n).mul(&c.mul(&c)));
        assert_eq!(c, rhs);
    }

    #[test]
    fn fibonacci_series_satisfies_its_equation() {
        let n = 15;
        let f = fibonacci_series(n);
        let x = Series::x(n);
        let one = Series::constant(1, n);
        let product = f.mul(&one.sub(&x).sub(&x.mul(&x)));
        assert_eq!(product, one);
    }

    #[test]
    fn removing_the_last_factor_returns_the_previous_product() {
        let n = 10;
        let p = partition_series(n);
        let mut coeffs = vec![0; n + 1];
        coeffs[0] = 1;
        coeffs[n] = -1;
        let last = Series::from_coeffs(&coeffs);
        assert_eq!(p.mul(&last).with_degree(n - 1), partition_series(n - 1));
    }
}

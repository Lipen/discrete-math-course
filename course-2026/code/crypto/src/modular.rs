//! Modular arithmetic on `u64`.
//!
//! The toolbox for the number-theory part:
//! GCD (Euclid), extended GCD, modular inverse, and fast exponentiation
//! by repeated squaring.

/// Euclid's algorithm: the greatest common divisor of `a` and `b`.
///
/// # Examples
///
/// ```
/// use crypto::modular::gcd;
///
/// assert_eq!(gcd(48, 18), 6);
/// assert_eq!(gcd(17, 5), 1);
/// assert_eq!(gcd(0, 7), 7);
/// ```
pub fn gcd(a: u64, b: u64) -> u64 {
    let (mut a, mut b) = (a, b);
    while b != 0 {
        let r = a % b;
        a = b;
        b = r;
    }
    a
}

/// Extended Euclidean algorithm.
///
/// Returns `(g, x, y)` such that `a * x + b * y = g` where `g = gcd(a, b)`.
/// The Bezout coefficients `x` and `y` can be negative even when `a` and `b`
/// are positive, so the parameters and results use `i128`.
///
/// # Examples
///
/// ```
/// use crypto::modular::egcd;
///
/// let (g, x, y) = egcd(240, 46);
/// assert_eq!(g, 2);
/// assert_eq!(240 * x + 46 * y, 2); // Bezout identity
/// ```
pub fn egcd(a: i128, b: i128) -> (i128, i128, i128) {
    if b == 0 {
        (a, 1, 0)
    } else {
        let (g, x, y) = egcd(b, a % b);
        (g, y, x - (a / b) * y)
    }
}

/// Modular inverse of `a` modulo `m`.
///
/// Returns `Some(x)` with `a * x ≡ 1 (mod m)`, or `None`
/// if `a` and `m` are not coprime (or `m == 0`).
///
/// # Examples
///
/// ```
/// use crypto::modular::mod_inverse;
///
/// assert_eq!(mod_inverse(3, 7), Some(5)); // 3 * 5 = 15 ≡ 1 (mod 7)
/// assert_eq!(mod_inverse(2, 4), None);    // gcd(2, 4) = 2
/// ```
pub fn mod_inverse(a: u64, m: u64) -> Option<u64> {
    if m == 0 {
        return None;
    }
    let (g, x, _) = egcd(a as i128, m as i128);
    if g != 1 {
        return None;
    }
    Some(((x % m as i128 + m as i128) % m as i128) as u64)
}

/// Fast modular exponentiation: `base^exp mod m` by repeated squaring.
///
/// Uses `u128` for intermediate multiplications to avoid overflow.
///
/// # Examples
///
/// ```
/// use crypto::modular::mod_pow;
///
/// assert_eq!(mod_pow(2, 10, 1000), 24);  // 2^10 = 1024
/// assert_eq!(mod_pow(3, 6, 7), 1);       // Fermat: 3^6 ≡ 1 (mod 7)
/// assert_eq!(mod_pow(5, 0, 13), 1);      // x^0 = 1
/// assert_eq!(mod_pow(7, 1, 100), 7);     // x^1 = x
/// ```
pub fn mod_pow(mut base: u64, mut exp: u64, m: u64) -> u64 {
    if m == 1 {
        return 0;
    }
    let mut result: u64 = 1;
    base %= m;
    while exp > 0 {
        if exp % 2 == 1 {
            result = ((result as u128 * base as u128) % m as u128) as u64;
        }
        exp /= 2;
        base = ((base as u128 * base as u128) % m as u128) as u64;
    }
    result
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn gcd_of_coprime_numbers_is_one() {
        assert_eq!(gcd(17, 5), 1);
        assert_eq!(gcd(100, 99), 1);
    }

    #[test]
    fn gcd_with_zero_returns_other() {
        assert_eq!(gcd(0, 7), 7);
        assert_eq!(gcd(7, 0), 7);
    }

    #[test]
    fn gcd_of_equal_numbers_is_itself() {
        assert_eq!(gcd(12, 12), 12);
    }

    #[test]
    fn egcd_satisfies_bezout_identity() {
        let cases = [(240, 46), (17, 5), (100, 99)];
        for (a, b) in cases {
            let (g, x, y) = egcd(a, b);
            assert_eq!(g, gcd(a as u64, b as u64) as i128);
            assert_eq!(a * x + b * y, g);
        }
    }

    #[test]
    fn egcd_when_b_is_zero() {
        let (g, x, y) = egcd(7, 0);
        assert_eq!((g, x, y), (7, 1, 0));
    }

    #[test]
    fn mod_inverse_exists_when_coprime() {
        assert_eq!(mod_inverse(3, 7), Some(5));
        assert_eq!(mod_inverse(7, 3), Some(1)); // 7 ≡ 1 (mod 3), inverse is 1
    }

    #[test]
    fn mod_inverse_none_when_not_coprime() {
        assert_eq!(mod_inverse(2, 4), None);
        assert_eq!(mod_inverse(6, 9), None);
    }

    #[test]
    fn mod_inverse_none_when_modulus_zero() {
        assert_eq!(mod_inverse(5, 0), None);
    }

    #[test]
    fn mod_pow_mod_one_is_zero() {
        assert_eq!(mod_pow(12345, 100, 1), 0);
    }

    #[test]
    fn mod_pow_zero_exponent_is_one() {
        assert_eq!(mod_pow(7, 0, 13), 1);
    }

    #[test]
    fn mod_pow_fermat_little_theorem() {
        // For prime p=7 and a=3 not divisible by p: 3^6 ≡ 1 (mod 7)
        assert_eq!(mod_pow(3, 6, 7), 1);
    }

    #[test]
    fn mod_pow_large_exponent() {
        // 2^100 mod 13.
        // 2^12 ≡ 1 (mod 13) by Fermat, so 2^100 = 2^(12*8+4) ≡ 2^4 = 16 ≡ 3.
        assert_eq!(mod_pow(2, 100, 13), 3);
    }

    #[test]
    fn mod_inverse_product_is_one() {
        for a in [3, 5, 7, 11] {
            let inv = mod_inverse(a, 17).unwrap();
            assert_eq!(a * inv % 17, 1);
        }
    }
}

//! The Euclidean algorithm, written from scratch.
//!
//! `gcd` and `extended_gcd` are the hand-rolled core of modular arithmetic:
//! `extended_gcd(a, m)` produces Bezout coefficients, and `mod_inverse`
//! extracts a multiplicative inverse from them. Nothing here is imported;
//! the loop is the whole algorithm.

/// Greatest common divisor of two non-negative integers.
pub fn gcd(mut a: i64, mut b: i64) -> i64 {
    while b != 0 {
        let r = a % b;
        a = b;
        b = r;
    }
    a
}

/// Bezout coefficients: returns `(g, x, y)` with `a x + b y == g == gcd(a, b)`.
pub fn extended_gcd(a: i64, b: i64) -> (i64, i64, i64) {
    let (mut old_r, mut r) = (a, b);
    let (mut old_s, mut s) = (1, 0);
    let (mut old_t, mut t) = (0, 1);
    while r != 0 {
        let q = old_r / r;
        let next_r = old_r - q * r;
        let next_s = old_s - q * s;
        let next_t = old_t - q * t;
        old_r = r;
        old_s = s;
        old_t = t;
        r = next_r;
        s = next_s;
        t = next_t;
    }
    (old_r, old_s, old_t)
}

/// Multiplicative inverse of `a` modulo `m`, if `a` and `m` are coprime.
pub fn mod_inverse(a: i64, m: i64) -> Option<i64> {
    let a = a.rem_euclid(m);
    let (g, x, _) = extended_gcd(a, m);
    if g != 1 {
        return None;
    }
    Some(x.rem_euclid(m))
}

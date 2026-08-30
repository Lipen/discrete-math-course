//! The finite fields `GF(2^m)`: polynomials over `GF(2)` modulo an
//! irreducible polynomial.
//!
//! The chapter builds `GF(p^m)` as `GF(p)[x] / (f(x))` for an irreducible
//! `f`; here `p = 2`, the case used by AES and by linear codes over `GF(2)`.
//! Addition is XOR, multiplication is polynomial multiplication reduced mod
//! the irreducible modulus, and every nonzero element has an inverse found by
//! the extended Euclidean algorithm on polynomials.

use std::fmt;

use crate::traits::{Field, Ring};

/// An element of `GF(2^m)`: a polynomial over `GF(2)` of degree `< m`, stored
/// as its coefficient bits (bit `i` is the coefficient of `x^i`).
///
/// The field is `GF(2)[x] / (MOD)`, where `MOD` is an irreducible polynomial
/// of degree `m` (its degree-`m` bit included). `M` is the degree `m`; use
/// [`Gf::new`] to build elements, which masks off bits of degree `>= m`.
#[derive(Clone, Copy, PartialEq, Eq, Hash, Debug)]
pub struct Gf<const M: usize, const MOD: u64>(pub u64);

/// `GF(4) = GF(2)[x] / (x^2 + x + 1)`: the field of four elements, with the
/// root `alpha = x` satisfying `alpha^2 = alpha + 1`.
pub type Gf4 = Gf<2, 0b111>;

/// `GF(256) = GF(2)[x] / (x^8 + x^4 + x^3 + x + 1)`: the byte field behind
/// AES, whose elements are exactly the 256 bytes.
pub type Gf256 = Gf<8, 0x11B>;

impl<const M: usize, const MOD: u64> Gf<M, MOD> {
    /// Build an element from coefficient bits, truncating to degree `< M`.
    pub fn new(coeffs: u64) -> Self {
        Gf(coeffs & ((1u64 << M) - 1))
    }

    /// The coefficient bits: bit `i` is the coefficient of `x^i`.
    pub fn coeffs(self) -> u64 {
        self.0
    }

    /// Whether this is the zero polynomial.
    pub fn is_zero(&self) -> bool {
        self.0 == 0
    }

    /// `self^k` by repeated squaring.
    pub fn pow(&self, mut k: u64) -> Self {
        let mut result = Gf::one();
        let mut base = *self;
        while k > 0 {
            if k & 1 == 1 {
                result = result.mul(&base);
            }
            base = base.mul(&base);
            k >>= 1;
        }
        result
    }

    /// The multiplicative order: the smallest `k >= 1` with `self^k == 1`, or
    /// `None` for zero (which has no multiplicative order).
    pub fn order(&self) -> Option<u64> {
        if self.0 == 0 {
            return None;
        }
        let q = (1u64 << M) - 1;
        let mut cur = *self;
        for k in 1..=q {
            if cur == Gf::one() {
                return Some(k);
            }
            cur = cur.mul(self);
        }
        Some(q)
    }

    /// All `2^m` elements, in increasing coefficient order.
    pub fn elements() -> Vec<Self> {
        (0..(1u64 << M)).map(Gf::new).collect()
    }

    /// A primitive element: one of order `2^m - 1`, whose powers run through
    /// every nonzero element of the field.
    pub fn primitive_element() -> Self {
        let q = (1u64 << M) - 1;
        for g in 1..(1u64 << M) {
            let g = Gf::new(g);
            if g.order() == Some(q) {
                return g;
            }
        }
        Gf::one()
    }
}

impl<const M: usize, const MOD: u64> Ring for Gf<M, MOD> {
    fn add(&self, other: &Self) -> Self {
        Gf(self.0 ^ other.0)
    }

    fn mul(&self, other: &Self) -> Self {
        // Schoolbook polynomial multiplication with on-the-fly reduction:
        // whenever `a` overflows degree `m`, XOR out the modulus.
        let mut r = 0u64;
        let mut a = self.0;
        let mut b = other.0;
        while b != 0 {
            if b & 1 == 1 {
                r ^= a;
            }
            b >>= 1;
            a <<= 1;
            if a & (1u64 << M) != 0 {
                a ^= MOD;
            }
        }
        Gf(r)
    }

    fn zero() -> Self {
        Gf(0)
    }

    fn one() -> Self {
        Gf(1)
    }

    fn neg(&self) -> Self {
        // In characteristic 2 every element is its own additive inverse.
        *self
    }
}

impl<const M: usize, const MOD: u64> Field for Gf<M, MOD> {
    fn inv(&self) -> Option<Self> {
        if self.0 == 0 {
            return None;
        }
        // Extended Euclidean algorithm on polynomials: track `t` so that
        // `t * a == 1 (mod MOD)` when the remainder reaches the gcd `1`.
        let (mut r0, mut r1) = (MOD, self.0);
        let (mut t0, mut t1) = (0u64, 1u64);
        while r1 != 0 {
            let q = poly_div(r0, r1);
            let r2 = r0 ^ poly_mul(q, r1);
            let t2 = t0 ^ poly_mul(q, t1);
            r0 = r1;
            r1 = r2;
            t0 = t1;
            t1 = t2;
        }
        Some(Gf(reduce::<M, MOD>(t0)))
    }
}

impl<const M: usize, const MOD: u64> fmt::Display for Gf<M, MOD> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

/// Degree of a binary polynomial, or `-1` for the zero polynomial.
fn poly_deg(p: u64) -> i32 {
    if p == 0 {
        -1
    } else {
        63 - p.leading_zeros() as i32
    }
}

/// Quotient `a / b` of binary polynomials (`b != 0`).
fn poly_div(mut a: u64, b: u64) -> u64 {
    let db = poly_deg(b);
    let mut q = 0u64;
    let mut da = poly_deg(a);
    while da >= db {
        let shift = (da - db) as u32;
        q ^= 1u64 << shift;
        a ^= b << shift;
        da = poly_deg(a);
    }
    q
}

/// Product of two binary polynomials, without reduction.
fn poly_mul(mut a: u64, b: u64) -> u64 {
    let mut r = 0u64;
    let mut bb = b;
    while bb != 0 {
        if bb & 1 == 1 {
            r ^= a;
        }
        bb >>= 1;
        a <<= 1;
    }
    r
}

/// Reduce a polynomial mod `MOD` so its degree is `< M`.
fn reduce<const M: usize, const MOD: u64>(mut p: u64) -> u64 {
    while poly_deg(p) >= M as i32 {
        p ^= MOD << (poly_deg(p) - M as i32);
    }
    p
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn gf4_matches_the_chapter_tables() {
        let a = Gf4::new(2); // alpha
        let ap1 = Gf4::new(3); // alpha + 1
        assert_eq!(a.add(&ap1), Gf4::one()); // x + (x+1) = 1
        assert_eq!(a.mul(&a), ap1); // x^2 = x + 1
        assert_eq!(a.mul(&ap1), Gf4::one()); // x(x+1) = x^2 + x = 1
    }

    #[test]
    fn every_nonzero_element_is_invertible() {
        for x in Gf4::elements() {
            if x.is_zero() {
                assert_eq!(x.inv(), None);
            } else {
                assert_eq!(x.mul(&x.inv().unwrap()), Gf4::one());
            }
        }
    }

    #[test]
    fn alpha_is_primitive() {
        let a = Gf4::new(2);
        assert_eq!(a.order(), Some(3));
        assert_eq!(Gf4::primitive_element().order(), Some(3));
    }

    #[test]
    fn aes_byte_field_orders() {
        let x = Gf256::new(2);
        let xp1 = Gf256::new(3);
        assert_eq!(x.order(), Some(51));
        assert_eq!(xp1.order(), Some(255));
        assert_eq!(x.mul(&x.inv().unwrap()), Gf256::one());
    }
}

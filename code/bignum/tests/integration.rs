//! Cross-layer scenarios: records, division inverting multiplication, and
//! algebraic laws that hold far beyond the built-in widths.

use bignum::integer::{factorial, fibonacci, BigInt, Sign};
use bignum::rng::SplitMix64;
use bignum::Magnitude;

/// The value of `base^exp` by repeated multiplication.
fn pow(base: u64, exp: u32) -> BigInt {
    let mut result = BigInt::from_u64(1);
    for _ in 0..exp {
        result = result * BigInt::from_u64(base);
    }
    result
}

#[test]
fn powers_match_known_decimal_strings() {
    assert_eq!(
        pow(2, 128).to_string(),
        "340282366920938463463374607431768211456"
    );
    assert_eq!(
        pow(3, 80).to_string(),
        "147808829414345923316083210206383297601"
    );
    assert_eq!(pow(2, 128).magnitude().limbs().len(), 5);
}

#[test]
fn division_inverts_multiplication() {
    let mut rng = SplitMix64::new(5);
    for _ in 0..100 {
        let a = Magnitude::from_u64(rng.next_u64());
        let b = Magnitude::from_limbs(
            (0..1 + rng.below(3))
                .map(|_| rng.next_u64() as u32)
                .collect(),
        );
        let product = &a * &b;
        let (q, r) = product.divmod(&b);
        assert_eq!(q, a);
        assert!(r.is_zero());
    }
}

#[test]
fn subtraction_plus_addition_restores_the_minuend() {
    let mut rng = SplitMix64::new(6);
    for _ in 0..100 {
        let a = Magnitude::from_limbs(
            (0..1 + rng.below(3))
                .map(|_| rng.next_u64() as u32)
                .collect(),
        );
        let b = Magnitude::from_u64(rng.next_u64());
        let (diff, _) = a.divmod(&b);
        // a = b * diff + r with r < b, so b * diff <= a and a - (b * diff) < b.
        let reduced = &a - &(&b * &diff);
        assert!(reduced < b);
        assert_eq!(&(&b * &diff) + &reduced, a);
    }
}

#[test]
fn factorial_splits_into_partial_products() {
    let mut tail = BigInt::from_u64(1);
    for k in 51..=100 {
        tail = tail * BigInt::from_u64(k as u64);
    }
    assert_eq!(factorial(100), factorial(50) * tail);
    assert_eq!(factorial(100).to_string().len(), 158);
}

#[test]
fn fibonacci_neighbor_law_holds_far_beyond_64_bits() {
    for n in [91u32, 94, 95, 200, 500, 999] {
        assert_eq!(fibonacci(n + 1), fibonacci(n) + fibonacci(n - 1));
    }
    assert_eq!(
        fibonacci(200).to_string(),
        "280571172992510140037611932413038677189525"
    );
}

#[test]
fn zero_is_canonical_through_negation_and_subtraction() {
    let a = BigInt::from_u64(12_345_678_901_234_567_890);
    let zero = a.clone() - a.clone();
    assert!(zero.is_zero());
    assert_eq!(zero.sign(), Sign::Positive);
    assert_eq!((-zero).sign(), Sign::Positive);
    let negated = -a.clone();
    assert_eq!(negated.sign(), Sign::Negative);
    assert_eq!(-negated, a);
}

#[test]
fn mixed_sign_sums_match_wide_builtins() {
    let mut rng = SplitMix64::new(8);
    for _ in 0..200 {
        let x = rng.next_u64() as i64;
        let y = rng.next_u64() as i64;
        let (bx, by) = (BigInt::from_i64(x), BigInt::from_i64(y));
        let sum = bx.clone() + by.clone();
        assert_eq!(sum.to_i128(), Some(x as i128 + y as i128));
        let diff = bx - by;
        assert_eq!(diff.to_i128(), Some(x as i128 - y as i128));
        assert_eq!(
            sum.cmp(&diff),
            (x as i128 + y as i128).cmp(&(x as i128 - y as i128))
        );
    }
}

//! Signed integers: a sign flag plus a magnitude, with zero always positive.
//!
//! Every signed case reduces to magnitude work. Addition of equal signs adds
//! magnitudes, addition of opposite signs subtracts the smaller magnitude
//! from the larger and keeps the sign of the larger, subtraction adds the
//! negation, and multiplication multiplies magnitudes under the parity of
//! the signs. Zero is canonicalized to [`Sign::Positive`], so sign tests
//! never need a zero case.

use crate::magnitude::Magnitude;
use std::cmp::Ordering;
use std::fmt;
use std::ops::{Add, Mul, Neg, Sub};

/// Sign of a [`BigInt`]; the zero integer always carries `Sign::Positive`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Sign {
    /// Above zero.
    Positive,
    /// Below zero.
    Negative,
}

impl Sign {
    fn flip(self) -> Self {
        match self {
            Sign::Positive => Sign::Negative,
            Sign::Negative => Sign::Positive,
        }
    }
}

/// An arbitrary-precision integer: sign plus magnitude.
///
/// The magnitude obeys the canonical-limb invariants of
/// [`Magnitude`](crate::magnitude::Magnitude), and the zero value carries
/// `Sign::Positive`, so every equal value has exactly one representation.
#[derive(Clone, Debug)]
pub struct BigInt {
    sign: Sign,
    mag: Magnitude,
}

impl BigInt {
    /// Assembles the canonical form: a zero magnitude lands on `Sign::Positive`.
    fn make(sign: Sign, mag: Magnitude) -> Self {
        BigInt {
            sign: if mag.is_zero() { Sign::Positive } else { sign },
            mag,
        }
    }

    /// The zero integer.
    pub fn zero() -> Self {
        BigInt::make(Sign::Positive, Magnitude::zero())
    }

    /// The value of a `u64`.
    pub fn from_u64(value: u64) -> Self {
        BigInt::make(Sign::Positive, Magnitude::from_u64(value))
    }

    /// The value of an `i64`, sign folded into the flag.
    pub fn from_i64(value: i64) -> Self {
        BigInt::make(
            if value < 0 {
                Sign::Negative
            } else {
                Sign::Positive
            },
            Magnitude::from_u64(value.unsigned_abs()),
        )
    }

    /// Assembles from a sign and a magnitude; a zero magnitude becomes positive.
    ///
    /// ```
    /// use bignum::integer::{BigInt, Sign};
    /// use bignum::Magnitude;
    ///
    /// let value = BigInt::from_parts(Sign::Negative, Magnitude::from_u64(2));
    /// assert_eq!(value.to_string(), "-2");
    /// ```
    pub fn from_parts(sign: Sign, mag: Magnitude) -> Self {
        BigInt::make(sign, mag)
    }

    /// The sign flag, `Sign::Positive` for zero.
    pub fn sign(&self) -> Sign {
        self.sign
    }

    /// The magnitude without the sign.
    pub fn magnitude(&self) -> &Magnitude {
        &self.mag
    }

    /// True exactly for zero.
    pub fn is_zero(&self) -> bool {
        self.mag.is_zero()
    }

    /// The value as `i128` when the magnitude fits 127 bits.
    pub fn to_i128(&self) -> Option<i128> {
        let mag = self.mag.to_u128()?;
        let signed = i128::try_from(mag).ok()?;
        Some(if self.sign == Sign::Negative {
            -signed
        } else {
            signed
        })
    }
}

/// Ordering by signs first, then by magnitudes, reversed for two negatives.
impl Ord for BigInt {
    fn cmp(&self, other: &Self) -> Ordering {
        match (self.sign, other.sign) {
            (Sign::Positive, Sign::Negative) => Ordering::Greater,
            (Sign::Negative, Sign::Positive) => Ordering::Less,
            (Sign::Positive, Sign::Positive) => self.mag.cmp(&other.mag),
            (Sign::Negative, Sign::Negative) => other.mag.cmp(&self.mag),
        }
    }
}

impl PartialOrd for BigInt {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl PartialEq for BigInt {
    fn eq(&self, other: &Self) -> bool {
        self.cmp(other) == Ordering::Equal
    }
}

impl Eq for BigInt {}

/// Equal signs add magnitudes, opposite signs subtract the smaller magnitude
/// from the larger and keep the sign of the larger.
impl Add for BigInt {
    type Output = BigInt;

    fn add(self, rhs: BigInt) -> BigInt {
        if self.sign == rhs.sign {
            BigInt::make(self.sign, &self.mag + &rhs.mag)
        } else {
            match self.mag.cmp(&rhs.mag) {
                Ordering::Equal => BigInt::zero(),
                Ordering::Greater => BigInt::make(self.sign, &self.mag - &rhs.mag),
                Ordering::Less => BigInt::make(rhs.sign, &rhs.mag - &self.mag),
            }
        }
    }
}

/// Subtraction is addition of the negation.
impl Sub for BigInt {
    type Output = BigInt;

    fn sub(self, rhs: BigInt) -> BigInt {
        self + (-rhs)
    }
}

/// Negation flips the flag, zero stays positive.
impl Neg for BigInt {
    type Output = BigInt;

    fn neg(self) -> BigInt {
        BigInt::make(self.sign.flip(), self.mag)
    }
}

/// Magnitudes multiply, signs combine: equal signs give plus, opposite give minus.
impl Mul for BigInt {
    type Output = BigInt;

    fn mul(self, rhs: BigInt) -> BigInt {
        BigInt::make(
            if self.sign == rhs.sign {
                Sign::Positive
            } else {
                Sign::Negative
            },
            &self.mag * &rhs.mag,
        )
    }
}

/// Minus for negatives, then the decimal magnitude.
impl fmt::Display for BigInt {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        if self.sign == Sign::Negative {
            f.write_str("-")?;
        }
        f.write_str(&self.mag.to_decimal_string())
    }
}

/// `n!` by repeated multiplication, the classic value that outgrows the
/// built-in widths: `100!` needs 158 decimal digits.
pub fn factorial(n: u32) -> BigInt {
    let mut acc = BigInt::from_u64(1);
    for k in 2..=n {
        acc = acc * BigInt::from_u64(k as u64);
    }
    acc
}

/// The `n`-th Fibonacci number with `F_1 = F_2 = 1`, by iteration on the pair
/// `(F_{k-1}, F_k)`: a thousand steps already produce 209 decimal digits.
pub fn fibonacci(n: u32) -> BigInt {
    let mut a = BigInt::zero();
    let mut b = BigInt::from_u64(1);
    for _ in 0..n {
        let next = a + b.clone();
        a = b;
        b = next;
    }
    a
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::magnitude::BASE;
    use crate::rng::SplitMix64;

    fn sample(rng: &mut SplitMix64, max_limbs: u32) -> BigInt {
        let count = 1 + rng.below(max_limbs as u64) as usize;
        let limbs: Vec<u32> = (0..count).map(|_| rng.next_u64() as u32).collect();
        let sign = if rng.below(2) == 0 {
            Sign::Positive
        } else {
            Sign::Negative
        };
        BigInt::from_parts(sign, Magnitude::from_limbs(limbs))
    }

    fn sample_i64(rng: &mut SplitMix64) -> i64 {
        let raw = (rng.next_u64() >> 1) as i64;
        if rng.below(2) == 0 {
            raw
        } else {
            -raw
        }
    }

    fn assert_canonical(value: &BigInt) {
        let limbs = value.magnitude().limbs();
        assert!(!limbs.is_empty(), "limb array never empty");
        assert!(limbs.len() == 1 || *limbs.last().expect("checked nonempty") != 0);
        if value.is_zero() {
            assert_eq!(value.sign(), Sign::Positive);
            assert_eq!(limbs, &[0]);
        }
    }

    #[test]
    fn zero_is_positive_and_canonical() {
        assert_eq!(BigInt::zero().sign(), Sign::Positive);
        assert_eq!(BigInt::from_i64(0).sign(), Sign::Positive);
        assert_eq!(BigInt::from_i64(0).magnitude().limbs(), &[0]);
        let five = BigInt::from_i64(5);
        let sum = five.clone() + (-five);
        assert!(sum.is_zero());
        assert_eq!(sum.sign(), Sign::Positive);
        assert_eq!(
            BigInt::from_parts(Sign::Negative, Magnitude::zero()).sign(),
            Sign::Positive
        );
    }

    #[test]
    fn signed_addition_matches_i128() {
        let mut rng = SplitMix64::new(29);
        for _ in 0..400 {
            let (x, y) = (sample_i64(&mut rng), sample_i64(&mut rng));
            let (bx, by) = (BigInt::from_i64(x), BigInt::from_i64(y));
            let sum = bx + by;
            assert_canonical(&sum);
            assert_eq!(sum.to_i128(), Some(x as i128 + y as i128));
        }
    }

    #[test]
    fn subtraction_goes_through_sign_of_difference() {
        let mut rng = SplitMix64::new(31);
        for _ in 0..400 {
            let (x, y) = (sample_i64(&mut rng), sample_i64(&mut rng));
            let diff = BigInt::from_i64(x) - BigInt::from_i64(y);
            assert_canonical(&diff);
            assert_eq!(diff.to_i128(), Some(x as i128 - y as i128));
        }
        let min = BigInt::from_i64(i64::MIN);
        let max = BigInt::from_i64(i64::MAX);
        assert_eq!(
            (min.clone() - max.clone()).to_string(),
            "-18446744073709551615"
        );
        assert_eq!((max - min).to_string(), "18446744073709551615");
    }

    #[test]
    fn multiplication_follows_sign_parity() {
        let mut rng = SplitMix64::new(37);
        for _ in 0..400 {
            let (x, y) = (sample_i64(&mut rng), sample_i64(&mut rng));
            let product = BigInt::from_i64(x) * BigInt::from_i64(y);
            assert_canonical(&product);
            assert_eq!(product.to_i128(), Some(x as i128 * y as i128));
        }
        assert_eq!(
            (BigInt::from_i64(-3) * BigInt::from_u64(0)).sign(),
            Sign::Positive
        );
    }

    #[test]
    fn ordering_matches_i128() {
        let mut rng = SplitMix64::new(41);
        for _ in 0..400 {
            let (x, y) = (sample_i64(&mut rng), sample_i64(&mut rng));
            assert_eq!(BigInt::from_i64(x).cmp(&BigInt::from_i64(y)), x.cmp(&y));
        }
        assert!(BigInt::from_i64(-1) < BigInt::zero());
        assert!(BigInt::from_i64(i64::MIN) < BigInt::from_i64(i64::MAX));
    }

    #[test]
    fn to_i128_round_trips_boundaries() {
        for value in [0i64, 1, -1, i64::MAX, i64::MIN] {
            assert_eq!(BigInt::from_i64(value).to_i128(), Some(value as i128));
        }
        assert_eq!(BigInt::from_u64(u64::MAX).to_i128(), Some(u64::MAX as i128));
        let wide = Magnitude::from_limbs(vec![u32::MAX, u32::MAX, u32::MAX, u32::MAX, 128]);
        assert_eq!(BigInt::from_parts(Sign::Positive, wide).to_i128(), None);
    }

    #[test]
    fn display_prints_minus_and_digits() {
        assert_eq!(
            BigInt::from_i64(i64::MIN).to_string(),
            "-9223372036854775808"
        );
        assert_eq!(BigInt::from_i64(-7).to_string(), "-7");
        assert_eq!(BigInt::zero().to_string(), "0");
        assert_eq!(BigInt::from_u64(BASE).to_string(), "4294967296");
    }

    #[test]
    fn ring_properties_hold_on_random_triples() {
        let mut rng = SplitMix64::new(43);
        for _ in 0..256 {
            let (a, b, c) = (
                sample(&mut rng, 4),
                sample(&mut rng, 4),
                sample(&mut rng, 4),
            );
            assert_eq!(
                a.clone() + b.clone(),
                b.clone() + a.clone(),
                "commutativity"
            );
            assert_eq!(
                (a.clone() + b.clone()) + c.clone(),
                a.clone() + (b.clone() + c.clone()),
                "associativity"
            );
            let product = a.clone() * (b.clone() + c.clone());
            let expanded = a.clone() * b.clone() + a.clone() * c.clone();
            assert_eq!(product, expanded, "distributivity");
            assert_canonical(&expanded);
        }
    }

    #[test]
    fn order_is_consistent_with_addition() {
        let mut rng = SplitMix64::new(47);
        for _ in 0..256 {
            let (a, b, c) = (
                sample(&mut rng, 3),
                sample(&mut rng, 3),
                sample(&mut rng, 3),
            );
            let direct = a.cmp(&b);
            let shifted = (a.clone() + c.clone()).cmp(&(b.clone() + c.clone()));
            assert_eq!(direct, shifted, "adding c preserves and reflects the order");
        }
    }

    #[test]
    fn cross_check_with_u64_builtins() {
        let mut rng = SplitMix64::new(53);
        for _ in 0..300 {
            let a = rng.next_u64();
            let b = rng.next_u64();
            let (ba, bb) = (BigInt::from_u64(a), BigInt::from_u64(b));
            assert_eq!(
                (ba.clone() + bb.clone()).to_i128(),
                Some(a as i128 + b as i128)
            );
            assert_eq!(
                (ba.clone() - bb.clone()).to_i128(),
                Some(a as i128 - b as i128)
            );
            let wide = a as u128 * b as u128;
            let expected = i128::try_from(wide).ok();
            assert_eq!((ba.clone() * bb.clone()).to_i128(), expected);
            assert_eq!(ba.cmp(&bb), a.cmp(&b));
            assert_canonical(&(ba - bb));
        }
    }

    #[test]
    fn factorial_record_beyond_64_bits() {
        let record = factorial(100);
        let text = record.to_string();
        assert_eq!(
            text,
            "9332621544394415268169923885626670049071596826438162146859296389521759999322991\
             5608941463976156518286253697920827223758251185210916864000000000000000000000000"
        );
        assert_eq!(text.len(), 158);
        let trailing = text.len() - text.trim_end_matches('0').len();
        assert_eq!(
            trailing, 24,
            "100! ends in exactly 24 zeros: 20 fives plus 4 twenty-fives"
        );
        assert_eq!(factorial(0).to_string(), "1");
        assert_eq!(factorial(1).to_string(), "1");
        assert_eq!(factorial(10).to_string(), "3628800");
    }

    #[test]
    fn fibonacci_records_and_divisibility() {
        assert_eq!(fibonacci(10).to_string(), "55");
        assert_eq!(fibonacci(100).to_string(), "354224848179261915075");
        assert_eq!(
            fibonacci(200).to_string(),
            "280571172992510140037611932413038677189525"
        );
        let thousand = fibonacci(1000);
        assert_eq!(thousand.to_string().len(), 209);
        assert_eq!(
            thousand.to_string(),
            "4346655768693745643568852767504062580256466051737178040248172908953655541794905\
             1890403879840079255169295922593080322634775209689623239873322471161642996440906\
             533187938298969649928516003704476137795166849228875"
        );
        let (q300, r300) = fibonacci(300)
            .magnitude()
            .divmod(fibonacci(100).magnitude());
        assert!(r300.is_zero(), "F_300 is divisible by F_100");
        assert_eq!(
            q300.to_string(),
            "627376215338105766356982006981782561278128"
        );
        let (q1000, r1000) = fibonacci(1000)
            .magnitude()
            .divmod(fibonacci(500).magnitude());
        assert!(r1000.is_zero(), "F_1000 is divisible by F_500");
        assert_eq!(q1000.to_string().len(), 105);
    }
}

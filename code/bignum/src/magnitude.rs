//! Nonnegative integers as limbs of base `2^32`, least significant first.
//!
//! This layer knows nothing about signs: it carries, borrows, compares,
//! multiplies, divides and prints. The signed layer in [`crate::integer`]
//! adds a sign flag and reduces every case to work done here.
//!
//! ```
//! use bignum::Magnitude;
//!
//! let product = &Magnitude::from_u64(u64::MAX) * &Magnitude::from_u64(3);
//! assert_eq!(product.to_string(), "55340232221128654845");
//! ```

use std::cmp::Ordering;
use std::fmt;
use std::ops::{Add, Mul, Sub};

/// Bit width of one stored limb.
pub const BASE_BITS: u32 = 32;

/// The limb base: one stored limb counts `2^32`.
pub const BASE: u64 = 1 << BASE_BITS;

/// Nine decimal digits fit one group of the decimal conversion.
const DECIMAL_GROUP: u64 = 1_000_000_000;

/// A nonnegative integer stored as limbs of base `BASE`, least significant first.
///
/// Two invariants hold at every observable moment: the limb array is never
/// empty, and its most significant limb is nonzero unless the value is zero,
/// which is stored as the single limb `[0]`.
/// Every constructor and every operation restores these invariants through
/// [`Magnitude::from_limbs`].
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Magnitude {
    limbs: Vec<u32>,
}

impl Magnitude {
    /// The limb at `index`, or zero past the end: operands align at the low end.
    fn limb(&self, index: usize) -> u64 {
        self.limbs.get(index).copied().unwrap_or(0) as u64
    }

    /// The single zero limb.
    pub fn zero() -> Self {
        Magnitude { limbs: vec![0] }
    }

    /// The limbs of a `u64`, least significant first.
    pub fn from_u64(value: u64) -> Self {
        Magnitude::from_limbs(vec![value as u32, (value >> BASE_BITS) as u32])
    }

    /// The limbs of a `u128`, least significant first.
    pub fn from_u128(value: u128) -> Self {
        Magnitude::from_limbs(vec![
            value as u32,
            (value >> 32) as u32,
            (value >> 64) as u32,
            (value >> 96) as u32,
        ])
    }

    /// Builds from raw limbs, dropping leading zeros, so empty input becomes zero.
    ///
    /// ```
    /// use bignum::Magnitude;
    ///
    /// assert_eq!(Magnitude::from_limbs(vec![7, 0, 0]).limbs(), &[7]);
    /// assert_eq!(Magnitude::from_limbs(vec![]).limbs(), &[0]);
    /// ```
    pub fn from_limbs(mut limbs: Vec<u32>) -> Self {
        while limbs.len() > 1 && limbs.last() == Some(&0) {
            limbs.pop();
        }
        if limbs.is_empty() {
            limbs.push(0);
        }
        Magnitude { limbs }
    }

    /// The stored limbs, least significant first, with no leading zeros.
    pub fn limbs(&self) -> &[u32] {
        &self.limbs
    }

    /// True exactly for the canonical zero.
    pub fn is_zero(&self) -> bool {
        self.limbs.len() == 1 && self.limbs[0] == 0
    }

    /// Count of significant bits: zero has none, `2^64 - 1` has 64.
    pub fn bit_len(&self) -> usize {
        let Some(&top) = self.limbs.last() else {
            return 0;
        };
        (self.limbs.len() - 1) * BASE_BITS as usize + (BASE_BITS - top.leading_zeros()) as usize
    }

    /// The value as `u128` when four limbs suffice.
    pub fn to_u128(&self) -> Option<u128> {
        if self.limbs.len() > 4 {
            return None;
        }
        let mut value = 0u128;
        for (k, &limb) in self.limbs.iter().enumerate() {
            value |= (limb as u128) << (32 * k);
        }
        Some(value)
    }

    /// The bit at `index`, counting from the least significant end.
    fn bit(&self, index: usize) -> u32 {
        (self.limbs[index >> 5] >> (index & 31)) & 1
    }

    /// The value times two, plus `bit` in the lowest position.
    fn shl1_or(&self, bit: u32) -> Self {
        let mut out = vec![0u32; self.limbs.len() + 1];
        for (k, &limb) in self.limbs.iter().enumerate() {
            out[k] |= limb << 1;
            out[k + 1] |= limb >> 31;
        }
        out[0] |= bit & 1;
        Magnitude::from_limbs(out)
    }

    /// Quotient and remainder for a nonzero divisor, by shift-subtract from
    /// the most significant bit.
    ///
    /// Each step doubles the running remainder, pulls down the next bit of
    /// the dividend, and subtracts the divisor whenever it fits.
    /// The cost is `O(bit_len * limbs)` word operations.
    ///
    /// # Panics
    ///
    /// Panics when the divisor is zero.
    pub fn divmod(&self, divisor: &Magnitude) -> (Magnitude, Magnitude) {
        assert!(!divisor.is_zero(), "division by zero");
        if self < divisor {
            return (Magnitude::zero(), self.clone());
        }
        let mut quotient = vec![0u32; self.limbs.len()];
        let mut rem = Magnitude::zero();
        for i in (0..self.bit_len()).rev() {
            rem = rem.shl1_or(self.bit(i));
            if &rem >= divisor {
                rem = &rem - divisor;
                quotient[i >> 5] |= 1 << (i & 31);
            }
        }
        (Magnitude::from_limbs(quotient), rem)
    }

    /// Decimal digits, most significant first, nine digits per division.
    ///
    /// Each pass divides by `10^9` and peels off one group of nine digits,
    /// printed as an unpadded head followed by zero-padded groups.
    pub fn to_decimal_string(&self) -> String {
        if self.is_zero() {
            return String::from("0");
        }
        let group = Magnitude::from_u64(DECIMAL_GROUP);
        let mut groups: Vec<u32> = Vec::new();
        let mut current = self.clone();
        while !current.is_zero() {
            let (q, r) = current.divmod(&group);
            groups.push(r.limbs[0]);
            current = q;
        }
        let mut text = groups
            .pop()
            .expect("a nonzero value has at least one group")
            .to_string();
        while let Some(group) = groups.pop() {
            text.push_str(&format!("{group:09}"));
        }
        text
    }
}

/// Digit-wise comparison from the most significant limb.
///
/// The implementation is manual on purpose: a derived `Ord` on `Vec<u32>`
/// would compare the least significant limbs first and get the answer
/// backwards, calling $1 > 2$ on `[1]` and `[0, 1]`.
/// Without leading zeros the array length alone orders values of different
/// widths, then equal-width values compare from the top limb down.
impl Ord for Magnitude {
    fn cmp(&self, other: &Self) -> Ordering {
        match self.limbs.len().cmp(&other.limbs.len()) {
            Ordering::Equal => {}
            order => return order,
        }
        for (a, b) in self.limbs.iter().zip(&other.limbs).rev() {
            match a.cmp(b) {
                Ordering::Equal => {}
                order => return order,
            }
        }
        Ordering::Equal
    }
}

impl PartialOrd for Magnitude {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

/// Schoolbook addition: digits align at the low end, the carry ripples upward.
///
/// A limb plus a limb plus a carry fits a `u64`: the low 32 bits stay in
/// place, the rest moves one limb up.
impl Add<&Magnitude> for &Magnitude {
    type Output = Magnitude;

    fn add(self, rhs: &Magnitude) -> Magnitude {
        let width = self.limbs.len().max(rhs.limbs.len());
        let mut out = Vec::with_capacity(width + 1);
        let mut carry = 0u64;
        for k in 0..width {
            let sum = self.limb(k) + rhs.limb(k) + carry;
            out.push(sum as u32);
            carry = sum >> BASE_BITS;
        }
        if carry > 0 {
            out.push(carry as u32);
        }
        Magnitude { limbs: out }
    }
}

/// Schoolbook subtraction with borrow, defined only for `self >= rhs`:
/// a limb that would go negative borrows one from the next limb up.
///
/// # Panics
///
/// Panics when `self < rhs`, so the layer stays free of negative values.
impl Sub<&Magnitude> for &Magnitude {
    type Output = Magnitude;

    fn sub(self, rhs: &Magnitude) -> Magnitude {
        assert!(self >= rhs, "magnitude subtraction requires a >= b");
        let mut out = Vec::with_capacity(self.limbs.len());
        let mut borrow = 0i64;
        for k in 0..self.limbs.len() {
            let diff = self.limb(k) as i64 - rhs.limb(k) as i64 - borrow;
            if diff < 0 {
                out.push((diff + BASE as i64) as u32);
                borrow = 1;
            } else {
                out.push(diff as u32);
                borrow = 0;
            }
        }
        debug_assert_eq!(borrow, 0, "self >= rhs leaves no trailing borrow");
        Magnitude::from_limbs(out)
    }
}

/// Schoolbook multiplication in `O(n * m)`: every limb pair contributes one
/// double-width product, and the carry of each row normalizes the array in
/// the same pass.
///
/// The bounds make a bare `u64` cell safe: a cell `out[i + j]` below `2^32`,
/// a limb product below `2^64` and a carry below `2^32` sum to at most
/// `2^64 - 1`, so no intermediate ever overflows.
impl Mul<&Magnitude> for &Magnitude {
    type Output = Magnitude;

    fn mul(self, rhs: &Magnitude) -> Magnitude {
        if self.is_zero() || rhs.is_zero() {
            return Magnitude::zero();
        }
        let mut out = vec![0u32; self.limbs.len() + rhs.limbs.len()];
        for (i, &a) in self.limbs.iter().enumerate() {
            let mut carry = 0u64;
            for (j, &b) in rhs.limbs.iter().enumerate() {
                let cell = out[i + j] as u64 + a as u64 * b as u64 + carry;
                out[i + j] = cell as u32;
                carry = cell >> BASE_BITS;
            }
            let mut k = i + rhs.limbs.len();
            while carry > 0 {
                let cell = out[k] as u64 + carry;
                out[k] = cell as u32;
                carry = cell >> BASE_BITS;
                k += 1;
            }
        }
        Magnitude::from_limbs(out)
    }
}

impl fmt::Display for Magnitude {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(&self.to_decimal_string())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::rng::SplitMix64;

    fn mag(value: u128) -> Magnitude {
        Magnitude::from_u128(value)
    }

    fn random_limbs(rng: &mut SplitMix64, max_limbs: u32) -> Vec<u32> {
        let count = 1 + rng.below(max_limbs as u64) as usize;
        (0..count).map(|_| rng.next_u64() as u32).collect()
    }

    #[test]
    fn digits_stay_canonical() {
        assert_eq!(Magnitude::from_limbs(vec![7, 0, 0]).limbs(), &[7]);
        assert_eq!(Magnitude::from_limbs(vec![]).limbs(), &[0]);
        assert_eq!(Magnitude::from_limbs(vec![0]).limbs(), &[0]);
        assert_eq!(Magnitude::from_u64(1).limbs(), &[1]);
        assert_eq!(Magnitude::from_u64(u64::MAX).limbs(), &[u32::MAX, u32::MAX]);
        assert!(Magnitude::zero().is_zero());
        assert_eq!(Magnitude::from_u64(0).limbs(), &[0]);
        assert_eq!(mag(1).bit_len(), 1);
        assert_eq!(Magnitude::from_u64(u64::MAX).bit_len(), 64);
        assert_eq!(Magnitude::zero().bit_len(), 0);
    }

    #[test]
    fn u128_round_trips() {
        let mut rng = SplitMix64::new(7);
        for _ in 0..200 {
            let halves: Vec<u64> = (0..2).map(|_| rng.next_u64()).collect();
            let value = ((halves[0] as u128) << 64) | halves[1] as u128;
            assert_eq!(mag(value).to_u128(), Some(value));
        }
        assert_eq!(mag(u128::MAX).to_u128(), Some(u128::MAX));
        assert_eq!(mag(u128::MAX).limbs(), &[u32::MAX; 4]);
    }

    #[test]
    fn addition_ripples_the_carry() {
        assert_eq!((&mag(BASE as u128 - 1) + &mag(1)).limbs(), &[0, 1]);
        assert_eq!(
            (&mag(u64::MAX as u128) + &mag(1)).to_u128(),
            Some(1u128 << 64)
        );
        assert_eq!((&mag(2) + &mag(3)).to_u128(), Some(5));
        let mut rng = SplitMix64::new(11);
        for _ in 0..200 {
            let halves: Vec<u64> = (0..4).map(|_| rng.next_u64()).collect();
            let a = ((halves[0] as u128) << 64) | halves[1] as u128;
            let b = ((halves[2] as u128) << 64) | halves[3] as u128;
            assert_eq!((&mag(a) + &mag(b)).to_u128(), a.checked_add(b));
        }
    }

    #[test]
    fn comparison_reads_most_significant_limbs_first() {
        assert_eq!(mag(5).cmp(&mag(7)), Ordering::Less);
        assert_eq!(mag(7).cmp(&mag(5)), Ordering::Greater);
        assert_eq!(mag(123).cmp(&mag(123)), Ordering::Equal);
        assert!(mag(1u128 << 64) > mag(u64::MAX as u128));
        assert_eq!(Magnitude::from_limbs(vec![3, 0]), mag(3));
        let mut rng = SplitMix64::new(13);
        for _ in 0..200 {
            let a = random_limbs(&mut rng, 4);
            let b = random_limbs(&mut rng, 4);
            let (va, vb) = (
                Magnitude::from_limbs(a.clone()).to_u128(),
                Magnitude::from_limbs(b.clone()).to_u128(),
            );
            assert_eq!(
                Magnitude::from_limbs(a).cmp(&Magnitude::from_limbs(b)),
                va.cmp(&vb)
            );
        }
    }

    #[test]
    fn subtraction_borrows_limb_by_limb() {
        assert_eq!(
            (&mag(1u128 << 32) - &mag(1)).to_u128(),
            Some(u32::MAX as u128)
        );
        assert_eq!(
            (&mag(1u128 << 64) - &mag(1)).to_u128(),
            Some(u64::MAX as u128)
        );
        assert_eq!((&mag(9) - &mag(9)).limbs(), &[0]);
        assert_eq!((&mag(BASE as u128) - &mag(0)).to_u128(), Some(BASE as u128));
        assert!((&mag(3) - &mag(3)).is_zero());
    }

    #[test]
    #[should_panic(expected = "magnitude subtraction requires a >= b")]
    fn subtraction_rejects_smaller_minuend() {
        let _ = &mag(3) - &mag(5);
    }

    #[test]
    fn multiplication_matches_u128() {
        assert_eq!((&mag(0) * &mag(u128::MAX)).limbs(), &[0]);
        let square = &mag(1u128 << 64) * &mag(1u128 << 64);
        assert_eq!(square.to_u128(), None);
        assert_eq!(square.limbs(), &[0, 0, 0, 0, 1]);
        let mut rng = SplitMix64::new(17);
        for _ in 0..300 {
            let a = rng.next_u64() as u128;
            let b = rng.next_u64() as u128;
            let expected = a.checked_mul(b).expect("64-bit factors fit 128 bits");
            assert_eq!((&mag(a) * &mag(b)).to_u128(), Some(expected));
        }
        let wide_a = Magnitude::from_limbs(vec![u32::MAX, u32::MAX, 5]);
        let wide_b = Magnitude::from_limbs(vec![3, 0, 7]);
        let product = &wide_a * &wide_b;
        assert_eq!(product.limbs().len(), 5);
        assert_eq!(product.limbs()[4], 42);
        assert_eq!(product.limbs()[0], (u32::MAX as u64 * 3 % BASE) as u32);
    }

    #[test]
    fn divmod_matches_u128() {
        assert_eq!(mag(5).divmod(&mag(9)), (Magnitude::zero(), mag(5)));
        assert_eq!(mag(40).divmod(&mag(5)), (mag(8), Magnitude::zero()));
        let mut rng = SplitMix64::new(19);
        for _ in 0..200 {
            let halves: Vec<u64> = (0..4).map(|_| rng.next_u64()).collect();
            let dividend = ((halves[0] as u128) << 64) | halves[1] as u128;
            let divisor = halves[2] | 1;
            let (q, r) = mag(dividend).divmod(&mag(divisor as u128));
            assert_eq!(q.to_u128(), Some(dividend / divisor as u128));
            assert_eq!(r.to_u128(), Some(dividend % divisor as u128));
        }
    }

    #[test]
    #[should_panic(expected = "division by zero")]
    fn divmod_rejects_zero_divisor() {
        let _ = mag(1).divmod(&Magnitude::zero());
    }

    #[test]
    fn decimal_strings_are_padded_and_ordered() {
        assert_eq!(Magnitude::zero().to_decimal_string(), "0");
        assert_eq!(mag(1_000_000_001).to_decimal_string(), "1000000001");
        assert_eq!(
            mag(u64::MAX as u128).to_decimal_string(),
            "18446744073709551615"
        );
        let two_pow_127 = format!("{}", 1u128 << 127);
        assert_eq!(mag(1u128 << 127).to_decimal_string(), two_pow_127);
        assert_eq!(Magnitude::from_u64(42).to_string(), "42");
    }

    #[test]
    fn decimal_string_length_matches_u128_display() {
        let mut rng = SplitMix64::new(23);
        for _ in 0..100 {
            let halves: Vec<u64> = (0..2).map(|_| rng.next_u64()).collect();
            let value = ((halves[0] as u128) << 64) | halves[1] as u128;
            assert_eq!(mag(value).to_decimal_string(), format!("{value}"));
        }
    }
}

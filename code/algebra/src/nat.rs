//! Peano natural numbers.
//!
//! `Zero` and `Succ` are the only constructors.
//! Addition and multiplication are written as recursion over those
//! constructors, with no `u32` arithmetic.
//! This is the slow, obvious definition, kept to show what an operation is
//! before any built-in number type enters the picture.

use crate::traits::{Monoid, Semigroup};

/// A natural number: zero, or the successor of another natural number.
#[derive(Clone, PartialEq, Eq, Debug)]
pub enum Nat {
    /// Zero.
    Zero,
    /// The successor of a natural number.
    Succ(Box<Nat>),
}

impl Nat {
    /// Convert a `u32` into a `Nat` (the only place machine integers appear).
    pub fn from_u32(n: u32) -> Nat {
        let mut out = Nat::Zero;
        for _ in 0..n {
            out = Nat::Succ(Box::new(out));
        }
        out
    }

    /// Convert back to a `u32` (recursion depth is the value itself).
    pub fn to_u32(&self) -> u32 {
        match self {
            Nat::Zero => 0,
            Nat::Succ(n) => 1 + n.to_u32(),
        }
    }

    /// Addition by recursion: `a + Succ(b) == Succ(a + b)`.
    pub fn add(&self, other: &Nat) -> Nat {
        match other {
            Nat::Zero => self.clone(),
            Nat::Succ(m) => Nat::Succ(Box::new(self.add(m))),
        }
    }

    /// Multiplication by recursion: `a * Succ(b) == a * b + a`.
    pub fn mul(&self, other: &Nat) -> Nat {
        match other {
            Nat::Zero => Nat::Zero,
            Nat::Succ(m) => self.mul(m).add(self),
        }
    }
}

// Under addition the naturals are a monoid: identity is zero, and there is
// no inverse (no negative naturals), so this is a monoid and not a group.
impl Semigroup for Nat {
    fn op(&self, other: &Self) -> Self {
        self.add(other)
    }
}

impl Monoid for Nat {
    fn identity() -> Self {
        Nat::Zero
    }
}

#[cfg(test)]
mod tests {
    use super::Nat;
    use crate::traits::{Monoid, Semigroup};

    #[test]
    fn peano_adds_and_multiplies() {
        let three = Nat::from_u32(3);
        let four = Nat::from_u32(4);
        assert_eq!(three.add(&four).to_u32(), 7);
        assert_eq!(three.mul(&four).to_u32(), 12);
    }

    #[test]
    fn zero_is_the_additive_identity() {
        let five = Nat::from_u32(5);
        assert_eq!(Nat::identity().op(&five).to_u32(), 5);
    }

    #[test]
    fn roundtrips_through_u32() {
        for n in 0..20 {
            assert_eq!(Nat::from_u32(n).to_u32(), n);
        }
    }
}

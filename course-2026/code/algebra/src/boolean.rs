//! The two-element field `GF(2)`: booleans with XOR and AND.

use crate::traits::{Field, Group, Monoid, Ring, Semigroup};

/// `false` and `true`, with XOR as addition and AND as multiplication.
///
/// This is the smallest field: every nonzero element (just `true`) is its
/// own additive and multiplicative inverse.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub struct Bool(pub bool);

impl Semigroup for Bool {
    fn op(&self, other: &Self) -> Self {
        Bool(self.0 ^ other.0)
    }
}

impl Monoid for Bool {
    fn identity() -> Self {
        Bool(false)
    }
}

impl Group for Bool {
    fn inverse(&self) -> Self {
        // In GF(2) every element is its own additive inverse: a + a = 0.
        *self
    }
}

impl Ring for Bool {
    fn add(&self, other: &Self) -> Self {
        Bool(self.0 ^ other.0)
    }
    fn mul(&self, other: &Self) -> Self {
        Bool(self.0 & other.0)
    }
    fn zero() -> Self {
        Bool(false)
    }
    fn one() -> Self {
        Bool(true)
    }
    fn neg(&self) -> Self {
        *self
    }
}

impl Field for Bool {
    fn inv(&self) -> Option<Self> {
        if self.0 {
            Some(Bool(true))
        } else {
            None
        }
    }
}

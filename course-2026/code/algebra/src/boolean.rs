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

#[cfg(test)]
mod tests {
    use super::Bool;
    use crate::traits::{Field, Group, Ring, Semigroup};

    #[test]
    fn xor_is_add_and_self_inverse() {
        let t = Bool(true);
        assert_eq!(t.op(&t), Bool(false));
        assert_eq!(t.inverse(), Bool(true));
    }

    #[test]
    fn true_is_invertible_false_is_not() {
        assert_eq!(Bool(true).inv(), Some(Bool(true)));
        assert_eq!(Bool(false).inv(), None);
    }

    #[test]
    fn distributivity_holds() {
        let (a, b, c) = (Bool(true), Bool(false), Bool(true));
        assert_eq!(a.mul(&b.add(&c)), a.mul(&b).add(&a.mul(&c)));
    }
}

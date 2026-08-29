//! Residue classes and their units.

use crate::arithmetic::{gcd, mod_inverse};
use crate::traits::{Group, Monoid, Ring, Semigroup};

/// A residue modulo `N`, the integers `0..N` with arithmetic taken mod `N`.
///
/// `Zn<N>` is an additive group under `op` (addition mod `N`) and, with
/// multiplication added, a ring. `N` must be at least 2.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub struct Zn<const N: u32>(pub u32);

impl<const N: u32> Zn<N> {
    /// The residue of `v` modulo `N`.
    pub fn new(v: u32) -> Self {
        Zn(v % N)
    }
}

impl<const N: u32> Semigroup for Zn<N> {
    fn op(&self, other: &Self) -> Self {
        Zn::new(self.0 + other.0)
    }
}

impl<const N: u32> Monoid for Zn<N> {
    fn identity() -> Self {
        Zn(0)
    }
}

impl<const N: u32> Group for Zn<N> {
    fn inverse(&self) -> Self {
        Zn((N - self.0) % N)
    }
}

impl<const N: u32> Ring for Zn<N> {
    fn add(&self, other: &Self) -> Self {
        Zn::new(self.0 + other.0)
    }
    fn mul(&self, other: &Self) -> Self {
        Zn::new(self.0 * other.0)
    }
    fn zero() -> Self {
        Zn(0)
    }
    fn one() -> Self {
        Zn(1 % N)
    }
    fn neg(&self) -> Self {
        Zn((N - self.0) % N)
    }
}

/// An invertible residue mod `N`, a unit of the ring `Zn<N>`.
///
/// Under multiplication these residues form the group `Z_N^*`: exactly the
/// elements coprime to `N`. `new` rejects non-units, so a `Unit` obtained
/// through `new` always has an inverse (found by the hand-rolled
/// [`mod_inverse`]).
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub struct Unit<const N: u32>(pub u32);

impl<const N: u32> Unit<N> {
    /// The unit represented by `v`, if `v` is coprime to `N`.
    pub fn new(v: u32) -> Option<Self> {
        let r = v % N;
        if gcd(r as i64, N as i64) == 1 {
            Some(Unit(r))
        } else {
            None
        }
    }
}

impl<const N: u32> Semigroup for Unit<N> {
    fn op(&self, other: &Self) -> Self {
        Unit((self.0 * other.0) % N)
    }
}

impl<const N: u32> Monoid for Unit<N> {
    fn identity() -> Self {
        Unit(1 % N)
    }
}

impl<const N: u32> Group for Unit<N> {
    fn inverse(&self) -> Self {
        Unit(mod_inverse(self.0 as i64, N as i64).expect("unit is coprime to N") as u32)
    }
}

#[cfg(test)]
mod tests {
    use super::{Unit, Zn};
    use crate::traits::{Group, Monoid, Semigroup};

    #[test]
    fn additive_group_laws() {
        let a = Zn::<7>::new(3);
        let b = Zn::<7>::new(6);
        assert_eq!(a.op(&b), Zn::new(2)); // 3 + 6 = 9 = 2 mod 7
        assert_eq!(a.op(&a.inverse()), Zn::<7>::identity());
    }

    #[test]
    fn unit_inverses_multiply_to_one() {
        let units: Vec<Unit<8>> = (1..8).filter_map(Unit::<8>::new).collect();
        assert_eq!(units.len(), 4); // the units of Z_8 are {1, 3, 5, 7}
        for u in units {
            assert_eq!(u.op(&u.inverse()).0, 1);
        }
    }
}

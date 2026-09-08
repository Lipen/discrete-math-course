//! The algebraic hierarchy: semigroup, monoid, group, ring, field.

/// A set with an associative binary operation.
///
/// The operation is written `a.op(b)`. Associativity -- `(a op b) op c ==
/// a op (b op c)` -- is a law the implementor promises, not something Rust
/// checks. Every implementor is a small closed set whose `op` never leaves
/// the type.
pub trait Semigroup: Clone + PartialEq {
    /// The binary operation.
    fn op(&self, other: &Self) -> Self;
}

/// A semigroup with a neutral element.
pub trait Monoid: Semigroup {
    /// The neutral element: `identity().op(a) == a.op(&identity()) == a`.
    fn identity() -> Self;
}

/// A monoid where every element has an inverse.
pub trait Group: Monoid {
    /// The inverse of `self`: `self.op(&self.inverse()) == Self::identity()`.
    fn inverse(&self) -> Self;
}

/// A ring: an additive group plus an associative multiplication with a unit,
/// linked by distributivity.
pub trait Ring: Clone + PartialEq {
    /// Addition, the additive group operation.
    fn add(&self, other: &Self) -> Self;
    /// Multiplication, associative and distributive over addition.
    fn mul(&self, other: &Self) -> Self;
    /// Additive identity.
    fn zero() -> Self;
    /// Multiplicative identity.
    fn one() -> Self;
    /// Additive inverse: `self.add(&self.neg()) == Self::zero()`.
    fn neg(&self) -> Self;
}

/// A ring where every nonzero element has a multiplicative inverse.
pub trait Field: Ring {
    /// Multiplicative inverse of a nonzero element, `None` for zero.
    fn inv(&self) -> Option<Self>;
}

//! The dihedral group D_4: the symmetries of the square.
//!
//! The eight symmetries are the four rotations and the four reflections.
//! With `r` the quarter-turn and `s` a reflection, the group is
//! `{e, r, r², r³, s, rs, r²s, r³s}` subject to `r⁴ = e`, `s² = e`, and
//! `s r = r³ s`. The rotations alone form the cyclic subgroup C_4.

use crate::traits::{Group, Monoid, Semigroup};

/// A symmetry of the square: `r^k` (a rotation) or `r^k s` (a rotation after
/// a reflection).
#[derive(Clone, Copy, PartialEq, Eq, Hash, Debug)]
pub struct D4 {
    /// Rotation exponent, in `0..4`.
    k: u8,
    /// Whether the reflection `s` is applied.
    s: bool,
}

impl D4 {
    /// The quarter-turn `r`.
    pub fn r() -> Self {
        Self::rotation(1)
    }

    /// The reflection `s`.
    pub fn s() -> Self {
        Self::reflection(0)
    }

    /// The rotation `r^k`.
    pub fn rotation(k: u8) -> Self {
        D4 { k: k % 4, s: false }
    }

    /// The reflection `r^k s`.
    pub fn reflection(k: u8) -> Self {
        D4 { k: k % 4, s: true }
    }

    /// All eight symmetries: the four rotations first, then the four reflections.
    pub fn elements() -> Vec<D4> {
        let mut out = Vec::with_capacity(8);
        for k in 0..4 {
            out.push(D4::rotation(k));
        }
        for k in 0..4 {
            out.push(D4::reflection(k));
        }
        out
    }

    /// The element's name: `e`, `r`, `r²`, `r³`, `s`, `rs`, `r²s`, `r³s`.
    pub fn name(&self) -> String {
        let rot = ["", "r", "r²", "r³"][self.k as usize];
        match (rot.is_empty(), self.s) {
            (true, false) => "e".to_string(),
            (true, true) => "s".to_string(),
            (false, false) => rot.to_string(),
            (false, true) => format!("{rot}s"),
        }
    }
}

impl Semigroup for D4 {
    fn op(&self, other: &Self) -> Self {
        // r^a s^p · r^b s^q = r^{a + (p ? -b : b)} s^{p xor q}
        let b = if self.s { (4 - other.k) % 4 } else { other.k };
        D4 {
            k: (self.k + b) % 4,
            s: self.s ^ other.s,
        }
    }
}

impl Monoid for D4 {
    fn identity() -> Self {
        D4 { k: 0, s: false }
    }
}

impl Group for D4 {
    fn inverse(&self) -> Self {
        if self.s {
            // Every reflection r^k s is its own inverse: (r^k s)² = e.
            *self
        } else {
            D4 {
                k: (4 - self.k) % 4,
                s: false,
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn eight_elements() {
        assert_eq!(D4::elements().len(), 8);
    }

    #[test]
    fn r_has_order_four_and_s_order_two() {
        let r = D4::r();
        assert_eq!(r.op(&r).op(&r).op(&r), D4::identity());
        assert_ne!(r.op(&r), D4::identity());
        let s = D4::s();
        assert_eq!(s.op(&s), D4::identity());
    }

    #[test]
    fn composition_laws() {
        let r = D4::r();
        let s = D4::s();
        assert_eq!(r.op(&r).op(&r).op(&r), D4::identity()); // r^4 = e
        assert_eq!(s.op(&s), D4::identity()); // s^2 = e
        assert_eq!(s.op(&r), r.op(&r).op(&r).op(&s)); // s r = r^3 s
    }

    #[test]
    fn closed_and_nonabelian() {
        let elems = D4::elements();
        let r = D4::r();
        let s = D4::s();
        for a in &elems {
            for b in &elems {
                assert!(elems.contains(&a.op(b)));
            }
        }
        assert_ne!(r.op(&s), s.op(&r));
    }
}

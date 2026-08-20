//! Small posets and their downset (order ideal) algebras.
//!
//! This is the key construction linking partial orders with intuitionistic
//! semantics.  A **downset** (order ideal) of a poset `P` is a subset `D`
//! closed under going down: if `y ∈ D` and `x <= y` then `x ∈ D`.  The
//! downsets of `P` form a Heyting algebra with:
//!
//! - meet = intersection, join = union,
//! - implication `A -> B` = the largest ideal `I` with `I ∩ A ⊆ B`.
//!
//! Every finite Heyting algebra is, up to isomorphism, a subalgebra of the
//! downset algebra of some finite poset (Birkhoff duality: a finite
//! distributive lattice is the downset algebra of its poset of
//! join-irreducibles).  The downset algebra of a small poset is therefore a
//! rich source of counterexamples for intuitionistic formulas.
//!
//! ```
//! use heyting::Poset;
//!
//! // The poset with 0 < 1 and 0 < 2 (a "V").
//! let p = Poset::from_relations(3, &[(0, 1), (0, 2)]);
//! let a = p.downset_algebra();
//! assert_eq!(a.size(), 5); // {}, {0}, {0,1}, {0,2}, {0,1,2}
//! ```

use crate::algebra::{format_subset, Algebra};

/// A finite poset given by its order relation.
///
/// The elements are `0..size`.  The order is stored as a relation matrix in a
/// bitmask: bit `x * size + y` is set exactly when `x <= y`.  Build one with
/// [`Poset::from_relations`] (transitive closure is computed for you) or
/// [`Poset::from_less`] (pass a full `less` function).
///
/// ```
/// use heyting::Poset;
///
/// // The three-element chain 0 < 1 < 2.
/// let chain = Poset::from_relations(3, &[(0, 1), (1, 2)]);
/// assert!(chain.less(0, 2));
/// assert!(!chain.less(2, 0));
/// ```
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Poset {
    /// Number of elements; elements are `0..size`.
    pub size: usize,
    /// Relation matrix: bit `x * size + y` means `x <= y`.  Public so the
    /// enumeration in [`crate::valid`] can build posets straight from a
    /// bitmask.
    pub mask: usize,
}

impl Poset {
    /// A poset on `0..size` ordered by `less`.
    ///
    /// `less` must describe a genuine partial order (reflexive, antisymmetric
    /// and transitive); it is not checked.
    ///
    /// ```
    /// use heyting::Poset;
    ///
    /// // Two incomparable elements.
    /// let p = Poset::from_less(2, |x, y| x == y);
    /// assert_eq!(p.downsets(), vec![0, 1, 2, 3]);
    /// ```
    pub fn from_less(size: usize, less: fn(usize, usize) -> bool) -> Poset {
        let mut mask = 0usize;
        for x in 0..size {
            for y in 0..size {
                if less(x, y) {
                    mask |= 1 << (x * size + y);
                }
            }
        }
        Poset { size, mask }
    }

    /// The poset on `0..size` whose order is the reflexive-transitive closure
    /// of the given covering relations `(x, y)` with `x < y`.
    ///
    /// The relations need not be covering edges -- any strict `x < y` works,
    /// and chains of them are closed transitively.  Panics if a relation
    /// refers to an element outside `0..size` or the closure is not
    /// antisymmetric (e.g. a cycle).
    ///
    /// ```
    /// use heyting::Poset;
    ///
    /// // The diamond 0 < 1, 0 < 2, 1 < 3, 2 < 3.
    /// let p = Poset::from_relations(4, &[(0, 1), (0, 2), (1, 3), (2, 3)]);
    /// assert!(p.less(0, 3));
    /// assert!(!p.less(3, 0));
    /// ```
    pub fn from_relations(size: usize, relations: &[(usize, usize)]) -> Poset {
        let mut mask = 0usize;
        for &(x, y) in relations {
            assert!(x < size && y < size, "relation out of bounds in Poset");
            mask |= 1 << (x * size + y);
        }
        // Reflexive closure.
        for i in 0..size {
            mask |= 1 << (i * size + i);
        }
        // Transitive closure (Floyd-Warshall on bits).
        for k in 0..size {
            for x in 0..size {
                for y in 0..size {
                    if mask & (1 << (x * size + k)) != 0 && mask & (1 << (k * size + y)) != 0 {
                        mask |= 1 << (x * size + y);
                    }
                }
            }
        }
        // Antisymmetry check.
        for x in 0..size {
            for y in 0..size {
                assert!(
                    x == y
                        || mask & (1 << (x * size + y)) == 0
                        || mask & (1 << (y * size + x)) == 0,
                    "Poset::from_relations: the closure is not antisymmetric (a cycle?)"
                );
            }
        }
        Poset { size, mask }
    }

    /// Number of elements.
    pub fn size(&self) -> usize {
        self.size
    }

    /// Is `x <= y` in this poset?
    pub fn less(&self, x: usize, y: usize) -> bool {
        self.mask & (1 << (x * self.size + y)) != 0
    }

    /// Is the subset `mask` (bit `i` set = element `i` is in it) a downset?
    ///
    /// A downset is closed under going down: whenever `y` is in the subset
    /// and `x <= y`, also `x` is in it.
    pub fn is_downset(&self, subset: usize) -> bool {
        for y in 0..self.size {
            if subset & (1 << y) != 0 {
                for x in 0..self.size {
                    if self.less(x, y) && subset & (1 << x) == 0 {
                        return false;
                    }
                }
            }
        }
        true
    }

    /// All downsets of the poset, as bitmasks, in increasing numeric order.
    ///
    /// ```
    /// use heyting::Poset;
    ///
    /// // Two incomparable elements: downsets are {}, {0}, {1}, {0,1}.
    /// let p = Poset::from_less(2, |x, y| x == y);
    /// assert_eq!(p.downsets(), vec![0, 1, 2, 3]);
    /// ```
    pub fn downsets(&self) -> Vec<usize> {
        let mut out = Vec::new();
        for mask in 0..(1usize << self.size) {
            if self.is_downset(mask) {
                out.push(mask);
            }
        }
        out
    }

    /// The Heyting algebra of downsets of this poset.
    ///
    /// Elements are the downsets in increasing numeric order; meet is
    /// intersection, join is union, and `A -> B` is the largest ideal `I`
    /// with `I ∩ A ⊆ B` (computed from the lattice by
    /// [`Algebra::from_meet_join`], which realizes the Heyting adjunction).
    ///
    /// ```
    /// use heyting::Poset;
    ///
    /// // The two-element chain 0 < 1: its three downsets form the
    /// // three-element Heyting algebra.
    /// let p = Poset::from_relations(2, &[(0, 1)]);
    /// let a = p.downset_algebra();
    /// assert_eq!(a.size(), 3);
    /// assert!(!a.is_boolean());
    /// ```
    pub fn downset_algebra(&self) -> Algebra {
        let downsets = self.downsets();
        let m = downsets.len();

        // index_of[subset] = position of the ideal `subset` in `downsets`.
        let mut index_of = vec![0usize; 1usize << self.size];
        for (i, &subset) in downsets.iter().enumerate() {
            index_of[subset] = i;
        }

        let mut meet = vec![vec![0; m]; m];
        let mut join = vec![vec![0; m]; m];
        for i in 0..m {
            for j in 0..m {
                meet[i][j] = index_of[downsets[i] & downsets[j]];
                join[i][j] = index_of[downsets[i] | downsets[j]];
            }
        }

        let labels: Vec<String> = downsets
            .iter()
            .map(|&d| format_subset(d, self.size))
            .collect();
        Algebra::from_meet_join("downsets", meet, join, labels)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn downsets_of_antichain_are_power_set() {
        let p = Poset::from_less(3, |x, y| x == y);
        assert_eq!(p.downsets(), vec![0, 1, 2, 3, 4, 5, 6, 7]);
        let a = p.downset_algebra();
        assert_eq!(a.size(), 8);
        assert!(a.is_boolean());
    }

    #[test]
    fn downsets_of_chain_two_is_three_chain() {
        let p = Poset::from_relations(2, &[(0, 1)]);
        // Ideals of 0 < 1: {}, {0}, {0,1}.
        assert_eq!(p.downsets(), vec![0, 1, 3]);
        let a = p.downset_algebra();
        assert_eq!(a.size(), 3);
        assert_eq!(a.bottom, 0);
        assert_eq!(a.top, 2);
        // Mid = {0}: ¬Mid = Mid -> ∅ = ∅.
        assert_eq!(a.not(1), 0);
        assert!(!a.is_boolean());
    }

    #[test]
    fn downset_implication_is_largest_ideal_with_i_and_a_subset_b() {
        let p = Poset::from_relations(3, &[(0, 1), (0, 2)]);
        let a = p.downset_algebra();
        let ideals = p.downsets();

        // For every pair (A, B), check the defining property directly on
        // ideals: A -> B is the union of all ideals I with I ∩ A ⊆ B, and
        // that union is itself an ideal.
        for i in 0..a.size() {
            for j in 0..a.size() {
                let ab = a.implies(i, j);
                let a_mask = ideals[i];
                let b_mask = ideals[j];
                let ab_mask = ideals[ab];

                // The pseudo-complement contains every ideal I with I∩A ⊆ B.
                for &i_mask in &ideals {
                    if i_mask & a_mask & !b_mask == 0 {
                        assert!(
                            i_mask & !ab_mask == 0,
                            "ideal I with I∩A ⊆ B must be contained in A->B"
                        );
                    }
                }
                // And it is the union of exactly those ideals.
                let mut union = 0usize;
                for &i_mask in &ideals {
                    if i_mask & a_mask & !b_mask == 0 {
                        union |= i_mask;
                    }
                }
                assert_eq!(ab_mask, union);
            }
        }
    }

    #[test]
    fn v_poset_has_five_ideals() {
        // 0 < 1, 0 < 2: ideals {}, {0}, {0,1}, {0,2}, {0,1,2}.
        let p = Poset::from_relations(3, &[(0, 1), (0, 2)]);
        assert_eq!(p.downsets().len(), 5);
        let a = p.downset_algebra();
        assert_eq!(a.size(), 5);
        // {0} -> ∅ = ∅, so ¬{0} = ∅ and {0} ∨ ¬{0} = {0} ≠ top: LEM fails.
        let mid = 1; // the ideal {0}
        assert_eq!(a.join(mid, a.not(mid)), mid);
        assert_ne!(a.join(mid, a.not(mid)), a.top);
    }

    #[test]
    fn from_relations_computes_transitive_closure() {
        let p = Poset::from_relations(4, &[(0, 1), (1, 2), (2, 3)]);
        assert!(p.less(0, 3));
        assert!(p.less(1, 3));
        // The chain 0 < 1 < 2 < 3 has 5 ideals: {}, {0}, {0,1}, {0,1,2}, all.
        assert_eq!(p.downsets(), vec![0, 1, 3, 7, 15]);
    }
}

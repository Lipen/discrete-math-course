//! The powerset as a boolean ring.

use std::collections::HashSet;
use std::hash::Hash;
use std::ops::{Add, Mul};

/// Over a finite universe this is the boolean ring of the powerset: the
/// additive identity is the empty set, every element is its own additive
/// inverse (`a Δ a = ∅`), and every element is idempotent under `*`
/// (`a ∩ a = a`). The multiplicative identity is the whole universe, which
/// is why [`BoolSet`] does not implement the `Ring` trait -- there is no
/// "whole set" without a chosen finite universe.
#[derive(Clone, PartialEq, Eq, Debug)]
pub struct BoolSet<T: Eq + Hash>(HashSet<T>);

impl<T: Eq + Hash + Clone> BoolSet<T> {
    /// The empty set, the additive identity.
    pub fn empty() -> Self {
        BoolSet(HashSet::new())
    }

    /// A subset built from an existing set.
    pub fn from(set: HashSet<T>) -> Self {
        BoolSet(set)
    }

    /// A singleton `{x}`.
    pub fn singleton(x: T) -> Self {
        BoolSet([x].into_iter().collect())
    }

    /// Union, the join of the boolean algebra.
    pub fn union(&self, other: &Self) -> Self {
        BoolSet(self.0.union(&other.0).cloned().collect())
    }

    /// Set difference `self \ other`.
    pub fn difference(&self, other: &Self) -> Self {
        BoolSet(self.0.difference(&other.0).cloned().collect())
    }

    /// Whether `x` is an element of the set.
    pub fn contains(&self, x: &T) -> bool {
        self.0.contains(x)
    }

    /// The number of elements.
    pub fn len(&self) -> usize {
        self.0.len()
    }

    /// Whether the set has no elements.
    pub fn is_empty(&self) -> bool {
        self.0.is_empty()
    }

    /// All `2^n` subsets of `{0, ..., n-1}`.
    pub fn subsets(n: u32) -> Vec<BoolSet<usize>> {
        (0..1u64 << n)
            .map(|mask| {
                let set: HashSet<usize> = (0..n)
                    .filter(|i| (mask >> i) & 1 == 1)
                    .map(|i| i as usize)
                    .collect();
                BoolSet(set)
            })
            .collect()
    }
}

impl<T: Eq + Hash + Clone> Add for BoolSet<T> {
    type Output = Self;
    fn add(self, rhs: Self) -> Self {
        BoolSet(self.0.symmetric_difference(&rhs.0).cloned().collect())
    }
}

impl<T: Eq + Hash + Clone> Mul for BoolSet<T> {
    type Output = Self;
    fn mul(self, rhs: Self) -> Self {
        BoolSet(self.0.intersection(&rhs.0).cloned().collect())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn s(xs: &[usize]) -> BoolSet<usize> {
        BoolSet(xs.iter().copied().collect())
    }

    #[test]
    fn symmetric_difference_and_intersection() {
        let a = s(&[0, 1]);
        let b = s(&[1, 2]);
        assert_eq!(a.clone() + b.clone(), s(&[0, 2])); // Δ keeps 0 and 2
        assert_eq!(a.clone() * b.clone(), s(&[1])); // ∩ keeps only 1
    }

    #[test]
    fn every_set_is_its_own_additive_inverse() {
        for a in BoolSet::<usize>::subsets(3) {
            assert_eq!(a.clone() + a.clone(), BoolSet::empty());
        }
    }

    #[test]
    fn distributivity_over_the_full_powerset() {
        let ps = BoolSet::<usize>::subsets(3);
        for a in &ps {
            for b in &ps {
                for c in &ps {
                    // a ∩ (b Δ c) = (a ∩ b) Δ (a ∩ c)
                    let lhs = a.clone() * (b.clone() + c.clone());
                    let rhs = (a.clone() * b.clone()) + (a.clone() * c.clone());
                    assert_eq!(lhs, rhs);
                }
            }
        }
    }

    #[test]
    fn subsets_of_three_has_eight_elements() {
        assert_eq!(BoolSet::<usize>::subsets(3).len(), 8);
    }
}

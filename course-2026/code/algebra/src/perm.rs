//! Permutations: the symmetric group `S_n`.

use crate::traits::{Group, Monoid, Semigroup};

/// A permutation of `{0, ..., N-1}`: `p.0[i]` is the image of `i`.
///
/// Composition `a.op(b)` applies `b` first, then `a`, so
/// `a.op(b).0[i] == a.0[b.0[i]]`.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub struct Perm<const N: usize>(pub [usize; N]);

impl<const N: usize> Semigroup for Perm<N> {
    fn op(&self, other: &Self) -> Self {
        let mut arr = [0; N];
        for (slot, &img) in arr.iter_mut().zip(other.0.iter()) {
            *slot = self.0[img];
        }
        Perm(arr)
    }
}

impl<const N: usize> Monoid for Perm<N> {
    fn identity() -> Self {
        let mut arr = [0; N];
        for (i, slot) in arr.iter_mut().enumerate() {
            *slot = i;
        }
        Perm(arr)
    }
}

impl<const N: usize> Group for Perm<N> {
    fn inverse(&self) -> Self {
        let mut arr = [0; N];
        for (i, &image) in self.0.iter().enumerate() {
            arr[image] = i;
        }
        Perm(arr)
    }
}

#[cfg(test)]
mod tests {
    use super::Perm;
    use crate::traits::{Group, Monoid, Semigroup};

    #[test]
    fn three_cycle_has_order_three() {
        let c = Perm([1, 2, 0]);
        let c3 = c.op(&c).op(&c);
        assert_eq!(c3, Perm::<3>::identity());
        assert_ne!(c.op(&c), Perm::<3>::identity());
    }

    #[test]
    fn inverse_undoes_composition() {
        let p = Perm([2, 0, 1]);
        assert_eq!(p.op(&p.inverse()), Perm::<3>::identity());
    }
}

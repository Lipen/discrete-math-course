//! Matroids and the greedy algorithm.
//!
//! A matroid is a finite ground set with an independence family closed under subsets (heredity) and satisfying the exchange property.
//! On a matroid the greedy algorithm finds a maximum-weight independent set.
//! On any other independence system it can be fooled.
//!
//! ```
//! use matroids::examples::UniformMatroid;
//! use matroids::{greedy, weight};
//!
//! let m = UniformMatroid { n: 4, k: 2 };
//! let weights = [5u32, 3, 4, 2];
//! let chosen = greedy(&m, &weights);
//! assert_eq!(chosen.len(), 2); // a base of U(2, 4): the two heaviest elements
//! assert_eq!(weight(&chosen, &weights), 9);
//! ```

pub mod examples;

/// A matroid: a ground set of `n` elements plus an independence oracle.
pub trait Matroid {
    /// Number of elements in the ground set.
    fn n(&self) -> u32;
    /// Whether the given set of element indices is independent.
    fn is_independent(&self, set: &[u32]) -> bool;
}

/// Greedy algorithm: consider elements in decreasing weight order, take an element when independence of the chosen set is preserved.
///
/// The returned indices are sorted in increasing order.
pub fn greedy<M: Matroid>(m: &M, weights: &[u32]) -> Vec<u32> {
    let mut order: Vec<u32> = (0..m.n()).collect();
    order.sort_by(|&a, &b| weights[b as usize].cmp(&weights[a as usize]));
    let mut chosen: Vec<u32> = Vec::new();
    for e in order {
        let mut candidate = chosen.clone();
        candidate.push(e);
        candidate.sort_unstable();
        if m.is_independent(&candidate) {
            chosen = candidate;
        }
    }
    chosen
}

/// Total weight of a chosen set of element indices.
pub fn weight(set: &[u32], weights: &[u32]) -> u32 {
    set.iter().map(|&i| weights[i as usize]).sum()
}

/// Rank of a matroid: the size of a maximum independent set.
///
/// Greedy with unit weights returns a base, and all bases of a matroid have the same size, so the rank is the size of the greedy result.
pub fn rank<M: Matroid>(m: &M) -> u32 {
    let unit = vec![1; m.n() as usize];
    greedy(m, &unit).len() as u32
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::examples::{GraphicMatroid, UniformMatroid};

    #[test]
    fn greedy_takes_the_two_heaviest_sorted() {
        let m = UniformMatroid { n: 4, k: 2 };
        let weights = [5u32, 3, 4, 2];
        let chosen = greedy(&m, &weights);
        assert_eq!(chosen, vec![0, 2]); // the two heaviest, increasing order
        assert!(m.is_independent(&chosen));
        assert_eq!(weight(&chosen, &weights), 9);
    }

    #[test]
    fn greedy_never_leaves_the_independent_family() {
        let m = UniformMatroid { n: 4, k: 1 };
        let weights = [7u32, 6, 5, 4];
        let chosen = greedy(&m, &weights);
        assert_eq!(chosen, vec![0]); // k = 1: only the heaviest element fits
        assert!(m.is_independent(&chosen));
    }

    #[test]
    fn weight_sums_element_weights() {
        let weights = [5u32, 3, 4, 2];
        assert_eq!(weight(&[0, 2], &weights), 9);
        assert_eq!(weight(&[], &weights), 0);
    }

    #[test]
    fn rank_equals_base_size() {
        let m = UniformMatroid { n: 4, k: 2 };
        assert_eq!(rank(&m), 2);
        // Unit-weight greedy returns a base: independent and of maximal size.
        let unit = vec![1; m.n() as usize];
        let base = greedy(&m, &unit);
        assert!(m.is_independent(&base));
        assert_eq!(base.len() as u32, rank(&m));
    }

    #[test]
    fn greedy_on_graphic_matroid_with_tie() {
        // Triangle 0-1-2 plus tail 2-3: every spanning tree must take the tail edge.
        let edges = vec![(0u32, 1u32), (1u32, 2u32), (0u32, 2u32), (2u32, 3u32)];
        let m = GraphicMatroid::new(4, &edges);
        let weights = [4u32, 3, 3, 5];
        // Descending order: d (5), a (4), then the b/c tie resolved by index order;
        // the last candidate closes the triangle and is rejected.
        let chosen = greedy(&m, &weights);
        assert_eq!(chosen, vec![0, 1, 3]);
        assert!(m.is_independent(&chosen));
        assert_eq!(weight(&chosen, &weights), 12); // the maximum spanning tree
    }
}

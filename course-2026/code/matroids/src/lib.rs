//! Matroids and the greedy algorithm.
//!
//! A matroid is a finite ground set with an independence family closed under
//! subsets (heredity) and satisfying the exchange property. On a matroid the
//! greedy algorithm finds a maximum-weight independent set; on any other
//! independence system it can be fooled.

pub mod examples;

/// A matroid: a ground set of `n` elements plus an independence oracle.
pub trait Matroid {
    /// Number of elements in the ground set.
    fn n(&self) -> u32;
    /// Whether the given set of element indices is independent.
    fn is_independent(&self, set: &[u32]) -> bool;
}

/// Greedy algorithm: consider elements in decreasing weight order,
/// take an element when independence of the chosen set is preserved.
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
/// Greedy with unit weights returns a base, and all bases of a matroid
/// have the same size, so the rank is the size of the greedy result.
pub fn rank<M: Matroid>(m: &M) -> u32 {
    let unit = vec![1; m.n() as usize];
    greedy(m, &unit).len() as u32
}

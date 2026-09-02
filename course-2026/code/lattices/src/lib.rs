//! Lattices and partial orders: join, meet, distributivity, modularity,
//! and the Birkhoff characterization of distributive lattices.
//!
//! A lattice is a finite set with a partial order in which every pair of
//! elements has a join (supremum) and a meet (infimum). Some lattices are
//! distributive, some are modular but not distributive, and the Birkhoff
//! characterization says that a lattice is distributive exactly when it
//! contains no sublattice isomorphic to M3 (the diamond) or N5 (the
//! pentagon). This crate lets you build small lattices, check these
//! properties, and search for the forbidden sublattices.

pub mod examples;

/// A finite lattice given explicitly: a set of elements and the relation `<=`.
///
/// The relation is the full list of pairs `(a, b)` with `a <= b`.
/// Keeping it explicit makes the code transparent for the small examples.
pub struct Lattice {
    /// The elements of the lattice.
    pub elements: Vec<u32>,
    /// The relation `<=` as pairs `(a, b)`, transitively closed.
    pub leq: Vec<(u32, u32)>,
}

impl Lattice {
    /// Whether `a <= b` in this lattice.
    pub fn le(&self, a: u32, b: u32) -> bool {
        self.leq.contains(&(a, b))
    }

    /// Common upper bounds of `a` and `b`.
    pub fn upper_bounds(&self, a: u32, b: u32) -> Vec<u32> {
        self.elements
            .iter()
            .copied()
            .filter(|&u| self.le(a, u) && self.le(b, u))
            .collect()
    }

    /// Common lower bounds of `a` and `b`.
    pub fn lower_bounds(&self, a: u32, b: u32) -> Vec<u32> {
        self.elements
            .iter()
            .copied()
            .filter(|&l| self.le(l, a) && self.le(l, b))
            .collect()
    }

    /// Join (supremum) of `a` and `b`: the least upper bound, if it exists.
    pub fn join(&self, a: u32, b: u32) -> Option<u32> {
        let ub = self.upper_bounds(a, b);
        ub.iter()
            .copied()
            .find(|&u| ub.iter().all(|&u2| self.le(u, u2)))
    }

    /// Meet (infimum) of `a` and `b`: the greatest lower bound, if it exists.
    pub fn meet(&self, a: u32, b: u32) -> Option<u32> {
        let lb = self.lower_bounds(a, b);
        lb.iter()
            .copied()
            .find(|&l| lb.iter().all(|&l2| self.le(l2, l)))
    }

    /// Whether every pair of elements has a join and a meet.
    pub fn is_lattice(&self) -> bool {
        for &a in &self.elements {
            for &b in &self.elements {
                if self.join(a, b).is_none() || self.meet(a, b).is_none() {
                    return false;
                }
            }
        }
        true
    }

    /// The least element, if the lattice has one.
    pub fn bottom(&self) -> Option<u32> {
        self.elements
            .iter()
            .copied()
            .find(|&b| self.elements.iter().all(|&x| self.le(b, x)))
    }

    /// The greatest element, if the lattice has one.
    pub fn top(&self) -> Option<u32> {
        self.elements
            .iter()
            .copied()
            .find(|&t| self.elements.iter().all(|&x| self.le(x, t)))
    }

    /// Whether every pair of elements is comparable.
    pub fn is_chain(&self) -> bool {
        for &a in &self.elements {
            for &b in &self.elements {
                if !self.le(a, b) && !self.le(b, a) {
                    return false;
                }
            }
        }
        true
    }

    /// Whether the distributive law holds for every triple:
    /// `a meet (b join c) = (a meet b) join (a meet c)`.
    pub fn is_distributive(&self) -> bool {
        if !self.is_lattice() {
            return false;
        }
        for &a in &self.elements {
            for &b in &self.elements {
                for &c in &self.elements {
                    let lhs = self.meet(a, self.join(b, c).unwrap());
                    let rhs = self.join(self.meet(a, b).unwrap(), self.meet(a, c).unwrap());
                    if lhs != rhs {
                        return false;
                    }
                }
            }
        }
        true
    }

    /// Whether the modular law holds for every triple with `a <= c`:
    /// `a join (b meet c) = (a join b) meet c`.
    pub fn is_modular(&self) -> bool {
        if !self.is_lattice() {
            return false;
        }
        for &a in &self.elements {
            for &b in &self.elements {
                for &c in &self.elements {
                    if self.le(a, c) {
                        let lhs = self.join(a, self.meet(b, c).unwrap());
                        let rhs = self.meet(self.join(a, b).unwrap(), c);
                        if lhs != rhs {
                            return false;
                        }
                    }
                }
            }
        }
        true
    }

    /// Whether the given subset is a sublattice: join and meet of its
    /// elements again lie in the subset.
    fn is_sublattice(&self, s: &[u32]) -> bool {
        for &a in s {
            for &b in s {
                let j = self.join(a, b).unwrap();
                let m = self.meet(a, b).unwrap();
                if !s.contains(&j) || !s.contains(&m) {
                    return false;
                }
            }
        }
        true
    }

    /// Whether the given 5-element subset is isomorphic to M3 (the diamond):
    /// a least element, a greatest element, and three pairwise incomparable
    /// middle elements.
    fn is_m3(&self, s: &[u32]) -> bool {
        if !self.is_sublattice(s) {
            return false;
        }
        let bottom = s
            .iter()
            .copied()
            .find(|&b| s.iter().all(|&x| self.le(b, x)));
        let top = s
            .iter()
            .copied()
            .find(|&t| s.iter().all(|&x| self.le(x, t)));
        let (Some(b), Some(t)) = (bottom, top) else {
            return false;
        };
        let middle: Vec<u32> = s.iter().copied().filter(|&x| x != b && x != t).collect();
        if middle.len() != 3 {
            return false;
        }
        // The three middle elements are pairwise incomparable.
        for i in 0..middle.len() {
            for j in (i + 1)..middle.len() {
                if self.le(middle[i], middle[j]) || self.le(middle[j], middle[i]) {
                    return false;
                }
            }
        }
        true
    }

    /// Whether the given 5-element subset is isomorphic to N5 (the pentagon):
    /// a chain `0 < a < b < 1` plus a middle `c` incomparable to `a` and `b`.
    fn is_n5(&self, s: &[u32]) -> bool {
        if !self.is_sublattice(s) {
            return false;
        }
        let zero = s
            .iter()
            .copied()
            .find(|&z| s.iter().all(|&x| self.le(z, x)));
        let one = s
            .iter()
            .copied()
            .find(|&o| s.iter().all(|&x| self.le(x, o)));
        let (Some(z), Some(o)) = (zero, one) else {
            return false;
        };
        let middle: Vec<u32> = s.iter().copied().filter(|&x| x != z && x != o).collect();
        if middle.len() != 3 {
            return false;
        }
        // Some middle `a < b`, with `c` incomparable to both.
        for &a in &middle {
            for &b in &middle {
                if a == b || !self.le(a, b) {
                    continue;
                }
                for &c in &middle {
                    if c == a || c == b {
                        continue;
                    }
                    let incomparable =
                        !self.le(c, a) && !self.le(a, c) && !self.le(c, b) && !self.le(b, c);
                    if incomparable {
                        return true;
                    }
                }
            }
        }
        false
    }

    /// Whether the lattice contains a sublattice isomorphic to M3.
    ///
    /// Brute force over 5-element subsets, fine for the small examples.
    pub fn has_m3_sublattice(&self) -> bool {
        combinations(&self.elements, 5)
            .into_iter()
            .any(|s| self.is_m3(&s))
    }

    /// Whether the lattice contains a sublattice isomorphic to N5.
    pub fn has_n5_sublattice(&self) -> bool {
        combinations(&self.elements, 5)
            .into_iter()
            .any(|s| self.is_n5(&s))
    }

    /// The Birkhoff characterization as a single check: a lattice is
    /// distributive exactly when it contains neither M3 nor N5.
    pub fn is_distributive_birkhoff(&self) -> bool {
        !self.has_m3_sublattice() && !self.has_n5_sublattice()
    }
}

/// The relation `{(i, j) : leq(i, j)}` as an explicit list of pairs.
///
/// Builds a full pair set for a finite relation given by a predicate: every
/// pair `(i, j)` with `0 <= i < n` and `0 <= j < n` is tested, and the pairs
/// for which `leq(i, j)` is true are collected in lexicographic order.
///
/// ```
/// use lattices::relation_pairs;
///
/// // The chain 0 < 1 < 2: leq is just `i <= j`.
/// let pairs = relation_pairs(3, |i, j| i <= j);
/// assert!(pairs.contains(&(0, 2)));
/// assert_eq!(pairs.len(), 6);
/// ```
pub fn relation_pairs(n: usize, leq: impl Fn(usize, usize) -> bool) -> Vec<(usize, usize)> {
    let mut pairs = Vec::new();
    for i in 0..n {
        for j in 0..n {
            if leq(i, j) {
                pairs.push((i, j));
            }
        }
    }
    pairs
}

/// The Hasse diagram (cover relation) of a poset given by its pairs.
///
/// A pair `(a, c)` is removed when it can be obtained by transitivity from
/// two other pairs: some `b` with both `(a, b)` and `(b, c)` in the
/// relation. What remains are the covers, the pairs that are not a
/// composition of two smaller steps. The input is expected to be the full
/// relation (as produced by `relation_pairs`), so that dropping the
/// transitive pairs leaves exactly the covering pairs.
///
/// This variant drops the reflexive pairs `(a, a)` too, so the result is
/// the strict cover relation.
///
/// ```
/// use lattices::{hasse, relation_pairs};
///
/// // The chain 0 < 1 < 2: pairs include the transitive (0, 2), the Hasse
/// // diagram does not.
/// let pairs = relation_pairs(3, |i, j| i <= j);
/// assert!(pairs.contains(&(0, 2)));
/// let hasse = hasse(&pairs);
/// assert!(!hasse.contains(&(0, 2)));
/// assert_eq!(hasse, vec![(0, 1), (1, 2)]);
/// ```
pub fn hasse(pairs: &[(usize, usize)]) -> Vec<(usize, usize)> {
    pairs
        .iter()
        .copied()
        .filter(|&(a, c)| {
            if a == c {
                return false;
            }
            // Keep (a, c) unless some b lies strictly between them.
            !pairs
                .iter()
                .any(|&(x, y)| x == a && y != a && y != c && pairs.contains(&(y, c)))
        })
        .collect()
}

/// The Hasse diagram, keeping the reflexive pairs.
///
/// Like `hasse`, this removes the transitive pairs, but it keeps the
/// reflexive pairs `(a, a)`, so the result is in the same pair format as
/// `Lattice::leq`.
/// `Lattice::leq` must be transitively closed, while the Hasse diagram
/// is deliberately not: to build a `Lattice` from a Hasse diagram, take
/// the transitive closure first (for a poset, the transitive closure of
/// the covers is the whole relation).
///
/// ```
/// use lattices::{hasse_reflexive, relation_pairs, Lattice};
///
/// // The chain 0 < 1 < 2: covers plus reflexive pairs.
/// let covers = hasse_reflexive(&relation_pairs(3, |i, j| i <= j));
/// assert_eq!(covers, vec![(0, 0), (0, 1), (1, 1), (1, 2), (2, 2)]);
///
/// // A Lattice needs the full relation, so close the covers transitively.
/// let leq: Vec<(u32, u32)> = relation_pairs(3, |i, j| {
///     covers.contains(&(i, j))
///         || covers.iter().any(|&(a, b)| a == i && covers.contains(&(b, j)))
/// })
/// .into_iter()
/// .map(|(a, b)| (a as u32, b as u32))
/// .collect();
/// let l = Lattice { elements: vec![0, 1, 2], leq };
/// assert!(l.is_chain());
/// assert!(l.is_distributive());
/// ```
pub fn hasse_reflexive(pairs: &[(usize, usize)]) -> Vec<(usize, usize)> {
    let mut reflexive: Vec<(usize, usize)> =
        pairs.iter().copied().filter(|&(a, b)| a == b).collect();
    reflexive.append(&mut hasse(pairs));
    reflexive.sort_unstable();
    reflexive
}

/// All `k`-element subsets of `xs`, each as a sorted `Vec`.
fn combinations(xs: &[u32], k: usize) -> Vec<Vec<u32>> {
    let mut out = Vec::new();
    let n = xs.len();
    if k > n {
        return out;
    }
    let mut idx: Vec<usize> = (0..k).collect();
    loop {
        out.push(idx.iter().map(|&i| xs[i]).collect());
        let mut i = k;
        loop {
            if i == 0 {
                return out;
            }
            i -= 1;
            if idx[i] < n - k + i {
                break;
            }
        }
        idx[i] += 1;
        for j in (i + 1)..k {
            idx[j] = idx[j - 1] + 1;
        }
    }
}

#[cfg(test)]
mod tests {
    use crate::examples::{boolean_3, divisors_12, m3, n5};
    use crate::Lattice;

    #[test]
    fn m3_is_modular_not_distributive() {
        let l = m3();
        assert!(l.is_lattice());
        assert!(l.is_modular());
        assert!(!l.is_distributive());
        assert!(!l.is_distributive_birkhoff());
        assert!(l.has_m3_sublattice());
        assert!(!l.has_n5_sublattice());
    }

    #[test]
    fn n5_is_not_modular() {
        let l = n5();
        assert!(l.is_lattice());
        assert!(!l.is_modular());
        assert!(!l.is_distributive());
        assert!(l.has_n5_sublattice());
        assert!(!l.has_m3_sublattice());
    }

    #[test]
    fn divisors_12_is_distributive() {
        let l = divisors_12();
        assert!(l.is_lattice());
        assert!(l.is_distributive());
        assert!(l.is_distributive_birkhoff());
        assert!(!l.has_m3_sublattice());
        assert!(!l.has_n5_sublattice());
        // Join of {2, 3} is 6, meet is 1.
        assert_eq!(l.join(2, 3), Some(6));
        assert_eq!(l.meet(2, 3), Some(1));
    }

    #[test]
    fn boolean_3_is_distributive() {
        let l = boolean_3();
        assert!(l.is_lattice());
        assert!(l.is_distributive());
        assert!(l.is_distributive_birkhoff());
        assert!(!l.has_m3_sublattice());
        assert!(!l.has_n5_sublattice());
    }

    #[test]
    fn birkhoff_matches_distributive_law() {
        for l in [m3(), n5(), divisors_12(), boolean_3()] {
            assert_eq!(l.is_distributive(), l.is_distributive_birkhoff());
        }
    }

    #[test]
    fn relation_pairs_builds_a_chain() {
        let pairs = crate::relation_pairs(3, |i, j| i <= j);
        assert_eq!(pairs, vec![(0, 0), (0, 1), (0, 2), (1, 1), (1, 2), (2, 2)]);
        // Only pairs satisfying the predicate appear.
        assert!(!pairs.contains(&(1, 0)));
        assert!(!pairs.contains(&(2, 1)));
    }

    #[test]
    fn hasse_drops_transitive_pairs() {
        let pairs = crate::relation_pairs(4, |i, j| i <= j);
        assert_eq!(crate::hasse(&pairs), vec![(0, 1), (1, 2), (2, 3)]);
        // The 3-element chain: (0, 2) is transitive, (0, 1) and (1, 2) are covers.
        let chain3 = crate::relation_pairs(3, |i, j| i <= j);
        assert_eq!(crate::hasse(&chain3), vec![(0, 1), (1, 2)]);
    }

    #[test]
    fn hasse_reflexive_keeps_covers_and_reflexive_pairs() {
        // The chain 0 < 1 < 2: reflexive pairs plus the covers.
        let covers = crate::hasse_reflexive(&crate::relation_pairs(3, |i, j| i <= j));
        assert_eq!(covers, vec![(0, 0), (0, 1), (1, 1), (1, 2), (2, 2)]);
        // A Lattice needs the transitively closed relation, as the crate's
        // example lattices have it.
        let leq: Vec<(u32, u32)> = crate::relation_pairs(3, |i, j| i <= j)
            .into_iter()
            .map(|(a, b)| (a as u32, b as u32))
            .collect();
        let l = Lattice {
            elements: vec![0, 1, 2],
            leq,
        };
        assert!(l.is_chain());
        assert!(l.is_distributive());
        assert_eq!(l.upper_bounds(0, 1), vec![1, 2]);
        assert_eq!(l.meet(0, 2), Some(0));
        assert_eq!(l.join(0, 2), Some(2));
    }

    #[test]
    fn hasse_on_divisors_12_matches_building_blocks() {
        // Divisor poset of 12: a <= b iff a divides b.
        // Indices: 0=1, 1=2, 2=3, 3=4, 4=6, 5=12.
        let d12 = divisors_12();
        let pairs = crate::relation_pairs(6, |i, j| d12.le(d12.elements[i], d12.elements[j]));
        let covers = crate::hasse(&pairs);
        // The covers are the covering pairs: 1<2, 1<3, 2<4, 2<6, 3<6,
        // 4<12, 6<12. The transitive pairs (1,4), (1,6), (1,12), (2,12),
        // (3,12) are removed; (2,6) stays because 4 does not divide 6.
        assert!(!covers.contains(&(0, 3))); // 1 -> 4 via 2
        assert!(!covers.contains(&(0, 4))); // 1 -> 6 via 3
        assert!(!covers.contains(&(0, 5))); // 1 -> 12
        assert!(!covers.contains(&(1, 5))); // 2 -> 12 via 4
        assert!(!covers.contains(&(2, 5))); // 3 -> 12 via 6
        assert!(covers.contains(&(0, 1))); // 1 -> 2
        assert!(covers.contains(&(0, 2))); // 1 -> 3
        assert!(covers.contains(&(1, 3))); // 2 -> 4
        assert!(covers.contains(&(1, 4))); // 2 -> 6
        assert!(covers.contains(&(2, 4))); // 3 -> 6
        assert!(covers.contains(&(3, 5))); // 4 -> 12
        assert!(covers.contains(&(4, 5))); // 6 -> 12
        assert_eq!(covers.len(), 7);
    }
}

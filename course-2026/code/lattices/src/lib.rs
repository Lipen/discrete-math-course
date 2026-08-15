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
/// The relation is the full list of pairs `(a, b)` with `a <= b`. Keeping it
/// explicit makes the code transparent; the book examples are small.
pub struct Lattice {
    pub elements: Vec<u32>,
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
    /// Brute force over 5-element subsets; fine for the small book examples.
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
        // Book example: join of {2, 3} is 6, meet is 1.
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
}

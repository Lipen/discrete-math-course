//! Fuzzy relations and max-min composition.
//!
//! A fuzzy relation is a fuzzy set on a Cartesian product `X × Y`: the degree `R(x, y)` says how strongly `x` is related to `y`.
//! On finite sets a relation is a matrix, and two relations compose exactly like classical relations, with `min` and `max` standing in for `and` and `or`.

/// A fuzzy relation `R: X × Y -> [0, 1]` on finite sets, stored as a dense row-major matrix of `rows × cols` membership degrees.
#[derive(Clone, Debug, PartialEq)]
pub struct FuzzyRelation {
    /// Number of rows.
    pub rows: usize,
    /// Number of columns.
    pub cols: usize,
    /// Membership degrees in row-major order: `rows * cols` entries.
    pub data: Vec<f64>,
}

impl FuzzyRelation {
    /// Build a relation from a membership function of the row and column index.
    pub fn from_fn(rows: usize, cols: usize, f: impl Fn(usize, usize) -> f64) -> Self {
        let mut data = Vec::with_capacity(rows * cols);
        for i in 0..rows {
            for j in 0..cols {
                data.push(f(i, j));
            }
        }
        FuzzyRelation { rows, cols, data }
    }

    /// The membership degree of the pair `(i, j)`.
    pub fn get(&self, i: usize, j: usize) -> f64 {
        self.data[i * self.cols + j]
    }

    /// Max-min composition: `(R ∘ S)(i, k) = max_j min(R(i, j), S(j, k))`.
    ///
    /// Returns `None` when the inner dimensions do not match.
    ///
    /// ```
    /// use fuzzy::FuzzyRelation;
    ///
    /// let close = FuzzyRelation::from_fn(4, 4, |i, j| {
    ///     (1.0 - (i as f64 - j as f64).abs() / 3.0).max(0.0)
    /// });
    /// // Compose with itself: through one middleman, 1 and 4 are 1/3 close.
    /// let r = close.max_min_compose(&close).unwrap();
    /// assert!((r.get(0, 3) - 1.0 / 3.0).abs() < 1e-12);
    /// ```
    pub fn max_min_compose(&self, other: &FuzzyRelation) -> Option<FuzzyRelation> {
        if self.cols != other.rows {
            return None;
        }
        let n = self.rows;
        let k = other.cols;
        let m = self.cols;
        let mut data = Vec::with_capacity(n * k);
        for i in 0..n {
            for j in 0..k {
                let mut best = 0.0f64;
                for t in 0..m {
                    best = best.max(self.get(i, t).min(other.get(t, j)));
                }
                data.push(best);
            }
        }
        Some(FuzzyRelation {
            rows: n,
            cols: k,
            data,
        })
    }

    /// Max-product composition (Larsen): `max_j R(i, j) * S(j, k)`.
    pub fn max_product_compose(&self, other: &FuzzyRelation) -> Option<FuzzyRelation> {
        if self.cols != other.rows {
            return None;
        }
        let n = self.rows;
        let k = other.cols;
        let m = self.cols;
        let mut data = Vec::with_capacity(n * k);
        for i in 0..n {
            for j in 0..k {
                let mut best = 0.0f64;
                for t in 0..m {
                    best = best.max(self.get(i, t) * other.get(t, j));
                }
                data.push(best);
            }
        }
        Some(FuzzyRelation {
            rows: n,
            cols: k,
            data,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn close() -> FuzzyRelation {
        // "x is close to y" on {1, 2, 3, 4}: mu = max(0, 1 - |x - y| / 3).
        FuzzyRelation::from_fn(4, 4, |i, j| {
            (1.0 - (i as f64 - j as f64).abs() / 3.0).max(0.0)
        })
    }

    #[test]
    fn closeness_degrees_match_the_formula() {
        let r = close();
        assert_eq!(r.get(0, 0), 1.0);
        assert!((r.get(0, 1) - 2.0 / 3.0).abs() < 1e-12);
        assert!((r.get(0, 2) - 1.0 / 3.0).abs() < 1e-12);
        assert_eq!(r.get(0, 3), 0.0);
        // Symmetric.
        assert_eq!(r.get(1, 3), r.get(3, 1));
    }

    #[test]
    fn max_min_composition_finds_paths() {
        let r = close();
        let rr = r.max_min_compose(&r).unwrap();
        // 1 and 4 are not directly close (0), but through a middleman:
        // max_j min(R(1,j), R(j,4)) = 1/3.
        assert!((rr.get(0, 3) - 1.0 / 3.0).abs() < 1e-12);
        // Reflexive pairs remain fully close.
        assert_eq!(rr.get(0, 0), 1.0);
        // Composition of a symmetric relation with itself is symmetric.
        assert_eq!(rr.get(0, 3), rr.get(3, 0));
    }

    #[test]
    fn max_product_composition_is_not_max_min() {
        let r = close();
        let min_comp = r.max_min_compose(&r).unwrap();
        let prod_comp = r.max_product_compose(&r).unwrap();
        // Product is <= min on [0,1], and here strictly smaller for (0,3).
        assert!(prod_comp.get(0, 3) < min_comp.get(0, 3));
    }

    #[test]
    fn mismatched_dimensions_fail() {
        let a = FuzzyRelation::from_fn(2, 3, |i, j| (i + j) as f64);
        let b = FuzzyRelation::from_fn(2, 2, |i, j| (i + j) as f64);
        assert!(a.max_min_compose(&b).is_none());
        assert!(a.max_product_compose(&b).is_none());
    }
}

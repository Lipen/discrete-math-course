//! Fuzzy sets as piecewise-linear membership functions.
//!
//! A fuzzy set on a numeric universe is a membership function `mu: U -> [0, 1]`.
//! This module represents the common shapes (triangular, trapezoidal, and any polyline) as a sorted list of `(x, mu)` breakpoints with linear interpolation between them and value `0` outside the span.
//! Zadeh's operations (union `max`, intersection `min`, complement `1 - mu`) are exact on this representation: the result of combining two piecewise-linear functions is again piecewise-linear.

/// A fuzzy set given by a piecewise-linear membership function.
///
/// `points` is a list of breakpoints `(x, mu)` sorted by `x`, with `mu` in `[0, 1]`.
/// The membership of any `x` outside the first and last breakpoint is `0`.
/// Between consecutive breakpoints the function is the linear interpolation, so a triangular fuzzy set `(l, m, r)` is the three points `[(l, 0), (m, 1), (r, 0)]`.
///
/// To make `alpha_cut(0)` span a chosen universe, include the universe boundaries as zero-membership breakpoints:
///
/// ```
/// use fuzzy::FuzzySet;
///
/// // The universe [0, 100] with "young" = 1 below 25, falling to 0 at 40.
/// let young = FuzzySet::new(vec![(0.0, 1.0), (25.0, 1.0), (40.0, 0.0), (100.0, 0.0)]);
/// assert_eq!(young.alpha_cut(0.0), vec![(0.0, 100.0)]);
/// ```
#[derive(Clone, Debug, PartialEq)]
pub struct FuzzySet {
    /// Breakpoints `(x, mu)` sorted by `x`, with `mu` in `[0, 1]`.
    pub points: Vec<(f64, f64)>,
}

impl FuzzySet {
    /// Build a set from breakpoints: sorts them, drops duplicate `x`, and
    /// removes collinear interior points.
    pub fn new(points: Vec<(f64, f64)>) -> Self {
        let mut pts = points;
        pts.sort_by(|a, b| a.0.partial_cmp(&b.0).unwrap());
        pts.dedup_by(|a, b| a.0 == b.0);
        FuzzySet {
            points: remove_collinear(pts),
        }
    }

    /// Degree of membership of `x`.
    ///
    /// ```
    /// use fuzzy::FuzzySet;
    ///
    /// // "young": 1 below 25, falling linearly to 0 at 40.
    /// let young = FuzzySet::new(vec![(0.0, 1.0), (25.0, 1.0), (40.0, 0.0), (100.0, 0.0)]);
    /// assert_eq!(young.membership(20.0), 1.0);
    /// assert!((young.membership(30.0) - 2.0 / 3.0).abs() < 1e-12);
    /// assert_eq!(young.membership(50.0), 0.0);
    /// ```
    pub fn membership(&self, x: f64) -> f64 {
        let pts = &self.points;
        if pts.is_empty() {
            return 0.0;
        }
        let first = pts[0];
        let last = pts[pts.len() - 1];
        if x < first.0 || x > last.0 {
            return 0.0;
        }
        for w in pts.windows(2) {
            let (x0, y0) = w[0];
            let (x1, y1) = w[1];
            if x <= x1 {
                return y0 + (y1 - y0) * (x - x0) / (x1 - x0);
            }
        }
        last.1
    }

    /// The height: the largest membership value attained.
    pub fn height(&self) -> f64 {
        self.points.iter().map(|p| p.1).fold(0.0, f64::max)
    }

    /// The support: the open interval of points with strictly positive membership, returned as `(left_boundary, right_boundary)`.
    pub fn support(&self) -> (f64, f64) {
        let pts = &self.points;
        assert!(
            !pts.is_empty(),
            "support of an empty fuzzy set is undefined"
        );
        let mut left = pts[0].0;
        let mut right = pts[pts.len() - 1].0;
        let mut found = false;
        for w in pts.windows(2) {
            let (x0, y0) = w[0];
            let (x1, y1) = w[1];
            if y0 > 0.0 || y1 > 0.0 {
                if !found {
                    left = if y0 > 0.0 {
                        x0
                    } else {
                        cross(x0, y0, x1, y1, 0.0)
                    };
                    found = true;
                }
                right = if y1 > 0.0 {
                    x1
                } else {
                    cross(x0, y0, x1, y1, 0.0)
                };
            }
        }
        if !found {
            return (pts[0].0, pts[0].0);
        }
        (left, right)
    }

    /// The core: the set of points with membership exactly `1`.
    pub fn core(&self) -> Vec<(f64, f64)> {
        self.alpha_cut(1.0)
    }

    /// The alpha-cut `{x : mu(x) >= alpha}` as a list of closed intervals.
    ///
    /// At `alpha = 0` the whole span of the set is returned; at
    /// `alpha = 1` this is the core.
    pub fn alpha_cut(&self, alpha: f64) -> Vec<(f64, f64)> {
        let pts = &self.points;
        let mut result = Vec::new();
        if pts.is_empty() {
            return result;
        }
        let (first, last) = (pts[0].0, pts[pts.len() - 1].0);
        if alpha <= 0.0 {
            return vec![(first, last)];
        }
        if alpha > self.height() {
            return result;
        }

        let mut start: Option<f64> = None;
        for w in pts.windows(2) {
            let (x0, y0) = w[0];
            let (x1, y1) = w[1];
            match (y0 >= alpha, y1 >= alpha) {
                (true, true) => {
                    if start.is_none() {
                        start = Some(x0);
                    }
                }
                (true, false) => {
                    let s = start.unwrap_or(x0);
                    let cx = cross(x0, y0, x1, y1, alpha);
                    result.push((s, cx));
                    start = None;
                }
                (false, true) => {
                    let cx = cross(x0, y0, x1, y1, alpha);
                    start = Some(cx);
                }
                (false, false) => {}
            }
        }
        if let Some(s) = start {
            result.push((s, last));
        }
        result
    }

    /// Reconstruct `mu(x)` from its alpha-cuts (the decomposition theorem).
    ///
    /// The result is the supremum of the given `levels` whose cut still contains `x`, so the finer the grid of levels, the closer the result is to the exact `membership(x)`.
    pub fn decompose_at(&self, x: f64, levels: &[f64]) -> f64 {
        levels
            .iter()
            .copied()
            .filter(|&a| self.membership(x) >= a)
            .fold(0.0, f64::max)
    }

    /// Zadeh union: `max(mu_A, mu_B)` pointwise.
    pub fn union(&self, other: &FuzzySet) -> FuzzySet {
        if self.points.is_empty() {
            return other.clone();
        }
        if other.points.is_empty() {
            return self.clone();
        }
        self.combine(other, |a, b| a.max(b))
    }

    /// Zadeh intersection: `min(mu_A, mu_B)` pointwise.
    pub fn intersection(&self, other: &FuzzySet) -> FuzzySet {
        if self.points.is_empty() || other.points.is_empty() {
            return FuzzySet::new(vec![]);
        }
        self.combine(other, |a, b| a.min(b))
    }

    /// Standard complement: `1 - mu`.
    pub fn complement(&self) -> FuzzySet {
        FuzzySet {
            points: self.points.iter().map(|&(x, y)| (x, 1.0 - y)).collect(),
        }
    }

    /// Combine two sets pointwise: `result(x) = op(self(x), other(x))`.
    ///
    /// Breakpoints of both sets plus every crossing point of the two
    /// functions are collected, so the result is exact for operations such as
    /// `min` and `max`.
    fn combine(&self, other: &FuzzySet, op: impl Fn(f64, f64) -> f64) -> FuzzySet {
        let mut xs: Vec<f64> = self.points.iter().map(|p| p.0).collect();
        xs.extend(other.points.iter().map(|p| p.0));
        self.add_crossings(other, &mut xs);
        xs.sort_by(|a, b| a.partial_cmp(b).unwrap());
        xs.dedup_by(|a, b| (*a - *b).abs() < 1e-12);
        let pts: Vec<(f64, f64)> = xs
            .iter()
            .map(|&x| (x, op(self.membership(x), other.membership(x))))
            .collect();
        FuzzySet {
            points: remove_collinear(pts),
        }
    }

    /// Push the x-coordinates where `self` and `other` are equal into `xs`.
    fn add_crossings(&self, other: &FuzzySet, xs: &mut Vec<f64>) {
        for w in self.points.windows(2) {
            let (fx0, fy0) = w[0];
            let (fx1, fy1) = w[1];
            if fx1 == fx0 {
                continue;
            }
            let af = (fy1 - fy0) / (fx1 - fx0);
            for v in other.points.windows(2) {
                let (gx0, gy0) = v[0];
                let (gx1, gy1) = v[1];
                if gx1 == gx0 {
                    continue;
                }
                let ag = (gy1 - gy0) / (gx1 - gx0);
                if (af - ag).abs() < 1e-12 {
                    continue;
                }
                let lo = fx0.max(gx0);
                let hi = fx1.min(gx1);
                if lo >= hi {
                    continue;
                }
                let x = (af * fx0 - ag * gx0 + gy0 - fy0) / (af - ag);
                if x >= lo && x <= hi {
                    xs.push(x);
                }
            }
        }
    }
}

/// The x where the linear segment through `(x0, y0)`, `(x1, y1)` equals `level`.
fn cross(x0: f64, y0: f64, x1: f64, y1: f64, level: f64) -> f64 {
    x0 + (level - y0) * (x1 - x0) / (y1 - y0)
}

/// Drop an interior breakpoint when it lies on the line through its
/// neighbors (so the function is unchanged with fewer points).
fn remove_collinear(pts: Vec<(f64, f64)>) -> Vec<(f64, f64)> {
    if pts.len() <= 2 {
        return pts;
    }
    let mut out: Vec<(f64, f64)> = Vec::with_capacity(pts.len());
    for &p in &pts {
        out.push(p);
        while out.len() >= 3 {
            let n = out.len();
            let (x0, y0) = out[n - 3];
            let (x1, y1) = out[n - 2];
            let (x2, y2) = out[n - 1];
            let cross_prod = (x1 - x0) * (y2 - y0) - (y1 - y0) * (x2 - x0);
            if cross_prod.abs() < 1e-12 {
                out.remove(n - 2);
            } else {
                break;
            }
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    fn high() -> FuzzySet {
        // "high": 0 below 160, rises 160 -> 190, 1 above 190.
        FuzzySet::new(vec![(140.0, 0.0), (160.0, 0.0), (190.0, 1.0), (210.0, 1.0)])
    }

    fn middle() -> FuzzySet {
        // "middle": 1 on [160, 170], falls 170 -> 180, 0 elsewhere.
        FuzzySet::new(vec![
            (140.0, 0.0),
            (160.0, 1.0),
            (170.0, 1.0),
            (180.0, 0.0),
            (210.0, 0.0),
        ])
    }

    #[test]
    fn young_support_core_height_and_cuts() {
        let young = FuzzySet::new(vec![(0.0, 1.0), (25.0, 1.0), (40.0, 0.0), (100.0, 0.0)]);
        assert_eq!(young.height(), 1.0);
        assert_eq!(young.support(), (0.0, 40.0));
        assert_eq!(young.core(), vec![(0.0, 25.0)]);
        assert_eq!(young.alpha_cut(0.0), vec![(0.0, 100.0)]);
        assert_eq!(young.alpha_cut(0.5), vec![(0.0, 32.5)]);
        assert_eq!(young.alpha_cut(0.25), vec![(0.0, 36.25)]);
        assert_eq!(young.alpha_cut(1.0), vec![(0.0, 25.0)]);
    }

    #[test]
    fn decomposition_matches_membership() {
        let young = FuzzySet::new(vec![(0.0, 1.0), (25.0, 1.0), (40.0, 0.0), (100.0, 0.0)]);
        let levels: Vec<f64> = (0..=20).map(|i| i as f64 / 20.0).collect();
        for x in [10.0, 30.0, 32.5, 39.0] {
            let via_cuts = young.decompose_at(x, &levels);
            assert!((via_cuts - young.membership(x)).abs() < 0.06);
        }
    }

    #[test]
    fn intersection_peaks_at_the_crossing() {
        // high and middle cross where (x-160)/30 = (180-x)/10, i.e. x = 175,
        // with value 0.5.
        let h = high();
        let m = middle();
        let inter = h.intersection(&m);
        assert!((inter.membership(175.0) - 0.5).abs() < 1e-9);
        assert_eq!(inter.membership(160.0), 0.0);
        assert_eq!(inter.membership(180.0), 0.0);
        // The peak is indeed at 175: everywhere else is strictly lower.
        assert!(inter.height() - 0.5 < 1e-9);
        assert!((inter.alpha_cut(0.5).first().unwrap().0 - 175.0).abs() < 1e-9);
    }

    #[test]
    fn union_and_intersection_of_equal_sets_are_the_set() {
        let h = high();
        assert_eq!(h.union(&h), h);
        assert_eq!(h.intersection(&h), h);
    }

    #[test]
    fn de_morgan_laws_hold() {
        let h = high();
        let m = middle();
        let left = h.union(&m).complement();
        let right = h.complement().intersection(&m.complement());
        for x in [150.0, 165.0, 175.0, 185.0, 200.0] {
            assert!((left.membership(x) - right.membership(x)).abs() < 1e-9);
        }
        let left2 = h.intersection(&m).complement();
        let right2 = h.complement().union(&m.complement());
        for x in [150.0, 165.0, 175.0, 185.0, 200.0] {
            assert!((left2.membership(x) - right2.membership(x)).abs() < 1e-9);
        }
    }

    #[test]
    fn excluded_middle_and_contradiction_fail() {
        // A ramp mu(x) = x on [0, 1]. At x = 0.6, mu = 0.6.
        let ramp = FuzzySet::new(vec![(0.0, 0.0), (1.0, 1.0)]);
        let not_ramp = ramp.complement();
        let union = ramp.union(&not_ramp);
        let inter = ramp.intersection(&not_ramp);
        // mu(A ∪ ¬A)(0.6) = max(0.6, 0.4) = 0.6, not 1.
        assert!((union.membership(0.6) - 0.6).abs() < 1e-9);
        // mu(A ∩ ¬A)(0.6) = min(0.6, 0.4) = 0.4, not 0.
        assert!((inter.membership(0.6) - 0.4).abs() < 1e-9);
    }
}

//! Fuzzy numbers on the real line.
//!
//! A fuzzy number models "about x0" as a fuzzy set on the reals.
//! The triangular form `(l, m, r)` rises from `l` to the mode `m` and falls back to `r`.
//! The trapezoidal form `(a, b, c, d)` adds a flat top.
//! Both are piecewise-linear, so their alpha-cuts are closed intervals.

use crate::set::FuzzySet;

/// A triangular fuzzy number `(l, m, r)`, "about `m`".
///
/// Membership is `0` outside `[l, r]`, rises linearly from `l` to the mode
/// `m` (where it is `1`), and falls linearly back to `r`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Triangular {
    /// Left edge: membership is 0 at and below `left`, then rises linearly.
    pub left: f64,
    /// The mode: membership is 1.
    pub mode: f64,
    /// Right edge: membership falls to 0 at `right` and stays 0 above.
    pub right: f64,
}

impl Triangular {
    /// Build a TFN; requires `left < mode < right`.
    pub fn new(left: f64, mode: f64, right: f64) -> Self {
        assert!(
            left < mode && mode < right,
            "a triangular fuzzy number needs left < mode < right"
        );
        Triangular { left, mode, right }
    }

    /// Degree of membership of `x`.
    pub fn membership(&self, x: f64) -> f64 {
        if x <= self.left || x >= self.right {
            0.0
        } else if x <= self.mode {
            (x - self.left) / (self.mode - self.left)
        } else {
            (self.right - x) / (self.right - self.mode)
        }
    }

    /// The alpha-cut as a closed interval `[l + a(m - l), r - a(r - m)]`.
    pub fn alpha_cut(&self, alpha: f64) -> (f64, f64) {
        let a = alpha.clamp(0.0, 1.0);
        (
            self.left + a * (self.mode - self.left),
            self.right - a * (self.right - self.mode),
        )
    }

    /// Componentwise addition (the alpha-cut arithmetic).
    pub fn add(&self, other: Triangular) -> Triangular {
        Triangular::new(
            self.left + other.left,
            self.mode + other.mode,
            self.right + other.right,
        )
    }

    /// Componentwise subtraction.
    pub fn sub(&self, other: Triangular) -> Triangular {
        Triangular::new(
            self.left - other.right,
            self.mode - other.mode,
            self.right - other.left,
        )
    }

    /// Componentwise (approximate) multiplication.
    pub fn mul(&self, other: Triangular) -> Triangular {
        Triangular::new(
            self.left * other.left,
            self.mode * other.mode,
            self.right * other.right,
        )
    }

    /// The same set as a piecewise-linear `FuzzySet`.
    pub fn to_fuzzy_set(&self) -> FuzzySet {
        FuzzySet::new(vec![(self.left, 0.0), (self.mode, 1.0), (self.right, 0.0)])
    }
}

/// A trapezoidal fuzzy number `(a, b, c, d)`: rises `a -> b`, flat on `[b, c]`, falls `c -> d`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Trapezoidal {
    /// Left edge: membership is 0 at and below `a`, then rises linearly.
    pub a: f64,
    /// Plateau start: membership is 1 from `b` on.
    pub b: f64,
    /// Plateau end: membership is 1 up to `c`, then falls linearly.
    pub c: f64,
    /// Right edge: membership is 0 at and above `d`.
    pub d: f64,
}

impl Trapezoidal {
    /// Build a trapezoid; requires `a < b <= c < d`.
    pub fn new(a: f64, b: f64, c: f64, d: f64) -> Self {
        assert!(
            a < b && b <= c && c < d,
            "a trapezoidal fuzzy number needs a < b <= c < d"
        );
        Trapezoidal { a, b, c, d }
    }

    /// Degree of membership of `x`.
    pub fn membership(&self, x: f64) -> f64 {
        if x <= self.a || x >= self.d {
            0.0
        } else if x < self.b {
            (x - self.a) / (self.b - self.a)
        } else if x <= self.c {
            1.0
        } else {
            (self.d - x) / (self.d - self.c)
        }
    }

    /// The alpha-cut as a closed interval.
    pub fn alpha_cut(&self, alpha: f64) -> (f64, f64) {
        let a = alpha.clamp(0.0, 1.0);
        (
            self.a + a * (self.b - self.a),
            self.d - a * (self.d - self.c),
        )
    }

    /// The same set as a piecewise-linear `FuzzySet`.
    pub fn to_fuzzy_set(&self) -> FuzzySet {
        FuzzySet::new(vec![
            (self.a, 0.0),
            (self.b, 1.0),
            (self.c, 1.0),
            (self.d, 0.0),
        ])
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn triangular_membership() {
        let a = Triangular::new(1.0, 2.0, 3.0);
        assert_eq!(a.membership(2.0), 1.0);
        assert!((a.membership(1.5) - 0.5).abs() < 1e-12);
        assert!((a.membership(2.5) - 0.5).abs() < 1e-12);
        assert_eq!(a.membership(0.0), 0.0);
        assert_eq!(a.membership(4.0), 0.0);
    }

    #[test]
    fn triangular_alpha_cuts() {
        let a = Triangular::new(1.0, 4.0, 7.0);
        assert_eq!(a.alpha_cut(0.0), (1.0, 7.0));
        assert_eq!(a.alpha_cut(0.5), (2.5, 5.5));
        assert_eq!(a.alpha_cut(1.0), (4.0, 4.0));
    }

    #[test]
    fn triangular_arithmetic() {
        let a = Triangular::new(1.0, 2.0, 3.0);
        let b = Triangular::new(4.0, 5.0, 6.0);
        assert_eq!(a.add(b), Triangular::new(5.0, 7.0, 9.0));
        assert_eq!(a.sub(b), Triangular::new(-5.0, -3.0, -1.0));
        assert_eq!(a.mul(b), Triangular::new(4.0, 10.0, 18.0));
    }

    #[test]
    fn trapezoidal_membership() {
        let t = Trapezoidal::new(2.0, 2.5, 3.0, 4.5);
        assert_eq!(t.membership(2.5), 1.0);
        assert_eq!(t.membership(3.0), 1.0);
        assert_eq!(t.membership(2.0), 0.0);
        assert_eq!(t.membership(2.25), 0.5);
        assert_eq!(t.membership(3.75), 0.5);
        assert_eq!(t.membership(5.0), 0.0);
    }
}

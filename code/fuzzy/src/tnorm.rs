//! Triangular norms and conorms on the unit interval `[0, 1]`.
//!
//! A t-norm generalizes logical AND to degrees of membership, and an s-norm (a t-conorm) generalizes OR.
//! The three classical families are Zadeh (`min`/`max`), the product (probabilistic) family, and Lukasiewicz.

/// A family of triangular norm (AND) and conorm (OR) on `[0, 1]`.
///
/// Each variant pairs a t-norm with its dual s-norm. The dual is
/// `conorm(a, b) = 1 - norm(1 - a, 1 - b)`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum TNorm {
    /// Zadeh: `min(a, b)` / `max(a, b)`. Idempotent: `min(a, a) = a`.
    Zadeh,
    /// Product (probabilistic): `a * b` / `a + b - a * b`. Not idempotent.
    Product,
    /// Lukasiewicz: `max(0, a + b - 1)` / `min(1, a + b)`. Nilpotent.
    Lukasiewicz,
}

impl TNorm {
    /// The t-norm (AND): how strongly two degrees hold together.
    ///
    /// ```
    /// use fuzzy::TNorm;
    ///
    /// assert_eq!(TNorm::Zadeh.norm(0.6, 0.7), 0.6);
    /// assert!((TNorm::Product.norm(0.6, 0.7) - 0.42).abs() < 1e-12);
    /// assert!((TNorm::Lukasiewicz.norm(0.6, 0.7) - 0.3).abs() < 1e-12);
    /// ```
    pub fn norm(self, a: f64, b: f64) -> f64 {
        match self {
            TNorm::Zadeh => a.min(b),
            TNorm::Product => a * b,
            TNorm::Lukasiewicz => (a + b - 1.0).max(0.0),
        }
    }

    /// The s-norm (OR), dual to the t-norm.
    ///
    /// ```
    /// use fuzzy::TNorm;
    ///
    /// assert_eq!(TNorm::Zadeh.conorm(0.6, 0.7), 0.7);
    /// assert!((TNorm::Product.conorm(0.6, 0.7) - 0.88).abs() < 1e-12);
    /// assert_eq!(TNorm::Lukasiewicz.conorm(0.6, 0.7), 1.0);
    /// ```
    pub fn conorm(self, a: f64, b: f64) -> f64 {
        match self {
            TNorm::Zadeh => a.max(b),
            TNorm::Product => a + b - a * b,
            TNorm::Lukasiewicz => (a + b).min(1.0),
        }
    }

    /// Human-readable name of the family.
    pub fn name(self) -> &'static str {
        match self {
            TNorm::Zadeh => "Zadeh (min/max)",
            TNorm::Product => "product (probabilistic)",
            TNorm::Lukasiewicz => "Lukasiewicz",
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn zadeh_is_min_and_max() {
        assert_eq!(TNorm::Zadeh.norm(0.6, 0.7), 0.6);
        assert_eq!(TNorm::Zadeh.conorm(0.6, 0.7), 0.7);
    }

    #[test]
    fn product_is_product_and_probabilistic_sum() {
        assert!((TNorm::Product.norm(0.6, 0.7) - 0.42).abs() < 1e-12);
        assert!((TNorm::Product.conorm(0.6, 0.7) - 0.88).abs() < 1e-12);
    }

    #[test]
    fn lukasiewicz_clamps() {
        assert!((TNorm::Lukasiewicz.norm(0.6, 0.7) - 0.3).abs() < 1e-12);
        assert_eq!(TNorm::Lukasiewicz.norm(0.4, 0.5), 0.0);
        assert_eq!(TNorm::Lukasiewicz.conorm(0.6, 0.7), 1.0);
    }

    #[test]
    fn lukasiewicz_restores_contradiction() {
        // A and not-A with a = 0.6: max(0, a + (1 - a) - 1) = 0.
        let a = 0.6;
        assert_eq!(TNorm::Lukasiewicz.norm(a, 1.0 - a), 0.0);
        // The other two families do not: min gives 0.4, product gives 0.24.
        assert_eq!(TNorm::Zadeh.norm(a, 1.0 - a), 0.4);
        assert!((TNorm::Product.norm(a, 1.0 - a) - 0.24).abs() < 1e-12);
    }
}

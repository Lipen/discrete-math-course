//! The truncated power series type and its arithmetic.
//!
//! Every operation returns a series whose truncation degree is the largest degree among its inputs.
//! Terms that would land above that degree are dropped, which is exactly what the truncated model prescribes.

/// A formal power series truncated at a fixed degree.
///
/// The series `a_0 + a_1 x + ... + a_N x^N` is stored as `N + 1` coefficients.
/// Coefficients above `N` are unknown and every accessor and operation treats them as zero.
///
/// ```
/// use generating_functions::Series;
///
/// let f = Series::from_coeffs(&[1, 2, 3]);
/// assert_eq!(f.degree(), 2);
/// assert_eq!(f.coeff(1), 2);
/// assert_eq!(f.coeff(7), 0);
/// ```
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Series {
    coeffs: Vec<i64>,
}

impl Series {
    /// The zero series truncated at `degree`.
    ///
    /// ```
    /// use generating_functions::Series;
    /// assert_eq!(Series::zeros(3).coefficients(), &[0, 0, 0, 0]);
    /// ```
    pub fn zeros(degree: usize) -> Series {
        Series {
            coeffs: vec![0; degree + 1],
        }
    }

    /// The series whose constant term is `value` and whose other coefficients are zero.
    ///
    /// The second argument fixes the truncation degree, so `Series::constant(1, 5)` is the constant `1` represented through degree `5`.
    ///
    /// ```
    /// use generating_functions::Series;
    /// assert_eq!(Series::constant(7, 2).coefficients(), &[7, 0, 0]);
    /// ```
    pub fn constant(value: i64, degree: usize) -> Series {
        let mut series = Series::zeros(degree);
        series.coeffs[0] = value;
        series
    }

    /// The series `x` truncated at `degree`.
    ///
    /// With `degree = 0` the term `x` lies above the truncation and the result is zero.
    ///
    /// ```
    /// use generating_functions::Series;
    /// assert_eq!(Series::x(4).coefficients(), &[0, 1, 0, 0, 0]);
    /// ```
    pub fn x(degree: usize) -> Series {
        let mut series = Series::zeros(degree);
        if degree >= 1 {
            series.coeffs[1] = 1;
        }
        series
    }

    /// A series from an explicit coefficient list, lowest degree first.
    ///
    /// The truncation degree is one less than the length of the list.
    /// An empty list gives the zero series of degree `0`.
    ///
    /// ```
    /// use generating_functions::Series;
    /// let f = Series::from_coeffs(&[3, -1, 4]);
    /// assert_eq!(f.coefficients(), &[3, -1, 4]);
    /// ```
    pub fn from_coeffs(coeffs: &[i64]) -> Series {
        if coeffs.is_empty() {
            Series::zeros(0)
        } else {
            Series {
                coeffs: coeffs.to_vec(),
            }
        }
    }

    /// The largest exponent stored, that is, the truncation degree `N`.
    ///
    /// A series always stores at least the constant term, so the degree is well defined.
    pub fn degree(&self) -> usize {
        self.coeffs.len() - 1
    }

    /// The coefficient of `x^k`, or `0` when `k` is above the truncation degree.
    ///
    /// ```
    /// use generating_functions::Series;
    /// let f = Series::from_coeffs(&[1, 2, 3]);
    /// assert_eq!(f.coeff(2), 3);
    /// assert_eq!(f.coeff(3), 0);
    /// ```
    pub fn coeff(&self, k: usize) -> i64 {
        self.coeffs.get(k).copied().unwrap_or(0)
    }

    /// All stored coefficients, from degree `0` through the truncation degree.
    ///
    /// ```
    /// use generating_functions::Series;
    /// assert_eq!(Series::constant(2, 1).coefficients(), &[2, 0]);
    /// ```
    pub fn coefficients(&self) -> &[i64] {
        &self.coeffs
    }

    /// A copy truncated or zero padded to `degree`.
    ///
    /// ```
    /// use generating_functions::Series;
    /// let f = Series::from_coeffs(&[1, 2, 3]);
    /// assert_eq!(f.with_degree(4).coefficients(), &[1, 2, 3, 0, 0]);
    /// assert_eq!(f.with_degree(1).coefficients(), &[1, 2]);
    /// ```
    pub fn with_degree(&self, degree: usize) -> Series {
        let mut coeffs = vec![0; degree + 1];
        let keep = self.coeffs.len().min(degree + 1);
        coeffs[..keep].copy_from_slice(&self.coeffs[..keep]);
        Series { coeffs }
    }

    /// The sum of two series, truncated at the larger of their degrees.
    ///
    /// ```
    /// use generating_functions::Series;
    /// let a = Series::from_coeffs(&[1, 2]);
    /// let b = Series::from_coeffs(&[3, 4, 5]);
    /// assert_eq!(a.add(&b).coefficients(), &[4, 6, 5]);
    /// ```
    pub fn add(&self, other: &Series) -> Series {
        let mut out = Series::zeros(self.degree().max(other.degree()));
        for (k, slot) in out.coeffs.iter_mut().enumerate() {
            *slot = self.coeff(k) + other.coeff(k);
        }
        out
    }

    /// The difference of two series, truncated at the larger of their degrees.
    ///
    /// ```
    /// use generating_functions::Series;
    /// let a = Series::from_coeffs(&[1, 2]);
    /// let b = Series::from_coeffs(&[3, 4, 5]);
    /// assert_eq!(a.sub(&b).coefficients(), &[-2, -2, -5]);
    /// ```
    pub fn sub(&self, other: &Series) -> Series {
        let mut out = Series::zeros(self.degree().max(other.degree()));
        for (k, slot) in out.coeffs.iter_mut().enumerate() {
            *slot = self.coeff(k) - other.coeff(k);
        }
        out
    }

    /// The product of two series, truncated at the larger of their degrees.
    ///
    /// The coefficient of `x^n` in the product is `sum a_k b_(n - k)` over `k = 0..=n`.
    /// When both inputs end at degree `N`, the product is cut back to degree `N`, so use [`Series::with_degree`] first if the full polynomial product is wanted.
    ///
    /// ```
    /// use generating_functions::Series;
    /// let unit = Series::constant(1, 2).add(&Series::x(2));
    /// assert_eq!(unit.mul(&unit).coefficients(), &[1, 2, 1]);
    /// ```
    pub fn mul(&self, other: &Series) -> Series {
        let degree = self.degree().max(other.degree());
        let mut out = Series::zeros(degree);
        for (i, &a) in self.coeffs.iter().enumerate() {
            for (j, &b) in other.coeffs.iter().enumerate() {
                if i + j > degree {
                    break;
                }
                out.coeffs[i + j] += a * b;
            }
        }
        out
    }

    /// Every coefficient multiplied by `factor`.
    ///
    /// ```
    /// use generating_functions::Series;
    /// let f = Series::from_coeffs(&[1, 2, 3]);
    /// assert_eq!(f.scale(10).coefficients(), &[10, 20, 30]);
    /// ```
    pub fn scale(&self, factor: i64) -> Series {
        Series {
            coeffs: self.coeffs.iter().map(|&a| a * factor).collect(),
        }
    }

    /// The term-by-term derivative, with the same truncation degree.
    ///
    /// The coefficient of `x^k` becomes `(k + 1) a_(k + 1)`, and the top coefficient becomes zero because its source lies outside the truncation.
    ///
    /// ```
    /// use generating_functions::Series;
    /// let f = Series::from_coeffs(&[1, 6, 12]);
    /// assert_eq!(f.derivative().coefficients(), &[6, 24, 0]);
    /// ```
    pub fn derivative(&self) -> Series {
        let mut out = Series::zeros(self.degree());
        for (k, &a) in self.coeffs.iter().enumerate().skip(1) {
            out.coeffs[k - 1] = a * k as i64;
        }
        out
    }

    /// The term-by-term integral with zero constant term, with the same truncation degree.
    ///
    /// The coefficient of `x^k` is divided by `k + 1` and moves to degree `k + 1`, while the top input coefficient leaves the truncation.
    /// Division is integer division, so the result is exact only when every division is exact.
    ///
    /// ```
    /// use generating_functions::Series;
    /// let f = Series::from_coeffs(&[6, 24, 0]);
    /// assert_eq!(f.integral().coefficients(), &[0, 6, 12]);
    /// ```
    pub fn integral(&self) -> Series {
        let mut out = Series::zeros(self.degree());
        for (k, &a) in self.coeffs.iter().enumerate().take(self.coeffs.len() - 1) {
            out.coeffs[k + 1] = a / (k as i64 + 1);
        }
        out
    }

    /// The multiplicative inverse, or `None` when the constant term is not `1` or `-1`.
    ///
    /// Integer coefficients can only invert a constant term that is a unit of the integers, so `a_0` must be `1` or `-1`.
    /// Writing `f = a_0 + a_1 x + ...` and `g = 1/f`, the coefficients of `g` follow from `f g = 1`:
    ///
    /// ```text
    /// g_0 = 1 / a_0
    /// g_n = -g_0 * (a_1 g_(n - 1) + ... + a_n g_0)
    /// ```
    ///
    /// ```
    /// use generating_functions::Series;
    /// let f = Series::constant(1, 4).sub(&Series::x(4));
    /// let g = f.inverse().expect("constant term is 1");
    /// assert_eq!(g.coefficients(), &[1, 1, 1, 1, 1]);
    /// assert_eq!(f.mul(&g).coefficients(), &[1, 0, 0, 0, 0]);
    /// ```
    pub fn inverse(&self) -> Option<Series> {
        let a0 = self.coeffs[0];
        if a0 != 1 && a0 != -1 {
            return None;
        }
        let degree = self.degree();
        let mut out = Series::zeros(degree);
        out.coeffs[0] = a0;
        for n in 1..=degree {
            let mut sum = 0;
            for k in 1..=n {
                sum += self.coeff(k) * out.coeff(n - k);
            }
            out.coeffs[n] = -a0 * sum;
        }
        Some(out)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn multiplication_convolves_and_truncates() {
        let unit = Series::constant(1, 2).add(&Series::x(2));
        assert_eq!(unit.mul(&unit).coefficients(), &[1, 2, 1]);

        let a = Series::from_coeffs(&[1, 2, 3]);
        let b = Series::from_coeffs(&[1, -1]);
        assert_eq!(a.mul(&b).coefficients(), &[1, 1, 1]);
    }

    #[test]
    fn addition_subtraction_and_scaling() {
        let a = Series::from_coeffs(&[1, 2]);
        let b = Series::from_coeffs(&[3, 4, 5]);
        assert_eq!(a.add(&b).coefficients(), &[4, 6, 5]);
        assert_eq!(a.sub(&b).coefficients(), &[-2, -2, -5]);
        assert_eq!(a.scale(3).coefficients(), &[3, 6]);
    }

    #[test]
    fn derivative_and_integral_round_trip_through_the_constant() {
        let f = Series::from_coeffs(&[1, 6, 12]);
        assert_eq!(f.derivative().coefficients(), &[6, 24, 0]);
        let g = Series::from_coeffs(&[6, 24, 0]);
        assert_eq!(g.integral().coefficients(), &[0, 6, 12]);
    }

    #[test]
    fn inverse_of_a_unit_constant_term() {
        let f = Series::constant(1, 4).sub(&Series::x(4));
        let g = f.inverse().expect("constant term is 1");
        assert_eq!(g.coefficients(), &[1, 1, 1, 1, 1]);
        assert_eq!(f.mul(&g).coefficients(), &[1, 0, 0, 0, 0]);

        let h = Series::constant(-1, 3).add(&Series::x(3));
        let hi = h.inverse().expect("constant term is -1");
        assert_eq!(h.mul(&hi).coefficients(), &[1, 0, 0, 0]);
    }

    #[test]
    fn inverse_rejects_non_unit_constant_term() {
        assert!(Series::constant(2, 3).inverse().is_none());
        assert!(Series::zeros(3).inverse().is_none());
        assert!(Series::constant(-3, 0).inverse().is_none());
    }

    #[test]
    fn truncation_and_padding() {
        let f = Series::from_coeffs(&[1, 2, 3]);
        assert_eq!(f.degree(), 2);
        assert_eq!(f.coeff(5), 0);
        assert_eq!(f.with_degree(4).coefficients(), &[1, 2, 3, 0, 0]);
        assert_eq!(f.with_degree(1).coefficients(), &[1, 2]);
        assert_eq!(Series::from_coeffs(&[]).degree(), 0);
    }

    #[test]
    fn x_above_the_truncation_is_zero() {
        assert_eq!(Series::x(0).coefficients(), &[0]);
        assert_eq!(Series::x(3).coeff(1), 1);
    }
}

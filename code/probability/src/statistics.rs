//! Sample covariance, correlation, and the moments of a finite data set.
//!
//! The functions treat the data as the whole distribution: means, variances,
//! and covariance divide by `n`, not by `n - 1`.

/// Arithmetic mean of a non-empty slice.
pub fn mean(xs: &[f64]) -> Option<f64> {
    if xs.is_empty() {
        None
    } else {
        Some(xs.iter().sum::<f64>() / xs.len() as f64)
    }
}

/// Population variance of a non-empty slice.
pub fn variance(xs: &[f64]) -> Option<f64> {
    let m = mean(xs)?;
    Some(xs.iter().map(|x| (x - m).powi(2)).sum::<f64>() / xs.len() as f64)
}

/// Population covariance of two equally long, non-empty slices.
pub fn covariance(xs: &[f64], ys: &[f64]) -> Option<f64> {
    if xs.len() != ys.len() || xs.is_empty() {
        return None;
    }
    let mx = mean(xs)?;
    let my = mean(ys)?;
    let n = xs.len() as f64;
    Some(
        xs.iter()
            .zip(ys)
            .map(|(x, y)| (x - mx) * (y - my))
            .sum::<f64>()
            / n,
    )
}

/// Pearson correlation coefficient of two equally long, non-empty slices.
///
/// Returns `None` when either variance is zero, because the coefficient is
/// undefined in that case.
pub fn correlation(xs: &[f64], ys: &[f64]) -> Option<f64> {
    let cov = covariance(xs, ys)?;
    let sx = variance(xs)?.sqrt();
    let sy = variance(ys)?.sqrt();
    if sx == 0.0 || sy == 0.0 {
        None
    } else {
        Some(cov / (sx * sy))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn close(a: f64, b: f64) -> bool {
        (a - b).abs() < 1e-12
    }

    #[test]
    fn mean_and_variance_of_a_small_sample() {
        let xs = [1.0, 2.0, 3.0, 4.0];
        assert_eq!(mean(&xs), Some(2.5));
        assert_eq!(variance(&xs), Some(1.25));
    }

    #[test]
    fn zero_covariance_without_independence() {
        // X is uniform on {-1, 0, 1}, Y = X^2: dependent, yet uncorrelated.
        let xs = [-1.0, 0.0, 1.0];
        let ys = [1.0, 0.0, 1.0];
        assert_eq!(covariance(&xs, &ys), Some(0.0));
        assert_eq!(correlation(&xs, &ys), Some(0.0));
    }

    #[test]
    fn perfect_linear_correlation() {
        let xs = [1.0, 2.0, 3.0, 4.0];
        let ys = [3.0, 5.0, 7.0, 9.0]; // y = 2x + 1
        assert!(close(covariance(&xs, &ys).unwrap(), 2.5));
        assert!(close(correlation(&xs, &ys).unwrap(), 1.0));
    }

    #[test]
    fn mismatch_and_empty_inputs_are_rejected() {
        assert_eq!(covariance(&[1.0], &[1.0, 2.0]), None);
        assert_eq!(covariance(&[], &[]), None);
        assert_eq!(correlation(&[1.0], &[1.0]), None);
    }
}

//! Four discrete distributions from one basic trial.
//!
//! A trial succeeds with probability `p`.
//! The distributions answer three questions: one trial (Bernoulli), the number of successes in `n` trials (binomial), the waiting time for the first success (geometric), and rare events in a large number of trials (Poisson).

/// A discrete probability distribution on non-negative integers.
///
/// Parameters are expected to satisfy `0 <= p <= 1` and `lambda > 0`.
/// Invalid parameters are not rejected, so callers should validate them.
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Distribution {
    /// One trial: 1 with probability `p`, 0 with probability `1 - p`.
    Bernoulli { p: f64 },
    /// Number of successes in `n` independent trials.
    Binomial { n: u64, p: f64 },
    /// Number of trials up to and including the first success.
    Geometric { p: f64 },
    /// Number of rare events with mean `lambda`.
    Poisson { lambda: f64 },
}

impl Distribution {
    /// Probability mass `P(X = k)`.
    pub fn pmf(&self, k: u64) -> f64 {
        match *self {
            Distribution::Bernoulli { p } => match k {
                0 => 1.0 - p,
                1 => p,
                _ => 0.0,
            },
            Distribution::Binomial { n, p } => {
                if k > n {
                    0.0
                } else {
                    binomial(n, k) * p.powi(k as i32) * (1.0 - p).powi((n - k) as i32)
                }
            }
            Distribution::Geometric { p } => {
                if k == 0 {
                    0.0
                } else {
                    (1.0 - p).powi((k - 1) as i32) * p
                }
            }
            Distribution::Poisson { lambda } => {
                (-lambda).exp() * lambda.powi(k as i32) / factorial(k)
            }
        }
    }

    /// Expected value `E[X]`.
    pub fn mean(&self) -> f64 {
        match *self {
            Distribution::Bernoulli { p } => p,
            Distribution::Binomial { n, p } => n as f64 * p,
            Distribution::Geometric { p } => 1.0 / p,
            Distribution::Poisson { lambda } => lambda,
        }
    }

    /// Variance `Var[X]`.
    pub fn variance(&self) -> f64 {
        match *self {
            Distribution::Bernoulli { p } => p * (1.0 - p),
            Distribution::Binomial { n, p } => n as f64 * p * (1.0 - p),
            Distribution::Geometric { p } => (1.0 - p) / (p * p),
            Distribution::Poisson { lambda } => lambda,
        }
    }
}

/// Binomial coefficient `C(n, k)` as a floating-point number.
fn binomial(n: u64, k: u64) -> f64 {
    if k > n {
        return 0.0;
    }
    let k = k.min(n - k);
    let mut result = 1.0;
    for i in 0..k {
        result *= (n - i) as f64 / (i + 1) as f64;
    }
    result
}

/// `k!` as a floating-point number.
fn factorial(k: u64) -> f64 {
    (1..=k).map(|i| i as f64).product()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn close(a: f64, b: f64) -> bool {
        (a - b).abs() < 1e-12
    }

    #[test]
    fn bernoulli_mass_and_moments() {
        let d = Distribution::Bernoulli { p: 0.25 };
        assert!(close(d.pmf(0), 0.75));
        assert!(close(d.pmf(1), 0.25));
        assert_eq!(d.pmf(2), 0.0);
        assert!(close(d.mean(), 0.25));
        assert!(close(d.variance(), 0.1875));
    }

    #[test]
    fn binomial_mass_sums_to_one() {
        let d = Distribution::Binomial { n: 10, p: 0.3 };
        let total: f64 = (0..=10).map(|k| d.pmf(k)).sum();
        assert!(close(total, 1.0));
        assert!(close(d.pmf(0), 0.7_f64.powi(10)));
        assert!(close(d.mean(), 3.0));
        assert!(close(d.variance(), 2.1));
    }

    #[test]
    fn geometric_waiting_time() {
        let d = Distribution::Geometric { p: 0.2 };
        assert!(close(d.pmf(1), 0.2));
        assert!(close(d.pmf(3), 0.8 * 0.8 * 0.2));
        assert!(close(d.mean(), 5.0));
        assert!(close(d.variance(), 20.0));
    }

    #[test]
    fn poisson_mass_sums_to_one() {
        let d = Distribution::Poisson { lambda: 3.0 };
        let total: f64 = (0..50).map(|k| d.pmf(k)).sum();
        assert!((total - 1.0).abs() < 1e-12);
        assert!(close(d.mean(), 3.0));
        assert!(close(d.variance(), 3.0));
    }

    #[test]
    fn binomial_tends_to_poisson_for_rare_events() {
        // n = 1000, p = 0.003 gives lambda = 3.
        let binomial = Distribution::Binomial { n: 1000, p: 0.003 };
        let poisson = Distribution::Poisson { lambda: 3.0 };
        assert!((binomial.pmf(2) - poisson.pmf(2)).abs() < 0.01);
    }
}

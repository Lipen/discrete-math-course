# probability

Discrete distributions and covariance.

Four distributions grow from one trial with success probability $p$: Bernoulli, binomial, geometric, and Poisson.
The statistics module computes mean, variance, covariance, and the Pearson correlation coefficient for finite data sets.

## Quick start

```bash
cargo run --example distributions
cargo test
```

## The model

### Distributions

| Distribution       | Support        | $P(X = k)$                     | Mean      | Variance    |
| ------------------ | -------------- | ------------------------------ | --------- | ----------- |
| Bernoulli$(p)$     | $0, 1$         | $p$ at $1$, $1-p$ at $0$       | $p$       | $p(1-p)$    |
| Binomial$(n, p)$   | $0, \ldots, n$ | $\binom{n}{k} p^k (1-p)^{n-k}$ | $np$      | $np(1-p)$   |
| Geometric$(p)$     | $1, 2, \ldots$ | $(1-p)^{k-1} p$                | $1/p$     | $(1-p)/p^2$ |
| Poisson$(\lambda)$ | $0, 1, \ldots$ | $e^{-\lambda} \lambda^k / k!$  | $\lambda$ | $\lambda$   |

The Poisson distribution is the limit of the binomial one when $n \to \infty$, $p \to 0$, and $np \to \lambda$.
The test `binomial_tends_to_poisson_for_rare_events` compares the two masses at $n = 1000$, $p = 0.003$, $\lambda = 3$.

### Covariance

For data sets $x$ and $y$ of equal length,

$$
\operatorname{Cov}(X, Y) = \frac{1}{n} \sum_{i=1}^{n} (x_i - \bar{x})(y_i - \bar{y}),
\qquad
\rho(X, Y) = \frac{\operatorname{Cov}(X, Y)}{\sigma_X \sigma_Y}.
$$

The functions use the population normalization $1/n$, not the sample normalization $1/(n-1)$.
Correlation returns `None` when either variance is zero.

Independence implies zero covariance, but the converse fails.
The test `zero_covariance_without_independence` uses $X$ uniform on $\{-1, 0, 1\}$ and $Y = X^2$: the variables are dependent, yet their covariance is zero.

## API

| Item                       | Result                                                       |
| -------------------------- | ------------------------------------------------------------ |
| `Distribution`             | `Bernoulli`, `Binomial`, `Geometric`, `Poisson`              |
| `Distribution::pmf(k)`     | $P(X = k)$                                                   |
| `Distribution::mean()`     | $E[X]$                                                       |
| `Distribution::variance()` | $\operatorname{Var}[X]$                                      |
| `mean(xs)`                 | arithmetic mean, `None` for an empty slice                   |
| `variance(xs)`             | population variance, `None` for an empty slice               |
| `covariance(xs, ys)`       | population covariance, `None` for mismatched or empty slices |
| `correlation(xs, ys)`      | Pearson coefficient, `None` for zero variance or bad input   |

## Demos

| Demo            | Shows                                                                                           |
| --------------- | ----------------------------------------------------------------------------------------------- |
| `distributions` | masses and moments of the four distributions, the Poisson tail, and the zero-covariance example |

## Tests

- Bernoulli mass and moments
- binomial mass sums to one, mean and variance
- geometric waiting time
- Poisson mass sums to one, mean equals variance
- binomial approaches Poisson for rare events
- mean and variance of a finite sample
- zero covariance without independence
- perfect linear correlation
- rejected mismatched and empty inputs

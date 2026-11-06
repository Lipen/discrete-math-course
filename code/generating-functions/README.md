# generating-functions

Truncated formal power series and the sequences they encode.

A formal power series is an infinite polynomial read as a sequence of coefficients.
`Series` stores the coefficients from degree $0$ through a chosen degree $N$ and drops the rest.
Addition, multiplication, scaling, differentiation, integration, and inversion all stay inside that truncation, which is enough to recover the first $N + 1$ terms of any algebraic generating function.

## Quick start

```bash
cargo run --example catalan
cargo run --example fibonacci
cargo run --example partitions
cargo test
```

## The model

A series is written

$$A(x) = a_0 + a_1 x + a_2 x^2 + \cdots$$

with coefficients in the integers.
The variable $x$ is a marker for position, not a number, so no convergence question arises.
Truncation at $N$ keeps $a_0, \dots, a_N$ and treats every higher coefficient as zero.
This is consistent: the coefficient of $x^n$ in a sum, product, or quotient depends only on coefficients of degree at most $n$ in the inputs.

The product convolves the coefficients.

$$(A B)_n = \sum_{k=0}^{n} a_k b_{n-k}$$

Division is multiplication by an inverse.
For a series with constant term $a_0 = \pm 1$, the inverse $g = 1/f$ is determined by $f g = 1$:

$$g_0 = \frac{1}{a_0}, \qquad g_n = -g_0 \sum_{k=1}^{n} a_k g_{n-k}$$

The constant term must be a unit of the integers, so `inverse` returns `None` for every other constant term.

The derivative and the integral act term by term.
The derivative maps $a_k$ to $k a_k$ and shifts one degree down.
The integral shifts one degree up and divides by the new exponent, using integer division.
Both keep the truncation degree of the input.

## API

| Item                         | Result                                                                 |
| ---------------------------- | ---------------------------------------------------------------------- |
| `Series::zeros(n)`           | zero series through degree `n`                                         |
| `Series::constant(c, n)`     | the constant `c` represented through degree `n`                        |
| `Series::x(n)`               | the series `x`, truncated at degree `n`                                |
| `Series::from_coeffs(&[..])` | series with the given coefficients, degree one less than the length    |
| `coeff(k)`                   | coefficient of `x^k`, or `0` above the truncation degree               |
| `coefficients()`             | all stored coefficients as a slice                                     |
| `degree()`                   | the truncation degree `N`                                              |
| `with_degree(n)`             | a copy truncated or zero padded to degree `n`                          |
| `add(&other)`, `sub(&other)` | sum and difference, truncated at the larger input degree               |
| `mul(&other)`                | convolution, truncated at the larger input degree                      |
| `scale(c)`                   | every coefficient multiplied by `c`                                    |
| `derivative()`, `integral()` | term-by-term derivative and integral, same truncation degree           |
| `inverse()`                  | multiplicative inverse, `None` unless the constant term is `1` or `-1` |
| `catalan_numbers(n)`         | $C_0$ through $C_n$, the fixed point of $C = 1 + x C^2$                |
| `catalan_series(n)`          | the Catalan generating function truncated at degree `n`                |
| `fibonacci_numbers(n)`       | coefficients of $1/(1 - x - x^2)$, with $F_0 = F_1 = 1$                |
| `fibonacci_series(n)`        | the Fibonacci generating function truncated at degree `n`              |
| `partition_numbers(n)`       | $p(0)$ through $p(n)$                                                  |
| `partition_series(n)`        | the product $\prod_{k=1}^{n} 1/(1 - x^k)$ truncated at degree `n`      |

## Demos

| Demo         | Shows                                                                                    |
| ------------ | ---------------------------------------------------------------------------------------- |
| `catalan`    | the iteration $C \mapsto 1 + x C^2$, the first six iterates, and $C_0$ through $C_{20}$  |
| `fibonacci`  | the denominator $1 - x - x^2$, its inverse, $F_0$ through $F_{20}$, and the golden ratio |
| `partitions` | the factors entering the product, partial products, and $p(0)$ through $p(20)$           |

## Complexity

With truncation degree $N$:

| Operation                | Time     | Memory |
| ------------------------ | -------- | ------ |
| `add`, `sub`, `scale`    | $O(N)$   | $O(N)$ |
| `derivative`, `integral` | $O(N)$   | $O(N)$ |
| `mul`                    | $O(N^2)$ | $O(N)$ |
| `inverse`                | $O(N^2)$ | $O(N)$ |
| `fibonacci_series(N)`    | $O(N^2)$ | $O(N)$ |
| `catalan_series(N)`      | $O(N^3)$ | $O(N)$ |
| `partition_series(N)`    | $O(N^3)$ | $O(N)$ |

The Catalan iteration needs $N$ applications of $C \mapsto 1 + x C^2$, each costing $O(N^2)$.
The partition product needs $N$ inversions and $N$ multiplications, each costing $O(N^2)$.
Coefficients are `i64`, so values beyond about $9 \cdot 10^{18}$ overflow.

## Tests

`cargo test` runs the unit tests in `src/` and the prefix checks in `tests/`.
The unit tests cover convolution and truncation, the inverse recurrence with both signs of the constant term, the rejection of other constant terms, and the derivative and integral round trip.
The prefix checks compare the three sequences against their tables and against the Fibonacci recurrence.

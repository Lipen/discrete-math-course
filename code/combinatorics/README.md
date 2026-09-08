# combinatorics

Combinatorial object generators.

Four families of objects — permutations, combinations, derangements, and integer partitions — each enumerated in lexicographic order.
Every enumeration yields exactly the count the theory predicts: $n!$, $C(n, k)$, and the subfactorial $!n$.

## Quick start

```bash
cargo run --example permutations
cargo run --example combinations
cargo run --example derangements
cargo run --example partitions
cargo test
```

## What the crate generates

| Family             | Object                                     | Count     | Enumeration order |
| ------------------ | ------------------------------------------ | --------- | ----------------- |
| Permutations       | a list of `0..n`, each value once          | $n!$      | lexicographic     |
| Combinations       | a strictly increasing `k`-subset of `0..n` | $C(n, k)$ | lexicographic     |
| Derangements       | a permutation with no fixed point          | $!n$      | lexicographic     |
| Integer partitions | a non-increasing list summing to `n`       | $p(n)$    | lexicographic     |

### The counts

$C(n, k) = \binom{n}{k}$ is the binomial coefficient.
The subfactorial $!n$ obeys the recurrence

$$!n = (n - 1) \cdot \bigl(!(n - 1) + !(n - 2)\bigr), \qquad !0 = 1,\ \ !1 = 0$$

The partition count $p(n)$ comes from the enumeration itself: the crate counts the generated list rather than evaluating a recurrence.

## Demos

| Demo           | Shows                                                                              |
| -------------- | ---------------------------------------------------------------------------------- |
| `permutations` | `next_permutation` on `(2, 4, 1, 3)`, all 6 permutations of `0..3`, the count $5!$ |
| `combinations` | the 2-subsets of `0..4`, $C(10, 5) = 252$                                          |
| `derangements` | the subfactorials $!1..!6$, the derangements of `0..3`                             |
| `partitions`   | the partition counts $p(0)..p(10)$ by enumeration, the partitions of 5             |

## API

| Function                                     | Result                                                      |
| -------------------------------------------- | ----------------------------------------------------------- |
| `factorial(n)`                               | $n!$ (fits in `u64` for $n \le 20$)                         |
| `next_permutation(&mut p)`                   | advance `p` to the next permutation, `false` after the last |
| `permutations(n)`                            | all $n!$ permutations of `0..n`                             |
| `binomial(n, k)`, `count_combinations(n, k)` | $C(n, k)$ (fits in `u64` for $n \le 67$)                    |
| `combinations(n, k)`                         | all $C(n, k)$ `k`-subsets of `0..n`                         |
| `subfactorial(n)`                            | $!n$ (fits in `u64` for $n \le 20$)                         |
| `derangements(n)`                            | all $!n$ derangements of `0..n`                             |
| `partitions(n)`                              | all $p(n)$ partitions of `n`                                |

## Notes

- `next_permutation` uses the three classic steps: find the longest decreasing suffix, swap the pivot with the smallest larger element of the suffix, and reverse the suffix.
- Derangements are enumerated without fixed points: at each position the matching value is skipped.

## Tests

`cargo test` runs the unit tests next to the code in `src/` and the cross-family checks in `tests/`.
The cross-family file verifies that every enumeration matches its formula ($n!$, $C(n, k)$, $!n$) and that the partition count matches the enumerated length.

# combinatorics

Combinatorial object generators.

Four families of objects -- permutations, combinations, derangements, and integer
partitions -- each enumerated in lexicographic order and paired with a rank and unrank
bijection.
The counts match the theory exactly: `n!`, `C(n, k)`, the subfactorial `!n`, and the
partition number `p(n)`.
Every idea has a runnable demo in `examples/`.

## Quick start

```bash
cargo run -p combinatorics --example permutations
cargo run -p combinatorics --example combinations
cargo run -p combinatorics --example derangements
cargo run -p combinatorics --example partitions
cargo test -p combinatorics
```

## What the crate generates

A rank assigns each object its position in the lexicographic enumeration, starting at 0.
Unrank returns the object at a given rank.
Together they form a bijection: `rank(unrank(r)) == r` and `unrank(rank(x)) == x`.
The tests check that each enumeration yields exactly the matching formula.

| Family | Object | Count | Enumeration order | Rank/unrank |
| --- | --- | --- | --- | --- |
| Permutations | a list of `0..n`, each value once | `n!` | lexicographic | factorial number system |
| Combinations | a strictly increasing `k`-subset of `0..n` | `C(n, k)` | lexicographic | subtract prefix blocks |
| Derangements | a permutation with no fixed point | `!n` | lexicographic | memoized completion counting |
| Integer partitions | a non-increasing list summing to `n` | `p(n)` | lexicographic | bounded-part counting |

## API

| Module | Functions |
| --- | --- |
| `permutation` | `next_permutation`, `permutations`, `factorial`, `rank_permutation`, `unrank_permutation` |
| `combination` | `combinations`, `binomial`, `count_combinations`, `rank_combination`, `unrank_combination` |
| `derangement` | `derangements`, `subfactorial`, `rank_derangement`, `unrank_derangement` |
| `partition` | `partitions`, `partition_count`, `rank_partition`, `unrank_partition` |

## Demos

| Demo | Shows |
| --- | --- |
| `permutations` | `next_permutation` on `(2,4,1,3)`; all 6 permutations of `0..3`; rank/unrank over `0..4` |
| `combinations` | The 2-subsets of `0..4`; `C(10,5) = 252`; rank/unrank over 3-subsets of `0..5` |
| `derangements` | The subfactorials `!1..!6`; the derangements of `0..3`; rank/unrank over `0..4` |
| `partitions` | The partition numbers `p(0)..p(10)` with `p(10) = 42`; the partitions of 5; rank/unrank |

## Notes

- `next_permutation` uses the three classic steps: find the longest decreasing suffix,
  swap the pivot with the smallest larger element of the suffix, and reverse the suffix.
- Derangements are enumerated without fixed points: at each position the matching value
  is skipped.
- `p(n)` uses Euler's pentagonal recurrence. Derangement and partition ranking count
  completions with memoization, so they do not materialize the whole list.
- Counts are `u64`: `n!` fits for `n <= 20`, `C(n, k)` for `n <= 67`, `!n` for `n <= 20`,
  and `p(n)` for `n <= 300`-ish.

## Tests

```bash
cargo test -p combinatorics
```

Unit tests live next to the code in `src/`; the cross-family checks that every enumeration
matches its formula and every rank/unrank pair is a bijection live in `tests/`.

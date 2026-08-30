# combinatorics

Combinatorial object generators.

Four families of objects -- permutations, combinations, derangements, and integer
partitions -- each enumerated in lexicographic order.
The counts match the theory exactly: `n!`, `C(n, k)`, and the subfactorial `!n`.
Integer partitions are counted by the length of the enumeration, not by Euler's `p(n)`.
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

Each family is enumerated in lexicographic order.
The tests check that each enumeration yields exactly the matching formula: `n!`,
`C(n, k)`, and `!n`.
Integer partitions are verified by counting the enumerated list.

| Family | Object | Count | Enumeration order |
| --- | --- | --- | --- |
| Permutations | a list of `0..n`, each value once | `n!` | lexicographic |
| Combinations | a strictly increasing `k`-subset of `0..n` | `C(n, k)` | lexicographic |
| Derangements | a permutation with no fixed point | `!n` | lexicographic |
| Integer partitions | a non-increasing list summing to `n` | counted by enumeration | lexicographic |

## API

| Module | Functions |
| --- | --- |
| `permutation` | `next_permutation`, `permutations`, `factorial` |
| `combination` | `combinations`, `binomial`, `count_combinations` |
| `derangement` | `derangements`, `subfactorial` |
| `partition` | `partitions` |

## Demos

| Demo | Shows |
| --- | --- |
| `permutations` | `next_permutation` on `(2,4,1,3)`; all 6 permutations of `0..3`; the count `5!` |
| `combinations` | The 2-subsets of `0..4`; `C(10,5) = 252` |
| `derangements` | The subfactorials `!1..!6`; the derangements of `0..3` |
| `partitions` | The partition counts `p(0)..p(10)` by enumeration; the partitions of 5 |

## Notes

- `next_permutation` uses the three classic steps: find the longest decreasing suffix,
  swap the pivot with the smallest larger element of the suffix, and reverse the suffix.
- Derangements are enumerated without fixed points: at each position the matching value
  is skipped.
- Counts are `u64`: `n!` fits for `n <= 20`, `C(n, k)` for `n <= 67`, and `!n` for
  `n <= 20`.

## Tests

```bash
cargo test -p combinatorics
```

Unit tests live next to the code in `src/`; the cross-family checks that every enumeration
matches its formula (`n!`, `C(n, k)`, `!n`) and that the partition count matches the
enumerated length live in `tests/`.

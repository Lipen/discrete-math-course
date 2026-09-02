# matroids

Matroids and the greedy algorithm.

The independence axioms, three concrete matroids (graphic, linear over GF(2), uniform), the scheduling matroid, the rank function, and the key fact that the greedy algorithm is optimal on a matroid.

## Quick start

```bash
cargo run --example spanning
cargo run --example scheduling
cargo run --example linear
cargo run --example rank
cargo test
```

## The idea

A matroid is a ground set with a family of independent sets satisfying two axioms.

- *Heredity*: every subset of an independent set is independent.
- *Exchange*: if `A` and `B` are independent and $|B| > |A|$, some element of $B \setminus A$ can be added to `A` keeping it independent.

On a matroid the greedy algorithm finds a maximum-weight independent set: take elements in decreasing weight order while independence holds.
On any other independence system the same procedure can be fooled.

Concrete systems in the crate:

| System                     | Ground set                 | Independent sets                        |
| -------------------------- | -------------------------- | --------------------------------------- |
| `UniformMatroid` $U_{k,n}$ | `n` elements               | subsets of size at most `k`             |
| `GraphicMatroid`           | edge indices of a graph    | acyclic edge subsets (forests)          |
| `BinaryLinearMatroid`      | rows of a binary matrix    | linearly independent subsets over GF(2) |
| `SchedulingMatroid`        | job indices with deadlines | sets of jobs schedulable by deadlines   |

The rank function `rank(m)` returns the size of a maximum independent set.
Greedy with unit weights returns a base, and all bases of a matroid have the same size, so the rank is well-defined.

## Demos

| Demo         | What it shows                                                                           |
| ------------ | --------------------------------------------------------------------------------------- |
| `spanning`   | Kruskal as greedy on the graphic matroid: maximum spanning tree of a triangle, weight 9 |
| `scheduling` | jobs with deadlines as a matroid: greedy picks `{A, C}` with profit 80                  |
| `linear`     | linear matroid over GF(2): three vectors, greedy picks `{v1, v2}` with weight 9         |
| `rank`       | rank of the graphic, linear and uniform matroids: all equal 2                           |

## API

| Item                   | What it does                                                         |
| ---------------------- | -------------------------------------------------------------------- |
| `Matroid` trait        | `n()` plus `is_independent(&[u32]) -> bool`, the independence oracle |
| `greedy(m, weights)`   | maximum-weight independent set on a matroid                          |
| `rank(m)`              | size of a maximum independent set (greedy with unit weights)         |
| `weight(set, weights)` | total weight of a chosen set                                         |
| `UniformMatroid`       | uniform matroid $U_{k,n}$, fields `n`, `k`                           |
| `GraphicMatroid`       | graphic matroid of an edge list, fields `vertices`, `edges`          |
| `BinaryLinearMatroid`  | linear matroid over GF(2), field `vectors`                           |
| `SchedulingMatroid`    | scheduling matroid, field `deadlines`                                |

## Tests

`cargo test` runs two integration files.
`greedy_test.rs` checks that greedy is optimal on the uniform, graphic, and scheduling matroids.
`linear_rank_test.rs` checks GF(2) independence, greedy on the linear matroid, the ranks of all four systems, and that every base of a matroid has the same size regardless of the weights.

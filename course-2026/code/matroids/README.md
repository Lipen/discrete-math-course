# matroids

Matroids and the greedy algorithm.

The independence axioms define a matroid, and the exchange axiom makes the greedy algorithm provably optimal on it.
Four concrete systems implement the axioms.

## Quick start

```bash
cargo run --example spanning
cargo run --example scheduling
cargo run --example linear
cargo run --example rank
cargo test
```

## The idea

A matroid is a finite ground set with a family of independent sets $\mathcal{I}$ satisfying two axioms.
Heredity requires that every subset of an independent set be independent:

$$A \in \mathcal{I},\ B \subseteq A \implies B \in \mathcal{I}$$

Exchange requires that some element of the larger independent set can be added to the smaller one:

$$A, B \in \mathcal{I},\ |A| < |B| \implies \exists\, x \in B \setminus A:\ A \cup \{x\} \in \mathcal{I}$$

### The greedy guarantee

On a matroid the greedy algorithm finds a maximum-weight independent set:

$$\operatorname{greedy}(M, w) \in \operatorname{arg\,max}_{I \in \mathcal{I}} \; \sum_{e \in I} w(e)$$

The procedure takes elements in decreasing weight order while independence holds.
On any other independence system the same procedure can be fooled.

### The systems of the crate

| System                     | Ground set                 | Independent sets                        |
| -------------------------- | -------------------------- | --------------------------------------- |
| `UniformMatroid` $U_{k,n}$ | `n` elements               | subsets of size at most `k`             |
| `GraphicMatroid`           | edge indices of a graph    | acyclic edge subsets (forests)          |
| `BinaryLinearMatroid`      | rows of a binary matrix    | linearly independent subsets over GF(2) |
| `SchedulingMatroid`        | job indices with deadlines | sets of jobs schedulable by deadlines   |

### Rank

$$r(M) = \max_{I \in \mathcal{I}} |I|$$

The function `rank(m)` computes the rank as greedy with unit weights.
Greedy returns a base, and the exchange property forces all bases of a matroid to have the same size, so the rank is well-defined.

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

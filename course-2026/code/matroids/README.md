# matroids

Matroids and the greedy algorithm.

Implements the matroids chapter: the independence axioms, three matroids
(graphic, linear over GF(2), uniform), the scheduling matroid, the rank
function, and the key fact that the greedy algorithm is optimal exactly when
the independence system is a matroid. The counterexample demo shows greedy
failing on a non-matroid.

## Quick start

```bash
cargo run -p matroids --example counterexample
cargo run -p matroids --example spanning
cargo run -p matroids --example scheduling
cargo run -p matroids --example linear
cargo run -p matroids --example rank
cargo test -p matroids
```

## The idea

A matroid is a ground set with a family of independent sets satisfying two axioms:

- *Heredity*: every subset of an independent set is independent.
- *Exchange*: if `A` and `B` are independent and `|B| > |A|`, some element of
  `B \ A` can be added to `A` keeping it independent.

On a matroid the greedy algorithm (take elements in decreasing weight order
while independence holds) finds a maximum-weight independent set.
On any other independence system, greedy can be fooled.

## Demos

| Demo | What it shows |
|------|---------------|
| `counterexample` | Greedy takes `{a}` (weight 5) while the optimum `{b,c}` weighs 8: the exchange property is missing |
| `spanning` | Kruskal as greedy on the graphic matroid: maximum spanning tree of a triangle, weight 9 |
| `scheduling` | Jobs with deadlines as a matroid: greedy picks `{A,C}` with profit 80 |
| `linear` | Linear matroid over GF(2): the three book vectors, greedy picks `{v1,v2}` with weight 9 |
| `rank` | Rank of the graphic, linear and uniform matroids: all equal 2 |

## API

| Item | What it does |
|------|--------------|
| `Matroid` trait | `n()` + `is_independent(&[u32]) -> bool` |
| `greedy(m, weights)` | Maximum-weight independent set on a matroid |
| `rank(m)` | Size of a maximum independent set (via greedy with unit weights) |
| `UniformMatroid`, `GraphicMatroid`, `BinaryLinearMatroid`, `SchedulingMatroid` | The three book matroids plus the scheduling matroid |
| `SimpleIndependenceSystem` | A non-matroid, to show greedy can fail |

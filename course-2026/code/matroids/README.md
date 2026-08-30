# matroids

Matroids and the greedy algorithm.

The independence axioms, three matroids
(graphic, linear over GF(2), uniform), the scheduling matroid, the rank
function, and the key fact that the greedy algorithm is optimal on a
matroid.

## Quick start

```bash
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

## Demos

| Demo | What it shows |
|------|---------------|
| `spanning` | Kruskal as greedy on the graphic matroid: maximum spanning tree of a triangle, weight 9 |
| `scheduling` | Jobs with deadlines as a matroid: greedy picks `{A,C}` with profit 80 |
| `linear` | Linear matroid over GF(2): the three vectors, greedy picks `{v1,v2}` with weight 9 |
| `rank` | Rank of the graphic, linear and uniform matroids: all equal 2 |

## API

| Item | What it does |
|------|--------------|
| `Matroid` trait | `n()` + `is_independent(&[u32]) -> bool` |
| `greedy(m, weights)` | Maximum-weight independent set on a matroid |
| `rank(m)` | Size of a maximum independent set (via greedy with unit weights) |
| `UniformMatroid`, `GraphicMatroid`, `BinaryLinearMatroid`, `SchedulingMatroid` | The three matroids plus the scheduling matroid |

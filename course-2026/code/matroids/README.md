# matroids

Matroids and the greedy algorithm.

Implements the matroids chapter: the independence axioms, three matroids
(graphic, linear, uniform), the scheduling matroid, and the key fact that the
greedy algorithm is optimal exactly when the independence system is a matroid.
The counterexample demo shows greedy failing on a non-matroid.

## Quick start

```bash
cargo run -p matroids --example counterexample
cargo run -p matroids --example spanning
cargo run -p matroids --example scheduling
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

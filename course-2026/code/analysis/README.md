# analysis

Abstract interpretation: abstract domains, transfer functions, and widening.

The sign, interval, and constant domains; abstract arithmetic on them; and transfer
functions over a tiny imperative program.
Loops are analyzed by computing a fixpoint; on the infinite interval and
constant domains widening makes the iteration converge.

## Quick start

```bash
cargo run -p analysis --example sign_analysis
cargo run -p analysis --example interval_analysis
cargo run -p analysis --example constant_propagation
cargo run -p analysis --example distributive_flow
cargo test -p analysis
```

## The core idea

A program runs on abstract values instead of concrete ones.
Assignments evaluate expressions abstractly; an `if` merges both branches with
the join ⊔; a `while` loop iterates its body to a fixpoint.
The sign lattice is finite, so plain iteration converges; the interval and
constant lattices are infinite, so loops are iterated with widening:

$$ w_{k+1} = w_k \nabla F(w_k) $$

The interval demo runs the counter loop: naive iteration
climbs `[0,0], [0,1], [0,2], ...` forever, while widening drops the moving
bound and converges on `[0, +∞)` in two steps.
The constant demo shows the key insight that zero times unknown is still zero.

## API

| Item | Purpose |
| --- | --- |
| `Sign` | The five-element sign lattice (−, 0, +, ⊥, ⊤) with `+`, `*`, `-`, and `lub` |
| `Interval` | The interval domain with `+`, `*`, `-`, `lub`, and `widen` (∇) |
| `Const` | The constant domain with `+`, `*`, `-`, `lub`, and `widen` (∇) |
| `Expr`, `Stmt` | A tiny imperative program |
| `eval_sign`, `exec_sign` | Sign-domain transfer functions |
| `eval_interval`, `exec_interval` | Interval-domain transfer functions with widening |
| `eval_const`, `exec_const` | Constant-domain transfer functions with widening |

## Demos

| Demo | Shows |
| --- | --- |
| `sign_analysis` | The cost of abstraction: `+ ⊞ − = ⊤`, and branch merging via the join |
| `interval_analysis` | The counter loop: widening turns a diverging iteration into a fixpoint |
| `constant_propagation` | Constants through arithmetic, branch-induced precision loss, and 0·⊤ = 0 |
| `distributive_flow` | Why distributivity of flow functions matters: `f(x ⊔ y)` vs `f(x) ⊔ f(y)` on a monotone and a distributive function |

## Tests

```bash
cargo test -p analysis
```

Tests cover the abstract-arithmetic tables for all three domains, branch
merging, widening edge cases, fixpoint convergence on while loops, and the
zero-times-unknown insight of constant propagation.

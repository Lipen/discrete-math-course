# analysis

Abstract interpretation: abstract domains, transfer functions, and widening.

Implements the theory from the abstract-interpretation chapter: the sign, interval, and constant domains; abstract arithmetic on them; and transfer functions over a tiny imperative program.
Loops are analyzed by computing a fixpoint; on the infinite interval domain widening makes the iteration converge.

## Quick start

```bash
cargo run -p analysis --example sign_analysis
cargo run -p analysis --example interval_analysis
cargo test -p analysis
```

## The core idea

A program runs on abstract values instead of concrete ones.
Assignments evaluate expressions abstractly; an `if` merges both branches with the join ⊔; a `while` loop iterates its body to a fixpoint.
The sign lattice is finite, so plain iteration converges; the interval lattice is infinite, so loops are iterated with widening:

$$ w_{k+1} = w_k \nabla F(w_k) $$

The interval demo runs the counter loop from the chapter: naive iteration climbs `[0,0], [0,1], [0,2], ...` forever, while widening drops the moving bound and converges on `[0, +∞)` in two steps.

## API

| Item | Purpose |
| --- | --- |
| `Sign` | The five-element sign lattice (−, 0, +, ⊥, ⊤) with `+`, `*`, unary `-`, and `lub` |
| `Interval` | The interval domain with `+`, `*`, unary `-`, `lub`, and `widen` (∇) |
| `Const` | The constant domain |
| `Expr`, `Stmt` | A tiny imperative program |
| `eval_sign`, `exec_sign` | Sign-domain transfer functions |
| `eval_interval`, `exec_interval` | Interval-domain transfer functions with widening |

## Demos

| Demo | Shows |
| --- | --- |
| `sign_analysis` | The cost of abstraction: `+ ⊞ − = ⊤`, and branch merging via the join |
| `interval_analysis` | The counter loop: widening turns a diverging iteration into a fixpoint |

## Tests

```bash
cargo test -p analysis
```

Tests check the abstract-arithmetic tables, branch merging, interval widening on the counter loop, and the fixpoint result.

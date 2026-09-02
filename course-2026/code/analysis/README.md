# analysis

Abstract interpretation: the constant domain, transfer functions, and fixed-point iteration.

A tiny imperative program is analyzed on abstract values.
The constant domain tracks which variables hold a known integer: ⊥ is unreachable, ⊤ is "not a constant".
Assignments evaluate expressions abstractly, an `if` merges both branches with the join ⊔, and a `while` loop iterates its body to a fixpoint by Kleene iteration.

## Quick start

```bash
cargo run --example constant_propagation
cargo run --example distributive_flow
cargo test
```

## The core idea

A program runs on abstract values instead of concrete ones.
Assignments evaluate expressions abstractly, an `if` merges both branches with the join, and a `while` loop iterates its body to a fixpoint.
The loop is analyzed by Kleene iteration from the loop-head state: after each pass the state is joined with the loop-head entry state, and the iteration stops once it stabilizes.
Because the join of two different constants is ⊤ (and every operation preserves ⊤), the iteration converges quickly.
The demo shows the key insight of constant propagation: zero times unknown is still zero.

## Demos

| Demo                    | Shows                                                                                                                             |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `constant_propagation`  | Constants through arithmetic, branch-induced precision loss, and $0 \cdot \top = 0$                                               |
| `distributive_flow`     | Why distributivity of flow functions matters: $f(x \sqcup y)$ versus $f(x) \sqcup f(y)$ on a monotone and a distributive function |

## API

| Item                        | Purpose                                                                        |
| --------------------------- | ------------------------------------------------------------------------------ |
| `Const`                     | The constant domain (⊥, known values, ⊤) with `+`, `*`, `-`, and `lub` (⊔)     |
| `Expr`, `Stmt`              | A tiny imperative program                                                      |
| `eval_const`, `exec_const`  | Constant-domain transfer functions with Kleene fixed-point iteration           |

## Tests

Unit tests cover the constant-domain lattice and arithmetic, branch merging, Kleene fixed-point convergence on a `while` loop, and the zero-times-unknown insight of constant propagation.

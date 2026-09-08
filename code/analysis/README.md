# analysis

Abstract interpretation: the constant domain, transfer functions, and fixed-point iteration.

A tiny imperative program is analyzed on abstract values.
The constant domain tracks which variables hold a known integer: ⊥ is unreachable, ⊤ is "not a constant".

## Quick start

```bash
cargo run --example constant_propagation
cargo run --example distributive_flow
cargo test
```

## The model

### The constant lattice

The information order puts ⊥ below every known constant below ⊤, and two different constants are incomparable:

$$\bot \;\sqsubset\; n \;\sqsubset\; \top \quad (n \in \mathbb{Z}) \qquad m \,\parallel\, n \quad (m \neq n)$$

The join merges branch states: equal values stay, different constants fall to ⊤, and ⊥ is neutral.

| $x \sqcup y$ | ⊥            | $n$                    | ⊤   |
| ------------ | ------------ | ---------------------- | --- |
| ⊥            | ⊥            | $n$                    | ⊤   |
| $m$          | $m$          | $m$ if $m = n$, else ⊤ | ⊤   |
| ⊤            | ⊤            | ⊤                      | ⊤   |

### Transfer functions

Assignments evaluate expressions abstractly:

- abstract `+` is known only when both operands are known, and any ⊥ operand makes the result ⊥
- abstract `*` multiplies known constants and kills uncertainty at zero: $0 \cdot \top = 0$
- abstract negation flips the sign of a known constant and leaves ⊥ and ⊤ unchanged

An `if` runs both branches on copies of the state and merges the results with ⊔.

### Kleene iteration

A `while` loop is analyzed from the loop-head state $E$: each pass computes the body on the current state, joins the result with $E$, and stops once the state no longer changes:

$$d_{k+1} \;=\; E \;\sqcup\; F_B(d_k)$$

Because the join of two different constants is ⊤ (and every operation preserves ⊤), the ascending chain is short and the iteration converges in a few passes.

## Demos

| Demo                    | Shows                                                                                                                             |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `constant_propagation`  | Constants through arithmetic, branch-induced precision loss, and $0 \cdot \top = 0$                                               |
| `distributive_flow`     | Why distributivity of flow functions matters: $f(x \sqcup y)$ versus $f(x) \sqcup f(y)$ on a monotone and a distributive function |

`distributive_flow` contrasts a monotone flow function, which can gain facts from a merged input ($f(x \sqcup y) \supsetneq f(x) \sqcup f(y)$), with a distributive one, where both orders agree — the property the IFDS class of analyses relies on.

## API

| Item                       | Purpose                                                                        |
| -------------------------- | ------------------------------------------------------------------------------ |
| `Const`                    | The constant domain (⊥, known values, ⊤) with `+`, `*`, `-`, and `lub` (⊔)     |
| `Expr`, `Stmt`             | A tiny imperative program                                                      |
| `State<D>`                 | An abstract state: a value per variable                                        |
| `eval_const`               | Abstract evaluation of an expression in the constant domain                    |
| `exec_const`               | Run statements: assignments transfer, branches merge, loops reach a fixpoint   |
| `assign`, `inc`            | Builders for `x := n` and `x := x + 1`                                         |

## Tests

- the lattice laws of the constant domain and its abstract arithmetic
- branch merging and the precision it loses
- Kleene fixed-point convergence on a `while` loop
- the zero-times-unknown rule on a branch result

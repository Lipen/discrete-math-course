# bdd

Reduced ordered binary decision diagrams (ROBDDs) with complement edges.

Implements the BDD machinery from the boolean-algebra chapter: a node table with the unique-node rule, reduction (dropping redundant nodes), and complement edges so negation costs nothing.
The fundamental operation is `ite`; `and`, `or`, and `xor` are its special cases.

## Quick start

```bash
cargo run -p bdd --example bdd_demo
cargo test -p bdd
```

## How it works

A BDD represents a boolean function by Shannon expansion: a node `(v, lo, hi)` means "if variable `v` then `hi` else `lo`".
Reduction and node sharing make the representation canonical: for a fixed variable order every function has exactly one ROBDD.
Complement edges store negation as a flag on the edge, so `not` never builds a new node and the diagram for `x XOR y` stays tiny.

![The ROBDD for x XOR y from the chapter](assets/xor-bdd.svg)

## API

| Item | Purpose |
| --- | --- |
| `Bdd::var` | The BDD for a single variable |
| `Bdd::not`, `and`, `or`, `xor` | Boolean operations built on `ite` |
| `Bdd::ite` | The fundamental ternary operator `ite(f, g, h)` |
| `Bdd::eval` | Evaluate the function under an assignment |
| `Bdd::size` | Number of nodes (including the constant) |

## Demo

| Demo | Shows |
| --- | --- |
| `bdd_demo` | Building the ROBDD for `x XOR y`, evaluating it, and checking that `NOT` is free |

## Tests

```bash
cargo test -p bdd
```

Functions are checked against reference truth tables over all assignments; the sharing and reduction rules are tested directly.

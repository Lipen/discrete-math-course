# bdd

Reduced ordered binary decision diagrams (ROBDDs) with complement edges.

Under a fixed variable order every boolean function has exactly one ROBDD, so satisfiability, tautology, and equivalence checks reduce to comparing single edges.
The manager builds each subdiagram once and shares it, and negation rides on the edges instead of costing new nodes.

## Quick start

```bash
cargo run --example bdd_demo
cargo run --example var_order
cargo run --example expr_demo
cargo run --example visualize
cargo test
```

## How it works

A BDD represents a boolean function by Shannon expansion:

$$f \;=\; (\lnot v \land f|_{v=0}) \;\lor\; (v \land f|_{v=1})$$

A node `(v, lo, hi)` stores one such split: follow `lo` when `v` is false and `hi` when `v` is true.
The fundamental operation is `ite(f, g, h)` — if `f` then `g` else `h` — and `and`, `or`, and `xor` are its special cases.
Memoization builds each subresult once.
Reduction and node sharing make the representation canonical: a node whose `lo` and `hi` coincide is dropped, and equal subgraphs merge into a single node.
Complement edges store negation as a flag on an edge, so `not` never builds a new node and complement-heavy functions stay compact.

![The ROBDD for x XOR y](assets/xor-bdd.svg)

## Demos

| Demo        | Shows                                                                          |
| ----------- | ------------------------------------------------------------------------------ |
| `bdd_demo`  | Building the ROBDD for `x XOR y`, evaluation, `sat_count`, `restrict`          |
| `var_order` | How variable ordering affects BDD size                                         |
| `expr_demo` | Building BDDs from expressions, equivalence, tautology check                   |
| `visualize` | DOT rendering, an indented tree dump, and the complement-free plain form       |

`var_order` builds the same function twice under different index orders and prints the node counts.
`visualize` writes a DOT file into a temp dir and prints its absolute path.

## API

| Item                                             | Purpose                                                              |
| ------------------------------------------------ | -------------------------------------------------------------------- |
| `Bdd::new`                                       | Create a fresh manager with the constant node                        |
| `Bdd::var`                                       | The BDD for a single variable `x_i`                                  |
| `Bdd::not`, `and`, `or`, `xor`                   | Boolean operations built on `ite`                                    |
| `Bdd::ite`                                       | The fundamental ternary operator `ite(f, g, h)`                      |
| `Bdd::eval`                                      | Evaluate the function under a variable assignment                    |
| `Bdd::sat_count`                                 | Count how many assignments satisfy the function                      |
| `Bdd::restrict`                                  | Fix a variable to a value                                            |
| `Bdd::is_tautology`                              | Check whether the function is always true                            |
| `Bdd::is_satisfiable`                            | Check whether the function has at least one model                    |
| `Bdd::size`                                      | Number of nodes in the manager                                       |
| `Bdd::to_dot`                                    | Render the diagram as a Graphviz DOT string                          |
| `Bdd::to_tree_string`                            | Dump the diagram as an indented tree with sharing marks              |
| `Bdd::to_plain`, `PlainBdd`, `PlainNode`         | The complement-free form of a diagram                                |
| `Edge`, `TRUE` / `FALSE`                         | Node index plus a complement flag in bit 0, `TRUE` = 0, `FALSE` = 1  |
| `Expr`                                           | Boolean expression AST (`Var`, `Not`, `And`, `Or`, `Xor`, `Implies`) |
| `Expr::to_bdd`                                   | Build the BDD for an expression                                      |

## Tests

- boolean operations against reference truth tables
- the unique-table and reduction rules
- `sat_count` on several functions
- `restrict` with and without complement edges
- `ite` base cases
- expression-to-BDD conversion, including tautology detection

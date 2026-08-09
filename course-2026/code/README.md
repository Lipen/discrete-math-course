# code

Rust companion to the discrete-math course.

A workspace of self-contained modules, one per topic.
Each crate is an independent unit: a library, its tests, and runnable examples.
Crates build, test, and run on their own.

## Crates

| Crate | Topic | Highlights |
| --- | --- | --- |
| [`automata`](automata/README.md) | Finite automata and regular languages | DFA, NFA, subset construction, regex via Thompson, minimization, language operations |
| [`codes`](codes/README.md) | Hamming codes | Hamming(7,4), syndrome decoding, single-error correction |
| [`sat`](sat/README.md) | Boolean satisfiability | A DPLL solver with unit propagation and backtracking |
| [`bdd`](bdd/README.md) | Binary decision diagrams | ROBDDs with complement edges, the `ite` operation |
| [`analysis`](analysis/README.md) | Abstract interpretation | Sign, interval, and constant domains; transfer functions; widening |
| [`crypto`](crypto/README.md) | Number theory and cryptography | Modular arithmetic, RSA, real attacks on it |
| [`lambda`](lambda/README.md) | Untyped λ-calculus | Terms, capture-avoiding substitution, β-reduction, Church numerals |
| [`turing`](turing/README.md) | Turing machines | Two-stack tape, transition table, run traces, example machines |

## Layout

Every crate follows the same shape:

```
<workspace root>
└── <crate>/
    ├── Cargo.toml
    ├── src/lib.rs            # library entry point
    ├── src/*.rs              # topic modules
    ├── examples/*.rs         # runnable demos
    └── README.md             # crate guide
```

## Build, test, run

```bash
# Build the whole workspace.
cargo build --workspace

# Run every test in every crate.
cargo test --workspace

# Run one demo from one crate.
cargo run -p <crate> --example <name>

# Lint everything, including demos and tests.
cargo clippy --workspace --all-targets
```

`-p <crate>` selects the crate, `--example <name>` the demo (without the `.rs` suffix).
For example, `cargo run -p automata --example even_ones`.

## How to read the demos

Every demo is written to be read, not just executed.
It prints its inputs, the intermediate steps, and the result.
Names map one-to-one to the concepts of the book chapter.

Each crate README explains its module, lists every demo, and has a diagram:

- [automata/README.md](automata/README.md)
- [codes/README.md](codes/README.md)
- [sat/README.md](sat/README.md)
- [bdd/README.md](bdd/README.md)
- [analysis/README.md](analysis/README.md)
- [crypto/README.md](crypto/README.md)
- [lambda/README.md](lambda/README.md)
- [turing/README.md](turing/README.md)

## Russian version

Read the same guide in Russian: [README.ru.md](README.ru.md).

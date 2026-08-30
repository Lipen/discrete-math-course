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
| [`smt`](smt/README.md) | Satisfiability modulo theories | Difference logic `x - y <= c`, negative-cycle detection via Bellman-Ford; demos: [`solve`](smt/examples/solve.rs), [`unsat`](smt/examples/unsat.rs) |
| [`bdd`](bdd/README.md) | Binary decision diagrams | ROBDDs with complement edges, the `ite` operation |
| [`circuits`](circuits/README.md) | Combinational circuits | Gate DAGs, topological simulation, size/depth, half/full adder, ripple-carry and carry-lookahead adders; demos: [`half_adder`](circuits/examples/half_adder.rs), [`ripple_carry`](circuits/examples/ripple_carry.rs), [`carry_lookahead`](circuits/examples/carry_lookahead.rs), [`fuzz`](circuits/examples/fuzz.rs) |
| [`model-checking`](model-checking/README.md) | CTL model checking | Kripke structures, state labeling, fixed-point semantics of EX/AX/EF/EG/EU; demos: [`mutex`](model-checking/examples/mutex.rs), [`deadlock`](model-checking/examples/deadlock.rs) |
| [`analysis`](analysis/README.md) | Abstract interpretation | Sign, interval, and constant domains; transfer functions; widening |
| [`crypto`](crypto/README.md) | Number theory and cryptography | Modular arithmetic, RSA, real attacks on it |
| [`lambda`](lambda/README.md) | Untyped λ-calculus | Terms, capture-avoiding substitution, β-reduction, Church numerals |
| [`turing`](turing/README.md) | Turing machines | Two-stack tape, transition table, run traces, example machines |
| [`graphs`](graphs/README.md) | Graphs | Simple no-generics model, BFS/DFS, Dijkstra, Kruskal, Euler, bridges, coloring; SVG/DOT/cytoscape/HTML renderers |
| [`matroids`](matroids/README.md) | Matroids | Independence axioms, graphic/linear/uniform/scheduling matroids, rank, greedy optimality; demos: [`counterexample`](matroids/examples/counterexample.rs), [`spanning`](matroids/examples/spanning.rs), [`scheduling`](matroids/examples/scheduling.rs), [`linear`](matroids/examples/linear.rs), [`rank`](matroids/examples/rank.rs) |
| [`prolog`](prolog/README.md) | Logic programming | Terms, unification with the occurs check, SLD resolution with backtracking |
| [`lattices`](lattices/README.md) | Lattices and orders | Join/meet, distributivity, modularity, Birkhoff characterization (M3/N5 forbidden sublattices) |
| [`heyting`](heyting/README.md) | Heyting algebras | Three-element algebra {0, 1/2, 1}, relative pseudo-complement, excluded middle fails; demos: [`values`](heyting/examples/values.rs), [`excluded_middle`](heyting/examples/excluded_middle.rs) |
| [`fitch`](fitch/README.md) | Natural deduction | Fitch-style proof checker, nested subproofs by depth, assumption discharge; demos: [`contrapositive`](fitch/examples/contrapositive.rs), [`rejected`](fitch/examples/rejected.rs) |
| [`algebra`](algebra/README.md) | Algebraic structures | Semigroup/monoid/group/ring/field traits, homomorphisms and quotient groups, finite fields GF(2^m) |
| [`context-free`](context-free/README.md) | Context-free grammars | Parse trees, CNF conversion, CYK recognition, ambiguity check; demos: [`dyck`](context-free/examples/dyck.rs), [`arithmetic`](context-free/examples/arithmetic.rs), [`cnf_cyk`](context-free/examples/cnf_cyk.rs) |

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
Names map one-to-one to the mathematical concepts.

Each crate README explains its module and lists every demo:

- [automata/README.md](automata/README.md)
- [codes/README.md](codes/README.md)
- [sat/README.md](sat/README.md)
- [smt/README.md](smt/README.md)
- [bdd/README.md](bdd/README.md)
- [circuits/README.md](circuits/README.md)
- [model-checking/README.md](model-checking/README.md)
- [analysis/README.md](analysis/README.md)
- [crypto/README.md](crypto/README.md)
- [lambda/README.md](lambda/README.md)
- [turing/README.md](turing/README.md)
- [graphs/README.md](graphs/README.md)
- [matroids/README.md](matroids/README.md)
- [prolog/README.md](prolog/README.md)
- [lattices/README.md](lattices/README.md)
- [heyting/README.md](heyting/README.md)
- [fitch/README.md](fitch/README.md)
- [algebra/README.md](algebra/README.md)
- [context-free/README.md](context-free/README.md)

## Russian version

Read the same guide in Russian: [README.ru.md](README.ru.md).

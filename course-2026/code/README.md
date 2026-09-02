# code

Rust study samples for discrete mathematics: **23 crates, one per topic**.

Each crate is a self-contained study aid — a library, its unit tests, and runnable examples you read like code, not just execute.
Every crate builds, tests, and runs on its own. None imports another.

## Crates, by theme

### Logic

| Crate | Topic | Highlights |
| --- | --- | --- |
| [`sat`](sat/README.md) | Boolean satisfiability | A DPLL solver with unit propagation and backtracking |
| [`smt`](smt/README.md) | Satisfiability modulo theories | Difference logic `x - y <= c`, negative-cycle detection via Bellman-Ford |
| [`fol`](fol/README.md) | First-order logic | Terms, formulas, quantifiers, capture-avoiding substitution, Tarski models, finite-domain validity/satisfiability by enumeration |
| [`fitch`](fitch/README.md) | Natural deduction | Fitch-style proof checker, nested subproofs by depth, assumption discharge |
| [`prolog`](prolog/README.md) | Logic programming | Terms, substitutions, unification with the occurs check, clause databases |
| [`heyting`](heyting/README.md) | Heyting algebras | Three-element algebra {0, 1/2, 1}, relative pseudo-complement, excluded middle fails |
| [`fuzzy`](fuzzy/README.md) | Fuzzy sets and fuzzy logic | Piecewise-linear membership functions, Zadeh operations, t-norms, alpha-cuts, TFN arithmetic |

### Automata, languages, computability

| Crate | Topic | Highlights |
| --- | --- | --- |
| [`automata`](automata/README.md) | Finite automata and regular languages | DFA, NFA, subset construction, language operations |
| [`context-free`](context-free/README.md) | Context-free grammars | Parse trees, CNF conversion, CYK recognition |
| [`turing`](turing/README.md) | Turing machines | Two-stack tape, transition table, run traces, example machines |
| [`codes`](codes/README.md) | Hamming codes | Hamming(7,4), syndrome decoding, single-error correction |

### Lambda calculus and types

| Crate | Topic | Highlights |
| --- | --- | --- |
| [`lambda`](lambda/README.md) | Untyped λ-calculus | Terms, capture-avoiding substitution, β-reduction, Church numerals |
| [`type-theory`](type-theory/README.md) | Simply-typed λ-calculus (λ→) | Types and contexts, the var/app/abs rules, unification-based inference, subject reduction |

### Algebra and structures

| Crate | Topic | Highlights |
| --- | --- | --- |
| [`algebra`](algebra/README.md) | Algebraic structures | Semigroup/monoid/group/ring/field traits, homomorphisms and quotient groups, finite fields GF(2^m) |
| [`lattices`](lattices/README.md) | Lattices and orders | Join/meet, distributivity, modularity, Birkhoff characterization (M3/N5 forbidden sublattices) |
| [`crypto`](crypto/README.md) | Number theory and cryptography | Modular arithmetic, RSA, real attacks on it |

### Graphs and combinatorics

| Crate | Topic | Highlights |
| --- | --- | --- |
| [`graphs`](graphs/README.md) | Graphs | Simple no-generics model, BFS/DFS, Dijkstra, Kruskal, Euler, bridges, coloring, and SVG/DOT/cytoscape/HTML renderers |
| [`matroids`](matroids/README.md) | Matroids | Independence axioms, graphic/linear/uniform/scheduling matroids, rank, greedy optimality |
| [`combinatorics`](combinatorics/README.md) | Combinatorial object generators | Permutations, combinations, derangements, integer partitions in lexicographic order |

### Circuits and verification

| Crate | Topic | Highlights |
| --- | --- | --- |
| [`circuits`](circuits/README.md) | Combinational circuits | Gate DAGs, topological simulation, size/depth, half/full adder, ripple-carry adder |
| [`bdd`](bdd/README.md) | Binary decision diagrams | ROBDDs with complement edges, the `ite` operation |
| [`model-checking`](model-checking/README.md) | CTL model checking | Kripke structures, state labeling, EX/AX single-step modalities |
| [`analysis`](analysis/README.md) | Abstract interpretation | Constant propagation domain: a lattice, a monotone transfer, and Kleene fixed-point iteration |

## Quick start

```bash
cargo build --workspace     # build all 23 crates
cargo test --workspace      # run every test in every crate
cargo clippy --workspace --all-targets   # lint everything, warning-free
```

Each crate README gives the per-crate commands to run from that crate's folder:

```bash
cd <crate>
cargo run --example <name>    # run one demo
```

## Layout

Every crate follows the same shape:

```
<workspace root>
└── <crate>/
    ├── Cargo.toml
    ├── src/lib.rs            # library entry point
    ├── src/*.rs              # topic modules
    ├── examples/*.rs         # runnable demos
    ├── README.md             # crate guide (English)
    └── README.ru.md          # the same guide in Russian
```

## How to read the demos

Every demo is written to be read, not just executed.
It prints its inputs, the intermediate steps, and the result.

Each crate README explains its modules and lists every demo.

## Russian version

Read the same guide in Russian: [README.ru.md](README.ru.md).

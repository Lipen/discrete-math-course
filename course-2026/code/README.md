# code

Rust companion to the discrete-math course: **23 crates, one per topic**.

Each crate is a self-contained study aid -- a library, its unit tests, and
runnable examples you can read like code, not just execute.
Every crate builds, tests, and runs on its own; none imports another.

## Crates, by theme

### Logic

| Crate | Topic | Highlights |
| --- | --- | --- |
| [`sat`](sat/README.md) | Boolean satisfiability | A DPLL solver with unit propagation and backtracking |
| [`smt`](smt/README.md) | Satisfiability modulo theories | Difference logic `x - y <= c`, negative-cycle detection via Bellman-Ford; demos: [`solve`](smt/examples/solve.rs), [`unsat`](smt/examples/unsat.rs) |
| [`fol`](fol/README.md) | First-order logic | Terms, formulas, quantifiers, capture-avoiding substitution, Tarski models, finite-domain validity/satisfiability by enumeration; demos: [`mortal`](fol/examples/mortal.rs), [`quantifier_scope`](fol/examples/quantifier_scope.rs), [`substitution`](fol/examples/substitution.rs), [`validity`](fol/examples/validity.rs) |
| [`fitch`](fitch/README.md) | Natural deduction | Fitch-style proof checker, nested subproofs by depth, assumption discharge; demos: [`contrapositive`](fitch/examples/contrapositive.rs), [`rejected`](fitch/examples/rejected.rs) |
| [`prolog`](prolog/README.md) | Logic programming | Terms, unification with the occurs check, SLD resolution with backtracking |
| [`heyting`](heyting/README.md) | Heyting algebras | Three-element algebra {0, 1/2, 1}, relative pseudo-complement, excluded middle fails; demos: [`values`](heyting/examples/values.rs), [`excluded_middle`](heyting/examples/excluded_middle.rs) |
| [`fuzzy`](fuzzy/README.md) | Fuzzy sets and fuzzy logic | Piecewise-linear membership functions, Zadeh operations (min/max/complement), t-norms, alpha-cuts and decomposition, TFN arithmetic, max-min composition, Mamdani inference with centroid/mean-of-max/bisector defuzzification; demos: [`operations`](fuzzy/examples/operations.rs), [`fuzzy_numbers`](fuzzy/examples/fuzzy_numbers.rs), [`relations`](fuzzy/examples/relations.rs), [`controller`](fuzzy/examples/controller.rs) |

### Automata, languages, computability

| Crate | Topic | Highlights |
| --- | --- | --- |
| [`automata`](automata/README.md) | Finite automata and regular languages | DFA, NFA, subset construction, regex via Thompson, minimization, language operations |
| [`context-free`](context-free/README.md) | Context-free grammars | Parse trees, CNF conversion, CYK recognition, ambiguity check; demos: [`dyck`](context-free/examples/dyck.rs), [`arithmetic`](context-free/examples/arithmetic.rs), [`cnf_cyk`](context-free/examples/cnf_cyk.rs) |
| [`turing`](turing/README.md) | Turing machines | Two-stack tape, transition table, run traces, example machines |
| [`codes`](codes/README.md) | Hamming codes | Hamming(7,4), syndrome decoding, single-error correction |

### Lambda calculus and types

| Crate | Topic | Highlights |
| --- | --- | --- |
| [`lambda`](lambda/README.md) | Untyped λ-calculus | Terms, capture-avoiding substitution, β-reduction, Church numerals |
| [`type-theory`](type-theory/README.md) | Simply-typed λ-calculus (λ→) | Types and contexts, the var/app/abs rules, unification-based inference, subject reduction; demos: [`typed_terms`](type-theory/examples/typed_terms.rs), [`inference`](type-theory/examples/inference.rs), [`subject_reduction`](type-theory/examples/subject_reduction.rs) |

### Algebra and structures

| Crate | Topic | Highlights |
| --- | --- | --- |
| [`algebra`](algebra/README.md) | Algebraic structures | Semigroup/monoid/group/ring/field traits, homomorphisms and quotient groups, finite fields GF(2^m) |
| [`lattices`](lattices/README.md) | Lattices and orders | Join/meet, distributivity, modularity, Birkhoff characterization (M3/N5 forbidden sublattices) |
| [`crypto`](crypto/README.md) | Number theory and cryptography | Modular arithmetic, RSA, real attacks on it |

### Graphs and combinatorics

| Crate | Topic | Highlights |
| --- | --- | --- |
| [`graphs`](graphs/README.md) | Graphs | Simple no-generics model, BFS/DFS, Dijkstra, Kruskal, Euler, bridges, coloring; SVG/DOT/cytoscape/HTML renderers |
| [`matroids`](matroids/README.md) | Matroids | Independence axioms, graphic/linear/uniform/scheduling matroids, rank, greedy optimality; demos: [`counterexample`](matroids/examples/counterexample.rs), [`spanning`](matroids/examples/spanning.rs), [`scheduling`](matroids/examples/scheduling.rs), [`linear`](matroids/examples/linear.rs), [`rank`](matroids/examples/rank.rs) |
| [`combinatorics`](combinatorics/README.md) | Combinatorial object generators | Permutations, combinations, derangements, integer partitions; lexicographic enumeration, rank/unrank; demos: [`permutations`](combinatorics/examples/permutations.rs), [`combinations`](combinatorics/examples/combinations.rs), [`derangements`](combinatorics/examples/derangements.rs), [`partitions`](combinatorics/examples/partitions.rs) |

### Circuits and verification

| Crate | Topic | Highlights |
| --- | --- | --- |
| [`circuits`](circuits/README.md) | Combinational circuits | Gate DAGs, topological simulation, size/depth, half/full adder, ripple-carry adder; demos: [`half_adder`](circuits/examples/half_adder.rs), [`ripple_carry`](circuits/examples/ripple_carry.rs), [`fuzz`](circuits/examples/fuzz.rs) |
| [`bdd`](bdd/README.md) | Binary decision diagrams | ROBDDs with complement edges, the `ite` operation |
| [`model-checking`](model-checking/README.md) | CTL model checking | Kripke structures, state labeling, fixed-point semantics of EX/AX/EF/EG/EU; demos: [`mutex`](model-checking/examples/mutex.rs), [`deadlock`](model-checking/examples/deadlock.rs) |
| [`analysis`](analysis/README.md) | Abstract interpretation | Sign, interval, and constant domains; transfer functions; widening |

## Quick start

```bash
cargo build --workspace     # build all 23 crates
cargo test --workspace      # run every test in every crate
cargo clippy --workspace --all-targets   # lint everything, warning-free

cargo run -p <crate> --example <name>    # run one demo
```

`-p <crate>` selects the crate, `--example <name>` the demo (without the `.rs`
suffix). For example, `cargo run -p automata --example even_ones`.

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
Names map one-to-one to the mathematical concepts.

Each crate README explains its modules and lists every demo.

## Russian version

Read the same guide in Russian: [README.ru.md](README.ru.md).

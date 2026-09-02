# fitch

A Fitch-style natural deduction proof checker for propositional logic.

A proof is a flat list of `Step`s.
Each step carries a formula, a nesting depth (0 = main proof, 1 = inside one subproof, ...), and a justification: an assumption, or a rule applied to earlier lines.
The checker verifies that every inference is a correct instance of its rule and that every referenced line is still in scope — a line inside a discharged subproof can no longer be used.

## Quick start

```bash
cargo run --example contrapositive
cargo run --example rejected
cargo test
```

## The idea

Natural deduction formalizes mathematical proof as a game of introduction and elimination rules.
To prove `A -> B`, assume `A` in a subproof and derive `B`.
To use `A -> B`, combine it with `A` and conclude `B`.
Fitch diagrams draw the subproofs as nested boxes, and here the nesting is the `depth` field.
The rule set is complete for classical propositional logic: double-negation elimination (`Dne`) is the one classical step, and every other rule is intuitionistically valid.

## Demos

| Demo             | What it shows                                                                                               |
| ---              | ---                                                                                                         |
| `contrapositive` | Builds and checks a proof of `(P -> Q) -> (~Q -> ~P)` with two nested subproofs                             |
| `rejected`       | Two invalid proofs — a wrong disjunct and an out-of-scope line — and the error each triggers                |

## API

| Item                                | What it does                                                                                                                                                     |
| ---                                 | ---                                                                                                                                                              |
| `Formula`                           | A propositional formula: `Atom`, `Bottom`, `Not`, `And`, `Or`, `Implies`                                                                                         |
| `atom`, `bottom`, `not`, `and`, `or`, `implies` | Formula constructors                                                                                                                                 |
| `Step { depth, formula, just }`     | One line of a proof                                                                                                                                              |
| `Just`                              | `Assumption` plus the rules: and-intro/elim, or-intro/elim, implies-intro/elim, not-intro/elim, bottom-elim, double-negation elim                                |
| `check(&[Step]) -> Result<(), Error>` | Verifies every step, `Error` names the offending line and the reason                                                                                           |

Formulas are built with constructors and displayed in the usual notation:

```rust
use fitch::{atom, implies, not};

let p = atom("P");
let q = atom("Q");
let contra = implies(implies(p.clone(), q.clone()), implies(not(q), not(p)));
assert_eq!(contra.to_string(), "((P -> Q) -> (¬Q -> ¬P))");
```

Proofs are checked line by line:

```rust
use fitch::{atom, check, or, Just, Step};

// P ⊢ P ∨ Q by ∨-introduction.
let steps = vec![
    Step { depth: 0, formula: atom("P"), just: Just::Assumption },
    Step { depth: 0, formula: or(atom("P"), atom("Q")), just: Just::OrIntroLeft { disj: 1 } },
];
assert!(check(&steps).is_ok());
```

## Tests

Unit proofs cover the contrapositive derivation, double-negation elimination, and or-elimination over two cases.
Rejection tests pin the error for a wrong disjunct, an out-of-scope line, and a rule that derives a formula different from the one stated.

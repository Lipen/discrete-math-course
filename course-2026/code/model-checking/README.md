# model-checking

A model-checking toolkit: CTL state labeling over Kripke structures.

A Kripke structure `(S, R, L)` is a directed graph of states with atom labels. The CTL checker works by *state labeling*: compute, bottom-up over subformulas, the set of states in which each subformula holds. This crate covers the base of that algorithm — atoms, boolean connectives, and the single-step modalities `EX` / `AX`. The fixed-point modalities (`EF`, `EG`, `EU` and their `A`-duals) that compute reachability, liveness, and safety are a later project.

## Quick start

```bash
cargo test -p model-checking
```

## The idea

Model checking answers a verification question: does every (or some) run of a system satisfy a temporal property?

CTL properties are evaluated on the state graph rather than on individual runs. The single-step operators look one transition ahead:

- `EX φ` — *some* successor state satisfies `φ`;
- `AX φ` — *every* successor state satisfies `φ` (vacuously true at a dead end).

The checker labels each state with the subformulas true in it, working bottom-up:

| Operator | Labeling rule |
|----------|---------------|
| atom `p` | states whose `atoms` list contains `p` |
| `¬φ` | complement of `φ`'s label |
| `φ ∧ ψ` / `φ ∨ ψ` | pointwise and / or of the two labels |
| `EX φ` | states with *some* successor in `φ`'s label |
| `AX φ` | states with *every* successor in `φ`'s label |

The `EX` / `AX` steps are exactly the preimage operators `Kripke::pre_exists` / `Kripke::pre_forall`.

## API

| Item | What it does |
|------|--------------|
| `Kripke::new(successors, atoms)` | A Kripke structure with `n` states; `successors[s]` and `atoms[s]` per state |
| `Kripke::pre_exists(set)` / `pre_forall(set)` | Preimage under one transition (the `EX` / `AX` step) |
| `ctl::Formula`, `check(&Kripke, &Formula) -> Vec<bool>` | CTL formulas (`Atom`, `Not`, `And`, `Or`, `Ex`, `Ax`) and the labeling check |

```rust
use model_checking::{check, Formula, Kripke};

// Traffic light: green -> yellow -> red -> green.
let m = Kripke::new(
    vec![vec![1], vec![2], vec![0]],
    vec![vec![0], vec![1], vec![2]], // atoms: 0 = green, 1 = yellow, 2 = red
);

// EX red: some successor is red -- true from yellow.
let next_red = Formula::Ex(Box::new(Formula::Atom(2)));
assert_eq!(check(&m, &next_red), vec![false, true, false]);

// AX green: every successor is green -- true only from red.
let next_green = Formula::Ax(Box::new(Formula::Atom(0)));
assert_eq!(check(&m, &next_green), vec![false, false, true]);
```

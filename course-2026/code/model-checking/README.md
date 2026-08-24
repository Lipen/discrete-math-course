# model-checking

A model-checking toolkit: CTL state labeling, LTL via Büchi automata, a declarative model builder, and a pedagogical symbolic engine.

A Kripke structure `(S, R, L)` is a directed graph of states with atom labels. The CTL checker works by *state labeling*: compute, bottom-up over subformulas, the set of states in which each subformula holds, using the fixed-point characterizations of the temporal operators (`EF`, `AF` are least fixed points, `EG`, `AG` are greatest fixed points). The LTL checker builds a Büchi automaton from the negated property, synchronizes it with the Kripke structure, and tests the product for an accepting cycle; on failure it returns a *lasso* counterexample (a finite prefix plus a repeating cycle).

## Quick start

```bash
cargo run -p model-checking --example mutex
cargo run -p model-checking --example deadlock
cargo run -p model-checking --example ltl_mutex
cargo run -p model-checking --example builder_symbolic
cargo test -p model-checking
```

## The idea

Model checking answers a verification question: does every (or some) run of a system satisfy a temporal property?

**CTL** properties are evaluated on the state graph rather than on individual runs:

- `EX φ` / `AX φ` -- some / every successor state satisfies `φ`;
- `EF φ` / `AF φ` -- some / every path eventually reaches a `φ` state;
- `EG φ` / `AG φ` -- some / every path satisfies `φ` forever;
- `E[φ U ψ]` / `A[φ U ψ]` -- some / every path keeps `φ` until `ψ` holds.

**LTL** properties talk about the runs themselves: `X φ` (next), `F φ` (eventually), `G φ` (always), `φ U ψ` (until), `φ R ψ` (release). The checker treats every state as an initial state: the formula holds iff every infinite run from every state satisfies it. The negated formula is converted to negation normal form (so that negated `U`/`R` formulas become positive `R`/`U` formulas, which the tableau can drive), and a *generalized Büchi automaton* is built from the closure: states are maximal consistent sets of subformulas, transitions enforce the temporal unfoldings (`G φ ∈ X ⟺ φ ∈ X ∧ G φ ∈ Y`, `φ U ψ ∈ X ⟺ ψ ∈ X ∨ (φ ∈ X ∧ φ U ψ ∈ Y)`, ...), and each `U`/`F` subformula contributes an acceptance condition. The product of the automaton with the Kripke structure has an accepting cycle exactly when some run violates the formula; that cycle is unwound into a lasso: `prefix ++ cycle ++ cycle ++ ...`, where `prefix` ends at the cycle entry and the entry reappears at the end of `cycle`, so every consecutive pair (including the wrap-around) is a transition. LTL talks about infinite runs: a dead-end state starts no run, so properties hold vacuously there (add self-loops to check finite-path behavior). The construction is deliberately unoptimized: up to `2^|closure|` automaton states, so formula size is the bottleneck.

The classical applications are concurrent systems: mutual exclusion (`AG ¬(crit₁ ∧ crit₂)`), liveness (`AF crit`), and deadlock freedom (`AG EX true`).

## Demos

| Demo | What it shows |
|------|---------------|
| `mutex` | Two processes sharing a lock, checked in CTL: `AG ¬(crit₁ ∧ crit₂)` holds for the correct protocol and fails for a broken one |
| `deadlock` | A circular wait with a dead-end state: structural scan, `EF deadlock` reachability, and `AG EX true` |
| `ltl_mutex` | The same lock checked in LTL: `G ¬(critA ∧ critB)` passes for the correct protocol; for the broken one the Büchi check returns a lasso counterexample printed as a run of states |
| `builder_symbolic` | The traffic light declared with the `ModelBuilder` DSL and verified in CTL; a 2-bit counter analyzed symbolically with `EF` / `AG` fixed-point iteration |

## API

| Item | What it does |
|------|--------------|
| `Kripke::new(successors, atoms)` | A Kripke structure with `n` states; `successors[s]` and `atoms[s]` per state |
| `Kripke::pre_exists(set)` / `pre_forall(set)` | Preimage under one transition (the `EX` / `AX` step) |
| `ctl::Formula`, `check(&Kripke, &Formula) -> Vec<bool>` | CTL formulas and the labeling check |
| `ltl::Formula` | LTL formulas: `Atom`, `Not`, `And`, `Or`, `X`, `F`, `G`, `U`, `R` |
| `ltl::check(&Kripke, &Formula) -> Result<(), Counterexample>` | LTL check; `Counterexample { prefix, cycle }` is the violating lasso |
| `property::holds(&Kripke, &Prop) -> Result<(), Counterexample>` | Uniform entry point for both logics (`Prop::Ctl` / `Prop::Ltl`); CTL failures carry a path or lasso witness |
| `ModelBuilder` + `Expr` | Declarative, SPIN/SMV-inspired synchronous transition system: `var(name, init)`, `next(name, expr)` (frame rule: unmentioned variables keep their value), `transition(guard)`; `build()` compiles to a `Kripke` over all valuations, with one atom per `(variable, value)` pair |
| `symbolic::BoolExpr`, `symbolic::System` | Boolean formulas (`Var`/`Not`/`And`/`Or`) with `eval`, `sat_count`, `models`; a `System` with `pre_exists`, `pre_forall`, `ef`, `ag` computed by fixed-point iteration over formulas (no BDDs -- exponential by design) |

```rust
use model_checking::{check, Formula, Kripke};

// Traffic light: green -> yellow -> red -> green.
let m = Kripke::new(
    vec![vec![1], vec![2], vec![0]],
    vec![vec![0], vec![1], vec![2]], // atoms: 0 = green, 1 = yellow, 2 = red
);

// EF red: some path reaches red -- true from every state.
let ef_red = Formula::Ef(Box::new(Formula::Atom(2)));
assert_eq!(check(&m, &ef_red), vec![true, true, true]);
```

```rust
use model_checking::{Kripke, ltl};

// The same light: "always green" fails, with a lasso counterexample.
let m = Kripke::new(
    vec![vec![1], vec![2], vec![0]],
    vec![vec![0], vec![1], vec![2]],
);
let always_green = ltl::Formula::G(Box::new(ltl::Formula::Atom(0)));
let err = ltl::check(&m, &always_green).unwrap_err();
assert_eq!(err.prefix, vec![1]);          // starts at yellow
assert_eq!(err.cycle, vec![2, 0, 1]);     // ... then repeats red, green, yellow
```

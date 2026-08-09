# sat

A small DPLL SAT solver.

Implements the DPLL algorithm from the book chapter on SAT: unit propagation and chronological backtracking.
Literals are integers (`v` = variable true, `-v` = variable false); a formula is a list of clauses.

## Quick start

```bash
cargo run -p sat --example dpll_demo
cargo test -p sat
```

## The idea

DPLL decides a variable, propagates unit clauses (clauses with exactly one unassigned literal), and backtracks when a clause becomes false.
The demo runs the solver on the worked example from the chapter:

$$ F = (x_1 \lor x_2 \lor x_3) \land (\neg x_1 \lor x_2) \land (x_2 \lor \neg x_3) \land (\neg x_2 \lor x_3) \land (\neg x_2 \lor \neg x_3) $$

which is unsatisfiable --- DPLL exhausts every branch and reports `None`.

## API

| Item | Purpose |
| --- | --- |
| `Lit`, `Clause` | Literal and clause types |
| `solve` | A satisfying assignment, or `None` when the formula is unsatisfiable |

## Demo

| Demo | Shows |
| --- | --- |
| `dpll_demo` | The UNSAT formula from the chapter, plus a satisfiable one with its model |

## Tests

```bash
cargo test -p sat
```

The solver is checked on satisfiable and unsatisfiable formulas; every returned model is verified against all clauses.

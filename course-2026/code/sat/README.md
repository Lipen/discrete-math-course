# sat

A small DPLL SAT solver -- teaching crate for SAT and NP-completeness.

Implements the Davis-Putnam-Logemann-Loveland algorithm: unit propagation, pure literal elimination, and chronological backtracking.
Literals are integers (`v` = variable true, `-v` = variable false); a formula is a conjunction of clauses.

This is DPLL, not CDCL: clause learning and non-chronological backtracking are deliberately left out of the crate.

## Quick start

```bash
cargo run -p sat --example dpll_demo
cargo run -p sat --example pigeonhole
cargo run -p sat --example random_3sat
cargo test -p sat
```

## The idea

DPLL decides a variable, propagates unit clauses (clauses with exactly one unassigned literal and the rest false), eliminates pure literals (variables that appear only in one polarity), and backtracks when a conflict is found.

The `dpll_demo` example runs the solver with step-by-step trace on the worked example:

$$ F = (x_1 \lor x_2 \lor x_3) \land (\neg x_1 \lor x_2) \land (x_2 \lor \neg x_3) \land (\neg x_2 \lor x_3) \land (\neg x_2 \lor \neg x_3) $$

which is unsatisfiable --- DPLL exhausts every branch and reports `None`.

## API

| Item | Module | Purpose |
| --- | --- | --- |
| `Lit`, `Clause` | `cnf` | Literal and clause type aliases |
| `pos`, `neg` | `cnf` | Create positive/negative literals |
| `var_of`, `lit_idx`, `is_pos` | `cnf` | Literal accessors |
| `clause_satisfied`, `unit_of`, `clause_has_unassigned` | `cnf` | Clause-level helpers |
| `Cnf` | `cnf` | CNF formula: `num_vars`, `clauses`, `new`, `random_3sat` |
| `format_lit`, `format_clause`, `format_cnf` | `cnf` | Display helpers |
| `solve` | `dpll` | Find a model or return `None` if UNSAT |
| `solve_traced` | `dpll` | Solve with step-by-step trace printed to stdout |

## Demo

| Demo | Shows |
| --- | --- |
| `dpll_demo` | The UNSAT formula (traced), plus a satisfiable one with pure literal elimination |
| `pigeonhole` | PHP(n, n-1) pigeonhole principle formulas are UNSAT (n=2..5), a classic hard case for SAT solvers |
| `random_3sat` | Phase transition: random 3-SAT flips from SAT to UNSAT around clauses/vars ≈ 4.3 |

## Tests

```bash
cargo test -p sat
```

The solver is checked on satisfiable and unsatisfiable formulas (unit clauses, pure literals, tautologies, pigeonhole principle).
Every returned model is verified against all clauses.
Randomised tests compare DPLL against brute-force exhaustive search on small formulas.

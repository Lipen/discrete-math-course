# sat

A small DPLL SAT solver.

The solver implements the Davis–Putnam–Logemann–Loveland procedure: unit propagation, pure literal elimination, and chronological backtracking.
A literal is an integer: `v` asserts that variable `v` is true, `-v` that it is false.
A formula is a conjunction of clauses, each clause a disjunction of literals.

This is DPLL, not CDCL: clause learning and non-chronological backtracking are left out.

## Quick start

```bash
cargo run --example dpll_demo
cargo run --example pigeonhole
cargo run --example random_3sat
cargo test
```

## The idea

DPLL decides a variable, propagates forced assignments, eliminates pure literals, and backtracks on a conflict.
A clause is unit when exactly one of its literals is unassigned and the rest are false: that literal is forced.
A variable is pure when it occurs with only one polarity in the unsatisfied clauses, and the satisfying value can be assigned at once.
On a conflict the search undoes the most recent decision.
When every decision has been tried both ways, the formula is unsatisfiable.

The traced demo runs the solver on

$$ F = (x_1 \lor x_2 \lor x_3) \land (\neg x_1 \lor x_2) \land (x_2 \lor \neg x_3) \land (\neg x_2 \lor x_3) \land (\neg x_2 \lor \neg x_3) $$

which is unsatisfiable: DPLL exhausts every branch and reports `None`.

## Demos

| Demo          | Shows                                                                                                                         |
| ---           | ---                                                                                                                           |
| `dpll_demo`   | The unsatisfiable formula above with a step-by-step trace, then a satisfiable formula solved with pure literal elimination    |
| `pigeonhole`  | The pigeonhole formulas $PHP(n, n - 1)$ for $n = 2..5$, all unsatisfiable and a classic hard case for DPLL                    |
| `random_3sat` | The phase transition of random 3-SAT around the clause-to-variable ratio $4.3$                                                |

`dpll_demo` prints each forced unit, each pure literal, each decision, and each backtrack, so the search tree can be read from the output.
`pigeonhole` encodes placing $n$ pigeons into $n - 1$ holes: every pigeon needs a hole, and no hole may hold two pigeons.
`random_3sat` solves twenty random instances at each ratio from 1 to 6 and prints how many are satisfiable.

## API

| Item                                                  | Module | Purpose                                                               |
| ---                                                   | ---    | ---                                                                   |
| `Lit`, `Clause`                                       | `cnf`  | Type aliases for a literal and a clause                               |
| `pos`, `neg`                                          | `cnf`  | Positive and negative literal constructors                            |
| `var_of`, `lit_idx`, `is_pos`                         | `cnf`  | Literal accessors                                                     |
| `clause_satisfied`, `unit_of`, `clause_has_unassigned` | `cnf` | Clause checks under a partial assignment                              |
| `Cnf`                                                 | `cnf`  | A formula with `num_vars` and `clauses`, plus `new` and `random_3sat` |
| `format_lit`, `format_clause`, `format_cnf`           | `cnf`  | Readable rendering of literals, clauses, and formulas                 |
| `solve`                                               | `dpll` | A satisfying assignment, or `None` for UNSAT                          |
| `solve_traced`                                        | `dpll` | `solve` with a step-by-step trace on stdout                           |

## Tests

The solver is checked on unit clauses, pure literals, tautologies, immediate conflicts, and the pigeonhole principle.
Every returned model is verified against every clause.
Randomized tests compare DPLL against exhaustive search over all assignments on small formulas.

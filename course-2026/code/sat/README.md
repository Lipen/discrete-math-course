# sat

A DPLL SAT solver with a step-by-step trace of the search.

## Quick start

```bash
cargo run --example dpll_demo
cargo run --example pigeonhole
cargo run --example random_3sat
cargo test
```

## The idea

The solver decides formulas in conjunctive normal form: a conjunction of clauses, each clause a disjunction of literals.

$$F = \bigwedge_{i=1}^{m} \bigvee_{j=1}^{k_i} l_{ij}, \qquad l_{ij} \in \{\,v,\ \neg v\,\}$$

A literal is an integer: `v` asserts that variable `v` is true, `-v` that it is false.
Variables are numbered from 1.

### The DPLL search

The Davis–Putnam–Logemann–Loveland search keeps a partial assignment and applies two propagation rules to a fixed point:

- a clause is **unit** when exactly one of its literals is unassigned and the rest are false: that literal is forced to true.
- a variable is **pure** when it occurs with only one polarity in the unsatisfied clauses: it takes the satisfying value at once.

When neither rule applies, DPLL decides the next unassigned variable and recurses on both values.
On a conflict the search undoes the most recent decision.
When every decision has been tried both ways, the formula is unsatisfiable.
This is DPLL, not CDCL: clause learning and non-chronological backtracking are left out.

### A traced run

The traced demo runs the solver on

$$ F = (x_1 \lor x_2 \lor x_3) \land (\neg x_1 \lor x_2) \land (x_2 \lor \neg x_3) \land (\neg x_2 \lor x_3) \land (\neg x_2 \lor \neg x_3) $$

which is unsatisfiable: DPLL exhausts every branch and reports `None`.

## Demos

| Demo          | Shows                                                                                                                      |
| ------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `dpll_demo`   | The unsatisfiable formula above with a step-by-step trace, then a satisfiable formula solved with pure literal elimination |
| `pigeonhole`  | The pigeonhole formulas $PHP(n, n - 1)$ for $n = 2..5$, all unsatisfiable and a classic hard case for DPLL                 |
| `random_3sat` | The phase transition of random 3-SAT around the clause-to-variable ratio $4.3$                                             |

`dpll_demo` prints each forced unit, each pure literal, each decision, and each backtrack, so the search tree can be read from the output.
`pigeonhole` encodes placing $n$ pigeons into $n - 1$ holes: every pigeon needs a hole, and no hole may hold two pigeons.
`random_3sat` solves twenty random instances at each ratio from 1 to 6 and prints how many are satisfiable.

## API

| Item                                                   | Module | Purpose                                                               |
| ------------------------------------------------------ | ------ | --------------------------------------------------------------------- |
| `Lit`, `Clause`                                        | `cnf`  | Type aliases for a literal and a clause                               |
| `pos`, `neg`                                           | `cnf`  | Positive and negative literal constructors                            |
| `var_of`, `lit_idx`, `is_pos`                          | `cnf`  | Literal accessors                                                     |
| `clause_satisfied`, `unit_of`, `clause_has_unassigned` | `cnf`  | Clause checks under a partial assignment                              |
| `Cnf`                                                  | `cnf`  | A formula with `num_vars` and `clauses`, plus `new` and `random_3sat` |
| `format_lit`, `format_clause`, `format_cnf`            | `cnf`  | Readable rendering of literals, clauses, and formulas                 |
| `solve`                                                | `dpll` | A satisfying assignment, or `None` for UNSAT                          |
| `solve_traced`                                         | `dpll` | `solve` with a step-by-step trace on stdout                           |

## Tests

The solver is checked on unit clauses, pure literals, tautologies, immediate conflicts, and the pigeonhole principle.
Every returned model is verified against every clause.
Randomized tests compare DPLL against exhaustive search over all assignments on small formulas.

# smt

A small DPLL(T) stack for quantifier-free SMT problems.

A SAT solver decides the Boolean structure, theory solvers decide conjunctions of arithmetic or bitvector literals, and the driver combines the two.
Each theory atom is abstracted to a Boolean variable, and every theory conflict contributes a learned clause.

## Quick start

```bash
cargo run --example solve      # difference logic, satisfiable
cargo run --example unsat      # difference logic, negative cycle
cargo run --example mixed      # mixed formula through the DPLL(T) driver
cargo test
```

## The layers

| Module       | What it does                                                                                                   |
| ------------ | -------------------------------------------------------------------------------------------------------------- |
| `sat`        | A self-contained DPLL SAT solver: unit propagation, decisions, backtracking, the engine for every other module |
| `difference` | Difference logic `x - y <= c`, decided by a negative-cycle test with Bellman–Ford                              |
| `linear`     | Linear real arithmetic by Fourier–Motzkin elimination with exact rational arithmetic (`Rat`)                   |
| `integers`   | Linear integer arithmetic by branch and bound on the rational relaxation                                       |
| `bitvec`     | Fixed-width bitvectors by bit-blasting: each expression becomes a circuit of clauses for the SAT core          |
| `driver`     | The DPLL(T) loop: `smt::check(formula)` for mixed formulas, with naive conflict learning                       |

### Design limits

The driver is deliberately simple: one theory per atom, and no Nelson–Oppen combination of variables across theories.

- Linear equality atoms are rejected because their negation is a disjunction: write `sum == b` as the two atoms `sum <= b` and `-sum <= -b`.
- `linear` and `integers` keep all arithmetic exact but expect small coefficients: elimination multiplies them.
- `bitvec` accepts widths from 1 to 64 bits with the operations `Not`, `And`, `Or`, `Add`, `Sub`, `Extract`, `Eq`, `Neq`.
- `Mul` and `Shl` fail with an explicit error rather than a wrong answer.

## Demos

| Demo    | What it shows                                                                                                                                                                |
| ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `solve` | A satisfiable difference-logic system (`4 <= x0 - x1 <= 5` and `x2 - x1 <= 2`), the assignment found, and every constraint re-checked                                        |
| `unsat` | A contradictory pair (`x0 - x1 <= 2` with `x1 - x0 <= -3`) that forms a negative cycle, so the solver reports `None`                                                         |
| `mixed` | A satisfiable mix of difference logic, linear arithmetic, and a 4-bit `secret + 1 == 5`, plus an unsatisfiable disjunction whose branches are rejected by different theories |

A mixed formula is a Boolean combination of theory atoms:

$$\varphi \;::=\; A \;\mid\; \neg\varphi \;\mid\; \varphi \land \varphi \;\mid\; \varphi \lor \varphi$$

where $A$ ranges over the atoms `Atom::Diff`, `Atom::Linear`, `Atom::Integer`, and `Atom::Bitvec`:

```rust
use smt::difference::Constraint as Diff;
use smt::driver::{Atom, Formula, Verdict};

// (x0 - x1 <= 2) OR (x1 - x0 <= -3): a task that takes at most 2 time
// units or at least 3.
let f = Formula::Or(
    Box::new(Formula::Atom(Atom::Diff(Diff { x: 0, y: 1, c: 2 }))),
    Box::new(Formula::Atom(Atom::Diff(Diff { x: 1, y: 0, c: -3 }))),
);
assert_eq!(smt::check(&f).unwrap(), Verdict::Sat);
```

The driver abstracts the two atoms to Booleans, hands every SAT model to the difference-logic solver, and on a rejection learns the negation of the offending assignment as a new clause.

## API

| Item                                    | What it does                                                                       |
| --------------------------------------- | ---------------------------------------------------------------------------------- |
| `sat::solve(num_vars, &clauses)`        | A Boolean model (one value per variable) or `None`                                 |
| `sat::Solver`                           | Incremental clauses, `solve()` repeatable after learning                           |
| `difference::Constraint { x, y, c }`    | The literal `x - y <= c`                                                           |
| `difference::solve(&[Constraint])`      | An assignment or `None` (negative cycle)                                           |
| `linear::Constraint { coeffs, b, rel }` | `sum <rel> b` over the reals (`Le`, `Lt`, `Eq`)                                    |
| `linear::solve(&[Constraint])`          | An exact rational assignment or `None`                                             |
| `linear::Rat`                           | An exact `num / den` rational with `to_f64`, `floor`, `ceil`                       |
| `integers::Constraint { coeffs, b }`    | `sum <= b` over the integers                                                       |
| `integers::solve(&[Constraint])`        | An integer assignment or `None`                                                    |
| `bitvec::Expr`                          | Bitvector expressions: `Const`, `Var`, `Not`, `And`, `Or`, `Add`, `Sub`, `Extract` |
| `bitvec::BoolExpr`                      | Top-level `Eq` / `Neq` literals                                                    |
| `bitvec::solve(&[BoolExpr])`            | `Ok(Some(model))` / `Ok(None)` / `Err(BitvecError)`                                |
| `driver::Atom`                          | A `Diff`, `Linear`, `Integer`, or `Bitvec` atom                                    |
| `driver::Formula`                       | `Atom`, `Not`, `And`, `Or`                                                         |
| `smt::check(&Formula)`                  | `Ok(Sat)` or `Ok(Unsat)`, or an error for unsupported literals                     |

## Tests

The SAT core is compared against exhaustive truth-table search over a fixed clause pool.
The theory solvers are checked on satisfiable and unsatisfiable systems.
The bitvector tests re-check every found model against the original expressions.

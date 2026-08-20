# smt

A small DPLL(T) stack for quantifier-free SMT problems, built in layers from a Boolean core up to a mixed-signature driver.

The crate is a miniature of the SMT story: a SAT solver decides Boolean structure, theory solvers decide conjunctions of arithmetic or bitvector literals, and a driver combines the two, abstracting each theory atom to a Boolean variable and learning a clause on every theory conflict.

## Quick start

```bash
cargo run -p smt --example solve      # difference logic, satisfiable
cargo run -p smt --example unsat      # difference logic, negative cycle
cargo run -p smt --example mixed      # mixed formula through the DPLL(T) driver
cargo test -p smt
```

## The layers

| Module | What it does |
|--------|--------------|
| `sat` | A self-contained DPLL SAT solver: unit propagation, decisions, backtracking. The engine for every other module |
| `difference` | Difference logic `x - y <= c`, solved as a negative-cycle test with Bellman-Ford |
| `linear` | Linear real arithmetic by Fourier-Motzkin elimination with exact rational arithmetic (`Rat`) |
| `integers` | Linear integer arithmetic by branch and bound on the rational relaxation |
| `bitvec` | Fixed-width bitvectors by bit-blasting: each expression becomes a circuit of clauses fed to the SAT core |
| `driver` | The DPLL(T) loop: `smt::check(formula)` for mixed formulas, with naive conflict learning |

The `driver` is deliberately simple: one theory per atom (no Nelson-Oppen sharing of variables between theories), and linear equality atoms are rejected because their negation is a disjunction -- write `sum == b` as the two atoms `sum <= b` and `-sum <= -b`. Each theory documents its own precision limits: `linear` and `integers` keep all arithmetic exact but expect small coefficients (elimination multiplies them), and `bitvec` supports widths from 1 to 64 bits with the operations `Not`, `And`, `Or`, `Add`, `Sub`, `Extract`, `Eq`, `Neq` -- `Mul` and `Shl` fail with an explicit error rather than a wrong answer.

## Demos

| Demo | What it shows |
|------|---------------|
| `solve` | A small satisfiable difference-logic system (`4 <= x0 - x1 <= 5` plus `x2 - x1 <= 2`), the assignment found, and every constraint re-checked |
| `unsat` | A contradictory pair (`x0 - x1 <= 2` with `x1 - x0 <= -3`) that forms a negative cycle; the solver reports `None` |
| `mixed` | A satisfiable mix of difference logic, linear arithmetic, and a 4-bit `secret + 1 == 5`, plus an unsatisfiable disjunction whose two branches are rejected by different theories |

## A mixed formula

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

## API

| Item | What it does |
|------|--------------|
| `sat::solve(num_vars, &clauses)` | Boolean model (one value per variable) or `None` |
| `sat::Solver` | Incremental clauses, `solve()` repeatable after learning |
| `difference::Constraint { x, y, c }` | The literal `x - y <= c` |
| `difference::solve(&[Constraint])` | Assignment or `None` (negative cycle) |
| `linear::Constraint { coeffs, b, rel }` | `sum <rel> b` over reals (`Le`, `Lt`, `Eq`) |
| `linear::solve(&[Constraint])` | Exact rational assignment or `None` |
| `linear::Rat` | Exact `num / den` rational with `to_f64`, `floor`, `ceil` |
| `integers::Constraint { coeffs, b }` | `sum <= b` over integers |
| `integers::solve(&[Constraint])` | Integer assignment or `None` |
| `bitvec::Expr` | Bitvector expressions: `Const`, `Var`, `Not`, `And`, `Or`, `Add`, `Sub`, `Extract` |
| `bitvec::BoolExpr` | Top-level `Eq` / `Neq` literals |
| `bitvec::solve(&[BoolExpr])` | `Ok(Some(model))` / `Ok(None)` / `Err(BitvecError)` |
| `driver::Atom` | `Diff`, `Linear`, `Integer`, or `Bitvec` atom |
| `driver::Formula` | `Atom`, `Not`, `And`, `Or` |
| `smt::check(&Formula)` | `Ok(Sat)` or `Ok(Unsat)`, or an error for unsupported literals |

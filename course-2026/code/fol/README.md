# fol

First-order logic: terms, formulas, models, and Tarski-style truth.

A first-order language is built from a signature of constants, function
symbols, and predicate symbols. From the signature we build terms (variables,
constants, function applications) and formulas (atoms, equality, the
connectives, and the quantifiers `∀` and `∃`). A structure assigns the symbols
a meaning -- a non-empty domain, a value per constant, a total function per
function symbol, a relation per predicate -- and the truth of a sentence is
computed by Tarski's definition. Over a fixed finite domain there are finitely
many structures, so satisfiability and validity are decidable by enumeration.

## Quick start

```bash
cargo run -p fol --example mortal
cargo run -p fol --example quantifier_scope
cargo run -p fol --example substitution
cargo run -p fol --example validity
cargo test -p fol
```

## The idea

Predicates and quantifiers let a formula look inside an atom. `P(x)` is a
template that becomes a statement once `x` is bound by a quantifier or replaced
by a constant. `∀x. P(x)` asks for the property over every element of the
domain, `∃x. P(x)` over at least one. Quantifier order matters: `∀x ∃y L(x, y)`
lets `y` depend on `x`, while `∃y ∀x L(x, y)` fixes one `y` for everyone.

A structure turns syntax into truth: constants name domain elements, function
symbols name functions, predicate symbols name relations. A sentence is then
true or false by Tarski's inductive definition, which this crate implements in
`Structure::eval`. Over a finite domain the quantifiers reduce to finite
conjunctions and disjunctions, so validity and satisfiability can be decided
by enumerating every structure -- `valid_over` and `satisfiable_over` do
exactly that.

## API

| Item | What it does |
|------|--------------|
| `Signature` | The constants, functions, and predicates of a language, with arities |
| `Term` | A term: `Var`, `Const`, `Fun` |
| `Formula` | A formula: `Pred`, `Eq`, `Not`, `And`, `Or`, `Implies`, `Forall`, `Exists` |
| `var` / `constant` / `func` | Term constructors |
| `pred` / `eq` / `not` / `and` / `or` / `implies` / `forall` / `exists` | Formula constructors |
| `Term::substitute` | Replace a variable by a term |
| `Formula::substitute` | Capture-avoiding substitution; renames binders when needed |
| `Formula::free_vars` | The free variables of a formula |
| `Structure` | A model: domain + interpretation of every symbol |
| `Structure::eval` | Tarski truth of a sentence; `eval_with` adds a variable assignment |
| `enumerate_structures` | All structures over a fixed finite domain |
| `satisfiable_over` / `valid_over` | Satisfiability / validity over a fixed finite domain |
| `domain` | A canonical domain of `n` individuals named `"0"` .. `"n-1"` |

## Demos

| Demo | What it shows |
|------|---------------|
| `mortal` | "Every human is mortal" is true in one world and false in another |
| `quantifier_scope` | `∀x ∃y L(x, y)` vs `∃y ∀x L(x, y)` -- order changes truth |
| `substitution` | Capture-avoiding substitution: the binder is renamed, the incoming term stays free |
| `validity` | Excluded middle is valid over finite domains; `∃x P(x)` is satisfiable but not valid |

## Tests

```bash
cargo test -p fol
```

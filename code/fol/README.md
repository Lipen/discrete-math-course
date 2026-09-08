# fol

First-order logic: terms, formulas, models, and Tarski-style truth.

## Quick start

```bash
cargo run --example mortal
cargo run --example quantifier_scope
cargo run --example substitution
cargo run --example validity
cargo test
```

## The idea

A first-order language is fixed by its signature: constants, function symbols, and predicate symbols, the latter two with arities.
Terms are variables, constants, and function applications.
Formulas are built by the grammar

$$\varphi \;::=\; P(t_1, \dots, t_n) \;\mid\; t_1 = t_2 \;\mid\; \neg\varphi \;\mid\; \varphi \land \varphi \;\mid\; \varphi \lor \varphi \;\mid\; \varphi \to \varphi \;\mid\; \forall x.\,\varphi \;\mid\; \exists x.\,\varphi$$

### Models and truth

A structure gives the symbols a meaning: a non-empty domain $D$, a value per constant, a total function per function symbol, a relation per predicate symbol.
The truth of a sentence is computed by Tarski's inductive definition, which `Structure::eval` implements.
The heart of the definition is the quantifier case:

$$\mathcal{M} \models \forall x.\,\varphi \iff \mathcal{M} \models \varphi[x := d] \text{ for every } d \in D$$

$$\mathcal{M} \models \exists x.\,\varphi \iff \mathcal{M} \models \varphi[x := d] \text{ for some } d \in D$$

Quantifier order matters: `∀x ∃y L(x, y)` lets `y` depend on `x`, while `∃y ∀x L(x, y)` fixes one `y` for everyone.
Predicates and quantifiers let a formula look inside an atom: `P(x)` is a template that becomes a statement once `x` is bound by a quantifier or replaced by a constant.

### Deciding over finite domains

Over a finite domain the quantifiers reduce to finite connectives:

$$\forall x.\,\varphi \;\equiv\; \bigwedge_{d \in D} \varphi[x := d] \qquad\qquad \exists x.\,\varphi \;\equiv\; \bigvee_{d \in D} \varphi[x := d]$$

There are finitely many structures over a fixed finite domain, so satisfiability and validity are decidable by exhaustion.
`enumerate_structures` lists them all, and `satisfiable_over` / `valid_over` decide the two questions.

### Substitution

`Formula::substitute` replaces a free variable by a term.
The substitution is capture-avoiding: a bound variable is renamed first when the incoming term would otherwise be captured.

## Demos

| Demo               | What it shows                                                                              |
| ------------------ | ------------------------------------------------------------------------------------------ |
| `mortal`           | "Every human is mortal" is true in one world and false in another                          |
| `quantifier_scope` | `∀x ∃y L(x, y)` versus `∃y ∀x L(x, y)` — the order changes the truth                       |
| `substitution`     | Capture-avoiding substitution: the binder is renamed, the incoming term stays free         |
| `validity`         | Excluded middle is valid over finite domains, while `∃x P(x)` is satisfiable but not valid |

## API

| Item                                                                   | What it does                                                               |
| ---------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| `Signature`                                                            | The constants, functions, and predicates of a language, with arities       |
| `Term`                                                                 | A term: `Var`, `Const`, `Fun`                                              |
| `Formula`                                                              | A formula: `Pred`, `Eq`, `Not`, `And`, `Or`, `Implies`, `Forall`, `Exists` |
| `var` / `constant` / `func`                                            | Term constructors                                                          |
| `pred` / `eq` / `not` / `and` / `or` / `implies` / `forall` / `exists` | Formula constructors                                                       |
| `Term::substitute`                                                     | Replaces a variable by a term                                              |
| `Formula::substitute`                                                  | Capture-avoiding substitution, renames binders when needed                 |
| `Formula::free_vars`                                                   | The free variables of a formula                                            |
| `Structure`                                                            | A model: domain plus interpretation of every symbol                        |
| `Structure::eval`                                                      | Tarski truth of a sentence, `eval_with` adds a variable assignment         |
| `enumerate_structures`                                                 | All structures over a fixed finite domain                                  |
| `satisfiable_over` / `valid_over`                                      | Satisfiability / validity over a fixed finite domain                       |
| `domain`                                                               | A canonical domain of `n` individuals named `"0"` .. `"n-1"`               |

## Tests

Integration tests check evaluation against hand calculations: quantifier order, the mortal-syllogism shape, equality as identity on the domain, and capture-avoiding substitution.
Enumeration tests decide satisfiability and validity over small domains, including the counts of structures over domains of size 1 and 2.

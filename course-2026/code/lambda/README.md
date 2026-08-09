# lambda

Untyped λ-calculus.

Terms, capture-avoiding substitution, β-reduction, and Church-numeral arithmetic.
Everything the chapter defines, plus a normalizer with a step guard against non-termination.

## Quick start

```bash
cargo run -p lambda --example church_arith
cargo test -p lambda
```

## The core operation

β-reduction feeds an argument into a binder, replacing each free occurrence of the bound variable:

$$ (\lambda x.\; M)\; N \;\to_\beta\; M[x := N] $$

Substitution is capture-avoiding: when a free variable of $N$ would be captured by a binder, the binder is α-renamed first.

![Beta reduction of the K combinator](assets/beta-reduction.svg)

The diagram reduces the constant combinator step by step: $(\lambda x.\,\lambda y.\,x)\;a\;b$.

## API

| Item | Purpose |
| --- | --- |
| `Term` | A λ-term: `Var`, `Abs`, `App` |
| `Term::free_vars` | Free variables of a term |
| `Term::substitute` | Capture-avoiding substitution $M[x := N]$ |
| `Term::beta_reduce` | One outermost-left β-step; `None` at a normal form |
| `Term::normalize` | Full reduction, guarded by `max_steps` |
| `church`, `to_nat` | Church numerals and reading their value back |
| `succ`, `add` | Arithmetic on Church numerals |

## Demo

| Demo | Shows |
| --- | --- |
| `church_arith` | Church numerals 2 + 3 = 5 and succ 2 = 3, fully reduced |

## Tests

```bash
cargo test -p lambda
```

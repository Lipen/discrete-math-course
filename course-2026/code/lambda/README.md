# lambda

Untyped λ-calculus.

Terms, capture-avoiding substitution, β-reduction, Church encodings (numerals,
booleans, pairs), and well-known combinators (SKI, Ω, Y).

## Quick start

```bash
cargo run -p lambda --example church_arith
cargo run -p lambda --example combinators
cargo run -p lambda --example beta_trace
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
|------|---------|
| `Term` | A λ-term: `Var`, `Abs`, `App` |
| `Term::var` / `Term::abs` / `Term::app` | Constructors |
| `Term::free_vars` | Free variables of a term |
| `Term::substitute` | Capture-avoiding substitution $M[x := N]$ |
| `Term::rename` | α-conversion (rename bound variable) |
| `Term::beta_reduce` | One normal-order β-step; `None` at a normal form |
| `Term::normalize` | Full reduction, guarded by `max_steps` |
| `Term::trace` | Step-by-step reduction trace as `Vec<Term>` |
| `Term::is_normal_form` | Whether the term contains no redex |
| `church` / `to_nat` | Church numerals and reading their value back |
| `succ` / `add` / `mult` / `power` | Arithmetic on Church numerals |
| `church_true` / `church_false` | Church booleans |
| `and` / `or` / `not` / `ifthenelse` | Boolean logic |
| `church_to_bool` | Interpret a Church boolean back to `bool` |
| `pair` / `fst` / `snd` | Church pairs and projections |
| `i` / `k` / `s` | SKI combinators (S and K form a basis) |
| `self_app` / `omega` | Self-application ω and non-terminating Ω |
| `y` | Call-by-name Y fixed-point combinator |

## Demo

| Demo | Shows |
|------|-------|
| `church_arith` | Church numerals: succ, add, mult, power (2^4 = 16, etc.) |
| `combinators` | I, K, S combinators; SKK = I; Ω non-termination |
| `beta_trace` | Step-by-step reduction trace; Ω with step limit; Church arithmetic with trace |

## Tests

```bash
cargo test -p lambda
```

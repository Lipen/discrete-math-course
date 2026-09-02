# lambda

Untyped λ-calculus as a small, self-contained library.

The crate provides λ-terms with capture-avoiding substitution, β-reduction under three strategies (normal order, applicative order, weak head normal form), Church encodings of numerals, booleans, and pairs, the SKI combinators, and a minimal simply-typed layer on top.

## Quick start

```bash
cargo test
cargo run --example church_arith
cargo run --example combinators
cargo run --example beta_trace
```

## The idea

β-reduction feeds an argument into a binder, replacing each free occurrence of the bound variable:

$$ (\lambda x.\; M)\; N \;\to_\beta\; M[x := N] $$

Substitution is capture-avoiding: when a free variable of $N$ would be captured by a binder, the binder is α-renamed first.

![Beta reduction of the K combinator](assets/beta-reduction.svg)

The diagram reduces the constant combinator $(\lambda x.\,\lambda y.\,x)\;a\;b$ step by step.

## Reduction strategies

All drivers are fuel-limited (`max_steps`), so diverging terms such as $\Omega$ cannot hang the process, and the outcome is reported as a `Reduction` with a step counter.

- **Normal order** (leftmost outermost) — if a normal form exists, normal order finds it.
- **Applicative order** (leftmost innermost) — arguments are evaluated before functions are applied, so it can loop where normal order terminates (when the argument diverges).
- **Weak head normal form** — the run stops once the head is a variable or a binder, and redexes inside arguments are left alone.

## Modules

| Module        | Contents                                                             |
| ------------- | -------------------------------------------------------------------- |
| `term`        | `Term` (`Var`, `Abs`, `App`), constructors, printing, free variables |
| `subst`       | Capture-avoiding substitution $M[x := N]$ and α-conversion `rename`  |
| `eval`        | Reduction strategies and fuel-limited drivers with step counters     |
| `church`      | Church numerals, booleans, pairs, zero test, predecessor             |
| `combinators` | I, K, S combinators (S and K form a basis)                           |
| `stlc`        | Simply-typed layer: `Ty`, `STerm`, type checking, type erasure       |

## Demos

| Demo           | Shows                                                                    |
| -------------- | ------------------------------------------------------------------------ |
| `church_arith` | Church numerals: `succ`, `add`, `mult`, `power` ($2^4 = 16$)             |
| `combinators`  | I, K, S and the reduction of `S K K` to the identity                     |
| `beta_trace`   | Step-by-step β-reduction traces, including Church `succ` applied to 2    |

## API

| Item                                                         | Purpose                                                                           |
| ------------------------------------------------------------ | --------------------------------------------------------------------------------- |
| `Term`                                                       | A λ-term: `Var`, `Abs`, `App`                                                     |
| `Term::var` / `Term::abs` / `Term::app`                      | Constructors                                                                      |
| `Term::free_vars`                                            | Free variables of a term                                                          |
| `Term::substitute`                                           | Capture-avoiding substitution $M[x := N]$                                         |
| `Term::rename`                                               | α-conversion (rename a bound variable)                                            |
| `Term::beta_reduce`                                          | One normal-order β-step, `None` at a normal form                                  |
| `Term::beta_reduce_applicative`                              | One applicative-order β-step (leftmost innermost)                                 |
| `Term::whnf_step`                                            | One step toward weak head normal form                                             |
| `Term::normalize`                                            | Normal-order reduction to normal form, fuel-limited                               |
| `Term::normalize_applicative`                                | Applicative-order reduction, fuel-limited                                         |
| `Term::whnf`                                                 | Weak-head reduction, fuel-limited                                                 |
| `Term::reduce_normal` / `reduce_applicative` / `reduce_whnf` | The same runs, returning a `Reduction` with a step counter                        |
| `Reduction`                                                  | `{ term, steps, converged }` — the term reached, the steps taken, the fuel status |
| `Term::trace` / `trace_applicative`                          | Step-by-step reduction traces                                                     |
| `Term::is_normal_form` / `is_whnf`                           | Normal-form predicates                                                            |
| `church` / `to_nat`                                          | Church numerals and reading their value back                                      |
| `succ` / `add` / `mult` / `power`                            | Arithmetic on Church numerals                                                     |
| `is_zero` / `pred`                                           | Zero test and predecessor (pair shift)                                            |
| `church_true` / `church_false`                               | Church booleans                                                                   |
| `and` / `or` / `not` / `ifthenelse`                          | Boolean logic                                                                     |
| `church_to_bool`                                             | Interpret a Church boolean back to `bool`                                         |
| `pair` / `fst` / `snd`                                       | Church pairs and projections                                                      |
| `i` / `k` / `s`                                              | SKI combinators (S and K form a basis)                                            |
| `Ty` / `STerm`                                               | Simply-typed terms: `Base`, `Arrow`, annotated binders                            |
| `STerm::erase`                                               | Erase types to the untyped `Term`                                                 |
| `STerm::infer` / `type_of`                                   | Type check against a context or the empty context                                 |
| `TypeError`                                                  | Why a typed term failed to check                                                  |

## Tests

Unit tests cover capture-avoidance edge cases, the divergence of applicative order on $\Omega$ where normal order terminates, weak-head behavior, and the arithmetic identities of the Church encodings.

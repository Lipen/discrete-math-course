# lambda

Untyped λ-calculus: terms with capture-avoiding substitution, three fuel-limited reduction strategies, Church encodings, the SKI combinators, and a simply-typed layer.

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

| Demo           | Shows                                                                 |
| -------------- | --------------------------------------------------------------------- |
| `church_arith` | Church numerals: `succ`, `add`, `mult`, `power` ($2^4 = 16$)          |
| `combinators`  | I, K, S and the reduction of `S K K` to the identity                  |
| `beta_trace`   | Step-by-step β-reduction traces, including Church `succ` applied to 2 |

## API

### Terms and reduction

| Item                                                         | Purpose                                                                            |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------- |
| `Term` (`Var`, `Abs`, `App`)                                 | a λ-term                                                                           |
| `Term::var` / `Term::abs` / `Term::app`                      | constructors                                                                       |
| `Term::free_vars`                                            | free variables of a term                                                           |
| `Term::substitute`                                           | capture-avoiding substitution $M[x := N]$                                          |
| `Term::rename`                                               | α-conversion (rename a bound variable)                                             |
| `Term::beta_reduce`                                          | one normal-order β-step, `None` at a normal form                                   |
| `Term::beta_reduce_applicative`                              | one applicative-order β-step (leftmost innermost)                                  |
| `Term::whnf_step`                                            | one step toward weak head normal form                                              |
| `Term::normalize`                                            | normal-order reduction to normal form, fuel-limited                                |
| `Term::normalize_applicative`                                | applicative-order reduction, fuel-limited                                          |
| `Term::whnf`                                                 | weak-head reduction, fuel-limited                                                  |
| `Term::reduce_normal` / `reduce_applicative` / `reduce_whnf` | the same runs, returning a `Reduction` with a step counter                         |
| `Reduction`                                                  | `{ term, steps, converged }` — the term reached, the steps taken, the fuel status  |
| `Term::trace` / `trace_applicative`                          | step-by-step reduction traces                                                      |
| `Term::is_normal_form` / `is_whnf`                           | normal-form predicates                                                             |

### Church encodings

| Item                                | Purpose                                      |
| ----------------------------------- | -------------------------------------------- |
| `church` / `to_nat`                 | Church numerals and reading their value back |
| `succ` / `add` / `mult` / `power`   | arithmetic on Church numerals                |
| `is_zero` / `pred`                  | zero test and predecessor (pair shift)       |
| `church_true` / `church_false`      | Church booleans                              |
| `and` / `or` / `not` / `ifthenelse` | boolean logic                                |
| `church_to_bool`                    | interpret a Church boolean back to `bool`    |
| `pair` / `fst` / `snd`              | Church pairs and projections                 |

### Combinators

| Item            | Purpose                                |
| --------------- | -------------------------------------- |
| `i` / `k` / `s` | SKI combinators (S and K form a basis) |

### Simply-typed layer

| Item                       | Purpose                                                |
| -------------------------- | ------------------------------------------------------ |
| `Ty` / `STerm`             | simply-typed terms: `Base`, `Arrow`, annotated binders |
| `STerm::erase`             | erase types to the untyped `Term`                      |
| `STerm::infer` / `type_of` | type check against a context or the empty context      |
| `TypeError`                | why a typed term failed to check                       |

## Tests

The unit tests cover:

- capture-avoidance edge cases: renaming under nested binders, shadow boundaries, names bound deeper in the body
- the divergence of applicative order on $\Omega$ where normal order terminates
- weak-head behavior: redexes inside arguments are left untouched
- the arithmetic identities of the Church encodings

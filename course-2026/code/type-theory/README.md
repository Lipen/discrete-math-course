# type-theory

Simply-typed λ-calculus (λ→).

The crate provides types and contexts, the three typing rules var/app/abs as *checking* over Church-annotated terms, *inference* of the most general type of an untyped term by unification with metavariables, and subject reduction: a typed term β-reduces preserving its type.
Self-application `λx. x x` is rejected — it would need `σ = σ -> τ`.

## Quick start

```bash
cargo test
cargo run --example typed_terms
cargo run --example inference
cargo run --example subject_reduction
```

## The type system

A type is a base type (`Nat`, `Bool`, ...) or a function type `σ -> τ`.
The three typing rules are the whole system:

$$
   \frac{}{(x:\sigma)\in\Gamma}\;\textbf{var} \\[1em]
   \frac{\Gamma\vdash M:\sigma\to\tau\quad\Gamma\vdash N:\sigma}{\Gamma\vdash MN:\tau}\;\textbf{app} \\[1em]
   \frac{\Gamma,x:\sigma\vdash M:\tau}{\Gamma\vdash\lambda x:\sigma.\;M:\sigma\to\tau}\;\textbf{abs}
$$

Checking an annotated term is a short walk over these rules.
Inferring the type of an untyped term assigns fresh metavariables to each binder and unifies.
Because `x` in `λx. x x` would have to be both the argument and a function, inference demands `σ = σ -> τ`, which the occurs check rejects.

The identity `λx:A. x` types as `A -> A` by one `var` step under one `abs` step:

$$
\frac{
   \frac{}{(x:A)\in\Gamma}\;\textbf{var}
}{
   \vdash \lambda x:A.\;x : A \to A
}\;\textbf{abs}
$$

## The core idea

`λx. x` has type `σ -> σ` for any `σ`.
Checked on `Nat` it reads `Nat -> Nat`, and its inferred most general type is `a -> a`.
The K combinator `λx. λy. x` types as `σ -> τ -> σ` (inferred as `a -> b -> a`), which reads as the axiom `A -> B -> A` of minimal logic.
Self-application `λx. x x` has no type: it would need `σ = σ -> τ`.
The non-terminating term $\Omega = (\lambda x.\;x\,x)(\lambda x.\;x\,x)$ is rejected for the same reason.
Subject reduction makes the type an *invariant* of computation: each β-step of a typed term preserves it.

## Modules

| Module    | Contents                                                                                                         |
| --------- | ---------------------------------------------------------------------------------------------------------------- |
| `ty`      | `Type` (`Base`, `Arrow`, `Var`), `Context` with variable-to-type assumptions, display                            |
| `term`    | Untyped `Term` (`Var`, `Abs`, `App`), capture-avoiding substitution, β-reduction                                 |
| `checker` | Church-annotated `STerm`, the var/app/abs rules in `STerm::check`, erasure, `TypeError`, subject-reduction steps |
| `infer`   | Unification-based inference (algorithm W): metavariables, occurs check, schematic types, `InferError`            |

## Demos

| Demo                | Shows                                                                                                                                    |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `typed_terms`       | Checking identity, K, a Church numeral, and composition, with ill-typed terms (self-application, mismatch, unbound variable) rejected    |
| `inference`         | Inferring the most general type of identity, K, S, and Church 2, with $\omega$ and $\Omega$ rejected by the occurs check                 |
| `subject_reduction` | `(λf:A→A. λx:A. f x)(λx:A. x)` reduces to `λx:A. x` with the type `A → A` preserved at every step                                        |

## API

| Item                                         | Purpose                                                       |
| -------------------------------------------- | ------------------------------------------------------------- |
| `Type::base` / `Type::nat` / `Type::boolean` | Base types                                                    |
| `Type::arrow`                                | Function type `dom -> cod`                                    |
| `Type::var`                                  | A type variable (schematic `a` or metavariable `?0`)          |
| `Context::new` / `extend` / `lookup`         | Typing context: innermost binding wins                        |
| `Term::var` / `abs` / `app`                  | Untyped term constructors                                     |
| `Term::beta_reduce` / `normalize`            | One β-step / normal form (fuel-limited)                       |
| `Term::substitute`                           | Capture-avoiding substitution $M[x := N]$                     |
| `STerm::var` / `abs` / `app`                 | Church-annotated term constructors                            |
| `STerm::check` / `type_of`                   | Type check against a context / the empty context              |
| `STerm::erase`                               | Erase annotations to the untyped `Term`                       |
| `STerm::beta_reduce` / `normalize`           | β-reduction keeping annotations (subject reduction)           |
| `infer` / `infer_in`                         | The most general type of an untyped term                      |
| `TypeError` / `InferError`                   | Why a term failed to type check                               |

## Tests

The suite covers the typing of identity and K, the rejection of self-application $\omega = \lambda x.\;x\;x$, and subject reduction on the detour example.

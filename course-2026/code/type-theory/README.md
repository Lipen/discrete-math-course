# type-theory

Simply-typed λ-calculus (λ→).

Types (base + function, and contexts), the three typing rules var/app/abs as
*checking* over Church-annotated terms, *inference* of the most general type
of an untyped term by unification with metavariables, and subject reduction:
a typed term β-reduces preserving its type. Self-application `λx. x x` is
rejected -- it would need `σ = σ -> τ`.

## Quick start

```bash
cargo run -p type-theory --example typed_terms
cargo run -p type-theory --example inference
cargo run -p type-theory --example subject_reduction
cargo test -p type-theory
```

## The type system

A type is a base type (`Nat`, `Bool`, ...) or a function type `σ -> τ`.
The three typing rules are the whole system:

$$
   \frac{}{(x:\sigma)\in\Gamma}\;\textbf{var} \\[1em]
   \frac{\Gamma\vdash M:\sigma\to\tau\quad\Gamma\vdash N:\sigma}{\Gamma\vdash MN:\tau}\;\textbf{app} \\[1em]
   \frac{\Gamma,x:\sigma\vdash M:\tau}{\Gamma\vdash\lambda x:\sigma.\;M:\sigma\to\tau}\;\textbf{abs}
$$

Checking an annotated term is a short walk over these rules; inferring the
type of an untyped term assigns fresh metavariables to each binder and unifies.
Because `x` in `λx. x x` would have to be both the argument and a function,
inference demands `σ = σ -> τ`, which the occurs check rejects.

The identity `λx:A. x` types as `A -> A` by one `var` step under one `abs` step:

$$
\frac{
   \frac{}{(x:A)\in\Gamma}\;\textbf{var}
}{
   \vdash \lambda x:A.\;x : A \to A
}\;\textbf{abs}
$$

## Modules

| Module | Contents |
|--------|----------|
| `ty` | `Type` (Base, Arrow, Var), `Context` (variable -> type assumptions), display |
| `term` | Untyped `Term` (Var, Abs, App), capture-avoiding substitution, β-reduction |
| `checker` | Church-annotated `STerm`, the var/app/abs rules in `STerm::check`, erasure, `TypeError`, subject-reduction β-steps |
| `infer` | Unification-based inference (algorithm W) with metavariables, occurs check, generalization to schematic types, `InferError` |

## API

| Item | Purpose |
|------|---------|
| `Type::base` / `Type::nat` / `Type::boolean` | Base types |
| `Type::arrow` | Function type `dom -> cod` |
| `Type::var` | A type variable (schematic `a` or metavariable `?0`) |
| `Context::new` / `extend` / `lookup` | Typing context; innermost binding wins |
| `Term::var` / `abs` / `app` | Untyped term constructors |
| `Term::beta_reduce` / `normalize` | One β-step / normal form (fuel-limited) |
| `Term::substitute` | Capture-avoiding substitution `M[x := N]` |
| `STerm::var` / `abs` / `app` | Church-annotated term constructors |
| `STerm::check` / `type_of` | Type check against a context / the empty context |
| `STerm::erase` | Erase annotations to the untyped `Term` |
| `STerm::beta_reduce` / `normalize` | β-reduce keeping annotations (subject reduction) |
| `infer` / `infer_in` | Infer the most general type of an untyped term |
| `TypeError` / `InferError` | Why a term failed to type check |

## The core idea

`λx. x` has type `σ -> σ` for any `σ`; checked on `Nat` it is `Nat -> Nat`,
and its inferred most general type is `a -> a`. The K combinator
`λx. λy. x` types as `σ -> τ -> σ` (inferred `a -> b -> a`), which reads as
the axiom `A -> B -> A` of minimal logic. Self-application `λx. x x` has no
type: it would need `σ = σ -> τ`, so the Ω = `(λx. x x)(λx. x x)` -- the
non-terminating term of the untyped chapter -- is also rejected. Subject
reduction then guarantees that the type of a typed term is an *invariant* of
its computation: each β-step preserves it.

## Demo

| Demo | Shows |
|------|-------|
| `typed_terms` | Checking identity, K, a Church numeral, and composition; ill-typed terms (self-application, mismatch, unbound variable) rejected |
| `inference` | Inferring the most general type of identity, K, S, Church 2; ω and Ω rejected by the occurs check |
| `subject_reduction` | `(λf:A→A. λx:A. f x)(λx:A. x)` reduces to `λx:A. x`, type `A → A` preserved at every step |

## Tests

```bash
cargo test -p type-theory
```

The suite covers identity : σ→σ, K : σ→τ→σ, rejection of self-application
ω = λx. x x, and subject reduction on a small example.

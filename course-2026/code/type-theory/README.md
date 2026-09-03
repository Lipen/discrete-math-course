# type-theory

Simply-typed λ-calculus (λ→).

Church-annotated terms are checked by the var/app/abs rules, untyped terms get their most general type by unification, and β-reduction of a typed term preserves its type.

## Quick start

```bash
cargo test
cargo run --example typed_terms
cargo run --example inference
cargo run --example subject_reduction
```

## The type system

Types are built from base names and arrows, and arrows associate to the right: `Nat -> Nat -> Nat` reads `Nat -> (Nat -> Nat)`.

$$\sigma ::= B \mid \sigma \to \tau$$

The three typing rules are the whole system:

$$
   \frac{}{(x:\sigma)\in\Gamma}\;\textbf{var} \\[1em]
   \frac{\Gamma\vdash M:\sigma\to\tau\quad\Gamma\vdash N:\sigma}{\Gamma\vdash MN:\tau}\;\textbf{app} \\[1em]
   \frac{\Gamma,x:\sigma\vdash M:\tau}{\Gamma\vdash\lambda x:\sigma.\;M:\sigma\to\tau}\;\textbf{abs}
$$

### Checking

Checking a Church-annotated term (`λx:σ. M`) is a walk over these rules: a variable looks up its type in the context, a binder extends the context, and an application compares the argument type with the function's domain.
The identity `λx:A. x` types as `A -> A` by one `var` step under one `abs` step:

$$
\frac{
   \frac{}{(x:A)\in\Gamma}\;\textbf{var}
}{
   \vdash \lambda x:A.\;x : A \to A
}\;\textbf{abs}
$$

### Inference

Inferring the type of an untyped term assigns a fresh metavariable to each binder and unifies the constraints of the three rules (algorithm W).
Unbound metavariables `?0`, `?1`, ... generalize, in order of first appearance, to schematic variables `a`, `b`, ..., so the identity infers as the scheme `a -> a`.
Because `x` in `λx. x x` would have to be both the argument and a function, inference demands `σ = σ -> τ`, which the occurs check rejects.

## Canonical terms

| Term          | Checked       | Inferred      | Reading                                       |
| ------------- | ------------- | ------------- | --------------------------------------------- |
| `λx. x`       | `σ -> σ`      | `a -> a`      | the identity function                         |
| `λx. λy. x`   | `σ -> τ -> σ` | `a -> b -> a` | the axiom `A -> B -> A` of minimal logic      |
| `ω = λx. x x` | rejected      | rejected      | needs `σ = σ -> τ`                            |
| `Ω = ω ω`     | rejected      | rejected      | contains `ω`, and the term does not terminate |

Checked on `Nat`, the identity reads `Nat -> Nat`.

## Subject reduction

The type is an *invariant* of computation: if `Γ ⊢ M : σ` and `M →β M'`, then `Γ ⊢ M' : σ`.
Reduction on `STerm` keeps the binder annotations, so each β-step of a typed term can be followed by a re-check.

## Modules

| Module    | Contents                                                                                                         |
| --------- | ---------------------------------------------------------------------------------------------------------------- |
| `ty`      | `Type` (`Base`, `Arrow`, `Var`), `Context` with variable-to-type assumptions, display                            |
| `term`    | Untyped `Term` (`Var`, `Abs`, `App`), capture-avoiding substitution, β-reduction                                 |
| `checker` | Church-annotated `STerm`, the var/app/abs rules in `STerm::check`, erasure, `TypeError`, subject-reduction steps |
| `infer`   | Unification-based inference (algorithm W): metavariables, occurs check, schematic types, `InferError`            |

## Demos

| Demo                 | Shows                                                                                                                                 |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `typed_terms`        | Checking identity, K, a Church numeral, and composition, with ill-typed terms (self-application, mismatch, unbound variable) rejected |
| `inference`          | Inferring the most general type of identity, K, S, and Church 2, with $\omega$ and $\Omega$ rejected by the occurs check              |
| `subject_reduction`  | `(λf:A→A. λx:A. f x)(λx:A. x)` reduces to `λx:A. x` with the type `A → A` preserved at every step                                     |

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

The unit tests and doc tests cover:

- typing of identity and K
- rejection of self-application $\omega = \lambda x.\;x\;x$
- subject reduction on the detour example

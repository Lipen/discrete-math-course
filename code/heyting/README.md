# heyting

Finite Heyting algebras and intuitionistic validity.

A Heyting algebra is a distributive lattice with a relative pseudo-complement: an operation $\to$ where $a \to b$ is the weakest $c$ satisfying

$$a \land c \le b.$$

The three-element algebra $\{0, 1/2, 1\}$ is the simplest non-Boolean one.
Its middle element $1/2$ ("not yet constructed") is where the law of excluded middle fails, which makes the algebra the standard counterexample semantics for intuitionistic logic.

The crate contains:

- `Value` — the three-element algebra as a plain enum, with `meet`/`join`/`implies` and `!` for negation
- `Algebra` — any finite Heyting algebra given by meet/join/implies tables, built from lattice tables or as a Boolean algebra
- `Poset` and downsets — the order-ideal construction linking partial orders with intuitionistic semantics
- `Formula` — a tiny propositional formula language, evaluated in any algebra
- `valid` — an exhaustive validity check over all finite Heyting algebras up to 5 elements

## Quick start

```bash
cargo run --example values
cargo run --example excluded_middle
cargo run --example semantics
cargo test
```

## The idea

Boolean algebras model classical truth: every proposition is either true or false.
A Heyting algebra keeps the lattice structure and drops the law $a \lor \lnot a = 1$:

- meet $\land$ plays the role of `and`,
- join $\lor$ the role of `or`,
- the relative pseudo-complement $\to$ the role of implication.

In $\{0, 1/2, 1\}$ negation is $\lnot a = a \to 0$, so $\lnot(1/2) = 0$ and

$$1/2 \lor \lnot(1/2) = 1/2 \ne 1.$$
Excluded middle and double-negation elimination are not tautologies there.
The formulas valid in *every* Heyting algebra are exactly the theorems of intuitionistic logic, so finite Heyting algebras pin down what constructive mathematics refuses to assert.

The key construction linking posets with intuitionistic semantics: the downsets (order ideals) of a poset form a Heyting algebra, with $A \to B$ the largest ideal $I$ satisfying $I \cap A \subseteq B$.
Every finite Heyting algebra is, up to isomorphism, a subalgebra of such a downset algebra (Birkhoff duality).

## API

| Item                                  | What it does                                                                                                     |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `Value`                               | The three elements `Bot`, `Mid`, `Top`, ordered $0 < 1/2 < 1$                                                    |
| `Value::meet`/`join`/`implies`, `!a`  | The operations of the three-element algebra                                                                      |
| `Algebra`                             | A general finite Heyting algebra: elements `0..n` with meet/join/implies tables, bottom, top, and element labels |
| `Algebra::from_meet_join`             | Build an algebra from lattice tables, deriving implication from the Heyting adjunction                           |
| `chain_three()`                       | The canonical example as a table algebra: the downset algebra of the 2-element chain                             |
| `bool_algebra(n)`                     | The Boolean algebra of all subsets of an `n`-element set ($2^n$ elements)                                        |
| `Poset::from_relations` / `from_less` | A small poset on `0..n`                                                                                          |
| `Poset::downset_algebra`              | The Heyting algebra of its downsets (order ideals)                                                               |
| `Formula`                             | A tiny propositional formula type: atoms, $\land$, $\lor$, $\to$, $\lnot$, $\top$, $\bot$                        |
| `Formula::eval`                       | Evaluate a formula in an algebra under a valuation                                                               |
| `all_valuations`                      | Enumerate all valuations of `n` atoms in a `size`-element algebra                                                |
| `valid_in`                            | Is a formula $\top$ under every valuation in one algebra?                                                        |
| `valid`                               | Is a formula valid in every finite Heyting algebra up to 5 elements?                                             |
| `all_finite_heyting_algebras`         | The exact enumeration used by `valid` (cached)                                                                   |

## Demos

| Demo              | What it shows                                                                                                                                                                                            |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `values`          | Truth tables of meet, join, implication, and negation in the three-element algebra, plus two formulas over all valuations: the tautology `p -> (q -> p)` and Peirce's law, which fails                   |
| `excluded_middle` | Where `p ∨ ¬p` and `¬¬p -> p` hold and where they fail (at `1/2`)                                                                                                                                        |
| `semantics`       | The downset algebra of a 3-element poset, excluded middle and double-negation elimination over all valuations, and a validity check of five formulas over the full enumeration of small Heyting algebras |

`values` prints the tables and then marks Peirce's law as not a tautology.
`semantics` ends with the verdicts for five formulas, two valid and three classical laws that fail.

## The validity enumeration

`valid` checks a formula against every algebra produced by `all_finite_heyting_algebras`, built in three steps:

1. every partial order on `0..n` for `n <= 4` (243 posets),
2. the downset algebra of each poset (at most 16 elements),
3. every subalgebra of every downset algebra (subsets closed under meet, join, and implication), deduplicated up to isomorphism.

Every finite Heyting algebra of at most 5 elements appears: by Birkhoff duality, an algebra of size $k$ has at most $k - 1$ join-irreducibles, so the check is exhaustive up to size 5.
The collection also contains 4 algebras of size 6 and larger ones up to the 16-element Boolean algebra.
The full list is cached after the first call.

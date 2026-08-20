# heyting

Finite Heyting algebras and intuitionistic validity.

A Heyting algebra is a distributive lattice with a relative pseudo-complement `a -> b` (the weakest `c` with `a ∧ c <= b`).
The three-element algebra `{0, 1/2, 1}` is the simplest non-Boolean one: its middle element `1/2` ("not yet constructed") is where the law of excluded middle fails, which makes it the standard counterexample semantics for intuitionistic logic.

This crate goes beyond the three-element example: it offers general table-driven finite Heyting algebras, the downset (order ideal) construction from small posets, Boolean algebras, a tiny formula language evaluated in any algebra, and an exhaustive validity checker over all finite Heyting algebras up to 5 elements.

## Quick start

```bash
cargo run -p heyting --example values
cargo run -p heyting --example excluded_middle
cargo run -p heyting --example semantics
cargo test -p heyting
```

## The idea

Boolean algebras model classical truth: every proposition is either true or false.
A Heyting algebra keeps the lattice structure -- meet is `and`, join is `or`, the pseudo-complement is `implication` -- but drops the law `a ∨ ¬a = 1`.
In `{0, 1/2, 1}` negation is `!a = a -> 0`, so `¬(1/2) = 0` and `1/2 ∨ ¬(1/2) = 1/2 ≠ 1`: excluded middle and double-negation elimination are not tautologies.
The formulas valid in *every* Heyting algebra are exactly the theorems of intuitionistic logic, so finite Heyting algebras pin down what constructive mathematics refuses to assert.

The key construction linking posets with intuitionistic semantics: the downsets (order ideals) of a poset form a Heyting algebra, with `A -> B` the largest ideal `I` with `I ∩ A ⊆ B`.
Every finite Heyting algebra is, up to isomorphism, a subalgebra of such a downset algebra (Birkhoff duality).

## Demos

| Demo | What it shows |
|------|---------------|
| `values` | The truth tables of meet, join, implication and negation of the three-element algebra, plus two formulas checked over all valuations: the tautology `p -> (q -> p)` and Peirce's law, which fails |
| `excluded_middle` | Where `p ∨ ¬p` and `¬¬p -> p` hold and where they fail (at `1/2`) |
| `semantics` | The downset algebra of a 3-element poset, excluded middle and double-negation elimination evaluated over all valuations, and a validity check of five formulas over the full enumeration of small Heyting algebras |

## API

| Item | What it does |
|------|--------------|
| `Value` | The three elements `Bot`, `Mid`, `Top`, ordered `0 < 1/2 < 1` |
| `Value::meet/join/implies`, `!a` | The operations of the three-element algebra |
| `Algebra` | A general finite Heyting algebra: elements `0..n` with meet/join/implies tables, bottom, top and element labels |
| `Algebra::from_meet_join` | Build an algebra from lattice tables; implication is derived from the Heyting adjunction |
| `chain_three()` | The canonical example as a table algebra: the downset algebra of the 2-element chain |
| `bool_algebra(n)` | The Boolean algebra of all subsets of an `n`-element set (2^n elements) |
| `Poset::from_relations` / `from_less` | A small poset on `0..n` |
| `Poset::downset_algebra` | The Heyting algebra of its downsets (order ideals) |
| `Formula` | A tiny propositional formula type: atoms, `∧`, `∨`, `->`, `¬`, `⊤`, `⊥` |
| `Formula::eval` | Evaluate a formula in an algebra under a valuation |
| `all_valuations` | Enumerate all valuations of `n` atoms in a `size`-element algebra |
| `valid_in` | Is a formula `⊤` under every valuation in one algebra? |
| `valid` | Is a formula valid in every finite Heyting algebra up to 5 elements? |
| `all_finite_heyting_algebras` | The exact enumeration used by `valid` (cached) |

```rust
use heyting::{Formula, valid, chain_three};

// Excluded middle fails at 1/2.
use std::ops::Not;
assert_eq!(heyting::Value::Mid.join(!heyting::Value::Mid), heyting::Value::Mid);

// The same failure, in the table algebra and via the validity checker.
let p = Formula::atom(0);
assert!(!valid(&p.clone().or(!p)));       // p ∨ ¬p is not intuitionistically valid
assert!(valid(&Formula::atom(0).implies(Formula::atom(0)))); // p -> p is
assert_eq!(chain_three().size(), 3);
```

## The validity enumeration

`valid` checks a formula against every algebra produced by `all_finite_heyting_algebras`, which is built as:

1. every partial order on `0..n` for `n <= 4` (243 posets),
2. the downset algebra of each poset (at most 16 elements),
3. every subalgebra of every downset algebra (subsets closed under `∧`, `∨`, `->`), deduplicated up to isomorphism.

Every finite Heyting algebra of at most 5 elements appears (by Birkhoff duality: a Heyting algebra of size `k` has at most `k-1` join-irreducibles), so the check is exhaustive up to size 5; the collection also contains 7 algebras of size 6 and larger ones up to the 16-element Boolean algebra.
The full list is cached after the first call.

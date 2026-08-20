# lattices

Lattices and partial orders.

Finite lattices with explicit order, the
join (supremum) and meet (infimum) of a pair, and the key structural
properties --- distributivity, modularity, and the Birkhoff
characterization that a lattice is distributive exactly when it contains no
sublattice isomorphic to M3 (the diamond) or N5 (the pentagon).

## Quick start

```bash
cargo run -p lattices --example join_meet
cargo run -p lattices --example birkhoff
cargo test -p lattices
```

## The idea

A lattice is a finite set with a partial order in which every pair of
elements has a join (supremum: the least upper bound) and a meet (infimum:
the greatest lower bound).

- A lattice is *distributive* when `a ∧ (b ∨ c) = (a ∧ b) ∨ (a ∧ c)` for
  every triple.
- A lattice is *modular* when `a ∨ (b ∧ c) = (a ∨ b) ∧ c` whenever `a ≤ c`.
- *Birkhoff's characterization*: distributive ⇔ no sublattice isomorphic to
  M3 or N5. The diamond M3 is modular but not distributive; the pentagon N5
  is not even modular.

The crate checks the laws directly and also searches for the forbidden
sublattices, so the characterization can be verified on examples.

## Demos

| Demo | What it shows |
|------|---------------|
| `join_meet` | Upper/lower bounds and join/meet on the divisors of 12: join of {2,3} is 6, meet is 1; also rebuilds the poset with `relation_pairs` and prints its Hasse diagram |
| `birkhoff` | Distributivity and modularity of D₁₂, B₃, M3 and N5, plus M3/N5 sublattice search |

## API

| Item | What it does |
|------|--------------|
| `Lattice` | A finite lattice: `elements` plus the `<=` relation |
| `le(a, b)` | Whether `a <= b` |
| `join(a, b)` / `meet(a, b)` | Supremum / infimum of a pair, `Option` if missing |
| `is_lattice()` | Whether every pair has a join and a meet |
| `is_chain()` | Whether every pair is comparable |
| `is_distributive()` / `is_modular()` | Check the lattice laws |
| `has_m3_sublattice()` / `has_n5_sublattice()` | Forbidden sublattice search |
| `is_distributive_birkhoff()` | The Birkhoff characterization as a single check |
| `relation_pairs(n, leq)` | The relation `{(i, j) : leq(i, j)}` as an explicit pair list |
| `hasse(pairs)` | The Hasse diagram (cover relation): transitive pairs removed, strict form |
| `hasse_reflexive(pairs)` | Same, but keeps the reflexive pairs to match the `Lattice` pair format |
| `examples::m3()`, `n5()`, `divisors_12()`, `boolean_3()` | The running examples |

![M3 and N5](assets/lattices-demo.svg)

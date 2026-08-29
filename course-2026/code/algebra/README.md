# algebra

Algebraic structures as Rust traits: semigroup, monoid, group, ring, field.

The hierarchy mirrors the book's algebra chapter. The bottom layer is built
from scratch -- Peano naturals and a hand-rolled Euclidean algorithm -- while
the concrete instances (residue classes, permutations, the boolean field)
sit on the traits and use standard iterators.

## Quick start

```bash
cargo run -p algebra --example from_scratch
cargo run -p algebra --example groups
cargo run -p algebra --example rings
cargo run -p algebra --example cayley
cargo test -p algebra
```

## The idea

A `Semigroup` is a set with an associative operation `op`; a `Monoid` adds
an identity; a `Group` adds an inverse. A `Ring` couples an additive group
with an associative multiplication, and a `Field` is a ring where every
nonzero element is invertible.

The from-scratch layer makes these definitions concrete before any built-in
number type appears: `Nat` is the Peano definition (only `Zero` and `Succ`),
and `gcd` / `extended_gcd` are the hand-rolled Euclidean algorithm that later
produces modular inverses. The instances then use standard iterators.

## Demos

| Demo | What it shows |
|------|---------------|
| `from_scratch` | Peano addition and multiplication, hand-rolled gcd and modular inverse |
| `groups` | Residues mod 8, permutations, the unit group Z_8^*: orders, powers, subgroups |
| `rings` | Zero divisors in Z_6, units of Z_5, the field GF(2) |
| `cayley` | Cayley table of Z_4 and the Latin-square property |
| `dihedral` | D_4: orders, the Cayley table, non-commutativity, the rotation subgroup |
| `table_group` | A group as pure data: axiom checks and a non-group counterexample |

## API

| Item | What it does |
|------|--------------|
| `Semigroup`, `Monoid`, `Group` | Single-operation hierarchy (`op`, `identity`, `inverse`) |
| `Ring`, `Field` | Two-operation hierarchy (`add`, `mul`, `neg`, `inv`) |
| `Zn<N>` | Residue classes mod N: an additive group and a ring |
| `Unit<N>` | Units of Z_N: the multiplicative group Z_N^* |
| `Perm<N>` | Permutations of N elements: the symmetric group S_N |
| `Bool` | GF(2): booleans with XOR and AND, the smallest field |
| `Nat` | Peano naturals (from scratch) |
| `gcd`, `extended_gcd`, `mod_inverse` | Hand-rolled Euclidean algorithm |
| `power`, `order`, `subgroup`, `is_abelian` | Generic helpers on groups |
| `Type` | Types as data: the semiring of types with `cardinality` and `simplify` |
| `Zero`, `One`, `Sum`, `Prod` | The type-level semiring: `0`, `1`, `+`, `*` with isomorphism proofs |
| `BoolSet<T>` | The powerset as a boolean ring: symmetric difference and intersection |
| `Category`, `Hask`, `compose`, `id` | The category of sets: functions as morphisms |
| `curry`, `uncurry`, `constant`, `flip` | Exponentials and morphism combinators |
| `Functor`, `Fix`, `OptionF`, `cata` | Functors and fixed points: `Nat = Fix(Option)` |
| `D4` | The dihedral group of order 8: symmetries of the square |
| `TableGroup` | A finite group given only by its Cayley table, with axiom checks |

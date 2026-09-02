# algebra

Algebraic structures as Rust traits: semigroup, monoid, group, ring, field — plus group homomorphisms, quotient groups, and the finite fields `GF(2^m)`.

The crate is zero-dependency.
Every structure is a trait with a handful of concrete instances: residue classes `Zn<N>` and their units `Unit<N>`, permutations `Perm<N>`, the boolean field `Bool`, the dihedral group `D4`, and the polynomial fields `Gf4` and `Gf256`.
The bottom layer defines the Peano naturals with only the `Zero` and `Succ` constructors and implements the Euclidean algorithm on plain integers, so the definitions are concrete before any built-in number type appears.

## Quick start

```bash
cargo test
cargo run --example from_scratch
cargo run --example groups
cargo run --example rings
cargo run --example cayley
cargo run --example dihedral
cargo run --example table_group
cargo run --example homomorphism
cargo run --example finite_field
```

## The idea

A `Semigroup` is a set with an associative operation `op`: `(a op b) op c = a op (b op c)`.
A `Monoid` adds an identity element with `identity().op(a) = a.op(&identity()) = a`.
A `Group` adds an inverse with `a.op(&a.inverse()) = identity()`.
A `Ring` couples an additive group with an associative multiplication, linked by distributivity.
A `Field` is a ring in which every nonzero element has a multiplicative inverse.

Around the traits stand the standard constructions: powers and orders of a single element, the cyclic subgroup it generates, Cayley tables with their axiom checks, homomorphisms with kernels and cosets, and the quotient-group operation behind the first isomorphism theorem.
The finite fields build `GF(2^m)` as $GF(2)[x]/(f(x))$ for an irreducible polynomial $f$: addition is the XOR of coefficient bits, and multiplication is polynomial multiplication reduced modulo $f$.
The type-level layer tracks the semiring of types, where $|A + B| = |A| + |B|$, $|A \times B| = |A| \cdot |B|$ and $|B^A| = |B|^{|A|}$ hold up to isomorphism, witnessed by pairs of inverse functions.

## Demos

| Demo           | What it shows                                                                           |
| -------------- | --------------------------------------------------------------------------------------- |
| `from_scratch` | Peano addition and multiplication, gcd and the modular inverse from Bézout coefficients |
| `groups`       | Residues mod 8, permutations, the unit group `Z_8^*`: orders, powers, subgroups         |
| `rings`        | Zero divisors in `Z_6`, units of `Z_5`, the field `GF(2)`                               |
| `cayley`       | Cayley table of `Z_4` and the Latin-square property                                     |
| `dihedral`     | `D_4`: orders, the Cayley table, non-commutativity, the rotation subgroup               |
| `table_group`  | A group as pure data: axiom checks and a non-group counterexample                       |
| `homomorphism` | The reduction map `Z_6 -> Z_3`, its kernel and cosets, the first isomorphism theorem    |
| `finite_field` | `GF(4)` addition and multiplication tables, the primitive element, orders in `GF(256)`  |

`from_scratch` computes on data alone: `Nat` values built from `Zero` and `Succ`, then `gcd` and `extended_gcd` on plain integers.
`homomorphism` shows the first isomorphism theorem on `Z_6 -> Z_3`: the kernel is normal, its cosets partition the group, and there is one coset per image element.
`finite_field` prints the `GF(4)` tables, derives $\alpha^2 = \alpha + 1$ from $x^2 + x + 1 = 0$, and compares element orders in the AES byte field `GF(256)`.

## API

| Item                                        | What it does                                                           |
| ------------------------------------------- | ---------------------------------------------------------------------- |
| `Semigroup`, `Monoid`, `Group`              | Single-operation hierarchy: `op`, `identity`, `inverse`                |
| `Ring`, `Field`                             | Two-operation hierarchy: `add`, `mul`, `neg`, `inv`                    |
| `Zn<N>`                                     | Residue classes mod `N`: an additive group and a ring                  |
| `Unit<N>`                                   | Units of `Z_N`: the multiplicative group `Z_N^*`                       |
| `Perm<N>`                                   | Permutations of `N` elements: the symmetric group `S_N`                |
| `Bool`                                      | `GF(2)`: booleans with XOR and AND, the smallest field                 |
| `Nat`                                       | Peano naturals with only the `Zero` and `Succ` constructors            |
| `gcd`, `extended_gcd`, `mod_inverse`        | The Euclidean algorithm and Bézout coefficients                        |
| `power`, `order`, `subgroup`, `is_abelian`  | Generic helpers on groups                                              |
| `Type`                                      | Types as data: the semiring of types with `cardinality` and `simplify` |
| `Zero`, `One`, `Sum`, `Prod`                | The type-level semiring `0`, `1`, `+`, `*` with isomorphism proofs     |
| `BoolSet<T>`                                | The powerset as a boolean ring: symmetric difference and intersection  |
| `Category`, `Hask`, `compose`, `id`         | The category of sets: functions as morphisms                           |
| `curry`, `uncurry`, `constant`, `flip`      | Exponentials and morphism combinators                                  |
| `Functor`, `Fix`, `OptionF`, `cata`         | Functors and fixed points: `Nat = Fix(Option)`                         |
| `D4`                                        | The dihedral group of order 8: symmetries of the square                |
| `TableGroup`                                | A finite group given only by its Cayley table, with axiom checks       |
| `is_homomorphism`, `kernel`, `image`        | Structure-preserving maps and their invariants                         |
| `left_cosets`, `is_normal`, `coset_product` | Cosets, normality, and the quotient group operation                    |
| `Gf<M, MOD>`, `Gf4`, `Gf256`                | The finite fields `GF(2^m)`: `GF(4)` and the byte field of AES         |

## Tests

`tests/algebra_test.rs` checks the axioms exhaustively over finite instances: associativity in `Z_5`, `S_3`, `Z_6` and in the units of `Z_8`, distributivity in `Z_6`, and the field laws in `GF(2)`.
Unit tests inside the modules check orders, inverses, coset partitions, and the isomorphism round-trips.

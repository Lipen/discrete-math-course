# algebra

Algebraic structures as Rust traits: semigroup, monoid, group, ring, field — plus group homomorphisms, quotient groups, and the finite fields `GF(2^m)`.

Every structure is a trait with concrete instances:

- residue classes `Zn<N>` and their units `Unit<N>`
- permutations `Perm<N>`, the symmetric group `S_N`
- the two-element field `Bool`, `GF(2)`
- the dihedral group `D4`, the symmetries of the square
- the polynomial fields `Gf4` and `Gf256`: `GF(4)` and the AES byte field
- the Peano naturals `Nat` and the Euclidean algorithm, concrete before any built-in number type appears

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

### The trait hierarchy

Each trait adds one ingredient to the previous:

| Trait       | Adds                                                              | Law                                        |
| ----------- | ----------------------------------------------------------------- | ------------------------------------------ |
| `Semigroup` | an associative operation `op`                                     | `(a op b) op c = a op (b op c)`            |
| `Monoid`    | an identity element                                               | `identity().op(a) = a.op(&identity()) = a` |
| `Group`     | an inverse element                                                | `a.op(&a.inverse()) = identity()`          |
| `Ring`      | `add` and `mul` with `zero`, `one`, `neg`, tied by distributivity | `a * (b + c) = a*b + a*c`                  |
| `Field`     | a multiplicative inverse of every nonzero element                 | `a * a^{-1} = 1` for `a != 0`              |

### Constructions

Around the traits stand the standard constructions:

- powers and orders of a single element, and the cyclic subgroup it generates
- Cayley tables with their axiom checks
- homomorphisms with kernels, images, and cosets
- the quotient-group operation behind the first isomorphism theorem

### Finite fields

The finite fields build `GF(2^m)` as a quotient of the polynomial ring over `GF(2)`:

$$GF(2^m) \cong GF(2)[x]/(f(x))$$

for an irreducible polynomial $f$ of degree $m$: addition is the XOR of coefficient bits, and multiplication is polynomial multiplication reduced modulo $f$.

### The type-level layer

Types themselves form a semiring, tracked here at the type level:

$$|A + B| = |A| + |B| \qquad |A \times B| = |A| \cdot |B| \qquad |B^A| = |B|^{|A|}$$

The laws hold up to isomorphism, witnessed by pairs of inverse functions.

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

### Traits

| Item                           | What it does                                            |
| ------------------------------ | ------------------------------------------------------- |
| `Semigroup`, `Monoid`, `Group` | Single-operation hierarchy: `op`, `identity`, `inverse` |
| `Ring`, `Field`                | Two-operation hierarchy: `add`, `mul`, `neg`, `inv`     |

### Instances

| Item                         | What it does                                                     |
| ---------------------------- | ---------------------------------------------------------------- |
| `Zn<N>`                      | Residue classes mod `N`: an additive group and a ring            |
| `Unit<N>`                    | Units of `Z_N`: the multiplicative group `Z_N^*`                 |
| `Perm<N>`                    | Permutations of `N` elements: the symmetric group `S_N`          |
| `Bool`                       | `GF(2)`: booleans with XOR and AND, the smallest field           |
| `Nat`                        | Peano naturals with only the `Zero` and `Succ` constructors      |
| `D4`                         | The dihedral group of order 8: symmetries of the square          |
| `TableGroup`                 | A finite group given only by its Cayley table, with axiom checks |
| `Gf<M, MOD>`, `Gf4`, `Gf256` | The finite fields `GF(2^m)`: `GF(4)` and the byte field of AES   |

### Functions

| Item                                        | What it does                                        |
| ------------------------------------------- | --------------------------------------------------- |
| `gcd`, `extended_gcd`, `mod_inverse`        | The Euclidean algorithm and Bézout coefficients     |
| `power`, `order`, `subgroup`, `is_abelian`  | Generic helpers on groups                           |
| `is_homomorphism`, `kernel`, `image`        | Structure-preserving maps and their invariants      |
| `left_cosets`, `is_normal`, `coset_product` | Cosets, normality, and the quotient group operation |

### Type-level layer

| Item                                   | What it does                                                           |
| -------------------------------------- | ---------------------------------------------------------------------- |
| `Type`                                 | Types as data: the semiring of types with `cardinality` and `simplify` |
| `Zero`, `One`, `Sum`, `Prod`           | The type-level semiring `0`, `1`, `+`, `*` with isomorphism proofs     |
| `BoolSet<T>`                           | The powerset as a boolean ring: symmetric difference and intersection  |
| `Category`, `Hask`, `compose`, `id`    | The category of sets: functions as morphisms                           |
| `curry`, `uncurry`, `constant`, `flip` | Exponentials and morphism combinators                                  |
| `Functor`, `Fix`, `OptionF`, `cata`    | Functors and fixed points: `Nat = Fix(Option)`                         |

## Tests

`tests/algebra_test.rs` checks the axioms exhaustively over finite instances:

- associativity in `Z_5`, `S_3`, `Z_6`, and the units of `Z_8`
- distributivity in `Z_6`
- the field laws in `GF(2)`

Unit tests inside the modules check orders, inverses, coset partitions, and the isomorphism round-trips.

# categories

Finite categories, functors, natural transformations, and the Yoneda bijection, all small enough to verify by exhaustive search.
A category is stored as a list of objects, a list of named morphisms, and a full composition table, so every law in sight becomes a loop that can actually run.

## Quick start

```bash
cargo run --example monoid_category
cargo run --example free_category
cargo run --example yoneda_check
cargo run --example kleisli
cargo test
```

## The idea

A category has objects and morphisms, and every composable pair $A \xrightarrow{f} B \xrightarrow{g} C$ has a composite $g \circ f : A \to C$.
Composition is associative, and each object $A$ has an identity morphism $\mathrm{id}_A$ with

$$\mathrm{id}_B \circ f = f = f \circ \mathrm{id}_A$$

Everything here is finite: the crate keeps the entire composition table, so checking a law means walking the table.

### Three builders

| Builder           | Category                 | Morphisms                                                |
| ----------------- | ------------------------ | -------------------------------------------------------- |
| `from_monoid`     | one object               | the elements of the monoid, composed by the Cayley table |
| `from_poset`      | a reflexive relation     | exactly one morphism $a \to b$ when $a \le b$            |
| `free_from_graph` | a directed acyclic graph | paths, with `e2*e1` meaning $e_2$ after $e_1$            |

`check_axioms` walks the table and verifies associativity and the identity laws.
A bad table, such as a non-associative multiplication or a non-transitive relation, builds a category that fails the check.

### Functors

A `Functor` carries every object and every morphism of a source category into a target category.
`check` verifies the two functor laws:

$$F(\mathrm{id}_A) = \mathrm{id}_{F(A)} \qquad F(g \circ f) = F(g) \circ F(f)$$

### Natural transformations and Yoneda

A `SetFunctor` assigns a finite set to every object and a function to every morphism.
A `NaturalTransformation` $\tau : F \Rightarrow G$ assigns a component function $\tau_A : F(A) \to G(A)$ to every object, and naturality asks every square of the following shape to commute:

$$G(f) \circ \tau_A = \tau_B \circ F(f)$$

`natural_transformations` enumerates every family of component functions and keeps the natural ones.

The Yoneda lemma says that the natural transformations out of a hom-functor are just the elements of $F$ at the focus object:

$$\mathrm{Nat}(\mathrm{Hom}(A, -),\, F) \cong F(A), \qquad \tau \mapsto \tau_A(\mathrm{id}_A)$$

`yoneda` builds the left side by exhaustive enumeration and checks that this canonical map is a bijection.

![The naturality square every family of components must satisfy](assets/naturality-square.svg)

### Kleisli composition

For the Option and List monads, `kleisli_option` and `kleisli_vec` compose arrows $A \to T(B)$ and $B \to T(C)$ into an arrow $A \to T(C)$ through the monad, with `unit_option` and `unit_vec` as the units.
Associativity of the composition and the unit laws hold on the concrete pipelines of the tests.

## Demos

| Demo              | What it shows                                                                        |
| ----------------- | ------------------------------------------------------------------------------------ |
| `monoid_category` | $\mathbb{Z}_4$ as a one-object category: the composition table is the Cayley table   |
| `free_category`   | the six paths of `A -a-> B -b-> C` and how composition glues them end to end         |
| `yoneda_check`    | the bijection on the monoid, the chain $0 < 1 < 2$, and the free category of a graph |
| `kleisli`         | an Option pipeline with early exits, then Vec pipelines and the Kleisli laws         |

## API

| Item                              | What it does                                                                    |
| --------------------------------- | ------------------------------------------------------------------------------- |
| `ObjId` / `Morphism`              | an object index / a named morphism with `src` and `dst`                         |
| `FiniteCategory`                  | objects, morphisms, and a total composition table                               |
| `FiniteCategory::from_monoid`     | the one-object category of a monoid                                             |
| `FiniteCategory::from_poset`      | the thin category of a reflexive relation                                       |
| `FiniteCategory::free_from_graph` | the free category of a directed acyclic graph                                   |
| `compose(f, g)` / `identity(o)`   | the composite `g` after `f` / the identity of an object                         |
| `check_axioms`                    | associativity and the identity laws over the whole table                        |
| `Functor` / `check`               | images of objects and morphisms / the two functor laws                          |
| `SetFunctor` / `check`            | sets and functions over a category / preservation of identities and composition |
| `hom_functor(cat, a)`             | the covariant hom-functor $\mathrm{Hom}(a, -)$                                  |
| `natural_transformations`         | all natural transformations between two set-valued functors, by search          |
| `yoneda(cat, a, f)`               | $\mathrm{Nat}(\mathrm{Hom}(a, -), F)$ and the verdict on the bijection          |
| `kleisli_option` / `kleisli_vec`  | composition through Option / Vec                                                |
| `unit_option` / `unit_vec`        | the units of the two monads                                                     |

## Tests

`cargo test` runs four integration files.
`category_test.rs` checks the axioms of all three builders, composition spot checks, a non-associative table and a non-transitive relation that must fail, a cyclic graph that must panic, and the empty and single-morphism categories.
`functor_test.rs` checks the functor laws, including a shift map and a wrong hom-set that must fail the check.
`yoneda_test.rs` runs the Yoneda bijection on the three categories and verifies the SetFunctor laws, including a broken functor that must fail.
`kleisli_test.rs` checks associativity, the unit laws, and short-circuiting for both monads.

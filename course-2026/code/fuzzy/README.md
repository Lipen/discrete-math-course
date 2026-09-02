# fuzzy

Fuzzy sets, fuzzy numbers, and fuzzy relations.

A fuzzy set replaces the crisp characteristic function $\chi\colon U \to \{0, 1\}$ with a membership function $\mu\colon U \to [0, 1]$: an element belongs to the set *to some degree*.
The crate models the standard shapes (triangular, trapezoidal, and any polyline) as piecewise-linear functions, implements Zadeh's operations (union `max`, intersection `min`, complement `1 - mu`), the three classical t-norm/t-conorm families, fuzzy numbers with their alpha-cuts, and fuzzy relations with max-min composition.

## Quick start

```bash
cargo run --example operations
cargo run --example fuzzy_numbers
cargo run --example relations
cargo test
```

## The idea

Membership is a degree, not a switch.
A person 175 cm tall is "high" to degree 0.5 and "not high" to degree 0.5 at the same time, so the law of the excluded middle fails: $\mu(A \cup \lnot A)(x) = \max(\mu, 1 - \mu) < 1$ for any intermediate $\mu$.
Choosing a t-norm is choosing the semantics of "and": `min` is idempotent, the product is cautious (two 0.7 experts give 0.49), and Lukasiewicz restores the law of contradiction at the price of idempotency.

Alpha-cuts reconnect the fuzzy world to the crisp one: a cut $\{x : \mu(x) \ge \alpha\}$ is an ordinary set, and the whole membership function is recovered as $\mu(x) = \sup\{a : x \in A_a\}$ (the decomposition theorem).

## API

| Item                                         | What it does                                                                                       |
| -------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| `FuzzySet`                                   | A fuzzy set as a piecewise-linear membership function: sorted `(x, mu)` breakpoints                |
| `membership` / `height` / `support` / `core` | Degree at a point, the maximum degree, the positive region, the `mu = 1` region                    |
| `alpha_cut`                                  | $\{x : \mu(x) \ge \alpha\}$ as intervals: `alpha_cut(0)` spans the set, `alpha_cut(1)` is the core |
| `decompose_at`                               | The decomposition theorem: $\mu(x) = \sup\{a : x \in A_a\}$                                        |
| `union` / `intersection` / `complement`      | Zadeh operations `max`, `min`, `1 - mu` (exact on piecewise-linear sets)                           |
| `TNorm`                                      | `Zadeh`, `Product`, `Lukasiewicz`, each with `norm` (AND) and `conorm` (OR)                        |
| `Triangular` / `Trapezoidal`                 | Fuzzy numbers: membership, alpha-cuts, componentwise add/sub/mul                                   |
| `FuzzyRelation`                              | A fuzzy relation as a matrix, with `max_min_compose` and `max_product_compose`                     |

## Demos

| Demo            | What it shows                                                                                                                                         |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `operations`    | Union, intersection, and complement on "high" vs "middle", De Morgan, the failure of the excluded middle, and the three t-norms on `a = 0.6, b = 0.7` |
| `fuzzy_numbers` | Triangular number membership, alpha-cuts, arithmetic, and reconstruction from cuts                                                                    |
| `relations`     | "x is close to y" on four towns, plus max-min and max-product composition                                                                             |

`operations` shows Zadeh union/intersection/complement as exact piecewise-linear sets and contrasts the three t-norm families on one pair of degrees.
`fuzzy_numbers` recovers a membership value from its alpha-cuts, demonstrating the decomposition theorem.
`relations` composes a closeness relation with itself: towns 1 and 4 are not directly close but become close through a middle town.

## Tests

Unit tests live next to each module.
`set.rs` covers the cuts, De Morgan, and the failure of the excluded middle, `number.rs` the shapes and their arithmetic, `relation.rs` both compositions.

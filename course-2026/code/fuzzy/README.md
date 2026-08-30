# fuzzy

Fuzzy sets, fuzzy numbers, fuzzy relations, and Mamdani inference.

A fuzzy set replaces the crisp `chi: U -> {0, 1}` with a membership function
`mu: U -> [0, 1]`: an element belongs to the set *to some degree*. The crate
models the standard shapes (triangular, trapezoidal, and any polyline) as
piecewise-linear functions, implements Zadeh's operations (union `max`,
intersection `min`, complement `1 - mu`), the three classical t-norm/t-conorm
families, fuzzy numbers with their alpha-cuts, fuzzy relations with max-min
composition, and a Mamdani controller that turns crisp inputs into a crisp
output.

## Quick start

```bash
cargo run -p fuzzy --example operations
cargo run -p fuzzy --example fuzzy_numbers
cargo run -p fuzzy --example relations
cargo run -p fuzzy --example controller
cargo test -p fuzzy
```

## The idea

Membership is a degree, not a switch. A person 175 cm tall is "high" to
degree 0.5 and "not high" to degree 0.5 at the same time, so the law of the
excluded middle fails: `mu(A ∪ ¬A)(x) = max(mu, 1 - mu) < 1` for any
intermediate `mu`. Choosing a t-norm is choosing the semantics of "and":
`min` is idempotent, the product is cautious (two 0.7 experts give 0.49), and
Lukasiewicz restores the law of contradiction at the price of idempotency.

Alpha-cuts reconnect the fuzzy world to the crisp one: a cut `{x : mu(x) >= a}`
is an ordinary set, and the whole membership function is recovered as
`mu(x) = sup {a : x in A_a}` (the decomposition theorem). A Mamdani
controller then fuzzifies crisp inputs, fires rules proportionally, aggregates
the clipped consequents, and defuzzifies the result into one number with a
centroid, mean-of-max, or bisector.

## API

| Item | What it does |
|------|--------------|
| `FuzzySet` | A fuzzy set as a piecewise-linear membership function: sorted `(x, mu)` breakpoints |
| `membership` / `height` / `support` / `core` | Degree at a point, the maximum degree, the positive region, the `mu = 1` region |
| `alpha_cut` | `{x : mu(x) >= alpha}` as intervals; `alpha_cut(0)` spans the set, `alpha_cut(1)` is the core |
| `decompose_at` | The decomposition theorem: `sup {a : x in A_a}` |
| `union` / `intersection` / `complement` | Zadeh operations `max`, `min`, `1 - mu` (exact on piecewise-linear sets) |
| `clip` | `min(mu, level)`: truncate a consequent at a firing strength |
| `TNorm` | `Zadeh`, `Product`, `Lukasiewicz`, each with `norm` (AND) and `conorm` (OR) |
| `Triangular` / `Trapezoidal` | Fuzzy numbers: membership, alpha-cuts, componentwise add/sub/mul |
| `FuzzyRelation` | A fuzzy relation as a matrix; `max_min_compose` and `max_product_compose` |
| `Mamdani` | A rule base plus linguistic variables: `fuzzify`, `firing_strength`, `aggregate`, `infer` |
| `defuzzify` / `centroid` / `mean_of_max` / `bisector` | The three defuzzification methods |

## Demos

| Demo | What it shows |
|------|---------------|
| `operations` | Union/intersection/complement on "high" vs "middle", De Morgan, the failure of the excluded middle, and the three t-norms on `a = 0.6, b = 0.7` |
| `fuzzy_numbers` | TFN membership, alpha-cuts, arithmetic, and reconstruction from cuts |
| `relations` | "x is close to y" on four towns, plus max-min and max-product composition |
| `controller` | A Mamdani air conditioner: fuzzification, firing strengths, aggregation, defuzzification, and a smooth sweep |

## Tests

```bash
cargo test -p fuzzy
```

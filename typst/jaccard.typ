#import "@preview/cetz:0.4.0"
#import "@preview/cetz-venn:0.1.4"

#show emph: set text(fill: blue.darken(20%))

#let JaccardDist = $d_J$

= Distance between Sets

Define the _Jaccard distance_ (measure of dissimilarity) between two sets $S_i$ and $S_j$ as:
$
  JaccardDist(S_i, S_j)
  = 1 - abs(S_i inter S_j) / abs(S_i union S_j)
  = abs(S_i triangle S_j) / abs(S_i union S_j)
$

#align(center)[
  #grid(
    columns: 2,
    align: left,
    column-gutter: 2em,
    cetz.canvas({
      cetz-venn.venn3(
        a-fill: blue.transparentize(80%),
        b-fill: green.transparentize(80%),
        c-fill: red.transparentize(80%),
        ab-fill: red.transparentize(80%),
        ac-fill: green.transparentize(80%),
        bc-fill: blue.transparentize(80%),
        abc-fill: yellow.transparentize(80%),
        a-stroke: 1pt + blue.darken(20%),
        b-stroke: 1pt + green.darken(20%),
        c-stroke: 1pt + red.darken(20%),
        abc-stroke: 1pt + yellow.darken(20%),
        padding: 0.4,
        name: "venn",
      )
      import cetz.draw: *
      content("venn.a", [$T_1$])
      content((rel: (-.7, .7), to: "venn.a"), [$S_1$])
      content("venn.b", [$T_2$])
      content((rel: (.7, .7), to: "venn.b"), [$S_2$])
      content("venn.c", [$T_3$])
      content((rel: (.9, -.6), to: "venn.c"), [$S_3$])
      content("venn.ab", [$T_3$])
      content("venn.ac", [$T_2$])
      content("venn.bc", [$T_1$])
      content("venn.abc", [$V$])
      content("venn.not-abc", [$U$], anchor: "south-west")
    }),
    [
      Let $U = union.big S_i$ and $V = inter.big S_i$.
      Define sets $T_i$:
      $
        #text(fill: blue.darken(20%))[$T_1$] = (S_1 without (S_2 union S_3)) union ((S_2 inter S_3) without S_1) \
        #text(fill: green.darken(20%))[$T_2$] = (S_2 without (S_1 union S_3)) union ((S_1 inter S_3) without S_2) \
        #text(fill: red.darken(20%))[$T_3$] = (S_3 without (S_1 union S_2)) union ((S_1 inter S_2) without S_3)
      $
      Or more generally:
      $
        T_i = (S_i without (S_j union S_k)) union ((S_j inter S_k) without S_i)
      $
    ],
  )
]

Let's prove that the Jaccard distance satisfies the _triangle inequality_:
$
  JaccardDist(S_i, S_j) + JaccardDist(S_j, S_k) >= JaccardDist(S_i, S_k)
$

*Step 1:*
The sum of $T_i$ is exactly $U$ without the triple intersection $V$:
$
  abs(T_1) + abs(T_2) + abs(T_3) = abs(U) - abs(V)
$

Which can be rearranged to:
$
  (abs(T_1) + abs(T_2) + abs(T_3)) / abs(U) = 1 - abs(V) / abs(U)
$

*Step 2:*
Take any pair $S_i, S_j$ and let $k$ be the remaining index.
Compute the symmetric difference:
$
  S_i triangle S_j
  = & (S_i without S_j) union (S_j without S_i) \
  = & ((S_i without (S_j union S_k)) union ((S_i inter S_k) without S_j)) union \
    & quad union ((S_j without (S_i union S_k)) union ((S_j inter S_k) without S_i)) \
  = & T_i union T_j
$

Since $T_i$ are pairwise disjoint, we have $abs(S_i triangle S_j) = abs(T_i) + abs(T_j)$.
Therefore, the Jaccard distance is:
$
  JaccardDist(S_i, S_j) = abs(S_i triangle S_j) / abs(S_i union S_j) = (abs(T_i) + abs(T_j)) / abs(S_i union S_j)
$

*Step 3:*
Use two monotonicity facts about set sizes:
+ For the union, $abs(S_i union S_j) <= abs(U)$.
  Dividing by a _smaller_ number makes the fraction _larger_, so:
  $
    JaccardDist(S_i, S_j)
    = (abs(T_i) + abs(T_j)) / abs(S_i union S_j)
    >= (abs(T_i) + abs(T_j)) / abs(U)
  $
+ For the intersection: $abs(S_i inter S_j) >= abs(V)$.
  Dividing by a _larger_ number makes the fraction _smaller_, so:
  $
    abs(S_i inter S_j) / abs(S_i union S_j)
    >= abs(V) / abs(U)
  $

Now recall (see Step 1) that $1 - abs(V) "/" abs(U) = (abs(T_1) + abs(T_2) + abs(T_3)) "/" abs(U)$, so this is the upper bound:
$
  JaccardDist(S_i, S_j) <= (abs(T_1) + abs(T_2) + abs(T_3)) / abs(U)
$

Thus for every pair $i, j$ we have the sandwich:
$
  (abs(T_i) + abs(T_j)) / abs(U)
  <= JaccardDist(S_i, S_j)
  <= (abs(T_1) + abs(T_2) + abs(T_3)) / abs(U)
  = 1 - abs(V) / abs(U)
$

*Step 4:*
Combine the inequalities for the distances $JaccardDist(S_1, S_2)$ and $JaccardDist(S_2, S_3)$.

Using the lower bounds, we have:
$
  JaccardDist(S_1, S_2) + JaccardDist(S_2, S_3)
  >= (abs(T_1) + abs(T_2)) / abs(U) + (abs(T_2) + abs(T_3)) / abs(U)
  = (abs(T_1) + 2 dot abs(T_2) + abs(T_3)) / abs(U)
$

Since $2 dot abs(T_2) >= abs(T_2)$, we have:
$
  (abs(T_1) + 2 dot abs(T_2) + abs(T_3)) / abs(U)
  >= (abs(T_1) + abs(T_2) + abs(T_3)) / abs(U)
  = 1 - abs(V) / abs(U)
$

But from the upper bound, we have $JaccardDist(S_1, S_3) <= 1 - abs(V) "/" abs(U)$.
Therefore:
$
  JaccardDist(S_1, S_2) + JaccardDist(S_2, S_3)
  >= 1 - abs(V) / abs(U)
  >= JaccardDist(S_1, S_3)
$

Hence $JaccardDist(S_1, S_2) + JaccardDist(S_2, S_3) >= JaccardDist(S_1, S_3)$.
The same argument works for any other permutation of indices, so the triangle inequality for the Jaccard distance is proven.
#h(1fr)$square$

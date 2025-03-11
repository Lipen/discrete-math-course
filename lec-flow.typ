#import "theme.typ": *
#show: slides.with(
  title: [Discrete Mathematics],
  subtitle: "Network Flows",
  date: "Spring 2025",
  authors: "Konstantin Chukharev",
  ratio: 16 / 9,
  // dark: true,
)

#show emph: set text(blue.lighten(20%))

#let In = $op("in")$
#let Out = $op("out")$

= Network Flows

== Motivation

TODO: a picture with a graph and a question about the flow in it

== Flow Network

#definition[
  A _flow network_ is a directed graph $G = angle.l V, E angle.r$ with:
  - a _source_ $s in V$, a vertex without incoming edges,
  - a _sink_ $t in V$, a vertex without outgoing edges,
  - a _capacity_ function $c: E to RR_+$ that assigns a non-negative capacity to each edge $e in E$.

  The flow network is denoted as $N = angle.l V, E, s, t, c angle.r$.
]

#note[
  We require that $E$ never contains both edges $(u, v)$ and $(v, u)$ for any $u, v in V$.
]

#note[
  If $(u, v) notin E$, then $c(u, v) = 0$.
]

#note[
  The graph is connected, i.e., every node has at least one incident edge.
]

== Flow Network Example

#example[
  Very meaningful example of a flow network with annotated capacities:
]
#align(center)[
  #import fletcher: diagram, node, edge
  #diagram(
    spacing: (2cm, 0.5cm),
    edge-stroke: 1pt,
    blob((0, 0), $s$, shape: fletcher.shapes.circle, tint: green, name: <s>),
    blob((3, 0), $t$, shape: fletcher.shapes.circle, tint: red, name: <t>),
    blob((1, -1), $a$, shape: fletcher.shapes.circle, tint: blue, name: <n1>),
    blob((1, 1), $b$, shape: fletcher.shapes.circle, tint: blue, name: <n2>),
    blob((2, -1), $c$, shape: fletcher.shapes.circle, tint: blue, name: <n3>),
    blob((2, 1), $d$, shape: fletcher.shapes.circle, tint: blue, name: <n4>),
    edge(<s>, <n1>, "-}>", label-side: center, label-angle: auto, bend: 15deg)[$16$],
    edge(<s>, <n2>, "-}>", label-side: center, label-angle: auto, bend: -15deg)[$13$],
    edge(<n1>, <n3>, "-}>", label-side: center, label-angle: auto)[$12$],
    edge(<n2>, <n4>, "-}>", label-side: center, label-angle: auto)[$14$],
    edge(<n2>, <n1>, "-}>", label-side: center)[$4$],
    edge(<n3>, <n2>, "-}>", label-side: center, label-angle: auto)[$9$],
    edge(<n3>, <t>, "-}>", label-side: center, label-angle: auto, bend: 15deg)[$20$],
    edge(<n4>, <t>, "-}>", label-side: center, label-angle: auto, bend: -15deg)[$4$],
    edge(<n4>, <n3>, "-}>", label-side: center)[$7$],
  )
]

== Flow

#definition[
  Given a flow network $N$, a _flow_ is a function $f: E to RR_+$ that satisfies the following _feasibility_ conditions:
  + _Capacity constraint_: $0 lt.eq f(e) lt.eq c(e)$ for each edge $e in E$.
  + _Flow conservation (balance constraint)_: for each node $v in V$, except for $s$ and $t$,
  $ underbrace(sum_(e in In(v)) f(e), #[flow into $v$]) = underbrace(sum_(e in Out(v)) f(e), #[flow out of $v$]) $
]

#note[
  If $(u, v) notin E$, then $f(u, v) = 0$.
]

== Flow Value

#definition[
  The _value_ $abs(f)$ of a flow $f$ is the total amount of flow that leaves the source $s$:
  $
    abs(f) = sum_(e in Out(s)) f(e) - underbrace(sum_(e in In(s)) f(e), "commonly 0")
  $
]

#note[
  $f^"in" (v) := sum_(e in In(v)) f(e)$
]
#note[
  $f^"out" (v) := sum_(e in Out(v)) f(e)$
]

#definition[Maximum Flow Problem][
  Given a flow network $N$, the _maximum flow problem_ is to find a flow $f$ that maximizes the value $abs(f)$.
]

== Max Flow Example

#example[Yet another meaningful example.]
#v(1em)
#place(center)[
  #import fletcher: diagram, node, edge
  #diagram(
    spacing: (2cm, 0.5cm),
    edge-stroke: 1pt,
    blob((0, 0), $s$, shape: fletcher.shapes.circle, tint: green, name: <s>),
    blob((3, 0), $t$, shape: fletcher.shapes.circle, tint: red, name: <t>),
    blob((1, -1), $a$, shape: fletcher.shapes.circle, tint: blue, name: <n1>),
    blob((1, 1), $b$, shape: fletcher.shapes.circle, tint: blue, name: <n2>),
    blob((2, -1), $c$, shape: fletcher.shapes.circle, tint: blue, name: <n3>),
    blob((2, 1), $d$, shape: fletcher.shapes.circle, tint: blue, name: <n4>),
    edge(<s>, <n1>, "-}>", label-side: center, label-angle: auto, bend: 15deg)[$4$],
    edge(<s>, <n2>, "-}>", label-side: center, label-angle: auto, bend: -15deg)[$2$],
    edge(<n1>, <n3>, "-}>", label-side: center, label-angle: auto)[$3$],
    edge(<n2>, <n4>, "-}>", label-side: center, label-angle: auto)[$3$],
    edge(<n2>, <n3>, "-}>", label-side: center, label-angle: auto, bend: -15deg)[$2$],
    edge(<n3>, <n2>, "-}>", label-side: center, label-angle: auto, bend: -15deg)[$1$],
    edge(<n3>, <t>, "-}>", label-side: center, label-angle: auto, bend: 15deg)[$2$],
    edge(<n4>, <t>, "-}>", label-side: center, label-angle: auto, bend: -15deg)[$4$],
  )

  #diagram(
    spacing: (2cm, 0.5cm),
    edge-stroke: 1pt,
    mark-scale: 150%,
    blob((0, 0), $s$, shape: fletcher.shapes.circle, tint: green, name: <s>),
    blob((3, 0), $t$, shape: fletcher.shapes.circle, tint: red, name: <t>),
    blob((1, -1), $a$, shape: fletcher.shapes.circle, tint: blue, name: <n1>),
    blob((1, 1), $b$, shape: fletcher.shapes.circle, tint: blue, name: <n2>),
    blob((2, -1), $c$, shape: fletcher.shapes.circle, tint: blue, name: <n3>),
    blob((2, 1), $d$, shape: fletcher.shapes.circle, tint: blue, name: <n4>),
    edge(<s>, <n1>, "-}>", label-side: center, label-angle: auto, extrude: (-2.5, 0, 2.5), bend: 15deg)[$3 slash 4$],
    edge(<s>, <n2>, "-}>", label-side: center, label-angle: auto, extrude: (-1.25, 1.25), bend: -15deg)[$2 slash 2$],
    edge(<n1>, <n3>, "-}>", label-side: center, label-angle: auto, extrude: (-2.5, 0, 2.5))[$3 slash 3$],
    edge(<n2>, <n4>, "-}>", label-side: center, label-angle: auto, extrude: (-2.5, 0, 2.5))[$3 slash 3$],
    edge(<n2>, <n3>, "--}>", label-side: center, label-angle: auto, bend: -15deg)[$0 slash 2$],
    edge(<n3>, <n2>, "-}>", label-side: center, label-angle: auto, bend: -15deg)[$1 slash 1$],
    edge(<n3>, <t>, "-}>", label-side: center, label-angle: auto, extrude: (-1.25, 1.25), bend: 15deg)[$2 slash 2$],
    edge(<n4>, <t>, "-}>", label-side: center, label-angle: auto, extrude: (-2.5, 0, 2.5), bend: -15deg)[$3 slash 4$],
  )
]

== Flow Conservation

#theorem[
  For any feasible flow $f$, the net flow out of $s$ is equal to the net flow into $t$:
  $
    abs(f) = sum_(e in Out(s)) f(e) = sum_(e in In(t)) f(e)
  $
]
#proof[
  This follows directly from the flow conservation condition.
  $
    abs(f) &= sum_(e in Out(s)) f(e) = \
    &= sum_(e in Out(s)) f(e) - sum_(v in V setminus {s,t}) [ sum_(e in In(v)) f(e) - sum_(e in Out(v)) f(e) ] = \
    &= sum_(e in In(t)) f(e)
  $
]

== Residual Capacity

#definition[
  The _skew-symmetry_ convention defines the flow in the opposite direction of an edge $e = (u, v)$ as $f(v, u) = -f(u, v)$.
]

#definition[
  Given a flow $f$ in a flow network $N$, the _residual capacity_ $c_f$ of an edge $e$ is the amount of flow that can be sent through the edge in addition to the flow already in it:
  $ c_f (e) := c(e) - f(e) $
]

== Residual Network

#definition[
  The _residual network_ $N_f$ for a flow $f$ is a flow network with the same vertices as $N$, constructed as follows:
  - _Forward edges_: For each edge $e = (u, v)$ of $N$, if $f(e) < c(e)$, add an edge $e' = (u, v)$ to $N_f$ with~capacity $c(e) - f(e)$.
  - _Backward edges_: For each edge $e = (u, v)$ in $N$, if $f(e) > 0$, add a reversed edge $e' = (v, u)$ to $N_f$ with capacity $f(e)$.

  In other words, a residual network is a directed graph with _all_ edges with _positive_ residual capacity.
]

== Residual Network Example

- _Remaining capacity:_ If $f(e) < c(e)$, add edge $e$ to $N_f$ with capacity $c(e) - f(e)$.
- _Can erase up to $f(e)$ capacity:_ If $f(u, v) > 0$, add reversed edge $(v, u)$ to $N_f$ with capacity $f(e)$.

#align(bottom + center)[
  #grid(
    columns: 2,
    column-gutter: 2cm,
    row-gutter: 1em,
    [*Network $N$ with flow $f$*], [*Residual Network $N_f$*],
    [
      #import fletcher: diagram, node, edge
      #diagram(
        spacing: (2cm, 1cm),
        edge-stroke: 1pt,
        blob((0, 0), $s$, shape: fletcher.shapes.circle, tint: green, name: <s>),
        blob((2, 0), $t$, shape: fletcher.shapes.circle, tint: red, name: <t>),
        blob((1, -1), $a$, shape: fletcher.shapes.circle, tint: blue, name: <n1>),
        blob((1, 1), $b$, shape: fletcher.shapes.circle, tint: blue, name: <n2>),
        edge(<s>, <n1>, "-}>", label-side: center, label-angle: auto, stroke: 2pt + red, bend: 15deg)[$20 slash 20$],
        edge(<s>, <n2>, "-}>", label-side: center, label-angle: auto, bend: -15deg)[$0 slash 10$],
        edge(<n1>, <n2>, "-}>", label-side: center, stroke: 2pt + red)[$20 slash 30$],
        edge(<n1>, <t>, "-}>", label-side: center, label-angle: auto, bend: 15deg)[$0 slash 10$],
        edge(<n2>, <t>, "-}>", label-side: center, label-angle: auto, stroke: 2pt + red, bend: -15deg)[$20 slash 20$],
      )
    ],
    [
      #import fletcher: diagram, node, edge
      #diagram(
        spacing: (2cm, 1cm),
        edge-stroke: 1pt,
        blob((0, 0), $s$, shape: fletcher.shapes.circle, tint: green, name: <s>),
        blob((2, 0), $t$, shape: fletcher.shapes.circle, tint: red, name: <t>),
        blob((1, -1), $a$, shape: fletcher.shapes.circle, tint: blue, name: <n1>),
        blob((1, 1), $b$, shape: fletcher.shapes.circle, tint: blue, name: <n2>),
        edge(<s>, <n1>, "<{-", label-side: center, label-angle: auto, stroke: red, bend: 15deg)[$20$],
        edge(<s>, <n2>, "-}>", label-side: center, label-angle: auto, bend: -15deg)[$10$],
        edge(<n1>, <n2>, "<{-", label-side: center, stroke: red, bend: 30deg)[$20$],
        edge(<n1>, <n2>, "-}>", label-side: center, bend: -30deg)[$10$],
        edge(<n1>, <t>, "-}>", label-side: center, label-angle: auto, bend: 15deg)[$10$],
        edge(<n2>, <t>, "<{-", label-side: center, label-angle: auto, stroke: red, bend: -15deg)[$20$],
      )
    ],
  )
]

== Augmenting Paths

#definition[
  An _augmenting path_ in the residual network $N_f$ is an $s$-$t$ path (a path from $s$ to $t$) such that all edges in the path have positive capacity.
  The _bottleneck_ of an augmenting path is the minimum capacity of the edges in the path.
]

#theorem[
  If _bottleneck_ is positive, then the flow can be increased by that amount along the path.
]

== Ford-Fulkerson Algorithm

#lovelace.pseudocode-list(
  // title: [Ford-Fulkerson, 1956],
  hooks: 0.5em,
  // line-gap: 0.7em,
)[
  - #smallcaps[*Input:*] A flow network $N$ with source $s$ and sink $t$.
  - #smallcaps[*Output:*] Maximum flow $f$ from $s$ to $t$.

  + Initialize $f(e) = 0$ for all $e in E$
  + *while* there is an augmenting path $P$ in the residual network $N_f$ *do*
    + Let $b = min_(e in P) c'(e)$ in $N_f$ along $P$
    + *for each* edge $e in P$ *do*
      + Update flow: $f(e) := f(e) + b$
    + Rebuild the residual network $N_f$
  + *return* $f$
]

== Example

#place[
  #import fletcher: diagram, node, edge
  #diagram(
    spacing: (1.5cm, 0.4cm),
    edge-stroke: 1pt,
    blob((0, 0), $s$, shape: fletcher.shapes.circle, tint: green, name: <s>),
    blob((3, 0), $t$, shape: fletcher.shapes.circle, tint: red, name: <t>),
    blob((1, -1), $a$, shape: fletcher.shapes.circle, tint: blue, name: <n1>),
    blob((1, 1), $b$, shape: fletcher.shapes.circle, tint: blue, name: <n2>),
    blob((2, -1), $c$, shape: fletcher.shapes.circle, tint: blue, name: <n3>),
    blob((2, 1), $d$, shape: fletcher.shapes.circle, tint: blue, name: <n4>),
    edge(<s>, <n1>, "-}>", label-side: center, label-angle: auto, bend: 15deg)[$4$],
    edge(<s>, <n2>, "-}>", label-side: center, label-angle: auto, bend: -15deg, stroke: green)[$2 slash 2$],
    edge(<n1>, <n3>, "-}>", label-side: center, label-angle: auto)[$3$],
    edge(<n2>, <n4>, "-}>", label-side: center, label-angle: auto)[$3$],
    edge(<n2>, <n3>, "-}>", label-side: center, label-angle: auto, bend: -15deg, stroke: green)[$2 slash 2$],
    edge(<n3>, <n2>, "-}>", label-side: center, label-angle: auto, bend: -15deg)[$1$],
    edge(<n3>, <t>, "-}>", label-side: center, label-angle: auto, bend: 15deg, stroke: green)[$2 slash 2$],
    edge(<n4>, <t>, "-}>", label-side: center, label-angle: auto, bend: -15deg)[$4$],
  )
  #h(1cm)
  #diagram(
    spacing: (1.5cm, 0.4cm),
    edge-stroke: 1pt,
    blob((0, 0), $s$, shape: fletcher.shapes.circle, tint: green, name: <s>),
    blob((3, 0), $t$, shape: fletcher.shapes.circle, tint: red, name: <t>),
    blob((1, -1), $a$, shape: fletcher.shapes.circle, tint: blue, name: <n1>),
    blob((1, 1), $b$, shape: fletcher.shapes.circle, tint: blue, name: <n2>),
    blob((2, -1), $c$, shape: fletcher.shapes.circle, tint: blue, name: <n3>),
    blob((2, 1), $d$, shape: fletcher.shapes.circle, tint: blue, name: <n4>),
    edge(<s>, <n1>, "-}>", label-side: center, label-angle: auto, bend: 15deg, stroke: green)[$3 slash 4$],
    edge(<s>, <n2>, "-}>", label-side: center, label-angle: auto, bend: -15deg, stroke: green)[$2 slash 2$],
    edge(<n1>, <n3>, "-}>", label-side: center, label-angle: auto, stroke: green)[$3 slash 3$],
    edge(<n2>, <n4>, "-}>", label-side: center, label-angle: auto, stroke: green)[$3 slash 3$],
    edge(<n2>, <n3>, "-}>", label-side: center, label-angle: auto, bend: -15deg)[$2$],
    edge(<n3>, <n2>, "-}>", label-side: center, label-angle: auto, bend: -15deg, stroke: green)[$1 slash 1$],
    edge(<n3>, <t>, "-}>", label-side: center, label-angle: auto, bend: 15deg, stroke: green)[$2 slash 2$],
    edge(<n4>, <t>, "-}>", label-side: center, label-angle: auto, bend: -15deg, stroke: green)[$3 slash 4$],
  )

  Networks (above) and residual networks (below) after pushing the flow with $abs(f) = 2$ along the path $s-b-c-t$ (left), and then after pushing the flow with $abs(f) = 3$ along the path $s-a-c-b-d-t$ (right).

  #diagram(
    spacing: (1.5cm, 0.4cm),
    edge-stroke: 1pt,
    blob((0, 0), $s$, shape: fletcher.shapes.circle, tint: green, name: <s>),
    blob((3, 0), $t$, shape: fletcher.shapes.circle, tint: red, name: <t>),
    blob((1, -1), $a$, shape: fletcher.shapes.circle, tint: blue, name: <n1>),
    blob((1, 1), $b$, shape: fletcher.shapes.circle, tint: blue, name: <n2>),
    blob((2, -1), $c$, shape: fletcher.shapes.circle, tint: blue, name: <n3>),
    blob((2, 1), $d$, shape: fletcher.shapes.circle, tint: blue, name: <n4>),
    edge(<s>, <n1>, "-}>", label-side: center, label-angle: auto, bend: 15deg, stroke: green)[$4$],
    edge(<s>, <n2>, "<{-", label-side: center, label-angle: auto, bend: -15deg)[$2$],
    edge(<n1>, <n3>, "-}>", label-side: center, label-angle: auto, stroke: green)[$3$],
    edge(<n2>, <n4>, "-}>", label-side: center, label-angle: auto, stroke: green)[$3$],
    edge(<n2>, <n3>, "<{-", label-side: center, label-angle: auto, stroke: green)[$3$],
    edge(<n3>, <t>, "<{-", label-side: center, label-angle: auto, bend: 15deg)[$2$],
    edge(<n4>, <t>, "-}>", label-side: center, label-angle: auto, bend: -15deg, stroke: green)[$4$],
  )
  #h(1cm)
  #diagram(
    spacing: (1.5cm, 0.4cm),
    edge-stroke: 1pt,
    blob((0, 0), $s$, shape: fletcher.shapes.circle, tint: green, name: <s>),
    blob((3, 0), $t$, shape: fletcher.shapes.circle, tint: red, name: <t>),
    blob((1, -1), $a$, shape: fletcher.shapes.circle, tint: blue, name: <n1>),
    blob((1, 1), $b$, shape: fletcher.shapes.circle, tint: blue, name: <n2>),
    blob((2, -1), $c$, shape: fletcher.shapes.circle, tint: blue, name: <n3>),
    blob((2, 1), $d$, shape: fletcher.shapes.circle, tint: blue, name: <n4>),
    edge(<s>, <n1>, "-}>", label-side: center, label-angle: auto, bend: 15deg)[$1$],
    edge(<s>, <n1>, "<{-", label-side: center, label-angle: auto, bend: -15deg)[$3$],
    edge(<s>, <n2>, "<{-", label-side: center, label-angle: auto, bend: -15deg)[$2$],
    edge(<n1>, <n3>, "<{-", label-side: center, label-angle: auto)[$3$],
    edge(<n2>, <n4>, "<{-", label-side: center, label-angle: auto)[$3$],
    edge(<n2>, <n3>, "-}>", label-side: center, label-angle: auto)[$3$],
    edge(<n3>, <t>, "<{-", label-side: center, label-angle: auto, bend: 15deg)[$2$],
    edge(<n4>, <t>, "<{-", label-side: center, label-angle: auto, bend: 15deg)[$3$],
    edge(<n4>, <t>, "-}>", label-side: center, label-angle: auto, bend: -15deg)[$1$],
  )
]

== Cuts

#definition[
  An _$s$-$t$ cut_ is a set of edges whose removal disconnects $t$ from $s$.

  Formally, a _cut_ is a partition of the vertices $V = A union B$ such that $s in A$ and $t in B$.
  The edges of the cut are the edges that go from $A$ to $B$.
]

#definition[
  The _capacity_ of a cut $(A, B)$ is the sum of the capacities of the edges leaving $A$.
  $ c(A, B) = sum_(a in A, b in B) c(a, b) $
]

#definition[
  Given a flow $f$ in $N$, the _net flow_ across a cut $(A, B)$ is defined as
  $ f(A, B) = sum_(e in Out(A)) f(e) - sum_(e in In(A)) f(e) $
]

== Cut Theorem 1

#theorem[
  Let $f$ be a flow and $(A, B)$ be an $s$-$t$ cut.
  Then:
  $ f(A, B) = abs(f) $
]

== Cut Theorem 2

#theorem[
  Let $f$ be a flow and $(A, B)$ be an $s$-$t$ cut.
  Then:
  $ f(A, B) lt.eq c(A, B) $
] <thm:cut-theorem-2>

#proof[
  $
    f(A,B) &= f^"out" (A) - f^"in" (A) \
    &lt.eq f^"out" (A) \
    &= sum_(e in Out(A)) f(e) \
    &lt.eq sum_(e in Out(A)) c(e) \
    &= c(A, B)
  $
]

== Max-Flow Min-Cut Theorem

#theorem[
  Given a flow network $N$ and a flow $f$, the following are equivalent:
  + $f$ is a _maximum flow_ in $N$.
  + There is _no augmenting path_ in the residual network $N_f$.
  + $abs(f) = c(A, B)$ for some $s$-$t$ cut $(A, B)$ in $N$.

  If one (and hence all) of these conditions hold, then $(A, B)$ is a _minimum cut_.
]

#proof[(1 $imply$ 2)][
  An augmenting path in the residual network $N_f$ would allow us to increase the flow $f$.
]

#proof[(3 $imply$ 1)][
  No flow can exceed the capacity of a cut (by @thm:cut-theorem-2)
]

#proof[(2 $imply$ 3)][
  Let $S$ be the set of vertices reachable from $s$ in the residual network $N_f$.
  Since there is no augmenting path in $N_f$, $S$ does not contain $t$.
  Then $(S, T)$ is a cut of $N$, where $T = V setminus S$.
  Moreover, for any $u in S$ and $v in T$, the residual capacity $c_f (e)$ must be zero (otherwise, the path $s arrow.squiggly u$ in $N_f$ could be extended to a path $s arrow.squiggly u arrow v$ in $N_f$).
  Thus, $f(S, T) = f^"out" (S) - f^"in" (S) = f^"out" (S) - 0 = c(S, T)$.
]

#[
  #import fletcher: diagram, node, edge
  #diagram(
    spacing: (1.5cm, 0.4cm),
    edge-stroke: 1pt,
    blob((0cm, 0cm), $s$, shape: fletcher.shapes.circle, tint: green, name: <s>),
    blob((1cm, 1.3cm), $1$, inset: 4pt, shape: fletcher.shapes.circle, tint: green, name: <n1>),
    blob((1.3cm, -0.6cm), $2$, inset: 4pt, shape: fletcher.shapes.circle, tint: green, name: <n2>),
    blob((2.5cm, -1.5cm), $3$, inset: 4pt, shape: fletcher.shapes.circle, tint: green, name: <n3>),
    blob((2.7cm, 2cm), $4$, inset: 4pt, shape: fletcher.shapes.circle, tint: green, name: <n4>),
    blob((2.2cm, 0.4cm), $5$, inset: 4pt, shape: fletcher.shapes.circle, tint: green, name: <n5>),
    edge(<s>, <n1>, "-}>"),
    edge(<s>, <n2>, "-}>"),
    edge(<n1>, <n4>, "-}>"),
    edge(<n1>, <n5>, "-}>"),
    edge(<n2>, <n5>, "-}>"),
    edge(<n2>, <n3>, "-}>"),
    blob((4cm, -0.5cm), $6$, inset: 4pt, shape: fletcher.shapes.circle, tint: red, name: <n6>),
    blob((4.5cm, 1.5cm), $7$, inset: 4pt, shape: fletcher.shapes.circle, tint: red, name: <n7>),
    blob((5.5cm, 0.5cm), $8$, inset: 4pt, shape: fletcher.shapes.circle, tint: red, name: <n8>),
    blob((5.5cm, -1.5cm), $9$, inset: 4pt, shape: fletcher.shapes.circle, tint: red, name: <n9>),
    blob((7cm, -0.5cm), $t$, shape: fletcher.shapes.circle, tint: red, name: <t>),
    edge(<n6>, <n8>, "-}>"),
    edge(<n7>, <n8>, "-}>"),
    edge(<n6>, <n9>, "-}>"),
    edge(<n8>, <n9>, "-}>"),
    edge(<n8>, <t>, "-}>"),
    edge(<n9>, <t>, "-}>"),
    edge(<n4>, <n7>, "--}>", stroke: blue),
    edge(<n5>, <n6>, "--}>", stroke: blue),
    edge(<n3>, <n6>, "--}>", stroke: blue),
    edge(<n5>, <n7>, "<{--", stroke: red),
    edge(<n2>, <n6>, "<{--", stroke: red),
  )
]

- Cut $(#text(green.darken(20%))[$S$], #text(red.darken(20%))[$T$])$ with $s in S$, $t in T$.
- #text(blue)[Blue] edges must be saturated.
- #text(red)[Red] edges must be empty (zero).

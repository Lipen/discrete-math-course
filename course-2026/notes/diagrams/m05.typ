// M05 Hasse diagrams — poset visualization via fletcher.
#import "@preview/fletcher:0.5.8": diagram, edge, node

#let n-size = 1.6em
#let n-fill = oklch(88%, 0.03, 250deg)
#let n-str = 0.6pt + oklch(60%, 0.08, 250deg)
#let e-str = 0.6pt + oklch(35%, 0.02, 265deg)

#let cn(pos, body, ..args) = node(
  pos,
  body,
  fill: n-fill,
  width: n-size,
  height: n-size,
  ..args,
)
#let e(from, to) = edge(from, to, "-", stroke: e-str)

// ── 1. Divisor poset on {1,2,3,4,6,12} ordered by | ──
#let hasse-divisors-12 = diagram(
  node-shape: "circle",
  node-stroke: n-str,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 2em,
  cn((0, 0), $1$, name: <d1>),
  cn((-1, 1), $2$, name: <d2>),
  cn((1, 1), $3$, name: <d3>),
  cn((-1, 2), $4$, name: <d4>),
  cn((1, 2), $6$, name: <d6>),
  cn((0, 3), $12$, name: <d12>),
  e(<d1>, <d2>),
  e(<d1>, <d3>),
  e(<d2>, <d4>),
  e(<d2>, <d6>),
  e(<d3>, <d6>),
  e(<d4>, <d12>),
  e(<d6>, <d12>),
)

// ── 2. Simple total order {1,2,3} : just a chain ──
#let hasse-chain-3 = diagram(
  node-shape: "circle",
  node-stroke: n-str,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 1.8em,
  cn((0, 0), $1$, name: <c1>),
  cn((0, 1), $2$, name: <c2>),
  cn((0, 2), $3$, name: <c3>),
  e(<c1>, <c2>),
  e(<c2>, <c3>),
)

// ── 3. Powerset of {1,2} ordered by ⊆ (Boolean lattice B_2) ──
#let hasse-powerset-2 = diagram(
  node-shape: "circle",
  node-stroke: n-str,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 2em,
  cn((0, 0), $nothing$, name: <p0>),
  cn((-1, 1), ${1}$, name: <p1>),
  cn((1, 1), ${2}$, name: <p2>),
  cn((0, 2), ${1,2}$, name: <p12>),
  e(<p0>, <p1>),
  e(<p0>, <p2>),
  e(<p1>, <p12>),
  e(<p2>, <p12>),
)

// ── 4. Powerset of {1,2,3} ordered by ⊆ (Boolean lattice B_3, a cube) ──
#let hasse-powerset-3 = diagram(
  node-shape: "circle",
  node-stroke: n-str,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 1.8em,
  // Layer 0: empty set
  cn((0, 0), $nothing$, name: <p0>),
  // Layer 1: singletons — {2} in the middle (front of the cube)
  cn((-1.3, 1), ${1}$, name: <p1>),
  cn((0, 1), ${2}$, name: <p2>),
  cn((1.3, 1), ${3}$, name: <p3>),
  // Layer 2: pairs — {1,3} in the middle (back of the cube)
  cn((-0.7, 2), ${1,2}$, name: <p12>),
  cn((0, 2), ${1,3}$, name: <p13>),
  cn((0.7, 2), ${2,3}$, name: <p23>),
  // Layer 3: full set
  cn((0, 3), ${1,2,3}$, name: <p123>),
  // Edges (cover = add exactly one element)
  e(<p0>, <p1>),
  e(<p0>, <p2>),
  e(<p0>, <p3>),
  e(<p1>, <p12>),
  e(<p1>, <p13>),
  e(<p2>, <p12>),
  e(<p2>, <p23>),
  e(<p3>, <p13>),
  e(<p3>, <p23>),
  e(<p12>, <p123>),
  e(<p13>, <p123>),
  e(<p23>, <p123>),
)

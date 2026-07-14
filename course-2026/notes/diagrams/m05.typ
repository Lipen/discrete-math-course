// M05 Hasse diagrams — fletcher for poset visualization.
#import "@preview/fletcher:0.5.8": diagram, edge, node

#let c-node = oklch(88%, 0.03, 250deg)
#let c-node-str = oklch(60%, 0.08, 250deg)
#let c-edge = oklch(35%, 0.02, 265deg)

// ── 1. Divisor poset on {1,2,3,4,6,12} ordered by | ──
#let hasse-divisors-12 = diagram(
  node-stroke: (paint: c-node-str, thickness: 0.8pt),
  node-fill: c-node,
  edge-stroke: (paint: c-edge, thickness: 0.8pt),
  spacing: 2.2em,
  // Layer 0
  node((0, 0), $1$, name: <d1>),
  // Layer 1
  node((-1, 1), $2$, name: <d2>),
  node((1, 1), $3$, name: <d3>),
  // Layer 2
  node((-1, 2), $4$, name: <d4>),
  node((1, 2), $6$, name: <d6>),
  // Layer 3
  node((0, 3), $12$, name: <d12>),
  // Edges (Hasse = cover relations only, no transitive)
  edge(<d1>, <d2>, "-"),
  edge(<d1>, <d3>, "-"),
  edge(<d2>, <d4>, "-"),
  edge(<d2>, <d6>, "-"),
  edge(<d3>, <d6>, "-"),
  edge(<d4>, <d12>, "-"),
  edge(<d6>, <d12>, "-"),
)

// ── 2. Simple total order {1,2,3} — just a chain ──
#let hasse-chain-3 = diagram(
  node-stroke: (paint: c-node-str, thickness: 0.8pt),
  node-fill: c-node,
  edge-stroke: (paint: c-edge, thickness: 0.8pt),
  spacing: 1.8em,
  node((0, 0), $1$, name: <c1>),
  edge(<c1>, <c2>, "-"),
  node((0, 1), $2$, name: <c2>),
  edge(<c2>, <c3>, "-"),
  node((0, 2), $3$, name: <c3>),
)

// ── 3. Powerset of {1,2} ordered by ⊆ (Boolean lattice B_2) ──
#let hasse-powerset-2 = diagram(
  node-stroke: (paint: c-node-str, thickness: 0.8pt),
  node-fill: c-node,
  edge-stroke: (paint: c-edge, thickness: 0.8pt),
  spacing: 2em,
  node((0, 0), $emptyset$, name: <p0>),
  node((-1, 1), ${1}$, name: <p1>),
  node((1, 1), ${2}$, name: <p2>),
  node((0, 2), ${1,2}$, name: <p12>),
  edge(<p0>, <p1>, "-"),
  edge(<p0>, <p2>, "-"),
  edge(<p1>, <p12>, "-"),
  edge(<p2>, <p12>, "-"),
)

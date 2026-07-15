// M03 diagrams — relation digraphs via fletcher.
#import "@preview/fletcher:0.5.8": diagram, edge, node

#let n-fill = oklch(88%, 0.03, 250deg)
#let n-str = 0.6pt + oklch(60%, 0.08, 250deg)
#let e-str = 0.6pt + oklch(35%, 0.02, 265deg)

#let cn(pos, body, ..args) = node(pos, body, fill: n-fill, width: 1.2em, height: 1.2em, ..args)
#let e(from, to) = edge(from, to, "->", stroke: e-str)

// ── Digraph of R = {(1,1),(1,2),(2,3),(3,1)} on A = {1,2,3} ──
#let rel-digraph = diagram(
  node-shape: "circle",
  node-stroke: n-str,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 2.5em,
  cn((0, 1.2), $1$, name: <1>),
  cn((-1.3, -0.6), $2$, name: <2>),
  cn((1.3, -0.6), $3$, name: <3>),
  e(<1>, <1>),
  e(<1>, <2>),
  e(<2>, <3>),
  e(<3>, <1>),
)

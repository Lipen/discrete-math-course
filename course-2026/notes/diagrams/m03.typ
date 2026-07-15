// M03 diagrams — relation digraphs via fletcher.
#import "@preview/fletcher:0.5.8": diagram, edge, node

#let n-fill = oklch(88%, 0.03, 250deg)
#let n-str = 0.6pt + oklch(60%, 0.08, 250deg)
#let e-str = 0.6pt + oklch(35%, 0.02, 265deg)
#let e-fg = oklch(35%, 0.02, 265deg)

#let cn(pos, body, ..args) = node(pos, body, fill: n-fill, width: 1.2em, height: 1.2em, ..args)
#let ea(from, to, ..args) = edge(from, to, "->", stroke: e-str, ..args)
#let el(from, to, angle: 30deg, ..args) = edge(from, to, "->", stroke: e-str, loop-angle: angle, ..args)

// ── Digraph of R on A = {1,2,3,4,5} ──
#let rel-digraph = diagram(
  node-shape: "circle",
  node-stroke: n-str,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 2.2em,
  cn((-0.5, 2.2), $1$, name: <1>),
  cn((1.8, 1.2), $2$, name: <2>),
  cn((1.8, -1.2), $3$, name: <3>),
  cn((-1.8, -1.2), $4$, name: <4>),
  cn((-1.8, 1.2), $5$, name: <5>),
  el(<1>, <1>, angle: 120deg),
  ea(<1>, <2>),
  ea(<1>, <5>),
  ea(<2>, <3>),
  ea(<2>, <4>),
  ea(<3>, <1>),
  ea(<4>, <2>),
  ea(<5>, <3>),
  el(<5>, <5>, angle: 240deg),
)

// m08 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import fletcher: diagram, edge, node
#import circuiteria: circuit, element, wire

#let n-size = 1.2em

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

#let hasse-divisors-12 = diagram(
  node-shape: "circle",
  node-stroke: n-str,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 2em,
  cn((0, 3), $1$, name: <d1>),
  cn((-1, 2), $2$, name: <d2>),
  cn((1, 2), $3$, name: <d3>),
  cn((-1, 1), $4$, name: <d4>),
  cn((1, 1), $6$, name: <d6>),
  cn((0, 0), $12$, name: <d12>),
  e(<d1>, <d2>),
  e(<d1>, <d3>),
  e(<d2>, <d4>),
  e(<d2>, <d6>),
  e(<d3>, <d6>),
  e(<d4>, <d12>),
  e(<d6>, <d12>),
)

#let hasse-chain-3 = diagram(
  node-shape: "circle",
  node-stroke: n-str,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 1.4em,
  cn((0, 2), $1$, name: <c1>),
  cn((0, 1), $2$, name: <c2>),
  cn((0, 0), $3$, name: <c3>),
  e(<c1>, <c2>),
  e(<c2>, <c3>),
)

#let hasse-powerset-2 = diagram(
  node-shape: "circle",
  node-stroke: n-str,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 2em,
  cn((0, 2), $nothing$, name: <p0>),
  cn((-1, 1), ${1}$, name: <p1>),
  cn((1, 1), ${2}$, name: <p2>),
  cn((0, 0), ${1,2}$, name: <p12>),
  e(<p0>, <p1>),
  e(<p0>, <p2>),
  e(<p1>, <p12>),
  e(<p2>, <p12>),
)

#let hasse-powerset-3 = diagram(
  node-shape: "circle",
  node-stroke: n-str,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 1.8em,
  // Layer 3: full set (top)
  cn((0, 0), ${1,2,3}$, name: <p123>),
  // Layer 2: pairs
  cn((-1.2, 1), ${1,2}$, name: <p12>),
  cn((0, 1), ${1,3}$, name: <p13>),
  cn((1.2, 1), ${2,3}$, name: <p23>),
  // Layer 1: singletons
  cn((-1.2, 2), ${1}$, name: <p1>),
  cn((0, 2), ${2}$, name: <p2>),
  cn((1.2, 2), ${3}$, name: <p3>),
  // Layer 0: empty set (bottom)
  cn((0, 3), $nothing$, name: <p0>),
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

#let lattice-m3 = diagram(
  node-shape: "circle",
  node-stroke: n-str,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 1.6em,
  cn((0, 2), $bot$, name: <m3-bot>),
  cn((-1, 1), $a$, name: <m3-a>),
  cn((0, 1), $b$, name: <m3-b>),
  cn((1, 1), $c$, name: <m3-c>),
  cn((0, 0), $top$, name: <m3-top>),
  e(<m3-bot>, <m3-a>),
  e(<m3-bot>, <m3-b>),
  e(<m3-bot>, <m3-c>),
  e(<m3-a>, <m3-top>),
  e(<m3-b>, <m3-top>),
  e(<m3-c>, <m3-top>),
)

#let lattice-n5 = diagram(
  node-shape: "circle",
  node-stroke: n-str,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 1.6em,
  cn((0, 3), $0$, name: <n5-zero>),
  cn((-1, 2), $a$, name: <n5-a>),
  cn((-1, 1), $b$, name: <n5-b>),
  cn((1, 1), $c$, name: <n5-c>),
  cn((0, 0), $1$, name: <n5-one>),
  e(<n5-zero>, <n5-a>),
  e(<n5-zero>, <n5-c>),
  e(<n5-a>, <n5-b>),
  e(<n5-b>, <n5-one>),
  e(<n5-c>, <n5-one>),
)

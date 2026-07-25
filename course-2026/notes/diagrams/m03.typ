// M03 diagrams --- relation digraphs via fletcher.
#import "../requirements.typ": *

#import fletcher: diagram, edge, node
#import cetz: canvas, draw

#let n-fill = oklch(88%, 0.03, 250deg)
#let n-str = 0.6pt + oklch(60%, 0.08, 250deg)
#let e-str = 0.6pt + oklch(35%, 0.02, 265deg)

#let cn(pos, body, ..args) = node(
  pos,
  body,
  fill: n-fill,
  width: 1.2em,
  height: 1.2em,
  ..args,
)
#let ea(from, to, ..args) = edge(from, to, "-}>", stroke: e-str, ..args)
#let el(from, to, angle: 30deg, ..args) = edge(
  from,
  to,
  "-}>",
  stroke: e-str,
  loop-angle: angle,
  ..args,
)

// ── Digraph of R on A = {1,2,3,4,5} ──
#let rel-digraph = diagram(
  node-shape: "circle",
  node-stroke: n-str,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 1.6em,
  cn((-0.4, 1.6), $1$, name: <1>),
  cn((1.3, 0.8), $2$, name: <2>),
  cn((1.3, -0.8), $3$, name: <3>),
  cn((-1.3, -0.8), $4$, name: <4>),
  cn((-1.3, 0.8), $5$, name: <5>),
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

// ── Hasse diagram of divisibility on {1,2,3,4,6,12} ──
#let hasse-divisibility = canvas({
  import cetz: draw
  let fill = oklch(88%, 0.03, 250deg)
  let stroke = 0.6pt + oklch(50%, 0.08, 250deg)
  let edge-str = 0.6pt + oklch(35%, 0.02, 265deg)

  // Positions: 1 at bottom, 12 at top
  let p(n) = {
    if n == 12 { return (0, 3.0) }
    if n == 4  { return (-1.5, 2.0) }
    if n == 6  { return (1.5, 2.0) }
    if n == 2  { return (-1.0, 1.0) }
    if n == 3  { return (1.0, 1.0) }
    if n == 1  { return (0, 0.0) }
  }

  // Nodes
  for (n, pos) in (("12", (0, 3.0)), ("4", (-1.5, 2.0)), ("6", (1.5, 2.0)), ("2", (-1.0, 1.0)), ("3", (1.0, 1.0)), ("1", (0, 0.0))) {
    draw.circle(pos, radius: 0.35, fill: fill, stroke: stroke)
    draw.content(pos, text(size: 0.7em)[#n])
  }

  // Edges --- only cover relations (no transitive shortcuts)
  // 1 -> 2, 1 -> 3
  draw.line((0, 0.35), (-1.0, 0.65), stroke: edge-str)
  draw.line((0, 0.35), (1.0, 0.65), stroke: edge-str)
  // 2 -> 4, 2 -> 6
  draw.line((-1.0, 1.35), (-1.5, 1.65), stroke: edge-str)
  draw.line((-1.0, 1.35), (1.5, 1.65), stroke: edge-str)
  // 3 -> 6
  draw.line((1.0, 1.35), (1.5, 1.65), stroke: edge-str)
  // 4 -> 12
  draw.line((-1.5, 2.35), (0, 2.65), stroke: edge-str)
  // 6 -> 12
  draw.line((1.5, 2.35), (0, 2.65), stroke: edge-str)
})

// ── Equivalence partition: numbers 1..10 modulo 3 ──
#let c-eq-a = oklch(88%, 0.06, 250deg)
#let c-eq-b = oklch(88%, 0.06, 155deg)
#let c-eq-c = oklch(88%, 0.10, 45deg)
#let c-eq-str = oklch(50%, 0.08, 250deg) + 0.6pt
#let c-eq-label = oklch(35%, 0.02, 265deg)

#let equivalence-partition = canvas({
  // Class [0]: {3, 6, 9}
  draw.rect(
    (-3.8, 1.2),
    (3.8, 2.8),
    radius: 12pt,
    fill: c-eq-a,
    stroke: c-eq-str,
  )
  draw.content((-2.5, 2.0), text(size: 0.7em, fill: c-eq-label)[3])
  draw.content((-0.8, 2.0), text(size: 0.7em, fill: c-eq-label)[6])
  draw.content((0.9, 2.0), text(size: 0.7em, fill: c-eq-label)[9])
  draw.content((3.2, 2.0), anchor: "west", text(
    size: 0.55em,
    fill: luma(50%),
  )[$"mod" 3 = 0$])

  // Class [1]: {1, 4, 7, 10}
  draw.rect(
    (-3.8, -0.3),
    (3.8, 1.3),
    radius: 12pt,
    fill: c-eq-b,
    stroke: c-eq-str,
  )
  draw.content((-2.5, 0.5), text(size: 0.7em, fill: c-eq-label)[1])
  draw.content((-0.8, 0.5), text(size: 0.7em, fill: c-eq-label)[4])
  draw.content((0.9, 0.5), text(size: 0.7em, fill: c-eq-label)[7])
  draw.content((2.6, 0.5), text(size: 0.7em, fill: c-eq-label)[10])
  draw.content((3.2, 0.5), anchor: "west", text(
    size: 0.55em,
    fill: luma(50%),
  )[$"mod" 3 = 1$])

  // Class [2]: {2, 5, 8}
  draw.rect(
    (-3.8, -1.8),
    (3.8, -0.2),
    radius: 12pt,
    fill: c-eq-c,
    stroke: c-eq-str,
  )
  draw.content((-1.5, -1.0), text(size: 0.7em, fill: c-eq-label)[2])
  draw.content((0.2, -1.0), text(size: 0.7em, fill: c-eq-label)[5])
  draw.content((1.9, -1.0), text(size: 0.7em, fill: c-eq-label)[8])
  draw.content((3.2, -1.0), anchor: "west", text(
    size: 0.55em,
    fill: luma(50%),
  )[$"mod" 3 = 2$])
})

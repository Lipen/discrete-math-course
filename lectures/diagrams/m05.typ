// Relation digraphs via fletcher.
// Скопировано из книги, чтобы лекции не зависели от неё.
#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/fletcher:0.5.8": diagram, edge, node

#let n-fill = oklch(88%, 0.03, 250deg)
#let n-str = 0.8pt + oklch(60%, 0.08, 250deg)
#let e-str = 0.8pt + oklch(35%, 0.02, 265deg)

#let cn(pos, body, ..args) = node(
  pos,
  text(size: 1.4em)[#body],
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
  bend: 125deg,
  loop-angle: angle,
)

// ── Digraph of R on A = {1,2,3,4,5} ──
#let rel-digraph = diagram(
  node-shape: "circle",
  node-stroke: n-str,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 2.6em,
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
  let fill = oklch(88%, 0.03, 250deg)
  let stroke = 0.6pt + oklch(50%, 0.08, 250deg)
  let edge-str = 0.6pt + oklch(35%, 0.02, 265deg)

  // Node helper: named circle with a label
  let v(name, pos) = {
    draw.circle(pos, radius: 0.18, fill: fill, stroke: stroke, name: name)
    draw.content(pos, text(size: 0.45em)[#name])
  }

  // Edge helper: straight line between two named nodes
  let e(a, b) = draw.line(a, b, stroke: edge-str)

  // Nodes, named
  v("12", (0, 1.5))
  v("4", (-0.75, 1.0))
  v("6", (0.75, 1.0))
  v("2", (-0.5, 0.5))
  v("3", (0.5, 0.5))
  v("1", (0, 0.0))

  // Edges --- only cover relations (no transitive shortcuts), node-based
  e("1", "2")
  e("1", "3")
  e("2", "4")
  e("2", "6")
  e("3", "6")
  e("4", "12")
  e("6", "12")
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
    (-1.9, 0.6),
    (1.9, 1.4),
    radius: 6pt,
    fill: c-eq-a,
    stroke: c-eq-str,
  )
  draw.content((-1.25, 1.0), text(size: 0.45em, fill: c-eq-label)[3])
  draw.content((-0.4, 1.0), text(size: 0.45em, fill: c-eq-label)[6])
  draw.content((0.45, 1.0), text(size: 0.45em, fill: c-eq-label)[9])
  draw.content((1.6, 1.0), anchor: "west", text(
    size: 0.4em,
    fill: luma(50%),
  )[$"mod" 3 = 0$])

  // Class [1]: {1, 4, 7, 10}
  draw.rect(
    (-1.9, -0.15),
    (1.9, 0.65),
    radius: 6pt,
    fill: c-eq-b,
    stroke: c-eq-str,
  )
  draw.content((-1.25, 0.25), text(size: 0.45em, fill: c-eq-label)[1])
  draw.content((-0.4, 0.25), text(size: 0.45em, fill: c-eq-label)[4])
  draw.content((0.45, 0.25), text(size: 0.45em, fill: c-eq-label)[7])
  draw.content((1.3, 0.25), text(size: 0.45em, fill: c-eq-label)[10])
  draw.content((1.6, 0.25), anchor: "west", text(
    size: 0.4em,
    fill: luma(50%),
  )[$"mod" 3 = 1$])

  // Class [2]: {2, 5, 8}
  draw.rect(
    (-1.9, -0.9),
    (1.9, -0.1),
    radius: 6pt,
    fill: c-eq-c,
    stroke: c-eq-str,
  )
  draw.content((-0.75, -0.5), text(size: 0.45em, fill: c-eq-label)[2])
  draw.content((0.1, -0.5), text(size: 0.45em, fill: c-eq-label)[5])
  draw.content((0.95, -0.5), text(size: 0.45em, fill: c-eq-label)[8])
  draw.content((1.6, -0.5), anchor: "west", text(
    size: 0.4em,
    fill: luma(50%),
  )[$"mod" 3 = 2$])
})

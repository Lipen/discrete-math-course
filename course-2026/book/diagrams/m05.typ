// m05 diagrams: граф отношения, диаграмма Хассе (делимость), разбиение на классы эквивалентности.
#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

#let e-stroke = (paint: c-edge, thickness: t-ed)

#let cn(pos, body, ..args) = node(
  pos,
  body,
  fill: c-fl,
  width: 1.2em,
  height: 1.2em,
  ..args,
)

#let ea(from, to, ..args) = edge(from, to, "-}>", stroke: e-stroke, ..args)

#let el(from, to, angle: 30deg, ..args) = edge(
  from,
  to,
  "-}>",
  stroke: e-stroke,
  loop-angle: angle,
  ..args,
)

#let rel-digraph = diagram(
  node-shape: "circle",
  node-stroke: t-bd + c-bd,
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

// ── Диаграмма Хассе: делимость на {1,2,3,4,6,12} ──
#let hasse-divisibility = canvas({
  let v(name, pos) = {
    draw.circle(pos, radius: 0.35, fill: c-fl, stroke: t-bd + c-bd, name: name)
    draw.content(pos, text(size: s-node, fill: c-ink)[#name])
  }

  let e(a, b) = draw.line(a, b, stroke: e-stroke)

  v("12", (0, 3.0))
  v("4", (-1.5, 2.0))
  v("6", (1.5, 2.0))
  v("2", (-1.0, 1.0))
  v("3", (1.0, 1.0))
  v("1", (0, 0.0))

  // Только покрывающие отношения, без транзитивных сокращений.
  e("1", "2")
  e("1", "3")
  e("2", "4")
  e("2", "6")
  e("3", "6")
  e("4", "12")
  e("6", "12")
})

// ── Разбиение целых по остатку mod 3 ──
#let eq-class(y, fill, residue, items) = {
  draw.rect(
    (-3.8, y + 0.8),
    (3.8, y - 0.8),
    radius: 12pt,
    fill: fill,
    stroke: t-bd + c-bd,
  )
  for (x, n) in items {
    draw.content((x, y), text(size: s-cap, fill: c-ink)[#n])
  }
  draw.content(
    (2.35, y),
    anchor: "west",
    text(size: s-cap, fill: c-muted)[$"mod" 3 = #residue$],
  )
}

#let equivalence-partition = canvas({
  // [0] = {3, 6, 9}
  eq-class(2.5, c-fl, 0, ((-2.5, 3), (-0.8, 6), (0.9, 9)))
  // [1] = {1, 4, 7, 10}
  eq-class(0.8, c-atom, 1, ((-2.5, 1), (-0.8, 4), (0.9, 7), (1.9, 10)))
  // [2] = {2, 5, 8}
  eq-class(-0.9, c-warn, 2, ((-1.5, 2), (0.2, 5), (1.9, 8)))
})

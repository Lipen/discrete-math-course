// M13 diagrams --- matroids.
// Скопировано из notes/diagrams/m28.typ, чтобы лекции не зависели от книги.
#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/fletcher:0.5.8": diagram, edge, node

#let c-src-fill = oklch(94%, 0.03, 250deg)
#let c-src-str = 0.7pt + oklch(55%, 0.10, 250deg)
#let c-mat-fill = oklch(87%, 0.08, 250deg)
#let c-mat-str = 0.9pt + oklch(45%, 0.12, 250deg)
#let c-conflict = oklch(55%, 0.16, 22deg)
#let c-label = oklch(30%, 0.02, 265deg)
#let e-str = 0.7pt + oklch(35%, 0.02, 265deg)

// ── 1. Три источника → один матроид ──
#let matroid-sources = {
  let src(pos, body, name) = node(pos, body, name: name, fill: c-src-fill)
  diagram(
    node-stroke: c-src-str,
    node-inset: 5pt,
    spacing: 1.8em,
    src((0, 0), [Лес \ ацикличность], <src-forest>),
    src((3, 0), [Векторы \ независимость], <src-linear>),
    src((6, 0), [Не более $k$ \ размер], <src-uniform>),
    node(
      (3, 2.6),
      [Матроид \ два свойства],
      name: <matroid>,
      fill: c-mat-fill,
      stroke: c-mat-str,
    ),
    edge(<src-forest>, <matroid>, "-}>", stroke: e-str),
    edge(<src-linear>, <matroid>, "-}>", stroke: e-str),
    edge(<src-uniform>, <matroid>, "-}>", stroke: e-str),
  )
}

// ── 2. Контрпример: граф конфликтов ──
#let greedy-counterexample = canvas({
  let elem(pos, letter, weight, name) = {
    draw.circle(
      pos,
      radius: 0.5,
      fill: c-src-fill,
      stroke: c-src-str,
      name: name,
    )
    draw.content(pos, text(size: 0.82em, fill: c-label)[#letter \ #weight])
  }
  elem((-1.9, 0), $a$, $5$, "a")
  elem((0.9, 1.2), $b$, $4$, "b")
  elem((0.9, -1.2), $c$, $4$, "c")
  draw.line("a.north-east", "b.south-west", stroke: (
    paint: c-conflict,
    thickness: 0.9pt,
    dash: "dashed",
  ))
  draw.line("a.south-east", "c.north-west", stroke: (
    paint: c-conflict,
    thickness: 0.9pt,
    dash: "dashed",
  ))
  draw.line("a.south", (-1.9, -1.5), stroke: e-str, mark: (end: "stealth"))
  draw.line("c.south", (0.9, -2.3), stroke: e-str, mark: (end: "stealth"))
  draw.content((-1.9, -1.9), text(
    size: 0.85em,
    fill: c-label,
  )[жадный: ${a}$, вес $5$])
  draw.content((0.9, -2.7), text(
    size: 0.85em,
    fill: c-label,
  )[оптимум: ${b,c}$, вес $8$])
})

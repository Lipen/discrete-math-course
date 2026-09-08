// Matroids.
// Скопировано из книги, чтобы лекции не зависели от неё.
#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/fletcher:0.5.8": diagram, edge, node

#let c-src-fill = oklch(94%, 0.03, 250deg)
#let c-src-str = 0.7pt + oklch(55%, 0.10, 250deg)
#let c-mat-fill = oklch(87%, 0.08, 250deg)
#let c-mat-str = 0.9pt + oklch(45%, 0.12, 250deg)
#let c-conflict = oklch(55%, 0.16, 22deg)
#let c-label = oklch(30%, 0.02, 265deg)
#let e-str = 0.7pt + oklch(35%, 0.02, 265deg)

// ── 1. Три источника -> один матроид ──
#let matroid-sources = {
  let src(pos, body, name) = node(
    pos,
    text(size: 0.6em, body),
    name: name,
    fill: c-src-fill,
  )
  diagram(
    node-stroke: c-src-str,
    node-inset: 2pt,
    spacing: 0.9em,
    src((0, 0), [Лес \ ацикличность], <src-forest>),
    src((1.5, 0), [Векторы \ независимость], <src-linear>),
    src((3, 0), [Не более $k$ \ размер], <src-uniform>),
    node(
      (1.5, 1.3),
      text(size: 0.6em)[Матроид \ два свойства],
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
      radius: 0.25,
      fill: c-src-fill,
      stroke: c-src-str,
      name: name,
    )
    draw.content(pos, text(size: 0.45em, fill: c-label)[#letter \ #weight])
  }
  elem((-0.95, 0), $a$, $5$, "a")
  elem((0.45, 0.6), $b$, $4$, "b")
  elem((0.45, -0.6), $c$, $4$, "c")
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
  draw.content(
    (-0.95, -0.95),
    text(
      size: 0.45em,
      fill: c-label,
    )[жадный: ${a}$, вес $5$],
    name: "lbl-greedy",
  )
  draw.content(
    (0.45, -1.35),
    text(
      size: 0.45em,
      fill: c-label,
    )[оптимум: ${b,c}$, вес $8$],
    name: "lbl-opt",
  )
  draw.line("a.south", "lbl-greedy.north", stroke: e-str, mark: (
    end: "stealth",
  ))
  draw.line("c.south", "lbl-opt.north", stroke: e-str, mark: (end: "stealth"))
})

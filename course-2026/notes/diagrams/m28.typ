// M28 diagrams: matroid sources, greedy counterexample, interval scheduling.
#import "../requirements.typ": *
#import "../notation.typ": *

#import fletcher: diagram, edge, node
#import cetz: canvas, draw

// ── Общие константы ──
#let c-src-fill = oklch(94%, 0.03, 250deg)
#let c-src-str = 0.7pt + oklch(55%, 0.10, 250deg)
#let c-mat-fill = oklch(87%, 0.08, 250deg)
#let c-mat-str = 0.9pt + oklch(45%, 0.12, 250deg)
#let c-conflict = oklch(55%, 0.16, 22deg)
#let c-long-fill = oklch(90%, 0.06, 60deg)
#let c-short-fill = oklch(90%, 0.06, 170deg)
#let c-label = oklch(30%, 0.02, 265deg)
#let e-str = 0.7pt + oklch(35%, 0.02, 265deg)

// ── 1. Три источника → один матроид ──
#let matroid-sources = diagram(
  node-stroke: c-src-str,
  node-inset: 5pt,
  spacing: 1.8em,
  node((0, 0), [Лес \ ацикличность], name: <src-forest>, fill: c-src-fill),
  node((3, 0), [Векторы \ независимость], name: <src-linear>, fill: c-src-fill),
  node((6, 0), [Не более $k$ \ размер], name: <src-uniform>, fill: c-src-fill),
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

// ── 2. Контрпример: граф конфликтов ──
#let greedy-counterexample = canvas({
  let elem(pos, letter, weight) = {
    draw.circle(pos, radius: 0.42, fill: c-src-fill, stroke: c-src-str)
    draw.content(pos, text(size: 0.9em, fill: c-label)[#letter])
    draw.content((pos.at(0) + 0.62, pos.at(1) + 0.4), text(
      size: 0.72em,
      fill: c-label,
    )[#weight])
  }
  elem((-1.9, 0), $a$, $5$)
  elem((0.9, 1.2), $b$, $4$)
  elem((0.9, -1.2), $c$, $4$)
  // запрещённые пары: a---b и a---c (пунктир)
  draw.line((-1.9, 0), (0.9, 1.2), stroke: (
    paint: c-conflict,
    thickness: 0.9pt,
    dash: "dashed",
  ))
  draw.line((-1.9, 0), (0.9, -1.2), stroke: (
    paint: c-conflict,
    thickness: 0.9pt,
    dash: "dashed",
  ))
  // результаты
  draw.line((-1.9, -0.7), (-1.9, -1.3), stroke: e-str, mark: (end: "stealth"))
  draw.line((0.9, -1.8), (0.9, -2.3), stroke: e-str, mark: (end: "stealth"))
  draw.content((-1.9, -1.7), text(size: 0.85em)[жадный: ${a}$, вес $5$])
  draw.content((0.9, -2.7), text(size: 0.85em)[оптимум: ${b,c}$, вес $8$])
})

// ── 3. Интервальное расписание ──
#let interval-scheduling = canvas({
  let bar(y, x1, x2, label, fill) = {
    draw.rect(
      (x1, y + 0.25),
      (x2, y - 0.25),
      fill: fill,
      stroke: e-str,
      radius: 2pt,
    )
    draw.content(((x1 + x2) / 2, y + 0.6), text(
      size: 0.8em,
      fill: c-label,
    )[#label])
  }
  draw.line((0, 0), (11, 0), stroke: e-str)
  for i in range(11) {
    draw.line((i, -0.12), (i, 0.12), stroke: e-str)
    draw.content((i, -0.45), text(size: 0.62em, fill: c-label)[#i])
  }
  bar(2.6, 1, 10, $A$, c-long-fill)
  bar(1.3, 1, 2, $B$, c-short-fill)
  bar(1.3, 3, 4, $C$, c-short-fill)
})

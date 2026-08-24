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

// ── 1. Три источника -> один матроид ──
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
  // запрещённые пары: пунктирные рёбра через именованные порты
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
  // результаты
  draw.content((-1.9, -1.9), text(
    size: 0.85em,
    fill: c-label,
  )[жадный: ${a}$, вес $5$], name: "lbl-greedy")
  draw.content((0.9, -2.7), text(
    size: 0.85em,
    fill: c-label,
  )[оптимум: ${b,c}$, вес $8$], name: "lbl-opt")
  draw.line("a.south", "lbl-greedy.north", stroke: e-str, mark: (end: "stealth"))
  draw.line("c.south", "lbl-opt.north", stroke: e-str, mark: (end: "stealth"))
})

// ── 3. Интервальное расписание ──
#let interval-scheduling = canvas({
  let bar(y, x1, x2, label, name, fill) = {
    draw.rect(
      (x1, y + 0.25),
      (x2, y - 0.25),
      fill: fill,
      stroke: e-str,
      radius: 2pt,
      name: name,
    )
    draw.content(name + ".north", anchor: "south", text(
      size: 0.8em,
      fill: c-label,
    )[#label])
  }
  draw.line((0, 0), (11, 0), stroke: e-str)
  for i in range(11) {
    draw.line((i, -0.12), (i, 0.12), stroke: e-str)
    draw.content((i, -0.45), text(size: 0.62em, fill: c-label)[#i])
  }
  bar(2.6, 1, 10, $A$, "bar-a", c-long-fill)
  bar(1.3, 1, 2, $B$, "bar-b", c-short-fill)
  bar(1.3, 3, 4, $C$, "bar-c", c-short-fill)
})

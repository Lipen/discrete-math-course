// m16 diagrams: источники матроида, контрпример жадного, интервальное расписание.
#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

#let n-stroke = t-bd + c-bd

#let e-stroke = (paint: c-edge, thickness: t-ed)

// ── Источники матроида ──
// Свойства-«доноры» независимости собираются в два аксиоматичных свойства матроида.
#let matroid-sources = {
  let src(pos, body, name) = node(pos, body, name: name, fill: c-fl)

  diagram(
    node-stroke: n-stroke,
    node-inset: 5pt,
    spacing: 1.8em,

    src((0, 0), [Лес \ ацикличность], <src-forest>),
    src((3, 0), [Векторы \ независимость], <src-linear>),
    src((6, 0), [Не более $k$ \ размер], <src-uniform>),

    node(
      (3, 2.6),
      [Матроид \ два свойства],
      name: <matroid>,
      fill: c-conn,
      stroke: n-stroke,
    ),

    edge(<src-forest>, <matroid>, "-}>", stroke: e-stroke),
    edge(<src-linear>, <matroid>, "-}>", stroke: e-stroke),
    edge(<src-uniform>, <matroid>, "-}>", stroke: e-stroke),
  )
}

// ── Контрпример жадного ──
// Жадный берёт $a$ (вес $5$), но $a$ конфликтует с $b$ и $c$; оптимум --- пара ${b,c}$.
#let greedy-counterexample = canvas({
  let elem(pos, letter, weight, name, fill: c-fl) = {
    draw.circle(pos, radius: 0.5, fill: fill, stroke: n-stroke, name: name)
    draw.content(pos, text(size: s-node, fill: c-ink)[#letter \ #weight])
  }
  let conflict(from, to) = draw.line(from, to, stroke: (
    paint: c-hot,
    thickness: t-bd,
    dash: "dashed",
  ))
  let result(from, to) = draw.line(from, to, stroke: e-stroke, mark: (end: "stealth", fill: c-edge))

  elem((-1.9, 0), $a$, $5$, "a", fill: c-warn)
  elem((0.9, 1.2), $b$, $4$, "b")
  elem((0.9, -1.2), $c$, $4$, "c")

  conflict("a.north-east", "b.south-west")
  conflict("a.south-east", "c.north-west")

  draw.content((-1.9, -1.9), text(size: s-cap, fill: c-hot)[жадный: ${a}$, вес $5$], name: "lbl-greedy")
  draw.content((0.9, -2.7), text(size: s-cap, fill: c-ink)[оптимум: ${b,c}$, вес $8$], name: "lbl-opt")
  result("a.south", "lbl-greedy.north")
  result("c.south", "lbl-opt.north")
})

// ── Интервальное расписание ──
#let interval-scheduling = canvas({
  let bar(y, x1, x2, label, name, fill) = {
    draw.rect((x1, y + 0.25), (x2, y - 0.25), fill: fill, stroke: e-stroke, radius: 2pt, name: name)
    draw.content(name + ".north", anchor: "south", text(size: s-node, fill: c-ink)[#label])
  }

  draw.line((0, 0), (11, 0), stroke: e-stroke)
  for i in range(11) {
    draw.line((i, -0.12), (i, 0.12), stroke: e-stroke)
    draw.content((i, -0.45), text(size: s-tiny, fill: c-muted)[#i])
  }

  bar(2.6, 1, 10, $A$, "bar-a", c-warn)
  bar(1.3, 1, 2, $B$, "bar-b", c-fl)
  bar(1.3, 3, 4, $C$, "bar-c", c-fl)
})

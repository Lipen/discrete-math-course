#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

#let n-stroke = t-bd + c-bd

#let e-stroke = (paint: c-edge, thickness: t-ed)

// ── Источники матроида ──
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
  let result(from, to) = draw.line(from, to, stroke: e-stroke, mark: (
    end: "stealth",
    fill: c-edge,
  ))

  elem((-1.9, 0), $a$, $5$, "a", fill: c-warn)
  elem((0.9, 1.2), $b$, $4$, "b")
  elem((0.9, -1.2), $c$, $4$, "c")

  conflict("a.north-east", "b.south-west")
  conflict("a.south-east", "c.north-west")

  draw.content(
    (-1.9, -1.9),
    text(size: s-cap, fill: c-hot)[жадный: ${a}$, вес $5$],
  )
  draw.content(
    (0.9, -2.7),
    text(size: s-cap, fill: c-ink)[оптимум: ${b,c}$, вес $8$],
  )
  result("a.south", (-1.9, -1.68))
  result("c.south", (0.9, -2.48))
})

// ── Интервальное расписание ──
#let interval-scheduling = canvas({
  let bar(y, x1, x2, label, fill) = {
    draw.rect(
      (x1, y + 0.25),
      (x2, y - 0.25),
      fill: fill,
      stroke: e-stroke,
      radius: 2pt,
    )
    draw.content(((x1 + x2) / 2, y + 0.38), anchor: "south", text(
      size: s-node,
      fill: c-ink,
    )[#label])
  }

  draw.line((0, 0), (11, 0), stroke: e-stroke)
  for i in range(11) {
    draw.line((i, -0.12), (i, 0.12), stroke: e-stroke)
    draw.content((i, -0.45), text(size: s-tiny, fill: c-muted)[#i])
  }

  bar(2.6, 1, 10, $A$, c-warn)
  bar(1.3, 1, 2, $B$, c-fl)
  bar(1.3, 3, 4, $C$, c-fl)
})

// ── Плоскость Фано ──
// Семь точек: 1, 2, 4 --- вершины треугольника, 3, 5, 6 --- середины сторон, 7 --- центр.
// Прямые: 123, 145, 246 (стороны), 167, 257, 347 (медианы), 356 (вписанная окружность).
#let fano-plane = canvas({
  let pt = (
    p1: (pos: (0, 2), label: $1$),
    p2: (pos: (-1.732, -1), label: $2$),
    p3: (pos: (-0.866, 0.5), label: $3$),
    p4: (pos: (1.732, -1), label: $4$),
    p5: (pos: (0.866, 0.5), label: $5$),
    p6: (pos: (0, -1), label: $6$),
    p7: (pos: (0, 0), label: $7$),
  )
  let ln(..args) = draw.line(..args, stroke: e-stroke)

  // Стороны треугольника: 1-3-2, 1-5-4, 2-6-4
  ln(pt.p1.pos, pt.p3.pos, pt.p2.pos)
  ln(pt.p1.pos, pt.p5.pos, pt.p4.pos)
  ln(pt.p2.pos, pt.p6.pos, pt.p4.pos)
  // Медианы через центр: 1-7-6, 2-7-5, 4-7-3
  ln(pt.p1.pos, pt.p7.pos, pt.p6.pos)
  ln(pt.p2.pos, pt.p7.pos, pt.p5.pos)
  ln(pt.p4.pos, pt.p7.pos, pt.p3.pos)
  // Прямая 3-5-6 --- окружность через середины сторон; остальные точки на ней не лежат
  draw.circle((0, 0), radius: 1, stroke: (
    paint: c-atom.darken(15%),
    thickness: t-ed,
  ))

  for (name, point) in pt {
    draw.circle(
      point.pos,
      radius: 0.3,
      fill: c-fl,
      stroke: n-stroke,
      name: name,
    )
    draw.content(point.pos, text(size: s-node, fill: c-ink)[#point.label])
  }
})

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
  let bw = 5.6
  let x0 = -bw / 2
  draw.rect(
    (x0, y + 0.5),
    (x0 + bw, y - 0.5),
    radius: 7pt,
    fill: fill,
    stroke: t-bd + c-bd,
  )
  draw.content(
    (x0 + 0.45, y),
    anchor: "west",
    text(size: s-node, weight: "bold", fill: c-ink)[$[#residue]$],
  )
  draw.line(
    (x0 + 1.2, y + 0.34),
    (x0 + 1.2, y - 0.34),
    stroke: c-edge + t-hr,
  )
  let step = 0.95
  let start = x0 + 1.65
  for (i, it) in items.enumerate() {
    let cx = start + i * step
    draw.rect(
      (cx - 0.32, y + 0.22),
      (cx + 0.32, y - 0.22),
      radius: 3pt,
      fill: white,
      stroke: c-bd + t-hr,
    )
    draw.content((cx, y), text(size: s-node, fill: c-ink)[#it])
  }
}

#let equivalence-partition = canvas({
  eq-class(2.6, c-fl, 0, (3, 6, 9))
  eq-class(0, c-atom, 1, (1, 4, 7, 10))
  eq-class(-2.6, c-warn, 2, (2, 5, 8))
})

// ── Дендрограмма: ультраметрическая кластеризация {a,b,c,d} ──
#let dendrogram = canvas({
  let hline(a, b) = draw.line(a, b, stroke: e-stroke)
  let vline(a, b) = draw.line(a, b, stroke: e-stroke)

  let leaf(x, label) = {
    draw.content((x, -0.35), anchor: "north", text(
      size: s-node,
      fill: c-ink,
    )[#label])
  }

  leaf(0, $a$)
  leaf(1, $b$)
  leaf(2, $c$)
  leaf(3, $d$)

  // Слияние a и b на высоте 1.
  vline((0, 0), (0, 1))
  vline((1, 0), (1, 1))
  hline((0, 1), (1, 1))

  // Слияние c и d на высоте 2.
  vline((2, 0), (2, 2))
  vline((3, 0), (3, 2))
  hline((2, 2), (3, 2))

  // Слияние всех на высоте 3.
  vline((0.5, 1), (0.5, 3))
  vline((2.5, 2), (2.5, 3))
  hline((0.5, 3), (2.5, 3))

  // Метки высот.
  draw.content((-0.35, 1), anchor: "east", text(size: s-node, fill: c-ink)[$1$])
  draw.content((-0.35, 2), anchor: "east", text(size: s-node, fill: c-ink)[$2$])
  draw.content((-0.35, 3), anchor: "east", text(size: s-node, fill: c-ink)[$3$])
})

// ── Филогенетическое дерево млекопитающих ──
#let mammal-tree = canvas({
  // Схема: высоты ветвлений не в масштабе, времена подписаны.
  let edge = e-stroke

  // Плашка под листом.
  let plate-w = 0.9
  let plate-top = -0.3
  let plate-bot = -0.9
  let plate-mid = (plate-top + plate-bot) / 2

  // Высоты ветвлений (схематичная шкала).
  let h6 = 1.5
  let h8 = 2.0
  let h14 = 2.5
  let h55 = 3.5
  let h75 = 4.0
  let h85 = 4.5

  // Горизонтальные позиции листьев.
  let gap = 2.0
  let x0 = 0
  let x1 = x0 + gap
  let x2 = x1 + gap
  let x3 = x2 + gap
  let x4 = x3 + gap
  let x5 = x4 + gap
  let x6 = x5 + gap

  // Середины групп.
  let m-human-chimp = (x0 + x1) / 2
  let m-ape3 = (m-human-chimp + x2) / 2
  let m-ape4 = (m-ape3 + x3) / 2
  let m-dog-cat = (x4 + x5) / 2
  let m-laur = (m-dog-cat + x6) / 2
  let m-root = (m-ape4 + m-laur) / 2

  // Вспомогательные построения.
  let line(a, b) = draw.line(a, b, stroke: edge)
  let leaf(x, label) = {
    draw.rect(
      (x - plate-w, plate-top),
      (x + plate-w, plate-bot),
      fill: luma(235),
      stroke: luma(160) + 0.6pt,
      radius: 6pt,
    )
    draw.content((x, plate-mid), text(size: s-node, fill: c-ink)[#label])
  }
  let stem(x, h) = line((x, 0), (x, h))

  // Листья.
  leaf(x0, [🚶 человек])
  leaf(x1, [🐒 шимпанзе])
  leaf(x2, [🦍 горилла])
  leaf(x3, [🦧 орангутан])
  leaf(x4, [🐕 собака])
  leaf(x5, [🐈 кошка])
  leaf(x6, [🐬 дельфин])

  // Стволы листьев.
  stem(x0, h6)
  stem(x1, h6)
  stem(x2, h8)
  stem(x3, h14)
  stem(x4, h55)
  stem(x5, h55)
  stem(x6, h75)

  // Приматы: человек+шимпанзе (6), затем горилла (8), затем орангутан (14).
  line((x0, h6), (x1, h6))
  line((m-human-chimp, h6), (m-human-chimp, h8))
  line((m-human-chimp, h8), (x2, h8))
  line((m-ape3, h8), (m-ape3, h14))
  line((m-ape3, h14), (x3, h14))
  line((m-ape4, h14), (m-ape4, h85))

  // Хищные и китообразные: собака+кошка (55), дельфин отделяется около 55, от хищных --- 75.
  line((x4, h55), (x5, h55))
  line((m-dog-cat, h55), (m-dog-cat, h75))
  line((m-dog-cat, h75), (x6, h75))
  line((m-laur, h75), (m-laur, h85))

  // Корень и кончик.
  line((m-ape4, h85), (m-laur, h85))
  let tip = 0.4
  line((m-root, h85), (m-root, h85 + tip))

  // Метки времени.
  let axis-x = -0.5
  let label(h, t) = draw.content(
    (axis-x, h),
    anchor: "east",
    text(size: s-cap, weight: "bold", fill: c-ink)[$#t$],
  )
  label(h6, 6)
  label(h8, 8)
  label(h14, 14)
  label(h55, 55)
  label(h75, 75)
  label(h85, 85)
  draw.content((axis-x, h85 + 2 * tip), anchor: "west", text(size: s-cap, fill: c-muted)[MYA (млн лет назад)])
})

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
  let sc = 0.05
  let hline(a, b) = draw.line(a, b, stroke: e-stroke)
  let vline(a, b) = draw.line(a, b, stroke: e-stroke)
  let leaf(x, label) = {
    draw.content(
      (x, -0.35),
      anchor: "north",
      text(size: s-node, fill: c-ink)[#label],
      frame: "rect",
      fill: luma(235),
      stroke: luma(160) + 0.6pt,
      radius: 3pt,
      padding: 2.5pt,
    )
  }

  leaf(0, [🚶 человек])
  leaf(2.4, [🐒 шимпанзе])
  leaf(4.8, [🐕 собака])
  leaf(7.2, [🐈 кошка])
  leaf(9.6, [🐬 дельфин])
  leaf(12, [🐄 корова])

  // Человек и шимпанзе расходятся около 6 млн лет назад.
  vline((0, 0), (0, 6 * sc))
  vline((2.4, 0), (2.4, 6 * sc))
  hline((0, 6 * sc), (2.4, 6 * sc))

  // Собака и кошка расходятся около 55 млн лет назад.
  vline((4.8, 0), (4.8, 55 * sc))
  vline((7.2, 0), (7.2, 55 * sc))
  hline((4.8, 55 * sc), (7.2, 55 * sc))

  // Дельфин и корова расходятся около 55 млн лет назад.
  vline((9.6, 0), (9.6, 55 * sc))
  vline((12, 0), (12, 55 * sc))
  hline((9.6, 55 * sc), (12, 55 * sc))

  // Хищные и китопарнокопытные расходятся около 75 млн лет назад.
  vline((6.0, 55 * sc), (6.0, 75 * sc))
  vline((10.8, 55 * sc), (10.8, 75 * sc))
  hline((6.0, 75 * sc), (10.8, 75 * sc))

  // Приматы и лавразиатерии расходятся около 85 млн лет назад.
  vline((1.2, 6 * sc), (1.2, 85 * sc))
  vline((8.4, 75 * sc), (8.4, 85 * sc))
  hline((1.2, 85 * sc), (8.4, 85 * sc))

  draw.content((-0.5, 6 * sc), anchor: "east", text(size: s-cap, weight: "bold", fill: c-ink)[$6$])
  draw.content((-0.5, 55 * sc), anchor: "east", text(size: s-cap, weight: "bold", fill: c-ink)[$55$])
  draw.content((-0.5, 75 * sc), anchor: "east", text(size: s-cap, weight: "bold", fill: c-ink)[$75$])
  draw.content((-0.5, 85 * sc), anchor: "east", text(size: s-cap, weight: "bold", fill: c-ink)[$85$])
  draw.content((-0.5, 95 * sc), anchor: "east", text(size: s-cap, fill: c-muted)[млн лет назад])
})

// Диаграммы модуля графов на общих токенах style.typ.
#import "style.typ": *
#import "@preview/cetz:0.5.2": canvas, draw

// Кружок-вершина с подписью.
#let vnode(name, pos, body, tone: cool, size: 0.31) = {
  vertex(name, pos, tone: tone, size: size)
  mark(pos, body)
}

// Квадрат-вершина с подписью: вторая доля двудольного графа.
#let snode(name, pos, body, tone: warm) = {
  cell(name, pos, tone: tone)
  mark(pos, body)
}

// ── Решётка с деревом обхода BFS ──
#let bfs-grid = canvas({
  let pts = ((0, 0), (1, 0), (2, 0), (0, -0.95), (1, -0.95), (2, -0.95))
  // Старт тонируется; дерево обхода --- единственный акцент фигуры.
  draw.circle(
    (0, 0),
    radius: 0.31,
    fill: fill-soft,
    stroke: 1.4pt + cool,
    name: "n1",
  )
  mark((0, 0), "1")
  for (i, p) in pts.enumerate() {
    if i > 0 { vnode("n" + str(i + 1), p, str(i + 1)) }
  }
  for (a, b) in (
    ("n1", "n2"),
    ("n1", "n4"),
    ("n2", "n3"),
    ("n2", "n5"),
    ("n3", "n6"),
  ) {
    draw.line(a, b, stroke: edge-cool)
  }
  for (a, b) in (("n4", "n5"), ("n5", "n6")) {
    draw.line(a, b, stroke: edge-thin)
  }
})

// ── K_5 ──
#let k5 = canvas({
  let v = (
    (0, 1.1),
    (1.047, 0.34),
    (0.647, -0.89),
    (-0.647, -0.89),
    (-1.047, 0.34),
  )
  for (i, p) in v.enumerate() { vnode("v" + str(i + 1), p, str(i + 1)) }
  for i in range(5) {
    for j in range(i + 1, 5) {
      draw.line("v" + str(i + 1), "v" + str(j + 1), stroke: edge-plain)
    }
  }
})

// ── K_(3,3): доли-круги против доли-квадратов ──
#let k33 = canvas({
  panel((-1.6, 1.18), (-0.5, -1.18), tone: cool)
  panel((0.5, 1.18), (1.6, -1.18), tone: warm, fill: panel-warm)
  mark((-1.95, 0), [$X$])
  mark((1.95, 0), [$Y$])
  for i in range(3) {
    vnode("l" + str(i + 1), (-1.05, 0.75 - 0.75 * i), [$v_#(i + 1)$])
  }
  for i in range(3) {
    snode("r" + str(i + 1), (1.05, 0.75 - 0.75 * i), [$u_#(i + 1)$])
  }
  for i in range(3) {
    for j in range(3) {
      draw.line("l" + str(i + 1), "r" + str(j + 1), stroke: edge-plain)
    }
  }
})

// ── Двудольный граф: доли X и Y ──
#let bipartite = canvas({
  panel((-1.05, 1.2), (1.55, 0.4), tone: cool)
  panel((-1.05, -0.4), (1.55, -1.2), tone: warm, fill: panel-warm)
  mark((-1.35, 0.8), [$X$])
  mark((-1.35, -0.8), [$Y$])
  let top = ((-0.6, 0.8), (0.25, 0.8), (1.1, 0.8))
  let bot = ((-0.6, -0.8), (0.25, -0.8), (1.1, -0.8))
  for (i, p) in top.enumerate() { vertex("t" + str(i + 1), p) }
  for (i, p) in bot.enumerate() { cell("b" + str(i + 1), p, tone: warm) }
  for (a, b) in (
    ("t1", "b1"),
    ("t1", "b2"),
    ("t2", "b1"),
    ("t2", "b2"),
    ("t2", "b3"),
    ("t3", "b2"),
    ("t3", "b3"),
  ) {
    draw.line(a, b, stroke: edge-plain)
  }
})

// ── Корневое дерево: каркас зелёным, листья приглушены ──
#let tree = canvas({
  let pts = (
    "r": (0, 1.18),
    "a": (-0.9, 0.48),
    "b": (0.9, 0.48),
    "c": (-1.35, -0.15),
    "d": (-0.45, -0.15),
    "e": (0.45, -0.15),
    "f": (1.35, -0.15),
    "g": (-1.6, -0.8),
    "h": (-0.7, -0.8),
    "i": (0.2, -0.8),
  )
  for lab in ("r", "a", "b", "c", "d", "e", "f") {
    vnode(lab, pts.at(lab), lab, tone: green)
  }
  for lab in ("g", "h", "i") {
    draw.circle(
      pts.at(lab),
      radius: 0.19,
      fill: fill-soft,
      stroke: edge-thin,
      name: lab,
    )
    mark(pts.at(lab), lab)
  }
  for (a, b) in (
    ("a", "r"),
    ("b", "r"),
    ("c", "a"),
    ("d", "a"),
    ("e", "b"),
    ("f", "b"),
    ("g", "c"),
    ("h", "d"),
    ("i", "e"),
  ) {
    let (ax, ay) = pts.at(a)
    let (bx, by) = pts.at(b)
    let bow = if ax > bx { 0.1 } else if ax < bx { -0.1 } else { 0 }
    tie(
      a,
      b,
      ((ax + bx) / 2 + bow, (ay + by) / 2),
      style: edge-green,
      from: "north",
      to: "south",
    )
  }
})

// ── Мосты Кёнигсберга: берега-плашки, острова-кружки ──
#let eulerian = canvas({
  let bank = (fill: panel-warm, stroke: 0.7pt + warm.lighten(45%), radius: 0.26)
  draw.rect((-2.25, 0.5), (-0.85, -0.5), ..bank, name: "A")
  draw.rect((0.85, 0.5), (2.25, -0.5), ..bank, name: "B")
  vnode("C", (0, 0.75), "C", tone: cool)
  vnode("D", (0, -0.75), "D", tone: cool)
  mark((-1.55, 0), "A")
  mark((1.55, 0), "B")
  tie("A", "D", (-0.55, -0.42), from: "east", to: "west")
  tie("B", "D", (0.55, -0.42), from: "west", to: "east")
  tie("C", "D", (0.1, 0), from: "south", to: "north")
  tie("A", "C", (-1.35, 1.05), from: "north", to: "north-west")
  tie("A", "C", (-0.78, 0.48), from: "north-east", to: "south-west")
  tie("B", "C", (1.35, 1.05), from: "north", to: "north-east")
  tie("B", "C", (0.78, 0.48), from: "north-west", to: "south-east")
  mark((-2.55, 0), [$3$], tone: ink-soft)
  mark((2.55, 0), [$3$], tone: ink-soft)
  mark((0, 1.28), [$5$], tone: ink-soft)
  mark((0, -1.28), [$3$], tone: ink-soft)
})

// ── Планарная укладка: внешняя грань подложкой ──
#let planar = canvas({
  panel((-1.75, 1.7), (1.75, -1.7), tone: cool)
  let v = (
    (0, 1.3),
    (1.22, 0.68),
    (1.22, -0.68),
    (0, -1.3),
    (-1.22, -0.68),
    (-1.22, 0.68),
  )
  for (i, p) in v.enumerate() { vnode("v" + str(i + 1), p, str(i + 1)) }
  for (a, b) in (
    ("v1", "v2"),
    ("v2", "v3"),
    ("v3", "v4"),
    ("v4", "v5"),
    ("v5", "v6"),
    ("v6", "v1"),
    ("v1", "v3"),
    ("v1", "v4"),
    ("v1", "v5"),
  ) {
    draw.line(a, b, stroke: edge-plain)
  }
  for (p, lab) in (
    ((0.81, 0.43), [$f_1$]),
    ((0.41, -0.23), [$f_2$]),
    ((-0.41, -0.23), [$f_3$]),
    ((-0.81, 0.43), [$f_4$]),
  ) {
    mark(p, lab, tone: ink-soft)
  }
  mark((1.42, -1.4), [$f_5$], tone: ink-soft)
})

// ── Раскраска C_5 в три цвета ──
#let graph-coloring = canvas({
  let v = (
    (0, 1.15),
    (-1.094, 0.355),
    (-0.676, -0.93),
    (0.676, -0.93),
    (1.094, 0.355),
  )
  let ci = (warm, green, warm, green, cool)
  for (i, p) in v.enumerate() {
    let tone = ci.at(i)
    draw.circle(
      p,
      radius: 0.27,
      fill: tone.lighten(40%),
      stroke: 1.4pt + tone,
      name: "c" + str(i),
    )
    mark(p, str(i))
  }
  for i in range(5) {
    draw.line("c" + str(i), "c" + str(calc.rem(i + 1, 5)), stroke: edge-plain)
  }
})

// ── Мост между двумя компонентами ──
#let bridge-cut = canvas({
  panel((-1.55, 1.15), (0, -0.65), tone: cool)
  panel((0, 1.15), (1.55, -0.65), tone: warm, fill: panel-warm)
  let v = (
    (-1.15, 0.75),
    (0.4, 0.75),
    (1.15, 0.75),
    (-1.15, -0.25),
    (-0.4, -0.25),
    (1.15, -0.25),
  )
  let tones = (cool, warm, warm, cool, cool, warm)
  for (i, p) in v.enumerate() {
    vnode("q" + str(i + 1), p, str(i + 1), tone: tones.at(i))
  }
  for (a, b) in (
    ("q1", "q4"),
    ("q4", "q5"),
    ("q5", "q1"),
    ("q2", "q3"),
    ("q3", "q6"),
    ("q6", "q2"),
  ) {
    draw.line(a, b, stroke: edge-plain)
  }
  draw.line("q1", "q2", stroke: edge-hot)
})

// ── Граф Петерсена: пентагон, спицы, пентаграмма ──
#let petersen = canvas({
  let outer = (
    (0, 1.2),
    (1.142, 0.371),
    (0.705, -0.971),
    (-0.705, -0.971),
    (-1.142, 0.371),
  )
  let inner = (
    (0, 0.62),
    (0.589, 0.192),
    (0.364, -0.501),
    (-0.364, -0.501),
    (-0.589, 0.192),
  )
  for (i, p) in outer.enumerate() {
    vnode("p" + str(i + 1), p, str(i + 1), size: 0.27)
  }
  for (i, p) in inner.enumerate() {
    vnode("p" + str(i + 6), p, str(i + 6), size: 0.27)
  }
  for i in range(5) {
    draw.line(
      "p" + str(calc.rem(i, 5) + 1),
      "p" + str(calc.rem(i + 1, 5) + 1),
      stroke: edge-plain,
    )
    draw.line("p" + str(i + 1), "p" + str(i + 6), stroke: edge-plain)
    draw.line(
      "p" + str(i + 6),
      "p" + str(calc.rem(i + 2, 5) + 6),
      stroke: edge-plain,
    )
  }
})

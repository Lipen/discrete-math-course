// Отношения: орграф, делимость, три представления, композиция, Уоршелл, эквивалентность.
#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/fletcher:0.5.8": diagram, edge, node
#import "style.typ": *
#import "../theme.typ": sim

// Три класса эквивалентности: общие тона для всех фигур файла.
#let class-tones = (cool, green, warm)
#let class-fills = (cool.lighten(78%), green.lighten(78%), warm.lighten(78%))

#let vertex-node(pos, body, ..args) = node(
  pos,
  text(size: 1.2em, fill: ink)[#body],
  ..args,
)
#let edge-arrow(from, to, ..args) = edge(
  from,
  to,
  "-}>",
  stroke: edge-plain,
  ..args,
)
#let loop-edge(from, to, angle: 30deg) = edge(
  from,
  to,
  "-}>",
  stroke: edge-plain,
  bend: 125deg,
  loop-angle: angle,
)
#let flow(
  a,
  b,
  ctrl,
  style: edge-plain,
  from: "east",
  to: "west",
) = draw.bezier(
  a + "." + from,
  b + "." + to,
  ctrl,
  stroke: style,
  mark: (end: "stealth", fill: style.paint),
)

// ── Орграф R на {1, ..., 5}: петли 1 и 5, цикл 1 -> 2 -> 3 -> 1 ──
#let rel-digraph = diagram(
  node-shape: "circle",
  node-fill: cool.lighten(82%),
  node-stroke: 1.2pt + cool,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 2.6em,
  vertex-node((-0.4, 1.6), $1$, name: <1>),
  vertex-node((1.3, 0.8), $2$, name: <2>),
  vertex-node((1.3, -0.8), $3$, name: <3>),
  vertex-node((-1.3, -0.8), $4$, name: <4>),
  vertex-node((-1.3, 0.8), $5$, name: <5>),
  loop-edge(<1>, <1>, angle: 270deg),
  loop-edge(<5>, <5>, angle: 135deg),
  edge(<1>, <2>, "-}>", stroke: edge-hot),
  edge(<2>, <3>, "-}>", stroke: edge-hot),
  edge(<3>, <1>, "-}>", stroke: edge-hot),
  edge-arrow(<1>, <5>),
  edge-arrow(<2>, <4>),
  edge-arrow(<4>, <2>),
  edge-arrow(<5>, <3>),
)

// ── Хассе: делимость на {1, 2, 3, 4, 6, 12}, только покрывающие рёбра ──
#let hasse-divisibility = canvas({
  let spot(name, pos) = {
    vertex(name, pos, size: 0.19)
    mark(pos, name)
  }

  spot("12", (0, 1.5))
  spot("4", (-0.75, 1.0))
  spot("6", (0.75, 1.0))
  spot("2", (-0.5, 0.5))
  spot("3", (0.5, 0.5))
  spot("1", (0, 0))

  for (a, b) in (
    ("1", "2"),
    ("1", "3"),
    ("2", "4"),
    ("2", "6"),
    ("3", "6"),
    ("4", "12"),
    ("6", "12"),
  ) {
    draw.line(a, b, stroke: edge-plain)
  }
})

// ── Разбиение {1, ..., 10} на классы по остаткам ──
#let equivalence-partition = canvas({
  let rows = (
    (elements: (3, 6, 9), residue: 0, tone: cool, fill: panel-cool),
    (elements: (1, 4, 7, 10), residue: 1, tone: green, fill: panel-green),
    (elements: (2, 5, 8), residue: 2, tone: warm, fill: panel-warm),
  )
  for (k, row) in rows.enumerate() {
    let y = 1.0 - k * 1.0
    panel((-2.4, y - 0.42), (2.4, y + 0.42), tone: row.tone, fill: row.fill)
    for (i, n) in row.elements.enumerate() {
      let x = -1.85 + i * 0.8
      cell(str(n), (x, y), tone: row.tone)
      mark((x, y), str(n))
    }
    mark((1.6, y), [$"mod" 3 = #row.residue$], tone: ink-soft)
  }
})

// ── Одно отношение в трёх представлениях: пары, матрица, орграф ──
#let rel-three-views = canvas({
  let m = ((1, 1, 0), (0, 0, 1), (1, 0, 0))

  panel((-5.5, -0.7), (-0.85, 0.7), tone: cool)
  mark((-3.0, 0), [$A = {1, 2, 3}$ \ $R = {(1, 1), (1, 2), (2, 3), (3, 1)}$])

  panel((-0.5, -0.95), (1.7, 0.95), tone: green, fill: panel-green)
  let c = 0.42
  for i in range(3) {
    for j in range(3) {
      let x = -0.03 + j * c
      let y = 0.63 - i * c
      draw.rect(
        (x, y - c),
        (x + c, y),
        fill: white,
        stroke: (paint: ink-soft, thickness: 0.4pt),
      )
      if m.at(i).at(j) == 1 {
        draw.content(
          (x + c / 2, y - c / 2),
          text(fill: ink, weight: "bold")[1],
        )
      }
    }
  }

  panel((2.1, -0.95), (5.3, 0.95), tone: warm, fill: panel-warm)
  vertex("t1", (2.95, 0.5), tone: warm, size: 0.26)
  vertex("t2", (2.95, -0.5), tone: warm, size: 0.26)
  vertex("t3", (4.45, 0), tone: warm, size: 0.26)
  mark((2.95, 0.5), $1$)
  mark((2.95, -0.5), $2$)
  mark((4.45, 0), $3$)
  flow("t1", "t1", (2.6, 0.95), from: "north", to: "west")
  flow("t1", "t2", (2.95, 0), from: "south", to: "north")
  flow("t2", "t3", (3.85, -0.45), from: "east", to: "south")
  flow("t3", "t1", (3.7, 0.42), from: "west", to: "east")
})

// ── Композиция как склейка путей: R, затем S, итог S∘R ──
#let rel-composition-paths = canvas({
  let dy = 0.85
  let spot(name, pos, label, tone) = {
    vertex(name, pos, tone: tone, size: 0.27)
    mark(pos, label)
  }

  panel((-0.55, -1.3), (2.25, 1.3), tone: cool)
  spot("ra1", (0, dy), $1$, cool)
  spot("ra2", (0, -dy), $2$, cool)
  spot("rb1", (1.7, dy), $x$, cool)
  spot("rb2", (1.7, -dy), $y$, cool)
  flow("ra1", "rb1", (0.85, dy + 0.16))
  flow("ra2", "rb1", (0.85, 0.1), style: edge-hot)
  flow("ra2", "rb2", (0.85, -dy - 0.16))
  mark((0.85, 1.62), $R$)
  mark((0, -1.62), $A$)
  mark((1.7, -1.62), $B$)

  panel((2.75, -1.3), (5.55, 1.3), tone: green, fill: panel-green)
  spot("sb1", (3.3, dy), $x$, green)
  spot("sb2", (3.3, -dy), $y$, green)
  spot("sc1", (5.0, dy), $alpha$, green)
  spot("sc2", (5.0, -dy), $beta$, green)
  flow("sb1", "sc1", (4.15, dy + 0.16), style: edge-hot)
  flow("sb2", "sc2", (4.15, -dy - 0.16))
  mark((4.15, 1.62), $S$)
  mark((3.3, -1.62), $B$)
  mark((5.0, -1.62), $C$)

  panel((6.05, -1.3), (8.85, 1.3), tone: warm, fill: panel-warm)
  spot("fa1", (6.6, dy), $1$, warm)
  spot("fa2", (6.6, -dy), $2$, warm)
  spot("fc1", (8.3, dy), $alpha$, warm)
  spot("fc2", (8.3, -dy), $beta$, warm)
  flow("fa1", "fc1", (7.45, dy + 0.16))
  flow("fa2", "fc1", (7.45, 0.1), style: edge-hot)
  flow("fa2", "fc2", (7.45, -dy - 0.16))
  mark((7.45, 1.62), $S compose R$)
  mark((6.6, -1.62), $A$)
  mark((8.3, -1.62), $C$)
})

// ── Уоршелл: единица, рождённая на текущем шаге ──
#let rel-warshall-steps = canvas({
  let c = 0.34
  let base = ((0, 1, 0), (0, 0, 1), (0, 0, 0))
  let after = ((0, 1, 1), (0, 0, 1), (0, 0, 0))

  vertex("w1", (0.45, -0.75), size: 0.26)
  vertex("w2", (1.55, 0), size: 0.26)
  vertex("w3", (0.45, 0.75), size: 0.26)
  mark((0.45, -0.75), $1$)
  mark((1.55, 0), $2$)
  mark((0.45, 0.75), $3$)
  draw.line(
    (0.66, -0.6),
    (1.34, -0.15),
    stroke: edge-plain,
    mark: (end: "stealth", fill: edge-plain.paint),
  )
  draw.line(
    (1.34, 0.15),
    (0.66, 0.6),
    stroke: edge-plain,
    mark: (end: "stealth", fill: edge-plain.paint),
  )
  mark((1.0, 1.35), $R$)

  let grid(x0, m, born) = {
    let top = 0.55
    for i in range(3) {
      for j in range(3) {
        let hot = born != none and born.at(0) == i and born.at(1) == j
        draw.rect(
          (x0 + j * c, top - (i + 1) * c),
          (x0 + (j + 1) * c, top - i * c),
          fill: if hot { warm.lighten(75%) },
          stroke: (paint: ink-soft, thickness: 0.4pt),
        )
        if m.at(i).at(j) == 1 {
          draw.content(
            (x0 + (j + 0.5) * c, top - (i + 0.5) * c),
            text(
              fill: if hot { warm } else { ink },
              weight: "bold",
            )[1],
          )
        }
      }
    }
    for t in range(3) {
      mark(
        (x0 + (t + 0.5) * c, top + 0.18),
        str(t + 1),
        tone: ink-soft,
      )
      mark(
        (x0 - 0.18, top - (t + 0.5) * c),
        str(t + 1),
        tone: ink-soft,
      )
    }
  }

  grid(
    2.5,
    base,
    none,
  )
  grid(
    4.4,
    after,
    (0, 2),
  )
  grid(
    6.3,
    after,
    none,
  )
  mark((3.01, 1.35), $k = 1$)
  mark((4.91, 1.35), $k = 2$)
  mark((6.81, 1.35), $k = 3$)
})

// ── Двудольное представление: две части, рёбра поперёк ──
#let rel-bipartite = canvas({
  let circles = (
    l1: (-2.25, 2.1),
    l2: (-2.25, 1.05),
    l3: (-2.25, 0),
    l4: (-2.25, -1.05),
    l5: (-2.25, -2.1),
  )
  let squares = (r1: (2.25, 1.31), r2: (2.25, 0), r3: (2.25, -1.31))
  let ties = (
    ("l1", "r1", 0.52, false),
    ("l1", "r2", 0.38, false),
    ("l2", "r1", 0.41, true),
    ("l3", "r1", 0.22, false),
    ("l3", "r3", -0.45, false),
    ("l4", "r2", -0.32, false),
  )

  panel((-3.75, -2.62), (-0.75, 2.62), tone: cool)
  panel((0.75, -2.62), (3.75, 2.62), tone: warm, fill: panel-warm)
  draw.line((0, -2.33), (0, 2.33), stroke: edge-soft)

  for (name, pos) in circles {
    vertex(name, pos, tone: cool, size: 0.32)
  }
  for (name, pos) in squares {
    cell(name, pos, tone: warm)
  }
  for (a, b, lift, accent) in ties {
    let ay = circles.at(a).at(1)
    let by = squares.at(b).at(1)
    tie(a, b, (0, (ay + by) / 2 + lift), style: if accent { edge-hot } else {
      edge-plain
    })
  }

  mark((0, 2.5), $R$)
  mark((-2.25, -3.0), $A$)
  mark((2.25, -3.0), $B$)
})

// ── Классы эквивалентности: непересекающиеся области внутри A ──
#let equivalence-classes-blobs = canvas({
  draw.rect(
    (-4.05, -2.2),
    (4.05, 2.2),
    radius: 0.2,
    stroke: (paint: ink, thickness: 0.8pt),
    name: "universe",
  )
  mark((3.6, 1.9), $A$)

  for (k, bounds) in (
    ((-3.4, 0.43), (-0.85, 1.7)),
    ((-3.4, -1.7), (-0.85, -0.43)),
    ((0.26, -1.7), (3.4, 1.7)),
  ).enumerate() {
    draw.rect(
      bounds.at(0),
      bounds.at(1),
      radius: 0.3,
      fill: class-fills.at(k),
      stroke: 0.7pt + class-tones.at(k),
    )
  }

  let dot(pos, label) = {
    draw.circle(pos, radius: 0.1, fill: ink, stroke: none)
    mark((pos.at(0), pos.at(1) + 0.42), label)
  }
  dot((-2.81, 1.05), $a$)
  dot((-1.45, 1.05), $b$)
  dot((-2.81, -1.05), $c$)
  dot((-1.45, -1.05), $d$)
  dot((1.02, 0.6), $e$)
  dot((2.04, 0.6), $f$)
  dot((2.81, -0.6), $g$)

  mark((-2.13, 0.68), $[a] = [b]$)
  mark((-2.13, -1.45), $[c]$)
  mark((1.83, -1.45), $[e]$)
})

// ── Каноническая проекция: классы сжимаются в точки фактора ──
#let quotient-collapse = canvas({
  for (k, bounds) in (
    ((-6.12, 0.94), (-3.23, 1.96)),
    ((-6.12, -0.51), (-3.23, 0.51)),
    ((-6.12, -1.96), (-3.23, -0.94)),
  ).enumerate() {
    draw.rect(
      bounds.at(0),
      bounds.at(1),
      radius: 0.3,
      fill: class-fills.at(k),
      stroke: 0.7pt + class-tones.at(k),
    )
  }
  draw.rect(
    (-6.35, -2.19),
    (-3.0, 2.19),
    radius: 0.2,
    stroke: (paint: ink, thickness: 0.8pt),
  )

  panel((0.7, -2.19), (2.7, 2.19), tone: cool)
  vertex("qa", (1.7, 1.45), tone: cool, size: 0.18)
  vertex("qc", (1.7, 0), tone: green, size: 0.18)
  vertex("qe", (1.7, -1.45), tone: warm, size: 0.18)
  mark((1.7, 0.95), $[a]$)
  mark((1.7, -0.5), $[c]$)
  mark((1.7, -1.95), $[e]$)

  for y in (1.45, 0, -1.45) {
    draw.line(
      (-3.23, y),
      (1.5, y),
      stroke: (paint: cool, thickness: 1.2pt, cap: "round"),
      mark: (end: "stealth", fill: cool),
    )
  }
  mark((-0.85, 1.75), $pi$, tone: cool)
  mark((-4.68, -2.55), $A$)
  mark((1.7, -2.55), $A\/_sim$)
})

// ── Эквивалентность в матрице: единицы блоками по диагонали ──
#let equivalence-matrix-blocks = canvas({
  let c = 0.5
  let n = 5
  let klass(i) = if i <= 2 { 0 } else if i == 3 { 1 } else { 2 }

  for i in range(n) {
    mark(((i + 0.5) * c, 0.35), str(i + 1))
    mark((-0.35, -(i + 0.5) * c), str(i + 1))
    for j in range(n) {
      draw.rect(
        (j * c, -(i + 1) * c),
        ((j + 1) * c, -i * c),
        fill: if klass(i) == klass(j) { class-fills.at(klass(i)) },
        stroke: (paint: ink-soft, thickness: 0.4pt),
      )
    }
  }
})

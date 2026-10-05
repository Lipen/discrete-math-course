#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

#let n-stroke = (paint: c-bd, thickness: t-bd)

#let e-stroke = (paint: c-edge, thickness: t-ed)

#let arrow-style = (
  mark: (end: "stealth", fill: c-edge),
  stroke: e-stroke,
)

#let node(pos, label, radius: 0.38) = {
  draw.circle(
    pos,
    radius: radius,
    fill: c-fl,
    stroke: n-stroke,
    name: label,
  )
  draw.content(pos)[#text(fill: c-ink, weight: "bold", size: s-node)[#label]]
}

#let small-node(pos, label) = node(pos, label, radius: 0.28)

#let edge-line(a, b, ..style) = {
  draw.line(a, b, stroke: e-stroke, ..style)
}

// ── Локальные семантические цвета ──
// Разбиения A/B (двудольность, потоки) и акцент пути.
#let c-pa-fill = oklch(90%, 0.03, 245deg)  // сторона A: фон
#let c-pb-fill = oklch(90%, 0.04, 45deg)   // сторона B: фон
#let c-pa-dot = oklch(65%, 0.12, 245deg)   // сторона A: узлы / акцент пути (синий)
#let c-pb-dot = oklch(65%, 0.14, 45deg)    // сторона B: узлы (персик)
// Раскраска C5.
#let c-colors = (
  oklch(80%, 0.14, 22deg), // тёплый
  oklch(80%, 0.12, 150deg), // зелёный
  oklch(80%, 0.12, 250deg), // синий
  oklch(82%, 0.14, 90deg), // жёлтый
)
// Код Прюфера: удалённые вершины/рёбра и ещё не восстановленные рёбра (серые).
#let c-pr-rem = oklch(82%, 0.01, 260deg)
#let c-pr-rem-str = oklch(72%, 0.01, 260deg)

// ── BFS-сетка ──
#let bfs-grid = canvas({
  let rows = ((0, 0), (1.5, 0), (3.0, 0), (0, -1.5), (1.5, -1.5), (3.0, -1.5))
  for (i, p) in rows.enumerate() { node(p, str(i + 1)) }
  edge-line("1", "2")
  edge-line("2", "3")
  edge-line("4", "5")
  edge-line("5", "6")
  edge-line("1", "4")
  edge-line("2", "5")
  edge-line("3", "6")
})

// ── K5 ──
#let k5 = canvas({
  let v = ((0, 2.5), (2.4, 0.8), (1.5, -2), (-1.5, -2), (-2.4, 0.8))
  for (i, p) in v.enumerate() { small-node(p, str(i + 1)) }
  for i in range(5) {
    for j in range(i + 1, 5) {
      edge-line(str(i + 1), str(j + 1))
    }
  }
})

// ── K33 ──
#let k33 = canvas({
  let left = ((0, 2), (0, 0), (0, -2))
  let right = ((4, 2), (4, 0), (4, -2))

  draw.rect(
    (-0.6, 2.5),
    (0.6, -2.5),
    radius: 6pt,
    fill: c-pa-fill,
    stroke: none,
  )
  draw.rect((3.4, 2.5), (4.6, -2.5), radius: 6pt, fill: c-pb-fill, stroke: none)
  for (i, p) in left.enumerate() {
    draw.circle(p, radius: 0.28, fill: c-pa-dot, name: "l" + str(i + 1))
    draw.content(p, $v_#(i + 1)$, anchor: "east", outset: 0.35em, size: s-tiny)
  }
  for (i, p) in right.enumerate() {
    draw.circle(p, radius: 0.28, fill: c-pb-dot, name: "r" + str(i + 1))
    draw.content(p, $u_#(i + 1)$, anchor: "west", outset: 0.35em, size: s-tiny)
  }
  for i in range(3) {
    for j in range(3) {
      edge-line("l" + str(i + 1), "r" + str(j + 1))
    }
  }
  draw.content((0, 2.6), anchor: "south")[$X$]
  draw.content((4, 2.6), anchor: "south")[$Y$]
})

// ── Двудольный граф ──
#let bipartite = canvas({
  let top = ((-1, 1.5), (0.5, 1.5), (2, 1.5))
  let bot = ((-1, -1.5), (0.5, -1.5), (2, -1.5))

  draw.rect((-1.8, 2.2), (2.8, 0.8), radius: 5pt, fill: c-pa-fill, stroke: none)
  draw.rect(
    (-1.8, -0.8),
    (2.8, -2.2),
    radius: 5pt,
    fill: c-pb-fill,
    stroke: none,
  )
  for (i, p) in top.enumerate() {
    draw.circle(p, radius: 0.38, fill: c-pa-dot, name: "t" + str(i + 1))
  }
  for (i, p) in bot.enumerate() {
    draw.circle(p, radius: 0.38, fill: c-pb-dot, name: "b" + str(i + 1))
  }
  edge-line("t1", "b1")
  edge-line("t1", "b2")
  edge-line("t2", "b1")
  edge-line("t2", "b2")
  edge-line("t2", "b3")
  edge-line("t3", "b2")
  edge-line("t3", "b3")
  draw.content((-2.2, 1.5), anchor: "east")[$X$]
  draw.content((-2.2, -1.5), anchor: "east")[$Y$]
})

// ── Дерево ──
#let tree = canvas({
  for (x, y, lab) in (
    (0, 2.5, "r"),
    (-1.5, 1, "a"),
    (1.5, 1, "b"),
    (-2.3, -0.2, "c"),
    (-0.7, -0.2, "d"),
    (0.7, -0.2, "e"),
    (2.3, -0.2, "f"),
  ) {
    draw.circle(
      (x, y),
      radius: 0.28,
      fill: c-atom,
      stroke: n-stroke,
      name: lab,
    )
    draw.content((x, y))[#text(fill: c-ink, weight: "bold", size: s-node)[#lab]]
  }
  for (x, y, lab) in ((-2.7, -1.5, "g"), (-1.2, -1.5, "h"), (0.2, -1.5, "i")) {
    draw.circle(
      (x, y),
      radius: 0.28,
      fill: none,
      stroke: n-stroke,
      name: lab,
    )
    draw.content((x, y))[#text(fill: c-ink, weight: "bold", size: s-node)[#lab]]
  }
  for (a, b) in (
    ("r", "a"),
    ("r", "b"),
    ("a", "c"),
    ("a", "d"),
    ("b", "e"),
    ("b", "f"),
    ("c", "g"),
    ("d", "h"),
    ("e", "i"),
  ) {
    edge-line(a, b)
  }
})

// ── Остовное дерево ──
#let spanning-tree = canvas({
  let v = ((0, 2.5), (-2, 0.5), (2, 0.5), (-1.5, -1.5), (1.5, -1.5))
  for (i, p) in v.enumerate() { node(p, str(i + 1), radius: 0.33) }

  let w = (
    (0, 1, "4", (-0.18, 0.12)),
    (0, 2, "3", (0.18, 0.12)),
    (1, 2, "5", (0, 0.22)),
    (1, 3, "2", (-0.25, -0.05)),
    (2, 4, "6", (0.25, -0.05)),
    (3, 4, "7", (0, -0.22)),
    (1, 4, "8", (0.12, 0.18)),
  )

  for (ai, bi, _, _) in w {
    edge-line(str(ai + 1), str(bi + 1), name: str(ai + 1) + "-" + str(bi + 1))
  }
  for (a, b) in (("1", "3"), ("1", "2"), ("2", "4"), ("3", "5")) {
    draw.line(a, b, stroke: (paint: c-accent, thickness: t-hi))
  }
  for (ai, bi, weight, off) in w {
    let ename = str(ai + 1) + "-" + str(bi + 1)
    draw.content(
      (rel: off, to: ename + ".mid"),
      weight,
      frame: "rect",
      fill: c-white,
      stroke: none,
      padding: 1pt,
      size: s-tiny,
    )
  }
})

// ── Кёнигсбергские мосты ──
#let eulerian = canvas({
  let v = ((0, 2.2), (0, -2.2), (-2, 0), (2, 0))
  let names = ("A", "B", "C", "D")
  let r = 0.52

  let rim(center, toward) = {
    let (cx, cy) = center
    let (tx, ty) = toward
    let d = calc.sqrt((tx - cx) * (tx - cx) + (ty - cy) * (ty - cy))
    (cx + (tx - cx) / d * r, cy + (ty - cy) / d * r)
  }

  for (i, p) in v.enumerate() {
    draw.circle(
      p,
      radius: r,
      fill: c-pa-fill,
      stroke: (paint: c-pa-dot, thickness: t-bd),
      name: names.at(i),
    )
    draw.content(p)[#text(weight: "bold", size: s-node)[#names.at(i)]]
  }

  draw.line("A", "D", stroke: e-stroke)
  draw.line("B", "D", stroke: e-stroke)
  draw.line("C", "D", stroke: e-stroke)

  draw.line("A", "C", stroke: e-stroke)
  let ac-ctrl = (-1.3, 1.3)
  draw.bezier(
    rim(v.at(0), ac-ctrl),
    rim(v.at(2), ac-ctrl),
    ac-ctrl,
    ac-ctrl,
    stroke: e-stroke,
  )

  draw.line("B", "C", stroke: e-stroke)
  let bc-ctrl = (-1.3, -1.3)
  draw.bezier(
    rim(v.at(1), bc-ctrl),
    rim(v.at(2), bc-ctrl),
    bc-ctrl,
    bc-ctrl,
    stroke: e-stroke,
  )

  draw.content(
    "A",
    anchor: "north",
    outset: 0.6em,
    size: s-cap,
    fill: c-muted,
  )[$3$]
  draw.content(
    "B",
    anchor: "south",
    outset: 0.6em,
    size: s-cap,
    fill: c-muted,
  )[$3$]
  draw.content(
    "C",
    anchor: "west",
    outset: 0.6em,
    size: s-cap,
    fill: c-muted,
  )[$5$]
  draw.content(
    "D",
    anchor: "east",
    outset: 0.6em,
    size: s-cap,
    fill: c-muted,
  )[$3$]
})

// ── Планарный граф ──
#let planar = canvas({
  let v = (
    (0, 2.5),
    (2.4, 1.3),
    (2.4, -1.3),
    (0, -2.5),
    (-2.4, -1.3),
    (-2.4, 1.3),
  )
  for (i, p) in v.enumerate() { node(p, str(i + 1), radius: 0.3) }

  edge-line("1", "2")
  edge-line("2", "3")
  edge-line("3", "4")
  edge-line("4", "5")
  edge-line("5", "6")
  edge-line("6", "1")
  edge-line("1", "3")
  edge-line("1", "4")
  edge-line("1", "5")

  for (p, lab) in (
    ((1.2, 1.2), $f_1$),
    ((1.8, 0), $f_2$),
    ((1.2, -1.2), $f_3$),
    ((-0.5, -1), $f_4$),
    ((-1.5, 0), $f_5$),
  ) {
    draw.content(p, lab, size: s-cap, fill: c-muted)
  }
})

// ── Раскраска C5 ──
#let graph-coloring = canvas({
  let v = (
    (0, 2),
    (-1.902, 0.618),
    (-1.176, -1.618),
    (1.176, -1.618),
    (1.902, 0.618),
  )
  let ci = (0, 1, 0, 1, 2)
  for (i, p) in v.enumerate() {
    let col = c-colors.at(ci.at(i))
    draw.content(
      p,
      [#text(weight: "bold", size: s-node)[#str(i)]],
      frame: "circle",
      radius: 0.42,
      fill: col,
      stroke: col.darken(20%),
      name: "c" + str(i),
    )
  }
  for i in range(5) {
    edge-line("c" + str(i), "c" + str(calc.rem(i + 1, 5)))
  }
  draw.content(
    (0, -2.3),
    anchor: "north",
    size: s-cap,
    fill: c-muted,
  )[$chi = 3$]
})

// ── Ориентированный граф ──
#let directed-graph = canvas({
  let v = ((0, 2.5), (2.5, 1), (2.5, -1), (0, -2.5), (-2.5, -1), (-2.5, 1))
  for (i, p) in v.enumerate() { small-node(p, str(i + 1)) }
  draw.line("1", "2", ..arrow-style)
  draw.line("2", "3", ..arrow-style)
  draw.line("3", "1", ..arrow-style)
  draw.line("1", "4", ..arrow-style)
  draw.line("4", "5", ..arrow-style)
  draw.line("5", "4", ..arrow-style)
  draw.line("6", "1", ..arrow-style)
  draw.line("2", "6", ..arrow-style)

  draw.circle((0, 0.75), radius: 3.1, fill: none, stroke: (
    paint: c-pa-dot,
    thickness: t-bd,
    dash: "dashed",
  ))
  draw.circle((-1.2, -1.8), radius: 1.6, fill: none, stroke: (
    paint: c-pb-dot,
    thickness: t-bd,
    dash: "dashed",
  ))
})

// ── Граф Петерсена ──
#let petersen = canvas({
  let outer = ((0, 2.5), (2.4, 0.8), (1.5, -2), (-1.5, -2), (-2.4, 0.8))
  let inner = (
    (0, 1.2),
    (1.15, 0.37),
    (0.72, -0.98),
    (-0.72, -0.98),
    (-1.15, 0.37),
  )
  for (i, p) in outer.enumerate() { small-node(p, str(i + 1)) }
  for (i, p) in inner.enumerate() { small-node(p, str(6 + i)) }
  for (a, b) in (
    ("1", "2"),
    ("2", "3"),
    ("3", "4"),
    ("4", "5"),
    ("5", "1"),
    ("6", "8"),
    ("7", "9"),
    ("8", "10"),
    ("9", "6"),
    ("10", "7"),
  ) {
    edge-line(a, b)
  }
  for i in range(5) {
    edge-line(str(i + 1), str(6 + i))
  }
})

// ── Мост и точка сочленения ──
#let bridge-cut = canvas({
  let v = (
    (-1.5, 1.5),
    (0, 1.5),
    (1.5, 1.5),
    (-1.5, -0.5),
    (0, -0.5),
    (1.5, -0.5),
  )
  for (i, p) in v.enumerate() { small-node(p, str(i + 1)) }
  for (a, b) in (
    ("1", "4"),
    ("4", "5"),
    ("1", "5"),
    ("2", "3"),
    ("3", "6"),
    ("2", "6"),
  ) {
    edge-line(a, b)
  }
  draw.line("1", "2", stroke: (paint: c-hot, thickness: t-hi))
  draw.circle(v.at(0), radius: 0.38, fill: none, stroke: (
    paint: c-hot,
    thickness: t-hi,
    dash: "dashed",
  ))
})

// ── BFS-дерево ──
#let bfs-tree = canvas({
  let v = (
    (0, 2.5),
    (-1.8, 1),
    (1.8, 1),
    (-2.8, -0.5),
    (-0.8, -0.5),
    (0.8, -0.5),
    (2.8, -0.5),
  )
  let r = 0.33

  let rim(center, toward) = {
    let (cx, cy) = center
    let (tx, ty) = toward
    let d = calc.sqrt((tx - cx) * (tx - cx) + (ty - cy) * (ty - cy))
    (cx + (tx - cx) / d * r, cy + (ty - cy) / d * r)
  }

  let shifts = (
    (0, 0.85),
    (-0.85, 0),
    (0.85, 0),
    (0, -0.85),
    (0, -0.85),
    (0, -0.85),
    (0, -0.85),
  )
  for (i, p) in v.enumerate() {
    node(p, str(i + 1), radius: 0.33)
    draw.content(
      (p.at(0) + shifts.at(i).at(0), p.at(1) + shifts.at(i).at(1)),
      size: s-tiny,
      fill: c-muted,
    )[
      $d!=!#((0, 1, 1, 2, 2, 2, 2).at(i))$
    ]
  }

  let cross-style = (paint: c-muted, thickness: t-hr, dash: "dashed")

  draw.bezier(
    rim(v.at(3), (0, -1.5)),
    rim(v.at(4), (0, -1.5)),
    (-2.8, -1.5),
    (-0.8, -1.5),
    stroke: cross-style,
  )
  draw.bezier(
    rim(v.at(5), (0, -1.5)),
    rim(v.at(6), (0, -1.5)),
    (0.8, -1.5),
    (2.8, -1.5),
    stroke: cross-style,
  )
  draw.bezier(
    rim(v.at(1), (1.8, -0.8)),
    rim(v.at(5), (1.8, -0.8)),
    (1.8, 0.2),
    (1.8, -1.3),
    stroke: cross-style,
  )

  for (a, b) in (
    ("1", "2"),
    ("1", "3"),
    ("2", "4"),
    ("2", "5"),
    ("3", "6"),
    ("3", "7"),
  ) {
    draw.line(a, b, stroke: (paint: c-pa-dot, thickness: t-hi))
  }
})

// ── Эйлеров цикл ──
#let euler-cycle = canvas({
  let pos = ((0, 1.5), (1, 0), (2, 1.5), (0, -1.5), (2, -1.5))
  let labs = ("A", "B", "C", "D", "E")

  for (i, p) in pos.enumerate() { node(p, labs.at(i), radius: 0.33) }

  let cycle = (
    ("B", "A", (-0.12, 0.12)),
    ("A", "C", (0, 0.15)),
    ("C", "B", (0.12, 0.12)),
    ("B", "D", (-0.12, -0.12)),
    ("D", "E", (0, -0.15)),
    ("E", "B", (0.12, -0.12)),
  )

  for (i, (a, b, off)) in cycle.enumerate() {
    let ename = a + "-" + b
    draw.line(a, b, stroke: (paint: c-pa-dot, thickness: t-hi), name: ename)
    let pt = (rel: off, to: ename + ".mid")
    draw.circle(pt, radius: 0.23, fill: c-white, stroke: (
      paint: c-pa-dot,
      thickness: t-bd,
    ))
    draw.content(pt, str(i + 1), size: s-tiny)
  }
})

// ── Наибольшее паросочетание и покрытие Кёнига ──
// Общая сцена: доли X/Y, серые непокрытые рёбра, жирное паросочетание.
#let matching-scene = {
  draw.rect(
    (-0.6, 3.5),
    (0.6, -0.5),
    radius: 6pt,
    fill: c-pa-fill,
    stroke: none,
  )
  draw.rect((3.4, 3.5), (4.6, -0.5), radius: 6pt, fill: c-pb-fill, stroke: none)

  for (i, y) in (0, 1.5, 3).enumerate() {
    draw.circle((0, y), radius: 0.38, fill: c-pa-dot, name: "L" + str(i + 1))
    draw.content(
      (0, y),
      $x_#(i + 1)$,
      anchor: "east",
      outset: 0.4em,
      size: s-node,
    )
    draw.circle((4, y), radius: 0.38, fill: c-pb-dot, name: "R" + str(i + 1))
    draw.content(
      (4, y),
      $y_#(i + 1)$,
      anchor: "west",
      outset: 0.4em,
      size: s-node,
    )
  }

  draw.line("L1", "R2", stroke: (paint: c-muted, thickness: t-ed))
  draw.line("L2", "R3", stroke: (paint: c-muted, thickness: t-ed))

  draw.line("L1", "R1", stroke: (paint: c-accent, thickness: t-hi))
  draw.line("L2", "R2", stroke: (paint: c-accent, thickness: t-hi))
  draw.line("L3", "R3", stroke: (paint: c-accent, thickness: t-hi))

  draw.content((0, 3.6), anchor: "south")[$X$]
  draw.content((4, 3.6), anchor: "south")[$Y$]
}

#let bipartite-matching = canvas({
  matching-scene
})

#let konig-cover = canvas({
  matching-scene

  for y in (0, 1.5, 3) {
    draw.circle((4, y), radius: 0.38, fill: none, stroke: (
      paint: c-hot,
      thickness: t-hi,
    ))
  }
})

// ── Контрпример Дейкстры ──
#let dijkstra-counterexample = canvas({
  node((0, 0), "S")
  node((3, 1.8), "A")
  node((3, -1.8), "B")

  draw.line("S", "A", ..arrow-style, name: "sa")
  draw.content((rel: (-0.05, 0.2), to: "sa.mid"), $3$, size: s-tiny)

  draw.line("S", "B", ..arrow-style, name: "sb")
  draw.content((rel: (-0.05, -0.2), to: "sb.mid"), $2$, size: s-tiny)

  draw.line(
    "A",
    "B",
    stroke: (paint: c-hot, thickness: t-hi, dash: "dashed"),
    mark: (end: "stealth", fill: c-hot),
    name: "ab",
  )
  draw.content((rel: (0.22, 0), to: "ab.mid"), $-2$, size: s-tiny, fill: c-hot)
})

// ── Код Прюфера ──
#let prufer-frame(ox, oy, vpos, edges, vst, est, code) = {
  let frame = str(ox).replace(".", "_")
  let nid = label => label + "-" + frame
  for (label, pos) in vpos {
    let st = vst.at(label, default: "on")
    let (fill, strk, txt) = if st == "off" {
      (c-pr-rem, c-pr-rem-str, c-pr-rem-str)
    } else if st == "last" {
      (c-atom, c-bd, c-ink)
    } else {
      (c-fl, c-bd, c-ink)
    }
    draw.circle(
      (pos.at(0) + ox, pos.at(1) + oy),
      radius: 0.27,
      fill: fill,
      stroke: (paint: strk, thickness: t-bd),
      name: nid(label),
    )
    draw.content(
      (pos.at(0) + ox, pos.at(1) + oy),
      text(fill: txt, weight: "bold", size: s-node)[#label],
    )
  }
  for (a, b) in edges {
    let st = est.at(a + b, default: "on")
    let stroke = if st == "none" {
      none
    } else if st == "off" {
      (paint: c-pr-rem-str, thickness: t-hr)
    } else if st == "future" {
      (paint: c-pr-rem-str, thickness: t-hr, dash: "dashed")
    } else if st == "add" {
      (paint: c-hot, thickness: t-hi)
    } else if st == "last" {
      (paint: c-accent, thickness: t-hi)
    } else {
      (paint: c-edge, thickness: t-ed)
    }
    if stroke == none {
      continue
    }
    draw.line(nid(a), nid(b), stroke: stroke)
  }
  draw.content(
    (1.2 + ox, -0.55 + oy),
    anchor: "north",
    text(fill: c-ink, size: s-cap)[#code],
  )
}

#let prufer-encode = canvas({
  let vpos = (
    "3": (1.5, 1.0),
    "2": (0.7, 1.9),
    "1": (0.0, 2.7),
    "4": (0.7, 0.1),
    "5": (2.3, 0.1),
  )
  let edges = (("1", "2"), ("2", "3"), ("3", "4"), ("3", "5"))
  prufer-frame(0.0, 0.0, vpos, edges, (:), (:), "K = []")
  prufer-frame(2.9, 0.0, vpos, edges, ("1": "off"), ("12": "off"), "K = [2]")
  prufer-frame(
    5.8,
    0.0,
    vpos,
    edges,
    ("1": "off", "2": "off"),
    ("12": "off", "23": "off"),
    "K = [2, 3]",
  )
  prufer-frame(
    8.7,
    0.0,
    vpos,
    edges,
    ("1": "off", "2": "off", "4": "off", "3": "last", "5": "last"),
    ("12": "off", "23": "off", "34": "off", "35": "last"),
    "K = [2, 3, 3]",
  )
})

#let prufer-decode = canvas({
  let vpos = (
    "1": (1.5, 1.8),
    "3": (0.6, 1.0),
    "5": (2.4, 1.0),
    "2": (0.0, 0.2),
    "4": (1.2, 0.2),
  )
  let edges = (("1", "3"), ("1", "5"), ("3", "2"), ("3", "4"))
  prufer-frame(
    0.0,
    0.0,
    vpos,
    edges,
    ("2": "on", "3": "on", "1": "off", "4": "off", "5": "off"),
    ("32": "add", "13": "future", "15": "future", "34": "future"),
    "K = [3, 1]",
  )
  prufer-frame(
    2.9,
    0.0,
    vpos,
    edges,
    ("2": "on", "3": "on", "4": "on", "1": "off", "5": "off"),
    ("32": "add", "34": "add", "13": "future", "15": "future"),
    "K = [1]",
  )
  prufer-frame(
    5.8,
    0.0,
    vpos,
    edges,
    ("2": "on", "3": "on", "4": "on", "1": "on", "5": "off"),
    ("32": "add", "34": "add", "13": "add", "15": "future"),
    "K = []",
  )
  prufer-frame(8.7, 0.0, vpos, edges, (:), (:), "K = []")
})

// ── Теорема Менгера ──
#let menger-paths = canvas({
  let c-path-green = oklch(55%, 0.18, 155deg) // путь 1 (зелёный)
  let c-path-blue = oklch(50%, 0.15, 250deg) // путь 2 (синий)

  node((0, 0.5), "u")
  node((1, 0), "a")
  node((1, 1), "b")
  node((2, 0), "c")
  node((2, 1), "d")
  node((3, 0.5), "v")

  edge-line("a", "d", stroke: (paint: c-muted, thickness: t-ed))
  edge-line("b", "c", stroke: (paint: c-muted, thickness: t-ed))
  edge-line("c", "d", stroke: (paint: c-muted, thickness: t-ed))

  edge-line("u", "a", stroke: (paint: c-path-green, thickness: t-hi))
  edge-line("a", "c", stroke: (paint: c-path-green, thickness: t-hi))
  edge-line("c", "v", stroke: (paint: c-path-green, thickness: t-hi))

  edge-line("u", "b", stroke: (paint: c-path-blue, thickness: t-hi))
  edge-line("b", "d", stroke: (paint: c-path-blue, thickness: t-hi))
  edge-line("d", "v", stroke: (paint: c-path-blue, thickness: t-hi))

  draw.circle((1, 0), radius: 0.38, fill: none, stroke: (
    paint: c-hot,
    thickness: t-hi,
  ))
  draw.circle((1, 1), radius: 0.38, fill: none, stroke: (
    paint: c-hot,
    thickness: t-hi,
  ))
})

// ── Сеть потока и её варианты ──
// Общие узлы сети s-a-b-t и ребро с подписью на плашке.
#let flow-nodes = {
  let v = ((-3, 0), (-0.5, 1.2), (-0.5, -1.2), (2.5, 0))
  for (i, p) in v.enumerate() {
    node(p, ("s", "a", "b", "t").at(i), radius: 0.36)
  }
}

#let labeled-arrow(
  from,
  to,
  label,
  offset,
  stroke: e-stroke,
  mark: (end: "stealth", fill: c-edge),
) = {
  let ename = from + "-" + to
  draw.line(from, to, name: ename, stroke: stroke, mark: mark)
  draw.content(
    (rel: offset, to: ename + ".mid"),
    label,
    frame: "rect",
    fill: c-white,
    stroke: none,
    padding: 1pt,
    size: s-tiny,
  )
}

#let flow-network = canvas({
  flow-nodes
  for (fr, to, cap, off) in (
    ("s", "a", "5", (-0.1, 0.26)),
    ("s", "b", "3", (-0.1, -0.26)),
    ("a", "t", "3", (0.1, 0.26)),
    ("b", "t", "4", (0.1, -0.26)),
    ("a", "b", "2", (0.22, 0)),
  ) {
    labeled-arrow(fr, to, cap, off)
  }
  draw.content((-3, 1.9), anchor: "south")[$s$]
  draw.content((2.5, 1.9), anchor: "south")[$t$]
})

// ── Допустимый поток ──
#let flow-values = canvas({
  flow-nodes
  for (fr, to, lb, off) in (
    ("s", "a", "3/5", (-0.12, 0.26)),
    ("s", "b", "2/3", (-0.12, -0.26)),
    ("a", "t", "2/3", (0.12, 0.26)),
    ("b", "t", "3/4", (0.12, -0.26)),
    ("a", "b", "1/2", (0.24, 0)),
  ) {
    labeled-arrow(fr, to, lb, off)
  }
})

// ── Остаточная сеть ──
#let residual-network = canvas({
  flow-nodes

  for (fr, to, cf, off, dim) in (
    ("s", "a", "2", (-0.12, 0.26), false),
    ("a", "s", "3", (-0.36, 0.18), true),
    ("s", "b", "1", (-0.12, -0.26), false),
    ("b", "s", "2", (-0.36, -0.18), true),
    ("a", "t", "1", (0.12, 0.26), false),
    ("t", "a", "2", (0.36, 0.18), true),
    ("b", "t", "1", (0.12, -0.26), false),
    ("t", "b", "3", (0.36, -0.18), true),
    ("a", "b", "1", (0.24, 0), false),
    ("b", "a", "1", (0.24, 0.1), true),
  ) {
    labeled-arrow(
      fr,
      to,
      cf,
      off,
      stroke: (
        paint: if dim { c-muted } else { c-edge },
        thickness: t-ed,
        dash: if dim { "dashed" } else { none },
      ),
      mark: (end: "stealth", fill: (if dim { c-muted } else { c-edge })),
    )
  }
})

// ── Разрез ──
#let flow-cut = canvas({
  flow-nodes

  for (fr, to, cap, off, hi) in (
    ("s", "a", "5", (-0.1, 0.26), false),
    ("s", "b", "3", (-0.1, -0.26), false),
    ("a", "t", "3", (0.1, 0.26), true),
    ("b", "t", "4", (0.1, -0.26), true),
    ("a", "b", "2", (0.24, 0), false),
  ) {
    labeled-arrow(
      fr,
      to,
      cap,
      off,
      stroke: (
        paint: if hi { c-hot } else { c-edge },
        thickness: if hi { t-hi } else { t-ed },
      ),
      mark: (end: "stealth", fill: (if hi { c-hot } else { c-edge })),
    )
  }
  draw.circle(
    (-1.2, 0),
    radius: 2.2,
    fill: c-pa-fill.transparentize(65%),
    stroke: (paint: c-pa-dot, thickness: t-bd, dash: "dashed"),
  )
})

// ── Поток через разрез ──
#let flow-cut-net = canvas({
  let v = ((-3, 0), (-0.5, 1.2), (-0.5, -1.2), (2.5, 0))
  for (i, p) in v.enumerate() {
    let (lbl, infA) = (("s", true), ("a", true), ("b", false), ("t", false)).at(
      i,
    )
    draw.circle(
      p,
      radius: 0.36,
      fill: if infA { c-atom } else { c-conn },
      stroke: n-stroke,
      name: lbl,
    )
    draw.content(p)[#text(fill: c-ink, weight: "bold", size: s-node)[#lbl]]
  }

  for (fr, to, lb, off, cross) in (
    ("s", "a", "3/3", (-0.12, 0.26), false),
    ("s", "b", "2/2", (-0.12, -0.26), true),
    ("a", "t", "2/2", (0.12, 0.26), true),
    ("b", "t", "3/3", (0.12, -0.26), false),
    ("a", "b", "1/1", (0.28, 0), true),
  ) {
    labeled-arrow(
      fr,
      to,
      lb,
      off,
      stroke: (
        paint: if cross { c-hot } else { c-edge },
        thickness: if cross { t-hi } else { t-ed },
      ),
      mark: (end: "stealth", fill: (if cross { c-hot } else { c-edge })),
    )
  }
})

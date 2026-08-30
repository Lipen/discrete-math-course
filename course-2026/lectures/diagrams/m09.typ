// Graph diagrams --- CeTZ 0.5.2, node-based.
// Скопировано из книги, чтобы лекции не зависели от неё.
#import "@preview/cetz:0.5.2": canvas, draw

// ── Palette ──
#let c-n-fill = oklch(88%, 0.03, 250deg)   // node fill: light blue
#let c-n-border = oklch(60%, 0.08, 250deg)   // node border
#let c-n-text = oklch(25%, 0.02, 260deg)   // node label

#let c-edge = oklch(35%, 0.02, 265deg)   // edges
#let c-edge-dim = oklch(65%, 0.01, 260deg)   // dimmed edges (grey)

#let c-hi = oklch(58%, 0.22, 22deg)    // highlight (bridge, cut-vertex)

#let c-t-fill = oklch(88%, 0.05, 155deg)   // tree node fill: light green
#let c-t-border = oklch(55%, 0.18, 155deg)   // tree edges & leaf border
#let c-t-leaf = oklch(50%, 0.10, 155deg)   // leaf text

#let c-pa-fill = oklch(90%, 0.03, 245deg)   // partition A background
#let c-pb-fill = oklch(90%, 0.04, 45deg)    // partition B background
#let c-pa-dot = oklch(65%, 0.12, 245deg)   // partition A node
#let c-pb-dot = oklch(65%, 0.14, 45deg)    // partition B node

// Colouring diagram palette (W_5)
#let c-colors = (
  oklch(80%, 0.14, 22deg), // warm red
  oklch(80%, 0.12, 150deg), // green
  oklch(80%, 0.12, 250deg), // blue
  oklch(82%, 0.14, 90deg), // yellow
)

// ── Helpers (re-import cetz.draw inside) ──
#let node(pos, label, radius: 0.19) = {
  draw.circle(
    pos,
    radius: radius,
    fill: c-n-fill,
    stroke: (paint: c-n-border, thickness: 0.8pt),
    name: label,
  )
  draw.content(pos)[#text(size: 0.5em, fill: c-n-text, weight: "bold")[#label]]
}

#let snode(pos, label) = { node(pos, label, radius: 0.14) }

// Edge helper: e("a", "b") --- styled edge. e("a", "b", stroke: ...) --- override.
#let e(a, b, ..style) = {
  draw.line(a, b, stroke: (paint: c-edge, thickness: 0.7pt), ..style)
}

// ── BFS grid (3×2) ──
#let bfs-grid = canvas({
  let rows = ((0, 0), (0.75, 0), (1.5, 0), (0, -0.75), (0.75, -0.75), (1.5, -0.75))
  for (i, p) in rows.enumerate() { node(p, str(i + 1)) }

  // Horizontal
  e("1", "2")
  e("2", "3")
  e("4", "5")
  e("5", "6")
  // Vertical
  e("1", "4")
  e("2", "5")
  e("3", "6")
})

// ── K_5 ──
#let k5 = canvas({
  let v = ((0, 1.25), (1.2, 0.4), (0.75, -1), (-0.75, -1), (-1.2, 0.4))
  for (i, p) in v.enumerate() { snode(p, str(i + 1)) }
  for i in range(5) {
    for j in range(i + 1, 5) {
      draw.line(str(i + 1), str(j + 1), stroke: (
        paint: c-edge,
        thickness: 0.7pt,
      ))
    }
  }
})

// ── K_{3,3} ──
#let k33 = canvas({
  let left = ((0, 1), (0, 0), (0, -1))
  let right = ((2, 1), (2, 0), (2, -1))
  // Background regions
  draw.rect(
    (-0.3, 1.25),
    (0.3, -1.25),
    radius: 3pt,
    fill: c-pa-fill,
    stroke: none,
  )
  draw.rect((1.7, 1.25), (2.3, -1.25), radius: 3pt, fill: c-pb-fill, stroke: none)
  // Nodes FIRST : named so line() routes border-to-border
  for (i, p) in left.enumerate() {
    draw.circle(p, radius: 0.14, fill: c-pa-dot, name: "l" + str(i + 1))
    draw.content(p, $v_i$, anchor: "west", outset: 0.15em, size: .4em)
  }
  for (i, p) in right.enumerate() {
    draw.circle(p, radius: 0.14, fill: c-pb-dot, name: "r" + str(i + 1))
    draw.content(p, $u_i$, anchor: "east", outset: 0.15em, size: .4em)
  }
  // Edges : node names, not coordinates
  for i in range(3) {
    for j in range(3) {
      draw.line("l" + str(i + 1), "r" + str(j + 1), stroke: (
        paint: c-edge,
        thickness: 0.7pt,
      ))
    }
  }
  draw.content((0, 1.3), anchor: "south", size: .5em)[$X$]
  draw.content((2, 1.3), anchor: "south", size: .5em)[$Y$]
})

// ── Bipartite graph ──
#let bipartite = canvas({
  let top = ((-0.5, 0.75), (0.25, 0.75), (1, 0.75))
  let bot = ((-0.5, -0.75), (0.25, -0.75), (1, -0.75))
  // Background regions
  draw.rect((-0.9, 1.1), (1.4, 0.4), radius: 2.5pt, fill: c-pa-fill, stroke: none)
  draw.rect(
    (-0.9, -0.4),
    (1.4, -1.1),
    radius: 2.5pt,
    fill: c-pb-fill,
    stroke: none,
  )
  // Nodes FIRST
  for (i, p) in top.enumerate() {
    draw.circle(p, radius: 0.19, fill: c-pa-dot, name: "t" + str(i + 1))
  }
  for (i, p) in bot.enumerate() {
    draw.circle(p, radius: 0.19, fill: c-pb-dot, name: "b" + str(i + 1))
  }
  // Edges : node names
  e("t1", "b1")
  e("t1", "b2")
  e("t2", "b1")
  e("t2", "b2")
  e("t2", "b3")
  e("t3", "b2")
  e("t3", "b3")
  draw.content((-1.1, 0.75), anchor: "east", size: .5em)[$X$]
  draw.content((-1.1, -0.75), anchor: "east", size: .5em)[$Y$]
})

// ── Rooted tree ──
#let tree = canvas({
  // Nodes FIRST : each named by its label letter
  for (x, y, lab) in (
    (0, 1.25, "r"),
    (-0.75, 0.5, "a"),
    (0.75, 0.5, "b"),
    (-1.15, -0.1, "c"),
    (-0.35, -0.1, "d"),
    (0.35, -0.1, "e"),
    (1.15, -0.1, "f"),
  ) {
    draw.circle(
      (x, y),
      radius: 0.14,
      fill: c-t-fill,
      stroke: (paint: c-t-border, thickness: 0.8pt),
      name: lab,
    )
    draw.content((x, y))[#text(size: 0.5em, weight: "bold")[#lab]]
  }
  for (x, y, lab) in ((-1.35, -0.75, "g"), (-0.6, -0.75, "h"), (0.1, -0.75, "i")) {
    draw.circle(
      (x, y),
      radius: 0.14,
      fill: none,
      stroke: (paint: c-t-border, thickness: 0.8pt),
      name: lab,
    )
    draw.content((x, y))[#text(size: 0.5em, fill: c-t-leaf)[#lab]]
  }
  // Edges : node names
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
    e(a, b, stroke: (paint: c-t-border, thickness: 1pt))
  }
})

// ── Bridges of Königsberg ──
#let eulerian = canvas({
  let v = ((0, 1.1), (0, -1.1), (-1, 0), (1, 0))
  let names = ("A", "B", "C", "D")
  let r = 0.26

  // Point on circle border in direction of `toward`
  let rim(center, toward) = {
    let (cx, cy) = center
    let (tx, ty) = toward
    let d = calc.sqrt((tx - cx) * (tx - cx) + (ty - cy) * (ty - cy))
    (cx + (tx - cx) / d * r, cy + (ty - cy) / d * r)
  }

  // Landmasses : circles, named
  for (i, p) in v.enumerate() {
    draw.circle(
      p,
      radius: r,
      fill: c-pa-fill,
      stroke: (paint: c-pa-dot, thickness: 1pt),
      name: names.at(i),
    )
    draw.content(p)[#text(size: 0.5em, weight: "bold")[#names.at(i)]]
  }

  let bridge-style = (paint: c-edge, thickness: 0.7pt)

  // Single bridges (straight, node-based)
  draw.line("A", "D", stroke: bridge-style)
  draw.line("B", "D", stroke: bridge-style)
  draw.line("C", "D", stroke: bridge-style)

  // Double bridge A--C: one straight, one bezier curving outward (left)
  draw.line("A", "C", stroke: bridge-style)
  let ac-ctrl = (-0.65, 0.65)
  draw.bezier(
    rim(v.at(0), ac-ctrl),
    rim(v.at(2), ac-ctrl),
    ac-ctrl,
    ac-ctrl,
    stroke: bridge-style,
  )

  // Double bridge B--C: one straight, one bezier curving outward (left)
  draw.line("B", "C", stroke: bridge-style)
  let bc-ctrl = (-0.65, -0.65)
  draw.bezier(
    rim(v.at(1), bc-ctrl),
    rim(v.at(2), bc-ctrl),
    bc-ctrl,
    bc-ctrl,
    stroke: bridge-style,
  )

  // Degree labels
  draw.content(
    "A",
    anchor: "north",
    outset: 0.3em,
    size: .4em,
    fill: c-edge-dim,
  )[$3$]
  draw.content(
    "B",
    anchor: "south",
    outset: 0.3em,
    size: .4em,
    fill: c-edge-dim,
  )[$3$]
  draw.content(
    "C",
    anchor: "west",
    outset: 0.3em,
    size: .4em,
    fill: c-edge-dim,
  )[$5$]
  draw.content(
    "D",
    anchor: "east",
    outset: 0.3em,
    size: .4em,
    fill: c-edge-dim,
  )[$3$]
})

// ── Planar graph (triangulated hexagon) ──
#let planar = canvas({
  let v = (
    (0, 1.25),
    (1.2, 0.65),
    (1.2, -0.65),
    (0, -1.25),
    (-1.2, -0.65),
    (-1.2, 0.65),
  )
  // Nodes FIRST
  for (i, p) in v.enumerate() { node(p, str(i + 1), radius: 0.15) }
  // Outer cycle
  e("1", "2")
  e("2", "3")
  e("3", "4")
  e("4", "5")
  e("5", "6")
  e("6", "1")
  // Diagonals from vertex 1 : all share endpoint 1, so none cross
  e("1", "3")
  e("1", "4")
  e("1", "5")
  // Face labels
  for (p, lab) in (
    ((0.6, 0.6), $f_1$),
    ((0.9, 0), $f_2$),
    ((0.6, -0.6), $f_3$),
    ((-0.25, -0.5), $f_4$),
    ((-0.75, 0), $f_5$),
  ) {
    draw.content(p, lab, size: .4em, fill: c-edge-dim)
  }
})

// ── Graph colouring (C5, χ = 3) ──
#let graph-coloring = canvas({
  let v = (
    (0, 1),
    (-0.951, 0.309),
    (-0.588, -0.809),
    (0.588, -0.809),
    (0.951, 0.309),
  )
  // 3-colouring: 0=red, 1=green, 0=red, 1=green, 2=blue
  let ci = (0, 1, 0, 1, 2)
  // Nodes : content inside a coloured circle frame
  for (i, p) in v.enumerate() {
    let col = c-colors.at(ci.at(i))
    draw.content(
      p,
      [#text(size: 0.5em, weight: "bold")[#str(i)]],
      frame: "circle",
      radius: 0.21,
      fill: col,
      stroke: col.darken(20%),
      name: "c" + str(i),
    )
  }
  // Edges : pentagon cycle
  for i in range(5) {
    e("c" + str(i), "c" + str(calc.rem(i + 1, 5)))
  }
  // Chromatic number
  draw.content(
    (0, -1.15),
    anchor: "north",
    size: .4em,
    fill: c-edge-dim,
  )[$chi = 3$]
})

// ── Bridge and cut-vertex ──
#let bridge-cut = canvas({
  let v = (
    (-0.75, 0.75),
    (0, 0.75),
    (0.75, 0.75),
    (-0.75, -0.25),
    (0, -0.25),
    (0.75, -0.25),
  )
  // Nodes FIRST
  for (i, p) in v.enumerate() { snode(p, str(i + 1)) }
  // Left component: {1, 4, 5}
  draw.line("1", "4", stroke: (paint: c-edge, thickness: 0.8pt))
  draw.line("4", "5", stroke: (paint: c-edge, thickness: 0.8pt))
  draw.line("1", "5", stroke: (paint: c-edge, thickness: 0.8pt))
  // Right component: {2, 3, 6}
  draw.line("2", "3", stroke: (paint: c-edge, thickness: 0.8pt))
  draw.line("3", "6", stroke: (paint: c-edge, thickness: 0.8pt))
  draw.line("2", "6", stroke: (paint: c-edge, thickness: 0.8pt))
  // Bridge : the only edge connecting left and right components
  draw.line("1", "2", stroke: (paint: c-hi, thickness: 2.2pt))
})

// ── Petersen graph ──
#let petersen = canvas({
  let outer = ((0, 1.25), (1.2, 0.4), (0.75, -1), (-0.75, -1), (-1.2, 0.4))
  let inner = (
    (0, 0.6),
    (0.575, 0.185),
    (0.36, -0.49),
    (-0.36, -0.49),
    (-0.575, 0.185),
  )
  // Nodes FIRST
  for (i, p) in outer.enumerate() { snode(p, str(i + 1)) }
  for (i, p) in inner.enumerate() { snode(p, str(6 + i)) }
  // Edges : node names
  e("1", "2")
  e("2", "3")
  e("3", "4")
  e("4", "5")
  e("5", "1")
  e("6", "8")
  e("7", "9")
  e("8", "10")
  e("9", "6")
  e("10", "7")
  for i in range(5) {
    e(str(i + 1), str(6 + i))
  }
})

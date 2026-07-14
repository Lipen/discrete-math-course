// M12 Graph diagrams — CeTZ 0.5.2, node-based.
// Light fills + dark text = good contrast for screen and print.
#import "@preview/cetz:0.5.2"

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
#let node(pos, label, radius: 0.3) = {
  import cetz.draw: circle, content
  circle(
    pos,
    radius: radius,
    fill: c-n-fill,
    stroke: (paint: c-n-border, thickness: 0.8pt),
    name: label,
  )
  content(pos)[#text(fill: c-n-text, weight: "bold")[#label]]
}

#let snode(pos, label) = { node(pos, label, radius: 0.2) }

// ── 1. Simple undirected graph ──
#let simple-graph = cetz.canvas({
  import cetz.draw: line
  let v = ((0, 2), (1.5, 2), (3, 2), (0.8, 0.5), (2.3, 0.5), (1.5, -1))
  for (i, p) in v.enumerate() { node(p, str(i + 1)) }
  line("2", "1")
  line("3", "2")
  line("1", "4")
  line("2", "4")
  line("2", "5")
  line("3", "5")
  line("4", "5")
  line("4", "6")
  line("5", "6")
})

// ── 2. K_5 ──
#let k5 = cetz.canvas({
  import cetz.draw: line
  let v = ((0, 2.5), (2.4, 0.8), (1.5, -2), (-1.5, -2), (-2.4, 0.8))
  for (i, p) in v.enumerate() { snode(p, str(i + 1)) }
  for i in range(5) {
    for j in range(i + 1, 5) {
      line(str(i + 1), str(j + 1), stroke: (paint: c-edge, thickness: 0.35pt))
    }
  }
})

// ── 3. K_{3,3} ──
#let k33 = cetz.canvas({
  import cetz.draw: *
  let left = ((0, 2), (0, 0), (0, -2))
  let right = ((4, 2), (4, 0), (4, -2))
  // Background regions
  rect((-0.6, 2.5), (0.6, -2.5), radius: 6pt, fill: c-pa-fill, stroke: none)
  rect((3.4, 2.5), (4.6, -2.5), radius: 6pt, fill: c-pb-fill, stroke: none)
  // Nodes FIRST — named so line() routes border-to-border
  // Labels placed outside (anchor: "west"/"east") since nodes are small dots.
  for (i, p) in left.enumerate() {
    circle(p, radius: 0.2, fill: c-pa-dot, name: "l" + str(i + 1))
    content(p, $v_i$, anchor: "west", outset: 0.3em, size: .8em)
  }
  for (i, p) in right.enumerate() {
    circle(p, radius: 0.2, fill: c-pb-dot, name: "r" + str(i + 1))
    content(p, $u_i$, anchor: "east", outset: 0.3em, size: .8em)
  }
  // Edges — node names, not coordinates
  for i in range(3) {
    for j in range(3) {
      line("l" + str(i + 1), "r" + str(j + 1), stroke: (
        paint: c-edge,
        thickness: 0.35pt,
      ))
    }
  }
  content((0, 2.6), anchor: "south")[$X$]
  content((4, 2.6), anchor: "south")[$Y$]
})

// ── 4. Bipartite graph ──
#let bipartite = cetz.canvas({
  import cetz.draw: *
  let top = ((-1, 1.5), (0.5, 1.5), (2, 1.5))
  let bot = ((-1, -1.5), (0.5, -1.5), (2, -1.5))
  // Background regions
  rect((-1.8, 2.2), (2.8, 0.8), radius: 5pt, fill: c-pa-fill, stroke: none)
  rect((-1.8, -0.8), (2.8, -2.2), radius: 5pt, fill: c-pb-fill, stroke: none)
  // Nodes FIRST
  for (i, p) in top.enumerate() {
    circle(p, radius: 0.3, fill: c-pa-dot, name: "t" + str(i + 1))
  }
  for (i, p) in bot.enumerate() {
    circle(p, radius: 0.3, fill: c-pb-dot, name: "b" + str(i + 1))
  }
  // Edges — node names
  line("t1", "b1")
  line("t1", "b2")
  line("t2", "b1")
  line("t2", "b2")
  line("t2", "b3")
  line("t3", "b2")
  line("t3", "b3")
  content((-2.2, 1.5), anchor: "east")[$X$]
  content((-2.2, -1.5), anchor: "east")[$Y$]
})

// ── 5. Rooted tree ──
#let tree = cetz.canvas({
  import cetz.draw: *
  // Nodes FIRST — each named by its label letter
  for (x, y, lab) in (
    (0, 2.5, "r"),
    (-1.5, 1, "a"),
    (1.5, 1, "b"),
    (-2.3, -0.2, "c"),
    (-0.7, -0.2, "d"),
    (0.7, -0.2, "e"),
    (2.3, -0.2, "f"),
  ) {
    circle(
      (x, y),
      radius: 0.2,
      fill: c-t-fill,
      stroke: (paint: c-t-border, thickness: 0.8pt),
      name: lab,
    )
    content((x, y))[#text(weight: "bold")[#lab]]
  }
  for (x, y, lab) in ((-2.7, -1.5, "g"), (-1.2, -1.5, "h"), (0.2, -1.5, "i")) {
    circle((x, y), radius: 0.2, fill: none, stroke: c-t-border, name: lab)
    content((x, y))[#text(fill: c-t-leaf)[#lab]]
  }
  // Edges — node names
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
    line(a, b, stroke: (paint: c-t-border, thickness: 1pt))
  }
})

// ── 6. Weighted graph + MST ──
#let spanning-tree = cetz.canvas({
  import cetz.draw: *
  let v = ((0, 2.5), (-2, 0.5), (2, 0.5), (-1.5, -1.5), (1.5, -1.5))
  // Nodes FIRST
  for (i, p) in v.enumerate() { node(p, str(i + 1), radius: 0.25) }
  // Thin edges with weight labels — each edge has a `rel:` offset to place the label beside (not on) the line.
  // Offsets are perpendicular to the edge direction.
  for (ai, bi, w, off) in (
    (0, 1, "4", (-0.18, 0.12)),
    (0, 2, "3", (0.18, 0.12)),
    (1, 2, "5", (0, 0.22)),
    (1, 3, "2", (-0.25, -0.05)),
    (2, 4, "6", (0.25, -0.05)),
    (3, 4, "7", (0, -0.22)),
    (1, 4, "8", (0.12, 0.18)),
  ) {
    let aname = str(ai + 1)
    let bname = str(bi + 1)
    let ename = aname + "-" + bname
    line(aname, bname, stroke: (paint: c-edge, thickness: 0.7pt), name: ename)
    content(
      (rel: off, to: ename + ".mid"),
      w,
      frame: "rect",
      fill: white,
      stroke: none,
      padding: 1pt,
      size: .65em,
    )
  }
  // MST highlight (bold) — node names
  for (a, b) in (("1", "3"), ("1", "2"), ("2", "4"), ("3", "5")) {
    line(a, b, stroke: (paint: c-t-border, thickness: 2.5pt))
  }
})

// ── 7. Bridges of Königsberg ──
// Diamond layout: A (north bank), B (south bank), C and D (islands).
// Real topology: A=3, B=3, C=5, D=3 — C (Kneiphof) has 5 bridges.
#let eulerian = cetz.canvas({
  import cetz.draw: *
  let v = ((0, 2.2), (0, -2.2), (-2, 0), (2, 0))
  let names = ("A", "B", "C", "D")
  let r = 0.42

  // Point on circle border in direction of `toward`
  let rim(center, toward) = {
    let (cx, cy) = center
    let (tx, ty) = toward
    let d = calc.sqrt((tx - cx) * (tx - cx) + (ty - cy) * (ty - cy))
    (cx + (tx - cx) / d * r, cy + (ty - cy) / d * r)
  }

  // Landmasses — circles, named
  for (i, p) in v.enumerate() {
    circle(
      p,
      radius: r,
      fill: c-pa-fill,
      stroke: (paint: c-pa-dot, thickness: 1pt),
      name: names.at(i),
    )
    content(p)[#text(weight: "bold")[#names.at(i)]]
  }

  let bridge-style = (paint: c-edge, thickness: 0.7pt)

  // Single bridges (straight, node-based)
  line("A", "D", stroke: bridge-style)
  line("B", "D", stroke: bridge-style)
  line("C", "D", stroke: bridge-style)

  // Double bridge A–C: one straight, one bezier curving outward (left)
  line("A", "C", stroke: bridge-style)
  let ac-ctrl = (-1.3, 1.3)
  bezier(
    rim(v.at(0), ac-ctrl),
    rim(v.at(2), ac-ctrl),
    ac-ctrl,
    ac-ctrl,
    stroke: bridge-style,
  )

  // Double bridge B–C: one straight, one bezier curving outward (left)
  line("B", "C", stroke: bridge-style)
  let bc-ctrl = (-1.3, -1.3)
  bezier(
    rim(v.at(1), bc-ctrl),
    rim(v.at(2), bc-ctrl),
    bc-ctrl,
    bc-ctrl,
    stroke: bridge-style,
  )

  // Degree labels — positioned outside each node via named anchors
  content(
    "A",
    anchor: "south",
    outset: 0.6em,
    size: .7em,
    fill: c-edge-dim,
  )[$3$]
  content(
    "B",
    anchor: "north",
    outset: 0.6em,
    size: .7em,
    fill: c-edge-dim,
  )[$3$]
  content("C", anchor: "east", outset: 0.6em, size: .7em, fill: c-edge-dim)[$5$]
  content("D", anchor: "west", outset: 0.6em, size: .7em, fill: c-edge-dim)[$3$]
})

// ── 8. Planar graph ──
#let planar = cetz.canvas({
  import cetz.draw: *
  let v = (
    (0, 2.5),
    (2.4, 1.3),
    (2.4, -1.3),
    (0, -2.5),
    (-2.4, -1.3),
    (-2.4, 1.3),
  )
  // Nodes FIRST
  for (i, p) in v.enumerate() { node(p, str(i + 1), radius: 0.22) }
  // Edges — node names
  line("1", "2")
  line("2", "3")
  line("3", "4")
  line("4", "5")
  line("5", "6")
  line("6", "1")
  line("1", "4")
  line("2", "5")
  line("3", "6")
  // Face labels
  for (p, lab) in (
    ((0, 1.2), $f_1$),
    ((1, 0), $f_2$),
    ((1, -0.9), $f_3$),
    ((0, -1.2), $f_4$),
    ((-1, -0.9), $f_5$),
    ((-1, 0), $f_6$),
  ) {
    content(p, lab, size: .7em, fill: c-edge-dim)
  }
})

// ── 9. Graph colouring (W_5) ──
#let graph-coloring = cetz.canvas({
  import cetz.draw: *
  let v = ((0, 1), (0, 2.5), (2.4, 0.8), (1.5, -2), (-1.5, -2), (-2.4, 0.8))
  let ci = (3, 0, 1, 0, 1, 2)
  // Nodes FIRST — named "n0".."n5"
  // content(..., frame: "circle") guarantees text is centered in the circle.
  for (i, p) in v.enumerate() {
    let c = c-colors.at(ci.at(i))
    let sz = if i == 0 { 0.38 } else { 0.3 }
    content(
      p,
      [#text(weight: "bold")[#str(i)]],
      frame: "circle",
      radius: sz,
      fill: c,
      stroke: c.darken(20%),
      name: "n" + str(i),
    )
  }
  // Edges — node names
  line("n1", "n2")
  line("n2", "n3")
  line("n3", "n4")
  line("n4", "n5")
  line("n5", "n1")
  line("n0", "n1")
  line("n0", "n2")
  line("n0", "n3")
  line("n0", "n4")
  line("n0", "n5")
})

// ── 10. Directed graph + SCC ──
#let directed-graph = cetz.canvas({
  import cetz.draw: *
  let v = ((0, 2.5), (2.5, 1), (2.5, -1), (0, -2.5), (-2.5, -1), (-2.5, 1))
  // Nodes FIRST
  for (i, p) in v.enumerate() { snode(p, str(i + 1)) }
  // Arrow style — spread pattern for clean reuse
  let arr = (mark: (end: "stealth"), stroke: (paint: c-edge, thickness: 0.7pt))
  // Edges — node names, CeTZ routes border-to-border
  line("1", "2", ..arr)
  line("2", "3", ..arr)
  line("3", "1", ..arr)
  line("1", "4", ..arr)
  line("4", "5", ..arr)
  line("5", "4", ..arr)
  line("6", "1", ..arr)
  line("2", "6", ..arr)
  // SCC regions (decorative — coordinate-based, no nodes involved)
  circle((0.8, 0.8), radius: 1.2, fill: none, stroke: (
    paint: c-pa-dot,
    thickness: 1.2pt,
    dash: "dashed",
  ))
  circle((-0.8, -1.8), radius: 0.9, fill: none, stroke: (
    paint: c-pb-dot,
    thickness: 1.2pt,
    dash: "dashed",
  ))
})

// ── 11. Petersen graph ──
#let petersen = cetz.canvas({
  import cetz.draw: *
  let outer = ((0, 2.5), (2.4, 0.8), (1.5, -2), (-1.5, -2), (-2.4, 0.8))
  let inner = (
    (0, 1.2),
    (1.15, 0.37),
    (0.72, -0.98),
    (-0.72, -0.98),
    (-1.15, 0.37),
  )
  // Nodes FIRST
  for (i, p) in outer.enumerate() { snode(p, str(i + 1)) }
  for (i, p) in inner.enumerate() { snode(p, str(6 + i)) }
  // Edges — node names
  line("1", "2")
  line("2", "3")
  line("3", "4")
  line("4", "5")
  line("5", "1")
  line("6", "8")
  line("7", "9")
  line("8", "10")
  line("9", "6")
  line("10", "7")
  for i in range(5) { line(str(i + 1), str(6 + i)) }
})

// ── 12. Bridge and cut-vertex ──
#let bridge-cut = cetz.canvas({
  import cetz.draw: *
  let v = (
    (-1.5, 1.5),
    (0, 1.5),
    (1.5, 1.5),
    (-1.5, -0.5),
    (0, -0.5),
    (1.5, -0.5),
  )
  // Nodes FIRST
  for (i, p) in v.enumerate() { snode(p, str(i + 1)) }
  // Edges — node names
  for (a, b) in (
    ("1", "4"),
    ("1", "5"),
    ("3", "5"),
    ("3", "6"),
    ("4", "5"),
    ("5", "6"),
  ) {
    line(a, b, stroke: (paint: c-edge, thickness: 0.8pt))
  }
  line("2", "3", stroke: (paint: c-edge, thickness: 0.8pt))
  // Bridge highlight (bold)
  line("1", "2", stroke: (paint: c-hi, thickness: 2.2pt))
  // Cut-vertex highlight circle (decorative — coordinate-based)
  circle(v.at(0), radius: 0.38, fill: none, stroke: (
    paint: c-hi,
    thickness: 1.8pt,
    dash: "dashed",
  ))
})

// ── 13. BFS tree ──
#let bfs-tree = cetz.canvas({
  import cetz.draw: *
  let v = (
    (0, 2.5),
    (-1.8, 1),
    (1.8, 1),
    (-2.8, -0.5),
    (-0.8, -0.5),
    (0.8, -0.5),
    (2.8, -0.5),
  )
  // Nodes FIRST
  for (i, p) in v.enumerate() {
    snode(p, str(i + 1))
    content(
      p,
      anchor: "north-east",
      outset: 0.25em,
      size: .55em,
      fill: c-edge-dim,
    )[
      $d!=!#((0, 1, 1, 2, 2, 2, 2).at(i))$
    ]
  }
  // All edges (dim) — node names
  for (a, b) in (
    ("1", "2"),
    ("1", "3"),
    ("2", "4"),
    ("2", "5"),
    ("3", "6"),
    ("3", "7"),
    ("4", "5"),
    ("6", "7"),
    ("2", "6"),
  ) {
    line(a, b, stroke: (paint: c-edge-dim, thickness: 0.25pt))
  }
  // BFS tree (bold) — node names
  for (a, b) in (
    ("1", "2"),
    ("1", "3"),
    ("2", "4"),
    ("2", "5"),
    ("3", "6"),
    ("3", "7"),
  ) {
    line(a, b, stroke: (paint: c-pa-dot, thickness: 2pt))
  }
})

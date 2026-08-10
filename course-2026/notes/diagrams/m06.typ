// M12 Graph diagrams : CeTZ 0.5.2, node-based.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

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
#let node(pos, label, radius: 0.38) = {
  draw.circle(
    pos,
    radius: radius,
    fill: c-n-fill,
    stroke: (paint: c-n-border, thickness: 0.8pt),
    name: label,
  )
  draw.content(pos)[#text(fill: c-n-text, weight: "bold")[#label]]
}

#let snode(pos, label) = { node(pos, label, radius: 0.28) }

// Edge helper: e("a", "b") --- styled edge. e("a", "b", stroke: ...) --- override.
#let e(a, b, ..style) = {
  draw.line(a, b, stroke: (paint: c-edge, thickness: 0.7pt), ..style)
}

// ── 1. Simple undirected graph ──
#let simple-graph = canvas({
  let v = ((0, 2), (1.5, 2), (3, 2), (0.8, 0.5), (2.3, 0.5), (1.5, -1))
  for (i, p) in v.enumerate() { node(p, str(i + 1)) }
  e("2", "1")
  e("3", "2")
  e("1", "4")
  e("2", "4")
  e("2", "5")
  e("3", "5")
  e("4", "5")
  e("4", "6")
  e("5", "6")
})

// ── 2. BFS grid (3×2) ──
#let bfs-grid = canvas({
  let rows = ((0, 0), (1.5, 0), (3.0, 0), (0, -1.5), (1.5, -1.5), (3.0, -1.5))
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

// ── 3. K_5 ──
#let k5 = canvas({
  let v = ((0, 2.5), (2.4, 0.8), (1.5, -2), (-1.5, -2), (-2.4, 0.8))
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

// ── 3. K_{3,3} ──
#let k33 = canvas({
  let left = ((0, 2), (0, 0), (0, -2))
  let right = ((4, 2), (4, 0), (4, -2))
  // Background regions
  draw.rect(
    (-0.6, 2.5),
    (0.6, -2.5),
    radius: 6pt,
    fill: c-pa-fill,
    stroke: none,
  )
  draw.rect((3.4, 2.5), (4.6, -2.5), radius: 6pt, fill: c-pb-fill, stroke: none)
  // Nodes FIRST : named so line() routes border-to-border
  // Labels placed outside (anchor: "west"/"east") since nodes are small dots.
  for (i, p) in left.enumerate() {
    draw.circle(p, radius: 0.28, fill: c-pa-dot, name: "l" + str(i + 1))
    draw.content(p, $v_i$, anchor: "west", outset: 0.3em, size: .8em)
  }
  for (i, p) in right.enumerate() {
    draw.circle(p, radius: 0.28, fill: c-pb-dot, name: "r" + str(i + 1))
    draw.content(p, $u_i$, anchor: "east", outset: 0.3em, size: .8em)
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
  draw.content((0, 2.6), anchor: "south")[$X$]
  draw.content((4, 2.6), anchor: "south")[$Y$]
})

// ── 4. Bipartite graph ──
#let bipartite = canvas({
  let top = ((-1, 1.5), (0.5, 1.5), (2, 1.5))
  let bot = ((-1, -1.5), (0.5, -1.5), (2, -1.5))
  // Background regions
  draw.rect((-1.8, 2.2), (2.8, 0.8), radius: 5pt, fill: c-pa-fill, stroke: none)
  draw.rect(
    (-1.8, -0.8),
    (2.8, -2.2),
    radius: 5pt,
    fill: c-pb-fill,
    stroke: none,
  )
  // Nodes FIRST
  for (i, p) in top.enumerate() {
    draw.circle(p, radius: 0.38, fill: c-pa-dot, name: "t" + str(i + 1))
  }
  for (i, p) in bot.enumerate() {
    draw.circle(p, radius: 0.38, fill: c-pb-dot, name: "b" + str(i + 1))
  }
  // Edges : node names
  e("t1", "b1")
  e("t1", "b2")
  e("t2", "b1")
  e("t2", "b2")
  e("t2", "b3")
  e("t3", "b2")
  e("t3", "b3")
  draw.content((-2.2, 1.5), anchor: "east")[$X$]
  draw.content((-2.2, -1.5), anchor: "east")[$Y$]
})

// ── 5. Rooted tree ──
#let tree = canvas({
  // Nodes FIRST : each named by its label letter
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
      fill: c-t-fill,
      stroke: (paint: c-t-border, thickness: 0.8pt),
      name: lab,
    )
    draw.content((x, y))[#text(weight: "bold")[#lab]]
  }
  for (x, y, lab) in ((-2.7, -1.5, "g"), (-1.2, -1.5, "h"), (0.2, -1.5, "i")) {
    draw.circle(
      (x, y),
      radius: 0.28,
      fill: none,
      stroke: (paint: c-t-border, thickness: 0.8pt),
      name: lab,
    )
    draw.content((x, y))[#text(fill: c-t-leaf)[#lab]]
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

// ── 6. Weighted graph + MST ──
#let spanning-tree = canvas({
  let v = ((0, 2.5), (-2, 0.5), (2, 0.5), (-1.5, -1.5), (1.5, -1.5))
  // Nodes FIRST
  for (i, p) in v.enumerate() { node(p, str(i + 1), radius: 0.33) }
  // Thin edges with weight labels : each edge has a `rel:` offset to place the label beside (not on) the line.
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
    draw.line(
      aname,
      bname,
      stroke: (paint: c-edge, thickness: 0.7pt),
      name: ename,
    )
    draw.content(
      (rel: off, to: ename + ".mid"),
      w,
      frame: "rect",
      fill: white,
      stroke: none,
      padding: 1pt,
      size: .65em,
    )
  }
  // MST highlight (bold) : node names
  for (a, b) in (("1", "3"), ("1", "2"), ("2", "4"), ("3", "5")) {
    draw.line(a, b, stroke: (paint: c-t-border, thickness: 2.5pt))
  }
})

// ── 7. Bridges of Königsberg ──
// Diamond layout: A (north bank), B (south bank), C and D (islands).
// Real topology: A=3, B=3, C=5, D=3 : C (Kneiphof) has 5 bridges.
#let eulerian = canvas({
  let v = ((0, 2.2), (0, -2.2), (-2, 0), (2, 0))
  let names = ("A", "B", "C", "D")
  let r = 0.52

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
    draw.content(p)[#text(weight: "bold")[#names.at(i)]]
  }

  let bridge-style = (paint: c-edge, thickness: 0.7pt)

  // Single bridges (straight, node-based)
  draw.line("A", "D", stroke: bridge-style)
  draw.line("B", "D", stroke: bridge-style)
  draw.line("C", "D", stroke: bridge-style)

  // Double bridge A--C: one straight, one bezier curving outward (left)
  draw.line("A", "C", stroke: bridge-style)
  let ac-ctrl = (-1.3, 1.3)
  draw.bezier(
    rim(v.at(0), ac-ctrl),
    rim(v.at(2), ac-ctrl),
    ac-ctrl,
    ac-ctrl,
    stroke: bridge-style,
  )

  // Double bridge B--C: one straight, one bezier curving outward (left)
  draw.line("B", "C", stroke: bridge-style)
  let bc-ctrl = (-1.3, -1.3)
  draw.bezier(
    rim(v.at(1), bc-ctrl),
    rim(v.at(2), bc-ctrl),
    bc-ctrl,
    bc-ctrl,
    stroke: bridge-style,
  )

  // Degree labels : positioned outside each node via named anchors
  draw.content(
    "A",
    anchor: "north",
    outset: 0.6em,
    size: .7em,
    fill: c-edge-dim,
  )[$3$]
  draw.content(
    "B",
    anchor: "south",
    outset: 0.6em,
    size: .7em,
    fill: c-edge-dim,
  )[$3$]
  draw.content(
    "C",
    anchor: "west",
    outset: 0.6em,
    size: .7em,
    fill: c-edge-dim,
  )[$5$]
  draw.content(
    "D",
    anchor: "east",
    outset: 0.6em,
    size: .7em,
    fill: c-edge-dim,
  )[$3$]
})

// ── 8. Planar graph ──
// Triangulated hexagon : all diagonals from vertex 1, no crossings.
// V=6, E=9, F=5 (4 inner triangular faces + 1 outer face). 6-9+5=2.
#let planar = canvas({
  let v = (
    (0, 2.5),
    (2.4, 1.3),
    (2.4, -1.3),
    (0, -2.5),
    (-2.4, -1.3),
    (-2.4, 1.3),
  )
  // Nodes FIRST
  for (i, p) in v.enumerate() { node(p, str(i + 1), radius: 0.3) }
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
  // Face labels : 5 faces: f_1..f_4 inside, f_5 outside
  for (p, lab) in (
    ((1.2, 1.2), $f_1$),
    ((1.8, 0), $f_2$),
    ((1.2, -1.2), $f_3$),
    ((-0.5, -1), $f_4$),
    ((-1.5, 0), $f_5$),
  ) {
    draw.content(p, lab, size: .7em, fill: c-edge-dim)
  }
})

// ── 9. Graph colouring (C5, χ = 3) ──
// Odd cycle: 5 vertices need 3 colours.  4 vertices alternate red-green;
// the 5th is adjacent to one red and one green → needs blue.
#let graph-coloring = canvas({
  import draw: *
  let v = (
    (0, 2),
    (-1.902, 0.618),
    (-1.176, -1.618),
    (1.176, -1.618),
    (1.902, 0.618),
  )
  // 3-colouring: 0=red, 1=green, 0=red, 1=green, 2=blue
  let ci = (0, 1, 0, 1, 2)
  // Nodes : content inside a coloured circle frame, named "c0".."c4"
  for (i, p) in v.enumerate() {
    let col = c-colors.at(ci.at(i))
    draw.content(
      p,
      [#text(weight: "bold")[#str(i)]],
      frame: "circle",
      radius: 0.42,
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
    (0, -2.3),
    anchor: "north",
    size: .8em,
    fill: c-edge-dim,
  )[$chi = 3$]
})

// ── 10. Directed graph + SCC ──
#let directed-graph = canvas({
  let v = ((0, 2.5), (2.5, 1), (2.5, -1), (0, -2.5), (-2.5, -1), (-2.5, 1))
  // Nodes FIRST
  for (i, p) in v.enumerate() { snode(p, str(i + 1)) }
  // Arrow style : spread pattern for clean reuse
  let arr = (mark: (end: "stealth"), stroke: (paint: c-edge, thickness: 0.7pt))
  // Edges : node names, CeTZ routes border-to-border
  draw.line("1", "2", ..arr)
  draw.line("2", "3", ..arr)
  draw.line("3", "1", ..arr)
  draw.line("1", "4", ..arr)
  draw.line("4", "5", ..arr)
  draw.line("5", "4", ..arr)
  draw.line("6", "1", ..arr)
  draw.line("2", "6", ..arr)
  // SCC regions (decorative : coordinate-based, no nodes involved)
  draw.circle((0, 0.75), radius: 3.1, fill: none, stroke: (
    paint: c-pa-dot,
    thickness: 1.2pt,
    dash: "dashed",
  ))
  draw.circle((-1.2, -1.8), radius: 1.6, fill: none, stroke: (
    paint: c-pb-dot,
    thickness: 1.2pt,
    dash: "dashed",
  ))
})

// ── 11. Petersen graph ──
#let petersen = canvas({
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

// ── 12. Bridge and cut-vertex ──
// Left component {1,4,5} and right component {2,3,6} connected ONLY by bridge (1,2).
// Removing (1,2) disconnects the graph. Vertex 1 is a cut-vertex.
#let bridge-cut = canvas({
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
  // Cut-vertex highlight circle (decorative : coordinate-based)
  draw.circle(v.at(0), radius: 0.38, fill: none, stroke: (
    paint: c-hi,
    thickness: 1.8pt,
    dash: "dashed",
  ))
})

// ── 13. BFS tree ──
// Bold straight lines = BFS tree. Dashed bezier arcs = cross/skip edges.
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
  let r = 0.33 // node radius (matches node() call below)

  // Point on circle border
  let rim(center, toward) = {
    let (cx, cy) = center
    let (tx, ty) = toward
    let d = calc.sqrt((tx - cx) * (tx - cx) + (ty - cy) * (ty - cy))
    (cx + (tx - cx) / d * r, cy + (ty - cy) / d * r)
  }

  // Nodes FIRST
  let anchors = ("north", "west", "east", "south", "south", "south", "south")
  for (i, p) in v.enumerate() {
    node(p, str(i + 1), radius: 0.33)
    draw.content(
      p,
      anchor: anchors.at(i),
      outset: 0.55em,
      size: .55em,
      fill: c-edge-dim,
    )[
      $d!=!#((0, 1, 1, 2, 2, 2, 2).at(i))$
    ]
  }

  let cross-style = (paint: c-edge-dim, thickness: 0.35pt, dash: "dashed")

  // Cross edges : dashed bezier arcs curving away from the tree
  // (4,5): siblings under 2 : arc below
  draw.bezier(
    rim(v.at(3), (0, -1.5)),
    rim(v.at(4), (0, -1.5)),
    (-2.8, -1.5),
    (-0.8, -1.5),
    stroke: cross-style,
  )
  // (6,7): siblings under 3 : arc below
  draw.bezier(
    rim(v.at(5), (0, -1.5)),
    rim(v.at(6), (0, -1.5)),
    (0.8, -1.5),
    (2.8, -1.5),
    stroke: cross-style,
  )
  // (2,6): cross between subtrees : arc to the right, outside the tree
  draw.bezier(
    rim(v.at(1), (1.8, -0.8)),
    rim(v.at(5), (1.8, -0.8)),
    (1.8, 0.2),
    (1.8, -1.3),
    stroke: cross-style,
  )

  // BFS tree edges : bold straight lines
  for (a, b) in (
    ("1", "2"),
    ("1", "3"),
    ("2", "4"),
    ("2", "5"),
    ("3", "6"),
    ("3", "7"),
  ) {
    draw.line(a, b, stroke: (paint: c-pa-dot, thickness: 2pt))
  }
})

// ── 14. Euler cycle (figure-8: two triangles sharing vertex B) ──
// All degrees even: A=2, C=2, D=2, E=2, B=4.
// Cycle: B→A→C→B→D→E→B --- each edge used exactly once.
#let euler-cycle = canvas({
  // Node positions
  let pos = ((0, 1.5), (1, 0), (2, 1.5), (0, -1.5), (2, -1.5))
  let labs = ("A", "B", "C", "D", "E")

  for (i, p) in pos.enumerate() { node(p, labs.at(i), radius: 0.33) }

  // Euler cycle path: edge pairs + offset for circled number placement
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
    draw.line(
      a,
      b,
      stroke: (paint: c-pa-dot, thickness: 1.2pt),
      name: ename,
    )
    // Circled step number at edge midpoint
    let pt = (rel: off, to: ename + ".mid")
    draw.circle(pt, radius: 0.23, fill: white, stroke: (
      paint: c-pa-dot,
      thickness: 0.7pt,
    ))
    draw.content(pt, str(i + 1), size: .58em)
  }
})

// ── 15. Bipartite graph with maximum matching ──
// Left part L: 3 vertices,  Right part R: 3 vertices.
// Matching (bold): L1-R1, L2-R2, L3-R3.  Non-matching (thin): L1-R2, L2-R3.
#let bipartite-matching = canvas({
  let ly = (0, 1.5, 3)
  let ry = (0, 1.5, 3)
  let xl = 0
  let xr = 4

  // Background regions
  draw.rect(
    (-0.6, 3.5),
    (0.6, -0.5),
    radius: 6pt,
    fill: c-pa-fill,
    stroke: none,
  )
  draw.rect((3.4, 3.5), (4.6, -0.5), radius: 6pt, fill: c-pb-fill, stroke: none)

  // Nodes
  for (i, y) in ly.enumerate() {
    draw.circle((xl, y), radius: 0.38, fill: c-pa-dot, name: "L" + str(i + 1))
    draw.content(
      (xl, y),
      $x_#(i + 1)$,
      anchor: "east",
      outset: 0.4em,
      size: .85em,
    )
  }
  for (i, y) in ry.enumerate() {
    draw.circle((xr, y), radius: 0.38, fill: c-pb-dot, name: "R" + str(i + 1))
    draw.content(
      (xr, y),
      $y_#(i + 1)$,
      anchor: "west",
      outset: 0.4em,
      size: .85em,
    )
  }

  // Non-matching edges : thin, dimmed
  draw.line("L1", "R2", stroke: (paint: c-edge-dim, thickness: 0.7pt))
  draw.line("L2", "R3", stroke: (paint: c-edge-dim, thickness: 0.7pt))

  // Matching edges : thick, highlighted
  draw.line("L1", "R1", stroke: (paint: c-t-border, thickness: 2.5pt))
  draw.line("L2", "R2", stroke: (paint: c-t-border, thickness: 2.5pt))
  draw.line("L3", "R3", stroke: (paint: c-t-border, thickness: 2.5pt))

  // Partition labels
  draw.content((0, 3.6), anchor: "south")[$X$]
  draw.content((4, 3.6), anchor: "south")[$Y$]
})

// ── 16. Dijkstra counterexample with negative edge ──
// S→A (weight 3), S→B (weight 2), A→B (weight −2).
// Intuition: Dijkstra fixes B at distance 2 before the negative edge can shorten it.
#let dijkstra-counterexample = canvas({
  import draw: *
  let c-neg = oklch(58%, 0.22, 22deg) // red highlight for negative edge

  // Node positions
  node((0, 0), "S")
  node((3, 1.8), "A")
  node((3, -1.8), "B")

  let arr = (mark: (end: "stealth"))

  // Edge S→A : weight 3
  draw.line(
    "S",
    "A",
    stroke: (paint: c-edge, thickness: 0.7pt),
    ..arr,
    name: "sa",
  )
  draw.content((rel: (-0.05, 0.2), to: "sa.mid"), $3$, size: .65em)

  // Edge S→B : weight 2
  draw.line(
    "S",
    "B",
    stroke: (paint: c-edge, thickness: 0.7pt),
    ..arr,
    name: "sb",
  )
  draw.content((rel: (-0.05, -0.2), to: "sb.mid"), $2$, size: .65em)

  // Edge A→B : weight −2 (negative, red, dashed)
  draw.line(
    "A",
    "B",
    stroke: (
      paint: c-neg,
      thickness: 1pt,
      dash: "dashed",
    ),
    ..arr,
    name: "ab",
  )
  draw.content((rel: (0.22, 0), to: "ab.mid"), $-2$, size: .65em, fill: c-neg)
})

// M12 Graph diagrams — CeTZ 0.5.2, node-based.
// Design: restrained palette, visual clarity, captions do the explaining.
#import "@preview/cetz:0.5.2"

// ── Palette (oklch, 5 semantic roles) ──
#let c-node = oklch(55%, 0.14, 255deg)   // primary: nodes
#let c-edge = oklch(35%, 0.02, 265deg)   // edges
#let c-hi = oklch(58%, 0.22, 22deg)    // highlight (bridges, cuts)
#let c-tree = oklch(55%, 0.19, 160deg)   // trees, spanning, MST
#let c-pa = oklch(65%, 0.10, 245deg)   // partition A
#let c-pb = oklch(65%, 0.12, 45deg)    // partition B
#let c-grey = oklch(60%, 0.01, 260deg)   // muted / secondary edges
#let c-white = oklch(100%, 0, 0deg)

// ── Helpers (re-import cetz.draw inside) ──
#let node(pos, label, radius: 0.3, fill: c-node) = {
  import cetz.draw: circle, content
  circle(pos, radius: radius, fill: fill, stroke: none, name: label)
  content(label + ".center", fill: c-white)[#text(weight: "bold")[#label]]
}

#let snode(pos, label) = { node(pos, label, radius: 0.2) }

#let wedge(a, b, w) = {
  import cetz.draw: content, line
  line(a, b, stroke: (paint: c-edge, thickness: 0.7pt))
  let mid = ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2)
  content(mid, fill: c-white, outset: 2pt, size: .65em)[#w]
}

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

// ── 2. K_5 (complete, non-planar) ──
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
  rect(
    (-0.6, 2.5),
    (0.6, -2.5),
    radius: 6pt,
    fill: c-pa.lighten(88%),
    stroke: none,
  )
  rect(
    (3.4, 2.5),
    (4.6, -2.5),
    radius: 6pt,
    fill: c-pb.lighten(88%),
    stroke: none,
  )
  for l in left {
    for r in right {
      line(l, r, stroke: (paint: c-edge, thickness: 0.35pt))
    }
  }
  for p in left {
    circle(p, radius: 0.15, fill: c-pa)
    content(p)[$v_i$]
  }
  for p in right {
    circle(p, radius: 0.15, fill: c-pb)
    content(p)[$u_i$]
  }
  content((0, 2.6), anchor: "south")[$X$]
  content((4, 2.6), anchor: "south")[$Y$]
})

// ── 4. Bipartite graph ──
#let bipartite = cetz.canvas({
  import cetz.draw: *
  let top = ((-1, 1.5), (0.5, 1.5), (2, 1.5))
  let bot = ((-1, -1.5), (0.5, -1.5), (2, -1.5))
  rect(
    (-1.8, 2.2),
    (2.8, 0.8),
    radius: 5pt,
    fill: c-pa.lighten(88%),
    stroke: none,
  )
  rect(
    (-1.8, -0.8),
    (2.8, -2.2),
    radius: 5pt,
    fill: c-pb.lighten(88%),
    stroke: none,
  )
  for p in top { circle(p, radius: 0.3, fill: c-pa) }
  for p in bot { circle(p, radius: 0.3, fill: c-pb) }
  line(top.at(0), bot.at(0))
  line(top.at(0), bot.at(1))
  line(top.at(1), bot.at(0))
  line(top.at(1), bot.at(1))
  line(top.at(1), bot.at(2))
  line(top.at(2), bot.at(1))
  line(top.at(2), bot.at(2))
  content((-2.2, 1.5), anchor: "east")[$X$]
  content((-2.2, -1.5), anchor: "east")[$Y$]
})

// ── 5. Rooted tree ──
#let tree = cetz.canvas({
  import cetz.draw: *
  let es = (
    (0, 2.5, -1.5, 1),
    (0, 2.5, 1.5, 1),
    (-1.5, 1, -2.3, -0.2),
    (-1.5, 1, -0.7, -0.2),
    (1.5, 1, 0.7, -0.2),
    (1.5, 1, 2.3, -0.2),
    (-2.3, -0.2, -2.7, -1.5),
    (-0.7, -0.2, -1.2, -1.5),
    (0.7, -0.2, 0.2, -1.5),
  )
  for (x1, y1, x2, y2) in es {
    line((x1, y1), (x2, y2), stroke: (paint: c-tree, thickness: 1pt))
  }
  // Internal (filled)
  for (x, y, lab) in (
    (0, 2.5, "r"),
    (-1.5, 1, "a"),
    (1.5, 1, "b"),
    (-2.3, -0.2, "c"),
    (-0.7, -0.2, "d"),
    (0.7, -0.2, "e"),
    (2.3, -0.2, "f"),
  ) {
    circle((x, y), radius: 0.2, fill: c-tree, stroke: none)
    content((x, y), fill: c-white)[#text(weight: "bold")[#lab]]
  }
  // Leaves (outlined)
  for (x, y, lab) in ((-2.7, -1.5, "g"), (-1.2, -1.5, "h"), (0.2, -1.5, "i")) {
    circle((x, y), radius: 0.2, fill: none, stroke: c-tree)
    content((x, y))[#lab]
  }
})

// ── 6. Weighted graph + MST ──
#let spanning-tree = cetz.canvas({
  import cetz.draw: *
  let v = ((0, 2.5), (-2, 0.5), (2, 0.5), (-1.5, -1.5), (1.5, -1.5))
  for (ai, bi, w) in (
    (0, 1, "4"),
    (0, 2, "3"),
    (1, 2, "5"),
    (1, 3, "2"),
    (2, 4, "6"),
    (3, 4, "7"),
    (1, 4, "8"),
  ) {
    wedge(v.at(ai), v.at(bi), w)
  }
  for (ai, bi) in ((0, 2), (0, 1), (1, 3), (2, 4)) {
    line(v.at(ai), v.at(bi), stroke: (paint: c-tree, thickness: 2.5pt))
  }
  for (i, p) in v.enumerate() { node(p, str(i + 1), radius: 0.25) }
})

// ── 7. Bridges of Königsberg ──
#let eulerian = cetz.canvas({
  import cetz.draw: *
  let v = ((-1.5, 1), (1.5, 1), (-1.5, -1), (1.5, -1))
  let names = ("A", "B", "C", "D")
  line(v.at(0), v.at(1))
  line(v.at(0), v.at(2))
  line(v.at(0), v.at(3))
  line(v.at(1), v.at(2))
  line(v.at(1), v.at(3))
  line(v.at(2), v.at(3))
  line(
    (v.at(0).at(0) + 0.2, v.at(0).at(1) - 0.1),
    (v.at(1).at(0) - 0.2, v.at(1).at(1) - 0.1),
  )
  for (i, p) in v.enumerate() {
    rect(
      (p.at(0) - 0.5, p.at(1) - 0.3),
      (rel: (1, 0.6)),
      radius: 5pt,
      fill: c-pa.lighten(85%),
      stroke: c-pa,
    )
    content(p, size: .8em)[#text(weight: "bold")[#names.at(i)]]
  }
  // Degree labels in soft grey
  content(
    v.at(0),
    anchor: "north",
    outset: 0.6em,
    size: .7em,
    fill: c-grey,
  )[$3$]
  content(
    v.at(1),
    anchor: "north",
    outset: 0.6em,
    size: .7em,
    fill: c-grey,
  )[$3$]
  content(
    v.at(2),
    anchor: "south",
    outset: 0.6em,
    size: .7em,
    fill: c-grey,
  )[$5$]
  content(
    v.at(3),
    anchor: "south",
    outset: 0.6em,
    size: .7em,
    fill: c-grey,
  )[$3$]
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
  line(v.at(0), v.at(1))
  line(v.at(1), v.at(2))
  line(v.at(2), v.at(3))
  line(v.at(3), v.at(4))
  line(v.at(4), v.at(5))
  line(v.at(5), v.at(0))
  line(v.at(0), v.at(3))
  line(v.at(1), v.at(4))
  line(v.at(2), v.at(5))
  for (i, p) in v.enumerate() { node(p, str(i + 1), radius: 0.22) }
  // Face labels
  for (p, lab) in (
    ((0, 1.2), "$f_1$"),
    ((1, 0), "$f_2$"),
    ((1, -0.9), "$f_3$"),
    ((0, -1.2), "$f_4$"),
    ((-1, -0.9), "$f_5$"),
    ((-1, 0), "$f_6$"),
  ) {
    content(p, size: .7em, fill: c-grey)[#lab]
  }
})

// ── 9. Graph colouring (W_5) ──
#let graph-coloring = cetz.canvas({
  import cetz.draw: *
  let cols = (
    oklch(60%, 0.22, 22deg),
    oklch(58%, 0.18, 150deg),
    oklch(58%, 0.16, 250deg),
    oklch(65%, 0.2, 90deg),
  )
  let v = ((0, 1), (0, 2.5), (2.4, 0.8), (1.5, -2), (-1.5, -2), (-2.4, 0.8))
  let ci = (3, 0, 1, 0, 1, 2)
  line(v.at(1), v.at(2))
  line(v.at(2), v.at(3))
  line(v.at(3), v.at(4))
  line(v.at(4), v.at(5))
  line(v.at(5), v.at(1))
  line(v.at(0), v.at(1))
  line(v.at(0), v.at(2))
  line(v.at(0), v.at(3))
  line(v.at(0), v.at(4))
  line(v.at(0), v.at(5))
  for (i, p) in v.enumerate() {
    let c = cols.at(ci.at(i))
    let sz = if i == 0 { 0.38 } else { 0.3 }
    circle(p, radius: sz, fill: c, stroke: c.darken(12%))
    content(p, fill: c-white)[#text(weight: "bold")[#str(i)]]
  }
})

// ── 10. Directed graph + SCC ──
#let directed-graph = cetz.canvas({
  import cetz.draw: *
  let v = ((0, 2.5), (2.5, 1), (2.5, -1), (0, -2.5), (-2.5, -1), (-2.5, 1))
  line(v.at(0), v.at(1), mark: (end: "stealth"))
  line(v.at(1), v.at(2), mark: (end: "stealth"))
  line(v.at(2), v.at(0), mark: (end: "stealth"))
  line(v.at(0), v.at(3), mark: (end: "stealth"))
  line(v.at(3), v.at(4), mark: (end: "stealth"))
  line(v.at(4), v.at(3), mark: (end: "stealth"))
  line(v.at(5), v.at(0), mark: (end: "stealth"))
  line(v.at(1), v.at(5), mark: (end: "stealth"))
  circle((0.8, 0.8), radius: 1.2, fill: none, stroke: (
    paint: c-pa,
    thickness: 1.2pt,
    dash: "dashed",
  ))
  circle((-0.8, -1.8), radius: 0.9, fill: none, stroke: (
    paint: c-pb,
    thickness: 1.2pt,
    dash: "dashed",
  ))
  for (i, p) in v.enumerate() { snode(p, str(i + 1)) }
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
  line(outer.at(0), outer.at(1))
  line(outer.at(1), outer.at(2))
  line(outer.at(2), outer.at(3))
  line(outer.at(3), outer.at(4))
  line(outer.at(4), outer.at(0))
  line(inner.at(0), inner.at(2))
  line(inner.at(1), inner.at(3))
  line(inner.at(2), inner.at(4))
  line(inner.at(3), inner.at(0))
  line(inner.at(4), inner.at(1))
  for i in range(5) { line(outer.at(i), inner.at(i)) }
  for (i, p) in outer.enumerate() { snode(p, str(i + 1)) }
  for (i, p) in inner.enumerate() { snode(p, str(6 + i)) }
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
  // Normal edges
  for (a, b) in ((0, 3), (0, 4), (2, 4), (2, 5), (3, 4), (4, 5)) {
    line(v.at(a), v.at(b), stroke: (paint: c-edge, thickness: 0.8pt))
  }
  // Regular edge 1-2
  line(v.at(1), v.at(2), stroke: (paint: c-edge, thickness: 0.8pt))
  // Bridge (highlighted)
  line(v.at(0), v.at(1), stroke: (paint: c-hi, thickness: 2.2pt))
  // Cut-vertex marker
  circle(v.at(0), radius: 0.38, fill: none, stroke: (
    paint: c-hi,
    thickness: 1.8pt,
    dash: "dashed",
  ))
  for (i, p) in v.enumerate() { snode(p, str(i + 1)) }
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
  // All edges (muted)
  for (a, b) in (
    (0, 1),
    (0, 2),
    (1, 3),
    (1, 4),
    (2, 5),
    (2, 6),
    (3, 4),
    (5, 6),
    (1, 5),
  ) {
    line(v.at(a), v.at(b), stroke: (paint: c-grey, thickness: 0.25pt))
  }
  // BFS tree (bold)
  for (a, b) in ((0, 1), (0, 2), (1, 3), (1, 4), (2, 5), (2, 6)) {
    line(v.at(a), v.at(b), stroke: (paint: c-pa, thickness: 2pt))
  }
  for (i, p) in v.enumerate() {
    snode(p, str(i + 1))
    content(
      p,
      anchor: "north-east",
      outset: 0.25em,
      size: .55em,
      fill: c-grey,
    )[$d!=!#((0, 1, 1, 2, 2, 2, 2).at(i))$]
  }
})

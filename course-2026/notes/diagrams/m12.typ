// M12 Graph diagrams — CeTZ 0.5.2, node-based.
#import "@preview/cetz:0.5.2"

// ── Palette ──
#let c-node = oklch(65%, 0.12, 250deg)
#let c-edge = oklch(45%, 0.02, 260deg)
#let c-hi = oklch(65%, 0.25, 25deg)
#let c-tree = oklch(55%, 0.22, 145deg)
#let c-pa = oklch(70%, 0.18, 250deg)
#let c-pb = oklch(70%, 0.18, 35deg)

// ── Global helpers (re-import cetz.draw inside) ──
#let node(pos, label, radius: 0.3, fill: c-node) = {
  import cetz.draw: circle, content
  circle(pos, radius: radius, fill: fill, stroke: none, name: label)
  content(label + ".center", fill: white)[#text(weight: "bold")[#label]]
}

#let snode(pos, label) = { node(pos, label, radius: 0.2) }

#let wedge(a, b, w) = {
  import cetz.draw: content, line
  line(a, b, stroke: (paint: c-edge, thickness: 0.8pt))
  let mid = ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2)
  content(mid, fill: white, outset: 2pt, size: .7em)[#w]
}

// ── Diagrams ──

// 1. Simple graph with degree annotations
#let simple-graph = cetz.canvas({
  import cetz.draw: content, line
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
  content((1.5, -1.8))[Handshaking: $sum "deg" = 3+4+2+3+3+2 = 17 = 2 dot 9$]
})

// 2. K_5 — complete, non-planar
#let k5 = cetz.canvas({
  import cetz.draw: content, line
  let v = ((0, 2.5), (2.4, 0.8), (1.5, -2), (-1.5, -2), (-2.4, 0.8))
  for (i, p) in v.enumerate() { snode(p, str(i + 1)) }
  for i in range(5) {
    for j in range(i + 1, 5) {
      line(str(i + 1), str(j + 1), stroke: (paint: c-edge, thickness: 0.4pt))
    }
  }
  content((0, -2.7))[$V=5, E=10$, $10 > 3 dot 5 - 6 = 9$ → non-planar]
})

// 3. K_{3,3} — bipartite, non-planar
#let k33 = cetz.canvas({
  import cetz.draw: *
  let left = ((0, 2), (0, 0), (0, -2))
  let right = ((4, 2), (4, 0), (4, -2))
  rect(
    (-0.6, 2.5),
    (0.6, -2.5),
    radius: 6pt,
    fill: c-pa.lighten(85%),
    stroke: none,
  )
  rect(
    (3.4, 2.5),
    (4.6, -2.5),
    radius: 6pt,
    fill: c-pb.lighten(85%),
    stroke: none,
  )
  for l in left {
    for r in right { line(l, r, stroke: (paint: c-edge, thickness: 0.4pt)) }
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
  content((2, -2.6))[Bipartite. $E=9$, non-planar by Kuratowski.]
})

// 4. Bipartite — two coloured partitions
#let bipartite = cetz.canvas({
  import cetz.draw: *
  let top = ((-1, 1.5), (0.5, 1.5), (2, 1.5))
  let bot = ((-1, -1.5), (0.5, -1.5), (2, -1.5))
  rect(
    (-1.8, 2.2),
    (2.8, 0.8),
    radius: 5pt,
    fill: c-pa.lighten(85%),
    stroke: none,
  )
  rect(
    (-1.8, -0.8),
    (2.8, -2.2),
    radius: 5pt,
    fill: c-pb.lighten(85%),
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
  content((-2.2, 1.5), anchor: "east")[Part $X$]
  content((-2.2, -1.5), anchor: "east")[Part $Y$]
})

// 5. Tree — levels, leaves outlined
#let tree = cetz.canvas({
  import cetz.draw: *
  // Edges
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
  for (x1, y1, x2, y2) in es { line((x1, y1), (x2, y2)) }
  // Internal nodes (filled)
  let ins = (
    (0, 2.5, "r"),
    (-1.5, 1, "a"),
    (1.5, 1, "b"),
    (-2.3, -0.2, "c"),
    (-0.7, -0.2, "d"),
    (0.7, -0.2, "e"),
    (2.3, -0.2, "f"),
  )
  for (x, y, lab) in ins {
    circle((x, y), radius: 0.2, fill: c-tree, stroke: none)
    content((x, y), fill: white)[#text(weight: "bold")[#lab]]
  }
  // Leaves (outlined)
  for (x, y, lab) in ((-2.7, -1.5, "g"), (-1.2, -1.5, "h"), (0.2, -1.5, "i")) {
    circle((x, y), radius: 0.2, fill: none, stroke: c-tree)
    content((x, y))[#lab]
  }
  content((0, -2.2))[9 vertices, 8 edges, 4 leaves (outlined)]
})

// 6. Weighted graph + MST
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
  // MST bold
  for (ai, bi) in ((0, 2), (0, 1), (1, 3), (2, 4)) {
    line(v.at(ai), v.at(bi), stroke: (paint: c-tree, thickness: 2.5pt))
  }
  for (i, p) in v.enumerate() { node(p, str(i + 1), radius: 0.25) }
  content((0, -2.2))[MST weight: $3+4+2+6=15$]
})

// 7. Bridges of Königsberg
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
      fill: c-pa.lighten(80%),
      stroke: c-pa,
    )
    content(p, size: .8em)[#text(weight: "bold")[#names.at(i)]]
  }
  content(v.at(0), anchor: "north", outset: 0.7em)[$3$]
  content(v.at(1), anchor: "north", outset: 0.7em)[$3$]
  content(v.at(2), anchor: "south", outset: 0.7em)[$5$]
  content(v.at(3), anchor: "south", outset: 0.7em)[$3$]
  content((0, -2.2))[All degrees odd → no Eulerian tour. Euler (1736).]
})

// 8. Planar graph + dual
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
  // Dual (dashed red)
  let d = (
    (0, 1.3),
    (1.2, -0.2),
    (1.2, -1.2),
    (0, -1.3),
    (-1.2, -1.2),
    (-1.2, -0.2),
    (0, 3.5),
  )
  for p in d { circle(p, radius: 0.08, fill: c-hi, stroke: none) }
  let de(a, b) = {
    line(a, b, stroke: (paint: c-hi, thickness: 0.5pt, dash: "dashed"))
  }
  de(d.at(0), d.at(1))
  de(d.at(1), d.at(2))
  de(d.at(2), d.at(3))
  de(d.at(3), d.at(4))
  de(d.at(4), d.at(5))
  de(d.at(5), d.at(0))
  de(d.at(0), d.at(3))
  de(d.at(1), d.at(5))
  de(d.at(2), d.at(4))
  de(d.at(6), d.at(0))
  de(d.at(6), d.at(3))
  de(d.at(6), d.at(4))
  de(d.at(6), d.at(5))
  content((0, 3.8))[Dual: $V^*!=!7$, each face $→$ vertex]
})

// 9. Graph colouring — W_5 wheel
#let graph-coloring = cetz.canvas({
  import cetz.draw: *
  let cols = (
    oklch(65%, 0.22, 25deg),
    oklch(65%, 0.18, 145deg),
    oklch(65%, 0.18, 250deg),
    oklch(70%, 0.2, 90deg),
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
    let sz = if i == 0 { 0.35 } else { 0.3 }
    circle(p, radius: sz, fill: c, stroke: c.darken(15%))
    content(p, fill: white)[#text(weight: "bold")[#str(i)]]
  }
  content((0, -2.7))[$W_5$: odd outer cycle → $chi(W_5)=4$.]
})

// 10. Directed graph + SCCs
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
    thickness: 1.5pt,
    dash: "dashed",
  ))
  content((0.8, 2.1), anchor: "south")[SCC 1]
  circle((-0.8, -1.8), radius: 0.9, fill: none, stroke: (
    paint: c-pb,
    thickness: 1.5pt,
    dash: "dashed",
  ))
  content((-0.8, -2.8))[SCC 2]
  for (i, p) in v.enumerate() { snode(p, str(i + 1)) }
})

// 11. Petersen graph
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
  content((
    0,
    -2.7,
  ))[Petersen: 3-regular, $V!=!10$, $chi!=!3$, non-planar, hypohamiltonian.]
})

// 12. Bridge and cut-vertex
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
  line(v.at(0), v.at(3))
  line(v.at(0), v.at(4))
  line(v.at(2), v.at(4))
  line(v.at(2), v.at(5))
  line(v.at(3), v.at(4))
  line(v.at(4), v.at(5))
  line(v.at(0), v.at(1), stroke: (paint: c-hi, thickness: 2pt))
  line(v.at(1), v.at(2))
  circle(v.at(0), radius: 0.35, fill: none, stroke: (
    paint: c-hi,
    thickness: 2pt,
    dash: "dashed",
  ))
  content((v.at(0).at(0), v.at(0).at(1) + 0.5))[cut-vertex]
  content((-0.75, 1.9))[bridge]
  for (i, p) in v.enumerate() { snode(p, str(i + 1)) }
  content((0, -2))[Edge {1,2} is a bridge. Vertex 1 is an articulation point.]
})

// 13. BFS tree — layered with distances
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
  // All edges grey
  let greys = (
    (0, 1),
    (0, 2),
    (1, 3),
    (1, 4),
    (2, 5),
    (2, 6),
    (3, 4),
    (5, 6),
    (1, 5),
  )
  for (a, b) in greys {
    line(v.at(a), v.at(b), stroke: (paint: gray.lighten(30%), thickness: 0.3pt))
  }
  // BFS tree bold
  for (a, b) in ((0, 1), (0, 2), (1, 3), (1, 4), (2, 5), (2, 6)) {
    line(v.at(a), v.at(b), stroke: (paint: c-pa, thickness: 2pt))
  }
  let dists = (0, 1, 1, 2, 2, 2, 2)
  for (i, p) in v.enumerate() {
    snode(p, str(i + 1))
    content(
      p,
      anchor: "north-east",
      outset: 0.3em,
      size: .6em,
    )[$d=#(dists.at(i))$]
  }
  content((0, -2))[BFS from vertex 1. Bold: tree edges. Cross edges grey.]
})

// M12 Graph diagrams using CeTZ 0.4.2
#import "@preview/cetz:0.4.2"

// 1. Simple undirected graph with 6 vertices
#let simple-graph = cetz.canvas({
  import cetz.draw: *
  set-style(radius: 0.25, stroke: (thickness: 1pt))
  let v = ((0, 1.5), (1.3, 1.5), (2.6, 1.5), (0.65, 0), (1.95, 0), (1.3, -1))
  for (i, p) in v.enumerate() {
    circle(p, name: "v" + str(i))
    content(p, [$#(i + 1)$])
  }
  line(v.at(0), v.at(1))
  line(v.at(1), v.at(2))
  line(v.at(0), v.at(3))
  line(v.at(1), v.at(3))
  line(v.at(1), v.at(4))
  line(v.at(2), v.at(4))
  line(v.at(3), v.at(4))
  line(v.at(4), v.at(5))
  line(v.at(3), v.at(5))
})

// 2. Complete graph K_5 (non-planar)
#let k5 = cetz.canvas({
  import cetz.draw: *
  set-style(radius: 0.22, stroke: (thickness: 1pt))
  let v = ((0, 2), (1.9, 0.62), (1.18, -1.62), (-1.18, -1.62), (-1.9, 0.62))
  for i in range(5) {
    for j in range(i + 1, 5) {
      line(v.at(i), v.at(j))
    }
  }
  for (i, p) in v.enumerate() {
    circle(p)
    content(p, [$#(i + 1)$])
  }
})

// 3. Complete bipartite K_{3,3} (non-planar)
#let k33 = cetz.canvas({
  import cetz.draw: *
  set-style(radius: 0.18, stroke: (thickness: 1pt))
  let left = ((0, 2), (0, 0), (0, -2))
  let right = ((3, 2), (3, 0), (3, -2))
  for l in left {
    for r in right {
      line(l, r)
    }
  }
  for p in left { circle(p, fill: black) }
  for p in right { circle(p, fill: black) }
  content((0, 2.5), anchor: "south")[$X$]
  content((3, 2.5), anchor: "south")[$Y$]
})

// 4. Bipartite graph with two colored parts
#let bipartite = cetz.canvas({
  import cetz.draw: *
  set-style(radius: 0.2, stroke: (thickness: 1pt))
  let top = ((-0.5, 1.5), (0.8, 1.5), (2.1, 1.5))
  let bot = ((-0.5, -1), (0.8, -1), (2.1, -1))
  for p in top { circle(p, fill: blue.lighten(80%)) }
  for p in bot { circle(p, fill: red.lighten(80%)) }
  line(top.at(0), bot.at(0))
  line(top.at(0), bot.at(1))
  line(top.at(1), bot.at(0))
  line(top.at(1), bot.at(1))
  line(top.at(1), bot.at(2))
  line(top.at(2), bot.at(1))
  line(top.at(2), bot.at(2))
})

// 5. Tree (rooted, 6 vertices)
#let tree = cetz.canvas({
  import cetz.draw: *
  set-style(radius: 0.18, stroke: (thickness: 1pt))
  circle((0, 2), name: "a")
  content((0, 2))[$a$]
  circle((-1, 1), name: "b")
  content((-1, 1))[$b$]
  circle((1, 1), name: "c")
  content((1, 1))[$c$]
  circle((-1.5, 0), name: "d")
  content((-1.5, 0))[$d$]
  circle((-0.5, 0), name: "e")
  content((-0.5, 0))[$e$]
  circle((1, 0), name: "f")
  content((1, 0))[$f$]
  line((0, 2), (-1, 1))
  line((0, 2), (1, 1))
  line((-1, 1), (-1.5, 0))
  line((-1, 1), (-0.5, 0))
  line((1, 1), (1, 0))
})

// 6. Graph with spanning tree highlighted
#let spanning-tree = cetz.canvas({
  import cetz.draw: *
  set-style(radius: 0.2, stroke: (thickness: 0.8pt))
  let v = ((0, 2), (-1.3, 0.5), (1.3, 0.5), (-1.3, -1), (1.3, -1))
  // All edges in light grey
  set-style(stroke: (paint: gray, thickness: 0.5pt))
  line(v.at(0), v.at(1))
  line(v.at(0), v.at(2))
  line(v.at(1), v.at(2))
  line(v.at(1), v.at(3))
  line(v.at(2), v.at(4))
  line(v.at(3), v.at(4))
  line(v.at(1), v.at(4))
  // Spanning tree edges in bold blue
  set-style(stroke: (paint: blue, thickness: 2pt))
  line(v.at(0), v.at(1))
  line(v.at(0), v.at(2))
  line(v.at(1), v.at(3))
  line(v.at(2), v.at(4))
  // Vertices on top
  for (i, p) in v.enumerate() {
    circle(p, fill: white, stroke: black)
    content(p, [$#(i + 1)$])
  }
})

// 7. Eulerian graph with a highlighted tour
#let eulerian = cetz.canvas({
  import cetz.draw: *
  set-style(radius: 0.2, stroke: (thickness: 0.8pt))
  let v = ((0, 1.5), (1.5, 1.5), (0, 0), (1.5, 0))
  // All edges in grey
  set-style(stroke: (paint: gray.lighten(40%), thickness: 0.5pt))
  line(v.at(0), v.at(1))
  line(v.at(0), v.at(2))
  line(v.at(1), v.at(3))
  line(v.at(2), v.at(3))
  line(v.at(0), v.at(3))
  line(v.at(1), v.at(2))
  // Eulerian tour: 0→1→3→2→0→3→1→2→0
  set-style(stroke: (paint: blue, thickness: 1.5pt))
  let tour = (0, 1, 3, 2, 0, 3, 1, 2, 0)
  for i in range(tour.len() - 1) {
    line(v.at(tour.at(i)), v.at(tour.at(i + 1)), mark: (end: "stealth"))
  }
  for (i, p) in v.enumerate() {
    circle(p, fill: white, stroke: black)
    content(p, [$#(i + 1)$])
  }
})

// 8. Planar graph with faces labeled
#let planar = cetz.canvas({
  import cetz.draw: *
  set-style(radius: 0.18, stroke: (thickness: 1pt))
  let v = ((0, 2), (1.73, 1), (1.73, -1), (0, -2), (-1.73, -1), (-1.73, 1))
  line(v.at(0), v.at(1))
  line(v.at(1), v.at(2))
  line(v.at(2), v.at(3))
  line(v.at(3), v.at(4))
  line(v.at(4), v.at(5))
  line(v.at(5), v.at(0))
  line(v.at(0), v.at(3))
  line(v.at(1), v.at(4))
  line(v.at(2), v.at(5))
  for (i, p) in v.enumerate() {
    circle(p)
    content(p, [$#(i + 1)$])
  }
  content((0, 1.2))[$f_1$]
  content((0.9, 0.2))[$f_2$]
  content((0.9, -0.8))[$f_3$]
  content((0, -1.2))[$f_4$]
  content((-1.1, -0.8))[$f_5$]
  content((-1.1, 0.2))[$f_6$]
  content((0, 3), anchor: "south")[$V=6, E=9, F=5$, $6-9+5=2$]
})

// 9. Graph with 4-coloring
#let graph-coloring = cetz.canvas({
  import cetz.draw: *
  set-style(radius: 0.22, stroke: (thickness: 1pt))
  let colors = (red, blue, green, yellow)
  let v = ((0, 2), (1.3, 1), (1.3, -0.5), (0, -1.5), (-1.3, -0.5), (-1.3, 1))
  let cols = (0, 1, 0, 2, 1, 3)
  line(v.at(0), v.at(1))
  line(v.at(1), v.at(2))
  line(v.at(2), v.at(3))
  line(v.at(3), v.at(4))
  line(v.at(4), v.at(5))
  line(v.at(5), v.at(0))
  line(v.at(0), v.at(2))
  line(v.at(2), v.at(4))
  line(v.at(4), v.at(0))
  for (i, p) in v.enumerate() {
    let c = colors.at(cols.at(i))
    circle(p, fill: c.lighten(85%), stroke: c)
    content(p, [$#(i + 1)$])
  }
})

// 10. Directed graph (for SCC example)
#let directed-graph = cetz.canvas({
  import cetz.draw: *
  set-style(radius: 0.2, stroke: (thickness: 1pt))
  let v = ((0, 1.5), (1.5, 0.5), (0, -1.5), (-1.5, 0.5))
  for (i, p) in v.enumerate() {
    circle(p)
    content(p, [$#(i + 1)$])
  }
  line(v.at(0), v.at(1), mark: (end: "stealth"))
  line(v.at(1), v.at(2), mark: (end: "stealth"))
  line(v.at(2), v.at(0), mark: (end: "stealth"))
  line(v.at(1), v.at(3), mark: (end: "stealth"))
  line(v.at(3), v.at(0), mark: (end: "stealth"))
})

// 11. Diamond poset / Hasse diagram
#let hasse-cube = cetz.canvas({
  import cetz.draw: *
  set-style(radius: 0.12, stroke: (thickness: 1.2pt))
  let b1 = (-0.5, -1.2)
  let b2 = (0.5, -1.2)
  let t1 = (-0.5, 1.2)
  let t2 = (0.5, 1.2)
  circle(b1, fill: black)
  circle(b2, fill: black)
  circle(t1, fill: black)
  circle(t2, fill: black)
  content(b1, anchor: "north-east", padding: 4pt)[$nothing$]
  content(b2, anchor: "north-west", padding: 4pt)[${a}$]
  content(t1, anchor: "south-east", padding: 4pt)[${b}$]
  content(t2, anchor: "south-west", padding: 4pt)[${a,b}$]
  line(b1, t1)
  line(b1, t2)
  line(b2, t1)
  line(b2, t2)
})

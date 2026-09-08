// Диаграммы для лекции «Алгебраические структуры».
#import "@preview/cetz:0.5.2": canvas, draw

#let d-node = 0.8pt + oklch(50%, 0.15, 250deg)
#let d-edge = 0.7pt + oklch(40%, 0.03, 265deg)
#let d-fill = oklch(91%, 0.03, 250deg)
#let d-ink = oklch(30%, 0.02, 250deg)

// ── Решётка подгрупп ZZ_12 ──
#let subgroup-lattice = canvas({
  let node(pos, name, body) = {
    draw.circle(pos, radius: 0.4, stroke: d-node, fill: d-fill, name: name)
    draw.content(name, text(size: 0.7em, fill: d-ink)[#body])
  }
  let edge(fr, to) = {
    draw.line(fr, to, stroke: d-edge)
  }

  node((0, 4.0), "n12", $12$)
  node((-2.0, 2.7), "n6", $6$)
  node((0.0, 2.7), "n4", $4$)
  node((2.0, 2.7), "n3", $3$)
  node((-1.0, 1.4), "n2", $2$)
  node((1.0, 1.4), "n1", $1$)

  edge("n12", "n6")
  edge("n12", "n4")
  edge("n12", "n3")
  edge("n6", "n2")
  edge("n4", "n2")
  edge("n3", "n1")
  edge("n2", "n1")
})

// ── Циклическая группа ZZ_8 ──
#let cyclic-generator = canvas({
  let node(pos, name, body) = {
    draw.circle(pos, radius: 0.4, stroke: d-node, fill: d-fill, name: name)
    draw.content(name, text(size: 0.7em, fill: d-ink)[#body])
  }
  let edge(fr, to) = {
    draw.line(fr, to, stroke: d-edge)
  }

  node((0, 3.0), "b0", $0$)
  node((2.1, 2.1), "b1", $1$)
  node((3.0, 0), "b2", $2$)
  node((2.1, -2.1), "b3", $3$)
  node((0, -3.0), "b4", $4$)
  node((-2.1, -2.1), "b5", $5$)
  node((-3.0, 0), "b6", $6$)
  node((-2.1, 2.1), "b7", $7$)

  edge("b0", "b1")
  edge("b1", "b2")
  edge("b2", "b3")
  edge("b3", "b4")
  edge("b4", "b5")
  edge("b5", "b6")
  edge("b6", "b7")
  edge("b7", "b0")

  draw.content((0, 0), text(size: 0.6em, fill: d-ink)[$ZZ_8$])
})

// ── Коммутативная диаграмма гомоморфизма ──
#let hom-square = canvas({
  let node(pos, name, body) = {
    draw.rect(
      (pos.at(0) - 1.0, pos.at(1) - 0.45),
      (pos.at(0) + 1.0, pos.at(1) + 0.45),
      radius: 4pt,
      stroke: d-node,
      fill: d-fill,
      name: name,
    )
    draw.content(name, text(size: 0.7em, fill: d-ink)[#body])
  }
  let arrow(fr, to, label) = {
    draw.line(fr, to, stroke: d-edge, mark: (end: ">"))
    draw.content((fr, 50%, to), dy: 0.7em, text(
      size: 0.55em,
      fill: d-ink,
    )[#label])
  }

  node((0, 2.0), "g", $G$)
  node((3.2, 2.0), "h", $H$)
  node((0, -2.0), "gk", $G / "ker"(phi)$)
  node((3.2, -2.0), "im", $"im"(phi)$)

  arrow("g", "h", $phi$)
  arrow("g", "gk", $pi$)
  arrow("gk", "im", $tilde(phi)$)
  arrow("h", "im", $"in"$)
})

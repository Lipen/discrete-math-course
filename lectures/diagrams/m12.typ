// Диаграммы для лекции "Алгебраические структуры".
#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/fletcher:0.5.8": diagram, edge, node
#import "style.typ": *

// ── Решётка порядков подгрупп ZZ_12 ──
#let subgroup-lattice = canvas({
  let vs = (
    ("n12", (0, 3.2), "12"),
    ("n6", (-1.5, 2.1), "6"),
    ("n4", (1.5, 2.1), "4"),
    ("n3", (-0.85, 1.0), "3"),
    ("n2", (0.85, 1.0), "2"),
    ("n1", (0, 0), "1"),
  )
  for (nm, p, lab) in vs {
    vertex(nm, p)
    mark(p, lab, size: 0.5em)
  }
  for (a, b) in (
    ("n12", "n6"),
    ("n12", "n4"),
    ("n6", "n3"),
    ("n6", "n2"),
    ("n4", "n2"),
    ("n3", "n1"),
    ("n2", "n1"),
  ) {
    draw.line(a, b, stroke: edge-plain)
  }
})

// ── Циклическая группа ZZ_8: шаги образующей по кругу ──
#let cyclic-generator = canvas({
  let R = 2.3
  let r = 0.3
  let pts = range(8).map(i => {
    let a = 90deg - i * 45deg
    (R * calc.cos(a), R * calc.sin(a))
  })
  for i in range(8) {
    vertex("g" + str(i), pts.at(i), size: r)
    mark(pts.at(i), str(i), size: 0.5em)
  }

  let rim(p, toward) = {
    let dx = toward.at(0) - p.at(0)
    let dy = toward.at(1) - p.at(1)
    let d = calc.sqrt(dx * dx + dy * dy)
    (p.at(0) + dx / d * r, p.at(1) + dy / d * r)
  }
  for i in range(8) {
    let j = calc.rem(i + 1, 8)
    let ctrl = (
      (pts.at(i).at(0) + pts.at(j).at(0)) * 0.75,
      (pts.at(i).at(1) + pts.at(j).at(1)) * 0.75,
    )
    draw.bezier(
      rim(pts.at(i), ctrl),
      rim(pts.at(j), ctrl),
      ctrl,
      mark: (end: "stealth"),
      stroke: if i == 0 { edge-hot } else { edge-plain },
    )
  }
  mark((0, 0), $ZZ_8$, size: 0.5em)
})

// ── Квадрат первой теоремы об изоморфизме ──
#let hom-square = diagram(
  node-stroke: (paint: cool, thickness: 1.1pt),
  node-fill: white,
  node-inset: 6pt,
  spacing: 3.4em,
  {
    node((0, 0), text(size: 0.8em)[$G$], name: <g>)
    node((3, 0), text(size: 0.8em)[$H$], name: <h>)
    node((0, 2), text(size: 0.8em)[$G / "ker"(phi)$], name: <gk>)
    node((3, 2), text(size: 0.8em)[$"im"(phi)$], name: <im>)
    edge(<g>, <h>, "->", label: $phi$, label-size: 0.7em, stroke: edge-plain)
    edge(<g>, <gk>, "->", label: $pi$, label-size: 0.7em, stroke: edge-plain)
    edge(
      <gk>,
      <im>,
      "->",
      label: $tilde(phi)$,
      label-size: 0.7em,
      stroke: edge-hot,
    )
    edge(<im>, <h>, "-hook->", stroke: edge-thin)
  },
)

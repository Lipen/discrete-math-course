// m12 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

#let hf-str = 0.8pt + oklch(35%, 0.02, 265deg)

#let hf-leaf-str = 1pt + oklch(35%, 0.02, 265deg)

#let huffman-tree = canvas({
  // Node positions --- tree structure (y-step = 1.8, units = cm)
  // Ноды именованы, чтобы cetz обрезал рёбра до границы кружка.
  let root = (0, 0)

  // Helper: labelled circle node (internal or leaf), named by `name`.
  let hf-node(pos, name, radius, body, stroke: hf-str, ..args) = {
    draw.circle(pos, radius: radius, stroke: stroke, name: name, ..args)
    draw.content(pos, body)
  }

  // Internal nodes (weights) and leaf nodes (symbols) --- created first,
  // so the edges below can reference them by name and clip at the border.
  hf-node(root, "root", 0.3, $1.0$)
  hf-node((1.5, -1.8), "R1", 0.3, $0.60$)
  hf-node((2.5, -3.6), "R2", 0.3, $0.35$)
  hf-node((3.5, -5.4), "R3", 0.3, $0.15$)
  hf-node((-3.5, -1.8), "A", 0.35, [$A: 0.40$], stroke: hf-leaf-str, fill: white)
  hf-node((-0.5, -3.6), "B", 0.35, [$B: 0.25$], stroke: hf-leaf-str, fill: white)
  hf-node((1, -5.4), "C", 0.35, [$C: 0.20$], stroke: hf-leaf-str, fill: white)
  hf-node((2.5, -7.2), "D", 0.35, [$D: 0.10$], stroke: hf-leaf-str, fill: white)
  hf-node((4.5, -7.2), "E", 0.35, [$E: 0.05$], stroke: hf-leaf-str, fill: white)

  // Edge helper: named line (cetz clips to node border) + label at midpoint.
  // `p`/`q` only give the midpoint coordinates for the label.
  let mid-label(fr, to, p, q, offset, label) = {
    draw.line(fr, to, stroke: hf-str)
    let mx = (p.at(0) + q.at(0)) / 2
    let my = (p.at(1) + q.at(1)) / 2
    draw.content((mx + offset.at(0), my + offset.at(1)), label)
  }

  // Edges with labels (by node names, so cetz clips to the border).
  mid-label("root", "A", root, (-3.5, -1.8), (-0.4, 0.1), [_0_])
  mid-label("root", "R1", root, (1.5, -1.8), (0.2, 0.1), [_1_])
  mid-label("R1", "B", (1.5, -1.8), (-0.5, -3.6), (-0.4, 0.1), [_0_])
  mid-label("R1", "R2", (1.5, -1.8), (2.5, -3.6), (0.2, 0.1), [_1_])
  mid-label("R2", "C", (2.5, -3.6), (1, -5.4), (-0.4, 0.1), [_0_])
  mid-label("R2", "R3", (2.5, -3.6), (3.5, -5.4), (0.2, 0.1), [_1_])
  mid-label("R3", "D", (3.5, -5.4), (2.5, -7.2), (-0.4, 0.1), [_0_])
  mid-label("R3", "E", (3.5, -5.4), (4.5, -7.2), (0.2, 0.1), [_1_])
})

#let hs-codeword = oklch(55%, 0.15, 260deg)

#let hs-sphere-stroke = oklch(58%, 0.10, 260deg)

#let hs-sphere-fill = oklch(96%, 0.03, 260deg)

#let hs-point = oklch(40%, 0.03, 265deg)

#let hs-label = oklch(35%, 0.02, 265deg)

#let hs-dim = oklch(55%, 0.14, 22deg)

#let hs-draw-sphere(center, radius, noise) = {
  let (cx, cy) = center

  // Sphere: dashed circle with light fill
  draw.circle(
    center,
    radius: radius,
    stroke: (paint: hs-sphere-stroke, thickness: 0.7pt, dash: "dashed"),
    fill: hs-sphere-fill,
  )

  // Noise points --- other strings at distance ≤ t from the codeword
  for p in noise {
    draw.circle((cx + p.at(0), cy + p.at(1)), radius: 0.07, fill: hs-point)
  }

  // Codeword dot on top (larger, filled)
  draw.circle(center, radius: 0.17, fill: hs-codeword)
}

#let hamming-spheres = canvas({
  let r = 1.25
  let cw1 = (1.8, 3.0)
  let cw2 = (6.2, 3.0)
  let cw3 = (4.0, -0.3)

  // Noise points inside each sphere (offsets from center, magnitude < r)
  let n1 = (
    (0.25, 0.50),
    (-0.50, -0.35),
    (0.10, -0.65),
    (0.60, -0.20),
    (-0.40, 0.40),
    (0.55, 0.30),
    (-0.20, -0.70),
    (-0.55, 0.10),
    (0.70, -0.40),
  )
  let n2 = (
    (-0.15, 0.55),
    (0.45, 0.25),
    (-0.45, -0.20),
    (-0.05, -0.45),
    (0.25, -0.40),
    (-0.35, 0.20),
    (0.60, 0.05),
    (0.15, 0.50),
    (-0.50, -0.50),
  )
  let n3 = (
    (0.35, 0.35),
    (-0.25, 0.45),
    (0.05, -0.30),
    (-0.45, -0.25),
    (0.60, 0.00),
    (-0.10, -0.50),
    (0.40, -0.30),
    (-0.40, 0.25),
    (-0.50, 0.10),
  )

  hs-draw-sphere(cw1, r, n1)
  hs-draw-sphere(cw2, r, n2)
  hs-draw-sphere(cw3, r, n3)

  // Dimension line: radius t from codeword 1 to sphere edge
  let dim-start = cw1
  let dim-end = (cw1.at(0) + r, cw1.at(1))
  draw.line(dim-start, dim-end, stroke: (paint: hs-dim, thickness: 0.6pt))
  // Tick marks
  draw.line(
    (dim-start.at(0), dim-start.at(1) - 0.12),
    (dim-start.at(0), dim-start.at(1) + 0.12),
    stroke: (paint: hs-dim, thickness: 0.5pt),
  )
  draw.line(
    (dim-end.at(0), dim-end.at(1) - 0.12),
    (dim-end.at(0), dim-end.at(1) + 0.12),
    stroke: (paint: hs-dim, thickness: 0.5pt),
  )
  // Dimension label
  draw.content(
    (cw1.at(0) + r / 2, cw1.at(1) + 0.28),
    anchor: "south",
    text(size: 0.7em, fill: hs-dim)[радиус $t$],
  )

  // Codeword label with arrow
  draw.content(
    (cw2.at(0), cw2.at(1) + 0.6),
    anchor: "south",
    text(size: 0.7em, fill: hs-label)[кодовое слово],
  )
  draw.line(
    (cw2.at(0), cw2.at(1) + 0.42),
    (cw2.at(0), cw2.at(1) + 0.19),
    stroke: (paint: hs-label, thickness: 0.4pt),
  )
})

#let cl-n-fill = oklch(88%, 0.03, 250deg)

#let cl-n-str = 0.6pt + oklch(60%, 0.08, 250deg)

#let cl-e-str = 0.6pt + oklch(35%, 0.02, 265deg)

#let cl-n-size = 1.6em

#let cl-node(pos, body, ..args) = node(
  pos,
  body,
  fill: cl-n-fill,
  stroke: cl-n-str,
  width: cl-n-size,
  height: cl-n-size,
  ..args,
)

#let cl-edge(from, to) = edge(from, to, "-", stroke: cl-e-str)

#let code-lattice = diagram(
  node-shape: "circle",
  node-stroke: cl-n-str,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 2.5em,
  // Top (y=0): full space
  cl-node((0, 0), $"GF"(2)^3$, name: <full>),
  // Layer 2 (y=1): 2D coordinate subspaces
  cl-node((-1.3, 1), $<x, y>$, name: <xy>),
  cl-node((0, 1), $<x, z>$, name: <xz>),
  cl-node((1.3, 1), $<y, z>$, name: <yz>),
  // Layer 1 (y=2): 1D coordinate subspaces
  cl-node((-1.3, 2), $<x>$, name: <x>),
  cl-node((0, 2), $<y>$, name: <y>),
  cl-node((1.3, 2), $<z>$, name: <z>),
  // Bottom (y=3): zero subspace
  cl-node((0, 3), ${0}$, name: <zero>),
  // Cover relations: zero -> axes
  cl-edge(<zero>, <x>),
  cl-edge(<zero>, <y>),
  cl-edge(<zero>, <z>),
  // Axes -> planes
  cl-edge(<x>, <xy>),
  cl-edge(<x>, <xz>),
  cl-edge(<y>, <xy>),
  cl-edge(<y>, <yz>),
  cl-edge(<z>, <xz>),
  cl-edge(<z>, <yz>),
  // Planes -> full space
  cl-edge(<xy>, <full>),
  cl-edge(<xz>, <full>),
  cl-edge(<yz>, <full>),
)

#let hg-p1 = oklch(52%, 0.15, 260deg)    // p₁ group: blue

#let hg-p2 = oklch(48%, 0.12, 150deg)    // p₂ group: green

#let hg-p4 = oklch(48%, 0.14, 315deg)    // p₄ group: purple

#let hg-data = oklch(38%, 0.03, 265deg)  // data bits and their lines

#let hg-line = oklch(72%, 0.02, 265deg)  // data lines

#let hg-label = oklch(30%, 0.02, 265deg) // bit labels

#let hg-dim = oklch(58%, 0.02, 265deg)   // positions, faint

#let hg-fill = oklch(97%, 0.02, 265deg)  // circle fill

#let hamming-groups = canvas({
  // Horizontal position of each codeword bit (index: position - 1).
  let x = (0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0)
  let cy = 7.0
  let r = 0.42
  let y-top = cy - r

  // Data lines from top (d₁) to bottom (d₄).
  let data-y = (5.4, 4.5, 3.6, 2.7)
  let data-name = (($d_1$), ($d_2$), ($d_3$), ($d_4$))
  for (i, y) in data-y.enumerate() {
    draw.line((-0.6, y), (6.6, y), stroke: (paint: hg-line, thickness: 0.5pt))
    draw.content((-1.7, y), text(size: 0.7em, fill: hg-data)[#data-name.at(i)])
  }

  // One circle per bit, stroked in its group's color.
  let hg-bit(bx, label, num, color) = {
    draw.circle(
      (bx, cy),
      radius: r,
      fill: hg-fill,
      stroke: (paint: color, thickness: 0.8pt),
    )
    draw.content((bx, cy), text(size: 0.72em, fill: hg-label)[#label])
    draw.content((bx, cy + 0.8), text(size: 0.55em, fill: hg-dim)[#num])
  }
  hg-bit(x.at(0), $p_1$, 1, hg-p1)
  hg-bit(x.at(1), $p_2$, 2, hg-p2)
  hg-bit(x.at(2), $d_1$, 3, hg-data)
  hg-bit(x.at(3), $p_4$, 4, hg-p4)
  hg-bit(x.at(4), $d_2$, 5, hg-data)
  hg-bit(x.at(5), $d_3$, 6, hg-data)
  hg-bit(x.at(6), $d_4$, 7, hg-data)

  // Vertical from a bit down to its lines; dots mark the connections.
  let hg-edge(bx, bottom, color, dots) = {
    draw.line((bx, y-top), (bx, bottom), stroke: (paint: color, thickness: 1pt))
    for d in dots {
      draw.circle((bx, d), radius: 0.13, fill: color)
    }
  }
  hg-edge(x.at(0), data-y.at(3), hg-p1, (
    data-y.at(0),
    data-y.at(1),
    data-y.at(3),
  ))
  hg-edge(x.at(1), data-y.at(3), hg-p2, (
    data-y.at(0),
    data-y.at(2),
    data-y.at(3),
  ))
  hg-edge(x.at(3), data-y.at(3), hg-p4, (
    data-y.at(1),
    data-y.at(2),
    data-y.at(3),
  ))
  hg-edge(x.at(2), data-y.at(0), hg-data, (data-y.at(0),))
  hg-edge(x.at(4), data-y.at(1), hg-data, (data-y.at(1),))
  hg-edge(x.at(5), data-y.at(2), hg-data, (data-y.at(2),))
  hg-edge(x.at(6), data-y.at(3), hg-data, (data-y.at(3),))
})

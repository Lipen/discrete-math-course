// M10 diagrams --- Hamming, Huffman.
// Скопировано из notes/diagrams/m09.typ, чтобы лекции не зависели от книги.
#import "@preview/cetz:0.5.2": canvas, draw, vector

#let hf-str = 0.8pt + oklch(35%, 0.02, 265deg)
#let hf-leaf-str = 1pt + oklch(35%, 0.02, 265deg)

// ── Huffman tree ──
#let huffman-tree = canvas({
  // Node helper: named circle with a label
  let hf-node(pos, radius, body, name, stroke: hf-str, ..args) = {
    draw.circle(pos, radius: radius, stroke: stroke, name: name, ..args)
    draw.content(pos, body)
  }

  // Edge helper: line between two named nodes + label at midpoint
  let mid-label(a, b, offset, label) = {
    draw.line(a, b, stroke: hf-str)
    draw.content((a, 50%, b), offset: offset, label)
  }

  // Nodes, named
  hf-node((0, 0), 0.3, $1.0$, "root")
  hf-node((-3.5, -1.8), 0.35, [$A: 0.40$], "A", stroke: hf-leaf-str, fill: white)
  hf-node((1.5, -1.8), 0.3, $0.60$, "R")
  hf-node((-0.5, -3.6), 0.35, [$B: 0.25$], "B", stroke: hf-leaf-str, fill: white)
  hf-node((2.5, -3.6), 0.3, $0.35$, "R2")
  hf-node((1, -5.4), 0.35, [$C: 0.20$], "C", stroke: hf-leaf-str, fill: white)
  hf-node((3.5, -5.4), 0.3, $0.15$, "R3")
  hf-node((2.5, -7.2), 0.35, [$D: 0.10$], "D", stroke: hf-leaf-str, fill: white)
  hf-node((4.5, -7.2), 0.35, [$E: 0.05$], "E", stroke: hf-leaf-str, fill: white)

  // Edges, node-based
  mid-label("root", "A", (-0.4, 0.1), [_0_])
  mid-label("root", "R", (0.2, 0.1), [_1_])
  mid-label("R", "B", (-0.4, 0.1), [_0_])
  mid-label("R", "R2", (0.2, 0.1), [_1_])
  mid-label("R2", "C", (-0.4, 0.1), [_0_])
  mid-label("R2", "R3", (0.2, 0.1), [_1_])
  mid-label("R3", "D", (-0.4, 0.1), [_0_])
  mid-label("R3", "E", (0.2, 0.1), [_1_])
})

// ── Hamming spheres ──
#let hs-codeword = oklch(55%, 0.15, 260deg)
#let hs-sphere-stroke = oklch(58%, 0.10, 260deg)
#let hs-sphere-fill = oklch(96%, 0.03, 260deg)
#let hs-point = oklch(40%, 0.03, 265deg)
#let hs-label = oklch(35%, 0.02, 265deg)
#let hs-dim = oklch(55%, 0.14, 22deg)

#let hs-draw-sphere(center, radius, noise) = {
  let (cx, cy) = center
  draw.circle(
    center,
    radius: radius,
    stroke: (paint: hs-sphere-stroke, thickness: 0.7pt, dash: "dashed"),
    fill: hs-sphere-fill,
  )
  for p in noise {
    draw.circle((cx + p.at(0), cy + p.at(1)), radius: 0.07, fill: hs-point)
  }
  draw.circle(center, radius: 0.17, fill: hs-codeword)
}

#let hamming-spheres = canvas({
  let r = 1.25
  let cw1 = (1.8, 3.0)
  let cw2 = (6.2, 3.0)
  let cw3 = (4.0, -0.3)

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

  let dim-start = cw1
  let dim-end = (cw1.at(0) + r, cw1.at(1))
  draw.line(dim-start, dim-end, stroke: (paint: hs-dim, thickness: 0.6pt))
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
  draw.content(
    (cw1.at(0) + r / 2, cw1.at(1) + 0.28),
    anchor: "south",
    text(size: 0.7em, fill: hs-dim)[радиус $t$],
  )

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

// ── Hamming groups ──
#let hg-p1 = oklch(52%, 0.15, 260deg)    // p₁ group: blue
#let hg-p2 = oklch(48%, 0.12, 150deg)    // p₂ group: green
#let hg-p4 = oklch(48%, 0.14, 315deg)    // p₄ group: purple
#let hg-data = oklch(38%, 0.03, 265deg)  // data bits and their lines
#let hg-line = oklch(72%, 0.02, 265deg)  // data lines
#let hg-label = oklch(30%, 0.02, 265deg) // bit labels
#let hg-dim = oklch(58%, 0.02, 265deg)   // positions, faint
#let hg-fill = oklch(97%, 0.02, 265deg)  // circle fill

#let hamming-groups = canvas({
  let x = (0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0)
  let cy = 7.0
  let r = 0.42
  let y-top = cy - r

  let data-y = (5.4, 4.5, 3.6, 2.7)
  let data-name = (($d_1$), ($d_2$), ($d_3$), ($d_4$))
  for (i, y) in data-y.enumerate() {
    draw.line((-0.6, y), (6.6, y), stroke: (paint: hg-line, thickness: 0.5pt))
    draw.content((-1.7, y), text(size: 0.7em, fill: hg-data)[#data-name.at(i)])
  }

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

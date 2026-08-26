// m12 diagrams: дерево Хаффмана, сферы Хэмминга, решётка кода, группы Хэмминга.
#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

// ── Дерево Хаффмана ──
#let huffman-tree = canvas({
  let node-stroke = c-bd + t-bd
  let edge-stroke = (paint: c-edge, thickness: t-ed)

  let hf-node(pos, name, radius, body, fill: none) = {
    draw.circle(pos, radius: radius, stroke: node-stroke, fill: fill, name: name)
    draw.content(name, text(size: s-node, fill: c-ink)[#body])
  }

  let hf-edge(fr, to, name, label) = {
    draw.line(fr, to, stroke: edge-stroke, name: name)
    draw.content(name, text(size: s-tiny, fill: c-ink)[#label], fill: white, stroke: none, padding: 2pt)
  }

  let root = (0, 0)
  hf-node(root, "root", 0.75, $1.0$)
  hf-node((1.5, -1.8), "R1", 0.75, $0.60$)
  hf-node((2.5, -3.6), "R2", 0.75, $0.35$)
  hf-node((3.5, -5.4), "R3", 0.75, $0.15$)
  hf-node((-3.5, -1.8), "A", 0.75, $A: 0.40$, fill: c-fl)
  hf-node((-0.5, -3.6), "B", 0.75, $B: 0.25$, fill: c-fl)
  hf-node((1, -5.4), "C", 0.75, $C: 0.20$, fill: c-fl)
  hf-node((2.5, -7.2), "D", 0.75, $D: 0.10$, fill: c-fl)
  hf-node((4.5, -7.2), "E", 0.75, $E: 0.05$, fill: c-fl)

  hf-edge("root", "A", "e-rA", [_0_])
  hf-edge("root", "R1", "e-rR1", [_1_])
  hf-edge("R1", "B", "e-r1B", [_0_])
  hf-edge("R1", "R2", "e-r1r2", [_1_])
  hf-edge("R2", "C", "e-r2C", [_0_])
  hf-edge("R2", "R3", "e-r2r3", [_1_])
  hf-edge("R3", "D", "e-r3D", [_0_])
  hf-edge("R3", "E", "e-r3E", [_1_])
})

// ── Сферы Хэмминга ──
#let hs-sphere-stroke = (paint: c-edge, thickness: t-ed, dash: "dashed")

#let hs-point-fill = c-ink

#let hs-codeword-fill = c-accent

#let hs-dim = c-accent

#let hs-draw-sphere(center, radius, noise) = {
  let (cx, cy) = center
  draw.circle(
    center,
    radius: radius,
    stroke: hs-sphere-stroke,
    fill: c-fl,
  )
  for p in noise {
    draw.circle((cx + p.at(0), cy + p.at(1)), radius: 0.07, fill: hs-point-fill)
  }
  draw.circle(center, radius: 0.17, fill: hs-codeword-fill)
}

#let hamming-spheres = canvas({
  let r = 1.25
  let cw1 = (1.8, 3.0)
  let cw2 = (6.2, 3.0)
  let cw3 = (4.0, -0.3)

  // Точки шума внутри каждой сферы (смещения от центра, |смещение| < r).
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
  let dim-stroke = (paint: hs-dim, thickness: t-hr)
  draw.line(dim-start, dim-end, stroke: dim-stroke)
  draw.line(
    (dim-start.at(0), dim-start.at(1) - 0.12),
    (dim-start.at(0), dim-start.at(1) + 0.12),
    stroke: dim-stroke,
  )
  draw.line(
    (dim-end.at(0), dim-end.at(1) - 0.12),
    (dim-end.at(0), dim-end.at(1) + 0.12),
    stroke: dim-stroke,
  )
  draw.content(
    (cw1.at(0) + r / 2, cw1.at(1) + 0.28),
    anchor: "south",
    text(size: s-cap, fill: c-muted)[радиус $t$],
  )

  draw.content(
    (cw2.at(0), cw2.at(1) + 0.6),
    anchor: "south",
    text(size: s-cap, fill: c-muted)[кодовое слово],
  )
  draw.line(
    (cw2.at(0), cw2.at(1) + 0.42),
    (cw2.at(0), cw2.at(1) + 0.19),
    stroke: dim-stroke,
  )
})

// ── Решётка кода ──
#let cl-n-fill = c-fl

#let cl-n-str = c-bd + t-bd

#let cl-e-str = (paint: c-edge, thickness: t-ed)

#let cl-n-size = 4em
#let cl-n-height = 1.2em

#let cl-node(pos, body, ..args) = node(
  pos,
  text(size: s-node, fill: c-ink)[#body],
  fill: cl-n-fill,
  stroke: cl-n-str,
  width: cl-n-size,
  height: cl-n-height,
  ..args,
)

#let cl-edge(from, to) = edge(from, to, "-", stroke: cl-e-str)

#let code-lattice = diagram(
  node-shape: "rect",
  node-stroke: cl-n-str,
  node-inset: 4pt,
  node-outset: 4pt,
  spacing: 2.5em,
  cl-node((0, 0), $"GF"(2)^3$, name: <full>),
  cl-node((-1.3, 1), $<x, y>$, name: <xy>),
  cl-node((0, 1), $<x, z>$, name: <xz>),
  cl-node((1.3, 1), $<y, z>$, name: <yz>),
  cl-node((-1.3, 2), $<x>$, name: <x>),
  cl-node((0, 2), $<y>$, name: <y>),
  cl-node((1.3, 2), $<z>$, name: <z>),
  cl-node((0, 3), ${0}$, name: <zero>),
  cl-edge(<zero>, <x>),
  cl-edge(<zero>, <y>),
  cl-edge(<zero>, <z>),
  cl-edge(<x>, <xy>),
  cl-edge(<x>, <xz>),
  cl-edge(<y>, <xy>),
  cl-edge(<y>, <yz>),
  cl-edge(<z>, <xz>),
  cl-edge(<z>, <yz>),
  cl-edge(<xy>, <full>),
  cl-edge(<xz>, <full>),
  cl-edge(<yz>, <full>),
)

// ── Группы Хэмминга ──
// Палитра групп паритета (локальная семантика кода). Данные и структура --- на токенах.
#let hg-p1 = oklch(52%, 0.15, 260deg)   // p₁
#let hg-p2 = oklch(48%, 0.12, 150deg)   // p₂
#let hg-p4 = oklch(48%, 0.14, 315deg)   // p₄

#let hg-bit-fill = c-fl

#let hg-data-text = c-ink

#let hg-pos-text = c-muted

#let hg-data-line = (paint: c-edge, thickness: t-ed)

#let hg-conn-thick = t-hi

#let hamming-groups = canvas({
  let x = (0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0)
  let cy = 7.0
  let r = 0.42
  let y-top = cy - r

  let data-y = (5.4, 4.5, 3.6, 2.7)
  let data-name = (($d_1$), ($d_2$), ($d_3$), ($d_4$))
  for (i, y) in data-y.enumerate() {
    draw.line((-0.6, y), (6.6, y), stroke: hg-data-line)
    draw.content((-1.7, y), text(size: s-cap, fill: hg-data-text)[#data-name.at(i)])
  }

  let hg-bit(bx, label, num, color) = {
    draw.circle((bx, cy), radius: r, fill: hg-bit-fill, stroke: (paint: color, thickness: t-bd))
    draw.content((bx, cy), text(size: s-node, fill: hg-data-text)[#label])
    draw.content((bx, cy + 0.8), text(size: s-tiny, fill: hg-pos-text)[#num])
  }
  hg-bit(x.at(0), $p_1$, 1, hg-p1)
  hg-bit(x.at(1), $p_2$, 2, hg-p2)
  hg-bit(x.at(2), $d_1$, 3, hg-data-text)
  hg-bit(x.at(3), $p_4$, 4, hg-p4)
  hg-bit(x.at(4), $d_2$, 5, hg-data-text)
  hg-bit(x.at(5), $d_3$, 6, hg-data-text)
  hg-bit(x.at(6), $d_4$, 7, hg-data-text)

  let hg-edge(bx, bottom, color, dots) = {
    draw.line((bx, y-top), (bx, bottom), stroke: (paint: color, thickness: hg-conn-thick))
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
  hg-edge(x.at(2), data-y.at(0), hg-data-text, (data-y.at(0),))
  hg-edge(x.at(4), data-y.at(1), hg-data-text, (data-y.at(1),))
  hg-edge(x.at(5), data-y.at(2), hg-data-text, (data-y.at(2),))
  hg-edge(x.at(6), data-y.at(3), hg-data-text, (data-y.at(3),))
})

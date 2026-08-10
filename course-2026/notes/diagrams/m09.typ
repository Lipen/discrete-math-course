// Diagrams for the Codes (m10) and SAT (m11) chapters: Huffman, Hamming, implication graph, DPLL.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

// ════════════════════════════════════════════════════════
// Section A --- Huffman tree (Codes, chapter m10-codes.typ)
// ════════════════════════════════════════════════════════

#let hf-str = 0.8pt + oklch(35%, 0.02, 265deg)
#let hf-leaf-str = 1pt + oklch(35%, 0.02, 265deg)

// Huffman tree for A: 0.40, B: 0.25, C: 0.20, D: 0.10, E: 0.05.
#let huffman-tree = canvas({

  // Node positions --- tree structure (y-step = 1.8, units = cm)
  let root = (0, 0)
  let nA = (-3.5, -1.8)
  let nR = (1.5, -1.8) // BCDE
  let nB = (-0.5, -3.6)
  let nR2 = (2.5, -3.6) // CDE
  let nC = (1, -5.4)
  let nR3 = (3.5, -5.4) // DE
  let nD = (2.5, -7.2)
  let nE = (4.5, -7.2)

  // Helper for midpoint label
  let mid-label(p, q, offset, label) = {
    let mx = (p.at(0) + q.at(0)) / 2
    let my = (p.at(1) + q.at(1)) / 2
    draw.line(p, q, stroke: hf-str)
    draw.content((mx + offset.at(0), my + offset.at(1)), label)
  }

  // Helper: labelled circle node (internal or leaf)
  let hf-node(pos, radius, body, stroke: hf-str, ..args) = {
    draw.circle(pos, radius: radius, stroke: stroke, ..args)
    draw.content(pos, body)
  }

  // Edges with labels
  mid-label(root, nA, (-0.4, 0.1), [_0_])
  mid-label(root, nR, (0.2, 0.1), [_1_])
  mid-label(nR, nB, (-0.4, 0.1), [_0_])
  mid-label(nR, nR2, (0.2, 0.1), [_1_])
  mid-label(nR2, nC, (-0.4, 0.1), [_0_])
  mid-label(nR2, nR3, (0.2, 0.1), [_1_])
  mid-label(nR3, nD, (-0.4, 0.1), [_0_])
  mid-label(nR3, nE, (0.2, 0.1), [_1_])

  // Internal nodes (weights)
  hf-node(root, 0.3, $1.0$)
  hf-node(nR, 0.3, $0.60$)
  hf-node(nR2, 0.3, $0.35$)
  hf-node(nR3, 0.3, $0.15$)

  // Leaf nodes (symbols)
  hf-node(nA, 0.35, [$A: 0.40$], stroke: hf-leaf-str, fill: white)
  hf-node(nB, 0.35, [$B: 0.25$], stroke: hf-leaf-str, fill: white)
  hf-node(nC, 0.35, [$C: 0.20$], stroke: hf-leaf-str, fill: white)
  hf-node(nD, 0.35, [$D: 0.10$], stroke: hf-leaf-str, fill: white)
  hf-node(nE, 0.35, [$E: 0.05$], stroke: hf-leaf-str, fill: white)
})

// ════════════════════════════════════════════════════════
// Section B --- Hamming spheres (Codes, chapter m09-codes.typ)
// ════════════════════════════════════════════════════════

#let hs-codeword = oklch(55%, 0.15, 260deg)
#let hs-sphere-stroke = oklch(58%, 0.10, 260deg)
#let hs-sphere-fill = oklch(96%, 0.03, 260deg)
#let hs-point = oklch(40%, 0.03, 265deg)
#let hs-label = oklch(35%, 0.02, 265deg)
#let hs-dim = oklch(55%, 0.14, 22deg)

// Draw a codeword dot with its Hamming sphere and surrounding noise points.
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

// ════════════════════════════════════════════════════════
// Section B2 --- Subspace lattice of GF(2)³ (Codes, chapter m09-codes.typ)
// ════════════════════════════════════════════════════════

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

// Hasse diagram of coordinate subspaces of GF(2)³, ordered by inclusion.
// Structure: 1 zero + 3 axes + 3 planes + 1 full space = 8 nodes (Boolean lattice B₃).
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
  // Cover relations: zero → axes
  cl-edge(<zero>, <x>),
  cl-edge(<zero>, <y>),
  cl-edge(<zero>, <z>),
  // Axes → planes
  cl-edge(<x>, <xy>),
  cl-edge(<x>, <xz>),
  cl-edge(<y>, <xy>),
  cl-edge(<y>, <yz>),
  cl-edge(<z>, <xz>),
  cl-edge(<z>, <yz>),
  // Planes → full space
  cl-edge(<xy>, <full>),
  cl-edge(<xz>, <full>),
  cl-edge(<yz>, <full>),
)

// ════════════════════════════════════════════════════════
// Section C --- SAT diagrams (used by m10-sat.typ)
// ════════════════════════════════════════════════════════

#let c-node = oklch(88%, 0.03, 250deg)
#let c-node-str = oklch(60%, 0.08, 250deg)
#let c-edge = oklch(35%, 0.02, 265deg) + 0.5pt
#let c-label = oklch(35%, 0.02, 265deg)

// Implication graph for: (x or y) and (not x or z) and (not y or not z)
// Clauses:
//   (x or y)    → not x → y,  not y → x
//   (not x or z) → x → z,     not z → not x
//   (not y or not z) → y → not z,  z → not y
//
// Layout: 6 nodes --- x, not x, y, not y, z, not z
// x=(0,1), notx=(0,-1), y=(2,1), noty=(2,-1), z=(4,1), notz=(4,-1)
#let implication-graph-2sat = canvas({
  let r = 0.4
  let positions = (
    ((0, 1.2), $x$),
    ((0, -1.2), $overline(x)$),
    ((2, 1.2), $y$),
    ((2, -1.2), $overline(y)$),
    ((4, 1.2), $z$),
    ((4, -1.2), $overline(z)$),
  )

  // Nodes
  for pair in positions {
    let pos = pair.at(0)
    let label = pair.at(1)
    draw.circle(pos, radius: r, fill: c-node, stroke: c-node-str)
    draw.content(pos, text(size: 0.72em, fill: c-label)[#label])
  }

  // Edges from (x or y): not x → y, not y → x
  draw.line((-0.3, -1.2), (1.7, 1.2), stroke: c-edge, mark: (end: ">"))
  draw.line((1.7, -1.2), (-0.3, 1.2), stroke: c-edge, mark: (end: ">"))

  // Edges from (not x or z): x → z, not z → not x
  draw.line((0.35, 1.2), (3.65, 1.2), stroke: c-edge, mark: (end: ">"))
  draw.line((3.65, -1.2), (0.35, -1.2), stroke: c-edge, mark: (end: ">"))

  // Edges from (not y or not z): y → not z, z → not y
  draw.line((2.35, 1.2), (3.65, -1.2), stroke: c-edge, mark: (end: ">"))
  draw.line((4.35, 1.2), (2.35, -1.2), stroke: c-edge, mark: (end: ">"))
})

// Simpler example for explanation: (x or y) and (not x or y)
// Clauses:
//   (x or y)    → not x → y
//   (not x or y) → x → y
// This formula is satisfiable: set y=true.
#let implication-graph-2sat-simple = canvas({
  let r = 0.4
  draw.circle((0, 0.8), radius: r, fill: c-node, stroke: c-node-str, name: "x")
  draw.content((0, 0.8), text(size: 0.72em, fill: c-label)[$x$])

  draw.circle(
    (0, -0.8),
    radius: r,
    fill: c-node,
    stroke: c-node-str,
    name: "notx",
  )
  draw.content((0, -0.8), text(size: 0.72em, fill: c-label)[$overline(x)$])

  draw.circle((2, 0.8), radius: r, fill: c-node, stroke: c-node-str, name: "y")
  draw.content((2, 0.8), text(size: 0.72em, fill: c-label)[$y$])

  draw.circle(
    (2, -0.8),
    radius: r,
    fill: c-node,
    stroke: c-node-str,
    name: "noty",
  )
  draw.content((2, -0.8), text(size: 0.72em, fill: c-label)[$overline(y)$])

  // Edges
  draw.line((-0.35, -0.8), (1.65, 0.8), stroke: c-edge, mark: (end: ">"))
  draw.line((0.35, 0.8), (1.65, 0.8), stroke: c-edge, mark: (end: ">"))

  // Labels
  draw.content((1, 1.4), anchor: "south", text(size: 0.65em, fill: oklch(
    45%,
    0.02,
    265deg,
  ))[$x or y$])
  draw.content((1, -1.4), anchor: "north", text(size: 0.65em, fill: oklch(
    45%,
    0.02,
    265deg,
  ))[$not x or y$])
})

// ── DPLL decision tree: φ = (x∨y) ∧ (¬x∨y) ∧ (x∨¬y) ∧ (¬x∨¬y) ──
#let dpll-dec-fill = oklch(92%, 0.04, 250deg)
#let dpll-dec-str = oklch(55%, 0.15, 250deg) + 0.8pt
#let dpll-up-fill = oklch(92%, 0.04, 155deg)
#let dpll-up-str = oklch(55%, 0.18, 155deg) + 0.7pt
#let dpll-conf-fill = oklch(92%, 0.06, 22deg)
#let dpll-conf-str = oklch(55%, 0.20, 22deg) + 0.8pt
#let dpll-edge-color = oklch(35%, 0.02, 265deg)
#let dpll-label = oklch(30%, 0.02, 265deg)

// Helper: rounded box with text, returns named node
#let dpll-box(pos, w, h, fill, stroke, title, subtitle, name) = {
  let (cx, cy) = pos
  draw.rect(
    (cx - w / 2, cy - h / 2),
    (cx + w / 2, cy + h / 2),
    radius: 4pt,
    fill: fill,
    stroke: stroke,
    name: name,
  )
  draw.content((cx, cy + 0.15), text(size: 0.55em, fill: dpll-label)[#title])
  if subtitle != none {
    draw.content((cx, cy - 0.2), text(size: 0.5em, fill: luma(45%))[#subtitle])
  }
}

// Helper: X marker for dead ends
#let dpll-dead-end(pos, name) = {
  let (cx, cy) = pos
  draw.line(
    (cx - 0.2, cy - 0.15),
    (cx + 0.2, cy - 0.4),
    stroke: dpll-conf-str,
    name: name + "-x1",
  )
  draw.line(
    (cx + 0.2, cy - 0.15),
    (cx - 0.2, cy - 0.4),
    stroke: dpll-conf-str,
    name: name + "-x2",
  )
}

// Helper: edge between named anchor strings
#let dpll-edge(from-anchor, to-anchor) = {
  draw.line(from-anchor, to-anchor, stroke: dpll-edge-color + 0.7pt)
}

#let dpll-tree = canvas({
  // ── Formula ──
  dpll-box(
    (0, 4.2),
    5.0,
    0.8,
    oklch(96%, 0.01, 260deg),
    oklch(60%, 0.05, 260deg) + 0.5pt,
    $(x or y) and (not x or y) and (x or not y) and (not x or not y)$,
    none,
    "formula",
  )

  // ── Decision ──
  dpll-box(
    (0, 3.0),
    2.0,
    0.6,
    dpll-dec-fill,
    dpll-dec-str,
    [выбор $x$],
    none,
    "decision",
  )
  dpll-edge("formula.south", "decision.north")

  // ── Left branch (x=1) ──
  draw.content((-2.1, 3.3), anchor: "south", text(
    size: 0.6em,
    fill: dpll-label,
  )[$x = 1$])
  dpll-box(
    (-2.1, 1.9),
    2.2,
    0.8,
    dpll-up-fill,
    dpll-up-str,
    [unit propagation],
    [$(not x or y) → y = 1$],
    "up-left",
  )
  dpll-edge("decision.south-west", "up-left.north")

  dpll-box(
    (-2.1, 0.7),
    2.2,
    0.8,
    dpll-conf-fill,
    dpll-conf-str,
    [конфликт],
    [$(not x or not y)$ пуст],
    "conf-left",
  )
  dpll-edge("up-left.south", "conf-left.north")
  dpll-dead-end((-2.1, 0.0), "dead-left")

  // ── Right branch (x=0) ──
  draw.content((2.1, 3.3), anchor: "south", text(
    size: 0.6em,
    fill: dpll-label,
  )[$x = 0$])
  dpll-box(
    (2.1, 1.9),
    2.2,
    0.8,
    dpll-up-fill,
    dpll-up-str,
    [unit propagation],
    [$(x or y) → y = 1$],
    "up-right",
  )
  dpll-edge("decision.south-east", "up-right.north")

  dpll-box(
    (2.1, 0.7),
    2.2,
    0.8,
    dpll-conf-fill,
    dpll-conf-str,
    [конфликт],
    [$(x or not y)$ пуст],
    "conf-right",
  )
  dpll-edge("up-right.south", "conf-right.north")
  dpll-dead-end((2.1, 0.0), "dead-right")
})

// ════════════════════════════════════════════════════════
// Section B4 --- Hamming(7,4) control groups (Codes, chapter m10-codes.typ)
// ════════════════════════════════════════════════════════

#let hg-p1 = oklch(52%, 0.15, 260deg)    // p₁ group: blue
#let hg-p2 = oklch(48%, 0.12, 150deg)    // p₂ group: green
#let hg-p4 = oklch(48%, 0.14, 315deg)    // p₄ group: purple
#let hg-data = oklch(38%, 0.03, 265deg)  // data bits and their lines
#let hg-line = oklch(72%, 0.02, 265deg)  // data lines
#let hg-label = oklch(30%, 0.02, 265deg) // bit labels
#let hg-dim = oklch(58%, 0.02, 265deg)   // positions, faint
#let hg-fill = oklch(97%, 0.02, 265deg)  // circle fill

// The 7-bit codeword on top; four data lines below. A vertical drops from
// each bit to its data lines, and a dot marks every line the bit feeds:
// p₁ feeds d₁, d₂, d₄; p₂ feeds d₁, d₃, d₄; p₄ feeds d₂, d₃, d₄; each dᵢ
// reaches only its own line.
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
  hg-edge(x.at(0), data-y.at(3), hg-p1, (data-y.at(0), data-y.at(1), data-y.at(3)))
  hg-edge(x.at(1), data-y.at(3), hg-p2, (data-y.at(0), data-y.at(2), data-y.at(3)))
  hg-edge(x.at(3), data-y.at(3), hg-p4, (data-y.at(1), data-y.at(2), data-y.at(3)))
  hg-edge(x.at(2), data-y.at(0), hg-data, (data-y.at(0),))
  hg-edge(x.at(4), data-y.at(1), hg-data, (data-y.at(1),))
  hg-edge(x.at(5), data-y.at(2), hg-data, (data-y.at(2),))
  hg-edge(x.at(6), data-y.at(3), hg-data, (data-y.at(3),))
})

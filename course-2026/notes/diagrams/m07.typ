// M06 diagrams --- Boolean Algebra: Karnaugh maps.
#import "../requirements.typ": *
#import cetz: canvas, draw

#let c-km-line = oklch(35%, 0.02, 265deg) + 0.5pt
#let c-km-fill = oklch(88%, 0.03, 155deg)
#let c-km-num = oklch(35%, 0.02, 265deg)

// Karnaugh map for 3 variables (x, y, z).
// Standard layout: rows=yz (00,01,11,10), cols=x (0,1).
#let karnaugh-3var = canvas({
  let s = 1.2 // cell size
  let rows = 4
  let cols = 2

  // Grid
  for i in range(rows + 1) {
    draw.line((0, -i * s), (cols * s, -i * s), stroke: c-km-line)
  }
  for j in range(cols + 1) {
    draw.line((j * s, 0), (j * s, -rows * s), stroke: c-km-line)
  }

  // Row labels (yz)
  let yz = ("00", "01", "11", "10")
  for (i, label) in yz.enumerate() {
    draw.content((-0.4, -(i + 0.5) * s), anchor: "east", text(
      size: 0.72em,
      fill: c-km-num,
    )[#label])
  }

  // Column label (x)
  draw.content((0.5 * s, 0.35), anchor: "south", text(
    size: 0.72em,
    fill: c-km-num,
  )[$x$])

  // Column header values
  for j in range(cols) {
    draw.content(((j + 0.5) * s, 0.25), anchor: "south", text(
      size: 0.65em,
      fill: c-km-num,
    )[#j])
  }

  // Axis labels
  draw.content((-1.0, -2 * s), anchor: "east", text(
    size: 0.72em,
    fill: c-km-num,
  )[$y z$])
})

// Karnaugh map for 4 variables (w, x, y, z).
// Standard layout: rows=yz (00,01,11,10), cols=wx (00,01,11,10).
// Gray code ordering on both axes.
#let karnaugh-4var = canvas({
  let s = 1.0
  let rows = 4
  let cols = 4

  // Grid
  for i in range(rows + 1) {
    draw.line((0, -i * s), (cols * s, -i * s), stroke: c-km-line)
  }
  for j in range(cols + 1) {
    draw.line((j * s, 0), (j * s, -rows * s), stroke: c-km-line)
  }

  // Row labels (yz) in Gray code
  let yz = ("00", "01", "11", "10")
  for (i, label) in yz.enumerate() {
    draw.content((-0.4, -(i + 0.5) * s), anchor: "east", text(
      size: 0.72em,
      fill: c-km-num,
    )[#label])
  }

  // Column labels (wx) in Gray code
  let wx = ("00", "01", "11", "10")
  for (j, label) in wx.enumerate() {
    draw.content(((j + 0.5) * s, 0.25), anchor: "south", text(
      size: 0.65em,
      fill: c-km-num,
    )[#label])
  }

  // Axis labels
  draw.content((-0.8, -2 * s), anchor: "east", text(
    size: 0.72em,
    fill: c-km-num,
  )[$y z$])
  draw.content((2 * s, 0.7), anchor: "south", text(
    size: 0.72em,
    fill: c-km-num,
  )[$w x$])
})

// Example: Karnaugh map for f(x,y,z) = xy + xz + yz (majority function).
// Filled cells show where f = 1.
#let karnaugh-3var-majority = canvas({
  let s = 1.2
  let rows = 4
  let cols = 2

  // Grid
  for i in range(rows + 1) {
    draw.line((0, -i * s), (cols * s, -i * s), stroke: c-km-line)
  }
  for j in range(cols + 1) {
    draw.line((j * s, 0), (j * s, -rows * s), stroke: c-km-line)
  }

  // Filled cells: minterms where majority(x,y,z)=1
  // yz=00: x=0→0, x=1→0
  // yz=01: x=0→0, x=1→1 (cell row=1, col=1)
  // yz=11: x=0→1 (row=2, col=0), x=1→1 (row=2, col=1)
  // yz=10: x=0→0, x=1→1 (row=3, col=1)
  let ones = ((1, 1), (2, 0), (2, 1), (3, 1))
  for (row, col) in ones {
    draw.rect(
      (col * s, -row * s),
      ((col + 1) * s, -(row + 1) * s),
      fill: c-km-fill,
      stroke: none,
    )
  }

  // Cell labels
  for (row, col) in ones {
    draw.content(((col + 0.5) * s, -(row + 0.5) * s), text(
      size: 0.8em,
      fill: c-km-num,
    )[1])
  }

  // Row labels (yz)
  let yz = ("00", "01", "11", "10")
  for (i, label) in yz.enumerate() {
    draw.content((-0.4, -(i + 0.5) * s), anchor: "east", text(
      size: 0.72em,
      fill: c-km-num,
    )[#label])
  }

  // Column labels
  draw.content((0.5 * s, 0.35), anchor: "south", text(
    size: 0.72em,
    fill: c-km-num,
  )[$x$])
  for j in range(cols) {
    draw.content(((j + 0.5) * s, 0.25), anchor: "south", text(
      size: 0.65em,
      fill: c-km-num,
    )[#j])
  }

  draw.content((-1.0, -2 * s), anchor: "east", text(
    size: 0.72em,
    fill: c-km-num,
  )[$y z$])
})

// ── ROBDD for f(x,y) = x xor y ──
// Order x < y. Shannon expansion: f = ¬x·f(0,y) ∨ x·f(1,y).
// f(0,y) = y (identity), f(1,y) = ¬y (negation).
// 3 internal nodes + 2 shared terminals.
// lo = dashed (var=0), hi = solid (var=1).

#let bdd-lo = oklch(55%, 0.10, 22deg)
#let bdd-hi = oklch(55%, 0.12, 250deg)
#let bdd-term-str = oklch(35%, 0.02, 265deg) + 0.8pt
#let bdd-label = oklch(30%, 0.02, 265deg)

// Internal node: circle with variable label
#let bdd-node(pos, var, name) = {
  draw.circle(pos, radius: 0.38,
    fill: oklch(90%, 0.02, 260deg),
    stroke: oklch(55%, 0.06, 260deg) + 0.7pt,
    name: name)
  draw.content(pos, text(size: 0.75em, weight: "semibold", fill: bdd-label)[#var])
}

// Terminal node: square with 0 or 1
#let bdd-term(pos, val, name) = {
  let (cx, cy) = pos
  draw.rect((cx - 0.28, cy - 0.28), (cx + 0.28, cy + 0.28),
    radius: 2pt, fill: white, stroke: bdd-term-str, name: name)
  draw.content(pos, text(size: 0.8em, fill: bdd-label)[#val])
}

// lo-edge: dashed, labelled 0
#let bdd-lo-edge(from-anchor, to-anchor) = {
  draw.line(from-anchor, to-anchor,
    stroke: (paint: bdd-lo, thickness: 0.7pt, dash: "dashed"))
}

// hi-edge: solid, labelled 1
#let bdd-hi-edge(from-anchor, to-anchor) = {
  draw.line(from-anchor, to-anchor,
    stroke: (paint: bdd-hi, thickness: 0.8pt))
}

#let bdd-xor = canvas({
  // ── Level 0: root ──
  bdd-node((0, 2.8), $x$, "x")

  // ── Level 1: y-nodes (cofactors) ──
  bdd-node((-1.8, 1.2), $y$, "y-lo")
  bdd-node((1.8, 1.2), $y$, "y-hi")

  // ── Level 2: shared terminals ──
  // 0 terminal centered between the two nodes that point to it
  bdd-term((-0.8, -0.3), 0, "t0")
  bdd-term((0.8, -0.3), 1, "t1")

  // ── Edges: root → cofactors ──
  bdd-lo-edge("x.south-west", "y-lo.north")
  bdd-hi-edge("x.south-east", "y-hi.north")

  // Edge labels (midpoint of x→y edges)
  draw.content((-0.9, 2.1), text(size: 0.55em, fill: bdd-lo)[$0$])
  draw.content((0.9, 2.1), text(size: 0.55em, fill: bdd-hi)[$1$])

  // ── Edges: y-lo → terminals ──
  // y-lo computes f(0,y) = y: lo→0, hi→1
  bdd-lo-edge("y-lo.south-west", "t0.north")
  bdd-hi-edge("y-lo.south-east", "t1.north")

  // ── Edges: y-hi → terminals ──
  // y-hi computes f(1,y) = ¬y: lo→1, hi→0
  bdd-lo-edge("y-hi.south-west", "t1.north-west")
  bdd-hi-edge("y-hi.south-east", "t0.north-east")

  // ── Cofactor labels ──
  draw.content((-2.2, 1.2), anchor: "east",
    text(size: 0.52em, fill: bdd-lo)[$x!=!0$])
  draw.content((2.2, 1.2), anchor: "west",
    text(size: 0.52em, fill: bdd-hi)[$x!=!1$])
})

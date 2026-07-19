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

// ── ROBDD for f(x,y) = x xor y with truth table ──
#let bdd-lo-color = oklch(50%, 0.08, 22deg)
#let bdd-hi-color = oklch(50%, 0.08, 250deg)
#let bdd-label = oklch(35%, 0.02, 265deg)
#let bdd-node-fill = oklch(88%, 0.03, 250deg)
#let bdd-node-str = oklch(60%, 0.08, 250deg) + 0.7pt

// Helper: internal node (circle with variable name)
#let bdd-var(pos, var-name, node-name) = {
  draw.circle(
    pos,
    radius: 0.42,
    fill: bdd-node-fill,
    stroke: bdd-node-str,
    name: node-name,
  )
  draw.content(pos, text(size: 0.8em, fill: bdd-label)[#var-name])
}

// Helper: terminal node (square with value 0 or 1)
#let bdd-term(pos, val, node-name) = {
  let (cx, cy) = pos
  draw.rect(
    (cx - 0.3, cy - 0.3),
    (cx + 0.3, cy + 0.3),
    radius: 2pt,
    fill: white,
    stroke: bdd-node-str,
    name: node-name,
  )
  draw.content(pos, text(size: 0.8em, fill: bdd-label)[#val])
}

// Helper: lo-edge (dashed, uses anchor strings directly)
#let bdd-lo(from-anchor, to-anchor) = {
  draw.line(from-anchor, to-anchor, stroke: (
    paint: bdd-lo-color,
    thickness: 0.6pt,
    dash: "dashed",
  ))
}

// Helper: hi-edge (solid)
#let bdd-hi(from-anchor, to-anchor) = {
  draw.line(from-anchor, to-anchor, stroke: (
    paint: bdd-hi-color,
    thickness: 0.7pt,
  ))
}

#let bdd-xor = canvas({
  // ── BDD nodes ──
  bdd-var((0, 2.2), $x$, "x")
  bdd-var((-1.3, 0.2), $y$, "y-lo")
  bdd-var((1.3, 0.2), $y$, "y-hi")

  bdd-term((-1.0, -1.5), 0, "t0-left")
  bdd-term((0.0, -1.5), 1, "t1-left")
  bdd-term((1.0, -1.5), 0, "t0-right")
  bdd-term((2.0, -1.5), 1, "t1-right")

  // ── Edges between named nodes ──
  bdd-lo("x.south", "y-lo.north")
  bdd-hi("x.south-east", "y-hi.north")

  bdd-lo("y-lo.south", "t0-left.north")
  bdd-hi("y-lo.south-east", "t1-left.north")

  bdd-lo("y-hi.south", "t1-right.north")
  bdd-hi("y-hi.south-east", "t0-right.north")

  // Edge labels at midpoints
  draw.content((-0.7, 1.2), text(size: 0.55em, fill: bdd-lo-color)[$0$])
  draw.content((0.7, 1.2), text(size: 0.55em, fill: bdd-hi-color)[$1$])

  // ── Truth table (right side) ──
  let tx = 3.8
  for (col, hdr) in (($x$, $y$, $f$),).enumerate() {
    for (k, label) in hdr.enumerate() {
      draw.content((tx + k * 0.6, 2.5), text(
        size: 0.6em,
        weight: "bold",
        fill: bdd-label,
      )[#label])
    }
  }
  for (k, (vx, vy, vf)) in (
    (0, 0, 0),
    (0, 1, 1),
    (1, 0, 1),
    (1, 1, 0),
  ).enumerate() {
    let y = 1.8 - k * 0.55
    draw.content((tx, y), text(size: 0.6em, fill: bdd-label)[#vx])
    draw.content((tx + 0.6, y), text(size: 0.6em, fill: bdd-label)[#vy])
    draw.content((tx + 1.2, y), text(
      size: 0.6em,
      weight: "bold",
      fill: bdd-label,
    )[#vf])
  }
})

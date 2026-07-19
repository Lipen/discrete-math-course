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
// Metaphor: decision flowchart + truth table correspondence.
// Each path through the BDD maps to one row of the truth table.
#let c-bdd-node = oklch(88%, 0.03, 250deg)
#let c-bdd-str = oklch(60%, 0.08, 250deg) + 0.7pt
#let c-bdd-lo-color = oklch(50%, 0.08, 22deg)
#let c-bdd-hi-color = oklch(50%, 0.08, 250deg)
#let c-bdd-lo = c-bdd-lo-color + 0.5pt
#let c-bdd-hi = c-bdd-hi-color + 0.7pt
#let c-bdd-label = oklch(35%, 0.02, 265deg)

#let bdd-xor = canvas({
  let r = 0.42

  // ── BDD (left side) ──
  // Internal nodes
  draw.circle((0, 2.2), radius: r, fill: c-bdd-node, stroke: c-bdd-str, name: "x")
  draw.content((0, 2.2), text(size: 0.8em, fill: c-bdd-label)[$x$])

  draw.circle((-1.3, 0.2), radius: r, fill: c-bdd-node, stroke: c-bdd-str, name: "y1")
  draw.content((-1.3, 0.2), text(size: 0.8em, fill: c-bdd-label)[$y$])

  draw.circle((1.3, 0.2), radius: r, fill: c-bdd-node, stroke: c-bdd-str, name: "y2")
  draw.content((1.3, 0.2), text(size: 0.8em, fill: c-bdd-label)[$y$])

  // Terminal nodes
  draw.rect((-1.3, -1.8), (-0.7, -1.2), radius: 2pt, fill: white, stroke: c-bdd-str)
  draw.content((-1, -1.5), text(size: 0.8em, fill: c-bdd-label)[0])
  draw.rect((-0.3, -1.8), (0.3, -1.2), radius: 2pt, fill: white, stroke: c-bdd-str)
  draw.content((0, -1.5), text(size: 0.8em, fill: c-bdd-label)[1])
  draw.rect((0.7, -1.8), (1.3, -1.2), radius: 2pt, fill: white, stroke: c-bdd-str)
  draw.content((1, -1.5), text(size: 0.8em, fill: c-bdd-label)[0])
  draw.rect((1.7, -1.8), (2.3, -1.2), radius: 2pt, fill: white, stroke: c-bdd-str)
  draw.content((2, -1.5), text(size: 0.8em, fill: c-bdd-label)[1])

  // Edges: lo=dashed, hi=solid
  draw.line((-0.3, 1.9), (-1.0, 0.55), stroke: (paint: c-bdd-lo-color, thickness: 0.6pt, dash: "dashed"))
  draw.line((0.3, 1.9), (1.0, 0.55), stroke: (paint: c-bdd-hi-color, thickness: 0.7pt))
  draw.content((-0.8, 1.3), text(size: 0.55em, fill: c-bdd-lo-color)[$0$])
  draw.content((0.8, 1.3), text(size: 0.55em, fill: c-bdd-hi-color)[$1$])

  // y1 → leaves
  draw.line((-1.15, -0.15), (-1.15, -1.15), stroke: (paint: c-bdd-lo-color, thickness: 0.6pt, dash: "dashed"))
  draw.line((-1.45, -0.15), (-0.15, -1.15), stroke: (paint: c-bdd-hi-color, thickness: 0.7pt))

  // y2 → leaves
  draw.line((1.45, -0.15), (2.15, -1.15), stroke: (paint: c-bdd-lo-color, thickness: 0.6pt, dash: "dashed"))
  draw.line((1.15, -0.15), (0.85, -1.15), stroke: (paint: c-bdd-hi-color, thickness: 0.7pt))

  // ── Truth table (right side) ──
  let tx = 3.5
  // Header
  draw.content((tx, 2.5), text(size: 0.6em, weight: "bold", fill: c-bdd-label)[$x$])
  draw.content((tx + 0.5, 2.5), text(size: 0.6em, weight: "bold", fill: c-bdd-label)[$y$])
  draw.content((tx + 1.0, 2.5), text(size: 0.6em, weight: "bold", fill: c-bdd-label)[$f$])

  let rows = ((0, 0, 0), (0, 1, 1), (1, 0, 1), (1, 1, 0))
  for (k, row) in rows.enumerate() {
    let y = 1.8 - k * 0.55
    draw.content((tx, y), text(size: 0.6em, fill: c-bdd-label)[#row.at(0)])
    draw.content((tx + 0.5, y), text(size: 0.6em, fill: c-bdd-label)[#row.at(1)])
    draw.content((tx + 1.0, y), text(size: 0.6em, weight: "bold", fill: c-bdd-label)[#row.at(2)])
  }

  // Connecting lines: truth table rows → BDD paths
  // (0,0)→0: through x-lo, y-lo
  // (0,1)→1: through x-lo, y-hi
  // (1,0)→1: through x-hi, y-lo
  // (1,1)→0: through x-hi, y-hi
})

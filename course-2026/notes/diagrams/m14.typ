// M14 diagrams — Turing Machines.
#import "../requirements.typ": *
#import cetz: canvas, draw

#let c-tape = oklch(90%, 0.02, 80deg)
#let c-tape-str = oklch(35%, 0.02, 265deg) + 0.4pt
#let c-head = oklch(88%, 0.03, 250deg)
#let c-head-str = oklch(60%, 0.08, 250deg) + 0.6pt
#let c-ctrl = oklch(88%, 0.05, 155deg)
#let c-ctrl-str = oklch(55%, 0.18, 155deg) + 0.7pt
#let c-label = oklch(35%, 0.02, 265deg)

// Schematic of a Turing machine: tape, head, finite control.
// The tape is a row of cells; the head reads/writes the current cell.
// The finite control holds the current state and transition logic.
#let turing-machine = canvas({
  // Tape cells — horizontal row
  let n = 8
  let cell = 0.8
  for i in range(n) {
    let x = (i - n / 2 + 0.5) * cell
    draw.rect((x, -0.4), (x + cell, 0.4), fill: c-tape, stroke: c-tape-str)
    // Show some sample symbols
    let syms = ("0", "1", "1", "0", "1", "0", "0", "1")
    draw.content((x + cell / 2, 0), text(size: 0.7em, fill: c-label)[#syms.at(
      i,
    )])
  }

  // Tape left/right continuation markers
  draw.content((-n / 2 * cell - 0.4, 0), text(
    size: 0.6em,
    fill: luma(50%),
  )[$dots$])
  draw.content((n / 2 * cell + 0.4, 0), text(
    size: 0.6em,
    fill: luma(50%),
  )[$dots$])

  // Head — triangle/arrow pointing down to the tape
  let head-x = 0
  draw.line((head-x, -0.5), (head-x - 0.3, -0.9), stroke: c-head-str)
  draw.line((head-x, -0.5), (head-x + 0.3, -0.9), stroke: c-head-str)
  draw.line((head-x - 0.3, -0.9), (head-x + 0.3, -0.9), stroke: c-head-str)
  draw.content((head-x, -0.72), text(size: 0.55em, fill: c-label)[↓])

  // Finite control box
  let ctrl-w = 2.5
  let ctrl-h = 1.2
  draw.rect(
    (-ctrl-w / 2, -1.6),
    (ctrl-w / 2, -2.8),
    radius: 4pt,
    fill: c-ctrl,
    stroke: c-ctrl-str,
  )
  draw.content((0, -1.95), text(size: 0.7em, fill: c-label)[$q_i$])
  draw.content((0, -2.35), text(size: 0.6em, fill: luma(50%))[конечное])

  // Connection head → control
  draw.line((head-x, -0.9), (head-x, -1.6), stroke: c-head-str)

  // Tape label
  draw.content((-n / 2 * cell, 0.7), anchor: "west", text(
    size: 0.72em,
    fill: c-label,
  )[Лента:])
})

// Reduction diagram: HALT ≤_m EMPTY
// Shows the reduction function f that transforms HALT instances into EMPTY instances.
#let reduction-halt-empty = canvas({
  let c-box = oklch(88%, 0.03, 250deg)
  let c-box-str = oklch(60%, 0.08, 250deg) + 0.5pt
  let c-arrow = oklch(35%, 0.02, 265deg) + 0.6pt
  let c-label = oklch(35%, 0.02, 265deg)

  // Input box
  draw.rect((-1.5, -0.5), (1.5, 0.5), fill: c-box, stroke: c-box-str)
  draw.content((0, 0), text(
    size: 0.7em,
    fill: c-label,
  )[$chevron.l M chevron.r w$])

  // f arrow
  draw.line((1.8, 0), (3.2, 0), stroke: c-arrow, mark: (end: ">"))
  draw.content((2.5, 0.3), anchor: "south", text(
    size: 0.65em,
    fill: c-label,
  )[$f$])

  // f box
  draw.rect((3.5, -0.5), (6.5, 0.5), fill: none, stroke: c-box-str)
  draw.content((5, 0), text(
    size: 0.7em,
    fill: c-label,
  )[$chevron.l M' chevron.r$])

  // Result arrow
  draw.line((6.8, 0), (8.2, 0), stroke: c-arrow, mark: (end: ">"))

  // Output labels
  draw.content((5, 0.9), anchor: "south", text(
    size: 0.55em,
    fill: luma(50%),
  )[описание МТ,])
  draw.content((5, 0.6), anchor: "south", text(
    size: 0.55em,
    fill: luma(50%),
  )[чей язык пуст iff M(w) останавливается])
})

// m24 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

#let c-tape = oklch(90%, 0.02, 80deg)

#let c-tape-str = oklch(35%, 0.02, 265deg) + 0.4pt

#let c-head-str = oklch(60%, 0.08, 250deg) + 0.6pt

#let c-ctrl = oklch(88%, 0.05, 155deg)

#let c-ctrl-str = oklch(55%, 0.18, 155deg) + 0.7pt

#let c-label = oklch(35%, 0.02, 265deg)

#let turing-machine = canvas({
  // Tape cells --- horizontal row
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

  // Head --- triangle/arrow pointing down to the tape
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

  // Connection head -> control
  draw.line((head-x, -0.9), (head-x, -1.6), stroke: c-head-str)

  // Tape label
  draw.content((-n / 2 * cell, 0.7), anchor: "west", text(
    size: 0.72em,
    fill: c-label,
  )[Лента:])
})

#let tm-computation = canvas({

  let cell = 0.75
  let n = 6
  let c-step-label = oklch(50%, 0.04, 265deg)
  let c-head-marker = oklch(55%, 0.18, 22deg)
  let c-accept = oklch(55%, 0.18, 155deg)

  // Helper: draw one configuration row
  let config-row(y, cells, head-idx, state-label, state-color: c-label) = {
    // Tape cells
    for (i, sym) in cells.enumerate() {
      let x = (i - n/2 + 0.5) * cell
      draw.rect((x, y - 0.35), (x + cell, y + 0.35), fill: c-tape, stroke: c-tape-str)
      draw.content((x + cell/2, y), text(size: 0.65em, fill: c-label)[#sym])
    }
    // State label on the left
    draw.content((-n/2 * cell - 0.35, y), anchor: "east", text(
      size: 0.65em,
      fill: state-color,
      weight: "bold",
    )[#state-label])
    // Head marker below current cell
    let hx = (head-idx - n/2 + 0.5) * cell + cell/2
    draw.content((hx, y - 0.6), text(size: 0.7em, fill: c-head-marker)[↓])
  }

  // Step 1: q₀ 1 1 □ □ □
  config-row(3.0, ($1$, $1$, $Blank$, $Blank$, $Blank$, $Blank$), 0, $q_0$)

  // Arrow between rows
  draw.content((-n/2 * cell - 0.35, 2.35), text(size: 0.6em, fill: luma(50%))[↓])
  draw.content((-0.2, 2.35), text(size: 0.6em, fill: luma(50%))[читает 1, пишет 1, $R$])

  // Step 2: 1 q₁ 1 ␣ ␣ ␣
  config-row(1.6, ($1$, $1$, $Blank$, $Blank$, $Blank$, $Blank$), 1, $q_1$)

  draw.content((-n/2 * cell - 0.35, 0.95), text(size: 0.6em, fill: luma(50%))[↓])
  draw.content((-0.2, 0.95), text(size: 0.6em, fill: luma(50%))[читает 1, пишет 1, $R$])

  // Step 3: 1 1 q₀ ␣ ␣ ␣
  config-row(0.2, ($1$, $1$, $Blank$, $Blank$, $Blank$, $Blank$), 2, $q_0$)

  draw.content((-n/2 * cell - 0.35, -0.45), text(size: 0.6em, fill: luma(50%))[↓])
  draw.content((-0.2, -0.45), text(size: 0.6em, fill: luma(50%))[читает ␣, принимает])

  // Step 4: 1 1 ␣ q_accept ␣ ␣
  config-row(-1.2, ($1$, $1$, $Blank$, $Blank$, $Blank$, $Blank$), 2, qAccept, state-color: c-accept)
})

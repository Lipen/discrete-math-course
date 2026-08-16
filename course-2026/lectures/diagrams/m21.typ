// M21 diagrams --- Turing machine schematic.
// Скопировано из notes/diagrams/m14.typ, чтобы лекции не зависели от книги.
#import "@preview/cetz:0.5.2": canvas, draw

#let c-tape = oklch(90%, 0.02, 80deg)
#let c-tape-str = oklch(35%, 0.02, 265deg) + 0.4pt
#let c-head = oklch(88%, 0.03, 250deg)
#let c-head-str = oklch(60%, 0.08, 250deg) + 0.6pt
#let c-ctrl = oklch(88%, 0.05, 155deg)
#let c-ctrl-str = oklch(55%, 0.18, 155deg) + 0.7pt
#let c-label = oklch(35%, 0.02, 265deg)

#let turing-machine = canvas({
  let n = 8
  let cell = 0.8
  for i in range(n) {
    let x = (i - n / 2 + 0.5) * cell
    draw.rect((x, -0.4), (x + cell, 0.4), fill: c-tape, stroke: c-tape-str)
    let syms = ("0", "1", "1", "0", "1", "0", "0", "1")
    draw.content((x + cell / 2, 0), text(size: 0.7em, fill: c-label)[#syms.at(
      i,
    )])
  }

  draw.content((-n / 2 * cell - 0.4, 0), text(
    size: 0.6em,
    fill: luma(50%),
  )[$dots$])
  draw.content((n / 2 * cell + 0.4, 0), text(
    size: 0.6em,
    fill: luma(50%),
  )[$dots$])

  let head-x = 0
  draw.line((head-x, -0.5), (head-x - 0.3, -0.9), stroke: c-head-str)
  draw.line((head-x, -0.5), (head-x + 0.3, -0.9), stroke: c-head-str)
  draw.line((head-x - 0.3, -0.9), (head-x + 0.3, -0.9), stroke: c-head-str)
  draw.content((head-x, -0.72), text(size: 0.55em, fill: c-label)[↓])

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

  draw.line((head-x, -0.9), (head-x, -1.6), stroke: c-head-str)

  draw.content((-n / 2 * cell, 0.7), anchor: "west", text(
    size: 0.72em,
    fill: c-label,
  )[Лента:])
})

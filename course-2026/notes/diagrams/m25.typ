// M25 diagrams --- Abstract interpretation.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

#let c-elem = oklch(55%, 0.10, 250deg)
#let c-hi = oklch(58%, 0.22, 22deg)
#let c-edge = oklch(35%, 0.02, 265deg)
#let c-text = oklch(35%, 0.02, 265deg)

// Widening for the counter loop: the naive intervals [0,0], [0,1], [0,2], ...
// keep growing and never stabilize; the widening operator (nabla) drops the
// growing upper bound and lands on [0, +inf) in two steps.
#let widening = canvas({
  // value axis
  draw.line((-0.5, -0.6), (11.5, -0.6), stroke: (
    paint: c-edge,
    thickness: 0.7pt,
  ))
  draw.content((0, -1.4), anchor: "center")[$0$]
  draw.content((11.5, -1.4), anchor: "center")[значение]

  // naive iteration intervals [0, k]
  for k in range(4) {
    draw.line((0, k), (k, k), stroke: (paint: c-elem, thickness: 0.9pt))
    draw.content((-0.4, k), anchor: "east", fill: c-text)[$[0, #k]$]
  }

  // the iteration does not stop
  draw.content((3.6, 3), anchor: "west", fill: c-text)[$dots$]

  // widening result
  draw.line((0, 5), (11, 5), stroke: (paint: c-hi, thickness: 2.2pt))
  draw.content((11.3, 5), anchor: "west", fill: c-hi)[$[0, +oo)$]

  // the widening jump
  draw.line(
    (3, 3),
    (1.2, 4.6),
    stroke: (paint: c-hi, thickness: 1.2pt),
    marker: (end: "arrow"),
  )
  draw.content((2.4, 4.0), anchor: "north", fill: c-hi)[$nabla$]
})

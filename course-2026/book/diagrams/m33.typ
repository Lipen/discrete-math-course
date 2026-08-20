// M33 diagrams --- Intuitionism: Kripke model of two worlds.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

#let k-node-str = 0.6pt + oklch(55%, 0.08, 250deg)
#let k-node-fill = oklch(92%, 0.03, 250deg)
#let k-forced-fill = oklch(92%, 0.06, 155deg)
#let k-edge = 0.6pt + oklch(35%, 0.02, 265deg)
#let k-label = oklch(30%, 0.02, 265deg)

// Kripke model: two worlds u < v, valuation V(p) = {v}.
#let kripke-two-worlds = canvas({
  // World u (left, p not forced).
  draw.circle((-1.5, 0), radius: 0.5, fill: k-node-fill, stroke: k-node-str, name: "u")
  draw.content((-1.5, 0), text(size: 0.8em, fill: k-label)[$u$])
  draw.content((-1.5, -0.9), text(size: 0.55em, fill: luma(45%))[$p$ не принуждается])

  // World v (right, p forced).
  draw.circle((1.5, 0), radius: 0.5, fill: k-forced-fill, stroke: (
    paint: oklch(50%, 0.16, 155deg),
    thickness: 0.8pt,
  ), name: "v")
  draw.content((1.5, 0), text(size: 0.8em, fill: k-label)[$v$])
  draw.content((1.5, -0.9), text(size: 0.55em, fill: luma(45%))[$p$ принуждается])

  // Accessibility edge u -> v.
  draw.line("u", "v", stroke: k-edge, mark: (end: ">"))
  draw.content((0, 0.35), text(size: 0.55em, fill: luma(45%))[$u <= v$])

  draw.content((0, -1.6), text(
    size: 0.55em,
    fill: luma(50%),
  )[оценка: $V(p) = {v}$])
})

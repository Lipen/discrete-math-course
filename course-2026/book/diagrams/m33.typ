// m33 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

#let k-node-str = 0.6pt + oklch(55%, 0.08, 250deg)

#let k-node-fill = oklch(92%, 0.03, 250deg)

#let k-forced-fill = oklch(92%, 0.06, 155deg)

#let k-edge = 0.6pt + oklch(35%, 0.02, 265deg)

#let k-label = oklch(30%, 0.02, 265deg)

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

#let kripke-umbrella = canvas({
  // World w0 (root, bottom left; neither p nor q forced).
  draw.circle((-1.8, 0), radius: 0.5, fill: k-node-fill, stroke: k-node-str, name: "w0")
  draw.content((-1.8, 0), text(size: 0.8em, fill: k-label)[$w_0$])
  draw.content((-1.8, -0.9), text(size: 0.55em, fill: luma(45%))[ни $p$, ни $q$ не принуждаются])

  // World w1 (top, both p and q forced).
  draw.circle((0.4, 2), radius: 0.5, fill: k-forced-fill, stroke: (
    paint: oklch(50%, 0.16, 155deg),
    thickness: 0.8pt,
  ), name: "w1")
  draw.content((0.4, 2), text(size: 0.8em, fill: k-label)[$w_1$])
  draw.content((0.4, 1.05), text(size: 0.55em, fill: luma(45%))[$p$ и $q$ принуждаются])

  // World w1' (top, p forced, q not).
  draw.circle((2.2, 2), radius: 0.5, fill: k-forced-fill, stroke: (
    paint: oklch(50%, 0.16, 155deg),
    thickness: 0.8pt,
  ), name: "w1'")
  draw.content((2.2, 2), text(size: 0.8em, fill: k-label)[$w_1'$])
  draw.content((2.2, 1.05), text(size: 0.55em, fill: luma(45%))[$p$ принуждается, $q$ --- нет])

  // Accessibility edges w0 -> w1 and w0 -> w1' (umbrella ribs).
  draw.line("w0", (-1.8, 1.5), (2.2, 1.5), "w1'", stroke: k-edge, mark: (end: ">"))
  draw.line("w0", (-1.8, 1.5), (0.4, 1.5), "w1", stroke: k-edge, mark: (end: ">"))

  draw.content((0.6, -1.7), text(
    size: 0.55em,
    fill: luma(50%),
  )[оценка: $V(p) = {w_1, w_1'}$, $V(q) = {w_1}$])
})

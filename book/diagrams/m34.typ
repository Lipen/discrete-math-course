#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

#let k-radius = 0.55

#let k-cap-gap = 1.0

#let k-edge = t-ed + c-edge

// k-forced-str: зелёная обводка принуждающего мира.
#let k-forced-str = oklch(50%, 0.16, 155deg)

#let kripke-world(
  pos,
  name,
  lbl,
  caption,
  fill: c-fl,
  stroke: t-bd + c-bd,
  cap-dy: k-cap-gap,
) = {
  let (x, y) = pos
  draw.circle(pos, radius: k-radius, fill: fill, stroke: stroke, name: name)
  draw.content(name, text(size: s-node, fill: c-ink)[#lbl])
  draw.content((x, y - cap-dy), text(size: s-cap, fill: c-muted)[#caption])
}

// ── Два мира: p принуждается только в v ──
#let kripke-two-worlds = canvas({
  kripke-world((-1.5, 0), "u", $u$, [$p$ не принуждается])
  kripke-world(
    (1.5, 0),
    "v",
    $v$,
    [$p$ принуждается],
    fill: c-atom,
    stroke: t-bd + k-forced-str,
  )

  draw.line(
    "u.east",
    "v.west",
    stroke: k-edge,
    mark: (end: ">", fill: c-edge),
    name: "uv",
  )
  draw.content((0, 0.32), text(size: s-tiny, fill: c-muted)[$u <= v$])

  draw.content((0, -1.7), text(
    size: s-cap,
    fill: c-muted,
  )[оценка: $V(p) = {v}$])
})

// ── Зонтик: монотонность истинности при движении вверх ──
#let kripke-umbrella = canvas({
  kripke-world((-1.8, 0), "w0", $w_0$, [ни $p$, ни $q$ не принуждаются])
  kripke-world(
    (0.0, 2),
    "w1",
    $w_1$,
    [$p$ и $q$ принуждаются],
    fill: c-atom,
    stroke: t-bd + k-forced-str,
    cap-dy: 1.2,
  )
  kripke-world(
    (3.2, 2),
    "w1'",
    $w_1'$,
    [$p$ принуждается, $q$ --- нет],
    fill: c-atom,
    stroke: t-bd + k-forced-str,
    cap-dy: 1.2,
  )

  draw.line(
    "w0",
    (-1.8, 1.3),
    (-0.70, 1.3),
    (-0.389, 1.611),
    stroke: k-edge,
    mark: (end: (symbol: ">", fill: c-edge)),
    name: "e1",
  )
  draw.line(
    "w0",
    (-1.8, 1.3),
    (2.50, 1.3),
    (2.811, 1.611),
    stroke: k-edge,
    mark: (end: (symbol: ">", fill: c-edge)),
    name: "e2",
  )

  draw.content((0.7, -1.75), text(
    size: s-cap,
    fill: c-muted,
  )[оценка: $V(p) = {w_1, w_1'}$, $V(q) = {w_1}$])
})

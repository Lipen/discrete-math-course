// m04 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

#let ca = oklch(72%, 0.1, 250deg).transparentize(55%)

#let cb = oklch(72%, 0.1, 25deg).transparentize(55%)

#let c-str = oklch(35%, 0.02, 265deg) + 0.7pt

#let r = 0.85

#let label(pos, body) = draw.content(pos, text(size: 0.85em)[#body])

#let venn-union = canvas({
  draw.circle((-0.35, 0), radius: r, fill: ca, stroke: c-str)
  draw.circle((0.35, 0), radius: r, fill: cb, stroke: c-str)
  label((-r - 0.1, 0), $A$)
  label((r + 0.1, 0), $B$)
  label((0, r + 0.5), $A union B$)
})

#let venn-intersection = canvas({
  let ym = calc.sqrt(r * r - 0.35 * 0.35)
  let a-top = calc.atan2(0.35, ym)
  let a-bot = calc.atan2(0.35, -ym)
  let b-top = calc.atan2(-0.35, ym)
  let b-bot = calc.atan2(-0.35, -ym) + 360deg

  draw.arc(
    (0, ym),
    start: a-top,
    stop: a-bot,
    radius: r,
    mode: "CLOSE",
    fill: ca,
    stroke: none,
  )
  draw.arc(
    (0, -ym),
    start: b-bot,
    stop: b-top,
    radius: r,
    mode: "CLOSE",
    fill: ca,
    stroke: none,
  )
  draw.circle((-0.35, 0), radius: r, fill: none, stroke: c-str)
  draw.circle((0.35, 0), radius: r, fill: none, stroke: c-str)
  label((-r - 0.1, 0), $A$)
  label((r + 0.1, 0), $B$)
  label((0, r + 0.5), $A inter B$)
})

#let venn-difference = canvas({
  // A fill only (behind)
  draw.circle((-0.35, 0), radius: r, fill: ca, stroke: none)
  // B with white fill to "cut out" the overlap
  draw.circle((0.35, 0), radius: r, fill: white, stroke: c-str)
  // A stroke restored on top
  draw.circle((-0.35, 0), radius: r, fill: none, stroke: c-str)
  label((-r - 0.1, 0), $A$)
  label((r + 0.1, 0), $B$)
  label((0, r + 0.5), $A setminus B$)
})

#let venn-subset = canvas({
  // B is an oval
  draw.circle((0, 0), radius: (1.2, r + 0.05), fill: cb, stroke: c-str)
  label((0.8, 0), $B$)
  draw.circle((-0.35, 0), radius: 0.6, fill: ca, stroke: c-str)
  label((-0.35, 0), $A$)
  label((0, r + 0.5), $A subset B$)
})

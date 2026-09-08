#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

#let r = 0.85

#let v-stroke = (paint: c-edge, thickness: t-ed)

#let label(pos, body) = draw.content(pos, text(size: s-node, fill: c-ink)[#body])

// ── Объединение ──
#let venn-union = canvas({
  draw.circle((-0.35, 0), radius: r, fill: c-fl, stroke: v-stroke)
  draw.circle((0.35, 0), radius: r, fill: c-conn, stroke: v-stroke)
  label((-r - 0.1, 0), $A$)
  label((r + 0.1, 0), $B$)
  label((0, r + 0.5), $A union B$)
})

// ── Пересечение ──
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
    fill: c-fl,
    stroke: none,
  )
  draw.arc(
    (0, -ym),
    start: b-bot,
    stop: b-top,
    radius: r,
    mode: "CLOSE",
    fill: c-fl,
    stroke: none,
  )
  draw.circle((-0.35, 0), radius: r, fill: none, stroke: v-stroke)
  draw.circle((0.35, 0), radius: r, fill: none, stroke: v-stroke)
  label((-r - 0.1, 0), $A$)
  label((r + 0.1, 0), $B$)
  label((0, r + 0.5), $A inter B$)
})

// ── Разность ──
#let venn-difference = canvas({
  draw.circle((-0.35, 0), radius: r, fill: c-fl, stroke: none)
  draw.circle((0.35, 0), radius: r, fill: white, stroke: v-stroke)
  draw.circle((-0.35, 0), radius: r, fill: none, stroke: v-stroke)
  label((-r - 0.1, 0), $A$)
  label((r + 0.1, 0), $B$)
  label((0, r + 0.5), $A setminus B$)
})

// ── Подмножество ──
#let venn-subset = canvas({
  draw.circle((0, 0), radius: (1.2, r + 0.05), fill: c-conn, stroke: v-stroke)
  label((0.8, 0), $B$)
  draw.circle((-0.35, 0), radius: 0.6, fill: c-fl, stroke: v-stroke)
  label((-0.35, 0), $A$)
  label((0, r + 0.5), $A subset B$)
})

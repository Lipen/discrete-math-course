// M04 diagrams — injection, surjection, bijection mapping schemes.
#import "@preview/cetz:0.5.2": canvas, draw

#let c-domain = oklch(80%, 0.06, 250deg)
#let c-codomain = oklch(80%, 0.06, 25deg)
#let c-arrow = oklch(35%, 0.02, 265deg) + 0.7pt

#let dot(x, y) = draw.circle((x, y), radius: 0.08, fill: c-arrow)
#let label(pos, body) = draw.content(pos, text(size: 0.85em, body))

// ── Injection (one-to-one): each B element reached at most once ──
#let mapping-injection = canvas({
  import draw: *
  // Domain A (left oval)
  circle((-2, 0), radius: (0.6, 1.2), fill: c-domain, stroke: c-arrow)
  label((-2, 1.5), $A$)
  dot(-2, -0.6)
  dot(-2, -0.2)
  dot(-2, 0.2)
  dot(-2, 0.6)
  // Codomain B (right oval)
  circle((2, 0), radius: (0.6, 1.5), fill: c-codomain, stroke: c-arrow)
  label((2, 1.8), $B$)
  dot(2, -1.0)
  dot(2, -0.6)
  dot(2, -0.2)
  dot(2, 0.2)
  dot(2, 0.6)
  dot(2, 1.0)
  // Arrows: distinct x → distinct y, some B elements unreached
  line((-2, -0.6), (2, -0.6), stroke: c-arrow, mark: (end: ">"))
  line((-2, -0.2), (2, 0.6), stroke: c-arrow, mark: (end: ">"))
  line((-2, 0.2), (2, -0.2), stroke: c-arrow, mark: (end: ">"))
  line((-2, 0.6), (2, 1.0), stroke: c-arrow, mark: (end: ">"))
  label((0, 0), $f$, anchor: "bottom")
  label((0, -2), text(size: 0.85em)[Каждый $y$ — не более одного прообраза.])
})

// ── Surjection (onto): each B element reached at least once ──
#let mapping-surjection = canvas({
  import draw: *
  // Domain A (left oval, more elements)
  circle((-2, 0), radius: (0.6, 1.5), fill: c-domain, stroke: c-arrow)
  label((-2, 1.8), $A$)
  dot(-2, -1.0)
  dot(-2, -0.6)
  dot(-2, -0.2)
  dot(-2, 0.2)
  dot(-2, 0.6)
  dot(-2, 1.0)
  // Codomain B (right oval, fewer elements)
  circle((2, 0), radius: (0.6, 1.0), fill: c-codomain, stroke: c-arrow)
  label((2, 1.3), $B$)
  dot(2, -0.5)
  dot(2, 0)
  dot(2, 0.5)
  // Arrows: every B element reached, some multiple times
  line((-2, -1.0), (2, -0.5), stroke: c-arrow, mark: (end: ">"))
  line((-2, -0.6), (2, -0.5), stroke: c-arrow, mark: (end: ">"))
  line((-2, -0.2), (2, 0), stroke: c-arrow, mark: (end: ">"))
  line((-2, 0.2), (2, 0), stroke: c-arrow, mark: (end: ">"))
  line((-2, 0.6), (2, 0.5), stroke: c-arrow, mark: (end: ">"))
  line((-2, 1.0), (2, 0.5), stroke: c-arrow, mark: (end: ">"))
  label((0, 0.3), $g$, anchor: "bottom")
  label((0, -2), text(size: 0.85em)[Каждый $y$ — хотя бы один прообраз.])
})

// ── Bijection: one-to-one AND onto ──
#let mapping-bijection = canvas({
  import draw: *
  // Domain A (left)
  circle((-2, 0), radius: (0.6, 1.2), fill: c-domain, stroke: c-arrow)
  label((-2, 1.5), $A$)
  dot(-2, -0.6)
  dot(-2, -0.2)
  dot(-2, 0.2)
  dot(-2, 0.6)
  // Codomain B (right, same size)
  circle((2, 0), radius: (0.6, 1.2), fill: c-codomain, stroke: c-arrow)
  label((2, 1.5), $B$)
  dot(2, -0.6)
  dot(2, -0.2)
  dot(2, 0.2)
  dot(2, 0.6)
  // Arrows: perfect one-to-one pairing
  line((-2, -0.6), (2, 0.2), stroke: c-arrow, mark: (end: ">"))
  line((-2, -0.2), (2, -0.6), stroke: c-arrow, mark: (end: ">"))
  line((-2, 0.2), (2, 0.6), stroke: c-arrow, mark: (end: ">"))
  line((-2, 0.6), (2, -0.2), stroke: c-arrow, mark: (end: ">"))
  label((0, 0), $h$, anchor: "bottom")
  label((0, -2), text(size: 0.85em)[Каждый $y$ — ровно один прообраз.])
})

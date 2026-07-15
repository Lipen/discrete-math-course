// M04 diagrams — injection, surjection, bijection mapping schemes.
#import "@preview/cetz:0.5.2": canvas, draw

#let c-dom = oklch(80%, 0.06, 250deg)
#let c-cod = oklch(80%, 0.06, 25deg)
#let c-dot = oklch(35%, 0.02, 265deg)
#let c-str = oklch(35%, 0.02, 265deg) + 0.7pt

#let pt(x, y) = draw.circle((x, y), radius: 0.07, fill: c-dot)
#let lbl(pos, body) = draw.content(pos, text(size: 0.85em, body))

// ── Injection (one-to-one): each B element reached at most once ──
#let mapping-injection = canvas({
  draw.circle((-2, 0), radius: (0.55, 1.1), fill: c-dom, stroke: c-str)
  lbl((-2, 1.4), $A$)
  pt(-2, -0.65)
  pt(-2, -0.25)
  pt(-2, 0.15)
  pt(-2, 0.55)

  draw.circle((2, 0), radius: (0.55, 1.4), fill: c-cod, stroke: c-str)
  lbl((2, 1.7), $B$)
  pt(2, -1.05)
  pt(2, -0.65)
  pt(2, -0.25)
  pt(2, 0.15)
  pt(2, 0.55)
  pt(2, 0.95)

  draw.line((-2, -0.65), (2, -0.65), stroke: c-str, mark: (end: ">"))
  draw.line((-2, -0.25), (2, 0.55), stroke: c-str, mark: (end: ">"))
  draw.line((-2, 0.15), (2, -0.25), stroke: c-str, mark: (end: ">"))
  draw.line((-2, 0.55), (2, 0.95), stroke: c-str, mark: (end: ">"))
})

// ── Surjection (onto): each B element reached at least once ──
#let mapping-surjection = canvas({
  draw.circle((-2, 0), radius: (0.55, 1.4), fill: c-dom, stroke: c-str)
  lbl((-2, 1.7), $A$)
  pt(-2, -1.05)
  pt(-2, -0.65)
  pt(-2, -0.25)
  pt(-2, 0.15)
  pt(-2, 0.55)
  pt(-2, 0.95)

  draw.circle((2, 0), radius: (0.55, 0.9), fill: c-cod, stroke: c-str)
  lbl((2, 1.2), $B$)
  pt(2, -0.45)
  pt(2, 0)
  pt(2, 0.45)

  draw.line((-2, -1.05), (2, -0.45), stroke: c-str, mark: (end: ">"))
  draw.line((-2, -0.65), (2, -0.45), stroke: c-str, mark: (end: ">"))
  draw.line((-2, -0.25), (2, 0), stroke: c-str, mark: (end: ">"))
  draw.line((-2, 0.15), (2, 0), stroke: c-str, mark: (end: ">"))
  draw.line((-2, 0.55), (2, 0.45), stroke: c-str, mark: (end: ">"))
  draw.line((-2, 0.95), (2, 0.45), stroke: c-str, mark: (end: ">"))
})

// ── Bijection: one-to-one AND onto ──
#let mapping-bijection = canvas({
  draw.circle((-2, 0), radius: (0.55, 1.1), fill: c-dom, stroke: c-str)
  lbl((-2, 1.4), $A$)
  pt(-2, -0.65)
  pt(-2, -0.25)
  pt(-2, 0.15)
  pt(-2, 0.55)

  draw.circle((2, 0), radius: (0.55, 1.1), fill: c-cod, stroke: c-str)
  lbl((2, 1.4), $B$)
  pt(2, -0.65)
  pt(2, -0.25)
  pt(2, 0.15)
  pt(2, 0.55)

  draw.line((-2, -0.65), (2, 0.15), stroke: c-str, mark: (end: ">"))
  draw.line((-2, -0.25), (2, -0.65), stroke: c-str, mark: (end: ">"))
  draw.line((-2, 0.15), (2, 0.55), stroke: c-str, mark: (end: ">"))
  draw.line((-2, 0.55), (2, -0.25), stroke: c-str, mark: (end: ">"))
})

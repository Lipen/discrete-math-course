// M20 diagrams --- Chomsky hierarchy.
// Скопировано из book/diagrams/m15.typ, чтобы лекции не зависели от книги.
#import "@preview/cetz:0.5.2": canvas, draw

#let chomsky-hierarchy = canvas({
  let c-reg = oklch(88%, 0.05, 155deg)
  let c-cf = oklch(88%, 0.04, 70deg)
  let c-cs = oklch(88%, 0.04, 300deg)
  let c-re = oklch(85%, 0.03, 22deg)
  let c-label = oklch(35%, 0.02, 265deg)
  let c-border = oklch(50%, 0.05, 250deg) + 0.5pt

  draw.circle((0, 0), radius: (0.4, 0.2), fill: c-reg, stroke: c-border)
  draw.content((0, 0.15), text(size: 0.42em, fill: c-label)[Regular])

  draw.circle((0, 0.2), radius: (0.7, 0.4), fill: c-cf, stroke: c-border)
  draw.content((0, 0.5), text(size: 0.42em, fill: c-label)[Context-Free])

  draw.circle((0, 0.6), radius: (1.3, 0.8), fill: c-cs, stroke: c-border)
  draw.content((0, 1.0), text(size: 0.42em, fill: c-label)[Context-Sensitive])

  draw.circle((0, 1.2), radius: (2, 1.4), fill: c-re, stroke: c-border)
  draw.content((0, 1.7), text(
    size: 0.42em,
    fill: c-label,
  )[Recursively Enumerable])
})

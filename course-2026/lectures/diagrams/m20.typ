// M20 diagrams --- Chomsky hierarchy.
// Скопировано из notes/diagrams/m15.typ, чтобы лекции не зависели от книги.
#import "@preview/cetz:0.5.2": canvas, draw

#let chomsky-hierarchy = canvas({
  let c-reg = oklch(88%, 0.05, 155deg)
  let c-cf = oklch(88%, 0.04, 70deg)
  let c-cs = oklch(88%, 0.04, 300deg)
  let c-re = oklch(85%, 0.03, 22deg)
  let c-label = oklch(35%, 0.02, 265deg)
  let c-border = oklch(50%, 0.05, 250deg) + 0.5pt

  draw.circle((0, 0), radius: (0.8, 0.4), fill: c-reg, stroke: c-border)
  draw.content((0, 0.3), text(size: 0.6em, fill: c-label)[Regular])

  draw.circle((0, 0.4), radius: (1.4, 0.8), fill: c-cf, stroke: c-border)
  draw.content((0, 1.0), text(size: 0.6em, fill: c-label)[Context-Free])

  draw.circle((0, 1.2), radius: (2.6, 1.6), fill: c-cs, stroke: c-border)
  draw.content((0, 2.0), text(size: 0.6em, fill: c-label)[Context-Sensitive])

  draw.circle((0, 2.4), radius: (4, 2.8), fill: c-re, stroke: c-border)
  draw.content((0, 3.4), text(
    size: 0.6em,
    fill: c-label,
  )[Recursively Enumerable])
})

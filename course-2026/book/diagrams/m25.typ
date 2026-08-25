// m25 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

#let c-label = oklch(35%, 0.02, 265deg)

#let reduction-halt-empty = canvas({
  let c-box = oklch(88%, 0.03, 250deg)
  let c-box-str = oklch(60%, 0.08, 250deg) + 0.5pt
  let c-arrow = oklch(35%, 0.02, 265deg) + 0.6pt
  let c-label = oklch(35%, 0.02, 265deg)

  // Input box
  draw.rect((-1.5, -0.5), (1.5, 0.5), fill: c-box, stroke: c-box-str)
  draw.content((0, 0), text(
    size: 0.7em,
    fill: c-label,
  )[$chevron.l M chevron.r w$])

  // f arrow
  draw.line((1.8, 0), (3.2, 0), stroke: c-arrow, mark: (end: ">", fill: oklch(35%, 0.02, 265deg)))
  draw.content((2.5, 0.3), anchor: "south", text(
    size: 0.65em,
    fill: c-label,
  )[$f$])

  // f box
  draw.rect((3.5, -0.5), (6.5, 0.5), fill: none, stroke: c-box-str)
  draw.content((5, 0), text(
    size: 0.7em,
    fill: c-label,
  )[$chevron.l M' chevron.r$])

  // Result arrow
  draw.line((6.8, 0), (8.2, 0), stroke: c-arrow, mark: (end: ">", fill: oklch(35%, 0.02, 265deg)))

  // Output labels
  draw.content((5, 0.9), anchor: "south", text(
    size: 0.55em,
    fill: luma(50%),
  )[описание МТ,])
  draw.content((5, 0.6), anchor: "south", text(
    size: 0.55em,
    fill: luma(50%),
  )[чей язык пуст iff M(w) останавливается])
})

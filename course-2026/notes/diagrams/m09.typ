// M09 diagrams — Pascal's triangle.
#import "@preview/cetz:0.5.2": canvas, draw

#let c-num = oklch(35%, 0.02, 265deg)

// ── Pascal's triangle, rows 0..7 ──
#let pascals-triangle = canvas({
  let dx = 0.9
  let dy = 0.9
  // Precompute rows of Pascal's triangle
  let rows = (
    (1,),
    (1, 1),
    (1, 2, 1),
    (1, 3, 3, 1),
    (1, 4, 6, 4, 1),
    (1, 5, 10, 10, 5, 1),
    (1, 6, 15, 20, 15, 6, 1),
    (1, 7, 21, 35, 35, 21, 7, 1),
  )
  for (i, row) in rows.enumerate() {
    for (j, val) in row.enumerate() {
      let x = (j - i / 2) * dx
      let y = i * -dy
      draw.content((x, y), text(size: 0.78em, fill: c-num)[#val])
    }
  }
})

// ── Pascal's recurrence: binom(n,k) = binom(n-1,k-1) + binom(n-1,k) ──
#let pascals-recurrence = canvas({
  let dy = 1.1
  let dx = 1.1
  draw.content((0, 0), text(size: 0.8em)[$binom(4, 2) = 6$])
  draw.content((-dx, dy), text(size: 0.75em, fill: c-num)[$binom(3, 1) = 3$])
  draw.content((dx, dy), text(size: 0.75em, fill: c-num)[$binom(3, 2) = 3$])
  draw.line(
    (-dx / 2, dy - 0.15),
    (-dx / 4, 0.15),
    stroke: (c-num + 0.5pt),
    mark: (end: (symbol: ">", fill: c-num)),
  )
  draw.line(
    (dx / 2, dy - 0.15),
    (dx / 4, 0.15),
    stroke: (c-num + 0.5pt),
    mark: (end: (symbol: ">", fill: c-num)),
  )
})

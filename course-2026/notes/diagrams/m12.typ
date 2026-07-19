// M12 diagrams — Transfinite: Cantor diagonal argument.
#import "../requirements.typ": *
#import cetz: canvas, draw

#let cantor-bg = oklch(97%, 0.005, 260deg)
#let cantor-diag = oklch(60%, 0.22, 22deg)
#let cantor-digit = oklch(30%, 0.02, 265deg)
#let cantor-constr = oklch(50%, 0.18, 250deg)
#let cantor-mismatch = oklch(55%, 0.20, 22deg)

#let cantor-diagonal = canvas({
  let s = 0.72
  let rows = 5
  let cols = 7
  let digits = (
    (3, 5, 2, 7, 1, 4, 8),
    (1, 8, 4, 6, 2, 9, 0),
    (7, 2, 5, 9, 3, 0, 6),
    (0, 3, 1, 8, 6, 2, 7),
    (9, 4, 7, 2, 0, 5, 3),
  )
  let constructed = (4, 4, 4, 4, 4)

  // Matrix background
  draw.rect((-0.7, 0.5), (cols * s + 0.2, -(rows + 0.3) * s),
    fill: cantor-bg, stroke: none, radius: 4pt)

  // Rows
  for i in range(rows) {
    draw.content((-0.4, -(i + 0.5) * s),
      text(size: 0.6em, fill: luma(45%))[$r_#(i+1)$])
    for j in range(cols) {
      let x = j * s + 0.1
      let y = -(i + 0.5) * s
      let is-diag = (i == j)
      if is-diag {
        draw.rect((x - 0.05, y - 0.32), (x + s - 0.05, y + 0.32),
          fill: cantor-diag.transparentize(80%),
          stroke: cantor-diag + 0.8pt, radius: 2pt,
          name: "d" + str(i))
      }
      draw.content((x + s/2, y),
        text(size: 0.7em,
          fill: if is-diag { cantor-diag } else { cantor-digit },
          weight: if is-diag { "bold" } else { "regular" })[#digits.at(i).at(j)])
    }
  }

  // Ellipsis
  draw.content((cols * s + 0.5, -(rows/2) * s),
    text(size: 0.65em, fill: luma(50%))[$dots$])

  // Constructed number r (named digit positions — must precede arrows)
  draw.content((-0.4, -(rows + 1.2) * s),
    text(size: 0.65em, weight: "bold", fill: cantor-constr)[$r = 0.$])
  for j in range(rows) {
    let x = j * s + s/2 + 0.1
    draw.content((x, -(rows + 1.2) * s),
      name: "r" + str(j),
      text(size: 0.75em, fill: cantor-constr, weight: "bold")[#constructed.at(j)])
  }
  draw.content((rows * s + 0.3, -(rows + 1.2) * s),
    text(size: 0.65em, fill: oklch(50%, 0.16, 300deg))[$dots not in {r_1, r_2, dots}$])

  // Vertical dashed arrows: diagonal cell → constructed digit
  for i in range(rows) {
    draw.line("d" + str(i) + ".south", "r" + str(i) + ".north",
      stroke: (paint: cantor-constr.transparentize(50%), thickness: 0.4pt, dash: "dashed"),
      name: "arr" + str(i))
    draw.content("arr" + str(i) + ".mid",
      text(size: 0.5em, fill: cantor-mismatch)[$≠$],
      frame: "rect", fill: white, stroke: none, padding: 0.5pt, anchor: "west")
  }
})

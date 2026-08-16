// M14 diagrams --- combinatorics: Pascal triangle, inclusion-exclusion.
// Скопировано из notes/diagrams/m11.typ, чтобы лекции не зависели от книги.
#import "@preview/cetz:0.5.2": canvas, draw

// ── Inclusion-exclusion Venn ──
#let venn-ie-a = oklch(65%, 0.18, 10deg)
#let venn-ie-b = oklch(65%, 0.15, 150deg)
#let venn-ie-c = oklch(65%, 0.15, 260deg)
#let venn-ie-text = oklch(35%, 0.02, 265deg)

#let venn-inclusion-exclusion = canvas({
  let r = 2.1
  let pa = (-1.3, 0.75)
  let pb = (1.3, 0.75)
  let pc = (0, -1.55)

  draw.circle(
    pa,
    radius: r,
    fill: venn-ie-a.transparentize(60%),
    stroke: venn-ie-a + 0.8pt,
    name: "A",
  )
  draw.circle(
    pb,
    radius: r,
    fill: venn-ie-b.transparentize(60%),
    stroke: venn-ie-b + 0.8pt,
    name: "B",
  )
  draw.circle(
    pc,
    radius: r,
    fill: venn-ie-c.transparentize(60%),
    stroke: venn-ie-c + 0.8pt,
    name: "C",
  )

  draw.content((-2.8, 2.5), text(
    size: 1.1em,
    weight: "bold",
    fill: venn-ie-a,
  )[$A$])
  draw.content((2.8, 2.5), text(
    size: 1.1em,
    weight: "bold",
    fill: venn-ie-b,
  )[$B$])
  draw.content((0, -3.5), text(
    size: 1.1em,
    weight: "bold",
    fill: venn-ie-c,
  )[$C$])

  draw.content((-2.1, 0.2), text(size: 0.8em, fill: venn-ie-text)[$+1$])
  draw.content((2.1, 0.2), text(size: 0.8em, fill: venn-ie-text)[$+1$])
  draw.content((0, -2.8), text(size: 0.8em, fill: venn-ie-text)[$+1$])
  draw.content((0, 1.3), text(size: 0.8em, fill: venn-ie-text)[$-1$])
  draw.content((-1.0, -0.7), text(size: 0.8em, fill: venn-ie-text)[$-1$])
  draw.content((1.0, -0.7), text(size: 0.8em, fill: venn-ie-text)[$-1$])
  draw.content((0, -0.05), text(
    size: 0.85em,
    weight: "bold",
    fill: venn-ie-text,
  )[$+1$])

  let ly = -4.2
  draw.rect(
    (-3.2, ly - 0.2),
    (-2.6, ly + 0.2),
    fill: venn-ie-a.transparentize(30%),
    stroke: venn-ie-a + 0.5pt,
    radius: 2pt,
  )
  draw.content((-1.8, ly), text(
    size: 0.65em,
    fill: venn-ie-text,
  )[$|A|+|B|+|C|$ --- одиночные])

  draw.rect(
    (0.5, ly - 0.2),
    (1.1, ly + 0.2),
    fill: venn-ie-a.transparentize(40%),
    stroke: venn-ie-a + 0.5pt,
    radius: 2pt,
  )
  draw.line((1.1, ly), (1.7, ly - 0.2), stroke: venn-ie-b + 0.5pt)
  draw.line((1.1, ly), (1.7, ly + 0.2), stroke: venn-ie-c + 0.5pt)
  draw.content((2.4, ly), text(
    size: 0.65em,
    fill: venn-ie-text,
  )[$-|A inter B|-|A inter C|-|B inter C|$])
})

// ── Pascal triangle ──
#let pt-text = oklch(35%, 0.02, 265deg)
#let pt-accent = oklch(45%, 0.12, 260deg)
#let pt-axis = oklch(35%, 0.02, 265deg)

#let pascal-triangle = canvas({
  let s = 0.62 // шаг по горизонтали
  let h = 1.05 // шаг по вертикали
  let rows = (
    (1,),
    (1, 1),
    (1, 2, 1),
    (1, 3, 3, 1),
    (1, 4, 6, 4, 1),
    (1, 5, 10, 10, 5, 1),
    (1, 6, 15, 20, 15, 6, 1),
  )

  draw.line((0, 7.05), (0, 0.45), stroke: (
    paint: pt-axis,
    thickness: 0.5pt,
    dash: "dashed",
  ))
  draw.content((0.32, 6.7), anchor: "west", text(
    size: 0.55em,
    fill: pt-text,
  )[ось симметрии])

  for (n, row) in rows.enumerate() {
    for (k, val) in row.enumerate() {
      let x = (2 * k - n) * s
      let y = (rows.len() - 1 - n) * h
      draw.content((x, y), text(size: 0.62em, fill: pt-text)[#val])
    }
  }

  let p1 = (-s, h)
  let p2 = (s, h)
  let c = (0, 0)
  draw.line(p1, c, stroke: pt-accent + 0.8pt)
  draw.line(p2, c, stroke: pt-accent + 0.8pt)
  draw.content(p1, text(size: 0.62em, weight: "bold", fill: pt-accent)[10])
  draw.content(p2, text(size: 0.62em, weight: "bold", fill: pt-accent)[10])
  draw.content(c, text(size: 0.62em, weight: "bold", fill: pt-accent)[20])
  draw.content((0, -0.6), text(size: 0.6em, fill: pt-text)[$20 = 10 + 10$])
})

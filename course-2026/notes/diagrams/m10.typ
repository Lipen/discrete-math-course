// M09 diagrams --- Pascal's triangle.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

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


// ── Burnside: necklaces of 3 beads, 2 colors → 4 orbits ──
#let c-bead-b = oklch(25%, 0.02, 265deg)  // black bead
#let c-bead-w = oklch(92%, 0.01, 90deg)   // white bead
#let c-bead-str = oklch(35%, 0.02, 265deg) + 0.5pt
#let c-orbit = oklch(35%, 0.02, 265deg)
#let c-rot = oklch(55%, 0.10, 250deg)

// Draw one necklace: circle with n colored dots on it.
// center: (x,y), colors: array of "b"|"w", radius
#let necklace(center, colors, radius: 0.55) = {
  let n = colors.len()
  let (cx, cy) = center
  // Draw the string circle
  draw.circle(center, radius: radius, fill: none, stroke: c-bead-str)
  // Draw beads
  for (i, col) in colors.enumerate() {
    let angle = 90deg - i * (360deg / n)
    let bx = cx + radius * calc.cos(angle)
    let by = cy + radius * calc.sin(angle)
    draw.circle(
      (bx, by),
      radius: 0.12,
      fill: if col == "b" { c-bead-b } else { c-bead-w },
      stroke: c-bead-str,
    )
  }
}

// Orbit 1: all-black {000} --- one element
// Orbit 2: all-white {111} --- one element
// Orbit 3: one-white {001, 010, 100} --- three elements (rotate)
// Orbit 4: two-white {011, 101, 110} --- three elements (rotate)

#let burnside-necklaces = canvas({
  // Orbit 1: {000}
  necklace((-1.5, 1.8), ("b", "b", "b"))
  draw.content((-1.5, 0.9), text(size: 0.55em, fill: c-orbit)[1 элемент])
  draw.content((-1.5, 0.55), text(size: 0.5em, fill: luma(50%))[$"000"$])

  // Orbit 2: {111}
  necklace((1.5, 1.8), ("w", "w", "w"))
  draw.content((1.5, 0.9), text(size: 0.55em, fill: c-orbit)[1 элемент])
  draw.content((1.5, 0.55), text(size: 0.5em, fill: luma(50%))[$"111"$])

  // Orbit 3: one white bead --- {001, 010, 100}
  necklace((-3.5, -1.0), ("w", "b", "b"))
  necklace((-1.5, -1.0), ("b", "w", "b"))
  necklace((0.5, -1.0), ("b", "b", "w"))
  // Rotation arrows between them
  draw.line((-2.8, -1.0), (-2.2, -1.0), stroke: c-rot + 0.5pt, mark: (end: ">"))
  draw.line((-0.8, -1.0), (-0.2, -1.0), stroke: c-rot + 0.5pt, mark: (end: ">"))
  draw.content((-2.5, -1.7), text(
    size: 0.55em,
    fill: c-orbit,
  )[3 элемента (повороты)])
  draw.content((-2.5, -2.1), text(
    size: 0.5em,
    fill: luma(50%),
  )[$"001", "010", "100"$])

  // Orbit 4: two white beads --- {011, 101, 110}
  necklace((-3.5, -3.5), ("w", "w", "b"))
  necklace((-1.5, -3.5), ("b", "w", "w"))
  necklace((0.5, -3.5), ("w", "b", "w"))
  draw.line((-2.8, -3.5), (-2.2, -3.5), stroke: c-rot + 0.5pt, mark: (end: ">"))
  draw.line((-0.8, -3.5), (-0.2, -3.5), stroke: c-rot + 0.5pt, mark: (end: ">"))
  draw.content((-2.5, -4.2), text(
    size: 0.55em,
    fill: c-orbit,
  )[3 элемента (повороты)])
  draw.content((-2.5, -4.6), text(
    size: 0.5em,
    fill: luma(50%),
  )[$"011", "101", "110"$])
})

// ── Ramsey R(3,3) ≤ 6: proof by pigeonhole ──
// Metaphor: vertex 1 connects to 5 others. By pigeonhole, ≥3 edges
// from 1 have the same color (say red, to vertices 2,3,4).
// The triangle {2,3,4} either has a red edge (→ red K₃ with 1)
// or is all blue (→ blue K₃). A monochromatic triangle is inevitable.
#let c-red = oklch(58%, 0.22, 22deg)
#let c-blue = oklch(58%, 0.18, 250deg)
#let c-ram-node = oklch(88%, 0.03, 250deg)
#let c-ram-str = oklch(60%, 0.08, 250deg) + 0.7pt
#let c-hi = oklch(65%, 0.20, 45deg)

#let ramsey-k6 = canvas({
  // Vertex 1 in center, others around
  let center = (0, 0)
  let others = (
    (0, 2.5),
    (2.4, 0.8),
    (1.5, -2),
    (-1.5, -2),
    (-2.4, 0.8),
  )

  // Center vertex 1 (highlighted)
  draw.circle(center, radius: 0.38, fill: c-hi, stroke: oklch(55%, 0.18, 45deg) + 1pt, name: "c")
  draw.content(center, text(size: 0.7em, weight: "bold", fill: oklch(30%, 0.02, 265deg))[1])

  // Outer vertices 2..6
  for (i, p) in others.enumerate() {
    let lab = str(i + 2)
    // Vertices 2,3,4 are the "pigeonhole" set (connected to 1 in red)
    let fill = if i < 3 { oklch(88%, 0.06, 22deg) } else { c-ram-node }
    let str = if i < 3 { oklch(55%, 0.18, 22deg) + 0.8pt } else { c-ram-str }
    draw.circle(p, radius: 0.32, fill: fill, stroke: str, name: "v" + lab)
    draw.content(p, text(size: 0.65em, fill: oklch(30%, 0.02, 265deg))[#lab])
  }

  // Edges from vertex 1: 3 red (to 2,3,4), 2 blue (to 5,6)
  for i in range(5) {
    let is-red = (i < 3)
    draw.line(center, others.at(i), stroke: (
      paint: if is-red { c-red } else { c-blue },
      thickness: if is-red { 1.6pt } else { 0.8pt },
    ))
  }

  // Triangle {2,3,4}: show edges. One is red (→ red K₃ with 1),
  // or all are blue (→ blue K₃). Here we show version with red edge.
  // Edge 2-3: red → red triangle {1,2,3}
  draw.line(others.at(0), others.at(1),
    stroke: (paint: c-red, thickness: 2.0pt))
  // Edge 3-4: blue
  draw.line(others.at(1), others.at(2),
    stroke: (paint: c-blue, thickness: 0.8pt))
  // Edge 2-4: blue
  draw.line(others.at(0), others.at(2),
    stroke: (paint: c-blue, thickness: 0.8pt))

  // Other edges (thin, dimmed)
  for (i1, i2) in ((0, 3), (0, 4), (1, 3), (1, 4), (2, 3), (2, 4), (3, 4)) {
    draw.line(others.at(i1), others.at(i2),
      stroke: (paint: luma(70%), thickness: 0.3pt))
  }

  // Highlight the red triangle {1,2,3}
  draw.line(center, others.at(0),
    stroke: (paint: c-red, thickness: 2.5pt))
  draw.line(center, others.at(1),
    stroke: (paint: c-red, thickness: 2.5pt))

  // Legend
  draw.line((3.8, 2.0), (4.5, 2.0), stroke: (paint: c-red, thickness: 1.5pt))
  draw.content((4.8, 2.0), text(size: 0.55em, fill: oklch(30%, 0.02, 265deg))[красное])
  draw.line((3.8, 1.3), (4.5, 1.3), stroke: (paint: c-blue, thickness: 1.5pt))
  draw.content((4.8, 1.3), text(size: 0.55em, fill: oklch(30%, 0.02, 265deg))[синее])

  // Annotation
  draw.content((3.5, 0.3), text(size: 0.5em, fill: luma(50%))[
    Из 5 рёбер от вершины 1 минимум 3 одного цвета.
  ])
  draw.content((3.5, -0.2), text(size: 0.5em, fill: luma(50%))[
    Среди их концов найдётся ребро того же цвета
  ])
  draw.content((3.5, -0.7), text(size: 0.5em, fill: luma(50%))[
    либо все три ребра --- другого цвета.
  ])
})

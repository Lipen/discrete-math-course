// M09 diagrams — Pascal's triangle.
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

// Orbit 1: all-black {000} — one element
// Orbit 2: all-white {111} — one element
// Orbit 3: one-white {001, 010, 100} — three elements (rotate)
// Orbit 4: two-white {011, 101, 110} — three elements (rotate)

#let burnside-necklaces = canvas({
  // Orbit 1: {000}
  necklace((-1.5, 1.8), ("b", "b", "b"))
  draw.content((-1.5, 0.9), text(size: 0.55em, fill: c-orbit)[1 элемент])
  draw.content((-1.5, 0.55), text(size: 0.5em, fill: luma(50%))[$"000"$])

  // Orbit 2: {111}
  necklace((1.5, 1.8), ("w", "w", "w"))
  draw.content((1.5, 0.9), text(size: 0.55em, fill: c-orbit)[1 элемент])
  draw.content((1.5, 0.55), text(size: 0.5em, fill: luma(50%))[$"111"$])

  // Orbit 3: one white bead — {001, 010, 100}
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

  // Orbit 4: two white beads — {011, 101, 110}
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

  // Total label
  draw.content((-2.5, -5.4), text(size: 0.75em, fill: c-orbit, weight: "bold")[
    Всего орбит: $(8 + 2 + 2) / 3 = 4$
  ])
})

// ── Ramsey R(3,3) = 6: K6 with 2-colored edges ──
#let c-red = oklch(58%, 0.22, 22deg)
#let c-blue = oklch(58%, 0.18, 250deg)
#let c-ram-node = oklch(88%, 0.03, 250deg)
#let c-ram-str = oklch(60%, 0.08, 250deg) + 0.7pt

#let ramsey-k6 = canvas({
  // Vertices of a regular hexagon
  let v = (
    (0, 2.2),
    (1.9, 1.1),
    (1.9, -1.1),
    (0, -2.2),
    (-1.9, -1.1),
    (-1.9, 1.1),
  )
  // Nodes
  for (i, p) in v.enumerate() {
    draw.circle(p, radius: 0.32, fill: c-ram-node, stroke: c-ram-str)
    draw.content(p, text(size: 0.7em, fill: c-orbit)[#(i + 1)])
  }
  // Edge coloring: (i,j,color) where color=true=red, false=blue
  // This specific 2-coloring has NO monochromatic triangle (optimal coloring)
  let edges = (
    (0, 1, true),
    (0, 2, false),
    (0, 3, true),
    (0, 4, false),
    (0, 5, false),
    (1, 2, true),
    (1, 3, false),
    (1, 4, true),
    (1, 5, true),
    (2, 3, true),
    (2, 4, false),
    (2, 5, false),
    (3, 4, true),
    (3, 5, true),
    (4, 5, false),
  )
  for (i, j, is-red) in edges {
    draw.line(v.at(i), v.at(j), stroke: (
      paint: if is-red { c-red } else { c-blue },
      thickness: 1.2pt,
    ))
  }
  // Legend
  draw.line((3.5, 1.5), (4.3, 1.5), stroke: (paint: c-red, thickness: 1.2pt))
  draw.content((4.6, 1.5), text(size: 0.6em, fill: c-orbit)[красное ребро])
  draw.line((3.5, 0.8), (4.3, 0.8), stroke: (paint: c-blue, thickness: 1.2pt))
  draw.content((4.6, 0.8), text(size: 0.6em, fill: c-orbit)[синее ребро])
  draw.content((3.5, 0.0), text(
    size: 0.55em,
    fill: luma(50%),
  )[2-раскраска без монохроматического $K_3$])
  draw.content((3.5, -0.4), text(
    size: 0.55em,
    fill: luma(50%),
  )[Значит, $R(3,3) > 6$])
})

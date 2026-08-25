// m17 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw
#import circuiteria: circuit, element, wire

#let c-bead-b = oklch(25%, 0.02, 265deg)  // black bead

#let c-bead-w = oklch(92%, 0.01, 90deg)   // white bead

#let c-bead-str = oklch(35%, 0.02, 265deg) + 0.5pt

#let c-orbit = oklch(35%, 0.02, 265deg)

#let c-rot = oklch(55%, 0.10, 250deg)

#let necklace(center, colors, radius: 0.55, name: none) = {
  let n = colors.len()
  let (cx, cy) = center
  draw.circle(
    center,
    radius: radius,
    fill: none,
    stroke: c-bead-str,
    name: name,
  )
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
  necklace((-3.0, -1.0), ("w", "b", "b"), name: "o3a")
  necklace((-1.5, -1.0), ("b", "w", "b"), name: "o3b")
  necklace((0.0, -1.0), ("b", "b", "w"), name: "o3c")
  draw.line("o3a.east", "o3b.west", stroke: c-rot + 0.5pt, mark: (end: ">"))
  draw.line("o3b.east", "o3c.west", stroke: c-rot + 0.5pt, mark: (end: ">"))
  draw.content((-2.5, -1.7), text(
    size: 0.55em,
    fill: c-orbit,
  )[3 элемента (повороты)])
  draw.content((-2.5, -2.1), text(
    size: 0.5em,
    fill: luma(50%),
  )[$"001", "010", "100"$])

  // Orbit 4: two white beads --- {011, 101, 110}
  necklace((-3.0, -3.5), ("w", "w", "b"), name: "o4a")
  necklace((-1.5, -3.5), ("b", "w", "w"), name: "o4b")
  necklace((0.0, -3.5), ("w", "b", "w"), name: "o4c")
  draw.line("o4a.east", "o4b.west", stroke: c-rot + 0.5pt, mark: (end: ">"))
  draw.line("o4b.east", "o4c.west", stroke: c-rot + 0.5pt, mark: (end: ">"))
  draw.content((-2.5, -4.2), text(
    size: 0.55em,
    fill: c-orbit,
  )[3 элемента (повороты)])
  draw.content((-2.5, -4.6), text(
    size: 0.5em,
    fill: luma(50%),
  )[$"011", "101", "110"$])
})

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
  draw.circle(
    center,
    radius: 0.38,
    fill: c-hi,
    stroke: oklch(55%, 0.18, 45deg) + 1pt,
    name: "c",
  )
  draw.content(center, text(size: 0.7em, weight: "bold", fill: oklch(
    30%,
    0.02,
    265deg,
  ))[1])

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
    let lab = str(i + 2)
    let is-red = (i < 3)
    draw.line("c", "v" + lab, stroke: (
      paint: if is-red { c-red } else { c-blue },
      thickness: if is-red { 1.6pt } else { 0.8pt },
    ))
  }

  // Triangle {2,3,4}: edge 2-3 red -> red triangle {1,2,3}
  draw.line("v2", "v3", stroke: (paint: c-red, thickness: 2.0pt))
  draw.line("v3", "v4", stroke: (paint: c-blue, thickness: 0.8pt))
  draw.line("v2", "v4", stroke: (paint: c-blue, thickness: 0.8pt))

  // Other edges (thin, dimmed) using named nodes
  for (a, b) in (
    ("v2", "v6"),
    ("v2", "v5"),
    ("v3", "v5"),
    ("v3", "v6"),
    ("v4", "v5"),
    ("v4", "v6"),
    ("v5", "v6"),
  ) {
    draw.line(a, b, stroke: (paint: luma(70%), thickness: 0.3pt))
  }

  // Highlight the red triangle {1,2,3}
  draw.line("c", "v2", stroke: (paint: c-red, thickness: 2.5pt))
  draw.line("c", "v3", stroke: (paint: c-red, thickness: 2.5pt))

  // Legend
  draw.line((3.8, 2.0), (4.5, 2.0), stroke: (paint: c-red, thickness: 1.5pt))
  draw.content((4.8, 2.0), text(size: 0.55em, fill: oklch(
    30%,
    0.02,
    265deg,
  ))[красное])
  draw.line((3.8, 1.3), (4.5, 1.3), stroke: (paint: c-blue, thickness: 1.5pt))
  draw.content((4.8, 1.3), text(size: 0.55em, fill: oklch(
    30%,
    0.02,
    265deg,
  ))[синее])

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

#let c-dt-fill = oklch(88%, 0.03, 250deg)

#let c-dt-str = oklch(55%, 0.12, 250deg) + 0.7pt

#let c-dt-edge = oklch(35%, 0.02, 265deg) + 0.6pt

#let c-dt-label = oklch(35%, 0.02, 265deg)

#let c-dt-leaf = oklch(35%, 0.08, 140deg)

#let decision-tree = canvas({

  // Helper: node --- small named circle
  let node(pos, name) = {
    draw.circle(pos, radius: 0.2, fill: c-dt-fill, stroke: c-dt-str, name: name)
  }

  // Helper: labelled edge --- line + label at midpoint
  let ledge(from-name, to-name, from-pos, to-pos, label) = {
    draw.line(from-name, to-name, stroke: c-dt-edge)
    let mx = (from-pos.at(0) + to-pos.at(0)) / 2
    let my = (from-pos.at(1) + to-pos.at(1)) / 2
    draw.content((mx, my + 0.12), text(size: 0.65em, fill: c-dt-label)[#label])
  }

  // ── Positions ──
  let start = (0.0, 5.2)

  let a = (-4.0, 3.5)
  let b = (0.0, 3.5)
  let c = (4.0, 3.5)

  let ab = (-5.0, 1.8)
  let ac = (-3.0, 1.8)
  let ba = (-1.0, 1.8)
  let bc = (1.0, 1.8)
  let ca = (3.0, 1.8)
  let cb = (5.0, 1.8)

  let abc = (-5.0, 0.3)
  let acb = (-3.0, 0.3)
  let bac = (-1.0, 0.3)
  let bca = (1.0, 0.3)
  let cab = (3.0, 0.3)
  let cba = (5.0, 0.3)

  // ── Nodes ──
  // Level 0
  node(start, "start")
  draw.content((start.at(0), start.at(1) + 0.35), text(
    size: 0.6em,
    fill: c-dt-label,
  )[старт])

  // Level 1: first element chosen
  node(a, "a")
  draw.content((a.at(0), a.at(1) - 0.35), text(
    size: 0.6em,
    fill: c-dt-label,
  )[A])
  node(b, "b")
  draw.content((b.at(0), b.at(1) - 0.35), text(
    size: 0.6em,
    fill: c-dt-label,
  )[B])
  node(c, "c")
  draw.content((c.at(0), c.at(1) - 0.35), text(
    size: 0.6em,
    fill: c-dt-label,
  )[C])

  // Level 2: second element chosen
  node(ab, "ab")
  draw.content((ab.at(0), ab.at(1) - 0.35), text(
    size: 0.6em,
    fill: c-dt-label,
  )[AB])
  node(ac, "ac")
  draw.content((ac.at(0), ac.at(1) - 0.35), text(
    size: 0.6em,
    fill: c-dt-label,
  )[AC])
  node(ba, "ba")
  draw.content((ba.at(0), ba.at(1) - 0.35), text(
    size: 0.6em,
    fill: c-dt-label,
  )[BA])
  node(bc, "bc")
  draw.content((bc.at(0), bc.at(1) - 0.35), text(
    size: 0.6em,
    fill: c-dt-label,
  )[BC])
  node(ca, "ca")
  draw.content((ca.at(0), ca.at(1) - 0.35), text(
    size: 0.6em,
    fill: c-dt-label,
  )[CA])
  node(cb, "cb")
  draw.content((cb.at(0), cb.at(1) - 0.35), text(
    size: 0.6em,
    fill: c-dt-label,
  )[CB])

  // Level 3: leaves --- full permutations
  node(abc, "abc")
  draw.content((abc.at(0), abc.at(1) - 0.4), text(
    size: 0.6em,
    weight: "bold",
    fill: c-dt-leaf,
  )[ABC])
  node(acb, "acb")
  draw.content((acb.at(0), acb.at(1) - 0.4), text(
    size: 0.6em,
    weight: "bold",
    fill: c-dt-leaf,
  )[ACB])
  node(bac, "bac")
  draw.content((bac.at(0), bac.at(1) - 0.4), text(
    size: 0.6em,
    weight: "bold",
    fill: c-dt-leaf,
  )[BAC])
  node(bca, "bca")
  draw.content((bca.at(0), bca.at(1) - 0.4), text(
    size: 0.6em,
    weight: "bold",
    fill: c-dt-leaf,
  )[BCA])
  node(cab, "cab")
  draw.content((cab.at(0), cab.at(1) - 0.4), text(
    size: 0.6em,
    weight: "bold",
    fill: c-dt-leaf,
  )[CAB])
  node(cba, "cba")
  draw.content((cba.at(0), cba.at(1) - 0.4), text(
    size: 0.6em,
    weight: "bold",
    fill: c-dt-leaf,
  )[CBA])

  // ── Edges ──
  // Level 0 -> Level 1
  ledge("start", "a", start, a, [A])
  ledge("start", "b", start, b, [B])
  ledge("start", "c", start, c, [C])

  // Level 1 -> Level 2
  ledge("a", "ab", a, ab, [B])
  ledge("a", "ac", a, ac, [C])
  ledge("b", "ba", b, ba, [A])
  ledge("b", "bc", b, bc, [C])
  ledge("c", "ca", c, ca, [A])
  ledge("c", "cb", c, cb, [B])

  // Level 2 -> Level 3
  ledge("ab", "abc", ab, abc, [C])
  ledge("ac", "acb", ac, acb, [B])
  ledge("ba", "bac", ba, bac, [C])
  ledge("bc", "bca", bc, bca, [A])
  ledge("ca", "cab", ca, cab, [B])
  ledge("cb", "cba", cb, cba, [A])
})

#let venn-ie-a = oklch(65%, 0.18, 10deg)

#let venn-ie-b = oklch(65%, 0.15, 150deg)

#let venn-ie-c = oklch(65%, 0.15, 260deg)

#let venn-ie-text = oklch(35%, 0.02, 265deg)

#let venn-inclusion-exclusion = canvas({

  let r = 2.1
  let pa = (-1.3, 0.75)
  let pb = (1.3, 0.75)
  let pc = (0, -1.55)

  // Circles with translucent fills
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

  // Set labels
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

  // Region contributions
  // A only
  draw.content((-2.1, 0.2), text(size: 0.8em, fill: venn-ie-text)[$+1$])
  // B only
  draw.content((2.1, 0.2), text(size: 0.8em, fill: venn-ie-text)[$+1$])
  // C only
  draw.content((0, -2.8), text(size: 0.8em, fill: venn-ie-text)[$+1$])
  // A∩B (outside C)
  draw.content((0, 1.3), text(size: 0.8em, fill: venn-ie-text)[$-1$])
  // A∩C (outside B)
  draw.content((-1.0, -0.7), text(size: 0.8em, fill: venn-ie-text)[$-1$])
  // B∩C (outside A)
  draw.content((1.0, -0.7), text(size: 0.8em, fill: venn-ie-text)[$-1$])
  // A∩B∩C
  draw.content((0, -0.05), text(
    size: 0.85em,
    weight: "bold",
    fill: venn-ie-text,
  )[$+1$])

  // Legend
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

#let combinatorial-numbers = table(
  columns: 5,
  align: center + horizon,
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header(
    [$n$], [$n!$], [$C_n$ (Catalan)], [$S(n,3)$ (Stirling)], [$B_n$ (Bell)]
  ),
  [1], [1], [1], [0], [1],
  [2], [2], [2], [0], [2],
  [3], [6], [5], [1], [5],
  [4], [24], [14], [6], [15],
  [5], [120], [42], [25], [52],
)

#let pt-text = oklch(35%, 0.02, 265deg)

#let pt-accent = oklch(45%, 0.12, 260deg)

#let pt-axis = oklch(35%, 0.02, 265deg)

#let pascal-triangle = canvas({
  let s = 0.62  // шаг по горизонтали
  let h = 1.05  // шаг по вертикали
  let rows = (
    (1,),
    (1, 1),
    (1, 2, 1),
    (1, 3, 3, 1),
    (1, 4, 6, 4, 1),
    (1, 5, 10, 10, 5, 1),
    (1, 6, 15, 20, 15, 6, 1),
  )

  // Ось симметрии через средний столбец.
  draw.line((0, 7.05), (0, 0.45), stroke: (
    paint: pt-axis,
    thickness: 0.5pt,
    dash: "dashed",
  ))
  draw.content((0.32, 6.7), anchor: "west", text(
    size: 0.55em,
    fill: pt-text,
  )[ось симметрии])

  // Числа треугольника: строка n, позиция k, координаты (x, y).
  for (n, row) in rows.enumerate() {
    for (k, val) in row.enumerate() {
      let x = (2 * k - n) * s
      let y = (rows.len() - 1 - n) * h
      draw.content((x, y), text(size: 0.62em, fill: pt-text)[#val])
    }
  }

  // Рекуррентность: внутренний элемент 20 равен сумме двух над ним.
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

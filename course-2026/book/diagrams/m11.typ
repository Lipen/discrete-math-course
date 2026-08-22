// Combinatorics (used by m17, m20): Catalan recursion, decision tree,
// inclusion--exclusion, convolution grid, combinatorial numbers.
#import "../requirements.typ": *
#import "../notation.typ": *
#import cetz: canvas, draw

// ═══════════════════════════════════════════════════════════════
// Convolution as a product grid with diagonal bands
// ═══════════════════════════════════════════════════════════════
// Metaphor: a multiplication table where each c_n is the sum
// of entries on the n-th anti-diagonal.

#let c-conv-band(n) = {
  let hue = calc.rem(250 + n * 55, 360)
  oklch(70%, 0.08, hue * 1deg).transparentize(70%)
}

#let convolution-grid = canvas({
  let a = (2, 1, 3, 0, 1)
  let b = (1, 3, 2, 0)
  let cell = 0.9

  // Column headers (a_j)
  for (j, val) in a.enumerate() {
    draw.content((j * cell + cell / 2 + 0.7, 0.8), text(
      size: 0.7em,
      weight: "bold",
      fill: oklch(45%, 0.12, 250deg),
    )[$a_#j$])
    draw.content((j * cell + cell / 2 + 0.7, 0.3), text(
      size: 0.6em,
      fill: oklch(40%, 0.02, 265deg),
    )[#val])
  }

  // Row headers (b_i)
  for (i, val) in b.enumerate() {
    draw.content((-0.1, -i * cell - cell / 2), anchor: "east", text(
      size: 0.7em,
      weight: "bold",
      fill: oklch(45%, 0.12, 22deg),
    )[$b_#i$])
    draw.content((0.3, -i * cell - cell / 2), anchor: "east", text(
      size: 0.6em,
      fill: oklch(40%, 0.02, 265deg),
    )[#val])
  }

  // Grid cells: product a_j * b_i, with diagonal band coloring
  for i in range(b.len()) {
    for j in range(a.len()) {
      let n = i + j // which c_n this term contributes to
      let x = j * cell + 0.7
      let y = -i * cell
      let prod = a.at(j) * b.at(i)

      // Cell background with band color
      draw.rect(
        (x, y - cell),
        (x + cell, y),
        fill: c-conv-band(n),
        stroke: oklch(85%, 0.01, 260deg) + 0.3pt,
        radius: 2pt,
      )

      // Product value
      draw.content((x + cell / 2, y - cell / 2), text(size: 0.65em, fill: oklch(
        30%,
        0.02,
        265deg,
      ))[#prod])
    }
  }

  // Diagonal band labels on the right
  for n in range(a.len() + b.len() - 1) {
    let y = -(n * cell / 2) - cell / 2
    draw.content((a.len() * cell + 1.0, y), anchor: "west", text(
      size: 0.65em,
      weight: "bold",
      fill: oklch(35%, 0.15, 250deg),
    )[$c_#n$])
  }

  // Convolution equation at bottom
  draw.content((a.len() * cell / 2 + 0.35, -(b.len()) * cell - 0.6), text(
    size: 0.7em,
    fill: oklch(35%, 0.02, 265deg),
  )[
    $c_n = sum_(i+j=n) a_i b_j$
  ])
})

// ═══════════════════════════════════════════════════════════════
// Catalan decomposition: recursive tree structure
// ═══════════════════════════════════════════════════════════════

#let cat-node-fill = oklch(88%, 0.03, 250deg)
#let cat-node-str = oklch(55%, 0.08, 250deg) + 0.6pt
#let cat-edge-color = oklch(35%, 0.02, 265deg)
#let cat-label = oklch(35%, 0.02, 265deg)

// Internal node: circle, named
#let cat-node(pos, name) = {
  draw.circle(
    pos,
    radius: 0.22,
    fill: cat-node-fill,
    stroke: cat-node-str,
    name: name,
  )
}

// Leaf: small square, named
#let cat-leaf(pos, name) = {
  let (cx, cy) = pos
  draw.rect(
    (cx - 0.12, cy - 0.12),
    (cx + 0.12, cy + 0.12),
    fill: white,
    stroke: cat-node-str,
    radius: 1pt,
    name: name,
  )
}

// Edge between named nodes
#let cat-edge(from, to) = {
  draw.line(from, to, stroke: cat-edge-color + 0.6pt)
}

#let catalan-recursive = canvas({
  // ── Original tree (left) ──
  // Root
  cat-node((0, 4), "root")
  // Left subtree: one internal node + two leaves
  cat-node((-1.2, 2.8), "L")
  cat-leaf((-1.6, 1.6), "LL")
  cat-leaf((-0.8, 1.6), "LR")
  // Right subtree: two internal nodes + three leaves
  cat-node((1.2, 2.8), "R")
  cat-node((0.7, 1.6), "RL")
  cat-leaf((0.3, 0.4), "RLL")
  cat-leaf((1.1, 0.4), "RLR")
  cat-leaf((1.7, 1.6), "RR")

  // Edges between named nodes
  cat-edge("root", "L")
  cat-edge("root", "R")
  cat-edge("L", "LL")
  cat-edge("L", "LR")
  cat-edge("R", "RL")
  cat-edge("R", "RR")
  cat-edge("RL", "RLL")
  cat-edge("RL", "RLR")

  // Label
  draw.content((0, -0.3), text(
    size: 0.7em,
    weight: "bold",
    fill: cat-label,
  )[$C_4$])

  // ── Equality sign ──
  draw.content((2.8, 2.0), text(size: 1.2em, fill: cat-label)[$=$])

  // ── Decomposition (right side): sum of products C_i·C_{3-i} ──
  let terms = (
    (0, 3, 3.8, 3.5, 5.5, 2.0),
    (1, 2, 6.5, 3.5, 8.2, 2.0),
    (2, 1, 9.2, 3.5, 10.9, 2.0),
    (3, 0, 11.9, 3.5, 13.6, 2.0),
  )

  for (i, (li, ri, x1, y1, x2, y2)) in terms.enumerate() {
    draw.rect(
      (x1 - 0.6, y1 - 0.4),
      (x1 + 0.6, y1 + 0.4),
      radius: 4pt,
      fill: oklch(92%, 0.03, 250deg).transparentize(40%),
      stroke: oklch(60%, 0.08, 250deg) + 0.5pt,
      name: "ci" + str(i) + "-l",
    )
    draw.content((x1, y1), text(size: 0.6em, fill: cat-label)[$C_#li$])

    draw.rect(
      (x2 - 0.6, y2 - 0.4),
      (x2 + 0.6, y2 + 0.4),
      radius: 4pt,
      fill: oklch(92%, 0.04, 155deg).transparentize(40%),
      stroke: oklch(55%, 0.18, 155deg) + 0.5pt,
      name: "ci" + str(i) + "-r",
    )
    draw.content((x2, y2), text(size: 0.6em, fill: cat-label)[$C_#ri$])

    if i < terms.len() - 1 {
      draw.content((x2 + 0.9, y1), text(size: 0.8em, fill: cat-label)[$+$])
    }
  }
})

// ═══════════════════════════════════════════════════════════════
// Generating function pipeline: sequence → GF → closed form
// ═══════════════════════════════════════════════════════════════

#let gf-box-fill = oklch(92%, 0.03, 250deg)
#let gf-box-str = oklch(60%, 0.08, 250deg) + 0.6pt
#let gf-arrow-color = oklch(35%, 0.02, 265deg)
#let gf-label = oklch(35%, 0.02, 265deg)

// A labelled box
#let gf-box(pos, w, h, fill, stroke, title, subtitle, name) = {
  let (cx, cy) = pos
  draw.rect(
    (cx - w / 2, cy - h / 2),
    (cx + w / 2, cy + h / 2),
    radius: 8pt,
    fill: fill,
    stroke: stroke,
    name: name,
  )
  draw.content((cx, cy + 0.2), text(
    size: 0.65em,
    weight: "bold",
    fill: gf-label,
  )[#title])
  draw.content((cx, cy - 0.25), text(size: 0.55em, fill: luma(50%))[#subtitle])
}

#let gf-pipeline = canvas({
  gf-box(
    (-3, 0),
    3.0,
    1.4,
    gf-box-fill,
    gf-box-str,
    $a_0, a_1, a_2, dots$,
    [последовательность],
    "seq",
  )
  gf-box(
    (1.8, 0),
    2.0,
    1.4,
    oklch(88%, 0.05, 155deg),
    oklch(55%, 0.18, 155deg) + 0.6pt,
    $A(x)$,
    [производящая функция],
    "gf",
  )
  gf-box(
    (6.1, 0),
    2.0,
    1.4,
    oklch(88%, 0.06, 45deg),
    oklch(55%, 0.18, 45deg) + 0.6pt,
    $a_n = [x^n] A(x)$,
    [явная формула],
    "result",
  )

  // Arrows between named boxes
  draw.line(
    "seq.east",
    "gf.west",
    stroke: gf-arrow-color + 0.7pt,
    mark: (end: "stealth"),
    name: "arr1",
  )
  draw.content("arr1.mid", anchor: "south", text(
    size: 0.55em,
    fill: luma(50%),
  )[$sum a_n x^n$])

  draw.line(
    "gf.east",
    "result.west",
    stroke: gf-arrow-color + 0.7pt,
    mark: (end: "stealth"),
    name: "arr2",
  )
  draw.content("arr2.mid", anchor: "south", text(
    size: 0.55em,
    fill: luma(50%),
  )[решаем уравнение])
})


// ═══════════════════════════════════════════════════════════════
// Decision tree: permutations of {A, B, C}
// ═══════════════════════════════════════════════════════════════
// Visualises the multiplicative principle: 3 choices for the first
// element, then 2 for the second, then 1 for the third → 3·2·1 = 6
// permutations.

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
  // Level 0 → Level 1
  ledge("start", "a", start, a, [A])
  ledge("start", "b", start, b, [B])
  ledge("start", "c", start, c, [C])

  // Level 1 → Level 2
  ledge("a", "ab", a, ab, [B])
  ledge("a", "ac", a, ac, [C])
  ledge("b", "ba", b, ba, [A])
  ledge("b", "bc", b, bc, [C])
  ledge("c", "ca", c, ca, [A])
  ledge("c", "cb", c, cb, [B])

  // Level 2 → Level 3
  ledge("ab", "abc", ab, abc, [C])
  ledge("ac", "acb", ac, acb, [B])
  ledge("ba", "bac", ba, bac, [C])
  ledge("bc", "bca", bc, bca, [A])
  ledge("ca", "cab", ca, cab, [B])
  ledge("cb", "cba", cb, cba, [A])
})


// ═══════════════════════════════════════════════════════════════
// Pascal's triangle --- table, rows 0..6
// ═══════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════
// Venn diagram: inclusion-exclusion for 3 sets
// ═══════════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════════
// Table of special combinatorial numbers
// ═══════════════════════════════════════════════════════════════

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

// Треугольник Паскаля как пирамида: рекуррентность (10 + 10 = 20)
// и ось симметрии нарисованы, а не подразумеваются пустыми клетками таблицы.
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

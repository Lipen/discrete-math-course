// m20 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

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

#let cat-node-fill = oklch(88%, 0.03, 250deg)

#let cat-node-str = oklch(55%, 0.08, 250deg) + 0.6pt

#let cat-edge-color = oklch(35%, 0.02, 265deg)

#let cat-label = oklch(35%, 0.02, 265deg)

#let cat-node(pos, name) = {
  draw.circle(
    pos,
    radius: 0.22,
    fill: cat-node-fill,
    stroke: cat-node-str,
    name: name,
  )
}

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

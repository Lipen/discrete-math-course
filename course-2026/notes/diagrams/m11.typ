// M11 diagrams — Generating Functions.
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
    draw.content((j * cell + cell/2 + 0.7, 0.8),
      text(size: 0.7em, weight: "bold", fill: oklch(45%, 0.12, 250deg))[$a_#j$])
    draw.content((j * cell + cell/2 + 0.7, 0.3),
      text(size: 0.6em, fill: oklch(40%, 0.02, 265deg))[#val])
  }

  // Row headers (b_i)
  for (i, val) in b.enumerate() {
    draw.content((-0.1, -i * cell - cell/2),
      anchor: "east",
      text(size: 0.7em, weight: "bold", fill: oklch(45%, 0.12, 22deg))[$b_#i$])
    draw.content((0.3, -i * cell - cell/2),
      anchor: "east",
      text(size: 0.6em, fill: oklch(40%, 0.02, 265deg))[#val])
  }

  // Grid cells: product a_j * b_i, with diagonal band coloring
  for i in range(b.len()) {
    for j in range(a.len()) {
      let n = i + j  // which c_n this term contributes to
      let x = j * cell + 0.7
      let y = -i * cell
      let prod = a.at(j) * b.at(i)

      // Cell background with band color
      draw.rect((x, y - cell), (x + cell, y),
        fill: c-conv-band(n), stroke: oklch(85%, 0.01, 260deg) + 0.3pt, radius: 2pt)

      // Product value
      draw.content((x + cell/2, y - cell/2),
        text(size: 0.65em, fill: oklch(30%, 0.02, 265deg))[#prod])
    }
  }

  // Diagonal band labels on the right
  for n in range(a.len() + b.len() - 1) {
    let y = -(n * cell / 2) - cell/2
    draw.content((a.len() * cell + 1.0, y),
      anchor: "west",
      text(size: 0.65em, weight: "bold", fill: oklch(35%, 0.15, 250deg))[$c_#n$])
  }

  // Convolution equation at bottom
  draw.content((a.len() * cell/2 + 0.35, -(b.len()) * cell - 0.6),
    text(size: 0.7em, fill: oklch(35%, 0.02, 265deg))[
      $c_n = sum_(i+j=n) a_i b_j$
    ])
})

// ═══════════════════════════════════════════════════════════════
// Catalan decomposition: recursive tree structure
// ═══════════════════════════════════════════════════════════════
// Metaphor: a binary tree that "breaks apart" at the root,
// revealing the recursive convolution C_{n+1} = Σ C_i C_{n-i}.
// Left side: the original tree. Right side: decomposition products.

#let cat-tree-node(x, y, r: 0.22, fill: oklch(88%, 0.03, 250deg)) = {
  draw.circle((x, y), radius: r, fill: fill, stroke: oklch(55%, 0.08, 250deg) + 0.6pt)
}

#let cat-tree-leaf(x, y) = {
  draw.rect((x - 0.12, y - 0.12), (x + 0.12, y + 0.12),
    fill: white, stroke: oklch(55%, 0.08, 250deg) + 0.5pt, radius: 1pt)
}

#let cat-tree-edge(x1, y1, x2, y2) = {
  draw.line((x1, y1), (x2, y2),
    stroke: oklch(35%, 0.02, 265deg) + 0.6pt)
}

#let catalan-recursive = canvas({
  // ── Original tree (left) ──
  // A binary tree with 4 internal nodes representing C_4
  // Root at (0, 4), splitting left and right

  // Root
  cat-tree-node(0, 4)
  // Left subtree: one internal node
  cat-tree-node(-1.2, 2.8)
  cat-tree-leaf(-1.6, 1.6)
  cat-tree-leaf(-0.8, 1.6)
  // Right subtree: two internal nodes
  cat-tree-node(1.2, 2.8)
  cat-tree-node(0.7, 1.6)
  cat-tree-leaf(0.3, 0.4)
  cat-tree-leaf(1.1, 0.4)
  cat-tree-leaf(1.7, 1.6)

  // Edges
  cat-tree-edge(0, 3.8, -1.2, 3.0)
  cat-tree-edge(0, 3.8, 1.2, 3.0)
  cat-tree-edge(-1.2, 2.6, -1.6, 1.8)
  cat-tree-edge(-1.2, 2.6, -0.8, 1.8)
  cat-tree-edge(1.2, 2.6, 0.7, 1.8)
  cat-tree-edge(1.2, 2.6, 1.7, 1.8)
  cat-tree-edge(0.7, 1.4, 0.3, 0.6)
  cat-tree-edge(0.7, 1.4, 1.1, 0.6)

  // Label
  draw.content((0, -0.3), text(size: 0.7em, weight: "bold",
    fill: oklch(35%, 0.02, 265deg))[$C_4$])

  // ── Equality sign ──
  draw.content((2.8, 2.0), text(size: 1.2em, fill: oklch(35%, 0.02, 265deg))[$=$])

  // ── Decomposition (right side) ──
  // Show the sum of products: C_0·C_3 + C_1·C_2 + C_2·C_1 + C_3·C_0
  // Each term shown as a pair of subtrees (left × right)

  let terms = (
    (0, 3, 3.8, 3.5, 5.5, 2.0),
    (1, 2, 6.5, 3.5, 8.2, 2.0),
    (2, 1, 9.2, 3.5, 10.9, 2.0),
    (3, 0, 11.9, 3.5, 13.6, 2.0),
  )

  for (i, (li, ri, x1, y1, x2, y2)) in terms.enumerate() {
    // Left subtree placeholder
    draw.rect((x1 - 0.6, y1 - 0.4), (x1 + 0.6, y1 + 0.4),
      radius: 4pt,
      fill: oklch(92%, 0.03, 250deg).transparentize(40%),
      stroke: oklch(60%, 0.08, 250deg) + 0.5pt)
    draw.content((x1, y1),
      text(size: 0.6em, fill: oklch(35%, 0.02, 265deg))[$C_#li$])

    // Right subtree placeholder
    draw.rect((x2 - 0.6, y2 - 0.4), (x2 + 0.6, y2 + 0.4),
      radius: 4pt,
      fill: oklch(92%, 0.04, 155deg).transparentize(40%),
      stroke: oklch(55%, 0.18, 155deg) + 0.5pt)
    draw.content((x2, y2),
      text(size: 0.6em, fill: oklch(35%, 0.02, 265deg))[$C_#ri$])

    // Plus sign between terms (except last)
    if i < terms.len() - 1 {
      let px = (x2 + 0.9, y1)
      draw.content(px, text(size: 0.8em, fill: oklch(35%, 0.02, 265deg))[$+$])
    }
  }
})

// ═══════════════════════════════════════════════════════════════
// Generating function as a "machine": sequence → GF → operations
// ═══════════════════════════════════════════════════════════════
// Metaphor: a pipeline that transforms a sequence into its closed form.

#let gf-pipeline = canvas({
  // Input: sequence on the left
  draw.rect((-4.5, -0.7), (-1.5, 0.7), radius: 8pt,
    fill: oklch(92%, 0.03, 250deg), stroke: oklch(60%, 0.08, 250deg) + 0.6pt)
  draw.content((-3.0, 0.2),
    text(size: 0.65em, weight: "bold", fill: oklch(35%, 0.02, 265deg))[$a_0, a_1, a_2, dots$])
  draw.content((-3.0, -0.3),
    text(size: 0.55em, fill: luma(50%))[последовательность])

  // Arrow 1
  draw.line((-1.2, 0), (0.5, 0),
    stroke: oklch(35%, 0.02, 265deg) + 0.7pt, mark: (end: "stealth"))
  draw.content((-0.35, 0.4),
    text(size: 0.5em, fill: luma(50%))[$sum a_n x^n$])

  // GF box
  draw.rect((0.8, -0.7), (2.8, 0.7), radius: 8pt,
    fill: oklch(88%, 0.05, 155deg), stroke: oklch(55%, 0.18, 155deg) + 0.6pt)
  draw.content((1.8, 0.2),
    text(size: 0.65em, weight: "bold", fill: oklch(35%, 0.02, 265deg))[$A(x)$])
  draw.content((1.8, -0.3),
    text(size: 0.55em, fill: luma(50%))[производящая функция])

  // Arrow 2: algebraic operations
  draw.line((3.1, 0), (4.8, 0),
    stroke: oklch(35%, 0.02, 265deg) + 0.7pt, mark: (end: "stealth"))
  draw.content((3.95, 0.4),
    text(size: 0.5em, fill: luma(50%))[решаем уравнение])

  // Result box
  draw.rect((5.1, -0.7), (7.1, 0.7), radius: 8pt,
    fill: oklch(88%, 0.06, 45deg), stroke: oklch(55%, 0.18, 45deg) + 0.6pt)
  draw.content((6.1, 0.2),
    text(size: 0.65em, weight: "bold", fill: oklch(35%, 0.02, 265deg))[$a_n = [x^n] A(x)$])
  draw.content((6.1, -0.3),
    text(size: 0.55em, fill: luma(50%))[явная формула])
})

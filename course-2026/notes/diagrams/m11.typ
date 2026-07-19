// M11 diagrams — Generating Functions.
#import "../requirements.typ": *
#import "../notation.typ": *

#import fletcher: diagram, edge, node
#import cetz: canvas, draw

// ── Convolution product: c_n = Σ a_i b_{n-i} ──
// Visual: two sequences stacked, showing which pairs contribute to each c_n.
#let c-conv-bg = oklch(92%, 0.03, 250deg)
#let c-conv-bg2 = oklch(92%, 0.03, 155deg)
#let c-conv-label = oklch(35%, 0.02, 265deg)
#let c-conv-arrow = oklch(50%, 0.10, 250deg) + 0.5pt

#let convolution-table = canvas({
  let s = 0.7
  // Sequence A (top row)
  draw.content((-0.6, 1.2), anchor: "east", text(
    size: 0.7em,
    fill: c-conv-label,
  )[$a_n$:])
  let a = (2, 1, 3, 0, 1)
  for (j, val) in a.enumerate() {
    draw.rect(
      (j * s, 1.0),
      (j * s + s, 1.6),
      fill: c-conv-bg,
      stroke: none,
      radius: 1pt,
    )
    draw.content((j * s + s / 2, 1.3), text(
      size: 0.65em,
      fill: c-conv-label,
    )[#val])
  }

  // Sequence B (left column, rotated visually to be below but conceptually aligned)
  draw.content((-0.6, 0.2), anchor: "east", text(
    size: 0.7em,
    fill: c-conv-label,
  )[$b_n$:])
  let b = (1, 3, 2, 0)
  for (i, val) in b.enumerate() {
    draw.rect(
      (-0.5, -i * s),
      (0.1, -i * s + 0.6),
      fill: c-conv-bg2,
      stroke: none,
      radius: 1pt,
    )
    draw.content((-0.2, -i * s + 0.3), text(
      size: 0.65em,
      fill: c-conv-label,
    )[#val])
  }

  // Convolution grid: show pairs (a_j, b_i) where i+j=n
  // For each n=0..4, show the contributing products
  for n in range(5) {
    let y = -n * s
    let terms = ()
    for i in range(0, n + 1) {
      if i < b.len() and (n - i) < a.len() {
        terms.push((i, n - i))
      }
    }
    if terms.len() > 0 {
      // Column of contributing pairs
      for (k, pair) in terms.enumerate() {
        let (bi, aj) = pair
        draw.content((1.2 + k * 2.2, y + 0.3), text(
          size: 0.6em,
          fill: c-conv-label,
        )[$a_#aj b_#bi$])
        if k > 0 {
          draw.content((1.2 + (k - 1) * 2.2 + 1.8, y + 0.3), text(
            size: 0.6em,
            fill: c-conv-label,
          )[$+$])
        }
      }
      // Equals c_n
      let cn = ()
      for pair in terms {
        let (bi, aj) = pair
        cn.push(a.at(aj) * b.at(bi))
      }
      draw.content((1.2 + terms.len() * 2.2, y + 0.3), text(
        size: 0.6em,
        fill: c-conv-label,
      )[$= c_#n = #cn.sum()$])
    }
  }
})

// ── Catalan tree decomposition: C_{n+1} = Σ C_i C_{n-i} ──
#let c-cat-node = oklch(88%, 0.03, 250deg)
#let c-cat-str = oklch(60%, 0.08, 250deg) + 0.7pt
#let c-cat-edge = oklch(35%, 0.02, 265deg) + 0.7pt
#let c-cat-sub = oklch(50%, 0.12, 250deg)
#let c-cat-label = oklch(35%, 0.02, 265deg)

#let catalan-decomposition = canvas({
  // Main tree (center): binary tree with 4 internal nodes (n=3 after removing root)
  // Root at top, splitting into left and right subtrees

  // Root
  draw.circle((0, 2.5), radius: 0.28, fill: c-cat-node, stroke: c-cat-str)
  draw.content((0, 2.5), text(size: 0.6em, fill: c-cat-label)[$r$])

  // Left subtree (i=1: one internal node)
  draw.circle((-1, 1.3), radius: 0.28, fill: c-cat-node, stroke: c-cat-str)
  draw.content((-1, 1.3), text(size: 0.6em, fill: c-cat-label)[$a$])
  // Left child of a (leaf)
  draw.rect(
    (-1.5, 0.2),
    (-1.1, -0.2),
    radius: 1pt,
    fill: white,
    stroke: c-cat-str,
  )
  draw.content((-1.3, 0), text(size: 0.55em, fill: luma(50%))[$bot$])
  // Right child of a (leaf)
  draw.rect(
    (-0.5, 0.2),
    (-0.1, -0.2),
    radius: 1pt,
    fill: white,
    stroke: c-cat-str,
  )
  draw.content((-0.3, 0), text(size: 0.55em, fill: luma(50%))[$bot$])

  // Right subtree (i=2: two internal nodes)
  draw.circle((1.2, 1.3), radius: 0.28, fill: c-cat-node, stroke: c-cat-str)
  draw.content((1.2, 1.3), text(size: 0.6em, fill: c-cat-label)[$b$])
  draw.circle((0.8, 0.2), radius: 0.28, fill: c-cat-node, stroke: c-cat-str)
  draw.content((0.8, 0.2), text(size: 0.6em, fill: c-cat-label)[$c$])
  // Leaves under right subtree
  draw.rect(
    (0.4, -0.9),
    (0.8, -1.3),
    radius: 1pt,
    fill: white,
    stroke: c-cat-str,
  )
  draw.content((0.6, -1.1), text(size: 0.55em, fill: luma(50%))[$bot$])
  draw.rect(
    (0.9, -0.9),
    (1.3, -1.3),
    radius: 1pt,
    fill: white,
    stroke: c-cat-str,
  )
  draw.content((1.1, -1.1), text(size: 0.55em, fill: luma(50%))[$bot$])
  // Right child of b
  draw.rect(
    (1.6, 0.2),
    (2.0, -0.2),
    radius: 1pt,
    fill: white,
    stroke: c-cat-str,
  )
  draw.content((1.8, 0), text(size: 0.55em, fill: luma(50%))[$bot$])

  // Edges: root to subtrees
  draw.line((0, 2.2), (-1, 1.6), stroke: c-cat-edge)
  draw.line((0, 2.2), (1.2, 1.6), stroke: c-cat-edge)
  // Left subtree edges
  draw.line((-1, 1.0), (-1.3, 0.2), stroke: c-cat-edge)
  draw.line((-1, 1.0), (-0.3, 0.2), stroke: c-cat-edge)
  // Right subtree edges
  draw.line((1.2, 1.0), (0.8, 0.5), stroke: c-cat-edge)
  draw.line((1.2, 1.0), (1.8, 0.2), stroke: c-cat-edge)
  draw.line((0.8, -0.1), (0.6, -0.9), stroke: c-cat-edge)
  draw.line((0.8, -0.1), (1.1, -0.9), stroke: c-cat-edge)

  // Brackets
  draw.rect((-2.0, 0.6), (-0.7, -0.5), radius: 6pt, fill: none, stroke: (
    paint: c-cat-sub,
    thickness: 0.5pt,
    dash: "dashed",
  ))
  draw.content((-1.35, -0.9), anchor: "north", text(
    size: 0.55em,
    fill: c-cat-sub,
  )[левое: $C_1$])

  draw.rect((0.3, 0.6), (2.3, -1.6), radius: 6pt, fill: none, stroke: (
    paint: c-cat-sub,
    thickness: 0.5pt,
    dash: "dashed",
  ))
  draw.content((1.3, -2.0), anchor: "north", text(
    size: 0.55em,
    fill: c-cat-sub,
  )[правое: $C_2$])

  // The formula at bottom
  draw.content((0, -2.7), text(
    size: 0.7em,
    fill: c-cat-label,
  )[$C_4 = sum_(i=0)^3 C_i C_(3-i)$])
})

// m20 diagrams: решётка свёртки, дерево рекурсии Каталана.
#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

// Тон анти-диагонали свёртки: одна ступень светлоты (акцентная синева) на слагаемое c_n.
#let c-conv-band(n) = oklch(93% - 2.4% * n, 0.05, 230deg)

// ── Решётка свёртки ──
#let convolution-grid = {
  let a = (2, 1, 3, 0, 1)
  let b = (1, 3, 2, 0)
  let cell = 0.9
  let cols = a.len()
  let rows = b.len()
  let xs(j) = 0.7 + j * cell
  let ys(i) = -i * cell

  // Ячейка (j, i): произведение a_j·b_i, заливка по диагонали n = i + j.
  let cell-box(j, i, n, val) = {
    let x = xs(j)
    let y = ys(i)
    draw.rect(
      (x, y - cell),
      (x + cell, y),
      fill: c-conv-band(n),
      stroke: (paint: c-bd, thickness: t-hr),
      radius: 2pt,
    )
    draw.content(
      (x + cell / 2, y - cell / 2),
      text(size: s-tiny, fill: c-muted)[#val],
    )
  }

  let col-head(j, val) = {
    let x = xs(j) + cell / 2
    draw.content((x, 0.85), text(size: s-cap, weight: "bold", fill: c-ink)[$a_#j$])
    draw.content((x, 0.4), text(size: s-tiny, fill: c-muted)[#val])
  }
  let row-head(i, val) = {
    let y = ys(i) - cell / 2
    draw.content((-0.15, y), anchor: "east", text(size: s-cap, weight: "bold", fill: c-ink)[$b_#i$])
    draw.content((0.35, y), anchor: "east", text(size: s-tiny, fill: c-muted)[#val])
  }

  canvas({
    for (j, val) in a.enumerate() {
      col-head(j, val)
    }
    for (i, val) in b.enumerate() {
      row-head(i, val)
    }
    for i in range(rows) {
      for j in range(cols) {
        cell-box(j, i, i + j, a.at(j) * b.at(i))
      }
    }
    for n in range(cols + rows - 1) {
      draw.content(
        (xs(cols - 1) + cell + 0.5, -(n * cell / 2) - cell / 2),
        anchor: "west",
        text(size: s-cap, weight: "bold", fill: c-accent)[$c_#n$],
      )
    }
    draw.content(
      ((xs(0) + xs(cols - 1) + cell) / 2, ys(rows - 1) - cell - 0.7),
      text(size: s-node, fill: c-ink)[$c_n = sum_(i+j=n) a_i b_j$],
    )
  })
}

// ── Дерево рекурсии Каталана ──
#let catalan-recursive = {
  let r = 0.2
  let l = 0.11

  let cat-node(pos, name) = draw.circle(
    pos,
    radius: r,
    fill: c-fl,
    stroke: (paint: c-bd, thickness: t-bd),
    name: name,
  )
  let cat-leaf(pos, name) = {
    let (x, y) = pos
    draw.rect(
      (x - l, y - l),
      (x + l, y + l),
      fill: white,
      stroke: (paint: c-bd, thickness: t-bd),
      radius: 1.5pt,
      name: name,
    )
  }
  let cat-edge(from, to) = draw.line(from, to, stroke: (paint: c-edge, thickness: t-ed))

  canvas({
    cat-node((0, 3.4), "root")
    cat-node((-1.2, 2.2), "L")
    cat-node((1.2, 2.2), "R")
    cat-leaf((-1.85, 1.0), "LL")
    cat-leaf((-0.55, 1.0), "LR")
    cat-node((0.55, 1.0), "RL")
    cat-leaf((1.85, 1.0), "RR")
    cat-leaf((0.25, -0.2), "RLL")
    cat-leaf((0.85, -0.2), "RLR")

    cat-edge("root", "L")
    cat-edge("root", "R")
    cat-edge("L", "LL")
    cat-edge("L", "LR")
    cat-edge("R", "RL")
    cat-edge("R", "RR")
    cat-edge("RL", "RLL")
    cat-edge("RL", "RLR")

    draw.content((0, -0.9), text(size: s-node, weight: "bold", fill: c-ink)[$C_4$])

    let bw = 0.46
    let pitch = 2.9
    let x0 = 3.5
    let y = 2.0

    let term(i, x) = {
      let ri = 3 - i
      draw.rect(
        (x - bw, y - 0.4),
        (x + bw, y + 0.4),
        fill: c-fl,
        stroke: (paint: c-bd, thickness: t-bd),
        radius: 4pt,
      )
      draw.content((x, y), text(size: s-node, fill: c-ink)[$C_#i$])
      draw.content((x + 0.7, y), text(size: s-cap, fill: c-ink)[$dot$])
      draw.rect(
        (x + 1.4 - bw, y - 0.4),
        (x + 1.4 + bw, y + 0.4),
        fill: c-atom,
        stroke: (paint: c-bd, thickness: t-bd),
        radius: 4pt,
      )
      draw.content((x + 1.4, y), text(size: s-node, fill: c-ink)[$C_#ri$])
    }

    draw.content((2.6, y), text(size: 1.1em, fill: c-ink)[$=$])

    for i in range(4) {
      term(i, x0 + pitch * i)
      if i < 3 {
        draw.content((x0 + pitch * i + 2.15, y), text(size: s-node, fill: c-ink)[$+$])
      }
    }
  })
}

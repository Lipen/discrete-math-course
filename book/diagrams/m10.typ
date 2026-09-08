#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

#let km-grid(rows, cols, s) = {
  let g = (paint: c-edge, thickness: t-hr)
  for i in range(rows + 1) {
    draw.line((0, -i * s), (cols * s, -i * s), stroke: g)
  }
  for j in range(cols + 1) {
    draw.line((j * s, 0), (j * s, -rows * s), stroke: g)
  }
}

// ── Карта Карно 3 переменных ──
#let karnaugh-3var = canvas({
  let s = 1.2
  km-grid(4, 2, s)

  let yz-coords = ("00", "01", "11", "10")
  for (i, label) in yz-coords.enumerate() {
    draw.content(
      (-0.4, -(i + 0.5) * s),
      anchor: "east",
      text(size: s-cap, fill: c-muted)[#label],
    )
  }

  draw.content(
    (s, 0.55),
    anchor: "south",
    text(size: s-cap, fill: c-muted)[$x$],
  )
  for j in range(2) {
    draw.content(
      ((j + 0.5) * s, 0.25),
      anchor: "south",
      text(size: s-tiny, fill: c-muted)[#j],
    )
  }

  draw.content(
    (-1.0, -2 * s),
    anchor: "east",
    text(size: s-cap, fill: c-muted)[$y z$],
  )
})

// ── Карта Карно 4 переменных ──
#let karnaugh-4var = canvas({
  let s = 1.2
  km-grid(4, 4, s)

  let yz-coords = ("00", "01", "11", "10")
  for (i, label) in yz-coords.enumerate() {
    draw.content(
      (-0.4, -(i + 0.5) * s),
      anchor: "east",
      text(size: s-cap, fill: c-muted)[#label],
    )
  }

  let wx-coords = ("00", "01", "11", "10")
  for (j, label) in wx-coords.enumerate() {
    draw.content(
      ((j + 0.5) * s, 0.25),
      anchor: "south",
      text(size: s-cap, fill: c-muted)[#label],
    )
  }

  draw.content(
    (-0.8, -2 * s),
    anchor: "east",
    text(size: s-cap, fill: c-muted)[$y z$],
  )
  draw.content(
    (2 * s, 0.7),
    anchor: "south",
    text(size: s-cap, fill: c-muted)[$w x$],
  )
})

// ── Карта Карно функции большинства ──
#let karnaugh-3var-majority = canvas({
  let s = 1.2

  // Единичные клетки функции большинства.
  let ones = ((1, 1), (2, 0), (2, 1), (3, 1))
  for (row, col) in ones {
    draw.rect(
      (col * s, -row * s),
      ((col + 1) * s, -(row + 1) * s),
      fill: c-fl,
      stroke: none,
    )
  }

  km-grid(4, 2, s)

  for (row, col) in ones {
    draw.content(
      ((col + 0.5) * s, -(row + 0.5) * s),
      text(size: s-node, fill: c-ink)[1],
    )
  }

  let yz-coords = ("00", "01", "11", "10")
  for (i, label) in yz-coords.enumerate() {
    draw.content(
      (-0.4, -(i + 0.5) * s),
      anchor: "east",
      text(size: s-cap, fill: c-muted)[#label],
    )
  }

  draw.content(
    (s, 0.55),
    anchor: "south",
    text(size: s-cap, fill: c-muted)[$x$],
  )
  for j in range(2) {
    draw.content(
      ((j + 0.5) * s, 0.25),
      anchor: "south",
      text(size: s-tiny, fill: c-muted)[#j],
    )
  }

  draw.content(
    (-1.0, -2 * s),
    anchor: "east",
    text(size: s-cap, fill: c-muted)[$y z$],
  )
})

// ── BDD для XOR ──
#let bdd-xor = {
  let vnode(pos, var, name) = {
    draw.circle(
      pos,
      radius: 0.4,
      fill: c-conn,
      stroke: t-bd + c-bd,
      name: name,
    )
    draw.content(pos, text(size: s-node, fill: c-ink)[#var])
  }
  let tnode(pos, val, name) = {
    let (cx, cy) = pos
    draw.rect(
      (cx - 0.3, cy - 0.3),
      (cx + 0.3, cy + 0.3),
      radius: 2pt,
      fill: c-atom,
      stroke: t-bd + c-bd,
      name: name,
    )
    draw.content(pos, text(size: s-node, fill: c-ink)[#val])
  }

  let ledge(from, to, edge-name) = {
    draw.line(
      from,
      to,
      name: edge-name,
      stroke: (paint: c-edge, thickness: t-ed, dash: "dashed"),
    )
    draw.content(
      edge-name + ".30%",
      text(size: s-tiny, fill: c-muted)[$0$],
      fill: white,
      stroke: none,
      padding: 2pt,
    )
  }
  let hedge(from, to, edge-name) = {
    draw.line(from, to, name: edge-name, stroke: (
      paint: c-edge,
      thickness: t-ed,
    ))
    draw.content(
      edge-name + ".30%",
      text(size: s-tiny, fill: c-muted)[$1$],
      fill: white,
      stroke: none,
      padding: 2pt,
    )
  }

  canvas({
    vnode((0, 3), $x$, "x")
    vnode((-2.0, 1), $y$, "y-lo")
    vnode((2.0, 1), $y$, "y-hi")
    tnode((-1.6, -1), 0, "t0")
    tnode((1.6, -1), 1, "t1")

    // x = 0 ведёт в f(0,y) = y, x = 1 --- в f(1,y) = ¬y.
    ledge("x", "y-lo", "e-x-lo")
    hedge("x", "y-hi", "e-x-hi")

    ledge("y-lo", "t0", "e-yl-t0")
    hedge("y-lo", "t1", "e-yl-t1")

    ledge("y-hi", "t1", "e-yr-t1")
    hedge("y-hi", "t0", "e-yr-t0")
  })
}

#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

#let km-grid(rows, cols, s) = {
  let g = (paint: c-edge, thickness: t-hr)
  for i in range(rows + 1) {
    draw.line((0, -i * s), (cols * s, -i * s), stroke: g)
  }
  for j in range(cols + 1) {
    draw.line((j * s, 0), (j * s, -rows * s), stroke: g)
  }
}

#let km-yz-labels(s) = for (i, label) in ("00", "01", "11", "10").enumerate() {
  draw.content(
    (-0.4, -(i + 0.5) * s),
    anchor: "east",
    text(size: s-cap, fill: c-muted)[#label],
  )
}

// ── Карта Карно 4 переменных ──
#let karnaugh-4var = canvas({
  let s = 1.2
  km-grid(4, 4, s)

  km-yz-labels(s)

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

  km-yz-labels(s)

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

// ── Гиперкуб Q4 в раскладке карты Карно ──
// Синие дуги --- циклические рёбра тора: они обходят карту снаружи.
#let hypercube-q4 = canvas({
  let s = 1.2
  let gray = ("00", "01", "11", "10")
  let e-straight = (paint: c-edge, thickness: t-ed)
  let e-wrap = (paint: c-accent, thickness: t-ed)

  let ctr(r, j) = ((j + 0.5) * s, -(r + 0.5) * s)
  let shift(p, d) = (p.at(0) + d.at(0), p.at(1) + d.at(1))

  let half-wrap(node, exit, apex, tan) = draw.bezier(
    node,
    apex,
    shift(node, exit),
    shift(apex, tan),
    stroke: e-wrap,
  )
  let wrap-h(r, apex-y, exit-l, exit-r, tan-x) = {
    let apex = (2 * s, apex-y)
    half-wrap(ctr(r, 0), exit-l, apex, (-tan-x, 0))
    half-wrap(ctr(r, 3), exit-r, apex, (tan-x, 0))
  }
  let wrap-v(j, apex-x, exit-bot, exit-top, tan-y) = {
    let apex = (apex-x, -2 * s)
    half-wrap(ctr(3, j), exit-bot, apex, (0, -tan-y))
    half-wrap(ctr(0, j), exit-top, apex, (0, tan-y))
  }

  wrap-h(0, 0.9, (-0.25, 0.85), (0.25, 0.85), 1.1)
  wrap-h(1, 1.75, (0.35, 0.95), (-0.35, 0.95), 1.3)
  wrap-h(3, -5.95, (0.18, -0.9), (-0.18, -0.9), 1.15)
  wrap-h(2, -6.75, (0.35, -0.95), (-0.35, -0.95), 1.3)
  wrap-v(0, -1.4, (-0.85, 0.35), (-0.85, -0.35), 1.1)
  wrap-v(1, -2.4, (-0.55, -0.3), (-0.45, -0.95), 1.3)
  wrap-v(3, 6.2, (0.85, 0.35), (0.85, -0.35), 1.1)
  wrap-v(2, 7.2, (0.55, -0.3), (0.45, -0.95), 1.3)

  for r in range(4) {
    for j in range(4) {
      draw.circle(
        ctr(r, j),
        radius: 0.38,
        name: "v" + str(r) + str(j),
        fill: c-fl,
        stroke: t-bd + c-bd,
      )
      draw.content("v" + str(r) + str(j), text(size: s-cap, fill: c-ink)[#(
        gray.at(j) + gray.at(r)
      )])
    }
  }
  for r in range(4) {
    for j in range(3) {
      draw.line(
        "v" + str(r) + str(j),
        "v" + str(r) + str(j + 1),
        stroke: e-straight,
      )
    }
  }
  for j in range(4) {
    for r in range(3) {
      draw.line(
        "v" + str(r) + str(j),
        "v" + str(r + 1) + str(j),
        stroke: e-straight,
      )
    }
  }

  for (r, label) in gray.enumerate() {
    draw.content(
      (-0.35, -(r + 0.5) * s),
      anchor: "east",
      frame: "rect",
      fill: c-white,
      stroke: none,
      padding: 2pt,
      text(size: s-cap, fill: c-muted)[#label],
    )
  }
  for (j, label) in gray.enumerate() {
    draw.content(
      ((j + 0.5) * s, 0.25),
      anchor: "south",
      frame: "rect",
      fill: c-white,
      stroke: none,
      padding: 2pt,
      text(size: s-cap, fill: c-muted)[#label],
    )
  }
})

// ── BDD для XOR ──
#let bdd-xor = {
  let vnode(pos, name, body) = node(
    pos,
    text(size: s-node, fill: c-ink)[#body],
    name: name,
    shape: circle,
    fill: c-conn,
    stroke: t-bd + c-bd,
    width: 1.5em,
    height: 1.5em,
    inset: 0pt,
  )
  let tnode(pos, name, val) = node(
    pos,
    text(size: s-node, fill: c-ink)[#val],
    name: name,
    fill: c-atom,
    stroke: t-bd + c-bd,
    inset: 4pt,
  )
  let bedge(from, to, bit) = edge(
    from,
    to,
    "-",
    stroke: if bit == 0 {
      (paint: c-edge, thickness: t-ed, dash: "dashed")
    } else {
      (paint: c-edge, thickness: t-ed)
    },
    label: text(size: s-tiny, fill: c-muted)[$#bit$],
    label-pos: 30%,
    label-side: center,
    label-fill: c-white,
  )

  diagram(
    spacing: 3.6em,
    vnode((0, 0), <x>, $x$),
    vnode((-1.5, 1), <y-lo>, $y$),
    vnode((1.5, 1), <y-hi>, $y$),
    tnode((-1.2, 2), <t0>, 0),
    tnode((1.2, 2), <t1>, 1),

    // x = 0 ведёт в f(0,y) = y, x = 1 --- в f(1,y) = ¬y.
    bedge(<x>, <y-lo>, 0),
    bedge(<x>, <y-hi>, 1),
    bedge(<y-lo>, <t0>, 0),
    bedge(<y-lo>, <t1>, 1),
    bedge(<y-hi>, <t1>, 0),
    bedge(<y-hi>, <t0>, 1),
  )
}

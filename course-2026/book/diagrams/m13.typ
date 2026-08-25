// m13 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

#let c-node = oklch(88%, 0.03, 250deg)

#let c-node-str = oklch(60%, 0.08, 250deg)

#let c-edge = oklch(35%, 0.02, 265deg) + 0.5pt

#let c-label = oklch(35%, 0.02, 265deg)

#let implication-graph-2sat-simple = canvas({
  let r = 0.4
  draw.circle((0, 0.8), radius: r, fill: c-node, stroke: c-node-str, name: "x")
  draw.content((0, 0.8), text(size: 0.72em, fill: c-label)[$x$])

  draw.circle(
    (0, -0.8),
    radius: r,
    fill: c-node,
    stroke: c-node-str,
    name: "notx",
  )
  draw.content((0, -0.8), text(size: 0.72em, fill: c-label)[$overline(x)$])

  draw.circle((2, 0.8), radius: r, fill: c-node, stroke: c-node-str, name: "y")
  draw.content((2, 0.8), text(size: 0.72em, fill: c-label)[$y$])

  draw.circle(
    (2, -0.8),
    radius: r,
    fill: c-node,
    stroke: c-node-str,
    name: "noty",
  )
  draw.content((2, -0.8), text(size: 0.72em, fill: c-label)[$overline(y)$])

  // Edges : node names, border-to-border
  draw.line("notx", "y", stroke: c-edge, mark: (end: ">"))
  draw.line("x", "y", stroke: c-edge, mark: (end: ">"))

  // Labels
  draw.content((1, 1.4), anchor: "south", text(size: 0.65em, fill: oklch(
    45%,
    0.02,
    265deg,
  ))[$x or y$])
  draw.content((1, -1.4), anchor: "north", text(size: 0.65em, fill: oklch(
    45%,
    0.02,
    265deg,
  ))[$not x or y$])
})

#let dpll-dec-fill = oklch(92%, 0.04, 250deg)

#let dpll-dec-str = oklch(55%, 0.15, 250deg) + 0.8pt

#let dpll-up-fill = oklch(92%, 0.04, 155deg)

#let dpll-up-str = oklch(55%, 0.18, 155deg) + 0.7pt

#let dpll-conf-fill = oklch(92%, 0.06, 22deg)

#let dpll-conf-str = oklch(55%, 0.20, 22deg) + 0.8pt

#let dpll-edge-color = oklch(35%, 0.02, 265deg)

#let dpll-label = oklch(30%, 0.02, 265deg)

#let dpll-box(pos, w, h, fill, stroke, title, subtitle, name) = {
  let (cx, cy) = pos
  draw.rect(
    (cx - w / 2, cy - h / 2),
    (cx + w / 2, cy + h / 2),
    radius: 4pt,
    fill: fill,
    stroke: stroke,
    name: name,
  )
  draw.content((cx, cy + 0.15), text(size: 0.55em, fill: dpll-label)[#title])
  if subtitle != none {
    draw.content((cx, cy - 0.2), text(size: 0.5em, fill: luma(45%))[#subtitle])
  }
}

#let dpll-dead-end(pos, name) = {
  let (cx, cy) = pos
  draw.line(
    (cx - 0.2, cy - 0.15),
    (cx + 0.2, cy - 0.4),
    stroke: dpll-conf-str,
    name: name + "-x1",
  )
  draw.line(
    (cx + 0.2, cy - 0.15),
    (cx - 0.2, cy - 0.4),
    stroke: dpll-conf-str,
    name: name + "-x2",
  )
}

#let dpll-edge(from-anchor, to-anchor) = {
  draw.line(from-anchor, to-anchor, stroke: dpll-edge-color + 0.7pt)
}

#let dpll-tree = canvas({
  // ── Formula ──
  dpll-box(
    (0, 4.2),
    5.0,
    0.8,
    oklch(96%, 0.01, 260deg),
    oklch(60%, 0.05, 260deg) + 0.5pt,
    $(x or y) and (not x or y) and (x or not y) and (not x or not y)$,
    none,
    "formula",
  )

  // ── Decision ──
  dpll-box(
    (0, 3.0),
    2.0,
    0.6,
    dpll-dec-fill,
    dpll-dec-str,
    [выбор $x$],
    none,
    "decision",
  )
  dpll-edge("formula.south", "decision.north")

  // ── Left branch (x=1) ──
  draw.content((-2.1, 3.3), anchor: "south", text(
    size: 0.6em,
    fill: dpll-label,
  )[$x = 1$])
  dpll-box(
    (-2.1, 1.9),
    2.2,
    0.8,
    dpll-up-fill,
    dpll-up-str,
    [unit propagation],
    [$(not x or y) -> y = 1$],
    "up-left",
  )
  dpll-edge("decision.south-west", "up-left.north")

  dpll-box(
    (-2.1, 0.7),
    2.2,
    0.8,
    dpll-conf-fill,
    dpll-conf-str,
    [конфликт],
    [$(not x or not y)$ пуст],
    "conf-left",
  )
  dpll-edge("up-left.south", "conf-left.north")
  dpll-dead-end((-2.1, 0.0), "dead-left")

  // ── Right branch (x=0) ──
  draw.content((2.1, 3.3), anchor: "south", text(
    size: 0.6em,
    fill: dpll-label,
  )[$x = 0$])
  dpll-box(
    (2.1, 1.9),
    2.2,
    0.8,
    dpll-up-fill,
    dpll-up-str,
    [unit propagation],
    [$(x or y) -> y = 1$],
    "up-right",
  )
  dpll-edge("decision.south-east", "up-right.north")

  dpll-box(
    (2.1, 0.7),
    2.2,
    0.8,
    dpll-conf-fill,
    dpll-conf-str,
    [конфликт],
    [$(x or not y)$ пуст],
    "conf-right",
  )
  dpll-edge("up-right.south", "conf-right.north")
  dpll-dead-end((2.1, 0.0), "dead-right")
})

#let clt-cell-str = 0.5pt + oklch(50%, 0.05, 250deg)

#let clt-cell-fill = oklch(97%, 0.01, 260deg)

#let clt-window-str = 1pt + oklch(55%, 0.18, 22deg)

#let clt-label = oklch(35%, 0.02, 265deg)

#let cook-levin-table = canvas({
  let rows = 4
  let cols = 6
  let cell = 0.55
  let head-y = (rows + 0.6) / 2 * 1.0

  // Grid cells: (i, t) with tape position i horizontal, step t vertical (down).
  for t in range(rows) {
    for i in range(cols) {
      let x = (i - (cols - 1) / 2) * cell
      let y = (rows / 2 - 0.5 - t) * cell
      draw.rect(
        (x - cell / 2, y - cell / 2),
        (x + cell / 2, y + cell / 2),
        fill: clt-cell-fill,
        stroke: clt-cell-str,
        name: "c-" + str(t) + "-" + str(i),
      )
    }
  }

  // Head markers
  for i in range(2, 5) {
    let x = (i - (cols - 1) / 2) * cell
    let y = (rows / 2 - 0.5 - 1) * cell
    draw.content((x, y + 0.02), text(
      size: 0.5em,
      fill: oklch(55%, 0.18, 22deg),
    )[$H$])
  }

  // Locality window: cells (t=0..1, i=2..4) -> 2 rows × 3 columns.
  let x0 = (2 - (cols - 1) / 2) * cell - cell / 2
  let x1 = (4 - (cols - 1) / 2) * cell + cell / 2
  let y0 = (rows / 2 - 0.5 - 1) * cell + cell / 2
  let y1 = (rows / 2 - 0.5 - 0) * cell - cell / 2
  draw.rect(
    (x0, y0),
    (x1, y1),
    stroke: clt-window-str,
    fill: none,
    name: "window",
  )

  // Axis labels.
  draw.content(
    (0, (rows / 2 + 0.8) * cell),
    text(size: 0.6em, fill: clt-label)[шаг $t$],
  )
  draw.content(
    (-(cols / 2 + 0.5) * cell, 0),
    rotate(90deg, text(size: 0.6em, fill: clt-label)[позиция $i$]),
  )
  draw.content(
    ((cols / 2 + 0.8) * cell, 0),
    rotate(-90deg, text(size: 0.55em, fill: luma(45%))[локальность: ячейка зависит от трёх выше]),
  )
})

#let cdcl-node-fill = oklch(92%, 0.03, 250deg)

#let cdcl-node-str = 0.6pt + oklch(55%, 0.08, 250deg)

#let cdcl-conf-fill = oklch(92%, 0.06, 22deg)

#let cdcl-conf-str = 0.8pt + oklch(55%, 0.20, 22deg)

#let cdcl-cut-str = 0.7pt + oklch(55%, 0.14, 300deg)

#let cdcl-edge = 0.6pt + oklch(35%, 0.02, 265deg)

#let cdcl-label = oklch(30%, 0.02, 265deg)

#let cdcl-node(pos, label, name, ..style) = {
  let (cx, cy) = pos
  draw.circle(
    (cx, cy),
    radius: 0.32,
    fill: cdcl-node-fill,
    stroke: cdcl-node-str,
    name: name,
    ..style,
  )
  draw.content((cx, cy), text(size: 0.62em, fill: cdcl-label)[#label])
}

#let cdcl-conflict-graph = canvas({
  // Decision level 1 (left): x1 = 1 at decision.
  cdcl-node((-2.6, 1.6), $x_1$, "x1", fill: oklch(92%, 0.05, 155deg), stroke: (
    paint: oklch(50%, 0.16, 155deg),
    thickness: 0.8pt,
  ))
  draw.content((-3.3, 1.9), text(size: 0.5em, fill: luma(50%))[ур. 1])
  cdcl-node((-1.5, 0.6), $overline(x_2)$, "nx2")
  cdcl-node((-0.4, 0.0), $x_3$, "x3")

  // Decision level 2 (right): x4 = 0 at decision.
  cdcl-node((2.6, 1.6), $overline(x_4)$, "nx4", fill: oklch(
    92%,
    0.05,
    155deg,
  ), stroke: (
    paint: oklch(50%, 0.16, 155deg),
    thickness: 0.8pt,
  ))
  draw.content((3.3, 1.9), text(size: 0.5em, fill: luma(50%))[ур. 2])
  cdcl-node((1.5, 0.6), $x_5$, "x5")

  // Conflict node in the middle.
  cdcl-node((0.0, -1.2), $bot$, "conf", fill: cdcl-conf-fill, stroke: cdcl-conf-str)

  // Implication edges: two chains converging at the conflict.
  draw.line("x1", "nx2", stroke: cdcl-edge, mark: (end: ">"))
  draw.line("nx2", "x3", stroke: cdcl-edge, mark: (end: ">"))
  draw.line("x3", "conf", stroke: cdcl-edge, mark: (end: ">"))
  draw.line("nx4", "x5", stroke: cdcl-edge, mark: (end: ">"))
  draw.line("x5", "conf", stroke: cdcl-edge, mark: (end: ">"))

  // Clause labels on edges.
  draw.content(((-2.6 - 1.5) / 2, 1.15), anchor: "south", text(
    size: 0.48em,
    fill: luma(45%),
  )[$overline(x_1) or overline(x_2)$])
  draw.content(((-1.5 - 0.4) / 2, 0.35), anchor: "south", text(
    size: 0.48em,
    fill: luma(45%),
  )[$x_2 or x_3$])
  draw.content(((2.6 + 1.5) / 2, 1.15), anchor: "south", text(
    size: 0.48em,
    fill: luma(45%),
  )[$x_4 or x_5$])

  // 1-UIP cut: dashed line separating reason (left+right) from conflict.
  draw.line(
    (-0.9, 0.7),
    (0.9, 0.7),
    name: "cut",
    stroke: cdcl-cut-str,
    dash: "dashed",
  )
  draw.content((0.95, 0.85), anchor: "west", text(
    size: 0.52em,
    fill: oklch(55%, 0.14, 300deg),
  )[разрез 1-UIP])

  // Learned clause below.
  draw.content(
    (0, -1.9),
    text(size: 0.6em, fill: cdcl-label)[выученный дизъюнкт: $x_1 or x_4$],
  )
})

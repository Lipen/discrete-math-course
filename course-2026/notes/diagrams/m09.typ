// M08 diagrams --- SAT: implication graph for 2-SAT.
#import "../requirements.typ": *
#import cetz: canvas, draw

#let c-node = oklch(88%, 0.03, 250deg)
#let c-node-str = oklch(60%, 0.08, 250deg)
#let c-edge = oklch(35%, 0.02, 265deg) + 0.5pt
#let c-label = oklch(35%, 0.02, 265deg)
#let c-arrow = oklch(35%, 0.02, 265deg)

// Implication graph for: (x or y) and (not x or z) and (not y or not z)
// Clauses:
//   (x or y)    → not x → y,  not y → x
//   (not x or z) → x → z,     not z → not x
//   (not y or not z) → y → not z,  z → not y
//
// Layout: 6 nodes --- x, not x, y, not y, z, not z
// x=(0,1), notx=(0,-1), y=(2,1), noty=(2,-1), z=(4,1), notz=(4,-1)
#let implication-graph-2sat = canvas({
  let r = 0.4
  let positions = (
    ((0, 1.2), $x$),
    ((0, -1.2), $overline(x)$),
    ((2, 1.2), $y$),
    ((2, -1.2), $overline(y)$),
    ((4, 1.2), $z$),
    ((4, -1.2), $overline(z)$),
  )

  // Nodes
  for pair in positions {
    let pos = pair.at(0)
    let label = pair.at(1)
    draw.circle(pos, radius: r, fill: c-node, stroke: c-node-str)
    draw.content(pos, text(size: 0.72em, fill: c-label)[#label])
  }

  // Edges from (x or y): not x → y, not y → x
  draw.line((-0.3, -1.2), (1.7, 1.2), stroke: c-edge, mark: (end: ">"))
  draw.line((1.7, -1.2), (-0.3, 1.2), stroke: c-edge, mark: (end: ">"))

  // Edges from (not x or z): x → z, not z → not x
  draw.line((0.35, 1.2), (3.65, 1.2), stroke: c-edge, mark: (end: ">"))
  draw.line((3.65, -1.2), (0.35, -1.2), stroke: c-edge, mark: (end: ">"))

  // Edges from (not y or not z): y → not z, z → not y
  draw.line((2.35, 1.2), (3.65, -1.2), stroke: c-edge, mark: (end: ">"))
  draw.line((4.35, 1.2), (2.35, -1.2), stroke: c-edge, mark: (end: ">"))
})

// Simpler example for explanation: (x or y) and (not x or y)
// Clauses:
//   (x or y)    → not x → y
//   (not x or y) → x → y
// This formula is satisfiable: set y=true.
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

  // Edges
  draw.line((-0.35, -0.8), (1.65, 0.8), stroke: c-edge, mark: (end: ">"))
  draw.line((0.35, 0.8), (1.65, 0.8), stroke: c-edge, mark: (end: ">"))

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

// ── DPLL decision tree: φ = (x∨y) ∧ (¬x∨y) ∧ (x∨¬y) ∧ (¬x∨¬y) ──
#let dpll-dec-fill = oklch(92%, 0.04, 250deg)
#let dpll-dec-str = oklch(55%, 0.15, 250deg) + 0.8pt
#let dpll-up-fill = oklch(92%, 0.04, 155deg)
#let dpll-up-str = oklch(55%, 0.18, 155deg) + 0.7pt
#let dpll-conf-fill = oklch(92%, 0.06, 22deg)
#let dpll-conf-str = oklch(55%, 0.20, 22deg) + 0.8pt
#let dpll-edge-color = oklch(35%, 0.02, 265deg)
#let dpll-label = oklch(30%, 0.02, 265deg)

// Helper: rounded box with text, returns named node
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

// Helper: X marker for dead ends
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

// Helper: edge between named anchor strings
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
    [$(not x or y) → y = 1$],
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
    [$(x or y) → y = 1$],
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


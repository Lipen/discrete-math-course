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

// ── DPLL decision landscape for φ = (x∨y) ∧ (¬x∨y) ∧ (x∨¬y) ∧ (¬x∨¬y) ──
// Metaphor: search as a branching road. Each decision forks the path;
// unit propagation is gravitational pull toward inevitable conclusions;
// conflicts are dead ends. When all roads lead to conflict → UNSAT.
#let c-dpll-dec-fill = oklch(92%, 0.04, 250deg)
#let c-dpll-dec-str = oklch(55%, 0.15, 250deg) + 0.8pt
#let c-dpll-up-fill = oklch(92%, 0.04, 155deg)
#let c-dpll-up-str = oklch(55%, 0.18, 155deg) + 0.7pt
#let c-dpll-conf-fill = oklch(92%, 0.06, 22deg)
#let c-dpll-conf-str = oklch(55%, 0.20, 22deg) + 0.8pt
#let c-dpll-edge = oklch(35%, 0.02, 265deg) + 0.7pt
#let c-dpll-label = oklch(30%, 0.02, 265deg)

#let dpll-tree = canvas({
  // ── Formula box at top ──
  draw.rect((-2.5, 3.8), (2.5, 4.6), radius: 6pt,
    fill: oklch(96%, 0.01, 260deg),
    stroke: oklch(60%, 0.05, 260deg) + 0.5pt)
  draw.content((0, 4.2),
    text(size: 0.55em, fill: c-dpll-label)[$(x or y) and (not x or y) and (x or not y) and (not x or not y)$])

  // ── Decision node: x ──
  draw.rect((-0.5, 2.7), (0.5, 3.3), radius: 4pt,
    fill: c-dpll-dec-fill, stroke: c-dpll-dec-str)
  draw.content((0, 3.0), text(size: 0.65em, weight: "bold", fill: c-dpll-label)[выбор $x$])

  draw.line((0, 3.8), (0, 3.3), stroke: c-dpll-edge)

  // ── Left branch: x=1 ──
  // Branch label
  draw.content((-1.6, 2.8), text(size: 0.6em, fill: c-dpll-label)[$x = 1$])

  // Unit propagation box
  draw.rect((-3.2, 1.5), (-1.0, 2.3), radius: 4pt,
    fill: c-dpll-up-fill, stroke: c-dpll-up-str)
  draw.content((-2.1, 2.05), text(size: 0.55em, fill: c-dpll-label)[unit propagation])
  draw.content((-2.1, 1.75), text(size: 0.5em, fill: luma(45%))[$(not x or y) → y = 1$])

  // Conflict box
  draw.rect((-3.2, 0.3), (-1.0, 1.1), radius: 4pt,
    fill: c-dpll-conf-fill, stroke: c-dpll-conf-str)
  draw.content((-2.1, 0.8), text(size: 0.55em, weight: "bold", fill: c-dpll-label)[конфликт])
  draw.content((-2.1, 0.5), text(size: 0.5em, fill: luma(45%))[$(not x or not y)$ пуст])

  // Edges
  draw.line((-0.3, 2.9), (-2.1, 2.3), stroke: c-dpll-edge)
  draw.line((-2.1, 1.5), (-2.1, 1.1), stroke: c-dpll-edge)

  // ── Right branch: x=0 ──
  draw.content((1.6, 2.8), text(size: 0.6em, fill: c-dpll-label)[$x = 0$])

  // Unit propagation box
  draw.rect((1.0, 1.5), (3.2, 2.3), radius: 4pt,
    fill: c-dpll-up-fill, stroke: c-dpll-up-str)
  draw.content((2.1, 2.05), text(size: 0.55em, fill: c-dpll-label)[unit propagation])
  draw.content((2.1, 1.75), text(size: 0.5em, fill: luma(45%))[$(x or y) → y = 1$])

  // Conflict box
  draw.rect((1.0, 0.3), (3.2, 1.1), radius: 4pt,
    fill: c-dpll-conf-fill, stroke: c-dpll-conf-str)
  draw.content((2.1, 0.8), text(size: 0.55em, weight: "bold", fill: c-dpll-label)[конфликт])
  draw.content((2.1, 0.5), text(size: 0.5em, fill: luma(45%))[$(x or not y)$ пуст])

  // Edges
  draw.line((0.3, 2.9), (2.1, 2.3), stroke: c-dpll-edge)
  draw.line((2.1, 1.5), (2.1, 1.1), stroke: c-dpll-edge)

  // Dead-end markers (X)
  for x in (-2.1, 2.1) {
    draw.line((x - 0.25, -0.1), (x + 0.25, -0.5), stroke: c-dpll-conf-str)
    draw.line((x + 0.25, -0.1), (x - 0.25, -0.5), stroke: c-dpll-conf-str)
  }
})


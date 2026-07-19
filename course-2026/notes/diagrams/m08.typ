// M08 diagrams — SAT: implication graph for 2-SAT.
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
// Layout: 6 nodes — x, not x, y, not y, z, not z
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

  draw.circle((0, -0.8), radius: r, fill: c-node, stroke: c-node-str, name: "notx")
  draw.content((0, -0.8), text(size: 0.72em, fill: c-label)[$overline(x)$])

  draw.circle((2, 0.8), radius: r, fill: c-node, stroke: c-node-str, name: "y")
  draw.content((2, 0.8), text(size: 0.72em, fill: c-label)[$y$])

  draw.circle((2, -0.8), radius: r, fill: c-node, stroke: c-node-str, name: "noty")
  draw.content((2, -0.8), text(size: 0.72em, fill: c-label)[$overline(y)$])

  // Edges
  draw.line((-0.35, -0.8), (1.65, 0.8), stroke: c-edge, mark: (end: ">"))
  draw.line((0.35, 0.8), (1.65, 0.8), stroke: c-edge, mark: (end: ">"))

  // Labels
  draw.content((1, 1.4), anchor: "south", text(size: 0.65em, fill: oklch(45%, 0.02, 265deg))[$x or y$])
  draw.content((1, -1.4), anchor: "north", text(size: 0.65em, fill: oklch(45%, 0.02, 265deg))[$not x or y$])
})

// ── DPLL search tree for φ = (x∨y) ∧ (¬x∨y) ∧ (x∨¬y) ∧ (¬x∨¬y) ──
// UNSAT formula: φ = y ∧ ¬y after resolving on x.
#let c-dpll-node = oklch(88%, 0.03, 250deg)
#let c-dpll-str = oklch(60%, 0.08, 250deg) + 0.7pt
#let c-dpll-dec = oklch(88%, 0.06, 250deg) // decision node
#let c-dpll-up = oklch(88%, 0.05, 155deg)  // unit propagation
#let c-dpll-conf = oklch(88%, 0.08, 22deg) // conflict
#let c-dpll-edge = oklch(35%, 0.02, 265deg) + 0.7pt
#let c-dpll-label = oklch(35%, 0.02, 265deg)

#let dpll-tree = canvas({
  // Root: decide x
  draw.circle((0, 3), radius: 0.35, fill: c-dpll-dec, stroke: c-dpll-str, name: "root")
  draw.content((0, 3), text(size: 0.6em, fill: c-dpll-label)[$x$])

  // Left branch: x=1
  draw.circle((-2.5, 1.5), radius: 0.35, fill: c-dpll-up, stroke: c-dpll-str, name: "l-up")
  draw.content((-2.5, 1.5), text(size: 0.6em, fill: c-dpll-label)[$y!=!1$])

  draw.rect((-3.1, 0.1), (-1.9, -0.5), radius: 4pt, fill: c-dpll-conf, stroke: oklch(55%, 0.18, 22deg) + 0.7pt, name: "l-conf")
  draw.content((-2.5, -0.2), text(size: 0.55em, fill: c-dpll-label)[конфликт])

  // Right branch: x=0
  draw.circle((2.5, 1.5), radius: 0.35, fill: c-dpll-up, stroke: c-dpll-str, name: "r-up")
  draw.content((2.5, 1.5), text(size: 0.6em, fill: c-dpll-label)[$y!=!1$])

  draw.rect((1.9, 0.1), (3.1, -0.5), radius: 4pt, fill: c-dpll-conf, stroke: oklch(55%, 0.18, 22deg) + 0.7pt, name: "r-conf")
  draw.content((2.5, -0.2), text(size: 0.55em, fill: c-dpll-label)[конфликт])

  // Edges
  draw.line("root", "l-up", stroke: c-dpll-edge)
  draw.line("root", "r-up", stroke: c-dpll-edge)
  draw.line("l-up", "l-conf", stroke: c-dpll-edge)
  draw.line("r-up", "r-conf", stroke: c-dpll-edge)

  // Branch labels
  draw.content((-1.2, 2.4), anchor: "south", text(size: 0.6em, fill: c-dpll-label)[$x!=!1$])
  draw.content((1.2, 2.4), anchor: "south", text(size: 0.6em, fill: c-dpll-label)[$x!=!0$])

  // Unit propagation annotations
  draw.content((-2.5, 0.7), anchor: "south",
    text(size: 0.5em, fill: luma(50%))[$(not x or y) → y$])
  draw.content((2.5, 0.7), anchor: "south",
    text(size: 0.5em, fill: luma(50%))[$(x or y) → y$])

})


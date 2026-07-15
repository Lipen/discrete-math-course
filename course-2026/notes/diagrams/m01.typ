// M01 diagrams — parse trees and logic visualizations.
#import "@preview/fletcher:0.5.8": diagram, edge, node
#import "../notation.typ": iff, imply

// ── Colors ──

#let c-edge = oklch(35%, 0.02, 265deg)
#let c-edge-str = (paint: c-edge, thickness: 0.8pt)
#let c-connective = oklch(92%, 0.04, 45deg)
#let c-atom = oklch(92%, 0.02, 155deg)

// ── Parse tree for (not p and q) -> r ──
// Root at top (level 0); leaves at bottom.
// All nodes are uniform circles: explicit width/height + shape: "circle".
#let parse-tree-imply = diagram(
  node-shape: "circle",
  node-stroke: 0.6pt + luma(70%),
  node-inset: 0pt,
  node-outset: 0pt,
  edge-stroke: c-edge-str,
  spacing: 2em,
  // Level 0 — root (top)
  node(
    (0, 0),
    $arrow.r$,
    name: <root>,
    fill: c-connective,
    width: 2em,
    height: 2em,
  ),
  // Level 1
  node(
    (-2, 1),
    $and$,
    name: <and>,
    fill: c-connective,
    width: 2em,
    height: 2em,
  ),
  node((2, 1), $r$, name: <r>, fill: c-atom, width: 1.6em, height: 1.6em),
  // Level 2
  node(
    (-3, 2),
    $not$,
    name: <not>,
    fill: c-connective,
    width: 2em,
    height: 2em,
  ),
  node((-0.5, 2), $q$, name: <q>, fill: c-atom, width: 1.6em, height: 1.6em),
  // Level 3 — leaves (bottom)
  node((-3, 3), $p$, name: <p>, fill: c-atom, width: 1.6em, height: 1.6em),
  // Edges — no explicit anchors, natural circle-to-circle routing
  edge(<root>, <and>, "-"),
  edge(<root>, <r>, "-"),
  edge(<and>, <not>, "-"),
  edge(<and>, <q>, "-"),
  edge(<not>, <p>, "-"),
)

// ── Parse tree for not(p and q) -> r ──
// Compare structure with parse-tree-imply.
#let parse-tree-not-and = diagram(
  node-shape: "circle",
  node-stroke: 0.6pt + luma(70%),
  node-inset: 0pt,
  node-outset: 0pt,
  edge-stroke: c-edge-str,
  spacing: 2em,
  // Level 0 — root (top)
  node(
    (0, 0),
    $arrow.r$,
    name: <root2>,
    fill: c-connective,
    width: 2em,
    height: 2em,
  ),
  // Level 1
  node(
    (-1.5, 1),
    $not$,
    name: <not2>,
    fill: c-connective,
    width: 2em,
    height: 2em,
  ),
  node((2, 1), $r$, name: <r2>, fill: c-atom, width: 1.6em, height: 1.6em),
  // Level 2
  node(
    (-1.5, 2),
    $and$,
    name: <and2>,
    fill: c-connective,
    width: 2em,
    height: 2em,
  ),
  // Level 3 — leaves (bottom)
  node((-2.5, 3), $p$, name: <p2>, fill: c-atom, width: 1.6em, height: 1.6em),
  node((-0.5, 3), $q$, name: <q2>, fill: c-atom, width: 1.6em, height: 1.6em),
  // Edges
  edge(<root2>, <not2>, "-"),
  edge(<root2>, <r2>, "-"),
  edge(<not2>, <and2>, "-"),
  edge(<and2>, <p2>, "-"),
  edge(<and2>, <q2>, "-"),
)

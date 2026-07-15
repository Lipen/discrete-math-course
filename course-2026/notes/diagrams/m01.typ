// M01 diagrams — parse trees and logic visualizations.
#import "@preview/fletcher:0.5.8": diagram, edge, node
#import "../notation.typ": iff, imply

// ── Shared constants ──

#let n-size = 1.6em
#let n-stroke = 0.6pt + luma(70%)
#let e-stroke = (paint: oklch(35%, 0.02, 265deg), thickness: 0.8pt)
#let c-connective = oklch(92%, 0.04, 45deg)
#let c-atom = oklch(92%, 0.02, 155deg)

// ── Parse tree for (not p and q) -> r ──
#let parse-tree-imply = {
  let cn(pos, label, ..args) = node(
    pos,
    label,
    fill: c-connective,
    width: n-size,
    height: n-size,
    ..args,
  )
  let an(pos, label, ..args) = node(
    pos,
    label,
    fill: c-atom,
    width: n-size,
    height: n-size,
    ..args,
  )
  let e(to, from) = edge(to, from, "-", stroke: e-stroke)

  diagram(
    node-shape: "circle",
    node-stroke: n-stroke,
    node-inset: 0pt,
    node-outset: 0pt,
    spacing: 2em,

    // Tree structure — root at top, leaves at bottom
    cn((0, 0), $arrow.r$, name: <root>),
    cn((-2, 1), $and$, name: <and>),
    an((2, 1), $r$, name: <r>),
    cn((-3, 2), $not$, name: <not>),
    an((-0.5, 2), $q$, name: <q>),
    an((-3, 3), $p$, name: <p>),

    e(<root>, <and>),
    e(<root>, <r>),
    e(<and>, <not>),
    e(<and>, <q>),
    e(<not>, <p>),
  )
}

// ── Parse tree for not(p and q) -> r ──
#let parse-tree-not-and = {
  let cn(pos, label, ..args) = node(
    pos,
    label,
    fill: c-connective,
    width: n-size,
    height: n-size,
    ..args,
  )
  let an(pos, label, ..args) = node(
    pos,
    label,
    fill: c-atom,
    width: n-size,
    height: n-size,
    ..args,
  )
  let e(to, from) = edge(to, from, "-", stroke: e-stroke)

  diagram(
    node-shape: "circle",
    node-stroke: n-stroke,
    node-inset: 0pt,
    node-outset: 0pt,
    spacing: 2em,

    // Tree structure
    cn((0, 0), $arrow.r$, name: <root2>),
    cn((-1.5, 1), $not$, name: <not2>),
    an((2, 1), $r$, name: <r2>),
    cn((-1.5, 2), $and$, name: <and2>),
    an((-2.5, 3), $p$, name: <p2>),
    an((-0.5, 3), $q$, name: <q2>),

    e(<root2>, <not2>),
    e(<root2>, <r2>),
    e(<not2>, <and2>),
    e(<and2>, <p2>),
    e(<and2>, <q2>),
  )
}

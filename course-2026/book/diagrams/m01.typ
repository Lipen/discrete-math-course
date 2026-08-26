// m01 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

#let n-size = 1.6em

#let n-stroke = 0.6pt + luma(70%)

#let e-stroke = (paint: oklch(35%, 0.02, 265deg), thickness: 0.8pt)

#let c-connective = oklch(92%, 0.04, 45deg)

#let c-atom = oklch(92%, 0.02, 155deg)

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

    // Tree structure: root at top, leaves at bottom
    cn((0, 0), $imply$, name: <root>),
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

#let quantifier-order = {
  let x-node(pos, label, ..args) = node(
    pos,
    label,
    fill: c-atom,
    width: n-size,
    height: n-size,
    ..args,
  )
  let e(to, from) = edge(to, from, "->", stroke: e-stroke)

  diagram(
    node-shape: "circle",
    node-stroke: n-stroke,
    node-inset: 0pt,
    node-outset: 0pt,
    spacing: 2em,

    // ∀x ∃y --- left
    node(
      (-3, 4),
      text(size: 0.85em)[$forall x exists y$],
      fill: none,
      stroke: none,
    ),
    x-node((-4, 0), $x_1$, name: <x1>),
    x-node((-4, 1.5), $x_2$, name: <x2>),
    x-node((-4, 3), $x_3$, name: <x3>),
    x-node((-2, 0), $y_1$, name: <y1>),
    x-node((-2, 1.5), $y_2$, name: <y2>),
    x-node((-2, 3), $y_3$, name: <y3>),
    e(<x1>, <y1>),
    e(<x2>, <y2>),
    e(<x3>, <y3>),

    // ∃y ∀x --- right
    node(
      (3, 4),
      text(size: 0.85em)[$exists y forall x$],
      fill: none,
      stroke: none,
    ),
    x-node((2, 0), $x_1$, name: <a1>),
    x-node((2, 1.5), $x_2$, name: <a2>),
    x-node((2, 3), $x_3$, name: <a3>),
    x-node((4, 1.5), $y$, name: <yy>),
    e(<a1>, <yy>),
    e(<a2>, <yy>),
    e(<a3>, <yy>),
  )
}

#let square-of-opposition = {
  let c-square = oklch(45%, 0.12, 260deg)
  let corner-size = 0.4
  let square-width = 3.0

  let corner(pos, label-text) = {
    let (x, y) = pos
    draw.rect(
      (x - corner-size, y + corner-size),
      (x + corner-size, y - corner-size),
      name: label-text,
      stroke: 1pt + c-square,
      radius: 5pt,
    )
    draw.content(label-text, text(1.4em)[#label-text])
  }

  let sq-edge(from, to, style: "solid", ..args) = {
    let st = if style == "dashed" {
      (paint: c-square, thickness: 2pt, dash: "dashed")
    } else if style == "arrow" {
      (paint: c-square, thickness: 2pt)
    } else {
      2pt + c-square
    }
    draw.line(from, to, name: from + "-" + to, stroke: st, ..args)
  }

  let edge-label(edge-name, body, ..args) = {
    draw.content(edge-name, body, ..args)
  }

  canvas({

    // Four corners
    corner((0, 0), "A")
    corner((square-width, 0), "E")
    corner((0, -square-width), "I")
    corner((square-width, -square-width), "O")

    // Top: contraries
    sq-edge("A", "E")
    // Bottom: subcontraries
    sq-edge("I", "O")
    // Diagonals: contradictories
    sq-edge("A", "O", style: "dashed")
    sq-edge("I", "E", style: "dashed")
    // Verticals: subalternation
    sq-edge("A", "I", style: "arrow", mark: (end: "stealth", fill: c-square))
    sq-edge("E", "O", style: "arrow", mark: (end: "stealth", fill: c-square))

    edge-label(
      "A-E",
      [Противоположность\ (contraries)],
      anchor: "south",
      padding: 0.2,
    )
    edge-label(
      "I-O",
      [Частичная совместимость\ (subcontraries)],
      anchor: "north",
      padding: 0.2,
    )
    edge-label(
      "A-I",
      [Подчинение\ (subalternation)],
      anchor: "east",
      padding: 0.2,
    )
    edge-label(
      "E-O",
      [Подчинение\ (subalternation)],
      anchor: "west",
      padding: 0.2,
    )
    edge-label(
      "I-E",
      box(fill: white, inset: 3pt)[Противоречие\ (contradictories)],
      anchor: "south",
      padding: 1pt,
    )
  })
}

#let c-res-in = oklch(88%, 0.03, 250deg)

#let c-res-mid = oklch(88%, 0.03, 155deg)

#let c-res-empty = oklch(88%, 0.06, 22deg)

#let c-res-str = oklch(60%, 0.08, 250deg) + 0.7pt

#let c-res-empty-str = oklch(55%, 0.18, 22deg) + 0.7pt

#let c-res-edge = oklch(35%, 0.02, 265deg) + 0.6pt

#let cn(pos, body, fill: c-res-in, ..args) = node(
  pos,
  body,
  fill: fill,
  width: 2.2em,
  height: 1.1em,
  ..args,
)

#let re(from, to) = edge(from, to, "-", stroke: c-res-edge)

#let resolution-dag = diagram(
  node-shape: "rect",
  node-stroke: c-res-str,
  node-inset: 4pt,
  node-outset: 4pt,
  spacing: 1.6em,

  // Input clauses (top row)
  cn((-4, 0), $not p or q$, name: <c1>),
  cn((-2, 0), $p$, name: <c3>),
  cn((0, 0), $not q or r$, name: <c2>),
  cn((2, 0), $not r$, name: <c4>),

  // Intermediate resolvents (middle row)
  cn((-3, 1.5), $q$, fill: c-res-mid, name: <r1>),
  cn((1, 1.5), $r$, fill: c-res-mid, name: <r2>),

  // Empty clause (bottom)
  cn(
    (-1, 3),
    $square$,
    fill: c-res-empty,
    stroke: c-res-empty-str,
    name: <empty>,
  ),

  // Resolution edges
  re(<c1>, <r1>),
  re(<c3>, <r1>),
  re(<c2>, <r2>),
  re(<r1>, <r2>),
  re(<r2>, <empty>),
  re(<c4>, <empty>),

  // Edge labels (cut variables)
  edge(<c1>, <r1>, "-", stroke: none, label: [$p$], label-size: 0.55em),
  edge(<c3>, <r1>, "-", stroke: none, label: [$p$], label-size: 0.55em),
  edge(<c2>, <r2>, "-", stroke: none, label: [$q$], label-size: 0.55em),
  edge(<r1>, <r2>, "-", stroke: none, label: [$q$], label-size: 0.55em),
  edge(<r2>, <empty>, "-", stroke: none, label: [$r$], label-size: 0.55em),
  edge(<c4>, <empty>, "-", stroke: none, label: [$r$], label-size: 0.55em),
)

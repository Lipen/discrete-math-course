// m19 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

#let c-mc-state = oklch(88%, 0.03, 250deg)

#let c-mc-str = oklch(60%, 0.08, 250deg)

#let c-mc-edge = oklch(35%, 0.02, 265deg)

#let c-mc-label = oklch(30%, 0.02, 265deg)

#let markov-chain = canvas({

  // state node helper
  let state(pos, label, name) = {
    let (x, y) = pos
    draw.circle(
      (x, y),
      radius: 0.5,
      name: name,
      fill: c-mc-state,
      stroke: 0.8pt + c-mc-str,
    )
    draw.content(
      (x, y),
      text(size: 0.9em, fill: c-mc-label, weight: "bold")[#label],
    )
  }

  // edge label helper
  let elabel(edge-name, label-text, anchor: "south") = {
    draw.content(
      edge-name + ".mid",
      text(size: 0.7em, fill: c-mc-label)[#label-text],
      frame: "rect",
      fill: white,
      stroke: none,
      padding: 1pt,
      anchor: anchor,
    )
  }

  // ── States ──
  state((0, 0), [$S$], "S")
  state((5, 0), [$R$], "R")

  // ── Transitions ──

  // S -> R
  draw.line(
    "S.north-east",
    "R.north-west",
    name: "s-r",
    stroke: 0.7pt + c-mc-edge,
    mark: (end: ">"),
  )
  elabel("s-r", [$0.2$])

  // R -> S
  draw.line(
    "R.south-west",
    "S.south-east",
    name: "r-s",
    stroke: 0.7pt + c-mc-edge,
    mark: (end: ">"),
  )
  elabel("r-s", [$0.4$])

  // S -> S (self-loop)
  draw.bezier(
    "S.north-west",
    "S.north-east",
    (-1.2, 1.5),
    (1.2, 1.5),
    name: "s-s",
    stroke: 0.7pt + c-mc-edge,
    mark: (end: ">"),
  )
  elabel("s-s", [$0.8$])

  // R -> R (self-loop)
  draw.bezier(
    "R.north-west",
    "R.north-east",
    (3.8, 1.5),
    (6.2, 1.5),
    name: "r-r",
    stroke: 0.7pt + c-mc-edge,
    mark: (end: ">"),
  )
  elabel("r-r", [$0.6$])
})

#let c-pt-node = oklch(55%, 0.13, 250deg)

#let c-pt-leaf = oklch(55%, 0.12, 160deg)

#let c-pt-edge = oklch(35%, 0.02, 265deg)

#let c-pt-label = oklch(35%, 0.02, 265deg)

#let c-pt-prob = oklch(55%, 0.12, 22deg)

#let probability-tree = canvas({
  // prob edge helper
  let prob-edge(from, to, prob) = {
    let name = "e-" + from + "-" + to
    draw.line(from, to, stroke: 0.6pt + c-pt-edge, name: name)
    draw.content(
      name,
      text(size: 0.75em, fill: c-pt-label)[$#prob$],
      frame: "rect",
      fill: white,
      stroke: none,
      padding: 1pt,
    )
  }

  // leaf label helper
  let leaf-label(name, outcome, prob) = {
    draw.content(
      name,
      anchor: "south",
      text(size: 0.7em, fill: c-pt-label)[#outcome],
      padding: 0.08,
    )
    draw.content(
      name,
      anchor: "north",
      text(size: 0.65em, fill: c-pt-prob)[$#prob$],
      padding: 0.06,
    )
  }

  // ── Nodes ──
  draw.circle((0, 3.5), radius: 0.15, fill: c-pt-node, name: "root")
  draw.circle((2, 1.8), radius: 0.14, fill: c-pt-node, name: "H")
  draw.circle((-2, 1.8), radius: 0.14, fill: c-pt-node, name: "T")
  draw.circle((3, 0), radius: 0.12, fill: c-pt-leaf, name: "HH")
  draw.circle((1, 0), radius: 0.12, fill: c-pt-leaf, name: "HT")
  draw.circle((-1, 0), radius: 0.12, fill: c-pt-leaf, name: "TH")
  draw.circle((-3, 0), radius: 0.12, fill: c-pt-leaf, name: "TT")

  // ── Edges with labels ──
  prob-edge("root", "H", 0.6)
  prob-edge("root", "T", 0.4)
  prob-edge("H", "HH", 0.6)
  prob-edge("H", "HT", 0.4)
  prob-edge("T", "TH", 0.6)
  prob-edge("T", "TT", 0.4)

  // ── Node labels (level 1) ──
  draw.content(
    "H",
    anchor: "west",
    text(size: 0.8em, fill: c-pt-node, weight: "bold")[$H$],
    padding: 0.15,
  )
  draw.content(
    "T",
    anchor: "east",
    text(size: 0.8em, fill: c-pt-node, weight: "bold")[$T$],
    padding: 0.15,
  )

  // ── Leaf labels ──
  leaf-label("HH", [$H H$], 0.36)
  leaf-label("HT", [$H T$], 0.24)
  leaf-label("TH", [$T H$], 0.24)
  leaf-label("TT", [$T T$], 0.16)
})

#let bayes-net = canvas({
  let c-bn-fill = oklch(92%, 0.04, 250deg)
  let c-bn-stroke = oklch(55%, 0.08, 250deg)
  let c-bn-label = oklch(30%, 0.02, 265deg)
  let c-bn-edge = oklch(35%, 0.02, 265deg)

  // Rounded rectangle node
  let node(pos, label, name) = {
    let (x, y) = pos
    draw.rect(
      (x - 1.2, y + 0.45),
      (x + 1.2, y - 0.45),
      name: name,
      fill: c-bn-fill,
      stroke: 0.8pt + c-bn-stroke,
      radius: 8pt,
    )
    draw.content(
      (x, y),
      text(size: 0.9em, fill: c-bn-label, weight: "bold")[#label],
    )
  }

  // Directed edge
  let dir-edge(from-anchor, to-anchor) = {
    draw.line(
      from-anchor,
      to-anchor,
      stroke: 0.7pt + c-bn-edge,
      mark: (end: ">"),
    )
  }

  // ── Nodes ──
  node((0, 2.2), [Грипп], "flu")
  node((-2.5, -0.3), [Кашель], "cough")
  node((2.5, -0.3), [Температура], "fever")

  // ── Edges ──
  dir-edge("flu.south-west", "cough.north")
  dir-edge("flu.south-east", "fever.north")

  // ── CPT: Flu ──
  draw.content(
    "flu.east",
    text(size: 0.65em, fill: c-bn-label)[$P("Flu") = 0.05$],
    anchor: "west",
    padding: 0.3,
  )

  // ── CPT: Cough ──
  draw.content(
    "cough.east",
    anchor: "west",
    padding: 0.25,
    text(size: 0.6em, fill: c-bn-label)[
      $P("Cough" | "Flu") = 0.8$\
      $P("Cough" | not "Flu") = 0.1$
    ],
  )

  // ── CPT: Fever ──
  draw.content(
    "fever.east",
    anchor: "west",
    padding: 0.25,
    text(size: 0.6em, fill: c-bn-label)[
      $P("Fever" | "Flu") = 0.9$\
      $P("Fever" | not "Flu") = 0.05$
    ],
  )
})

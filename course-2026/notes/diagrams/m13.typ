// M13 Automata diagrams : fletcher state machines.
#import "../requirements.typ": *
#import "../notation.typ": *

#import fletcher: diagram, edge, node
#import cetz: canvas, draw

#let c-state = oklch(88%, 0.03, 250deg)
#let c-state-str = oklch(60%, 0.08, 250deg)
#let c-accept = oklch(88%, 0.05, 155deg)
#let c-accept-str = oklch(55%, 0.18, 155deg)
#let c-edge = oklch(35%, 0.02, 265deg)

// ── 1. DFA: strings over {0,1} ending with "01" ──
#let dfa-01 = diagram(
  node-stroke: (paint: c-state-str, thickness: 0.8pt),
  node-fill: c-state,
  edge-stroke: (paint: c-edge, thickness: 0.7pt),
  spacing: 3em,
  // Incoming arrow
  edge((-1, 0), "-}>"),
  node((0, 0), $q_0$, name: <q0>),
  edge(<q0>, <q1>, "-}>", label: "0"),
  node((1, 0), $q_1$, name: <q1>),
  edge(<q1>, <q2>, "-}>", label: "1"),
  node((2, 0), $q_2$, name: <q2>, fill: c-accept, stroke: (
    paint: c-accept-str,
    thickness: 1.2pt,
  )),
  // Self-loops
  edge(<q0>, <q0>, "-}>", label: "1", bend: -50deg),
  edge(<q1>, <q1>, "-}>", label: "0", bend: -50deg),
  // Back edges
  edge(<q2>, <q1>, "-}>", label: "0", bend: 40deg),
  edge(<q2>, <q0>, "-}>", label: "1", bend: -40deg),
)

// ── 2. NFA: strings containing "00" or "11" ──
#let nfa-00-11 = diagram(
  node-stroke: (paint: c-state-str, thickness: 0.8pt),
  node-fill: c-state,
  edge-stroke: (paint: c-edge, thickness: 0.7pt),
  spacing: 3em,
  edge((-1, 0), "-}>"),
  node((0, 0), $q_0$, name: <s0>),
  // Upper branch
  edge(<s0>, <s1>, "-}>", label: "0"),
  node((1, 1), $q_1$, name: <s1>),
  edge(<s1>, <sa>, "-}>", label: "0"),
  node((2, 1), $q_a$, name: <sa>, fill: c-accept, stroke: (
    paint: c-accept-str,
    thickness: 1.2pt,
  )),
  // Lower branch
  edge(<s0>, <s2>, "-}>", label: "1"),
  node((1, -1), $q_2$, name: <s2>),
  edge(<s2>, <sb>, "-}>", label: "1"),
  node((2, -1), $q_b$, name: <sb>, fill: c-accept, stroke: (
    paint: c-accept-str,
    thickness: 1.2pt,
  )),
  // Mismatch: back to start
  edge(<s1>, <s0>, "-}>", label: "1", bend: -40deg),
  edge(<s2>, <s0>, "-}>", label: "0", bend: 40deg),
  // Accepting self-loops
  edge(<sa>, <sa>, "-}>", label: "0,1", bend: -50deg),
  edge(<sb>, <sb>, "-}>", label: "0,1", bend: 50deg),
)

// ── Pumping Lemma visualization ──
#let c-pl-str = oklch(60%, 0.08, 250deg) + 0.7pt
#let c-pl-fill = oklch(88%, 0.03, 250deg)
#let c-pl-y-color = oklch(55%, 0.18, 22deg)
#let c-pl-y-str = c-pl-y-color + 0.7pt
#let c-pl-edge = oklch(35%, 0.02, 265deg) + 0.7pt
#let c-pl-label = oklch(35%, 0.02, 265deg)

// Schematic: string split into x·y·z, with y looping
#let pumping-lemma = canvas({
  // States in a line: start → q_i → q_j → accept
  let sy = 0
  draw.circle(
    (-3, sy),
    radius: 0.35,
    fill: c-pl-fill,
    stroke: c-pl-str,
    name: "start",
  )
  draw.content((-3, sy), text(size: 0.6em, fill: c-pl-label)[$q_0$])

  draw.circle(
    (-0.5, sy),
    radius: 0.35,
    fill: c-pl-fill,
    stroke: c-pl-str,
    name: "qi",
  )
  draw.content((-0.5, sy), text(size: 0.6em, fill: c-pl-label)[$q_i$])

  draw.circle(
    (2, sy),
    radius: 0.35,
    fill: c-pl-fill,
    stroke: c-pl-str,
    name: "qj",
  )
  draw.content((2, sy), text(size: 0.6em, fill: c-pl-label)[$q_j$])

  draw.circle(
    (4.5, sy),
    radius: 0.35,
    fill: c-pl-fill,
    stroke: c-pl-str,
    name: "acc",
  )
  draw.content((4.5, sy), text(size: 0.6em, fill: c-pl-label)[$q_f$])

  // Double circle for accept
  draw.circle((4.5, sy), radius: 0.45, fill: none, stroke: c-pl-str)

  // Path edges
  draw.line("start", "qi", stroke: c-pl-edge)
  draw.line("qi", "qj", stroke: (paint: c-pl-y-color, thickness: 0.8pt))
  draw.line("qj", "acc", stroke: c-pl-edge)

  // Labels for x, y, z segments
  draw.content((-1.75, 0.55), anchor: "south", text(
    size: 0.65em,
    fill: c-pl-label,
  )[$x$])
  draw.content((0.75, 0.55), anchor: "south", text(
    size: 0.65em,
    fill: c-pl-y-color,
    weight: "bold",
  )[$y$])
  draw.content((3.25, 0.55), anchor: "south", text(
    size: 0.65em,
    fill: c-pl-label,
  )[$z$])

  // Loop back from q_j to q_i (the "pumping" loop)
  draw.bezier((2.3, 0.45), (-0.2, 0.45), (1.5, 1.3), (0.5, 1.3), stroke: (
    paint: c-pl-y-color,
    thickness: 0.6pt,
    dash: "dashed",
  ))

  // Below: pumped strings
  let yy = -2.0
  draw.content((0.5, yy), text(size: 0.7em, fill: c-pl-label)[
    $x z$ (0 повторений $y$)
  ])
  draw.content((0.5, yy - 0.5), text(size: 0.7em, fill: c-pl-label)[
    $x y z$ (1 повторение)
  ])
  draw.content((0.5, yy - 1.0), text(size: 0.7em, fill: c-pl-label)[
    $x y y z$ (2 повторения)
  ])
  draw.content((0.5, yy - 1.5), text(size: 0.7em, fill: c-pl-label)[
    $x y^k z$ ($k$ повторений)
  ])
})

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

// ── Pumping Lemma: x·y·z with y loop ──
#let pl-node-fill = oklch(90%, 0.02, 260deg)
#let pl-node-str = oklch(55%, 0.06, 260deg) + 0.7pt
#let pl-y-color = oklch(55%, 0.18, 22deg)
#let pl-edge = oklch(35%, 0.02, 265deg) + 0.7pt
#let pl-label = oklch(30%, 0.02, 265deg)

// State node
#let pl-state(pos, label, name, ..style) = {
  draw.circle(
    pos,
    radius: 0.35,
    fill: pl-node-fill,
    stroke: pl-node-str,
    name: name,
    ..style,
  )
  draw.content(pos, text(size: 0.65em, fill: pl-label)[#label])
}

#let pumping-lemma = canvas({
  // ── States (left to right) ──
  pl-state((-3, 0), $q_0$, "q0")
  pl-state((-0.5, 0), $q_i$, "qi")
  pl-state((2, 0), $q_j$, "qj")
  pl-state((4.5, 0), $q_f$, "qf")
  // Accept state: double circle
  draw.circle(
    (4.5, 0),
    radius: 0.45,
    fill: none,
    stroke: pl-node-str,
    name: "qf-ring",
  )

  // ── Forward edges (named, with segment labels at midpoints) ──
  draw.line("q0", "qi", name: "e-x", stroke: pl-edge)
  draw.content(
    "e-x.mid",
    text(size: 0.65em, fill: pl-label)[$x$],
    frame: "rect",
    fill: white,
    stroke: none,
    padding: 1pt,
    anchor: "south",
  )

  draw.line("qi", "qj", name: "e-y", stroke: (
    paint: pl-y-color,
    thickness: 0.9pt,
  ))
  draw.content(
    "e-y.mid",
    text(size: 0.65em, fill: pl-y-color, weight: "bold")[$y$],
    frame: "rect",
    fill: white,
    stroke: none,
    padding: 1pt,
    anchor: "south",
  )

  draw.line("qj", "qf", name: "e-z", stroke: pl-edge)
  draw.content(
    "e-z.mid",
    text(size: 0.65em, fill: pl-label)[$z$],
    frame: "rect",
    fill: white,
    stroke: none,
    padding: 1pt,
    anchor: "south",
  )

  // ── Loop back: q_j → q_i (the "pumping" cycle) ──
  // Bezier arc above the states, from q_j.north back to qi.north
  draw.bezier(
    "qj.north",
    "qi.north",
    (1.5, 1.5),
    (-0.2, 1.5),
    name: "e-loop",
    stroke: (paint: pl-y-color, thickness: 0.7pt, dash: "dashed"),
  )

  // ── Pumped strings below ──
  let pumped = (
    ([$x z$ (0 повторений)], -1.8),
    ([$x y z$ (1 повторение)], -2.3),
    ([$x y^2 z$ (2 повторения)], -2.8),
    ([$x y^k z$ ($k$ повторений)], -3.3),
  )
  for (k, (label, y)) in pumped.enumerate() {
    draw.content((0.5, y), text(size: 0.65em, fill: if k == 1 {
      pl-label
    } else { luma(55%) })[#label])
  }
})

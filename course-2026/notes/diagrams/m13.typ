// M13 Automata diagrams — fletcher state machines.
#import "@preview/fletcher:0.5.8": diagram, edge, node

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

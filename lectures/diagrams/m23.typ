// Finite automata: DFA, NFA, eps-NFA, subset construction, Thompson.
#import "style.typ": *
#import "@preview/fletcher:0.5.8": diagram, edge, node, shapes

// Круги-состояния: обычные в cool, принимающие --- двойная зелёная обводка.
#let state-stroke = 1.4pt + cool
#let accept-stroke = 1.4pt + green
#let start-stroke = (paint: ink, thickness: 1.2pt, cap: "round")

#let state(name, pos, label, accept: false) = node(
  pos,
  label,
  name: name,
  shape: shapes.circle,
  fill: if accept { green.lighten(82%) } else { cool.lighten(82%) },
  stroke: if accept { accept-stroke } else { state-stroke },
  inset: 0.38em,
  extrude: if accept { (0, 1.6) } else { (0,) },
)

#let start-at(to, from: -0.8) = edge((from, 0), to, "-|>", stroke: start-stroke)

// ── 1. DFA: strings over {0,1} ending with "01" ──
#let dfa-01 = diagram(
  edge-stroke: edge-plain,
  spacing: 3.2em,
  start-at(<q0>),
  state(<q0>, (0, 0), $q_0$),
  state(<q1>, (1, 0), $q_1$),
  state(<q2>, (2, 0), $q_2$, accept: true),
  edge(<q0>, <q1>, "-}>", label: [0]),
  edge(<q1>, <q2>, "-}>", label: [1]),
  edge(<q0>, <q0>, "-}>", label: [1], loop-angle: 90deg, bend: 120deg),
  edge(<q1>, <q1>, "-}>", label: [0], loop-angle: 90deg, bend: 120deg),
  edge(<q2>, <q1>, "-}>", label: [0], bend: 40deg),
  edge(<q2>, <q0>, "-}>", label: [1], bend: -50deg),
)

// ── 2. NFA with epsilon: contains "01", or the empty word ──
#let nfa-01-eps = diagram(
  edge-stroke: edge-plain,
  spacing: 3em,
  start-at(<s>),
  state(<s>, (0, 0), $s$),
  state(<q0>, (1, 0), $q_0$),
  state(<q1>, (2, 1), $q_1$),
  state(<q2>, (2, -1), $q_2$, accept: true),
  edge(<s>, <q0>, "-}>", label: [$epsilon$], stroke: edge-soft),
  edge(<s>, <q2>, "-}>", label: [$epsilon$], stroke: edge-soft, bend: 30deg),
  edge(<q0>, <q0>, "-}>", label: [0,1], loop-angle: 90deg, bend: 120deg),
  edge(<q0>, <q1>, "-}>", label: [0], label-side: right),
  edge(<q1>, <q2>, "-}>", label: [1]),
  edge(<q2>, <q2>, "-}>", label: [0,1], loop-angle: 90deg, bend: 120deg),
)

// ── 2b. Same automaton with the epsilon-edge repaired: the empty word is
// ──     served by a separate accepting state with no outgoing edges.
#let nfa-01-eps-fixed = diagram(
  edge-stroke: edge-plain,
  spacing: 3em,
  start-at(<s>),
  state(<s>, (0, 0), $s$),
  state(<q0>, (1, 0), $q_0$),
  state(<q1>, (2, 1), $q_1$),
  state(<q2>, (2, -1), $q_2$, accept: true),
  state(<f>, (0, -1.8), $f$, accept: true),
  edge(<s>, <q0>, "-}>", label: [$epsilon$], stroke: edge-soft),
  edge(<s>, <f>, "-}>", label: [$epsilon$], stroke: edge-soft),
  edge(<q0>, <q0>, "-}>", label: [0,1], loop-angle: 90deg, bend: 120deg),
  edge(<q0>, <q1>, "-}>", label: [0], label-side: right),
  edge(<q1>, <q2>, "-}>", label: [1]),
  edge(<q2>, <q2>, "-}>", label: [0,1], loop-angle: 90deg, bend: 120deg),
)

// ── 3. DFA: even number of ones ──
#let dfa-even-ones = diagram(
  edge-stroke: edge-plain,
  spacing: 4em,
  start-at(<e0>),
  state(<e0>, (0, 0), $q_0$, accept: true),
  state(<e1>, (1, 0), $q_1$),
  edge(<e0>, <e0>, "-}>", label: [0], loop-angle: 90deg, bend: 120deg),
  edge(<e0>, <e1>, "-}>", label: [1], bend: 30deg),
  edge(<e1>, <e1>, "-}>", label: [0], loop-angle: 90deg, bend: 120deg),
  edge(<e1>, <e0>, "-}>", label: [1], bend: 30deg),
)

// ── 4. NFA: strings ending with "01" ──
#let nfa-ends-01 = diagram(
  edge-stroke: edge-plain,
  spacing: 2.7em,
  start-at(<n0>),
  state(<n0>, (0, 0), $s$),
  state(<n1>, (1.5, 0), $q_1$),
  state(<n2>, (3, 0), $q_2$, accept: true),
  edge(<n0>, <n0>, "-}>", label: [0, 1], loop-angle: 90deg, bend: 120deg),
  edge(<n0>, <n1>, "-}>", label: [0]),
  edge(<n1>, <n2>, "-}>", label: [1]),
)

// ── 5. Subset construction result: states are sets of NFA states ──
#let dfa-subset-01 = diagram(
  edge-stroke: edge-plain,
  spacing: 4.5em,
  start-at(<m0>, from: -0.5),
  state(<m0>, (0, 0), text[$s$]),
  state(<m1>, (1.6, 0), text[$s, q_1$]),
  state(<m2>, (3.2, 0), text[$s, q_2$], accept: true),
  edge(<m0>, <m0>, "-}>", label: [1], loop-angle: 90deg, bend: 120deg),
  edge(<m0>, <m1>, "-}>", label: [0]),
  edge(<m1>, <m1>, "-}>", label: [0], loop-angle: 90deg, bend: 120deg),
  edge(<m1>, <m2>, "-}>", label: [1]),
  edge(<m2>, <m1>, "-}>", label: [0], bend: -40deg),
  edge(<m2>, <m0>, "-}>", label: [1], bend: -50deg),
)

// ── 6. NFA: third symbol from the end equals 1 ──
#let nfa-third-one = diagram(
  edge-stroke: edge-plain,
  spacing: 3em,
  start-at(<t0>),
  state(<t0>, (0, 0), $s$),
  state(<t1>, (1.4, 0), $q_1$),
  state(<t2>, (2.8, 0), $q_2$),
  state(<t3>, (4.2, 0), $q_3$, accept: true),
  edge(<t0>, <t0>, "-}>", label: [0, 1], loop-angle: 90deg, bend: 120deg),
  edge(<t0>, <t1>, "-}>", label: [1]),
  edge(<t1>, <t2>, "-}>", label: [0, 1]),
  edge(<t2>, <t3>, "-}>", label: [0, 1]),
)

// ── 7. Thompson construction for (0|1)*1 ──
#let thompson-star-one = diagram(
  edge-stroke: edge-plain,
  spacing: 3em,
  start-at(<p0>),
  state(<p0>, (0, 0), $s$),
  state(<p1>, (1.5, 0), $q$),
  state(<p2>, (3, 0), $r$),
  state(<p3>, (4.5, 0), $f$, accept: true),
  edge(<p0>, <p1>, "-}>", label: [$epsilon$], stroke: edge-soft),
  edge(<p1>, <p1>, "-}>", label: [0, 1], loop-angle: 90deg, bend: 120deg),
  edge(<p1>, <p2>, "-}>", label: [$epsilon$], stroke: edge-soft),
  edge(<p2>, <p3>, "-}>", label: [1]),
)

// ── 8. Four-state DFA for the even-ones language ──
#let dfa-redundant = diagram(
  edge-stroke: edge-plain,
  spacing: 2.6em,
  start-at(<d0>),
  state(<d0>, (0, 0), $r_0$, accept: true),
  state(<d1>, (2, 0), $r_1$),
  state(<d2>, (0, 2), $r_2$, accept: true),
  state(<d3>, (2, 2), $r_3$),
  edge(<d0>, <d1>, "-}>", label: [1]),
  edge(<d1>, <d0>, "-}>", label: [1], bend: 40deg),
  edge(<d0>, <d2>, "-}>", label: [0]),
  edge(<d1>, <d1>, "-}>", label: [0], loop-angle: 0deg, bend: 120deg),
  edge(<d2>, <d3>, "-}>", label: [1]),
  edge(<d3>, <d2>, "-}>", label: [1], bend: 40deg),
  edge(<d2>, <d2>, "-}>", label: [0], loop-angle: 180deg, bend: 120deg),
  edge(<d3>, <d3>, "-}>", label: [0], loop-angle: 0deg, bend: 120deg),
)

// Finite automata.
// Скопировано из книги, чтобы лекции не зависели от неё.
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
  edge-stroke: (paint: c-edge, thickness: 0.8pt),
  spacing: 3em,
  edge((-1, 0), "-}>"),
  node((0, 0), $q_0$, name: <q0>),
  edge(<q0>, <q1>, "-}>", label: [0]),
  node((1, 0), $q_1$, name: <q1>),
  edge(<q1>, <q2>, "-}>", label: [1]),
  node((2, 0), $q_2$, name: <q2>, fill: c-accept, stroke: (
    paint: c-accept-str,
    thickness: 1.2pt,
  )),
  edge(<q0>, <q0>, "-}>", label: [1], bend: -50deg),
  edge(<q1>, <q1>, "-}>", label: [0], bend: -50deg),
  edge(<q2>, <q1>, "-}>", label: [0], bend: 40deg),
  edge(<q2>, <q0>, "-}>", label: [1], bend: -50deg),
)

// ── 2. NFA with epsilon: contains "01", or the empty word ──
#let nfa-01-eps = diagram(
  node-stroke: (paint: c-state-str, thickness: 0.8pt),
  node-fill: c-state,
  edge-stroke: (paint: c-edge, thickness: 0.8pt),
  spacing: 3em,
  edge((-0.6, 0), <s>, "-}>"),
  node((0, 0), $s$, name: <s>),
  edge(<s>, <q0>, "-}>", label: [$epsilon$]),
  edge(<s>, <q2>, "-}>", label: [$epsilon$], bend: 30deg),
  node((1, 0), $q_0$, name: <q0>),
  edge(<q0>, <q0>, "-}>", label: [0,1], bend: -50deg),
  edge(<q0>, <q1>, "-}>", label: [0], label-side: right),
  node((2, 1), $q_1$, name: <q1>),
  edge(<q1>, <q2>, "-}>", label: [1]),
  node((2, -1), $q_2$, name: <q2>, fill: c-accept, stroke: (
    paint: c-accept-str,
    thickness: 1.2pt,
  )),
  edge(<q2>, <q2>, "-}>", label: [0,1], loop-angle: 90deg, bend: 120deg),
)

// ── 3. DFA: even number of ones ──
#let dfa-even-ones = diagram(
  node-stroke: (paint: c-state-str, thickness: 0.8pt),
  node-fill: c-state,
  edge-stroke: (paint: c-edge, thickness: 0.8pt),
  spacing: 3em,
  edge((-1, 0), "-}>"),
  node((0, 0), $q_0$, name: <e0>, fill: c-accept, stroke: (
    paint: c-accept-str,
    thickness: 1.2pt,
  )),
  node((1, 0), $q_1$, name: <e1>),
  edge(<e0>, <e0>, "-}>", label: [0], loop-angle: 90deg, bend: 120deg),
  edge(<e0>, <e1>, "-}>", label: [1], bend: 30deg),
  edge(<e1>, <e1>, "-}>", label: [0], loop-angle: 90deg, bend: 120deg),
  edge(<e1>, <e0>, "-}>", label: [1], bend: 30deg),
)

// ── 4. NFA: strings ending with "01" ──
#let nfa-ends-01 = diagram(
  node-stroke: (paint: c-state-str, thickness: 0.8pt),
  node-fill: c-state,
  edge-stroke: (paint: c-edge, thickness: 0.8pt),
  spacing: 3em,
  edge((-1, 0), "-}>"),
  node((0, 0), $s$, name: <n0>),
  edge(<n0>, <n0>, "-}>", label: [0, 1], loop-angle: 90deg, bend: 120deg),
  node((2, 0), $q_1$, name: <n1>),
  edge(<n0>, <n1>, "-}>", label: [0]),
  node((4, 0), $q_2$, name: <n2>, fill: c-accept, stroke: (
    paint: c-accept-str,
    thickness: 1.2pt,
  )),
  edge(<n1>, <n2>, "-}>", label: [1]),
)

// ── 5. Subset construction result: states are sets of NFA states ──
#let dfa-subset-01 = diagram(
  node-stroke: (paint: c-state-str, thickness: 0.8pt),
  node-fill: c-state,
  edge-stroke: (paint: c-edge, thickness: 0.8pt),
  spacing: 5em,
  edge((-1.4, 0), "-}>"),
  node((0, 0), text(size: 0.75em)[$q_0$], name: <m0>),
  edge(<m0>, <m0>, "-}>", label: [1], loop-angle: 90deg, bend: 120deg),
  node((2.5, 0), text(size: 0.75em)[$q_0, q_1$], name: <m1>),
  edge(<m0>, <m1>, "-}>", label: [0]),
  edge(<m1>, <m1>, "-}>", label: [0], loop-angle: 90deg, bend: 120deg),
  node((5, 0), text(size: 0.75em)[$q_0, q_2$], name: <m2>, fill: c-accept, stroke: (
    paint: c-accept-str,
    thickness: 1.2pt,
  )),
  edge(<m1>, <m2>, "-}>", label: [1]),
  edge(<m2>, <m1>, "-}>", label: [0], bend: -40deg),
  edge(<m2>, <m0>, "-}>", label: [1], bend: -50deg),
)
// ── 6. NFA: third symbol from the end equals 1 ──
#let nfa-third-one = diagram(
  node-stroke: (paint: c-state-str, thickness: 0.8pt),
  node-fill: c-state,
  edge-stroke: (paint: c-edge, thickness: 0.8pt),
  spacing: 3.5em,
  edge((-1, 0), "-}>"),
  node((0, 0), $s$, name: <t0>),
  edge(<t0>, <t0>, "-}>", label: [0, 1], loop-angle: 90deg, bend: 120deg),
  node((2, 0), $q_1$, name: <t1>),
  edge(<t0>, <t1>, "-}>", label: [1]),
  node((4, 0), $q_2$, name: <t2>),
  edge(<t1>, <t2>, "-}>", label: [0, 1]),
  node((6, 0), $q_3$, name: <t3>, fill: c-accept, stroke: (
    paint: c-accept-str,
    thickness: 1.2pt,
  )),
  edge(<t2>, <t3>, "-}>", label: [0, 1]),
)

// ── 7. Thompson construction for (0|1)*1 ──
#let thompson-star-one = diagram(
  node-stroke: (paint: c-state-str, thickness: 0.8pt),
  node-fill: c-state,
  edge-stroke: (paint: c-edge, thickness: 0.8pt),
  spacing: 3em,
  edge((-1, 0), "-}>"),
  node((0, 0), $s$, name: <p0>),
  node((1.5, 0), $q$, name: <p1>),
  edge(<p0>, <p1>, "-}>", label: [$epsilon$]),
  edge(<p1>, <p1>, "-}>", label: [0, 1], loop-angle: 90deg, bend: 120deg),
  node((3, 0), $r$, name: <p2>),
  edge(<p1>, <p2>, "-}>", label: [$epsilon$]),
  node((4.5, 0), $f$, name: <p3>, fill: c-accept, stroke: (
    paint: c-accept-str,
    thickness: 1.2pt,
  )),
  edge(<p2>, <p3>, "-}>", label: [1]),
)

// ── 8. Four-state DFA for the even-ones language ──
#let dfa-redundant = diagram(
  node-stroke: (paint: c-state-str, thickness: 0.8pt),
  node-fill: c-state,
  edge-stroke: (paint: c-edge, thickness: 0.8pt),
  spacing: 4em,
  edge((-1, 0), "-}>"),
  node((0, 0), $r_0$, name: <d0>, fill: c-accept, stroke: (
    paint: c-accept-str,
    thickness: 1.2pt,
  )),
  node((2, 0), $r_1$, name: <d1>),
  node((0, 2), $r_2$, name: <d2>, fill: c-accept, stroke: (
    paint: c-accept-str,
    thickness: 1.2pt,
  )),
  node((2, 2), $r_3$, name: <d3>),
  edge(<d0>, <d1>, "-}>", label: [1]),
  edge(<d1>, <d0>, "-}>", label: [1], bend: 40deg),
  edge(<d0>, <d2>, "-}>", label: [0]),
  edge(<d1>, <d1>, "-}>", label: [0], loop-angle: 0deg, bend: 120deg),
  edge(<d2>, <d3>, "-}>", label: [1]),
  edge(<d3>, <d2>, "-}>", label: [1], bend: 40deg),
  edge(<d2>, <d2>, "-}>", label: [0], loop-angle: 180deg, bend: 120deg),
  edge(<d3>, <d3>, "-}>", label: [0], loop-angle: 0deg, bend: 120deg),
)

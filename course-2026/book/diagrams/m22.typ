// m22 diagrams: ДКА, НКА-00-11, лемма о накачке, НКА-пример, ε-НКА.
#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

// Общие токены состояния: заливка c-fl, граница c-bd+t-bd, рёбра c-edge+t-ed.
#let n-stroke = t-bd + c-bd
#let e-stroke = (paint: c-edge, thickness: t-ed)
#let start-stroke = (paint: c-accent, thickness: t-ed)
// Допускающее состояние: двойной кружок.
#let acc-extrude = (0, 2pt)

#let st(pos, label, name, accept: false) = if accept {
  node(pos, label, name: name, extrude: acc-extrude)
} else {
  node(pos, label, name: name)
}

#let tr(from, to, label, stroke: e-stroke, ..args) = edge(
  from, to, "-}>",
  label: label,
  label-size: s-cap,
  stroke: stroke,
  ..args,
)

#let start-arrow(to) = edge((-1, 0), to, "-}>", stroke: start-stroke)

// ── ДКА над {0,1}: строки, где за "0" идёт "1" ──
#let dfa-01 = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3em,

  start-arrow(<q0>),
  st((0, 0), $q_0$, <q0>),
  st((1, 0), $q_1$, <q1>),
  st((2, 0), $q_2$, <q2>, accept: true),

  tr(<q0>, <q1>, "0"),
  tr(<q1>, <q2>, "1"),
  tr(<q0>, <q0>, "1", bend: -50deg),
  tr(<q1>, <q1>, "0", bend: -50deg),
  tr(<q2>, <q1>, "0", bend: 40deg),
  tr(<q2>, <q0>, "1", bend: -40deg),
)

// ── НКА-00-11: строки, содержащие "00" или "11" ──
#let nfa-00-11 = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3em,

  start-arrow(<s0>),
  st((0, 0), $q_0$, <s0>),
  st((1, 1), $q_1$, <s1>),
  st((2, 1), $q_a$, <sa>, accept: true),
  st((1, -1), $q_2$, <s2>),
  st((2, -1), $q_b$, <sb>, accept: true),

  tr(<s0>, <s0>, "0,1", bend: 80deg),
  tr(<s0>, <s1>, "0"),
  tr(<s1>, <sa>, "0"),
  tr(<s0>, <s2>, "1"),
  tr(<s2>, <sb>, "1"),
  tr(<sa>, <sa>, "0,1", bend: -50deg),
  tr(<sb>, <sb>, "0,1", bend: 50deg),
)

// ── НКА-пример: {0,1}-строки, оканчивающиеся на "01" ──
#let nfa-example = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3em,

  start-arrow(<q0>),
  st((0, 0), $q_0$, <q0>),
  st((1, 0), $q_1$, <q1>),
  st((2, 0), $q_2$, <q2>, accept: true),

  tr(<q0>, <q0>, "0,1", bend: -50deg),
  tr(<q0>, <q1>, "0"),
  tr(<q1>, <q2>, "1"),
)

// ── ε-НКА: ε-переходы (пунктир) до и после состояния ──
#let epsilon-nfa = diagram(
  node-stroke: n-stroke,
  node-fill: c-fl,
  spacing: 3em,

  start-arrow(<q0>),
  st((0, 0), $q_0$, <q0>),
  st((1, 0), $q_1$, <q1>),
  st((2, 0), $q_2$, <q2>, accept: true),

  tr(<q0>, <q1>, $epsilon$, stroke: (
    paint: c-edge,
    thickness: t-ed,
    dash: "dashed",
  )),
  tr(<q1>, <q2>, $epsilon$, stroke: (
    paint: c-edge,
    thickness: t-ed,
    dash: "dashed",
  )),
  tr(<q1>, <q1>, $"a"$, bend: -50deg),
  tr(<q2>, <q2>, $"b"$, bend: -50deg),
)

// ── Лемма о накачке: цикл q_i -> q_j -> q_i (накачка y) ──
#let pl-state(pos, label, name, accept: false) = {
  draw.circle(pos, radius: 0.42, fill: c-fl, stroke: n-stroke, name: name)
  draw.content(pos, text(size: s-node, fill: c-ink)[#label])
  if accept {
    draw.circle(pos, radius: 0.54, stroke: n-stroke)
  }
}

#let pl-edge(from, to, name, label, stroke: e-stroke, fill: c-ink) = {
  draw.line(from, to, name: name, stroke: stroke)
  draw.content(
    name + ".mid",
    text(size: s-cap, fill: fill)[#label],
    fill: white,
    stroke: none,
    padding: 2pt,
  )
}

#let pumping-lemma = canvas({
  let acc-stroke = (paint: c-accent, thickness: t-hi)

  pl-state((-3, 0), $q_0$, "q0")
  pl-state((-0.5, 0), $q_i$, "qi")
  pl-state((2, 0), $q_j$, "qj")
  pl-state((4.5, 0), $q_f$, "qf", accept: true)

  pl-edge("q0", "qi", "e-x", $x$)
  pl-edge(
    "qi", "qj", "e-y", $y$,
    stroke: acc-stroke,
    fill: c-accent,
  )
  pl-edge("qj", "qf", "e-z", $z$)

  draw.bezier(
    "qj.north",
    "qi.north",
    (1.5, 1.5),
    (-0.2, 1.5),
    name: "e-loop",
    stroke: (paint: c-accent, thickness: t-ed, dash: "dashed"),
  )

  let pumped = (
    ([$x z$ (0 повторений)], -1.8),
    ([$x y z$ (1 повторение)], -2.3),
    ([$x y^2 z$ (2 повторения)], -2.8),
    ([$x y^k z$ ($k$ повторений)], -3.3),
  )
  for (k, (label, y)) in pumped.enumerate() {
    draw.content(
      (0.5, y),
      text(size: s-cap, fill: if k == 1 { c-ink } else { c-muted })[#label],
    )
  }
})

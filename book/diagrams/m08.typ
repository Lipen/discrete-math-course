#import "../requirements.typ": *
#import "../notation.typ": *

#import "style.typ": *

#import fletcher: diagram, edge, node

#let n-stroke = c-bd + t-bd

#let e-stroke = (paint: c-edge, thickness: t-ed)

#let hasse-node(pos, body, ..args) = node(
  pos,
  text(size: s-node, fill: c-ink)[#body],
  fill: c-fl,
  ..args,
)

#let cover-edge(from, to) = edge(from, to, "-", stroke: e-stroke)

#let hasse-diagram(spacing: 2em, ..nodes) = diagram(
  node-shape: "circle",
  node-stroke: n-stroke,
  node-inset: 4pt,
  node-outset: 0pt,
  spacing: spacing,
  ..nodes,
)

// ── Делители 12 ──
#let hasse-divisors-12 = hasse-diagram(
  hasse-node((0, 3), $1$, name: <d1>),
  hasse-node((-1, 2), $2$, name: <d2>),
  hasse-node((1, 2), $3$, name: <d3>),
  hasse-node((-1, 1), $4$, name: <d4>),
  hasse-node((1, 1), $6$, name: <d6>),
  hasse-node((0, 0), $12$, name: <d12>),
  cover-edge(<d1>, <d2>),
  cover-edge(<d1>, <d3>),
  cover-edge(<d2>, <d4>),
  cover-edge(<d2>, <d6>),
  cover-edge(<d3>, <d6>),
  cover-edge(<d4>, <d12>),
  cover-edge(<d6>, <d12>),
)

// ── Цепь из трёх элементов ──
#let hasse-chain-3 = hasse-diagram(
  spacing: 2em,
  hasse-node((0, 2), $1$, name: <c1>),
  hasse-node((0, 1), $2$, name: <c2>),
  hasse-node((0, 0), $3$, name: <c3>),
  cover-edge(<c1>, <c2>),
  cover-edge(<c2>, <c3>),
)

// ── Булева решётка B2 ──
#let hasse-powerset-2 = hasse-diagram(
  spacing: 2.8em,
  hasse-node((0, 2), $nothing$, name: <p0>),
  hasse-node((-1, 1), ${1}$, name: <p1>),
  hasse-node((1, 1), ${2}$, name: <p2>),
  hasse-node((0, 0), ${1,2}$, name: <p12>),
  cover-edge(<p0>, <p1>),
  cover-edge(<p0>, <p2>),
  cover-edge(<p1>, <p12>),
  cover-edge(<p2>, <p12>),
)

// ── Булева решётка B3 ──
#let hasse-powerset-3 = hasse-diagram(
  spacing: 3.6em,
  hasse-node((0, 0), ${1,2,3}$, name: <p123>),
  hasse-node((-1.2, 1), ${1,2}$, name: <p12>),
  hasse-node((0, 1), ${1,3}$, name: <p13>),
  hasse-node((1.2, 1), ${2,3}$, name: <p23>),
  hasse-node((-1.2, 2), ${1}$, name: <p1>),
  hasse-node((0, 2), ${2}$, name: <p2>),
  hasse-node((1.2, 2), ${3}$, name: <p3>),
  hasse-node((0, 3), $nothing$, name: <p0>),
  // Покрытие = добавить ровно один элемент.
  cover-edge(<p0>, <p1>),
  cover-edge(<p0>, <p2>),
  cover-edge(<p0>, <p3>),
  cover-edge(<p1>, <p12>),
  cover-edge(<p1>, <p13>),
  cover-edge(<p2>, <p12>),
  cover-edge(<p2>, <p23>),
  cover-edge(<p3>, <p13>),
  cover-edge(<p3>, <p23>),
  cover-edge(<p12>, <p123>),
  cover-edge(<p13>, <p123>),
  cover-edge(<p23>, <p123>),
)

// ── Решётка M3 ──
#let lattice-m3 = hasse-diagram(
  spacing: 2em,
  hasse-node((0, 2), $bot$, name: <m3-bot>),
  hasse-node((-1, 1), $a$, name: <m3-a>),
  hasse-node((0, 1), $b$, name: <m3-b>),
  hasse-node((1, 1), $c$, name: <m3-c>),
  hasse-node((0, 0), $top$, name: <m3-top>),
  cover-edge(<m3-bot>, <m3-a>),
  cover-edge(<m3-bot>, <m3-b>),
  cover-edge(<m3-bot>, <m3-c>),
  cover-edge(<m3-a>, <m3-top>),
  cover-edge(<m3-b>, <m3-top>),
  cover-edge(<m3-c>, <m3-top>),
)

// ── Решётка N5 ──
#let lattice-n5 = hasse-diagram(
  spacing: 2em,
  hasse-node((0, 3), $0$, name: <n5-zero>),
  hasse-node((-1, 2), $a$, name: <n5-a>),
  hasse-node((-1, 1), $b$, name: <n5-b>),
  hasse-node((1, 1), $c$, name: <n5-c>),
  hasse-node((0, 0), $1$, name: <n5-one>),
  cover-edge(<n5-zero>, <n5-a>),
  cover-edge(<n5-zero>, <n5-c>),
  cover-edge(<n5-a>, <n5-b>),
  cover-edge(<n5-b>, <n5-one>),
  cover-edge(<n5-c>, <n5-one>),
)

// ── Сдвиг натуральных чисел: изоморфизм двух строк ──
#let order-isomorphism-shift = hasse-diagram(
  spacing: 2.2em,
  node((1.5, 2.2), $NN$, fill: none, stroke: none),
  node((1.5, -2.2), $NN setminus {0}$, fill: none, stroke: none),

  hasse-node((0, 1), $0$, name: <t0>),
  hasse-node((1, 1), $1$, name: <t1>),
  hasse-node((2, 1), $2$, name: <t2>),
  hasse-node((3, 1), $3$, name: <t3>),
  node((4, 1), $dots.c$, fill: none, stroke: none),

  hasse-node((0, -1), $1$, name: <b1>),
  hasse-node((1, -1), $2$, name: <b2>),
  hasse-node((2, -1), $3$, name: <b3>),
  hasse-node((3, -1), $4$, name: <b4>),
  node((4, -1), $dots.c$, fill: none, stroke: none),

  edge(<t0>, <b1>, "-}>", stroke: e-stroke, label: $f$, label-size: s-cap, label-fill: c-white),
  edge(<t1>, <b2>, "-}>", stroke: e-stroke),
  edge(<t2>, <b3>, "-}>", stroke: e-stroke),
  edge(<t3>, <b4>, "-}>", stroke: e-stroke),
)

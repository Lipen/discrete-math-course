// Диаграммы решений: простое BDD, полное дерево XOR и ROBDD большинства.
#import "@preview/fletcher:0.5.8": diagram, edge, node
#import "style.typ": *

#let vnode(pos, name, body) = node(
  pos,
  text(fill: ink)[#body],
  name: name,
  shape: circle,
  fill: cool.lighten(82%),
  stroke: (paint: cool, thickness: 1.1pt),
  inset: 0pt,
  width: 1.55em,
  height: 1.55em,
)

#let leaf(pos, name, val, tone) = node(
  pos,
  text(fill: ink)[#val],
  name: name,
  fill: tone.lighten(80%),
  stroke: (paint: tone, thickness: 1pt),
  inset: 3pt,
)

#let branch(from, to, bit, label-pos: 30%, label: true) = edge(
  from,
  to,
  "-",
  stroke: if bit == 0 {
    (paint: ink-soft, thickness: 0.7pt, dash: "dashed")
  } else {
    (paint: cool, thickness: 1.7pt)
  },
  label: if label { text(fill: ink)[$#bit$] } else { none },
  label-pos: label-pos,
  label-side: center,
  label-fill: white,
)

// BDD для x and y: x=0 сразу в 0, x=1 проверяет y.
#let bdd-and = diagram(
  spacing: 2.8em,
  vnode((0, 0), <x>, $x$),
  vnode((1.35, 1), <y>, $y$),
  leaf((-0.15, 2), <zero>, $0$, ink-soft),
  leaf((2.0, 2), <one>, $1$, green),
  branch(<x>, <zero>, 0),
  branch(<x>, <y>, 1),
  branch(<y>, <zero>, 0),
  branch(<y>, <one>, 1),
)

// Полное дерево решений для x xor y: семь узлов.
#let bdd-xor-tree = diagram(
  spacing: 2.8em,
  vnode((0, 0), <x>, $x$),
  vnode((-1.55, 1), <ylo>, $y$),
  vnode((1.55, 1), <yhi>, $y$),
  leaf((-2.35, 2), <t0>, $0$, ink-soft),
  leaf((-0.75, 2), <t1>, $1$, green),
  leaf((0.75, 2), <t2>, $1$, green),
  leaf((2.35, 2), <t3>, $0$, ink-soft),
  branch(<x>, <ylo>, 0),
  branch(<x>, <yhi>, 1),
  branch(<ylo>, <t0>, 0),
  branch(<ylo>, <t1>, 1, label-pos: 22%),
  branch(<yhi>, <t2>, 0, label-pos: 22%),
  branch(<yhi>, <t3>, 1),
)

// Тот же xor после слияния листьев: пять узлов.
#let bdd-xor = diagram(
  spacing: 2.8em,
  vnode((0, 0), <x>, $x$),
  vnode((-1.55, 1), <ylo>, $y$),
  vnode((1.55, 1), <yhi>, $y$),
  leaf((-0.75, 2), <t0>, $0$, ink-soft),
  leaf((0.75, 2), <t1>, $1$, green),
  branch(<x>, <ylo>, 0, label: false),
  branch(<x>, <yhi>, 1, label: false),
  branch(<ylo>, <t0>, 0, label: false),
  branch(<ylo>, <t1>, 1, label-pos: 22%, label: false),
  branch(<yhi>, <t1>, 0, label-pos: 22%, label: false),
  branch(<yhi>, <t0>, 1, label: false),
)

// ROBDD большинства M(x,y,z): шесть узлов.
#let robdd-majority = diagram(
  spacing: 2.8em,
  vnode((0, 0), <r>, $x$),
  vnode((-1.45, 1), <a>, $y$),
  vnode((1.45, 1), <b>, $y$),
  vnode((0, 2), <z>, $z$),
  leaf((-1.45, 3), <zero>, $0$, ink-soft),
  leaf((1.45, 3), <one>, $1$, green),
  branch(<r>, <a>, 0, label: false),
  branch(<r>, <b>, 1, label: false),
  branch(<a>, <zero>, 0, label: false),
  branch(<a>, <z>, 1, label: false),
  branch(<b>, <z>, 0, label: false),
  branch(<b>, <one>, 1, label: false),
  branch(<z>, <zero>, 0, label: false),
  branch(<z>, <one>, 1, label: false),
)

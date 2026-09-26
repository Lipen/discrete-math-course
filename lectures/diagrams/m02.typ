// Деревья вывода: посылки снизу, заключение сверху, имена правил на рёбрах.
#import "@preview/fletcher:0.5.8": diagram, edge, node
#import "style.typ": *

#let premise-node(pos, body, ..args) = node(
  pos,
  text(size: 1.4em)[#body],
  fill: white,
  stroke: 1.1pt + cool,
  corner-radius: 4pt,
  inset: 0.3em,
  width: auto,
  height: auto,
  ..args,
)

#let conclusion-node(pos, body, ..args) = node(
  pos,
  text(size: 1.4em)[#body],
  fill: panel-warm,
  stroke: 1.4pt + warm,
  corner-radius: 4pt,
  inset: 0.3em,
  width: auto,
  height: auto,
  ..args,
)

// Гипотеза уже снята правилом -> I: пунктир.
#let discharged-node(pos, body, ..args) = node(
  pos,
  text(size: 1.4em)[#body],
  fill: white,
  stroke: (paint: violet, thickness: 1.1pt, dash: "dashed"),
  corner-radius: 4pt,
  inset: 0.3em,
  width: auto,
  height: auto,
  ..args,
)

#let rule-edge(from, to, name, side: auto) = edge(
  from,
  to,
  "-}>",
  stroke: 1.1pt + cool,
  label: text(size: 0.9em, fill: ink)[#name],
  label-side: side,
)

// ── Цепочка двух MP: C выводится из A -> B, A и B -> C ──
#let mp-chain = diagram(
  spacing: 2.4em,
  conclusion-node((0, 0), $C$, name: <c>),
  premise-node((-1.7, 1.4), $B$, name: <b>),
  premise-node((-3.4, 2.8), $A -> B$, name: <ab>),
  premise-node((-0.2, 2.8), $A$, name: <a>),
  premise-node((1.7, 2.8), $B -> C$, name: <bc>),
  rule-edge(<ab>, <b>, $"MP"$, side: left),
  rule-edge(<a>, <b>, $"MP"$, side: right),
  rule-edge(<b>, <c>, $"MP"$, side: left),
  rule-edge(<bc>, <c>, $"MP"$, side: right),
)

// ── Введение импликации: A -> (B -> A), гипотезы сняты дважды ──
#let nd-impi = diagram(
  spacing: 2.6em,
  conclusion-node((0, 0), $A -> (B -> A)$, name: <goal>),
  premise-node((0, 1.4), $B -> A$, name: <mid>),
  discharged-node((0, 2.8), $[A]^1 [A]^2$, name: <hyp>),
  rule-edge(<hyp>, <mid>, $-> I\,2$),
  rule-edge(<mid>, <goal>, $-> I\,1$),
)

// ── Проекция: A and B -> A ──
#let nd-projection = diagram(
  spacing: 2.6em,
  conclusion-node((0, 0), $A and B -> A$, name: <goal>),
  premise-node((0, 1.4), $A$, name: <half>),
  discharged-node((0, 2.8), $[A and B]^1$, name: <hyp>),
  rule-edge(<hyp>, <half>, $and E$),
  rule-edge(<half>, <goal>, $-> I\,1$),
)

// ── Коммутативность: A and B -> B and A ──
#let nd-comm = diagram(
  spacing: 2.4em,
  conclusion-node((0, 0), $B and A$, name: <goal>),
  premise-node((-1.5, 1.4), $B$, name: <left>),
  premise-node((1.5, 1.4), $A$, name: <right>),
  discharged-node((0, 2.8), $A and B$, name: <hyp>),
  rule-edge(<hyp>, <left>, $and E$, side: left),
  rule-edge(<hyp>, <right>, $and E$, side: right),
  rule-edge(<left>, <goal>, $and I$, side: left),
  rule-edge(<right>, <goal>, $and I$, side: right),
)

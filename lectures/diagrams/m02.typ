// Деревья вывода: посылки снизу, заключение сверху, имена правил на рёбрах.
#import "@preview/fletcher:0.5.8": diagram, edge, node

#let n-fill = oklch(88%, 0.03, 250deg)
#let n-str = 0.8pt + oklch(60%, 0.08, 250deg)
#let e-str = 0.8pt + oklch(35%, 0.02, 265deg)
#let e-label = oklch(40%, 0.02, 265deg)

#let f(pos, body, ..args) = node(
  pos,
  text(size: 1.4em)[#body],
  fill: n-fill,
  stroke: n-str,
  width: auto,
  height: auto,
  corner-radius: 4pt,
  inset: 0.3em,
  ..args,
)
#let rule-edge(from, to, name, side: auto) = edge(
  from,
  to,
  "-}>",
  stroke: e-str,
  label: text(size: 0.9em, fill: e-label)[#name],
  label-side: side,
)

// ── Цепочка двух MP: C выводится из A -> B, A и B -> C ──
#let mp-chain = diagram(
  spacing: 2.4em,
  f((0, 0), $C$, name: <c>),
  f((-1.7, 1.4), $B$, name: <b>),
  f((-3.4, 2.8), $A -> B$, name: <ab>),
  f((-0.2, 2.8), $A$, name: <a>),
  f((1.7, 2.8), $B -> C$, name: <bc>),
  rule-edge(<ab>, <b>, $"MP"$, side: left),
  rule-edge(<a>, <b>, $"MP"$, side: right),
  rule-edge(<b>, <c>, $"MP"$, side: left),
  rule-edge(<bc>, <c>, $"MP"$, side: right),
)

// ── Введение импликации: A -> (B -> A), гипотезы сняты дважды ──
#let nd-impi = diagram(
  spacing: 2.6em,
  f((0, 0), $A -> (B -> A)$, name: <goal>),
  f((0, 1.4), $B -> A$, name: <mid>),
  f((0, 2.8), $[A]^1 [A]^2$, name: <hyp>),
  rule-edge(<hyp>, <mid>, $-> I\,2$),
  rule-edge(<mid>, <goal>, $-> I\,1$),
)

// ── Проекция: A and B -> A ──
#let nd-projection = diagram(
  spacing: 2.6em,
  f((0, 0), $A and B -> A$, name: <goal>),
  f((0, 1.4), $A$, name: <half>),
  f((0, 2.8), $[A and B]^1$, name: <hyp>),
  rule-edge(<hyp>, <half>, $and E$),
  rule-edge(<half>, <goal>, $-> I\,1$),
)

// ── Коммутативность: A and B -> B and A ──
#let nd-comm = diagram(
  spacing: 2.4em,
  f((0, 0), $B and A$, name: <goal>),
  f((-1.5, 1.4), $B$, name: <left>),
  f((1.5, 1.4), $A$, name: <right>),
  f((0, 2.8), $A and B$, name: <hyp>),
  rule-edge(<hyp>, <left>, $and E$, side: left),
  rule-edge(<hyp>, <right>, $and E$, side: right),
  rule-edge(<left>, <goal>, $and I$, side: left),
  rule-edge(<right>, <goal>, $and I$, side: right),
)

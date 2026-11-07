// Деревья вывода: посылки сверху, заключение снизу, имена правил на рёбрах.
#import "@preview/fletcher:0.5.8": diagram, edge, node
#import "style.typ": *

#let imply = sym.arrow.r

#let premise-node(pos, body, ..args) = node(
  pos,
  text(size: 1.4em)[#body],
  fill: cool.lighten(88%),
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
  fill: warm.lighten(88%),
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
  fill: violet.lighten(88%),
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
  label: text(fill: ink)[#name],
  label-side: side,
)

#let silent-edge(from, to) = edge(from, to, "-}>", stroke: 1.1pt + cool)

// ── Цепочка двух MP: C выводится из A -> B, A и B -> C ──
#let mp-chain = diagram(
  spacing: 2.4em,
  conclusion-node((0, 2.8), $C$, name: <c>),
  premise-node((-1.7, 1.4), $B$, name: <b>),
  premise-node((-3.4, 0), $A imply B$, name: <ab>),
  premise-node((-0.2, 0), $A$, name: <a>),
  premise-node((1.7, 0), $B imply C$, name: <bc>),
  rule-edge(<ab>, <b>, $"MP"$, side: left),
  silent-edge(<a>, <b>),
  rule-edge(<b>, <c>, $"MP"$, side: left),
  silent-edge(<bc>, <c>),
)

// ── Проекция: A and B -> A ──
#let nd-projection = diagram(
  spacing: 2.6em,
  conclusion-node((0, 2.8), $A and B imply A$, name: <goal>),
  premise-node((0, 1.4), $A$, name: <half>),
  discharged-node((0, 0), $[A and B]^1$, name: <hyp>),
  rule-edge(<hyp>, <half>, $and E$),
  rule-edge(<half>, <goal>, $imply I thin 1$),
)

// ── Коммутативность: A and B -> B and A ──
#let nd-comm = diagram(
  spacing: 2.4em,
  conclusion-node((0, 5.4), $A and B imply B and A$, name: <goal>),
  premise-node((0, 3.6), $B and A$, name: <conj>),
  premise-node((-1.5, 1.8), $B$, name: <left>),
  premise-node((1.5, 1.8), $A$, name: <right>),
  discharged-node((0, 0), $[A and B]^1$, name: <hyp>),
  rule-edge(<hyp>, <left>, $and E$, side: left),
  rule-edge(<hyp>, <right>, $and E$, side: right),
  rule-edge(<left>, <conj>, $and I$, side: left),
  silent-edge(<right>, <conj>),
  rule-edge(<conj>, <goal>, $imply I thin 1$),
)

// ── Поиск с возвратом: тупик и откат на дереве целей ──
#let search-node(pos, body, note, tone, ..args) = node(
  pos,
  text(size: 1.3em)[#body \ #text(size: 0.62em, fill: tone)[#note]],
  fill: tone.lighten(88%),
  stroke: 1.1pt + tone,
  corner-radius: 4pt,
  inset: 0.3em,
  width: auto,
  height: auto,
  ..args,
)

#let search-backtrack = diagram(
  spacing: 2.2em,
  search-node((0, 0), [$p or q$], [цель], cool, name: <search-root>),
  search-node((-1.8, 1.5), [$p$], [тупик], warm, name: <search-dead>),
  search-node((1.8, 1.5), [$q$], [успех], green, name: <search-ok>),
  edge(
    <search-root>,
    <search-dead>,
    "-}>",
    stroke: 1.1pt + cool,
    label: text(fill: ink)[$or I$],
    label-side: left,
  ),
  edge(
    <search-root>,
    <search-ok>,
    "-}>",
    stroke: 1.1pt + cool,
    label: text(fill: ink)[$or I$],
    label-side: right,
  ),
  edge(
    <search-dead>,
    <search-ok>,
    "-}>",
    stroke: (paint: warm, thickness: 1.2pt, dash: "dashed"),
    label: text(fill: warm)[откат],
  ),
)

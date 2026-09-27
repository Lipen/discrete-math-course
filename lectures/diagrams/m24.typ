// Диаграммы лекции по контекстно-свободным языкам: иерархия Хомского, дерево разбора.
#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/fletcher:0.5.8": diagram, edge, node
#import "style.typ": *

// ── Иерархия Хомского: вложенные классы языков ──
#let chomsky-hierarchy = canvas({
  // вложенные арки с общей нижней касательной y = -0.2
  draw.circle(
    (0, 1.8),
    radius: (2.5, 2.0),
    fill: fill-soft,
    stroke: (paint: ink-soft, thickness: 0.8pt),
  )
  draw.circle(
    (0, 1.3),
    radius: (1.75, 1.5),
    fill: violet.lighten(82%),
    stroke: (paint: violet, thickness: 0.8pt),
  )
  draw.circle(
    (0, 0.8),
    radius: (1.35, 1.0),
    fill: amber.lighten(80%),
    stroke: (paint: amber, thickness: 0.8pt),
  )
  draw.circle(
    (0, 0.25),
    radius: (0.95, 0.45),
    fill: green.lighten(75%),
    stroke: (paint: green, thickness: 0.8pt),
  )
  mark((0, 0.25), [Regular])
  mark((0, 1.2), [Context-Free])
  mark((0, 2.2), [Context-Sensitive])
  mark((0, 3.3), [Recursively Enumerable])
})

// ── Дерево разбора a^3 b^3: корень S слева, листья справа ──
#let parse-tree-a3b3 = {
  let cn(pos, label, name) = node(
    pos,
    label,
    name: name,
    fill: cool.lighten(82%),
    stroke: (paint: cool, thickness: 1.1pt),
    shape: circle,
    width: 1.6em,
    height: 1.6em,
  )
  let tn(pos, label, name) = node(
    pos,
    label,
    name: name,
    fill: green.lighten(82%),
    stroke: (paint: green, thickness: 1.1pt),
    shape: circle,
    width: 1.6em,
    height: 1.6em,
  )
  let prod(from, to) = edge(
    from,
    to,
    "-",
    stroke: edge-plain,
    label: text(fill: ink-soft)[$S -> a S b$],
    label-anchor: "center",
    label-angle: auto,
  )

  diagram(
    node-inset: 0pt,
    node-outset: 0pt,
    spacing: 2em,

    cn((0, 0), $S$, <s0>),
    tn((2, -1.2), $a$, <a1>),
    cn((2, 0), $S$, <s1>),
    tn((2, 1.2), $b$, <b1>),
    tn((4, -1.2), $a$, <a2>),
    cn((4, 0), $S$, <s2>),
    tn((4, 1.2), $b$, <b2>),
    tn((6, -1.2), $a$, <a3>),
    cn((6, 0), $S$, <s3>),
    tn((6, 1.2), $b$, <b3>),
    node(
      (8.7, 0),
      text(fill: ink-soft)[$epsilon$],
      name: <eps>,
      fill: none,
      stroke: (paint: ink-soft, thickness: 0.8pt, dash: "dashed"),
      shape: circle,
      width: 1.6em,
      height: 1.6em,
    ),

    prod(<s0>, <a1>),
    prod(<s0>, <s1>),
    prod(<s0>, <b1>),
    prod(<s1>, <a2>),
    prod(<s1>, <s2>),
    prod(<s1>, <b2>),
    prod(<s2>, <a3>),
    prod(<s2>, <s3>),
    prod(<s2>, <b3>),
    edge(
      <s3>,
      <eps>,
      "-",
      stroke: edge-hot,
      label: text[$S -> epsilon$],
      label-anchor: "center",
      label-angle: auto,
    ),
  )
}

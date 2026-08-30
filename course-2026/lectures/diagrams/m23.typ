// Chomsky hierarchy and parse tree.
// Скопировано из книги, чтобы лекции не зависели от неё.
#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/fletcher:0.5.8": diagram, edge, node

#let chomsky-hierarchy = canvas({
  let c-reg = oklch(88%, 0.05, 155deg)
  let c-cf = oklch(88%, 0.04, 70deg)
  let c-cs = oklch(88%, 0.04, 300deg)
  let c-re = oklch(85%, 0.03, 22deg)
  let c-label = oklch(35%, 0.02, 265deg)
  let c-border = oklch(50%, 0.05, 250deg) + 0.5pt

  draw.circle((0, 0), radius: (0.4, 0.2), fill: c-reg, stroke: c-border)
  draw.content((0, 0.15), text(size: 0.42em, fill: c-label)[Regular])

  draw.circle((0, 0.2), radius: (0.7, 0.4), fill: c-cf, stroke: c-border)
  draw.content((0, 0.5), text(size: 0.42em, fill: c-label)[Context-Free])

  draw.circle((0, 0.6), radius: (1.3, 0.8), fill: c-cs, stroke: c-border)
  draw.content((0, 1.0), text(size: 0.42em, fill: c-label)[Context-Sensitive])

  draw.circle((0, 1.2), radius: (2, 1.4), fill: c-re, stroke: c-border)
  draw.content((0, 1.7), text(
    size: 0.42em,
    fill: c-label,
  )[Recursively Enumerable])
})

// ── Дерево разбора a^3 b^3 ──
// Дерево растёт слева направо: корень S слева, листья справа.
// На каждой стрелке --- правило, применённое к родительскому нетерминалу.
#let parse-tree-a3b3 = {
  let n-size = 1.5em
  let n-stroke = 0.6pt + luma(70%)
  let e-stroke = (paint: oklch(35%, 0.02, 265deg), thickness: 0.8pt)
  let c-nonterm = oklch(92%, 0.04, 45deg)
  let c-term = oklch(92%, 0.02, 155deg)

  let cn(pos, label, ..args) = node(
    pos,
    label,
    fill: c-nonterm,
    width: n-size,
    height: n-size,
    ..args,
  )
  let tn(pos, label, ..args) = node(
    pos,
    label,
    fill: c-term,
    width: n-size,
    height: n-size,
    ..args,
  )
  let re(from, to, label) = edge(
    from,
    to,
    "-",
    stroke: e-stroke,
    label: label,
    label-anchor: "center",
    label-angle: auto,
    label-size: 0.55em,
  )

  diagram(
    node-shape: "circle",
    node-stroke: n-stroke,
    node-inset: 0pt,
    node-outset: 0pt,
    spacing: 2em,

    // Корень и уровни вложенности (ось y вниз; дети S --- столбец a, S, b).
    cn((0, 0), $S$, name: <s0>),
    tn((2, -1.2), $a$, name: <a1>),
    cn((2, 0), $S$, name: <s1>),
    tn((2, 1.2), $b$, name: <b1>),
    tn((4, -1.2), $a$, name: <a2>),
    cn((4, 0), $S$, name: <s2>),
    tn((4, 1.2), $b$, name: <b2>),
    tn((6, -1.2), $a$, name: <a3>),
    cn((6, 0), $S$, name: <s3>),
    tn((6, 1.2), $b$, name: <b3>),
    tn((8, 0), $epsilon$, name: <eps>),

    re(<s0>, <a1>, $S -> a S b$),
    re(<s0>, <s1>, $S -> a S b$),
    re(<s0>, <b1>, $S -> a S b$),
    re(<s1>, <a2>, $S -> a S b$),
    re(<s1>, <s2>, $S -> a S b$),
    re(<s1>, <b2>, $S -> a S b$),
    re(<s2>, <a3>, $S -> a S b$),
    re(<s2>, <s3>, $S -> a S b$),
    re(<s2>, <b3>, $S -> a S b$),
    re(<s3>, <eps>, $S -> epsilon$),
  )
}

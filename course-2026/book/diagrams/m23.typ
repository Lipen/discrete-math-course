// M23 diagrams: дерево разбора слова a^3 b^3.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

// ── Общие константы ──
#let n-size = 1.5em
#let n-stroke = 0.6pt + luma(70%)
#let e-stroke = (paint: oklch(35%, 0.02, 265deg), thickness: 0.8pt)
#let c-nonterm = oklch(92%, 0.04, 45deg)
#let c-term = oklch(92%, 0.02, 155deg)

// ── Дерево разбора a^3 b^3 ──
// Дерево растёт слева направо: корень S слева, листья справа.
// На каждой стрелке --- правило, применённое к родительскому нетерминалу.
// Колонки и ряды расставлены с запасом, чтобы метки правил не налезали на узлы.
#let parse-tree-a3b3 = {
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

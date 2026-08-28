#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

#let n-size = 1.5em

#let n-stroke = t-bd + c-bd

#let e-stroke = (paint: c-edge, thickness: t-ed)

#let c-reg = oklch(88%, 0.05, 155deg)   // регулярные
#let c-cf = oklch(88%, 0.04, 70deg)     // контекстно-свободные
#let c-cs = oklch(88%, 0.04, 300deg)    // контекстно-зависимые
#let c-re = oklch(85%, 0.03, 22deg)     // рекурсивно перечислимые

// ── Иерархия Хомского ──
#let chomsky-hierarchy = canvas({
  // Вложенные кольца: внешнее рисуем первым, чтобы каждая меньшая область
  // накрывала предыдущую и зазор между эллипсами сохранял свою заливку.
  let ring(rx, ry, fill) = draw.circle((0, 0), radius: (rx, ry), fill: fill, stroke: c-bd + t-bd)

  ring(3.8, 2.7, c-re)
  ring(2.9, 2.05, c-cs)
  ring(2.0, 1.4, c-cf)
  ring(1.15, 0.8, c-reg)

  let lab(pos, body) = draw.content(pos, text(size: s-cap, fill: c-ink)[#body])
  lab((0, 2.3), [Recursively Enumerable])
  lab((0, 1.65), [Context-Sensitive])
  lab((0, 1.0), [Context-Free])
  lab((0, 0.5), [Regular])
})

// ── Дерево разбора a³b³ ──
#let parse-tree-a3b3 = {
  let cn(pos, body, ..args) = node(pos, body, fill: c-conn, width: n-size, height: n-size, ..args)
  let tn(pos, body, ..args) = node(pos, body, fill: c-atom, width: n-size, height: n-size, ..args)
  let re(from, to, label) = edge(from, to, "-", stroke: e-stroke, label: label, label-side: center, label-fill: white, label-size: s-tiny)

  diagram(
    node-shape: "circle",
    node-stroke: n-stroke,
    node-inset: 0pt,
    node-outset: 0pt,
    spacing: 2em,

    // Хребет S слева направо: каждый S раскрыт в a, S, b.
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

    // Каждое раскрытие S подписано своим правилом.
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

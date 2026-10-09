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
  let ring(rx, ry, fill) = draw.circle(
    (0, 0),
    radius: (rx, ry),
    fill: fill,
    stroke: c-bd + t-bd,
  )

  ring(3.8, 2.7, c-re)
  ring(2.9, 2.05, c-cs)
  ring(2.0, 1.4, c-cf)
  ring(1.15, 0.8, c-reg)

  let lab(pos, body) = draw.content(pos, text(size: s-cap, fill: c-ink)[#body])
  lab((0, 2.3), [Рекурсивно перечислимые])
  lab((0, 1.65), [Контекстно-зависимые])
  lab((0, 1.0), [Контекстно-свободные])
  lab((0, 0.5), [Регулярные])
})

// ── Дерево разбора a³b³ ──
#let parse-tree-a3b3 = {
  let cn(pos, body, ..args) = node(
    pos,
    body,
    fill: c-conn,
    width: n-size,
    height: n-size,
    ..args,
  )
  let tn(pos, body, ..args) = node(
    pos,
    body,
    fill: c-atom,
    width: n-size,
    height: n-size,
    ..args,
  )
  let re(from, to, label: $S -> a S b$) = edge(
    from,
    to,
    "-",
    stroke: e-stroke,
    label: label,
    label-side: center,
    label-fill: c-white,
    label-size: s-tiny,
  )

  diagram(
    node-shape: "circle",
    node-stroke: n-stroke,
    node-inset: 0pt,
    node-outset: 0pt,
    spacing: 2em,

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

    re(<s0>, <a1>),
    re(<s0>, <s1>),
    re(<s0>, <b1>),
    re(<s1>, <a2>),
    re(<s1>, <s2>),
    re(<s1>, <b2>),
    re(<s2>, <a3>),
    re(<s2>, <s3>),
    re(<s2>, <b3>),
    re(<s3>, <eps>, label: $S -> epsilon$),
  )
}

// ── Два дерева разбора одного слова ──
#let ambig-parse-trees = {
  let n-amb = 2em

  let cn(pos, body, ..args) = node(
    pos,
    body,
    fill: c-conn,
    width: n-amb,
    height: n-amb,
    ..args,
  )
  let tn(pos, body, ..args) = node(
    pos,
    body,
    fill: c-atom,
    width: n-amb,
    height: n-amb,
    ..args,
  )
  let te(from, to) = edge(from, to, "-", stroke: e-stroke)
  let cap(pos, body) = node(pos, body, shape: rect, fill: none, stroke: none)

  diagram(
    node-shape: "circle",
    node-stroke: n-stroke,
    node-inset: 0pt,
    node-outset: 0pt,
    spacing: 2em,

    cn((2, 0), $E$, name: <a-rot>),
    cn((1, 1), $E$, name: <a-l>),
    tn((3, 1), $"*"$, name: <a-mul>),
    cn((4, 1), $E$, name: <a-r>),
    cn((0, 2), $E$, name: <a-ll>),
    tn((1, 2), $"+"$, name: <a-add>),
    cn((2, 2), $E$, name: <a-lr>),
    tn((0, 3), $"id"$, name: <a-id0>),
    tn((2, 3), $"id"$, name: <a-id2>),
    tn((4, 3), $"id"$, name: <a-id4>),

    cn((8.5, 0), $E$, name: <b-rot>),
    cn((6.5, 1), $E$, name: <b-l>),
    tn((7.5, 1), $"+"$, name: <b-add>),
    cn((8.5, 1), $E$, name: <b-r>),
    cn((8.5, 2), $E$, name: <b-rl>),
    tn((9.5, 2), $"*"$, name: <b-mul>),
    cn((10.5, 2), $E$, name: <b-rr>),
    tn((6.5, 3), $"id"$, name: <b-id0>),
    tn((8.5, 3), $"id"$, name: <b-id2>),
    tn((10.5, 3), $"id"$, name: <b-id4>),

    cap((2, 4), [$("id" + "id") * "id"$]),
    cap((8.5, 4), [$"id" + ("id" * "id")$]),

    te(<a-rot>, <a-l>),
    te(<a-rot>, <a-mul>),
    te(<a-rot>, <a-r>),
    te(<a-l>, <a-ll>),
    te(<a-l>, <a-add>),
    te(<a-l>, <a-lr>),
    te(<a-ll>, <a-id0>),
    te(<a-lr>, <a-id2>),
    te(<a-r>, <a-id4>),

    te(<b-rot>, <b-l>),
    te(<b-rot>, <b-add>),
    te(<b-rot>, <b-r>),
    te(<b-r>, <b-rl>),
    te(<b-r>, <b-mul>),
    te(<b-r>, <b-rr>),
    te(<b-l>, <b-id0>),
    te(<b-rl>, <b-id2>),
    te(<b-rr>, <b-id4>),
  )
}

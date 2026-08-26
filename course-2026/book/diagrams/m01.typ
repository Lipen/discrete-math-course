// m01 diagrams: деревья разбора, порядок кванторов, квадрат оппозиций, DAG резолюции.
#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

#let n-size = 1.5em

#let n-stroke = t-bd + c-bd

#let e-stroke = (paint: c-edge, thickness: t-ed)

#let parse-tree-imply = {
  let cn(pos, label, ..args) = node(
    pos,
    label,
    fill: c-conn,
    width: n-size,
    height: n-size,
    ..args,
  )
  let an(pos, label, ..args) = node(
    pos,
    label,
    fill: c-atom,
    width: n-size,
    height: n-size,
    ..args,
  )
  let e(to, from) = edge(to, from, "-", stroke: e-stroke)

  diagram(
    node-shape: "circle",
    node-stroke: n-stroke,
    node-inset: 0pt,
    node-outset: 0pt,
    spacing: 2em,

    cn((0, 0), $imply$, name: <root>),
    cn((-2, 1), $and$, name: <and>),
    an((2, 1), $r$, name: <r>),
    cn((-3, 2), $not$, name: <not>),
    an((-0.5, 2), $q$, name: <q>),
    an((-3, 3), $p$, name: <p>),

    e(<root>, <and>),
    e(<root>, <r>),
    e(<and>, <not>),
    e(<and>, <q>),
    e(<not>, <p>),
  )
}

#let quantifier-order = {
  let x-node(pos, label, ..args) = node(
    pos,
    label,
    fill: c-atom,
    width: n-size,
    height: n-size,
    ..args,
  )
  let e(to, from) = edge(to, from, "->", stroke: e-stroke)

  diagram(
    node-shape: "circle",
    node-stroke: n-stroke,
    node-inset: 0pt,
    node-outset: 0pt,
    spacing: 2em,

    node(
      (-3, 4),
      text(size: 0.85em)[$forall x exists y$],
      fill: none,
      stroke: none,
    ),
    x-node((-4, 0), $x_1$, name: <x1>),
    x-node((-4, 1.5), $x_2$, name: <x2>),
    x-node((-4, 3), $x_3$, name: <x3>),
    x-node((-2, 0), $y_1$, name: <y1>),
    x-node((-2, 1.5), $y_2$, name: <y2>),
    x-node((-2, 3), $y_3$, name: <y3>),
    e(<x1>, <y1>),
    e(<x2>, <y2>),
    e(<x3>, <y3>),

    node(
      (3, 4),
      text(size: 0.85em)[$exists y forall x$],
      fill: none,
      stroke: none,
    ),
    x-node((2, 0), $x_1$, name: <a1>),
    x-node((2, 1.5), $x_2$, name: <a2>),
    x-node((2, 3), $x_3$, name: <a3>),
    x-node((4, 1.5), $y$, name: <yy>),
    e(<a1>, <yy>),
    e(<a2>, <yy>),
    e(<a3>, <yy>),
  )
}

// Квадрат оппозиций: A (общеутв.), E (общеотриц.), I (частноутв.), O (частноотриц.).
// Горизонтали --- контрарность и субконтрарность, диагонали --- противоречие,
// вертикали (стрелки вниз) --- подчинение от общего к частному.
#let square-of-opposition = {
  let half = 2.1
  let box = 0.62
  let c-line = c-accent

  let corner(pos, label-text) = {
    let (x, y) = pos
    draw.rect(
      (x - box, y + box),
      (x + box, y - box),
      name: label-text,
      fill: c-fl,
      stroke: t-bd + c-bd,
      radius: 6pt,
    )
    draw.content(label-text, text(size: s-node, fill: c-ink)[#label-text])
  }

  let sq-edge(from, to, label: none, dashed: false, arrow: false) = {
    let st = if dashed {
      (paint: c-line, thickness: t-bd, dash: "dashed")
    } else {
      (paint: c-line, thickness: t-bd)
    }
    let mark = if arrow { (end: "stealth", fill: c-line) } else { none }
    draw.line(from, to, name: from + "-" + to, stroke: st, mark: mark)
    if label != none {
      draw.content(
        from + "-" + to,
        text(size: s-cap, fill: c-muted)[#label],
        fill: white,
        stroke: none,
        padding: 2pt,
      )
    }
  }

  canvas({
    corner((-half, half), "A")
    corner((half, half), "E")
    corner((-half, -half), "I")
    corner((half, -half), "O")

    sq-edge("A", "E", label: [контрарность])
    sq-edge("I", "O", label: [субконтрарность])
    sq-edge("A", "I", label: [подчинение], arrow: true)
    sq-edge("E", "O", label: [подчинение], arrow: true)

    sq-edge("A", "O", dashed: true)
    sq-edge("I", "E", dashed: true)
    draw.content(
      (0, 0),
      text(size: s-cap, fill: c-muted)[противоречие],
      fill: white,
      stroke: none,
      padding: 2pt,
    )
  })
}

#let c-res-in = c-fl

#let c-res-mid = c-atom

#let c-res-empty = c-conn

#let c-res-str = c-bd + t-bd

#let c-res-empty-str = c-hot + t-bd

#let c-res-edge = c-edge + t-ed

#let cn(pos, body, fill: c-res-in, ..args) = node(
  pos,
  body,
  fill: fill,
  width: 2.2em,
  height: 1.1em,
  ..args,
)

#let re(from, to) = edge(from, to, "-", stroke: c-res-edge)

#let resolution-dag = diagram(
  node-shape: "rect",
  node-stroke: c-res-str,
  node-inset: 4pt,
  node-outset: 4pt,
  spacing: 1.6em,

  cn((-4, 0), $not p or q$, name: <c1>),
  cn((-2, 0), $p$, name: <c3>),
  cn((0, 0), $not q or r$, name: <c2>),
  cn((2, 0), $not r$, name: <c4>),

  cn((-3, 1.5), $q$, fill: c-res-mid, name: <r1>),
  cn((1, 1.5), $r$, fill: c-res-mid, name: <r2>),

  cn(
    (-1, 3),
    $square$,
    fill: c-res-empty,
    stroke: c-res-empty-str,
    name: <empty>,
  ),

  re(<c1>, <r1>),
  re(<c3>, <r1>),
  re(<c2>, <r2>),
  re(<r1>, <r2>),
  re(<r2>, <empty>),
  re(<c4>, <empty>),

  edge(<c1>, <r1>, "-", stroke: none, label: [$p$], label-size: 0.55em),
  edge(<c3>, <r1>, "-", stroke: none, label: [$p$], label-size: 0.55em),
  edge(<c2>, <r2>, "-", stroke: none, label: [$q$], label-size: 0.55em),
  edge(<r1>, <r2>, "-", stroke: none, label: [$q$], label-size: 0.55em),
  edge(<r2>, <empty>, "-", stroke: none, label: [$r$], label-size: 0.55em),
  edge(<c4>, <empty>, "-", stroke: none, label: [$r$], label-size: 0.55em),
)

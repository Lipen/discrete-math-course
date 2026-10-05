#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

#let n-size = 1.5em

#let n-stroke = t-bd + c-bd

#let e-stroke = (paint: c-edge, thickness: t-ed)

// ── Дерево разбора ──
#let tree-diagram(spacing: 2em, ..nodes) = diagram(
  node-shape: "circle",
  node-stroke: n-stroke,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: spacing,
  ..nodes,
)

#let parse-tree-imply = {
  let conn-node(pos, label, ..args) = node(
    pos,
    label,
    fill: c-conn,
    width: n-size,
    height: n-size,
    ..args,
  )
  let atom-node(pos, label, ..args) = node(
    pos,
    label,
    fill: c-atom,
    width: n-size,
    height: n-size,
    ..args,
  )
  let tree-edge(parent, child) = edge(parent, child, "-", stroke: e-stroke)

  tree-diagram(
    conn-node((0, 0), $imply$, name: <root>),
    conn-node((-2, 1), $and$, name: <and>),
    atom-node((2, 1), $r$, name: <r>),
    conn-node((-3, 2), $not$, name: <not>),
    atom-node((-0.5, 2), $q$, name: <q>),
    atom-node((-3, 3), $p$, name: <p>),

    tree-edge(<root>, <and>),
    tree-edge(<root>, <r>),
    tree-edge(<and>, <not>),
    tree-edge(<and>, <q>),
    tree-edge(<not>, <p>),
  )
}

// ── Порядок кванторов ──
#let quantifier-order = {
  let element-node(pos, label, ..args) = node(
    pos,
    label,
    fill: c-atom,
    width: n-size,
    height: n-size,
    ..args,
  )
  let arrow-edge(from, to) = edge(from, to, "->", stroke: e-stroke)
  let formula-node(pos, body) = node(
    pos,
    text(size: 0.85em)[#body],
    fill: none,
    stroke: none,
  )

  tree-diagram(
    formula-node((-3, 4), $forall x exists y$),
    element-node((-4, 0), $x_1$, name: <x1>),
    element-node((-4, 1.5), $x_2$, name: <x2>),
    element-node((-4, 3), $x_3$, name: <x3>),
    element-node((-2, 0), $y_1$, name: <y1>),
    element-node((-2, 1.5), $y_2$, name: <y2>),
    element-node((-2, 3), $y_3$, name: <y3>),
    arrow-edge(<x1>, <y1>),
    arrow-edge(<x2>, <y2>),
    arrow-edge(<x3>, <y3>),

    formula-node((3, 4), $exists y forall x$),
    element-node((2, 0), $x_1$, name: <a1>),
    element-node((2, 1.5), $x_2$, name: <a2>),
    element-node((2, 3), $x_3$, name: <a3>),
    element-node((4, 1.5), $y$, name: <yy>),
    arrow-edge(<a1>, <yy>),
    arrow-edge(<a2>, <yy>),
    arrow-edge(<a3>, <yy>),
  )
}

// ── Логический квадрат ──
// Квадрат оппозиций: A (общеутв.), E (общеотриц.), I (частноутв.), O (частноотриц.).
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
        fill: c-white,
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
      fill: c-white,
      stroke: none,
      padding: 2pt,
    )
  })
}

// ── Резолюционное опровержение ──
#let resolution-dag = {
  let clause-node(pos, body, fill: c-fl, ..args) = node(
    pos,
    body,
    fill: fill,
    width: 2.2em,
    height: 1.1em,
    ..args,
  )
  let resolve-edge(from, to, label: none) = edge(
    from,
    to,
    "-",
    stroke: c-edge + t-ed,
    label: label,
    label-size: s-tiny,
  )

  diagram(
    node-shape: "rect",
    node-stroke: c-bd + t-bd,
    node-inset: 4pt,
    node-outset: 4pt,
    spacing: 1.6em,

    clause-node((-4, 0), $not p or q$, name: <c1>),
    clause-node((-2, 0), $p$, name: <c3>),
    clause-node((0, 0), $not q or r$, name: <c2>),
    clause-node((2, 0), $not r$, name: <c4>),

    clause-node((-3, 1.5), $q$, fill: c-atom, name: <r1>),
    clause-node((1, 1.5), $r$, fill: c-atom, name: <r2>),

    clause-node(
      (-1, 3),
      $square$,
      fill: c-conn,
      stroke: c-hot + t-bd,
      name: <empty>,
    ),

    resolve-edge(<c1>, <r1>, label: $p$),
    resolve-edge(<c3>, <r1>, label: $p$),
    resolve-edge(<c2>, <r2>, label: $q$),
    resolve-edge(<r1>, <r2>, label: $q$),
    resolve-edge(<r2>, <empty>, label: $r$),
    resolve-edge(<c4>, <empty>, label: $r$),
  )
}

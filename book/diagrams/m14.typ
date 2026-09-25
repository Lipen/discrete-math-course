#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

// ── Граф импликаций 2-SAT ──
#let implication-graph-2sat-simple = diagram(
  node-shape: circle,
  node-fill: c-atom,
  node-stroke: t-bd + c-bd,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 5em,
  node(
    (0, 0),
    text(size: s-node, fill: c-ink)[$x$],
    name: <x>,
    width: 2em,
    height: 2em,
  ),
  node(
    (0, 1),
    text(size: s-node, fill: c-ink)[$overline(x)$],
    name: <notx>,
    width: 2em,
    height: 2em,
  ),
  node(
    (1, 0),
    text(size: s-node, fill: c-ink)[$y$],
    name: <y>,
    width: 2em,
    height: 2em,
  ),
  node(
    (1, 1),
    text(size: s-node, fill: c-ink)[$overline(y)$],
    name: <noty>,
    width: 2em,
    height: 2em,
  ),

  // Стрелки соответствуют дизъюнктам: (x or y) и (not x or y).
  edge(
    <notx>,
    <y>,
    "->",
    stroke: c-edge + t-ed,
    label: text(size: s-cap, fill: c-muted)[$x or y$],
    label-side: center,
    label-fill: c-white,
  ),
  edge(
    <x>,
    <y>,
    "->",
    stroke: c-edge + t-ed,
    label: text(size: s-cap, fill: c-muted)[$not x or y$],
    label-side: center,
    label-fill: c-white,
  ),
)

// ── Дерево DPLL ──
#let dpll-tree = {
  let dnode(pos, name, fill, stroke, title, subtitle) = node(
    pos,
    {
      text(size: s-cap, fill: c-ink)[#title]
      if subtitle != none {
        linebreak()
        text(size: s-tiny, fill: c-muted)[#subtitle]
      }
    },
    name: name,
    fill: fill,
    stroke: stroke,
    shape: rect,
    inset: 8pt,
    corner-radius: 4pt,
  )
  let dnote(pos, body) = node(
    pos,
    body,
    fill: none,
    stroke: none,
    shape: rect,
    inset: 0pt,
  )
  let dtree-edge(fr, to) = edge(fr, to, "-", stroke: c-edge + t-ed)

  diagram(
    spacing: (5em, 3.4em),
    dnode(
      (0, 0),
      <formula>,
      c-fl,
      t-bd + c-bd,
      $(x or y) and (not x or y) and (x or not y) and (not x or not y)$,
      none,
    ),
    dnode((0, 1), <decision>, c-conn, t-bd + c-bd, [выбор $x$], none),
    dnote((-1.2, 1.45), text(size: s-cap, fill: c-accent)[$x = 1$]),
    dnode(
      (-1.2, 2),
      <up-left>,
      c-atom,
      t-bd + c-bd,
      [unit propagation],
      [$(not x or y) -> y = 1$],
    ),
    dnode(
      (-1.2, 3),
      <conf-left>,
      c-warn,
      t-bd + c-hot,
      [конфликт],
      [$(not x or not y)$ пуст],
    ),
    dnote((-1.2, 3.7), text(size: s-cap, fill: c-hot, weight: "bold")[$times$]),
    dnote((1.2, 1.45), text(size: s-cap, fill: c-accent)[$x = 0$]),
    dnode(
      (1.2, 2),
      <up-right>,
      c-atom,
      t-bd + c-bd,
      [unit propagation],
      [$(x or y) -> y = 1$],
    ),
    dnode(
      (1.2, 3),
      <conf-right>,
      c-warn,
      t-bd + c-hot,
      [конфликт],
      [$(x or not y)$ пуст],
    ),
    dnote((1.2, 3.7), text(size: s-cap, fill: c-hot, weight: "bold")[$times$]),

    dtree-edge(<formula>, <decision>),
    dtree-edge(<decision>, <up-left>),
    dtree-edge(<decision>, <up-right>),
    dtree-edge(<up-left>, <conf-left>),
    dtree-edge(<up-right>, <conf-right>),
  )
}

// ── Таблица Кука-Левина ──
#let cook-levin-table = {
  canvas({
    let rows = 4
    let cols = 6
    let cell = 0.55

    for t in range(rows) {
      for i in range(cols) {
        let x = (i - (cols - 1) / 2) * cell
        let y = (rows / 2 - 0.5 - t) * cell
        draw.rect(
          (x - cell / 2, y - cell / 2),
          (x + cell / 2, y + cell / 2),
          fill: c-fl,
          stroke: t-hr + c-bd,
          name: "c-" + str(t) + "-" + str(i),
        )
      }
    }

    for i in range(2, 5) {
      let x = (i - (cols - 1) / 2) * cell
      let y = (rows / 2 - 0.5 - 1) * cell
      draw.content((x, y + 0.02), text(size: s-tiny, fill: c-hot)[$H$])
    }

    let x0 = (2 - (cols - 1) / 2) * cell - cell / 2
    let x1 = (4 - (cols - 1) / 2) * cell + cell / 2
    let y0 = (rows / 2 - 0.5 - 1) * cell + cell / 2
    let y1 = (rows / 2 - 0.5 - 2) * cell - cell / 2
    draw.rect(
      (x0, y0),
      (x1, y1),
      stroke: t-bd + c-hot,
      fill: none,
      name: "window",
    )

    draw.content(
      (0, (rows / 2 + 0.8) * cell),
      text(size: s-cap, fill: c-muted)[шаг $t$],
    )
    draw.content(
      (-(cols / 2 + 0.5) * cell, 0),
      rotate(90deg, text(size: s-cap, fill: c-muted)[позиция $i$]),
    )
    draw.content(
      ((cols / 2 + 0.8) * cell, 0),
      rotate(-90deg, text(
        size: s-tiny,
        fill: c-muted,
      )[локальность: ячейка зависит от трёх выше]),
    )
  })
}

// ── Конфликт-граф CDCL ──
#let cdcl-conflict-graph = {
  let cnode(pos, name, label, ..args) = node(
    pos,
    text(size: s-node, fill: c-ink)[#label],
    name: name,
    shape: circle,
    width: 1.8em,
    height: 1.8em,
    inset: 0pt,
    fill: c-fl,
    stroke: t-bd + c-bd,
    ..args,
  )
  let cnote(pos, body) = node(
    pos,
    body,
    fill: none,
    stroke: none,
    shape: rect,
    inset: 0pt,
  )
  let impl-edge(fr, to, ..args) = edge(
    fr,
    to,
    "->",
    stroke: c-edge + t-ed,
    ..args,
  )

  diagram(
    spacing: (4.5em, 4em),
    // Решения: x₁ = 1 (уровень 1), x₂ = 0, то есть ¬x₂ (уровень 2).
    cnode((-1.5, 0), <x1>, $x_1$, fill: c-atom, stroke: t-hi + c-bd),
    cnote((-1.9, -0.22), text(size: s-tiny, fill: c-muted)[ур. 1]),
    cnode((1.5, 0), <nx2>, $overline(x_2)$, fill: c-atom, stroke: t-hi + c-bd),
    cnote((1.9, -0.22), text(size: s-tiny, fill: c-muted)[ур. 2]),

    cnode((-1.1, 1), <x3>, $x_3$),
    cnode((-0.6, 1.45), <x4>, $x_4$),
    cnode((1.1, 1), <x5>, $x_5$),
    cnode((0.25, 2.1), <x6>, $x_6$),
    cnode((0, 2.75), <conf>, $bot$, fill: c-warn, stroke: t-bd + c-hot),

    impl-edge(
      <x1>,
      <x3>,
      label: text(size: s-tiny, fill: c-muted)[$overline(x_1) or x_3$],
      label-side: center,
      label-fill: c-white,
    ),
    impl-edge(
      <x3>,
      <x4>,
      label: text(size: s-tiny, fill: c-muted)[$overline(x_3) or x_4$],
      label-side: center,
      label-fill: c-white,
    ),
    impl-edge(<x4>, <x6>),
    impl-edge(
      <nx2>,
      <x5>,
      label: text(size: s-tiny, fill: c-muted)[$x_2 or x_5$],
      label-side: center,
      label-fill: c-white,
    ),
    impl-edge(<x5>, <x6>),
    impl-edge(<x6>, <conf>),
    impl-edge(<x5>, <conf>),
    impl-edge(<x4>, <conf>),

    // Разрез сразу за первым UIP (x₅) отделяет причину от следствия.
    edge(
      (-1.9, 1.85),
      (1.9, 1.85),
      "-",
      stroke: (paint: c-hot, thickness: t-bd, dash: "dashed"),
      label: text(size: s-tiny, fill: c-hot)[разрез 1-UIP],
      label-pos: 0.93,
      label-side: left,
    ),
    cnote((0, 3.45), text(
      size: s-cap,
      fill: c-ink,
    )[выученный дизъюнкт: $overline(x_4) or overline(x_5)$]),
  )
}

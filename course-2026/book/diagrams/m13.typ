#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

// ── Граф импликаций 2-SAT ──
#let implication-graph-2sat-simple = {
  let lit-node(pos, label, name) = {
    draw.circle(pos, radius: 0.4, fill: c-atom, stroke: t-bd + c-bd, name: name)
    draw.content(pos, text(size: s-node, fill: c-ink)[#label])
  }

  // Стрелки соответствуют дизъюнктам: (x or y) и (not x or y).
  let impl-edge(from, to, name) = draw.line(
    from,
    to,
    name: name,
    stroke: c-edge + t-ed,
    mark: (end: "stealth", fill: c-edge),
  )

  canvas({
    lit-node((0, 0.8), $x$, "x")
    lit-node((0, -0.8), $overline(x)$, "notx")
    lit-node((2, 0.8), $y$, "y")
    lit-node((2, -0.8), $overline(y)$, "noty")

    impl-edge("notx", "y", "e-lower")
    impl-edge("x", "y", "e-upper")

    draw.content("e-upper", text(size: s-cap, fill: c-muted)[$x or y$], fill: white, stroke: none, padding: 2pt)
    draw.content("e-lower", text(size: s-cap, fill: c-muted)[$not x or y$], fill: white, stroke: none, padding: 2pt)
  })
}

// ── Дерево DPLL ──
#let dpll-box(pos, w, h, fill, stroke, title, subtitle, name) = {
  let (cx, cy) = pos
  draw.rect(
    (cx - w / 2, cy - h / 2),
    (cx + w / 2, cy + h / 2),
    radius: 4pt,
    fill: fill,
    stroke: stroke,
    name: name,
  )
  draw.content((cx, cy + 0.15), text(size: s-cap, fill: c-ink)[#title])
  if subtitle != none {
    draw.content((cx, cy - 0.2), text(size: s-tiny, fill: c-muted)[#subtitle])
  }
}

#let dpll-dead-end(pos, name) = {
  let (cx, cy) = pos
  draw.line(
    (cx - 0.2, cy - 0.15),
    (cx + 0.2, cy - 0.4),
    stroke: c-hot + t-bd,
    name: name + "-x1",
  )
  draw.line(
    (cx + 0.2, cy - 0.15),
    (cx - 0.2, cy - 0.4),
    stroke: c-hot + t-bd,
    name: name + "-x2",
  )
}

#let dpll-edge(from-anchor, to-anchor) = {
  draw.line(from-anchor, to-anchor, stroke: c-edge + t-ed)
}

#let dpll-tree = {
  canvas({
    dpll-box(
      (0, 4.2),
      5.0,
      0.8,
      c-fl,
      t-bd + c-bd,
      $(x or y) and (not x or y) and (x or not y) and (not x or not y)$,
      none,
      "formula",
    )

    dpll-box((0, 3.0), 2.0, 0.6, c-conn, t-bd + c-bd, [выбор $x$], none, "decision")
    dpll-edge("formula.south", "decision.north")

    draw.content((-2.1, 3.3), anchor: "south", text(size: s-cap, fill: c-accent)[$x = 1$])
    dpll-box(
      (-2.1, 1.9),
      2.2,
      0.8,
      c-atom,
      t-bd + c-bd,
      [unit propagation],
      [$(not x or y) -> y = 1$],
      "up-left",
    )
    dpll-edge("decision.south-west", "up-left.north")

    dpll-box(
      (-2.1, 0.7),
      2.2,
      0.8,
      c-warn,
      t-bd + c-hot,
      [конфликт],
      [$(not x or not y)$ пуст],
      "conf-left",
    )
    dpll-edge("up-left.south", "conf-left.north")
    dpll-dead-end((-2.1, 0.0), "dead-left")

    draw.content((2.1, 3.3), anchor: "south", text(size: s-cap, fill: c-accent)[$x = 0$])
    dpll-box(
      (2.1, 1.9),
      2.2,
      0.8,
      c-atom,
      t-bd + c-bd,
      [unit propagation],
      [$(x or y) -> y = 1$],
      "up-right",
    )
    dpll-edge("decision.south-east", "up-right.north")

    dpll-box(
      (2.1, 0.7),
      2.2,
      0.8,
      c-warn,
      t-bd + c-hot,
      [конфликт],
      [$(x or not y)$ пуст],
      "conf-right",
    )
    dpll-edge("up-right.south", "conf-right.north")
    dpll-dead-end((2.1, 0.0), "dead-right")
  })
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
    let y1 = (rows / 2 - 0.5 - 0) * cell - cell / 2
    draw.rect((x0, y0), (x1, y1), stroke: t-bd + c-hot, fill: none, name: "window")

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
      rotate(-90deg, text(size: s-tiny, fill: c-muted)[локальность: ячейка зависит от трёх выше]),
    )
  })
}

// ── Конфликт-граф CDCL ──
#let cdcl-node(pos, label, name, ..style) = {
  let (cx, cy) = pos
  draw.circle(
    (cx, cy),
    radius: 0.32,
    fill: c-fl,
    stroke: t-bd + c-bd,
    name: name,
    ..style,
  )
  draw.content((cx, cy), text(size: s-node, fill: c-ink)[#label])
}

#let cdcl-conflict-graph = {
  let impl-edge(from, to, name) = draw.line(
    from,
    to,
    name: name,
    stroke: c-edge + t-ed,
    mark: (end: "stealth", fill: c-edge),
  )

  canvas({
    cdcl-node((-2.6, 1.6), $x_1$, "x1", fill: c-atom, stroke: t-hi + c-bd)
    draw.content((-3.3, 1.9), text(size: s-tiny, fill: c-muted)[ур. 1])
    cdcl-node((-1.5, 0.6), $overline(x_2)$, "nx2")
    cdcl-node((-0.4, 0.0), $x_3$, "x3")

    cdcl-node((2.6, 1.6), $overline(x_4)$, "nx4", fill: c-atom, stroke: t-hi + c-bd)
    draw.content((3.3, 1.9), text(size: s-tiny, fill: c-muted)[ур. 2])
    cdcl-node((1.5, 0.6), $x_5$, "x5")

    cdcl-node((0.0, -1.2), $bot$, "conf", fill: c-warn, stroke: t-bd + c-hot)

    impl-edge("x1", "nx2", "x1-nx2")
    impl-edge("nx2", "x3", "nx2-x3")
    impl-edge("x3", "conf", "x3-conf")
    impl-edge("nx4", "x5", "nx4-x5")
    impl-edge("x5", "conf", "x5-conf")

    draw.content("x1-nx2", text(size: s-tiny, fill: c-muted)[$overline(x_1) or overline(x_2)$], fill: white, stroke: none, padding: 2pt)
    draw.content("nx2-x3", text(size: s-tiny, fill: c-muted)[$x_2 or x_3$], fill: white, stroke: none, padding: 2pt)
    draw.content("nx4-x5", text(size: s-tiny, fill: c-muted)[$x_4 or x_5$], fill: white, stroke: none, padding: 2pt)

    // Разрез за первым UIP отделяет причину от следствия.
    draw.line((-0.9, 0.7), (0.9, 0.7), name: "cut", stroke: t-bd + c-hot, dash: "dashed")
    draw.content((0.95, 0.85), anchor: "west", text(size: s-tiny, fill: c-hot)[разрез 1-UIP])

    draw.content((0, -1.9), text(size: s-cap, fill: c-ink)[выученный дизъюнкт: $x_1 or x_4$])
  })
}

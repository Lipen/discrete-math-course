// m19 diagrams: цепь Маркова, дерево вероятностей, байесовская сеть.
#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

#let n-stroke = t-bd + c-bd

#let e-stroke = (paint: c-edge, thickness: t-ed)

// ── Цепь Маркова ──
#let markov-chain = canvas({
  let state(pos, label, name) = {
    let (x, y) = pos
    draw.circle((x, y), radius: 0.5, name: name, fill: c-fl, stroke: n-stroke)
    draw.content((x, y), text(size: s-node, fill: c-ink, weight: "bold")[#label])
  }

  // Вероятность перехода --- в середине ребра.
  let elabel(edge-name, prob) = {
    draw.content(
      edge-name + ".mid",
      text(size: s-cap, fill: c-accent)[#prob],
      fill: white,
      stroke: none,
      padding: 2pt,
      anchor: "south",
    )
  }

  // ── Состояния ──
  state((0, 0), [$S$], "S")
  state((5, 0), [$R$], "R")

  // ── Переходы ──
  draw.line(
    "S.north-east",
    "R.north-west",
    name: "s-r",
    stroke: e-stroke,
    mark: (end: ">", fill: c-edge),
  )
  elabel("s-r", [$0.2$])

  draw.line(
    "R.south-west",
    "S.south-east",
    name: "r-s",
    stroke: e-stroke,
    mark: (end: ">", fill: c-edge),
  )
  elabel("r-s", [$0.4$])

  draw.bezier(
    "S.north-west",
    "S.north-east",
    (-1.2, 1.5),
    (1.2, 1.5),
    name: "s-s",
    stroke: e-stroke,
    mark: (end: ">", fill: c-edge),
  )
  elabel("s-s", [$0.8$])

  draw.bezier(
    "R.north-west",
    "R.north-east",
    (3.8, 1.5),
    (6.2, 1.5),
    name: "r-r",
    stroke: e-stroke,
    mark: (end: ">", fill: c-edge),
  )
  elabel("r-r", [$0.6$])
})

// ── Дерево вероятностей ──
#let probability-tree = canvas({
  let prob-edge(from, to, prob) = {
    let name = "e-" + from + "-" + to
    draw.line(from, to, stroke: e-stroke, name: name)
    draw.content(
      name + ".mid",
      text(size: s-cap, fill: c-accent)[$#prob$],
      fill: white,
      stroke: none,
      padding: 2pt,
    )
  }

  let leaf-label(pos, outcome, prob) = {
    let (x, y) = pos
    draw.content((x, y - 0.4), text(size: s-cap, fill: c-muted)[#outcome])
    draw.content((x, y - 0.78), text(size: s-cap, fill: c-accent)[$#prob$])
  }

  // ── Узлы: ветвления ──
  draw.circle((0, 3.4), radius: 0.17, fill: c-fl, stroke: n-stroke, name: "root")
  draw.circle((2.8, 1.8), radius: 0.17, fill: c-fl, stroke: n-stroke, name: "H")
  draw.circle((-2.8, 1.8), radius: 0.17, fill: c-fl, stroke: n-stroke, name: "T")

  draw.circle((4.2, 0), radius: 0.17, fill: c-atom, stroke: n-stroke, name: "HH")
  draw.circle((1.4, 0), radius: 0.17, fill: c-atom, stroke: n-stroke, name: "HT")
  draw.circle((-1.4, 0), radius: 0.17, fill: c-atom, stroke: n-stroke, name: "TH")
  draw.circle((-4.2, 0), radius: 0.17, fill: c-atom, stroke: n-stroke, name: "TT")

  // ── Ветви с вероятностями ──
  prob-edge("root", "H", 0.6)
  prob-edge("root", "T", 0.4)
  prob-edge("H", "HH", 0.6)
  prob-edge("H", "HT", 0.4)
  prob-edge("T", "TH", 0.6)
  prob-edge("T", "TT", 0.4)

  // ── Метки ветвлений (в открытом месте, вне рёбер) ──
  draw.content((3.4, 2.4), text(size: s-node, fill: c-ink, weight: "bold")[$H$])
  draw.content((-3.4, 2.4), text(size: s-node, fill: c-ink, weight: "bold")[$T$])

  // ── Исходы ──
  leaf-label((4.2, 0), [$H H$], 0.36)
  leaf-label((1.4, 0), [$H T$], 0.24)
  leaf-label((-1.4, 0), [$T H$], 0.24)
  leaf-label((-4.2, 0), [$T T$], 0.16)
})

// ── Байесовская сеть ──
#let bayes-net = canvas({
  let bn-node(pos, label, name) = {
    let (x, y) = pos
    draw.rect(
      (x - 1.2, y + 0.45),
      (x + 1.2, y - 0.45),
      name: name,
      fill: c-fl,
      stroke: n-stroke,
      radius: 8pt,
    )
    draw.content((x, y), text(size: s-node, fill: c-ink, weight: "bold")[#label])
  }

  let dir-edge(from-anchor, to-anchor) = {
    draw.line(
      from-anchor,
      to-anchor,
      stroke: e-stroke,
      mark: (end: ">", fill: c-edge),
    )
  }

  // ── Узлы ──
  bn-node((0, 2.2), [Грипп], "flu")
  bn-node((-2.5, -0.3), [Кашель], "cough")
  bn-node((2.5, -0.3), [Температура], "fever")

  // ── Причинно-следственные связи ──
  dir-edge("flu.south-west", "cough.north")
  dir-edge("flu.south-east", "fever.north")

  // ── CPT-аннотации ──
  draw.content(
    "flu.east",
    text(size: s-cap, fill: c-muted)[$P("Flu") = 0.05$],
    anchor: "west",
    padding: 0.3,
  )

  draw.content(
    "cough.west",
    anchor: "east",
    padding: 0.25,
    text(size: s-cap, fill: c-muted)[
      $P("Cough" | "Flu") = 0.8$\
      $P("Cough" | not "Flu") = 0.1$
    ],
  )

  draw.content(
    "fever.east",
    anchor: "west",
    padding: 0.25,
    text(size: s-cap, fill: c-muted)[
      $P("Fever" | "Flu") = 0.9$\
      $P("Fever" | not "Flu") = 0.05$
    ],
  )
})

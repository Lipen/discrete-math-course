// M18 diagrams --- Type Theory: typing derivation trees.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

// ── Colours ──
#let c-judgment = oklch(50%, 0.04, 260deg)
#let c-rule = oklch(55%, 0.14, 260deg)
#let c-line = oklch(35%, 0.02, 265deg)

// ── Helpers ──

// Judgment node: rounded rect with given half-width.
#let judgment-node(pos, name, w, body) = {
  let (x, y) = pos
  draw.rect(
    (x - w, y + 0.35),
    (x + w, y - 0.35),
    name: name,
    fill: oklch(97%, 0.01, 260deg),
    stroke: 0.7pt + c-judgment,
    radius: 4pt,
  )
  draw.content(name, text(size: 0.65em, fill: c-judgment)[#body])
}

// Rule label at node.east + 0.3em gap, anchor west.
#let rule-label(node-name, body) = {
  draw.content(
    (rel: (0.3em, 0), to: node-name + ".east"),
    anchor: "west",
    text(size: 0.55em, fill: c-rule, weight: "semibold")[#body],
  )
}

// Vertical edge from parent.south to child.north.
#let vert-edge(parent, child) = {
  draw.line(
    (parent + ".south"),
    (child + ".north"),
    stroke: 0.6pt + c-line,
  )
}

// ═══════════════════════════════════════════════════════════════════
// Derivation of tack.r λx:Nat. x : Nat -> Nat
//
// One branch: premise (leaf, top) to conclusion (root, bottom).
// Linear because each typing rule in λ-> has at most one subderivation.
// ═══════════════════════════════════════════════════════════════════
#let derivation-id = figure(
  canvas({
    import draw: *
    let nw = 3.3
    let py = 3.0 // premise (var) --- leaf, top
    let cy = 1.0 // conclusion (abs) --- root, bottom

    judgment-node((3.0, py), "prem", nw, {
      $x : "Nat" tack.r x : "Nat"$
    })
    rule-label("prem", [(var)])

    judgment-node((3.0, cy), "conc", nw, {
      $tack.r lambda x : "Nat" . x : "Nat" -> "Nat"$
    })
    rule-label("conc", [(abs)])

    vert-edge("prem", "conc")
  }),
  caption: [
    Дерево вывода типа для тождественной функции.
    Верхний уровень --- аксиома var, нижний --- применение правила abs.
    Поскольку у правила abs одна посылка, дерево вырождается в линию --- это нормально для типовых выводов в $lambda ->$.
  ],
)

// ═══════════════════════════════════════════════════════════════════
// Derivation of K combinator: tack.r λx:Nat. λy:Bool. x : Nat -> Bool -> Nat
//
// Three levels: var -> abs on y -> abs on x. Linear for the same reason.
// ═══════════════════════════════════════════════════════════════════
#let derivation-k = figure(
  canvas({
    import draw: *
    let nw = 4.0
    let py = 4.4 // premise (var) --- leaf, top
    let my = 2.6 // abs on y --- middle
    let cy = 0.8 // abs on x --- root, bottom

    judgment-node((3.5, py), "k-prem", nw, {
      $x : "Nat", y : "Bool" tack.r x : "Nat"$
    })
    rule-label("k-prem", [(var)])

    judgment-node((3.5, my), "k-mid", nw, {
      $x : "Nat" tack.r lambda y : "Bool" . x : "Bool" -> "Nat"$
    })
    rule-label("k-mid", [(abs)])

    judgment-node((3.5, cy), "k-top", nw, {
      $tack.r lambda x : "Nat" . lambda y : "Bool" . x : "Nat" -> "Bool" -> "Nat"$
    })
    rule-label("k-top", [(abs)])

    vert-edge("k-prem", "k-mid")
    vert-edge("k-mid", "k-top")
  }),
  caption: [
    Дерево вывода типа для комбинатора $K$ (проекция на первый аргумент) с типами $"Nat"$ и $"Bool"$.
    Три шага: аксиома var, затем два применения правила abs.
    Вывод снова линеен --- каждое правило имеет ровно одну посылочную ветвь.
  ],
)

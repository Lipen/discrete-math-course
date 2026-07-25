// M18 diagrams — Type Theory: typing derivation trees.
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

// Rule label at node.east, anchor west — text starts at right edge of node.
#let rule-label(node-name, body) = {
  draw.content(
    (node-name + ".east"),
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
// Derivation of ⊢ λx:Nat. x : Nat → Nat
//
// One branch: conclusion above one premise.
// Linear because each typing rule in λ→ has at most one subderivation.
// ═══════════════════════════════════════════════════════════════════
#let derivation-id = figure(
  canvas({
    import draw: *
    let nw = 3.3
    let by = 1.0
    let ty = 3.0

    judgment-node((3.0, by), "prem", nw, {
      $x : "Nat" tack.r x : "Nat"$
    })
    rule-label("prem", [(var)])

    judgment-node((3.0, ty), "conc", nw, {
      $tack.r lambda x : "Nat" . x : "Nat" -> "Nat"$
    })
    rule-label("conc", [(abs)])

    vert-edge("conc", "prem")
  }),
  caption: [
    Дерево вывода типа для тождественной функции.
    Два уровня: нижний --- аксиома var, верхний --- правило abs.
    Поскольку у правила abs одна посылка, дерево вырождается в линию --- это нормально для типовых выводов в $lambda ->$.
  ],
)

// ═══════════════════════════════════════════════════════════════════
// Derivation of K combinator: ⊢ λx:Nat. λy:Bool. x : Nat → Bool → Nat
//
// Three levels: var → abs on y → abs on x. Linear for the same reason.
// ═══════════════════════════════════════════════════════════════════
#let derivation-k = figure(
  canvas({
    import draw: *
    let nw = 4.0
    let by = 0.8
    let my = 2.6
    let ty = 4.4

    judgment-node((3.5, by), "k-prem", nw, {
      $x : "Nat", y : "Bool" tack.r x : "Nat"$
    })
    rule-label("k-prem", [(var)])

    judgment-node((3.5, my), "k-mid", nw, {
      $x : "Nat" tack.r lambda y : "Bool" . x : "Bool" -> "Nat"$
    })
    rule-label("k-mid", [(abs)])

    judgment-node((3.5, ty), "k-top", nw, {
      $tack.r lambda x : "Nat" . lambda y : "Bool" . x : "Nat" -> "Bool" -> "Nat"$
    })
    rule-label("k-top", [(abs)])

    vert-edge("k-top", "k-mid")
    vert-edge("k-mid", "k-prem")
  }),
  caption: [
    Дерево вывода типа для комбинатора $K$ (проекция на первый аргумент) с типами $"Nat"$ и $"Bool"$.
    Три шага: аксиома var, затем два применения правила abs.
    Вывод снова линеен --- каждое правило имеет ровно одну посылочную ветвь.
  ],
)

// M18 diagrams — Type Theory: typing derivation trees.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

// ── Colours ──
#let c-judgment = oklch(50%, 0.04, 260deg)
#let c-rule = oklch(55%, 0.14, 260deg)
#let c-line = oklch(35%, 0.02, 265deg)

// ── Helpers ──

// Judgment node: rounded rect with fixed width.
// Width is generous to fit all judgments in these derivations.
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

// Rule label anchored west (left edge at position, text goes right).
#let rule-label(pos, body) = {
  draw.content(
    pos,
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
// A tree with one branch: conclusion above one premise.
// Linear because each typing rule in λ→ has at most one subderivation.
// ═══════════════════════════════════════════════════════════════════
#let derivation-id = figure(
  canvas({
    import draw: *

    let nw = 3.3 // half-width of judgment rects
    let lx = 4.0 // x position for rule labels (anchor=west)

    let by = 1.0 // bottom row
    let ty = 3.0 // top row

    judgment-node((3.0, by), "prem", nw, {
      $x : "Nat" tack.r x : "Nat"$
    })
    rule-label((lx, by), [(var)])

    judgment-node((3.0, ty), "conc", nw, {
      $tack.r lambda x : "Nat" . x : "Nat" -> "Nat"$
    })
    rule-label((lx, ty), [(abs)])

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

    let nw = 4.0 // wider for longer judgments
    let lx = 5.0

    let by = 0.8 // bottom: var
    let my = 2.6 // middle: abs on y
    let ty = 4.4 // top: abs on x

    judgment-node((4.0, by), "k-prem", nw, {
      $x : "Nat", y : "Bool" tack.r x : "Nat"$
    })
    rule-label((lx, by), [(var)])

    judgment-node((4.0, my), "k-mid", nw, {
      $x : "Nat" tack.r lambda y : "Bool" . x : "Bool" -> "Nat"$
    })
    rule-label((lx, my), [(abs)])

    judgment-node((4.0, ty), "k-top", nw, {
      $tack.r lambda x : "Nat" . lambda y : "Bool" . x : "Nat" -> "Bool" -> "Nat"$
    })
    rule-label((lx, ty), [(abs)])

    vert-edge("k-top", "k-mid")
    vert-edge("k-mid", "k-prem")
  }),
  caption: [
    Дерево вывода типа для комбинатора $K$ (проекция на первый аргумент) с типами $"Nat"$ и $"Bool"$.
    Три шага: аксиома var, затем два применения правила abs.
    Вывод снова линеен --- каждое правило имеет ровно одну посылочную ветвь.
  ],
)

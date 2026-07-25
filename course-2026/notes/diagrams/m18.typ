// M18 diagrams — Type Theory: typing derivation trees.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

// ── Colours ──
#let c-judgment = oklch(50%, 0.04, 260deg)
#let c-rule = oklch(55%, 0.14, 260deg)
#let c-line = oklch(35%, 0.02, 265deg)

// ── Helper: judgment node with automatic width ──
// Draws a rounded rect around the content, returns the node.
// Content determines width; height is fixed.
#let judgment-node(pos, name, body) = {
  let (x, y) = pos
  // Estimate width: ~0.47em per character in math, plus padding
  // We use a generous estimate and let CeTZ clip if needed
  let est-w = 3.0 // default width for most judgments
  draw.rect(
    (x - est-w, y + 0.35),
    (x + est-w, y - 0.35),
    name: name,
    fill: oklch(97%, 0.01, 260deg),
    stroke: 0.7pt + c-judgment,
    radius: 4pt,
  )
  draw.content(name, text(size: 0.65em, fill: c-judgment)[#body])
}

// ── Helper: rule label to the RIGHT of a node ──
#let rule-label(pos, name, text-body) = {
  draw.content(
    pos,
    name: name,
    anchor: "west",
    text(size: 0.55em, fill: c-rule, weight: "semibold")[#text-body],
  )
}

// ── Helper: vertical edge (parent → child) ──
// Uses CeTZ compass anchors: parent.south → child.north
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
// This derivation is a TREE with one branch (two levels):
// the conclusion (top) follows from a single premise (bottom).
// Many typing derivations are linear like this — each rule has
// at most one premise that requires further proof.
// ═══════════════════════════════════════════════════════════════════
#let derivation-id = figure(
  canvas({
    import draw: *

    // Vertical spacing: compact, 2cm between levels
    let by = 1.0 // bottom row y
    let ty = 3.0 // top row y

    // Bottom: premise — x:Nat ⊢ x : Nat  [var]
    judgment-node((2.5, by), "prem", {
      $x : "Nat" tack.r x : "Nat"$
    })
    rule-label((5.6, by), "rl1", [(var)])

    // Top: conclusion — ⊢ λx:Nat. x : Nat → Nat  [abs]
    judgment-node((2.5, ty), "conc", {
      $tack.r lambda x : "Nat" . x : "Nat" -> "Nat"$
    })
    rule-label((5.6, ty), "rl2", [(abs)])

    // Vertical edge
    vert-edge("conc", "prem")
  }),
  caption: [
    Дерево вывода типа для тождественной функции.
    Вывод состоит из двух уровней: нижний --- аксиома var, верхний --- применение правила abs.
    Поскольку у правила abs ровно одна посылка, дерево вырождается в линию --- это нормально для типовых выводов в $lambda ->$.
  ],
)

// ═══════════════════════════════════════════════════════════════════
// Derivation of K combinator: ⊢ λx:Nat. λy:Bool. x : Nat → Bool → Nat
//
// Three levels: var (bottom), abs on y (middle), abs on x (top).
// Again linear — each step has exactly one subderivation.
// ═══════════════════════════════════════════════════════════════════
#let derivation-k = figure(
  canvas({
    import draw: *

    // Vertical spacing: compact, 1.8cm between levels
    let by = 0.8 // bottom: var
    let my = 2.6 // middle: abs on y
    let ty = 4.4 // top: abs on x

    // Bottom: x:Nat, y:Bool ⊢ x : Nat  [var]
    judgment-node((2.5, by), "k-prem", {
      $x : "Nat", y : "Bool" tack.r x : "Nat"$
    })
    rule-label((5.6, by), "kr1", [(var)])

    // Middle: x:Nat ⊢ λy:Bool. x : Bool → Nat  [abs]
    judgment-node((2.5, my), "k-mid", {
      $x : "Nat" tack.r lambda y : "Bool" . x : "Bool" -> "Nat"$
    })
    rule-label((5.6, my), "kr2", [(abs)])

    // Top: ⊢ λx:Nat. λy:Bool. x : Nat → Bool → Nat  [abs]
    judgment-node((2.5, ty), "k-top", {
      $tack.r lambda x : "Nat" . lambda y : "Bool" . x : "Nat" -> "Bool" -> "Nat"$
    })
    rule-label((5.6, ty), "kr3", [(abs)])

    // Vertical edges
    vert-edge("k-top", "k-mid")
    vert-edge("k-mid", "k-prem")
  }),
  caption: [
    Дерево вывода типа для комбинатора $K$ (проекция на первый аргумент) с типами $"Nat"$ и $"Bool"$.
    Три шага: аксиома var, два применения правила abs.
    Вывод снова линеен --- каждое правило имеет ровно одну посылочную ветвь.
  ],
)

// M18 diagrams — Type Theory: typing derivation trees.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

// ── Colours ──
#let c-judgment = oklch(50%, 0.04, 260deg)
#let c-rule = oklch(55%, 0.14, 260deg)
#let c-line = oklch(35%, 0.02, 265deg)
#let c-context = oklch(40%, 0.01, 265deg)

// ── Helper: typing judgment node ──
// Draws a rounded rect with the judgment text inside.
#let judgment-node(pos, body) = {
  let (x, y) = pos
  let w = 2.6
  draw.rect(
    (x - w, y + 0.35),
    (x + w, y - 0.35),
    fill: oklch(97%, 0.01, 260deg),
    stroke: 0.7pt + c-judgment,
    radius: 4pt,
  )
  draw.content(
    pos,
    text(size: 0.65em, fill: c-judgment)[#body],
  )
}

// ── Helper: rule name label ──
#let rule-label(pos, text-body) = {
  draw.content(
    pos,
    text(size: 0.55em, fill: c-rule, weight: "semibold")[#text-body],
  )
}

// ── Helper: vertical line connecting parent to child ──
#let vert-edge(top-pos, bottom-pos) = {
  let (tx, ty) = top-pos
  let (bx, by) = bottom-pos
  draw.line(
    (tx, ty - 0.35),
    (bx, by + 0.35),
    stroke: 0.6pt + c-line,
  )
}

// ═══════════════════════════════════════════════════════════════════
// Typing derivation: λx:Nat. x  :  Nat -> Nat
// ═══════════════════════════════════════════════════════════════════
#let derivation-id = figure(
  canvas({
    import draw: *

    // Tree structure:
    //   ⊢ λx:Nat. x : Nat -> Nat          (top row, y=3.8)
    //          |
    //   x:Nat ⊢ x : Nat                  (bottom row, y=1.6)

    // Bottom: premise [(var)]
    let by = 1.1
    judgment-node((3.75, by), {
      $x : "Nat" ⊢ x : "Nat"$
    })

    // Rule label for the premise
    rule-label((6.4, by), {
      [(var)]
    })

    // Top: conclusion [(abs)]
    let ty = 3.5
    judgment-node((3.75, ty), {
      $dots.c ⊢ lambda x : "Nat" . x : "Nat" -> "Nat"$
    })

    // Rule label for the top
    rule-label((5.2, ty), {
      [(abs)]
    })

    // Vertical edge
    vert-edge((3.75, ty), (3.75, by))
  }),
  caption: [
    Дерево вывода типа для $lambda x : "Nat" . x : "Nat" arrow.r "Nat"$.
    Единственная посылка --- аксиома var.
    Вывод состоит из двух шагов.
  ],
)

// ═══════════════════════════════════════════════════════════════════
// Typing derivation: λx:Nat. λy:Bool. x  :  Nat -> Bool -> Nat
// ═══════════════════════════════════════════════════════════════════
#let derivation-k = figure(
  canvas({
    import draw: *

    // Tree structure:
    //   ⊢ λx:Nat. λy:Bool. x : Nat -> Bool -> Nat    (top, y=5.6)
    //          |
    //   x:Nat ⊢ λy:Bool. x : Bool -> Nat            (middle, y=3.4)
    //          |
    //   x:Nat, y:Bool ⊢ x : Nat                    (bottom, y=1.2)

    // Bottom: premise [(var)]
    let by = 1.1
    judgment-node((4.25, by), {
      $x : "Nat", y : "Bool" ⊢ x : "Nat"$
    })
    rule-label((7.3, by), {
      [(var)]
    })

    // Middle: [(abs)] on y
    let my = 3.1
    judgment-node((4.25, my), {
      $x : "Nat" ⊢ lambda y : "Bool" . x : "Bool" -> "Nat"$
    })
    rule-label((6.2, my), {
      [(abs)]
    })

    // Top: [(abs)] on x
    let ty = 5.1
    judgment-node((4.25, ty), {
      $dots.c ⊢ lambda x : "Nat" . lambda y : "Bool" . x : "Nat" -> "Bool" -> "Nat"$
    })
    rule-label((6.2, ty), {
      [(abs)]
    })

    // Vertical edges
    vert-edge((4.25, ty), (4.25, my))
    vert-edge((4.25, my), (4.25, by))
  }),
  caption: [
    Дерево вывода типа для комбинатора $K$ с типами $"Nat"$ и $"Bool"$:
    $lambda x : "Nat" . lambda y : "Bool" . x : "Nat" arrow.r "Bool" arrow.r "Nat"$.
    Три шага: одна аксиома var и два применения правила abs.
  ],
)

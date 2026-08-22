// M02 diagrams: Venn diagrams for set operations (used by m04),
// natural deduction tree and sequent calculus trees (used by m02).
// Proof trees are typeset with the `curryst` package: premises above
// a horizontal bar, conclusion below, rule name on the right of the bar.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw
#import "@preview/curryst:0.6.0": rule, prooftree

// ── Venn diagrams (m04) ──

#let ca = oklch(72%, 0.1, 250deg).transparentize(55%)
#let cb = oklch(72%, 0.1, 25deg).transparentize(55%)
#let c-str = oklch(35%, 0.02, 265deg) + 0.7pt
#let r = 0.85

#let label(pos, body) = draw.content(pos, text(size: 0.85em)[#body])

// ── Union: A ∪ B ──
#let venn-union = canvas({
  draw.circle((-0.35, 0), radius: r, fill: ca, stroke: c-str)
  draw.circle((0.35, 0), radius: r, fill: cb, stroke: c-str)
  label((-r - 0.1, 0), $A$)
  label((r + 0.1, 0), $B$)
  label((0, r + 0.5), $A union B$)
})

// ── Intersection: A ∩ B ──
// Two CLOSE-mode arcs forming the lens.
// Right arc: clockwise from top to bottom through the right side (part of circle A).
// Left arc:  clockwise from bottom to top through the left side (part of circle B).
#let venn-intersection = canvas({
  let ym = calc.sqrt(r * r - 0.35 * 0.35)
  let a-top = calc.atan2(0.35, ym)
  let a-bot = calc.atan2(0.35, -ym)
  let b-top = calc.atan2(-0.35, ym)
  let b-bot = calc.atan2(-0.35, -ym) + 360deg

  draw.arc(
    (0, ym),
    start: a-top,
    stop: a-bot,
    radius: r,
    mode: "CLOSE",
    fill: ca,
    stroke: none,
  )
  draw.arc(
    (0, -ym),
    start: b-bot,
    stop: b-top,
    radius: r,
    mode: "CLOSE",
    fill: ca,
    stroke: none,
  )
  draw.circle((-0.35, 0), radius: r, fill: none, stroke: c-str)
  draw.circle((0.35, 0), radius: r, fill: none, stroke: c-str)
  label((-r - 0.1, 0), $A$)
  label((r + 0.1, 0), $B$)
  label((0, r + 0.5), $A inter B$)
})

// ── Difference: A \ B ──
#let venn-difference = canvas({
  // A fill only (behind)
  draw.circle((-0.35, 0), radius: r, fill: ca, stroke: none)
  // B with white fill to "cut out" the overlap
  draw.circle((0.35, 0), radius: r, fill: white, stroke: c-str)
  // A stroke restored on top
  draw.circle((-0.35, 0), radius: r, fill: none, stroke: c-str)
  label((-r - 0.1, 0), $A$)
  label((r + 0.1, 0), $B$)
  label((0, r + 0.5), $A setminus B$)
})

// ── Subset: A ⊂ B ──
#let venn-subset = canvas({
  // B is an oval
  draw.circle((0, 0), radius: (1.2, r + 0.05), fill: cb, stroke: c-str)
  label((0.8, 0), $B$)
  // A is a smaller circle inside B, offset to the left
  draw.circle((-0.35, 0), radius: 0.6, fill: ca, stroke: c-str)
  label((-0.35, 0), $A$)
  label((0, r + 0.5), $A subset B$)
})

// ── Proof trees (m02), typeset with curryst ──
// Правило: rule(name: ..., премисы..., заключение); prooftree раскладывает.

// ── Дерево натурального вывода: проекция A∧B → A ──
#let nd-tree-projection = prooftree(
  rule(
    name: [$->$I],
    rule(
      name: [$and$E],
      $A and B$,
      $A$,
    ),
    $A and B -> A$,
  ),
)

// ── Дерево секвенций: ⊢ A ∨ ¬A (классический вывод) ──
#let seq-tree-lem = prooftree(
  rule(
    name: [контракция],
    rule(
      name: [$or R_1$],
      rule(
        name: [$or R_2$],
        rule(
          name: [$not$R],
          $A proves A$,
          $proves not A, A$,
        ),
        $proves not A, A or not A$,
      ),
      $proves A or not A, A or not A$,
    ),
    $proves A or not A$,
  ),
)

// ── Ветвящееся дерево секвенций: A ∨ B ⊢ B ∨ A ──
// Правило ∨L имеет две посылки: дерево раздваивается.
#let seq-tree-comm = prooftree(
  rule(
    name: [$or$L],
    rule(
      name: [$or R_2$],
      $A proves A$,
      $A proves B or A$,
    ),
    rule(
      name: [$or R_1$],
      $B proves B$,
      $B proves B or A$,
    ),
    $A or B proves B or A$,
  ),
)

// ── Дерево опровержения резолюцией: транзитивность импликации ──
// Листья --- клаузы, каждый узел --- шаг резолюции, корень --- пустой дизъюнкт.
#let res-tree-trans = prooftree(
  rule(
    name: [резолюция по $R$],
    rule(
      name: [резолюция по $Q$],
      rule(
        name: [резолюция по $P$],
        $not P or Q$,
        $P$,
        $Q$,
      ),
      $not Q or R$,
      $R$,
    ),
    $not R$,
    $square$,
  ),
)

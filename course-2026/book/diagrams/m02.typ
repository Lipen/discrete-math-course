// M02 diagrams: Venn diagrams for set operations (used by m04),
// natural deduction tree and sequent calculus tree (used by m02).
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

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

// ── Natural deduction and sequent trees (m02) ──

#let n-stroke = 0.6pt + luma(70%)
#let e-stroke = (paint: oklch(35%, 0.02, 265deg), thickness: 0.8pt)
#let c-hyp = oklch(92%, 0.02, 155deg)      // гипотеза: холодный фон
#let c-rule = oklch(92%, 0.04, 45deg)      // правило/промежуточный: тёплый фон
#let c-concl = oklch(92%, 0.06, 230deg)    // заключение: синеватый фон

// ── Дерево натурального вывода: проекция A∧B → A ──
// Поток сверху вниз: гипотезы → заключение (как resolution-dag в m01).
#let nd-tree-projection = {
  let hyp(pos, label, ..args) = node(
    pos,
    label,
    fill: c-hyp,
    width: auto,
    height: 1.1em,
    ..args,
  )
  let mid(pos, label, ..args) = node(
    pos,
    label,
    fill: c-rule,
    width: auto,
    height: 1.1em,
    ..args,
  )
  let concl(pos, label, ..args) = node(
    pos,
    label,
    fill: c-concl,
    width: auto,
    height: 1.1em,
    ..args,
  )
  let nde(to, from) = edge(to, from, "-", stroke: e-stroke)

  diagram(
    node-shape: "rect",
    node-stroke: n-stroke,
    node-inset: 4pt,
    node-outset: 4pt,
    spacing: 1.6em,

    hyp((0, 0), $A and B$, name: <h>),
    mid((0, 1.4), $A$, name: <a>),
    concl((0, 2.8), $A and B -> A$, name: <c>),

    nde(<h>, <a>),
    nde(<a>, <c>),

    edge(<h>, <a>, "-", stroke: none, label: [$and$E], label-size: 0.7em),
    edge(<a>, <c>, "-", stroke: none, label: [$->$I], label-size: 0.7em),
  )
}

// ── Дерево секвенций: ⊢ A ∨ ¬A (классический вывод) ──
// Аксиома наверху, заключение внизу; на каждом ребре --- правило.
#let seq-tree-lem = {
  let sn(pos, label, ..args) = node(
    pos,
    label,
    fill: c-hyp,
    width: auto,
    height: 1.0em,
    ..args,
  )
  let e(to, from) = edge(to, from, "-", stroke: e-stroke)

  diagram(
    node-shape: "rect",
    node-stroke: n-stroke,
    node-inset: 5pt,
    node-outset: 4pt,
    spacing: 1.6em,

    sn((0, 0), $A proves A$, name: <s1>),
    sn((0, 1.3), $proves not A, A$, name: <s2>),
    sn((0, 2.6), $proves not A, A or not A$, name: <s3>),
    sn((0, 3.9), $proves A or not A, A or not A$, name: <s4>),
    sn((0, 5.2), $proves A or not A$, name: <s5>),

    e(<s1>, <s2>),
    e(<s2>, <s3>),
    e(<s3>, <s4>),
    e(<s4>, <s5>),

    edge(<s1>, <s2>, "-", stroke: none, label: [$not$R], label-size: 0.7em),
    edge(<s2>, <s3>, "-", stroke: none, label: [$or R_2$], label-size: 0.7em),
    edge(<s3>, <s4>, "-", stroke: none, label: [$or R_1$], label-size: 0.7em),
    edge(<s4>, <s5>, "-", stroke: none, label: [контракция], label-size: 0.65em),
  )
}

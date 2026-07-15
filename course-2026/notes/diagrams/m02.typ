// M02 diagrams — Venn diagrams for set operations.
#import "@preview/cetz:0.5.2": canvas, draw
#import "../notation.typ": setminus

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
// Lens shape built from two polyline halves (right arc of A, left arc of B).
#let venn-intersection = canvas({
  let n = 30
  let y-max = calc.sqrt(r * r - 0.35 * 0.35)
  // Right arc of A: for y from -y-max to +y-max
  let right-arc = range(-n, n + 1).map(i => {
    let y = y-max * i / n
    let x = -0.35 + calc.sqrt(r * r - y * y)
    (x, y)
  })
  // Left arc of B: for y from +y-max down to -y-max
  let left-arc = range(-n, n + 1).rev().map(i => {
    let y = y-max * i / n
    let x = 0.35 - calc.sqrt(r * r - y * y)
    (x, y)
  })
  // Draw filled lens polygon
  draw.line(..right-arc, ..left-arc, close: true, fill: ca, stroke: none)
  // A and B outlines
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

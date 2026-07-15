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
  import draw: *
  circle((-0.35, 0), radius: r, fill: ca, stroke: c-str)
  circle((0.35, 0), radius: r, fill: cb, stroke: c-str)
  label((-r - 0.1, 0), $A$)
  label((r + 0.1, 0), $B$)
  label((0, r + 0.5), $A union B$)
})

// ── Intersection: A ∩ B ──
#let venn-intersection = canvas({
  import draw: *
  circle((-0.35, 0), radius: r, fill: ca, stroke: c-str)
  circle((0.35, 0), radius: r, fill: cb, stroke: c-str)
  label((-r - 0.1, 0), $A$)
  label((r + 0.1, 0), $B$)
  label((0, r + 0.5), $A inter B$)
})

// ── Difference: A \ B ──
#let venn-difference = canvas({
  import draw: *
  circle((-0.35, 0), radius: r, fill: ca, stroke: c-str)
  circle((0.35, 0), radius: r, fill: none, stroke: c-str)
  label((-r - 0.1, 0), $A$)
  label((r + 0.1, 0), $B$)
  label((0, r + 0.5), $A setminus B$)
})

// ── Subset: A ⊂ B ──
#let venn-subset = canvas({
  import draw: *
  circle((0, 0), radius: 1.15, fill: cb, stroke: c-str)
  circle((0, 0), radius: r, fill: ca, stroke: c-str)
  label((0, 0.3), $A$)
  label((0, -0.7), $B$)
  label((0, 1.35), $A subset B$)
})

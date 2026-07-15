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
// Only the overlap lens is filled (approximated by a centered ellipse).
// A and B are drawn as outlines only.
#let venn-intersection = canvas({
  import draw: *
  // Overlap highlight (ellipse centered between the two circles)
  circle((0, 0), radius: (0.45, 0.7), fill: ca, stroke: none)
  // A and B outlines
  circle((-0.35, 0), radius: r, fill: none, stroke: c-str)
  circle((0.35, 0), radius: r, fill: none, stroke: c-str)
  label((-r - 0.1, 0), $A$)
  label((r + 0.1, 0), $B$)
  label((0, r + 0.5), $A inter B$)
})

// ── Difference: A \ B ──
// A fill (behind), then B with white fill to erase the overlap,
// then A stroke-only (on top) to restore the A outline.
#let venn-difference = canvas({
  import draw: *
  // A fill only (behind)
  circle((-0.35, 0), radius: r, fill: ca, stroke: none)
  // B with white fill to "cut out" the overlap, plus B stroke
  circle((0.35, 0), radius: r, fill: white, stroke: c-str)
  // A stroke restored on top
  circle((-0.35, 0), radius: r, fill: none, stroke: c-str)
  label((-r - 0.1, 0), $A$)
  label((r + 0.1, 0), $B$)
  label((0, r + 0.5), $A setminus B$)
})

// ── Subset: A ⊂ B ──
#let venn-subset = canvas({
  import draw: *
  // B is an oval
  circle((0, 0), radius: (1.2, r + 0.05), fill: cb, stroke: c-str)
  label((0.8, 0), $B$)
  // A is a smaller circle inside B, offset to the left
  circle((-0.35, 0), radius: 0.6, fill: ca, stroke: c-str)
  label((-0.35, 0), $A$)
  label((0, r + 0.5), $A subset B$)
})

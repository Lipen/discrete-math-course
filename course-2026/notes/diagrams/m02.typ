// M02 diagrams — Venn diagrams for set operations.
#import "@preview/cetz:0.5.2": canvas, draw
#import "../notation.typ": setminus

#let c-a = oklch(80%, 0.08, 250deg)
#let c-b = oklch(80%, 0.08, 25deg)
#let c-stroke = oklch(35%, 0.02, 265deg) + 0.7pt
#let c-text = oklch(35%, 0.02, 265deg)
#let r = 0.9

// ── Helper ──
#let label(pos, body) = draw.content(pos, text(size: 0.9em, fill: c-text, body))

// ── Subset: A ⊂ B ──
#let venn-subset = canvas({
  import draw: *
  circle((0, 0), radius: 1.2, fill: c-b, stroke: c-stroke)
  circle((0, 0), radius: r, fill: c-a, stroke: c-stroke)
  label((0, 0.45), $A$)
  label((0, -0.85), $B$)
})

// ── Union: A ∪ B ──
#let venn-union = canvas({
  import draw: *
  circle((-0.4, 0), radius: r, fill: c-a, stroke: c-stroke)
  circle((0.4, 0), radius: r, fill: c-b, stroke: c-stroke)
  label((-0.7, 0), $A$)
  label((0.7, 0), $B$)
  label((0, -1.3), $A union B$)
})

// ── Intersection: A ∩ B ──
#let venn-intersection = canvas({
  import draw: *
  circle((-0.4, 0), radius: r, fill: c-a, stroke: c-stroke)
  circle((0.4, 0), radius: r, fill: c-b, stroke: c-stroke)
  label((-0.7, 0), $A$)
  label((0.7, 0), $B$)
  label((0, -1.3), $A inter B$)
})

// ── All four Venn diagrams in a 2×2 grid ──
#let venn-all = canvas({
  import draw: *
  let dx = 3.5
  let dy = 3.2
  // Top-left: union
  circle((-0.4 - dx, 0 - dy), radius: r, fill: c-a, stroke: c-stroke)
  circle((0.4 - dx, 0 - dy), radius: r, fill: c-b, stroke: c-stroke)
  label((-0.7 - dx, 0 - dy), $A$)
  label((0.7 - dx, 0 - dy), $B$)
  label((0 - dx, -1.3 - dy), $A union B$)
  // Top-right: intersection
  circle((-0.4 + dx, 0 - dy), radius: r, fill: c-a, stroke: c-stroke)
  circle((0.4 + dx, 0 - dy), radius: r, fill: c-b, stroke: c-stroke)
  label((-0.7 + dx, 0 - dy), $A$)
  label((0.7 + dx, 0 - dy), $B$)
  label((0 + dx, -1.3 - dy), $A inter B$)
  // Bottom-left: difference
  circle((0.4 - dx, 0 + dy), radius: r, fill: none, stroke: c-stroke)
  circle((-0.4 - dx, 0 + dy), radius: r, fill: c-a, stroke: c-stroke)
  label((-0.7 - dx, 0 + dy), $A$)
  label((0.7 - dx, 0 + dy), $B$)
  label((0 - dx, -1.3 + dy), $A setminus B$)
  // Bottom-right: subset
  circle((0 + dx, 0 + dy), radius: 1.2, fill: c-b, stroke: c-stroke)
  circle((0 + dx, 0 + dy), radius: r, fill: c-a, stroke: c-stroke)
  label((0 + dx, 0.45 + dy), $A$)
  label((0 + dx, -0.85 + dy), $B$)
  label((0 + dx, -1.3 + dy), $A subset B$)
})

// ── Difference: A \ B ──
#let venn-difference = canvas({
  import draw: *
  // Draw B first (behind), then A (on top) — the overlap shows A's fill
  circle((0.4, 0), radius: r, fill: none, stroke: c-stroke)
  circle((-0.4, 0), radius: r, fill: c-a, stroke: c-stroke)
  label((-0.7, 0), $A$)
  label((0.7, 0), $B$)
  label((0, -1.3), $A setminus B$)
})

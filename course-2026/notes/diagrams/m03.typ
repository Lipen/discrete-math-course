// M03 diagrams — relation digraphs.
#import "@preview/cetz:0.5.2": canvas, draw

#let c-node = oklch(88%, 0.03, 250deg)
#let c-str = oklch(35%, 0.02, 265deg) + 0.7pt
#let c-fg = oklch(35%, 0.02, 265deg)

#let v(pos, label, ..args) = draw.circle(pos, radius: 0.3, fill: c-node, stroke: c-str, name: label, ..args)
#let vlbl(pos, body) = draw.content(pos, text(size: 0.8em, body))

// ── Digraph of R = {(1,1),(1,2),(2,3),(3,1)} on A = {1,2,3} ──
#let rel-digraph = canvas({
  // Vertices
  v((0, 1.5), "1")
  vlbl((0, 1.5), $1$)
  v((-1.3, -0.5), "2")
  vlbl((-1.3, -0.5), $2$)
  v((1.3, -0.5), "3")
  vlbl((1.3, -0.5), $3$)

  // Loop on 1 — small arc above the vertex
  draw.arc((0.22, 1.78), start: 120deg, stop: 60deg, radius: 0.16,
    stroke: c-str, mark: (end: (symbol: ">", fill: c-fg)))

  // 1 → 2 (curved left)
  draw.line("1", "2", stroke: c-str, mark: (end: (symbol: ">", fill: c-fg)))

  // 2 → 3
  draw.line("2", "3", stroke: c-str, mark: (end: (symbol: ">", fill: c-fg)))

  // 3 → 1 (curved right)
  draw.line("3", "1", stroke: c-str, mark: (end: (symbol: ">", fill: c-fg)))
})

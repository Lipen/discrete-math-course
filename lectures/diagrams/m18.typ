// Combinatorics: decision tree of choices, Catalan lattice paths.
#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/fletcher:0.5.8": diagram, edge, node

// ── Palette ──
#let n-fill = oklch(88%, 0.03, 250deg)
#let n-str = 0.6pt + oklch(60%, 0.08, 250deg)
#let e-str = 0.6pt + oklch(35%, 0.02, 265deg)
#let grid-line = oklch(85%, 0.02, 265deg)
#let diag-line = oklch(45%, 0.12, 260deg)
#let path-colors = (
  oklch(55%, 0.16, 260deg),
  oklch(55%, 0.14, 150deg),
  oklch(55%, 0.16, 25deg),
  oklch(58%, 0.14, 85deg),
  oklch(52%, 0.15, 320deg),
)

// ── Decision tree: permutations of {A, B, C} ──
#let decision-tree = diagram(
  node-shape: "circle",
  node-stroke: n-str,
  node-inset: 0pt,
  node-outset: 0pt,
  spacing: 1.1em,
  node((0, 0), text(size: 0.55em)[старт], fill: n-fill, name: <root>),
  node((-1.5, 1), $A$, fill: n-fill, name: <a>),
  node((0, 1), $B$, fill: n-fill, name: <b>),
  node((1.5, 1), $C$, fill: n-fill, name: <c>),
  node((-2, 2), $A B$, fill: white, stroke: none, name: <ab>),
  node((-1, 2), $A C$, fill: white, stroke: none, name: <ac>),
  node((-0.5, 2), $B A$, fill: white, stroke: none, name: <ba>),
  node((0.5, 2), $B C$, fill: white, stroke: none, name: <bc>),
  node((1, 2), $C A$, fill: white, stroke: none, name: <ca>),
  node((2, 2), $C B$, fill: white, stroke: none, name: <cb>),
  edge(<root>, <a>, "-", stroke: e-str),
  edge(<root>, <b>, "-", stroke: e-str),
  edge(<root>, <c>, "-", stroke: e-str),
  edge(<a>, <ab>, "-", stroke: e-str),
  edge(<a>, <ac>, "-", stroke: e-str),
  edge(<b>, <ba>, "-", stroke: e-str),
  edge(<b>, <bc>, "-", stroke: e-str),
  edge(<c>, <ca>, "-", stroke: e-str),
  edge(<c>, <cb>, "-", stroke: e-str),
)

// ── Catalan lattice: monotone paths below the diagonal, n = 3 ──
#let catalan-lattice = canvas({
  let n = 3

  for i in range(n + 1) {
    draw.line((i, 0), (i, n), stroke: (paint: grid-line, thickness: 0.4pt))
    draw.line((0, i), (n, i), stroke: (paint: grid-line, thickness: 0.4pt))
  }

  draw.line(
    (0, 0),
    (n, n),
    stroke: (paint: diag-line, thickness: 0.8pt, dash: "dashed"),
    name: "diagonal",
  )
  draw.content((0.42, 1.28), anchor: "south-west", text(
    size: 0.42em,
    fill: diag-line,
  )[$y = x$])

  let paths = (
    ((0, 0), (1, 0), (2, 0), (3, 0), (3, 1), (3, 2), (3, 3)),
    ((0, 0), (1, 0), (2, 0), (2, 1), (3, 1), (3, 2), (3, 3)),
    ((0, 0), (1, 0), (2, 0), (2, 1), (2, 2), (3, 2), (3, 3)),
    ((0, 0), (1, 0), (1, 1), (2, 1), (3, 1), (3, 2), (3, 3)),
    ((0, 0), (1, 0), (1, 1), (2, 1), (2, 2), (3, 2), (3, 3)),
  )
  for (color, path) in path-colors.zip(paths) {
    draw.line(..path, stroke: (paint: color, thickness: 1.2pt))
  }

  draw.circle(
    (0, 0),
    radius: 0.06,
    fill: diag-line,
    stroke: none,
    name: "start",
  )
  draw.circle((n, n), radius: 0.06, fill: diag-line, stroke: none, name: "end")
  draw.content((0, 0), anchor: "north-east", text(
    size: 0.42em,
    fill: diag-line,
  )[$(0, 0)$])
  draw.content((n, n), anchor: "west", text(
    size: 0.42em,
    fill: diag-line,
  )[$(n, n)$])
})

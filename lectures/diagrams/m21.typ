// Combinatorics: decision tree of choices, Catalan lattice paths.
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

// сетка фона: светлее любого штрихового токена style.typ
#let grid-line = oklch(85%, 0.02, 265deg)

// ── Decision tree: permutations of {A, B, C} ──
#let decision-tree = canvas({
  // корень --- единственный акцент: выбор начинается здесь
  draw.circle((0, 2.2), radius: 0.5, fill: cool, stroke: none, name: "root")
  mark((0, 2.2), text(weight: "bold", fill: white)[старт])

  let branches = (("a", -2.6, [$A$]), ("b", 0, [$B$]), ("c", 2.6, [$C$]))
  for (nm, x, letter) in branches {
    vertex(nm, (x, 1.25), size: 0.3)
    mark((x, 1.25), text[#letter])
  }

  let leaves = (
    ("ab", -3.25, [$A B$]),
    ("ac", -1.95, [$A C$]),
    ("ba", -0.65, [$B A$]),
    ("bc", 0.65, [$B C$]),
    ("ca", 1.95, [$C A$]),
    ("cb", 3.25, [$C B$]),
  )
  for (nm, x, perm) in leaves {
    cell(nm, (x, 0.05), size: 0.5, radius: 0.12)
    mark((x, 0.05), text[#perm])
  }

  for (nm, ..) in branches {
    draw.line("root", nm, stroke: edge-plain)
  }
  draw.bezier("a.south", "ab.north", (-3.12, 0.72), stroke: edge-plain)
  draw.bezier("a.south", "ac.north", (-2.08, 0.72), stroke: edge-plain)
  draw.bezier("b.south", "ba.north", (-0.5, 0.72), stroke: edge-plain)
  draw.bezier("b.south", "bc.north", (0.5, 0.72), stroke: edge-plain)
  draw.bezier("c.south", "ca.north", (2.08, 0.72), stroke: edge-plain)
  draw.bezier("c.south", "cb.north", (3.12, 0.72), stroke: edge-plain)
})

// ── Catalan lattice: monotone paths below the diagonal, n = 3 ──
#let catalan-lattice = canvas({
  let n = 3
  // мягкая запретная зона над диагональю
  let forbidden = warm.transparentize(91%)

  draw.line((0, 0), (0, n), (n, n), close: true, fill: forbidden, stroke: none)

  for i in range(n + 1) {
    draw.line((i, 0), (i, n), stroke: (paint: grid-line, thickness: 0.4pt))
    draw.line((0, i), (n, i), stroke: (paint: grid-line, thickness: 0.4pt))
  }

  draw.line((0, 0), (n, n), stroke: edge-soft, name: "diagonal")
  mark((0.78, 1.45), $y = x$)

  let paths = (
    ((0, 0), (1, 0), (2, 0), (3, 0), (3, 1), (3, 2), (3, 3)),
    ((0, 0), (1, 0), (2, 0), (2, 1), (3, 1), (3, 2), (3, 3)),
    ((0, 0), (1, 0), (2, 0), (2, 1), (2, 2), (3, 2), (3, 3)),
    ((0, 0), (1, 0), (1, 1), (2, 1), (3, 1), (3, 2), (3, 3)),
  )
  for path in paths {
    draw.line(..path, stroke: (
      paint: ink,
      thickness: 1.1pt,
      cap: "round",
      join: "round",
    ))
  }

  // акцентный путь возвращается на диагональ в каждой точке --- он несёт рекурренту Каталана
  draw.line(
    (0, 0),
    (1, 0),
    (1, 1),
    (2, 1),
    (2, 2),
    (3, 2),
    (3, 3),
    stroke: edge-cool,
  )

  draw.circle(
    (0, 0),
    radius: 0.1,
    fill: cool.lighten(82%),
    stroke: 1.2pt + cool,
    name: "start",
  )
  draw.circle(
    (n, n),
    radius: 0.1,
    fill: cool.lighten(82%),
    stroke: 1.2pt + cool,
    name: "end",
  )
  mark((-0.52, 0.05), $(0, 0)$)
  mark((n + 0.5, n), $(n, n)$)
})

// Диаграмма лекции по логическому программированию: SLD-дерево.
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

// ── SLD-дерево: цели, ответы, тупиковая ветвь ──
#let sld-tree = canvas({
  let hw = 0.85

  let goal(name, pos, body) = {
    let (x, y) = pos
    draw.rect(
      (x - hw, y - 0.18),
      (x + hw, y + 0.18),
      radius: 0.08,
      fill: white,
      stroke: 1pt + cool,
      name: name,
    )
    mark(pos, body, size: 0.45em)
  }
  let answer(name, pos, body) = {
    let (x, y) = pos
    draw.rect(
      (x - hw, y - 0.18),
      (x + hw, y + 0.18),
      radius: 0.08,
      fill: panel-green,
      stroke: 1pt + green,
      name: name,
    )
    mark(pos, body, size: 0.45em)
  }
  let dead(name, pos) = {
    let (x, y) = pos
    draw.rect(
      (x - hw, y - 0.18),
      (x + hw, y + 0.18),
      radius: 0.08,
      fill: none,
      stroke: (paint: ink-soft, thickness: 0.7pt, dash: "dashed"),
      name: name,
    )
  }

  goal("root", (0, 0), [`ancestor(alice, Y)`])
  goal("base1", (-1.7, -0.9), [`parent(alice, Y)`])
  goal("recur1", (1.7, -0.9), [`parent(alice, Z)` \ `ancestor(Z, Y)`])
  answer("sol1", (-1.7, -1.8), [$Y = "bob"$])
  goal("anc", (1.7, -1.8), [`ancestor(bob, Y)`])
  goal("base2", (0.8, -2.7), [`parent(bob, Y)`])
  goal("recur2", (2.6, -2.7), [`parent(bob, Z')` \ `ancestor(Z', Y)`])
  answer("sol2", (0.8, -3.6), [$Y = "carol"$])
  dead("dead", (2.6, -3.6))
  mark((2.6, -3.98), [тупик], tone: ink-soft, size: 0.45em)

  draw.line("root", "base1", stroke: edge-plain)
  draw.line("root", "recur1", stroke: edge-plain)
  draw.line("base1", "sol1", stroke: edge-plain)
  draw.line("recur1", "anc", stroke: edge-plain)
  draw.line("anc", "base2", stroke: edge-plain)
  draw.line("anc", "recur2", stroke: edge-plain)
  draw.line("base2", "sol2", stroke: edge-plain)
  draw.line("recur2", "dead", stroke: edge-soft)
})

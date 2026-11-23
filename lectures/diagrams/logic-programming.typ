// Диаграмма лекции по логическому программированию: SLD-дерево.
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

// ── SLD-дерево: цели, ответы, тупиковая ветвь ──
#let sld-tree = canvas({
  // моноширинная цель шириной ~0.16 см на знак: полуширина бокса по самой длинной строке
  let hw-for(ls) = 0.085 * calc.max(..ls.map(l => l.len())) + 0.15

  let goal(name, pos, ls) = {
    let (x, y) = pos
    let hh = if ls.len() > 1 { 0.46 } else { 0.27 }
    draw.rect(
      (x - hw-for(ls), y - hh),
      (x + hw-for(ls), y + hh),
      radius: 0.08,
      fill: cool.lighten(88%),
      stroke: 1pt + cool,
      name: name,
    )
    let body = raw(ls.first())
    for l in ls.slice(1) {
      body += linebreak() + raw(l)
    }
    mark(pos, body)
  }
  let answer(name, pos, body) = {
    let (x, y) = pos
    draw.rect(
      (x - 0.85, y - 0.27),
      (x + 0.85, y + 0.27),
      radius: 0.08,
      fill: panel-green,
      stroke: 1pt + green,
      name: name,
    )
    mark(pos, body)
  }
  let dead(name, pos) = {
    let (x, y) = pos
    draw.rect(
      (x - 0.85, y - 0.27),
      (x + 0.85, y + 0.27),
      radius: 0.08,
      fill: none,
      stroke: (paint: ink-soft, thickness: 0.7pt, dash: "dashed"),
      name: name,
    )
  }

  goal("root", (0, 0), ("ancestor(alice, Y)",))
  goal("base1", (-3.5, -0.88), ("parent(alice, Y)",))
  goal("recur1", (3.5, -0.88), ("parent(alice, Z)", "ancestor(Z, Y)"))
  answer("sol1", (-3.5, -1.76), [$Y = "bob"$])
  goal("anc", (3.5, -1.76), ("ancestor(bob, Y)",))
  goal("base2", (1.55, -2.64), ("parent(bob, Y)",))
  goal("recur2", (5.45, -2.64), ("parent(bob, Z')", "ancestor(Z', Y)"))
  answer("sol2", (1.55, -3.52), [$Y = "carol"$])
  dead("dead", (5.45, -3.52))
  mark((5.45, -4.07), [тупик], tone: ink-soft)

  draw.line("root", "base1", stroke: edge-plain)
  draw.line("root", "recur1", stroke: edge-plain)
  draw.line("base1", "sol1", stroke: edge-plain)
  draw.line("recur1", "anc", stroke: edge-plain)
  draw.line("anc", "base2", stroke: edge-plain)
  draw.line("anc", "recur2", stroke: edge-plain)
  draw.line("base2", "sol2", stroke: edge-plain)
  draw.line("recur2", "dead", stroke: edge-soft)
})

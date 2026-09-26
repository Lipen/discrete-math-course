// Диаграммы лекции по матроидам: три источника, контрпример для жадного.
#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/fletcher:0.5.8": diagram, edge, node
#import "style.typ": *

// ── Три источника -> один матроид ──
#let matroid-sources = diagram(
  node-stroke: (paint: cool, thickness: 1pt),
  node-fill: white,
  node-inset: 6pt,
  spacing: 1.1em,
  {
    node((0, 0), text(size: 0.6em)[Лес \ ацикличность], name: <forest>)
    node((2.3, 0), text(size: 0.6em)[Векторы \ независимость], name: <vec>)
    node((4.6, 0), text(size: 0.6em)[Не более $k$ \ размер], name: <unif>)
    node(
      (2.3, 1.6),
      text(size: 0.6em, weight: "bold")[Матроид \ два свойства],
      name: <matroid>,
      fill: panel-green,
      stroke: (paint: green, thickness: 1.2pt),
    )
    edge(<forest>, <matroid>, "->", stroke: edge-plain)
    edge(<vec>, <matroid>, "->", stroke: edge-plain)
    edge(<unif>, <matroid>, "->", stroke: edge-plain)
  },
)

// ── Контрпример для жадного: a конфликтует с каждым из пары b, c ──
#let greedy-counterexample = canvas({
  vertex("a", (-0.9, 0.3), size: 0.36)
  vertex("b", (0.9, 0.9), size: 0.36)
  vertex("c", (0.9, -0.3), size: 0.36)
  mark((-0.9, 0.3), [$a$ \ $5$], size: 0.45em)
  mark((0.9, 0.9), [$b$ \ $4$], size: 0.45em)
  mark((0.9, -0.3), [$c$ \ $4$], size: 0.45em)

  draw.line("a", "b", stroke: edge-hot)
  draw.line("a", "c", stroke: edge-hot)
})

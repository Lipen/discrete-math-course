// SAT: граф импликаций 2-SAT --- оба дизъюнкта ведут в y.
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

#let implication-graph-2sat-simple = canvas({
  vertex("x", (0, 1.0), size: 0.34)
  vertex("notx", (0, -1.0), size: 0.34)
  vertex("y", (2.9, 1.0), tone: warm, size: 0.34)
  vertex("noty", (2.9, -1.0), tone: ink-soft, size: 0.34)

  mark((0, 1.0), $x$)
  mark((0, -1.0), $overline(x)$)
  mark((2.9, 1.0), $y$)
  mark((2.9, -1.0), $overline(y)$)

  // (not x or y): x -> y;  (x or y): not x -> y.
  draw.line("x.east", "y.west", stroke: edge-hot, mark: (end: ">"))
  draw.bezier("notx.east", "y.south", (1.4, -0.6), stroke: edge-hot, mark: (
    end: ">",
  ))

  mark((1.45, 1.38), $not x or y$)
  mark((1.42, -1.22), $x or y$)
})

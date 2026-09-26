// SAT: граф импликаций 2-SAT --- оба дизъюнкта ведут в y.
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

#let implication-graph-2sat-simple = canvas({
  vertex("x", (0, 0.8))
  vertex("notx", (0, -0.8))
  vertex("y", (2.2, 0.8), tone: warm)
  vertex("noty", (2.2, -0.8), tone: ink-soft)

  mark((0, 0.8), $x$, size: 0.7em)
  mark((0, -0.8), $overline(x)$, size: 0.7em)
  mark((2.2, 0.8), $y$, size: 0.7em)
  mark((2.2, -0.8), $overline(y)$, size: 0.7em)

  // (not x or y): x -> y;  (x or y): not x -> y.
  draw.line("x.east", "y.west", stroke: edge-hot, mark: (end: ">"))
  draw.bezier("notx.east", "y.south", (1.05, -0.5), stroke: edge-hot, mark: (
    end: ">",
  ))

  mark((1.1, 1.14), $not x or y$, size: 0.5em)
  mark((1.2, -0.75), $x or y$, size: 0.5em)
})

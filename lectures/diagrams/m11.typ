// Логические схемы: полусумматор, полный сумматор, мультиплексор 4-в-1.
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

// Единый глиф вентиля: скруглённый корпус, имя внутри.
#let gate(pos, label, w: 0.85, h: 0.5) = {
  let (x, y) = pos
  draw.rect(
    (x - w / 2, y - h / 2),
    (x + w / 2, y + h / 2),
    fill: white,
    stroke: (paint: cool, thickness: 1.1pt),
    radius: 3pt,
  )
  draw.content(pos, text(size: 0.5em, fill: ink, weight: "bold")[#label])
}

#let wire(a, b, stroke: edge-plain) = draw.line(a, b, stroke: stroke)

#let jdot(pos) = draw.circle(pos, radius: 0.035, fill: ink)

#let lab(pos, body, anchor: "east") = draw.content(
  pos,
  anchor: anchor,
  text(size: 0.45em, fill: ink)[#body],
)

// ── Полусумматор: S = A xor B, C = A and B ──
#let half-adder = canvas({
  gate((0, 0.45), "XOR")
  gate((0, -0.45), "AND")

  wire((-1.25, 0.575), (-0.425, 0.575))
  jdot((-0.75, 0.575))
  wire((-0.75, 0.575), (-0.75, -0.325))
  wire((-0.75, -0.325), (-0.425, -0.325))

  wire((-1.25, -0.575), (-0.425, -0.575))
  jdot((-0.55, -0.575))
  wire((-0.55, -0.575), (-0.55, 0.325))
  wire((-0.55, 0.325), (-0.425, 0.325))

  wire((0.425, 0.45), (0.72, 0.45), stroke: edge-hot)
  wire((0.425, -0.45), (0.7, -0.45))

  lab((-1.4, 0.575), $A$)
  lab((-1.4, -0.575), $B$)
  lab((0.85, 0.45), $S$, anchor: "west")
  lab((0.83, -0.45), $C$, anchor: "west")
})

// ── Полный сумматор: ступень суммы и ступень переноса ──
#let full-adder = canvas({
  panel((-0.9, 0.25), (1.95, 1.02), tone: cool, fill: panel-cool)
  panel((-0.9, -1.35), (2.9, -0.05), tone: warm, fill: panel-warm)

  gate((0, 0.6), "XOR", w: 0.8)
  gate((0, -0.55), "AND", w: 0.8)
  gate((1.35, 0.6), "XOR", w: 0.8)
  gate((1.35, -0.375), "AND", w: 0.8)
  gate((2.3, -0.5), "OR", w: 0.8)

  wire((-1.35, 0.675), (-0.4, 0.675))
  jdot((-0.8, 0.675))
  wire((-0.8, 0.675), (-0.8, -0.425))
  wire((-0.8, -0.425), (-0.4, -0.425))

  wire((-1.35, -0.675), (-0.4, -0.675))
  jdot((-0.55, -0.675))
  wire((-0.55, -0.675), (-0.55, 0.525))
  wire((-0.55, 0.525), (-0.4, 0.525))

  wire((0.4, 0.6), (0.675, 0.6))
  jdot((0.675, 0.6))
  wire((0.675, 0.6), (0.675, 0.7))
  wire((0.675, 0.7), (0.95, 0.7))
  wire((0.675, 0.6), (0.675, -0.25))
  wire((0.675, -0.25), (0.95, -0.25))

  wire((-1.35, -0.95), (0.5, -0.95))
  jdot((0.5, -0.95))
  wire((0.5, -0.95), (0.5, 0.5))
  jdot((0.5, -0.5))
  wire((0.5, -0.5), (0.95, -0.5))
  wire((0.5, 0.5), (0.95, 0.5))

  wire((0.4, -0.55), (0.4, -1.15))
  wire((0.4, -1.15), (1.8, -1.15))
  wire((1.8, -1.15), (1.8, -0.625))
  wire((1.8, -0.625), (1.9, -0.625))

  wire((1.75, -0.375), (1.9, -0.375))

  wire((1.75, 0.6), (2.1, 0.6), stroke: edge-hot)
  wire((2.7, -0.5), (3.05, -0.5))

  lab((-1.5, 0.675), $A$)
  lab((-1.5, -0.675), $B$)
  lab((-1.5, -0.95), $C_"in"$)
  lab((2.22, 0.6), $S$, anchor: "west")
  lab((3.17, -0.5), $C_"out"$, anchor: "west")
})

// ── Мультиплексор 4-в-1 ──
#let multiplexer-4to1 = canvas({
  draw.line(
    (0, 1.0),
    (2.1, 0.5),
    (2.1, -0.5),
    (0, -1.0),
    close: true,
    fill: panel-cool,
    stroke: (paint: cool, thickness: 1.1pt),
  )
  draw.content((1.05, 0.12), text(size: 0.5em, fill: ink, weight: "bold")[MUX])
  mark((1.05, -0.32), $4 times 1$, size: 0.45em, tone: ink-soft)

  for (i, y) in (0.75, 0.25, -0.25, -0.75).enumerate() {
    wire((-0.5, y), (0, y))
    lab((-0.62, y), $D_#i$)
  }

  wire((2.1, 0), (2.48, 0), stroke: edge-hot)
  lab((2.6, 0), $Y$, anchor: "west")

  wire((0.7, 0.833), (0.7, 1.25))
  mark((0.7, 1.44), $S_0$, size: 0.45em)
  wire((1.4, 0.667), (1.4, 1.25))
  mark((1.4, 1.44), $S_1$, size: 0.45em)

  mark((1.05, -1.38), $Y = D_((S_1 S_0)_2)$, size: 0.45em)
})

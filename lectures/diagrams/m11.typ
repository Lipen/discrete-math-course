// Логические схемы: полусумматор, полный сумматор, мультиплексор 4-в-1.
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

// Единый глиф вентиля: скруглённый корпус, имя внутри.
#let gate(pos, label, w: 1.05, h: 0.62) = {
  let (x, y) = pos
  draw.rect(
    (x - w / 2, y - h / 2),
    (x + w / 2, y + h / 2),
    fill: cool.lighten(88%),
    stroke: (paint: cool, thickness: 1.1pt),
    radius: 3pt,
  )
  draw.content(pos, text(fill: ink, weight: "bold")[#label])
}

#let wire(a, b, stroke: edge-plain) = draw.line(a, b, stroke: stroke)

#let jdot(pos) = draw.circle(pos, radius: 0.035, fill: ink)

#let lab(pos, body, anchor: "east") = draw.content(
  pos,
  anchor: anchor,
  text(fill: ink)[#body],
)

// ── Полусумматор: S = A xor B, C = A and B ──
#let half-adder = canvas({
  gate((0, 0.5), "XOR")
  gate((0, -0.55), "AND")

  wire((-1.5, 0.69), (-0.525, 0.69))
  jdot((-0.95, 0.69))
  wire((-0.95, 0.69), (-0.95, -0.36))
  wire((-0.95, -0.36), (-0.525, -0.36))

  wire((-1.5, -0.74), (-0.525, -0.74))
  jdot((-0.75, -0.74))
  wire((-0.75, -0.74), (-0.75, 0.31))
  wire((-0.75, 0.31), (-0.525, 0.31))

  wire((0.525, 0.5), (0.95, 0.5), stroke: edge-hot)
  wire((0.525, -0.55), (0.92, -0.55))

  lab((-1.64, 0.69), $A$)
  lab((-1.64, -0.74), $B$)
  lab((1.08, 0.5), $S$, anchor: "west")
  lab((1.05, -0.55), $C$, anchor: "west")
})

// ── Полный сумматор: ступень суммы и ступень переноса ──
#let full-adder = canvas({
  panel((-0.95, 0.15), (2.3, 1.05), tone: cool, fill: panel-cool)
  panel((-0.95, -1.45), (3.55, -0.02), tone: warm, fill: panel-warm)

  gate((0, 0.6), "XOR")
  gate((0, -0.55), "AND")
  gate((1.6, 0.6), "XOR")
  gate((1.6, -0.375), "AND")
  gate((2.85, -0.5), "OR")

  wire((-1.75, 0.79), (-0.525, 0.79))
  jdot((-1.1, 0.79))
  wire((-1.1, 0.79), (-1.1, -0.36))
  wire((-1.1, -0.36), (-0.525, -0.36))

  wire((-1.75, -0.74), (-0.525, -0.74))
  jdot((-0.9, -0.74))
  wire((-0.9, -0.74), (-0.9, 0.41))
  wire((-0.9, 0.41), (-0.525, 0.41))

  wire((0.525, 0.6), (0.75, 0.6))
  jdot((0.75, 0.6))
  wire((0.75, 0.6), (0.75, 0.78))
  wire((0.75, 0.78), (1.075, 0.78))
  wire((0.75, 0.6), (0.75, -0.19))
  wire((0.75, -0.19), (1.075, -0.19))

  wire((-1.75, -1.1), (0.85, -1.1))
  jdot((0.85, -1.1))
  wire((0.85, -1.1), (0.85, 0.41))
  wire((0.85, 0.41), (1.075, 0.41))
  jdot((0.85, -0.565))
  wire((0.85, -0.565), (1.075, -0.565))

  wire((0.525, -0.55), (0.6, -0.55))
  wire((0.6, -0.55), (0.6, -1.3))
  wire((0.6, -1.3), (2.2, -1.3))
  wire((2.2, -1.3), (2.2, -0.69))
  wire((2.2, -0.69), (2.325, -0.69))

  wire((2.125, -0.375), (2.2, -0.375))
  wire((2.2, -0.375), (2.2, -0.31))
  wire((2.2, -0.31), (2.325, -0.31))

  wire((2.125, 0.6), (2.55, 0.6), stroke: edge-hot)
  wire((3.375, -0.5), (3.72, -0.5))

  lab((-1.9, 0.79), $A$)
  lab((-1.9, -0.74), $B$)
  lab((-1.9, -1.1), $C_"in"$)
  lab((2.68, 0.6), $S$, anchor: "west")
  lab((3.85, -0.5), $C_"out"$, anchor: "west")
})

// ── Мультиплексор 4-в-1 ──
#let multiplexer-4to1 = canvas({
  draw.line(
    (0, 1.2),
    (2.52, 0.6),
    (2.52, -0.6),
    (0, -1.2),
    close: true,
    fill: panel-cool,
    stroke: (paint: cool, thickness: 1.1pt),
  )
  draw.content((1.26, 0.15), text(fill: ink, weight: "bold")[MUX])
  mark((1.26, -0.4), $4 times 1$, tone: ink-soft)

  for (i, y) in (0.9, 0.3, -0.3, -0.9).enumerate() {
    wire((-0.6, y), (0, y))
    lab((-0.74, y), $D_#i$)
  }

  wire((2.52, 0), (2.98, 0), stroke: edge-hot)
  lab((3.11, 0), $Y$, anchor: "west")

  wire((0.84, 1.0), (0.84, 1.5))
  mark((0.84, 1.72), $S_0$)
  wire((1.68, 0.8), (1.68, 1.5))
  mark((1.68, 1.72), $S_1$)

  mark((1.26, -1.62), $Y = D_((S_1 S_0)_2)$)
})

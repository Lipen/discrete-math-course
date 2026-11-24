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

// ── Полный сумматор: сумма и перенос разведены по цветам ──
#let full-adder = canvas({
  let hline(y, x1, x2, stroke: edge-plain) = draw.line(
    (x1, y),
    (x2, y),
    stroke: stroke,
  )
  let vline(x, y1, y2, stroke: edge-plain) = draw.line(
    (x, y1),
    (x, y2),
    stroke: stroke,
  )

  // Входы A и B расходятся к XOR и AND первого яруса.
  hline(2.6, -2.7, -0.9)
  vline(-0.9, 2.6, 0.62)
  hline(1.82, -0.9, -0.6)
  hline(0.62, -0.9, -0.6)
  jdot((-0.9, 1.82))
  jdot((-0.9, 0.62))

  hline(1.2, -2.7, -1.3)
  vline(-1.3, 1.38, 0.18)
  hline(1.38, -1.3, -0.6)
  hline(0.18, -1.3, -0.6)
  jdot((-1.3, 1.2))

  // C_in идёт между ярусами. Разрыв в вертикали отмечает пересечение с s1.
  vline(1.5, -0.9, 0.54)
  vline(1.5, 0.70, 1.38)
  hline(0.18, 1.5, 1.8)
  hline(1.38, 1.5, 1.8)
  jdot((1.5, 0.18))

  // Сумма: s1 = A xor B, затем S = s1 xor C_in.
  hline(1.6, 0.6, 1.4, stroke: edge-cool)
  vline(1.4, 0.62, 1.82, stroke: edge-cool)
  hline(1.82, 1.4, 1.8, stroke: edge-cool)
  hline(0.62, 1.4, 1.8, stroke: edge-cool)
  jdot((1.4, 1.6))

  // Перенос: c1 = A and B, c2 = s1 and C_in, C_out = c1 or c2.
  hline(0.4, 0.6, 0.9, stroke: edge-hot)
  vline(0.9, 0.4, -1.2, stroke: edge-hot)
  hline(-1.2, 0.9, 3.3, stroke: edge-hot)
  vline(3.3, -1.2, 0.18, stroke: edge-hot)
  hline(0.18, 3.3, 3.8, stroke: edge-hot)

  hline(0.4, 3.0, 3.5, stroke: edge-hot)
  vline(3.5, 0.4, 0.62, stroke: edge-hot)
  hline(0.62, 3.5, 3.8, stroke: edge-hot)

  hline(1.6, 3.0, 3.55, stroke: edge-cool)
  hline(0.4, 5.0, 5.55, stroke: edge-hot)

  gate((0, 1.6), "XOR", w: 1.2, h: 0.7)
  gate((0, 0.4), "AND", w: 1.2, h: 0.7)
  gate((2.4, 1.6), "XOR", w: 1.2, h: 0.7)
  gate((2.4, 0.4), "AND", w: 1.2, h: 0.7)
  gate((4.4, 0.4), "OR", w: 1.2, h: 0.7)

  mark((0.95, 1.78), $u$, tone: cool)
  mark((0.78, 0.56), $v$, tone: warm)
  mark((3.15, 0.56), $w$, tone: warm)

  lab((-2.75, 2.6), $A$)
  lab((-2.75, 1.2), $B$)
  lab((1.75, -1.0), $C_"in"$, anchor: "west")
  lab((3.65, 1.6), $S$, anchor: "west")
  lab((5.65, 0.4), $C_"out"$, anchor: "west")
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

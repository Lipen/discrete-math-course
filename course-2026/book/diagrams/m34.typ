// m34 diagrams.
#import "../requirements.typ": *
#import "../notation.typ": *

#import cetz: canvas, draw

#let c-tri = oklch(55%, 0.18, 22deg)

#let c-trap = oklch(50%, 0.14, 260deg)

#let c-gauss = oklch(46%, 0.13, 140deg)

#let c-axis = oklch(35%, 0.02, 265deg)

#let c-tick = oklch(40%, 0.02, 265deg)

#let membership-functions = canvas({

  let tx(x) = 0.5 + x * 0.7
  let ty(y) = 0.5 + y * 4.0

  // ── Axes ──
  draw.line((tx(0), ty(0)), (tx(10.6), ty(0)), stroke: 0.5pt + c-axis)
  draw.line((tx(0), ty(0)), (tx(0), ty(1.15)), stroke: 0.5pt + c-axis)

  // x-axis ticks
  for i in range(1, 11) {
    draw.line(
      (tx(i), ty(0) - 0.06),
      (tx(i), ty(0) + 0.06),
      stroke: 0.3pt + c-tick,
    )
    draw.content(
      (tx(i), ty(-0.18)),
      text(size: 0.55em, fill: c-tick)[#i],
    )
  }

  // y-axis tick with label
  let y-tick(y, label, tick-len: 0.06, stroke: 0.3pt + c-tick, size: 0.55em, fill: c-tick) = {
    draw.line((tx(0) - tick-len, ty(y)), (tx(0) + tick-len, ty(y)), stroke: stroke)
    draw.content((tx(-0.15), ty(y)), anchor: "east", text(size: size, fill: fill)[#label])
  }

  y-tick(0, "0")
  y-tick(0.5, "0.5", tick-len: 0.04, stroke: 0.2pt + luma(65%), size: 0.5em, fill: luma(55%))
  y-tick(1, "1")

  // Axis labels
  draw.content(
    (tx(5.3), ty(-0.45)),
    text(size: 0.7em, fill: c-axis)[$x$],
  )
  draw.content(
    (tx(-0.5), ty(0.55)),
    text(size: 0.7em, fill: c-axis)[$mu(x)$],
  )

  // ── Dashed horizontal at y = 1 ──
  draw.line(
    (tx(0), ty(1)),
    (tx(10), ty(1)),
    stroke: (paint: luma(78%), thickness: 0.3pt, dash: "dashed"),
  )

  // ── 1. Triangular: μ(x) = max(0, 1 − |x−5|/3) ──
  draw.line(
    (tx(2), ty(0)),
    (tx(5), ty(1)),
    stroke: 1pt + c-tri,
  )
  draw.line(
    (tx(5), ty(1)),
    (tx(8), ty(0)),
    stroke: 1pt + c-tri,
  )

  // ── 2. Trapezoidal ──
  draw.line(
    (tx(2), ty(0)),
    (tx(4), ty(1)),
    stroke: 1pt + c-trap,
  )
  draw.line(
    (tx(4), ty(1)),
    (tx(7), ty(1)),
    stroke: 1pt + c-trap,
  )
  draw.line(
    (tx(7), ty(1)),
    (tx(9), ty(0)),
    stroke: 1pt + c-trap,
  )

  // ── 3. Gaussian-like bell ──
  draw.bezier(
    (tx(2), ty(0)),
    (tx(5), ty(1)),
    (tx(3.2), ty(0.03)),
    (tx(4.3), ty(0.88)),
    stroke: 1pt + c-gauss,
  )
  draw.bezier(
    (tx(5), ty(1)),
    (tx(8), ty(0)),
    (tx(5.7), ty(0.88)),
    (tx(6.8), ty(0.03)),
    stroke: 1pt + c-gauss,
  )

  // ── Legend ──
  let ly = ty(1.18)
  let lx = tx(5.8)
  let lg = 0.55
  let ls = 0.22

  // legend entry (line + label)
  let legend-item(y, color, label) = {
    draw.line((lx, y), (lx + lg, y), stroke: 1pt + color)
    draw.content((lx + lg + 0.15, y), anchor: "west", text(size: 0.55em, fill: c-axis)[#label])
  }

  legend-item(ly, c-tri, "Треугольная")
  legend-item(ly - ls, c-trap, "Трапецеидальная")
  legend-item(ly - 2 * ls, c-gauss, "Гауссова")
})

#let c-muA = oklch(55%, 0.18, 250deg)

#let c-muA-dim = oklch(70%, 0.08, 250deg)

#let c-muB = oklch(55%, 0.18, 25deg)

#let c-muB-dim = oklch(70%, 0.08, 25deg)

#let c-result = oklch(40%, 0.16, 280deg)

#let fuzzy-operations = canvas({

  // panel axes
  let panel-axes(ox) = {
    draw.line((ox + 0.6, 0.5), (ox + 4.0, 0.5), stroke: 0.5pt + c-axis)
    draw.line((ox + 0.6, 0.5), (ox + 0.6, 3.0), stroke: 0.5pt + c-axis)
    draw.line((ox + 0.6 - 0.08, 0.5), (ox + 0.6, 0.5), stroke: 0.3pt + c-tick)
    draw.content((ox + 0.44, 0.5), anchor: "east", text(
      size: 0.5em,
      fill: c-tick,
    )[0])
    draw.line((ox + 0.6 - 0.08, 3.0), (ox + 0.6, 3.0), stroke: 0.3pt + c-tick)
    draw.content((ox + 0.44, 3.0), anchor: "east", text(
      size: 0.5em,
      fill: c-tick,
    )[1])
    draw.content((ox + 2.3, -0.1), text(size: 0.55em, fill: c-axis)[$x$])
    draw.content((ox + 0.35, 1.75), anchor: "east", text(
      size: 0.55em,
      fill: c-axis,
    )[$mu$])
  }

  // ══════ Panel 1: Union (max) ══════
  let ox = 0
  // Axes
  panel-axes(ox)
  // Dim curves A and B
  draw.line((ox + 0.8, 0.5), (ox + 1.8, 3.0), stroke: 0.5pt + c-muA-dim)
  draw.line((ox + 1.8, 3.0), (ox + 2.8, 0.5), stroke: 0.5pt + c-muA-dim)
  draw.line((ox + 1.8, 0.5), (ox + 2.8, 3.0), stroke: 0.5pt + c-muB-dim)
  draw.line((ox + 2.8, 3.0), (ox + 3.8, 0.5), stroke: 0.5pt + c-muB-dim)
  // Max: upper envelope
  draw.line((ox + 0.8, 0.5), (ox + 1.8, 3.0), stroke: 1.2pt + c-muA)
  draw.line((ox + 1.8, 3.0), (ox + 2.3, 1.75), stroke: 1.2pt + c-muA)
  draw.line((ox + 2.3, 1.75), (ox + 2.8, 3.0), stroke: 1.2pt + c-muA)
  draw.line((ox + 2.8, 3.0), (ox + 3.8, 0.5), stroke: 1.2pt + c-muA)
  // Labels
  draw.content((ox + 1.6, 2.4), anchor: "south", text(
    size: 0.55em,
    fill: c-muA,
  )[$mu_A$])
  draw.content((ox + 3.4, 2.2), anchor: "south", text(
    size: 0.55em,
    fill: c-muB,
  )[$mu_B$])
  draw.content((ox + 2.3, 3.4), text(
    size: 0.7em,
    weight: "semibold",
    fill: c-axis,
  )[Объединение $(max)$])

  // ══════ Panel 2: Intersection (min) ══════
  ox = 5.0
  panel-axes(ox)
  // Dim curves A and B
  draw.line((ox + 0.8, 0.5), (ox + 1.8, 3.0), stroke: 0.5pt + c-muA-dim)
  draw.line((ox + 1.8, 3.0), (ox + 2.8, 0.5), stroke: 0.5pt + c-muA-dim)
  draw.line((ox + 1.8, 0.5), (ox + 2.8, 3.0), stroke: 0.5pt + c-muB-dim)
  draw.line((ox + 2.8, 3.0), (ox + 3.8, 0.5), stroke: 0.5pt + c-muB-dim)
  // Min: lower envelope
  draw.line((ox + 1.8, 0.5), (ox + 2.3, 1.75), stroke: 1.2pt + c-result)
  draw.line((ox + 2.3, 1.75), (ox + 2.8, 0.5), stroke: 1.2pt + c-result)
  // Labels
  draw.content((ox + 1.6, 2.4), anchor: "south", text(
    size: 0.55em,
    fill: c-muA,
  )[$mu_A$])
  draw.content((ox + 3.4, 2.2), anchor: "south", text(
    size: 0.55em,
    fill: c-muB,
  )[$mu_B$])
  draw.content((ox + 2.3, 3.4), text(
    size: 0.7em,
    weight: "semibold",
    fill: c-axis,
  )[Пересечение $(min)$])

  // ══════ Panel 3: Complement ─═════
  ox = 10.0
  panel-axes(ox)
  // Original A
  draw.line((ox + 0.8, 0.5), (ox + 1.8, 3.0), stroke: 0.8pt + c-muA)
  draw.line((ox + 1.8, 3.0), (ox + 2.8, 0.5), stroke: 0.8pt + c-muA)
  // ¬A: mirrored
  draw.line((ox + 0.8, 3.0), (ox + 1.8, 0.5), stroke: 1.2pt + c-result)
  draw.line((ox + 1.8, 0.5), (ox + 2.8, 3.0), stroke: 1.2pt + c-result)
  // Labels
  draw.content((ox + 1.2, 1.5), anchor: "west", text(
    size: 0.55em,
    fill: c-muA,
  )[$mu_A$])
  draw.content((ox + 1.2, 2.6), anchor: "west", text(
    size: 0.55em,
    fill: c-result,
  )[$mu_{not A}$])
  draw.content((ox + 2.3, 3.4), text(
    size: 0.7em,
    weight: "semibold",
    fill: c-axis,
  )[Дополнение $(1-mu)$])
})

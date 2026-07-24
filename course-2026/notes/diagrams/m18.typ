// M18 diagrams — Fuzzy sets: membership functions.
#import "../requirements.typ": *
#import cetz: canvas, draw

#let c-tri = oklch(55%, 0.18, 22deg)
#let c-trap = oklch(50%, 0.14, 260deg)
#let c-gauss = oklch(46%, 0.13, 140deg)
#let c-axis = oklch(35%, 0.02, 265deg)
#let c-tick = oklch(40%, 0.02, 265deg)

// Three membership functions on one canvas for comparison:
// triangular (peak at x=5, width 6), trapezoidal, and Gaussian-like.
#let membership-functions = figure(
  canvas(length: 9cm, {
    import draw: *

    // Data coordinates → canvas coordinates.
    // x-data: 0…10  → canvas x: 0.5…7.5  (0.7 per unit)
    // y-data: 0…1.2 → canvas y: 0.5…5.3  (4.0 per unit)
    let tx(x) = 0.5 + x * 0.7
    let ty(y) = 0.5 + y * 4.0

    // ── Axes ──
    line((tx(0), ty(0)), (tx(10.6), ty(0)), stroke: 0.5pt + c-axis)
    line((tx(0), ty(0)), (tx(0), ty(1.15)), stroke: 0.5pt + c-axis)

    // x-axis ticks (every unit from 1 to 10)
    for i in range(1, 11) {
      line(
        (tx(i), ty(0) - 0.06),
        (tx(i), ty(0) + 0.06),
        stroke: 0.3pt + c-tick,
      )
      content(
        (tx(i), ty(-0.18)),
        text(size: 0.55em, fill: c-tick)[#i],
      )
    }

    // y-axis ticks: 0, 0.5, 1
    line(
      (tx(0) - 0.06, ty(0)),
      (tx(0) + 0.06, ty(0)),
      stroke: 0.3pt + c-tick,
    )
    content(
      (tx(-0.15), ty(0)),
      anchor: "east",
      text(size: 0.55em, fill: c-tick)[0],
    )
    line(
      (tx(0) - 0.04, ty(0.5)),
      (tx(0) + 0.04, ty(0.5)),
      stroke: 0.2pt + luma(65%),
    )
    content(
      (tx(-0.15), ty(0.5)),
      anchor: "east",
      text(size: 0.5em, fill: luma(55%))[0.5],
    )
    line(
      (tx(0) - 0.06, ty(1)),
      (tx(0) + 0.06, ty(1)),
      stroke: 0.3pt + c-tick,
    )
    content(
      (tx(-0.15), ty(1)),
      anchor: "east",
      text(size: 0.55em, fill: c-tick)[1],
    )

    // Axis labels
    content(
      (tx(5.3), ty(-0.45)),
      text(size: 0.7em, fill: c-axis)[$x$],
    )
    content(
      (tx(-0.5), ty(0.55)),
      text(size: 0.7em, fill: c-axis)[$mu(x)$],
    )

    // ── Dashed horizontal at y = 1 ──
    line(
      (tx(0), ty(1)),
      (tx(10), ty(1)),
      stroke: (paint: luma(78%), thickness: 0.3pt, dash: "dashed"),
    )

    // ── 1. Triangular: μ(x) = max(0, 1 − |x−5|/3) ──
    // Rises from x=2 to x=5, falls from x=5 to x=8.
    line(
      (tx(2), ty(0)),
      (tx(5), ty(1)),
      stroke: 1pt + c-tri,
    )
    line(
      (tx(5), ty(1)),
      (tx(8), ty(0)),
      stroke: 1pt + c-tri,
    )

    // ── 2. Trapezoidal: rise 2→4, plateau 4→7, fall 7→9 ──
    line(
      (tx(2), ty(0)),
      (tx(4), ty(1)),
      stroke: 1pt + c-trap,
    )
    line(
      (tx(4), ty(1)),
      (tx(7), ty(1)),
      stroke: 1pt + c-trap,
    )
    line(
      (tx(7), ty(1)),
      (tx(9), ty(0)),
      stroke: 1pt + c-trap,
    )

    // ── 3. Gaussian-like bell: centred at x = 5 ──
    // Left half: slow rise → steep approach → peak.
    bezier(
      (tx(2), ty(0)),
      (tx(5), ty(1)),
      (tx(3.2), ty(0.03)),
      (tx(4.3), ty(0.88)),
      stroke: 1pt + c-gauss,
    )
    // Right half: gentle descent → steep drop → zero.
    bezier(
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

    line((lx, ly), (lx + lg, ly), stroke: 1pt + c-tri)
    content(
      (lx + lg + 0.15, ly),
      anchor: "west",
      text(size: 0.55em, fill: c-axis)[Треугольная],
    )

    line((lx, ly - ls), (lx + lg, ly - ls), stroke: 1pt + c-trap)
    content(
      (lx + lg + 0.15, ly - ls),
      anchor: "west",
      text(size: 0.55em, fill: c-axis)[Трапецеидальная],
    )

    line((lx, ly - 2 * ls), (lx + lg, ly - 2 * ls), stroke: 1pt + c-gauss)
    content(
      (lx + lg + 0.15, ly - 2 * ls),
      anchor: "west",
      text(size: 0.55em, fill: c-axis)[Гауссова],
    )
  }),
  caption: [
    Функции принадлежности: треугольная $(2, 5, 8)$, трапецеидальная $(2, 4, 7, 9)$ и гауссова (центр $5$).
  ],
)

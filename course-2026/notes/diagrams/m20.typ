// M20 diagrams --- Fuzzy sets: membership functions and operations.
#import "../requirements.typ": *
#import cetz: canvas, draw

#let c-tri = oklch(55%, 0.18, 22deg)
#let c-trap = oklch(50%, 0.14, 260deg)
#let c-gauss = oklch(46%, 0.13, 140deg)
#let c-axis = oklch(35%, 0.02, 265deg)
#let c-tick = oklch(40%, 0.02, 265deg)

// ── Three membership functions for comparison ──
#let membership-functions = figure(
  canvas({
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

// ── Fuzzy set operations ──

#let c-muA = oklch(55%, 0.18, 250deg)
#let c-muA-dim = oklch(70%, 0.08, 250deg)
#let c-muB = oklch(55%, 0.18, 25deg)
#let c-muB-dim = oklch(70%, 0.08, 25deg)
#let c-result = oklch(40%, 0.16, 280deg)

// ── Union (max), intersection (min), complement --- three panels ──
#let fuzzy-operations = figure(
  canvas({
    import draw: *

    // Panel offsets: each sub-plot is 4.6 wide, with 0.4 gap between.
    // Plot area within panel: [ox+0.6, ox+4.0] in x, [0.5, 3.0] in y.
    //
    // Triangle vertices for A: (ox+0.8,0.5) → (ox+1.8,3.0) → (ox+2.8,0.5)
    // Triangle vertices for B: (ox+1.8,0.5) → (ox+2.8,3.0) → (ox+3.8,0.5)
    // Intersection A-right ∩ B-left at (ox+2.3, 1.75)

    // ══════ Panel 1: Union (max) ══════
    let ox = 0
    // Axes
    line((ox + 0.6, 0.5), (ox + 4.0, 0.5), stroke: 0.5pt + c-axis)
    line((ox + 0.6, 0.5), (ox + 0.6, 3.0), stroke: 0.5pt + c-axis)
    line((ox + 0.6 - 0.08, 0.5), (ox + 0.6, 0.5), stroke: 0.3pt + c-tick)
    content((ox + 0.44, 0.5), anchor: "east", text(
      size: 0.5em,
      fill: c-tick,
    )[0])
    line((ox + 0.6 - 0.08, 3.0), (ox + 0.6, 3.0), stroke: 0.3pt + c-tick)
    content((ox + 0.44, 3.0), anchor: "east", text(
      size: 0.5em,
      fill: c-tick,
    )[1])
    content((ox + 2.3, -0.1), text(size: 0.55em, fill: c-axis)[$x$])
    content((ox + 0.35, 1.75), anchor: "east", text(
      size: 0.55em,
      fill: c-axis,
    )[$mu$])
    // Dim curves A and B
    line((ox + 0.8, 0.5), (ox + 1.8, 3.0), stroke: 0.5pt + c-muA-dim)
    line((ox + 1.8, 3.0), (ox + 2.8, 0.5), stroke: 0.5pt + c-muA-dim)
    line((ox + 1.8, 0.5), (ox + 2.8, 3.0), stroke: 0.5pt + c-muB-dim)
    line((ox + 2.8, 3.0), (ox + 3.8, 0.5), stroke: 0.5pt + c-muB-dim)
    // Max: upper envelope
    line((ox + 0.8, 0.5), (ox + 1.8, 3.0), stroke: 1.2pt + c-muA)
    line((ox + 1.8, 3.0), (ox + 2.3, 1.75), stroke: 1.2pt + c-muA)
    line((ox + 2.3, 1.75), (ox + 2.8, 3.0), stroke: 1.2pt + c-muA)
    line((ox + 2.8, 3.0), (ox + 3.8, 0.5), stroke: 1.2pt + c-muA)
    // Labels
    content((ox + 1.6, 2.4), anchor: "south", text(
      size: 0.55em,
      fill: c-muA,
    )[$mu_A$])
    content((ox + 3.4, 2.2), anchor: "south", text(
      size: 0.55em,
      fill: c-muB,
    )[$mu_B$])
    content((ox + 2.3, 3.4), text(
      size: 0.7em,
      weight: "semibold",
      fill: c-axis,
    )[Объединение $(max)$])

    // ══════ Panel 2: Intersection (min) ══════
    ox = 5.0
    line((ox + 0.6, 0.5), (ox + 4.0, 0.5), stroke: 0.5pt + c-axis)
    line((ox + 0.6, 0.5), (ox + 0.6, 3.0), stroke: 0.5pt + c-axis)
    line((ox + 0.6 - 0.08, 0.5), (ox + 0.6, 0.5), stroke: 0.3pt + c-tick)
    content((ox + 0.44, 0.5), anchor: "east", text(
      size: 0.5em,
      fill: c-tick,
    )[0])
    line((ox + 0.6 - 0.08, 3.0), (ox + 0.6, 3.0), stroke: 0.3pt + c-tick)
    content((ox + 0.44, 3.0), anchor: "east", text(
      size: 0.5em,
      fill: c-tick,
    )[1])
    content((ox + 2.3, -0.1), text(size: 0.55em, fill: c-axis)[$x$])
    content((ox + 0.35, 1.75), anchor: "east", text(
      size: 0.55em,
      fill: c-axis,
    )[$mu$])
    // Dim curves A and B
    line((ox + 0.8, 0.5), (ox + 1.8, 3.0), stroke: 0.5pt + c-muA-dim)
    line((ox + 1.8, 3.0), (ox + 2.8, 0.5), stroke: 0.5pt + c-muA-dim)
    line((ox + 1.8, 0.5), (ox + 2.8, 3.0), stroke: 0.5pt + c-muB-dim)
    line((ox + 2.8, 3.0), (ox + 3.8, 0.5), stroke: 0.5pt + c-muB-dim)
    // Min: lower envelope
    line((ox + 1.8, 0.5), (ox + 2.3, 1.75), stroke: 1.2pt + c-result)
    line((ox + 2.3, 1.75), (ox + 2.8, 0.5), stroke: 1.2pt + c-result)
    // Labels
    content((ox + 1.6, 2.4), anchor: "south", text(
      size: 0.55em,
      fill: c-muA,
    )[$mu_A$])
    content((ox + 3.4, 2.2), anchor: "south", text(
      size: 0.55em,
      fill: c-muB,
    )[$mu_B$])
    content((ox + 2.3, 3.4), text(
      size: 0.7em,
      weight: "semibold",
      fill: c-axis,
    )[Пересечение $(min)$])

    // ══════ Panel 3: Complement ─═════
    ox = 10.0
    line((ox + 0.6, 0.5), (ox + 4.0, 0.5), stroke: 0.5pt + c-axis)
    line((ox + 0.6, 0.5), (ox + 0.6, 3.0), stroke: 0.5pt + c-axis)
    line((ox + 0.6 - 0.08, 0.5), (ox + 0.6, 0.5), stroke: 0.3pt + c-tick)
    content((ox + 0.44, 0.5), anchor: "east", text(
      size: 0.5em,
      fill: c-tick,
    )[0])
    line((ox + 0.6 - 0.08, 3.0), (ox + 0.6, 3.0), stroke: 0.3pt + c-tick)
    content((ox + 0.44, 3.0), anchor: "east", text(
      size: 0.5em,
      fill: c-tick,
    )[1])
    content((ox + 2.3, -0.1), text(size: 0.55em, fill: c-axis)[$x$])
    content((ox + 0.35, 1.75), anchor: "east", text(
      size: 0.55em,
      fill: c-axis,
    )[$mu$])
    // Original A
    line((ox + 0.8, 0.5), (ox + 1.8, 3.0), stroke: 0.8pt + c-muA)
    line((ox + 1.8, 3.0), (ox + 2.8, 0.5), stroke: 0.8pt + c-muA)
    // ¬A: mirrored about y = 1.75
    line((ox + 0.8, 3.0), (ox + 1.8, 0.5), stroke: 1.2pt + c-result)
    line((ox + 1.8, 0.5), (ox + 2.8, 3.0), stroke: 1.2pt + c-result)
    // Labels
    content((ox + 1.2, 1.5), anchor: "west", text(
      size: 0.55em,
      fill: c-muA,
    )[$mu_A$])
    content((ox + 1.2, 2.6), anchor: "west", text(
      size: 0.55em,
      fill: c-result,
    )[$mu_{not A}$])
    content((ox + 2.3, 3.4), text(
      size: 0.7em,
      weight: "semibold",
      fill: c-axis,
    )[Дополнение $(1-mu)$])
  }),
  caption: [Операции над нечёткими множествами: объединение ($max$), пересечение ($min$) и дополнение ($1 - mu$). Треугольные функции принадлежности $mu_A$ и $mu_B$ показаны тонкими линиями, результат операции --- жирной.],
)

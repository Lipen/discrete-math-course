// Injection, surjection, bijection mapping schemes.
// Скопировано из книги, чтобы лекции не зависели от неё.
#import "@preview/cetz:0.5.2": canvas, draw

#let c-dom = oklch(80%, 0.06, 250deg)
#let c-cod = oklch(80%, 0.06, 25deg)
#let c-dot = oklch(35%, 0.02, 265deg)
#let c-str = oklch(35%, 0.02, 265deg) + 0.7pt

#let label(pos, body) = draw.content(pos, text(size: 0.85em, body))

// ── Injection (one-to-one): each B element reached at most once ──
#let mapping-injection = canvas({
  draw.circle((-1.5, 0), radius: (0.55, 1.1), fill: c-dom, stroke: c-str)
  label((-1.5, 1.4), $A$)
  draw.circle((-1.5, -0.65), radius: 0.07, fill: c-dot, name: "a1")
  draw.circle((-1.5, -0.25), radius: 0.07, fill: c-dot, name: "a2")
  draw.circle((-1.5, 0.15), radius: 0.07, fill: c-dot, name: "a3")
  draw.circle((-1.5, 0.55), radius: 0.07, fill: c-dot, name: "a4")

  draw.circle((1.5, 0), radius: (0.55, 1.4), fill: c-cod, stroke: c-str)
  label((1.5, 1.7), $B$)
  draw.circle((1.5, -1.05), radius: 0.07, fill: c-dot, name: "b1")
  draw.circle((1.5, -0.65), radius: 0.07, fill: c-dot, name: "b2")
  draw.circle((1.5, -0.25), radius: 0.07, fill: c-dot, name: "b3")
  draw.circle((1.5, 0.15), radius: 0.07, fill: c-dot, name: "b4")
  draw.circle((1.5, 0.55), radius: 0.07, fill: c-dot, name: "b5")
  draw.circle((1.5, 0.95), radius: 0.07, fill: c-dot, name: "b6")

  draw.line("a1", "b2", stroke: c-str, mark: (end: (symbol: ">", fill: black)))
  draw.line("a2", "b5", stroke: c-str, mark: (end: (symbol: ">", fill: black)))
  draw.line("a3", "b3", stroke: c-str, mark: (end: (symbol: ">", fill: black)))
  draw.line("a4", "b6", stroke: c-str, mark: (end: (symbol: ">", fill: black)))
  label((0, -2.2), text(weight: "bold")[Инъекция])
})

// ── Surjection (onto): each B element reached at least once ──
#let mapping-surjection = canvas({
  draw.circle((-1.5, 0), radius: (0.55, 1.4), fill: c-dom, stroke: c-str)
  label((-1.5, 1.7), $A$)
  draw.circle((-1.5, -1.05), radius: 0.07, fill: c-dot, name: "a1")
  draw.circle((-1.5, -0.65), radius: 0.07, fill: c-dot, name: "a2")
  draw.circle((-1.5, -0.25), radius: 0.07, fill: c-dot, name: "a3")
  draw.circle((-1.5, 0.15), radius: 0.07, fill: c-dot, name: "a4")
  draw.circle((-1.5, 0.55), radius: 0.07, fill: c-dot, name: "a5")
  draw.circle((-1.5, 0.95), radius: 0.07, fill: c-dot, name: "a6")

  draw.circle((1.5, 0), radius: (0.55, 0.9), fill: c-cod, stroke: c-str)
  label((1.5, 1.2), $B$)
  draw.circle((1.5, -0.45), radius: 0.07, fill: c-dot, name: "b1")
  draw.circle((1.5, 0), radius: 0.07, fill: c-dot, name: "b2")
  draw.circle((1.5, 0.45), radius: 0.07, fill: c-dot, name: "b3")

  draw.line("a1", "b1", stroke: c-str, mark: (end: (symbol: ">", fill: black)))
  draw.line("a2", "b1", stroke: c-str, mark: (end: (symbol: ">", fill: black)))
  draw.line("a3", "b2", stroke: c-str, mark: (end: (symbol: ">", fill: black)))
  draw.line("a4", "b2", stroke: c-str, mark: (end: (symbol: ">", fill: black)))
  draw.line("a5", "b3", stroke: c-str, mark: (end: (symbol: ">", fill: black)))
  draw.line("a6", "b3", stroke: c-str, mark: (end: (symbol: ">", fill: black)))
  label((0, -2.2), text(weight: "bold")[Сюръекция])
})

// ── Bijection: one-to-one AND onto ──
#let mapping-bijection = canvas({
  draw.circle((-1.5, 0), radius: (0.55, 1.1), fill: c-dom, stroke: c-str)
  label((-1.5, 1.4), $A$)
  draw.circle((-1.5, -0.65), radius: 0.07, fill: c-dot, name: "a1")
  draw.circle((-1.5, -0.25), radius: 0.07, fill: c-dot, name: "a2")
  draw.circle((-1.5, 0.15), radius: 0.07, fill: c-dot, name: "a3")
  draw.circle((-1.5, 0.55), radius: 0.07, fill: c-dot, name: "a4")

  draw.circle((1.5, 0), radius: (0.55, 1.1), fill: c-cod, stroke: c-str)
  label((1.5, 1.4), $B$)
  draw.circle((1.5, -0.65), radius: 0.07, fill: c-dot, name: "b1")
  draw.circle((1.5, -0.25), radius: 0.07, fill: c-dot, name: "b2")
  draw.circle((1.5, 0.15), radius: 0.07, fill: c-dot, name: "b3")
  draw.circle((1.5, 0.55), radius: 0.07, fill: c-dot, name: "b4")

  draw.line("a1", "b3", stroke: c-str, mark: (end: (symbol: ">", fill: black)))
  draw.line("a2", "b1", stroke: c-str, mark: (end: (symbol: ">", fill: black)))
  draw.line("a3", "b4", stroke: c-str, mark: (end: (symbol: ">", fill: black)))
  draw.line("a4", "b2", stroke: c-str, mark: (end: (symbol: ">", fill: black)))
  label((0, -2.2), text(weight: "bold")[Биекция])
})

// ── Function parts: domain and codomain, f: A -> B ──
#let function-parts = canvas({
  // Sets A and B
  draw.circle((-1.6, 0), radius: (0.6, 1.0), fill: c-dom, stroke: c-str)
  label((-1.6, 1.35), $A$)
  draw.circle((1.6, 0), radius: (0.6, 1.0), fill: c-cod, stroke: c-str)
  label((1.6, 1.35), $B$)

  // Functional arrow f
  draw.line((-1.0, 0), (1.0, 0), stroke: 1.2pt + c-dot, mark: (
    end: (symbol: ">", fill: black),
  ))
  label((0, 0.4), $f$)

  // Underbrace: smooth dip below a set, with a label
  let underbrace(x0, x1, y, body) = {
    let xc = (x0 + x1) / 2
    let w = x1 - x0
    let dip = 0.25
    draw.bezier(
      (x0, y),
      (xc, y - dip),
      (x0 + 0.3 * w, y),
      (xc - 0.3 * w, y - dip),
      stroke: c-str,
    )
    draw.bezier(
      (xc, y - dip),
      (x1, y),
      (xc + 0.3 * w, y - dip),
      (x1 - 0.3 * w, y),
      stroke: c-str,
    )
    draw.content((xc, y - dip - 0.22), text(size: 0.8em, fill: c-dot)[#body])
  }

  underbrace(-2.25, -0.95, -1.3, "домен")
  underbrace(0.95, 2.25, -1.3, "кодомен")
})

#let c-floor = oklch(50%, 0.16, 150deg)
#let c-ceil = oklch(55%, 0.17, 300deg)
#let c-hl = oklch(50%, 0.15, 300deg)

// ── Image and preimage of a subset ──
#let image-preimage = canvas({
  draw.circle((-1.9, 0), radius: (0.72, 1.35), fill: c-dom, stroke: c-str)
  label((-1.9, 1.65), $A$)
  draw.circle((-1.9, -0.9), radius: 0.07, fill: c-dot, name: "ia1")
  draw.circle((-1.9, -0.45), radius: 0.07, fill: c-dot, name: "ia2")
  draw.circle((-1.9, 0), radius: 0.07, fill: c-dot, name: "ia3")
  draw.circle((-1.9, 0.45), radius: 0.07, fill: c-dot, name: "ia4")
  draw.circle((-1.9, 0.9), radius: 0.07, fill: c-dot, name: "ia5")

  draw.circle((1.9, 0), radius: (0.78, 1.05), fill: c-cod, stroke: c-str)
  label((1.9, 1.35), $B$)
  draw.circle((1.9, -0.55), radius: 0.07, fill: c-dot, name: "ib1")
  draw.circle((1.9, 0), radius: 0.07, fill: c-dot, name: "ib2")
  draw.circle((1.9, 0.55), radius: 0.07, fill: c-dot, name: "ib3")

  draw.line("ia1", "ib1", stroke: c-str, mark: (
    end: (symbol: ">", fill: black),
  ))
  draw.line("ia2", "ib1", stroke: c-str, mark: (
    end: (symbol: ">", fill: black),
  ))
  draw.line("ia3", "ib2", stroke: c-str, mark: (
    end: (symbol: ">", fill: black),
  ))
  draw.line("ia4", "ib3", stroke: c-str, mark: (
    end: (symbol: ">", fill: black),
  ))
  draw.line("ia5", "ib3", stroke: c-str, mark: (
    end: (symbol: ">", fill: black),
  ))

  draw.circle((-1.9, -0.675), radius: (0.36, 0.4), stroke: (
    paint: c-hl,
    dash: "dashed",
  ))
  draw.circle((1.9, -0.55), radius: 0.18, stroke: (paint: c-hl, dash: "dashed"))
  draw.circle((1.9, 0.55), radius: 0.18, stroke: (paint: c-hl, dash: "dashed"))
  draw.circle((-1.9, 0.675), radius: (0.36, 0.4), stroke: (
    paint: c-hl,
    dash: "dashed",
  ))

  draw.content((-3.05, -0.675), text(size: 0.85em, $X$))
  draw.content((3.2, -0.55), text(size: 0.85em, $f(X)$))
  draw.content((3.2, 0.55), text(size: 0.85em, $Y$))
  draw.content((-3.05, 0.675), text(size: 0.85em, $f^(-1) (Y)$))
})

// ── Composition of two maps as a pipeline ──
#let composition-pipeline = canvas({
  draw.circle((-2.6, 0), radius: (0.5, 0.95), fill: c-dom, stroke: c-str)
  label((-2.6, 1.2), $A$)
  draw.circle((0, 0), radius: (0.5, 0.95), fill: c-dom, stroke: c-str)
  label((0, 1.2), $B$)
  draw.circle((2.6, 0), radius: (0.5, 0.95), fill: c-cod, stroke: c-str)
  label((2.6, 1.2), $C$)

  draw.line((-2.1, 0), (-0.5, 0), stroke: c-str, mark: (
    end: (symbol: ">", fill: black),
  ))
  label((-1.3, 0.3), $f$)
  draw.line((0.5, 0), (2.1, 0), stroke: c-str, mark: (
    end: (symbol: ">", fill: black),
  ))
  label((1.3, 0.3), $g$)

  draw.bezier(
    (-2.6, -0.9),
    (2.6, -0.9),
    (-1.5, -1.9),
    (1.5, -1.9),
    stroke: c-hl,
    mark: (
      end: (symbol: ">", fill: black),
    ),
  )
  draw.content((0, -1.95), text(size: 0.85em, $g compose f$))
})

// ── Floor and ceiling on the number line ──
#let floor-ceil-line = canvas({
  draw.line((-2.8, 0), (4.0, 0), stroke: c-str, mark: (
    end: (symbol: ">", fill: black),
  ))
  for k in range(-2, 4) {
    draw.line((k, -0.08), (k, 0.08), stroke: c-str)
    label((k, -0.32), [#k])
  }

  draw.circle((2.7, 0), radius: 0.06, fill: c-dot)
  draw.circle((2, 0), radius: 0.06, fill: c-floor)
  draw.circle((3, 0), radius: 0.06, fill: c-ceil)

  draw.circle((-1.3, 0), radius: 0.06, fill: c-dot)
  draw.circle((-2, 0), radius: 0.06, fill: c-floor)
  draw.circle((-1, 0), radius: 0.06, fill: c-ceil)

  draw.content((0.5, 0.75), text(
    size: 0.85em,
  )[$x = 2.7$: $floor(x) = 2$, $ceil(x) = 3$])
  draw.content((0.5, 1.25), text(
    size: 0.85em,
  )[$x = -1.3$: $floor(x) = -2$, $ceil(x) = -1$])
})

// ── Step graphs of floor and ceiling ──
#let floor-ceil-steps = canvas({
  draw.line((-1.9, 0), (3.5, 0), stroke: c-str, mark: (
    end: (symbol: ">", fill: black),
  ))
  draw.line((0, -1.9), (0, 3.5), stroke: c-str, mark: (
    end: (symbol: ">", fill: black),
  ))
  label((3.1, -0.35), $x$)
  label((0.35, 3.15), $y$)

  let solid(pos, color) = draw.circle(pos, radius: 0.055, fill: color)
  let open(pos, color) = draw.circle(
    pos,
    radius: 0.055,
    fill: white,
    stroke: 0.9pt + color,
  )

  for k in range(-1, 3) {
    draw.line((k, k), (k + 1, k), stroke: 1.1pt + c-floor)
    solid((k, k), c-floor)
    open((k + 1, k), c-floor)
  }

  for k in range(0, 3) {
    draw.line((k, k + 1), (k + 1, k + 1), stroke: (
      paint: c-ceil,
      dash: "dashed",
      thickness: 1.1pt,
    ))
    open((k, k + 1), c-ceil)
    solid((k + 1, k + 1), c-ceil)
  }

  draw.content(
    (2.8, 1.1),
    text(size: 0.8em, fill: c-floor)[пол],
    anchor: "west",
  )
  draw.content(
    (2.8, 2.1),
    text(size: 0.8em, fill: c-ceil)[потолок],
    anchor: "west",
  )
})

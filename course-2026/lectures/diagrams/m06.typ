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

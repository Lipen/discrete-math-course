#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

#let lens(pos, rx, ry, fill, label-text) = {
  let (x, y) = pos
  draw.circle(pos, radius: (rx, ry), fill: fill, stroke: c-edge + t-ed)
  draw.content((x, y + ry + 0.3), text(size: s-node, fill: c-ink)[#label-text])
}

#let dot(pos, name) = draw.circle(pos, radius: 0.07, fill: c-ink, name: name)

#let arrow(a, b) = draw.line(
  a,
  b,
  stroke: c-edge + t-ed,
  mark: (end: (symbol: ">", fill: c-edge)),
)

#let kicker(label-text) = draw.content(
  (0, -2.2),
  text(size: s-cap, fill: c-ink, weight: "bold")[#label-text],
)

// ── Инъекция ──
#let mapping-injection = canvas({
  lens((-1.5, 0), 0.55, 1.1, c-fl, $A$)
  dot((-1.5, -0.65), "a1")
  dot((-1.5, -0.25), "a2")
  dot((-1.5, 0.15), "a3")
  dot((-1.5, 0.55), "a4")

  lens((1.5, 0), 0.55, 1.4, c-conn, $B$)
  dot((1.5, -1.05), "b1")
  dot((1.5, -0.65), "b2")
  dot((1.5, -0.25), "b3")
  dot((1.5, 0.15), "b4")
  dot((1.5, 0.55), "b5")
  dot((1.5, 0.95), "b6")

  arrow("a1", "b2")
  arrow("a2", "b5")
  arrow("a3", "b3")
  arrow("a4", "b6")

  kicker([Инъекция])
})

// ── Сюръекция ──
#let mapping-surjection = canvas({
  lens((-1.5, 0), 0.55, 1.4, c-fl, $A$)
  dot((-1.5, -1.05), "a1")
  dot((-1.5, -0.65), "a2")
  dot((-1.5, -0.25), "a3")
  dot((-1.5, 0.15), "a4")
  dot((-1.5, 0.55), "a5")
  dot((-1.5, 0.95), "a6")

  lens((1.5, 0), 0.55, 0.9, c-conn, $B$)
  dot((1.5, -0.45), "b1")
  dot((1.5, 0), "b2")
  dot((1.5, 0.45), "b3")

  arrow("a1", "b1")
  arrow("a2", "b1")
  arrow("a3", "b2")
  arrow("a4", "b2")
  arrow("a5", "b3")
  arrow("a6", "b3")

  kicker([Сюръекция])
})

// ── Биекция ──
#let mapping-bijection = canvas({
  lens((-1.5, 0), 0.55, 1.1, c-fl, $A$)
  dot((-1.5, -0.65), "a1")
  dot((-1.5, -0.25), "a2")
  dot((-1.5, 0.15), "a3")
  dot((-1.5, 0.55), "a4")

  lens((1.5, 0), 0.55, 1.1, c-conn, $B$)
  dot((1.5, -0.65), "b1")
  dot((1.5, -0.25), "b2")
  dot((1.5, 0.15), "b3")
  dot((1.5, 0.55), "b4")

  arrow("a1", "b3")
  arrow("a2", "b1")
  arrow("a3", "b4")
  arrow("a4", "b2")

  kicker([Биекция])
})

// ── Части функции ──
#let function-parts = canvas({
  lens((-1.6, 0), 0.6, 1.0, c-fl, $A$)
  lens((1.6, 0), 0.6, 1.0, c-conn, $B$)

  arrow((-1.0, 0), (1.0, 0))
  draw.content((0, 0.4), text(size: s-cap, fill: c-ink)[$f$])

  let underbrace(x0, x1, y, body) = {
    let xc = (x0 + x1) / 2
    let w = x1 - x0
    let dip = 0.25
    draw.bezier(
      (x0, y),
      (xc, y - dip),
      (x0 + 0.3 * w, y),
      (xc - 0.3 * w, y - dip),
      stroke: c-edge + t-ed,
    )
    draw.bezier(
      (xc, y - dip),
      (x1, y),
      (xc + 0.3 * w, y - dip),
      (x1 - 0.3 * w, y),
      stroke: c-edge + t-ed,
    )
    draw.content((xc, y - dip - 0.22), text(size: s-cap, fill: c-ink)[#body])
  }

  underbrace(-2.25, -0.95, -1.3, "домен")
  underbrace(0.95, 2.25, -1.3, "кодомен")
})

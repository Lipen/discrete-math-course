// Функции: типы отображений, домен/кодомен, образ и прообраз, композиция, пол и потолок.
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

#let set-ellipse(pos, rx, ry, tone, fill, name: none) = draw.circle(
  pos,
  radius: (rx, ry),
  fill: fill,
  stroke: 0.7pt + tone.lighten(45%),
  name: name,
)

#let dom-el(name, pos) = vertex(name, pos, tone: cool, size: 0.13)
#let cod-el(name, pos) = cell(name, pos, tone: warm, size: 0.12, radius: 0.04)

#let map-edge(a, b, curve, style) = draw.bezier(
  a + ".east",
  b + ".west",
  (0, curve),
  stroke: style,
  mark: (end: (symbol: ">", fill: style.paint)),
)

// ── Инъекция: каждый элемент B задействован не более одного раза ──
#let mapping-injection = canvas({
  set-ellipse((-1.6, 0), 0.55, 1.15, cool, panel-cool)
  mark((-1.6, 1.5), $A$)
  dom-el("a1", (-1.6, -0.6))
  dom-el("a2", (-1.6, -0.2))
  dom-el("a3", (-1.6, 0.2))
  dom-el("a4", (-1.6, 0.6))

  set-ellipse((1.6, 0), 0.58, 1.45, warm, panel-warm)
  mark((1.6, 1.8), $B$)
  cod-el("b1", (1.6, -1.05))
  cod-el("b2", (1.6, -0.63))
  cod-el("b3", (1.6, -0.21))
  cod-el("b4", (1.6, 0.21))
  cod-el("b5", (1.6, 0.63))
  cod-el("b6", (1.6, 1.05))

  map-edge("a1", "b2", -0.9, edge-cool)
  map-edge("a2", "b5", 0.35, edge-cool)
  map-edge("a3", "b3", -0.35, edge-cool)
  map-edge("a4", "b6", 1.0, edge-cool)
})

// ── Сюръекция: каждый элемент B задействован хотя бы один раз ──
#let mapping-surjection = canvas({
  set-ellipse((-1.6, 0), 0.55, 1.45, cool, panel-cool)
  mark((-1.6, 1.8), $A$)
  dom-el("a1", (-1.6, -1.05))
  dom-el("a2", (-1.6, -0.63))
  dom-el("a3", (-1.6, -0.21))
  dom-el("a4", (-1.6, 0.21))
  dom-el("a5", (-1.6, 0.63))
  dom-el("a6", (-1.6, 1.05))

  set-ellipse((1.6, 0), 0.5, 0.95, warm, panel-warm)
  mark((1.6, 1.25), $B$)
  cod-el("b1", (1.6, -0.45))
  cod-el("b2", (1.6, 0))
  cod-el("b3", (1.6, 0.45))

  map-edge("a1", "b1", -1.0, edge-green)
  map-edge("a2", "b1", -0.55, edge-green)
  map-edge("a3", "b2", -0.35, edge-green)
  map-edge("a4", "b2", 0.35, edge-green)
  map-edge("a5", "b3", 0.55, edge-green)
  map-edge("a6", "b3", 1.0, edge-green)
})

// ── Биекция: и не более одного, и хотя бы один ──
#let mapping-bijection = canvas({
  set-ellipse((-1.6, 0), 0.55, 1.15, cool, panel-cool)
  mark((-1.6, 1.5), $A$)
  dom-el("a1", (-1.6, -0.6))
  dom-el("a2", (-1.6, -0.2))
  dom-el("a3", (-1.6, 0.2))
  dom-el("a4", (-1.6, 0.6))

  set-ellipse((1.6, 0), 0.55, 1.15, warm, panel-warm)
  mark((1.6, 1.5), $B$)
  cod-el("b1", (1.6, -0.75))
  cod-el("b2", (1.6, -0.25))
  cod-el("b3", (1.6, 0.25))
  cod-el("b4", (1.6, 0.75))

  map-edge("a1", "b3", 0.55, edge-hot)
  map-edge("a2", "b1", -0.8, edge-hot)
  map-edge("a3", "b4", 0.8, edge-hot)
  map-edge("a4", "b2", -0.55, edge-hot)
})

// ── Части функции: домен и кодомен, f: A -> B ──
#let function-parts = canvas({
  draw.circle(
    (-1.6, 0),
    radius: (0.6, 1.05),
    fill: panel-cool,
    stroke: 0.7pt + cool.lighten(45%),
    name: "set-a",
  )
  mark((-1.6, 1.4), $A$)
  draw.circle(
    (1.6, 0),
    radius: (0.6, 1.05),
    fill: panel-warm,
    stroke: 0.7pt + warm.lighten(45%),
    name: "set-b",
  )
  mark((1.6, 1.4), $B$)

  draw.line("set-a.east", "set-b.west", stroke: edge-cool, mark: (
    end: (symbol: ">", fill: cool),
  ))
  mark((0, 0.35), $f$, tone: cool)

  let underbrace(x0, x1, y, body) = {
    let xc = (x0 + x1) / 2
    let w = x1 - x0
    let dip = 0.25
    draw.bezier(
      (x0, y),
      (xc, y - dip),
      (x0 + 0.3 * w, y),
      (xc - 0.3 * w, y - dip),
      stroke: edge-thin,
    )
    draw.bezier(
      (xc, y - dip),
      (x1, y),
      (xc + 0.3 * w, y - dip),
      (x1 - 0.3 * w, y),
      stroke: edge-thin,
    )
    mark((xc, y - dip - 0.3), body)
  }

  underbrace(-2.25, -0.95, -1.3, [домен])
  underbrace(0.95, 2.25, -1.3, [кодомен])
})

// ── Образ и прообраз подмножества ──
#let image-preimage = canvas({
  set-ellipse((-1.9, 0), 0.72, 1.35, cool, panel-cool)
  mark((-1.9, 1.65), $A$)
  dom-el("ia1", (-1.9, -0.9))
  dom-el("ia2", (-1.9, -0.45))
  dom-el("ia3", (-1.9, 0))
  dom-el("ia4", (-1.9, 0.45))
  dom-el("ia5", (-1.9, 0.9))

  set-ellipse((1.9, 0), 0.78, 1.05, warm, panel-warm)
  mark((1.9, 1.35), $B$)
  cod-el("ib1", (1.9, -0.55))
  cod-el("ib2", (1.9, 0))
  cod-el("ib3", (1.9, 0.55))

  map-edge("ia1", "ib1", -0.85, edge-plain)
  map-edge("ia2", "ib1", -0.35, edge-plain)
  map-edge("ia3", "ib2", 0.15, edge-plain)
  map-edge("ia4", "ib3", 0.35, edge-plain)
  map-edge("ia5", "ib3", 0.85, edge-plain)

  let region(pos, radius) = draw.circle(pos, radius: radius, stroke: (
    paint: violet,
    thickness: 1.1pt,
    dash: "dashed",
  ))
  region((-1.9, -0.675), (0.36, 0.42))
  region((1.9, -0.55), 0.19)
  region((1.9, 0.55), 0.19)
  region((-1.9, 0.675), (0.36, 0.42))

  mark((-2.95, -0.675), $X$, tone: violet)
  mark((3.1, -0.55), $f(X)$, tone: violet)
  mark((3.1, 0.55), $Y$, tone: violet)
  mark((-3.35, 0.675), $f^(-1) (Y)$, tone: violet)
})

// ── Композиция двух отображений как конвейер ──
#let composition-pipeline = canvas({
  set-ellipse((-2.6, 0), 0.5, 0.95, cool, panel-cool, name: "set-a")
  mark((-2.6, 1.25), $A$)
  set-ellipse((0, 0), 0.5, 0.95, green, panel-green, name: "set-b")
  mark((0, 1.25), $B$)
  set-ellipse((2.6, 0), 0.5, 0.95, warm, panel-warm, name: "set-c")
  mark((2.6, 1.25), $C$)

  draw.line("set-a.east", "set-b.west", stroke: edge-plain, mark: (
    end: (symbol: ">", fill: edge-plain.paint),
  ))
  mark((-1.3, 0.32), $f$)
  draw.line("set-b.east", "set-c.west", stroke: edge-plain, mark: (
    end: (symbol: ">", fill: edge-plain.paint),
  ))
  mark((1.3, 0.32), $g$)

  draw.bezier(
    (-2.6, -0.9),
    (2.6, -0.9),
    (-1.5, -1.85),
    (1.5, -1.85),
    stroke: edge-hot,
    mark: (end: (symbol: ">", fill: edge-hot.paint)),
  )
  mark((0, -2.1), $g compose f$)
})

// ── Пол и потолок на числовой прямой ──
#let floor-ceil-line = canvas({
  draw.line((-2.9, 0), (4.2, 0), stroke: edge-plain, mark: (
    end: (symbol: ">", fill: edge-plain.paint),
  ))
  for k in range(-2, 4) {
    draw.line((k, -0.08), (k, 0.08), stroke: edge-thin)
    mark((k, -0.34), [#k])
  }

  draw.circle((2, 0), radius: 0.075, fill: green)
  draw.circle((2.7, 0), radius: 0.075, fill: ink)
  draw.circle((3, 0), radius: 0.075, fill: violet)
  mark((2, 0.42), $floor(x)$, tone: green)
  mark((2.7, -0.62), $x$)
  mark((3, 0.42), $ceil(x)$, tone: violet)

  draw.circle((-2, 0), radius: 0.075, fill: green)
  draw.circle((-1.3, 0), radius: 0.075, fill: ink)
  draw.circle((-1, 0), radius: 0.075, fill: violet)
  mark((-2, 0.42), $floor(x)$, tone: green)
  mark((-1.3, -0.62), $x$)
  mark((-1, 0.42), $ceil(x)$, tone: violet)
})

// ── Ступеньки пола и потолка ──
#let floor-ceil-steps = canvas({
  draw.line((-1.9, 0), (3.5, 0), stroke: edge-plain, mark: (
    end: (symbol: ">", fill: edge-plain.paint),
  ))
  draw.line((0, -1.9), (0, 3.5), stroke: edge-plain, mark: (
    end: (symbol: ">", fill: edge-plain.paint),
  ))
  mark((3.1, -0.35), $x$)
  mark((0.35, 3.15), $y$)

  let solid(pos, tone) = draw.circle(pos, radius: 0.055, fill: tone)
  let open(pos, tone) = draw.circle(
    pos,
    radius: 0.055,
    fill: white,
    stroke: 0.9pt + tone,
  )

  for k in range(-1, 3) {
    draw.line((k, k), (k + 1, k), stroke: (
      paint: green,
      thickness: 1.2pt,
      cap: "round",
    ))
    solid((k, k), green)
    open((k + 1, k), green)
  }

  for k in range(0, 3) {
    draw.line((k, k + 1), (k + 1, k + 1), stroke: (
      paint: violet,
      thickness: 1.2pt,
      cap: "round",
    ))
    open((k, k + 1), violet)
    solid((k + 1, k + 1), violet)
  }

  mark((3.55, 2.0), [пол], tone: green)
  mark((3.55, 3.0), [потолок], tone: violet)
})

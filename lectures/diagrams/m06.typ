// Функции: типы отображений, домен/кодомен, образ и прообраз, композиция, пол и потолок.
#import "@preview/cetz:0.5.2": canvas, draw
#import "../theme.typ": setminus
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

// ── Функция Дирихле: QQ и RR\QQ двумя цветами на прямой ──
#let dirichlet-line = canvas({
  let rationals = (0.5, 1, 1.5, 2, 2.5, 3)
  let irrationals = (0.707, 1.414, 1.732, 2.236)

  draw.line((-0.3, 0), (3.5, 0), stroke: edge-plain, mark: (
    end: (symbol: ">", fill: edge-plain.paint),
  ))
  mark((3.75, 0), $RR$)

  for x in rationals {
    draw.line((x, 0), (x, 0.52), stroke: edge-thin)
    draw.circle((x, 0.62), radius: 0.085, fill: cool)
  }
  for x in irrationals {
    draw.line((x, 0), (x, -0.52), stroke: edge-thin)
    draw.circle((x, -0.62), radius: 0.085, fill: violet)
  }

  mark((-0.85, 0.62), $QQ$, tone: cool)
  mark((-0.85, -0.62), $RR setminus QQ$, tone: violet)
  mark((4.0, 0.62), $D = 1$, tone: cool)
  mark((4.0, -0.62), $D = 0$, tone: violet)
  mark((0.5, 0.97), $1 slash 2$)
  mark((1.414, -0.99), $sqrt(2)$)
})

// ── Пол и потолок на числовой прямой ──
#let floor-ceil-line = canvas({
  draw.line((-3.7, 0), (4.3, 0), stroke: edge-plain, mark: (
    end: (symbol: ">", fill: edge-plain.paint),
  ))
  for k in range(-3, 4) {
    draw.line((k, -0.08), (k, 0.08), stroke: edge-thin)
    mark((k, -0.4), [#k], size: 0.7em)
  }

  let cluster(x, xl, xr, lbl) = {
    draw.circle((xl, 0), radius: 0.075, fill: green)
    draw.circle((x, 0), radius: 0.075, fill: ink)
    draw.circle((xr, 0), radius: 0.075, fill: violet)
    draw.line((xl, 0.1), (xl, 0.52), stroke: edge-thin)
    draw.line((xr, 0.1), (xr, 1.18), stroke: edge-thin)
    mark((xl, 0.72), $floor(#lbl)$, tone: green)
    mark((x, -0.78), $lbl$)
    mark((xr, 1.4), $ceil(#lbl)$, tone: violet)
  }

  cluster(2.7, 2, 3, $x_1$)
  cluster(-1.3, -2, -1, $x_2$)
})

// ── Ступеньки пола и потолка: две панели с чередующимся акцентом ──
#let steps-panel(focus) = canvas({
  mark((3.5, -0.4), $x$, size: 0.8em)
  mark((-0.4, 3.5), $y$, size: 0.8em)

  let fl = if focus == "floor" { green } else { green.transparentize(45%) }
  let ce = if focus == "ceil" { violet } else { violet.transparentize(45%) }
  let fl-lab = if focus == "floor" { (fill: green, weight: "bold") } else { (fill: green.transparentize(45%)) }
  let ce-lab = if focus == "ceil" { (fill: violet, weight: "bold") } else { (fill: violet.transparentize(45%)) }

  // ось тоньше ступеней: бледная ступень на y=0 читается поверх неё
  draw.line((-1.9, 0), (3.9, 0), stroke: edge-thin, mark: (
    end: (symbol: ">", fill: edge-plain.paint),
  ))
  draw.line((0, -1.9), (0, 3.9), stroke: edge-plain, mark: (
    end: (symbol: ">", fill: edge-plain.paint),
  ))

  // приглушённая лестница первой: жирная кладёт общие маркеры поверх неё
  if focus != "floor" {
    for k in range(-1, 3) {
      draw.line((k, k), (k + 1, k), stroke: (paint: fl, thickness: 1pt, cap: "round"))
      draw.circle((k, k), radius: 0.045, fill: fl)
      draw.circle((k + 1, k), radius: 0.045, fill: white, stroke: (paint: fl, thickness: 0.8pt))
    }
  } else {
    for k in range(-1, 3) {
      draw.line((k, k + 1), (k + 1, k + 1), stroke: (paint: ce, thickness: 1pt, cap: "round"))
      draw.circle((k, k + 1), radius: 0.045, fill: white, stroke: (paint: ce, thickness: 0.8pt))
      draw.circle((k + 1, k + 1), radius: 0.045, fill: ce)
    }
  }

  for k in range(-1, 3) {
    draw.line((k, k), (k + 1, k), stroke: (
      paint: fl,
      thickness: if focus == "floor" { 1.8pt } else { 1pt },
      cap: "round",
    ))
    draw.circle((k, k), radius: if focus == "floor" { 0.06 } else { 0.045 }, fill: fl)
    draw.circle(
      (k + 1, k),
      radius: if focus == "floor" { 0.06 } else { 0.045 },
      fill: white,
      stroke: (paint: fl, thickness: if focus == "floor" { 0.9pt } else { 0.8pt }),
    )
  }

  for k in range(-1, 3) {
    draw.line((k, k + 1), (k + 1, k + 1), stroke: (
      paint: ce,
      thickness: if focus == "ceil" { 1.8pt } else { 1pt },
      cap: "round",
    ))
    draw.circle(
      (k, k + 1),
      radius: if focus == "ceil" { 0.06 } else { 0.045 },
      fill: white,
      stroke: (paint: ce, thickness: if focus == "ceil" { 0.9pt } else { 0.8pt }),
    )
    draw.circle((k + 1, k + 1), radius: if focus == "ceil" { 0.06 } else { 0.045 }, fill: ce)
  }

  draw.content((3.6, 2), text(..fl-lab, size: label-size)[пол\ (floor)], anchor: "west")
  draw.content((3.6, 3), text(..ce-lab, size: label-size)[потолок\ (ceil)], anchor: "west")
})

#let floor-ceil-steps = grid(
  columns: (auto, auto),
  gutter: 2.5em,
  align: center,
  steps-panel("floor"), steps-panel("ceil"),
)

// ── Итерации на числовой прямой: точки $x_0, x_1, dots$ и дуги переходов ──
// xs --- положения точек на прямой, высота дуги растёт с номером шага.
#let iteration-dots(xs, tone) = canvas({
  draw.line((-3.9, 0), (4.0, 0), stroke: edge-thin, mark: (
    end: (symbol: ">", fill: edge-plain.paint),
  ))
  for k in range(-3, 4) {
    draw.line((k, -0.06), (k, 0.06), stroke: edge-thin)
  }
  mark((4.15, 0), $x$, size: 0.75em)

  let n = xs.len()
  for k in range(n) {
    draw.circle((xs.at(k), 0), radius: 0.09, fill: tone)
    let dy = if calc.odd(k) { -0.74 } else { -0.36 }
    mark((xs.at(k), dy), $x_#k$, tone: tone, size: 0.72em)
  }
  for k in range(n - 1) {
    let x0 = xs.at(k)
    let x1 = xs.at(k + 1)
    let h = 0.7 + 0.3 * k
    draw.bezier(
      (x0, 0.12),
      (x1, 0.12),
      (x0, h),
      (x1, h),
      stroke: (paint: tone, thickness: 1.2pt, cap: "round"),
      mark: (end: (symbol: ">", fill: tone)),
    )
  }
})

// ── Удвоение: итерации x, 2x, 4x, 8x уходят вправо, дуги растут ──
#let iteration-double = iteration-dots((0.2, 0.4, 0.8, 1.6, 3.2), edge-cool.paint)

// ── Инволюция f(x) = 1 - x на {0, 1}: две дуги-стрелки между точками ──
#let iteration-swap = canvas({
  draw.circle((0, 0), radius: 0.16, fill: edge-hot.paint.lighten(82%), stroke: 1.6pt + edge-hot.paint)
  draw.circle((2, 0), radius: 0.16, fill: edge-hot.paint.lighten(82%), stroke: 1.6pt + edge-hot.paint)
  mark((0, -0.48), $0$, tone: ink)
  mark((2, -0.48), $1$, tone: ink)
  draw.bezier(
    (0.17, 0.12),
    (1.83, 0.12),
    (0.55, 0.9),
    (1.45, 0.9),
    stroke: edge-hot,
    mark: (end: (symbol: ">", fill: edge-hot.paint)),
  )
  draw.bezier(
    (1.83, -0.12),
    (0.17, -0.12),
    (1.45, -0.9),
    (0.55, -0.9),
    stroke: edge-hot,
    mark: (end: (symbol: ">", fill: edge-hot.paint)),
  )
  mark((1, 1.2), $f$, tone: edge-hot.paint)
  mark((1, -1.2), $f$, tone: edge-hot.paint)
})

// ── Сетка Канторовой пары: цвет ячейки --- диагональ k_1 + k_2 = s ──
#let diag-green = panel-green
#let diag-amber = oklch(96%, 0.02, 70deg)
#let diag-violet = oklch(96%, 0.015, 300deg)
#let cantor-grid = table(
  columns: 4,
  align: center,
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header([ ], [$k_1 = 0$], [$k_1 = 1$], [$k_1 = 2$]),
  [$k_2 = 0$],
  table.cell(fill: diag-green)[0],
  table.cell(fill: diag-amber)[2],
  table.cell(fill: diag-violet)[5],
  [$k_2 = 1$],
  table.cell(fill: diag-amber)[1],
  table.cell(fill: diag-violet)[4],
  [8],
  [$k_2 = 2$],
  table.cell(fill: diag-violet)[3],
  [7],
  [12],
)

// ── Каррирование: f: A × B -> C превращается в curry f: A -> (B -> C) ──
#let curry-schema = canvas({
  set-ellipse((-2.6, 1.05), 0.95, 0.6, cool, panel-cool, name: "prod")
  mark((-2.6, 2.0), $A times B$)
  set-ellipse((2.6, 1.05), 0.62, 0.6, warm, panel-warm, name: "cset")
  mark((2.6, 2.0), $C$)
  draw.line("prod.east", "cset.west", stroke: edge-plain, mark: (
    end: (symbol: ">", fill: edge-plain.paint),
  ))
  mark((0, 1.4), $f$)

  set-ellipse((-2.6, -1.05), 0.62, 0.6, cool, panel-cool, name: "aset")
  mark((-2.6, -0.05), $A$)
  set-ellipse((2.6, -1.05), 0.95, 0.6, warm, panel-warm, name: "fun")
  mark((2.6, -0.05), $B -> C$)
  draw.line("aset.east", "fun.west", stroke: edge-hot, mark: (
    end: (symbol: ">", fill: edge-hot.paint),
  ))
  mark((0, -0.55), $"curry" f$, tone: warm)
})

// ── Гонка скоростей роста: log n, n, n log n, n^2, 2^n (масштаб условный) ──
#let growth-races = canvas({
  let xs(n) = n / 8
  draw.line((0, 0), (9.5, 0), stroke: edge-plain, mark: (
    end: (symbol: ">", fill: edge-plain.paint),
  ))
  draw.line((0, 0), (0, 4.7), stroke: edge-plain, mark: (
    end: (symbol: ">", fill: edge-plain.paint),
  ))
  mark((9.75, 0.2), $n$)
  mark((0.4, 4.85), $T(n)$)
  for t in (8, 16, 32, 64) {
    draw.line((xs(t), -0.08), (xs(t), 0.08), stroke: edge-thin)
    mark((xs(t), -0.38), [#t], size: 0.7em)
  }

  let curve(f, scale, stroke-style) = {
    let pts = range(1, 65).filter(n => calc.rem(n, 3) == 1).map(n => (xs(n), f(n) * scale))
    for i in range(1, pts.len()) {
      draw.line(pts.at(i - 1), pts.at(i), stroke: stroke-style)
    }
  }

  curve(n => calc.log(n, base: 2), 0.085, (paint: ink-soft, thickness: 1.2pt, cap: "round"))
  curve(n => n, 0.045, (paint: cool, thickness: 1.6pt, cap: "round"))
  curve(n => n * calc.log(n, base: 2), 0.009, (paint: green, thickness: 1.6pt, cap: "round"))
  curve(n => calc.pow(n, 2), 0.001, (paint: warm, thickness: 1.6pt, cap: "round"))

  let pts-exp = range(1, 24).map(n => (xs(n), 0.00000036 * calc.pow(2, n)))
  for i in range(1, pts-exp.len()) {
    draw.line(pts-exp.at(i - 1), pts-exp.at(i), stroke: edge-hot)
  }
  draw.line(pts-exp.last(), (3.15, 4.45), stroke: edge-hot, mark: (
    end: (symbol: ">", fill: edge-hot.paint),
  ))

  mark((8.9, 0.51), $log_2 n$, tone: ink-soft)
  mark((8.9, 2.88), $n$, tone: cool)
  mark((8.9, 3.46), $n log_2 n$, tone: green)
  mark((8.9, 4.1), $n^2$, tone: warm)
  mark((3.7, 4.3), $2^n$, tone: oklch(55%, 0.17, 25deg))
})

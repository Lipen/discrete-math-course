#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

// Локальные цвета: зелёная кривая (гауссова) и результирующая кривая операций.
#let c-gauss = oklch(46%, 0.13, 140deg)

#let c-res = oklch(40%, 0.16, 280deg)

// ── Функции принадлежности ──
#let membership-functions = canvas({
  let tx(x) = 0.5 + x * 0.7
  let ty(y) = 0.5 + y * 4.0

  let axis = c-edge + t-ed
  let tick = c-edge + t-hr
  let curve-stroke(color) = (paint: color, thickness: 1.1pt)

  draw.line((tx(0), ty(0)), (tx(10), ty(0)), stroke: axis)
  draw.line((tx(0), ty(0)), (tx(0), ty(1.2)), stroke: axis)
  draw.content((tx(5), ty(-0.5)), text(size: s-cap, fill: c-muted)[$x$])
  draw.content((tx(0) - 0.15, ty(1.24)), anchor: "east", text(
    size: s-cap,
    fill: c-muted,
  )[$mu(x)$])

  for i in range(1, 11) {
    draw.line((tx(i), ty(0) - 0.06), (tx(i), ty(0) + 0.06), stroke: tick)
    draw.content((tx(i), ty(-0.2)), text(size: s-tiny, fill: c-muted)[#i])
  }
  for (yy, lab) in ((0, "0"), (0.5, "0.5"), (1, "1")) {
    draw.line((tx(-0.06), ty(yy)), (tx(0.06), ty(yy)), stroke: tick)
    draw.content((tx(-0.15), ty(yy)), anchor: "east", text(
      size: s-tiny,
      fill: c-muted,
    )[#lab])
  }

  draw.line((tx(0), ty(1)), (tx(10), ty(1)), stroke: (
    paint: c-muted,
    thickness: t-hr,
    dash: "dashed",
  ))

  draw.line((tx(2), ty(0)), (tx(5), ty(1)), stroke: curve-stroke(c-accent))
  draw.line((tx(5), ty(1)), (tx(8), ty(0)), stroke: curve-stroke(c-accent))

  draw.line((tx(2), ty(0)), (tx(4), ty(1)), stroke: curve-stroke(c-hot))
  draw.line((tx(4), ty(1)), (tx(7), ty(1)), stroke: curve-stroke(c-hot))
  draw.line((tx(7), ty(1)), (tx(9), ty(0)), stroke: curve-stroke(c-hot))

  draw.bezier(
    (tx(2), ty(0)),
    (tx(5), ty(1)),
    (tx(3.2), ty(0.03)),
    (tx(4.3), ty(0.88)),
    stroke: curve-stroke(c-gauss),
  )
  draw.bezier(
    (tx(5), ty(1)),
    (tx(8), ty(0)),
    (tx(5.7), ty(0.88)),
    (tx(6.8), ty(0.03)),
    stroke: curve-stroke(c-gauss),
  )

  let ly = ty(1.32)
  let lx = tx(5.8)
  let lg = 0.55
  let ls = 0.22
  let legend-item(y, color, lab) = {
    draw.line((lx, y), (lx + lg, y), stroke: curve-stroke(color))
    draw.content((lx + lg + 0.15, y), anchor: "west", text(
      size: s-tiny,
      fill: c-muted,
    )[#lab])
  }

  legend-item(ly, c-accent, "Треугольная")
  legend-item(ly - ls, c-hot, "Трапецеидальная")
  legend-item(ly - 2 * ls, c-gauss, "Гауссова")
})

// ── Операции над нечёткими множествами ──
#let fuzzy-operations = canvas({
  let axis = c-edge + t-ed
  let tick = c-edge + t-hr
  let res-stroke = (paint: c-res, thickness: 1.2pt)

  let my(mu) = 0.5 + 2.5 * mu
  let p(ox, x, mu) = (ox + x, my(mu))

  let lab(at, body, color: c-muted, anchor: "center") = draw.content(
    at,
    text(size: s-tiny, fill: color)[#body],
    fill: white,
    stroke: none,
    padding: 2pt,
    anchor: anchor,
  )

  let panel-axes(ox, title) = {
    draw.line((ox + 0.5, my(0)), (ox + 4.0, my(0)), stroke: axis)
    draw.line((ox + 0.5, my(0)), (ox + 0.5, my(1)), stroke: axis)
    draw.line((ox + 0.42, my(0)), (ox + 0.5, my(0)), stroke: tick)
    draw.content((ox + 0.38, my(0)), anchor: "east", text(
      size: s-tiny,
      fill: c-muted,
    )[0])
    draw.line((ox + 0.42, my(1)), (ox + 0.5, my(1)), stroke: tick)
    draw.content((ox + 0.38, my(1)), anchor: "east", text(
      size: s-tiny,
      fill: c-muted,
    )[1])
    draw.content((ox + 2.25, my(-0.25)), text(size: s-cap, fill: c-muted)[$x$])
    draw.content((ox + 0.15, my(0.55)), anchor: "east", text(
      size: s-cap,
      fill: c-muted,
    )[$mu$])
    draw.content((ox + 2.25, my(1) + 0.5), text(
      size: s-cap,
      weight: "semibold",
      fill: c-muted,
    )[#title])
  }

  let dim-ab(ox) = {
    draw.line(p(ox, 0.8, 0), p(ox, 1.8, 1), stroke: 0.7pt + c-accent)
    draw.line(p(ox, 1.8, 1), p(ox, 2.8, 0), stroke: 0.7pt + c-accent)
    draw.line(p(ox, 1.8, 0), p(ox, 2.8, 1), stroke: 0.7pt + c-hot)
    draw.line(p(ox, 2.8, 1), p(ox, 3.8, 0), stroke: 0.7pt + c-hot)
  }

  let ab-labels(ox) = {
    lab(p(ox, 1.15, 0.72), $mu_A$, color: c-accent, anchor: "east")
    lab(p(ox, 3.4, 0.72), $mu_B$, color: c-hot, anchor: "west")
  }

  // ── Объединение (max) -- верхняя огибающая
  panel-axes(0, [Объединение ($max$)])
  draw.line(
    p(0, 0.8, 0),
    p(0, 1.8, 1),
    p(0, 2.3, 0.5),
    p(0, 2.8, 1),
    p(0, 3.8, 0),
    close: true,
    fill: c-fl,
    stroke: none,
  )
  dim-ab(0)
  draw.line(p(0, 0.8, 0), p(0, 1.8, 1), stroke: res-stroke)
  draw.line(p(0, 1.8, 1), p(0, 2.3, 0.5), stroke: res-stroke)
  draw.line(p(0, 2.3, 0.5), p(0, 2.8, 1), stroke: res-stroke)
  draw.line(p(0, 2.8, 1), p(0, 3.8, 0), stroke: res-stroke)
  ab-labels(0)

  // ── Пересечение (min) -- нижняя огибающая
  panel-axes(5, [Пересечение ($min$)])
  draw.line(
    p(5, 1.8, 0),
    p(5, 2.3, 0.5),
    p(5, 2.8, 0),
    close: true,
    fill: c-fl,
    stroke: none,
  )
  dim-ab(5)
  draw.line(p(5, 1.8, 0), p(5, 2.3, 0.5), stroke: res-stroke)
  draw.line(p(5, 2.3, 0.5), p(5, 2.8, 0), stroke: res-stroke)
  ab-labels(5)

  // ── Дополнение (1 - mu) -- зеркальная кривая
  panel-axes(10, [Дополнение ($1 - mu$)])
  draw.line(
    p(10, 0.8, 1),
    p(10, 1.8, 0),
    p(10, 2.8, 1),
    p(10, 2.8, 0),
    p(10, 0.8, 0),
    close: true,
    fill: c-fl,
    stroke: none,
  )
  draw.line(p(10, 0.8, 0), p(10, 1.8, 1), stroke: 0.7pt + c-accent)
  draw.line(p(10, 1.8, 1), p(10, 2.8, 0), stroke: 0.7pt + c-accent)
  draw.line(p(10, 0.8, 1), p(10, 1.8, 0), stroke: res-stroke)
  draw.line(p(10, 1.8, 0), p(10, 2.8, 1), stroke: res-stroke)
  lab(p(10, 0.9, 0.3), $mu_A$, color: c-accent, anchor: "west")
  lab(p(10, 0.9, 0.82), $mu_{not A}$, color: c-res, anchor: "west")
})

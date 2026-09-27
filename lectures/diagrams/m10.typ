// Булевы функции: карта Карно функции большинства и ROBDD для XOR.
#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/fletcher:0.5.8": diagram, edge, node
#import "style.typ": *

// ── Карта Карно: f = x y + x z + y z, единицы и склейки ──
#let k-grid = (paint: ink-soft, thickness: 0.5pt)
#let k-unit = green.lighten(72%)
#let k-loop(paint) = (paint: paint, thickness: 1.8pt, cap: "round")

#let karnaugh-3var-majority = canvas({
  let s = 0.62

  for i in range(5) {
    draw.line((0, -i * s), (2 * s, -i * s), stroke: k-grid)
  }
  for j in range(3) {
    draw.line((j * s, 0), (j * s, -4 * s), stroke: k-grid)
  }

  // Единицы --- минтермы функции большинства.
  for (row, col) in ((1, 1), (2, 0), (2, 1), (3, 1)) {
    draw.rect(
      (col * s + 0.05, -(row + 1) * s + 0.05),
      ((col + 1) * s - 0.05, -row * s - 0.05),
      fill: k-unit,
      stroke: none,
      radius: 0.09,
    )
  }

  // Склейки --- простые импликанты xz, yz, xy.
  draw.rect(
    (s + 0.09, -3 * s + 0.09),
    (2 * s - 0.09, -s - 0.09),
    stroke: k-loop(cool),
    radius: 0.12,
  )
  draw.rect(
    (0.09, -3 * s + 0.09),
    (2 * s - 0.09, -2 * s - 0.09),
    stroke: k-loop(green),
    radius: 0.12,
  )
  draw.rect(
    (s + 0.09, -4 * s + 0.09),
    (2 * s - 0.09, -2 * s - 0.09),
    stroke: k-loop(warm),
    radius: 0.12,
  )

  // Код Грея на осях.
  mark((0.5 * s, 0.24), [0])
  mark((1.5 * s, 0.24), [1])
  for (i, code) in ("00", "01", "11", "10").enumerate() {
    mark((-0.42, -(i + 0.5) * s), code)
  }

  draw.line((0.09, 0.5), (2 * s - 0.09, 0.5), stroke: k-grid)
  mark((s, 0.82), $x$)
  draw.line((-0.62, -0.07), (-0.62, -4 * s + 0.07), stroke: k-grid)
  mark((-0.98, -2 * s), $y z$)

  // Импликанты --- легендой справа, тоном в цвет своей склейки.
  let legend-x = 2 * s + 0.42
  mark((legend-x, -1.3 * s), $x z$, tone: cool)
  mark((legend-x, -2.5 * s), $y z$, tone: green)
  mark((legend-x, -3.7 * s), $x y$, tone: warm)
})

// ── ROBDD: x xor y со слитыми листьями ──
#let bdd-xor = {
  let vnode(pos, name, body) = node(
    pos,
    text(fill: ink)[#body],
    name: name,
    shape: circle,
    fill: cool.lighten(82%),
    stroke: (paint: cool, thickness: 1.1pt),
    inset: 0pt,
    width: 1.6em,
    height: 1.6em,
  )
  let leaf(pos, name, val, tone) = node(
    pos,
    text(fill: ink)[#val],
    name: name,
    fill: tone.lighten(80%),
    stroke: (paint: tone, thickness: 1pt),
    inset: 3pt,
  )
  let branch(from, to, bit, label-pos: 30%) = edge(
    from,
    to,
    "-",
    stroke: if bit == 0 {
      (paint: ink-soft, thickness: 0.7pt, dash: "dashed")
    } else {
      edge-hot
    },
    label: text(fill: ink)[$#bit$],
    label-pos: label-pos,
    label-side: center,
    label-fill: white,
  )

  diagram(
    spacing: 2.8em,
    vnode((0, 0), <x>, $x$),
    vnode((-1.6, 1), <y-lo>, $y$),
    vnode((1.6, 1), <y-hi>, $y$),
    leaf((-0.8, 2), <t0>, $0$, ink-soft),
    leaf((0.8, 2), <t1>, $1$, green),
    branch(<x>, <y-lo>, 0),
    branch(<x>, <y-hi>, 1),
    branch(<y-lo>, <t0>, 0),
    branch(<y-lo>, <t1>, 1, label-pos: 22%),
    branch(<y-hi>, <t1>, 0),
    branch(<y-hi>, <t0>, 1, label-pos: 22%),
  )
}

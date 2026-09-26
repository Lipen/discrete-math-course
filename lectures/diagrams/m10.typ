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
      (col * s + 0.035, -(row + 1) * s + 0.035),
      ((col + 1) * s - 0.035, -row * s - 0.035),
      fill: k-unit,
      stroke: none,
      radius: 0.07,
    )
  }

  // Склейки --- простые импликанты xz, yz, xy.
  draw.rect(
    (s + 0.07, -3 * s + 0.07),
    (2 * s - 0.07, -s - 0.07),
    stroke: k-loop(cool),
    radius: 0.09,
  )
  draw.rect(
    (0.07, -3 * s + 0.07),
    (2 * s - 0.07, -2 * s - 0.07),
    stroke: k-loop(green),
    radius: 0.09,
  )
  draw.rect(
    (s + 0.07, -4 * s + 0.07),
    (2 * s - 0.07, -2 * s - 0.07),
    stroke: k-loop(warm),
    radius: 0.09,
  )

  // Код Грея на осях.
  mark((0.5 * s, 0.2), [0], size: 0.45em)
  mark((1.5 * s, 0.2), [1], size: 0.45em)
  for (i, code) in ("00", "01", "11", "10").enumerate() {
    mark((-0.38, -(i + 0.5) * s), code, size: 0.45em)
  }

  draw.line((0.08, 0.38), (2 * s - 0.08, 0.38), stroke: k-grid)
  mark((s, 0.62), $x$, size: 0.5em)
  draw.line((-0.62, -0.06), (-0.62, -4 * s + 0.06), stroke: k-grid)
  mark((-0.9, -2 * s), $y z$, size: 0.5em)

  mark((1.5 * s, -1.5 * s), $x z$, size: 0.5em, tone: cool)
  mark((0.5 * s, -2.5 * s), $y z$, size: 0.5em, tone: green)
  mark((1.5 * s, -3.5 * s), $x y$, size: 0.5em, tone: warm)
})

// ── ROBDD: x xor y со слитыми листьями ──
#let bdd-xor = {
  let vnode(pos, name, body) = node(
    pos,
    text(size: 0.8em, fill: ink)[#body],
    name: name,
    shape: circle,
    fill: white,
    stroke: (paint: cool, thickness: 1.1pt),
    inset: 0pt,
    width: 1.6em,
    height: 1.6em,
  )
  let leaf(pos, name, val, tone) = node(
    pos,
    text(size: 0.8em, fill: ink)[#val],
    name: name,
    fill: white,
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
    label: text(size: 0.5em, fill: ink)[$#bit$],
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

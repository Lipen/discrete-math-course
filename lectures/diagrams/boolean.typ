// Булевы функции: куб Q3, цикл Грея, треугольник XOR, карта Карно и ROBDD.
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

// ── Q3 как куб: передняя грань z = 0, задняя z = 1 ──
#let q3-layout = (
  "000": (0.0, 0.0),
  "100": (2.1, 0.0),
  "010": (0.0, 2.1),
  "110": (2.1, 2.1),
  "001": (1.0, 1.0),
  "101": (3.1, 1.0),
  "011": (1.0, 3.1),
  "111": (3.1, 3.1),
)

#let q3-edges = (
  ("000", "100"),
  ("000", "010"),
  ("100", "110"),
  ("010", "110"),
  ("001", "101"),
  ("001", "011"),
  ("101", "111"),
  ("011", "111"),
  ("000", "001"),
  ("100", "101"),
  ("010", "011"),
  ("110", "111"),
)

#let q3-cube(highlight: (), tone: cool) = canvas({
  let on(v) = highlight.contains(v)
  for (a, b) in q3-edges {
    draw.line(
      q3-layout.at(a),
      q3-layout.at(b),
      stroke: if on(a) and on(b) {
        (paint: tone, thickness: 2.4pt, cap: "round")
      } else {
        edge-thin
      },
    )
  }
  for (name, pos) in q3-layout {
    draw.circle(
      pos,
      radius: 0.34,
      fill: if on(name) { tone.lighten(78%) } else { white },
      stroke: if on(name) { 1.8pt + tone } else { 0.9pt + ink-soft },
    )
    draw.content(pos, text(0.70em, fill: ink)[#name])
  }
})

#let q3-gray-cycle = canvas({
  let cycle = (
    ("000", "001"),
    ("001", "011"),
    ("011", "010"),
    ("010", "110"),
    ("110", "111"),
    ("111", "101"),
    ("101", "100"),
    ("100", "000"),
  )
  for (a, b) in q3-edges {
    draw.line(q3-layout.at(a), q3-layout.at(b), stroke: edge-thin)
  }
  for (a, b) in cycle {
    draw.line(
      q3-layout.at(a),
      q3-layout.at(b),
      stroke: (paint: warm, thickness: 2.6pt, cap: "round"),
    )
  }
  for (name, pos) in q3-layout {
    draw.circle(pos, radius: 0.34, fill: white, stroke: 0.9pt + ink-soft)
    draw.content(pos, text(0.70em, fill: ink)[#name])
  }
})

// ── Треугольник XOR: строки значений, первые элементы --- коэффициенты ──
#let xor-triangle(rows: ()) = canvas({
  let h = 0.82
  for (r, row) in rows.enumerate() {
    let offset = r * 0.5
    for (i, val) in row.enumerate() {
      draw.content(
        (offset + i, -r * h),
        text(
          0.9em,
          weight: if i == 0 { "bold" } else { "regular" },
          fill: if i == 0 { ink } else { ink-soft },
        )[#val],
      )
    }
  }
})

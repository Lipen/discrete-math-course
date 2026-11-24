// Булевы функции: куб Q3, цикл Грея, треугольник XOR, суперпозиция, решётка Поста, карта Карно и ROBDD.
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

// ── Треугольник XOR: значения в кружках, первые элементы строк --- коэффициенты ──
#let xor-triangle(rows: ()) = canvas({
  let dx = 1.5
  let dy = 1.15
  let radius = 0.48
  let tones = (cool, green, warm, violet)

  for (row-index, row) in rows.enumerate() {
    let tone = tones.at(calc.rem(row-index, tones.len()))
    let offset = row-index * dx
    for (i, val) in row.enumerate() {
      let pos = (offset + i * dx, -row-index * dy)
      let first = i == 0
      draw.circle(
        pos,
        radius: radius,
        fill: if first { tone.lighten(78%) } else { tone.lighten(92%) },
        stroke: if first {
          (paint: tone, thickness: 1.8pt)
        } else {
          (paint: tone.lighten(30%), thickness: 0.8pt)
        },
      )
      draw.content(
        pos,
        text(
          1em,
          weight: if first { "bold" } else { "regular" },
          fill: ink,
        )[#val],
      )
    }
  }
})

// ── Суперпозиция: входы, функции g_i, внешняя f ──
#let superposition-diagram = {
  let box(pos, name, body, tone: cool) = node(
    pos,
    text(fill: ink)[#body],
    name: name,
    fill: tone.lighten(88%),
    stroke: (paint: tone, thickness: 1pt),
    inset: 5pt,
    width: 2.4em,
    height: 1.7em,
  )
  let wire(from, to) = edge(from, to, "->", stroke: edge-plain)
  diagram(
    spacing: 2.2em,
    node(
      (0, 0),
      $x_1, ..., x_m$,
      name: <in>,
      fill: none,
      stroke: none,
      inset: 2pt,
    ),
    box((2, -1.3), <g1>, $g_1$),
    box((2, 0), <g2>, $g_2$),
    box((2, 1.3), <g3>, $g_3$),
    box((4, 0), <f>, $f$, tone: green),
    node(
      (6, 0),
      $h$,
      name: <out>,
      fill: none,
      stroke: none,
      inset: 2pt,
    ),
    wire(<in>, <g1>),
    wire(<in>, <g2>),
    wire(<in>, <g3>),
    wire(<g1>, <f>),
    wire(<g2>, <f>),
    wire(<g3>, <f>),
    wire(<f>, <out>),
  )
}

// ── Схема решётки Поста: P2, пять предполных классов, проекции ──
#let post-lattice-scheme = {
  let class-node(pos, name, body) = node(
    pos,
    text(fill: ink)[#body],
    name: name,
    fill: cool.lighten(88%),
    stroke: (paint: cool, thickness: 1pt),
    inset: 5pt,
    width: 2.2em,
    height: 1.6em,
  )
  let wire(from, to) = edge(from, to, "-", stroke: edge-thin)
  let schematic-wire(from, to) = edge(from, to, "-", stroke: (
    paint: edge-thin.paint,
    thickness: edge-thin.thickness,
    dash: "dashed",
  ))
  diagram(
    spacing: 2.2em,
    node(
      (0, 0),
      $P_2$,
      name: <top>,
      fill: green.lighten(88%),
      stroke: (paint: green, thickness: 1pt),
      inset: 5pt,
    ),
    class-node((-2, 1.5), <t0>, $T_0$),
    class-node((-1, 1.5), <t1>, $T_1$),
    class-node((0, 1.5), <s>, $S$),
    class-node((1, 1.5), <m>, $M$),
    class-node((2, 1.5), <l>, $L$),
    node(
      (0, 3),
      [проекции],
      name: <bot>,
      fill: luma(95%),
      stroke: (paint: ink-soft, thickness: 0.9pt),
      inset: 5pt,
    ),
    wire(<top>, <t0>),
    wire(<top>, <t1>),
    wire(<top>, <s>),
    wire(<top>, <m>),
    wire(<top>, <l>),
    schematic-wire(<t0>, <bot>),
    schematic-wire(<t1>, <bot>),
    schematic-wire(<s>, <bot>),
    schematic-wire(<m>, <bot>),
    schematic-wire(<l>, <bot>),
  )
}

// ── Теорема Стоуна: булеан двух атомов ──
#let stone-diamond = canvas({
  let pos = (
    "11": (0, 2.0),
    "01": (-1.35, 1.0),
    "10": (1.35, 1.0),
    "00": (0, 0),
  )
  let atoms = ("01", "10")

  for (a, b) in (("00", "01"), ("00", "10"), ("01", "11"), ("10", "11")) {
    draw.line(pos.at(a), pos.at(b), stroke: edge-thin)
  }

  for (name, p) in pos {
    let is-atom = atoms.contains(name)
    draw.circle(
      p,
      radius: 0.46,
      fill: if is-atom { green.lighten(82%) } else { white },
      stroke: if is-atom {
        (paint: green, thickness: 1.8pt)
      } else {
        (paint: ink-soft, thickness: 0.9pt)
      },
    )
    draw.content(p, text(0.76em, fill: ink)[#name])
  }
})

// ── Раунд AES: SubBytes, ShiftRows, MixColumns, AddRoundKey ──
#let aes-round = canvas({
  let w = 2.4
  let h = 0.8
  let stage(x, label, tone: cool) = {
    draw.rect(
      (x - w / 2, -h / 2),
      (x + w / 2, h / 2),
      fill: tone.lighten(90%),
      stroke: (paint: tone, thickness: 1pt),
      radius: 3pt,
    )
    draw.content((x, 0), text(0.70em, weight: "bold")[#label])
  }
  let arrow(x1, x2) = draw.line(
    (x1, 0),
    (x2, 0),
    stroke: edge-plain,
    mark: (end: "stealth"),
  )

  stage(0, [SubBytes], tone: green)
  stage(2.9, [ShiftRows])
  stage(5.8, [MixColumns])
  stage(8.7, [AddRoundKey])

  arrow(1.25, 1.65)
  arrow(4.15, 4.55)
  arrow(7.05, 7.45)
  arrow(-1.4, -1.2)
  arrow(9.95, 10.15)

  mark((4.35, -0.85), [10/12/14 раундов], tone: ink-soft)
})

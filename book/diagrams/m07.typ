#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw
#import fletcher: diagram, edge, node

// ── Диагональ Кантора: R несчётно ──
#let cantor-diagonal = canvas({
  let s = 0.72
  let rows = 5
  let cols = 7
  let digits = (
    (5, 1, 8, 4, 2, 6, 9),
    (2, 7, 3, 6, 9, 1, 4),
    (9, 0, 4, 1, 1, 7, 3),
    (6, 5, 7, 3, 3, 8, 0),
    (1, 4, 2, 8, 5, 7, 1),
  )
  let constructed = (4, 4, 5, 4, 4)

  draw.rect(
    (-0.7, 0.5),
    (cols * s + 0.2, -(rows + 0.3) * s),
    fill: c-fl,
    stroke: none,
    radius: 4pt,
  )

  for i in range(rows) {
    draw.content((-0.4, -(i + 0.5) * s), text(
      size: s-tiny,
      fill: c-muted,
    )[$r_#(i + 1)$])
    for j in range(cols) {
      let x = j * s + 0.1
      let y = -(i + 0.5) * s
      if i == j {
        // Диагональная ячейка подсвечена: её цифра задаёт разряд числа r.
        draw.rect(
          (x + 0.05, y - 0.32),
          (x + s - 0.05, y + 0.32),
          fill: c-warn,
          stroke: c-hot + 0.8pt,
          radius: 2pt,
          name: "d" + str(i),
        )
      }
      draw.content((x + s / 2, y), text(
        size: s-cap,
        fill: if i == j { c-hot } else { c-ink },
        weight: if i == j { "bold" } else { "regular" },
      )[#digits.at(i).at(j)])
    }
  }

  draw.content((cols * s + 0.5, -(rows / 2) * s), text(
    size: s-tiny,
    fill: c-muted,
  )[$dots$])

  // Конструируемое число r = 0.44544 (не встречается в перечислении).
  draw.content((-0.4, -(rows + 1.2) * s), text(
    size: s-cap,
    weight: "bold",
    fill: c-accent,
  )[$r = 0.$])
  for j in range(rows) {
    draw.content(
      (j * s + s / 2 + 0.1, -(rows + 1.2) * s),
      name: "r" + str(j),
      text(size: s-node, fill: c-accent, weight: "bold")[#constructed.at(j)],
    )
  }
  draw.content(
    (cols * s + 0.3, -(rows + 1.2) * s),
    text(size: s-cap, fill: c-hot)[$dots not in {r_1, r_2, dots}$],
  )

  for i in range(rows) {
    draw.line(
      "d" + str(i) + ".south",
      "r" + str(i) + ".north",
      stroke: (
        paint: c-accent.transparentize(50%),
        thickness: t-ed,
        dash: "dashed",
      ),
      name: "arr" + str(i),
    )
  }
  for i in range(rows) {
    draw.content(
      (rel: (0, 0.2), to: "r" + str(i) + ".north"),
      text(size: s-tiny, fill: c-hot)[$≠$],
      frame: "rect",
      fill: c-white,
      stroke: none,
      padding: 0.6pt,
    )
  }
})

// ── Диагональная нумерация пар ──
// Локальная подсветка диагоналей: оттенок ячейки кодирует её диагональ d = i + j.
#let qq-pairing = canvas(y: -1, {
  let size = 5
  let diag-fill(d) = oklch(75%, 0.1, 260deg - d * 30deg).transparentize(80%)

  for i in range(size) {
    draw.content((i + 0.5, 0), anchor: "south", padding: 0.3, text(
      size: s-cap,
      fill: c-muted,
    )[$#i$])
    draw.content((0, i + 0.5), anchor: "east", padding: 0.3, text(
      size: s-cap,
      fill: c-muted,
    )[$#i$])
  }

  // Путь по диагоналям: клетки в порядке возрастания s = i + j.
  let cells = ()
  for s in range(2 * size - 1) {
    for i in range(calc.max(0, s - (size - 1)), calc.min(size - 1, s) + 1) {
      cells.push((i, s - i))
    }
  }
  let path-col = c-hot.transparentize(50%)
  for idx in range(0, cells.len()) {
    let (ci, cj) = cells.at(idx)
    if idx > 0 {
      let (pi, pj) = cells.at(idx - 1)
      draw.line(
        (pj + 0.5, pi + 0.5),
        (cj + 0.5, ci + 0.5),
        stroke: t-ed + path-col,
        mark: (end: "stealth", fill: path-col),
      )
    }
    draw.content(
      (cj + 0.5, ci),
      anchor: "north",
      padding: 0.1,
      text(size: s-tiny, fill: c-hot, weight: "bold")[#idx],
    )
  }

  for i in range(size) {
    for j in range(size) {
      let n = i + j
      draw.rect(
        (j, i),
        (j + 1, i + 1),
        fill: diag-fill(n),
        stroke: t-hr + c-bd.transparentize(75%),
      )
      draw.content(
        (j + 0.5, i + 1),
        anchor: "south",
        padding: 0.1,
        text(size: s-cap, fill: c-ink)[$(#i, #j)$],
      )
    }
  }
})

// ── Диаграмма Хассе булеана ──
#let power-set-hasse = diagram(
  node-shape: rect,
  node-fill: c-atom,
  node-stroke: t-bd + c-bd,
  node-inset: 5pt,
  node-outset: 2pt,
  spacing: (3cm, 1.6cm),
  node((0, 0), text(size: s-node, fill: c-ink)[${a, b, c}$], name: <abc>),
  node((-1, 1), text(size: s-node, fill: c-ink)[${a, b}$], name: <ab>),
  node((0, 1), text(size: s-node, fill: c-ink)[${a, c}$], name: <ac>),
  node((1, 1), text(size: s-node, fill: c-ink)[${b, c}$], name: <bc>),
  node((-1, 2), text(size: s-node, fill: c-ink)[${a}$], name: <a>),
  node((0, 2), text(size: s-node, fill: c-ink)[${b}$], name: <b>),
  node((1, 2), text(size: s-node, fill: c-ink)[${c}$], name: <c>),
  node((0, 3), text(size: s-node, fill: c-ink)[$emptyset$], name: <e>),
  edge(<e>, <a>, "->", stroke: t-ed + c-edge),
  edge(<e>, <b>, "->", stroke: t-ed + c-edge),
  edge(<e>, <c>, "->", stroke: t-ed + c-edge),
  edge(<a>, <ab>, "->", stroke: t-ed + c-edge),
  edge(<a>, <ac>, "->", stroke: t-ed + c-edge),
  edge(<b>, <ab>, "->", stroke: t-ed + c-edge),
  edge(<b>, <bc>, "->", stroke: t-ed + c-edge),
  edge(<c>, <ac>, "->", stroke: t-ed + c-edge),
  edge(<c>, <bc>, "->", stroke: t-ed + c-edge),
  edge(<ab>, <abc>, "->", stroke: t-ed + c-edge),
  edge(<ac>, <abc>, "->", stroke: t-ed + c-edge),
  edge(<bc>, <abc>, "->", stroke: t-ed + c-edge),
)

// ── Биекция отрезка на квадрат ──
#let cantor-line-square = canvas({
  let w = 2
  let gap = 1.5

  draw.line((0, 0), (w, 0), mark: (symbol: "|"))
  draw.content((w / 2, w / 2), text(size: s-node, fill: c-ink)[$L = [0,1]$])

  draw.rect((w + gap, 0), (w + gap + w, w), fill: c-fl, stroke: t-bd + c-bd)
  draw.content((w + gap + w / 2, w / 2), text(
    size: s-node,
    fill: c-ink,
  )[$S = [0,1]^2$])

  draw.content((w + gap / 2, w / 2), text(size: s-cap, fill: c-muted)[$approx$])
})

// ── Цепочки алеф-бет ──
// Семантические цвета цепочек: алеф-цепь (преемник) --- тёплая, бет-цепь (булеан) --- зелёная.
// Зелёный штрих булеана --- единственный локальный цвет: для него нет токена.
#let aleph-beth = {
  let c-pow-str = oklch(50%, 0.10, 155deg)

  let anode(pos, name, body, fill, str) = node(
    pos,
    text(size: s-node, fill: c-ink)[#body],
    name: name,
    fill: fill,
    stroke: t-bd + str,
    inset: 5pt,
    corner-radius: 5pt,
  )

  diagram(
    spacing: (3.4cm, 1.9cm),
    anode((0, 1), <start>, $aleph_0 = beth_0 = abs(NN)$, c-fl, c-bd),
    anode((1, 0), <a1>, $aleph_1$, c-warn, c-hot),
    anode((2, 0), <a2>, $aleph_2$, c-warn, c-hot),
    anode((3, 0), <a3>, $aleph_3$, c-warn, c-hot),
    anode((1, 2), <b1>, $beth_1 = 2^(aleph_0)$, c-atom, c-pow-str),
    anode((2, 2), <b2>, $beth_2 = 2^(beth_1)$, c-atom, c-pow-str),
    anode((3, 2), <b3>, $beth_3 = 2^(beth_2)$, c-atom, c-pow-str),

    edge(
      <start>,
      <a1>,
      "->",
      stroke: t-ed + c-hot,
      label: text(
        size: s-tiny,
        fill: c-muted,
      )[следующий],
      label-side: left,
    ),
    edge(
      <start>,
      <b1>,
      "->",
      stroke: t-ed + c-pow-str,
      label: text(
        size: s-tiny,
        fill: c-muted,
      )[булеан],
      label-side: right,
    ),
    edge(<a1>, <a2>, "->", stroke: t-ed + c-hot),
    edge(<a2>, <a3>, "->", stroke: t-ed + c-hot),
    edge(<b1>, <b2>, "->", stroke: t-ed + c-pow-str),
    edge(<b2>, <b3>, "->", stroke: t-ed + c-pow-str),

    // Континуум-гипотеза: вопрос между aleph_1 и beth_1.
    edge(
      <a1>,
      <b1>,
      "-",
      stroke: (paint: c-muted, thickness: 1pt, dash: "dashed"),
      label: text(size: s-node, fill: c-hot, weight: "bold")[$?$],
      label-fill: c-white,
      label-side: center,
    ),
  )
}

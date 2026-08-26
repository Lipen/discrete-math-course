#import "../requirements.typ": *
#import "../notation.typ": *
#import "style.typ": *

#import cetz: canvas, draw

// ── Диагональ Кантора: R несчётно ──
#let cantor-diagonal = canvas({
  let s = 0.72
  let rows = 5
  let cols = 7
  let digits = (
    (3, 5, 2, 7, 1, 4, 8),
    (1, 8, 4, 6, 2, 9, 0),
    (7, 2, 5, 9, 3, 0, 6),
    (0, 3, 1, 8, 6, 2, 7),
    (9, 4, 7, 2, 0, 5, 3),
  )
  let constructed = (4, 4, 4, 4, 4)

  draw.rect(
    (-0.7, 0.5),
    (cols * s + 0.2, -(rows + 0.3) * s),
    fill: c-fl,
    stroke: none,
    radius: 4pt,
  )

  for i in range(rows) {
    draw.content((-0.4, -(i + 0.5) * s), text(size: s-tiny, fill: c-muted)[$r_#(i + 1)$])
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

  draw.content((cols * s + 0.5, -(rows / 2) * s), text(size: s-tiny, fill: c-muted)[$dots$])

  // Конструируемое число r = 0.44444 (не встречается в перечислении).
  draw.content((-0.4, -(rows + 1.2) * s), text(size: s-cap, weight: "bold", fill: c-accent)[$r = 0.$])
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
      (i * s + s / 2 + 0.1, -(rows + 0.7) * s),
      text(size: s-tiny, fill: c-hot)[$≠$],
      frame: "rect",
      fill: white,
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

  for i in range(1, size + 1) {
    draw.content((i + 0.5, 1), anchor: "south", padding: 0.3, text(size: s-cap, fill: c-muted)[$#i$])
    draw.content((1, i + 0.5), anchor: "east", padding: 0.3, text(size: s-cap, fill: c-muted)[$#i$])
  }

  // Путь по диагоналям: клетки в порядке возрастания s = i + j.
  let cells = ()
  for s in range(2, size * size) {
    for i in range(calc.max(1, s - size), calc.min(size, s - 1) + 1) {
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
      text(size: s-tiny, fill: c-hot, weight: "bold")[#(idx + 1)],
    )
  }

  for i in range(1, size + 1) {
    for j in range(1, size + 1) {
      let n = i + j + 1
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
#let power-set-hasse = canvas({
  let xgap = 2
  let ygap = 1.5
  let w = 1.4
  let h = 0.6

  let node(pos, label, name) = {
    let (x, y) = pos
    draw.rect(
      (x - w / 2, y + h / 2),
      (x + w / 2, y - h / 2),
      name: name,
      fill: c-atom,
      stroke: t-bd + c-bd,
      radius: 4pt,
    )
    draw.content((x, y), text(size: s-node, fill: c-ink)[#label])
  }

  let subset-edge(from-name, to-name) = {
    draw.line(
      from-name,
      to-name,
      stroke: t-ed + c-edge,
      mark: (end: "stealth", fill: c-edge),
    )
  }

  node((0, ygap * 3), ${a, b, c}$, "abc")
  node((-xgap, ygap * 2), ${a, b}$, "ab")
  node((0, ygap * 2), ${a, c}$, "ac")
  node((xgap, ygap * 2), ${b, c}$, "bc")
  node((-xgap, ygap), ${a}$, "a")
  node((0, ygap), ${b}$, "b")
  node((xgap, ygap), ${c}$, "c")
  node((0, 0), $emptyset$, "e")

  subset-edge("e", "a")
  subset-edge("e", "b")
  subset-edge("e", "c")
  subset-edge("a", "ab")
  subset-edge("a", "ac")
  subset-edge("b", "ab")
  subset-edge("b", "bc")
  subset-edge("c", "ac")
  subset-edge("c", "bc")
  subset-edge("ab", "abc")
  subset-edge("ac", "abc")
  subset-edge("bc", "abc")
})

// ── Биекция отрезка на квадрат ──
#let cantor-line-square = canvas({
  let w = 2
  let gap = 1.5

  draw.line((0, 0), (w, 0), mark: (symbol: "|"))
  draw.content((w / 2, w / 2), text(size: s-node, fill: c-ink)[$L = [0,1]$])

  draw.rect((w + gap, 0), (w + gap + w, w), fill: c-fl, stroke: t-bd + c-bd)
  draw.content((w + gap + w / 2, w / 2), text(size: s-node, fill: c-ink)[$S = [0,1]^2$])

  draw.content((w + gap / 2, w / 2), text(size: s-cap, fill: c-muted)[$approx$])
})

// ── Цепочки алеф-бет ──
// Семантические цвета цепочек: алеф-цепь (преемник) --- тёплая, бет-цепь (булеан) --- зелёная.
// Зелёный штрих булеана --- единственный локальный цвет: для него нет токена.
#let aleph-beth = canvas({
  let gap = 2.6
  let y = 1.6

  let c-pow-str = oklch(50%, 0.10, 155deg)

  let node(pos, label, name, fill, str) = {
    let (x, yy) = pos
    draw.rect(
      (x - 1.3, yy + 0.45),
      (x + 1.3, yy - 0.45),
      name: name,
      fill: fill,
      stroke: t-bd + str,
      radius: 5pt,
    )
    draw.content((x, yy), text(size: s-node, fill: c-ink)[#label])
  }

  // Общее начало: aleph_0 = beth_0 = |N|.
  node((0, y), $aleph_0 = beth_0 = abs(NN)$, "start", c-fl, c-bd)

  node((gap, 2 * y), $aleph_1$, "a1", c-warn, c-hot)
  node((2 * gap, 2 * y), $aleph_2$, "a2", c-warn, c-hot)
  node((3 * gap, 2 * y), $aleph_3$, "a3", c-warn, c-hot)

  node((gap, 0), $beth_1 = 2^(aleph_0)$, "b1", c-atom, c-pow-str)
  node((2 * gap, 0), $beth_2 = 2^(beth_1)$, "b2", c-atom, c-pow-str)
  node((3 * gap, 0), $beth_3 = 2^(beth_2)$, "b3", c-atom, c-pow-str)

  draw.line("start", "a1", stroke: t-ed + c-hot, mark: (end: "stealth", fill: c-hot))
  draw.line("start", "b1", stroke: t-ed + c-pow-str, mark: (end: "stealth", fill: c-pow-str))

  draw.line("a1", "a2", stroke: t-ed + c-hot, mark: (end: "stealth", fill: c-hot))
  draw.line("a2", "a3", stroke: t-ed + c-hot, mark: (end: "stealth", fill: c-hot))

  draw.line("b1", "b2", stroke: t-ed + c-pow-str, mark: (end: "stealth", fill: c-pow-str))
  draw.line("b2", "b3", stroke: t-ed + c-pow-str, mark: (end: "stealth", fill: c-pow-str))

  // Континуум-гипотеза: вопрос между aleph_1 и beth_1.
  draw.line("a1", "b1", stroke: (paint: c-muted, thickness: 1pt, dash: "dashed"), mark: none)
  draw.content(
    (gap, y + 0.25),
    text(size: s-node, fill: c-hot, weight: "bold")[$?$],
    frame: "rect",
    fill: white,
    stroke: none,
    padding: 0.6pt,
  )

  draw.content((gap / 2, 2 * y + 0.6), text(size: s-tiny, fill: c-muted)[следующий])
  draw.content((gap / 2, -0.6), text(size: s-tiny, fill: c-muted)[булеан])
})

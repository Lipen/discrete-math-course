// Мощность: диагональ Кантора, спаривание QQ, отрезок и квадрат, алефы и беты, лестница ординалов.
#import "@preview/cetz:0.5.2": canvas, draw
#import "style.typ": *

// ── Диагональ Кантора: цифры диагонали собираются в число r ──
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
    fill: panel-cool,
    stroke: none,
    radius: 4pt,
  )

  for i in range(rows) {
    mark((-0.4, -(i + 0.5) * s), [$r_#(i + 1)$], tone: ink-soft)
    for j in range(cols) {
      let x = j * s + 0.1
      let y = -(i + 0.5) * s
      let is-diag = (i == j)
      if is-diag {
        draw.rect(
          (x - 0.05, y - 0.32),
          (x + s - 0.05, y + 0.32),
          fill: warm.transparentize(80%),
          stroke: warm + 0.8pt,
          radius: 2pt,
        )
      }
      draw.content((x + s / 2, y), text(
        fill: if is-diag { warm } else { ink },
        weight: if is-diag { "bold" } else { "regular" },
      )[#digits.at(i).at(j)])
    }
  }

  mark((cols * s + 0.5, -(rows / 2) * s), $dots$, tone: ink-soft)

  for i in range(rows) {
    let x = i * s + s / 2 + 0.1
    mark((x, -(rows + 0.75) * s), $!=$, tone: warm)
    draw.content((x, -(rows + 1.55) * s), text(
      fill: ink,
      weight: "bold",
    )[#constructed.at(i)])
  }
  draw.content((-0.4, -(rows + 1.55) * s), text(
    weight: "bold",
    fill: ink,
  )[$r = 0.$])
  mark((1.5, -(rows + 2.4) * s), $dots not in {r_1, r_2, dots}$)
})

// ── Спаривание QQ: счёт по диагоналям ──
#let qq-pairing = canvas({
  let size = 5
  let diag-tones = (cool, green, warm, amber, violet)

  let cells = ()
  for s in range(2, 2 * size + 1) {
    let lo = calc.max(1, s - size)
    let hi = calc.min(size, s - 1)
    for i in range(lo, hi + 1) {
      cells.push((i, s - i))
    }
  }
  for sq in cells {
    let (i, j) = sq
    let tone = diag-tones.at(calc.rem(i + j - 2, diag-tones.len()))
    draw.rect(
      (j - 1, i - 1),
      (j, i),
      fill: tone.lighten(75%),
      stroke: (paint: ink-soft, thickness: 0.4pt),
    )
  }
  for (idx, sq) in cells.enumerate() {
    let (i, j) = sq
    mark((j - 0.5, i - 0.5), str(idx + 1))
  }

  for i in range(1, size + 1) {
    mark((i - 0.5, -0.42), str(i), tone: ink-soft)
    mark((-0.42, i - 0.5), str(i), tone: ink-soft)
  }
})

// ── Отрезок и квадрат равномощны ──
#let cantor-line-square = canvas({
  let w = 2.6
  let gap = 1.7

  draw.line(
    (0, 0),
    (w, 0),
    stroke: (paint: ink, thickness: 1.2pt),
    cap: "round",
  )
  draw.line((0, -0.14), (0, 0.14), stroke: (paint: ink, thickness: 1.2pt))
  draw.line((w, -0.14), (w, 0.14), stroke: (paint: ink, thickness: 1.2pt))
  mark((w / 2, -0.45), $L = [0, 1]$)
  mark((0, -0.42), $0$, tone: ink-soft)
  mark((w, -0.42), $1$, tone: ink-soft)

  panel((w + gap, 0), (w + gap + w, w), tone: cool, radius: 0.12)
  for t in (1, 2) {
    draw.line(
      (w + gap + w * t / 3, 0),
      (w + gap + w * t / 3, w),
      stroke: (paint: ink-soft, thickness: 0.4pt),
    )
    draw.line(
      (w + gap, w * t / 3),
      (w + gap + w, w * t / 3),
      stroke: (paint: ink-soft, thickness: 0.4pt),
    )
  }
  mark((w + gap + w / 2, w + 0.45), $S = [0, 1]^2$)
  mark((w + gap, -0.42), $0$, tone: ink-soft)
  mark((w + gap + w, -0.42), $1$, tone: ink-soft)

  for (sx, tx, ty) in ((0.45, 0.6, 0.75), (1.3, 1.6, 1.95), (2.15, 2.3, 1.1)) {
    draw.circle((sx, 0), radius: 0.06, fill: ink, stroke: none)
    draw.circle((w + gap + tx, ty), radius: 0.06, fill: ink, stroke: none)
    draw.bezier(
      (sx + 0.06, 0.06),
      (w + gap + tx - 0.06, ty - 0.06),
      ((sx + w + gap + tx) / 2, (0 + ty) / 2 + 0.6),
      stroke: (paint: ink-soft, thickness: 0.6pt),
    )
  }

  mark((w + gap / 2 - 0.25, 2.15), $approx$, size: 1.2em)
})

// ── Алефы и беты: общий старт, разные операции; вопрос между aleph_1 и beth_1 ──
#let aleph-beth = canvas({
  let gap = 2.9
  let y = 1.5

  let node(pos, label, name, tone, hw: 1.05) = {
    let (x, yy) = pos
    draw.rect(
      (x - hw, yy + 0.42),
      (x + hw, yy - 0.42),
      name: name,
      fill: if tone == none { fill-soft } else { tone.lighten(88%) },
      stroke: if tone == none { 0.9pt + ink } else { 0.9pt + tone },
      radius: 5pt,
    )
    draw.content((x, yy), text(fill: ink)[#label])
  }

  node((0, y), $aleph_0 = beth_0 = abs(NN)$, "start", none, hw: 1.75)
  node((gap, 2 * y), $aleph_1$, "a1", cool)
  node((2 * gap, 2 * y), $aleph_2$, "a2", cool)
  node((3 * gap, 2 * y), $aleph_3$, "a3", cool)
  node((gap, 0), $beth_1 = 2^(aleph_0)$, "b1", green)
  node((2 * gap, 0), $beth_2 = 2^(beth_1)$, "b2", green)
  node((3 * gap, 0), $beth_3 = 2^(beth_2)$, "b3", green)

  let step(a, b, tone) = draw.line(
    a,
    b,
    stroke: (paint: tone, thickness: 1.1pt, cap: "round"),
    mark: (end: "stealth", fill: tone),
  )
  step("start", "a1", cool)
  step("a1", "a2", cool)
  step("a2", "a3", cool)
  step("start", "b1", green)
  step("b1", "b2", green)
  step("b2", "b3", green)

  draw.line(
    "a1",
    "b1",
    stroke: (paint: warm, thickness: 1.2pt, dash: "dashed"),
  )
  // Плашка под "?" --- пунктир не должен просвечивать сквозь знак.
  draw.rect(
    (gap - 0.2, y + 0.05),
    (gap + 0.2, y + 0.55),
    fill: white,
    stroke: none,
  )
  mark((gap, y + 0.3), $?$, tone: warm, size: 1.2em)

  mark((gap / 2, 2 * y + 0.62), "следующий", tone: cool)
  mark((gap / 2, -0.62), "булеан", tone: green)
})

// ── Лестница ординалов: цветные прыжки --- предельные шаги ──
#let ordinal-ladder = canvas({
  let xs = (0, 1.05, 2.1, 4.3, 5.5, 7.9, 10.4, 12.7)
  let labels = (
    $0$,
    $1$,
    $2$,
    $omega$,
    $omega + 1$,
    $omega dot 2$,
    $omega^2$,
    $omega^omega$,
  )
  let plain-edges = ((0, 1), (1, 2), (3, 4))
  let limit-edges = ((2, 3), (4, 5), (5, 6), (6, 7))
  let r = 0.13

  for (i, j) in limit-edges {
    draw.line(
      (xs.at(i) + r, 0),
      (xs.at(j) - r, 0),
      stroke: (paint: warm, thickness: 1.6pt, cap: "round"),
      mark: (end: "stealth", fill: warm),
    )
  }
  for (i, j) in plain-edges {
    draw.line(
      (xs.at(i) + r, 0),
      (xs.at(j) - r, 0),
      stroke: edge-plain,
      mark: (end: "stealth", fill: edge-plain.paint),
    )
  }
  for i in range(xs.len()) {
    draw.circle((xs.at(i), 0), radius: 0.11, fill: fill-soft, stroke: 1pt + ink)
    mark((xs.at(i), 0.55), labels.at(i))
  }
  for x in (3.2, 6.7, 9.15, 11.55) {
    mark((x, -0.5), $dots$, tone: ink-soft)
  }
})

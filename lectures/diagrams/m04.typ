// Диаграммы множеств: Венн, декартово произведение, равенство боксов.
#import "@preview/cetz:0.5.2": canvas, draw
#import "../theme.typ": setminus
#import "style.typ": *

// ── Геометрия венновских кругов ──
#let r = 0.85
#let dx = 0.35
#let ym = calc.sqrt(r * r - dx * dx)
#let ang = calc.atan2(dx, ym) // точка пересечения из центра A
#let ang-b = 180deg - ang // та же точка из центра B
#let a-fill = cool.transparentize(60%)
#let b-fill = warm.transparentize(60%)

#let tag(pos, body, tone: ink) = mark(pos, body, tone: tone, size: 0.6em)

// дуга окружности с центром (cx, 0) от угла from до to против часовой
#let arc-at(cx, rad, from, to, ..args) = draw.arc(
  (cx + rad * calc.cos(from), rad * calc.sin(from)),
  start: from,
  stop: to,
  radius: rad,
  ..args,
)

#let dot(pos, tone: cool, open: false) = draw.circle(
  pos,
  radius: 0.07,
  fill: if open { white } else { tone },
  stroke: if open { 0.8pt + tone } else { none },
)

// ── Объединение A и B ──
#let venn-union = canvas({
  draw.circle((-dx, 0), radius: r, fill: a-fill, stroke: edge-plain)
  draw.circle((dx, 0), radius: r, fill: b-fill, stroke: edge-plain)
  // граница объединения --- акцент
  arc-at(-dx, r, ang, 360deg - ang, stroke: edge-cool)
  arc-at(dx, r, -ang-b, ang-b, stroke: edge-cool)
  tag((-r - 0.15, 0), $A$)
  tag((r + 0.15, 0), $B$)
  tag((0, r + 0.42), $A union B$)
})

// ── Пересечение A и B ──
#let venn-intersection = canvas({
  draw.circle((-dx, 0), radius: r, fill: fill-soft, stroke: edge-plain)
  draw.circle((dx, 0), radius: r, fill: fill-soft, stroke: edge-plain)
  // линза: два сегмента по хорде пересечения
  arc-at(
    -dx,
    r,
    -ang,
    ang,
    mode: "CLOSE",
    fill: green.transparentize(35%),
    stroke: none,
  )
  arc-at(
    dx,
    r,
    ang-b,
    360deg - ang-b,
    mode: "CLOSE",
    fill: green.transparentize(35%),
    stroke: none,
  )
  arc-at(-dx, r, -ang, ang, stroke: edge-green)
  arc-at(dx, r, ang-b, 360deg - ang-b, stroke: edge-green)
  tag((-r - 0.15, 0), $A$)
  tag((r + 0.15, 0), $B$)
  tag((0, r + 0.42), $A inter B$)
})

// ── Difference: A \ B ──
#let venn-difference = canvas({
  // серп A без линзы --- результат, тёплый акцент
  arc-at(
    -dx,
    r,
    ang,
    360deg - ang,
    mode: "CLOSE",
    fill: warm.transparentize(40%),
    stroke: none,
  )
  draw.circle((dx, 0), radius: r, fill: b-fill, stroke: edge-plain)
  draw.circle((-dx, 0), radius: r, fill: none, stroke: edge-plain)
  arc-at(-dx, r, ang, 360deg - ang, stroke: edge-hot)
  arc-at(-dx, r, -ang, ang, stroke: edge-hot)
  tag((-r - 0.15, 0), $A$)
  tag((r + 0.15, 0), $B$)
  tag((0, r + 0.42), $A setminus B$)
})

// ── Subset: A ⊂ B ──
#let venn-subset = canvas({
  draw.circle(
    (0, 0),
    radius: (1.2, r + 0.05),
    fill: panel-warm,
    stroke: edge-plain,
  )
  draw.circle(
    (-0.35, 0),
    radius: 0.6,
    fill: cool.transparentize(40%),
    stroke: edge-cool,
  )
  tag((0.8, 0), $B$)
  tag((-0.35, 0), $A$)
  tag((0, r + 0.42), $A subset B$)
})

// ── Декартово произведение интервалов на плоскости ──
#let product-plane = canvas({
  let a-seg = 1pt + cool
  let b-seg = 1pt + warm

  draw.grid(
    (0, 0),
    (5, 4.6),
    step: 1,
    stroke: (paint: luma(85%), thickness: 0.4pt),
  )
  draw.line((-0.3, 0), (5.4, 0), stroke: 0.8pt + ink, mark: (end: "stealth"))
  draw.line((0, -0.3), (0, 4.6), stroke: 0.8pt + ink, mark: (end: "stealth"))
  tag((5.6, -0.35), $x$)
  tag((-0.4, 4.8), $y$)
  tag((-0.35, -0.35), $0$)
  for i in range(1, 6) {
    draw.line((i, 0.08), (i, -0.08), stroke: 0.8pt + ink)
    tag((i, -0.4), [#i])
  }
  for i in range(1, 5) {
    draw.line((0.08, i), (-0.08, i), stroke: 0.8pt + ink)
    tag((-0.4, i), [#i])
  }

  draw.line((1, -0.65), (4, -0.65), stroke: a-seg)
  dot((1, -0.65))
  dot((4, -0.65), open: true)
  tag((2.5, -1.05), $A = [1; 4)$)

  draw.line((-0.65, 2), (-0.65, 4), stroke: b-seg)
  dot((-0.65, 2), open: true)
  dot((-0.65, 4))
  tag((-1.65, 3), $B = (2; 4]$)

  // сплошные стороны --- включённые концы, пунктир --- исключённые
  draw.rect((1, 2), (4, 4), fill: a-fill, stroke: none)
  draw.line((1, 2), (1, 4), stroke: 1.1pt + cool)
  draw.line((1, 4), (4, 4), stroke: 1.1pt + cool)
  draw.line((1, 2), (4, 2), stroke: edge-soft)
  draw.line((4, 2), (4, 4), stroke: edge-soft)
  dot((1, 2), open: true)
  dot((1, 4))
  dot((4, 4), open: true)
  dot((4, 2), open: true)
  tag((2.5, 3.15), $A times B$)
})

// ── Сетка точек A на B ──
#let points-grid = canvas({
  let a-set = (1, 2, 3)
  let b-set = (1, 2)

  panel((0.5, 0.5), (3.5, 2.5), tone: cool)
  draw.grid(
    (0, 0),
    (3.5, 2.7),
    step: 1,
    stroke: (paint: luma(85%), thickness: 0.4pt),
  )
  draw.line((-0.2, 0), (3.5, 0), stroke: 0.8pt + ink, mark: (end: "stealth"))
  draw.line((0, -0.2), (0, 2.7), stroke: 0.8pt + ink, mark: (end: "stealth"))
  tag((3.7, -0.35), $x$)
  tag((-0.4, 2.9), $y$)
  for a in a-set {
    tag((a, -0.35), [#a])
  }
  for b in b-set {
    tag((-0.35, b), [#b])
  }
  for a in a-set {
    for b in b-set {
      draw.circle((a, b), radius: 0.16, fill: white, stroke: 1.3pt + cool)
      tag((a, b + 0.45), $(#a, #b)$)
    }
  }
})

// ── Разность прямоугольников ──
#let rect-difference = canvas({
  let a-side = 1.1pt + cool
  let a-dash = (paint: cool, thickness: 0.7pt, dash: "dashed")
  let c-dash = (paint: warm, thickness: 0.7pt, dash: "dashed")

  let (a0, a1) = (1, 5)
  let (b0, b1) = (1, 4)
  let (c0, c1) = (2, 4)
  let (d0, d1) = (2, 3)

  draw.grid(
    (0, 0),
    (5.6, 4.6),
    step: 1,
    stroke: (paint: luma(85%), thickness: 0.4pt),
  )
  draw.line((-0.3, 0), (5.6, 0), stroke: 0.8pt + ink, mark: (end: "stealth"))
  draw.line((0, -0.3), (0, 4.6), stroke: 0.8pt + ink, mark: (end: "stealth"))
  tag((5.8, -0.35), $x$)
  tag((-0.4, 4.8), $y$)

  draw.rect((a0, b0), (a1, b1), fill: a-fill, stroke: none)
  draw.rect((c0, d0), (c1, d1), fill: white, stroke: none)

  // сплошные стороны --- включённые концы, пунктир --- исключённые
  draw.line((a0, b1), (a1, b1), stroke: a-side)
  draw.line((a1, b0), (a1, b1), stroke: a-side)
  draw.line((a0, b0), (a1, b0), stroke: a-dash)
  draw.line((a0, b0), (a0, b1), stroke: a-side)

  // рамка вырезанного C на D
  draw.line((c0, d0), (c1, d0), stroke: c-dash)
  draw.line((c1, d0), (c1, d1), stroke: c-dash)
  draw.line((c0, d1), (c1, d1), stroke: c-dash)
  draw.line((c0, d0), (c0, d1), stroke: c-dash)

  dot((a0, b1))
  dot((a1, b1))
  dot((a0, b0), open: true)
  dot((a1, b0), open: true)
  for pos in ((c0, d0), (c1, d0), (c0, d1), (c1, d1)) {
    dot(pos, open: true, tone: warm)
  }

  draw.line((a0, -0.6), (a1, -0.6), stroke: a-side)
  dot((a0, -0.6))
  dot((a1, -0.6))
  tag((3, -1.0), $A = [1; 5]$)

  draw.line((-0.6, b0), (-0.6, b1), stroke: a-side)
  dot((-0.6, b0), open: true)
  dot((-0.6, b1))
  draw.content(
    (-1.1, 2.5),
    text(size: 0.6em, fill: ink)[$B = (1; 4\]$],
    angle: 90deg,
    anchor: "south",
  )

  draw.line((c0, -1.4), (c1, -1.4), stroke: 1pt + warm)
  dot((c0, -1.4), open: true, tone: warm)
  dot((c1, -1.4), open: true, tone: warm)
  tag((3, -1.8), $C = (2; 4)$)

  draw.line((-1.4, d0), (-1.4, d1), stroke: 1pt + warm)
  dot((-1.4, d0), open: true, tone: warm)
  dot((-1.4, d1), open: true, tone: warm)
  draw.content(
    (-2.15, 2.5),
    text(size: 0.6em, fill: ink)[$D = (2; 3)$],
    angle: 90deg,
    anchor: "south",
  )
})

// ── Венн против Эйлера ──
#let venn-vs-euler = canvas({
  let r2 = 1.35
  let dx2 = 0.75
  let ym2 = calc.sqrt(r2 * r2 - dx2 * dx2)
  let ang2 = calc.atan2(dx2, ym2)
  let ang2-b = 180deg - ang2

  draw.circle((-dx2, 0), radius: r2, fill: a-fill, stroke: edge-plain)
  draw.circle((dx2, 0), radius: r2, fill: b-fill, stroke: edge-plain)
  // линза "3" --- акцент: поняли разницу
  arc-at(
    -dx2,
    r2,
    -ang2,
    ang2,
    mode: "CLOSE",
    fill: green.transparentize(35%),
    stroke: none,
  )
  arc-at(
    dx2,
    r2,
    ang2-b,
    360deg - ang2-b,
    mode: "CLOSE",
    fill: green.transparentize(35%),
    stroke: none,
  )
  arc-at(-dx2, r2, -ang2, ang2, stroke: edge-green)
  arc-at(dx2, r2, ang2-b, 360deg - ang2-b, stroke: edge-green)
  tag((-1.45, 0), $1$)
  tag((1.45, 0), $2$)
  tag((0, 0), $3$)
})

// ── Коробка-множество ──
#let set-box = canvas({
  panel((0, 0), (3.0, 2.4), tone: cool)
  cell("el-bird", (0.75, 1.6), tone: cool)
  draw.content("el-bird", text(size: 1.2em)[#emoji.bird])
  cell("el-five", (2.25, 1.6), tone: warm)
  draw.content("el-five", text(size: 0.9em)[$5$])
  cell("el-tri", (1.5, 0.7), tone: green)
  draw.content("el-tri", text(size: 0.9em)[$triangle$])
  tag((1.5, 2.8), $A = {5, triangle, #emoji.bird}$)
})

// ── Боксы равенства ──
#let equality-boxes = canvas({
  let w = 1.5
  let h = 0.8
  let gap = 0.55
  let bodies = (${a, b}$, ${b, a}$, ${a, b, b}$, ${b, a, b}$)
  for i in range(4) {
    let x = i * (w + gap)
    draw.rect(
      (x, 0),
      (x + w, h),
      radius: 0.12,
      fill: fill-soft,
      stroke: edge-plain,
    )
    tag((x + w / 2, h / 2), bodies.at(i))
    if i < 3 {
      // равенство --- акцент
      tag((x + w + gap / 2, h / 2), $=$, tone: green)
    }
  }
})

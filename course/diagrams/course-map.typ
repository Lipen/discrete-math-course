// Карта курса: два ряда модулей, чистый Typst-grid (читаемые кегли, надёжная вёрстка).

// Палитра --- зеркало syllabus.
#let c-blue = oklch(45%, 0.12, 262deg)
#let c-cyan = oklch(45%, 0.11, 205deg)
#let c-purple = oklch(45%, 0.12, 320deg)
#let c-green = oklch(45%, 0.12, 150deg)
#let c-amber = oklch(48%, 0.12, 70deg)
#let c-spring = oklch(45%, 0.12, 175deg)
#let c-soft = oklch(45%, 0.02, 265deg)
#let p-blue = oklch(52%, 0.19, 262deg).transparentize(90%)
#let p-cyan = oklch(52%, 0.17, 205deg).transparentize(90%)
#let p-purple = oklch(52%, 0.18, 320deg).transparentize(90%)
#let p-green = oklch(52%, 0.17, 150deg).transparentize(90%)
#let p-amber = oklch(56%, 0.16, 75deg).transparentize(90%)
#let p-spring = oklch(52%, 0.16, 175deg).transparentize(88%)

#let map-cell(color, pastel, title, lec) = block(
  width: 100%,
  fill: pastel,
  stroke: (top: 2.2pt + color),
  inset: (x: 7pt, y: 6.5pt),
  breakable: false,
)[
  #set par(justify: false)
  #text(size: 0.8em, weight: "bold", hyphenate: false)[#title]
  #v(0.1em)
  #text(size: 0.72em, fill: c-soft)[#lec]
]

#let map-row(label, label-color, cells) = (
  grid.cell(align(right + horizon)[#text(size: 0.8em, weight: "bold", fill: label-color, hyphenate: false)[#label]]),
  ..cells.map(((c, p, t, l)) => grid.cell(map-cell(c, p, t, l))),
)

// ── Карта курса ──
#let course-map = block(width: 100%, breakable: false)[
  #grid(
    columns: (auto, 1fr, 1fr, 1fr, 1fr),
    gutter: (8pt, 5pt),
    row-gutter: 4pt,
    ..map-row([Семестр 1], c-blue, (
      (c-blue, p-blue, [Множества и отношения], [лекции 1--8]),
      (c-purple, p-purple, [Формальная логика], [лекции 9--11]),
      (c-green, p-green, [Булева алгебра и схемы], [лекции 12--14]),
      (c-amber, p-amber, [Коды], [лекции 15--16]),
    )),
    grid.cell(colspan: 5)[
      #set align(center)
      #set text(size: 0.72em, fill: c-soft)
      ↓ вычисления и их пределы ↓
    ],
    ..map-row([Семестр 2], c-spring, (
      (c-spring, p-spring, [Графы], [лекции 1--4]),
      (c-cyan, p-cyan, [Конечные автоматы], [лекции 5--8]),
      (c-purple, p-purple, [Машина Тьюринга и разрешимость], [лекции 9--12]),
      (c-green, p-green, [Комбинаторика], [лекции 13--16]),
    )),
  )
]

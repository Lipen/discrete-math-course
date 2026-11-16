// Карта курса: модули семестров и номера лекций.

#let c-ink = oklch(30%, 0.02, 265deg)
#let c-mute = oklch(50%, 0.02, 265deg)
#let c-blue = oklch(45%, 0.12, 262deg)
#let c-cyan = oklch(45%, 0.11, 205deg)
#let c-purple = oklch(45%, 0.12, 320deg)
#let c-green = oklch(45%, 0.12, 150deg)
#let c-amber = oklch(48%, 0.12, 70deg)
#let p-blue = oklch(52%, 0.19, 262deg).transparentize(90%)
#let p-cyan = oklch(52%, 0.17, 205deg).transparentize(90%)
#let p-purple = oklch(52%, 0.18, 320deg).transparentize(90%)
#let p-green = oklch(52%, 0.17, 150deg).transparentize(90%)
#let p-amber = oklch(56%, 0.16, 75deg).transparentize(90%)
#let band = oklch(52%, 0.19, 262deg).transparentize(95%)

#let module-row(fill, title, lectures) = (
  table.cell(fill: fill, align: left)[#title],
  table.cell(align: center)[#lectures],
)

#let course-map = block(width: 100%, breakable: false)[
  #table(
    columns: (1fr, auto),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    align: (left, center),
    inset: (x: 8pt, y: 3pt),
    table.header([*Модуль*], [*Лекции*]),
    table.cell(colspan: 2, fill: band, inset: (x: 8pt, y: 4.5pt))[
      #text(weight: "semibold", fill: c-ink)[Семестр 1]
    ],
    ..module-row(p-blue, [Логика и множества], [1--3]),
    ..module-row(p-cyan, [Отношения, порядок, функции и счётность], [4--8]),
    ..module-row(p-purple, [Формальная логика], [9--11]),
    ..module-row(p-green, [Булева алгебра, схемы и решатели], [12--15]),
    ..module-row(p-amber, [Коды и информация], [16]),
    table.cell(colspan: 2, fill: band, inset: (x: 8pt, y: 4.5pt))[
      #text(weight: "semibold", fill: c-ink)[Семестр 2]
    ],
    ..module-row(p-blue, [Графы], [1--4]),
    ..module-row(p-cyan, [Конечные автоматы], [5--8]),
    ..module-row(p-purple, [Машина Тьюринга и разрешимость], [9--12]),
    ..module-row(p-green, [Комбинаторика], [13--16]),
  )
]

// Карта курса: модули семестров и номера лекций.

#let c-blue = oklch(45%, 0.12, 262deg)
#let c-cyan = oklch(45%, 0.11, 205deg)
#let c-purple = oklch(45%, 0.12, 320deg)
#let c-green = oklch(45%, 0.12, 150deg)
#let c-amber = oklch(48%, 0.12, 70deg)
#let c-spring = oklch(45%, 0.12, 175deg)
#let p-blue = oklch(52%, 0.19, 262deg).transparentize(90%)
#let p-cyan = oklch(52%, 0.17, 205deg).transparentize(90%)
#let p-purple = oklch(52%, 0.18, 320deg).transparentize(90%)
#let p-green = oklch(52%, 0.17, 150deg).transparentize(90%)
#let p-amber = oklch(56%, 0.16, 75deg).transparentize(90%)
#let p-spring = oklch(52%, 0.16, 175deg).transparentize(88%)

#let module-cell(fill, title) = table.cell(fill: fill, align: left)[#title]

#let course-map = block(width: 100%, breakable: false)[
  #set text(size: 0.9em)
  #table(
  columns: (auto, 1fr, auto),
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  align: (left, left, center),
  inset: (x: 8pt, y: 2.5pt),
  table.header([*Семестр*], [*Модуль*], [*Лекции*]),
  [Семестр 1],
  module-cell(p-blue, [Язык, множества и отношения]),
  [1--4],
  [],
  module-cell(p-cyan, [Порядок, функции и мощность]),
  [5--8],
  [],
  module-cell(p-purple, [Формальная логика]),
  [9--11],
  [],
  module-cell(p-green, [Булева алгебра и схемы]),
  [12--14],
  [],
  module-cell(p-amber, [Теория кодирования]),
  [15--16],
  [Семестр 2],
  module-cell(p-spring, [Графы]),
  [1--4],
  [],
  module-cell(p-cyan, [Конечные автоматы]),
  [5--8],
  [],
  module-cell(p-purple, [Машина Тьюринга и разрешимость]),
  [9--12],
  [],
  module-cell(p-green, [Комбинаторика]),
  [13--16],
)
]

// Карта курса: модули семестров и номера лекций.

#let module-row(title, lectures) = (
  table.cell(align: left)[#title],
  table.cell(align: center)[#lectures],
)

#let course-map = block(width: 100%, breakable: false)[
  #table(
    columns: (1fr, auto),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    align: (left, center),
    inset: (x: 8pt, y: 3pt),
    table.header([*Модуль*], [*Лекции*]),
    table.cell(colspan: 2, inset: (x: 8pt, y: 6pt))[
      #text(weight: "bold")[Семестр 1]
    ],
    ..module-row([Логика и множества], [1--3]),
    ..module-row([Отношения, порядок, функции и счётность], [4--8]),
    ..module-row([Формальная логика], [9--11]),
    ..module-row([Булева алгебра и схемы], [12--14]),
    ..module-row([Коды и информация], [15--16]),
    table.cell(colspan: 2, inset: (x: 8pt, y: 8pt))[
      #text(weight: "bold")[Семестр 2]
    ],
    ..module-row([Графы], [1--4]),
    ..module-row([Конечные автоматы], [5--8]),
    ..module-row([Машина Тьюринга и разрешимость], [9--12]),
    ..module-row([Комбинаторика], [13--16]),
  )
]

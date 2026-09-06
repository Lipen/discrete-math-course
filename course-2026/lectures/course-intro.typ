// course-intro --- вводная лекция: наука, устройство курса, баллы, карта семестра.
#import "theme-mag.typ": *

#set document(title: "Дискретная математика", author: "Константин Чухарев")
#show: slides.with()

#set par(leading: 0.58em, spacing: 1.05em)
#set block(above: 1em, below: 1em)

// ── Журнальные виджеты ──
#let tcard(color, title, body) = block(
  width: 100%,
  fill: color.transparentize(93%),
  stroke: (
    left: 2pt + color,
    top: 0.4pt + color.lighten(50%),
    bottom: 0.4pt + color.lighten(50%),
    right: 0.4pt + color.lighten(50%),
  ),
  radius: 4pt,
  inset: (x: 10pt, y: 5pt),
)[
  #text(size: 0.9em, weight: "bold", fill: color.darken(10%))[#title]
  #v(0.25em)
  #body
]

#let stat(num, label) = block(
  width: 100%,
  fill: colors.accent.transparentize(93%),
  stroke: 0.4pt + colors.accent.lighten(55%),
  radius: 4pt,
  inset: (x: 6pt, y: 9pt),
  align(center)[
    #text(1.4em, weight: "bold", fill: colors.accent-strong)[#num]
    #v(2pt)
    #text(0.8em, fill: colors.muted)[#label]
  ],
)

#let pseg(color, num, label) = {
  block(
    width: 100%,
    fill: color.transparentize(90%),
    stroke: (top: 2pt + color),
    radius: (top: 4pt),
    height: 1.9em,
    breakable: false,
    align(center + horizon)[#text(1.1em, weight: "bold", fill: color)[#num]],
  )
  v(3pt)
  align(center)[#text(0.72em, fill: colors.muted)[#label]]
}

#let zone(color, range, name) = block(
  width: 100%,
  fill: color.transparentize(90%),
  stroke: (top: 2pt + color),
  radius: (top: 4pt),
  inset: (x: 2pt, y: 5pt),
  height: 2.6em,
  breakable: false,
  align(center + horizon)[
    #text(weight: "bold", fill: color)[#range] \
    #text(0.75em, fill: colors.muted)[#name]
  ],
)

// ── Обложка ──
#title-slide({
  set page(fill: colors.accent)

  place(right + top, dx: -0.6cm, dy: -2.4cm)[
    #text(
      16em,
      weight: "bold",
      fill: white.transparentize(85%),
      font: "Libertinus Sans",
    )[ДМ]
  ]

  place(left + top, dx: 1.6cm, dy: 1.5cm)[
    #text(
      0.8em,
      weight: "bold",
      tracking: 0.3em,
      fill: white.transparentize(35%),
    )[
      ПЕРВЫЙ КУРС · ВВОДНАЯ ЛЕКЦИЯ
    ]
  ]

  place(left + top, dx: 1.6cm, dy: 2.6cm, block(width: 88%)[
    #text(
      3.4em,
      weight: "bold",
      font: "Libertinus Sans",
      fill: white,
      hyphenate: false,
    )[
      Дискретная\ математика
    ]
    #v(0.9em, weak: true)
    #line(length: 22%, stroke: 2pt + white)
    #v(0.9em, weak: true)
    #text(
      1.2em,
      fill: white.transparentize(25%),
    )[Математический фундамент программиста]
  ])

  place(bottom, dy: -1.6cm, block(width: 100%, inset: (x: 1.6cm))[
    #grid(
      columns: (1fr,) * 4,
      column-gutter: 12pt,
      ..(
        ([2], [семестра]),
        ([32], [лекции]),
        ([8], [контрольных]),
        ([4], [теормина]),
      ).map(
        ((n, l)) => grid.cell(
          stroke: (top: 0.8pt + white.transparentize(60%)),
          inset: (top: 7pt),
        )[
          #text(1.4em, weight: "bold", fill: white)[#n]
          #v(3pt)
          #text(0.8em, fill: white.transparentize(30%))[#l]
        ],
      ),
    )
  ])

  place(bottom + left, dx: 1.6cm, dy: -0.85cm)[
    #text(0.8em, fill: white.transparentize(35%))[Константин Чухарев]
  ]
  place(bottom + right, dx: -1.6cm, dy: -0.85cm)[
    #text(0.8em, fill: white.transparentize(35%))[Осень 2026]
  ]
})

= Что это за наука

#focus-slide(
  epigraph: [Бог создал целые числа, всё остальное --- дело рук человека.],
  epigraph-author: [Леопольд Кронекер],
)

== Что изучает курс?

Дискретная математика --- математический фундамент computer science.
Её объекты дискретны: множества, отношения, функции, графы, автоматы, слова.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  row-gutter: 8pt,
  tcard(colors.accent, [Алгоритмы])[
    Корректность и сложность: логика, инварианты, комбинаторика.
  ],
  tcard(colors.green, [Базы данных])[
    SQL --- это множества, отношения и реляционная алгебра.
  ],

  tcard(colors.amber, [Криптография])[
    Арифметика остатков, простые числа, подсчёт без перебора.
  ],
  tcard(colors.violet, [Компиляторы])[
    Регулярные выражения, автоматы, грамматики.
  ],
)

#important[
  Всё упирается в вопрос "что вообще можно вычислить?" --- машина Тьюринга, весенний семестр.
  Две оси --- объекты и _как рассуждать_ о них.
  Логика --- первая глава и сквозная тема.
]

= Как работает курс

#focus-slide(
  epigraph: [Когда вы можете измерить то, о чём говорите, и выразить это в числах, вы кое-что об этом знаете.],
  epigraph-author: [Лорд Кельвин],
)

== Как дышит неделя

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 8pt,
  tcard(colors.accent, [Лекция])[
    Живое введение: слайды, примеры, мотивация.
  ],
  tcard(colors.green, [Книга])[
    Текст для чтения: детали, доказательства, история.
    На каждую лекцию --- глава.
  ],
  tcard(colors.violet, [Практика])[
    Разбор задач и защиты домашних заданий.
  ],
)

#note[
  Консультации --- отдельные пары для вопросов и досдач, свободное посещение.
  Исходники книги, конспекты и слайды --- в репозитории курса.
]

#important[
  Обязательная глава объявляется после лекции --- по ней опросник на следующей.
  Книга шире курса: часть глав --- чтение для любопытных.
]

== Пять минут на листочке

Начало каждой лекции --- именной листочек: вопросы по прошлой лекции и заданному чтению.

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 8pt,
  stat([5], [минут в начале лекции]),
  stat([1], [балл за понимание]),
  stat([0--10], [максимум за семестр]),
)

#important[
  Написал опросник --- значит пришёл: опросник и есть фиксация посещения.
]

#note[
  Опоздал --- листочек не пишется, и лекция не засчитывается.
  Пустой листок балла не приносит: ответ --- на понимание, а не на воспроизведение.
]

== Домашние задания и капы

Четыре работы за семестр, на пройденные темы, около десяти заданий трёх сортов.
Первая --- письменно, от руки.

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 8pt,
  tcard(colors.green, [База])[
    Обязательный минимум --- пропускать нельзя.
  ],
  tcard(colors.accent, [Челлендж])[
    Задачи посложнее: пропускать можно, решать интереснее.
  ],
  tcard(colors.amber, [Бонус])[
    Для тех, кому десяти задач мало. Кап не двигает.
  ],
)

#important[
  Домашняя работа не даёт баллов сама: она задаёт _кап_ --- максимум за контрольную с тем же номером, $c = min(x, k)$.
  + Пока какое-то базовое задание не сдано --- кап равен нулю.
  + Неполная домашка к дедлайну --- кап не выше пяти.
]

#note[
  Каждое решение защищается лично: рассказать любое и ответить на "почему".
]

== Контрольные и теормины

Письменный контроль --- четыре контрольные, устный --- два теормина.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  tcard(colors.accent, [Контрольные --- четыре])[
    По материалу своего модуля: полтора часа, письменно, на отдельной паре.
    С собой --- любые бумажные материалы, электроника запрещена.
    Пишутся всем курсом одновременно: отдельных дней сдачи нет.
  ],
  tcard(colors.violet, [Теормины --- два])[
    Устный ответ: вопросы и термины по пройденному материалу плюс небольшое доказательство.
    ТМ1 --- множества, отношения и логика.
    ТМ2 --- булева алгебра и коды.
  ],
)

== Экзамен и ИИ

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  tcard(colors.amber, [Экзамен --- январь])[
    Один день, три части: письменные билеты, практические задачи, устные вопросы.
    Разрешено всё, кроме ИИ.
    Баллы --- от 12 до 20 или ноль при провале.
    Не обязателен: без него итог ограничен 80 баллами.
  ],
  tcard(colors.green, [ИИ-политика])[
    В домашних работах ИИ разрешён --- при раскрытии: напишите, что и как использовали.
    На контрольных, теорминах и экзамене --- запрещён.
  ],
)

#important[
  Решение всё равно защищается лично.
  Проверяется не то, _как_ получен ответ, а понимает ли студент своё решение.
]

== Как считается итог?

Итог за семестр --- 100 баллов.

#grid(
  columns: (40fr, 20fr, 20fr, 10fr, 10fr),
  column-gutter: 5pt,
  pseg(colors.accent, [40], [контрольные]),
  pseg(colors.violet, [20], [теормины]),
  pseg(colors.amber, [20], [экзамен]),
  pseg(colors.green, [10], [практики]),
  pseg(colors.muted, [10], [лекции]),
)

#grid(
  columns: (59fr, 14fr, 16fr, 11fr),
  column-gutter: 5pt,
  zone(colors.red, [0--59], [долг]),
  zone(colors.warn, [60--73], [удовл.]),
  zone(colors.accent, [74--89], [хорошо]),
  zone(colors.green, [90--100], [отлично]),
)

#important[
  Допуск к экзамену --- 48 баллов практической части и все работы сданы.
  Практическая часть --- максимум 80: без экзамена выше "хорошо" не подняться.
]

#note[
  Подробности --- в обзоре курса: правила, дедлайны, частые вопросы.
]

= Семестр 1

#focus-slide(
  epigraph: [Границы моего языка означают границы моего мира.],
  epigraph-author: [Людвиг Витгенштейн],
)

== Карта семестра

Пять модулей, шестнадцать недель.

#table(
  columns: (auto, 1fr, auto),
  align: (center, left, left),
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  inset: (x: 8pt, y: 7pt),
  table.header([*Недели*], [*Модуль*], [*Контроль*]),
  [1--3], [Логика и множества], [КР 1 --- нед. 5],
  [4--8],
  [Отношения, порядок, функции и счётность],
  [КР 2 --- нед. 9, ТМ 1 --- нед. 10],

  [9--11], [Формальная логика], [КР 3 --- нед. 12],
  [12--14], [Булева алгебра и схемы], [КР 4 --- нед. 15],
  [15--16], [Теория кодирования], [ТМ 2 --- нед. 16],
)

#note[
  Каждая абстракция привязана к реальной системе: SQL --- на множествах и отношениях, цифровые схемы --- на булевой алгебре, память с коррекцией ошибок --- на кодах, регулярные выражения --- на автоматах.
]

== С чего начнём
#v(1fr)

#important[
  Сегодня --- высказывания и логические связки: атомы смысла и способы их соединения.
]
#v(0.6em)

#note[
  К следующей паре --- глава о них в книге.
]
#v(0.6em)

#Block(color: colors.green)[
  Но сначала --- первый опросник.
  Он по обзору курса, а не по чтению: заданное чтение появится после лекции.
]
#v(1fr)

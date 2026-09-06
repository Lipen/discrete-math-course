// course-intro --- вводная лекция: наука, устройство курса, баллы, карта семестра.
#import "theme-intro.typ": *

#set document(title: "Дискретная математика", author: "Константин Чухарев")
#show: slides.with()

#set list(spacing: 0.8em)
#set enum(spacing: 0.8em)

// ── Журнальные виджеты ──
// Пастельная палитра карточек: пыльные тона, белый болд в плашках читается крупным кеглем.
#let c-blue = oklch(56%, 0.10, 258deg)
#let c-green = oklch(56%, 0.08, 152deg)
#let c-red = oklch(55%, 0.12, 25deg)
#let c-violet = oklch(56%, 0.10, 305deg)

#let tcard(color, title, body) = {
  block(
    width: 100%,
    fill: color.transparentize(93%),
    stroke: (
      top: 0.4pt + color.lighten(50%),
      bottom: 0.4pt + color.lighten(50%),
      right: 0.4pt + color.lighten(50%),
    ),
    radius: 4pt,
    inset: 0pt,
  )[
    #block(
      width: 100%,
      fill: color,
      radius: (top-left: 4pt, top-right: 4pt),
      inset: (x: 0.8em, y: 0.5em),
      above: 0em,
      below: 0em,
    )[
      #text(size: 1.2em, weight: "bold", fill: white)[#title]
    ]
    #block(
      width: 100%,
      inset: (x: 0.8em, y: 0.5em),
      above: 0em,
      below: 0em,
    )[
      #body
    ]
  ]
}

#let stat(num, label) = block(
  width: 100%,
  fill: colors.accent.transparentize(93%),
  stroke: 0.4pt + colors.accent.lighten(55%),
  radius: 4pt,
  inset: (x: 0.5em, y: 0.8em),
  align(center)[
    #text(3em, weight: "bold", fill: colors.accent-strong)[#num]
    #v(1em, weak: true)
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
    align(center + horizon)[#text(1.2em, weight: "bold", fill: color)[#num]],
  )
  v(0.5em)
  align(center)[#text(0.8em, fill: colors.muted)[#label]]
}

#let zone(color, range, name) = block(
  width: 100%,
  fill: color.transparentize(90%),
  stroke: (top: 2pt + color),
  radius: (top: 4pt),
  inset: (x: 0.5em, y: 0.5em),
  height: 2.6em,
  breakable: false,
  align(center + horizon)[
    #text(weight: "bold", fill: color)[#range] \
    #text(0.8em, fill: colors.muted)[#name]
  ],
)

// ── Обложка ──
#title-slide({
  set page(fill: colors.accent)

  // Водяной знак --- единственная работа place на странице
  place(right + top, dx: -1.1cm, dy: 0.8cm)[
    #text(
      8em,
      weight: "bold",
      fill: white.transparentize(60%),
      font: "Libertinus Sans",
    )[ДМ]
  ]

  block(
    height: 100%,
    inset: (left: 1.6cm, right: 1.6cm, top: 1.5cm, bottom: 0.85cm),
  )[
    #text(
      0.8em,
      weight: "bold",
      tracking: 0.3em,
      fill: white.transparentize(35%),
    )[
      ПЕРВЫЙ КУРС · ВВОДНАЯ ЛЕКЦИЯ
    ]
    #v(1fr)
    #text(
      3em,
      weight: "bold",
      font: "Libertinus Sans",
      fill: white,
      hyphenate: false,
    )[
      Дискретная\ математика
    ]
    #v(2em, weak: true)
    #text(
      1.2em,
      fill: white.transparentize(25%),
    )[Математический фундамент программиста]
    #v(1fr)
    #grid(
      columns: (1fr,) * 4,
      column-gutter: 1em,
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
          #v(0.5em, weak: true)
          #text(0.8em, fill: white.transparentize(30%))[#l]
        ],
      ),
    )
    #v(1em)
    #grid(columns: (1fr, auto))[
      #text(0.8em, fill: white.transparentize(35%))[Константин Чухарев]
    ][
      #text(0.8em, fill: white.transparentize(35%))[Осень 2026]
    ]
  ]
})

= Что это за наука

#focus-slide(
  epigraph: [Бог создал целые числа, всё остальное --- дело рук человека.],
  epigraph-author: [Леопольд Кронекер],
)

== Что изучает курс?

Дискретная математика --- математический фундамент computer science.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  row-gutter: 8pt,
  tcard(c-blue, [Логика])[
    Высказывания, доказательства, дедукция.
  ],
  tcard(c-green, [Структуры])[
    Множества, отношения, функции, графы.
  ],

  tcard(c-red, [Алгебра и коды])[
    Булева алгебра, схемы, коды с коррекцией.
  ],
  tcard(c-violet, [Вычисление])[
    Автоматы, машина Тьюринга, вычислимость.
  ],
)

#important[
  Две оси --- объекты и _как рассуждать_ о них.\
  Логика --- первая глава и сквозная тема курса.
]

#note[
  SQL и компиляторы описаны на этом языке --- это то, ради чего он нужен.
]

= Как работает курс

#focus-slide(
  epigraph: [Когда вы можете измерить то, о чём говорите, и выразить это в числах, вы кое-что об этом знаете.],
  epigraph-author: [Лорд Кельвин],
)

== Лекция, книга, практика

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 8pt,
  tcard(c-blue, [Лекция])[
    Живое введение: слайды, примеры, мотивация.
  ],
  tcard(c-green, [Книга])[
    Текст для чтения: детали, доказательства, история.\
    На каждую лекцию --- глава.
  ],
  tcard(c-violet, [Практика])[
    Разбор задач и защиты домашних заданий.
  ],
)

#note[
  - Консультации --- отдельные пары для вопросов и досдач, свободное посещение
  - Исходники книги, конспекты и слайды --- в репозитории курса
]

#important[
  Обязательная глава объявляется после лекции --- по ней опросник на следующей.\
  Книга шире курса: часть глав --- чтение для любопытных.
]

== Флеш-опросники

Начало каждой лекции --- именной листочек: вопросы по прошлой лекции и заданному домашнему чтению.

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
  Опоздал --- листочек не пишется, и лекция не засчитывается.\
  Пустой листок балла не приносит: ответ --- на понимание, а не на воспроизведение.
]

== Домашние задания и капы

Четыре работы за семестр, около десяти заданий трёх сортов.\
Первая --- от руки.

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 8pt,
  tcard(c-green, [База])[
    Обязательный минимум --- пропускать нельзя.
  ],
  tcard(c-blue, [Челлендж])[
    Задачи посложнее: пропускать можно, решать интереснее.
  ],
  tcard(c-red, [Бонус])[
    Для тех, кому десяти задач мало.
  ],
)

#important[
  Домашняя работа не даёт баллов --- она задаёт _кап_ контрольной с тем же номером.\
  Итог считается как $c = min(x, k)$, где $k$ --- кап, $x$ --- письменный результат.
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
  tcard(c-blue, [Контрольные --- четыре])[
    - по материалу своего модуля
    - полтора часа, письменно, на отдельной паре
    - любые бумажные материалы, электроника запрещена
    - пишутся всем курсом одновременно: отдельных дней нет
  ],
  tcard(c-violet, [Теормины --- два])[
    - устный ответ: вопросы, термины, небольшое доказательство
    - ТМ1 --- множества, отношения и логика
    - ТМ2 --- булева алгебра и коды
  ],
)

== Экзамен и ИИ

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  tcard(c-red, [Экзамен --- январь])[
    - один день, три части: билеты, задачи, устные вопросы
    - разрешено всё, кроме ИИ
    - баллы --- *12--20* или ноль при провале
    - не обязателен: без него итог ограничен *80* баллами
  ],
  tcard(c-green, [ИИ-политика])[
    В домашних работах ИИ разрешён --- при раскрытии: напишите, что и как использовали.\
    На контрольных, теорминах и экзамене --- запрещён.
  ],
)

#important[
  Решение всё равно защищается лично.\
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
  Допуск к экзамену --- *48* баллов практической части и все работы сданы.\
  Практическая часть --- максимум *80*: без экзамена выше "хорошо" не подняться.
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
  inset: (x: 8pt, y: 5pt),
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
  Каждая абстракция строится на реальной системе:
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 0.5em,
    [- SQL --- на множествах и отношениях],
    [- цифровые схемы --- на булевой алгебре],

    [- память с коррекцией ошибок --- на кодах],
    [- регулярные выражения --- на автоматах],
  )
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
  Но сначала --- первый опросник.\
  Он по обзору курса, а не по чтению: заданное чтение появится после лекции.
]
#v(1fr)

// theme.typ --- тема лекционных слайдов (16:9).
// Единый вход: #show: slides.with(title: [...], ...)
// Всё локально: палитра, нотация, блоки, слайды. Без зависимости от книги.

// === Палитра: единый объект цветов ===
#let colors = (
  accent: oklch(50%, 0.15, 250deg), // сине-индиго, основной
  accent-strong: oklch(45%, 0.15, 250deg), // заголовки
  amber: oklch(70%, 0.15, 80deg), // ключевые выводы
  warn: oklch(60%, 0.15, 40deg), // предупреждения
  green: oklch(50%, 0.14, 150deg), // определения
  red: oklch(50%, 0.2, 25deg), // ложь в таблицах истинности
  violet: oklch(55%, 0.15, 300deg), // теоремы
  teal: oklch(55%, 0.1, 200deg), // примечания
  ink: oklch(30%, 0.02, 250deg), // основной текст
  muted: oklch(45%, 0.01, 250deg), // вторичный текст
  line: luma(88%), // тонкие границы
)

// === Нотация (скопирована из notes/notation.typ) ===
// Лекции не зависят от книги: книга меняется со временем.
#let NN = $NN$
#let ZZ = $ZZ$
#let RR = $RR$

#let imply = sym.arrow.r
#let iff = sym.arrow.l.r
#let models = sym.tack.rr // семантическое следование (⊨)
#let setminus = sym.without
#let symdiff = $Delta$

#let Green(x) = text(fill: colors.green.darken(20%), x)
#let Red(x) = text(fill: colors.red.darken(20%), x)
#let True = Green[`true`]
#let False = Red[`false`]
#let T = Green[`T`]
#let F = Red[`F`]

#let power(x) = $cal(P)(#x)$

// === Карточка: прозрачная заливка, левая полоса ===
#let card(bar, tint) = (
  fill: tint,
  stroke: (
    left: 3pt + bar,
    top: 0.5pt + bar.lighten(50%),
    bottom: 0.5pt + bar.lighten(50%),
    right: 0.5pt + bar.lighten(50%),
  ),
  radius: 4pt,
)

// === Счётчики окружений ===
#let definition-counter = counter("definition")
#let theorem-counter = counter("theorem")
#let corollary-counter = counter("corollary")

// === Общий каркас окружения ===
#let env-box(bar, tint, head, body, header: true) = block(
  ..card(bar, tint),
  inset: (x: 1em, y: 0.5em),
)[
  #if header [#head #v(0.3em) #body] else [#head #h(0.5em) #body]
]

// Разбор аргументов: `[body]` или `[Title][body]`.
#let split-args(args) = {
  let first = args.at(0, default: none)
  let second = args.at(1, default: none)
  if second == none { (none, first) } else { (first, second) }
}

// === Окружения ===
// Нумерованное: шаг счётчика в потоке, номер в context, заголовок отдельной строкой.
#let numbered-env(bar, tint, label, counter, title, body) = {
  let head = text(fill: bar, weight: "bold")[
    #counter.step()
    #label #context counter.display("1")#(if title != none [. #title])
  ]
  env-box(bar, tint, head, body)
}

#let definition(..args) = {
  let (title, body) = split-args(args)
  numbered-env(
    colors.green.darken(10%),
    colors.green.transparentize(90%),
    "Определение",
    definition-counter,
    title,
    body,
  )
}
#let theorem(..args) = {
  let (title, body) = split-args(args)
  numbered-env(
    colors.violet.darken(10%),
    colors.violet.transparentize(90%),
    "Теорема",
    theorem-counter,
    title,
    body,
  )
}
#let corollary(..args) = {
  let (title, body) = split-args(args)
  numbered-env(
    colors.violet.darken(10%),
    colors.violet.transparentize(90%),
    "Следствие",
    corollary-counter,
    title,
    body,
  )
}
#let proof(..args) = {
  let (title, body) = split-args(args)
  block(
    fill: colors.accent.transparentize(90%),
    stroke: (
      left: 2.5pt + colors.accent.lighten(30%),
      top: 0.5pt + colors.line,
      bottom: 0.5pt + colors.line,
      right: 0.5pt + colors.line,
    ),
    radius: 4pt,
    inset: (x: 1em, y: 0.5em),
  )[
    #text(weight: "bold")[Доказательство#(if title != none [. #title])]
    #v(0.3em)
    #body
  ]
}
#let example(..args) = {
  let (title, body) = split-args(args)
  env-box(
    colors.muted,
    colors.line.lighten(40%),
    text(fill: colors.muted, weight: "bold")[
      Пример#(if title != none [: #title])
    ],
    body,
    header: false,
  )
}
#let note(..args) = {
  let (title, body) = split-args(args)
  env-box(
    colors.teal.darken(10%),
    colors.teal.transparentize(90%),
    text(fill: colors.teal.darken(10%), weight: "bold")[
      Замечание#(if title != none [: #title])
    ],
    body,
    header: false,
  )
}

// === Блок-применение ===
// color --- акцент блока (colors.accent для применений, colors.amber для выводов, colors.warn для предупреждений).
#let Block(color: colors.accent, body, ..args) = block(
  body,
  fill: color.transparentize(90%),
  stroke: (
    left: 3pt + color.darken(10%),
    top: 0.5pt + color.lighten(50%),
    bottom: 0.5pt + color.lighten(50%),
    right: 0.5pt + color.lighten(50%),
  ),
  radius: 4pt,
  inset: (x: 1em, y: 0.5em),
  ..args.named(),
)

// === Заголовок текущей секции ===
// focus-slide берёт заголовок из последнего h1 перед собой.
#let current-heading(level: 1) = context {
  let h = query(selector(heading.where(level: level)).before(here()))
  if h.len() > 0 {
    h.last().body
  } else {
    none
  }
}

// === Титульный слайд презентации ===
#let title-slide(content) = {
  set page(header: none, footer: none, margin: 0pt)
  content
  pagebreak(weak: true)
}

// === Слайд-открыватель секции ===
// title по умолчанию берётся из заголовка h1.
#let focus-slide(
  title: none,
  epigraph: none,
  epigraph-author: none,
) = {
  let title = if title == none {
    current-heading()
  } else if type(title) == function {
    title(current-heading())
  } else {
    title
  }

  set page(header: none, footer: none, margin: 0pt)

  // Заголовок, акцентная линия, эпиграф --- как на титульной странице
  place(left + horizon, block(width: 100%, inset: (x: 2cm, y: 1cm))[
    #block(width: 82%)[
      #set text(2.3em, weight: "bold", font: "Libertinus Sans", fill: colors.accent-strong)
      #title
    ]
    #v(1em, weak: true)
    #line(length: 32%, stroke: 1.5pt + colors.accent)
    #if epigraph != none [
      #v(1em, weak: true)
      #set text(1em, style: "italic", fill: colors.muted)
      #if type(epigraph) == function {
        epigraph()
      } else {
        epigraph
      }
      #if epigraph-author != none [
        #v(0.3em, weak: true)
        #align(right)[
          #set text(0.85em, weight: "bold", fill: colors.accent-strong)
          --- #epigraph-author
        ]
      ]
    ]
  ])

  pagebreak(weak: true)
}

// === Слайды: точка входа ===
#let slides(
  content,
  title: none,
  subtitle: none,
  date: none,
  authors: (),
) = {
  // === Текст: русский, базовый размер и цвет ===
  set text(lang: "ru", size: 12pt, fill: colors.ink)

  // === Страница 16:9 ===
  let height = 10.5cm
  let width = height * 16 / 9
  let space = 1.6cm

  let title-color = colors.accent-strong
  let title-font = "Libertinus Sans"

  set page(
    width: width,
    height: height,
    margin: (x: 0.5 * space, top: space, bottom: 0.5 * space),
    header: context {
      let page = here().page()
      let headings = query(selector(heading.where(level: 2)))
      let heading = headings.rev().find(x => x.location().page() <= page)
      if heading != none {
        set align(bottom)
        set text(
          1.4em,
          weight: "bold",
          font: title-font,
          fill: title-color,
        )
        let body = {
          heading.body
          if not heading.location().page() == page {
            numbering(" [1]", page - heading.location().page() + 1)
          }
        }
        block(
          outset: (bottom: 0.4em, x: 0.1em),
          stroke: (bottom: 0.5pt + title-color),
        )[
          #set par(leading: 0.4em)
          #body
        ]
      }
    },
    footer: context {
      set text(0.8em, fill: luma(50%))
      set align(right)
      counter(page).display("1 / 1", both: true)
    },
  )
  set document(title: title, author: authors) if (title != none)

  // === Заголовки ===
  // h1 --- открыватель секции (слайд рисует focus-slide)
  show heading.where(level: 1): none
  // h2 --- заголовок слайда (текст живёт в шапке)
  show heading.where(level: 2): pagebreak(weak: true)

  // === Списки, эмфасис, ссылки ===
  set list(marker: (
    text(fill: title-color)[•],
    text(fill: title-color)[‣],
    text(fill: title-color)[-],
  ))
  set enum(numbering: nums => text(fill: title-color)[*#nums.*])
  show emph: set text(fill: colors.accent)
  show link: underline

  // === Титульная страница ===
  if title != none {
    if (type(authors) != array) {
      authors = (authors,)
    }
    title-slide({
      // Заголовок, акцентная линия, подзаголовок --- по левому краю
      place(left + horizon, block(width: 100%, inset: (x: 2cm, y: 1cm))[
        #block(width: 82%)[
          #set text(3em, weight: "bold", font: title-font, fill: title-color)
          #title
        ]
        #v(1.1em, weak: true)
        #line(length: 32%, stroke: 2pt + colors.accent)
        #v(1.1em, weak: true)
        #if subtitle != none [
          #set text(1.2em, fill: colors.muted)
          #subtitle
        ]
      ])
      // Авторы и дата внизу
      place(
        bottom + left,
        dx: 2cm,
        dy: -0.9cm,
        text(0.95em, fill: luma(45%))[#authors.join(", ", last: " и ")],
      )
      place(
        bottom + right,
        dx: -2cm,
        dy: -0.9cm,
        if date != none {
          text(0.85em, fill: luma(55%))[#date]
        },
      )
    })
  }

  show sym.emptyset: set text(font: "Libertinus Sans")

  set math.mat(column-gap: 1em)

  set table(inset: (x: 5pt, y: 2pt))

  // === Контент ===
  content
}

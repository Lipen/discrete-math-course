// theme.typ --- тема лекционных слайдов (16:9).
// Единый вход: #show: slides.with(title: [...], ...)
// Всё локально: палитра, нотация, блоки, слайды. Без зависимости от книги.

// === Палитра: единый объект цветов ===
#let colors = (
  accent: oklch(50%, 0.17, 250deg), // сине-индиго, основной
  accent-strong: oklch(45%, 0.17, 250deg), // заголовки
  amber: oklch(70%, 0.17, 80deg), // ключевые выводы
  warn: oklch(60%, 0.17, 40deg), // предупреждения
  green: oklch(50%, 0.16, 150deg), // определения
  red: oklch(50%, 0.2, 25deg), // ложь в таблицах истинности
  violet: oklch(55%, 0.17, 300deg), // теоремы
  ink: oklch(30%, 0.02, 250deg), // основной текст
  muted: oklch(45%, 0.01, 250deg), // вторичный текст
  line: luma(88%), // тонкие границы
)

// Модульная система: поток объявляет себя сам --- #show: slides.with(module: "automata").
// Оттенки наследуются из course/syllabus.typ (полосы таймлайна), вес нормализован под слайды.
#let module-accents = (
  sets: oklch(50%, 0.14, 262deg),
  relations: oklch(50%, 0.12, 262deg),
  logic: oklch(52%, 0.15, 300deg),
  boolean: oklch(50%, 0.13, 150deg),
  codes: oklch(56%, 0.14, 75deg),
  graphs: oklch(50%, 0.14, 262deg),
  automata: oklch(50%, 0.13, 205deg),
  turing: oklch(52%, 0.15, 320deg),
  combinatorics: oklch(50%, 0.13, 150deg),
)
#let module-names = (
  sets: "Множества",
  relations: "Отношения",
  logic: "Формальная логика",
  boolean: "Булева алгебра",
  codes: "Коды",
  graphs: "Графы",
  automata: "Конечные автоматы",
  turing: "Машина Тьюринга",
  combinatorics: "Комбинаторика",
)
#let module-index = (
  sets: 0,
  relations: 0,
  logic: 1,
  boolean: 2,
  codes: 3,
  graphs: 0,
  automata: 1,
  turing: 2,
  combinatorics: 3,
)

// Текущий модуль; читают мебельные слайды и note.
#let mod-state = state("theme-module", none)

// === Нотация (скопирована из book/notation.typ) ===
// Лекции не зависят от книги: книга меняется со временем.
#let NN = $NN$
#let ZZ = $ZZ$
#let RR = $RR$

#let imply = sym.arrow.r
#let iff = sym.arrow.l.r
#let models = sym.tack.rr // семантическое следование
#let setminus = sym.without
#let symdiff = $Delta$
#let sim = sym.tilde
#let partialto = sym.arrow.r.bar
#let nand = sym.arrow.t // штрих Шеффера
#let nor = sym.arrow.b // стрелка Пирса
#let EE = math.op("E") // матожидание
#let la = $chevron.l$
#let ra = $chevron.r$

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
    left: 2pt + bar,
    top: 0.4pt + bar.lighten(50%),
    bottom: 0.4pt + bar.lighten(50%),
    right: 0.4pt + bar.lighten(50%),
  ),
  radius: 4pt,
)

// === Счётчики окружений ===
#let definition-counter = counter("definition")
#let theorem-counter = counter("theorem")
#let corollary-counter = counter("corollary")

// === Общий каркас окружения ===
#let env-box(bar, tint, head, body, header: true, gap: 1em) = block(
  ..card(bar, tint),
  width: 100%,
  inset: (x: 1em, y: 0.5em),
)[
  #if header [#head #v(gap, weak: true) #body] else [#head #h(
      0.5em,
      weak: true,
    ) #body]
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
    #label #context counter.display("1")#(if title != none [ (#title)])
  ]
  env-box(bar, tint, head, body)
}

#let definition(..args) = {
  let (title, body) = split-args(args)
  numbered-env(
    colors.green.darken(10%),
    colors.green.transparentize(93%),
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
    colors.violet.transparentize(93%),
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
    colors.violet.transparentize(93%),
    "Следствие",
    corollary-counter,
    title,
    body,
  )
}
#let proof(..args) = {
  let (title, body) = split-args(args)
  block(
    fill: luma(96%),
    stroke: (
      left: 2pt + colors.muted,
      top: 0.4pt + colors.line,
      bottom: 0.4pt + colors.line,
      right: 0.4pt + colors.line,
    ),
    radius: 4pt,
    inset: (x: 1em, y: 0.5em),
  )[
    #text(fill: colors.muted, weight: "bold")[
      Доказательство#(if title != none [ (#title)])
    ]
    #v(1em, weak: true)
    #body
  ]
}
#let example(..args) = {
  let (title, body) = split-args(args)
  env-box(
    colors.muted,
    colors.line.lighten(40%),
    text(fill: colors.muted, weight: "bold")[
      Пример#(if title != none [ (#title)])
    ],
    body,
    gap: 0.8em,
  )
}

// === Блок: прозрачная заливка, левая полоса ===
// color --- акцент блока (colors.accent для применений, colors.amber для выводов, colors.warn для предупреждений).
#let Block(color: colors.accent, body, ..args) = block(
  body,
  fill: color.transparentize(93%),
  stroke: (
    left: 2pt + color.darken(10%),
    top: 0.4pt + color.lighten(50%),
    bottom: 0.4pt + color.lighten(50%),
    right: 0.4pt + color.lighten(50%),
  ),
  radius: 4pt,
  inset: (x: 1em, y: 0.5em),
  ..args.named(),
)

// === Неформальные блоки: цвет без текстовой метки ===
// important --- важное (amber), note --- пояснение (голубое).
#let important(..args) = Block(..args, color: colors.amber)
#let note(..args) = context {
  let m = mod-state.final()
  let c = if m != none { module-accents.at(m) } else { colors.accent }
  Block(..args, color: c)
}

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
  set page(header: none, foreground: none, margin: 0pt)
  content
  pagebreak(weak: true)
}

// === Слайд-открыватель секции ===
// title по умолчанию берётся из заголовка h1.
#let focus-slide(
  title: none,
  epigraph: none,
  epigraph-author: none,
  ghost: none,
) = {
  let title = if title == none {
    current-heading()
  } else if type(title) == function {
    title(current-heading())
  } else {
    title
  }

  context {
    let m = mod-state.final()
    let acc = if m != none { module-accents.at(m) } else { colors.accent }
    let strong = acc.darken(8%)

    set page(
      fill: acc.transparentize(94%),
      header: none,
      foreground: none,
      margin: 0pt,
    )

    // Призрак секции: глиф или CeTZ/Fletcher-функция --- она получает цвет призрака
    if ghost != none {
      place(right + top, dx: -1.1cm, dy: 0.8cm)[
        #if type(ghost) == function {
          ghost(acc.transparentize(80%))
        } else {
          text(
            8em,
            weight: "bold",
            fill: acc.transparentize(80%),
            font: "Libertinus Sans",
          )[#ghost]
        }
      ]
    }

    let probe(s) = text(s, weight: "bold", font: "Libertinus Sans")[#title]
    let fits(s) = (
      measure(probe(s), width: 13.2cm).height <= 3.05 * 12pt * (s / 1em)
    )
    let pick = if fits(3em) { 3em } else if fits(2.4em) { 2.4em } else if fits(1.8em) { 1.8em } else { 1.4em }
    place(left + horizon, block(width: 100%, inset: (x: 2cm, y: 1cm))[
      #block[
        #set text(
          pick,
          weight: "bold",
          font: "Libertinus Sans",
          fill: strong,
        )
        #title
      ]
      #v(1.4em, weak: true)
      #if epigraph != none [
        #block(
          width: 100%,
          stroke: (left: 2pt + acc),
          inset: (x: 1em),
        )[
          #set text(1.4em, style: "italic", fill: colors.ink)
          #if type(epigraph) == function {
            epigraph()
          } else {
            epigraph
          }
          #if epigraph-author != none [
            #v(0.8em, weak: true)
            #align(right)[
              #text(0.8em, weight: "bold", fill: strong)[--- #epigraph-author]
            ]
          ]
        ]
      ]
    ])
  }

  pagebreak(weak: true)
}

// === Слайд-разделитель лекции (внутри модульного дека: несколько лекций в одном файле) ===
// Сбрасывает нумерацию окружений; teaser --- анонс лекции на карточке постера.
#let lecture-slide(num, title, week: none, teaser: none) = {
  definition-counter.update(0)
  theorem-counter.update(0)
  corollary-counter.update(0)

  context {
    let m = mod-state.final()
    let acc = if m != none { module-accents.at(m) } else { colors.accent }
    let strong = acc.darken(8%)

    set page(
      fill: acc,
      header: none,
      foreground: none,
      margin: 0pt,
    )

    // Гигантский номер-призрак
    place(right + top, dx: -1.1cm, dy: 0.8cm)[
      #text(
        8em,
        weight: "bold",
        fill: white.transparentize(60%),
        font: "Libertinus Sans",
      )[#num]
    ]

    // Единый вертикальный поток; кегль титула --- не выше двух строк
    let probe(s) = text(s, weight: "bold", font: "Libertinus Sans")[#title]
    let fits(s) = (
      measure(probe(s), width: 13.5cm).height <= 3.05 * 12pt * (s / 1em)
    )
    let pick = if fits(3em) { 3em } else if fits(2.4em) { 2.4em } else if fits(
      1.8em,
    ) { 1.8em } else { 1.4em }
    place(left + horizon, block(width: 100%, inset: (x: 2cm, y: 0.5cm))[
      #stack(
        dir: ttb,
        spacing: 1em,
        text(
          0.8em,
          weight: "bold",
          tracking: 0.25em,
          fill: white.transparentize(15%),
        )[ЛЕКЦИЯ],
        block(width: 100%)[
          #set par(leading: 0.5em)
          #text(
            pick,
            weight: "bold",
            font: "Libertinus Sans",
            fill: white,
          )[#title]
        ],
        if week != none [
          #box(
            inset: (x: 0.8em, y: 0.3em),
            stroke: 1pt + white.transparentize(40%),
            radius: 4pt,
          )[
            #text(fill: white)[#week]
          ]
        ],
        if teaser != none [
          #block(
            width: 14.6cm,
            fill: white,
            radius: 4pt,
            inset: (x: 1em, y: 0.8em),
          )[
            #set text(fill: colors.ink, style: "italic")
            #teaser
          ]
        ],
      )
    ])
  }

  pagebreak(weak: true)
}

// === Слайды: точка входа ===
#let slides(
  content,
  title: none,
  subtitle: none,
  date: none,
  authors: (),
  module: none,
) = {
  if module != none {
    mod-state.update(module)
  }
  // === Текст ===
  set text(
    lang: "ru",
    size: 12pt,
    fill: colors.ink,
  )

  // === Страница 16:9 ===
  let height = 10.5cm
  let width = height * 16 / 9
  let space = 1.6cm

  let mod-acc = if module != none { module-accents.at(module) } else {
    colors.accent
  }
  let title-color = if module != none { mod-acc.darken(8%) } else {
    colors.accent-strong
  }
  let title-font = "Libertinus Sans"

  set page(
    width: width,
    height: height,
    margin: (
      x: 0.5 * space,
      top: space,
      bottom: 0.5 * space,
    ),
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
          stroke: (bottom: 0.4pt + title-color),
        )[
          #set par(leading: 0.4em)
          #body
        ]
      }
    },
    foreground: context {
      place(
        bottom + right,
        dx: -0.8cm,
        dy: -0.5cm,
        text(0.8em, fill: luma(50%))[
          #counter(page).display("1 / 1", both: true)
        ],
      )
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
  show emph: set text(fill: mod-acc)
  show link: underline

  // === Блочный код: плашка ===
  show raw.where(block: true): block.with(
    fill: luma(96%),
    inset: 0.8em,
    radius: 4pt,
    width: 100%,
  )

  // === Титульная страница ===
  if title != none {
    if (type(authors) != array) {
      authors = (authors,)
    }
    title-slide({
      // Центрированный постер: заголовок --- линия --- подзаголовок
      place(center + horizon, block(width: 88%, inset: (x: 1cm))[
        #align(center)[
          #text(
            3em,
            weight: "bold",
            font: title-font,
            fill: title-color,
          )[#title]
          #v(1em, weak: true)
          #line(length: 20%, stroke: 2pt + colors.accent)
          #v(1em, weak: true)
          #if subtitle != none [
            #text(1.2em, fill: colors.muted)[#subtitle]
          ]
          #context {
            let m = mod-state.final()
            if m != none and m in module-index {
              v(1em, weak: true)
              box(inset: (y: 0.4em))[
                #let active = module-index.at(m)
                #for i in range(4) {
                  if i > 0 { h(0.8em) }
                  box(circle(
                    radius: 4pt,
                    fill: if i == active { module-accents.at(m) },
                    stroke: if i != active { 0.8pt + colors.line },
                  ))
                }
              ]
            }
          }
        ]
      ])
      // Авторы и дата внизу
      place(
        bottom + left,
        dx: 2cm,
        dy: -1cm,
        text(0.8em, fill: luma(45%))[#authors.join(", ", last: " и ")],
      )
      place(
        bottom + right,
        dx: -2cm,
        dy: -1cm,
        if date != none {
          text(0.8em, fill: luma(55%))[#date]
        },
      )
    })
  }

  show sym.emptyset: set text(font: "Libertinus Sans")

  set math.mat(column-gap: 1em)

  // === Контент ===
  content
}

// theme-intro.typ --- тема вводного дека курса (16:9), журнальный стиль.
// Самодостаточна: палитра, каркас слайдов, фокус-разделители, неформальные блоки.

// === Палитра ===
#let colors = (
  accent: oklch(50%, 0.17, 250deg), // сине-индиго, основной
  accent-strong: oklch(45%, 0.17, 250deg), // заголовки
  amber: oklch(70%, 0.17, 80deg), // ключевые выводы
  warn: oklch(60%, 0.17, 40deg), // предупреждения
  green: oklch(50%, 0.16, 150deg), // определения
  red: oklch(50%, 0.2, 25deg), // долг / провал
  violet: oklch(55%, 0.17, 300deg), // теоремы
  ink: oklch(30%, 0.02, 250deg), // основной текст
  muted: oklch(45%, 0.01, 250deg), // вторичный текст
  line: luma(88%), // тонкие границы
)

// === Блок: прозрачная заливка, левая полоса ===
// color --- акцент блока (amber --- выводы, accent --- пояснения).
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

// === Неформальные блоки ===
#let important(..args) = Block(..args, color: colors.amber)
#let note(..args) = Block(..args, color: colors.accent)

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

// === Титульная страница (контент --- постер обложки) ===
#let title-slide(content) = {
  set page(header: none, foreground: none, margin: 0pt)
  content
  pagebreak(weak: true)
}

// === Слайд-открыватель секции ===
// title по умолчанию берётся из заголовка h1; эпиграф --- на всю ширину колонки.
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

  set page(
    fill: colors.accent.transparentize(94%),
    header: none,
    foreground: none,
    margin: 0pt,
  )

  place(left + horizon, block(width: 100%, inset: (x: 2cm, y: 1cm))[
    #block(width: 90%)[
      #set text(
        3em,
        weight: "bold",
        font: "Libertinus Sans",
        fill: colors.accent-strong,
      )
      #title
    ]
    #v(1.4em, weak: true)
    #if epigraph != none [
      #block(
        width: 100%,
        stroke: (left: 2pt + colors.accent),
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
            #text(
              0.8em,
              weight: "bold",
              fill: colors.accent-strong,
            )[--- #epigraph-author]
          ]
        ]
      ]
    ]
  ])

  pagebreak(weak: true)
}

// === Слайды: точка входа ===
#let slides(content) = {
  // === Текст ===
  set text(
    lang: "ru",
    size: 12pt,
    fill: colors.ink,
  )
  set par(spacing: 1em)
  set block(above: 1em, below: 1em)

  // === Страница 16:9 ===
  let height = 10.5cm
  let width = height * 16 / 9
  let space = 1.6cm

  let title-color = colors.accent-strong
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

  // === Заголовки ===
  // h1 --- открыватель секции (слайд рисует focus-slide)
  show heading.where(level: 1): none
  // h2 --- заголовок слайда (текст живёт в шапке)
  show heading.where(level: 2): pagebreak(weak: true)

  // === Списки, эмфасис ===
  set list(marker: (
    text(fill: title-color)[•],
    text(fill: title-color)[‣],
    text(fill: title-color)[-],
  ))
  set enum(numbering: nums => text(fill: title-color)[*#nums.*])
  show emph: set text(fill: colors.accent)

  content
}

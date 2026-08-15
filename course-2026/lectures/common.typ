// Общие окружения и хелперы лекций.
// Собственная машинерия блоков (без ctheorems): карточки с левой полосой и прозрачной заливкой.
// Числа --- круглые: прозрачность 90%, паддинг 1em/0.5em, радиус 4pt.
// Math-алиасы НЕ здесь: единый источник --- ../notes/notation.typ.
#import "requirements.typ": *

// --- Палитра: единый объект цветов ---
#let colors = (
  // Акценты
  accent: oklch(50%, 0.15, 250deg), // сине-индиго, основной
  accent-strong: oklch(45%, 0.15, 250deg), // заголовки
  amber: oklch(70%, 0.15, 80deg), // ключевые выводы
  warn: oklch(60%, 0.15, 40deg), // предупреждения
  green: oklch(50%, 0.14, 150deg), // определения
  violet: oklch(55%, 0.15, 300deg), // теоремы
  teal: oklch(55%, 0.1, 200deg), // примечания
  // Нейтральные
  ink: oklch(30%, 0.02, 250deg), // основной текст
  muted: oklch(45%, 0.01, 250deg), // вторичный текст
  line: luma(88%), // тонкие границы
)

#let template(dark: false, doc) = {
  set text(fill: white) if dark
  set page(fill: luma(10%)) if dark

  // Fix emptyset symbol
  show sym.emptyset: set text(font: "Libertinus Sans")

  // Show i.e. in italic:
  show "i.e.": set text(style: "italic")
  show "e.g.": set text(style: "italic")
  show "etc.": set text(style: "italic")

  // Matrix setup
  set math.mat(column-gap: 1em)

  doc
}

// Карточка: прозрачная заливка, левая полоса.
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

// Счётчики окружений.
#let definition-counter = counter("definition")
#let theorem-counter = counter("theorem")
#let corollary-counter = counter("corollary")

// Общий каркас: заголовок (отдельной строкой или inline) + тело.
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

// --- Окружения ---
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
    text(
      fill: colors.muted,
      weight: "bold",
    )[Пример#(if title != none [: #title])],
    body,
    header: false,
  )
}
#let note(..args) = {
  let (title, body) = split-args(args)
  env-box(
    colors.teal.darken(10%),
    colors.teal.transparentize(90%),
    text(
      fill: colors.teal.darken(10%),
      weight: "bold",
    )[Замечание#(if title != none [: #title])],
    body,
    header: false,
  )
}

// Horizontal rule
#let hrule = line(length: 100%)

// Blob for fletcher diagrams
#let blob(
  pos,
  label,
  tint: colors.green,
  shape: auto,
  ..args,
) = fletcher.node(
  pos,
  align(center, label),
  fill: if (tint != none) { tint.lighten(80%) } else { auto },
  stroke: if (tint != none) { tint.darken(20%) } else { auto },
  shape: shape,
  ..args,
)

// Colored box around a content
#let fancy-box(
  tint: colors.green,
  diagram-style: (:),
  blob-style: (:),
  content,
) = fletcher.diagram(
  node-corner-radius: 2pt,
  node-stroke: .8pt,
  ..diagram-style,
  blob(
    (0, 0),
    content,
    tint: tint,
    ..blob-style,
  ),
)

// Link with icon
#let href(..args) = link(..args, super(fontawesome.fa-external-link()))

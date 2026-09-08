// usage:
// ```
// #import "theme.typ": *
// #show: template
// ```

// ── Палитра ──
#let accent = blue.darken(25%)
#let warn = rgb("#b45309")
#let good = rgb("#15803d")

// ── Темплеет ──
#let template(dark: false, doc) = {
  set text(fill: white) if dark
  set page(fill: luma(12%)) if dark

  set text(12pt, lang: "ru")
  set par(justify: true)

  show emph: set text(fill: accent)
  show link: set text(fill: accent)

  show sym.emptyset: set text(font: "Libertinus Sans")

  show "i.e.": set text(style: "italic")
  show "e.g.": set text(style: "italic")
  show "etc.": set text(style: "italic")

  set math.mat(column-gap: 1em)

  // Заголовки задач: цвет, размер и волосяная линейка снизу.
  show heading.where(level: 2): set text(size: 13pt, weight: "bold", fill: accent)
  show heading.where(level: 2): it => block(
    width: 100%,
    above: 1.6em,
    below: 0.9em,
    sticky: true,
    inset: (bottom: 0.35em),
    stroke: (bottom: 0.8pt + accent.lighten(40%)),
    it,
  )

  doc
}

// ── Пункты задачи: сквозная нумерация внутри задачи; подпункты: (а), (б), ... ──
#let letters = ("а", "б", "в", "г", "д", "е", "ж", "з", "и", "к", "л", "м", "н", "о", "п")

// Первый уровень --- "1.", "2.", ... (общий счётчик: нумерация продолжается
// через колонки). Второй уровень --- "(а)", "(б)", ... Параметр format
// задаёт формат первого уровня (например, "1)" для списков-перечислений).
#let tasklist(id, cols: 1, format: none, full: true, body) = {
  let s = counter(id)
  s.update(1)
  set enum(full: full, numbering: (..n) => context {
    if n.pos().len() <= 1 {
      s.step()
      if format != none {
        s.display(format)
      } else {
        s.display("1.")
      }
    } else {
      "(" + letters.at(n.pos().last() - 1) + ")"
    }
  })
  columns(cols, gutter: 1em)[#body]
}

// ── Алиасы ──
#let neg = sym.not
#let imply = sym.arrow.r
#let implies = imply
#let iff = sym.arrow.l.r
#let to = sym.arrow.r
#let maps = sym.arrow.bar
#let neq = sym.eq.not
#let leq = sym.lt.eq
#let geq = sym.gt.eq
#let models = sym.tack.rr
#let entails = sym.tack.r
#let notin = sym.in.not
#let setminus = sym.without
#let intersect = sym.inter
#let symdiff = sym.triangle
#let sim = sym.tilde
#let angle = sym.chevron
#let bmat = math.mat.with(delim: "[")
#let Bmat = math.mat.with(delim: "{")
#let vmat = math.mat.with(delim: "|")
#let Vmat = math.mat.with(delim: "||")

#let Given(title: none, body) = block(
  width: 100%,
  above: 1em,
  below: 1em,
  inset: (left: 10pt),
  stroke: (left: 1.5pt + accent.lighten(40%)),
)[
  #if title != none [
    #text(size: 0.82em, weight: "bold", fill: accent, tracking: 0.3pt)[#title]
    #v(0.25em, weak: true)
  ]
  #body
]

// ── Указание ──
#let Hint(body) = block(
  width: 100%,
  above: 0.5em,
  below: 0.5em,
)[
  #set text(size: 0.9em)
  #text(fill: warn, weight: "bold")[Указание.] #emph[#body]
]

// ── Бокс (цитата-эпиграф) ──
#let Box(body, align: right, inset: 0.8em) = std.align(align)[
  #set std.align(right)
  #set text(size: 10.5pt, style: "italic", fill: luma(35%))
  #body
]

// ── Блок с левой рамкой ──
#let Block(body, ..args) = {
  block(
    body,
    inset: (x: 1em),
    stroke: (left: 2pt + accent),
    outset: (y: 3pt, left: -3pt),
    ..args,
  )
}

// ── Теги-пилюли ──
#let Tag(label, color) = {
  set text(size: 0.72em, weight: "bold", fill: color.darken(25%))
  box(
    label,
    radius: 50%,
    inset: (x: 0.5em, y: 0.2em),
    outset: (y: 0.2em),
    stroke: 0.7pt + color.darken(25%),
    fill: color.lighten(88%),
  )
}
#let TagCore = Tag("База", green)
#let TagChallenge = Tag("Челлендж", purple)
#let TagBonus = Tag("Бонус", yellow)

// ── Цветовые помощники и логические ярлыки ──
#let Green(x) = text(green.darken(20%), x)
#let Red(x) = text(red.darken(20%), x)

#let True = Green(`true`)
#let False = Red(`false`)
#let YES = Green(sym.checkmark)
#let NO = Red(sym.crossmark)

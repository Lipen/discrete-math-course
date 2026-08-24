// Тема и нотация домашних заданий курса "Дискретная математика".
// Самодостаточная: не зависит от внешних typst-модулей и от `../typst`.
// Подключается из ДЗ: `#import "theme.typ": *` и `#show: template`.

// ── Темплеет ──
#let template(dark: false, doc) = {
  set text(fill: white) if dark
  set page(fill: luma(12%)) if dark

  set text(12pt, lang: "ru")
  set par(justify: true)

  show emph: set text(fill: blue.darken(20%))
  show link: set text(fill: blue.darken(20%))

  show sym.emptyset: set text(font: "Libertinus Sans")

  show "i.e.": set text(style: "italic")
  show "e.g.": set text(style: "italic")
  show "etc.": set text(style: "italic")

  set math.mat(column-gap: 1em)

  doc
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

// ── Список задач с собственным счётчиком ──
#let tasklist(id, cols: 1, format: "1.", body) = {
  let s = counter(id)
  s.update(1)
  set enum(numbering: _ => context {
    s.step()
    s.display(format)
  })
  columns(cols, gutter: 1em)[#body]
}

// ── Бокс (курсив, серая рамка) ──
#let Box(body, align: left, inset: 0.8em) = std.align(align)[
  #box(
    stroke: 0.4pt + gray,
    inset: inset,
    radius: 3pt,
  )[
    #set std.align(left)
    #set text(size: 10pt, style: "italic")
    #body
  ]
]

// ── Блок (левая рамка) ──
#let Block(body, ..args) = {
  block(
    body,
    inset: (x: 1em),
    stroke: (left: 3pt + gray),
    outset: (y: 3pt, left: -3pt),
    ..args,
  )
}

// ── Теги ──
#let Tag(label, color) = {
  set text(size: 0.8em)
  box(
    label,
    radius: 5pt,
    inset: (x: 0.4em),
    outset: (y: 0.4em),
    stroke: 0.6pt + color.darken(20%),
    fill: color.lighten(80%),
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

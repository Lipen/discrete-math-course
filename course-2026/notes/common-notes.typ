// Автономный A4-стиль для конспекта по дискретной математике.
// Импортируется всеми файлами тем и файлами сборки.
//
// Использование:
//   #import "common-notes.typ": *
//   #show: notes-template.with(theme: oklch(55%, 0.16, 230deg))
//   #set document(title: "...", author: "...")

#import "requirements.typ": *

// --- Библиотека теорем ---
#import "theorems.typ": *

#import "notation.typ": *

// --- Вёрстка и символы ---
#let YES = text(fill: green, sym.checkmark)

// --- Окружения: front-matter / main-matter ---
// Используются как вставки (не show-правила), чтобы не заменять notes-template.

// Римская нумерация страниц для титула и содержания.
#let front-matter = {
  set page(numbering: "i")
}

// Арабская нумерация страниц для основного текста.
#let main-matter = {
  set page(numbering: "1")
  set heading(numbering: "1.1.1")
}

// --- Страница-разделитель (часть) ---
#let part(title, number: none, theme: oklch(55%, 0.16, 230deg)) = {
  pagebreak(weak: true)
  set page(header: none, footer: none, numbering: none)
  align(center + horizon)[
    #v(2.5cm)
    #if number != none [
      #text(size: 5em, fill: theme, weight: "bold")[#number]
      #v(0.3em)
    ]
    #line(length: 80%, stroke: 1.5pt + theme)
    #v(1.2em)
    #text(size: 2.8em, weight: "bold")[#title]
    #v(0.3em)
    #line(length: 45%, stroke: 1.5pt + theme)
    #v(2.5cm)
  ]
  pagebreak(weak: true)
}

// --- Размеры шрифта ---
#let h1-size = 22pt
#let h2-size = 16pt
#let h3-size = 14pt
#let h4-size = 12pt
#let chapter-num-size = 42pt

// --- Шаблон: все set/show-правила внутри, чтобы действовали глобально ---
#let notes-template(it, theme: oklch(55%, 0.16, 230deg)) = {
  // Типографика
  set text(
    font: "Libertinus Serif",
    size: 12pt,
    lang: "ru",
  )
  set par(
    justify: true,
    leading: 0.65em,
    first-line-indent: 1em,
    justification-limits: (
      spacing: (min: 100% * 2 / 3, max: 150%),
      tracking: (min: -0.01em, max: 0.02em),
    ),
  )

  // Заголовки
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    counter("definition").update(0)
    counter("theorem").update(0)

    if it.numbering != none {
      v(3em)
      text(size: chapter-num-size, fill: theme, weight: "bold")[
        #counter(heading).display()
      ]
      v(-0.6em)
      line(length: 22%, stroke: 1.5pt + theme)
      v(0.8em)
    }
    text(size: h1-size, weight: "bold")[#it.body]
    v(1.5em)
  }
  show heading.where(level: 2): it => block(
    sticky: true,
    above: 2em,
    below: 1em,
    {
      set text(size: h2-size, weight: "bold")
      box(width: 0em, inset: -1em)[
        #text(fill: theme)[#sym.section]
      ]
      counter(heading).display()
      h(0.5em)
      it.body
      v(-0.2em)
      line(length: 100%, stroke: 0.4pt + theme)
    },
  )
  show heading.where(level: 3): set text(size: h3-size, weight: "bold")
  show heading.where(level: 4): set text(size: h4-size, style: "italic")

  // Нумерация заголовков (3 уровня: 1, 1.1, 1.1.1)
  set heading(numbering: "1.1.1")

  // Математика
  set math.mat(column-gap: 1em)
  show sym.emptyset: set text(font: "Libertinus Sans")

  // Таблицы
  set table(inset: (x: 0.8em, y: 0.3em))
  show table.cell.where(y: 0): strong

  // Содержание: dot leaders
  set outline.entry(fill: box(width: 1fr, repeat(gap: 0.25em)[.]))

  // Рисунки: по центру
  set figure(gap: 0.65em)
  show figure: it => align(center, it)

  // Латинские сокращения
  show "i.e.": set text(style: "italic")
  show "e.g.": set text(style: "italic")
  show "etc.": set text(style: "italic")

  // QED-правила размещения
  setup-qed-rules()

  it
}

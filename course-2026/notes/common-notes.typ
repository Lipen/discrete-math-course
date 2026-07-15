// Автономный A4-стиль для конспекта по дискретной математике.
// Импортируется всеми файлами тем и файлами сборки.
//
// Использование:
//   #import "common-notes.typ": *
//   #show: notes-template.with(theme: oklch(55%, 0.18, 155deg))
//   #set document(title: "...", author: "...")

#import "requirements.typ": *

// --- Библиотека теорем ---
#import "theorems.typ": *

#import "notation.typ": *

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

// --- Страница-разделитель (часть/семестр) ---
#let part(title, theme: oklch(55%, 0.02, 265deg)) = {
  pagebreak()
  set page(header: none, footer: none, numbering: none)
  align(center + horizon)[
    #v(3cm)
    #line(length: 45%, stroke: 1.5pt + theme)
    #v(1.5em)
    #text(size: 2.2em, weight: "bold")[#title]
    #v(0.3em)
    #line(length: 45%, stroke: 1.5pt + theme)
    #v(3cm)
  ]
  pagebreak()
}

// --- Шаблон: все set/show-правила внутри, чтобы действовали глобально ---
#let notes-template(it, theme: oklch(55%, 0.02, 265deg)) = {
  // Типографика
  set text(font: "Libertinus Serif", size: 12pt, lang: "ru")
  set par(justify: true, leading: 0.65em, first-line-indent: 1em)

  // Заголовки
  show heading.where(level: 1): set text(size: 22pt, weight: "bold")
  show heading.where(level: 2): set text(size: 18pt, weight: "bold")
  show heading.where(level: 3): set text(size: 14pt, weight: "bold")
  show heading.where(level: 4): set text(size: 12pt, style: "italic")

  // Нумерация заголовков (3 уровня: 1, 1.1, 1.1.1)
  set heading(numbering: "1.1.1")

  // Открытие главы: крупный номер, линия, воздух.
  show heading.where(level: 1): it => {
    pagebreak()
    counter("definition").update(0)
    counter("theorem").update(0)

    if it.numbering != none {
      v(3em)
      text(size: 3.5em, fill: theme, weight: "bold")[
        #counter(heading).display()
      ]
      v(-0.6em)
      line(length: 22%, stroke: 1.5pt + theme)
      v(1.2em)
    }
    it
    v(2.5em)
  }

  // Математика
  set math.mat(column-gap: 1em)
  show sym.emptyset: set text(font: "Libertinus Sans")

  // Таблицы
  set table(inset: (x: 10pt, y: 4pt))
  show table.cell.where(y: 0): strong

  // Рисунки: по центру
  set figure(gap: 8pt)
  show figure: it => align(center, it)

  // Бумажно-безопасные ссылки: URL в сноску при печати
  show link: it => {
    let url = it.dest
    if type(url) == str and it.body != url {
      it
      footnote(url)
    } else {
      it
    }
  }

  // Латинские сокращения
  show "i.e.": set text(style: "italic")
  show "e.g.": set text(style: "italic")
  show "etc.": set text(style: "italic")

  // QED-правила размещения
  setup-qed-rules()

  it
}

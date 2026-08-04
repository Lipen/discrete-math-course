// Автономный A4-стиль для конспекта по дискретной математике.
// Импортируется всеми файлами тем и файлами сборки.
//
// Использование:
//   #import "common-notes.typ": *
//   #show: notes-template.with(theme: oklch(55%, 0.16, 230deg))
//   #set document(title: "...", author: "...")

#import "requirements.typ": *
#import "theorems.typ": *
#import "notation.typ": *

// --- Вёрстка и символы ---
#let YES = text(fill: green, sym.checkmark)

// Roman numeral helper
#let roman(n) = numbering("I", n)

// --- Орнаменты заголовков ---
#let chapter-ornament(accent) = {
  v(-0.3em)
  line(length: 100%, stroke: 0.5pt + accent)
}

#let section-rule(border) = {
  v(-0.3em)
  line(length: 100%, stroke: 0.35pt + border)
}

// --- Окружения: front-matter / main-matter ---
#let front-matter = {
  set page(numbering: "i")
}

#let main-matter = {
  set page(numbering: "1")
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

// --- Шаблон: все set/show-правила ---
// toc-numbers -- уровни, для которых показывать номера в содержании.
// По умолчанию (2, 3) -- номера секций и подсекций.
// Убрать все: () или (,) -- только h2: (2,).
// sticky-headers -- закреплять заголовки блоков (бейдж+название) при разрыве страниц.
#let notes-template(
  it,
  theme: oklch(55%, 0.16, 230deg),
  toc-numbers: (2, 3),
  sticky-headers: true,
) = {
  sticky-state.update(sticky-headers)
  // Типографика
  set text(
    font: "Libertinus Serif",
    size: 12pt,
    lang: "ru",
  )
  set par(
    justify: true,
    leading: 0.65em,
    // first-line-indent: 1em,
  )

  // show figure.caption: it => {
  //   it
  // }

  set heading(numbering: "1.1.1")

  // Заголовки
  show heading.where(level: 1): it => {
    def-ctr.update(0)
    thm-ctr.update(0)
    pagebreak(weak: true)
    block(
      width: 100%,
      below: 2em,
      sticky: true,
    )[
      #context [
        #let ch = counter(heading).at(it.location()).first()
        #text(
          size: 48pt,
          weight: "bold",
          fill: theme,
          tracking: 0.1em,
        )[#roman(ch)]
      ]
      #v(2em, weak: true)
      #text(
        size: 22pt,
        weight: "medium",
        fill: theme,
        font: "Libertinus Sans",
        tracking: 0.05em,
      )[#it.body]
      #chapter-ornament(theme)
    ]
  }

  show heading.where(level: 2): it => {
    block(
      width: 100%,
      above: 2em,
      below: 1em,
      sticky: true,
    )[
      #text(size: 16pt, weight: "medium")[
        #text(fill: theme)[§] #counter(heading).display()#h(0.5em)#it.body
      ]
      #section-rule(luma(80%))
    ]
  }

  show heading.where(level: 3): it => {
    block(
      width: 100%,
      above: 2em,
      below: 1em,
      sticky: true,
    )[
      #text(size: 14pt, weight: "medium")[
        #counter(heading).display()#h(0.5em)#it.body
      ]
    ]
  }

  // Математика
  set math.mat(column-gap: 1em)
  show sym.emptyset: set text(font: "Libertinus Sans")

  // Таблицы
  set table(inset: (x: 0.8em, y: 0.3em))
  show table.cell.where(y: 0): strong

  // Содержание
  show outline.entry: it => {
    if it.level == 1 {
      let nums = counter(heading).at(it.element.location())
      block(above: 1.5em, below: 0.5em, sticky: true)[
        #text(size: 14pt, weight: "medium")[
          #text(fill: theme)[#roman(nums.first())]#h(0.5em)#link(it.element.location())[#it.element.body]
          #box(width: 1fr, repeat(gap: 0.5em, justify: true)[·])
          #it.page()
        ]
      ]
    } else if it.level == 2 {
      block(above: 0.5em, below: 0.5em, inset: (left: 2em), sticky: true)[
        #context {
          let nums = counter(heading).at(it.element.location())
          text(size: 11.5pt)[
            #if toc-numbers.contains(2) [
              #text(fill: theme)[#numbering("1.1", ..nums.slice(0, 2))]
              #h(0.5em, weak: true)
            ]
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, repeat(gap: 0.5em, justify: true)[·])
            #it.page()
          ]
        }
      ]
    } else if it.level == 3 {
      block(above: 0.3em, below: 0.3em, inset: (left: 4em))[
        #context {
          let nums = counter(heading).at(it.element.location())
          text(size: 10pt, fill: luma(45%))[
            #if toc-numbers.contains(3) [
              #text(fill: theme)[#numbering("1.1.1", ..nums)]
              #h(0.5em, weak: true)
            ]
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, repeat(gap: 0.5em, justify: true)[·])
            #it.page()
          ]
        }
      ]
    }
  }

  // Рисунки: по центру
  set figure(gap: 0.65em)
  show figure: it => align(center, it)

  // Латинские сокращения
  show "i.e.": set text(style: "italic")
  show "e.g.": set text(style: "italic")
  show "etc.": set text(style: "italic")

  it
}

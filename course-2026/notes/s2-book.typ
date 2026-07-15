// Семестр 2 — "Вычисления": сборка книги.
// Включает все темы S2 через #include.

#import "common-notes.typ": *
#import "notation.typ": *

#let theme = oklch(55%, 0.15, 250deg) // синий
#let theme-light = oklch(85%, 0.05, 250deg)

#set document(
  title: "Дискретная математика — конспект лекций",
  author: "Константин Чухарев",
)

// --- Титульная страница ---
#set page(
  paper: "a4",
  margin: (left: 2.5cm, right: 2cm, top: 2cm, bottom: 2.5cm),
  header: none,
  footer: none,
)

#align(center)[
  #block(height: 3cm)
  #text(size: 30pt, weight: "bold")[Дискретная математика]
  #block(height: 0.3cm)
  #text(size: 18pt, fill: luma(40%), weight: "light")[Конспект лекций]
  #block(height: 1.8cm)
  #line(length: 3cm, stroke: 2pt + theme)
  #block(height: 1.2cm)
  #text(size: 13pt, weight: "semibold")[Вычисления]
  #block(height: 0.2cm)
  #text(size: 10pt, fill: luma(50%))[Семестр II]
  #block(height: 2.5cm)
  #text(size: 10pt, fill: luma(45%))[Университет ИТМО] \
  #text(size: 10pt, fill: luma(45%))[Осень 2026 -- Весна 2027]
  #block(height: 1.5cm)
  #text(size: 8pt, fill: luma(60%))[Черновик --- в работе]
]

#pagebreak()

// --- Страницы с контентом ---
#set page(
  paper: "a4",
  margin: (left: 2.5cm, right: 2cm, top: 2.2cm, bottom: 2.5cm),
  header: [
    #set text(7.5pt, fill: luma(45%))
    #text(
      tracking: 0.14em,
      weight: "semibold",
    )[ДИСКРЕТНАЯ МАТЕМАТИКА · КОНСПЕКТ]
    #h(1fr)
    #text(style: "italic", fill: luma(35%))[Вычисления]
    #v(4pt)
    #line(length: 100%, stroke: 0.3pt + luma(85%))
  ],
  footer: context [
    #set text(7.5pt, fill: luma(50%))
    #line(length: 100%, stroke: 0.3pt + luma(85%))
    #v(2pt)
    #h(1fr)
    #counter(page).display("1")
    #h(1fr)
  ],
)

#set heading(numbering: "1.1.1")

// --- Содержание ---
#outline(indent: 1em, depth: 3)

// --- Главы ---
#include "m12-graphs.typ"
#include "m13-automata.typ"
#include "m14-turing.typ"
#include "m15-complexity.typ"

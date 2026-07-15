// Семестр 1 — "Язык и объекты": сборка книги.
// Включает все темы S1 через #include.

#import "common-notes.typ": *
#import "notation.typ": *

#let theme = oklch(55%, 0.18, 155deg) // зелёный
#let theme-light = oklch(85%, 0.05, 155deg)

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
  #text(size: 13pt, weight: "semibold")[Язык и объекты]
  #block(height: 0.2cm)
  #text(size: 10pt, fill: luma(50%))[Семестр I]
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
    #smallcaps[
      #text(
        tracking: 0.1em,
        weight: "semibold",
      )[Дискретная математика]
    ]
    #h(1fr)
    #text(style: "italic", fill: luma(35%))[Язык и объекты]
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
#include "m01-logic-proofs.typ"
#include "m02-sets.typ"
#include "m03-relations.typ"
#include "m04-functions.typ"
#include "m05-order-relations.typ"
#include "m06-boolean-algebra.typ"
#include "m07-circuits.typ"
#include "m08-sat.typ"
#include "m09-combinatorics.typ"
#include "m10-generating-fns.typ"
#include "m11-transfinite.typ"

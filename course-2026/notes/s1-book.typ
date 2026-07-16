// Семестр 1: "Язык и объекты", сборка книги.
// Включает все темы S1 через #include.

#import "common-notes.typ": *
#import "notation.typ": *

#let theme = oklch(55%, 0.18, 155deg) // зелёный
#let theme-light = oklch(85%, 0.05, 155deg)

#set document(
  title: "Дискретная математика --- конспект лекций",
  author: "Константин Чухарев",
)

#show: notes-template.with(theme: theme)

// --- Титульная страница ---
#front-matter

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

// --- Содержание ---
#outline(indent: 1em, depth: 3)

// --- Страницы с контентом ---
#main-matter

#set page(
  paper: "a4",
  margin: (left: 2.5cm, right: 2cm, top: 2.2cm, bottom: 2.5cm),
)
#running-header(theme: theme)

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

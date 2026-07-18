// Дискретная математика --- конспект лекций, полная книга.

#import "common-notes.typ": *
#import "notation.typ": *

#let accent-color = oklch(55%, 0.16, 230deg) // сине-голубой

#set document(
  title: "Дискретная математика --- конспект лекций",
  author: "Константин Чухарев",
)

#show: notes-template.with(theme: accent-color)

// --- Титульная страница ---
#front-matter

#set page(
  paper: "a4",
  margin: (left: 2.5cm, right: 2cm, top: 2cm, bottom: 2.5cm),
  header: none,
  footer: none,
)

#align(center)[
  #block(height: 4cm)
  #text(size: 2.8em, weight: "bold")[Дискретная математика]
  #block(height: 0.4cm)
  #line(length: 3cm, stroke: 2pt + accent-color)
  #block(height: 2cm)
  #text(size: 1em, fill: luma(45%))[Университет ИТМО]
  #block(height: 0.1cm)
  #text(size: 0.85em, fill: luma(55%))[2026 / 2027]
]

#pagebreak(weak: true)

// --- Содержание ---
#outline(indent: 1em, depth: 3)

// --- Основной текст ---
#main-matter

#set page(
  paper: "a4",
  margin: (left: 2.5cm, right: 2cm, top: 2.2cm, bottom: 2.5cm),
  header: context [
    #set text(0.65em, fill: luma(45%))
    #smallcaps[
      #text(tracking: 0.1em, weight: "semibold")[Дискретная математика]
    ]
    #h(1fr)
    #{
      let pg = counter(page).get().first()
      let hs = query(heading.where(level: 1))
      let ch = hs.rev().find(h => counter(page).at(h.location()).first() <= pg)
      if ch != none {
        text(style: "italic", fill: luma(35%))[#ch.body]
      }
    }
    #v(4pt)
    #line(length: 100%, stroke: 0.3pt + luma(85%))
  ],
  footer: context [
    #set text(0.65em, fill: luma(50%))
    #line(length: 100%, stroke: 0.3pt + luma(85%))
    #v(2pt)
    #h(1fr)
    #counter(page).display("1")
    #h(1fr)
  ],
)

// --- Главы ---
#include "m01-logic-proofs.typ"
#include "m02-sets.typ"
#include "m03-relations.typ"
#include "m04-functions.typ"
#include "m05-order-relations.typ"
#include "m12-graphs.typ"
#include "m06-boolean-algebra.typ"
#include "m07-circuits.typ"
#include "m08-sat.typ"
#include "m09-combinatorics.typ"
#include "m10-generating-fns.typ"
#include "m11-transfinite.typ"

#include "m13-automata.typ"
#include "m14-turing.typ"
#include "m15-complexity.typ"

// --- Упражнения ---
#include "exercises.typ"

// Дискретная математика --- конспект лекций, полная книга.
// Два семестра, единый документ.

#import "common-notes.typ": *
#import "notation.typ": *

#let s1-theme = oklch(55%, 0.18, 155deg) // зелёный --- "Язык и объекты"
#let s2-theme = oklch(55%, 0.15, 250deg) // синий --- "Вычисления"

#set document(
  title: "Дискретная математика --- конспект лекций",
  author: "Константин Чухарев",
)

#show: notes-template.with(theme: s1-theme)

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
  #text(size: 2.5em, weight: "bold")[Дискретная математика]
  #block(height: 0.3cm)
  #text(size: 1.5em, fill: luma(40%), weight: "light")[Конспект лекций]
  #block(height: 1.8cm)
  #line(length: 3cm, stroke: 2pt + s1-theme)
  #block(height: 1.2cm)
  #text(size: 1.1em, weight: "semibold")[Язык, объекты, вычисления]
  #block(height: 0.2cm)
  #text(size: 0.85em, fill: luma(50%))[Семестры I и II]
  #block(height: 2.5cm)
  #text(size: 0.85em, fill: luma(45%))[Университет ИТМО] \
  #text(size: 0.85em, fill: luma(45%))[2026 -- 2027]
  #block(height: 1.5cm)
  #text(size: 0.65em, fill: luma(60%))[Черновик --- в работе]
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

// --- Семестр I: Язык и объекты ---
#part("Язык и объекты", number: "I", theme: s1-theme)

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

// --- Семестр II: Вычисления ---
#part("Вычисления", number: "II", theme: s2-theme)

#include "m12-graphs.typ"
#include "m13-automata.typ"
#include "m14-turing.typ"
#include "m15-complexity.typ"

// --- Упражнения ---
#include "exercises.typ"

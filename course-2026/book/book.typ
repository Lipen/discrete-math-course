// Дискретная математика --- полная книга курса.

#import "common.typ": *
#import "notation.typ": *
#import "title-page.typ": *

#let accent-color = oklch(55%, 0.16, 230deg) // сине-голубой

#set document(
  title: "Дискретная математика",
  author: "Константин Чухарев",
)

#show: notes-template.with(theme: accent-color)

// --- Титульная страница ---
#front-matter

#set page(
  paper: "a4",
  margin: (left: 3cm, right: 2.5cm, top: 3cm, bottom: 2.5cm),
  header: none,
  footer: none,
)

#title-page()

#pagebreak(weak: true)

// --- Содержание ---
#heading(
  level: 1,
  numbering: none,
  outlined: false,
  bookmarked: true,
)[Содержание]
#outline(title: none, indent: 1em, depth: 3)

// --- Основной текст ---
#main-matter

#set page(
  paper: "a4",
  margin: (left: 3cm, right: 2.5cm, top: 3cm, bottom: 2.5cm),
  header: [
    #set text(size: 8.5pt, fill: luma(45%))
    #grid(
      columns: (1fr, 1fr),
      align(left)[#text(tracking: 0.08em)[ДИСКРЕТНАЯ МАТЕМАТИКА]],
      align(right)[
        #context {
          let pg = counter(page).get().first()
          let name = ""
          let num = 0
          let no-num = false
          for h in query(heading.where(level: 1)) {
            let hp = counter(page).at(h.location()).first()
            if hp <= pg {
              name = h.body
              num = counter(heading).at(h.location()).first()
              no-num = h.numbering == none
            }
          }
          if (not no-num) and num > 0 {
            [#num. #name]
          } else {
            name
          }
        }
      ],
    )
    #v(0.25em)
    #line(length: 100%, stroke: 0.3pt + luma(80%))
  ],
  footer: align(center)[
    #set text(size: 8pt, fill: luma(50%))
    #align(center)[
      #line(length: 3cm, stroke: 0.3pt + luma(80%))
      #v(0.15em)
      #context { counter(page).display("1") }
    ]
  ],
)

// --- Главы ---
#include "introduction.typ"
#include "m01-logic.typ"
#include "m02-deduction.typ"
#include "m03-fol.typ"
#include "m04-sets.typ"
#include "m05-relations.typ"
#include "m06-functions.typ"
#include "m07-cardinals.typ"
#include "m08-order-relations.typ"
#include "m09-graphs.typ"
#include "m10-boolean-algebra.typ"
#include "m11-circuits.typ"
#include "m12-algebra.typ"
#include "m13-codes.typ"
#include "m14-sat.typ"
#include "m15-smt.typ"
#include "m16-logic-programming.typ"
#include "m17-matroids.typ"
#include "m18-combinatorics.typ"
#include "m19-number-theory-crypto.typ"
#include "m20-probability.typ"
#include "m21-generating-fns.typ"
#include "m22-constructions.typ"
#include "m23-automata.typ"
#include "m24-context-free.typ"
#include "m25-turing.typ"
#include "m26-decidability.typ"
#include "m27-lambda.typ"
#include "m28-type-theory.typ"
#include "m29-beyond-n.typ"
#include "m30-complexity.typ"
#include "m31-abstract-interpretation.typ"
#include "m32-verification.typ"
#include "m33-modal.typ"
#include "m34-intuitionism.typ"
#include "m35-fuzzy-sets.typ"
#include "m36-categories.typ"
#include "conclusion.typ"

// --- Указания к упражнениям со звёздочкой ---
#include "hints.typ"

// --- Глоссарий ---
#include "glossary.typ"

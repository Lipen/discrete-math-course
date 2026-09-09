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
#include "chapters/m01-logic.typ"
#include "chapters/m02-deduction.typ"
#include "chapters/m03-fol.typ"
#include "chapters/m04-sets.typ"
#include "chapters/m05-relations.typ"
#include "chapters/m06-functions.typ"
#include "chapters/m07-cardinals.typ"
#include "chapters/m08-order-relations.typ"
#include "chapters/m09-graphs.typ"
#include "chapters/m10-boolean-algebra.typ"
#include "chapters/m11-circuits.typ"
#include "chapters/m12-algebra.typ"
#include "chapters/m13-codes.typ"
#include "chapters/m14-sat.typ"
#include "chapters/m15-smt.typ"
#include "chapters/m16-logic-programming.typ"
#include "chapters/m17-matroids.typ"
#include "chapters/m18-combinatorics.typ"
#include "chapters/m19-number-theory-crypto.typ"
#include "chapters/m20-probability.typ"
#include "chapters/m21-generating-fns.typ"
#include "chapters/m22-constructions.typ"
#include "chapters/m23-automata.typ"
#include "chapters/m24-context-free.typ"
#include "chapters/m25-turing.typ"
#include "chapters/m26-decidability.typ"
#include "chapters/m27-lambda.typ"
#include "chapters/m28-type-theory.typ"
#include "chapters/m29-beyond-n.typ"
#include "chapters/m30-complexity.typ"
#include "chapters/m31-abstract-interpretation.typ"
#include "chapters/m32-verification.typ"
#include "chapters/m33-modal.typ"
#include "chapters/m34-intuitionism.typ"
#include "chapters/m35-fuzzy-sets.typ"
#include "chapters/m36-categories.typ"
#include "conclusion.typ"

// --- Указания к упражнениям со звёздочкой ---
#include "hints.typ"

// --- Глоссарий ---
#include "glossary.typ"

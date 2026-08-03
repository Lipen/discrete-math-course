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
  margin: (left: 3cm, right: 2.5cm, top: 3cm, bottom: 2.5cm),
  header: none,
  footer: none,
)

#align(center + horizon)[
  #block(
    fill: white,
    inset: (x: 3.5em, y: 2.5em),
    radius: 6pt,
    stroke: 0.4pt + luma(80%),
    width: auto,
  )[
    #align(center)[
      #text(
        size: 9pt,
        weight: "semibold",
        fill: accent-color,
        tracking: 0.14em,
      )[#upper[университет итмо]]
      #v(0.8em)
      #text(
        size: 44pt,
        weight: "bold",
        fill: accent-color,
        font: "Libertinus Sans",
      )[ДИСКРЕТНАЯ]
      #v(0em)
      #text(
        size: 44pt,
        weight: "light",
        fill: accent-color,
        font: "Libertinus Sans",
      )[МАТЕМАТИКА]
      #v(0.6em)
      #line(length: 4cm, stroke: 0.5pt + accent-color)
      #v(0.8em)
      #text(size: 10pt, fill: luma(45%))[2026 / 2027]
    ]
  ]
]

#pagebreak(weak: true)

// --- Содержание ---
#outline(indent: 1em, depth: 3)

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
          for h in query(heading.where(level: 1)) {
            let hp = counter(page).at(h.location()).first()
            if hp <= pg {
              name = h.body
              num = counter(heading).at(h.location()).first()
            }
          }
          if num > 0 {
            [#roman(num). #name]
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
#include "m01-logic-proofs.typ"
#include "m02-sets.typ"
#include "m03-relations.typ"
#include "m04-functions.typ"
#include "m05-cardinals.typ"
#include "m06-order-relations.typ"
#include "m07-graphs.typ"
#include "m08-boolean-algebra.typ"
#include "m09-circuits.typ"
#include "m10-codes.typ"
#include "m11-sat.typ"
#include "m12-combinatorics.typ"
#include "m13-probability.typ"
#include "m14-generating-fns.typ"
#include "m15-constructions.typ"

#include "m16-automata.typ"
#include "m19-turing.typ"
#include "m20-decidability.typ"
#include "m21-lambda.typ"
#include "m22-type-theory.typ"
#include "m23-beyond-n.typ"
#include "m24-complexity.typ"
#include "m25-fuzzy-sets.typ"

// --- Глоссарий ---
#include "glossary.typ"

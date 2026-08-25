// Дискретная математика --- конспект лекций, полная книга.

#import "common.typ": *
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
    inset: (x: 5em, y: 3.2em),
    radius: 0pt,
    stroke: 0.5pt + luma(78%),
    width: auto,
  )[
    #align(center)[
      // Шапка --- университет, мелко и разрежённо
      #text(
        size: 9pt,
        weight: "semibold",
        fill: luma(50%),
        tracking: 0.2em,
      )[#upper[университет итмо]]

      #v(1.7em)

      // Заглавие на греческом --- как в "Началах"
      #text(
        size: 27pt,
        weight: "medium",
        fill: accent-color,
        font: "Libertinus Serif",
        tracking: 0.06em,
      )[ΔΙΑΚΡΙΤΑ ΜΑΘΗΜΑΤΙΚΑ]

      #v(0.7em)
      #line(length: 5cm, stroke: 0.7pt + accent-color)
      #v(0.35em)
      #text(
        size: 12pt,
        style: "italic",
        fill: luma(55%),
        font: "Libertinus Serif",
        tracking: 0.18em,
      )[Mathematica Discreta]

      #v(1.6em)

      // Русское заглавие --- читаемое
      #text(size: 19pt, weight: "medium", fill: black)[Дискретная математика]
      #v(0.25em)
      #text(size: 11.5pt, fill: luma(45%), tracking: 0.04em)[конспект лекций]

      #v(1.8em)

      // Эпиграф --- знаменитые слова Эвклида
      #text(
        size: 10.5pt,
        style: "italic",
        fill: luma(40%),
        font: "Libertinus Serif",
      )[«Οὐκ ἔστι βασιλικὴ ὁδὸς ἐπὶ γεωμετρίαν»]
      #v(0.3em)
      #text(size: 9.5pt, fill: luma(55%))[к геометрии нет царского пути]
      #v(0.35em)
      #text(size: 9.5pt, weight: "semibold", fill: luma(50%))[--- Евклид]

      #v(2.0em)

      #line(length: 3cm, stroke: 0.4pt + luma(80%))
      #v(0.7em)
      #text(size: 10.5pt, fill: luma(40%))[Константин Чухарев]
      #v(0.3em)
      #text(size: 9.5pt, fill: luma(50%))[2026 / 2027]
    ]
  ]
]

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
#include "m12-codes.typ"
#include "m13-sat.typ"
#include "m14-smt.typ"
#include "m15-logic-programming.typ"
#include "m16-matroids.typ"
#include "m17-combinatorics.typ"
#include "m18-number-theory-crypto.typ"
#include "m19-probability.typ"
#include "m20-generating-fns.typ"
#include "m21-constructions.typ"
#include "m22-automata.typ"
#include "m23-context-free.typ"
#include "m24-turing.typ"
#include "m25-decidability.typ"
#include "m26-lambda.typ"
#include "m27-type-theory.typ"
#include "m28-beyond-n.typ"
#include "m29-complexity.typ"
#include "m30-abstract-interpretation.typ"
#include "m31-verification.typ"
#include "m32-modal.typ"
#include "m33-intuitionism.typ"
#include "m34-fuzzy-sets.typ"
#include "conclusion.typ"

// --- Указания к упражнениям со звёздочкой ---
#include "hints.typ"

// --- Глоссарий ---
#include "glossary.typ"

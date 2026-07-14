// Semester 1 — «Language and Objects»: book assembly.
// Includes all S1 topic files via #include.

#import "common-notes.typ": *
#import "notation.typ": *

#let theme = oklch(55%, 0.18, 155deg) // green

#set document(
  title: "Discrete Mathematics — Lecture Notes",
  author: "Konstantin Chukharev",
)

// --- Title page ---
#set page(
  paper: "a4",
  margin: (left: 2.5cm, right: 2cm, top: 2cm, bottom: 2.5cm),
  header: none,
  footer: none,
)

#align(center)[
  #block(height: 3cm)
  #line(length: 4cm, stroke: 2pt + theme)
  #block(height: 1.5cm)
  #text(size: 28pt, weight: "bold")[Discrete Mathematics]
  #block(height: 0.4cm)
  #text(size: 20pt, fill: luma(35%))[Lecture Notes]
  #block(height: 1.5cm)
  #text(size: 14pt)[Language and Objects]
  #text(size: 11pt, fill: luma(45%))[Semester 1]
  #block(height: 2.5cm)
  #text(size: 11pt, fill: luma(45%))[ITMO University]
  #text(size: 11pt, fill: luma(45%))[Fall 2026 — Spring 2027]
  #block(height: 1.5cm)
  #text(size: 9pt, fill: luma(55%))[Draft — work in progress]
]

#pagebreak()

// --- Content pages ---
#set page(
  paper: "a4",
  margin: (left: 2.5cm, right: 2cm, top: 2.2cm, bottom: 2.5cm),
  header: [
    #line(length: 100%, stroke: 1.5pt + theme)
    #v(3pt)
    #set text(7.5pt, fill: luma(45%))
    #text(tracking: 0.12em)[DISCRETE MATH · NOTES]
    #h(1fr)
    #emph[Language and Objects]
  ],
  footer: context [
    #set text(8pt, fill: luma(50%))
    #line(length: 100%, stroke: 0.3pt + luma(88%))
    #v(2pt)
    #h(1fr)
    #counter(page).display("1")
    #h(1fr)
  ],
)

#set heading(numbering: "1.1.1")

// --- Table of contents ---
#outline(indent: 1em, depth: 3)

// --- Topic chapters ---
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

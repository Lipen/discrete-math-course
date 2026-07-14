// Semester 1 — «Language and Objects»: book assembly.
// Includes all S1 topic files via #include.

#import "common-notes.typ": *
#import "notation.typ": *

#let theme = oklch(55%, 0.18, 155deg) // green
#let theme-light = oklch(85%, 0.05, 155deg)

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
  #block(height: 2.5cm)
  // Geometric accent: circle on a pole
  #align(center)[
    #rect(width: 7pt, height: 7pt, fill: theme, radius: 50%, inset: 0pt)
    #v(6pt)
    #line(length: 1pt, stroke: 1.5pt + theme)
    #v(1pt)
    #line(length: 3cm, stroke: 2pt + theme)
  ]
  #block(height: 2cm)
  #text(size: 30pt, weight: "bold")[Discrete Mathematics]
  #block(height: 0.3cm)
  #text(size: 18pt, fill: luma(40%), weight: "light")[Lecture Notes]
  #block(height: 1.8cm)
  #line(length: 3cm, stroke: 0.3pt + luma(80%))
  #block(height: 1.2cm)
  #text(size: 13pt, weight: "semibold")[Language and Objects]
  #block(height: 0.2cm)
  #text(size: 10pt, fill: luma(50%))[Semester 1]
  #block(height: 2.5cm)
  #text(size: 10pt, fill: luma(45%))[ITMO University]
  #text(size: 10pt, fill: luma(45%))[Fall 2026 — Spring 2027]
  #block(height: 1.5cm)
  #text(size: 8pt, fill: luma(60%))[Draft — work in progress]
]

#pagebreak()

// --- Content pages ---
#set page(
  paper: "a4",
  margin: (left: 2.5cm, right: 2cm, top: 2.2cm, bottom: 2.5cm),
  header: [
    // Top bar — thick colored
    #line(length: 100%, stroke: 2.5pt + theme)
    #v(1pt)
    // Second bar — lighter echo
    #line(length: 100%, stroke: 0.5pt + theme-light)
    #v(5pt)
    // Header text line
    #set text(7.5pt, fill: luma(45%))
    #rect(width: 4.5pt, height: 4.5pt, fill: theme, inset: 0pt)
    #h(5pt)
    #text(tracking: 0.18em, weight: "semibold")[DISCRETE MATH · NOTES]
    #h(1fr)
    #text(style: "italic", fill: luma(35%))[Language and Objects]
    #v(4pt)
    // Bottom rule — thin gray
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

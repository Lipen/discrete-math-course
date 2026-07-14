// Semester 2 — «Computation»: book assembly.
// Includes all S2 topic files via #include.

#import "common-notes.typ": *
#import "notation.typ": *

#let theme = oklch(55%, 0.15, 250deg) // blue
#let theme-light = oklch(85%, 0.05, 250deg)

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
  #text(size: 30pt, weight: "bold")[Discrete Mathematics]
  #block(height: 0.3cm)
  #text(size: 18pt, fill: luma(40%), weight: "light")[Lecture Notes]
  #block(height: 1.8cm)
  #line(length: 3cm, stroke: 2pt + theme)
  #block(height: 1.2cm)
  #text(size: 13pt, weight: "semibold")[Computation]
  #block(height: 0.2cm)
  #text(size: 10pt, fill: luma(50%))[Semester 2]
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
    #set text(7.5pt, fill: luma(45%))
    #text(tracking: 0.14em, weight: "semibold")[DISCRETE MATH · NOTES]
    #h(1fr)
    #text(style: "italic", fill: luma(35%))[Computation]
    #v(4pt)
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
#include "m12-graphs.typ"
#include "m13-automata.typ"
#include "m14-turing.typ"
#include "m15-complexity.typ"

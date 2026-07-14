// Semester 2 — «Computation»: book assembly.
// Includes all S2 topic files via #include.

#import "common-notes.typ": *
#import "notation.typ": *

#let theme = oklch(55%, 0.15, 250deg) // blue

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
  #text(size: 14pt)[Computation]
  #text(size: 11pt, fill: luma(45%))[Semester 2]
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
    #emph[Computation]
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
#include "m12-graphs.typ"
#include "m13-automata.typ"
#include "m14-turing.typ"
#include "m15-complexity.typ"

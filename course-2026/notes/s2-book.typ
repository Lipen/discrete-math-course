// Semester 2 --- «Computation»: book assembly.
// Includes all S2 topic files via #include.

#import "common-notes.typ": *
#import "notation.typ": *

// Must be in root file — set rules inside imported modules don't affect headings.
#set heading(numbering: "1.1.1")

#set document(
  title: "Discrete Mathematics --- Lecture Notes",
  author: "Konstantin Chukharev",
)

// --- Title page ---
#align(center)[
  #block(height: 4cm)
  #text(size: 28pt, weight: "bold")[Discrete Mathematics]
  #block(height: 0.5cm)
  #text(size: 22pt)[Lecture Notes]
  #block(height: 1cm)
  #text(size: 16pt)[Semester 2 --- Computation]
  #block(height: 2cm)
  #text(size: 12pt)[ITMO University]
  #text(size: 12pt)[Fall 2026 --- Spring 2027]
  #block(height: 1cm)
  #text(size: 10pt, fill: luma(50%))[Draft --- work in progress]
]

#pagebreak()

// --- Table of contents ---
#outline(indent: 1em, depth: 3)

// --- Topic chapters ---
#include "m12-graphs.typ"
#include "m13-automata.typ"
#include "m14-turing.typ"
#include "m15-complexity.typ"

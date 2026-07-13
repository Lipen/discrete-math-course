// Semester 1 --- «Language and Objects»: book assembly.
// Includes all S1 topic files via #include.

#import "common-notes.typ": *
#import "notation.typ": *

#set document(
title: "Discrete Mathematics --- Lecture Notes", author: "Konstantin Chukharev", )

// --- Title page ---
#align(center)[
  #block(height: 4cm)
  #text(size: 28pt, weight: "bold")[Discrete Mathematics]
  #block(height: 0.5cm)
  #text(size: 22pt)[Lecture Notes]
  #block(height: 1cm)
  #text(size: 16pt)[Semester 1 --- Language and Objects]
  #block(height: 2cm)
  #text(size: 12pt)[ITMO University]
  #text(size: 12pt)[2026/27]
  #block(height: 1cm)
  #text(size: 10pt, fill: luma(50%))[Draft --- work in progress]
]

#pagebreak()

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

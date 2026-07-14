// Semester 1 --- «Language and Objects»: book assembly.
// Includes all S1 topic files via #include.

#import "common-notes.typ": *
#import "notation.typ": *

// Must be in root file — set rules inside imported modules don't affect these elements.
#set page(
paper: "a4", margin: (left: 2.5cm, right: 2cm, top: 2cm, bottom: 2.5cm), header: [
    #set text(9pt, fill: luma(40%))
    Discrete Math --- Lecture Notes
    #h(1fr)
Fall 2026 --- Spring 2027 ], footer: context [
    #set text(9pt, fill: luma(40%))
    #h(1fr)
    #counter(page).display("1")
    #h(1fr) ],
)
#set heading(numbering: "1.1.1")

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
  #text(size: 12pt)[Fall 2026 --- Spring 2027]
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

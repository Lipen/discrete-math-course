#import "theme.typ": *
#show: slides.with(
  title: [Formal Logic],
  subtitle: "Discrete Math",
  date: "Fall 2025",
  authors: "Konstantin Chukharev",
  // dark: true,
)

#show table.cell.where(y: 0): strong

#set quote(block: true)
#show quote: set par(justify: false)
#show quote: set align(left)

#let iff = symbol(math.arrow.double.l.r.long, ("not", math.arrow.double.l.r.not))
#let power(x) = $cal(P)(#x)$
#let pair(a, b) = $angle.l #a, #b angle.r$
#let rel(x) = math.class("relation", x)
#let nrel(x) = rel(math.cancel(x))
#let matrel(x) = $bracket.double.l #x bracket.double.r$
#let Dom = math.op("Dom")
#let Cod = math.op("Cod")
#let Range = math.op("Range")
#let equinumerous = symbol(math.approx, ("not", math.approx.not))
#let smaller = symbol(math.prec, ("eq", math.prec.eq))
#let Join = math.or
#let Meet = math.and
#let nand = $overline(and)$
#let nor = $overline(or)$

#let Green(x) = text(green.darken(20%), x)
#let Red(x) = text(red.darken(20%), x)
#let Blue(x) = text(blue.darken(20%), x)

#let True = Green(`true`)
#let False = Red(`false`)

#let YES = Green(sym.checkmark)
#let NO = Red(sym.crossmark)

#let Block(
  color: blue.lighten(40%),
  body,
) = block(
  body,
  fill: color.lighten(80%),
  stroke: 1pt + color.darken(20%),
  radius: 5pt,
  inset: 8pt,
)

#show heading.where(level: 1): none

= Formal Logic
#focus-slide(
  epigraph: [Logic is the anatomy of thought.],
  epigraph-author: [John Locke],
  scholars: (
    (
      name: "Kurt Gödel",
      image: image("assets/Kurt_Godel.jpg"),
    ),
    (
      name: "Alfred Tarski",
      image: image("assets/Alfred_Tarski.jpg"),
    ),
    "TODO",
  ),
)

// == Historical Introduction

// The development of mathematical logic transformed both mathematics and philosophy, providing rigorous foundations for reasoning and computation.

// === Gottlob Frege (1848-1925)

// Frege revolutionized logic by:
// - Creating the first complete system of mathematical logic (_Begriffsschrift_, 1879)
// - Introducing the distinction between _syntax_ and _semantics_
// - Developing predicate logic with quantifiers
// - Attempting to reduce arithmetic to logic (logicism)

// === The Logical Revolution

// #example[Key Milestones][
//   - *1879*: Frege's _Begriffsschrift_ - first formal logical system
//   - *1910-1913*: Russell & Whitehead's _Principia Mathematica_
//   - *1930*: Gödel's Completeness Theorem
//   - *1931*: Gödel's Incompleteness Theorems
//   - *1936*: Church's undecidability of first-order logic
// ]

// == Syntax and Semantics

// #Box(color: yellow)[
//   *Mathematical logic* distinguishes between
//   - the _form_ of logical expressions (_syntax_)
//   - and their _meaning_ (_semantics_).
// ]

// == Syntax: The Language of Logic

// #Box[
//   *Syntax* concerns the formal _structure_ of logical expressions --- how symbols are arranged according to grammatical rules, _independent of meaning_.
// ]

// #definition[
//   A _well-formed formula_ (WFF) is a string of symbols constructed according to the syntactic rules of a logical system.
// ]

// == Semantics: The Meaning of Logic

// #Box[
//   *Semantics* concerns the _meaning_ (or _interpretation_) of logical expressions --- how they relate to _truth_ values and the world.
// ]

// #definition[
//   An _interpretation_ assigns meaning to the symbols of a logical language, determining truth values for formulas.
// ]

== Propositional Logic

#definition[
  Logic is the study of valid reasoning.
]

#definition[
  Formal logic is the study of deductively valid inferences or logical truths.
]

#example[
  _Modus ponens_ inference rule:
  #grid(
    inset: 5pt,
    columns: 1,
    $P$,
    $P arrow.r Q$,
    grid.hline(stroke: .8pt),
    $therefore Q$,
  )
]

#definition[Propositional Logic][
  The simplest form of logic, dealing with whole statements (_propositions_) that can be either #True or #False.

  Also known as _sentential logic_ or _zeroth-order logic_.
]

== Syntax: The Language of Logic

#Block[
  *Syntax* concerns the formal _structure_ of logical expressions --- how symbols are arranged according to grammatical rules, _independent of meaning_.
]

#definition[
  A propositional _language_ consists of:
  - _Propositional variables_: $P, Q, R, dots$ (atomic propositions)
  - _Logical connectives_: $not, and, or, imply, iff$
  - _Punctuation_: parentheses for grouping
]

#definition[
  A _well-formed formula_ (WFF) in propositional logic is defined recursively:
  - Every propositional variable is a WFF.
  - If $alpha$ is a WFF, then $not alpha$ is a WFF.
  - If $alpha$ and $beta$ are WFFs, then $(alpha and beta)$, $(alpha or beta)$, $(alpha imply beta)$, $(alpha iff beta)$ are WFFs.
  - Nothing else is a WFF.
]

== Semantics: The Meaning of Logic

#Block[
  *Semantics* concerns the _meaning_ (or _interpretation_) of logical expressions --- how they relate to _truth_ values and the world.
]

// #definition[
//   An _interpretation_ assigns meaning to the symbols of a logical language, determining truth values for formulas.
// ]

- Each propositional variable is assigned a truth value: #True or #False.
- More formally, an _interpretation_ $nu : V to BB$ assigns truth values ($BB = {0,1}$) to variables (atoms) $V$.

// #definition[
//   An _interpretation_ $nu : V to BB$ assigns truth values ($BB = {0,1} = {#false, #true}$) to propositional variables (atoms) $V$.
// ]

#let Eval_(phi, inter) = $bracket.double.l phi bracket.double.r_(inter)$
#let Eval(phi) = Eval_(phi, $nu$)
// #let Eval(phi) = $nu(phi)$

#definition[
  The truth value (_evaluation_) of complex formulas is determined recursively:
  $
           Eval(not alpha) & = True  && "iff" Eval(alpha) = False \
      Eval(alpha and beta) & = True  && "iff" Eval(alpha) = True "and" Eval(beta) = True \
       Eval(alpha or beta) & = True  && "iff" Eval(alpha) = True "or" Eval(beta) = True "(or both)" \
    Eval(alpha imply beta) & = False && "iff" Eval(alpha) = True "and" Eval(beta) = False \
      Eval(alpha iff beta) & = True  && "iff" Eval(alpha) = Eval(beta)
  $
]

== TODO

- First-Order Logic (FOL)
- Natural Deduction
- Sequent Calculus
- Fitch notation
- Inference rules and proof theory
- Soundness and Completeness

// == Bibliography
// #bibliography("refs.yml")

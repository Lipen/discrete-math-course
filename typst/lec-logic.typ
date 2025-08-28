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
#let proves = entails

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
    columns: 1,
    inset: 5pt,
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

#let EvalWith(phi, inter) = $bracket.double.l phi bracket.double.r_(inter)$
#let Eval(phi) = EvalWith(phi, $nu$)

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

== Truth Tables

#definition[
  A _truth table_ systematically lists all possible truth value assignments to propositional variables and shows the resulting truth values of complex formulas.
]

#example[Truth Tables for Basic Connectives][
  #grid(
    columns: 3,
    column-gutter: 2em,
    // Negation
    table(
      columns: 2,
      align: center,
      stroke: none,
      table.header([$P$], [$not P$]),
      table.hline(),
      [#True], [#False],
      [#False], [#True],
    ),
    // Conjunction and Disjunction
    table(
      columns: 4,
      align: center,
      stroke: none,
      table.header([$P$], [$Q$], [$P and Q$], [$P or Q$]),
      table.hline(),
      [#True], [#True], [#True], [#True],
      [#True], [#False], [#False], [#True],
      [#False], [#True], [#False], [#True],
      [#False], [#False], [#False], [#False],
    ),
    // Implication and Biconditional
    table(
      columns: 4,
      align: center,
      stroke: none,
      table.header([$P$], [$Q$], [$P imply Q$], [$P iff Q$]),
      table.hline(),
      [#True], [#True], [#True], [#True],
      [#True], [#False], [#False], [#False],
      [#False], [#True], [#True], [#False],
      [#False], [#False], [#True], [#True],
    ),
  )
]

== Semantic Concepts

#definition[
  A formula $phi$ is _satisfiable_ if there exists an interpretation $nu$ such that $EvalWith(phi, nu) = True$.

  A formula is _unsatisfiable_ if no such interpretation exists.
]

#definition[
  A formula $phi$ is a _tautology_ (or _valid_) if $EvalWith(phi, nu) = True$ for every interpretation $nu$.

  Notation: $models phi$ (read: "$phi$ is valid").
]

#definition[
  A formula $phi$ is a _contradiction_ if $EvalWith(phi, nu) = False$ for every interpretation $nu$.
]

#example[
  - $P or not P$ is a tautology (Law of Excluded Middle)
  - $P and not P$ is a contradiction
  - $P or Q$ is satisfiable but not a tautology
]

== Logical Equivalence

#definition[
  Two formulas $alpha$ and $beta$ are _logically equivalent_, written $alpha equiv beta$, if they have the same truth value under every interpretation:
  $
    alpha equiv beta
    quad "iff" quad
    forall nu. thin EvalWith(alpha, nu) = EvalWith(beta, nu)
  $
]

#example[Important Equivalences][
  #grid(
    columns: 2,
    column-gutter: 1em,
    [
      *De Morgan's Laws:*
      - $not (P and Q) equiv not P or not Q$
      - $not (P or Q) equiv not P and not Q$

      *Double Negation:*
      - $not not P equiv P$

      *Implication:*
      - $P imply Q equiv (not P) or Q$
    ],
    [
      *Associativity:*
      - $(P and Q) and R equiv P and (Q and R)$
      - $(P or Q) or R equiv P or (Q or R)$

      *Commutativity:*
      - $P and Q equiv Q and P$
      - $P or Q equiv Q or P$

      *Distributivity:*
      - $P and (Q or R) equiv (P and Q) or (P and R)$
    ],
  )
]

== Semantic Entailment

#definition[
  A set of formulas $Gamma$ _semantically entails_ a formula $alpha$, written $Gamma models alpha$, if every interpretation that makes all formulas in $Gamma$ true also makes $alpha$ true:
  $
    Gamma models alpha
    quad "iff" quad
    forall nu. thin (forall beta in Gamma. thin EvalWith(beta, nu) = True) imply EvalWith(alpha, nu) = True
  $
]

#example[
  ${P imply Q, P} models Q$ (this captures modus ponens semantically)
]

#theorem[Semantic Deduction Theorem][
  For any formulas $alpha$ and $beta$:
  $
    {alpha} models beta
    quad "iff" quad
    models alpha imply beta
  $
]

== Normal Forms

#definition[
  A _literal_ is either a propositional variable $P$ or its negation $not P$.
]

#definition[
  A formula is in _conjunctive normal form_ (CNF) if it is a conjunction of disjunctions of literals:
  $
    (L_(1,1) or dots or L_(1,k_1)) and dots and (L_(n,1) or dots or L_(n,k_n))
  $

  Each disjunction $(L_(i,1) or dots or L_(i,k_i))$ is called a _clause_.
]

#definition[
  A formula is in _disjunctive normal form_ (DNF) if it is a disjunction of conjunctions of literals:
  $
    (L_(1,1) and dots and L_(1,k_1)) or dots or (L_(n,1) and dots and L_(n,k_n))
  $
]

#theorem[Normal Form Existence][
  Every propositional formula is logically equivalent to a formula in CNF and to a formula in DNF.
]

// TODO: add complete conversion algorithm steps
#example[
  $(P imply Q) and R$

  Converting to CNF:
  1. Eliminate implications: $(not P or Q) and R$
  2. Already in CNF: $(not P or Q) and R$

  Converting to DNF:
  1. Distribute: $(not P and R) or (Q and R)$
]

// TODO: Mention that CNF is preferred for SAT solvers, and DNF is better for some model checking applications.

== Boolean Satisfiability Problem (SAT)

#definition[SAT Problem][
  Given a propositional formula $phi$, determine whether $phi$ is satisfiable.
]

#theorem[Cook-Levin Theorem][
  SAT is NP-complete.
]
// TODO: proof

== From Semantics to Syntax

// TODO: Emphasize that we want syntactic methods that match semantic truths.

#Block[
  So far we've studied _semantics_ --- what formulas _mean_ in terms of truth values.

  Now we turn to _syntax_ --- how to _prove_ formulas using purely symbolic manipulation, without reference to truth values.
]

#definition[
  A _proof system_ consists of:
  - _Axioms_: formulas assumed to be true
  - _Inference rules_: patterns for deriving new formulas from existing ones

  A _proof_ of $phi$ is a sequence of formulas ending with $phi$, where each formula is either an axiom or follows from previous formulas by an inference rule.
]

#definition[Syntactic Derivability][
  We write $Gamma proves phi$ (read: "$Gamma$ proves $phi$") if there exists a proof of $phi$ using axioms and formulas from $Gamma$ as premises.
]

// TODO: The goal is to make syntactic derivability ($proves$) match semantic entailment ($models$).

== Natural Deduction

#definition[Natural Deduction][
  A proof system where formulas are derived using _introduction_ and _elimination_ rules for each logical connective.

  Proofs are typically presented in _Fitch notation_ --- a structured format showing the logical dependencies.
]

== Fitch Notation

#Block[
  Fitch notation uses vertical lines and indentation to show proof structure:
  - Vertical lines indicate scope of assumptions
  - Horizontal lines separate assumptions from conclusions
  - Each step is numbered and justified
]

// Visualization suggestion: Show a simple Fitch proof with boxes and lines
// Use actual Fitch diagram format with numbered steps, assumptions in boxes

#example[Fitch Proof Structure][
  ```
  1  | P → Q        Premise
  2  | P            Premise
     |____________
  3  | Q            Modus Ponens 1,2
  ```
]

== Inference Rules for Conjunction

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *Conjunction Introduction ($and$I):*
    #grid(
      columns: 1,
      inset: 5pt,
      $alpha$,
      $beta$,
      grid.hline(stroke: .8pt),
      $alpha and beta$,
    )

    If we have both $alpha$ and $beta$, we can conclude $alpha and beta$.
  ],
  [
    *Conjunction Elimination ($and$E):*
    #grid(
      columns: 2,
      column-gutter: 1em,
      inset: 5pt,
      grid(
        columns: 1,
        inset: 5pt,
        $alpha and beta$,
        grid.hline(stroke: .8pt),
        $alpha$,
      ),
      grid(
        columns: 1,
        inset: 5pt,
        $alpha and beta$,
        grid.hline(stroke: .8pt),
        $beta$,
      ),
    )

    From $alpha and beta$, we can conclude either $alpha$ or $beta$.
  ],
)

== Inference Rules for Disjunction

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *Disjunction Introduction ($or$I):*
    #grid(
      columns: 2,
      column-gutter: 1em,
      inset: 5pt,
      grid(
        columns: 1,
        inset: 5pt,
        $alpha$,
        grid.hline(stroke: .8pt),
        $alpha or beta$,
      ),
      grid(
        columns: 1,
        inset: 5pt,
        $beta$,
        grid.hline(stroke: .8pt),
        $alpha or beta$,
      ),
    )

    From either $alpha$ or $beta$, we can conclude $alpha or beta$.
  ],
  [
    *Disjunction Elimination ($or$E):*
    #Block(color: yellow.lighten(60%))[
      #grid(
        columns: 1,
        inset: 5pt,
        $alpha or beta$,
        $[alpha] dots gamma$,
        $[beta] dots gamma$,
        grid.hline(stroke: .8pt),
        $gamma$,
      )

      To use $alpha or beta$, assume each disjunct and show that both lead to the same conclusion $gamma$.
    ]
  ],
)

== Inference Rules for Implication

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *Implication Introduction ($imply$I):*
    #Block(color: yellow.lighten(60%))[
      #grid(
        columns: 1,
        inset: 5pt,
        $[alpha] dots beta$,
        grid.hline(stroke: .8pt),
        $alpha imply beta$,
      )

      To prove $alpha imply beta$, assume $alpha$ and derive $beta$.

      This _discharges_ the assumption $alpha$.
    ]
  ],
  [
    *Implication Elimination ($imply$E):*
    #grid(
      columns: 1,
      inset: 5pt,
      $alpha imply beta$,
      $alpha$,
      grid.hline(stroke: .8pt),
      $beta$,
    )

    This is _modus ponens_ --- the fundamental rule of reasoning.
  ],
)

== Inference Rules for Negation

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *Negation Introduction ($not$I):*
    #Block(color: yellow.lighten(60%))[
      #grid(
        columns: 1,
        inset: 5pt,
        $[phi] dots bot$,
        grid.hline(stroke: .8pt),
        $not phi$,
      )

      To prove $not phi$, assume $phi$ and derive a contradiction $bot$.
    ]
  ],
  [
    *Negation Elimination ($not$E):*
    #grid(
      columns: 1,
      inset: 5pt,
      $phi$,
      $not phi$,
      grid.hline(stroke: .8pt),
      $bot$,
    )

    From $phi$ and $not phi$, derive contradiction.
  ],
)

#definition[
  _Contradiction_ ($bot$) is special formula that represents logical inconsistency.

  From $bot$, anything can be derived (_ex falso quodlibet_).
]

// TODO: remove this section and fit all negation rules into one slide
== Additional Rules

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *Ex Falso Quodlibet ($bot$E):*
    #grid(
      columns: 1,
      inset: 5pt,
      $bot$,
      grid.hline(stroke: .8pt),
      $phi$,
    )

    From contradiction, anything follows.
  ],
  [
    *Double Negation Elimination:*
    #grid(
      columns: 1,
      inset: 5pt,
      $not not phi$,
      grid.hline(stroke: .8pt),
      $phi$,
    )

    (Classical logic only)
  ],
)

// TODO: Double negation elimination distinguishes classical from intuitionistic logic. In constructive mathematics, we can't always eliminate double negation.

== Example: Fitch Proof

#example[Proving Contrapositive][
  $(P imply Q) therefore ((not Q) imply (not P))$
  ```
  1  | P → Q                     Premise
     |________________________
  2  | | ¬Q                     Assumption
     | |______________________
  3  | | | P                   Assumption
  4  | | | Q                   →E 1,3
  5  | | | ⊥                   ¬E 2,4
     | | |____________________
  6  | | ¬P                    ¬I 3-5
     | |______________________
  7  | ¬Q → ¬P                 →I 2-6
     |________________________
  8  | (P → Q) → (¬Q → ¬P)      →I 1-7
  ```
]

== Derived Rules

#definition[
  _Derived rules_ are complex inference patterns that can be proven from basic rules, used as _shortcuts_ in proofs.
]

#example[Useful derived rules][
  #grid(
    columns: 3,
    column-gutter: 1em,
    [
      *Modus Tollens:*
      #grid(
        columns: 1,
        inset: 5pt,
        $alpha imply beta$,
        $not beta$,
        grid.hline(stroke: .8pt),
        $not alpha$,
      )
    ],
    [
      *Hypothetical Syllogism:*
      #grid(
        columns: 1,
        inset: 5pt,
        $alpha imply beta$,
        $beta imply gamma$,
        grid.hline(stroke: .8pt),
        $alpha imply gamma$,
      )
    ],
    [
      *Proof by Contradiction (Reductio ad Absurdum):*
      #Block(color: yellow.lighten(60%))[
        #grid(
          columns: 1,
          inset: 5pt,
          $[not phi] dots bot$,
          grid.hline(stroke: .8pt),
          $phi$,
        )
      ]
    ],
  )
]

= Soundness and Completeness
#focus-slide()

== Soundness of Natural Deduction

#definition[Soundness][
  A proof system is _sound_ if every syntactically derivable formula is semantically valid.
  $ "If" Gamma proves phi "then" Gamma models phi $
]

#theorem[
  Natural deduction for propositional logic is sound.
]

#proof[(sketch)][
  By induction on proof structure:

  *Base case:* Axioms and premises are semantically valid by assumption.

  *Inductive step:* Show each inference rule preserves semantic validity:
  - If premises are true under interpretation $nu$, then conclusion is also true under $nu$
  - For example, for $and$I: if $Eval(alpha) = True$ and $Eval(beta) = True$, then $Eval(alpha and beta) = True$

  The proof requires checking all inference rules systematically.
]

// TODO: Emphasize that soundness guarantees we never prove false statements

== Completeness Preview

#definition[Completeness][
  A proof system is _complete_ if every semantically valid formula is syntactically derivable.
  $ "If" Gamma models phi "then" Gamma proves phi $
]

#theorem[Gödel][
  Natural deduction for propositional logic is complete.
]

// TODO: Emphasize that this is one of the most important results in logic. It shows that syntactic proof captures exactly the semantically valid formulas.

#Block(color: green.lighten(60%))[
  *Soundness + Completeness* = syntactic derivability ($proves$) exactly matches semantic entailment ($models$).
  $
    Gamma proves phi
    quad "iff" quad
    Gamma models phi
  $
]

== Proof of Completeness

#proof[
  We prove the contrapositive: if $Gamma proves.not alpha$, then $Gamma models.not alpha$.

  The _strategy_ is to construct a model (interpretation) that satisfies all formulas in $Gamma$, but falsifies $alpha$.

  #enum(numbering: it => [*Step #it:*])[
    If $Gamma proves.not alpha$, then $Gamma union {not alpha}$ is consistent (cannot derive $bot$).
  ][
    Extend $Gamma union {not alpha}$ to a _maximal consistent set_ $Delta$:
    - $Delta$ is consistent (cannot derive $bot$)
    - For every formula $beta$, either $beta in Delta$ or $not beta in Delta$
  ][
    Define interpretation $nu$ for atomic propositions $P$ by:
    $ nu(P) = True iff P in Delta $
  ][
    Show by induction that for all formulas $beta$:
    $ Eval(beta) = True iff beta in Delta $
  ][
    Since $not alpha in Delta$, we have $Eval(alpha) = False$.
    Since $Gamma subset.eq Delta$, we have $Eval(gamma) = True$ for all $gamma in Gamma$.
  ]

  Therefore $Gamma models.not alpha$.
]

== The Completeness Result

#theorem[
  For any set of formulas $Gamma$ and formula $phi$:
  $
    Gamma models phi
    quad "iff" quad
    Gamma proves phi
  $

  // - Natural deduction is sound: $Gamma proves phi implies Gamma models phi$
  // - Natural deduction is complete: $Gamma models phi implies Gamma proves phi$
]

#Block(color: blue.lighten(60%))[
  This establishes the _harmony_ between semantics and syntax in propositional logic.

  *Practical implications:*
  - Automated theorem provers are theoretically sound.
  - Truth table methods and proof methods are equivalent.
  - Proof search is as hard as SAT.
]

// TODO: Emphasize that this is only valid in PL. FOL is complete but undecidable; HOL is incomplete.

= Predicate Logic
#focus-slide(
  epigraph: [All men are mortal. Socrates is a man. Therefore, Socrates is mortal.],
  epigraph-author: [Classical syllogism],
  scholars: (
    "Aristotle",
    "Socrates",
    "George Boole",
  ),
)

== From Propositional to Categorical

#Block[
  Classical propositional logic treats statements as atomic units.

  But human reasoning often involves _relationships between classes_ of objects:
  - "All birds can fly"
  - "Some mammals are aquatic"
  - "No reptiles are warm-blooded"

  _Traditional logic_ studies these patterns, providing a bridge to modern predicate logic.
]

== Categorical Propositions

#definition[
  A _categorical proposition_ is a statement that asserts or denies a relationship between two _categories_ (classes) of objects.

  Every categorical proposition has:
  - _Subject term_ (S): the category being described
  - _Predicate term_ (P): the category used in the description
  - _Quantifier_: indicates how much of the subject is included
  - _Quality_: affirmative or negative
]

#example[
  "All _politicians_ are _corrupt_."
  - Subject: politicians
  - Predicate: corrupt people
  - Quantifier: all (universal)
  - Quality: affirmative
]

== The Four Standard Forms

#definition[
  Traditional logic recognizes _four standard forms_ of categorical propositions:

  #table(
    columns: 5,
    align: (center, center, center, left, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([Form], [Quantifier], [Quality], [Structure], [Example]),
    [*A*], [Universal], [Affirmative], [All S are P], ["All cats are mammals"],
    [*E*], [Universal], [Negative], [No S are P], ["No fish are mammals"],
    [*I*], [Particular], [Affirmative], [Some S are P], ["Some birds are flightless"],
    [*O*], [Particular], [Negative], [Some S are not P], ["Some animals are not vertebrates"],
  )
]

// TODO: The letters A, E, I, O come from latin words "affirmo" and "nego".

== Examples of Categorical Propositions

#grid(
  columns: 2,
  column-gutter: 1em,
  [
    *A (Universal Affirmative):*
    - All students are hardworking
    - Every theorem has a proof
    - All prime numbers except 2 are odd

    *E (Universal Negative):*
    - No circles are squares
    - No valid argument has false premises and true conclusion
    - No even number greater than 2 is prime
  ],
  [
    *I (Particular Affirmative):*
    - Some politicians are honest
    - Some functions are continuous
    - Some equations have multiple solutions

    *O (Particular Negative):*
    - Some students are not prepared
    - Some triangles are not right triangles
    - Some numbers are not rational
  ],
)

== The Square of Opposition

#definition[
  A _square of opposition_ is a diagram showing the logical relationships between A, E, I, and O propositions with the same subject and predicate terms.
]

// #Block(color: yellow.lighten(60%))[
//   *Square Structure:*
//   ```
//         A ←—————— contraries —————→ E
//         ↑                           ↑
//         │                           │
//   subalternation              subalternation
//         │                           │
//         ↓                           ↓
//         I ←———— subcontraries ————→ O

//         Contradictories: A←→O, E←→I (diagonal lines)
//   ```
// ]

#align(center)[
  #cetz.canvas({
    import cetz: draw

    let s = 0.5
    let w = 4

    let draw-corner(
      pos,
      name,
      content,
    ) = {
      let (x, y) = pos
      draw.rect(
        (x - s, y + s),
        (x + s, y - s),
        name: name,
        stroke: 1pt + blue,
        radius: 5pt,
      )
      draw.content(name, text(1.5em)[#content])
    }

    draw-corner((0, 0), "A", [A])
    draw-corner((w, 0), "E", [E])
    draw-corner((0, -w), "I", [I])
    draw-corner((w, -w), "O", [O])

    draw.line("A", "E", name: "A-E", stroke: 2pt + blue)
    draw.line("I", "O", name: "I-O", stroke: 2pt + blue)
    draw.line(
      "A",
      "O",
      name: "A-O",
      stroke: (paint: blue, thickness: 2pt, dash: "dashed"),
    )
    draw.line(
      "I",
      "E",
      name: "I-E",
      stroke: (paint: blue, thickness: 2pt, dash: "dashed"),
    )
    draw.line(
      "A",
      "I",
      name: "A-I",
      stroke: (paint: blue, thickness: 2pt, dash: "solid"),
      mark: (end: "stealth", fill: blue),
    )
    draw.line(
      "E",
      "O",
      name: "E-O",
      stroke: (paint: blue, thickness: 2pt, dash: "solid"),
      mark: (end: "stealth", fill: blue),
    )

    draw.content(
      "A-E",
      [Contraries],
      anchor: "south",
      padding: 0.2,
    )
    draw.content(
      "I-O",
      [Subcontraries],
      anchor: "north",
      padding: 0.2,
    )
    draw.content(
      "A-I",
      [Subalternation],
      angle: "I",
      anchor: "north",
      padding: 0.2,
    )
    draw.content(
      "E-O",
      [Subalternation],
      angle: "O",
      anchor: "south",
      padding: 0.2,
    )
    draw.content(
      "I-E",
      box(fill: white, inset: 4pt)[Contradictories],
      angle: "E",
      anchor: "south",
      padding: 1pt,
    )
  })
]

== Logical Relationships in the Square

#definition[The Four Relationships][
  #grid(
    columns: 2,
    column-gutter: 1em,
    [
      *Contradictories* (A--O, E--I):
      - Cannot both be true
      - Cannot both be false
      - Exactly one must be true

      *Contraries* (A--E):
      - Cannot both be true
      - Can both be false
      - At most one is true
    ],
    [
      *Subcontraries* (I--O):
      - Cannot both be false
      - Can both be true
      - At least one is true

      *Subalternation* (A $imply$ I, E $imply$ O):
      - If universal is true, particular is true
      - If particular is false, universal is false
    ],
  )
]

#pagebreak(weak: true)

#example[
  Given: "All roses are flowers" (A-form, #true)

  By the square of opposition:
  - "No roses are flowers" (E-form) is #false (contraries)
  - "Some roses are flowers" (I-form) is #true (subalternation)
  - "Some roses are not flowers" (O-form) is #false (contradictories)
]

== Translation Between Traditional and Modern Logic

#definition[
  Categorical propositions can be translated into first-order logic:

  #table(
    columns: 3,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([Traditional], [Modern Logic], [Reading]),
    [All S are P], [$forall x (S(x) → P(x))$], ["For all x, if x is S then x is P"],
    [No S are P], [$forall x (S(x) → ¬P(x))$], ["For all x, if x is S then x is not P"],
    [Some S are P], [$exists x (S(x) ∧ P(x))$], ["There exists x such that x is S and x is P"],
    [Some S are not P], [$exists x (S(x) ∧ ¬P(x))$], ["There exists x such that x is S and x is not P"],
  )
]

#example[
  "All students are hardworking" becomes:
  $forall x (text("Student")(x) → text("Hardworking")(x))$

  "Some politicians are not honest" becomes:
  $exists x (text("Politician")(x) ∧ ¬text("Honest")(x))$
]

== The Existential Import Problem

#definition[
  A proposition "$S$ is $P$" has _existential import_ if it implies the existence of objects (at~least one) in its subject class $S$.
]

#Block(color: orange.lighten(50%))[
  *The Problem:*

  Traditional logic (Aristotle) assumes all categorical propositions have existential import.

  Modern logic questions this assumption.

  Consider: "All unicorns are magical"
  - Traditional: Implies unicorns exist (so the statement is false)
  - Modern: True vacuously (if there are no unicorns, the implication holds trivially)
]

#pagebreak(weak: true)

#example[Impact on the Square][
  In modern logic with empty domains:
  - A and E can both be true (if subject class is empty)
  - I and O can both be false (if subject class is empty)
  - Subalternation fails (A can be true while I is false)

  The traditional square of opposition only works when we assume non-empty subject classes.
]

== Syllogisms: Reasoning with Categories

#definition[
  _Categorical syllogism_ is a form of reasoning with three categorical propositions:
  - _Major premise_: contains the predicate of the conclusion
  - _Minor premise_: contains the subject of the conclusion
  - _Conclusion_: derived from the premises

  Uses exactly three terms: major, minor, and middle.
]

#example[Classic syllogism][
  #grid(
    columns: 2,
    column-gutter: 2em,
    grid(
      columns: 2,
      inset: 5pt,
      [All humans are mortal], [(Major premise)],
      [Socrates is human], [(Minor premise)],
      grid.hline(stroke: .8pt),
      [Therefore, Socrates is mortal], [(Conclusion)],
    ),
    [
      Terms:
      - Major term: mortal (P)
      - Minor term: Socrates (S)
      - Middle term: human (M)
    ],
  )
]

== Figures and Moods of Syllogisms

#definition[
  The _figure_ of a syllogism is determined by the position of the middle term:

  #align(center)[
    #table(
      columns: 4,
      align: center,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
      table.header([Figure 1], [Figure 2], [Figure 3], [Figure 4]),
      grid(
        columns: 1,
        inset: 5pt,
        [*M* — P],
        [S — *M*],
        grid.hline(stroke: .8pt),
        [S — P],
      ),
      grid(
        columns: 1,
        inset: 5pt,
        [P — *M*],
        [S — *M*],
        grid.hline(stroke: .8pt),
        [S — P],
      ),
      grid(
        columns: 1,
        inset: 5pt,
        [*M* — P],
        [*M* — S],
        grid.hline(stroke: .8pt),
        [S — P],
      ),
      grid(
        columns: 1,
        inset: 5pt,
        [P — *M*],
        [*M* — S],
        grid.hline(stroke: .8pt),
        [S — P],
      ),
    )
  ]
]

#definition[
  The _mood_ of a syllogism is the 3-letter sequence of categorical forms (A, E, I, O) of its three propositions, in order: major premise, minor premise, conclusion.
]

#example[Barbara (AAA-1)][
  #grid(
    columns: 1,
    inset: 5pt,
    [All M are P *(A)*],
    [All S are M *(A)*],
    grid.hline(stroke: .8pt),
    [All S are P *(A)*],
  )

  This arguments has mood AAA in figure 1, called "Barbara" — a valid syllogistic form.
]

== Valid Syllogistic Forms

#Block[
  Traditional logic identified 24 valid syllogistic forms across the four figures.

  Each valid form has a traditional Latin name that encodes its mood:
  - Vowels indicate the categorical forms (A, E, I, O)
  - Some consonants indicate required operations for reduction
]

// TODO: re-check
#example[Famous Valid Forms][
  #table(
    columns: 4,
    align: center,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([Figure 1], [Figure 2], [Figure 3], [Figure 4]),
    [Barbara (AAA)], [Cesare (EAE)], [Darapti (AAI)], [Bramantip (AAI)],
    [Celarent (EAE)], [Camestres (AEE)], [Disamis (IAI)], [Camenes (AEE)],
    [Darii (AII)], [Festino (EIO)], [Datisi (AII)], [Dimaris (IAI)],
    [Ferio (EIO)], [Baroco (AOO)], [Felapton (EAO)], [Fesapo (EAO)],
    [], [], [Bocardo (OAO)], [Fresison (EIO)],
    [], [], [Ferison (EIO)], [],
  )
]

== Syllogistic Fallacies

#Block(color: orange.lighten(50%))[
  *Common syllogistic fallacies:*
  #grid(
    columns: 2,
    column-gutter: 1em,
    [
      *Fallacy of Four Terms:* \
      Using more than three distinct terms

      #example[
        - All banks are financial institutions
        - The river bank is muddy
        - Therefore, some financial institutions are muddy

        (Equivocates on "bank")
      ]
    ],
    [
      *Undistributed Middle:* \
      Middle term not distributed in either premise

      #example[
        - All cats are mammals
        - All dogs are mammals
        - Therefore, all cats are dogs

        ("Mammals" not distributed)
      ]
    ],
  )
]

#definition[More Fallacies][
  #grid(
    columns: 2,
    column-gutter: 1em,
    [
      *Illicit Major:*
      Major term distributed in conclusion but not in major premise

      *Illicit Minor:*
      Minor term distributed in conclusion but not in minor premise
    ],
    [
      *Fallacy of Exclusive Premises:*
      Both premises negative

      *Existential Fallacy:*
      Particular conclusion from universal premises (when subject class may be empty)
    ],
  )
]

== Distribution of Terms

#definition[
  A term is _distributed_ in a proposition if the proposition says something about _all_ members of the class denoted by that term.

  - Only _universal_ propositions (A, E) distribute their _subject_ term.
  - Only _negative_ propositions (E, O) distribute their _predicate_ term.

  #table(
    columns: 3,
    align: (left, center, center),
    stroke: (x, y) => if (x == 0 and y == 0) or (x > 0 and y == 1) { (bottom: 0.8pt) } else if x > 0 and y == 0 {
      (bottom: 0.4pt)
    },
    table.header(
      table.cell(rowspan: 2, align: bottom)[Form],
      table.cell(colspan: 2, align: center)[Distribution],
      [Subject],
      [Predicate],
    ),
    [*A*: All S are P], [#YES], [#NO],
    [*E*: No S are P], [#YES], [#YES],
    [*I*: Some S are P], [#NO], [#NO],
    [*O*: Some S are not P], [#NO], [#YES],
  )
]

== Why Distribution Matters

// TODO: introduce Venn diagrams earlier
#example[
  Consider the terms in these propositions:

  #place(right)[
    #cetz.canvas({
      import cetz: draw
      import "@preview/cetz-venn:0.1.4"

      draw.scale(60%)

      cetz-venn.venn2(
        name: "venn",
        a-fill: red.lighten(80%),
        not-ab-stroke: none,
        padding: 0,
      )

      draw.content("venn.a", [S])
      draw.content("venn.b", [P])
    })
  ]

  - "All cats are mammals" (A-form)
    - Says something about ALL cats (subject distributed)
    - Says nothing about ALL mammals (predicate not distributed)

  #place(right)[
    #cetz.canvas({
      import cetz: draw
      import "@preview/cetz-venn:0.1.4"

      draw.scale(60%)

      cetz-venn.venn2(
        name: "venn",
        ab-fill: red.lighten(80%),
        not-ab-stroke: none,
        padding: 0,
      )

      draw.content("venn.a", [S])
      draw.content("venn.b", [P])
    })
  ]

  - "No reptiles are mammals" (E-form)
    - Says something about ALL reptiles (subject distributed)
    - Says something about ALL mammals (predicate distributed)

  #place(right)[
    #cetz.canvas({
      import cetz: draw
      import "@preview/cetz-venn:0.1.4"

      draw.scale(60%)

      cetz-venn.venn2(
        name: "venn",
        not-ab-stroke: none,
        padding: 0,
      )

      draw.content("venn.a", [S])
      draw.content("venn.b", [P])
      draw.content("venn.ab", text(fill: red.darken(20%))[#sym.crossmark])
    })
  ]

  - "Some birds are flightless" (I-form)
    - Says something about SOME birds (subject not distributed)
    - Says something about SOME flightless creatures (predicate not distributed)

  #place(right)[
    #cetz.canvas({
      import cetz: draw
      import "@preview/cetz-venn:0.1.4"

      draw.scale(60%)

      cetz-venn.venn2(
        name: "venn",
        not-ab-stroke: none,
        padding: 0,
      )

      draw.content("venn.a", text(fill: red.darken(20%))[#sym.crossmark])
      draw.content("venn.b", [P])
    })
  ]

  - "Some animals are not vertebrates" (O-form)
    - Says something about SOME animals (subject not distributed)
    - Says something about ALL vertebrates (predicate distributed)
]

== Rules for Valid Syllogisms

#definition[Validity Rules][
  A categorical syllogism is valid if and only if it satisfies all these rules:

  1. *Exactly three terms* (no equivocation)
  2. *Middle term distributed at least once*
  3. *No term distributed in conclusion unless distributed in premise*
  4. *No conclusion from two negative premises*
  5. *Negative conclusion if and only if exactly one negative premise*
  6. *No particular conclusion from two universal premises* (if existential import assumed)
]

== Venn Diagrams for Categorical Logic

#definition[Venn Diagram Method][
  Categorical propositions can be represented using Venn diagrams with two or three circles.

  - Shaded regions represent empty classes
  - X marks represent existing individuals
  - Overlap patterns show relationships between categories
]

// TODO: Show Venn diagrams for each categorical form.

#example[Venn Diagram for Syllogism][
  Testing Barbara (AAA-1):
  - All M are P: Shade M outside P
  - All S are M: Shade S outside M
  - Conclusion: All S are P

  The diagrams show that S must be entirely within P, validating the syllogism.
]

== Modern Developments

#Block[
  Traditional categorical logic has evolved in several directions:

  - *Set theory*: Categories become sets, relations become set operations
  - *Formal semantics*: Precise treatment of quantification and scope
  - *Knowledge representation*: Description logics in AI and semantic web
  - *Natural language processing*: Computational linguistics and parsing
  - *Database theory*: Query languages and constraint systems
]

// TODO: Traditional logic isn't obsolete - it's foundational

== Limitations of Traditional Logic

#Block(color: yellow.lighten(40%))[
  Traditional categorical logic has important _limitations_:
  + Only handles simple quantification (all, some, no)
  + Cannot express complex relationships (between more than two categories)
  + Limited to categorical structure (subject--predicate form)
  + Struggles with relational statements ("John is taller than Mary")
  + No systematic treatment of compound statements
  + Existential import controversies
]

#example[What traditional logic cannot express][
  - "Every student likes some professor" (multiple quantifiers)
  - "If John is happy, then Mary is happy" (conditional with individuals)
  - "All numbers between 5 and 10 are prime" (complex domain restrictions)
  - "Most birds can fly" (non-standard quantifiers)
  - "Students who study hard usually succeed" (statistical generalizations)
]

== The Legacy of Traditional Logic

#Block(color: blue.lighten(60%))[
  *Enduring Contributions:*
  =
  - Systematic study of quantification and categorical reasoning
  - Recognition of logical form vs. content
  - Analysis of validity in natural language arguments
  - Foundation for formal semantics and knowledge representation
  - Critical thinking tools for evaluating everyday reasoning

  *Modern Relevance:*
  Traditional logic remains important for understanding human reasoning patterns, developing AI systems that interact naturally with humans, and teaching critical thinking skills.
]

= First-Order Logic
#focus-slide()

== Transition to First-Order Logic

#Block[
  Propositional logic can only reason about _whole statements_.

  To reason about _objects_ and their _properties_, we need _first-order logic_ (FOL).
]

#example[Limitations of Propositional Logic][
  Cannot express:
  - "All humans are mortal"
  - "Socrates is human"
  - "Therefore, Socrates is mortal"

  In propositional logic, these would be unrelated atomic propositions $P$, $Q$, $R$, without any structure connecting them.
]

#definition[
  First-order logic extends propositional logic with:
  - _Variables_: $x, y, z, dots$
  - _Predicates_: $P(x), R(x,y), dots$
  - _Quantifiers_: $forall x$ (for all), $exists x$ (there exists)
  - _Functions_: $f(x), g(x,y), dots$
  - _Constants_: $a, b, c, dots$
]

== First-Order Syntax

#definition[Terms][
  _Terms_ are expressions denoting objects:
  - Variables: $x, y, z$
  - Constants: $a, b, c$
  - Function applications: $f(t_1, dots, t_n)$ where $t_i$ are terms
]

#definition[Atomic Formulas][
  _Atomic formulas_ are basic statements:
  - Predicate applications: $P(t_1, dots, t_n)$ where $t_i$ are terms
  - Equality: $t_1 = t_2$ where $t_1, t_2$ are terms
]

#definition[First-Order Formulas][
  Built recursively from atomic formulas using:
  - Propositional connectives: $not, and, or, imply, iff$
  - Quantifiers: $forall x. phi$, $exists x. phi$
]

#pagebreak(weak: true)

#examples[
  - $forall x. thin (P(x) imply Q(x))$ — "For all $x$, if $P(x)$ then $Q(x)$"
  - $exists x. thin (P(x) and not Q(x))$ — "There exists an $x$ such that $P(x)$ and not $Q(x)$"
  - $forall x. exists y. thin R(x,y)$ — "For every $x$, there exists a $y$ such that $R(x,y)$"
]

== First-Order Semantics

#definition[
  A _structure_ $cal(M) = pair(D, cal(I))$ consists of:
  - _Domain_ $D$: non-empty set of objects
  - _Interpretation function_ $cal(I)$:
    - Maps constants to elements of $D$
    - Maps $n$-ary predicates to $n$-ary relations on $D$
    - Maps $n$-ary functions to $n$-ary functions on $D$
]

#definition[
  A _variable assignment_ $sigma : V to D$ maps variables to domain elements.
]

#definition[Truth in a Structure][
  For structure $cal(M)$ and assignment $sigma$:
  - $cal(M), sigma models P(t_1, dots, t_n)$ iff $angle.l cal(I)(t_1)^sigma, dots, cal(I)(t_n)^sigma angle.r in cal(I)(P)$
  - $cal(M), sigma models forall x. thin phi$ iff $cal(M), sigma' models phi$ for all $sigma'$ that differ from $sigma$ at most on $x$
  - $cal(M), sigma models exists x. thin phi$ iff $cal(M), sigma' models phi$ for some $sigma'$ that differs from $sigma$ at most on $x$
]

== Theories and Models

#definition[
  A _theory_ $T$ is a set of first-order formulas (axioms).
]

#definition[
  A structure $cal(M)$ is a _model_ of theory $T$ if $cal(M) models phi$ for every formula $phi in T$.
]

#example[Group Theory][
  The theory of groups has axioms:
  - (Associativity) $forall x, y, z. thin (x dot (y dot z)) = ((x dot y) dot z)$
  - (Identity) $exists e. forall x. thin (x dot e = x) and (e dot x = x)$
  - (Inverses) $forall x. exists y. thin (x dot y = e) and (y dot x = e)$

  Models include $angle.l ZZ, + angle.r$, $angle.l RR setminus {0}, dot angle.r$, etc.
]

== First-Order Natural Deduction

#definition[
  Additional rules for quantifiers:
  #grid(
    columns: 2,
    column-gutter: 2em,
    [
      *Universal Introduction ($forall$I):*
      #Block(color: yellow.lighten(60%))[
        #grid(
          columns: 1,
          inset: 5pt,
          $phi(a)$,
          grid.hline(stroke: .8pt),
          $forall x. thin phi(x)$,
        )

        Where $a$ is arbitrary (fresh).
      ]

      *Universal Elimination ($forall$E):*
      #grid(
        columns: 1,
        inset: 5pt,
        $forall x. thin phi(x)$,
        grid.hline(stroke: .8pt),
        $phi(t)$,
      )
    ],
    [
      *Existential Introduction ($exists$I):*
      #grid(
        columns: 1,
        inset: 5pt,
        $phi(t)$,
        grid.hline(stroke: .8pt),
        $exists x. thin phi(x)$,
      )

      *Existential Elimination ($exists$E):*
      #Block(color: yellow.lighten(60%))[
        #grid(
          columns: 1,
          inset: 5pt,
          $exists x. thin phi(x)$,
          $[phi(a)] dots psi$,
          grid.hline(stroke: .8pt),
          $psi$,
        )

        Where $a$ is fresh and doesn't occur in $psi$.
      ]
    ],
  )
]

== Interactive Theorem Provers

#Block[
  Modern mathematics increasingly uses _interactive theorem provers_ — computer systems that assist in constructing and verifying formal proofs.
]

#examples[Major Systems][
  #grid(
    columns: 3,
    column-gutter: 1em,
    [
      *Lean 4:*
      - Functional programming
      - Dependent types
      - Growing math library
    ],
    [
      *Coq:*
      - Constructive logic
      - Curry-Howard correspondence
      - Machine-checked proofs
    ],
    [
      *Isabelle/HOL:*
      - Higher-order logic
      - Automated tactics
      - Large formalizations
    ],
  )
]

#example[
  Major theorems _proven_ in interactive systems:
  - Four Color Theorem (Coq)
  - Odd Order Theorem (Coq)
  - Kepler Conjecture (Isabelle/HOL)
  - Liquid Tensor Experiment (Lean)
]

== Completeness and Decidability

#theorem[Gödel][
  First-order logic is complete: every semantically valid formula is provable.
]

#theorem[Church][
  First-order logic is undecidable: there is no algorithm that determines whether an arbitrary first-order formula is valid.
]

// TODO: incompleteness theorem for arithmetic

#Block(color: orange.lighten(50%))[
  *The trade-off:*
  - Propositional logic: decidable (SAT-solvable) but has _limited expressiveness_
  - First-order logic: highly expressive but _undecidable_
  - Higher-order logic: even more expressive but _incomplete_
]

// TODO: Emphasize that this illustrates fundamental limitations in automated reasoning: we gain expressiveness at the cost of decidability.

== Applications and Connections

#example[Logic in Computer Science][
  #grid(
    columns: 2,
    column-gutter: 1em,
    [
      *Verification:*
      - Program correctness
      - Hardware verification
      - Protocol analysis
      - Security properties

      *Databases:*
      - Query languages (SQL)
      - Integrity constraints
      - Deductive databases
    ],
    [
      *AI and Knowledge Representation:*
      - Expert systems
      - Automated planning
      - Semantic web (RDF, OWL)
      - Natural language processing

      *Programming Languages:*
      - Type systems
      - Specification languages
      - Logic programming (Prolog)
    ],
  )
]

== Summary: The Logical Landscape

#table(
  columns: 4,
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header([Logic], [Expressiveness], [Decidability], [Completeness]),
  [Propositional], [Basic], [#YES], [#YES],
  [First-Order], [High], [#NO], [#YES],
  [Second-Order], [Very High], [#NO], [#NO],
  [Higher-Order], [Maximum], [#NO], [#NO],
)

#Block(color: blue.lighten(60%))[
  *Key insights:*
  - Syntax and semantics can be perfectly aligned (completeness)
  - Expressiveness comes at the cost of decidability
  - Formal logic provides foundations for mathematical reasoning and computation
  - Interactive theorem provers make formal logic practically useful
]

== Looking Forward

*Next topics in advanced logic:*
- Modal logic (necessity, possibility, knowledge, belief)
- Temporal logic (time, concurrency, reactive systems)
- Intuitionistic logic (constructive mathematics)
- Linear logic (resource-aware reasoning)
- Description logics (knowledge representation, semantic web)

*Connections to other areas:*
- Computability theory and complexity
- Category theory and type theory
- Model theory and set theory
- Philosophical logic and foundations of mathematics

== TODO

- ...

// == Bibliography
// #bibliography("refs.yml")

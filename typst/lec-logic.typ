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
  A formula $phi$ is _satisfiable_ if there exists an interpretation $nu$ such that $Eval(phi) = True$.

  A formula is _unsatisfiable_ if no such interpretation exists.
]

#definition[
  A formula $phi$ is a _tautology_ (or _valid_) if $Eval(phi) = True$ for every interpretation $nu$.

  Notation: $models phi$ (read: "$phi$ is valid").
]

#definition[
  A formula $phi$ is a _contradiction_ if $Eval(phi) = False$ for every interpretation $nu$.
]

#example[
  - $P or not P$ is a tautology (Law of Excluded Middle)
  - $P and not P$ is a contradiction
  - $P or Q$ is satisfiable but not a tautology
]

== Logical Equivalence

#definition[
  Two formulas $phi$ and $psi$ are _logically equivalent_, written $phi equiv psi$, if they have the same truth value under every interpretation:
  $
    phi equiv psi
    quad "iff" quad
    forall nu. thin EvalWith(phi, nu) = EvalWith(psi, nu)
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
  A set of formulas $Gamma$ _semantically entails_ a formula $phi$, written $Gamma models phi$, if every interpretation that makes all formulas in $Gamma$ true also makes $phi$ true:
  $
    Gamma models phi
    quad "iff" quad
    forall nu. thin (forall psi in Gamma. thin EvalWith(psi, nu) = True) imply EvalWith(phi, nu) = True
  $
]

#example[
  ${P imply Q, P} models Q$ (this captures modus ponens semantically)
]

#theorem[Semantic Deduction Theorem][
  For any formulas $phi$ and $psi$:
  $
    {phi} models psi
    quad "iff" quad
    models phi imply psi
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

#definition[Proof System][
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
      $phi$,
      $psi$,
      grid.hline(stroke: .8pt),
      $phi and psi$,
    )

    If we have both $phi$ and $psi$, we can conclude $phi and psi$.
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
        $phi and psi$,
        grid.hline(stroke: .8pt),
        $phi$,
      ),
      grid(
        columns: 1,
        inset: 5pt,
        $phi and psi$,
        grid.hline(stroke: .8pt),
        $psi$,
      ),
    )

    From $phi and psi$, we can conclude either $phi$ or $psi$.
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
        $phi$,
        grid.hline(stroke: .8pt),
        $phi or psi$,
      ),
      grid(
        columns: 1,
        inset: 5pt,
        $psi$,
        grid.hline(stroke: .8pt),
        $phi or psi$,
      ),
    )

    From either $phi$ or $psi$, we can conclude $phi or psi$.
  ],
  [
    *Disjunction Elimination ($or$E):*
    #Block(color: yellow.lighten(60%))[
      #grid(
        columns: 1,
        inset: 5pt,
        $phi or psi$,
        $[phi] dots chi$,
        $[psi] dots chi$,
        grid.hline(stroke: .8pt),
        $chi$,
      )

      To use $phi or psi$, assume each disjunct and show that both lead to the same conclusion $chi$.
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
        $[phi] dots psi$,
        grid.hline(stroke: .8pt),
        $phi imply psi$,
      )

      To prove $phi imply psi$, assume $phi$ and derive $psi$.

      This _discharges_ the assumption $phi$.
    ]
  ],
  [
    *Implication Elimination ($imply$E):*
    #grid(
      columns: 1,
      inset: 5pt,
      $phi imply psi$,
      $phi$,
      grid.hline(stroke: .8pt),
      $psi$,
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

#definition[Contradiction ($bot$)][
  A special formula that represents logical inconsistency. From $bot$, anything can be derived (_ex falso quodlibet_).
]

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

#example[Proving $(P imply Q) imply ((not Q) imply (not P))$ (Contrapositive)][
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

#definition[Derived Rules][
  Complex inference patterns that can be proven from basic rules, used as shortcuts in proofs.
]

#example[
  Useful _derived_ rules:
  #grid(
    columns: 3,
    column-gutter: 1em,
    [
      *Modus Tollens:*
      #grid(
        columns: 1,
        inset: 5pt,
        $phi imply psi$,
        $not psi$,
        grid.hline(stroke: .8pt),
        $not phi$,
      )
    ],
    [
      *Hypothetical Syllogism:*
      #grid(
        columns: 1,
        inset: 5pt,
        $phi imply psi$,
        $psi imply chi$,
        grid.hline(stroke: .8pt),
        $phi imply chi$,
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
  - For example, for $and$I: if $EvalWith(phi, nu) = True$ and $EvalWith(psi, nu) = True$, then $EvalWith(phi and psi, nu) = True$

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
  We prove the contrapositive: if $Gamma proves.not phi$, then $Gamma models.not phi$.

  The _strategy_ is to construct a model (interpretation) that satisfies all formulas in $Gamma$, but falsifies $phi$.

  #enum(numbering: it => [*Step #it:*])[
    If $Gamma proves.not phi$, then $Gamma union {not phi}$ is consistent (cannot derive $bot$).
  ][
    Extend $Gamma union {not phi}$ to a _maximal consistent set_ $Delta$:
    - $Delta$ is consistent (cannot derive $bot$)
    - For every formula $psi$, either $psi in Delta$ or $not psi in Delta$
  ][
    Define interpretation $nu$ for atomic propositions $P$ by:
    $
      nu(P) = True iff P in Delta
    $][
    Show by induction that for all formulas $psi$:
    $
      EvalWith(psi, nu) = True iff psi in Delta
    $
  ][
    Since $not phi in Delta$, we have $EvalWith(phi, nu) = False$.
    Since $Gamma subset.eq Delta$, we have $EvalWith(gamma, nu) = True$ for all $gamma in Gamma$.
  ]

  Therefore $Gamma models.not phi$.
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
  - $cal(M), sigma models forall x. phi$ iff $cal(M), sigma' models phi$ for all $sigma'$ that differ from $sigma$ at most on $x$
  - $cal(M), sigma models exists x. phi$ iff $cal(M), sigma' models phi$ for some $sigma'$ that differs from $sigma$ at most on $x$
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
          $forall x. phi(x)$,
        )

        Where $a$ is arbitrary (fresh).
      ]

      *Universal Elimination ($forall$E):*
      #grid(
        columns: 1,
        inset: 5pt,
        $forall x. phi(x)$,
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
        $exists x. phi(x)$,
      )

      *Existential Elimination ($exists$E):*
      #Block(color: yellow.lighten(60%))[
        #grid(
          columns: 1,
          inset: 5pt,
          $exists x. phi(x)$,
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

#Block(color: orange.lighten(60%))[
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

// TODO: add #Yes and #No commands for icons
#table(
  columns: 4,
  align: center,
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header([Logic], [Expressiveness], [Decidability], [Completeness]),
  [Propositional], [Basic], [YES], [YES],
  [First-Order], [High], [NO], [YES],
  [Second-Order], [Very High], [NO], [NO],
  [Higher-Order], [Maximum], [NO], [NO],
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

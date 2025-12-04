#import "theme.typ": *
#show: slides.with(
  title: [Formal Logic],
  subtitle: "Discrete Math",
  date: "Fall 2025",
  authors: "Konstantin Chukharev",
  // dark: true,
)

#show heading.where(level: 1): none

#import "common-lec.typ": *

#let rel(x) = math.class("relation", x)
#let nrel(x) = rel(math.cancel(x))
#let proves = entails

#let EvalWith(phi, inter) = $bracket.stroked.l phi bracket.stroked.r_(inter)$
#let Eval(phi) = EvalWith(phi, $nu$)


#CourseOverviewPage()


= Formal Logic
#focus-slide(
  epigraph: [Logic is the anatomy of thought.],
  epigraph-author: [John Locke],
  scholars: (
    (
      name: "Gottfried Wilhelm Leibniz",
      image: image("assets/Gottfried_Wilhelm_Leibniz.jpg"),
    ),
    (
      name: "Gottlob Frege",
      image: image("assets/Gottlob_Frege.jpg"),
    ),
    (
      name: "Kurt Gödel",
      image: image("assets/Kurt_Godel.jpg"),
    ),
    (
      name: "Alfred Tarski",
      image: image("assets/Alfred_Tarski.jpg"),
    ),
    (
      name: "Gerhard Gentzen",
      image: image("assets/Gerhard_Gentzen.jpg"),
    ),
    (
      name: "Jacques Herbrand",
      image: image("assets/Jacques_Herbrand.jpg"),
    ),
    (
      name: "Per Martin-Löf",
      image: image("assets/Per_Martin-Lof.jpg"),
    ),
  ),
)

== Why Formal Logic?

#Block(color: teal)[
  *From Boolean Algebra to Formal Reasoning*

  In Boolean Algebra, we studied _truth values_ and _operations_ on them.
  Now we ask: _how do we reason correctly about truth?_

  - Boolean algebra: "What is the value of $(P and Q) or not P$?"
  - Formal logic: "If $P imply Q$ and $P$ are true, _must_ $Q$ be true?"
]

#Block(color: yellow)[
  *Logic answers fundamental questions:*
  - What does it mean for an argument to be _valid_?
  - Can we _mechanically verify_ that a proof is correct?
  - What can (and cannot) be proven?
]

== Applications of Formal Logic

#grid(
  columns: 2,
  column-gutter: 1em,
  Block[
    *Computer Science:*
    - Program verification ("this code never crashes")
    - Type systems (Curry--Howard correspondence)
    - Database queries (SQL WHERE clauses)
    - Hardware design (circuit correctness)
    - AI reasoning (knowledge bases, planners)
  ],
  Block[
    *Mathematics:*
    - Foundations of mathematics
    - Automated theorem proving
    - Proof assistants (Lean, Coq, Isabelle)
    - Decidability questions
    - Model theory
  ],
)

#example[
  _Modus ponens_ --- the fundamental inference rule:

  #align(center)[
    #grid(
      columns: 1,
      align: left,
      inset: 5pt,
      $P$,
      $P imply Q$,
      grid.hline(stroke: .8pt),
      $therefore Q$,
    )
  ]

  If "it rains" ($P$) and "if it rains, the ground is wet" ($P imply Q$), then ($therefore$) "the ground is wet" ($Q$).
]

== What is Propositional Logic?

#definition[
  _Logic_ is the study of valid reasoning --- distinguishing correct arguments from fallacies.
]

#definition[
  _Formal logic_ studies reasoning using precise symbolic notation, enabling mechanical verification of arguments.
]

#definition[
  _Propositional logic_ is the simplest formal logic, dealing with whole statements (_propositions_) that are either #True or #False.

  Also known as _sentential logic_, _statement logic_, or _zeroth-order logic_.
]

#Block(color: purple)[
  Propositional logic is the _foundation_ for more expressive logics (first-order, modal, temporal) that we'll explore later.
]

== Syntax: The Language of Logic

#Block[
  *Syntax* concerns the formal _structure_ of logical expressions --- how symbols are arranged according to grammatical rules, _independent of meaning_.
]

#definition[
  A _propositional language_ $cal(L)$ consists of:
  - _Propositional variables_ (atoms): $P, Q, R, dots$ or $p_1, p_2, p_3, dots$
  - _Logical connectives_: $not$ (negation), $and$ (conjunction), $or$ (disjunction), $imply$ (implication), $iff$ (biconditional)
  - _Punctuation_: parentheses $($ and $)$ for grouping
  - _Constants_ (optional): $top$ (true), $bot$ (false)
]

#definition[
  A _well-formed formula_ (WFF) is defined inductively:
  + Every propositional variable $P, Q, R, dots$ is a WFF.
  + The constants $top$ and $bot$ are WFFs.
  + If $phi$ is a WFF, then $(not phi)$ is a WFF.
  + If $phi$ and $psi$ are WFFs, then $(phi and psi)$, $(phi or psi)$, $(phi imply psi)$, $(phi iff psi)$ are WFFs.
  + Nothing else is a WFF.
]

#note[
  Outer parentheses can be omitted for readability, e.g., $P and Q$ instead of $(P and Q)$.
]

#example[
  - $P$, $Q$, $(P and Q)$, $((P and Q) imply R)$ are WFFs.

  - $P and$, $imply Q R$, $P Q and$ are _not_ WFFs (malformed).
]

== Operator Precedence

#Block(color: yellow)[
  To reduce parentheses, we adopt _precedence conventions_ (highest to lowest):

  #align(center)[
    #table(
      columns: 5,
      align: (center, center, left, center, left),
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
      table.header([*Priority*], [*Connective*], [*Name*], [*Associativity*], [*Example*]),
      [1 (highest)], [$not$], [Negation], [Right], [$not not P and Q equiv (not (not P)) and Q$],
      [2], [$and$], [Conjunction], [Left], [$P and Q and R equiv (P and Q) and R$],
      [3], [$or$], [Disjunction], [Left], [$P or Q or R equiv (P or Q) or R$],
      [4], [$imply$], [Implication], [Right], [$P imply Q imply R equiv P imply (Q imply R)$],
      [5 (lowest)], [$iff$], [Biconditional], [Left], [$P iff Q iff R equiv (P iff Q) iff R$],
    )
  ]
]

#example[
  Using precedence rules:
  - $not P and Q$ means $(not P) and Q$
  - $P or Q and R$ means $P or (Q and R)$
  - $P imply Q or R$ means $P imply (Q or R)$
  - $P iff Q imply R or S$ means $P iff (Q imply (R or S))$
    $quad$
    (*Note:* not in all real systems! See NuSMV)
]

== The Logical Connectives

#grid(
  columns: 2,
  column-gutter: 1.5em,
  row-gutter: 1em,
  [
    *Negation* ($not$): "not"
    - $not P$ is true iff $P$ is false
    - Flips the truth value
  ],
  [
    *Conjunction* ($and$): "and"
    - $P and Q$ is true iff _both_ are true
    - Like multiplication: $1 dot 1 = 1$, else $0$
  ],

  [
    *Disjunction* ($or$): "or" (inclusive)
    - $P or Q$ is true iff _at least one_ is true
    - Like bounded addition: $max(P, Q)$
  ],
  [
    *Biconditional* ($iff$): "if and only if"
    - $P iff Q$ is true iff $P$ and $Q$ have _same_ value
    - Equivalence test: $(P imply Q) and (Q imply P)$
  ],
)

#pagebreak(weak: true)

== Understanding Implication

#Block(color: orange)[
  *The implication* $P imply Q$ ("if $P$ then $Q$") is the _most confusing_ connective!

  $P imply Q$ is false _only_ when $P$ is true and $Q$ is false.
]

#definition[
  _Material implication_ is defined as: $P imply Q equiv not P or Q$

  Read: "either $P$ is false, or $Q$ is true (or both)."
]

#example[Why is "false implies anything" true?][
  Consider: "If pigs fly, then I'm the Queen of England."

  - Pigs don't fly ($P$ is false)
  - The statement is _vacuously true_ --- it makes no false claims!
  - There's no counterexample: we never have $P$ true and $Q$ false.
]

== Vacuous Truth

#Block[
  When $P$ is false, $P imply Q$ is true _regardless_ of $Q$.

  Think of implication as a _promise_: "If $P$, then $Q$."
  - $P$ true, $Q$ true: promise kept
  - $P$ true, $Q$ false: promise broken
  - $P$ false: promise untested --- not broken!
]

#example[
  - "All unicorns are purple" --- #True (no unicorns)
  - "Every element of $emptyset$ is a dragon" --- #True
  - "If $2 + 2 = 5$, then I can fly" --- #True
]

#Block(color: orange)[
  *Warning:* "All bugs in this code are fixed" is true if the code has no bugs!
]

== Semantics: The Meaning of Logic

#Block[
  *Semantics* concerns the _meaning_ (or _interpretation_) of logical expressions --- how they relate to _truth_ values.

  While syntax asks "Is this formula well-formed?", semantics asks "Is this formula _true_?"
]

#definition[
  An _interpretation_ (also called _truth assignment_ or _valuation_) is a function
  $ nu : V to BB $
  that assigns a truth value to each propositional variable, where $V$ is the set of variables and $BB = {0, 1} = {False, True}$.
]

#example[
  For variables $V = {P, Q, R}$, one interpretation is:
  $ nu(P) = True, quad nu(Q) = False, quad nu(R) = True $
]

#definition[
  The _evaluation_ (or _truth value_) of a formula $phi$ under interpretation $nu$, written $Eval(phi)$, is~defined recursively:

  $
                   Eval(P) & = nu(P) && "for propositional variable" P \
                 Eval(top) & = True \
                 Eval(bot) & = False \
           Eval(not alpha) & = True  && iff Eval(alpha) = False \
      Eval(alpha and beta) & = True  && iff Eval(alpha) = True "and" Eval(beta) = True \
       Eval(alpha or beta) & = True  && iff Eval(alpha) = True "or" Eval(beta) = True \
    Eval(alpha imply beta) & = False && iff Eval(alpha) = True "and" Eval(beta) = False \
      Eval(alpha iff beta) & = True  && iff Eval(alpha) = Eval(beta)
  $
]

#note[
  The evaluation function extends the interpretation from atoms to all formulas, using the _compositional_ (truth-functional) nature of propositional logic.
]

== Truth Tables

#definition[
  A _truth table_ systematically lists all possible interpretations (truth value assignments) and shows the resulting truth values of formulas.
]

#Block(color: blue)[
  *Constructing a Truth Table:*
  + List all propositional variables: $P_1, P_2, dots, P_n$
  + Create $2^n$ rows for all possible combinations of truth values
  + For each subformula, compute its value column-by-column
  + The final column gives the formula's truth value for each interpretation
]

== Truth Tables for Basic Connectives

#grid(
  columns: 3,
  column-gutter: 2em,

  // Negation
  table(
    columns: 2,
    align: center,
    stroke: none,
    table.header([*$P$*], [*$not P$*]),
    table.hline(),
    [#True], [#False],
    [#False], [#True],
  ),

  // Conjunction and Disjunction
  table(
    columns: 4,
    align: center,
    stroke: none,
    table.header([*$P$*], [*$Q$*], [*$P and Q$*], [*$P or Q$*]),
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
    table.header([*$P$*], [*$Q$*], [*$P imply Q$*], [*$P iff Q$*]),
    table.hline(),
    [#True], [#True], [#True], [#True],
    [#True], [#False], [#False], [#False],
    [#False], [#True], [#True], [#False],
    [#False], [#False], [#True], [#True],
  ),
)

#note[
  Truth tables connect directly to Boolean algebra: $and$ is multiplication, $or$ is (bounded) addition, $not$~is~complement.
  See the Boolean Algebra lecture for optimization techniques like Karnaugh maps.
]

== Semantic Classification of Formulas

#definition[
  Formulas are classified by their truth behavior across _all_ interpretations:

  - *Tautology* (valid): True under _every_ interpretation. Notation: $models phi$
  - *Contradiction*: False under _every_ interpretation.
  - *Contingent*: True under _some_ interpretations, false under others.
  - *Satisfiable*: True under _at least one_ interpretation (includes tautologies and contingent formulas).
]

#align(center)[
  #cetz.canvas({
    import cetz: draw

    // All formulas
    draw.rect(
      (0, 0),
      (9, 4),
      stroke: 1pt + blue,
      fill: blue.lighten(85%),
      radius: 3pt,
      name: "all",
    )
    draw.content(
      "all.north",
      [*All formulas*],
      anchor: "north",
      padding: 0.2,
    )

    // Satisfiable region
    draw.rect(
      (0.2, 0.2),
      (6, 3.2),
      stroke: 1pt + green,
      fill: green.lighten(85%),
      radius: 5pt,
      name: "sat",
    )
    draw.content(
      "sat.north",
      [*Satisfiable*],
      anchor: "north",
      padding: 0.2,
    )

    // Tautologies
    draw.circle(
      (1.6, 1.4),
      radius: (1.2, 0.8),
      stroke: 1pt + purple,
      fill: purple.lighten(85%),
      name: "tautologies",
    )
    draw.content("tautologies", [Tautologies])

    // Contingent
    draw.rect(
      (3, 0.4),
      (5.8, 2.4),
      stroke: 1pt + orange,
      fill: orange.lighten(85%),
      radius: 3pt,
      name: "contingent",
    )
    draw.content("contingent", [Contingent])

    // Contradictions
    draw.circle(
      (7.5, 1.4),
      radius: (1.2, 0.8),
      stroke: 1pt + red,
      fill: red.lighten(85%),
      name: "contradictions",
    )
    draw.content("contradictions", [Contra-\ dictions])
  })
]

== Examples of Classifications

#table(
  columns: 3,
  align: left,
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header([*Formula*], [*Classification*], [*Reason*]),
  [$P or not P$], [Tautology], [Law of Excluded Middle],
  [$P and not P$], [Contradiction], [Law of Non-Contradiction],
  [$P imply P$], [Tautology], [Reflexivity of implication],
  [$P or Q$], [Contingent], [Depends on values of $P$ and $Q$],
  [$P and Q imply P$], [Tautology], [Simplification],
  [$(P imply Q) and (Q imply P)$], [Contingent], [Same as $P iff Q$],
)

== Logical Equivalence

#definition[
  Two formulas $phi$ and $psi$ are _logically equivalent_, written $phi equiv psi$, if they have the same truth value under _every_ interpretation:
  $
    phi equiv psi
    quad "iff" quad
    forall nu. thin Eval(phi) = Eval(psi)
    quad "iff" quad
    models phi iff psi
  $
]

#theorem[
  $phi equiv psi$ if and only if $phi iff psi$ is a tautology.
]

#proof[
  By definition, $phi equiv psi$ means $Eval(phi) = Eval(psi)$ for all interpretations $nu$.

  The biconditional $phi iff psi$ is true exactly when $Eval(phi) = Eval(psi)$.

  Therefore, $phi iff psi$ is true under all interpretations (a tautology) if and only if $phi equiv psi$.
]

== Fundamental Equivalence Laws

#Block(color: green)[
  These laws form the _algebra of propositions_ (compare with Boolean algebra!)
]

#grid(
  columns: 3,
  column-gutter: 2em,
  row-gutter: 1em,
  [
    *Identity:*
    - $P and top equiv P$
    - $P or bot equiv P$

    *Complement:*
    - $P and not P equiv bot$
    - $P or not P equiv top$

    *Double Negation:*
    - $not not P equiv P$

    *De Morgan's Laws:*
    - $not (P and Q) equiv not P or not Q$
    - $not (P or Q) equiv not P and not Q$
  ],
  [
    *Domination:*
    - $P or top equiv top$
    - $P and bot equiv bot$

    *Idempotence:*
    - $P and P equiv P$
    - $P or P equiv P$

    *Absorption:*
    - $P and (P or Q) equiv P$
    - $P or (P and Q) equiv P$
  ],
  [
    *Commutativity:*
    - $P and Q equiv Q and P$
    - $P or Q equiv Q or P$

    *Associativity:*
    - $(P and Q) and R equiv P and (Q and R)$
    - $(P or Q) or R equiv P or (Q or R)$

    *Distributivity:*
    - $P and (Q or R) equiv (P and Q) or (P and R)$
    - $P or (Q and R) equiv (P or Q) and (P or R)$
  ],
)

== Implication and Biconditional Laws

#grid(
  columns: 2,
  column-gutter: 1.5em,
  [
    *Implication Elimination:*
    - $P imply Q equiv not P or Q$
    - $not (P imply Q) equiv P and not Q$

    *Contrapositive:*
    - $P imply Q equiv not Q imply not P$
  ],
  [
    *Biconditional:*
    - $P iff Q equiv (P imply Q) and (Q imply P)$
    - $P iff Q equiv (P and Q) or (not P and not Q)$

    *Exportation:*
    - $(P and Q) imply R equiv P imply (Q imply R)$
  ],
)

#note[
  These equivalences can be verified by truth tables or used to _simplify_ formulas algebraically --- exactly like simplifying Boolean expressions for circuit optimization.
]

== Semantic Entailment

#definition[
  A set of formulas $Gamma$ _semantically entails_ (or _logically implies_) a formula $phi$, written $Gamma models phi$, if every interpretation that satisfies all formulas in $Gamma$ also satisfies $phi$:
  $
    Gamma models phi
    quad "iff" quad
    forall nu. thin (forall psi in Gamma. thin Eval(psi) = True) imply Eval(phi) = True
  $
]

#example[
  - ${P, P imply Q} models Q$ (modus ponens, semantically)
  - ${P imply Q, Q imply R} models P imply R$ (hypothetical syllogism)
  - ${P or Q, not P} models Q$ (disjunctive syllogism)
]

#theorem[Semantic Deduction Theorem][
  $Gamma union {phi} models psi$ if and only if $Gamma models phi imply psi$

  _Special case:_ ${phi} models psi$ iff $models phi imply psi$
]

#note[
  The deduction theorem connects entailment with implication: to show that premises entail a conclusion, we can equivalently show that the conjunction of premises implies the conclusion.
]

= Normal Forms
#focus-slide()

== Literals, Clauses, Cubes, and Normal Forms

#definition[
  A _literal_ is a propositional variable or its negation:
  - _Positive literal_: $P$
  - _Negative literal_: $not P$
]

#definition[
  A _clause_ is a disjunction of literals: $(L_1 or L_2 or dots or L_k)$
]

// #definition[
//   A _cube_ is a conjunction of literals: $(L_1 and L_2 and dots and L_k)$
// ]

#definition[
  A formula is in _conjunctive normal form_ (CNF) if it is a conjunction of clauses:
  $
    underbrace((L_(1,1) or dots or L_(1,k_1)), "clause 1") and dots and underbrace((L_(n,1) or dots or L_(n,k_n)), "clause n")
  $
]

// #definition[
//   A formula is in _disjunctive normal form_ (DNF) if it is a disjunction of cubes:
//   $
//     underbrace((L_(1,1) and dots and L_(1,k_1)), "cube 1") or dots or underbrace((L_(m,1) and dots and L_(m,k_m)), "cube m")
//   $
// ]

== CNF Conversion Algorithm

#Block(color: blue)[
  *Algorithm to convert any formula to CNF:*

  + *Eliminate biconditionals:* $phi iff psi ~> (phi imply psi) and (psi imply phi)$
  + *Eliminate implications:* $phi imply psi ~> not phi or psi$
  + *Push negations inward* (De Morgan + double negation):
    - $not (phi and psi) ~> not phi or not psi$
    - $not (phi or psi) ~> not phi and not psi$
    - $not not phi ~> phi$
  + *Distribute* $or$ over $and$:
    - $phi or (psi and chi) ~> (phi or psi) and (phi or chi)$
]

#pagebreak(weak: true)

#example[Converting to CNF][
  Convert $(P imply Q) imply R$ to CNF:

  + Eliminate outer implication: $not (P imply Q) or R$
  + Eliminate inner implication: $not (not P or Q) or R$
  + Push negation inward: $(not not P and not Q) or R$
  + Double negation: $(P and not Q) or R$
  + Distribute $or$ over $and$: $(P or R) and (not Q or R)$

  Final CNF: $(P or R) and (not Q or R)$
]

#theorem[Normal Form Existence][
  Every propositional formula is logically equivalent to a formula in CNF and to a formula in DNF.
]

#note[
  - *CNF* is preferred for SAT solvers (clause-based reasoning)
  - *DNF* is useful for model enumeration and some verification tasks
  - Conversion may cause _exponential blowup_ in formula size
]

== Connection to SAT

#definition[
  The _satisfiability problem_ (SAT): given a propositional formula $phi$ (usually in CNF), determine whether $phi$ is satisfiable.
]

#theorem[Cook--Levin][
  SAT is *NP-complete* --- the canonical NP-complete problem.
]

#Block(color: teal)[
  *Why SAT matters:*
  - Foundation of computational complexity theory
  - Practical SAT solvers handle formulas with _millions_ of variables
  - Applications: verification, planning, cryptanalysis, scheduling

  #v(0.5em)
  _See the dedicated lecture on SAT for DPLL algorithm, CDCL, and applications._
]

= Proof Systems
#focus-slide(
  epigraph: [Mathematics is not about numbers, equations, or algorithms: \ it is about understanding.],
  epigraph-author: [William Paul Thurston],
)

== From Semantics to Syntax

#Block[
  So far we've studied _semantics_ --- what formulas _mean_ in terms of truth values.

  Now we turn to _syntax_ --- how to _prove_ formulas using purely symbolic manipulation.
]

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *Semantic approach:*
    - Check all $2^n$ interpretations
    - Exponential in number of variables
    - "Brute force" verification
    - Answers: "_Is_ this true?"
  ],
  [
    *Syntactic approach:*
    - Apply inference rules step-by-step
    - Polynomial-sized proofs (sometimes)
    - "Reasoned" derivation
    - Answers: "_Why_ is this true?"
  ],
)

#Block(color: yellow)[
  *The fundamental question:* Can syntactic proofs capture exactly the semantic truths?

  If $models phi$ (semantically valid), can we always _prove_ $phi$ syntactically?
]

== What is a Proof System?

#Block[
  A _proof system_ is a formal method for deriving conclusions from premises using explicit rules.

  But what exactly are the components?
]

#definition[
  An _axiom_ is a formula that we accept as true without proof --- a starting point for reasoning.
]

#definition[
  An _inference rule_ is a pattern that allows us to derive a new formula (the _conclusion_) from one or more existing formulas (the _premises_).
]

#example[
  The most famous inference rule is _modus ponens_:

  #align(center)[
    #grid(
      columns: 1,
      align: left,
      inset: 5pt,
      [$phi$],
      [$phi imply psi$],
      grid.hline(stroke: .8pt),
      [$psi$],
    )
  ]

  "If we have $phi$ and we have $phi imply psi$, then we may conclude $psi$."
]

#note[
  Inference rules are written with premises above the line and conclusion below. This notation goes back to Frege and Gentzen.
]

== What is a Proof?

#definition[
  A _proof_ (or _derivation_) of formula $phi$ from a set of premises $Gamma$ is a finite sequence of formulas $phi_1, phi_2, dots, phi_n$ where:
  - The final formula $phi_n = phi$ (the thing we want to prove)
  - Each $phi_i$ in the sequence is justified by one of:
    + It is an axiom of the system
    + It is a premise (a formula from $Gamma$)
    + It follows from earlier formulas by an inference rule
]

#example[
  A simple proof of $Q$ from premises ${P, thick P imply Q}$:
  #grid(
    columns: 3,
    align: left,
    inset: 5pt,
    [1.], [$P$], [Premise],
    [2.], [$P imply Q$], [Premise],
    [3.], [$Q$], [Modus ponens from 1, 2],
  )
]

== Derivability Notation

#definition[
  We write $Gamma proves phi$ (read: "$Gamma$ proves $phi$" or "$phi$ is derivable from $Gamma$") when there exists a proof of $phi$ from the premises in $Gamma$.
]

#example[
  - ${P, thin P imply Q} proves Q$ --- we just showed this proof above
  - ${P imply Q, thin Q imply R} proves P imply R$ --- hypothetical syllogism
  - ${P and Q} proves P$ --- conjunction elimination
]

#note[
  We ofter _drop_ the curly braces for the set of premises, e.g., writing $P, P imply Q proves Q$.
]

#definition[
  When $Gamma = emptyset$ (no premises), we write $proves phi$ and say "$phi$ is a _theorem_" --- provable from the axioms alone.
]

== Semantic vs. Syntactic Entailment

#Block(color: yellow)[
  *Compare the two turnstiles:*
  - $Gamma models phi$ --- semantic: $phi$ is true whenever all of $Gamma$ is true
  - $Gamma proves phi$ --- syntactic: $phi$ can be derived from $Gamma$ using rules

  Are they the same? This is the central question of metalogic!
]

== Types of Proof Systems

#Block(color: yellow)[
  There are many different proof systems for propositional logic. They differ in:
  - How many axioms they have (many vs. few vs. none)
  - What inference rules they use
  - How proofs are structured
]

#v(1fr, weak: true)

#grid(
  columns: 2,
  column-gutter: 1em,
  Block(color: blue)[
    *Hilbert-style systems:*
    - Many axiom _schemas_
    - Few inference rules (e.g. just modus ponens)
    - Proofs are linear sequences
    - Historically important but hard to use
  ],
  Block(color: green)[
    *Natural deduction:*
    - No axioms
    - Many inference rules (intro/elim)
    - Tree-structured or Fitch-style proofs
    - Mirrors human reasoning
  ],
)

#v(1fr, weak: true)

#Block(color: orange)[
  Other systems include: _sequent calculus_ (Gentzen), _tableaux_ (semantic trees), _resolution_ (SAT).

  Different systems are useful for different purposes!
]

== Hilbert Systems: An Example

#Block[
  Hilbert systems have many axiom _schemas_ (patterns that generate infinitely many axioms) but typically only _modus ponens_ as an inference rule.
]

#example[A Classic Hilbert System][
  *Axiom schemas* (where $phi, psi, chi$ are any formulas):
  + $phi imply (psi imply phi)$
  + $(phi imply (psi imply chi)) imply ((phi imply psi) imply (phi imply chi))$
  + $(not phi imply not psi) imply (psi imply phi)$

  *Inference rule:* Modus ponens only.
]

#Block(color: orange)[
  *Problem:* Hilbert proofs are often long and unintuitive.

  Even proving $P imply P$ (identity) requires several steps --- try it!
]

#note[
  Hilbert systems are important for metamathematics (proving things _about_ proof systems) but impractical for everyday reasoning.
]

== Natural Deduction: The Idea

#Block(color: teal)[
  _Natural deduction_ was invented by Gerhard Gentzen (1934) to formalize how mathematicians _actually_ reason.

  *The key insight:* instead of many axioms, we have _rules_ for each logical connective.
]

#grid(
  columns: 2,
  column-gutter: 1em,
  [
    #definition[
      An _introduction rule_ shows how to *prove* a formula with a given connective as main operator.
    ]

    #example[
      *Conjunction ($and$):*
      - _Introduction:_ From $phi$ and $psi$, conclude $phi and psi$
      - _Elimination:_ From $phi and psi$, conclude $phi$ (or $psi$)
    ]
  ],
  [
    #definition[
      An _elimination rule_ shows how to *use* a formula with a given connective to derive new formulas.
    ]

    #example[
      *Implication ($imply$):*
      - _Introduction:_ Assume $phi$, derive $psi$, conclude $phi imply psi$
      - _Elimination:_ From $phi imply psi$ and $phi$, conclude $psi$ (modus~ponens)
    ]
  ],
)

== Hypothetical Reasoning

#Block[
  A crucial feature of natural deduction is _hypothetical reasoning_:
  - We can temporarily *assume* a formula
  - Derive consequences from that assumption
  - Then *discharge* the assumption to get a conditional result
]

#example[Proving $P imply P$][
  + Assume $P$ #h(2em) _(assumption)_
  + We have $P$ #h(2em) _(from 1)_
  + Therefore $P imply P$ #h(1em) _($imply$I, discharge 1)_
]

#Block(color: yellow)[
  *This is how mathematicians reason:*

  "Suppose $n$ is even. Then... Therefore, _if_ $n$ is even, _then_ $n^2$ is even."
]

== Fitch Notation

#Block[
  _Fitch notation_ is a structured format for writing natural deduction proofs:
  - *Vertical lines* show the _scope_ of assumptions
  - *Indentation* indicates subproofs (nested assumptions)
  - Each line is *numbered* and *justified* by a rule
]

#example[
  Simple proof using _Modus Ponens_ ($imply$E rule):
  #grid(
    columns: 3,
    align: left,
    inset: 5pt,
    [1.], [$P imply Q$], [_Premise_],
    [2.], [$P$], [_Premise_],
    grid.hline(stroke: 0.8pt),
    [3.], [$Q$], [$imply$E 1, 2],
  )

  From premises $P imply Q$ and $P$, we derive $Q$ by modus ponens.
]

== Inference Rules: Overview

#Block(color: green)[
  For each connective, we have:
  - *Introduction rule* (I): How to _prove_ a formula with that connective
  - *Elimination rule* (E): How to _use_ a formula with that connective
]

#table(
  columns: 4,
  align: (center, left, left, left),
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header([*Connective*], [*Introduction*], [*Elimination*], [*Intuition*]),
  [$and$], [Combine two proofs], [Extract component], ["Both"],
  [$or$], [Provide one proof], [Case analysis], ["Either"],
  [$imply$], [Assume, derive], [Modus ponens], ["If...then"],
  [$not$], [Assume, derive $bot$], [Derive $bot$], ["Not"],
  [$bot$], [---], [Derive anything], ["Absurdity"],
)

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
    #Block(color: yellow)[
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
    #Block(color: yellow)[
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
    #Block(color: yellow)[
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
  _Contradiction_ ($bot$) represents logical inconsistency --- a situation that cannot occur.
]

#pagebreak()

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

    From contradiction, _anything_ follows.
    (Latin: "from falsehood, anything")
  ],
  [
    *Double Negation Elimination (DNE):*
    #grid(
      columns: 1,
      inset: 5pt,
      $not not phi$,
      grid.hline(stroke: .8pt),
      $phi$,
    )

    This rule is _classical_ (not valid in intuitionistic logic).
  ],
)

#note(title: "Classical vs Intuitionistic")[
  Double negation elimination distinguishes _classical_ from _intuitionistic_ logic.
  In constructive mathematics, proving $not not phi$ doesn't automatically give us $phi$ --- we need a _witness_.
]

== Proof Strategies

#Block(color: blue)[
  *Common proof patterns in natural deduction:*

  #grid(
    columns: 2,
    column-gutter: 1em,
    [
      *Direct Proof:*
      - Start from premises
      - Apply rules step-by-step
      - Derive conclusion directly
    ],
    [
      *Proof by Contradiction:*
      - Assume negation of goal
      - Derive contradiction ($bot$)
      - Conclude original goal
    ],
  )

  #grid(
    columns: 2,
    column-gutter: 1em,
    [
      *Conditional Proof:*
      - To prove $phi imply psi$
      - Assume $phi$
      - Derive $psi$, discharge assumption
    ],
    [
      *Proof by Cases:*
      - Given $phi or psi$
      - Show goal follows from $phi$
      - Show goal follows from $psi$
    ],
  )
]

== Worked Example: Contrapositive

// TODO: indent assumption scope (lines 1-7) !!!
#example[
  Proving $(P imply Q) imply (not Q imply not P)$:
  #grid(
    columns: 3,
    align: left,
    inset: 5pt,
    [1.], [$P imply Q$], [_Assumption_],
    [2.], [$not Q$], [_Assumption_],
    [3.], [$P$], [_Assumption_],
    grid.hline(stroke: 0.8pt),
    [4.], [$Q$], [$imply$E 1, 3],
    [5.], [$bot$], [$not$E 2, 4],
    [6.], [$not P$], [$not$I 3--5],
    [7.], [$not Q imply not P$], [$imply$I 2--6],
    [8], [$(P imply Q) imply (not Q imply not P)$], [$imply$I 1--7],
  )
]

== Derived Rules

#definition[
  _Derived rules_ are complex inference patterns provable from basic rules, used as shortcuts.
]

#grid(
  columns: 3,
  column-gutter: 2em,
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
    *Disjunctive Syllogism:*
    #grid(
      columns: 1,
      inset: 5pt,
      $phi or psi$,
      $not phi$,
      grid.hline(stroke: .8pt),
      $psi$,
    )
  ],
)

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *Proof by Contradiction (RAA):*
    #Block(color: yellow)[
      #grid(
        columns: 2,
        column-gutter: 2em,
        [
          #grid(
            columns: 1,
            inset: 5pt,
            $[not phi] dots bot$,
            grid.hline(stroke: .8pt),
            $phi$,
          )
        ],
        [
          Assume negation, \ derive absurdity, \ conclude original.
        ],
      )
    ]
  ],
  [
    *Constructive Dilemma:*
    #grid(
      columns: 1,
      inset: 5pt,
      $(phi imply chi) and (psi imply chi)$,
      $phi or psi$,
      grid.hline(stroke: .8pt),
      $chi$,
    )
  ],
)

= Soundness and Completeness
#focus-slide(
  epigraph: [The rules of logic are to mathematics \ what those of structure are to architecture.],
  epigraph-author: [Bertrand Russell],
)

== The Central Question

#Block(color: blue)[
  We have developed two completely different ways to think about "logical truth":
  - *Semantic* ($models$): True in all interpretations (truth tables)
  - *Syntactic* ($proves$): Derivable using inference rules (proofs)

  *Do they coincide?* This is the fundamental question of metalogic.
]

#grid(
  columns: 2,
  column-gutter: 1em,
  Block(color: orange)[
    *If they don't match:*
    - Some truths are _unprovable_ (bad!)
    - Some "proofs" lead to _falsehoods_ (worse!)
    - We couldn't trust either method
  ],
  Block(color: green)[
    *If they do match:*
    - Proofs and truth tables give _same answers_
    - We can choose whichever method is easier
    - Formal reasoning is _reliable_
  ],
)

#Block(color: teal)[
  *Historical importance:* This question drove 20th century logic. Answering it required developing precise definitions of "proof" and "truth" --- the birth of mathematical logic as we know it.
]

== Soundness: Proofs Never Lie

#definition[
  A proof system is _sound_ if every derivable formula is semantically valid:
  $ Gamma proves phi quad imply quad Gamma models phi $

  In other words: "You can't prove anything false."
]

#theorem[
  Natural deduction for propositional logic is sound.
]

#proof[(sketch)][
  By induction on the length of derivations:
  - *Base case*: Premises and axioms are valid by assumption.
  - *Inductive step*: Each inference rule preserves validity.

  For example, $and$-Introduction: if $Eval(phi) = True$ and $Eval(psi) = True$, then $Eval(phi and psi) = True$.
]

#pagebreak()

#Block(color: yellow)[
  *Why soundness matters:*
  - Proofs are _reliable_ --- they never lead to false conclusions
  - Automated provers can be _trusted_
  - If $proves bot$, the system is _inconsistent_ (useless)
]

== Completeness: All Truths Are Provable

#definition[
  A proof system is _complete_ if every semantically valid formula is derivable:
  $ Gamma models phi quad imply quad Gamma proves phi $

  In other words: "Everything true can be proven."
]

#theorem[Gödel, 1929][
  Natural deduction for propositional logic is complete.
]

#Block(color: yellow)[
  *Why completeness matters:*
  - Proof search is _exhaustive_ --- if it's true, you can find a proof
  - No "unreachable truths" in propositional logic
  - Truth tables and proofs are _equivalent_ methods
]

#Block(color: green)[
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

  #[
    #set enum(numbering: it => [*Step #it:*])

    + If $Gamma proves.not alpha$, then $Gamma union {not alpha}$ is consistent (cannot derive $bot$).
    + Extend $Gamma union {not alpha}$ to a _maximal consistent set_ $Delta$:
      - $Delta$ is consistent (cannot derive $bot$)
      - For every formula $beta$, either $beta in Delta$ or $not beta in Delta$
    + Define interpretation $nu$ for atomic propositions $P$ by:
      $ nu(P) = True iff P in Delta $
    + Show by induction that for all formulas $beta$:
      $ Eval(beta) = True iff beta in Delta $
    + Since $not alpha in Delta$, we have $Eval(alpha) = False$.
      Since $Gamma subset.eq Delta$, we have $Eval(gamma) = True$ for all $gamma in Gamma$.
  ]

  Therefore $Gamma models.not alpha$.
]

== The Completeness Theorem

#theorem[
  In _propositional logic_, for any set of formulas $Gamma$ and formula $phi$:
  $
    Gamma models phi
    quad "iff" quad
    Gamma proves phi
  $
]

#Block(color: blue)[
  *Practical implications:*
  - Automated theorem provers are _theoretically sound_
  - Truth table methods and proof methods are _equivalent_
  - Proof search is _as hard as SAT_ (NP-complete)
]

#note(title: "Beyond Propositional Logic")[
  This perfect correspondence doesn't always hold:
  - *First-order logic*: Complete (Gödel 1929) but undecidable (Church 1936)
  - *Second-order logic*: Incomplete (no proof system captures all valid formulas)
  - *Arithmetic*: Incomplete (Gödel's Incompleteness Theorems, 1931)
]

= Categorical Logic
#focus-slide(
  epigraph: [All men are mortal. Socrates is a man. Therefore, Socrates is mortal.],
  epigraph-author: [Classical syllogism],
  scholars: (
    (
      name: "Aristotle",
      image: image("assets/Aristotle.jpg"),
    ),
    (
      name: "Socrates",
      image: image("assets/Socrates.jpg"),
    ),
    (
      name: "George Boole",
      image: image("assets/George_Boole.jpg"),
    ),
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
    table.header([*Form*], [*Quantifier*], [*Quality*], [*Structure*], [*Example*]),
    [*A*], [Universal], [Affirmative], [All S are P], ["All cats are mammals"],
    [*E*], [Universal], [Negative], [No S are P], ["No fish are mammals"],
    [*I*], [Particular], [Affirmative], [Some S are P], ["Some birds are flightless"],
    [*O*], [Particular], [Negative], [Some S are not P], ["Some animals are not vertebrates"],
  )
]

== Examples of Categorical Propositions

#grid(
  columns: 2,
  column-gutter: 1em,
  [
    *A (Universal Affirmative):*
    - All students are hardworking
    - Every theorem has a proof
    - All prime numbers except 2 are odd

    *I (Particular Affirmative):*
    - Some politicians are honest
    - Some functions are continuous
    - Some equations have multiple solutions
  ],
  [
    *E (Universal Negative):*
    - No circles are squares
    - No valid argument has false premises and true conclusion
    - No even number greater than 2 is prime

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

// #Block(color: yellow)[
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

#Block[
  The square captures _four fundamental relationships_:

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

#Block[
  Categorical propositions can be translated into first-order logic:

  #table(
    columns: 3,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Traditional*], [*Modern Logic*], [*Reading*]),
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

#Block(color: orange)[
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
    columns: 3,
    column-gutter: 2em,
    grid(
      columns: 2,
      inset: 5pt,
      [All humans are mortal], [_(Major premise)_],
      [Socrates is human], [_(Minor premise)_],
      grid.hline(stroke: .8pt),
      [Therefore, Socrates is mortal], [_(Conclusion)_],
    ),
    [
      Terms:
      - Major term: mortal (P)
      - Minor term: Socrates (S)
      - Middle term: human (M)
    ],
    grid(
      columns: 2,
      inset: 5pt,
      [All M are P], [*(A)*],
      [All S are M], [*(A)*],
      grid.hline(stroke: .8pt),
      [All S are P], [*(A)*],
    ),
  )
]

== Syllogistic Forms and Validity

#Block[
  Traditional logic identified *24 valid syllogistic forms* across four figures.

  Each valid form has a traditional Latin name encoding its mood (vowels = A, E, I, O):
]

#example[Famous Valid Forms][
  - *Barbara* (AAA-1): All M are P, All S are M $therefore$ All S are P
  - *Celarent* (EAE-1): No M are P, All S are M $therefore$ No S are P
  - *Darii* (AII-1): All M are P, Some S are M $therefore$ Some S are P
]

#Block(color: orange)[
  *Common Fallacies:*
  - *Undistributed Middle*: "All A are B, All C are B $therefore$ All A are C"
  - *Four Terms*: Equivocation on word meaning
  - *Existential Fallacy*: Particular conclusion from universal premises
]

#note[
  The names A, E, I, O come from Latin vowels in _affirmo_ (I affirm) and _nego_ (I deny).
]

== From Categorical Logic to First-Order Logic

#Block(color: yellow)[
  Traditional categorical logic has important _limitations_:
  + Only handles *simple quantification* (all, some, no)
  + *Cannot express relations*: "John is taller than Mary"
  + *Limited to two categories* per proposition
  + *No nested quantifiers*: "Every student likes some professor"
  + *Existential import* controversies
]

#example[What categorical logic cannot express][
  - $forall x. exists y. R(x, y)$ --- "Everyone has someone who loves them"
  - $forall x. (P(x) imply exists y. Q(x, y))$ --- "Every problem has a solution"
  - Transitive closure, recursion, arithmetic
]

#Block(color: blue)[
  These limitations motivate *first-order logic* (predicate logic), which we study next.
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

  In propositional logic, these would be _unrelated_ atomic propositions $P$, $Q$, $R$, without any structure connecting them.
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

#definition[
  A _term_ is an expression denoting an object:
  - Variables: $x, y, z$
  - Constants: $a, b, c$
  - Function applications: $f(t_1, dots, t_n)$ where $t_i$ are terms
]

#definition[
  An _atomic formula_ is a basic statement:
  - Predicate application: $P(t_1, dots, t_n)$ where $t_i$ are terms
  - Equality: $t_1 = t_2$ where $t_1, t_2$ are terms
]

#definition[
  A _first-order formula_ is built recursively from atomic formulas using:
  - Propositional connectives: $not, and, or, imply, iff$
  - Quantifiers: $forall x. phi$, $exists x. phi$
]

#pagebreak(weak: true)

#examples[
  - $forall x. thin (P(x) imply Q(x))$ — "For all $x$, if $P(x)$ then $Q(x)$"
  - $exists x. thin (P(x) and not Q(x))$ — "There exists an $x$ such that $P(x)$ and not $Q(x)$"
  - $forall x. exists y. thin R(x,y)$ — "For every $x$, there exists a $y$ such that $R(x,y)$"
]

== Free and Bound Variables

#definition[
  An occurrence of variable $x$ in formula $phi$ is:
  - _Bound_ if it occurs within the scope of a quantifier $forall x$ or $exists x$
  - _Free_ if it is not bound

  The _scope_ of quantifier $Q x.$ in formula $Q x. thin phi$ is the formula $phi$.
]

#example[
  In the formula $underbrace(P(x), "free") and forall x. thin underbrace(Q(x), "bound")$:
  - The first $x$ is *free* (not under any quantifier)
  - The second $x$ is *bound* by $forall x$
]

#Block(color: yellow)[
  *Key insight:* The same variable name can be both free and bound in one formula! The two $x$'s above are _different_ --- one refers to an external value, the other is quantified.
]

#definition[
  A formula with no free variables is called _closed_ or a _sentence_.

  Only sentences can be evaluated as simply true or false in a structure.
]

#example[Closed vs. Open Formulas][
  #table(
    columns: 3,
    align: (left, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Formula*], [*Status*], [*Why*]),
    [$forall x. thin P(x) imply Q(x)$], [Closed], [No free variables],
    [$P(x) and Q(y)$], [Open], [Both $x$ and $y$ are free],
    [$exists x. thin P(x) and Q(y)$], [Open], [$y$ is free],
    [$forall x. exists y. thin R(x,y)$], [Closed], [All variables bound],
  )
]

#Block(color: orange)[
  *Warning:* Be careful with nested quantifiers and variable shadowing!

  $forall x. thin (P(x) and exists x. thin Q(x))$ --- the inner $exists x$ _shadows_ the outer $forall x$.
]

== Translating English to FOL

#Block[
  Formalization requires choosing an appropriate _vocabulary_ (predicates, constants, functions) and expressing the logical structure precisely.
]

#example[Common Translation Patterns][
  Let: $H(x)$ = "$x$ is human", $M(x)$ = "$x$ is mortal", $s$ = Socrates

  #table(
    columns: 2,
    align: (left, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*English*], [*FOL*]),
    [All humans are mortal], [$forall x. thin (H(x) imply M(x))$],
    [Some humans are mortal], [$exists x. thin (H(x) and M(x))$],
    [No humans are immortal], [$forall x. thin (H(x) imply M(x))$],
    [Socrates is human], [$H(s)$],
    [Only humans are rational], [$forall x. thin (R(x) imply H(x))$],
  )
]

#pagebreak()

#Block(color: yellow)[
  *Key pattern:*
  - "All A are B" $arrow.r$ $forall x. thin (A(x) imply B(x))$ #h(1em) (use $imply$)
  - "Some A are B" $arrow.r$ $exists x. thin (A(x) and B(x))$ #h(1em) (use $and$)

  These patterns mirror the categorical forms A and I!
]

#Block(color: orange)[
  *Common mistake:* Writing $forall x. thin (H(x) and M(x))$ for "all humans are mortal".

  This actually says "everything is both human and mortal" --- wrong!
]

== First-Order Semantics

#definition[
  A _structure_ (or _model_) $cal(M) = pair(D, cal(I))$ consists of:
  - _Domain_ $D$: non-empty set of objects
  - _Interpretation function_ $cal(I)$:
    - Maps constants to elements of $D$
    - Maps $n$-ary predicates to $n$-ary relations on $D$
    - Maps $n$-ary functions to $n$-ary functions on $D$
]

#definition[
  A _variable assignment_ $sigma : V to D$ maps variables to domain elements.
]

#Block[
  _Truth in a structure:_ For structure $cal(M)$ and assignment $sigma$:
  - $cal(M), sigma models P(t_1, dots, t_n)$ iff $chevron.l cal(I)(t_1)^sigma, dots, cal(I)(t_n)^sigma chevron.r in cal(I)(P)$
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

  Models include $chevron.l ZZ, + chevron.r$, $chevron.l RR setminus {0}, dot chevron.r$, etc.
]

== First-Order Natural Deduction

#definition[
  Additional rules for quantifiers:
  #grid(
    columns: 2,
    column-gutter: 2em,
    [
      *Universal Introduction ($forall$I):*
      #Block(color: yellow)[
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
      #Block(color: yellow)[
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

#Block(color: yellow)[
  *Gödel's Incompleteness (for arithmetic):*

  Any consistent formal system strong enough to express arithmetic contains statements that are _true but unprovable_ within the system. This is different from (un)decidability --- it concerns the limits of _any_ proof system, not just algorithmic validity checking.
]

#pagebreak()

#Block(color: orange)[
  *The expressiveness--decidability trade-off:*
  - Propositional logic: decidable (SAT-solvable) but has _limited expressiveness_
  - First-order logic: highly expressive but _undecidable_
  - Higher-order logic: even more expressive but _incomplete_

  This illustrates fundamental limitations in automated reasoning: we gain expressiveness at the cost of decidability.
]

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
  table.header([*Logic*], [*Expressiveness*], [*Decidability*], [*Completeness*]),
  [Propositional], [Basic], [#YES], [#YES],
  [First-Order], [High], [#NO], [#YES],
  [Second-Order], [Very High], [#NO], [#NO],
  [Higher-Order], [Maximum], [#NO], [#NO],
)

#Block(color: blue)[
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

// == Bibliography
// #bibliography("refs.yml")

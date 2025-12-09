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

  In Boolean Algebra, we studied how to _compute_ with truth values --- evaluating expressions like #box[$(P and Q) or not P$] given specific values for $P$ and $Q$.

  Now we ask a deeper question: which formulas are _always_ true, regardless of the values we plug in?
  And how do we _prove_ that an argument is valid?
]

#Block(color: yellow)[
  *Logic answers:*
  - What makes an argument _valid_?
  - Can we _mechanically check_ proofs?
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
  _Modus ponens_ --- the basic inference rule:

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
  Before we can ask whether a formula is _true_, we need to specify what counts as a valid formula. \
  This is the job of *syntax*: defining the grammar of our logical language.

  Syntax is purely about structure --- it says nothing about meaning.
]

#definition[
  A _propositional language_ $cal(L)$ consists of:

  - _Propositional variables_ (atoms): $P, Q, R, dots$ or $p_1, p_2, p_3, dots$

  - _Logical connectives_: $not$ (negation), $and$ (conjunction), $or$ (disjunction), $imply$ (implication), $iff$~(biconditional)

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
  *Material implication* $P imply Q$ ("if $P$ then $Q$") often trips people up.

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
  So far we've discussed _syntax_ --- the grammar of logical formulas.

  *Semantics* is about _meaning_: when is a formula true?
  The answer depends on what truth values we assign to the variables.
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
  A _truth table_ lists all possible interpretations and the resulting truth values of formulas.
]

#Block(color: blue)[
  *Constructing a Truth Table:*
  + List variables $P_1, dots, P_n$
  + Create $2^n$ rows for all truth value combinations
  + Compute each subformula column-by-column
  + The final column gives the formula's value for each interpretation
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
  Just as Boolean algebra has laws for simplifying expressions, propositional logic has equivalence laws.
  In fact, they're the same laws!
  Here's a reference:
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
  column-gutter: 2em,
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
  To check if ${P, P imply Q} models Q$ (modus ponens):

  + Find all interpretations that satisfy all formulas in $Gamma = {P, P imply Q}$:
    - $Eval(P) = #True$ and $Eval(P imply Q) = #True$
    - There is only one such interpretation: $nu = {P mapsto #True, Q mapsto #True}$

  + These interpretations must have $Eval(Q) = #True$ for $Gamma models Q$ to hold.
    - Indeed, $Eval(Q) = #True$ under this interpretation.
]

#example[
  ${P imply Q, Q imply R} models P imply R$ (hypothetical syllogism)
]

#example[
  ${P or Q, not P} models Q$ (disjunctive syllogism)
]

== Semantic Deduction Theorem

#theorem[
  $Gamma union {phi} models psi$ if and only if $Gamma models phi imply psi$

  *Special case:* ${phi} models psi$ $thin$ iff $thin$ $models phi imply psi$
]

#note[
  The deduction theorem connects _entailment_ with _implication_: to show that premises entail a conclusion, we can equivalently show that the conjunction of premises implies the conclusion.
]

#proof[($arrow.r.double$)][
  Assume $Gamma union {phi} models psi$.

  - For any interpretation $nu$, if $Eval(chi) = True$ for all $chi in Gamma$ and $Eval(phi) = True$, then $Eval(psi) = True$.
  - Therefore, if $Eval(chi) = True$ for all $chi in Gamma$, then whenever $Eval(phi) = True$, we have $Eval(psi) = True$.
  - This means $Eval(phi imply psi) = True$ under all interpretations satisfying $Gamma$, so $Gamma models phi imply psi$. #qedhere
]

#proof[($arrow.l.double$)][
  Assume $Gamma models phi imply psi$.

  - For any interpretation $nu$, if $Eval(chi) = True$ for all $chi in Gamma$, then $Eval(phi imply psi) = True$.
  - If also $Eval(phi) = True$, then by the definition of implication, $Eval(psi) = True$.
  - Thus, whenever all formulas in $Gamma union {phi}$ are true, so is $psi$, hence $Gamma union {phi} models psi$. #qedhere
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


= Logic Puzzles
#focus-slide(
  epigraph: () => align(left)[
    "What's the sense of a question without an answer?" asked Alice. \
    "Ah, that's the kind that makes you think!" he replied. \
    "Think about what?" asked Alice. \
    "About what the answer could be," he replied.
  ],
  epigraph-author: [Raymond Smullyan],
)

== Why Logic Puzzles?

#Block(color: teal)[
  Logic puzzles are a playground for formal reasoning.
  They look like entertainment, but solving them requires exactly the same techniques we use for serious applications: formalizing constraints, applying inference rules, and checking for consistency.

  What makes them valuable is that they reveal how easily informal intuition can go wrong.
]

#Block(color: yellow)[
  *In this section:*
  - Formalizing puzzle constraints as formulas
  - Systematic solving techniques
  - Connection to SAT solvers
]

== Knights and Knaves: The Setup

#definition[
  On the _Island of Knights and Knaves_:
  - *Knights* always tell the truth
  - *Knaves* always lie
  - Every inhabitant is either a knight or a knave

  Your task: determine who is what from their statements.
]

#Block(color: blue)[
  *Formalization:* For each person $X$, let $K_X$ mean "$X$ is a knight."

  A statement $S$ made by $X$ translates to: $K_X iff S$

  _Why?_ If $X$ is a knight, $S$ is true. If $X$ is a knave, $S$ is false.
]

== Puzzle 1: A Simple Start

#example[
  *Person A says:* "I am a knave."

  *Is A a knight or a knave?*
]

#Block(color: green)[
  *Solution:*

  Let $K_A$ = "A is a knight". A's statement is $not K_A$ ("I am a knave").

  The constraint: $K_A iff not K_A$

  - If $K_A$ is true: then $not K_A$ must be true (contradiction!)
  - If $K_A$ is false: then $not K_A$ must be false, so $K_A$ is true (contradiction!)

  *This is a contradiction!* No consistent assignment exists.

  $therefore$ This situation _cannot occur_ on the island --- A cannot make this statement.
]

== Puzzle 2: Two Inhabitants

#example[
  *Person A says:* "We are both knaves."

  *Determine the types of A and B.*
]

#Block(color: green)[
  *Formalization:*
  - $K_A$ = "A is a knight", $K_B$ = "B is a knight"
  - A's statement: $not K_A and not K_B$
  - Constraint: $K_A iff (not K_A and not K_B)$

  *Analysis:*
  - If $K_A$ (A is a knight): Then $not K_A and not K_B$ is true, so $not K_A$ is true. Contradiction!
  - So $not K_A$ (A is a knave): Then $not K_A and not K_B$ is false.
    Since $not K_A$ is true, we need $not K_B$ to be false, so $K_B$ is true.

  *Answer:* A is a knave, B is a knight.
]

== Puzzle 3: Mutual Accusations

*A says:* "B is a knave."

*B says:* "Me and A are of different types."

*What are A and B?*

#Block(color: green)[
  *Formalization:*
  - A's statement: $not K_B$ $quad$ Constraint: $K_A iff not K_B$
  - B's statement: $K_A iff.not K_B$ (different types) $quad$ Constraint: $K_B iff (K_A iff.not K_B)$

  From constraint 1: $K_A$ and $K_B$ have opposite values.

  Substituting into constraint 2: $K_B iff top$ (since $K_A iff.not K_B$ is always true given constraint 1)

  So $K_B$ is true (B is a knight), hence $K_A$ is false (A is a knave).

  *Answer:* A is a knave, B is a knight.

  *Check:* A (knave) lies about B being a knave. B (knight) truthfully says they're different. #YES
]

== Puzzle 4: The Fork in the Road

You reach a fork.
One path leads to treasure, the other to doom.

A single inhabitant stands there. You may ask *one yes/no question*.

*What question finds the treasure?*

#Block(color: green)[
  *The key question:* "If I asked you 'Does the left path lead to treasure?', would you say yes?"

  Let $L$ = "left leads to treasure".

  - *Knight:* Answers the inner question truthfully.
    Says "yes" iff $L$.

  - *Knave:* Would lie about the inner question.
    But asked _whether_ he'd say yes, he lies _again_ --- double negation!
    Says "yes" iff $L$.

  *Both types answer "yes" exactly when left leads to treasure.*
]

#v(1fr, weak: true)

#Block(color: yellow)[
  *The double-negation trick:* Asking a liar what they _would_ say inverts the lie, yielding truth.
]

== From Puzzles to SAT

#Block(color: blue)[
  *Knights and Knaves puzzles are SAT problems in disguise!*

  The translation is direct:
  - *Variables:* $K_A, K_B, dots$ (one per person: true = knight)
  - *Constraints:* For each statement $S$ by person $X$: add clause $K_X iff S$
  - *Solution:* Find a satisfying assignment

  Modern SAT solvers handle puzzles with _thousands_ of inhabitants.
]

#example[Puzzle 2 as CNF][
  Constraint: $K_A iff (not K_A and not K_B)$.
  Converting to CNF:
  $
    & (not K_A or not K_A) and (not K_A or not K_B) and (K_A or K_A or K_B) \
    & quad equiv not K_A and (not K_A or not K_B) and (K_A or K_B) \
    & quad equiv not K_A and K_B
  $

  SAT solver immediately finds a solution: $K_A = 0, K_B = 1$
]

== The Hardest Logic Puzzle Ever

#Block(color: orange)[
  *Boolos's puzzle (1996):* Three gods --- True, False, and Random --- stand before you.
  - True always speaks truly; False always lies
  - Random answers randomly
  - They respond with "da" or "ja" (you don't know which means yes/no)

  *Challenge:* Determine each god's identity using exactly three yes/no questions.
]

#Block(color: yellow)[
  This puzzle combines:
  - Knights and Knaves logic
  - Unknown language mapping
  - Non-deterministic behavior

  It was proven that three questions are both _necessary_ and _sufficient_!

  Reference: _G. Boolos, "The Hardest Logic Puzzle Ever", 1996._
]

== Self-Reference Puzzles

#example[The Liar's Paradox][
  Consider the statement: "This statement is false."

  - If it's true, then what it says holds, so it's false. Contradiction!
  - If it's false, then what it says doesn't hold, so it's not false, i.e., true. Contradiction!
]

#Block(color: orange)[
  *This is not a puzzle to solve --- it's a _paradox_!*

  Unlike Knights and Knaves, there's no consistent truth assignment.

  Paradoxes like this motivated:
  - Tarski's hierarchy of truth predicates
  - Gödel's incompleteness theorems
  - Careful treatment of self-reference in formal systems
]

#Block(color: yellow)[
  *Takeaway:* Formal logic helps us distinguish _solvable puzzles_ from _genuine paradoxes_.
]

== Logic Puzzle Strategies

#Block(color: blue)[
  *Systematic approach:*

  + *Formalize:* Assign a variable to each unknown
  + *Translate:* Convert each statement to a formula
  + *Constrain:* Add $(italic("statement")) iff (italic("speaker is truthful"))$
  + *Simplify:* Apply logical equivalences
  + *Solve:* Find satisfying assignments (or prove none exist)
  + *Verify:* Check against all constraints
]

#example[
  *Always verify!* In Puzzle 2:
  - A (knave) says "We are both knaves" --- false since B is a knight. #YES
  - $K_A = 0, K_B = 1$ satisfies all constraints. #YES
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
  column-gutter: 1.5em,
  Block(color: green)[
    *Semantic approach:*
    - Assign truth values to variables
    - Evaluate formula under each interpretation
    - Check all $2^n$ rows of truth table
    - Answers: "Is $phi$ true everywhere?"
  ],
  Block(color: purple)[
    *Syntactic approach:*
    - Start from axioms or premises
    - Apply inference rules step-by-step
    - Build a derivation (proof)
    - Answers: "Can we derive $phi$?"
  ],
)

#Block(color: yellow)[
  *The key shift:*
  A proof system derives formulas _without mentioning truth_.
  It manipulates symbols according to rules --- a purely mechanical process.
]

== What is a Proof System?

#Block(color: blue)[
  A _proof system_ is a precise, formal game with strict rules.

  Think of it as a machine: you feed in some formulas (premises), turn the crank (apply rules), and out comes a conclusion.
  The machine doesn't "understand" the formulas --- it just manipulates symbols according to patterns.
]

#definition[
  A *proof system* for a logic consists of:
  + A set of *axioms* --- formulas accepted without justification
  + A set of *inference rules* --- patterns for deriving new formulas from existing ones
]

#note[
  Every step in a proof is _mechanically checkable_.
  A computer can verify any proof by pattern-matching alone, without understanding what the formulas "mean."
]

== Axioms: Starting Points

#definition[
  An _axiom_ is a formula we accept as true without proof --- a starting point for all derivations.
]

#Block[
  Different proof systems make different choices about axioms:
  - *Many axioms:* Hilbert systems have infinitely many axiom _schemas_
  - *Few axioms:* Some systems minimize axioms for elegance
  - *No axioms:* Natural deduction needs _no axioms at all_!
]

#Block(color: orange)[
  *The problem with axioms:* We must accept them without justification.
  Axiom-heavy systems require us to "believe" certain formulas are valid before we can prove anything else.
]

== Inference Rules: The Heart of Proof

#Block[
  An _inference rule_ is a template for deriving new formulas.
  It specifies:

  - *Premises* (input formulas we already have)
  - *Conclusion* (output formula we can _derive_)

  Rules are notated with premises above a horizontal line and conclusion below.
]

#definition[
  An inference rule has the general form:

  #align(center)[
    #grid(
      columns: 1,
      align: center,
      inset: 5pt,
      [$phi_1 quad phi_2 quad dots quad phi_n$],
      grid.hline(stroke: .8pt),
      [$psi$],
    )
  ]

  Read: "If we have _premises_ $phi_1, phi_2, dots, phi_n$, then we may derive the _conclusion_ $psi$."
]

== Modus Ponens

#example[
  The most famous inference rule --- _modus ponens_:

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

  Interpretation: "From $phi$ and the conditional $phi imply psi$, we derive $psi$."
]

#note[
  Rules are _syntactic_ --- they match patterns in formulas.
  The rule doesn't care what $phi$ and $psi$ _mean_, only that they have the right form.
]

== Proofs and Derivability

#definition[
  A _proof_ (or _derivation_) of $phi$ from premises $Gamma$ is a finite sequence of formulas where:
  - The final formula is $phi$
  - Each formula is justified as an axiom, a premise from $Gamma$, or follows from earlier formulas by an inference rule
]

#definition[
  We write $Gamma proves phi$ (read: "$Gamma$ proves $phi$") when such a derivation exists.

  When $Gamma = emptyset$, we write $proves phi$ and call $phi$ a *theorem*.
]

#example[
  A proof showing $P, thin P imply Q proves Q$:
  #grid(
    columns: 3,
    align: left,
    inset: 5pt,
    [1.], [$P$], [Premise],
    [2.], [$P imply Q$], [Premise],
    [3.], [$Q$], [Modus ponens on 1, 2],
  )
]

== Semantic vs. Syntactic Entailment

#Block(color: blue)[
  We now have *two turnstile symbols* with very different meanings:
  - $Gamma models phi$ is _about meaning_: every interpretation satisfying $Gamma$ also satisfies $phi$.
  - $Gamma proves phi$ is _about derivation_: there exists a proof of $phi$ from $Gamma$ using rules.
]

#v(1fr, weak: true)

#grid(
  columns: 2,
  column-gutter: 1em,
  Block(color: green)[
    *Semantic ($models$):*

    - About _truth_ and _meaning_
    - Requires checking interpretations
    - "What _is_ true?"
    - Exponential in worst case ($2^n$ rows)
    - External: refers to the world
  ],
  Block(color: purple)[
    *Syntactic ($proves$):*

    - About _derivation_ and _symbols_
    - Requires applying rules
    - "What can we _derive_?"
    - Proof size varies (can be short!)
    - Internal: stays within the system
  ],
)

#v(1fr, weak: true)

#Block(color: yellow)[
  *The central question:* Do $models$ and $proves$ coincide?

  If $Gamma models phi$ implies $Gamma proves phi$ (and vice versa), we can use whichever method is more convenient.
]

== Types of Proof Systems

#Block[
  Many proof systems exist for propositional logic.

  They all prove the _same theorems_, but differ in their design:
]

#grid(
  columns: 2,
  column-gutter: 1em,
  Block(color: purple)[
    *Hilbert-style systems:*
    - Many axiom _schemas_
    - Few rules (often just modus ponens)
    - Proofs are linear sequences
    - Historically important, but tedious
  ],
  Block(color: green)[
    *Natural deduction:*
    - *No axioms at all!*
    - Many rules (intro/elim per connective)
    - Tree-structured or Fitch-style proofs
    - Mirrors how mathematicians reason
  ],
)

#note[
  Other systems: _sequent calculus_ (Gentzen), _tableaux_ (semantic trees), _resolution_ (SAT solvers).
]

== Hilbert Systems: Axiom-Heavy Approach

#Block[
  Hilbert systems have many axiom _schemas_ (patterns generating infinitely many axioms) but typically only modus ponens as inference rule.
]

*Axiom schemas* (for any formulas $phi, psi, chi$):
+ $phi imply (psi imply phi)$
+ $(phi imply (psi imply chi)) imply ((phi imply psi) imply (phi imply chi))$
+ $(not phi imply not psi) imply (psi imply phi)$

*Inference rule:* Modus ponens only.

#Block(color: orange)[
  Hilbert proofs are long and unintuitive --- even proving $P imply P$ requires several non-obvious steps.

  And we must accept those axiom schemas as valid before we can prove anything.
]

== Natural Deduction: The Axiom-Free Alternative

#Block(color: green)[
  _Natural deduction_ (Gentzen, 1934) takes a radical approach: *no axioms*.

  Instead, we have _rules_ for each logical connective --- ways to _introduce_ and _eliminate_ it.
]

#Block(color: yellow)[
  *Why no axioms?*

  Each rule is self-evident: it just says what a connective _means_.

  - To prove $phi and psi$, prove both $phi$ and $psi$
  - To use $phi and psi$, extract $phi$ or $psi$

  The rules _define_ the connectives through their behavior.
]

== Natural Deduction: Introduction and Elimination

#grid(
  columns: 2,
  column-gutter: 1em,
  [
    #definition[
      An _introduction rule_ shows how to *prove* a formula with a given connective as its main operator.
    ]

    #example[
      *Conjunction ($and$):*
      - _Introduction:_ From $phi$ and $psi$, conclude $phi and psi$
      - _Elimination:_ From $phi and psi$, conclude $phi$ (or $psi$)
    ]
  ],
  [
    #definition[
      An _elimination rule_ shows how to *use* a formula with a given connective to derive something new.
    ]

    #example[
      *Implication ($imply$):*
      - _Introduction:_ Assume $phi$, derive $psi$, conclude $phi imply psi$
      - _Elimination:_ From $phi imply psi$ and $phi$, conclude $psi$ (modus~ponens)
    ]
  ],
)

#note[
  Each connective gets exactly two rules: one to _build_ formulas, one to _use_ them.
]

== Hypothetical Reasoning

#Block[
  One of the most powerful features of natural deduction is _hypothetical reasoning_:
  - We can temporarily *assume* a formula
  - Derive consequences from that assumption
  - Then *discharge* the assumption to get a conditional result

  This mirrors how mathematicians actually argue: "Suppose $P$ holds.
  Then...
  Therefore, if $P$ then $Q$."
]

#grid(
  columns: (1fr, auto),
  gutter: 2em,
  example[Proving $P imply P$][
    #v(-0.5em)
    #grid(
      columns: 3,
      align: left,
      inset: 5pt,
      [1.], [$P$], [_Assumption_],
      grid.hline(stroke: 0.8pt),
      [2.], [$P$], [From 1],
      [3.], [$P imply P$], [$imply$I 1],
    )
    #v(-0.5em)
  ],
  Block(color: yellow)[
    *This is how mathematicians reason:*

    "Suppose $n$ is even. Then... Therefore, _if_ $n$ is even, _then_ $n^2$ is even."
  ],
)

== Fitch Notation

#Block[
  _Fitch notation_ is a structured format for natural deduction proofs:
  - *Horizontal lines* separate premises from derived formulas
  - *Indentation* (in full Fitch style) shows subproof scope
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

  From $P imply Q$ and $P$, we derive $Q$.
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

    This is _modus ponens_.
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

#example[
  Proving $(P imply Q) imply (not Q imply not P)$:
  #grid(
    columns: 3,
    align: left,
    inset: 5pt,
    [1.], [$P imply Q$], [_Assumption_],
    [2.], [$thick not Q$], [_Assumption_],
    [3.], [$thick thick P$], [_Assumption_],
    grid.hline(stroke: 0.8pt),
    [4.], [$thick thick Q$], [$imply$E 1, 3],
    [5.], [$thick thick bot$], [$not$E 2, 4],
    [6.], [$thick not P$], [$not$I 3--5],
    [7.], [$not Q imply not P$], [$imply$I 2--6],
    [8.], [$(P imply Q) imply (not Q imply not P)$], [$imply$I 1--7],
  )
]

== Worked Example: Proof by Contradiction (RAA)

#example[Law of Excluded Middle][
  Proving $P or not P$ using _reductio ad absurdum_ (proof by contradiction):
  #grid(
    columns: 3,
    align: left,
    inset: 5pt,
    [1.], [$not (P or not P)$], [_Assumption (for RAA)_],
    [2.], [$thick P$], [_Assumption_],
    grid.hline(stroke: 0.8pt),
    [3.], [$thick P or not P$], [$or$I 2],
    [4.], [$thick bot$], [$not$E 1, 3],
    [5.], [$not P$], [$not$I 2--4],
    [6.], [$P or not P$], [$or$I 5],
    [7.], [$bot$], [$not$E 1, 6],
    [8.], [$P or not P$], [RAA 1--7],
  )
]

#Block(color: yellow)[
  *Key technique:* We assumed $not (P or not P)$ and derived $bot$.
  By RAA, we conclude $P or not P$.

  This is a *classical* proof --- it relies on double negation elimination and is not valid in intuitionistic logic!
]

== Worked Example: Double Negation

#example[Double Negation Introduction][
  Proving $P imply not not P$:
  #grid(
    columns: 3,
    align: left,
    inset: 5pt,
    [1.], [$P$], [_Assumption_],
    [2.], [$thick not P$], [_Assumption (for RAA)_],
    grid.hline(stroke: 0.8pt),
    [3.], [$thick bot$], [$not$E 1, 2],
    [4.], [$not not P$], [$not$I 2--3],
    [5.], [$P imply not not P$], [$imply$I 1--4],
  )
]

#pagebreak()

#example[Double Negation Elimination][
  Proving $not not P imply P$ (requires classical logic):
  #grid(
    columns: 3,
    align: left,
    inset: 5pt,
    [1.], [$not not P$], [_Assumption_],
    [2.], [$thick not P$], [_Assumption (for RAA)_],
    grid.hline(stroke: 0.8pt),
    [3.], [$thick bot$], [$not$E 1, 2],
    [4.], [$P$], [RAA 2--3],
    [5.], [$not not P imply P$], [$imply$I 1--4],
  )
]

== Worked Example: Disjunctive Syllogism

#example[
  Proving $(P or Q) imply (not P imply Q)$:
  #grid(
    columns: 3,
    align: left,
    inset: 5pt,
    [1.], [$P or Q$], [_Assumption_],
    [2.], [$thick not P$], [_Assumption_],
    [3.], [$thick thick P$], [_Assumption (for case 1)_],
    grid.hline(stroke: 0.8pt),
    [4.], [$thick thick bot$], [$not$E 2, 3],
    [5.], [$thick thick Q$], [$bot$E 4],
    [6.], [$thick thick Q$], [_Assumption (for case 2)_],
    [7.], [$thick Q$], [$or$E 1, 3--5, 6--6],
    [8.], [$not P imply Q$], [$imply$I 2--7],
    [9.], [$(P or Q) imply (not P imply Q)$], [$imply$I 1--8],
  )
]

#Block(color: blue)[
  *This proof combines:*
  - Nested assumptions (subproofs within subproofs)
  - Case analysis ($or$E)
  - Ex falso quodlibet ($bot$E) for the impossible case
]

== Worked Example: Peirce's Law

#example[Peirce's Law --- A Classic Challenge][
  Proving $((P imply Q) imply P) imply P$:
  #grid(
    columns: 3,
    align: left,
    inset: 5pt,
    [1.], [$(P imply Q) imply P$], [_Assumption_],
    [2.], [$thick not P$], [_Assumption (for RAA)_],
    [3.], [$thick thick P$], [_Assumption_],
    grid.hline(stroke: 0.8pt),
    [4.], [$thick thick bot$], [$not$E 2, 3],
    [5.], [$thick thick Q$], [$bot$E 4],
    [6.], [$thick P imply Q$], [$imply$I 3--5],
    [7.], [$thick P$], [$imply$E 1, 6],
    [8.], [$thick bot$], [$not$E 2, 7],
    [9.], [$P$], [RAA 2--8],
    [10.], [$((P imply Q) imply P) imply P$], [$imply$I 1--9],
  )
]

#Block(color: orange)[
  *Peirce's Law* is another purely classical theorem.
  It's equivalent to excluded middle and cannot be proven constructively.
  It's named after Charles Sanders Peirce (1839--1914).
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


= Logical Fallacies
#focus-slide(
  epigraph: [The first principle is that you must not fool yourself --- \ and you are the easiest person to fool.],
  epigraph-author: [Richard Feynman],
)

== Why Study Fallacies?

#Block(color: teal)[
  *Fallacies* are reasoning patterns that _look_ valid but _aren't_.

  They appear everywhere: everyday arguments, political debates, advertising, even academic papers.
  The trouble is that they can be quite persuasive until you analyze them carefully.

  Formal logic gives us precise tools to identify and refute fallacious reasoning.
]

#Block(color: yellow)[
  *Our approach:*
  + Present the fallacy pattern
  + Give a concrete example
  + Prove formally why it fails (via countermodel)
]

== Fallacy 1: Affirming the Consequent

#definition[
  *Affirming the Consequent* is the invalid inference:
  #align(center)[
    #grid(
      columns: 1,
      align: left,
      inset: 5pt,
      $P imply Q$,
      $Q$,
      grid.hline(stroke: .8pt),
      [$P$ #h(2em) #text(fill: red)[*✗ INVALID*]],
    )
  ]
]

#example[
  "If it rains, the ground is wet. The ground is wet. Therefore, it rained."

  *Counterexample:* Someone could have watered the garden!
]

#Block(color: blue)[
  *Formal proof of invalidity:*

  Find an interpretation where premises are true but conclusion is false:
  - Let $nu(P) = False$, $nu(Q) = True$
  - Then $P imply Q = False imply True = True$ #YES
  - And $Q = True$ #YES
  - But $P = False$ #NO

  The premises don't entail the conclusion: ${P imply Q, Q} models.not P$
]

== Fallacy 2: Denying the Antecedent

#definition[
  *Denying the Antecedent* is the invalid inference:
  #align(center)[
    #grid(
      columns: 1,
      align: left,
      inset: 5pt,
      $P imply Q$,
      $not P$,
      grid.hline(stroke: .8pt),
      [$not Q$ #h(2em) #Red[#NO *INVALID*]],
    )
  ]
]

#example[
  "If you study hard, you will pass. You didn't study hard. Therefore, you won't pass."

  *Counterexample:* You might be naturally talented, or the exam was easy!
]

#Block(color: green)[
  *Formal proof of invalidity:*

  - Let $nu(P) = False$, $nu(Q) = True$
  - Then $P imply Q = True$ #YES
  - And $not P = True$ #YES
  - But $not Q = False$ #NO

  The conclusion $not Q$ is false while premises are true!
]

== Compare with Valid Forms

#grid(
  columns: 2,
  column-gutter: 2em,
  Block(color: green)[
    *Modus Ponens (VALID):*
    #grid(
      columns: 1,
      inset: 5pt,
      $P imply Q$,
      $P$,
      grid.hline(stroke: .8pt),
      [$Q$ #h(1em) #YES],
    )
    "If $P$ then $Q$; $P$; so $Q$."
  ],
  Block(color: green)[
    *Modus Tollens (VALID):*
    #grid(
      columns: 1,
      inset: 5pt,
      $P imply Q$,
      $not Q$,
      grid.hline(stroke: .8pt),
      [$not P$ #h(1em) #YES],
    )
    "If $P$ then $Q$; not $Q$; so not $P$."
  ],
)

#Block(color: yellow)[
  *Pattern recognition:*
  - *Valid:* Work with the antecedent ($P$) directly, or contrapose using the consequent ($not Q$)
  - *Invalid:* Affirm the consequent ($Q$) or deny the antecedent ($not P$)
]

== Fallacy 3: Undistributed Middle

#definition[
  *Undistributed Middle* (in syllogistic reasoning):
  #align(center)[
    #grid(
      columns: 1,
      inset: 5pt,
      [All A are B],
      [All C are B],
      grid.hline(stroke: .8pt),
      [All A are C #h(2em) #Red[#NO *INVALID*]],
    )
  ]
]

#example[
  "All cats are mammals. All dogs are mammals. Therefore, all cats are dogs."

  Wrong! Yet the _form_ looks like valid syllogistic reasoning.
]

#Block(color: green)[
  *Formal analysis in FOL:*

  Premises: $forall x.(A(x) imply B(x))$ and $forall x.(C(x) imply B(x))$

  *Countermodel:* Let domain $= {a, c}$, with $A(a) = T$, $C(c) = T$, $B(a) = B(c) = T$, and $A(c) = C(a) = F$.

  Both premises hold, but $A(a) imply C(a)$ is $T imply F = F$. #NO
]

== Fallacy 4: False Dilemma

#definition[
  *False Dilemma* (or False Dichotomy): Presenting only two options when more exist.
  #align(center)[
    #grid(
      columns: 1,
      inset: 5pt,
      $P or Q$,
      $not P$,
      grid.hline(stroke: .8pt),
      $Q$,
    )
  ]
  The inference _is_ valid (disjunctive syllogism), but the premise $P or Q$ may be _false_!
]

#example[
  "You're either with us or against us. You're not with us. Therefore, you're against us."

  *Problem:* One can be neutral, undecided, or have a nuanced position.
]

#Block(color: orange)[
  Some fallacies aren't about _invalid inference_ but about _false premises_.

  The form is valid, but the argument is _unsound_ because a premise doesn't hold.
]

== Fallacy 5: Begging the Question

#definition[
  *Begging the Question* (circular reasoning): The conclusion is assumed in the premises.
]

#example[
  "This medicine works because it's effective, and we know it's effective because it works."

  Formally: $P imply Q$ and $Q imply P$ don't establish either $P$ or $Q$ without assuming one.
]

#Block(color: green)[
  *Formal analysis:*

  Given only $P iff Q$:
  - $P = Q = True$: consistent #YES
  - $P = Q = False$: consistent #YES

  Neither follows! We have $proves P iff Q$ but $proves.not P$ and $proves.not Q$.
]

#Block(color: yellow)[
  *Detection:* Remove the conclusion from premises --- can they still support it?
]

== Fallacy 6: Existential Fallacy

#definition[
  *Existential Fallacy*: Concluding existence from universal statements about possibly empty classes.
  #align(center)[
    #grid(
      columns: 1,
      inset: 5pt,
      [All S are P],
      grid.hline(stroke: .8pt),
      [Some S are P #h(2em) #Red[#NO *INVALID*]],
    )
  ]
]

#example[
  "All unicorns are magical. Therefore, some unicorns are magical."

  If there are no unicorns, the premise is vacuously true but the conclusion is false!
]

#Block(color: green)[
  *FOL analysis:*
  - Premise: $forall x.(S(x) imply P(x))$ --- true if $S$ is empty
  - Conclusion: $exists x.(S(x) and P(x))$ --- false if $S$ is empty

  *Countermodel:* Domain $= {a}$, $S(a) = False$, $P(a) = True$.

  Premise: $forall x. (F imply T) = T$.
  Conclusion: $exists x. (F and T) = F$.
]

== Proof by Contradiction: Showing Invalidity

#Block(color: blue)[
  *General method to prove an inference is invalid:*

  + Assume the inference $Gamma models phi$ is valid
  + Construct a _countermodel_: an interpretation where all premises in $Gamma$ are true, but $phi$ is false
  + The existence of such a countermodel disproves validity
]

#example[Affirming the Consequent --- Detailed][
  *Claim:* ${P imply Q, Q} models P$ is *invalid*.

  *Countermodel construction:*
  - Choose $nu(P) = 0$, $nu(Q) = 1$
  - Check premise 1: $nu(P imply Q) = nu(not P or Q) = max(1, 1) = 1$ #YES
  - Check premise 2: $nu(Q) = 1$ #YES
  - Check conclusion: $nu(P) = 0$ #NO

  Premises true, conclusion false $imply$ inference invalid.
]

== Valid vs. Invalid Inference Patterns

#table(
  columns: 3,
  align: (left, center, left),
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header([*Pattern*], [*Valid?*], [*Name*]),
  [$P imply Q, P therefore Q$], [#YES], [Modus Ponens],
  [$P imply Q, not Q therefore not P$], [#YES], [Modus Tollens],
  [$P imply Q, Q therefore P$], [#NO], [Affirming Consequent],
  [$P imply Q, not P therefore not Q$], [#NO], [Denying Antecedent],
  [$P or Q, not P therefore Q$], [#YES], [Disjunctive Syllogism],
  [$P and Q therefore P$], [#YES], [Simplification],
)

#Block(color: yellow)[
  *Critical thinking:* Identify the logical form, then check if it matches a valid or invalid pattern.
]


= Soundness and Completeness
#focus-slide(
  epigraph: [The rules of logic are to mathematics \ what those of structure are to architecture.],
  epigraph-author: [Bertrand Russell],
)

== The Central Question

#Block(color: blue)[
  We have two different ways to characterize "logical truth":
  - *Semantic* ($models$): True in all interpretations (truth tables)
  - *Syntactic* ($proves$): Derivable using inference rules (proofs)

  *Do they coincide?*
  This is the central question of metalogic.
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
  This question drove 20th century logic, requiring precise definitions of "proof" and "truth" --- the birth of modern mathematical logic.
]

== Soundness: Proofs Never Lie

#definition[
  A proof system is _sound_ if every derivable formula is semantically valid:
  $ Gamma proves phi quad imply quad Gamma models phi $

  In other words: "You can't prove anything false."
]

#theorem[Soundness of Natural Deduction][
  Natural deduction for propositional logic is sound: if $Gamma proves phi$, then $Gamma models phi$.
]

#Block(color: blue)[
  *Proof strategy:* Induction on the _structure of derivations_.

  We show that every inference rule _preserves validity_: if the premises of a rule are true under some interpretation, then the conclusion is also true under that interpretation.
]

== Soundness Proof: Base Cases

#proof[(Part 1: Base Cases)][
  The derivation uses only a premise or an axiom.

  *Case: Premise*

  If $phi in Gamma$ appears as a line in the derivation, then trivially $Gamma models phi$: any interpretation satisfying all of $Gamma$ satisfies $phi$ in particular.

  *Case: Axiom (if any)*

  In natural deduction, we have no axioms in the usual sense (only rules).
  In Hilbert systems, axioms are tautologies, which are valid by definition.
]

== Soundness Proof: Conjunction Rules

#proof[(Part 2: Conjunction)][
  *($and$I) Conjunction Introduction:*

  Suppose we have derivations of $phi$ and $psi$ from $Gamma$, and by IH, $Gamma models phi$ and $Gamma models psi$.

  Let $nu$ be any interpretation satisfying all formulas in $Gamma$.
  Then $Eval(phi) = True$ and $Eval(psi) = True$.
  By definition of $and$: $Eval(phi and psi) = True$.

  Therefore $Gamma models phi and psi$. #YES

  *($and$E) Conjunction Elimination:*

  Suppose we have a derivation of $phi and psi$ from $Gamma$, and by IH, $Gamma models phi and psi$.

  Let $nu$ satisfy all of $Gamma$. Then $Eval(phi and psi) = True$.
  By definition: $Eval(phi) = True$ and $Eval(psi) = True$.

  Therefore $Gamma models phi$ and $Gamma models psi$. #YES
]

== Soundness Proof: Disjunction Rules

#proof[(Part 3: Disjunction)][
  *($or$I) Disjunction Introduction:*

  Suppose $Gamma models phi$ (by IH). Let $nu$ satisfy $Gamma$.
  Then $Eval(phi) = True$, so $Eval(phi or psi) = True$.
  Similarly for the other direction. #YES

  *($or$E) Disjunction Elimination:*

  Suppose $Gamma models phi or psi$, and $Gamma union {phi} models chi$, and $Gamma union {psi} models chi$ (by IH).

  Let $nu$ satisfy $Gamma$. Then $Eval(phi or psi) = True$.

  *Case 1:* $Eval(phi) = True$.
  Then $nu$ satisfies $Gamma union {phi}$, so $Eval(chi) = True$.

  *Case 2:* $Eval(psi) = True$.
  Then $nu$ satisfies $Gamma union {psi}$, so $Eval(chi) = True$.

  In both cases, $Eval(chi) = True$. Therefore $Gamma models chi$. #YES
]

== Soundness Proof: Implication Rules

#proof[(Part 4: Implication)][
  *($imply$I) Implication Introduction:*

  Suppose $Gamma union {phi} models psi$ (by IH).
  We need to show $Gamma models phi imply psi$.

  Let $nu$ satisfy $Gamma$.
  We consider two cases:

  *Case 1:* $Eval(phi) = False$.
  Then $Eval(phi imply psi) = True$ (false implies anything).

  *Case 2:* $Eval(phi) = True$.
  Then $nu$ satisfies $Gamma union {phi}$.
  By IH, $Eval(psi) = True$.
  So $Eval(phi imply psi) = True$.

  In both cases, $Gamma models phi imply psi$. #YES

  *($imply$E) Implication Elimination (Modus Ponens):*

  Suppose $Gamma models phi imply psi$ and $Gamma models phi$ (by IH).

  Let $nu$ satisfy $Gamma$.
  Then $Eval(phi imply psi) = True$ and $Eval(phi) = True$.

  If $Eval(psi) = False$, then $Eval(phi imply psi) = Eval(not phi or psi) = False$.
  Contradiction.

  Therefore $Eval(psi) = True$, and $Gamma models psi$. #YES
]

== Soundness Proof: Negation Rules

#proof[(Part 5: Negation)][
  *($not$I) Negation Introduction:*

  Suppose $Gamma union {phi} models bot$ (by IH).
  We show $Gamma models not phi$.

  Assume for contradiction that some $nu$ satisfies $Gamma$ but $Eval(not phi) = False$, i.e., $Eval(phi) = True$.

  Then $nu$ satisfies $Gamma union {phi}$. By IH, $Eval(bot) = True$.
  But $bot$ is always false! Contradiction.

  Therefore no such $nu$ exists, so $Gamma models not phi$. #YES

  *($not$E) Negation Elimination:*

  Suppose $Gamma models phi$ and $Gamma models not phi$ (by IH).

  Let $nu$ satisfy $Gamma$.
  Then $Eval(phi) = True$ and $Eval(not phi) = True$.
  But $Eval(not phi) = not Eval(phi) = False$. Contradiction.

  Therefore no $nu$ satisfies $Gamma$, so $Gamma models bot$ vacuously. #YES

  *($bot$E) Ex Falso Quodlibet:*

  Suppose $Gamma models bot$.
  Then no interpretation satisfies $Gamma$.
  Therefore $Gamma models phi$ holds vacuously for any $phi$. #YES
]

== Soundness: Summary

#Block(color: green)[
  *We have shown:* Every inference rule of natural deduction preserves semantic validity.

  By induction on derivation structure, if $Gamma proves phi$, then $Gamma models phi$.

  $therefore$ *Natural deduction is sound.*
]

#Block(color: yellow)[
  *Why soundness matters:*
  - Proofs are _reliable_ --- they never lead to false conclusions
  - Automated provers can be _trusted_
  - If $proves bot$, the system is _inconsistent_ (useless)
]

#Block(color: orange)[
  *Exam tip:* You may be asked to prove soundness of a specific rule.
  Follow the pattern: assume premises are valid, show conclusion is valid under any interpretation.
]

== Completeness: All Truths Are Provable

#definition[
  A proof system is _complete_ if every semantically valid formula is derivable:
  $ Gamma models phi quad imply quad Gamma proves phi $

  In other words: "Everything true can be proven."
]

#theorem[Completeness of Propositional Logic][
  Natural deduction for propositional logic is complete: if $Gamma models phi$, then $Gamma proves phi$.
]

#Block(color: blue)[
  *Proof strategy:* We prove the _contrapositive_:

  If $Gamma proves.not phi$, then $Gamma models.not phi$.

  The idea: if we _cannot_ prove $phi$, we can construct a _countermodel_ --- an interpretation where all of $Gamma$ is true but $phi$ is false.
]

== Completeness Proof: Key Concepts

#definition[
  A set of formulas $Gamma$ is _consistent_ if $Gamma proves.not bot$.

  Equivalently: there is no derivation of a contradiction from $Gamma$.
]

#definition[
  A set of formulas $Delta$ is _maximal consistent_ if:
  + $Delta$ is consistent
  + For every formula $phi$: either $phi in Delta$ or $not phi in Delta$ (completeness)
  + Adding any formula not in $Delta$ makes it inconsistent (maximality)
]

#Block(color: yellow)[
  A maximal consistent set "decides" every formula --- it contains exactly one of $phi$ or $not phi$ for each $phi$.

  This is powerful: we can define an interpretation directly from membership in $Delta$!
]

== Completeness Proof: Lindenbaum's Lemma

#theorem[Lindenbaum's Lemma][
  Every consistent set $Gamma$ can be extended to a maximal consistent set $Delta supset.eq Gamma$.
]

#proof[(constructive)][
  Let $phi_1, phi_2, phi_3, dots$ be an enumeration of all formulas.

  Define a sequence of sets:
  - $Gamma_0 = Gamma$
  - $Gamma_(n+1) = cases(
      Gamma_n union {phi_(n+1)} & "if this is consistent",
      Gamma_n union {not phi_(n+1)} & "otherwise"
    )$
  - $Delta = union.big_(n=0)^oo Gamma_n$

  *Claim 1:* Each $Gamma_n$ is consistent (by induction).

  *Claim 2:* $Delta$ is consistent (a derivation uses only finitely many formulas).

  *Claim 3:* $Delta$ is maximal (every $phi_n$ or $not phi_n$ was added at step $n$).
]

== Completeness Proof: Canonical Model

#definition[
  Given a maximal consistent set $Delta$, define the _canonical interpretation_ $nu_Delta$:
  $
    nu_Delta (P) = cases(
      True & "if" P in Delta,
      False & "if" P in.not Delta
    )
  $
  for each propositional variable $P$.
]

#theorem[Truth Lemma][
  For any formula $phi$ and maximal consistent set $Delta$:
  $
    Eval(phi) = True quad "iff" quad phi in Delta
  $
]

#Block(color: blue)[
  This is the heart of the completeness proof!
  It says the canonical interpretation "agrees" with membership in $Delta$ for _all_ formulas, not just atoms.
]

== Completeness Proof: Truth Lemma

#proof[
  By structural induction on $phi$.

  *Base case:* $phi = P$ (atomic). By definition of $nu_Delta$. #YES

  *Case $phi = not psi$:*
  $Eval(not psi) = True$ iff $Eval(psi) = False$ iff $psi in.not Delta$ (IH) iff $not psi in Delta$ (maximality). #YES

  *Case $phi = psi and chi$:*
  - ($arrow.r.double$) If $psi and chi in Delta$, then $psi in Delta$ and $chi in Delta$ (by $and$E being sound and $Delta$ being maximal consistent). By IH, $Eval(psi) = Eval(chi) = True$, so $Eval(psi and chi) = True$.

  - ($arrow.l.double$) If $Eval(psi and chi) = True$, then $Eval(psi) = Eval(chi) = True$. By IH, $psi, chi in Delta$. Since $Delta$ is closed under derivability and $psi, chi proves psi and chi$, we have $psi and chi in Delta$. #YES

  _(see next page)_

  #colbreak()

  *Case $phi = psi or chi$:*
  - ($arrow.r.double$)
    If $psi or chi in Delta$, suppose for contradiction that $psi in.not Delta$ and $chi in.not Delta$.
    By maximality, $not psi in Delta$ and #box[$not chi in Delta$].
    But then $Delta proves psi or chi$ and $Delta proves not psi$ and $Delta proves not chi$, which by $or$E gives $Delta proves bot$.
    Contradiction with consistency!

  - ($arrow.l.double$)
    If $Eval(psi or chi) = True$, then $Eval(psi) = True$ or $Eval(chi) = True$.
    By IH, $psi in Delta$ or $chi in Delta$.
    By $or$I, $psi or chi in Delta$.

  *Case $phi = psi imply chi$:*
  - ($arrow.r.double$)
    If $psi imply chi in Delta$ and $Eval(psi) = True$, then by IH $psi in Delta$.
    By $imply$E, $chi in Delta$, so $Eval(chi) = True$.

  - ($arrow.l.double$)
    If $Eval(psi imply chi) = True$: either $Eval(psi) = False$ or $Eval(chi) = True$.
    In either case, by maximality and closure under derivability, $psi imply chi in Delta$.

  All cases complete.
]

== Completeness Proof: Main Argument

#theorem[Completeness][
  If $Gamma models phi$, then $Gamma proves phi$.
]

#proof[
  We prove the contrapositive: if $Gamma proves.not phi$, then $Gamma models.not phi$.

  Assume $Gamma proves.not phi$.
  Then $Gamma union {not phi}$ is consistent (if not, we could derive $phi$ by RAA).

  By Lindenbaum's Lemma, extend $Gamma union {not phi}$ to a maximal consistent set $Delta$.

  Define the canonical interpretation $nu_Delta$.

  By the Truth Lemma:
  - For each $gamma in Gamma$: since $gamma in Delta$, we have $Eval(gamma) = True$
  - Since $not phi in Delta$, we have $Eval(not phi) = True$, i.e., $Eval(phi) = False$

  Therefore $nu_Delta$ satisfies $Gamma$ but falsifies $phi$.

  This means $Gamma models.not phi$.
]

== The Completeness Theorem: Full Statement

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
  The square captures four relationships:

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
    [All S are P], [$forall x (S(x) imply P(x))$], ["For all x, if x is S then x is P"],
    [No S are P], [$forall x (S(x) imply not P(x))$], ["For all x, if x is S then x is not P"],
    [Some S are P], [$exists x (S(x) and P(x))$], ["There exists x such that x is S and x is P"],
    [Some S are not P], [$exists x (S(x) and not P(x))$], ["There exists x such that x is S and x is not P"],
  )
]

#example[
  "All students are hardworking" becomes:
  $forall x ("Student"(x) imply "Hardworking"(x))$

  "Some politicians are not honest" becomes:
  $exists x ("Politician"(x) and not "Honest"(x))$
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
  Propositional logic treats statements as atomic units --- we can't look _inside_ them.

  But many arguments depend on the _internal structure_ of statements: the objects they mention and the properties those objects have.
]

#example[Limitations of Propositional Logic][
  Consider the classic syllogism:
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
  - $forall x. thin (P(x) imply Q(x))$ --- "For all $x$, if $P(x)$ then $Q(x)$"
  - $exists x. thin (P(x) and not Q(x))$ --- "There exists an $x$ such that $P(x)$ and not $Q(x)$"
  - $forall x. exists y. thin R(x,y)$ --- "For every $x$, there exists a $y$ such that $R(x,y)$"
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
  *Note:* The same variable name can be both free and bound in one formula!
  The two $x$'s above are _different_ --- one refers to an external value, the other is quantified.
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
  - $cal(M), sigma models P(t_1, dots, t_n)$ iff $(cal(I)(t_1)^sigma, dots, cal(I)(t_n)^sigma) in cal(I)(P)$
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

  Models include $pair(ZZ, +)$, $pair(RR without {0}, dot)$, etc.
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
  Modern mathematics increasingly uses _interactive theorem provers_ --- computer systems that assist in constructing and verifying formal proofs.
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

  Any consistent formal system strong enough to express arithmetic contains true statements that are unprovable within that system.

  This is different from undecidability --- incompleteness says that _no_ proof system can capture all mathematical truths about arithmetic.
]

#pagebreak()

#Block(color: orange)[
  *The expressiveness--decidability trade-off:*

  There's a pattern here:
  - Propositional logic: decidable but limited in what it can express
  - First-order logic: very expressive but undecidable
  - Higher-order logic: even more expressive but incomplete

  We gain expressive power at the cost of decidability.
  This is a theme throughout theoretical computer science.
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
  *Takeaways:*
  - Syntax and semantics can be perfectly aligned (completeness)
  - Expressiveness comes at the cost of decidability
  - Formal logic provides foundations for mathematical reasoning and computation
  - Interactive theorem provers make formal logic practically useful
]


= Modal Logic
#focus-slide(
  epigraph: [A truth is necessary when its negation implies a contradiction.],
  epigraph-author: [Gottfried Wilhelm Leibniz],
)

== Beyond Truth: Modes of Truth

#Block(color: teal)[
  In propositional logic, statements are simply _true_ or _false_.

  But when we reason in everyday life, we often care about _how_ something is true:
  - "2 + 2 = 4" is *necessarily* true --- it couldn't be otherwise
  - "It will rain tomorrow" is *possibly* true --- it might happen
  - "John knows the door is locked" involves *knowledge*
  - "Promises ought to be kept" involves *obligation*

  These are different _modes_ of truth, and classical logic can't express them.
]

#Block(color: yellow)[
  *Modal logic* extends classical logic with operators for these _modalities_.
]

== The Modal Operators

#definition[
  _Modal logic_ extends propositional logic with two dual operators:
  - $square phi$ --- "necessarily $phi$" (box)
  - $diamond phi$ --- "possibly $phi$" (diamond)

  These are related by duality:
  $ diamond phi equiv not square not phi $
  $ square phi equiv not diamond not phi $
]

#example[
  - $square (2 + 2 = 4)$ --- "Necessarily, 2 + 2 = 4" (mathematical truth)
  - $diamond ("rain tomorrow")$ --- "It's possible it will rain tomorrow"
  - $square (P imply P)$ --- "Necessarily, if $P$ then $P$" (logical truth)
]

== Modal Syntax

#definition[
  The syntax of basic modal logic extends propositional logic:
  - If $phi$ is a formula, then $square phi$ and $diamond phi$ are formulas
  - All propositional connectives ($not$, $and$, $or$, $imply$, $iff$) apply

  _Precedence:_ $square$ and $diamond$ bind tighter than binary connectives.
]

#example[Formulas in modal logic][
  - $square P imply P$ --- "If necessarily $P$, then $P$"
  - $square (P imply Q) imply (square P imply square Q)$ --- Distribution axiom (K)
  - $square P imply square square P$ --- Positive introspection (4)
  - $P imply square diamond P$ --- Brouwer axiom (B)
]

== Kripke Semantics: The Key Idea

#Block(color: blue)[
  *Classical semantics* assigns truth values to propositions.

  *Kripke semantics* (1959, 1963) adds _structure_:
  - Multiple "possible worlds"
  - An _accessibility relation_ between worlds
  - Truth is evaluated _at a world_
]

#definition[
  A _Kripke frame_ is a pair $cal(F) = pair(W, R)$ where:
  - $W$ is a non-empty set of _possible worlds_
  - $R subset.eq W times W$ is the _accessibility relation_

  We write $w R v$ to mean "world $v$ is accessible from world $w$."
]

== Kripke Models

#definition[
  A _Kripke model_ is a triple $cal(M) = (W, R, V)$ where:
  - $pair(W, R)$ is a Kripke frame
  - $V : "Prop" to cal(P)(W)$ is a _valuation_ function assigning to each proposition the set of worlds where it is true
]

#definition[
  _Truth at a world_ $w$, written $cal(M), w models phi$, is defined:
  - $cal(M), w models P$ iff $w in V(P)$ #h(2em) (for atomic $P$)
  - $cal(M), w models not phi$ iff $cal(M), w models.not phi$
  - $cal(M), w models phi and psi$ iff $cal(M), w models phi$ and $cal(M), w models psi$
  - $cal(M), w models square phi$ iff *for all* $v$ with $w R v$: $cal(M), v models phi$
  - $cal(M), w models diamond phi$ iff *there exists* $v$ with $w R v$: $cal(M), v models phi$
]

== Understanding the Semantics

#Block(color: yellow)[
  *Intuition for $square$ and $diamond$:*

  - $square phi$ is true at $w$ if $phi$ is true in _all_ worlds accessible from $w$
  - $diamond phi$ is true at $w$ if $phi$ is true in _some_ world accessible from $w$

  The accessibility relation $R$ determines "what counts as possible" from each world.
]

#align(center)[
  #cetz.canvas({
    import cetz: draw

    // Worlds
    draw.circle((0, 0), radius: 0.4, fill: blue.lighten(70%), stroke: 1pt, name: "w")
    draw.content("w", $w$)

    draw.circle((2.5, 1), radius: 0.4, fill: green.lighten(70%), stroke: 1pt, name: "v1")
    draw.content("v1", $v_1$)

    draw.circle((2.5, -1), radius: 0.4, fill: green.lighten(70%), stroke: 1pt, name: "v2")
    draw.content("v2", $v_2$)

    draw.circle((5, 0), radius: 0.4, fill: orange.lighten(70%), stroke: 1pt, name: "u")
    draw.content("u", $u$)

    // Arrows
    draw.line("w", "v1", mark: (end: "stealth", fill: black))
    draw.line("w", "v2", mark: (end: "stealth", fill: black))
    draw.line("v1", "u", mark: (end: "stealth", fill: black))

    // Labels
    draw.content((1.2, 1.3), text(size: 0.8em)[accessible])
    draw.content((3.8, 0.8), text(size: 0.8em)[accessible])
  })
]

#Block(color: green)[
  At $w$: $square P$ means "$P$ holds at both $v_1$ and $v_2$"

  At $w$: $diamond P$ means "$P$ holds at $v_1$ or $v_2$ (or both)"
]

== Example: A Simple Kripke Model

#example[
  Consider a model with worlds $W = {w_1, w_2, w_3}$:
  - $R = {(w_1, w_2), (w_1, w_3), (w_2, w_3)}$
  - $V(P) = {w_2, w_3}$ (P is true at $w_2$ and $w_3$)
  - $V(Q) = {w_1, w_2}$ (Q is true at $w_1$ and $w_2$)

  *Evaluate at $w_1$:*
  - $cal(M), w_1 models P$? No, $w_1 in.not V(P)$
  - $cal(M), w_1 models square P$? Yes! From $w_1$, we access $w_2$ and $w_3$, both in $V(P)$
  - $cal(M), w_1 models diamond Q$? Yes! $w_2$ is accessible and $w_2 in V(Q)$
]

#Block(color: orange)[
  *Key observation:* $P$ is _false_ at $w_1$, but $square P$ is _true_ at $w_1$!

  "Necessarily $P$" doesn't require $P$ to hold at the current world --- only at all accessible worlds.
]

== Modal Axiom Systems

#Block(color: blue)[
  Different axiom systems capture different interpretations of necessity.

  The base system *K* (after Kripke) contains:
  - All propositional tautologies
  - *K axiom:* $square (phi imply psi) imply (square phi imply square psi)$
  - *Necessitation rule:* If $proves phi$, then $proves square phi$
]

#definition[
  Common additional axioms and their frame conditions:
  #table(
    columns: 3,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Axiom*], [*Name*], [*Frame Condition*]),
    [$square phi imply phi$], [T], [Reflexive: $forall w. thick w R w$],
    [$square phi imply square square phi$], [4], [Transitive: $w R v and v R u imply w R u$],
    [$phi imply square diamond phi$], [B], [Symmetric: $w R v imply v R w$],
    [$diamond phi imply square diamond phi$], [5], [Euclidean: $w R v and w R u imply v R u$],
  )
]

== Important Modal Systems

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *System K:*
    - Base modal logic
    - No conditions on $R$
    - Weakest normal modal logic

    *System T (= K + T):*
    - Adds $square phi imply phi$
    - Reflexive frames
    - "What is necessary is actual"
  ],
  [
    *System S4 (= T + 4):*
    - Adds transitivity
    - Reflexive + transitive = preorder
    - Common for knowledge logic

    *System S5 (= S4 + B = S4 + 5):*
    - Full equivalence relation
    - "All worlds see all worlds"
    - Strongest normal system
  ],
)

#Block(color: yellow)[
  *S5* captures the idea that possibility and necessity are "absolute" --- if something is possible, it's necessarily possible.
]

== Applications of Modal Logic

#grid(
  columns: 2,
  column-gutter: 1em,
  Block(color: blue)[
    *Epistemic Logic:*

    $square_a phi$ = "Agent $a$ knows $phi$"

    - $square_a phi imply phi$ (knowledge is true)
    - $square_a phi imply square_a square_a phi$ (positive introspection)

    Used in: AI, game theory, security protocols
  ],
  Block(color: green)[
    *Deontic Logic:*

    $square phi$ = "It ought to be that $phi$"

    - Models obligations, permissions
    - $square phi imply diamond phi$ (ought implies can)

    Used in: Legal AI, normative systems
  ],
)

#Block(color: orange)[
  *Temporal Logic:*

  - $square phi$ = "$phi$ holds at all future times"
  - $diamond phi$ = "$phi$ holds at some future time"
  - $circle.small phi$ = "$phi$ holds at the next time step"
  - $phi thin cal(U) thin psi$ = "$phi$ holds until $psi$"

  Used in: Verification of reactive systems (LTL, CTL)
]

== Modal Logic in Computer Science

#example[Verifying a Mutex Property][
  Consider two processes $P_1$ and $P_2$ competing for a critical section.

  Let $"crit"_i$ = "process $i$ is in critical section"

  *Mutual exclusion:* $square not ("crit"_1 and "crit"_2)$

  "At all reachable states, both processes are never in the critical section simultaneously."
]

#Block(color: yellow)[
  *Model checking* is the algorithmic verification of modal/temporal formulas over finite-state systems.

  Tools like SPIN, NuSMV, and Alloy use these logics for specification --- and many rely on SAT solvers internally!
]


= Proofs as Programs
#focus-slide(
  epigraph: [The formulas-as-types notion is not just an analogy \
    --- it is an isomorphism.],
  epigraph-author: [William Howard],
)

== The Curry--Howard Correspondence

#Block(color: teal)[
  *A deep discovery:* Proofs and programs are the _same thing_ viewed differently!

  - *Logic:* propositions, proofs, inference rules
  - *Computation:* types, programs, evaluation rules

  This is the _Curry--Howard correspondence_ --- also known as "propositions as types."
]

#Block(color: yellow)[
  *Historical milestones:*
  - 1934: Curry notices connection between combinatory logic and types
  - 1969: Howard formalizes the correspondence for intuitionistic logic
  - 1980s--now: Foundation of modern type theory and proof assistants (Coq, Lean, Agda)
]

== The Dictionary

#definition[
  The Curry--Howard correspondence establishes:

  #table(
    columns: 2,
    align: (center, center),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Logic*], [*Computation*]),
    [Proposition $phi$], [Type $tau$],
    [Proof of $phi$], [Program of type $tau$],
    [Proposition $phi$ is provable], [Type $tau$ is inhabited],
    [$phi and psi$], [Product type $tau times sigma$],
    [$phi or psi$], [Sum type $tau + sigma$],
    [$phi imply psi$], [Function type $tau arrow.r sigma$],
    [$bot$ (falsehood)], [Empty type (no elements)],
    [$top$ (truth)], [Unit type (one element)],
  )
]

== Implication as Function Type

#Block(color: green)[
  The heart of the correspondence:

  A proof of $phi imply psi$ is a _method_ that transforms any proof of $phi$ into a proof of $psi$.

  A function of type $A arrow.r B$ is a _program_ that transforms any value of type $A$ into a value of type $B$.

  These are the same concept viewed from different angles!
]

#example[
  The identity proof $proves P imply P$:
  #grid(
    columns: 2,
    column-gutter: 2em,
    [
      *Proof:*
      + Assume $P$ #h(1em) _(hypothesis)_
      + We have $P$ #h(1em) _(from 1)_
      + Therefore $P imply P$ #h(0.5em) _($imply$I)_
    ],
    [
      *Program:*
      ```python
      def identity(x: A) -> A:
          return x
      ```
      Type: $A arrow.r A$
    ],
  )
]

== Conjunction as Product Type

#example[Conjunction and Pairs][
  Proof of $P and Q imply Q and P$:
  #grid(
    columns: 2,
    column-gutter: 2em,
    [
      *Proof:*
      + Assume $P and Q$
      + $P$ by $and$E from 1
      + $Q$ by $and$E from 1
      + $Q and P$ by $and$I from 3, 2
    ],
    [
      *Program:*
      ```python
      def swap(pair: (A, B)) -> (B, A):
          (a, b) = pair
          return (b, a)
      ```
      Type: $(A times B) arrow.r (B times A)$
    ],
  )
]

#Block(color: yellow)[
  - $and$-Introduction = constructing a pair
  - $and$-Elimination = projecting from a pair
]

== Disjunction as Sum Type

#example[Disjunction and Tagged Unions][
  Proof of $(P imply R) imply (Q imply R) imply (P or Q imply R)$:
  #grid(
    columns: 2,
    column-gutter: 1em,
    [
      *Proof structure:*

      Given a proof of $P imply R$ and a proof of $Q imply R$, and given $P or Q$, do case analysis: if~$P$, use first; if~$Q$, use second.
    ],
    [
      *Program:*
      ```python
      def handle(f: A -> C,
                 g: B -> C,
                 x: A | B) -> C:
          match x:
              case Left(a): return f(a)
              case Right(b): return g(b)
      ```
    ],
  )
]

== Negation and Empty Types

#Block(color: orange)[
  *Negation* $not phi$ is defined as $phi imply bot$.

  Computationally: a function that takes a value of type $phi$ and produces a value of the empty type (which is impossible --- the function can never return!).
]

#example[
  A proof of $not (P and not P)$ corresponds to:
  ```python
  def no_contradiction(x: (A, A -> Empty)) -> Empty:
      (a, not_a) = x
      return not_a(a)  # Calls a function that "never returns"
  ```
]

#Block(color: purple)[
  *Ex falso quodlibet* ($bot imply phi$) corresponds to a function from the empty type to any type --- which trivially exists because it's never called!
]

== Classical vs. Intuitionistic Logic

#Block(color: blue)[
  The Curry--Howard correspondence works best with *intuitionistic logic*.

  In intuitionistic logic:
  - $not not phi imply phi$ is _not_ provable
  - $phi or not phi$ (excluded middle) is _not_ provable
  - Every proof is _constructive_ --- it provides a witness
]

#example[Why excluded middle is non-constructive][
  Consider $P or not P$. In intuitionistic logic, to prove a disjunction we must prove one of the disjuncts.

  But $P or not P$ claims this _without specifying which_! It's not a program that computes anything --- it's just an assertion.
]

#Block(color: yellow)[
  *Classical proofs* (using RAA or LEM) correspond to programs with _control operators_ like `call/cc` (call-with-current-continuation) or exceptions.
  The continuation captures "what happens next" --- exactly like assuming a negation in RAA!
]

== Proof Assistants and Type Theory

#Block(color: green)[
  Modern proof assistants implement the Curry--Howard correspondence:
  - Proofs are programs
  - Type checking = proof verification
  - Programming = proving theorems
]

#example[Lean 4 Syntax][
  ```lean
  -- Proposition (type)
  theorem and_comm : P ∧ Q → Q ∧ P := by
    intro ⟨hp, hq⟩  -- assume P ∧ Q, destruct
    exact ⟨hq, hp⟩  -- construct Q ∧ P

  -- Same as:
  def and_comm' : P ∧ Q → Q ∧ P :=
    fun ⟨hp, hq⟩ => ⟨hq, hp⟩
  ```
]

== The Deep Correspondence

#Block(color: purple)[
  *The Curry--Howard--Lambek correspondence* extends to:

  #table(
    columns: 3,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Logic*], [*Type Theory*], [*Category Theory*]),
    [Propositions], [Types], [Objects],
    [Proofs], [Terms], [Morphisms],
    [Implication], [Function space], [Exponential],
    [Conjunction], [Product], [Product],
    [Disjunction], [Coproduct], [Coproduct],
    [True], [Unit], [Terminal object],
    [False], [Empty], [Initial object],
  )
]

#Block(color: teal)[
  This three-way correspondence --- logic, computation, algebra --- is a deep unification at the heart of theoretical computer science.
]

== Why Curry--Howard Matters

#Block(color: blue)[
  *Practical applications:*

  + *Verified software:* Programs proven correct _by construction_
  + *Proof automation:* Programming techniques applied to theorem proving
  + *Proof extraction:* Compile proofs into executable code
  + *Dependent types:* Types that depend on values, enabling rich specifications
]

#example[
  A function with type $"List"(A) arrow.r "NonEmpty"("List"(A)) + "Unit"$

  The _type_ guarantees: "Returns either a non-empty list or indicates the input was empty."

  No runtime checks needed --- it's enforced by the type system!
]


== Looking Forward

#Block(color: teal)[
  We've traveled from truth tables to type theory, covering a lot of ground:

  - *Propositional logic* gave us the basics: connectives, truth tables, proofs
  - *Soundness and completeness* showed that semantic and syntactic truth coincide
  - *First-order logic* let us reason about objects and their properties
  - *Modal logic* added necessity, possibility, and beyond
  - *Curry--Howard* revealed that proofs and programs are two views of the same thing

  This is just the beginning --- logic connects to almost every area of computer science and mathematics.
]

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    *Topics to explore:*
    - Temporal logic (LTL, CTL)
    - Intuitionistic logic
    - Linear logic
    - Description logics (OWL)
  ],
  [
    *Connections:*
    - Computability theory
    - Category theory
    - Model theory
    - Philosophical logic
  ],
)

// == Bibliography
// #bibliography("refs.yml")

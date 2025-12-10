#import "common.typ": *
#show: template

#set page(
  paper: "a4",
  margin: (top: 3cm, rest: 2cm),
  header: [
    #set text(10pt)
    #smallcaps[*Homework Assignment \#4*]
    #h(1fr)
    #link("https://github.com/Lipen/discrete-math-course")[*Discrete Mathematics*]
    \
    *Formal Logic*
    #h(1fr)
    *$#emoji.leaf.maple$Fall 2025*
    #place(bottom, dy: 0.4em)[
      #line(length: 100%, stroke: 0.6pt)
    ]
  ],
)

#set text(12pt)
#set par(justify: true)

#show table.cell.where(y: 0): strong

#show heading.where(level: 2): set block(below: 1em, above: 1.4em)

#show emph: set text(fill: blue.darken(20%))

// Custom operators and notation
#let proves = entails

// Color helpers
#let Green(x) = text(green.darken(20%), x)
#let Red(x) = text(red.darken(20%), x)
#let Blue(x) = text(blue.darken(20%), x)
#let Orange(x) = text(orange.darken(20%), x)

#let True = Green(`true`)
#let False = Red(`false`)

#let YES = Green(sym.checkmark)
#let NO = Red(sym.crossmark)

// Task list helper
#let tasklist(id, cols: 1, body) = {
  let s = counter(id)
  s.update(1)
  set enum(numbering: _ => context {
    s.step()
    s.display("1.")
  })
  columns(cols, gutter: 1em)[#body]
}

// Fancy box
#let Box(body, align: left, inset: 0.8em) = std.align(align)[
  #box(
    stroke: 0.4pt + gray,
    inset: inset,
    radius: 3pt,
  )[
    #set std.align(left)
    #set text(size: 10pt, style: "italic")
    #body
  ]
]

// Fancy block
#let Block(body, ..args) = {
  block(
    body,
    inset: (x: 1em),
    stroke: (left: 3pt + gray),
    outset: (y: 3pt, left: -3pt),
    ..args,
  )
}


#Box(align: right)[
  #set text(fill: blue.darken(20%))
  "The universe is not only queerer than we suppose, but queerer than we *can* suppose."

  #align(right)[
    --- J.B.S. Haldane
  ]
]

#Block[
  The cosmos, as Stanisław Lem's heroes have discovered, is full of logical puzzles.

  In this assignment, you encounter problems that arise from their adventures: logical contradictions that plague Captain Pirx, truth-telling paradoxes that confound Ijon Tichy, and formal conundrums that perplex even the ingenious constructors Trurl and Klapaucius.
]

= Chapter I: Propositional Foundations

#Box[
  Logic is the art of going wrong with confidence.
]

== Problem 1: The Council of Contradictory Decrees

Captain Pirx is dispatched to Enteropia, where the High Council governs through bureaucratic proclamations that must remain logically consistent --- lest reality itself unravel.
The Council needs Pirx to verify four batches of decrees before they become law.

For each set, determine whether the decrees are *jointly satisfiable*.
If consistent, provide a satisfying truth assignment; if not, identify the contradiction.

#tasklist("prob1", cols: 2)[
  + ${ not D, (D or F), not F }$

  + ${ (T imply K), not K, (K or not T) }$

  #colbreak()

  + ${ not(A imply (not C imply B)), ((B or C) and A) }$

  + ${ (C imply B), (D or C), not B, (D imply B) }$
]


== Problem 2: Diplomatic Dispatches in Alliterative Cipher

Pirx's next stop is Fomalhaut Station, where intercepted transmissions arrive encrypted in *Alliterative Cipher* --- a technique encoding logical relationships beneath elaborate linguistic symmetry.

For each dispatch: symbolize the argument, determine validity via truth table, and provide either a Fitch-style derivation (if valid) or a counterexample valuation (if invalid).

#tasklist("prob2")[
  + If philosophers ponder profound problems, their quandaries quell quotidian quibbles.
    Either their quandaries don't quell quotidian quibbles or right reasoning reveals reality.
    Philosophers do ponder profound problems.
    _Therefore_, right reasoning reveals reality.

  + If aardvarks are adorable, then either baby baboons don't beat bongos or crocodiles can't consume cute capybaras.
    Baby baboons beat bongos.
    Aardvarks aren't adorable unless crocodiles can't consume cute capybaras.
    _Therefore_, aardvarks aren't adorable.

  + If discipline doesn't defeat deficiency, then geniuses generally get good grades.
    If discipline defeats deficiency, then homework has harmed humanity.
    _Therefore_, geniuses generally get good grades unless homework has harmed humanity.

  + Crocodiles can consume cute capybaras only if incarcerating iguanas isn't illegal.
    Mad monkeys make mayhem and dinosaurs do disco dance, unless crocodiles consume cute capybaras.
    Incarcerating iguanas is illegal.
    _Therefore_, dinosaurs do disco dance if and only if mad monkeys make mayhem.
]


== Problem 3: The Emporium of Synthetic Companions

At Orbital Station Cygnus-7, Ijon Tichy visits the *Emporium of Synthetic Companions*, where the proprietor Minik enforces strict regulations on robotic pet purchases:

#Block[
  *Regulation 1:* If you purchase exactly one of the Giraffoid or Elephandroid, you must also purchase a Simianoid. (Solitary mega-fauna develop existential melancholy.)

  *Regulation 2:* Neither the Elephandroid nor the Simianoid may be purchased unless the Giraffoid is also purchased. (The Giraffoid serves as social anchor.)
]

A customer named Mestorf announces: "We'll take all three."

Minik replies: "Excellent. Then we shall certainly sell you either the Elephandroid or the Giraffoid."

*Question:* How many companions were actually purchased?


== Problem 4: Voting Protocol

Ijon Tichy mediates a constitutional crisis on the *Galactic Council*.
Five member worlds --- Alderan, Betelgeuse, Centauri, Deneb, and Eridani --- must adopt a new voting protocol.
Their automated legal verification system uses symbolic constraint solving: all political rules must be expressed in CNF (conjunctive normal form) so the system can check whether any legal configuration is possible.

Let $A$, $B$, $C$, $D$, $E$ denote "member world voted yes."

+ *Majority support:*
  The Council's charter requires majority support: encode "at least 3 of 5 voted yes" in CNF.
  Count the resulting clauses.

+ *Opposition safeguard:*
  To prevent tyranny by dissenters, the Council imposes a stricter constraint: no *single world* may block a proposal.
  Formalize and encode "at most 1 world votes no" in CNF.
  Count the resulting clauses.

+ *Alderan's privilege:*
  Alderan (the elder civilization) enjoys special status: a proposal passes if either (at least 3 worlds approve) OR (Alderan approves alone, with or without support).
  Formalize this rule and convert to CNF.

+ *Efficient cardinality encoding:*
  The verification system struggles with the growing number of clauses from the encodings above.
  Generalize: design a compact encoding for "at least $k$ of $n$ variables are true, and at most $m$ are true" (where $k <= m$) using auxiliary variables. \
  For the Council case ($n=5, k=3, m=4$), count your encoding's clauses versus naive CNF.
  What architectural trade-off emerges between encoding size and solver efficiency?


#pagebreak()

= Chapter II: Truth-Tellers and Liars

#Box[
  A liar who claims to lie speaks truth --- and therein lies the trap.
]

== Problem 5: The Quantum Cheat-Leaf Affair

A *Quantum Cheat-Leaf* is discovered near the exam hall at the Interstellar Navigation Academy.
Tichy must identify the cheater by logical deduction alone: the Academy forbids punishment without proof, yet allowing cheaters to graduate is equally fatal.

Three cadets were interrogated:

#Block[
  *Ivanko:* "I didn't use it. Sidorik used it. Petryn used it too."

  *Petryn:* "Ivanko used it. I didn't use it. About Sidorik, I cannot say."

  *Sidorik:* Remains silent.
]

Later, the cadets confess privately: "One of us told the complete truth. One made exactly one true statement. One lied in every statement."
They refused to reveal who was who.

+ Formalize each cadet's statements in propositional logic.
+ Can you identify who used Cheat-Leaf?
+ Which cadet told the complete truth?


== Problem 6: The Contradictory Cosmonauts

The *Asymptote* suffered a catastrophic reactor failure.
Three crew members --- Knyazev (engineer), Faraonov (chief technician), and Tsaryov (safety officer) --- were on duty.
Tichy interrogates them to reconstruct the events leading to the disaster.

#Block[
  - *Knyazev* gives an initial testimony $K$ (content unknown)
  - *Faraonov* responds: "Knyazev's testimony is false."
  - *Tsaryov* adds: "Faraonov is lying."
  - *Knyazev* (called again) asserts: "Both Faraonov and Tsaryov lied."
]

_Note:_ Treat $K$ as an atomic propositional variable whose truth value is unspecified.

+ Formalize all four statements as propositional formulas.
+ Find _all_ consistent truth assignments (valuations) for the four claims.
+ Identify which statements are _logically forced_ (must have a fixed truth value in every consistent assignment), and which remain _undetermined_.


== Problem 7: The Council Chamber Paradox

Tichy arrives on Barbaria, a planet where inhabitants are born into two castes: *Knights* (who always speak truth) and *Knaves* (who always lie).
In a high council chamber, where delegates debate critical trade agreements, one member rises and declares: _"Everyone else in this chamber is a knave!"_
Immediately, each other person repeats the same: "Everyone else in this chamber is a knave."

Tichy is genuinely puzzled: *How many knights are in the chamber?*


== Problem 8: Arkonada and the Solaric Vaults

Dr. Arkonada discovers three vaults in the Solaric Archives: Gold, Silver, and Lead.
One contains the legendary *Crystallized Theorem*, the others are empty.
Each vault bears an inscription:
#Block[
  *Gold vault*: "The Theorem is not here."

  *Silver vault*: "The Theorem is in the Gold vault."

  *Lead vault*: "The Theorem is here."
]

Ancient texts warn: "You cannot trust all the inscriptions, nor can you dismiss them entirely."

+ *Loose interpretation:*
  The Solarians were pragmatic.
  They required that at least one inscription be truthful and at least one be false.
  Under this constraint, determine which vault(s) could contain the Theorem, and prove your answer.

+ *Classical interpretation:*
  The ancients were more precise.
  They decreed that exactly one inscription must be true.
  Under this constraint, determine which vault must contain the Theorem, and prove your answer.


== Problem 9: The Logician's Vault --- Lady or Tiger?

Ijon Tichy has infiltrated the *Logician's Vault*, an automated security complex guarding three sequential chambers.
To escape, he must pass each trial by deducing what lies behind sealed doors.
Behind any door waits either a lady or a tiger.
Each door bears an inscription --- a logical statement claiming facts about the contents of both doors.
The vault announces a constraint specifying the relationship between the truth values of these two inscriptions.

For each chamber, Tichy must: translate the inscriptions into propositional logic, apply the constraint, and determine definitively what lies behind each door.

=== Chamber 1: The Disjunction

#Block[
  _Constraint:_ Exactly one inscription is true, and exactly one is false.

  *Door A:* "In this room there is a lady, and in the other room there is a tiger."

  *Door B:* "In one of these rooms there is a lady, and in one of these rooms there is a tiger."
]

=== Chamber 2: The Conjunction

#Block[
  _Constraint:_ Both inscriptions have the same truth value (either both true or both false).

  *Door A:* "At least one of these rooms contains a lady."

  *Door B:* "A tiger is behind the other room."
]

=== Chamber 3: The Implication

#Block[
  _Constraint:_ Both inscriptions have the same truth value (either both true or both false).

  *Door A:* "If there is no tiger in this room, then there is a lady in the other room."

  *Door B:* "A lady is in the other room."
]


#pagebreak()

= Chapter III: Proof Theory

#Box[
  A proof is a path; elegance lies in taking the shortest one.
]

== Problem 10: The Clause Factory on Titan

At Titan's *Clause Factory*, a massive automated production facility manufactures logical proofs by resolution.
The factory's quality control system has flagged a batch of clauses as "suspicious" --- the engineers suspect the batch may be *unsatisfiable*.

$
  { thin P or Q, quad not P or R, quad not Q or S, quad not R, quad not S thin }
$

+ Apply the resolution rule iteratively and derive the empty clause $square$.
+ Present your derivation as a proof tree.
+ Explain why deriving the empty clause confirms unsatisfiability.


== Problem 11: The Proof Certification Academy

At the *Proof Certification Academy*, every star-navigator must master Fitch-style natural deduction before being licensed to validate ship systems.
"A navigator who cannot prove," the instructors intone, "cannot navigate."
Prove each tautology below using natural deduction.

+ $(A imply B) or (B imply A)$
+ $A imply (B imply A)$
+ $(not B imply not A) imply ((not B imply A) imply B)$
+ $(A imply (B imply C)) imply ((A imply B) imply (A imply C))$


== Problem 12: Restoring the Corrupted Proof Archive

A cosmic ray has struck the *Galactic Archive's* proof repository, corrupting several derivations mid-flight.
The archivists have recovered partial proofs with gaps marked by $square$ boxes.
Fill in the missing formulae and justifications to restore each proof to its former glory.

#let BOX = {
  move(dy: 2pt, box(stroke: 1pt, width: 2em, height: 1em))
}
#let BOXM = {
  move(dy: 0pt, box(stroke: 1pt, width: 2em, height: 1em))
}

#grid(
  columns: 2,
  column-gutter: 3cm,
  [
    // #derive-it.ded-nat(stcolor: black, arr: (
    //   (0, $H imply (R and C)$, "Premise"),
    //   (0, $not R or not C$, "Premise"),
    //   (0, $not(R and C)$, BOX),
    //   (0, $BOXM$, "MT 1, 3"),
    // ))
    #grid(
      columns: 3,
      align: left,
      stroke: (x, y) => if x == 0 { (right: 0.8pt) },
      inset: 5pt,
      [1.], [$H imply (R and C)$], [Premise],
      grid.hline(stroke: .8pt, start: 1),
      [2.], [$not R or not C$], [Premise],
      [3.], [$not (R and C)$], [#BOXM],
      [4.], [#BOXM], [MT 1, 3],
    )

    // #derive-it.ded-nat(stcolor: black, arr: (
    //   (0, $K and S$, "Premise"),
    //   (0, $not K$, "Premise"),
    //   (0, $BOXM$, BOX),
    //   (0, $BOXM$, BOX),
    //   (0, $not S$, BOX),
    // ))
    #grid(
      columns: 3,
      align: left,
      stroke: (x, y) => if x == 0 { (right: 0.8pt) },
      inset: 5pt,
      [1.], [$K and S$], [Premise],
      grid.hline(stroke: .8pt, start: 1),
      [2.], [$not K$], [Premise],
      [3.], [#BOXM], [#BOXM],
      [4.], [#BOXM], [#BOXM],
      [5.], [$not S$], [#BOXM],
    )
  ],
  [
    // #derive-it.ded-nat(stcolor: black, arr: (
    //   (0, $A imply not A$, "Premise"),
    //   (0, $BOXM$, "(multiple lines)"),
    //   (0, $not A$, [LEM $BOXM$]),
    // ))
    #grid(
      columns: 3,
      align: left,
      stroke: (x, y) => if x == 0 { (right: 0.8pt) },
      inset: 5pt,
      [1.], [$A imply not A$], [Premise],
      grid.hline(stroke: .8pt, start: 1),
      [2.], [#BOXM], [(multiple lines)],
      [3.], [$not A$], [LEM $#BOXM$],
    )

    // #derive-it.ded-nat(stcolor: black, arr: (
    //   (0, $(P and Q) or (P and R)$, "Premise"),
    //   (1, $BOXM$, "Assume"),
    //   (1, $P$, BOX),
    //   (0, $...$, text(gray)[empty line]), // TODO: remove this empty line, but keep the assumption scopes separated
    //   (1, $BOXM$, "Assume"),
    //   (1, $P$, BOX),
    //   (0, $P$, BOX),
    // ))
    #grid(
      columns: 3,
      align: left,
      stroke: (x, y) => if x == 0 { (right: 0.8pt) },
      inset: 5pt,
      [1.], [$(P and Q) or (P and R)$], [Premise],
      grid.hline(stroke: .8pt, start: 1),
      [2.], grid.cell(rowspan: 2, inset: (left: 1em, rest: 0pt))[
        #grid(
          inset: 4pt,
          stroke: (left: 1pt),
          [#BOXM],
          grid.hline(stroke: .8pt),
          $P$,
        )
      ], [Assume],
      [3.], /**/ [#BOXM],
      [4.], grid.cell(rowspan: 2, inset: (left: 1em, rest: 0pt))[
        #grid(
          inset: 4pt,
          stroke: (left: 1pt),
          [#BOXM],
          grid.hline(stroke: .8pt),
          $P$,
        )
      ], [Assume],
      [5.], /**/ [#BOXM],
      [6.], [$P$], [#BOXM],
    )
  ],
)


= Chapter IV: First-Order Logic

#Box[
  Quantifiers are how machines learn to speak of infinity.
]

== Problem 13: Cataloging the Galactic Software Archive

Trurl and Klapaucius build a cataloging system for the Galactic Archives.
They define predicates over the domain of _all software_: $O(x)$ means "$x$ is open-source", $B(x)$ means "$x$ is buggy", and $U(x,y)$ means "$x$ uses $y$."

Translate into first-order logic:
+ "Some open-source software is not buggy."
+ "All buggy software uses some open-source software."
+ "There exists a piece of software that uses all open-source software."

For each formula, construct a small finite model satisfying it.


== Problem 14: The Theorem-Printer's Corruption

A power surge corrupts the *Theorem-Printer* aboard the *Asymptote*.
Before failure, it logged this formula as a fundamental truth:
$
  forall x exists y . thin (P(x) imply Q(x,y))
$

=== Part 1: Negation and Prenex Form

To reconstruct the machine's reasoning system, engineers need to understand what would *refute* this claim.
Compute its *logical negation* in prenex normal form (quantifier prefix first, then quantifier-free matrix).

=== Part 2: Satisfiability Analysis

+ Is the original formula satisfiable?
  Provide a model, or argue why none exists.
+ Is its negation satisfiable?
  Provide a model, or argue why none exists.
+ What does this tell you about the relationship between the two formulas?


== Problem 15: Challenging the Theorem-Printer

Once restored, the Theorem-Printer outputs an entailment:
$
  forall x . thin (P(x) or Q(x))
  quad proves quad
  (forall x . thin P(x)) or (forall x . thin Q(x))
$

Klapaucius is skeptical: "Universal quantification distributes over disjunction?"

Determine whether this entailment is valid.
- If valid, provide a formal proof.
- If invalid, construct a countermodel: domain $D$ and interpretations of $P$, $Q$ where the premise holds but conclusion fails.


#pagebreak()

== Problem 16: The Census of Echoworld

Tichy arrives at Echoworld, a planet of perfect symmetry where every fact about visitation is precisely documented.
A vast archive records which travelers have visited which worlds.
Tichy must decode the archive's formal notation.

Predicates over the domain "all planets and travelers":
#Block[
  - $P(x)$: "$x$ is a planet"
  - $I(x)$: "$x$ is inhabited"
  - $V(x, y)$: "$x$ has visited $y$"
  - $W(x)$: "$x$ is worth visiting"
  - Constant $t$: Tichy
]

=== Part 1: Encoding wisdom

Translate each English statement into FOL.

+ "Tichy has visited every inhabited planet."
+ "Some planet has never been visited by anyone."
+ "Every planet that Tichy visited is inhabited."
+ "There exists a planet that all travelers have visited."
+ "No single traveler has visited all planets."

=== Part 2: The Ambiguous Decree

The archive contains two interpretations of "Only inhabited planets are worth visiting."

The Archive Keeper and her assistant disagree on which is correct:
#Block[
  *Keeper:* $forall x . thin (I(x) imply W(x))$

  *Assistant:* $forall x . thin (W(x) imply I(x))$
]

Determine which translation captures the intended meaning.
Then construct a concrete countermodel (specific planets with specific properties) that shows the other translation is wrong.
Explain why the difference matters in practice.

=== Part 3: The Mystery of Quantifier Scope

Two ancient inscriptions appear in the archive, each describing a different visitation pattern.
Translate them to English, paying close attention to how quantifier order changes the meaning:
#Block[
  *Inscription A:* $exists x forall y . thin V(y, x)$

  *Inscription B:* $forall x exists y . thin V(y, x)$
]

Which inscription describes a planet so famous that *all* travelers have visited it?
Which describes a weaker property: that every traveler has visited *at least one* planet?
Prove that one logically implies the other, but not vice versa.

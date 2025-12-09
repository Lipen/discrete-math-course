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


#Box(align: right)[
  #set text(fill: blue.darken(20%))
  "The universe is not only queerer than we suppose, but queerer than we *can* suppose."

  #align(right)[
    --- J.B.S. Haldane
  ]
]

The cosmos, as Stanisław Lem's heroes have discovered, is full of logical puzzles.
In this assignment, you encounter problems that arise from their adventures: logical contradictions that plague Captain Pirx, truth-telling paradoxes that confound Ijon Tichy, and formal reasoning challenges that challenge even the ingenious constructors Trurl and Klapaucius.

= Part I: Propositional Foundations

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

Pirx's next stop is Fomalhaut Station, where intercepted transmissions arrive encrypted in *Alliterative Cipher* --- a Byzantine technique encoding logical relationships beneath elaborate linguistic symmetry.

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

#block(
  inset: (x: 1em),
  stroke: (left: 3pt + gray),
  outset: (y: 3pt, left: -3pt),
)[
  *Regulation 1:* If you purchase exactly one of the Giraffoid or Elephandroid, you must also purchase a Simianoid. (Solitary mega-fauna develop existential melancholy.)

  *Regulation 2:* Neither the Elephandroid nor the Simianoid may be purchased unless the Giraffoid is also purchased. (The Giraffoid serves as social anchor.)
]

A customer named Mestorf announces: "We'll take all three."

Minik replies: "Excellent. Then we shall certainly sell you either the Elephandroid or the Giraffoid."

Let $G$, $E$, $S$ denote purchasing each companion.

+ Formalize the regulations and both declarations.
+ Which purchase combinations are consistent with these constraints?
+ Which propositions are logical consequences of the system?
+ How many companions are actually purchased, and why?


== Problem 4: Voting Protocol

Ijon Tichy mediates a constitutional crisis on the *Galactic Council*.
Five member worlds --- Alderan, Betelgeuse, Centauri, Deneb, and Eridani --- must adopt a new voting protocol.
Their automated legal verification system accepts only CNF formulas for constraint checking.

Let $A$, $B$, $C$, $D$, $E$ denote "member world voted yes."

+ *Majority support:* The Council's charter requires majority support: encode "at least 3 of 5 voted yes" in CNF.
  Count the resulting clauses.

+ *Opposition safeguard:* To prevent tyranny by dissenters, the Council imposes a stricter constraint: no *single world* may block a proposal.
  Formalize and encode "at most 1 world votes no" in CNF.
  Count the resulting clauses.

+ *Alderan's privilege:* Alderan (the elder civilization) enjoys special status: a proposal passes if either (at least 3 worlds approve) OR (Alderan approves alone, with or without support).
  Formalize this rule and convert to CNF.

+ *Efficient cardinality encoding:* The verification system struggles with the growing number of clauses from the encodings above.
  Generalize: design a compact encoding for "at least $k$ of $n$ variables are true, and at most $m$ are true" (where $k <= m$) using auxiliary variables. \
  For the Council case ($n=5, k=3, m=4$), count your encoding's clauses versus naive CNF.
  What architectural trade-off emerges between encoding size and solver efficiency?


#pagebreak()

= Part II: Truth-Tellers and Liars

#Box[
  Identity and consistency are two different constraints.
]

== Problem 5: The Quantum Cheat-Leaf Affair

At the Interstellar Navigation Academy, a scandal erupts: a *Quantum Cheat-Leaf* (a banned mnemonic device) is discovered near the examination hall.
Tichy interrogates three cadets who took the same exam.

*Ivanko:* "I didn't use it. Sidorik used it. Petryn used it too."

*Petryn:* "Ivanko used it. I didn't use it. About Sidorik, I cannot say."

*Sidorik:* Remains silent.

Later, the cadets confess privately: "One of us told the complete truth. One made exactly one true statement. One lied in every statement."

Let $I$, $P$, $S$ denote "Ivanko / Petryn / Sidorik used the Cheat-Leaf."

+ Formalize Ivanko's and Petryn's testimonies.
+ Using the meta-constraint, determine all consistent scenarios.
+ Who used the Cheat-Leaf? Is it certain someone did?
+ Which cadet told the complete truth?


== Problem 6: The Contradictory Cosmonauts

Aboard the research vessel *Asymptote*, Tichy investigates a reactor incident by interviewing three crew members.

- *Knyazev* gives an initial testimony (truth value $K$, unknown).
- *Faraonov* says: "Knyazev's testimony is false."
- *Tsaryov* says: "Faraonov is lying."
- *Knyazev* (recalled) adds: "Both Faraonov and Tsaryov lied."

+ Formalize all four statements.
+ List all consistent truth-value assignments.
+ Which statements are determinately true/false in every assignment? Which depend on $K$?


== Problem 7: The Council Chamber Paradox

Ijon Tichy arrives at an island where inhabitants belong to two castes: *Knights* who always speak truth, and *Knaves* who always lie.
In a council chamber, someone stands up and says: "Everyone else in this chamber is a knave."
Immediately, each other person in the room repeats the exact same statement: "Everyone else in this chamber is a knave."

How many knights are in the chamber?
Can you identify which person (if any) is a knight?


== Problem 8: Arkonada and the Solaric Vaults

Dr. Arkonada discovers three vaults in the Solaric Archives: Gold, Silver, and Lead.
One contains the legendary *Crystallized Theorem*, the others are empty.
Each vault bears an inscription:

- *Gold vault*: "The Theorem is not here."
- *Silver vault*: "The Theorem is in the Gold vault."
- *Lead vault*: "The Theorem is here."

Ancient texts warn: "You cannot trust all the inscriptions, nor can you dismiss them entirely."

+ *Loose interpretation:*
  The Solarians were pragmatic.
  They required that at least one inscription be truthful and at least one be false.
  Under this constraint, determine which vault(s) could contain the Theorem, and prove your answer.

+ *Classical interpretation:*
  The ancients were more precise.
  They decreed that exactly one inscription must be true.
  Under this constraint, determine which vault must contain the Theorem, and prove your answer.


== Problem 9: The Museum of Possible Futures --- Lady or Tiger?

In the Museum of Possible Futures, Tichy faces two sealed chambers.
One contains the *Lady of Lyra* (safe passage); the other, a *Tiger-construct*.

The placard states: *"Exactly one inscription is true."*

- *Chamber I*: "Here is the Lady, and in the other chamber the Tiger."
- *Chamber II*: "Exactly one chamber contains a Lady and the other a Tiger."

Let $L_1$, $L_2$ denote the Lady's presence in each chamber.

+ Formalize both inscriptions.
+ Under the constraint that exactly one is true, which chamber contains the Lady?
+ If Chamber II instead read: "At least one chamber has a Lady and at least one has a Tiger" --- how does the answer change?


== Problem 10: The Three Archived Minds

Tichy arrives at the *Interstellar Bureau of Statistics* on Drabno, where three archivists guard the vault containing all census data.
Three archivists: Arkas, Bronda, and Carpus --- one always tells the truth, one always lies, and one answers randomly.

They respond in an ancient language: *da* and *ja* mean yes and no --- but which is which? Unknown.

Tichy has exactly three yes/no questions (one per archivist) to identify which archivist is which, and to decode the language.
Design your three questions, specify whom you would ask each one, and show (via case analysis or decision tree) that your questions uniquely determine all identities and the meaning of *da* and *ja*.


#pagebreak()

= Part III: First-Order Logic

#Box[
  Quantifiers are how machines learn to speak of infinity.
]


== Problem 11: Cataloging the Galactic Software Archive

Trurl and Klapaucius build a cataloging system for the Galactic Archives.
They define predicates over the domain of _all software_:

#block(
  inset: (x: 1em),
  stroke: (left: 3pt + gray),
  outset: (y: 3pt, left: -3pt),
)[
  - $O(x)$ --- "$x$ is open-source"
  - $B(x)$ --- "$x$ is buggy"
  - $U(x,y)$ --- "$x$ uses $y$"
]

+ Translate into first-order logic:
  - "Some open-source software is not buggy."
  - "All buggy software uses some open-source software."
  - "There exists a piece of software that uses all open-source software."

+ For each formula:
  - Construct a small finite model satisfying it.
  - Which formula(s) require an existential witness that persists when the domain expands?


== Problem 12: The Theorem-Printer's Corruption

A power surge corrupts the *Theorem-Printer* aboard the *Asymptote*.
Before failure, it logged this formula as a fundamental truth:
$
  forall x exists y . thin (P(x) imply Q(x,y))
$

To reconstruct the machine's reasoning system, engineers need to understand what would *refute* this claim --- i.e., compute its *logical negation* in prenex normal form (quantifier prefix first, then quantifier-free matrix).


== Problem 13: Challenging the Theorem-Printer

Once restored, the Theorem-Printer outputs an entailment:
$
  forall x . thin (P(x) or Q(x))
  quad proves quad
  (forall x . thin P(x)) or (forall x . thin Q(x))
$

Klapaucius is skeptical: "Universal quantification distributes over disjunction?"

+ Determine whether this entailment is valid.
+ If invalid, construct a countermodel: domain $D$ and interpretations of $P$, $Q$ where the premise holds but conclusion fails.


#pagebreak()

= Part IV: Proof Theory

#Box[
  A proof is a path; elegance lies in taking the shortest one.
]


== Problem 14: The Clause Factory on Titan

At Titan's *Clause Factory*, a batcher produces a clause-set flagged as "suspicious":
$
  { thin P or Q, quad not P or R, quad not Q or S, quad not R, quad not S thin }
$

Factory engineers fear the batch is defective (unsatisfiable).

- Apply Resolution iteratively to derive the empty clause $square$.
- Document each step: parent clauses → resolvent.
- Why does deriving $square$ prove unsatisfiability?


== Problem 15: Navigator Training --- Natural Deduction

At the *Celestial Navigation Academy*, Klapaucius teaches: "Every star-navigator must master Fitch-style natural deduction."

Prove each tautology:
+ $(A imply B) or (B imply A)$
+ $A imply (B imply A)$
+ $(not B imply not A) imply ((not B imply A) imply B)$
+ $(A imply (B imply C)) imply ((A imply B) imply (A imply C))$

For each proof, provide a Fitch-style derivation, marking all assumptions and rules.


== Problem 16: Restoring the Corrupted Proof Archive

The *Galactic Archive's* proof repository suffered data corruption. Several Fitch-style proofs have gaps marked with $square$ boxes. Fill in the missing formulae and justifications.

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
    #derive-it.ded-nat(stcolor: black, arr: (
      (0, $H imply (R and C)$, "Premise"),
      (0, $not R or not C$, "Premise"),
      (0, $not(R and C)$, BOX),
      (0, $BOXM$, "MT 1, 3"),
    ))

    #derive-it.ded-nat(stcolor: black, arr: (
      (0, $K and S$, "Premise"),
      (0, $not K$, "Premise"),
      (0, $BOXM$, BOX),
      (0, $BOXM$, BOX),
      (0, $not S$, BOX),
    ))
  ],
  [
    #derive-it.ded-nat(stcolor: black, arr: (
      (0, $A imply not A$, "Premise"),
      (0, $BOXM$, "(multiple lines)"),
      (0, $not A$, [LEM $BOXM$]),
    ))

    #derive-it.ded-nat(stcolor: black, arr: (
      (0, $(P and Q) or (P and R)$, "Premise"),
      (1, $BOXM$, "Assume"),
      (1, $P$, BOX),
      (0, $...$, [empty line]), // TODO: remove this empty line, but keep the assumption scopes separated
      (1, $BOXM$, "Assume"),
      (1, $P$, BOX),
      (0, $P$, BOX),
    ))
  ],
)


= Part V: Advanced Challenges

#Box[
  The hardest puzzles reveal the deepest logical truths.
]


== Problem 17: Tri-Constellation Agent Communications

Captain Pirx analyzes communications among four field agents: *Bilion*, *Stevok*, *Tomix*, *Johnon*.
Cryptanalysts reconstructed these constraints:

#block(
  inset: (x: 1em),
  stroke: (left: 3pt + gray),
  outset: (y: 3pt, left: -3pt),
)[
  - If Bilion contacted Stevok, then Tomix did not contact Stevok.
  - Bilion contacted Stevok iff Johnon contacted at least one of them (Bilion or Stevok).
  - If Johnon contacted Stevok, then Bilion did not contact Stevok.
]

Let $C(x,y)$ denote "$x$ contacted $y$" (directional).

+ Formalize all three constraints.
+ Identify a pair who *must* have communicated.
+ Identify a pair who *definitively did not* communicate.
+ Is there an agent who *necessarily* communicated with at least one other?


== Problem 18: Martians and Venusians on the Arithmetic Axis

Astronaut Marek observes a lattice where each point $n >= 1$ houses either a *Martian* ($M_n$) or a *Venusian* ($V_n$), never both.

#block(
  inset: (x: 1em),
  stroke: (left: 3pt + gray),
  outset: (y: 3pt, left: -3pt),
)[
  *Observation 1:* No Martian has both neighbors as Martians. \
  ($forall n >= 2. thin M_n imply not(M_(n-1) and M_(n+1))$)

  *Observation 2:* Every Venusian has at least one Martian neighbor. \
  ($forall n >= 2. thin V_n imply (M_(n-1) or M_(n+1))$)

  *Constraint 3:* If point 3 is Martian, all multiples of 3 are Martian. \
  ($M_3 imply forall k. thin (3 | k imply M_k)$)

  *Constraint 4 (false in this world):* If point 5 is Martian, some multiple of 3 is Martian. \
  ($not(M_5 imply exists k. thin (3 | k and M_k))$)
]

+ What does negating Constraint 4 logically entail?
+ If exactly five Martians exist, determine their positions.
+ Must point 1 be Martian?
+ Formulate a general rule for inhabitant type at point $n$.
+ What global structure emerges from local constraints?


#line(length: 100%, stroke: 0.4pt)

*Submission:* Organize solutions clearly. State assumptions, show steps, mark conclusions.

*Grading:* Correctness 50% · Logical rigor 30% · Completeness 20%

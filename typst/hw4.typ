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
  #box(stroke: 0.4pt + gray, inset: inset, radius: 3pt)[
    #set std.align(left)
    #set text(size: 10pt, style: "italic")
    #body
  ]
]


#Box(align: right, inset: 1em)[
  #set text(fill: blue.darken(20%))
  "The universe is not only queerer than we suppose, but queerer than we *can* suppose."

  #align(right)[
    --- J.B.S. Haldane
  ]
]


= Part I: Propositional Foundations

// #Box[
//   TODO
// ]

== Problem 1: The Council of Contradictory Decrees

On the planet Enteropia, the High Council issues decrees that must be logically consistent --- lest the reality-fabric tear.
Tichy, serving as Logical Auditor, must verify each batch.

For each set of decrees below, determine whether they are *jointly satisfiable* (logically consistent).
If consistent, provide a satisfying assignment; if not, explain the contradiction.

#tasklist("prob1", cols: 1)[
  + $not D$, #h(1em) $(D or F)$, #h(1em) $not F$

  + $(T imply K)$, #h(1em) $not K$, #h(1em) $(K or not T)$

  + $not(A imply (not C imply B))$, #h(1em) $((B or C) and A)$

  + $(C imply B)$, #h(1em) $(D or C)$, #h(1em) $not B$, #h(1em) $(D imply B)$
]


== Problem 2: Diplomatic Dispatches in Alliterative Cipher

Intercepted transmissions from the Fomalhaut Confederation are encoded in _Alliterative Cipher_ --- a format where meaning hides in elaborate wordplay.
Tichy must symbolize each argument, determine validity via truth table, and for valid arguments provide a Fitch proof (for invalid ones, a counterexample valuation).

#tasklist("prob2")[
  + If philosophers ponder profound problems, their quandaries quell quotidian quibbles.
    Either their quandaries don't quell quotidian quibbles or right reasoning reveals reality (or both).
    Philosophers do ponder profound problems.
    _Therefore_, right reasoning reveals reality.

  + If aardvarks are adorable, then either baby baboons don't beat bongos or crocodiles can't consume cute capybaras (or both).
    Baby baboons beat bongos.
    Aardvarks aren't adorable unless crocodiles can't consume cute capybaras.
    _Therefore_, aardvarks aren't adorable.

  + If discipline doesn't defeat deficiency, then geniuses generally get good grades.
    If discipline defeats deficiency, then homework has harmed humanity.
    _Therefore_, geniuses generally get good grades unless homework has harmed humanity.

  + Crocodiles can consume cute capybaras only if incarcerating iguanas isn't illegal.
    Mad monkeys make mayhem and dinosaurs do disco dance, unless crocodiles consume cute capybaras.
    It is known that incarcerating iguanas is illegal.
    _Therefore_, dinosaurs do disco dance if and only if mad monkeys make mayhem.
]


#pagebreak()

== Problem 3: The Emporium of Melancholic Automatons

At Orbital Station Cygnus-7, the *Emporium of Synthetic Companions* sells robotic pets to lonely cosmonauts.
The proprietor, a small automaton named Minik, explains the regulations to Tichy with bureaucratic zeal:

#quote(block: true)[
  "Regulation 1: If you purchase *exactly one* of the Giraffoid or the Elephandroid, you must also purchase a Simianoid.
  Solitary mega-fauna units develop existential melancholy --- they contemplate the void and cease functioning."

  "Regulation 2: Neither the Elephandroid nor the Simianoid may be purchased unless the Giraffoid is purchased as well.
  The Giraffoid serves as social anchor."
]

Mestorf, a gruff mining engineer, responds: "Fine. We'll take _all three_ --- the Giraffoid, the Elephandroid, and the Simianoid."

Minik, seemingly pleased, adds: "Excellent! Then we shall certainly sell you either the Elephandroid or the Giraffoid."

Tichy observes the exchange with puzzlement.

*Your task:*
+ Introduce propositional variables $G$, $E$, $S$ for purchasing each toy. Formalize all of Minik's regulations and both of Mestorf's and Minik's declarations.
+ Determine which combinations of purchases are consistent with these constraints.
+ Identify which propositions are logical consequences of the stated claims.
+ State succinctly: how many toys were bought, and why?


= Part II: The Liar's Archipelago

#Box[
  On certain planets, truth and falsehood intertwine like binary stars. \
  Ijon Tichy has learned to navigate these treacherous waters.
]

== Problem 4: The Quantum Cheat-Leaf Affair

At the Interstellar Navigation Academy, a minor scandal has erupted: a *Quantum Cheat-Leaf* --- a banned mnemonic symbiont from the restricted planet Mnemonikos --- was discovered near the examination hall.
Ijon Tichy, summoned as an impartial investigator, interrogates three cadets who all drew the same exam question: "Navigating Topologically Impossible Nebulae."

*Ivanko* testifies: "I did not use the Cheat-Leaf. Sidorik used it. Petryn used it too."

*Petryn* testifies: "Ivanko used it. I did not use it. As for Sidorik, I cannot say."

*Sidorik* remains silent --- invoking the Fifth Amendment of Cosmic Self-Incrimination.

After the official hearing, the three cadets whisper a confession to Tichy in private:
#quote(block: true)[
  "One of us told the complete truth. One of us told exactly one true statement among the three. One of us lied in every statement."
]
They refuse to specify who is who.

*Your task:*

Let $I$, $P$, $S$ denote "Ivanko / Petryn / Sidorik used the Cheat-Leaf" respectively.
+ Formalize the statements of Ivanko and Petryn.
+ Using the meta-constraint about truth-telling, determine all consistent scenarios.
+ Can we deduce who used the Cheat-Leaf?
+ Is it certain that *someone* used it?
+ Can we identify which cadet told the complete truth?


== Problem 5: The Case of the Contradictory Cosmonauts

After a minor reactor incident aboard the research vessel _Asymptote_, Tichy collects testimonies from three cosmonauts.

- *Knyazev* gives an initial testimony. (We denote its truth value by $K$.)
- *Faraonov* responds: "Knyazev's first testimony is _false_."
- *Tsaryov* interjects: "Faraonov is lying."
- When recalled, *Knyazev* adds: "Both Faraonov and Tsaryov lied."

Tichy notes the self-referential tangle with weary familiarity.

*Your task:*
+ Let $K$ be the truth value of Knyazev's initial testimony. Formalize all four statements.
+ List all consistent truth-value assignments.
+ Identify which statements are *determinately* true or false (in every consistent assignment), and which depend on the unknown value of $K$.


== Problem 6: Checkpoint Omega --- Knight, Knave, Spy

At Checkpoint Omega, the border between the Galactic Core and the Outer Rim, Tichy encounters three customs bots: *Aster*, *Boron*, and *Circe*.
Regulations require one Knight-bot (always truthful, for verification), one Knave-bot (always lying, for security stress-tests), and one Spy-bot (answers arbitrarily, for infiltration detection).

The bots make their declarations:
- *Aster*: "I am the Knight."
- *Boron*: "Aster is the Spy."
- *Circe*: "I am the Spy."

*Your task:*
+ Determine who is Knight, Knave, and Spy. Provide a case-by-case analysis.
+ If Circe's statement were instead "_Aster is the Knave_," how would the identification change?


== Problem 7: The Metallurgical Vaults of Solaris

Deep within the Solaric Archives, Tichy discovers three ancient vaults: *Gold*, *Silver*, and *Lead*.
One vault contains the legendary *Crystallized Theorem* --- a physical manifestation of a mathematical truth so pure it glows.

Inscriptions on the vaults read:
- *Gold*: "The Crystallized Theorem is not here."
- *Silver*: "The Crystallized Theorem is in the Gold vault."
- *Lead*: "The Crystallized Theorem is here."

Tichy recalls the Solaric warning: _"Trust neither all inscriptions nor none."_

*Your task:*
+ *Loose reading*: At least one inscription is true and at least one is false. Which vault(s) may contain the Theorem?
+ *Classic reading*: Exactly one inscription is true. Find the unique vault and prove it.


== Problem 8: The Rooms of Probabilistic Doom

In the quantum-probabilistic wing of the Museum of Possible Futures, Tichy faces two chambers.
Each bears an inscription, and *exactly one inscription is true*.
One room contains the Lady of Lyra (a benevolent hologram); the other contains a Tiger-construct (decidedly less benevolent).

*Room I*: "Here is the Lady, and in the other room the Tiger."

*Room II*: "Exactly one room contains a Lady and the other a Tiger."

*Your task:*
+ Formalize both inscriptions using propositions $L_1$, $L_2$ (Lady in Room I/II).
+ Determine which room contains the Lady. Justify in one paragraph.
+ *Variant*: If Room II instead read "_At least one room contains a Lady and at least one a Tiger_," does the answer change? Explain.


= Part III: First-Order Logic

#Box[
  Quantifiers give us the power to speak of all and some. \
  But with great power comes the risk of great confusion.
]


== Problem 9: The Grand Repository of Galactic Software

Ijon catalogs software artifacts in the Galactic Archives.
The domain is _all software_. Predicates:
- $O(x)$ --- "$x$ is open-source"
- $B(x)$ --- "$x$ is buggy"
- $U(x,y)$ --- "$x$ uses $y$"

*Translate each statement into first-order logic:*
+ "Some open-source software is not buggy."
+ "All buggy software uses some open-source software."
+ "There exists a piece of software that uses all open-source software."

*For each formula:*
- Provide a small finite model that satisfies it.
- State which formula requires an existential witness that cannot be removed when the domain is expanded (i.e., is not equivalent to a universal statement).


== Problem 10: The Printer's Slip --- Quantifier Negation

The self-aware Theorem-Printer aboard the _Asymptote_ produced the following formula, claiming it to be a fundamental truth:
$
  forall x exists y . thin (P(x) imply Q(x,y))
$
Moments later, a power surge corrupted its memory, and it now demands verification of the formula's negation.

*Your task:*
+ Write the negation of the formula.
+ Push negation inward to atoms using De Morgan's laws for quantifiers.
+ Present the final quantifier prefix and the quantifier-free matrix.


== Problem 11: Theorem-Machine Validation

The Theorem-Printer confidently asserts:
$
  forall x . thin (P(x) or Q(x))
  quad proves quad
  (forall x . thin P(x)) or (forall x . thin Q(x))
$

Tichy, ever skeptical of machines, asks you to verify.

*Your task:*
+ Decide whether the entailment is valid.
+ If invalid, produce a concrete countermodel: specify a domain and an interpretation of $P$ and $Q$ that satisfies the left-hand side but falsifies the right.
+ Give a one-sentence semantic explanation of why the entailment fails (or holds).


= Part IV: Proof Theory

#Box[
  A proof is a path through the forest of logic. \
  Find the shortest path, and you find elegance.
]


== Problem 12: Resolution in the Clause Factory

At the automated Clause Factory on Titan, a noisy batcher prints clause-sets for satisfiability testing.
A batch flagged as "suspicious" arrives at Tichy's desk:
$
  { thin P or Q, quad not P or R, quad not Q or S, quad not R, quad not S thin }
$

The engineers fear the batch is defective (unsatisfiable).

*Your task:*
- Use the Resolution rule step by step to derive the empty clause $square$.
- For each step, show the two parent clauses and the resolvent.
- Conclude unsatisfiability.


== Problem 13: Navigator's Fitch Drills

Every star-navigator must master propositional proofs.
Tichy assigns the following formulas for Fitch-style natural deduction:

+ $(A imply B) or (B imply A)$
+ $A imply (B imply A)$
+ $(not B imply not A) imply ((not B imply A) imply B)$
+ $(A imply (B imply C)) imply ((A imply B) imply (A imply C))$

*For each:*
- Provide a concise Fitch-style derivation, marking inference rules used.
- For (1), note briefly: Is this formula intuitionistically derivable, or does it require classical logic (e.g., Law of Excluded Middle)?


== Problem 14: Corrupted Proofs from the Archive

The Galactic Archive's proof repository suffered data corruption.
Several Fitch proofs have missing steps marked with $square$ boxes.
Reconstruct the missing formulae and justifications.

#let BOX = {
  move(dy: 2pt, box(stroke: 1pt, width: 2em, height: 1em))
}
#let BOXM = {
  move(dy: 0pt, box(stroke: 1pt, width: 2em, height: 1em))
}

*Proof 1 --- Modus Tollens:*

#align(center)[
  #derive-it.ded-nat(stcolor: black, arr: (
    (0, $H imply (R and C)$, "Premise"),
    (0, $not R or not C$, "Premise"),
    (0, $not(R and C)$, BOX),
    (0, $BOXM$, "MT 1, 3"),
  ))
]

*Proof 2 --- Contradiction:*

#align(center)[
  #derive-it.ded-nat(stcolor: black, arr: (
    (0, $K and S$, "Premise"),
    (0, $not K$, "Premise"),
    (0, $BOXM$, BOX),
    (0, $BOXM$, BOX),
    (0, $not S$, BOX),
  ))
]

*Proof 3 --- Disjunctive Elimination:*

#align(center)[
  #derive-it.ded-nat(stcolor: black, arr: (
    (0, $(P and Q) or (P and R)$, "Premise"),
    (1, $BOXM$, "Assume"),
    (1, $P$, BOX),
    (0, $...$, []),
    (1, $BOXM$, "Assume"),
    (1, $P$, BOX),
    (0, $P$, BOX),
  ))
]


= Part V: Advanced Challenges

#Box[
  For those who dare to venture beyond the curriculum. \
  Extra credit awaits the bold.
]


== Problem 15: Tri-Constellation Agent Communications

Central Command transmits a decrypted intelligence fragment to Tichy regarding last week's contacts among four field agents: *Bilion*, *Stevok*, *Tomix*, and *Johnon*.

The deciphered memo reads:
#block(
  inset: (left: 1em),
  stroke: (left: 3pt + gray),
  outset: (y: 3pt, left: -3pt),
)[
  "If Bilion contacted Stevok, then Tomix did not contact Stevok.
  Furthermore, Bilion contacted Stevok if and only if Johnon contacted at least one of them (Bilion or Stevok).
  Additionally, if Johnon contacted Stevok, then Bilion did not contact Stevok."
]

Let $C(x,y)$ denote "$x$ contacted $y$" (not necessarily symmetric).

*Your task:*
+ Formalize the three constraints as propositional formulas.
+ Identify a pair of agents who *definitely* communicated (in some direction).
+ Identify a pair who *definitely did not* communicate.
+ Determine whether there exists an agent who *certainly* communicated with at least one other.


== Problem 16: Martians and Venusians on the Arithmetic Axis

On the infinite *Arithmetic Axis*, every natural point $n >= 1$ houses either a _Martian_ or a _Venusian_.

A xenopsychologist publishes the following observations:
- "No Martian endures having both neighbors also Martians." \
  (Formally: $forall n >= 2. thin M_n imply not(M_(n-1) and M_(n+1))$)
- "Every Venusian demands at least one Martian neighbor." \
  (Formally: $forall n >= 2. thin V_n imply (M_(n-1) or M_(n+1))$)

Martians transmit an encrypted addendum:
- "If point 3 houses a Martian, then every point divisible by 3 houses a Martian." \
  (Formally: $M_3 imply forall k. thin (3 | k imply M_k)$)

Additionally, the following statement is declared *false* in this world:
- "If point 5 houses a Martian, then there exists a point divisible by 3 that houses a Martian."

*Your task:*
+ Explain the logical consequence of the fourth constraint being false.
+ If exactly five Martians live on the axis, determine their unique positions.
+ Decide whether point 1 must house a Martian.
+ Formulate a general rule for the inhabitant at any point $n$.


== Problem 17: Modal Lamps at the Observatory

At the Interstellar Observatory, Tichy examines a Kripke frame with four possible worlds: $w_1, w_2, w_3, w_4$.

*Accessibility relations:*
- $w_1 -> w_2$, #h(1em) $w_1 -> w_3$
- $w_2 -> w_4$, #h(1em) $w_3 -> w_4$
- $w_4 -> w_4$ (reflexive)

*Valuation:*
Proposition $P$ is #True in $w_2$ and $w_4$, and #False in $w_1$ and $w_3$.

*Your task:*
+ At $w_1$, evaluate: $diamond P$, $square P$, $square diamond P$, and $diamond square P$.
+ In one sentence, explain why $square diamond P$ differs from $diamond square P$ in this model.
+ If all worlds become reflexive, which of the four evaluations change?


== Problem 18: Da, Ja, and the Three Algorithmic Gods

On a forgotten island, Tichy encounters three ancient AIs who answer only *"da"* or *"ja"* --- one word means _yes_, the other _no_, but Tichy doesn't know which is which.

One AI always tells the truth (*True*).
One always lies (*False*).
One answers randomly (*Random*).

Tichy may ask exactly *three yes/no questions*, each directed to one AI of his choosing.

*Your task:*
+ Devise three explicit questions (in natural language) that allow Tichy to identify each AI --- regardless of which word means what and regardless of Random's coin flips.
+ Provide a short explanation of the trick that makes the questions robust to the unknown language.

_Hint:_ Consider questions that yield the same observable response whether "da" means yes or no.


#line(length: 100%, stroke: 0.4pt)

*Submission Guidelines:*
- Organize solutions clearly with problem numbers and parts.
- For proofs: State assumptions, show logical steps, and clearly mark conclusions.

*Grading Rubric:*
- Correctness of symbolizations and proofs: 50%
- Logical rigor and clarity of reasoning: 30%
- Completeness and attention to detail: 20%

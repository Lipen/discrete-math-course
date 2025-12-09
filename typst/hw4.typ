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


Ijon Tichy's wanderings across the cosmos have accumulated, as if by gravitational attraction, a~collection of logical tangles and philosophical snares.
The following problems emerge from his investigations: some are mere technical puzzles, others carry implications for understanding truth, proof, and the nature of reasoning itself.

= Part I: Propositional Foundations

#Box[
  Logic is the art of going wrong with confidence.
]

== Problem 1: The Council of Contradictory Decrees

On the planet Enteropia, the High Council has accumulated the peculiar habit of issuing decrees that must remain logically consistent at all times --- lest the underlying fabric of bureaucratic reality begin to unravel, taking the Council with it.
Tichy, appointed as Logical Auditor by circumstance and resigned to the role by experience, must examine each batch of proclamations to determine whether they can coexist without logical contradiction.

For each set of decrees below, establish whether they are *jointly satisfiable* (logically consistent).
If consistent, exhibit a satisfying assignment of truth values; if not, expose the logical contradiction that makes them mutually incompatible.

#tasklist("prob1", cols: 2)[
  + ${ not D, (D or F), not F }$

  + ${ (T imply K), not K, (K or not T) }$

  #colbreak()

  + ${ not(A imply (not C imply B)), ((B or C) and A) }$

  + ${ (C imply B), (D or C), not B, (D imply B) }$
]


== Problem 2: Diplomatic Dispatches in Alliterative Cipher

Intercepted transmissions from the Fomalhaut Confederation arrive encrypted in what cryptographers call the *Alliterative Cipher* --- a Byzantine obfuscation technique that encodes logical relationships beneath elaborate patterns of linguistic symmetry.
Tichy must recover the underlying logical structure from each dispatch: symbolize the argument, determine its validity via truth table, and furnish either a Fitch-style derivation (for valid inferences) or a counterexample valuation (for invalid ones).
The elegance of this cipher lies in its redundancy; only careful logical analysis can separate signal from noise.

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


// #pagebreak()

== Problem 3: The Emporium of Synthetic Companions

At Orbital Station Cygnus-7, deep within the commercial quarter, stands the *Emporium of Synthetic Companions* --- a modest establishment that sells robotic pets to lonely cosmonauts stationed in remote outposts.
Its proprietor, a small automaton named Minik, has developed an elaborate set of regulations governing what combinations of companions may be purchased together.
The regulations arise from genuine concern: Minik has observed that certain machines, deprived of social interaction, develop a form of existential despondence that leads them into malfunction and silence.

Minik explains the regulations to Tichy with meticulous bureaucratic precision:

#block(
  inset: (x: 1em),
  stroke: (left: 3pt + gray),
  outset: (y: 3pt, left: -3pt),
)[
  *Regulation 1:* #h(.3em)
  If you purchase exactly one of the Giraffoid or the Elephandroid, you must also purchase a Simianoid.
  Solitary mega-fauna units develop a form of existential melancholy --- they contemplate their isolation and gradually cease functioning.

  *Regulation 2:* #h(.3em)
  Neither the Elephandroid nor the Simianoid may be purchased unless the Giraffoid is purchased as well.
  The Giraffoid, it seems, serves as social anchor for the entire collection.
]

One day, a visiting engineer named Mestorf arrives and announces: "We shall take _all three_ --- the Giraffoid, the Elephandroid, and the Simianoid."

Minik, consulting its regulatory database, replies with evident satisfaction: "Excellent. Then we shall certainly sell you either the Elephandroid or the Giraffoid."

Tichy observes this exchange with the weary skepticism of one accustomed to bureaucratic contradictions.

*Your task:*
+ Introduce propositional variables $G$, $E$, $S$ for the purchase of each companion. Formalize all of Minik's regulations and both declarations (Mestorf's announcement and Minik's reply).
+ Determine which combinations of purchases are logically consistent with these constraints.
+ Identify which of the stated propositions are logical consequences of the regulatory system.
+ Determine succinctly: which companions were actually purchased, and why does the regulatory logic force this outcome?
#pagebreak()

= Part II: The Liar's Archipelago

#Box[
  On certain planets, truth and falsehood intertwine like binary stars. \
  Ijon Tichy has learned to navigate these treacherous waters.
]

== Problem 4: The Quantum Cheat-Leaf Affair

At the prestigious Interstellar Navigation Academy, an unprecedented scandal erupts when a *Quantum Cheat-Leaf* --- a banned mnemonic device derived from the restricted planet Mnemonikos --- is discovered concealed near the examination hall.
The device is contraband not merely because it confers unfair advantage, but because its quantum-entangled nature renders its use nearly undetectable by conventional means.

Ijon Tichy is summoned by the Academy's Director to investigate. Three cadets --- all of whom drew the identical examination problem ("Navigating Topologically Impossible Nebulae") --- are brought for interrogation.

*Ivanko's testimony:* "I did not use the Cheat-Leaf. Sidorik used it. Petryn used it too."

*Petryn's testimony:* "Ivanko used it. I did not use it. As for Sidorik, I cannot speak with certainty."

*Sidorik:* Invokes silence, claiming constitutional protection against self-incrimination.

Later, in a private corridor, all three cadets approach Tichy and whisper a collective confession:

#block(
  inset: (x: 1em),
  stroke: (left: 3pt + gray),
  outset: (y: 3pt, left: -3pt),
)[
  "Understand this: One of us has spoken nothing but truth. One of us has made exactly one true statement. One of us has lied in every statement we gave."
]

They refuse to specify which cadet belongs to which category.

*Your task:*
Let $I$, $P$, $S$ denote the propositions "Ivanko / Petryn / Sidorik used the Cheat-Leaf" respectively.
+ Formalize the testimonies of Ivanko and Petryn as propositional formulas.
+ Using the meta-constraint about the distribution of truth-telling among the three cadets, determine all logically consistent scenarios.
+ Can we definitively determine who used the Cheat-Leaf?
+ Is it certain that _someone_ used it?
+ Can we identify which cadet is the complete truth-teller?


== Problem 5: The Case of the Contradictory Cosmonauts

Aboard the research vessel _Asymptote_, a minor but consequential incident involving the reactor has occurred.
To establish what transpired, Tichy interviews three crew members, only to discover that their accounts intertwine in a web of meta-logical assertion and denial.

- *Knyazev* gives an initial testimony regarding the incident.
- *Faraonov* responds: "Knyazev's first testimony is _false_."
- *Tsaryov* interjects: "Faraonov is lying."
- When recalled for clarification, *Knyazev* adds: "Both Faraonov and Tsaryov have lied."

Tichy, familiar with such self-referential tangles from his years of investigation, begins to analyze the structure of their claims.

*Your task:*
+ Let $K$ be the truth value of Knyazev's initial testimony. Formalize all four statements as propositional formulas.
+ Construct a truth table and list all consistent truth-value assignments for $K$, the other testimonies, and any derived propositions.
+ Identify which statements are *determinately* true or false in every consistent assignment, and which depend on the unknown value of $K$.
+ If possible, deduce the truth value of $K$ from the structure of the testimonies alone.


== Problem 6: Checkpoint Omega --- Knight, Knave, Spy

At Checkpoint Omega, the highly sensitive border station between the Galactic Core and the Outer Rim, sophisticated security protocols employ three categories of customs-inspection bots.
The regulations are exacting: one Knight-bot (programmed to always speak truthfully, used to verify passenger claims), one Knave-bot (deliberately programmed to always lie, used to stress-test security procedures), and one Spy-bot (its response protocol randomized for infiltration detection).

Tichy presents himself for inspection. The three bots respond to his status inquiry with simultaneous declarations:

- *Aster*: "I am the Knight."
- *Boron*: "Aster is the Spy."
- *Circe*: "I am the Spy."

The contradiction is immediate and unnerving.

*Your task:*
+ Determine which bot is Knight, which is Knave, and which is Spy.
+ If Circe's statement were instead "_Aster is the Knave_," how would the identification change?
+ Why is it impossible for the Spy-bot to make either of these declarations with certainty?


== Problem 7: The Metallurgical Vaults of Solaris

Deep within the Solaric Archives --- a vast repository of artifacts from a civilization long extinct --- Tichy discovers three monumental vaults constructed from mysterious alloys: one of Gold, one of Silver, one of Lead.
According to cryptic historical records, one vault contains the *Crystallized Theorem* --- a legendary mathematical artifact so refined and powerful that it allegedly glows with logical coherence.
Finding it would revolutionize our understanding of mathematics itself.

Each vault bears an inscription, aged but legible:

- *Gold vault*: "The Crystallized Theorem is not here."
- *Silver vault*: "The Crystallized Theorem is in the Gold vault."
- *Lead vault*: "The Crystallized Theorem is here."

Tichy recalls a Solaric scholarly warning, repeated in fragmentary historical documents: _"Trust neither all inscriptions nor none; the ancients encoded truth and falsehood in deliberate tension."_

*Your task:*
+ *Loose interpretation*: Assume at least one inscription is true and at least one is false. Under these constraints, which vault(s) _might_ contain the Theorem? Enumerate all possibilities.
+ *Classical interpretation*: Assume exactly one inscription is true. Determine which vault uniquely contains the Theorem and provide a rigorous proof.
+ What does the logical structure of these inscriptions tell us about the ancients' understanding of meta-truth?


== Problem 8: The Rooms of Probabilistic Doom

In the quantum-probabilistic wing of the Museum of Possible Futures, Tichy encounters an installation designed as both logical puzzle and philosophical provocation. He stands before two sealed chambers, each bearing an inscription.
One chamber contains the *Lady of Lyra* --- a benevolent holographic entity whose presence assures safe passage. The other contains a *Tiger-construct* --- a decidedly less benevolent automaton engineered to enforce certain epistemic rigors.

Only one of the two inscriptions is true; the other is false. This constraint is guaranteed by the museum's logical assurance mechanism.

*Chamber I* bears: "Here is the Lady, and in the other chamber the Tiger."

*Chamber II* bears: "Exactly one chamber contains a Lady and the other a Tiger."

*Your task:*
+ Formalize both inscriptions as propositional formulas. Let $L_1$, $L_2$ denote the presence of the Lady in each chamber.
+ Using the constraint that exactly one inscription is true, determine which chamber contains the Lady. Show all logical steps.
+ If Chamber II's inscription were instead "_At least one chamber contains a Lady and at least one a Tiger_," how would the answer change? Provide a complete analysis of the new logical scenario.


= Part III: First-Order Logic

#Box[
  Quantifiers give us the power to speak of all and some. \
  But with great power comes the risk of great confusion.
]


== Problem 9: The Grand Repository of Galactic Software

Ijon undertakes the monumental task of cataloging software artifacts recovered from abandoned research stations scattered across the galaxy.
The Galactic Archives maintain an exhaustive collection spanning millennia of computational history.
He must codify relationships among these artifacts using first-order logic, creating a formal taxonomy.

The domain is _all software_. The predicates are:
- $O(x)$ --- "$x$ is open-source"
- $B(x)$ --- "$x$ is buggy"
- $U(x,y)$ --- "$x$ uses $y$"

*Your task:*
+ Translate each of the following statements into first-order logic:
  - "Some open-source software is not buggy."
  - "All buggy software uses some open-source software."
  - "There exists a piece of software that uses all open-source software."

+ For each formula above:
  - Construct a small finite model (specifying domain, truth values) that satisfies the formula.
  - Identify which formula(s) require an existential witness that cannot be universally quantified even when the domain is expanded. Why is this significant?


== Problem 10: The Printer's Slip --- Quantifier Negation

The *Theorem-Printer* --- a sophisticated self-aware logical inference machine aboard the _Asymptote_ --- has produced the following formula, asserting it as a fundamental mathematical truth:
$
  forall x exists y . thin (P(x) imply Q(x,y))
$

Before the assertion can be logged, a power surge strikes the system, corrupting its memory.
The machine now demands verification by computing the negation of this formula and reducing it to a canonical form.

*Your task:*
+ Compute the negation using De Morgan's laws and quantifier negation rules.
+ Present the final result in canonical form: quantifier prefix, then quantifier-free matrix.


== Problem 11: Theorem-Machine Validation

The Theorem-Printer, once restored to operational status, outputs a new entailment claim:
$
  forall x . thin (P(x) or Q(x))
  quad proves quad
  (forall x . thin P(x)) or (forall x . thin Q(x))
$

Tichy, bearing the scars of experience with automated systems that conflate intuition with rigor, approaches this claim with skepticism and demands rigorous verification.

*Your task:*
+ Determine whether the entailment is valid. Justify your answer with precise logical reasoning.
+ If invalid, construct a concrete countermodel: specify a domain $D$ and interpretations of $P$ and~$Q$ such that the left-hand side is true but the right-hand side is false.
+ Provide a one-sentence semantic explanation: Why does this entailment hold or fail?


= Part IV: Proof Theory

#Box[
  A proof is a path through the forest of logic. \
  Find the shortest path, and you find elegance.
]


== Problem 12: Resolution in the Clause Factory

On Titan's automated *Clause Factory* --- a vast industrial facility dedicated to satisfiability analysis --- a noisy batcher has produced a clause-set flagged as "suspicious" by preliminary screening.
The batch is forwarded to Tichy's desk for expert verification:
$
  { thin P or Q, quad not P or R, quad not Q or S, quad not R, quad not S thin }
$

The factory engineers fear the entire batch is defective (unsatisfiable), which would trigger a production halt and investigation into equipment calibration.

*Your task:*
- Apply the Resolution rule iteratively to this clause-set, deriving the empty clause $square$.
- Document each step: show the two parent clauses and the resulting resolvent.
- Conclude and explain: Why does the derivation of the empty clause prove unsatisfiability?


== Problem 13: Navigator's Fitch Drills

The *Celestial Navigation Academy* requires all star-navigators to demonstrate mastery of formal propositional proof techniques. Tichy, as guest instructor, assigns the following tautologies for Fitch-style natural deduction.
Each formula requires careful reasoning about implication, negation, and logical equivalence.

For each formula:
+ $(A imply B) or (B imply A)$
+ $A imply (B imply A)$
+ $(not B imply not A) imply ((not B imply A) imply B)$
+ $(A imply (B imply C)) imply ((A imply B) imply (A imply C))$

*Your task:*
- Provide a concise Fitch-style natural deduction derivation for each formula, clearly marking all assumptions and inference rules.
- For formula (1): Briefly analyze whether it is derivable intuitionistically, or whether it requires classical logic (e.g., Law of Excluded Middle).
- For formula (4): This is the exportation law. Explain its significance.


== Problem 14: Corrupted Proofs from the Archive

The *Galactic Archive's* proof repository has suffered catastrophic data corruption from a systems failure. Several historically important Fitch-style natural deduction proofs have been partially reconstructed, but gaps remain marked with $square$ boxes throughout the derivations.
Your task is to restore these proofs to canonical form by identifying the missing formulae and justifications.

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

*Proof 2 --- Contradiction and Negation:*

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

*Central Command* transmits to Tichy an intelligence summary concerning last week's communications among four field agents operating in the remote regions between the Tri-Constellation colonies: *Bilion*, *Stevok*, *Tomix*, and *Johnon*.
Communications logs were partially encrypted and subsequently corrupted, but the following constraints were reconstructed by cryptanalysts:

#block(
  inset: (x: 1em),
  stroke: (left: 3pt + gray),
  outset: (y: 3pt, left: -3pt),
)[
  "If Bilion contacted Stevok, then Tomix did not contact Stevok.

  Furthermore, Bilion contacted Stevok if and only if Johnon contacted at least one of them (Bilion or Stevok).

  Additionally, if Johnon contacted Stevok, then Bilion did not contact Stevok."
]

Let $C(x,y)$ denote the proposition "$x$ contacted $y$" (directional; not necessarily symmetric).

*Your task:*
+ Formalize all three constraints as propositional formulas using variables $C(x,y)$.
+ Through logical analysis, identify a pair of agents who *must* have communicated (in at least one direction).
+ Identify a pair who *definitively did not* communicate.
+ Determine: Is there an agent who *necessarily* communicated with at least one other? Justify.
+ Construct a truth-table or case analysis to support your conclusions.


== Problem 16: Martians and Venusians on the Arithmetic Axis

On the infinite *Arithmetic Axis* --- extending unbroken from point 1 to infinity --- every natural coordinate $n >= 1$ houses either a *Martian* or a *Venusian*, but never both.
A renowned xenopsychologist, after decades of observation from orbital stations, publishes the following formal constraints on the population distribution:

#block(
  inset: (x: 1em),
  stroke: (left: 3pt + gray),
  outset: (y: 3pt, left: -3pt),
)[
  *Observation 1:* "No Martian tolerates having both neighbors also as Martians." \
  (Formally: $forall n >= 2. thin M_n imply not(M_(n-1) and M_(n+1))$)

  *Observation 2:* "Every Venusian demands at least one Martian neighbor." \
  (Formally: $forall n >= 2. thin V_n imply (M_(n-1) or M_(n+1))$)
]

A subsequent transmission from the Martian political councils provides an encrypted addendum:
- *Constraint 3:* "If point 3 houses a Martian, then every point divisible by 3 houses a Martian." \
  (Formally: $M_3 imply forall k. thin (3 | k imply M_k)$)

Finally, xenopsychologists intercept a statement and determine definitively that it is *false* within this world:
- *Constraint 4 (negated):* "If point 5 houses a Martian, then there exists a point divisible by 3 that houses a Martian." \
  (Formally: $not(M_5 imply exists k. thin (3 | k and M_k))$)

*Your task:*
+ Explain: What does the negation of Constraint 4 logically entail?
+ Given that exactly five Martians inhabit the axis, determine their positions uniquely.
+ Must point 1 house a Martian? Provide rigorous justification.
+ Formulate a general descriptive rule governing the inhabitant type at any point $n$.


== Problem 17: Da, Ja, and the Three Algorithmic Gods

On a forgotten island shrouded in gravitational anomalies, Tichy discovers three ancient AIs — monuments to a civilization's attempt to encode pure reason into physical substrate.
These entities communicate only through two utterances: *"da"* and *"ja"* --- one signifies affirmation, the other negation, but the encoding is deliberately obscured.

*Specification:*
- One AI is programmed to always speak truthfully (*Truth*).
- One is programmed to always lie (*Falsehood*).
- One operates under a randomization protocol (*Random*), responding affirmatively or negatively with equal probability.

Tichy is granted exactly *three yes/no questions*, each directed to one AI of his choosing. Based solely on the pattern of responses, he must identify which AI is which.
The challenge is compounded: he does not know which language maps to which truth value.

*Your task:*
+ Design three concrete yes/no questions (state them in natural language) such that Tichy can uniquely identify each AI's role, regardless of which word means "yes" and regardless of Random's probabilistic choices.

+ Provide a detailed explanation of the logical principle that makes these questions robust.
  Why~does your strategy succeed despite the language ambiguity and randomness?

+ For your three questions, construct an exhaustive decision tree or truth table showing:
  - The response pattern (da or ja) from each AI for each question.
  - How the response patterns uniquely identify Truth, Falsehood, and Random.
  - Why no other configuration of AIs could produce the same response sequence.

_Hint:_ Consider designing questions where the truth-value of the statement is independent of what "da" means --- i.e., questions that yield consistent answers across both language interpretations. Also consider questions about the other AIs' characteristics.


#line(length: 100%, stroke: 0.4pt)

*Submission Guidelines:*
- Organize solutions clearly with problem numbers and parts.
- For proofs: State assumptions, show logical steps, and clearly mark conclusions.

*Grading Rubric:*
- Correctness of symbolizations and proofs: 50%
- Logical rigor and clarity of reasoning: 30%
- Completeness and attention to detail: 20%

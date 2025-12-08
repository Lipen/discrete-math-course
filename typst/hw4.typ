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



== Problem 1: The Emporium of Lonely Automatons

Minik, a small selling automaton, and his maker Mestorf argue in Ijon Tichy's presence about a tiny shopping decision.
Minik warns: "If you buy *exactly one* of the Giraffoid or the Elephandroid, you must also buy a Simianoid --- solitary units become melancholic.
But Minik also repeats an older rule: neither the Elephandroid nor the Simianoid may be bought unless the Giraffoid is bought as well.
Mestorf answers: "Very well --- we will take the Giraffoid, the Elephandroid, and the Simianoid."
Minik adds, almost to please himself: "Then let us buy either the Elephandroid or the Giraffoid."

You need to resolve the exchange for Tichy's notes:
- Introduce propositional variables for the three toys and formalize Minik's rules and Mestorf's declaration.
- Decide which combinations of toys are consistent and which follow from these claims.
- State succinctly how many toys were bought and why.


== Problem 2: Galactic Cadets and the Quantum Cheat-Leaf

// Ijon interviews three cadets after an exam.
// A forbidden Quantum Cheat-Leaf is found.

// Three cadets of the Interstellar Navigation Academy --- Ivanko, Petryn and Sidorik --- draw the same exam question on "Navigating Topologically Impossible Nebulae."
// A banned Quantum Cheat-Leaf is later found.
// Ijon Tichy, summoned as the curious pedagogical inspector, interrogates the three cadets separately.

At the Interstellar Navigation Academy a minor scandal flutters: a *banned Quantum Cheat-Leaf* was found near the exam hall.
Ijon Tichy, summoned as the curious pedagogical inspector, questions three cadets who each drew the same impossible nebula problem.
Cadets answer in curt bursts of cosmic hygiene and blame.

- Ivanko says: "I didn't use it. Sidorik used it. Petryn used it too."
- Petryn says: "Ivanko used it. I didn't. I cannot say anything about Sidorik."
- Sidorik says nothing publicly.

Later the three whisper to Tichy: "One of us told only the truth. One of us told exactly one truth. One of us lied in everything."
They refuse to specify who.

// Later they confess: one of the three cadets’ three statements was entirely true, another cadet told exactly one true statement among his three, and the third cadet told no true statements. They refuse to say who was who.

// Questions:
// a) Can one deduce who—if anyone—consulted the cheat-leaf?
// b) Is it guaranteed that someone used it?
// c) Can we determine whether Ivanov or Petrov was the reliable one?

Help Tichy reconstruct the event by formalizing their claims.
+ Can we deduce who used the Cheat-Leaf?
+ Is it certain that someone used it?
+ Can we identify the truthful cadet?


== Problem 3: The Case of the Contradictory Cosmonauts

After a small reactor incident, Tichy collects testimonies from three cosmonauts:
- Knyazev gives an initial testimony.
- Faraonov replies: "Knyazev's first testimony is false."
- Tsaryov says: "Faraonov is lying."
- Called back, Knyazev now states: "Both Faraonov and Tsaryov lied"

Tichy asks you to:
+ List all consistent truth-value assignments for the three utterances.
+ Point out which statements are determinately true or false in every consistent assignment, and which depend on the initial truth of Knyazev's first testimony.


== Problem 4: Border Bots --- Knight, Knave, Spy

At a border booth Tichy meets three bots: Aster, Boron, and Circe.
One always tells the truth (Knight), one always lies (Knave), one answers arbitrarily (Spy).
They proclaim:
- Aster: "I am the Knight."
- Boron: "Aster is the Spy."
- Circe: "I am the Spy."

Tichy asks you to identify their roles:
+ Determine who is Knight, Knave, and Spy, with a short case analysis.
+ If Circe's statement were instead "Aster is the Knave," indicate how the identification changes.


== Problem 5: The Metallurgical Vaults

Ijon examines three museum vaults.
Inscriptions read:
- Gold: "The treasure is not here."
- Silver: "The treasure is in the Gold chest."
- Lead: "The treasure is here."

Tichy requests two solutions:
+ Loose reading: at least one inscription is true and at least one false --- find which vault(s) may contain the treasure.
+ Classic reading: exactly one inscription is true --- find the unique vault and prove it.

State each answer clearly and justify it.


== Problem 6: Tri-Constellation Agent Communications

Central Command sends Tichy a decrypted fragment about last week's contacts among Bilion, Stevok, Tomix, and Johnon.
The deciphered memo reads: "If Bilion contacted Stevok then Tomix did not; and Bilion contacting Stevok holds exactly when Johnon contacted at least one of them. Also, if Johnon contacted Stevok then Bilion did not contact Stevok."

Tichy asks you to:
// TODO: "reasonable formal parsing" is confusing
// + Choose a reasonable formal parsing and write the corresponding propositional formulas.
// + Under that parsing, determine which agent pairs definitely contacted, which definitely did not, and whether any agent must have contacted someone.
// + Briefly explain how an alternative natural-language parse could change conclusions.

// **Questions:**
+ Identify a pair of agents who definitely communicated.
+ Identify a pair who definitely did not.
+ Determine whether there exists an agent who certainly communicated with at least one other.


== Problem 7: Resolution in the Clause Factory

A noisy clause-batcher prints a small set that worries the engineers.
Ijon brings it to class:
$
  { P or Q, not P or R, not Q or S, not R, not S }
$

Tichy asks for a crisp proof.
You must:
- Use the Resolution rule step by step to derive the empty clause.
- Show each resolved pair and the resolvent.
- Conclude unsatisfiability.


== Problem 8: Quantifier Negation --- The Printer's Slip

The theorem-printer produced:
$
  forall x exists y . thin (P(x) imply Q(x,y))
$

Tichy asks students to check its negation.
+ Write the negation and push negation to atoms.
+ Present the final quantifier prefix and the quantifier-free matrix.


== Problem 9: FOL Translations in the Grand Repository

Ijon catalogs software.
Predicates: $O(x)$ = "$x$ is open-source", $B(x)$ = "$x$ is buggy", $U(x,y)$ = "$x$ uses $y$".

Translate and exemplify:
+ "Some open-source software is not buggy."
+ "All buggy software uses some open-source software."
+ "There exists a piece of software that uses all open-source software."

For each:
- Give a precise first-order formula.
- Provide a small finite model that satisfies it.
- State which formula requires an existential witness that cannot be removed when the domain is expanded.


== Problem 10: Forall and Or --- Theorem-Machine Check

Theorem-Printer asserts:
$
  forall x . thin (P(x) or Q(x))
  quad proves quad
  (forall x . thin P(x)) or (forall x . thin Q(x))
$

Tichy asks for a verdict.
You must:
+ Decide whether the entailment is valid.
+ If invalid, produce a concrete countermodel (domain and interpretation) satisfying the left side but falsifying the right.
+ Give a one-sentence semantic explanation.


== Problem 11: Martians and Venusians on Natural-Number Street

// On Natural-Number Street each house $n >= 1$ holds either $M_n$ (Martian) or $V_n$ (Venusian).
// The rules are:
// - Martians: no Martian has both neighbors Martian.
// - Venusians: each Venusian has at least one Martian neighbor.
// - Martian broadcast: $M_3 imply forall k . thin (3 | k imply M_k)$.
// - The implication $(M_5 imply exists k . thin (3 | k and M_k))$ is #False in the world.

// Tichy wants the pattern:
// - Explain the logical consequence of that implication being false.
// - If exactly five Martians live on the street, determine their positions and prove uniqueness.
// - Decide whether $M_1$ must hold.
// - Give a short rule describing who lives at a general position $n$.

On the infinite Arithmetic Axis, every natural point ($n >= 1$) houses either a Martian or Venusian.

A xenopsychologist publishes:
- "No Martian endures having both neighbors also Martians."
- "Every Venusian demands at least one Martian neighbor."

Martians send an encrypted addendum:
- If point 3 houses a Martian, then every point divisible by 3 houses a Martian.

Additionally, the following statement is declared false:
- "If point 5 houses a Martian, then there exists a point divisible by 3 that houses a Martian."

Tichy tasks you with:
+ If exactly five Martians live on the axis, determining their unique positions.
+ Deciding whether point 1 must house a Martian.
+ Formulating a general rule for the inhabitant at any point $n$.


== Problem 12: Modal Lamps at the Observatory

The Observatory presents four worlds with accessibility relations:
- $w_1 -> w_2$, $w_1 -> w_3$; $w_2 -> w_4$, $w_3 -> w_4$; $w_4 -> w_4$.

Proposition $P$ is #True in $w_2$ and $w_4$, and #False in $w_1$ and $w_3$.

Tichy asks:
- At $w_1$ evaluate: $diamond P$, $square P$, $square diamond P$, and $diamond square P$.
- In one sentence explain why $square diamond P$ differs from $diamond square P$ here.
- If all worlds become reflexive, state which evaluations change.


== Problem 13: Short Fitch Proofs

Tichy needs compact natural-deduction (Fitch) proofs for these formulas:
1. $(A imply B) or (B imply A)$
2. $A imply (B imply A)$
3. $(not B imply not A) imply ((not B imply A) imply B)$
4. $(A imply (B imply C)) imply ((A imply B) imply (A imply C))$

For each:
- Provide a concise Fitch-style derivation and mark rules used.
- For (1), note briefly whether the formula is intuitionistically derivable or requires classical logic.


== Problem 14: Da, Ja, and the Three Algorithmic Gods

On a tiny isle three gods answer only "da" or "ja."
One always tells truth, one always lies, one answers randomly.
Tichy can ask three yes/no questions total.

Produce:
+ Three explicit questions (text) that identify each god regardless of the da/ja mapping and Random's coin flips.
+ A short explanation of the trick that makes the questions robust to the unknown language.


== Problem 15: The Rooms of Probabilistic Doom

Tichy finds two quantum rooms.
Each bears an inscription and exactly one inscription is true.
One room hides a Lady, the other a Tiger.

Inscriptions:
- Room I: "Here is the Lady, and in the other room the Tiger."
- Room II: "Exactly one room contains a Lady and the other a Tiger."

Help Tichy to:
- Formalize both inscriptions briefly.
- Determine which room contains the Lady and justify in one short paragraph.
- If Room II instead read "At least one room contains a Lady and at least one a Tiger," explain whether the answer changes.



////////////////////////////////////////////////////////


// == Problem 1: Logical Consistency

// For each given set of sentences, determine whether it is logically consistent (jointly satisfiable).

// #tasklist("prob1", cols: 2)[
//   + $not D$, $(D or F)$, $not F$

//   + $(T imply K)$, $not K$, $(K or not T)$

//   #colbreak()

//   + $not(A imply (not C imply B))$, $((B or C) and A)$

//   + $(C imply B)$, $(D or C)$, $not B$, $(D imply B)$
// ]


// == Problem 2: Formal Proofs with Missing Steps

// Complete the following deductive formal proofs by filling in missing formulae and justifications.

// #note[
//   These proofs use natural deduction in Fitch notation.
//   You can verify your proofs at
//   #link("https://proofs.openlogicproject.org")[`proofs.openlogicproject.org`].
//   Note that some inference rules may be missing (e.g., contraposition and commutativity) ---
//   nevertheless, you are still allowed to use them in this task.
// ]

// For each proof below, fill in the missing steps (marked with $square$ boxes) to complete the derivation.

// #let BOX = {
//   move(dy: 2pt, box(stroke: 1pt, width: 2em, height: 1em))
// }
// #let BOXM = {
//   move(dy: 0pt, box(stroke: 1pt, width: 2em, height: 1em))
// }

// *Proof 1:* Modus Tollens

// #align(center)[
//   #derive-it.ded-nat(stcolor: black, arr: (
//     (0, $H imply (R and C)$, "Premise"),
//     (0, $not R or not C$, "Premise"),
//     (0, $not(R and C)$, BOX),
//     (0, $BOXM$, "MT 1, 3"),
//   ))
// ]

// *Proof 2:* Contradiction

// #align(center)[
//   #derive-it.ded-nat(stcolor: black, arr: (
//     (0, $K and S$, "Premise"),
//     (0, $not K$, "Premise"),
//     (0, $BOXM$, BOX),
//     (0, $BOXM$, BOX),
//     (0, $not S$, BOX),
//   ))
// ]

// *Proof 3:* Proof by Cases (Law of Excluded Middle)

// #align(center)[
//   #derive-it.ded-nat(stcolor: black, arr: (
//     (0, $A imply not A$, "Premise"),
//     (0, $BOXM$, "(multiple lines)"),
//     (0, $not A$, [LEM $#BOXM$]),
//   ))
// ]

// *Proof 4:* Disjunctive Elimination

// #align(center)[
//   #derive-it.ded-nat(stcolor: black, arr: (
//     (0, $(P and Q) or (P and R)$, "Premise"),
//     (1, $BOXM$, "Assume"),
//     (1, $P$, BOX),
//     (0, $...$, "empty line"), // TODO: remove this line, but keep assumption scopes separated somehow...
//     (1, $BOXM$, "Assume"),
//     (1, $P$, BOX),
//     (0, $P$, BOX),
//   ))
// ]


// == Problem 3: Argument Symbolization and Validity

// Symbolize the given arguments with well-formed formulae (WFFs) of propositional logic.
// For each argument, determine its validity using a truth table.
// For each _valid_ argument, provide a deductive formal proof in Fitch notation.
// For each _invalid_ argument, provide a counterexample valuation.

// #tasklist("prob3")[
//   // Symbolization: $(P imply Q)$, $(not Q or R)$, $P$ and $R$ (conclusion)
//   + If philosophers ponder profound problems, their quandaries quell quotidian quibbles.
//     Either their quandaries don't quell quotidian quibbles or right reasoning reveals reality (or both).
//     Philosophers do ponder profound problems.
//     Therefore, right reasoning reveals reality.

//   // Symbolization: $A imply (not B or not C)$, $B$, $not A or not C$; Conclusion: $not A$
//   + If aardvarks are adorable, then either baby baboons don't beat bongos or crocodiles can't consume cute capybaras (or both).
//     Baby baboons beat bongos.
//     Aardvarks aren't adorable unless crocodiles can't consume cute capybaras.
//     Therefore, aardvarks aren't adorable.

//   // Symbolization: $not D imply G$, $D imply H$; Conclusion: $G or H$
//   + If discipline doesn't defeat deficiency, then geniuses generally get good grades.
//     If discipline defeats deficiency, then homework has harmed humanity.
//     Therefore, geniuses generally get good grades unless homework has harmed humanity.


//   // Symbolization: $C imply not I$, $(M and D) or C$, $I$; Conclusion: $M iff D$
//   + Crocodiles can consume cute capybaras only if incarcerating iguanas isn't illegal.
//     Mad monkeys make mayhem and dinosaurs do disco dance, unless crocodiles consume cute capybaras.
//     It is known that incarcerating iguanas is illegal.
//     Therefore, dinosaurs do disco dance if and only if mad monkeys make mayhem.
// ]


// == Problem 4: Deductive Proofs with Basic Rules

// For each given argument, construct a deductive proof in Fitch notation using only basic inference rules.

// #tasklist("prob4", cols: 1)[
//   + *Double negation elimination:*
//     $not not A therefore A$

//   + *Peirce's law:*
//     $(A imply B) imply A therefore A$

//   + *Contraposition:*
//     $not B imply not A therefore A imply B$


//   + *De Morgan's law:*
//     $not(A or B) therefore not A and not B$

//   + *De Morgan's law:*
//     $not A and not B therefore not(A or B)$

//   + *Proof by cases:*
//     $(A imply B) and (not A imply B) therefore B$

//   + *Modus Tollens:*
//     $A imply B and not B therefore not A$

//   + *Disjunctive syllogism:*
//     $A or B and not A therefore B$

//   + *Hypothetical syllogism:*
//     $A imply B and B imply C therefore A imply C$

//   + *The "Law of Clavius":*
//     $not A imply A therefore A$
// ]


// == Problem 5: Tautology Proofs

// For each given tautology, construct a deductive proof in Fitch notation.

// + $(A imply B) or (B imply A)$

// + $A imply (B imply A)$

// + $(not B imply not A) imply ((not B imply A) imply B)$

// + $(A imply (B imply C)) imply ((A imply B) imply (A imply C))$


// == Problem 6: The Island of Knights, Knaves, and Spies

// You meet three inhabitants: Alice, Bob, and Charlie.

// - Knights always tell the truth.
// - Knaves always lie.
// - Spies can lie or tell the truth arbitrarily.
// - There is one of each.

// Alice says: "I am the Knight."
// Bob says: "Alice is the Spy."
// Charlie says: "I am the Spy."

// Determine who is who.


// == Problem 7: The Treasure Chests

// You face three chests: Gold, Silver, and Lead. One contains the treasure.

// - Gold Chest inscription: "The treasure is not here."
// - Silver Chest inscription: "The treasure is in the Gold Chest."
// - Lead Chest inscription: "The treasure is here."

// At least one inscription is true, and at least one is false.
// Where is the treasure?


// == Problem 8: Database Queries

// Translate the following English sentences into First-Order Logic. Let the domain be "all software".
// Predicates: $B(x)$ = "$x$ is buggy", $O(x)$ = "$x$ is open-source", $U(x, y)$ = "$x$ uses $y$".

// + "Some open-source software is not buggy."
// + "All buggy software uses some open-source software."
// + "There is a piece of software that uses all open-source software."


// == Problem 9: The Lady or the Tiger

// You are presented with two rooms with inscribed signs:

// - Room I: "In this room there is a lady, and in the other room there is a tiger."
// - Room II: "In one of these rooms there is a lady, and in one of these rooms there is a tiger."

// One sign is true, the other is false.
// Behind which door is the lady?


// == Problem 10: Negation of Quantifiers

// Find the negation of the following sentence and simplify it:
// $
//   forall x exists y . thin P(x) imply Q(x, y)
// $


// == Problem 11: Resolution Rule

// Use the Resolution inference rule to prove that the set of clauses is unsatisfiable:
// $
//   {P or Q, not P or R, not Q or S, not R, not S}
// $


// == Problem 12: Validity Check

// Is the following argument valid?
// $
//   forall x . thin (P(x) or Q(x))
//   quad proves quad
//   (forall x . thin P(x)) or (forall x . thin Q(x))
// $

// If yes, prove it.
// If no, provide a countermodel.


// == Problem 13: Kripke Semantics

// Consider a Kripke model with 3 worlds: $w_1, w_2, w_3$.

// - $w_1 -> w_2$, $w_2 -> w_3$, $w_3 -> w_3$ (reflexive).
// - $P$ is true in $w_2$ and $w_3$.
//   $P$ is false in $w_1$.

// Evaluate the truth of $square P$ and $diamond P$ at world $w_1$.


#line(length: 100%, stroke: 0.4pt)

*Submission Guidelines:*
- Organize solutions clearly with problem numbers and parts.
- For proofs: State assumptions, show logical steps, and clearly mark conclusions.

*Grading Rubric:*
- Correctness of symbolizations and proofs: 50%
- Logical rigor and clarity of reasoning: 30%
- Completeness and attention to detail: 20%

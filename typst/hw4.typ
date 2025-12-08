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
// ...

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


== Problem 1: Logical Consistency

For each given set of sentences, determine whether it is logically consistent (jointly satisfiable).

#tasklist("prob1", cols: 2)[
  + $not D$, $(D or F)$, $not F$

  + $(T imply K)$, $not K$, $(K or not T)$

  #colbreak()

  + $not(A imply (not C imply B))$, $((B or C) and A)$

  + $(C imply B)$, $(D or C)$, $not B$, $(D imply B)$
]


== Problem 2: Formal Proofs with Missing Steps

Complete the following deductive formal proofs by filling in missing formulae and justifications.

#note[
  These proofs use natural deduction in Fitch notation. You can verify your proofs at
  #link("https://proofs.openlogicproject.org")[`proofs.openlogicproject.org`].
  Note that some inference rules may be missing (e.g., contraposition and commutativity) ---
  nevertheless, you are still allowed to use them in this task.
]

For each proof below, fill in the missing steps (marked with $square$ boxes) to complete the derivation.

*Proof 1:* Modus Tollens

#align(center)[
  #derive-it.ded-nat(stcolor: black, arr: (
    (0, $H imply (R and C)$, "PR"),
    (0, $not R or not C$, "PR"),
    (0, $not(R and C)$, "DM 2"),
    (0, $not H$, "MT 1, 3"),
  ))
]

*Proof 2:* Contradiction

#align(center)[
  #derive-it.ded-nat(stcolor: black, arr: (
    (0, $K and S$, "PR"),
    (0, $not K$, "PR"),
    (0, $K$, "Simp 1"),
    (0, $K and not K$, "Conj 3, 2"),
    (0, $not S$, "RAA 2-4"),
  ))
]

*Proof 3:* Proof by Cases (Law of Excluded Middle)

#align(center)[
  #derive-it.ded-nat(stcolor: black, arr: (
    (0, $A imply not A$, "PR"),
    (1, $A$, "Sup. Proof by cases"),
    (1, $not A$, "MP 1, 2"),
    (1, $A and not A$, "Conj 2, 3"),
    (0, $not A$, "Proof by cases"),
  ))
]

*Proof 4:* Disjunctive Elimination

#align(center)[
  #derive-it.ded-nat(stcolor: black, arr: (
    (0, $(P and Q) or (P and R)$, "PR"),
    (1, $P and Q$, "Sup. Case 1"),
    (1, $P$, "Simp 2"),
    (1, $P and Q imply P$, "PC"),
    (1, $P and R$, "Sup. Case 2"),
    (1, $P$, "Simp 4"),
    (1, $P and R imply P$, "PC"),
    (0, $P$, "Disj elim 1, PC, PC"),
  ))
]


== Problem 3: Argument Symbolization and Validity

Symbolize the given arguments with well-formed formulae (_WFFs_) of propositional logic.
For each argument, determine its validity using a truth table.
For each _valid_ argument, provide a deductive formal proof in Fitch notation.
For each _invalid_ argument, provide a counterexample valuation.

#tasklist("prob3")[
  // Symbolization: $(P imply Q)$, $(not Q or R)$, $P$ and $R$ (conclusion)
  + _If philosophers ponder profound problems, their quandaries quell quotidian quibbles.
    Either their quandaries don't quell quotidian quibbles or right reasoning reveals reality (or both).
    Philosophers do ponder profound problems.
    Therefore, right reasoning reveals reality._

  // Symbolization: $A imply (not B or not C)$, $B$, $not A or not C$; Conclusion: $not A$
  + _If aardvarks are adorable, then either baby baboons don't beat bongos or crocodiles can't consume cute capybaras (or both).
    Baby baboons beat bongos.
    Aardvarks aren't adorable unless crocodiles can't consume cute capybaras.
    Therefore, aardvarks aren't adorable._

  // Symbolization: $not D imply G$, $D imply H$; Conclusion: $G or H$
  + _If discipline doesn't defeat deficiency, then geniuses generally get good grades.
    If discipline defeats deficiency, then homework has harmed humanity.
    Therefore, geniuses generally get good grades unless homework has harmed humanity._


  // Symbolization: $C imply not I$, $(M and D) or C$, $I$; Conclusion: $M iff D$
  + _Crocodiles can consume cute capybaras only if incarcerating iguanas isn't illegal.
    Mad monkeys make mayhem and dinosaurs do disco dance, unless crocodiles consume cute capybaras.
    It is known that incarcerating iguanas is illegal.
    Therefore, dinosaurs do disco dance if and only if mad monkeys make mayhem._
]


== Problem 4: Deductive Proofs with Basic Rules

For each given argument, construct a deductive proof in Fitch notation using only basic inference rules.

#tasklist("prob4", cols: 1)[
  + $not not A$ (conclusion: $A$)
    (Double negation elimination)

  + $((A imply B) imply A)$ (conclusion: $A$)
    (Peirce's law)

  + $(not B imply not A)$ (conclusion: $A imply B$)
    (Contraposition)

  + $not(A or B)$ (conclusion: $not A and not B$)
    (De Morgan's law)

  + $(not A and not B)$ (conclusion: $not(A or B)$)
    (De Morgan's law, converse)

  + $(A imply B) and (not A imply B)$ (conclusion: $B$)
    (Proof by cases)
]


== Problem 5: Tautology Proofs

For each given tautology, construct a deductive proof in Fitch notation.

#tasklist("prob5", cols: 2)[
  + $(A imply B) or (B imply A)$

  + $A imply (B imply A)$

  #colbreak()

  + $(not B imply not A) imply ((not B imply A) imply B)$

  + $(A imply (B imply C)) imply ((A imply B) imply (A imply C))$
]


// == Problem 6: Reduction to Boolean Satisfiability (SAT)

// Reduce _any three_ of the following problems to the Boolean satisfiability problem ($SAT$).
// Collaborate with your classmates to cover distinct problems from different domains.

// Provide a detailed encoding of each chosen problem into logical variables and propositional constraints.
// While your encoding does not have to be in CNF, explain how high-level constraints (such as arithmetic conditions) translate into propositional logic.
// Additionally, discuss possible extensions or variations for each problem.

// #block(width: 100%)[
//   *Available Problems:*

//   0. _*(Do not pick this one!)*_ *Graph Coloring:*
//   Determine if a given graph $G = (V, E)$ can be properly colored with $k$ colors so that no two adjacent vertices share the same color.

//   1. *Sudoku Puzzle:*
//   Determine if a partially filled $9 times 9$ Sudoku grid can be completed so that each row, column, and $3 times 3$ sub-grid contains each digit from 1 to 9 exactly once.

//   2. *N-Queens Problem:*
//   Place $N$ queens on an $N times N$ chessboard so that no two queens threaten each other (no shared row, column, or diagonal).

//   3. *Hamiltonian Cycle:*
//   Determine if a given directed graph $G = (V, E)$ contains a Hamiltonian cycle that visits each vertex exactly once and returns to the starting point.

//   4. *Clique:*
//   Determine if a graph $G = (V, E)$ has a $k$-clique: a complete subgraph on $k$ vertices.

//   5. *Vertex Cover:*
//   Determine if a graph $G = (V, E)$ has a vertex cover of size $k$: a set of vertices touching all edges.

//   6. *Tiling Problem:*
//   Determine if a given rectangular region can be tiled (without gaps or overlaps) using a specified set of shapes (e.g., dominoes or tetrominoes).

//   7. *3D Packing Problem:*
//   Determine if a set of 3D rectangular objects can fit into a container of fixed dimensions without overlapping, possibly rotating the objects as necessary.

//   8. *Exact Cover Problem:*
//   Given a universe $U$ and a collection of subsets, determine if there exists a sub-collection of these subsets that covers each element of $U$ exactly once.

//   9. *Cryptarithm Solver:*
//   Given a cryptarithm (e.g., `SEND` + `MORE` = `MONEY`), assign a unique digit to each letter so that the resulting arithmetic equation holds true.

//   10. *Boolean Formula Synthesis:*
//   Given a Boolean function $f: {0,1}^n to {0,1}$, construct a Boolean formula in a form of a parse tree with $k$ nodes (logic connectives and variables) that computes $f$.

//   11. *Boolean Circuit Synthesis:*
//   Given a Boolean function $f: {0,1}^n to {0,1}^m$, construct a Boolean circuit with $k$ logic gates that computes $f$.

//   12. *Logical Equivalence Check:*
//   Determine if two given Boolean circuits are equivalent (i.e., they compute the same Boolean function).

//   13. *Scheduling Problem:*
//   Assign $n$ tasks to $m$ time slots and $k$ processors. Each task should be scheduled exactly once, precedence constraints must be satisfied, tasks sharing a resource cannot overlap, and tasks requiring multiple time slots must be scheduled contiguously.

//   14. *Pancake Sorting:*
//   Given a stack of pancakes of varying sizes, determine a sequence of flips (each flip reverses the order of the top portion of the stack) to sort the stack with the largest pancake at the bottom.

//   15. *Latin Square:*
//   Determine if a partially filled $n times n$ grid can be completed so that each row and column contains each of $n$ distinct symbols exactly once.

//   16. *Bin Packing Problem:*
//   Given a set of items with sizes and a fixed number of bins with given capacities, determine if all items can be placed into the bins without exceeding any bin's capacity.

//   17. *Betweenness Problem:*
//   Given a set of elements and constraints of the form $(a,b,c)$, meaning that in any acceptable linear ordering of these elements, $b$ must lie between $a$ and $c$, determine if there exists such an ordering that satisfies all betweenness constraints.
// ]

// #block(width: 100%, sticky: true)[
//   *Guidelines for the reduction:*
//   - Define logical variables to represent key properties of the problem (e.g., whether a vertex is assigned a specific color, whether an item is placed in a particular bin, etc.).
//   - Formulate constraints that enforce the rules of the problem in propositional logic.
//   - Show how a solution to the SAT instance corresponds to a solution of the original problem.
//   - Verify that your reduction captures all valid solutions of the original problem.
// ]

// #block(width: 100%)[
//   *Example Solution: Graph Coloring*

//   + Define variables $x_{v,c}$ for each vertex $v in V$ and color $c in {1, dots, k}$, where $x_{v,c}=1$ if vertex $v$ is assigned color $c$.

//   + Add constraints ensuring each vertex is assigned exactly one color:

//     $ or.big_(c=1)^k x_{v,c} quad "for all" v in V $

//     $ not(x_{v,c} and x_{v,c'}) quad "for all" v in V, c eq.not c' $

//   + Add constraints ensuring no two adjacent vertices share the same color:

//     $ not(x_{u,c} and x_{v,c}) quad "for all" (u,v) in E, c in {1, dots, k} $

//   + Optionally, fix a specific vertex and color to reduce symmetries:

//     $ x_(1,1) = 1 $

//   + *Possible extensions and variations:*
//     - _Bounded coloring:_ Require each color to be used at least $t_("min")$ and at most $t_("max")$ times.
//     - _Exact coloring:_ Ensure every pair of colors appears on exactly one pair of adjacent vertices.
// ]

// #block(width: 100%)[
//   *Example Solution: Knapsack Problem*

//   + Define variables $x_i$ for each item $i$, where $x_i = 1$ if item $i$ is included.

//   + Add constraints to ensure the total weight does not exceed the limit $W$:

//     $ sum_i w_i x_i <= W $

//   + Formulate the objective (though SAT is a decision problem, you can encode the optimization problem as a series of checks):

//     $ sum_i v_i x_i >= V_"target" $

//   + *Possible extensions and variations:*
//     - _Fractional knapsack:_ Allow items to be broken into smaller pieces.
//     - _Multiple knapsacks:_ Consider multiple knapsacks with different weight limits.
// ]


#line(length: 100%, stroke: 0.4pt)

*Submission Guidelines:*
- Organize solutions clearly with problem numbers and parts.
- For proofs: State assumptions, show logical steps, and clearly mark conclusions.

*Grading Rubric:*
- Correctness of symbolizations and proofs: 50%
- Logical rigor and clarity of reasoning: 30%
- Completeness and attention to detail: 20%

#import "theme.typ": *
#show: slides.with(
  title: [Boolean Satisfiability],
  subtitle: "Discrete Math",
  date: "Fall 2025",
  authors: "Konstantin Chukharev",
)

#show heading.where(level: 1): none

#import "common-lec.typ": *
#import "@preview/oxifmt:1.0.0": strfmt


= Boolean Satisfiability
#focus-slide(
  epigraph: [Can machines think?],
  epigraph-author: [Alan Turing],
  scholars: (
    (
      name: "Stephen Cook",
      image: image("assets/Stephen_Cook.jpg"),
    ),
    (
      name: "Leonid Levin",
      image: image("assets/Leonid_Levin.jpg"),
    ),
    (
      name: "Richard Karp",
      image: image("assets/Richard_Karp.jpg"),
    ),
    (
      name: "Marijn Heule",
      image: image("assets/Marijn_Heule.jpg"),
    ),
    (
      name: "Armin Biere",
      image: image("assets/Armin_Biere.jpg"),
    ),
    (
      name: "João Marques-Silva",
      image: image("assets/Joao_Marques-Silva.jpg"),
    ),
  ),
)

== A Puzzle to Start

#align(center, text(size: 1.2em)[
  *You're given a formula. Can you make it true?*
])

#v(0.5em)

#align(center)[
  #box(stroke: 2pt + blue, inset: 1em, radius: 5pt)[
    $ (x or y) and (not x or z) and (not y or not z) $
  ]
]

#v(0.5em)

#columns(2)[
  Try $x = 1, y = 1, z = 1$:
  - $(1 or 1)$ #YES
  - $(0 or 1)$ #YES
  - $(0 or 0)$ #NO

  #colbreak()

  Try $x = 1, y = 0, z = 1$:
  - $(1 or 0)$ #YES
  - $(0 or 1)$ #YES
  - $(1 or 0)$ #YES #h(1em) *Found it!*
]

#Block(color: yellow)[
  This is the *Boolean Satisfiability Problem* (SAT) --- _the_ central problem in computer science.
]

== Why Should You Care?

#grid(
  columns: 2,
  gutter: 1.5em,
  Block(color: blue)[
    *\$475 million bug*

    In 1994, Intel's Pentium had a floating-point division bug.

    _Now:_ Every Intel CPU is verified using SAT solvers.
  ],
  Block(color: green)[
    *1/3 of security bugs*

    Microsoft's SAGE tool found 1/3 of all Windows 7 security vulnerabilities.

    _How?_ By encoding programs as SAT formulas.
  ],
)

#v(0.5em)

#Block(color: orange)[
  *The paradox:* SAT is proven to be "computationally hard" (NP-complete), yet modern solvers routinely handle formulas with _millions_ of variables!
]

== The SAT Problem

#definition[
  A formula $phi$ is _satisfiable_ if:
  $ exists (x_1, ..., x_n) in {0,1}^n : thin phi(x_1, ..., x_n) = 1 $
]

#grid(
  columns: 2,
  gutter: 1em,
  Block(color: green)[
    #align(center)[*Satisfiable (SAT)*]

    $(x or y) and (not x or z) and (not y or not z)$

    $x = 1, y = 0, z = 1$ #YES
  ],
  Block(color: red)[
    #align(center)[*Unsatisfiable (UNSAT)*]

    $(x or y) and (not x or y) and (not y)$

    No assignment works. #NO
  ],
)

== Validity (TAUT)

#definition[
  A formula $phi$ is _valid_ (a _tautology_) if:
  $ forall (x_1, ..., x_n) in {0,1}^n : thin phi(x_1, ..., x_n) = 1 $
]

#grid(
  columns: 2,
  gutter: 1em,
  Block(color: green)[
    #align(center)[*Valid*]

    $(x or y) or (not x and not y)$

    True for all $x, y$. #YES
  ],
  Block(color: red)[
    #align(center)[*Not valid*]

    $(x or y) and (not x or z)$

    False when $x = 0, y = 0$. #NO
  ],
)

== SAT vs TAUT

#grid(
  columns: 2,
  gutter: 1em,
  Block(color: blue)[
    #align(center)[*SAT*]

    $ exists X : phi(X) = 1 thin ? $

    At least one satisfying assignment?
  ],
  Block(color: purple)[
    #align(center)[*TAUT*]

    $ forall X : phi(X) = 1 thin ? $

    All assignments satisfying?
  ],
  grid.cell(colspan: 2, align: center)[
    #cetz.canvas({
      import cetz.draw: *

      rect((-4, -1.5), (4, 1), fill: gray.transparentize(90%), stroke: 1pt, radius: 5pt)
      content((0, -1.5), [All $2^n$ assignments], anchor: "north", padding: 0.2)

      circle((-2.5, 0), radius: 0.4, fill: green.transparentize(50%), stroke: 1pt + green)
      content((-2.5, -0.9), text(fill: green.darken(20%))[SAT: $exists$ one])

      for x in range(-1, 4) {
        circle((0.8 * x + 1, 0), radius: 0.3, fill: green.transparentize(50%), stroke: 1pt + green)
      }
      content((1.6, -0.9), text(fill: purple.darken(20%))[TAUT: $forall$ all])
    })
  ],
)

== SAT-TAUT Duality

#theorem[
  $phi$ is valid iff $not phi$ is unsatisfiable.

  $
    "TAUT"(phi) equiv not "SAT"(not phi)
  $
]

#example[
  Is $(x and y) -> (x or y)$ a tautology?

  Check if $not((x and y) -> (x or y))$ is unsatisfiable:
  $ not((x and y) -> (x or y)) = (x and y) and not(x or y) = (x and y) and (not x and not y) $

  Requires $x = 1$ and $x = 0$ simultaneously --- contradiction! UNSAT.

  Therefore, $(x and y) -> (x or y)$ is a tautology. #YES
]

A SAT solver can check both satisfiability and validity.

== Applications

#grid(
  columns: 2,
  gutter: 1em,
  [
    *Hardware Verification*
    - CPU correctness (Intel, AMD)
    - Circuit equivalence checking

    *Software Analysis*
    - Bug finding, test generation
    - Program verification
  ],
  [
    *Artificial Intelligence*
    - Planning, scheduling
    - Constraint satisfaction

    *Cryptography*
    - Cipher analysis
    - Hash function attacks
  ],
)

*SAT Competition* (since 2002): CaDiCaL, Kissat, Glucose, CryptoMiniSat.

== Historical Notes

- *1928:* Hilbert's _Entscheidungsproblem_ --- can we decide mathematical truth?
- *1936:* Turing & Church: No (for general mathematics).
- *1971:* Cook--Levin theorem: SAT is NP-complete.

For Boolean formulas:
- SAT _is_ decidable (try all $2^n$ assignments)
- Question: can we do better than $O(2^n)$?

#Block(color: blue)[
  *P vs NP problem:* Is there a polynomial-time algorithm for SAT?

  Most believe: *no*. But no proof exists.
]


= CNF: The Language of SAT Solvers
#focus-slide()

== Building Blocks: Literals

#definition[
  A _literal_ is a variable or its negation.
]

#example[
  - $x$ is a _positive literal_
  - $not x$ (also written $overline(x)$ or $dash.en x$) is a _negative literal_
]

#grid(
  columns: 2,
  gutter: 1em,
  Block(color: green)[
    *Positive literal $x$:*

    True when $x = 1$

    False when $x = 0$
  ],
  Block(color: red)[
    *Negative literal $not x$:*

    True when $x = 0$

    False when $x = 1$
  ],
)

We denote the _complement_ of literal $l$ as $overline(l)$: if $l = x$, then $overline(l) = not x$, and vice versa.

== Building Blocks: Clauses

#definition[
  A _clause_ is a disjunction (OR) of literals:
  $ C = (l_1 or l_2 or dots or l_k) $
]

#example[
  $(x or not y or z)$ is a clause with 3 literals.
]

#Block(color: yellow)[
  *To satisfy a clause:* At least one literal must be true.
]

#example[
  Clause $(x or not y or z)$ is satisfied by:
  - $x = 1$ (any $y, z$) #YES
  - $y = 0$ (any $x, z$) #YES
  - $z = 1$ (any $x, y$) #YES
  - $x = 0, y = 1, z = 0$ #NO --- all literals false!
]

== Conjunctive Normal Form (CNF)

#definition[
  A formula is in *CNF* if it is a conjunction (AND) of clauses:
  $ F = C_1 and C_2 and dots and C_m $
]

#example[
  $ (x or y) and (not x or z) and (not y or not z) $
  This CNF has 3 clauses over 3 variables.
]

#Block(color: yellow)[
  *To satisfy a CNF:* Every clause must have at least one true literal.

  *CNF is unsatisfiable if:* Any clause has all literals false.
]

== Special Cases

#definition[
  A *unit clause* has exactly one literal: $(x)$ or $(not y)$.
]

#definition[
  The *empty clause* $square$ has no literals --- it's always false!
]

#example[
  - Unit clause $(x)$ forces $x = 1$
  - Unit clause $(not y)$ forces $y = 0$
  - Empty clause $square$ means the formula is *UNSAT*
]

#Block(color: orange)[
  *Key insight:* Unit clauses force variable assignments.

  This is the foundation of the *Unit Propagation* algorithm!
]

== CNF vs DNF

#grid(
  columns: 2,
  gutter: 1em,
  Block(color: blue)[
    *CNF* (AND of ORs)

    $(a or b) and (c or d)$

    #v(0.5em)
    - *SAT is hard* (NP-complete)
    - *TAUT is easy* (P)
    - Check: any clause all-false?
  ],
  Block(color: green)[
    *DNF* (OR of ANDs)

    $(a and b) or (c and d)$

    #v(0.5em)
    - *SAT is easy* (P)
    - *TAUT is hard* (co-NP)
    - Check: any term all-true?
  ],
)

#Block(color: yellow)[
  *Why the asymmetry?*

  CNF SAT: Must satisfy _all_ clauses simultaneously --- hard constraint.

  DNF SAT: Just find _one_ satisfiable term --- easy search.
]

== The Conversion Problem

*Problem:* How do we convert an arbitrary formula to CNF?

#Block(color: orange)[
  *Naive conversion can explode!*

  $(x_1 and y_1) or (x_2 and y_2) or dots or (x_n and y_n)$

  Direct CNF: $2^n$ clauses (exponential blowup!)
]

#example[
  $(a and b) or (c and d)$ converts to:
  $ (a or c) and (a or d) and (b or c) and (b or d) $
  4 clauses for 2 terms. With $n$ terms: $2^n$ clauses!
]

We need a smarter approach...

== Tseitin Transformation

#definition[
  Tseitin transformation is a method to convert any formula $phi$ into an _equisatisfiable_ CNF formula $F$ of size $O(|phi|)$ (instead of exponential) by introducing _auxiliary variables_ for subformulas.
]

*Idea:* For each subformula $psi$, introduce a fresh variable $t$ and encode $t <-> psi$.

#example[
  Formula: $(a and b) or c$

  Introduce $t$ for $(a and b)$:
  - $t <-> (a and b)$ encodes as: $(not t or a) and (not t or b) and (t or not a or not b)$

  Final CNF: $(t or c) and (not t or a) and (not t or b) and (t or not a or not b)$
]

#Block(color: yellow)[
  *Key:* Tseitin CNF is _equisatisfiable_ (same SAT/UNSAT status), not equivalent.

  That's all we need for SAT solving!
]

== Tseitin Encodings for Gates

#align(center)[
  #table(
    columns: 3,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Gate*], [*Meaning*], [*CNF clauses*]),
    [$t <-> not a$], [$t = not a$], [$(t or a) and (not t or not a)$],
    [$t <-> a and b$], [$t = a and b$], [$(not t or a) and (not t or b) and (t or not a or not b)$],
    [$t <-> a or b$], [$t = a or b$], [$(t or not a) and (t or not b) and (not t or a or b)$],
    [$t <-> a -> b$], [$t = not a or b$], [$(t or a) and (t or not b) and (not t or not a or b)$],
    [$t <-> a <-> b$], [$t = (a equiv b)$], [$(not t or not a or b) and (not t or a or not b) and ...$],
  )
]

#Block(color: blue)[
  *Each gate adds a constant number of clauses.*

  Total CNF size: $O(|phi|)$ --- linear in formula size!
]

== Satisfying a CNF Formula

#Block(color: blue)[
  *To satisfy a CNF formula:*
  - Each clause must have _at least one_ true literal.
  - All clauses must be satisfied _simultaneously_.
]

#example[
  Formula: $(x or y) and (not x or z) and (not y or not z)$

  Try $x = 1, y = 1, z = 0$:
  - Clause 1: $(1 or 1) = 1$ #YES
  - Clause 2: $(0 or 0) = 0$ #NO

  Try $x = 1, y = 0, z = 1$:
  - Clause 1: $(1 or 0) = 1$ #YES
  - Clause 2: $(0 or 1) = 1$ #YES
  - Clause 3: $(1 or 0) = 1$ #YES

  Found satisfying assignment!
]

== Decision vs Search

#definition[
  _Decision SAT_ is the problem: given a CNF formula $F$, determine whether $F$ is satisfiable (Yes/No).
]

#definition[
  _Search SAT_ (or _functional SAT_) is the problem: given a satisfiable CNF formula $F$, find a satisfying assignment.
]

#Block(color: yellow)[
  *In practice:*
  - Decision and search have the same complexity (both NP-complete)
  - Modern SAT solvers do both: return SAT + model, or UNSAT
]

#example[
  Input: $(x or y) and (not x or y) and (not y or z)$

  Decision answer: *SAT*

  Search answer: $x = 0, y = 1, z = 1$
]


= Complexity of SAT
#focus-slide()

== The Brute Force Approach

#Block(color: orange)[
  *Naive algorithm:* Try all possible assignments.

  - For $n$ variables: $2^n$ possible assignments
  - Check each assignment in $O(m)$ time (where $m$ = number of clauses)
  - Total: $O(m dot 2^n)$ --- exponential!
]

#example[
  - $n = 10$: $1024$ assignments (instant)
  - $n = 20$: $approx 10^6$ assignments (seconds)
  - $n = 50$: $approx 10^15$ assignments (years!)
  - $n = 100$: $approx 10^30$ assignments (heat death of universe)
]

#Block(color: yellow)[
  *Key question:* Is there a polynomial-time algorithm for SAT?

  This is the famous *P vs NP* problem --- worth \$1 million!
]

== Complexity Classes: P and NP

#definition[
  The _complexity class $P$_ consists of problems solvable in polynomial time by a deterministic algorithm.

  Examples: sorting, shortest path, linear programming.
]

#definition[
  The _complexity class $"NP"$_ consists of problems where a "yes" answer can be _verified_ in polynomial time.

  Equivalently: solvable in polynomial time by a _nondeterministic_ algorithm.
]

#Block(color: blue)[
  *SAT is in NP:*
  Given a satisfying assignment (certificate), we can verify it in $O(n + m)$ time by evaluating each clause.
]

== NP-Completeness

#definition[
  A problem $X$ is _NP-hard_ if every problem in NP can be _reduced_ to $X$ in polynomial time.
]

#definition[
  A problem is _NP-complete_ if it is both in NP and NP-hard.

  NP-complete problems are the "hardest" problems in NP.
]

#Block(color: yellow)[
  *If you solve ANY NP-complete problem in polynomial time, you solve ALL of them!*

  This would prove P = NP and revolutionize computer science.
]

== The Cook--Levin Theorem

#theorem[Cook--Levin (1971)][
  SAT is NP-complete.

  That is, SAT is in NP, and _any_ problem in NP can be _reduced_ to SAT in polynomial time.
]

#Block(color: teal)[
  *Historical significance:*
  - First problem proven NP-complete
  - Independently discovered by Stephen Cook (1971) and Leonid Levin (1973)
  - Foundation of computational complexity theory
]

#Block(color: blue)[
  *Consequence:* If we could solve SAT in polynomial time, we could solve:
  - Traveling salesman, graph coloring, scheduling, ...
  - Cryptographic problems, protein folding, ...
  - Essentially all "hard" combinatorial problems!
]

== Proof Sketch: SAT is NP-complete

#proof[(SAT $in$ NP)][
  A satisfying assignment serves as a _certificate_ that can be verified in linear time by evaluating each clause.
]

#proof[(SAT is NP-hard, sketch)][
  For any problem $L in "NP"$, there exists a polynomial-time verifier $V$.

  Given input $x$, we construct a formula $phi_x$ such that:
  - $phi_x$ encodes the computation of $V$ on $x$ with certificate $c$
  - Variables represent: machine state, tape contents, head position at each step
  - Clauses enforce: valid initial state, transition rules, acceptance

  Then: $x in L$ iff $phi_x$ is satisfiable.

  Construction is polynomial in $|x|$.
]

#Block(color: yellow)[
  This result means SAT is a "universal" problem --- all of NP reduces to it.
]

== Karp's 21 NP-Complete Problems (1972)

Richard Karp showed 21 classic problems are NP-complete by reducing SAT to them.

#align(center)[
  #import fletcher: diagram, edge, node
  #diagram(
    spacing: (12mm, 10mm),
    node-stroke: 1pt,
    node-corner-radius: 3pt,
    edge-stroke: 1pt,
    // Level 0: SAT
    blob((0, 0), [*SAT*], tint: red, name: <sat>),
    // Level 1: 3-SAT
    blob((0, 1), [3-SAT], tint: orange, name: <3sat>),
    edge(<sat>, <3sat>, "-|>"),
    // Level 2: branching from 3-SAT
    blob((-2.5, 2), [Clique], tint: blue, name: <clique>),
    blob((-1.5, 2), [3-Coloring], tint: blue, name: <3col>),
    blob((-0.5, 2), [Vertex Cover], tint: blue, name: <vc>),
    blob((0.5, 2), [Subset Sum], tint: blue, name: <ss>),
    blob((1.5, 2), [Ham. Cycle], tint: blue, name: <hc>),
    blob((2.5, 2), [Partition], tint: blue, name: <part>),
    edge(<3sat>, <clique>, "-|>", bend: -20deg),
    edge(<3sat>, <3col>, "-|>", bend: -15deg),
    edge(<3sat>, <vc>, "-|>", bend: -10deg),
    edge(<3sat>, <ss>, "-|>", bend: 10deg),
    edge(<3sat>, <hc>, "-|>", bend: 15deg),
    edge(<3sat>, <part>, "-|>", bend: 20deg),
    // Level 3: further reductions
    blob((-2.5, 3), [Indep. Set], tint: green, name: <is>),
    blob((-1.5, 3), [Chromatic], tint: green, name: <chrom>),
    blob((-0.5, 3), [Set Cover], tint: green, name: <setcov>),
    blob((0.5, 3), [Knapsack], tint: green, name: <knap>),
    blob((1.5, 3), [TSP], tint: green, name: <tsp>),
    blob((2.5, 3), [Bin Packing], tint: green, name: <binp>),
    edge(<clique>, <is>, "-|>"),
    edge(<3col>, <chrom>, "-|>"),
    edge(<vc>, <setcov>, "-|>"),
    edge(<ss>, <knap>, "-|>"),
    edge(<hc>, <tsp>, "-|>"),
    edge(<part>, <binp>, "-|>"),
  )
]

#Block(color: yellow)[
  To prove that problem $X$ is NP-complete: _reduce_ a known NP-complete problem (e.g., 3-SAT) to $X$.
]

== SAT Variants: The Complexity Landscape

#definition[
  _$k$-SAT_ is SAT restricted to formulas where each clause has exactly $k$ literals.
]

#grid(
  columns: 2,
  gutter: 1em,
  Block(color: green)[
    *In P (polynomial time):*
    - *1-SAT:* Trivial (unit propagation)
    - *2-SAT:* $O(n + m)$ via implication graphs
    - *Horn-SAT:* At most one positive literal per clause --- $O(n dot m)$
    - *XOR-SAT:* Gaussian elimination --- $O(n^3)$
  ],
  Block(color: red.lighten(50%))[
    *NP-complete:*
    - *3-SAT:* The "minimal" hard case
    - *$k$-SAT* for all $k >= 3$
    - *NAE-SAT:* Not-all-equal SAT
    - *1-in-3 SAT:* Exactly one true per clause
  ],
)

#Block(color: yellow)[
  *The phase transition:* Going from 2-SAT to 3-SAT crosses the P/NP boundary!

  This is one of the sharpest complexity transitions known.
]

== 2-SAT: A Polynomial Algorithm

#definition[
  The _implication graph_ for a 2-SAT formula $phi$ is a directed graph $G_phi$ where:
  - Nodes: literals $x$ and $not x$ for each variable
  - Edges: $(not a, b)$ and $(not b, a)$ for each clause $(a or b)$
]

#example[
  Formula: $(x or y) and (not x or z)$

  #align(center)[
    #import fletcher: diagram, edge, node
    #diagram(
      spacing: 3em,
      node-stroke: 1pt,
      edge-stroke: 1pt,
      // Row 0: positive literals
      blob((0, 0), $x$, tint: blue, name: <x>),
      blob((1, 0), $y$, tint: blue, name: <y>),
      blob((2, 0), $z$, tint: blue, name: <z>),
      // Row 1: negative literals
      blob((0, 1), $overline(x)$, tint: orange, name: <nx>),
      blob((1, 1), $overline(y)$, tint: orange, name: <ny>),
      blob((2, 1), $overline(z)$, tint: orange, name: <nz>),
      // From (x or y): ¬x → y, ¬y → x
      edge(<nx>, <y>, "-|>"),
      edge(<ny>, <x>, "-|>"),
      // From (¬x or z): x → z, ¬z → ¬x
      edge(<x>, <z>, "-|>", bend: 30deg),
      edge(<nz>, <nx>, "-|>", bend: 30deg),
    )
  ]

  Clause $(a or b)$ becomes implications $not a -> b$ and $not b -> a$.
]

#theorem[2-SAT Characterization][
  A 2-SAT formula is unsatisfiable iff there exists a variable $x$ such that $x$ and $not x$ are in the same strongly connected component of $G_phi$.
]

#Block(color: blue)[
  *Algorithm:* Tarjan's SCC in $O(n + m)$ $=>$ 2-SAT in linear time!
]


= SAT Solving Algorithms
#focus-slide()

== How to Solve SAT?

#Block(color: blue)[
  Despite exponential worst-case complexity, modern SAT solvers are remarkably effective:

  - Handle industrial instances with millions of variables
  - Often find solutions in seconds or minutes
  - Based on _clever search strategies_ and _learning_
]

#grid(
  columns: 2,
  gutter: 1em,
  [
    *Key techniques:*
    - Unit propagation
    - Pure literal elimination
    - Backtracking search (DPLL)
    - Conflict-driven clause learning (CDCL)
    - Variable selection heuristics
  ],
  [
    *Modern solvers:*
    - MiniSat, CryptoMiniSat
    - Glucose, Lingeling
    - CaDiCaL, Kissat
    - Z3, CVC5 (SMT solvers)
  ],
)

== Unit Propagation

#definition[
  _Unit propagation_ is the following simplification rule: if a CNF formula contains a _unit clause_ $(l)$, then:
  + Set the literal $l$ to true
  + Remove all clauses containing $l$ (they are satisfied)
  + Remove $overline(l)$ from all remaining clauses
]

#place(right)[
  #set align(left)
  #Block(color: yellow)[
    Unit propagation is the _workhorse_ of \ SAT solvers --- fast and effective!
  ]
]

#example[
  Formula: $(x or y) and (not x or z) and (x)$

  Unit clause $(x)$ forces $x = 1$:
  - Remove $(x or y)$ and $(x)$, since they contain $x$
  - Remove $not x$ from $(not x or z)$

  Result: $(z)$ --- another unit clause!

  Continue: $z = 1$, formula simplifies to $top$, i.e., the formula is _satisfied_.
]

== Pure Literal Elimination

#definition[
  A literal $l$ is _pure_ if it appears in the formula but $overline(l)$ does not.
]

#definition[
  The _pure literal rule_ states: if a literal $l$ is pure, then:
  + Set $l$ to true
  + Remove all clauses containing $l$
]

#example[
  Formula: $(x or y) and (x or z) and (y or z)$

  The literal $x$ is pure (only positive occurrences).

  Set $x = 1$, remove clauses containing $x$:

  Result: $(y or z)$ --- simpler formula!
]

#Block(color: yellow)[
  Pure literals can always be set to true without losing satisfiability.
]

== The DPLL Algorithm

#definition[
  _DPLL_ (Davis--Putnam--Logemann--Loveland, 1962) is a complete backtracking algorithm for SAT:

  + *Simplify:* Apply unit propagation and pure literal elimination
  + *Check:* If no clauses remain, return SAT; if empty clause exists, return UNSAT
  + *Branch:* Choose an unassigned variable $x$
    - Try $x = 1$; if SAT, return SAT
    - Otherwise, try $x = 0$; return result
]

#Block(color: blue)[
  *Key properties:*
  - _Complete:_ always finds a solution if one exists
  - _Sound:_ only returns SAT if formula is satisfiable
  - Worst case: exponential time (unavoidable unless P = NP)
]

== DPLL: Visual Example

#example[
  #grid(
    columns: (1fr, auto),
    gutter: 1em,
    [
      Formula: $(x or y) and (not x or y) and (not y or z) and (not z)$

      DPLL explores:
      - Branch $x = 1$: unit prop gives $y = 1$, then $z = 1$ --- conflict with $(not z)$!
      - Backtrack, try $x = 0$: unit prop gives $y = 1$, then $z = 1$ --- same conflict!

      Both branches lead to conflict $=>$ *UNSAT*.
    ],
    [
      #import fletcher: diagram, edge, node
      #diagram(
        spacing: (1em, 2em),
        node-stroke: none,
        edge-stroke: 0.8pt,
        // Root
        node((0, 0), $phi$, name: <root>),
        // Level 1: branch on x
        node((-1, 1), $x = 1$, name: <x1>),
        node((1, 1), $x = 0$, name: <x0>),
        edge(<root>, <x1>, "-}>"),
        edge(<root>, <x0>, "-}>"),
        // Left branch: x=1
        node((-1, 2), $y = 1$, name: <y1>),
        node((-1, 3), $z = 1$, name: <z1>),
        node((-1, 4), text(fill: red)[$bot$], name: <c1>),
        edge(<x1>, <y1>, "-}>"),
        edge(<y1>, <z1>, "-}>"),
        edge(<z1>, <c1>, "-}>", stroke: red),
        // Right branch: x=0
        node((1, 2), $y = 1$, name: <y0>),
        node((1, 3), $z = 1$, name: <z0>),
        node((1, 4), text(fill: red)[$bot$], name: <c0>),
        edge(<x0>, <y0>, "-}>"),
        edge(<y0>, <z0>, "-}>"),
        edge(<z0>, <c0>, "-}>", stroke: red),
      )
    ],
  )
]

== Conflict-Driven Clause Learning (CDCL)

#Block(color: blue)[
  Modern SAT solvers use CDCL --- an enhanced version of DPLL.

  *Key insight:* When we hit a conflict, _learn from it_!

  Analyze _why_ the conflict occurred, and add a new clause to prevent repeating the same "mistake".
]

// #definition[Clause learning][
//   When a conflict occurs, analyze _why_ it happened and add a new clause that prevents the same conflict pattern in the future.
// ]

#align(center)[
  #import fletcher: diagram, edge, node
  #diagram(
    spacing: (4em, 2em),
    node-corner-radius: 3pt,
    edge-stroke: 1pt,
    edge-corner-radius: 5pt,
    mark-scale: 80%,
    blob(
      (0, 0),
      [Propagate],
      tint: blue,
      shape: fletcher.shapes.rect,
      name: <propagate>,
    ),
    blob(
      (1, 0),
      [Conflict?],
      tint: yellow,
      shape: fletcher.shapes.diamond,
      name: <conflict>,
    ),
    blob(
      (2, 0),
      [Analyze &\ Learn],
      tint: orange,
      shape: fletcher.shapes.rect,
      name: <learn>,
    ),
    blob(
      (1, 1),
      [All vars\ assigned?],
      tint: yellow,
      shape: fletcher.shapes.diamond,
      name: <check>,
    ),
    blob(
      (2, 1),
      [SAT],
      tint: green,
      shape: fletcher.shapes.pill,
      inset: 1em,
      name: <sat>,
    ),
    blob(
      (0, 1),
      [Decide],
      tint: green,
      shape: fletcher.shapes.rect,
      name: <decide>,
    ),
    edge(<propagate>, "-|>", <conflict>),
    edge(<conflict>, "-|>", <learn>, label-side: right)[yes],
    edge(<conflict>, "-|>", <check>)[no],
    edge(<check>, "-|>", <sat>)[yes],
    edge(<check>, "-|>", <decide>)[no],
    edge(<decide>, "-|>", <propagate>),
    edge(<learn>, <propagate>, "-|>", bend: -20deg, floating: true),
  )
]

#Block(color: yellow)[
  CDCL can _skip_ large parts of the search space by learning conflict clauses.
]

== Implication Graphs & Conflict Analysis

#definition[
  An _implication graph_ is a DAG tracking why each literal was assigned:
  - Decision nodes: literals chosen by branching
  - Propagation nodes: literals forced by unit propagation
  - Edges: from antecedent literals to implied literal
]

#align(center)[
  #import fletcher: diagram, edge, node
  #diagram(
    spacing: 4em,
    node-stroke: 1pt,
    edge-stroke: 1pt,
    // Decision node (column 0)
    blob((0, 0), [$x = 1$], tint: green, shape: fletcher.shapes.rect, name: <x>),
    blob((0, 1), text(size: 0.8em)[_decision_]),
    // Propagated nodes (column 1) - y above, z below
    blob((1, -0.5), [$y = 0$], tint: blue, name: <y>),
    blob((1, 0.5), [$z = 1$], tint: blue, name: <z>),
    // w node (column 2)
    blob((2, 0), [$w = 0$], tint: blue, name: <w>),
    // Conflict node (column 3)
    blob((3, 0), [$kappa$], tint: red, shape: fletcher.shapes.circle, name: <conf>),
    blob((3, 1), text(size: 0.8em, fill: red)[_conflict_]),
    // Edges: x -> y, x -> z
    edge(
      <x>,
      <y>,
      "-|>",
      label: text(size: 0.8em)[$(not x or not y)$],
      label-angle: auto,
      label-side: left,
    ),
    edge(
      <x>,
      <z>,
      "-|>",
      label: text(size: 0.8em)[$(not x or z)$],
      label-angle: auto,
      label-side: right,
    ),
    // Edges: y -> w, z -> w via clause (not y or z or not w)
    edge(
      <y>,
      <w>,
      "-|>",
      label: text(size: 0.8em)[$(y or not z or not w)$],
      label-side: left,
      label-anchor: "south-west",
      label-sep: 1pt,
    ),
    edge(
      <z>,
      <w>,
      "-|>",
      // bend: -30deg,
      label: text(size: 0.8em)[$(y or not z or not w)$],
      label-side: right,
      label-anchor: "north-west",
      label-sep: 1pt,
    ),
    // Edges to conflict
    edge(
      <w>,
      <conf>,
      "-|>",
      stroke: red,
      label: text(size: 0.8em, fill: red)[$(w or not z)$],
    ),
    edge(
      <z>,
      <conf>,
      "-|>",
      stroke: red,
      bend: -30deg,
      label: text(size: 0.8em, fill: red)[$(w or not z)$],
      label-angle: auto,
      label-side: right,
    ),
  )
]

#pagebreak()

Clauses correspond to implications, visualized as edges in the graph:

#v(-0.5em)
#align(center)[
  #table(
    columns: 2,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Clause*], [*Implication*]),
    $(not x or not y)$, $x imply not y$,
    $(not x or z)$, $x imply z$,
    $(y or not z or not w)$, $(y and z) imply not w$,
    $(w or not z)$, $(not w and z) imply bot$,
  )
]
#v(-0.5em)

#definition[
  The _first UIP_ (unique implication point) scheme derives the conflict clause by finding a cut in the implication graph that separates the conflict from the last decision.

  The *1st UIP* finds the closest such cut --- most effective in practice!
]

#v(-0.5em)

#Block(color: orange)[
  *Non-chronological backtracking:* Jump back to the decision level of the _second-highest_ literal in the learned clause --- can skip many levels!
]

== Alternative Learning Schemes

#Block(color: blue)[
  *1st UIP* is standard, but alternatives exist:

  - *All-UIP:* Learn all UIPs at current level
  - *Last UIP (Decision):* Learn clause containing only decision variables
  - *RelSAT scheme:* Learn clause of minimum size
]

#theorem[1st UIP Optimality][
  1st UIP produces _shortest_ asserting clause at the current level.
]

#Block(color: yellow)[
  *Empirical result:* 1st UIP dominates in practice, but combining different learning schemas can help on specific instances.
]

== Lookahead Solvers

#definition[
  A _lookahead solver_ probes each variable before branching:
  - Temporarily set $x = 0$, propagate, measure effects
  - Temporarily set $x = 1$, propagate, measure effects
  - Choose variable that maximizes some criterion
]

#grid(
  columns: 2,
  gutter: 1em,

  Block(color: blue)[
    *Lookahead benefits:*
    - Detects failed literals (probing gives conflict)
    - Learns _necessary assignments_
    - Computes better branching heuristic
  ],

  Block(color: orange)[
    *Lookahead drawbacks:*
    - Expensive: $O(n)$ propagations per decision
    - Doesn't learn clauses as effectively as CDCL
  ],
)

#Block(color: yellow)[
  *Best of both worlds:* Use lookahead for cube generation, CDCL for solving --- _cube-and-conquer_.
]

== Phase Saving

#definition[
  _Phase saving_ is a heuristic that remembers the last assignment of each variable.

  When branching on $x$, first try $x$'s previous value.
]

#Block(color: blue)[
  *Why it helps:*
  - Good assignments tend to remain good after restarts
  - Avoids re-exploring same wrong choices
  - Very cheap to implement (just remember last value)
]

#Block(color: yellow)[
  *Combined with restarts:* Phase saving + aggressive restarts = very effective!

  Solver can restart frequently while preserving good partial solutions.
]

== The Two-Watched Literals Scheme

#Block(color: teal)[
  *The bottleneck:* Unit propagation happens millions of times --- must be FAST!
]

#definition[
  The _two-watched literals_ scheme maintains pointers to exactly two unassigned literals ("watches") for each clause.

  *Key property:* Only check a clause when one of its watched literals becomes false.
]

#grid(
  columns: (auto, 1fr),
  gutter: 1em,

  Block(color: blue)[
    *Why it works:*
    - If both watches are unassigned or true $=>$ clause is not unit
    - When a watch becomes false, search for a new unassigned literal
    - If none found and other watch is unassigned $=>$ unit clause!
    - If none found and other watch is false $=>$ conflict!
  ],

  Block(color: yellow)[
    *Impact:* Chaff (2001) introduced this, achieving 10--100× speedup!

    Two-watched literals is the _standard_ in all modern SAT solvers.
  ],
)

== Variable Selection Heuristics

#grid(
  columns: 2,
  gutter: 1em,
  [
    #Block(color: blue, width: 100%)[
      *VSIDS* (Variable State Independent Decaying Sum):
      - Each variable has an _activity score_
      - Increment score when variable appears in a conflict
      - Periodically _decay_ all scores (multiply by 0.95)
      - Always branch on the highest-scoring variable
    ]
    #Block(color: green, width: 100%)[
      *Why VSIDS works:*
      - Recently conflicting variables are "hot" --- likely relevant
      - Decay ensures we don't get stuck on old conflicts
      - Focuses search on the "active" part of the formula
    ]
  ],
  Block(color: orange)[
    *Modern variants:*

    - *CHB* (Conflict History-Based): \ learning rate adaptation

    - *LRB* (Learning Rate Branching): \ exponential moving average

    - *VMTF* (Variable Move To Front): \ simpler, sometimes effective
  ],
)

== Restarts: The Counter-Intuitive Trick

#Block(color: yellow)[
  *Observation:* Sometimes CDCL gets stuck in a "bad" part of the search space.

  *Solution:* Periodically _restart_ the search from scratch!
]

#definition[
  A _restart policy_ specifies when to restart the search: after $k$ conflicts, undo all decisions but keep learned clauses.
]

#grid(
  columns: 2,
  gutter: 1em,
  [
    *Common policies:*
    - *Luby sequence:* 1, 1, 2, 1, 1, 2, 4, 1, 1, 2, 1, 1, 2,~4,~8,~... \ (optimal for Las Vegas algorithms)
    - *Geometric:* $k, k dot r, k dot r^2, ...$ (e.g., $k = 100$, $r = 1.5$)
    - *Glucose-style:* Restart when recent learned clauses have high LBD
  ],
  Block(color: blue)[
    *Why restarts help:*
    - Escape from bad variable orderings
    - Learned clauses persist $=>$ \ progress is not lost
    - Combines exploration with exploitation
  ],
)


= Encoding Problems as SAT
#focus-slide()

== The SAT Encoding Recipe

#Block(color: blue)[
  *General approach to solve any problem with SAT:*

  + *Variables:* Define propositional variables to represent the problem's state
  + *Constraints:* Encode requirements as Boolean formulas
  + *CNF:* Convert to conjunctive normal form
  + *Solve:* Run a SAT solver
  + *Decode:* Interpret the solution (if SAT)
]

#example[
  *Problem:* Schedule 3 tasks without conflicts

  *Variables:* $t_(i,s) =$ "task $i$ runs in slot $s$"

  *Constraints:*
  - Each task runs in some slot: $(t_(1,1) or t_(1,2)) and dots$
  - No two tasks in same slot: $(not t_(1,1) or not t_(2,1)) and dots$
]

== Example: Graph Coloring

#definition[
  A _graph $k$-coloring_ is an assignment of one of $k$ colors to each vertex of a graph $G = (V, E)$ such that adjacent vertices have different colors.
]

#Block(color: blue)[
  *SAT encoding:*

  Variables: $x_(v,c)$ = "vertex $v$ has color $c$"

  Constraints:
  - Each vertex has at least one color: $or.big_c x_(v,c)$ for each $v$
  - Each vertex has at most one color: $(not x_(v,c_1) or not x_(v,c_2))$ for $c_1 eq.not c_2$
  - Adjacent vertices differ: $(not x_(u,c) or not x_(v,c))$ for each edge $(u,v)$
]

#example[
  Triangle with 3 colors: 9 variables, 24 clauses.

  SAT solver finds coloring instantly!
]

== Example: Sudoku as SAT

#Block(color: teal)[
  A standard 9×9 Sudoku puzzle can be encoded as a SAT instance:

  *Variables:* $x_(r,c,d)$ = "cell $(r,c)$ contains digit $d$" --- 729 variables

  *Constraints:*
  - Each cell has exactly one digit (81 cells × 36 clauses)
  - Each row has all digits (9 rows × 9 digits × 36 clauses)
  - Each column has all digits (9 columns × 9 digits × 36 clauses)
  - Each 3×3 box has all digits (9 boxes × 9 digits × 36 clauses)
  - Given clues (unit clauses)
]

#Block(color: yellow)[
  *Result:* $approx$ 12,000 clauses total.

  Modern SAT solvers solve any Sudoku in _milliseconds_!
]

== Complete SAT Workflow Example

#Block(color: blue)[
  *Problem:* Schedule 3 tasks on 2 time slots with constraints.

  Tasks: $A$, $B$, $C$. Slots: 1, 2. Constraint: $A$ and $B$ cannot be in the same slot.
]

*Step 1: Variables* --- $t_(X,s)$ = "task $X$ in slot $s$"

#v(-0.5em)
#align(center)[
  #table(
    columns: 3,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([], [*Slot 1*], [*Slot 2*]),
    [$A$], [$t_(A,1)$], [$t_(A,2)$],
    [$B$], [$t_(B,1)$], [$t_(B,2)$],
    [$C$], [$t_(C,1)$], [$t_(C,2)$],
  )
]
#v(-1em)

*Step 2: Clauses*
- Each task in some slot: $(t_(A,1) or t_(A,2))$, $(t_(B,1) or t_(B,2))$, $(t_(C,1) or t_(C,2))$
- Conflict constraint: $(not t_(A,1) or not t_(B,1))$ and $(not t_(A,2) or not t_(B,2))$

*Step 3: Solve* --- SAT! Model: $t_(A,1) = 1$, $t_(B,2) = 1$, $t_(C,1) = 1$

*Step 4: Decode* --- $A$ in slot 1, $B$ in slot 2, $C$ in slot 1 #YES

== Example: Ramsey Numbers

#definition[Ramsey Number][
  The _Ramsey number_ $R(r, s)$ is the smallest $n$ such that any 2-coloring of edges of $K_n$ contains either a red $K_r$ or a blue $K_s$.
]

#example[Finding $R(3,3) = 6$][
  Can we 2-color edges of $K_5$ without monochromatic triangles?

  #place(right, dx: -3em)[
    #import fletcher: diagram, edge, node
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      {
        // Pentagon with colored edges
        let n = 5
        let r = 1.2cm
        for i in range(1, n + 1) {
          let angle = 90deg + (i - 1) * (360deg / n)
          node((angle, r), str(i), outset: 1pt, name: label(str(i)))
        }
        // Edges: outer pentagon in red, inner star in blue
        for i in range(1, n + 1) {
          for k in range(i + 1, n + 1) {
            let is-adjacent = (k - i == 1) or (i == 1 and k == 5)
            edge(
              label(str(i)),
              label(str(k)),
              "-",
              stroke: if is-adjacent { 2pt + red } else { 1pt + blue },
            )
          }
        }
      },
    )
  ]

  *Encoding:*
  - Variables: $e_(i,j)$ = "edge $(i,j)$ is red"
  - For each triangle $(i,j,k)$:
    - Not all red: $(not e_(i,j) or not e_(j,k) or not e_(i,k))$
    - Not all blue: $(e_(i,j) or e_(j,k) or e_(i,k))$

  SAT solver: *SAT* for $K_5$, *UNSAT* for $K_6$.

  Therefore $R(3,3) = 6$.
]

== SAT Encoding: At-Most-One Constraint

A common constraint: "at most one of $x_1, ..., x_n$ is true."

#Block(color: blue)[
  *Pairwise encoding:*
  $ and.big_(1 <= i < j <= n) (not x_i or not x_j) $

  This generates $binom(n, 2) = n(n-1)/2$ clauses.
]

#example[
  For $n = 4$ variables: 6 clauses.

  $(not x_1 or not x_2) and (not x_1 or not x_3) and (not x_1 or not x_4) and$
  $(not x_2 or not x_3) and (not x_2 or not x_4) and (not x_3 or not x_4)$
]

#Block(color: orange)[
  *Warning:* For large $n$, this encoding grows quadratically.
  Advanced encodings (commander, ladder) use $O(n)$ clauses.
]

== SAT Encoding: Exactly-One Constraint

#definition[
  An _exactly-one constraint_ requires that exactly one of $x_1, ..., x_n$ is true.
]

#Block(color: blue)[
  *Encoding:*

  _At least one:_ $(x_1 or x_2 or dots or x_n)$ --- 1 clause

  _At most one:_ $(not x_i or not x_j)$ for all $i < j$ --- $binom(n, 2)$ clauses
]

#example[
  For task scheduling: "each task runs in exactly one time slot."

  Variables: $t_(i,1), t_(i,2), t_(i,3)$ for task $i$ in slots 1, 2, 3.

  Exactly-one: $(t_(i,1) or t_(i,2) or t_(i,3))$
  $and (not t_(i,1) or not t_(i,2)) and (not t_(i,1) or not t_(i,3)) and (not t_(i,2) or not t_(i,3))$
]


= Advanced Encodings
#focus-slide()

== XOR Constraints and Gaussian Elimination

#definition[
  An _XOR clause_ is a constraint requiring an odd number of literals to be true:
  $ x_1 xor x_2 xor dots xor x_n = 1 $
]

#Block(color: orange)[
  *Problem:* XOR of $n$ variables requires $2^(n-1)$ CNF clauses!

  $(x xor y xor z)$ becomes $(x or y or z) and (x or not y or not z) and (not x or y or not z) and (not x or not y or z)$
]

#Block(color: blue)[
  *Solution: Native XOR support*

  CryptoMiniSat and other solvers handle XOR constraints _natively_:
  - Gaussian elimination over GF(2)
  - Linear algebra instead of search
  - Polynomial time for pure XOR systems
]

#example[
  Cryptographic problems (AES, SHA) have many XOR constraints.

  CryptoMiniSat: 100$times$ faster than standard SAT on crypto instances!
]

== Parity Reasoning

#definition[
  _XOR-SAT_ is SAT restricted to XOR clauses only.

  *Solvable in polynomial time* via Gaussian elimination!
]

#grid(
  columns: 2,
  gutter: 1em,

  Block(color: blue)[
    *Hybrid solving:*
    - Maintain CNF and XOR parts separately
    - Propagate assignments between them
    - Use Gaussian elimination for XOR part
  ],

  Block(color: yellow)[
    *Applications:*
    - Cryptanalysis (breaking ciphers)
    - Error-correcting codes (decoding)
    - Randomness testing (analyzing sequences)
  ],
)

#theorem[XOR Reasoning Power][
  Resolution cannot efficiently simulate XOR reasoning.

  Some formulas need exponential resolution proofs but have polynomial XOR proofs.
]

== Cardinality Constraints

#definition[
  A _cardinality constraint_ restricts how many of $x_1, ..., x_n$ can be true:
  - *At-most-$k$:* $sum_(i=1)^n x_i <= k$

  - *At-least-$k$:* $sum_(i=1)^n x_i >= k$

  - *Exactly-$k$:* $sum_(i=1)^n x_i = k$
]

#Block(color: orange)[
  *Challenge:* Naive pairwise encoding for at-most-$k$ requires $O(n^k)$ clauses!

  For $n = 100$, $k = 3$: over 160,000 clauses.
]

#place(right)[
  #set align(center)
  #Block(color: yellow)[
    Choice of encoding dramatically \ affects solver performance!
  ]
]

*Better encodings:*
- *Sequential counter:* $O(n dot k)$ clauses and variables
- *Parallel counter:* $O(n dot log k)$ clauses
- *Sorting networks:* $O(n dot log^2 n)$ clauses
- *BDD-based:* Often optimal in practice

== Sequential Counter Encoding

#definition[
  The _sequential counter_ encoding (Sinz, 2005) introduces auxiliary variables $s_(i,j)$ meaning "at least $j$ of $x_1, ..., x_i$ are true."
]


#place(right)[
  #set align(left)
  #Block(color: blue)[
    *Advantage:* UP achieves _arc consistency_
  ]
]

#align(left)[
  #table(
    columns: 5,
    align: center,
    stroke: none,
    table.header([], [*$x_1$*], [*$x_2$*], [*$x_3$*], [*$x_4$*]),
    [*count $>= 1$*], [$s_(1,1)$], [$s_(2,1)$], [$s_(3,1)$], [$s_(4,1)$],
    [*count $>= 2$*], [], [$s_(2,2)$], [$s_(3,2)$], [$s_(4,2)$],
  )
]

*Key clauses:*
- $x_i -> s_(i,1)$: input contributes to count
- $s_(i-1,j) -> s_(i,j)$: propagate count forward
- $x_i and s_(i-1,j-1) -> s_(i,j)$: increment when both true
- $not s_(n,k+1)$: forbid exceeding limit (for at-most-$k$)

#example[
  At-most-2 constraint: add clause $not s_(4,3)$ (count never reaches 3).

  If $x_1 = x_2 = x_3 = 1$, propagation sets $s_(3,3) = 1$ $=>$ conflict!
]

== Arithmetic in SAT: Bit-Blasting

#definition[
  _Bit-blasting_ encodes integer variables as bit-vectors and arithmetic operations as Boolean circuits.
]

#example[Integer addition][
  $z = x + y$ where $x, y, z$ are 4-bit integers.

  Variables: $x_0, x_1, x_2, x_3$ (bits of $x$), similarly for $y, z$.

  Encode using full adders:
  - $z_i = x_i xor y_i xor c_(i-1)$ (sum bit)
  - $c_i = (x_i and y_i) or (c_(i-1) and (x_i xor y_i))$ (carry)
]

#Block(color: yellow)[
  *Applications:*
  - Software verification (bounded model checking)
  - Cryptographic analysis
  - SMT bit-vector theory (via bit-blasting to SAT)
]

== Pseudo-Boolean Constraints

#definition[
  A _pseudo-Boolean (PB) constraint_ is a linear inequality over Boolean variables:
  $ sum_(i=1)^n a_i dot x_i <= k quad "where" a_i, k in ZZ $
]

#example[
  $3x_1 + 2x_2 + x_3 + x_4 <= 4$

  Allows at most: $x_1$ alone, or $x_2 + x_3 + x_4$, or $x_2 + x_3$, etc.
]

*Encodings:*
- *Adder networks:* Build binary addition circuit
- *BDD-based:* Construct BDD for the constraint, convert to CNF
- *Sorting networks:* For unweighted or low-weight cases
- *Watchdog encoding:* Generalization of sequential counter

#Block(color: blue)[
  PB constraints are powerful for optimization problems and occur frequently in MaxSAT.
]


= Incremental SAT and Assumptions
#focus-slide()

== Incremental SAT Solving

#definition[
  _Incremental SAT_ is the task of solving a sequence of related SAT problems, reusing information from previous solves.
]

#Block(color: blue)[
  *Common scenarios:*
  - Bounded model checking: $phi_0, phi_0 and phi_1, phi_0 and phi_1 and phi_2, ...$
  - Iterative refinement: add constraints until satisfied
  - AllSAT: repeatedly block found solutions
  - CEGIS: add counterexamples
]

#Block(color: yellow)[
  *Key insight:* Learned clauses from previous solves remain valid!

  Reusing learned clauses can give 10$times$ -- 100$times$ speedup.
]

== Assumption-Based Solving

#definition[
  _Assumptions_ are temporary unit clauses that can be "retracted" between solves.

  `solve(assumptions = [x, ¬y])` acts like adding $(x)$ and $(not y)$, but only for this call.
]

#Block(color: blue)[
  *API (MiniSat-style):*
  ```
  solver.add_clause([x, y, z])       // Permanent
  solver.solve([a, ¬b])              // Temporary assumptions
  solver.solve([¬a, b])              // Different assumptions, same clauses
  ```
]

#example[
  *Checking multiple properties:*

  Base formula: $phi$ (system behavior)

  Check property 1: `solve([¬property1])` --- if UNSAT, property holds

  Check property 2: `solve([¬property2])` --- same base formula!
]

== Unsat Cores via Assumptions

#definition[
  An _unsatisfiable core_ is a subset of clauses that is still unsatisfiable.
]

#Block(color: blue)[
  If `solve(assumptions = [a1, a2, a3, ...])` returns UNSAT, solver can report which assumptions are in the conflict.

  These form an _unsatisfiable core_ --- subset of assumptions sufficient for UNSAT.
]

#example[
  *Debugging infeasible constraints:*

  `solve([constraint1, constraint2, constraint3, constraint4])`

  Returns UNSAT with core: `{constraint1, constraint3}`

  $=>$ Constraints 1 and 3 are mutually incompatible!
]

#Block(color: yellow)[
  *Applications:* MaxSAT (core-guided), diagnosis, debugging, minimal explanations.
]

== Push/Pop Interface

#definition[
  A _context stack_ allows adding and removing clauses in a stack-like manner:
  - `push()`: Save current state
  - `pop()`: Restore to last pushed state, removing added clauses
]

#grid(
  columns: (auto, 1fr),
  gutter: 1em,

  Block(color: blue)[
    *Example:*
    ```
    solver.add(base_clauses)
    solver.push()
    solver.add(additional_clauses)
    result1 = solver.solve()
    solver.pop()  // Removes additional_clauses
    solver.push()
    solver.add(other_clauses)
    result2 = solver.solve()
    ```
  ],

  Block(color: yellow)[
    *Limitation:* Less efficient than assumptions --- learned clauses may become invalid.

    Use assumptions when possible, push/pop for clause structure changes.
  ],
)


= SMT: Advanced Topics
#focus-slide()

== Theory Combination: Nelson-Oppen

#Block(color: orange)[
  *Problem:* SMT formula uses _multiple_ theories simultaneously.

  Example: $(x = y + 1) and (f(x) eq.not f(y + 1))$

  Uses: Linear arithmetic (LIA) + Uninterpreted functions (UF)
]

#definition[
  The _Nelson-Oppen method_ combines theory solvers for _disjoint signature_ theories:
  + Purify: separate theory-specific parts
  + Share equalities between shared variables
  + Iterate until fixed point or conflict
]

#example[
  $(x = y + 1) and (f(x) eq.not f(y + 1))$

  LIA sees: $x = y + 1$

  UF sees: $f(x) eq.not f(y + 1)$

  LIA deduces: $x = y + 1$, shares with UF

  UF deduces: conflict with $f(x) eq.not f(y + 1)$ since arguments equal!
]

== Theory Propagation and Conflict

#Block(color: blue)[
  *DPLL(T) communication:*

  - *SAT $->$ Theory:* "Here's a partial assignment, is it theory-consistent?"
  - *Theory $->$ SAT:* "Conflict!" (theory lemma) or "These literals are implied"
]

#definition[
  _Theory propagation_ is when the theory solver deduces new facts from assigned literals.

  Example: From $x <= y$ and $y <= z$, deduce $x <= z$.
]

#definition[
  A _theory conflict_ occurs when the theory solver finds that an assignment is theory-inconsistent.

  It returns a _theory lemma_ explaining the conflict.
]

#example[
  Assignment: $x > 5$, $y < 3$, $x < y$

  LIA theory: Conflict! $x > 5$ and $x < y$ and $y < 3$ is impossible.

  Lemma: $(x <= 5) or (y >= 3) or (x >= y)$
]

== Lazy vs Eager SMT

#grid(
  columns: 2,
  gutter: 1em,

  Block(color: blue, width: 100%)[
    *Lazy approach (DPLL(T)):*
    - Boolean skeleton to SAT solver
    - Theory solver checks consistency
    - Exchange lemmas on-demand

    *Pros:* Flexible, handles complex theories

    *Cons:* Many theory calls
  ],

  Block(color: green, width: 100%)[
    *Eager approach (bit-blasting):*
    - Compile entire formula to SAT
    - Run pure SAT solver
    - Decode model back

    *Pros:* Simple, SAT solver optimizations

    *Cons:* Huge formulas, loses structure
  ],

  grid.cell(colspan: 2)[
    #Block(color: yellow, width: 100%)[
      *Modern SMT:* Hybrid approaches --- eager for bit-vectors, lazy for arithmetic/arrays.
    ]
  ],
)

== SMT Theories: Details

#definition[
  The _theory of arrays_ provides:
  - *Read:* $"read"(a, i)$ returns element at index $i$
  - *Write:* $"write"(a, i, v)$ returns array with $a[i] = v$

  Axioms:
  - $"read"("write"(a, i, v), i) = v$
  - $i eq.not j imply "read"("write"(a, i, v), j) = "read"(a, j)$
]

#definition[
  The _theory of strings_ includes:
  - Concatenation: $x dot y$
  - Length: $|x|$
  - Contains: $x in y$
  - Regular expressions: $x in L(r)$

  *Challenge:* Undecidable in general! Solvers use heuristics.
]

#Block(color: yellow)[
  *Theory support varies by solver:*
  - Z3: Most complete theory support
  - CVC5: Strong on strings and arithmetic
  - Yices: Fast on linear arithmetic
]


= Parameterized Complexity of SAT
#focus-slide()

== Fixed-Parameter Tractability

#definition[
  A _parameterized problem_ is an instance $(x, k)$ where $x$ is the input and $k$ is a _parameter_.
]

#definition[
  A problem is _fixed-parameter tractable (FPT)_ if it is solvable in time $f(k) dot |x|^(O(1))$ for some computable $f$.

  Exponential in parameter $k$, but _polynomial_ in input size!
]

#Block(color: yellow)[
  *Key insight:* If $k$ is small, FPT algorithms can be practical even when $f(k)$ is large.
]

== FPT Results for SAT

#theorem[Bounded Treewidth][
  SAT restricted to CNF formulas with _treewidth $k$_ is solvable in $O(2^k dot n)$ time.
]

#Block(color: blue)[
  *Treewidth:* Measures how "tree-like" the variable interaction graph is.

  - Tree: treewidth 1
  - Grid: treewidth $sqrt(n)$
  - Complete graph: treewidth $n$
]

#theorem[Backdoor Variables][
  If there exist $k$ variables whose removal makes the formula tractable (e.g., Horn), SAT is FPT parameterized by $k$.
]

#Block(color: yellow)[
  *Practical impact:* Many industrial formulas have small treewidth or backdoors!

  This partially explains why SAT solvers work well despite NP-hardness.
]

== Kernelization

#definition[
  _Kernelization_ is a polynomial-time reduction $(x, k) -> (x', k')$ where $|x'|, k' <= f(k)$.

  It produces a _kernel_ of size depending only on the parameter.
]

#Block(color: orange)[
  *Negative result:* $k$-SAT (parameterized by number of clauses) has no polynomial kernel unless $"NP" subset.eq "coNP/poly"$.

  This is unlikely, so SAT probably cannot be efficiently compressed!
]

#Block(color: blue)[
  *Positive result:* SAT parameterized by _deletion distance to Horn_ has a polynomial kernel.

  If formula is "almost Horn," we can reduce it efficiently.
]


= Extensions and Variants
#focus-slide()

== MaxSAT: Optimization over SAT

#definition[
  _MaxSAT_ is the optimization problem: given a CNF formula, find an assignment that _maximizes_ the number of satisfied clauses.
]

#definition[
  _Weighted MaxSAT_ assigns a weight to each clause; the goal is to maximize the total weight of satisfied clauses.
]

#definition[
  _Partial MaxSAT_ distinguishes two types of clauses:
  - *Hard clauses:* Must be satisfied (weight = $infinity$)
  - *Soft clauses:* Want to satisfy, but not required
]

#example[
  Scheduling with preferences:
  - Hard: "No two meetings at same time"
  - Soft: "Meeting A prefers morning" (weight 5)
  - Soft: "Meeting B prefers afternoon" (weight 3)
]

#Block(color: yellow)[
  *Applications:* Optimization, diagnosis, repair, configuration, planning.

  *Solvers:* MaxHS, RC2, Open-WBO, EvalMaxSAT
]

== MaxSAT Algorithms

#Block(color: blue)[
  *Core-guided approach:*
  + Find an unsatisfiable core (subset of soft clauses that conflict)
  + Add cardinality constraint to allow relaxation
  + Iterate until SAT
]

#Block(color: green)[
  *Branch-and-bound:*
  - Lower bound: current solution quality
  - Upper bound: optimistic estimate
  - Prune when bounds cross
]

#example[
  Formula: $(x) and (not x) and (y)$ (all soft, weight 1)

  Core: ${(x), (not x)}$ --- cannot both be satisfied.

  Relax: at most 1 of these can be true.

  Optimal: satisfy $(y)$ and one of $(x)$, $(not x)$ $=>$ value = 2.
]

== Quantified Boolean Formulas (QBF)

#definition[QBF][
  Boolean formulas with _quantifiers_:
  $ exists x_1. forall x_2. exists x_3. dots phi(x_1, x_2, x_3, ...) $
]

#Block(color: orange)[
  *Complexity:* QBF satisfiability is *PSPACE-complete* --- much harder than NP!
]

#example[
  $exists x. forall y. (x or y) and (not x or not y)$

  Does there exist $x$ such that for _all_ $y$, the formula is true?

  Try $x = 1$: need $(1 or y) and (0 or not y) = 1 and not y$. Fails for $y = 1$.

  Try $x = 0$: need $(0 or y) and (1 or not y) = y and 1 = y$. Fails for $y = 0$.

  *UNSAT* --- no winning strategy for $exists$!
]

#Block(color: yellow)[
  *Applications:* Verification, planning under uncertainty, game solving, synthesis.
]

== Special Cases of SAT

#Block(color: green)[
  Some SAT restrictions are solvable in polynomial time:
]

#definition[2-SAT][
  Each clause has _at most 2 literals_.

  *Solvable in $O(n + m)$* using implication graphs and strongly connected components!
]

#definition[Horn-SAT][
  Each clause has _at most one positive literal_.

  *Solvable in linear time* using unit propagation.
]

#Block(color: yellow)[
  *Key insight:* The jump from 2-SAT to 3-SAT crosses the P/NP boundary!

  3-SAT (each clause has exactly 3 literals) is NP-complete.
]

== The DIMACS Format

#grid(
  columns: 2,
  gutter: 1em,

  Block(color: blue)[
    Standard input format for SAT solvers:

    ```
    c This is a comment
    p cnf 3 4
    1 -2 0
    2 3 0
    -1 -3 0
    1 3 0
    ```
  ],

  Block(color: yellow)[
    *Format:*
    - `p cnf <vars> <clauses>` --- problem line
    - Each clause: space-separated integers, terminated by `0`
    - Positive integer = positive literal, negative = negated
    - Variables numbered $1, 2, 3, ...$
  ],
)

#example[
  The formula $(x_1 or not x_2) and (x_2 or x_3) and (not x_1 or not x_3) and (x_1 or x_3)$
]

== SMT: Satisfiability Modulo Theories

#definition[SMT][
  Extends propositional SAT with _first-order theories_:
  $ phi_"Bool" and phi_"Theory" $
]

#grid(
  columns: (auto, 1fr),
  align: (left, center),
  gutter: 1em,
  [
    *Common theories:*
    - *LRA:* Linear Real Arithmetic
    - *BV:* Bit-Vectors (via bit-blasting)
    - *UF:* Uninterpreted Functions
    - *LIA:* Linear Integer Arithmetic
    - *Arrays:* Read/write axioms
    - *Strings:* String constraints
  ],
  [
    #import fletcher: diagram, edge, node
    #diagram(
      spacing: (2em, 1.5em),
      node-corner-radius: 3pt,
      edge-stroke: 1pt,
      mark-scale: 80%,
      blob(
        (0, 0),
        [*SAT Solver*\ (Boolean reasoning)],
        tint: blue,
        shape: fletcher.shapes.rect,
        name: <sat>,
      ),
      blob(
        (2, 0),
        [*Theory Solver*\ (LIA, LRA, BV, UF...)],
        tint: green,
        shape: fletcher.shapes.rect,
        name: <theory>,
      ),
      edge(<sat>, <theory>, "-|>", [assignment], bend: 40deg),
      edge(<theory>, <sat>, "-|>", [conflict / propagation], bend: 40deg),
    )
  ],
)

#Block(color: yellow)[
  *Major SMT solvers:* Z3 (Microsoft), CVC5, Yices, MathSAT
]

== SMT Example: Program Verification

#example[
  Verify: "if $x > 0$ and $y > 0$, then $x + y > 0$"

  SMT formula (LIA): $(x > 0) and (y > 0) and not(x + y > 0)$

  If UNSAT $=>$ property holds!
]

#Block(color: blue)[
  *Bit-vector theory example:*

  Check if `(x ^ y) & z == (x & z) ^ (y & z)` for all 32-bit integers.

  Encode as: $exists x, y, z. thin (x xor y) and z eq.not (x and z) xor (y and z)$

  SMT solver (via bit-blasting): *UNSAT* $=>$ identity holds!
]

#Block(color: teal)[
  *Real-world usage:*
  - KLEE: symbolic execution for C programs
  - SAGE: whitebox fuzzing at Microsoft
  - SeaHorn: software verification
  - Dafny: verified programming language
]

== SAT in Practice: Hardware Verification

#Block(color: teal)[
  *Real-world success story:*

  Intel's Pentium FDIV bug (1994): \$475 million recall.

  *Now:* All major CPUs are formally verified using SAT/SMT solvers.
]

#Block(color: blue)[
  *How it works:*
  + Describe circuit behavior as Boolean formulas
  + Encode correctness properties
  + Check: "Does there exist an input that violates the property?"
  + If SAT $=>$ bug found; if UNSAT $=>$ property verified
]

#Block(color: yellow)[
  *Scale:* Modern CPU verification involves formulas with _billions_ of clauses.

  Techniques: bounded model checking, interpolation, abstraction refinement.
]


= Applications Deep Dive
#focus-slide()

== Bounded Model Checking (BMC)

#definition[Bounded Model Checking][
  Verify that a property holds for _all_ executions up to $k$ steps by encoding as SAT.
]

#Block(color: blue)[
  *Encoding:*
  - State variables at each time step: $s_0, s_1, ..., s_k$
  - Transition relation: $T(s_i, s_(i+1))$
  - Initial state: $I(s_0)$
  - Property violation: $not P(s_i)$ for some $i$

  Formula: $I(s_0) and and.big_(i=0)^(k-1) T(s_i, s_(i+1)) and or.big_(i=0)^k not P(s_i)$

  If *SAT* $=>$ counterexample found!
]

#align(center)[
  #cetz.canvas(length: 0.7cm, {
    import cetz.draw: *

    // States
    for i in range(4) {
      let name = strfmt("s_{}", i)
      circle(
        (i * 2.8, 0),
        radius: 0.6,
        fill: blue.lighten(80%),
        stroke: 1.2pt + blue.darken(20%),
        name: name,
      )
      content(name, [$s_#i$])
    }
    content((11, 0), text(size: 1.2em)[...], name: "ellipsis")

    // Transitions
    for i in range(3) {
      let from = strfmt("s_{}", i)
      let to = strfmt("s_{}", i + 1)
      let name = strfmt("t_{}", i)
      line(from, to, stroke: 1pt, mark: (end: ">"), name: name)
      content(name, text(size: 0.8em)[$T$], anchor: "south", padding: 0.2)
    }
    line("s_3", "ellipsis", stroke: 1pt, mark: (end: ">"), name: "to-ellipsis")

    // Initial state marker
    content(
      (-1.5, 0),
      text(fill: green.darken(20%), size: 0.8em)[Initial $I(s_0)$],
      anchor: "east",
      padding: 0.2,
      name: "initial",
    )
    line("initial", "s_0", stroke: 1pt + green.darken(20%), mark: (end: ">"))

    // Property checks
    for i in range(4) {
      let node = strfmt("s_{}", i)
      let name = strfmt("p_{}", i)
      content(
        (rel: (0, -2), to: node),
        text(size: 0.8em, fill: orange.darken(20%))[$not P$?],
        anchor: "north",
        padding: 0.2,
        name: name,
      )
      line(node, name, stroke: 0.8pt + orange.darken(20%), mark: (end: ">"))
    }
  })
]

#example[
  Verifying a mutex: "processes $A$ and $B$ never both in critical section."

  Encode: system transitions, check if $"cs"_A and "cs"_B$ is ever reachable.
]

== Circuit SAT and Synthesis

#definition[Circuit SAT][
  Given a Boolean circuit $C$, is there an input $x$ such that $C(x) = 1$?
]

#Block(color: yellow)[
  *Note:* Circuit SAT can be converted to CNF using Tseitin transformation.
]

#definition[Circuit Synthesis][
  Given a specification $phi(x, y)$, find a circuit $C$ such that:
  $ forall x. thin phi(x, C(x)) $
]

#Block(color: blue)[
  *Approach:* Use QBF or incremental SAT solving with counterexample-guided inductive synthesis (CEGIS).

  *CEGIS loop:*
  + Propose candidate circuit $C$
  + Find counterexample $x$ where $C$ fails
  + Add constraint ruling out this failure
  + Repeat until no counterexample exists
]

== SAT for Cryptanalysis

#Block(color: orange)[
  SAT solvers can attack cryptographic primitives!
]

#example[Hash Collision][
  Find $x eq.not y$ such that $H(x) = H(y)$.

  Encode hash function as CNF, add constraint $x eq.not y$ and $H(x) = H(y)$.

  SAT solver searches for collision!
]

#Block(color: blue)[
  *Applications:*
  - Attacking reduced-round versions of SHA, MD5
  - Finding weak keys in block ciphers
  - Algebraic cryptanalysis

  Modern ciphers are designed to resist SAT-based attacks (high degree, many rounds).
]

#Block(color: yellow)[
  *Notable result:* SAT solvers found collisions in reduced MD4 and MD5.
]

== AI Planning with SAT

#definition[Classical Planning][
  Given initial state $I$, goal $G$, and actions $A$, find a sequence of actions reaching $G$.
]

#Block(color: blue)[
  *SAT encoding (SATplan):*
  - Variables: $"action"_(a,t)$ = "action $a$ at time $t$", $"holds"_(f,t)$ = "fluent $f$ true at $t$"
  - Preconditions: action implies preconditions hold
  - Effects: action implies effects hold at next step
  - Frame axioms: unchanged fluents persist
]

#example[
  Blocks world: Stack blocks A, B, C into tower.

  SAT encoding finds: pickup(A), stack(A,B), pickup(C), stack(C,A).
]

#Block(color: yellow)[
  SATplan won the 2004 and 2006 International Planning Competitions!
]

== SAT in Machine Learning

#Block(color: green)[
  *Decision tree learning:*

  Find smallest decision tree consistent with training data $=>$ SAT/MaxSAT encoding!
]

#Block(color: blue)[
  *Neural network verification:*

  Given neural network $N$ and property $P$:
  - Encode $N$ as SMT formula (piecewise-linear for ReLU)
  - Check: exists input violating $P$?

  *Tools:* Reluplex, Marabou, $alpha$-$beta$-CROWN
]

#example[
  Verify: "For any input image $x$ with $||x - x_0|| < epsilon$, classifier output is unchanged."

  This proves _local robustness_ against adversarial perturbations!
]

== Symbolic Execution in Detail

#definition[Symbolic Execution][
  Execute program with _symbolic_ inputs, collecting _path conditions_.

  Each path through the program has a constraint characterizing inputs that take it.
]

#grid(
  columns: 2,
  gutter: 1em,

  Block(color: blue)[
    *Example:*
    ```python
    def abs(x):
        if x < 0:
            return -x
        else:
            return x
    ```

    Path 1: $x < 0$, returns $-x$

    Path 2: $x >= 0$, returns $x$
  ],

  Block(color: yellow)[
    *Using SAT/SMT:*
    - Solve path conditions to generate test inputs
    - Check if dangerous states (crashes, assertions) are reachable
    - Find inputs triggering specific behaviors
  ],
)

== Concolic Testing

#definition[Concolic = Concrete + Symbolic][
  Run program with concrete inputs while maintaining symbolic constraints.

  At each branch, negate a condition to explore new paths.
]

#grid(
  columns: 2,
  gutter: 1em,

  Block(color: blue)[
    *SAGE (Microsoft):*
    + Start with random input
    + Execute symbolically, collect path constraint
    + Negate one constraint, solve with SMT
    + New input explores new path!
    + Repeat
  ],

  Block(color: green)[
    *Results:*
    - SAGE found 1/3 of all security bugs in Windows 7
    - Runs continuously on Microsoft software
    - Has found hundreds of exploitable bugs
  ],
)

== Program Synthesis with SAT

#definition[Syntax-Guided Synthesis (SyGuS)][
  Given a grammar $G$ and specification $phi$:

  Find program $P in G$ such that $forall x. thin phi(x, P(x))$
]

#Block(color: blue)[
  *CEGIS (Counterexample-Guided Inductive Synthesis):*
  + Guess candidate program $P$
  + Check: $exists x. thin not phi(x, P(x))$?
  + If yes: $x$ is counterexample, add constraint, repeat
  + If no: $P$ is correct!
]

#example[
  Synthesize: $max(x, y)$

  Candidate 1: $x$ --- counterexample: $x=0, y=1$

  Candidate 2: $x + y$ --- counterexample: $x=1, y=0$

  Candidate 3: $"ite"(x >= y, x, y)$ --- correct!
]

== SAT for Constraint Solving

#Block(color: teal)[
  *Beyond Boolean constraints:*

  Many constraint satisfaction problems (CSPs) can be encoded as SAT!
]

*Examples:*
- *Scheduling:* Jobs, machines, time constraints
- *Resource allocation:* Assign resources without conflicts
- *Configuration:* Product configuration with compatibility rules
- *Timetabling:* University course scheduling

#Block(color: blue)[
  *Encoding recipe:*
  + Variables: $x_(i,v)$ = "variable $i$ has value $v$"
  + At-least-one: each variable has some value
  + At-most-one: each variable has at most one value
  + Constraints: encode problem-specific rules
]

#Block(color: yellow)[
  *Modern CP solvers* (like OR-Tools, Chuffed) often use SAT as a backend!
]


= Theoretical Depth
#focus-slide()

== Resolution Proof System

#definition[Resolution rule][
  From $(A or x)$ and $(B or not x)$, derive $(A or B)$.

  This is sound and complete for proving unsatisfiability!
]

#align(center)[
  #import fletcher: diagram, edge, node
  #diagram(
    spacing: (3em, 3em),
    node-stroke: 1pt,
    edge-stroke: 1pt,
    node-corner-radius: 3pt,
    // Parent clauses
    node(
      (-0.5, 0),
      [$(A or #text(fill: red)[$x$])$],
      fill: blue.lighten(80%),
      stroke: blue.darken(20%),
      name: <c1>,
    ),
    node(
      (0.5, 0),
      [$(B or #text(fill: red)[$not x$])$],
      fill: blue.lighten(80%),
      stroke: blue.darken(20%),
      name: <c2>,
    ),
    // Resolvent
    node(
      (0, 1),
      [$(A or B)$],
      fill: green.lighten(80%),
      stroke: green.darken(20%),
      name: <res>,
    ),
    // Edges
    edge(<c1>, <res>, "-|>"),
    edge(<c2>, <res>, "-|>"),
    // Annotation
    node((1, 0.5), text(size: 0.9em)[_resolve on $x$_]),
  )
]

#example[
  Prove $(x) and (not x or y) and (not y)$ is UNSAT:

  + $(x)$ and $(not x or y)$ $-->$ $(y)$ #h(1em) [resolve on $x$]
  + $(y)$ and $(not y)$ $-->$ $()$ #h(1em) [resolve on $y$, empty clause!]

  Empty clause $()$ means *UNSAT*.
]

#Block(color: yellow)[
  Every CDCL run produces a resolution proof!

  Learned clauses are derived via resolution from conflict clauses.
]

== Proof Complexity

#definition[Resolution width][
  Minimum width of any clause in a resolution proof.
]

#definition[Resolution size][
  Minimum number of clauses in a resolution proof.
]

#theorem[Width-Size Tradeoff (Ben-Sasson & Wigderson)][
  If resolution refutation has width $w$, then it has size at least $2^(Omega(n"/"w))$.
]

#Block(color: blue)[
  *Implication:* If a formula requires wide clauses to prove UNSAT, the proof must be exponentially long!

  This explains why some formulas are hard for resolution-based solvers.
]

#example[Pigeonhole principle][
  $"PHP"_n^(n+1)$: $n+1$ pigeons, $n$ holes, no two pigeons share a hole.

  Requires resolution proofs of size $2^(Omega(n))$!
]

== Phase Transitions in Random SAT

#Block(color: yellow)[
  *Random $k$-SAT:* Generate $m$ random $k$-clauses over $n$ variables.

  Let $alpha = m"/"n$ be the _clause density_.
]

#align(center)[
  #cetz.canvas(length: 0.6cm, {
    import cetz.draw: *

    // Axes
    line((-1, 0), (12, 0), stroke: 1pt, mark: (end: ">"))
    line((0, -0.5), (0, 7), stroke: 1pt, mark: (end: ">"))
    content((12, -0.8), [$alpha = m "/" n$])
    content((-1.5, 6.5), [Prob(SAT)])

    // Phase transition curve (sigmoid-like)
    let pts = ()
    for i in range(0, 50) {
      let x = i * 0.2
      let y = 5.5 / (1 + calc.exp(2 * (x - 4.267)))
      pts.push((x, y))
    }
    line(..pts, stroke: 2pt + blue)

    // Threshold line
    line((4.267, 0), (4.267, 6), stroke: (dash: "dashed", paint: red))
    content((4.267, -0.8), text(fill: red)[$alpha_c approx 4.267$])

    // Labels
    content((2, 5), text(fill: green.darken(20%))[*SAT region*])
    content((7, 1), text(fill: orange.darken(20%))[*UNSAT region*])

    // Hardness peak annotation
    line((4.267, 3), (6.5, 4.5), stroke: 0.5pt)
    content((7.5, 4.8), text(size: 0.8em)[Hardest instances!])
  })
]

#theorem[Phase Transition][
  For random 3-SAT with $n$ variables and $m = alpha n$ clauses:
  - If $alpha < 4.267$: almost surely *SAT*
  - If $alpha > 4.267$: almost surely *UNSAT*

  The transition is _sharp_ --- probability jumps from near 1 to near 0!
]

#Block(color: blue)[
  This phase transition is analogous to physical phase transitions (like water freezing).
]

== Lower Bounds: Why SAT is Hard

#Block(color: orange)[
  *Current state of proof complexity:*

  No polynomial-size proofs for the pigeonhole principle in:
  - Resolution (exponential lower bound)
  - Bounded-depth Frege (exponential lower bound)

  But we don't know if all proof systems require superpolynomial proofs!
]

#Block(color: blue)[
  *Exponential Time Hypothesis (ETH):*

  3-SAT cannot be solved in time $2^(o(n))$ where $n$ = number of variables.

  This is stronger than P $eq.not$ NP and implies many other lower bounds!
]

#Block(color: yellow)[
  *Strong ETH (SETH):*

  For every $epsilon > 0$, there exists $k$ such that $k$-SAT cannot be solved in $O(2^((1-epsilon)n))$ time.

  SETH implies: many "optimal" algorithms cannot be improved!
]

== CDCL and Proof Complexity

#Block(color: blue)[
  *CDCL = Resolution*

  Every CDCL run implicitly constructs a resolution proof!

  - Decision: start a new branch
  - Unit propagation: apply resolution
  - Conflict analysis: derive learned clause via resolution
  - Backtrack: continue proof construction
]

#theorem[CDCL Power][
  CDCL with restarts can polynomially simulate _any_ resolution proof.

  Without restarts, CDCL is limited to _tree-like_ resolution.
]

#Block(color: yellow)[
  *Implication:* Lower bounds on resolution $=>$ lower bounds on CDCL!

  Pigeonhole principle is hard for CDCL because it's hard for resolution.
]

== Beyond Resolution: Stronger Proof Systems

#definition[Proof System Hierarchy][
  Resolution $<$ Cutting Planes $<$ Frege $<$ Extended Frege

  Each system can simulate all weaker systems with polynomial overhead.
]

#align(center)[
  #cetz.canvas(length: 0.55cm, {
    import cetz.draw: *

    // Stacked boxes showing hierarchy - centered with consistent widths
    rect((-3, 0), (3, 1.3), fill: blue.lighten(85%), stroke: 1pt + blue.darken(20%), radius: 4pt)
    content((0, 0.65), [*Resolution* (SAT/CDCL)])

    rect((-3.3, 2), (3.3, 3.3), fill: green.lighten(85%), stroke: 1pt + green.darken(20%), radius: 4pt)
    content((0, 2.65), [*Cutting Planes* (ILP)])

    rect((-3.6, 4), (3.6, 5.3), fill: yellow.lighten(85%), stroke: 1pt + yellow.darken(20%), radius: 4pt)
    content((0, 4.65), [*Frege* (propositional logic)])

    rect((-4, 6), (4, 7.3), fill: orange.lighten(85%), stroke: 1pt + orange.darken(20%), radius: 4pt)
    content((0, 6.65), [*Extended Frege* (with abbreviations)])

    // Annotations on the right - better positioned
    line((3.2, 0.65), (4.5, 0.65), stroke: 0.6pt + red, mark: (end: ">"))
    content((6.3, 0.65), text(size: 0.65em, fill: red)[PHP hard])

    line((3.5, 2.65), (4.5, 2.65), stroke: 0.6pt + green.darken(30%), mark: (end: ">"))
    content((6.3, 2.65), text(size: 0.65em, fill: green.darken(30%))[PHP easy!])

    // Vertical "stronger" arrow on the left
    line((-5.5, 0.5), (-5.5, 7), stroke: 1pt, mark: (end: ">"))
    content((-5.5, -0.5), text(size: 0.7em)[weaker])
    content((-5.5, 7.8), text(size: 0.7em)[stronger])
  })
]

#Block(color: blue)[
  *Cutting Planes:*
  - Work with linear inequalities over integers
  - Can prove pigeonhole with polynomial-size proofs!
  - Corresponds to integer linear programming

  *Frege (Propositional Logic):*
  - Natural deduction / sequent calculus
  - Can derive any tautology with short proofs
  - No superpolynomial lower bounds known!
]

#Block(color: orange)[
  *Major open problem:* Are there polynomial-size Frege proofs for all tautologies?

  If yes and efficiently constructible $=>$ NP = coNP (unlikely!)
]

== Circuit Complexity and SAT

#Block(color: teal)[
  Deep connection between SAT complexity and circuit lower bounds!
]

#theorem[Natural Proofs Barrier (Razborov-Rudich)][
  "Natural" proof techniques cannot prove superpolynomial circuit lower bounds, assuming strong pseudorandom functions exist.
]

#Block(color: blue)[
  *Why this matters for SAT:*
  - Proving P $eq.not$ NP requires circuit lower bounds
  - Natural proof barrier blocks most known techniques
  - SAT algorithms might be inherently limited
]

#Block(color: yellow)[
  *Positive direction:* Circuit lower bounds for $"ACC"^0$ (Carmosino et al., 2016)

  Progress is slow but ongoing!
]

== Fine-Grained Complexity

#Block(color: blue)[
  *Beyond P vs NP:* Study _exact_ complexity of problems.

  $k$-SAT running times:
  - $k = 3$: best known $O(1.308^n)$ (Hertli, 2014)
  - $k = 4$: best known $O(1.469^n)$
  - General $k$: $O(2^(n(1-1/O(k)))$)
]

#theorem[Sparsification Lemma][
  Any $k$-SAT instance with $m$ clauses can be reduced to $2^(epsilon n)$ instances, each with $O(n)$ clauses, in $2^(epsilon n)$ time.
]

#Block(color: yellow)[
  *Consequence:* Under ETH, SAT complexity depends on number of _variables_, not clauses.

  Dense formulas aren't harder than sparse ones (asymptotically)!
]

== Randomized SAT Algorithms

#definition[PPSZ Algorithm (Paturi et al., 2005)][
  Randomized algorithm for $k$-SAT with best known running time for large $k$.

  + Randomly permute variables
  + For each variable (in order): if value is implied by unit propagation + resolution of width $<= w$, set it; else set randomly
  + Check if assignment satisfies formula
]

#theorem[PPSZ Running Time][
  For random satisfiable $k$-SAT instances:

  Expected time $O(2^(n(1 - mu_k/k)))$ where $mu_k -> infinity$ as $k -> infinity$.

  For 3-SAT: $O(1.308^n)$.
]

#Block(color: yellow)[
  *Key insight:* Resolution can sometimes "deduce" the correct value of a variable, reducing effective branching factor.
]

== Schöning's Algorithm

#definition[Schöning's Algorithm (1999)][
  Simple local search with provable guarantees:

  + Start with random assignment
  + Repeat $3n$ times:
    - If satisfying, return SAT
    - Pick any unsatisfied clause
    - Flip a random variable in it
  + Repeat whole algorithm multiple times
]

#theorem[Schöning's Running Time][
  For $k$-SAT: expected time $O(((2(k-1))/k)^n dot "poly"(n))$

  For 3-SAT: $O(1.334^n)$ --- worse than PPSZ but simpler!
]

#Block(color: blue)[
  *Why it works:* Random walk on Hamming cube. Each flip has $>=1/k$ chance of moving toward solution.
]

== Craig Interpolation

#definition[Craig Interpolant][
  Given $A and B$ is UNSAT:

  An _interpolant_ $I$ is a formula such that:
  - $A imply I$
  - $I and B$ is UNSAT
  - $I$ uses only variables common to $A$ and $B$
]

#Block(color: blue)[
  *From resolution proofs:*

  Given a resolution proof of $A and B => bot$, an interpolant can be extracted in polynomial time!
]

#example[
  $A = (x or y)$, $B = (not x) and (not y)$

  Interpolant: $I = x or y$ (same as $A$ here, but uses only shared variables)
]

#Block(color: yellow)[
  *Applications:*
  - Model checking (unbounded verification)
  - Invariant generation
  - Predicate abstraction refinement
]

== Symmetry Breaking

#definition[Symmetry in SAT][
  Permutation of variables that maps satisfying assignments to satisfying assignments.
]

#Block(color: orange)[
  *Problem:* Symmetries cause redundant search --- solver explores "equivalent" assignments.
]

#Block(color: blue)[
  *Symmetry breaking:*
  + Detect symmetries (graph automorphism)
  + Add _lex-leader_ constraints: only consider "smallest" assignment in each equivalence class
]

#example[
  Graph coloring: colors are interchangeable.

  Without breaking: solver tries (R,G,B), (G,R,B), (B,G,R), ...

  With breaking: fix color of first vertex $=>$ 6$times$ speedup!
]

#Block(color: yellow)[
  *Tools:* BreakID, Shatter, SMS (SAT Modulo Symmetries)
]


= Modern Developments
#focus-slide()

== Local Search and Incomplete Solvers

#Block(color: blue)[
  *Idea:* Don't prove UNSAT, just find satisfying assignments fast!
]

#definition[WalkSAT (Selman et al., 1994)][
  + Start with random assignment
  + While unsatisfied clauses exist:
    - Pick an unsatisfied clause $C$
    - With probability $p$: flip a random variable in $C$
    - Otherwise: flip variable that minimizes broken clauses
]

#Block(color: green)[
  *Advantages:*
  - Very fast on satisfiable instances
  - Scales to millions of variables
  - Works well near phase transition

  *Disadvantages:*
  - Cannot prove UNSAT
  - May not find solutions for hard SAT instances
]

#Block(color: yellow)[
  *Modern variants:* probSAT, Sparrow, YalSAT --- winners of random SAT track!
]

== Parallel and Distributed SAT

#Block(color: blue)[
  *Portfolio approach:*

  Run multiple solvers with different configurations in parallel. First to finish wins!

  *Why it works:* Different solvers excel on different instances.
]

#Block(color: green)[
  *Divide-and-conquer:*
  - Split search space: $phi and x_1 = 0$ and $phi and x_1 = 1$
  - Solve subproblems in parallel
  - Challenge: balancing workload (guiding path selection)
]

#Block(color: orange)[
  *Clause sharing:*

  Parallel threads share learned clauses.

  Challenge: filter useful clauses (too many $=>$ overhead, too few $=>$ wasted learning)

  *Heuristic:* Share only short clauses (LBD $<= 8$).
]

== Cube-and-Conquer

#definition[Cube-and-Conquer][
  Hybrid parallel approach:
  + *Cube phase:* Lookahead solver partitions search space into "cubes" (partial assignments)
  + *Conquer phase:* CDCL solvers solve each cube independently
]

#align(center)[
  #cetz.canvas(length: 0.6cm, {
    import cetz.draw: *

    // Full search space
    rect((0, 0), (10, 5), fill: gray.lighten(90%), stroke: 1pt)
    content((5, 5.5), text(weight: "bold")[Search Space])

    // Cubes (partial assignments)
    rect((0.3, 0.3), (2.2, 2.2), fill: blue.lighten(70%), stroke: 1pt + blue)
    content((1.25, 1.25), text(size: 0.7em)[$x_1=0$\ $x_5=1$])

    rect((2.5, 0.3), (4.4, 2.2), fill: green.lighten(70%), stroke: 1pt + green)
    content((3.45, 1.25), text(size: 0.7em)[$x_1=1$\ $x_3=0$])

    rect((4.7, 0.3), (6.6, 2.2), fill: yellow.lighten(70%), stroke: 1pt + yellow.darken(20%))
    content((5.65, 1.25), text(size: 0.7em)[$x_1=1$\ $x_3=1$])

    rect((6.9, 0.3), (8.8, 2.2), fill: orange.lighten(70%), stroke: 1pt + orange)
    content((7.85, 1.25), text(size: 0.7em)[$x_2=0$\ $x_7=1$])

    content((9.5, 1.25), text(size: 0.8em)[...])

    // Labels
    content((5, 3.5), text(size: 0.8em)[Lookahead: split into cubes])
    content((5, -0.8), text(size: 0.8em)[CDCL: solve each cube in parallel])
  })
]

#Block(color: blue)[
  *Why it works:*
  - Lookahead is good at finding hard splitting variables
  - CDCL is good at solving structured subproblems
  - Cubes are independent $=>$ embarrassingly parallel
]

#example[
  Pythagorean triples theorem:
  - Cube phase: 800,000 cubes generated
  - Conquer phase: solved on 800 cores in 2 days
  - Result: UNSAT (200TB proof)
]

#Block(color: yellow)[
  Cube-and-conquer solved several long-standing mathematical problems!
]

== Machine Learning in SAT

#Block(color: yellow)[
  *Neural-guided CDCL:*

  Train neural network to predict:
  - Variable branching scores (replace VSIDS)
  - Restart timing
  - Which clauses to learn/forget
]

#Block(color: blue)[
  *NeuroSAT (Selsam et al., 2019):*

  Graph neural network that predicts SAT/UNSAT directly from formula structure!
]

#align(center)[
  #cetz.canvas(length: 0.6cm, {
    import cetz.draw: *

    // Variables (left side) - evenly spaced
    for i in range(4) {
      circle((-4, -i * 1.8), radius: 0.5, fill: blue.lighten(70%), stroke: 1pt + blue.darken(20%))
      content((-4, -i * 1.8), text(size: 0.65em)[$x_#(i + 1)$])
    }
    content((-4, 1.2), text(size: 0.7em, weight: "bold")[Variables])

    // Clauses (right side) - aligned with variables
    for i in range(3) {
      rect(
        (3.5, -i * 1.8 - 0.9 - 0.35),
        (4.5, -i * 1.8 - 0.9 + 0.35),
        fill: green.lighten(70%),
        stroke: 1pt + green.darken(20%),
        radius: 3pt,
      )
      content((4, -i * 1.8 - 0.9), text(size: 0.65em)[$C_#(i + 1)$])
    }
    content((4, 1.2), text(size: 0.7em, weight: "bold")[Clauses])

    // Bipartite edges - cleaner routing
    // x1 -> C1, C2
    line((-3.5, 0), (3.5, -0.9), stroke: 0.7pt + gray.darken(20%))
    line((-3.5, 0), (3.5, -2.7), stroke: 0.7pt + gray.darken(20%))
    // x2 -> C1, C3
    line((-3.5, -1.8), (3.5, -0.9), stroke: 0.7pt + gray.darken(20%))
    line((-3.5, -1.8), (3.5, -4.5), stroke: 0.7pt + gray.darken(20%))
    // x3 -> C2
    line((-3.5, -3.6), (3.5, -2.7), stroke: 0.7pt + gray.darken(20%))
    // x4 -> C2, C3
    line((-3.5, -5.4), (3.5, -2.7), stroke: 0.7pt + gray.darken(20%))
    line((-3.5, -5.4), (3.5, -4.5), stroke: 0.7pt + gray.darken(20%))

    // Message passing annotation
    content((0, -2.7), std.rotate(-8deg, text(size: 0.7em, fill: purple)[message passing]))

    // Output arrow and label
    line((5.5, -2.7), (7.5, -2.7), stroke: 1.2pt, mark: (end: ">"))
    content((9, -2.2), text(size: 0.75em)[SAT/UNSAT])
    content((9, -3.2), text(size: 0.75em)[+ assignment])
  })
]

#Block(color: green)[
  *Current limitations:*
  - Still slower than engineered solvers on most benchmarks
  - Requires domain-specific training
  - Hard to prove correctness

  *Promise:* Hybrid systems combining ML predictions with verified reasoning.
]

== SAT for Combinatorics and Mathematics

#Block(color: teal)[
  SAT solvers have settled long-standing mathematical conjectures!
]

*Notable results:*
- *Boolean Pythagorean Triples (2016):* $n = 7824$ is the threshold
- *Schur Number Five (2017):* $S(5) = 160$
- *Keller's Conjecture (2020):* Disproved in dimension 8
- *Chromatic Number of the Plane:* Lower bound improved to 5 (2018)

#Block(color: blue)[
  *Methodology:*
  + Encode combinatorial problem as SAT
  + Use cube-and-conquer for parallelization
  + Generate machine-checkable UNSAT proof
  + Verify with certified checker

  Result: Computer-assisted _proof_, not just computation!
]

== Satisfiability Attacks

#Block(color: orange)[
  *Algebraic attacks on cryptography:*

  Encode cipher as SAT, attack by solving!
]

#example[
  *Side-channel + SAT:*

  Known: partial information about key (from power analysis)

  Encode: cipher structure + partial key constraints

  SAT solver: recovers full key!
]

#Block(color: blue)[
  *SAT-based attacks succeeded against:*
  - Stream ciphers (Trivium, Grain)
  - Reduced-round block ciphers
  - Hash functions (MD4, MD5, SHA-1 reduced)
  - Public-key primitives (factoring small RSA)
]

#Block(color: yellow)[
  Modern ciphers are designed with SAT resistance in mind --- high algebraic degree, many rounds.
]

== SAT Solver Portfolio Selection

#definition[Algorithm Selection Problem][
  Given instance features, predict which solver will perform best.
]

#Block(color: blue)[
  *SATzilla approach:*
  + Extract syntactic features (clause/variable ratio, graph properties, etc.)
  + Train classifier on solver performance data
  + At runtime: compute features, select predicted-best solver
]

#Block(color: yellow)[
  *Feature examples:*
  - Clause length distribution
  - Variable-clause graph diameter
  - Proximity to phase transition
  - Horn clause fraction
]

#Block(color: green)[
  SATzilla and successors consistently win SAT Competition portfolio tracks!
]


= History and Key Figures
#focus-slide()

== Historical Timeline

#grid(
  columns: (1fr, 3fr),
  gutter: 1em,
  [*1936*], [Turing, Church: Undecidability of Entscheidungsproblem],
  [*1960*], [Davis--Putnam procedure (DP)],
  [*1962*], [Davis--Logemann--Loveland: DPLL algorithm],
  [*1971*], [Cook: SAT is NP-complete],
  [*1972*], [Karp: 21 NP-complete problems],
  [*1992*], [DIMACS format standardized],
  [*1994*], [Selman: WalkSAT (local search)],
  [*1996*], [Marques-Silva & Sakallah: GRASP (first CDCL)],
  [*1999*], [Moskewicz et al.: Chaff (VSIDS, 2WL)],
  [*2003*], [Eén & Sörensson: MiniSat],
  [*2009*], [Audemard & Simon: Glucose (LBD, aggressive restarts)],
  [*2016*], [Heule, Kullmann, Marek: Pythagorean triples (200TB proof)],
)

== Pioneers of SAT

#grid(
  columns: 2,
  gutter: 1em,

  Block(color: blue)[
    *Stephen Cook* (1971)
    - Proved SAT is NP-complete
    - Turing Award 1982

    *Leonid Levin* (1973)
    - Independent NP-completeness proof
    - "Universal search" algorithm
  ],

  Block(color: green)[
    *João Marques-Silva*
    - Invented CDCL (GRASP, 1996)
    - Conflict clause learning
    - Non-chronological backtracking

    *Matthew Moskewicz*
    - Chaff solver (1999)
    - VSIDS heuristic
    - Two-watched literals
  ],
)

#Block(color: yellow)[
  *Modern contributors:* Armin Biere, Niklas Eén, Niklas Sörensson, Marijn Heule
]

== The Largest Proofs Ever

#Block(color: teal)[
  *Boolean Pythagorean Triples (2016):*

  "Can ${1,2,...,7824}$ be 2-colored so no monochromatic Pythagorean triple?"

  Answer: *NO*

  Proof: 200 terabytes (compressed to 68GB), verified by independent checker.
]

#Block(color: blue)[
  *Schur Number Five (2017):*

  "Can ${1,2,...,160}$ be 5-colored with no monochromatic $a+b=c$?"

  Answer: *YES* (161: NO)

  Computed using massively parallel SAT solving.
]

#Block(color: yellow)[
  These are among the largest mathematical proofs ever created --- generated and verified by computers!
]


= Preprocessing and Inprocessing
#focus-slide()

== Why Preprocessing Matters

#Block(color: blue)[
  Before running the main CDCL search, simplify the formula!

  *Goal:* Remove redundant variables and clauses, making the formula smaller and easier to solve.
]

#grid(
  columns: 2,
  gutter: 1em,
  [
    *Preprocessing (before search):*
    - Variable elimination
    - Subsumption
    - Self-subsuming resolution
    - Blocked clause elimination
    - Bounded variable addition
  ],
  [
    *Inprocessing (during search):*
    - Apply simplifications periodically
    - Between restarts
    - Use learned clauses
    - Vivification
    - Probing
  ],
)

#Block(color: yellow)[
  Modern solvers like CaDiCaL and Kissat spend significant effort on preprocessing --- it often determines success or failure!
]

== Variable Elimination (VE)

#definition[Variable Elimination][
  Remove variable $x$ by resolving all clauses containing $x$ with all clauses containing $not x$.
]

#example[
  Clauses with $x$: $(x or a)$, $(x or b)$

  Clauses with $not x$: $(not x or c)$, $(not x or d)$

  Resolvents: $(a or c)$, $(a or d)$, $(b or c)$, $(b or d)$

  Remove original 4 clauses, add 4 resolvents, variable $x$ is eliminated!
]

#Block(color: orange)[
  *Problem:* Can increase clause count! (2 $times$ 2 = 4 resolvents from 4 clauses)

  *Heuristic:* Only eliminate $x$ if the number of clauses decreases or stays same.
]

#Block(color: yellow)[
  VE is the core of the SatELite preprocessor (used in MiniSat, Glucose).
]

== Subsumption

#definition[Subsumption][
  Clause $C$ _subsumes_ clause $D$ if $C subset.eq D$.

  If $C$ subsumes $D$, then $D$ is _redundant_ and can be removed.
]

#example[
  $(x or y)$ subsumes $(x or y or z)$.

  Remove $(x or y or z)$ --- it's implied by the shorter clause!
]

#definition[Self-Subsuming Resolution][
  If resolving $C$ with $D$ produces a clause that subsumes $C$, strengthen $C$.
]

#example[
  $C = (x or y or z)$, $D = (not x or y)$

  Resolvent: $(y or z)$ subsumes $C$!

  Replace $C$ with $(y or z)$ (shorter clause).
]

== Blocked Clause Elimination (BCE)

#definition[Blocked Clause][
  Clause $C$ with literal $l$ is _blocked_ on $l$ if every resolvent of $C$ on $l$ is a tautology.
]

#example[
  $C = (x or a or b)$, and all clauses with $not x$ have form $(not x or not a or ...)$ or $(not x or not b or ...)$.

  Every resolution produces $(a or b or not a or ...)$ --- tautology!

  $C$ is blocked and can be safely removed.
]

#Block(color: yellow)[
  BCE can remove many clauses without changing satisfiability!

  *Key insight:* Blocked clauses are "useless" for unit propagation.
]

== Bounded Variable Addition (BVA)

#definition[Bounded Variable Addition][
  _Add_ auxiliary variables to make the formula smaller!
]

#example[
  Clauses: $(a or b or c)$, $(a or b or d)$, $(a or b or e)$

  Introduce $x = (a or b)$:

  New clauses: $(x or c)$, $(x or d)$, $(x or e)$, $(not x or a or b)$

  Reduced from 9 literals to 8 literals!
]

#Block(color: blue)[
  *BVA reverses Tseitin:* Instead of expanding definitions, we _create_ definitions for common subexpressions.

  Very effective on structured formulas from hardware verification.
]

== Vivification

#definition[Vivification][
  Try to shorten clauses by temporarily assuming their negation and propagating.
]

#Block(color: blue)[
  *Algorithm:*
  + For clause $(l_1 or l_2 or ... or l_k)$
  + Temporarily set $l_1 = 0$, propagate
  + If conflict, clause can be shortened to $(l_1)$
  + If $l_2$ propagates, continue with $l_3$, etc.
  + Result: potentially shorter clause
]

#example[
  Clause $(a or b or c)$, and $(not a)$ propagates to $b = 1$.

  Then clause can be strengthened to $(a or b)$!
]

#Block(color: yellow)[
  Vivification is expensive but very effective --- used in top solvers during inprocessing.
]


= Certified UNSAT: DRAT Proofs
#focus-slide()

== Why Certify UNSAT?

#Block(color: orange)[
  *Problem:* SAT solvers are complex ($>$50,000 lines of code). How do we trust an UNSAT answer?

  - Bugs in implementation
  - Hardware errors (bit flips)
  - Adversarial inputs
]

#Block(color: blue)[
  *Solution:* Produce a _proof_ that can be independently verified!

  - Solver produces proof alongside answer
  - Simple checker verifies proof
  - Trust shifts to small, simple checker
]

#Block(color: yellow)[
  Since 2014, SAT Competition requires UNSAT proofs for all UNSAT answers!
]

== Resolution Proofs

#definition[Resolution Proof][
  A sequence of clauses where each clause is either:
  - An original clause from the formula, or
  - Derived by resolution from two previous clauses

  A proof of UNSAT ends with the empty clause $square$.
]

#example[
  Formula: $(x or y)$, $(not x)$, $(not y)$

  Proof:
  + $(x or y)$ #h(2em) [original]
  + $(not x)$ #h(2em) [original]
  + $(y)$ #h(3em) [resolve 1,2 on $x$]
  + $(not y)$ #h(2em) [original]
  + $square$ #h(3em) [resolve 3,4 on $y$]

  Empty clause $=>$ UNSAT!
]

== DRAT: Deletion Resolution Asymmetric Tautology

#definition[DRAT Proof][
  A sequence of clause _additions_ and _deletions_:
  - Addition: Add a clause that is a Reverse Unit Propagation (RUP) or Asymmetric Tautology (RAT)
  - Deletion: Remove a clause (for efficiency)
]

#Block(color: blue)[
  *RUP (Reverse Unit Propagation):*

  Clause $C$ has RUP if adding $not C$ (negation of all literals) leads to a conflict via unit propagation.

  *Intuition:* $C$ is _implied_ by the current formula.
]

#example[
  Formula: $(x or y)$, $(not x or z)$, $(not y or z)$

  Clause $(z)$ has RUP: adding $(not z)$ propagates to conflict.

  $(not z) ->$ formula becomes $(x or y)$, $(not x)$, $(not y)$ $->$ UNSAT
]

== DRAT Checking

#Block(color: green)[
  *DRAT-trim* (Heule, Hunt, Wetzler):

  - Fast proof checker
  - Verifies DRAT proofs in time proportional to proof size
  - Used in SAT Competition since 2014
]

#Block(color: blue)[
  *Formally verified checkers:*
  - *ACL2check:* Verified in ACL2 theorem prover
  - *GRAT:* Verified in Isabelle/HOL
  - *cake_lpr:* Verified in HOL4 with CakeML

  These provide _mathematical certainty_ that UNSAT answers are correct!
]

#Block(color: yellow)[
  *Trust chain:* Complex solver $->$ DRAT proof $->$ Simple checker $->$ Formal verification

  We only need to trust the _formally verified checker_, not the solver!
]

== Proof Sizes and Compression

#Block(color: teal)[
  DRAT proofs can be huge:

  - Typical: 10$times$ -- 100$times$ the formula size
  - Pythagorean triples: 200 TB proof!
  - Compression (LRAT format): 10$times$ -- 100$times$ smaller
]

#definition[LRAT (Linear RAT)][
  Optimized format that includes hints for faster checking:
  - Each step includes clause IDs used in derivation
  - Checker doesn't need to search --- just verify hints
  - Enables $O(n)$ checking instead of $O(n^2)$
]

#Block(color: yellow)[
  LRAT makes it practical to check even the largest proofs!
]


= Model Counting and AllSAT
#focus-slide()

== Beyond Satisfiability: Counting

#definition[\#SAT (Model Counting)][
  Given a CNF formula $phi$, count the number of satisfying assignments.
  $ \#"SAT"(phi) = |{sigma : sigma models phi}| $
]

#Block(color: orange)[
  *Complexity:* \#SAT is *\#P-complete* --- even harder than NP-complete!

  \#P is the class of counting problems associated with NP decision problems.
]

#example[
  Formula: $(x or y) and (not x or not y)$

  Satisfying assignments: $(0,1), (1,0), (1,1)$ --- wait, check $(1,1)$: $(1) and (0) = 0$ #NO

  Actually: $(0,1), (1,0)$ only. $\#"SAT" = 2$.
]

#Block(color: yellow)[
  Even if P = NP, \#SAT would still be hard! (Unless P = \#P, very unlikely)
]

== Why Model Counting Matters

#Block(color: blue)[
  *Applications:*

  - *Probabilistic inference:* Compute probability of events in Bayesian networks
  - *Reliability analysis:* Probability that a system fails
  - *Network reliability:* Probability of connectivity
  - *Information leakage:* Quantify secrets revealed by program outputs
  - *Quantified information flow*
]

#example[
  Bayesian network query: $P("Disease" | "Symptom")$

  Encode as weighted model counting:
  $ P("Disease" | "Symptom") = (W("Disease" and "Symptom")) / (W("Symptom")) $

  where $W(phi)$ is the weighted count of models of $phi$.
]

== Model Counting Algorithms

#Block(color: blue)[
  *Exact counting:*
  - *DPLL-based:* Exhaustive search with caching (SharpSAT, c2d)
  - *Knowledge compilation:* Convert to d-DNNF, then count in linear time
  - *Component caching:* Exploit formula structure
]

#Block(color: green)[
  *Approximate counting:*
  - *Hashing-based:* Add random XOR constraints, binary search
  - *ApproxMC:* $epsilon$-$delta$ approximation guarantees
  - *Sampling:* Uniform sampling from solution space
]

#example[
  ApproxMC can count solutions to formulas with $10^{100}$ solutions with guaranteed accuracy $(1 plus.minus epsilon)$ and high probability!
]

== AllSAT: Enumerating All Solutions

#definition[AllSAT][
  Given a CNF formula $phi$, enumerate _all_ satisfying assignments.
]

#Block(color: blue)[
  *Blocking clause approach:*
  + Find a solution $sigma$
  + Add blocking clause $not sigma$ (forbids this exact solution)
  + Repeat until UNSAT
]

#example[
  Formula: $(x or y)$

  Solution 1: $x=1, y=0$ $->$ add $(not x or y)$

  Solution 2: $x=0, y=1$ $->$ add $(x or not y)$

  Solution 3: $x=1, y=1$ $->$ add $(not x or not y)$

  Now UNSAT. Total: 3 solutions.
]

#Block(color: orange)[
  *Challenge:* Number of solutions can be exponential! (up to $2^n$)

  Practical only for formulas with "few" solutions.
]

== Knowledge Compilation

#definition[Knowledge Compilation][
  Compile Boolean formula into a _tractable representation_ that supports efficient queries.
]

#Block(color: blue)[
  *Target languages:*
  - *BDD (Binary Decision Diagram):* DAG representation, canonical
  - *OBDD:* Ordered BDD, variable order fixed
  - *d-DNNF:* Decomposable Negation Normal Form
  - *SDD (Sentential Decision Diagram):* Combines BDD and DNNF benefits
]

*Tractable operations:*
- Model counting: $O(|"compiled"|)$
- Satisfiability check: $O(1)$
- Conditioning: $O(|"compiled"|)$
- Model enumeration: $O(|"models"|)$

== d-DNNF and Model Counting

#definition[d-DNNF (Decomposable NNF)][
  Formula in NNF where for each AND node, children share no variables.
]

#Block(color: blue)[
  *Why d-DNNF is powerful:*

  Model count of AND: product of children's counts!

  Model count of OR: sum of children's counts!

  $=>$ Linear-time counting after compilation.
]

#example[
  $(x and y) or (not x and z)$ in d-DNNF:

  Count = Count($x and y$) + Count($not x and z$) = $1 dot 1 + 1 dot 1 = 2$

  (With proper handling of free variables)
]

#Block(color: yellow)[
  *Tools:* c2d, D4, miniC2D compile CNF to d-DNNF for counting and queries.
]


= More Encoding Examples
#focus-slide()

== N-Queens Problem

#definition[N-Queens][
  Place $n$ queens on an $n times n$ chessboard so that no two queens attack each other.
]

#Block(color: blue)[
  *SAT encoding:*

  Variables: $q_(i,j)$ = "queen at row $i$, column $j$"

  Constraints:
  - At least one queen per row: $or.big_j q_(i,j)$ for each $i$
  - At most one queen per row: $(not q_(i,j_1) or not q_(i,j_2))$ for $j_1 eq.not j_2$
  - At most one per column: $(not q_(i_1,j) or not q_(i_2,j))$ for $i_1 eq.not i_2$
  - At most one per diagonal: similar constraints
]

#example[
  8-Queens: 64 variables, ~1500 clauses.

  SAT solver finds solution in milliseconds!

  12-Queens: 14,200 solutions. AllSAT enumerates all.
]

== Latin Square and Sudoku Variants

#definition[Latin Square][
  An $n times n$ grid where each row and column contains each symbol exactly once.
]

#Block(color: blue)[
  *SAT encoding:*

  Variables: $x_(i,j,k)$ = "cell $(i,j)$ contains value $k$"

  Same constraints as Sudoku, without box constraints.
]

#definition[Quasigroup Completion][
  Given a partial Latin square, complete it to a full Latin square.

  *NP-complete!* (despite Latin squares being "easy" to construct)
]

#Block(color: yellow)[
  *Variants solved by SAT:*
  - Killer Sudoku (sum constraints)
  - Futoshiki (inequality constraints)
  - KenKen (arithmetic constraints)
]

== Pigeonhole Principle: A Hard Instance

#definition[Pigeonhole Principle (PHP)][
  Can $n+1$ pigeons be placed in $n$ holes with at most one pigeon per hole?
]

#Block(color: orange)[
  Obviously UNSAT (more pigeons than holes!), but _hard for resolution_:

  Any resolution proof of $"PHP"_n^(n+1)$ requires $2^(Omega(n))$ clauses.
]

#Block(color: blue)[
  *SAT encoding:*

  Variables: $p_(i,j)$ = "pigeon $i$ in hole $j$"

  Clauses:
  - Each pigeon in some hole: $or.big_j p_(i,j)$
  - No two pigeons share hole: $(not p_(i,j) or not p_(k,j))$ for $i eq.not k$
]

#example[
  $"PHP"_4^5$: 5 pigeons, 4 holes.

  SAT encoding: 20 variables, 35 clauses.

  Modern CDCL solvers: still struggle for large $n$!
]

== Cryptographic Encodings

#Block(color: blue)[
  *Hash function preimage:*

  Given output $h$, find input $m$ such that $H(m) = h$.

  *SAT encoding:*
  - Variables for each bit of input $m$
  - Encode hash computation as Boolean circuit
  - Add constraints: output bits = $h$
]

#example[
  MD5 produces 128-bit hash.

  SAT encoding of reduced MD5 (24 rounds instead of 64):
  - ~50,000 variables
  - ~200,000 clauses

  SAT solvers have found collisions in reduced MD5!
]

#Block(color: orange)[
  *Limitation:* Full cryptographic functions are designed to resist this --- SAT encoding exists but solving is infeasible.
]


= SAT Competition and Benchmarks
#focus-slide()

== The SAT Competition

#Block(color: teal)[
  *Annual competition since 2002:*
  - Standardized benchmarks
  - Categories: random, crafted, industrial/application
  - Main track: solve as many instances as possible in 5000 seconds each
  - Drives solver development
]

*Track categories:*
- *Main Track:* Industrial/application instances
- *Random Track:* Random 3-SAT near threshold
- *Crafted Track:* Mathematically structured instances
- *Parallel Track:* Multi-core solving
- *No-Limits Track:* Any technique allowed

#Block(color: yellow)[
  Competition has driven dramatic improvements: 100$times$ speedup since 2002!
]

== Benchmark Sources

#grid(
  columns: 2,
  gutter: 1em,

  Block(color: blue)[
    *Industrial:*
    - Hardware verification (Intel, AMD)
    - Software verification (CBMC, KLEE)
    - Cryptographic analysis
    - Planning problems
    - Configuration
  ],

  Block(color: green)[
    *Crafted:*
    - Pigeonhole principle
    - Graph coloring
    - Ramsey numbers
    - Pythagorean triples
    - Factoring semiprimes
  ],
)

#Block(color: yellow)[
  *Key insight:* Industrial instances have _structure_ that solvers exploit.

  Random instances at the threshold are often harder than huge industrial ones!
]

== Evolution of Winning Solvers

#table(
  columns: 2,
  align: left,
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header([*Year*], [*Winners & Innovations*]),
  [2002--2004], [zChaff, BerkMin (VSIDS, learning)],
  [2005--2008], [MiniSat (simplicity), PrecoSat (preprocessing)],
  [2009--2012], [Glucose (LBD, aggressive restarts)],
  [2013--2016], [Lingeling (inprocessing)],
  [2017--2019], [MapleSAT (LRB branching)],
  [2020--2024], [CaDiCaL, Kissat (Armin Biere)],
)

#Block(color: yellow)[
  *Pattern:* Major innovations become standard, then incremental improvements.

  Recent winners: combinations of all techniques with careful engineering.
]

== State of the Art: Kissat (2020--)

#grid(
  columns: 2,
  gutter: 1em,

  Block(color: blue)[
    *Key features of modern solvers:*
    - CDCL with aggressive restarts
    - LBD-based clause management
    - VSIDS/CHB hybrid branching
    - Extensive preprocessing (VE, subsumption, BCE, vivification)
    - Inprocessing during search
    - DRAT proof generation
  ],

  Block(color: yellow)[
    *Open challenges:*
    - Random SAT near threshold
    - Pigeonhole variants
    - Cryptographic instances
    - Extremely large industrial instances \ ($>10^8$ variables)
  ],
)

#Block(color: green)[
  *Kissat performance (SAT Competition 2023):*
  - Solved 250+ out of 400 industrial instances
  - Average time: under 100 seconds for solved instances
  - Code: ~50,000 lines of C
]


= Summary
#focus-slide(title: [Key Takeaways])

== What We Learned

#Block(color: purple)[
  *Core concepts:*
  - SAT: determining if a Boolean formula has a satisfying assignment
  - CNF: standard form for SAT solvers (AND of OR clauses)
  - NP-completeness: SAT is the canonical hard problem
  - Cook--Levin theorem: any NP problem reduces to SAT
]

#Block(color: blue)[
  *Algorithms:*
  - DPLL: complete backtracking search with propagation
  - CDCL: learning from conflicts (implication graphs, 1st UIP)
  - Preprocessing: variable elimination, subsumption, BCE
  - Local search: WalkSAT, probSAT for satisfiable instances
]

#Block(color: yellow)[
  *Applications:*
  - Hardware/software verification (bounded model checking)
  - AI planning, scheduling, configuration
  - Cryptanalysis and security
  - Mathematical theorem proving
]

== Extensions and Theory

#Block(color: purple)[
  *Beyond SAT:*
  - MaxSAT: optimization over satisfiability
  - QBF: quantified Boolean formulas (PSPACE-complete)
  - SMT: SAT with arithmetic, arrays, strings
  - \#SAT: model counting (\#P-complete)
]

#grid(
  columns: 2,
  gutter: 1em,

  Block(color: blue)[
    *Theoretical foundations:*
    - Resolution proofs and proof complexity
    - Phase transitions in random SAT
    - ETH and SETH conjectures
    - Parameterized complexity (treewidth, backdoors)
  ],

  Block(color: green)[
    *Modern developments:*
    - Certified UNSAT (DRAT proofs)
    - Parallel SAT (cube-and-conquer)
    - Machine learning in SAT (NeuroSAT)
    - SAT for combinatorics (200TB Pythagorean proof!)
  ],
)

== The Big Picture

// Problems by complexity class:
// - P: 2-SAT, Sorting, 2-COL (2-coloring), MST (minimum spanning tree)
// - NP-complete (NP ∩ NP-hard): SAT, 3-SAT, Clique, Vertex Cover, TSP, 3-COL
// - NP but not P or NPC (if P≠NP): Graph Isomorphism(?), Factoring(?)
// - EXPTIME-complete: Generalized Chess, Go, Checkers, QBF
// - Beyond EXPTIME (decidable): 2-EXPTIME (Presburger arithmetic), ELEMENTARY, Primitive recursive
// - Undecidable (also NP-hard!): Halting problem, Post correspondence, Diophantine equations

#align(center)[
  #cetz.canvas(length: 0.5cm, {
    import cetz.draw: *

    // Decidable region
    rect(
      (-8, -5),
      (12, 5),
      fill: blue.transparentize(95%),
      stroke: 0.8pt + blue.darken(10%),
      name: "decidable",
    )
    content((-9, 4.2), text(fill: blue.darken(25%), size: 0.6em)[Decidable], anchor: "south-west")

    // EXPTIME
    circle(
      (0, 0),
      radius: (7.5, 4),
      fill: purple.transparentize(90%),
      stroke: 1pt + purple.darken(10%),
      name: "exp",
    )
    content(
      "exp.north",
      text(fill: purple.darken(25%), size: 0.65em)[EXPTIME],
      anchor: "south",
      padding: 0.1,
    )

    // NP-hard ellipse
    circle(
      (4, 0),
      radius: (6.5, 4),
      fill: red.transparentize(90%),
      stroke: 1pt + red.darken(10%),
      name: "nphard",
    )
    content(
      "nphard.north",
      text(fill: red.darken(25%), size: 0.6em)[NP-hard],
      anchor: "south",
      padding: 0.1,
    )

    // NP ellipse
    circle(
      (-2, 0),
      radius: (5.3, 3),
      fill: yellow.transparentize(80%),
      stroke: 1.2pt + yellow.darken(20%),
      name: "np",
    )
    content(
      "np.north-west",
      text(fill: yellow.darken(30%), weight: "bold")[NP],
      anchor: "south-east",
      padding: 0.1,
    )

    // P circle (inside NP, on the left)
    circle(
      (-5, 0),
      radius: 2,
      fill: green.transparentize(78%),
      stroke: 1.2pt + green.darken(20%),
      name: "p",
    )
    content(
      "p.north",
      text(fill: green.darken(20%), weight: "bold")[P],
      anchor: "north",
      padding: 0.2,
    )

    // P problems
    content((-6.4, 0.35), text(size: 0.8em)[2-SAT])
    content((-6, 0), text(size: 0.8em)[Sorting])
    content((-5.6, -0.4), text(size: 0.8em)[2-COL])
    content((-6.3, -0.15), text(size: 0.8em)[MST])

    // NP-complete region
    content((0, 1.1), text(size: 0.8em, fill: orange.darken(10%), weight: "bold")[NP-complete])
    content((0, 0.5), text(size: 0.8em)[SAT])
    content((0, 0.05), text(size: 0.8em)[3-SAT])
    content((0, -0.4), text(size: 0.8em)[Clique])
    content((0, -0.85), text(size: 0.8em)[Vertex Cover])
    content((0, -1.3), text(size: 0.8em)[TSP])
    content((0, -1.75), text(size: 0.8em)[Coloring])

    // NP but not P or NPC (if P≠NP)
    content((-3.8, 1.6), text(size: 0.45em, fill: gray.darken(20%))[Graph Iso?])
    content((-4.2, -1.8), text(size: 0.45em, fill: gray.darken(20%))[Factoring?])

    // EXPTIME-complete (NP-hard, in EXPTIME, outside NP)
    content((4, 0.9), text(size: 0.45em)[Gen. Chess])
    content((4, 0.45), text(size: 0.45em)[Gen. Go])
    content((4, 0), text(size: 0.45em)[Gen. Checkers])
    content((4, -0.45), text(size: 0.45em)[QBF/QSAT])

    // Undecidable problems (still NP-hard!)
    content((15, 3), text(size: 0.55em, fill: gray.darken(35%), weight: "bold")[Undecidable])
    content((15, 2.4), text(size: 0.45em, fill: gray.darken(25%))[(also NP-hard!)])
    content((15, 1.4), text(size: 0.45em)[Halting problem])
    content((15, 0.8), text(size: 0.45em)[Post corresp.])
    content((15, 0.2), text(size: 0.45em)[Diophantine eqs])
    content((15, -0.4), text(size: 0.45em)[Rice's theorem])
    content((15, -1), text(size: 0.45em)[Kolmogorov compl.])
  })
]

#Block(color: yellow)[
  *Open question:* Is P = NP? (Probably not, but unproven!)

  If P $eq.not$ NP, then SAT has no polynomial algorithm --- but our solvers work amazingly well in practice!
]

== The SAT Ecosystem

#grid(
  columns: 2,
  gutter: 1em,
  Block(color: blue)[
    *Major SAT solvers:*
    - CaDiCaL, Kissat (state of the art)
    - MiniSat (educational)
    - Glucose (LBD-based)
    - CryptoMiniSat (XOR support)
  ],
  Block(color: green)[
    *SMT solvers:*
    - Z3 (Microsoft)
    - CVC5
    - Yices, MathSAT
    - Boolector (bit-vectors)
  ],
)

#Block(color: yellow)[
  *Related tools:*
  - SharpSAT, D4 (model counting)
  - Open-WBO, MaxHS (MaxSAT)
  - DepQBF, CAQE (QBF)
  - DRAT-trim, GRAT (proof checking)
]

== Using SAT Solvers in Practice

#Block(color: blue)[
  *PySAT example (Python):*
  ```python
  from pysat.solvers import Glucose3

  solver = Glucose3()
  # (x1 or x2) and (not x1 or x3) and (not x2 or not x3)
  solver.add_clause([1, 2])
  solver.add_clause([-1, 3])
  solver.add_clause([-2, -3])

  if solver.solve():
      print("SAT:", solver.get_model())
  else:
      print("UNSAT")
  ```
]

#Block(color: green)[
  *Z3 example (Python):*
  ```python
  from z3 import *
  x, y, z = Bools('x y z')
  s = Solver()
  s.add(Or(x, y), Or(Not(x), z), Or(Not(y), Not(z)))
  if s.check() == sat:
      print(s.model())
  ```
]

#Block(color: yellow)[
  Both libraries available via `pip install python-sat z3-solver`.
]

== Further Reading

#Block(color: blue)[
  *Textbooks:*
  - Biere et al.: _Handbook of Satisfiability_ (2nd ed., 2021)
  - Arora & Barak: _Computational Complexity: A Modern Approach_
  - Knuth: _The Art of Computer Programming, Vol. 4B_ (Satisfiability)
]

#Block(color: green)[
  *Online resources:*
  - SAT Competition: satcompetition.org
  - SAT Live!: satlive.org
  - SMT-LIB: smtlib.cs.uiowa.edu
]

#Block(color: yellow)[
  *Practice:*
  - Try encoding Sudoku, N-Queens, graph coloring as SAT
  - Use PySAT (Python), SAT4J (Java), or Z3 (Python/C++)
  - Participate in SAT Competition student tracks!
]

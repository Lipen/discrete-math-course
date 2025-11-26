#import "theme.typ": *
#show: slides.with(
  title: [Boolean Satisfiability],
  subtitle: "Discrete Math",
  date: "Fall 2025",
  authors: "Konstantin Chukharev",
)

#show heading.where(level: 1): none

#import "common-lec.typ": *
#import fletcher: diagram, edge, node

#let rewrite = $arrow.double.long$


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
  ),
)

== What is Satisfiability?

Given a Boolean formula, can we find values for its variables that make it _true_?

#definition[Satisfiability][
  A Boolean formula $f$ is _satisfiable_ if there exists an assignment of truth values to its variables that makes $f$ evaluate to 1 (true).
  $ exists x_1, ..., x_n in {0,1} . thin f(x_1, ..., x_n) = 1 $
]

#example[
  The formula $(x or y) and (not x or z)$ is satisfiable.

  Setting $x = 1$, $y = 0$, $z = 1$ gives $(1 or 0) and (0 or 1) = 1 and 1 = 1$.
]

#example[
  The formula $(x) and (not x)$ is _unsatisfiable_ --- no assignment can make both clauses true simultaneously.
]

#Block(color: yellow)[
  *SAT* is the problem of _deciding_ whether a given formula is satisfiable.
]

== Why SAT Matters

#Block(color: blue)[
  *SAT is the canonical hard problem in computer science.*

  - First problem proven NP-complete (Cook, 1971)
  - Universal: _any_ NP problem can be reduced to SAT
  - Practical: modern SAT solvers handle millions of variables
]

#grid(
  columns: 2,
  gutter: 1em,
  [
    *Applications:*
    - Hardware verification (Intel, AMD)
    - Software testing & bug finding
    - AI planning & scheduling
    - Cryptanalysis
    - Constraint satisfaction
    - Automated theorem proving
  ],
  [
    *Scale:*
    - Industrial SAT instances: $10^6$+ variables
    - Solving time: seconds to hours
    - Annual SAT Competition since 2002
    - Thousands of research papers
  ],
)

#Block(color: yellow)[
  Understanding SAT connects theory (complexity) with practice (solvers, applications).
]

== Quick Review: Normal Forms

#definition[Literal][
  A _literal_ is a variable ($x$) or its negation ($not x$).
]

#definition[Clause][
  A _clause_ is a disjunction (OR) of literals: $thin (l_1 or l_2 or dots or l_k)$.
]

#definition[Conjunctive Normal Form (CNF)][
  A formula is in _CNF_ if it is a conjunction (AND) of clauses:
  $ (l_(1,1) or dots or l_(1,k_1)) and (l_(2,1) or dots or l_(2,k_2)) and dots and (l_(m,1) or dots or l_(m,k_m)) $
]

#example[
  $(x or y or not z) and (not x or y) and (z)$ is in CNF with 3 clauses.
]

#Block(color: yellow)[
  *Why CNF?* SAT solvers work exclusively with CNF formulas.
  Any formula can be converted to CNF (possibly with auxiliary variables).
]

== Special Clauses

#definition[Unit clause][
  A _unit clause_ is a clause with a single literal, e.g., $(x)$ or $(not y)$.
]

#definition[Empty clause][
  An _empty clause_ (denoted $square$) has no literals.

  *Key fact:* An empty clause is _always false_ (unsatisfiable).
]

#example[
  - $(x)$ is a unit clause --- forces $x = 1$
  - $(not y)$ is a unit clause --- forces $y = 0$
  - $square$ (empty clause) --- contradiction, formula is UNSAT
]

#Block(color: orange)[
  *If a CNF contains an empty clause, the entire formula is unsatisfiable.*
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

#definition[Decision SAT][
  Given a CNF formula $F$, determine: Is $F$ satisfiable? (Yes/No)
]

#definition[Search SAT (Functional SAT)][
  Given a satisfiable CNF formula $F$, _find_ a satisfying assignment.
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

#definition[Class P][
  Problems solvable in _polynomial time_ by a deterministic algorithm.

  Examples: sorting, shortest path, linear programming.
]

#definition[Class NP][
  Problems where a "yes" answer can be _verified_ in polynomial time.

  Equivalently: solvable in polynomial time by a _nondeterministic_ algorithm.
]

#Block(color: blue)[
  *SAT is in NP:*
  Given a satisfying assignment (certificate), we can verify it in $O(n + m)$ time by evaluating each clause.
]

#Block(color: yellow)[
  *The million-dollar question:* Is P = NP?

  Most experts believe P $eq.not$ NP, but no proof exists!
]

== NP-Completeness

#definition[NP-hard][
  A problem $X$ is _NP-hard_ if every problem in NP can be _reduced_ to $X$ in polynomial time.
]

#definition[NP-complete][
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

== Karp's 21 NP-Complete Problems

After Cook's theorem, Richard Karp (1972) showed 21 classic problems are NP-complete by reducing SAT to them.

#align(center)[
  #cetz.canvas(length: 0.9cm, {
    import cetz.draw: *

    // Central SAT node
    circle((0, 0), radius: 0.8, fill: red.lighten(70%), stroke: 1pt + red.darken(20%), name: "sat")
    content("sat", [*SAT*])

    // First level reductions
    let problems1 = (
      (angle: 90deg, name: "3sat", label: "3-SAT"),
      (angle: 30deg, name: "clique", label: "Clique"),
      (angle: -30deg, name: "vc", label: [Vertex\ Cover]),
      (angle: -90deg, name: "hc", label: [Hamiltonian\ Cycle]),
      (angle: -150deg, name: "color", label: [Graph\ Coloring]),
      (angle: 150deg, name: "ip", label: [Integer\ Program]),
    )

    for p in problems1 {
      let pos = (calc.cos(p.angle) * 3, calc.sin(p.angle) * 3)
      circle(pos, radius: 0.8, fill: blue.lighten(80%), stroke: 1pt + blue.darken(20%), name: p.name)
      content(p.name, text(size: 0.7em)[#p.label])
      line("sat", p.name, stroke: 1pt, mark: (end: ">"))
    }
  })
]

#Block(color: yellow)[
  *Key insight:* SAT reductions let us prove hardness of many problems automatically.
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

#definition[Unit propagation][
  If a CNF formula contains a _unit clause_ $(l)$, then:
  + Set the literal $l$ to true
  + Remove all clauses containing $l$ (they are satisfied)
  + Remove $overline(l)$ from all remaining clauses
]

#example[
  Formula: $(x or y) and (not x or z) and (x)$

  Unit clause $(x)$ forces $x = 1$:
  - Remove $(x or y)$ and $(x)$, since they contain $x$
  - Remove $not x$ from $(not x or z)$

  Result: $(z)$ --- another unit clause!

  Continue: $z = 1$, formula simplifies to $top$, i.e., the formula is _satisfied_.
]

#Block(color: yellow)[
  Unit propagation is the _workhorse_ of SAT solvers --- fast and effective!
]

== Pure Literal Elimination

#definition[Pure literal][
  A literal $l$ is _pure_ if it appears in the formula but $overline(l)$ does not.
]

#definition[Pure literal rule][
  If a literal $l$ is pure:
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

#definition[DPLL (Davis--Putnam--Logemann--Loveland, 1962)][
  A complete backtracking algorithm for SAT:

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
  Formula: $(x or y) and (not x or y) and (not y or z) and (not z)$

  #align(center)[
    #cetz.canvas(length: 0.8cm, {
      import cetz.draw: *

      // Root
      content((0, 0), $F$, name: "root")

      // Level 1: choose x
      content((-3, -2), [$x = 1$], name: "x1")
      content((3, -2), [$x = 0$], name: "x0")

      line("root", "x1", stroke: 1pt)
      line("root", "x0", stroke: 1pt)

      // From x=1: unit prop gives y=1
      content((-3, -4), [$y = 1$\ (unit prop)], name: "y1")
      line("x1", "y1", stroke: 1pt)

      // From y=1: unit prop gives z=1
      content((-3, -6), [$z = 1$], name: "z1")
      line("y1", "z1", stroke: 1pt)

      // Conflict with (not z)
      content((-3, -8), text(fill: red)[*Conflict!*\ $z and not z$], name: "conf1")
      line("z1", "conf1", stroke: 1pt + red)

      // From x=0: unit prop on (x or y) gives y=1
      content((3, -4), [$y = 1$\ (unit prop)], name: "y1b")
      line("x0", "y1b", stroke: 1pt)

      // From y=1: same conflict
      content((3, -6), [$z = 1$], name: "z1b")
      line("y1b", "z1b", stroke: 1pt)

      content((3, -8), text(fill: red)[*Conflict!*], name: "conf2")
      line("z1b", "conf2", stroke: 1pt + red)
    })
  ]

  Both branches lead to conflict $=>$ Formula is *UNSAT*.
]

== Conflict-Driven Clause Learning (CDCL)

#Block(color: blue)[
  Modern SAT solvers use CDCL --- an enhanced version of DPLL.

  *Key insight:* When we hit a conflict, _learn from it_!
]

#definition[Clause learning][
  When a conflict occurs, analyze _why_ it happened and add a new clause that prevents the same conflict pattern in the future.
]

#align(center)[
  #fletcher.diagram(
    spacing: (2.5em, 2em),
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
      name: <done>,
    ),
    blob(
      (0, 1),
      [Decide],
      tint: green,
      shape: fletcher.shapes.rect,
      name: <decide>,
    ),
    edge(<propagate>, "-|>", <conflict>),
    edge(<conflict>, "-|>", <learn>)[yes],
    edge(<conflict>, "-|>", <done>)[no],
    edge(<done>, "-|>", <decide>)[no],
    edge(<decide>, "-|>", <propagate>),
    edge(<learn>, <propagate>, "-|>", bend: 40deg),
  )
]

#Block(color: yellow)[
  CDCL can _skip_ large parts of the search space by learning conflict clauses.
]


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

#definition[Graph $k$-coloring][
  Given a graph $G = (V, E)$ and $k$ colors, assign a color to each vertex such that adjacent vertices have different colors.
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

== Example: Ramsey Numbers

#definition[Ramsey number $R(r, s)$][
  The smallest $n$ such that any 2-coloring of edges of $K_n$ contains either a red $K_r$ or a blue $K_s$.
]

#example[Finding $R(3,3) = 6$][
  Can we 2-color edges of $K_5$ without monochromatic triangles?

  #place(right, dy: -3em)[
    #diagram(
      node-stroke: 1pt,
      edge-stroke: 1pt,
      {
        // Pentagon with colored edges
        let n = 5
        for i in range(1, n + 1) {
          let angle = 18deg + i * 72deg
          node((angle, 0.8cm), str(i), outset: 1pt, name: label(str(i)))
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

#definition[Exactly-one constraint][
  Exactly one of $x_1, ..., x_n$ must be true.
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


= Extensions and Variants
#focus-slide()

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

== Beyond SAT: SMT Solvers

#definition[Satisfiability Modulo Theories (SMT)][
  Extends SAT with _background theories_:
  - Linear arithmetic: $x + 2y <= 10$
  - Arrays: $a[i] = a[j] imply i = j$
  - Bit-vectors: $x and_"bv" y = 0$
  - Uninterpreted functions: $f(x) = f(y) imply x = y$
]

#example[
  Formula: $(x > 0) and (y > 0) and (x + y < 3) and (x eq.not y)$

  SMT solver (e.g., Z3) can find: $x = 1, y = 1$ --- wait, that violates $x eq.not y$!

  New attempt: $x = 1, y = 0.5$? But $y > 0$ and integers... Actually: UNSAT in integers!
]

#Block(color: yellow)[
  SMT solvers are the backbone of program verification and symbolic execution.
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
  - Unit propagation and pure literal elimination
  - DPLL: complete backtracking search
  - CDCL: learning from conflicts
]

#Block(color: yellow)[
  *Applications:*
  - Encode any combinatorial problem as SAT
  - Modern solvers handle millions of variables
  - Foundation for verification, AI, cryptanalysis
]

== The Big Picture

#align(center)[
  #cetz.canvas(length: 0.7cm, {
    import cetz.draw: *

    // Draw nested ovals for complexity classes
    circle((0, 0), radius: (6, 4), fill: red.lighten(90%), stroke: 1pt + red.darken(20%))
    content((4.5, 3), text(fill: red.darken(20%))[*NP-hard*])

    circle((0, 0), radius: (4.5, 3), fill: yellow.lighten(85%), stroke: 1pt + yellow.darken(20%))
    content((0, 2.2), text(fill: yellow.darken(30%))[*NP*])

    circle((-1, 0), radius: (2.5, 1.8), fill: green.lighten(85%), stroke: 1pt + green.darken(20%))
    content((-1, 1), text(fill: green.darken(20%))[*P*])

    // P problems
    content((-1.5, -0.3), text(size: 0.8em)[Sorting])
    content((-0.5, -0.8), text(size: 0.8em)[2-SAT])

    // NP-complete (intersection)
    circle((2, 0), radius: 1.2, fill: orange.lighten(80%), stroke: 1pt + orange.darken(20%))
    content((2, 0.5), text(size: 0.8em, fill: orange.darken(20%))[*NP-complete*])
    content((2, -0.3), text(size: 0.7em)[*SAT*])
  })
]

#Block(color: yellow)[
  *Open question:* Is P = NP? (Probably not, but unproven!)

  If P $eq.not$ NP, then SAT has no polynomial algorithm --- but our solvers work amazingly well in practice!
]

== Further Reading

#Block(color: blue)[
  *Textbooks:*
  - Arora & Barak: _Computational Complexity: A Modern Approach_
  - Biere et al.: _Handbook of Satisfiability_
  - Sipser: _Introduction to the Theory of Computation_
]

#Block(color: green)[
  *Online resources:*
  - SAT Competition: satcompetition.org
  - MiniSat tutorial: minisat.se
  - Z3 solver: github.com/Z3Prover/z3
]

#Block(color: yellow)[
  *Practice:*
  Try encoding your favorite puzzle (Sudoku, N-Queens, scheduling) as SAT and solve it with MiniSat or Z3!
]

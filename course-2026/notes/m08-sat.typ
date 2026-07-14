// M08 --- SAT: the Boolean satisfiability problem and its central role in computation.
#import "common-notes.typ": *
#import "notation.typ": *

= SAT

#chapter-overview[
  The Boolean satisfiability problem (SAT) asks: does there exist an assignment making a given CNF formula true?
  Despite its simplicity, SAT is the canonical NP-complete problem --- a "universal" problem to which all of NP reduces.
  This chapter introduces SAT, k-SAT, the art of encoding problems into CNF, and the architecture of modern SAT solvers. ]

== The SAT Problem

=== SAT Definitions

#definition[SAT][
  *SAT*: Given a Boolean formula $phi$ in CNF, decide whether there exists a satisfying assignment (a *model*). ]

#definition[CNF formula][
  $phi = C_1 and ... and C_m$, each clause $C_i = (l_(i,1) or ... or l_(i,k_i))$.
  A literal is a variable $x$ or its negation $overline(x)$. ]

#example[Satisfiable formula][
  $phi = (x or overline(y)) and (overline(x) or y or z) and (overline(z))$. $x = 1, y = 1, z = 0$ satisfies all three clauses. ]

#example[Unsatisfiable formula][
  $psi = (x) and (overline(x))$ is unsatisfiable. ]

=== k-SAT

#definition[k-SAT][
  $k$-SAT: every clause has exactly $k$ literals.
  - *2-SAT*: solvable in polynomial time (implication graph + SCC).
  - *3-SAT*: NP-complete.
]

=== 2-SAT Algorithm

#proposition[2-SAT via implication graph][
  1. Build digraph: vertices $x_i$, $overline(x_i)$ for each variable.
  2. Clause $(l_1 or l_2)$ $=>$ edges $overline(l_1) arrow l_2$, $overline(l_2) arrow l_1$.
  3. Compute SCCs.
  4. If $x_i$ and $overline(x_i)$ share an SCC: unsatisfiable.
  Otherwise, assign by reverse topological SCC order. ]

#proof-sketch[
  $x_i$, $overline(x_i)$ in same SCC $=>$ $x_i iff overline(x_i)$ --- contradiction.
  Reverse-topological assignment satisfies all implications.
  Runs in $O(n + m)$. ]

#remark[
  2-SAT (easy) vs 3-SAT (NP-complete) --- small problem changes cause dramatic complexity jumps. ]

== Encoding Problems to SAT

#proposition[SAT reduction recipe][
  1. Choose Boolean variables.
  2. Write constraints as clauses.
  3. Run SAT solver.
  4. Interpret: SAT $=>$ decode model; UNSAT $=>$ no solution.
]

#example[Graph $k$-coloring][
  Variables: $x_(v, c) = 1$ iff vertex $v$ has color $c$.
  - Each vertex has a color: $or.big_(c=1)^k x_(v, c)$.
  - No vertex has two colors: $overline(x_(v, c)) or overline(x_(v, d))$ for $c < d$.
  - Adjacent vertices differ: $overline(x_(u, c)) or overline(x_(v, c))$ for edge ${u, v}$.
]

#example[Sudoku][
  9×9 Sudoku = SAT with $9^3 = 729$ variables $x_(r, c, d)$ (cell $(r, c)$ contains digit $d$).
  Constraints: each cell has one digit; each digit once per row, column, 3×3 block; given digits fixed.
  Hardest puzzles solved in milliseconds. ]

#example[Vertex cover][
  Does graph $G$ have a vertex cover of size $<= k$?
  Variables: $x_v = 1$ iff vertex $v$ is in the cover.
  Constraints:
  - Every edge covered: $x_u or x_v$ for each ${u, v} in E$.
  - Size limit: use cardinality constraint encoding (sequential counter or binary adder).
]

The art of SAT encoding lies in choosing the right variables and writing compact clauses.
Poor encodings blow up clause count; good encodings exploit problem structure.

=== Modern SAT Solvers: CDCL

Modern solvers descend from the DPLL algorithm (Davis-Putnam-Logemann-Loveland, 1962): backtracking search with unit propagation and pure literal elimination.
CDCL (Conflict-Driven Clause Learning) adds:

#proposition[CDCL algorithm --- outline][
  1. *Unit propagation* (Boolean constraint propagation): if a clause has all-but-one literal assigned false, the remaining must be true.
    Propagate until fixpoint or conflict.
  2. *Decision*: when no more propagation, pick an unassigned variable and assign it arbitrarily.
    VSIDS heuristic: variables appearing in recent conflicts are prioritised.
  3. *Conflict analysis*: when a clause becomes false, analyse the implication graph to derive a *learned clause* --- a new clause that rules out the conflicting partial assignment.
    The first-UIP (Unique Implication Point) scheme is standard.
  4. *Backjumping*: undo decisions up to the point where the learned clause becomes unit (non-chronological backtracking).
  5. *Learn and restart*: add the learned clause to the formula; periodically restart the search (keeping learned clauses) to escape unfruitful branches.
]

#remark[
  CDCL solvers (MiniSat, Glucose, CaDiCaL) routinely solve industrial instances with millions of variables and tens of millions of clauses.
  Applications: hardware verification (equivalence checking), software bounded model checking, AI planning, cryptography (attacking reduced-round ciphers), and configuration management.
  Despite NP-completeness, real-world instances often have enough structure to be tractable --- the "SAT revolution." ]

== SAT and NP

#theorem[Cook's theorem --- statement][
  SAT is NP-complete: SAT $in$ NP, and every problem in NP is polynomial-time reducible to SAT. ]

#note[
  Full proof in the complexity chapter (Semester 2).
  Idea: encode NTM computation tableau as CNF; formula satisfiable iff machine accepts. ]

#corollary[P vs NP consequence][
  If SAT $in$ P, then $P = "NP"$.
  If SAT requires exponential time, then $P eq.not "NP"$. ]

SAT is the "canary in the coal mine" of complexity theory --- solve it efficiently and all of NP collapses.

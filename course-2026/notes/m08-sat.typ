// M08 --- SAT: the Boolean satisfiability problem and its central role in computation.
#import "common-notes.typ": *
#import "notation.typ": *

= SAT

#chapter-overview[
    *Chapter overview.*
    The Boolean satisfiability problem (SAT) asks: does there exist an assignment making a given CNF formula true?
    Despite its simplicity, SAT is the canonical NP-complete problem --- a "universal" problem to which all of NP reduces.
    This chapter introduces SAT, k-SAT, the art of encoding problems into CNF, and the architecture of modern SAT solvers.
]

== The SAT Problem

=== Definitions

#definition[SAT][
    *SAT*: Given a Boolean formula $phi$ in CNF, decide whether there exists a satisfying assignment (a *model*).
]

#definition[CNF formula][
    $phi = C_1 and ... and C_m$, each clause $C_i = (l_(i,1) or ... or l_(i,k_i))$.
    A literal is a variable $x$ or its negation $overline(x)$.
]

#example[
    $phi = (x or overline(y)) and (overline(x) or y or z) and (overline(z))$.
    $x = 1, y = 1, z = 0$ satisfies all three clauses.
]

#example[
    $psi = (x) and (overline(x))$ is unsatisfiable.
]

=== k-SAT

#definition[k-SAT][
    $k$-SAT: every clause has exactly $k$ literals.
    + *2-SAT*: solvable in polynomial time (implication graph + SCC).
    + *3-SAT*: NP-complete.
]

=== 2-SAT Algorithm

#proposition[2-SAT via implication graph][
    1. Build digraph: vertices $x_i$, $overline(x_i)$ for each variable.
    2. Clause $(l_1 or l_2)$ → edges $overline(l_1) arrow l_2$, $overline(l_2) arrow l_1$.
    3. Compute SCCs.
    4. If $x_i$ and $overline(x_i)$ share an SCC: unsatisfiable.
    Otherwise, assign by reverse topological SCC order.
]

#proof-sketch[
    $x_i$, $overline(x_i)$ in same SCC → $x_i arrow.l.r overline(x_i)$ --- contradiction.
    Reverse-topological assignment satisfies all implications. Runs in $O(n + m)$.
]

#remark[
    2-SAT (easy) vs 3-SAT (NP-complete) --- small problem changes cause dramatic complexity jumps.
]

== Encoding Problems to SAT

#proposition[SAT reduction recipe][
    1. Choose Boolean variables.
    2. Write constraints as clauses.
    3. Run SAT solver.
    4. Interpret: SAT → decode model; UNSAT → no solution.
]

#example[Graph $k$-coloring][
    Variables: $x_(v, c) = 1$ iff vertex $v$ has color $c$.
    + Each vertex has a color: $or.big_(c=1)^k x_(v, c)$.
    + No vertex has two colors: $overline(x_(v, c)) or overline(x_(v, d))$ for $c < d$.
    + Adjacent vertices differ: $overline(x_(u, c)) or overline(x_(v, c))$ for edge ${u, v}$.
]

#example[Sudoku][
    9×9 Sudoku = SAT with $9^3 = 729$ variables $x_(r, c, d)$.
    Hardest puzzles solved in milliseconds by modern solvers.
]

=== Modern SAT Solvers: CDCL

#proposition[CDCL algorithm --- outline][
    1. *Unit propagation*: all-but-one false → remaining must be true.
    2. *Decision*: pick unassigned variable (VSIDS heuristic).
    3. *Conflict analysis*: derive *learned clause* from implication graph.
    4. *Backjumping*: undo to where learned clause becomes unit.
    5. *Learn and restart*: add clause, periodically restart (keeping learned clauses).
]

#remark[
    CDCL solvers (MiniSat, Glucose, CaDiCaL) solve industrial instances with millions of variables.
    Despite NP-completeness, real-world instances are often tractable --- the "SAT revolution."
]

== SAT and NP

#theorem[Cook's theorem --- statement][
    SAT is NP-complete: SAT $in$ NP, and every problem in NP is polynomial-time reducible to SAT.
]

#note[
    Full proof in the complexity chapter (Semester 2).
    Idea: encode NTM computation tableau as CNF; formula satisfiable iff machine accepts.
]

#corollary[P vs NP consequence][
    If SAT $in$ P, then $P = "NP"$.
    If SAT requires exponential time, then $P eq.not "NP"$.
]

SAT is the "canary in the coal mine" of complexity theory --- solve it efficiently and all of NP collapses.

// M15 --- Complexity and NP-Completeness: the limits of efficient computation.
#import "common-notes.typ": *
#import "notation.typ": *

= Complexity and NP-Completeness

#chapter-overview[
    *Chapter overview.*
    Not all decidable problems are created equal --- some can be solved in linear time, others require exponential time, and some sit at the frontier of human knowledge (P vs NP).
    This chapter introduces P and NP, polynomial-time reductions, NP-completeness, and Cook's theorem.
    The chapter closes with strategies for coping with intractability and the broader complexity landscape.
]

== The Class P

#definition[Class P][
    $P = union.big_(k >= 1) "TIME"(n^k)$ --- decision problems solvable by a deterministic TM in polynomial time.
    Robust: same class for single-tape, multi-tape TMs, and RAM model (within polynomial factors).
]

#example[Problems in P][
    Sorting, shortest paths (Dijkstra), MST, 2-coloring (bipartiteness), Eulerian cycle, planarity testing, linear programming, primality (AKS, 2002), CFG parsing ($O(n^3)$).
]

== The Class NP

#definition[Class NP][
    $L in "NP"$ if $exists$ polynomial-time verifier $V$ and polynomial $p$:
    $w in L$ iff $exists c$ (certificate), $|c| <= p(|w|)$, and $V(w, c)$ accepts.
    "Guess the certificate, verify in polynomial time."
]

Equivalently: solvable by nondeterministic TM in polynomial time.

#example[Problems in NP][
    SAT (certificate = assignment), Hamiltonian cycle (the cycle), Vertex Cover $<= k$ (the cover), Clique, $k$-coloring, Subset Sum, ILP, Graph Isomorphism.
]

#note[
    $P subset.eq "NP"$ trivially. $P = "NP"$? Open --- one of seven Millennium Prize Problems ($1,000,000).
]

== Polynomial Reductions and NP-Completeness

#definition[Polynomial reduction][
    $A #preduce B$: $exists$ poly-time computable $f$ s.t. $w in A$ iff $f(w) in B$.
]

#proposition[Closure][
    $A #preduce B$ and $B in P$ → $A in P$.
    $A #preduce B$ and $B in "NP"$ → $A in "NP"$.
]

#definition[NP-hard, NP-complete][
    + $B$ is *NP-hard* if $forall A in "NP"$, $A #preduce B$.
    + $B$ is *NP-complete* if $B in "NP"$ and $B$ is NP-hard.
]

#theorem[Significance][
    If any NP-complete problem is in P, then $P = "NP"$.
]

=== Cook's Theorem

#theorem[Cook-Levin theorem][
    SAT is NP-complete.
]

#proof-sketch[
    SAT $in$ NP: certificate = assignment, verify in linear time.
    NP-hardness: given NTM $M$ accepting $L$ in time $p(n)$, construct CNF $phi$ encoding the computation tableau.
    Variables: $x_(t,p,s)$ (time $t$, position $p$, symbol $s$), $y_(t,i)$ (time $t$, head at $i$, state $q_i$).
    Clauses enforce: valid start, valid transitions, acceptance.
    $phi$ satisfiable iff $M$ accepts $w$. Size $O(p(|w|)^2)$.
]

=== The NP-Complete Zoo

#proposition[Standard reduction chain][
    $"SAT" #preduce "3-SAT" #preduce "Vertex Cover" #preduce "Clique" #preduce "Independent Set"$.
    Also: $"3-SAT" #preduce "Subset Sum" #preduce "Partition" #preduce "Knapsack"$.
    $"3-SAT" #preduce "3-Coloring"$. $"Vertex Cover" #preduce "Hamiltonian Cycle" #preduce "TSP"$.
]

Major NP-complete problems: logic (SAT, 3-SAT, Max-2-SAT), graphs (Clique, Vertex Cover, Hamiltonian Cycle, TSP, 3-Coloring), numbers (Subset Sum, Partition, Knapsack, ILP), scheduling (Job Shop), games (Sudoku, Minesweeper, Tetris).

== Coping with NP-Hardness

#proposition[Exact algorithms][
    Branch-and-bound, backtracking. SAT solvers (CDCL) handle millions of variables in practice despite exponential worst-case.
]

#proposition[Approximation algorithms][
    Vertex Cover 2-approximation: repeatedly pick uncovered edge, add both endpoints. PTAS, APX.
    Some problems (general TSP) cannot be approximated at all unless $P = "NP"$.
]

#definition[FPT --- Fixed-Parameter Tractability][
    Solvable in $f(k) dot "poly"(n)$ where $k$ is a small parameter.
    Example: Vertex Cover in $O(1.27^k + n)$.
]

#proposition[Heuristics][
    Genetic algorithms, simulated annealing, local search. SAT/ILP solvers for structured real-world instances.
]

== Beyond NP

#proposition[Complexity hierarchy][
    $P subset.eq "NP" subset.eq "PSPACE" subset.eq "EXP"$.
    + *PSPACE*: polynomial space (QBF, generalised geography, $n times n$ chess).
    + *EXP*: exponential time (generalised chess, Go --- EXPTIME-complete).
    Known: $P subset "EXP"$ (Time Hierarchy Theorem). At least one inclusion above is strict --- which one(s) remain open.
]

#definition[Other classes][
    + *coNP*: complements of NP languages (UNSAT). Open: $"NP" = "coNP"$?
    + *PH* (Polynomial Hierarchy): generalises NP with alternating quantifiers. Collapses if $P = "NP"$.
    + *\#P*: counting solutions. \#SAT is \#P-complete (even harder than NP).
    + *BQP*: quantum polynomial time. $P subset.eq "BQP" subset.eq "PSPACE"$. Shor's algorithm (factoring) in BQP.
]

#remark[Cryptography][
    Modern crypto rests on assumed hardness: factoring (RSA), discrete log (Diffie-Hellman), AES.
    All in NP but not known NP-complete. One-way functions → $P eq.not "NP"$, but converse unknown.
]

#note[
    Practical lesson: if your problem is NP-complete, don't search for an efficient exact algorithm.
    Look for structure in your instances, consider approximation, parameterise on the small part, or use a SAT/ILP solver.
]

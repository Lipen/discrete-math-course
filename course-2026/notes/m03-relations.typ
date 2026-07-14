// M03 --- Relations: the mathematical language for connections between objects.
#import "common-notes.typ": *
#import "notation.typ": *

= Relations

#chapter-overview[
  Relations formalise connections between objects --- they underpin databases, equivalence, order, and graph theory.
  This chapter introduces binary relations and their algebraic properties, then focuses on two special kinds: equivalence relations (which partition sets) and partial orders (which rank and compare).
  The pigeonhole principle, a deceptively simple counting argument, closes the chapter with surprising applications throughout discrete mathematics.
]

== Binary Relations

=== Definitions and Representations

#definition[Binary relation][
  A binary relation $R$ on a set $A$ is a subset $R subset.eq A times A$.
  We write $a R b$ to mean $(a, b) in R$.
]

A relation can be specified in three equivalent ways:

#definition[Representations][
  - *Set of pairs*: $R = {(a_1, b_1), (a_2, b_2), ...}$.
  - *Adjacency matrix*: $n times n$ matrix $M$ where $M_(i j) = 1$ if $(a_i, a_j) in R$.
  - *Directed graph*: vertices = elements of $A$; directed edge $a arrow b$ iff $(a, b) in R$.
]

#example[
  $A = {1, 2, 3}$, $R = {(1, 1), (1, 2), (2, 3), (3, 1)}$.
  The adjacency matrix has 1s at those positions; the graph has self-loop at 1, edges $1 arrow 2$, $2 arrow 3$, $3 arrow 1$.
]

#remark[
  In a database, a table is a relation.
  Each row is a tuple in the relation.
  SQL tables are mathematical relations --- the connection is direct, not an analogy.
]

=== Properties of Relations

#definition[Relational properties][
  Let $R$ be a binary relation on $A$.
  - *Reflexive*: $forall a in A space a R a$.
  - *Irreflexive*: $forall a in A space not(a R a)$.
  - *Symmetric*: $a R b arrow b R a$.
  - *Antisymmetric*: $(a R b and b R a) arrow a = b$.
  - *Asymmetric*: $a R b arrow not(b R a)$.
  - *Transitive*: $(a R b and b R c) arrow a R c$.
  - *Total* (connected): $a eq.not b arrow (a R b or b R a)$.
]

#note[
  Irreflexive is stronger than "not reflexive."
  Asymmetry implies irreflexivity: if $a R a$, then $not(a R a)$ --- contradiction.
]

=== Reading Properties from Representations

#proposition[Property detection][
  - *Reflexive*: all diagonal entries 1; every vertex has self-loop.
  - *Irreflexive*: all diagonal entries 0; no self-loops.
  - *Symmetric*: matrix symmetric ($M = M^T$); every edge is bidirectional.
  - *Antisymmetric*: no symmetric 1s off-diagonal; no bidirectional edges.
  - *Transitive*: whenever there is a length-2 path, there is a direct edge.
]

=== Closures of Relations

#definition[Closure][
  - *Reflexive closure* of $R$: $R union {(a, a) mid(|) a in A}$.
  - *Symmetric closure*: $R union {(b, a) mid(|) (a, b) in R}$.
]

#definition[Composition of relations][
  Given $R subset.eq A times B$ and $S subset.eq B times C$, their composition is:
  $S @ R = {(a, c) mid(|) exists b in B space (a, b) in R and (b, c) in S}$.
  For a relation $R$ on $A$, powers: $R^1 = R$, $R^(k+1) = R^k @ R$.
]

#definition[Transitive closure][
  $R^+ = union.big_(k=1)^oo R^k$, where $R^(k+1) = R^k @ R$.
  In the graph, $a R^+ b$ iff there is a directed path from $a$ to $b$.
]

#remark[
  The Warshall algorithm computes the transitive closure in $O(n^3)$ via dynamic programming:
  for $k$, $i$, $j$: $M_(i j) = M_(i j) or (M_(i k) and M_(k j))$.
  This is the essence of Floyd-Warshall all-pairs shortest paths.
]


== Equivalence Relations

=== Definition and Equivalence Classes

#definition[Equivalence relation][
  A binary relation $sim$ on $A$ is an equivalence relation if it is reflexive, symmetric, and transitive.
]

#definition[Equivalence class][
  For $a in A$, the equivalence class of $a$ is $[a] = {b in A mid(|) a sim b}$.
]

#proposition[Class properties][
  - $a in [a]$ (reflexivity).
  - $[a] = [b]$ iff $a sim b$.
  - $[a] inter [b] = nothing$ iff $not(a sim b)$.
  Classes are either identical or disjoint.
]

=== The Partition Theorem

#theorem[Equivalence relations and partitions][
  The set of all equivalence classes $A\/sim = {[a] mid(|) a in A}$ forms a partition of $A$.
  Conversely, every partition of $A$ defines an equivalence relation: $a sim b$ iff $a$ and $b$ belong to the same part.
]

#proof[
  (Forward): Classes are pairwise disjoint and every element belongs to its own class.
  (Reverse): Given partition ${A_i}$, define $a sim b$ iff they share a part.
  This is reflexive, symmetric, and transitive (parts are disjoint, so sharing a part is an equivalence).
]

=== Examples of Equivalence Relations

#example[Equality modulo $m$][
  $a sim b$ iff $a equiv b (mod m)$.
  Classes: $ZZ_m = {[0], [1], ..., [m-1]}$.
  Addition and multiplication are well-defined on $ZZ_m$ --- the foundation of modular arithmetic and cryptography.
]

#example[Equinumerosity][
  $X sim Y$ iff there exists a bijection between $X$ and $Y$.
  The equivalence class is the cardinal number --- a teaser for the transfinite chapter.
]

#example[Graph isomorphism][
  $G sim H$ iff isomorphic.
  Returns in the graphs chapter of semester 2.
]

=== Applications of Equivalence Relations

#remark[
  *Data clustering*: grouping records by attribute partitions the dataset into equivalence classes.
  *Hash tables*: the hash function partitions the key space; each bucket is a class.
  *DFA minimisation*: equivalent states (indistinguishable by any input) form classes; merging them gives the minimal DFA (semester 2).
]


== Partial Orders

=== Partial Order Definition

#definition[Partial order][
  A binary relation $prec.eq$ on $A$ is a partial order if it is reflexive, antisymmetric, and transitive.
  The pair $(A, prec.eq)$ is a *poset*.
]

#definition[Strict and total orders][
  - *Strict order* $<$: irreflexive, asymmetric, transitive.
  Interchangeable: $a < b$ iff $a prec.eq b$ and $a eq.not b$.
  - *Total order*: partial order where every pair is comparable.
]

#example[
  $(NN, <=)$ is total. $(cal(P)(A), subset.eq)$ is partial (not total for $|A| > 1$).
  Divisibility $a | b$ on $NN^+$ is partial: 2 and 3 are incomparable.
]

=== Hasse Diagrams

#definition[Hasse diagram][
  To draw the Hasse diagram of a finite poset:
  1. Remove self-loops.
  2. Remove edges implied by transitivity.
  3. Place $a$ lower than $b$ when $a < b$.
  4. Draw undirected lines --- direction implied by vertical position.
]

#example[
  For $(cal(P)({1, 2, 3}), subset.eq)$, the Hasse diagram is a cube: $nothing$ at bottom, ${1, 2, 3}$ at top, edges between sets differing by one element.
]

=== Extremal Elements and Bounds

#definition[Minimal, maximal, least, greatest][
  - $m$ is *minimal* if no element is strictly smaller.
  - $m$ is *maximal* if no element is strictly larger.
  - $m$ is the *least element* if $m prec.eq a$ for all $a$ (unique if exists).
  - $m$ is the *greatest element* if $a prec.eq m$ for all $a$ (unique if exists).
]

#definition[Bounds, supremum, infimum][
  - $u$ is an *upper bound* of $S$ if $s prec.eq u$ for all $s in S$.
  - The *supremum* (join) is the _least_ upper bound.
  - The *infimum* (meet) is the _greatest_ lower bound.
]

=== Lattices

#definition[Lattice][
  A poset is a *lattice* if every pair has both a supremum ($a or b$) and an infimum ($a and b$).
]

#example[
  $(cal(P)(A), subset.eq)$: join = $union$, meet = $inter$.
  $(NN^+, |)$: join = lcm, meet = gcd.
]

#definition[Distributive lattice and Boolean algebra][
  A lattice is *distributive* if $a and (b or c) = (a and b) or (a and c)$.
  A *Boolean algebra* is a complemented distributive lattice --- with 0, 1, and complement $overline(a)$.
]

#note[
  Propositional logic, set algebra, and Boolean algebra are the same abstract structure --- a complemented distributive lattice.
]

=== Lexicographic Order and Topological Sort

#definition[Lexicographic order][
  $(a_1, b_1) <_"lex" (a_2, b_2)$ iff $a_1 < a_2$, or $a_1 = a_2$ and $b_1 < b_2$.
  Extends to $n$-tuples and strings.
]

#definition[Topological sort][
  A topological sort of a finite poset is a total order $<=$ extending $prec.eq$: $a prec.eq b arrow a <= b$.
  Every finite poset has at least one topological sort.
]

#remark[
  Topological sorting: build systems (Make, Gradle), task scheduling, course prerequisites.
]

=== Applications of Orders

#remark[
  *Type hierarchies*: subclassing is a partial order on types; multiple inheritance introduces joins.
  *Versioning*: semver is not total --- different major versions are incomparable.
  *Distributed systems*: Lamport's happens-before is a partial order capturing causality without synchronised clocks.
]


== Pigeonhole Principle

#theorem[Pigeonhole principle][
  - *Simple form*: $n+1$ objects in $n$ boxes $=>$ at least one box has $>= 2$ objects.
  - *General form*: $m$ objects in $n$ boxes $=>$ some box has $>= ceil(m/n)$ objects.
]

#proof[
  If every box had $<= ceil(m/n) - 1$ objects, total would be $< n dot (m/n) = m$, contradiction.
]

In function language: if $|A| > |B|$, no injection $f: A arrow B$ exists --- the mathematical essence of hash collisions.

=== Examples

#example[
  Among 367 people, two share a birthday (366 possible birthdays).
]

#example[
  5 points in a unit square $=>$ two within distance $<= 1/sqrt{2}$.
  Partition into four $1/2 times 1/2$ subsquares; two points in same subsquare.
]

#example[
  Any graph on $n >= 2$ vertices has two vertices with the same degree.
  Degrees are ${0, ..., n-1}$; 0 and $n-1$ cannot both occur $=>$ at most $n-1$ distinct degrees.
]

#proposition[Erdős--Szekeres][
  Every sequence of $n^2 + 1$ distinct real numbers contains a monotone subsequence of length $n + 1$.
]

#proof-sketch[
  Assign each element $(italic("inc"), italic("dec"))$: longest increasing/decreasing subsequence ending there.
  At most $n^2$ labels if both $<= n$; $n^2 + 1$ elements $=>$ some label exceeds $n$ by pigeonhole.
]

#remark[
  The pigeonhole principle is the simplest case of Ramsey theory: "complete disorder is impossible."
  Any large enough structure contains a highly ordered substructure.
]

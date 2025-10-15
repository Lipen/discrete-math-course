#import "common.typ": *
#show: template

#set page(
  paper: "a4",
  margin: (top: 3cm, rest: 2cm),
  header: [
    #set text(10pt)
    #smallcaps[*Homework Assignment \#2*]
    #h(1fr)
    #link("https://github.com/Lipen/discrete-math-course")[*Discrete Mathematics*]
    \
    *Binary Relations*
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

#let power(x) = $cal(P)(#x)$
#let pair(a, b) = $angle.l #a, #b angle.r$
#let card(x) = $abs(#x)$
#let Jaccard = $cal(J)$
#let JaccardDist = $d_cal(J)$
#let rel(x) = math.class("relation", x)
#let nrel(x) = rel(math.cancel(x))
#let relmat(x) = $bracket.double.l #x bracket.double.r$
#let eqclass(x, R) = $bracket.l #x bracket.r_#R$
#let quotient(M, R) = $#M slash_(#R)$
#let congruent(a, b, n) = $#a equiv #b space (mod #n)$
#let boolprod = $dot.circle$
#let equinumerous = $approx$
#let finer = $lt.tri.eq$
#let consonance = $rel(triangle.l)$

#let Green(x) = text(green.darken(20%), x)
#let Red(x) = text(red.darken(20%), x)
#let Blue(x) = text(blue.darken(20%), x)

#let True = Green(`true`)
#let False = Red(`false`)

#let YES = Green(sym.checkmark)
#let NO = Red(sym.crossmark)

#let tasklist(id, cols: 1, body) = {
  let s = counter(id)
  s.update(1) // Start from 1

  set enum(numbering: _ => context {
    s.step()
    s.display("1.")
  })

  columns(cols, gutter: 1em)[#body]
}

== Problem 1: Relation Properties

For each relation below, determine whether it is _reflexive, irreflexive, coreflexive, symmetric, antisymmetric, asymmetric, transitive, left/right Euclidean, connected, semi-connected_.
Organize your findings in a table and provide counterexamples for properties that don't hold.

+ *Proximity relation:*
  For real numbers, define $x rel(R) y$ iff $|x - y| <= 1$.

+ *Subset hierarchy:*
  For all subsets of ${a,b,c}$, define $pair(A, B) in R$ iff $A subset.eq B$.

+ *Communication flow:*
  For users ${a,b,c,d}$, relation $R$ has adjacency matrix:
  $
    relmat(R) = natrix.bnat(
      0, 1, 0, 1;
      0, 0, 0, 1;
      1, 1, 0, 0;
      0, 0, 1, 0
    )
  $

+ *Game dominance:*
  In rock-paper-scissors, define $x rel(R) y$ iff "$x$ beats $y$".

+ *Modulo equivalence:*
  For natural numbers, define $x rel(R) y$ iff $congruent(x, y, 7)$.


== Problem 2: Social Network Relations

Consider a social network with users $U = {"Alice", "Bob", "Carol", "Dave", "Eve"}$ and three types of connections:
- *Friendship* $F$: mutual (symmetric) friend relations
- *Following* $L$: who follows whom (for updates)
- *Trust* $T$: who trusts whom (for recommendations)

Given these specific relations:
- $F = {pair("Alice", "Bob"), pair("Bob", "Alice"), pair("Carol", "Dave"), pair("Dave", "Carol")}$
- $L = {pair("Alice", "Carol"), pair("Bob", "Dave"), pair("Carol", "Alice"), pair("Dave", "Eve"), pair("Eve", "Bob")}$
- $T = {pair("Alice", "Bob"), pair("Bob", "Carol"), pair("Carol", "Dave"), pair("Dave", "Alice")}$

#block(sticky: true)[*Part (a): Relation Operations*]

+ Find the _mutual connections_ $B = F union (L inter L^(-1))$.
  What does $L inter L^(-1)$ represent?
+ Compute the _influence chain_ $I = L compose T$.
+ Compute the _trust chain_ $J = T compose L$.
+ Compare $I$ and $J$.
  What do they represent?
+ Is there exists an _influencer_ --- a user to whom all other users have a direct edge in $L union I$?
+ Is there exists a _trust hub_ --- a user to whom all other users have a direct edge in $T union J$?

#block(sticky: true)[*Part (b): Property Preservation*]

+ *Transitivity:*
  Is it true that if $R_1$ and $R_2$ are transitive relations, then $R_1 inter R_2$ is also transitive?
  Either prove this statement or construct a counterexample on ${1,2,3}$.

+ *Equivalence:*
  Prove that if $R$ and $S$ are equivalence relations on the same set, then $R inter S$ is also an equivalence relation.

+ *Symmetry:*
  Can the union of two symmetric relations not be symmetric?

#block(sticky: true)[*Part (c): Trust Propagation*]

Trust can spread in chains: you might trust someone because a person you trust recommends them.
Let $T^2 = T compose T$ represent _second-hand trust_ (trust over 2 people), $T^3 = T^2 compose T$ represent _third-degree trust_ (trust over 3 steps), and so on.
Define the _$k$-fold trust network_ as $T^[k] = union.big_(i=1)^k T^i$.

+ Compute $T^[2]$ and $T^[3]$.
+ When does the trust network _stabilize_?
  Find the smallest $k$ where $T^[k+1] = T^[k]$.
+ Show that the _ultimate trust network_ $T^+ = union.big_(n=1)^infinity T^n$ (containing all possible trust connections) also satisfies the transitivity property, for arbitrary initial trust relation $T$.


== Problem 3: Equivalence Relations

#block(sticky: true)[*Part (a): Equinumerosity Relation*]

The _equinumerosity relation_ $equinumerous$ is defined as: $A equinumerous B$ iff $card(A) = card(B)$.

+ Prove that $equinumerous$ is an equivalence relation over finite sets.
+ Prove that $equinumerous$ is an equivalence relation over infinite sets.
  #footnote[
    For infinite sets, $card(A) = card(B)$ means there exists a bijection between $A$ and $B$.
  ]
+ Find the quotient set of $power({a,b,c,d})$ by $equinumerous$.

#block(sticky: true)[*Part (b): Modular Arithmetic*]

Consider the relation $R_m$ on integers: $a rel(R_m) b$ iff $congruent(a, b, m)$ for fixed $m >= 1$.

+ Prove that $R_m$ is an equivalence relation for any $m >= 1$.
+ Describe the equivalence classes of $R_7$ and find the quotient set $quotient(ZZ, R_7)$.
+ Show that the quotient set $quotient(ZZ, R_m)$ has exactly $m$ elements.

#block(sticky: true)[*Part (c): String Permutation*]

Define relation $sim$ on the set of all finite strings over alphabet $Sigma = {a, b, c}$ where $s_1 sim s_2$ iff $s_2$ can be obtained from $s_1$ by rearranging (permuting) its characters.

For example, $"abc" sim "bca"$ and $"aab" sim "aba"$, but $"abc" sim.not "ab"$ and $"abc" sim.not "abb"$.

+ Prove that $sim$ is an equivalence relation.
+ Find all equivalence classes for strings over $Sigma$ of length 3.
+ How many equivalence classes exist for $Sigma$-strings of length $n$?


== Problem 4: Similarity Networks and Tolerance Relations

Academic researchers often collaborate when they share common expertise areas.
We model this collaboration potential using the _#box[$theta$-similarity] relation_ $R_theta$, where $theta in [0,1] subset.eq RR$ is a similarity threshold parameter.
Two researchers $A$ and $B$ are _$theta$-similar_ (denoted $A rel(R_theta) B$) if their Jaccard similarity coefficient satisfies:
#v(-0.3em)
$
  Jaccard(A, B) = frac(card(A inter B), card(A union B)) >= theta
$
where $A$ and $B$ represent the finite sets#footnote[
  Either consider only non-empty sets, or define $Jaccard(emptyset, emptyset) = 1$.
] of expertise areas for each researcher.

Consider six researchers with expertise in the following areas:
#align(center, table(
  columns: 2,
  align: (left, left),
  stroke: (x, y) => if y == 0 { (bottom: 0.6pt) },
  table.header([*Researcher*], [*Expertise Areas*]),
  [赖 (Lài)], [$"Graph Theory", "High-Performance Computing", "Bioinformatics", "Databases"$],
  [石 (Shí)], [$"Internet of Things", "Cryptography", "Formal Methods", "Embedded Systems"$],
  [邱 (Qiū)], [$"Cryptography", "Algorithms", "Bioinformatics"$],
  [魏 (Wèi)], [$"High-Performance Computing", "Databases", "Graph Theory", "Algorithms"$],
  [辛 (Xīn)], [$"Embedded Systems", "Algorithms", "Databases"$],
  [朱 (Zhū)], [$"Formal Methods", "Internet of Things", "Cryptography", "Databases"$],
))

#block(sticky: true)[*Part (a): Building the Collaboration Network*]

For a similarity threshold of $theta = 0.25$:
+ Calculate all pairwise Jaccard similarities $Jaccard(A, B)$ between the six researchers.
+ Determine which pairs are $0.25$-similar.
+ Draw the collaboration network graph $G_(0.25)$, where vertices are researchers and edges connect $0.25$-similar pairs.

#block(sticky: true)[*Part (b): Properties of the Similarity Relation*]

+ Prove that the $theta$-similarity relation $R_theta$ is a _tolerance relation_ for any $theta in [0; 1]$ by showing it is reflexive and symmetric.
+ For the specific researcher data, determine whether the relation $R_(0.25)$ is transitive. If not, provide a counterexample where transitivity fails.
+ For which value(s) of $theta$ (if any) does $R_theta$ become an equivalence relation for arbitrary sets?

#block(sticky: true)[*Part (c): Network Structure and Dynamics*]

+ Identify all research _clusters_ (the connected components) in the graph $G_(0.25)$.
+ As $theta$ increases from 0 to 1, the collaboration network $R_theta$ loses edges.
  Find all _critical_ values of $theta$ at which the number of connected components in the network changes.
+ What is the maximum value of $theta$ for which the collaboration network of our six researchers remains connected (i.e., is a single connected component)?

#block(sticky: true)[*Part (d): Researcher Impact Analysis*]

+ *Diversity analysis:*
  Define the _diversity index_ $d(X)$ of a researcher $X$ as their number of expertise areas, $d(X) = card(X)$.
  For each researcher, compute their diversity index and their average Jaccard similarity with all others:
  $
    overline(Jaccard)(X) = 1/5 sum_(Y != X) Jaccard(X, Y)
  $
  Does the researcher with the highest diversity index also have the highest average similarity?

+ *Network resilience:*
  If one researcher were to leave the network, whose absence would cause the most fragmentation?
  Determine which researcher's removal from the $theta=0.25$ network results in the maximum number of connected components.


#pagebreak()

== Problem 5: Boolean Matrix and Transitive Closure

#block(sticky: true)[*Part (a): Boolean Matrix Product*]

Any relation $R subset.eq M^2$ on a finite set $M$ with $n = card(M)$ can be represented as an $n times n$ Boolean matrix $relmat(R) = [r_(i j)]$, where $r_(i j) = 1$ iff $pair(m_i, m_j) in R$, and $0$ otherwise.

The _Boolean product_ of two matrices $A boolprod B = [c_(i j)]$ is defined as: $c_(i j) = or.big_k (a_(i k) and b_(k j))$.

+ Compute the Boolean product:
  $
    natrix.bnat(
      1, 0, 1;
      0, 1, 0;
      1, 1, 0
    )
    boolprod
    natrix.bnat(
      0, 1, 1;
      1, 0, 1;
      0, 1, 0
    )
  $
+ For the Boolean matrix $M$ below, compute its Boolean square $M boolprod M$ and cube $M boolprod M boolprod M$.
  Interpret these results in terms of paths in the corresponding directed graph.
  $
    M = natrix.bnat(
      1, 1, 0;
      0, 1, 1;
      1, 0, 1
    )
  $
+ Prove that if $R$ and $S$ are relations, then the matrix of $S compose R$ equals $relmat(R) boolprod relmat(S)$.

#block(sticky: true)[*Part (b): Warshall's Algorithm for Transitive Closure*]

The _Warshall algorithm_ computes the transitive closure $R^+$ of a relation $R$ on a set $M$ of size $n$.
Given the $n times n$ adjacency matrix $A$ of the relation, the algorithm iteratively computes a sequence of matrices $A^((0)), A^((1)), dots, A^((n))$.

It starts with $A^((0)) = A$ and uses the following recurrence for $k = 1, ..., n$:
$
  A^((k))_(i j) = A^((k-1))_(i j) or (A^((k-1))_(i k) and A^((k-1))_(k j))
$
The final matrix $A^((n))$ is the adjacency matrix of the transitive closure $R^+$.

+ Apply Warshall's algorithm to compute the transitive closure of $R$ on $M = {1, 2, 3, 4}$:
  $ R = { pair(1, 2), pair(2, 3), pair(3, 1), pair(3, 4) } $
  Show the matrix at each iteration step, $A^((0)), A^((1)), A^((2)), A^((3))$, and the final result $A^((4))$.
+ Prove by induction on $k$ that $A^((k))_(i j) = 1$ if and only if there is a path from vertex $i$ to $j$ using only intermediate vertices from the set ${1, ..., k}$.
+ Compare the computational complexity of Warshall's algorithm with the naive approach of computing $A^+ = A or A^2 or ... or A^n$ using Boolean matrix products (powers).


#pagebreak()

== Problem 6: Proof Validation and Counterexamples

#block(sticky: true)[*Part (a): Find the Error*]

Critique the following "proof":

_"Theorem":_ If relation $R$ is symmetric and transitive, then $R$ is reflexive.

_"Proof":_ Let $a in A$. Take $b in A$ such that $pair(a, b) in R$. Since $R$ is symmetric, $pair(b, a) in R$. By transitivity, with $pair(a, b) in R$ and $pair(b, a) in R$, we get $pair(a, a) in R$.

+ Identify the logical error.
+ Provide a counterexample showing a symmetric and transitive relation that isn't reflexive.

#block(sticky: true)[*Part (b): Closure Operations*]

Find a relation $R$ on ${a,b,c}$ such that the symmetric closure of the reflexive closure of the transitive closure of $R$ is _not_ transitive.

*Hint:* Work backwards --- start with a non-transitive relation and see what $R$ could produce it.


== Problem 7: Data Pipeline Composition

Modern data processing systems rely heavily on chaining operations together.
Understanding how mathematical properties are preserved (or lost) through the composition of steps is crucial for building reliable pipelines.

#block(sticky: true)[*Part (a): Reversible Data Transformations*]

Consider a multi-stage data processing pipeline where data flows through different formats:
#align(center)[
  #import fletcher: diagram, edge, node
  #diagram(
    spacing: 1cm,
    node-shape: fletcher.shapes.rect,
    node-corner-radius: 3pt,
    node-stroke: 1pt + gray,
    edge-stroke: 1pt,
    blob(
      (0, 0),
      [Raw \ Data],
      name: <raw>,
    ),
    edge("-}>", label: [$P$]),
    blob(
      (1, 0),
      [Preprocessed \ Data],
      name: <pre>,
    ),
    edge("-}>", label: [$T$]),
    blob(
      (2, 0),
      [Processed \ Data],
      name: <data>,
    ),
    edge(
      <raw.south-east>,
      <data.south-west>,
      "-}>",
      label: [$T compose P$],
      bend: -15deg,
    ),
  )
  #v(-.5em)
]

Let $P$ represent the preprocessing step (e.g., converting human-filled Excel to machine-readable JSON) and $T$ represent the transformation step (e.g., JSON to analytics results).
The complete pipeline is the _composition_ $T compose P$, which directly transforms raw data to final results.
In data engineering, it's often crucial to trace data provenance backwards --- if we see a result, we want to know which original data produced it.

For relations $R subset.eq A times B$ and $S subset.eq B times C$, prove that the inverse of the composition equals the composition of individual inverse steps:
$(S compose R)^(-1) = R^(-1) compose S^(-1)$.

_This composition property ensures that data provenance tracking works correctly in complex pipelines._

#block(sticky: true)[*Part (b): Pipeline Integrity Analysis*]

In real-world data systems, we often need to ensure that certain properties are preserved through multi-stage processing. Consider a concrete pipeline:

- $R =$ set of raw customer records (with potential duplicates and missing fields)
- $C =$ set of cleaned customer records (deduplicated, standardized)
- $F =$ set of customer feature vectors (for machine learning)

#align(center)[
  #import fletcher: diagram, edge, node
  #diagram(
    spacing: 1cm,
    node-shape: fletcher.shapes.rect,
    node-corner-radius: 3pt,
    node-stroke: 1pt + gray,
    edge-stroke: 1pt,
    blob(
      (0, 0),
      [Raw \ Data],
    ),
    edge("-}>", label: [$f$]),
    blob(
      (1, 0),
      [Cleaned \ Records],
    ),
    edge("-}>", label: [$g$]),
    blob(
      (2, 0),
      [Feature \ Vectors],
    ),
  )
]

// + If $f$ and $g$ are injective, is $g compose f$ injective?
// + If $f$ and $g$ are surjective, is $g compose f$ surjective?
// + If $g compose f$ is injective, is $f$ injective?
// + If $g compose f$ is injective, is $g$ injective?
// + If $g compose f$ is surjective, is $f$ surjective?
// + If $g compose f$ is surjective, is $g$ surjective?

Let $f: R -> C$ be the data cleaning function and $g: C -> F$ be the feature extraction function.
The complete pipeline is their _function composition_ $g compose f: R -> F$, and we need to analyze how properties are preserved through composition:

+ *Uniqueness preservation:*
  If cleaning never merges distinct customers (injective $f$) and feature extraction never merges distinct records (injective $g$), does the complete pipeline preserve customer uniqueness (injective $g compose f$)?
+ *Coverage guarantee:*
  If cleaning produces all possible clean record types (surjective $f$) and extraction produces all possible feature vectors (surjective $g$), does the pipeline produce all possible features (surjective $g compose f$)?
+ *Pipeline diagnostics:*
  If the complete pipeline preserves customer uniqueness, can we conclude the cleaning step never merges customers?
+ *Error isolation:*
  If the complete pipeline preserves customer uniqueness, can we conclude the feature extraction never merges records?
+ *Intermediate coverage analysis:*
  If the complete pipeline produces all possible feature vectors, can we conclude the cleaning step produces all possible clean record types?
+ *Output coverage analysis:*
  If the complete pipeline produces all possible feature vectors, can we conclude the extraction step produces all possible features from clean data?

For each property, either prove the statement or provide a concrete counterexample using realistic data processing scenarios (e.g., filtering operations, aggregations, joins).


== Problem 8: Cardinality and Infinity

For each set below, determine whether it is _countable_ (same size as natural numbers) or _uncountable_ (strictly larger than natural numbers).
Provide clear justifications, including explicit bijections or diagonalization arguments where appropriate.

+ The set of rational
  #footnote[
    A rational number is a fraction $m "/" n$, where $m in ZZ$ is an integer and $n in NN^+$ is a natural number.
  ]
  numbers $QQ$.
+ The power set of natural numbers $power(NN)$.
+ The set of all functions $f: NN -> NN$.
+ The union of countably many countable sets.
+ The set of all computer programs in a particular programming language.
+ The set of real roots of all quadratic equations $a x^2 + b x + c = 0$ with integer coefficients.


#pagebreak()

== Problem 9: Partial Orders

#block(sticky: true)[*Part (a): Divisibility Poset*]

Consider $H = {1,2,4,5,10,12,20}$ with _divisibility_
#footnote[
  A number $x$ _divides_ $y$ (denoted $x | y$) if there exists an integer $k$ such that $y = k dot x$.
]
relation $x rel(R) y$ iff $x | y$.

Define grading function $rho(n)$ to be the sum of exponents in prime factorization of $n$.
For example: $rho(20) = rho(2^#Blue[$2$] dot 5^#Green[$1$]) = #Blue[$2$] + #Green[$1$] = 3$.

+ Verify that $R$ is a partial order.
+ Is $R$ a total order? Explain.
+ Draw the Hasse diagram for $pair(H, R)$ with elements arranged by grade $rho(n)$.
+ Find all minimal, maximal, minimum, and maximum elements, if they exist.
+ Perform a topological sort of $H$.
// + Identify all chains and antichains of maximum length.


#block(sticky: true)[*Part (b): Harmonic Ordering*]

In music theory, notes can be ordered based on harmonic principles.
We'll explore two such orderings on the 12-note chromatic scale:
$N = {"C", "C"sharp, "D", "D"sharp, "E", "F", "F"sharp, "G", "G"sharp, "A", "A"sharp, "B"}$.

+ *Circle of Fifths Precedence:*
  The circle of fifths defines a precedence relation $prec.eq$ on the notes: #footnote[
    For this problem, we treat this as a linear sequence and ignore the wrap-around from F back to C.
  ]
  $
    "C" prec.eq "G" prec.eq "D" prec.eq "A" prec.eq "E" prec.eq "B" prec.eq "F"sharp prec.eq "C"sharp prec.eq "G"sharp prec.eq "D"sharp prec.eq "A"sharp prec.eq "F"
  $
  Verify that this relation is a partial order and draw its Hasse diagram.

+ *Consonance Dominance:*
  Notes can also be ordered by their consonance relative to a root note (here, C).
  The hierarchy of consonance levels is given by the table below.
  #align(center, table(
    columns: 4,
    align: (center, left, left, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.6pt) },
    table.header([*Level*], [*Category*], [*Notes*], [*Interval*]),
    [0], [Perfect Unison], [$"C"$], [Unison],
    [1], [Perfect Consonances], [$"G", "F"$], [Perfect 5th, 4th],
    [2], [Imperfect Consonances], [$"E", "A"$], [Major 3rd, 6th],
    [3], [Near Consonances], [$"D", "B"$], [Major 2nd, 7th],
    [4], [Mild Dissonances], [$"C"sharp, "D"sharp, "G"sharp, "A"sharp$], [Minor intervals],
    [5], [Maximum Dissonance], [$"F"sharp$], [Tritone],
  ))
  Define the _consonance dominance_ relation $consonance$ such that $x consonance y$ if note $x$ is strictly more consonant than note $y$, that is, $"level"(x) < "level"(y)$.
  A note at a certain level dominates all notes at higher-numbered (less consonant) levels.

  - Is $consonance$ reflexive? Antisymmetric? Transitive? Is it a partial order?
  - Draw the Hasse diagram for the poset $pair(N, consonance)$.
  - Identify all maximal and minimal elements in this poset.


== Problem 10: Advanced Topics

#block(sticky: true)[*Part (a): Well-Founded and Well-Ordered Relations*]

A poset is _well-founded_ if every non-empty subset has a _minimal_ element.
A poset is _well-ordered_ if it is a well-founded total order (or, equivalently, if every non-empty subset has a _least_ element).

+ Is lexicographic order well-founded on the set of _finite_ lowercase English strings?
+ Is lexicographic order well-founded on the set of _infinite_ lowercase English strings?
+ Construct an example of a poset that is well-founded but not well-ordered.

#block(sticky: true)[*Part (b): Partition Refinement Lattices*]

A partition $alpha$ of a set $S$ is a _refinement_ of a partition $beta$, denoted
#footnote[
  We say that "$alpha$ is _finer_ than $beta$" or "$beta$ is _coarser_ than $alpha$".
]
$alpha finer beta$, if every block of $alpha$ is a subset of some block of $beta$.

#example[
  For the set $S = {a, b, c}$, the partition $alpha = {{a}, {b}, {c}}$ is a refinement of $beta = {{a, b}, {c}}$, because the blocks ${a}$ and ${b}$ are subsets of ${a, b}$, and ${c}$ is a subset of ${c}$.
]

+ Prove that the set of all partitions of a set $S$, ordered by the refinement relation $finer$, forms a lattice.
+ For $S = {a,b,c}$, list all 5 possible partitions
  #footnote[
    The number of partitions of an $n$-element set is the #link("https://en.wikipedia.org/wiki/Bell_number")[Bell number] $B_n$.
    For example, $B_3 = 5$.
  ]
  and draw the Hasse diagram of the partition lattice.
+ Draw the Hasse diagram of the partition lattice for the set $S = {a,b,c,d}$.
+ Compare the structure of the partition refinement lattice to the Boolean lattice (the poset of subsets of $S$ ordered by $subset.eq$).
+ Is partition refinement lattice distributive?
+ Is partition refinement lattice complemented?


#line(length: 100%, stroke: 0.4pt)

*Submission Guidelines:*
- Organize solutions clearly with problem numbers and parts.
- For proofs: state assumptions, show logical steps, conclude with QED.
- For disproof: provide specific counterexamples with verification.
- For computational problems: show work and double-check answers.
- Use tables, diagrams, and visual aids where helpful.

*Grading Rubric:*
- Mathematical accuracy and completeness: 50%
- Proof quality and logical reasoning: 30%
- Clarity, organization, and presentation: 20%

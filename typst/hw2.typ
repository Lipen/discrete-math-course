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
#let boolprod = math.class("binary", $dot.circle$)
#let equinumerous = math.approx

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

For each relation below, determine whether it is _reflexive, irreflexive, coreflexive, symmetric, antisymmetric, asymmetric, transitive, left/right Euclidean, connex_.
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
  For natural numbers, define $x rel(R) y$ iff $x equiv y space (mod 7)$.


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
+ Compute the _influence chain_ $I = L compose T$. List all pairs in $I$.
+ Compute the _trust chain_ $J = T compose L$. List all pairs in $J$.
+ Compare $I$ and $J$. What do they represent?
+ Determine if there exists an _influencer_ --- a user to whom all other users are connected in $L union I$.
+ Determine if there exists a _trust hub_ --- a user to whom all other users are connected in $T union J$.

#block(sticky: true)[*Part (b): Property Preservation*]

+ *Transitivity:*
  Is it true that if $R_1$ and $R_2$ are transitive relations, then $R_1 inter R_2$ is also transitive?
  Either prove this statement or construct a counterexample on ${1,2,3}$.

+ *Equivalence:*
  Prove that if $R$ and $S$ are equivalence relations on the same set, then $R inter S$ is also an equivalence relation.

+ *Symmetry:*
  Can combining two symmetric relations destroy symmetry?
  Find the minimum example of two symmetric relations (on the same set) whose union is not symmetric.

#block(sticky: true)[*Part (c): Trust Propagation*]

Trust can spread in chains: you might trust someone because a person you trust recommends them.
Let $T^2 = T compose T$ represent _second-hand trust_ (trust over 2 people), $T^3 = T^2 compose T$ represent _third-degree trust_ (trust over 3 steps), and so on.

+ Compute $T^2$ and $T^3$.
+ When does the trust network _stabilize_? Find the smallest $k$ where $T^k = T^(k+1)$.
+ Show that the _ultimate trust network_ $T^+ = union.big_(n=1)^infinity T^n$ containing all possible trust connections also satisfies the transitivity property, for arbitrary initial trust relation $T$.


== Problem 3: Equivalence Relations and Quotient Sets

#block(sticky: true)[*Part (a): Equinumerosity Relation*]

The _equinumerosity relation_ $equinumerous$ is defined as: $A equinumerous B$ iff $card(A) = card(B)$.

+ Prove that $equinumerous$ is an equivalence relation over finite sets.
+ Prove that $equinumerous$ is an equivalence relation over infinite sets#footnote[For infinite sets, $card(A) = card(B)$ means there exists a bijection between $A$ and $B$.].
+ Find the quotient set of $power({a,b,c,d})$ by $equinumerous$.

#block(sticky: true)[*Part (b): Modular Arithmetic Equivalence*]

Consider the relation $R_m$ on integers defined by $a rel(R_m) b$ iff $a equiv b space (mod m)$ for fixed positive integer $m$.

+ Prove that $R_m$ is an equivalence relation for any $m >= 1$.
+ Describe the equivalence classes of $R_7$ and find the quotient set $ZZ slash R_7$.
+ Show that the quotient set $ZZ slash R_m$ has exactly $m$ elements and forms the additive group $ZZ_m$.

#block(sticky: true)[*Part (c): String Equivalence Under Permutation*]

Define relation $sim$ on the set of all finite strings over alphabet ${a, b, c}$ where $s_1 sim s_2$ iff $s_2$ can be obtained from $s_1$ by rearranging (permuting) its characters.

+ Prove that $sim$ is an equivalence relation.
+ Find all equivalence classes for strings of length 3.
+ How many equivalence classes exist for strings of length $n$? Express your answer in terms of partitions of $n$.


== Problem 4: Similarity Networks and Tolerance Relations

Academic researchers often collaborate when they share common expertise areas.
We model this collaboration potential using the _#box[$theta$-similarity] relation_ $R_theta$, where $theta in [0,1] subset.eq RR$ is a similarity threshold parameter.
Two researchers $A$ and $B$ are _$theta$-similar_ (denoted $A rel(R_theta) B$) if their Jaccard similarity coefficient satisfies:
$
  Jaccard(A, B) = frac(card(A inter B), card(A union B)) >= theta
$
where $A$ and $B$ represent the sets of expertise areas for each researcher.

Consider six researchers with expertise in the following areas:
- 赖 (Lài): ${ "Graph Theory", "High-Performance Computing", "Bioinformatics", "Databases" }$
- 石 (Shí): ${ "Internet of Things", "Cryptography", "Formal Methods", "Embedded Systems" }$
- 邱 (Qiū): ${ "Cryptography", "Algorithms", "Bioinformatics" }$
- 魏 (Wèi): ${ "High-Performance Computing", "Databases", "Graph Theory", "Algorithms" }$
- 辛 (Xīn): ${ "Embedded Systems", "Algorithms", "Databases" }$
- 朱 (Zhū): ${ "Formal Methods", "Internet of Things", "Cryptography", "Databases" }$

*Part (a):* For $theta = 0.25$:
+ Calculate all pairwise Jaccard similarities $Jaccard(A, B)$.
+ Determine which pairs are $theta$-similar (i.e., have Jaccard similarity $>= 0.25$).
+ Draw the collaboration network graph $G_theta$ showing only $theta$-similar connections.
+ Identify all research clusters (connected components) in the network.

#block(sticky: true)[*Part (b): $theta$-Relation Properties*]

+ Prove that $R_theta$ is a _tolerance relation_ for any $theta in [0,1]$ by showing it is reflexive and symmetric.
+ For the specific researcher data above, determine whether $R_(0.25)$ is transitive.
  If not, provide a counterexample showing where transitivity fails.
+ For which values of $theta$ (if any) does $R_theta$ become an equivalence relation for arbitrary sets?
+ What is the maximum value of $theta$ for which the collaboration network of our six researchers remains connected (i.e., forms a single connected component)?

#block(sticky: true)[*Part (c): Network Threshold Dynamics*]

+ *Threshold analysis:*
  As $theta$ increases from 0 to 1, the collaboration network $R_theta$ loses edges and components split.
  For the given researcher data, find all critical values of $theta$ where the number of connected components changes.
  List these threshold values and determine the number of components at each stage.

+ *Diversity analysis:*
  Define the _diversity index_ $d(X)$ of researcher $X$ as the number of expertise areas they have (i.e., $d(X) = card(X)$).
  For each researcher, compute their diversity index $d(X)$ and their average Jaccard similarity with all other researchers:
  $
    overline(Jaccard)(X) = 1/n sum_(Y != X) Jaccard(X, Y)
  $

  Test the hypothesis that the researcher with maximum diversity index also has maximum average Jaccard similarity.

+ *Network resilience:*
  If one researcher leaves the collaboration network, which absence causes the most fragmentation?
  Determine the researcher whose removal results in the maximum number of connected components in the remaining network.


== Problem 5: Boolean Matrix Operations and Transitive Closure

#block(sticky: true)[*Part (a): Boolean Matrix Operations*]

Any relation $R subset.eq M^2$ can be represented as a Boolean matrix $relmat(R) = [r_(i j)]$, where $r_(i j) = 1$ iff $pair(m_i, m_j) in R$, and $0$ otherwise.

The _boolean product_ of two matrices $A boolprod B = [c_(i j)]$ is defined as: $c_(i j) = or.big_k (a_(i k) and b_(k j))$.

+ Prove that if $R$ and $S$ are relations, then the matrix of $S compose R$ equals $relmat(R) boolprod relmat(S)$.
+ Compute the boolean product:
  $
    natrix.bnat(1, 0, 1; 0, 1, 0; 1, 1, 0)
    boolprod
    natrix.bnat(0, 1, 1; 1, 0, 1; 0, 1, 0)
  $

#block(sticky: true)[*Part (b): Transitive Closure*]

*Definition:* #h(.2em) $R^+ = union.big_(n=1)^infinity R^n$ is a _transitive closure_ of relation $R subset.eq M^2$, where:
- $R^1 = R$
- $R^(n+1) = R^n compose R$ for $n >= 1$
- $S compose R = {pair(a, c) | exists b in M: (a rel(R) b) and (b rel(S) c)}$ is the composition of relations $R$ and $S$.

+ Prove that $R^+$ is indeed transitive.
+ For relation $R = {pair(1, 2), pair(2, 3), pair(3, 1), pair(1, 4)}$ on ${1,2,3,4}$, compute $R^+$ step by step.

#block(sticky: true)[*Part (c): Warshall's Algorithm*]

The _Warshall algorithm_ computes the transitive closure of a relation using boolean matrix operations.
Given the adjacency matrix $A$ of relation $R$, it computes the matrix $A^+$ of $R^+$ using the recurrence:
$
  A^(k)_(i j) = A^(k-1)_(i j) or (A^(k-1)_(i k) and A^(k-1)_(k j))
$
where $A^(0) = A$ and $A^+ = A^(n)$ for an $n times n$ matrix.

+ Apply Warshall's algorithm to compute the transitive closure of relation $R$ from part (b).
  Show each iteration step $A^(k)$ for $k = 1, 2, 3, 4$.
+ Prove that the Warshall algorithm correctly computes the transitive closure in at most $n$ iterations.
+ Compare the computational complexity of Warshall's algorithm with the naive approach of repeatedly computing boolean matrix powers.


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


== Problem 7: Composition Properties

#block(sticky: true)[*Part (a): Composition of Relations*]

For relations $R subset.eq A times B$ and $S subset.eq B times C$, prove: $(S compose R)^(-1) = R^(-1) compose S^(-1)$.

#block(sticky: true)[*Part (b): Function Composition*]

For functions $f: A -> B$ and $g: B -> C$, analyze composition properties:

#tasklist("steps-fun-comp", cols: 2)[
  + If $f$ and $g$ are injective, is $g compose f$ injective?
  + If $f$ and $g$ are surjective, is $g compose f$ surjective?
  + If $g compose f$ is injective, is $f$ injective?
  #colbreak()
  + If $g compose f$ is injective, is $g$ injective?
  + If $g compose f$ is surjective, is $f$ surjective?
  + If $g compose f$ is surjective, is $g$ surjective?
]


== Problem 8: Cardinality and Infinity

For each set below, determine whether it is _countable_ (same size as natural numbers) or _uncountable_ (strictly larger than natural numbers).
Provide clear justifications, including explicit bijections or diagonalization arguments where appropriate.

+ The set of rational#footnote[A rational number is a fraction $m slash n$, where $m in ZZ$ is an integer and $n in NN^+$ is a natural number.] numbers $QQ$.
+ The power set of natural numbers $power(NN)$.
+ The set of all functions $f: NN -> NN$.
+ The union of countably many countable sets.
+ The set of all computer programs in a particular programming language.
+ The set of real roots of all quadratic equations $a x^2 + b x + c = 0$ with integer coefficients.


== Problem 9: Partial Orders and Hasse Diagrams

#block(sticky: true)[*Part (a): Divisibility Poset*]

Consider $H = {1,2,4,5,10,12,20}$ with divisibility relation $x R y$ iff $x | y$.

Define grading function $rho(n)$ to be the sum of exponents in prime factorization of $n$.
For example: $rho(20) = rho(2^2 dot 5^1) = 2 + 1 = 3$.

+ Verify that $R$ is a partial order.
+ Is $R$ a total order? Explain.
+ Draw the Hasse diagram for $pair(H, R)$ with elements arranged by grade $rho(n)$.
+ Find all minimal, maximal, minimum, and maximum elements, if they exist.
+ Perform a topological sort of $H$.
// + Identify all chains and antichains of maximum length.


#block(sticky: true)[*Part (b): Harmonic Ordering*]

In music theory, notes can be ordered by their _harmonic tension_ and _consonance hierarchy_.
We'll explore ordering relations based on harmonic principles.

Consider the chromatic scale: $N = {"C", "C"sharp, "D", "D"sharp, "E", "F", "F"sharp, "G", "G"sharp, "A", "A"sharp, "B"}$ (12 notes).

Define the _harmonic precedence_ relation $prec.eq$ where $x prec.eq y$ if note $x$ has equal or higher harmonic priority than note $y$ in the circle of fifths ordering, starting from C.

The circle of fifths gives us the ordering#footnote[
  Here, we ignore the octave repetition and omit the circular relation $F prec.eq C$.
]:
$
  "C" prec.eq "G" prec.eq "D" prec.eq "A" prec.eq "E" prec.eq "B" prec.eq "F"sharp prec.eq "C"sharp prec.eq "G"sharp prec.eq "D"sharp prec.eq "A"sharp prec.eq "F"
$

Define the _consonance dominance_ relation $triangle.l$ where $x triangle.l y$ if note $x$ is more consonant than note $y$ relative to C, based on harmonic interval theory.
Each consonance level dominates all levels below it in the hierarchy:
- Perfect unison: $"C"$ (0 semitones --- most consonant)
- Perfect consonances: $"G"$ (perfect 5th, 7 semitones) and F (perfect 4th, 5 semitones)
- Major consonances: $"E"$ (major 3rd, 4 semitones) and $"A"$ (major 6th, 9 semitones)
- Minor consonances: $"D"$ (major 2nd, 2 semitones) and $"B"$ (major 7th, 11 semitones)
- Mild dissonances: $"C"sharp$, $"D"sharp$, $"G"sharp$, $"A"sharp$
- Maximum dissonance: $"F"sharp$ (tritone, 6 semitones)

+ Verify that $prec.eq$ is a partial order by checking reflexivity, antisymmetry, and transitivity.
// Draw the Hasse diagram for this harmonic precedence ordering.

+ Analyze the consonance dominance relation $triangle.l$:
  - Is $triangle.l$ reflexive? Antisymmetric? Transitive? Partial order?
  - Draw the Hasse diagram for $pair(N, triangle.l)$, arranging notes by consonance levels.
  - Identify all maximal and minimal elements under $triangle.l$.

#let steps = $Delta$

+ Consider the _circle of fifths distance_ ordering $d$ where $x rel(d) y$ iff $steps("C", x) <= steps("C", y)$, where $steps("C", z)$ is the minimum number of perfect fifth steps needed to reach note $z$ from C in the circle of fifths.

  For example: $steps("C", "C") = 0$, $steps("C", "D") = 2$, $steps("C", "F"sharp) = 6$, $steps("C", "F") = 1$ (backwards), etc.

  - Prove that $d$ defines a partial order on $N$.
  - Find all elements that are comparable to C under this ordering.
  - What is the greatest lower bound (infimum) of the set ${"G", "F"}$ under this ordering?

// + Construct the _lexicographic harmonic ordering_ $prec.eq_"lex"$ by first ordering by consonance level, then by position in circle of fifths for ties.
//   - Show this gives a total order on $N$.
//   - List the first 6 elements in this total ordering.
//   - Find the unique minimal and maximal elements.


== Problem 10: Advanced Topics

#block(sticky: true)[*Part (a): Well-Founded Relations*]

A poset $pair(P, prec.eq)$ is _well-founded_ if it has no infinite decreasing chains.

// A poset is _well-ordered_ if every non-empty subset has a least element.

+ Is the set of lowercase English strings with lexicographic order well-founded?
+ What about finite strings vs. infinite strings?
+ Construct a poset that is well-founded but not well-ordered.

#block(sticky: true)[*Part (b): Partition Refinement Lattices*]

For a set $S$, define the refinement relation $prec.eq$ on partitions: $P_1 prec.eq P_2$ if every block of $P_1$ is contained in some block of $P_2$.

+ Prove that the set of all partitions of $S$ with refinement relation $prec.eq$ is a lattice.
+ For $S = {a,b,c}$, list all 5 possible partitions#footnote[
    The number of partitions of an $n$-element set is the #link("https://en.wikipedia.org/wiki/Bell_number")[Bell number] $B_n$.
    For example, $B_3 = 5$.
  ] and draw the Hasse diagram of the partition lattice.
+ Draw the Hasse diagram of the partition lattice for $S = {a,b,c,d}$.
+ Compare the partition refinement lattice to the Boolean lattice.


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

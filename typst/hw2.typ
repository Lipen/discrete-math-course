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

== Problem 1: Relation Properties Analysis

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

#block(sticky: true)[*Part (b): Musical Harmony*]

In music theory, notes are related by _harmonic intervals_.
We'll explore two types of musical relations: pitch equivalence and harmonic consonance.

Consider the chromatic scale: $N = {"C", "C"sharp, "D", "D"sharp, "E", "F", "F"sharp, "G", "G"sharp, "A", "A"sharp, "B"}$ (12 notes).

Define the _pitch class_ relation $P$ where $x rel(P) y$ if notes $x$ and $y$ have the same pitch class (i.e., they differ by a multiple of 12 semitones, or octaves).

For example: $C rel(P) C$ (same note), and if we extended beyond one octave, $C rel(P) C'$ (where $C'$ is C one octave higher).

Now define the _perfect harmony_ relation $H$ where $x rel(H) y$ if the interval between notes $x$ and $y$ is a unison (0 semitones), perfect fifth (7 semitones), or perfect fourth (5 semitones).

For example: $C rel(H) C$ (unison), $C rel(H) G$ (perfect fifth), $C rel(H) F$ (perfect fourth).

+ Show that $P$ is an equivalence relation by verifying reflexivity, symmetry, and transitivity.
  Find all equivalence classes under $P$.

+ Analyze the relation $H$:
  - Is $H$ reflexive? Symmetric? Transitive?
  - Give a specific counterexample if some property fails.
  - What type of relation is $H$?

+ The _harmonic closure_ $H^*$ is the smallest equivalence relation containing $H$.
  - Since $H$ is not transitive, we need to "close" it by adding all missing transitive connections.
  - Start by exploring: if C relates to G (perfect fifth), and G relates to D (perfect fifth), what new relations must be added for transitivity?
  - Continue this process systematically. Which notes can you reach from C through chains of perfect intervals?
  - Compute the complete equivalence class $[C]$ under $H^*$. How many notes does it contain?
  - How many total equivalence classes does $H^*$ have?
  - *Interpretation:* In music theory, notes connected through chains of perfect fifths and fourths are considered to be in the same "harmonic family."
    Does your mathematical result align with the musical principle that all chromatic notes are harmonically related through such chains?


== Problem 4: Similarity Networks and Tolerance Relations

Academic researchers often collaborate when they share common expertise areas.
We model this collaboration potential using the _#box[$theta$-similarity] relation_ $R_theta$, where $theta in [0,1] subset.eq RR$ is a similarity threshold parameter.
Two researchers $A$ and $B$ are _$theta$-similar_ (denoted $A rel(R_theta) B$) if their Jaccard similarity coefficient satisfies:
$
  Jaccard(A, B) = frac(card(A inter B), card(A union B)) >= theta
$
where $A$ and $B$ represent the sets of expertise areas for each researcher.

Consider six researchers with expertise in the following areas:
- Lai: ${ "Graph Theory", "High-Performance Computing", "Bioinformatics", "Databases" }$
- Shi: ${ "Internet of Things", "Cryptography", "Formal Methods", "Embedded" }$
- Qiu: ${ "Cryptography", "Algorithms", "Bioinformatics" }$
- Wei: ${ "High-Performance Computing", "Databases", "Graph Theory", "Algorithms" }$
- Xin: ${ "Embedded", "Algorithms", "Databases" }$
- Zhu: ${ "Formal Methods", "Internet of Things", "Cryptography", "Databases" }$

*Part (a):* For $theta = 0.25$:
+ Calculate all pairwise Jaccard similarities $Jaccard(A, B)$.
+ Determine which pairs are $theta$-similar (i.e., have Jaccard similarity $>= 0.25$).
+ Draw the collaboration network graph showing only $theta$-similar connections.
+ Identify all research clusters (connected components) in the network.

#block(sticky: true)[*Part (b): $theta$-Relation Properties*]

+ Prove that $R_theta$ is a _tolerance relation_ for any $theta in [0,1]$ by showing it is reflexive and symmetric.
+ For the specific researcher data above, determine whether $R_(0.25)$ is transitive.
  If not, provide a counterexample showing where transitivity fails.
+ For which values of $theta$ (if any) does $R_theta$ become an equivalence relation for arbitrary researcher expertise sets?
+ What is the maximum value of $theta$ for which the collaboration network of our six researchers remains connected (i.e., forms a single connected component)?

#block(sticky: true)[*Part (c): Network Threshold Dynamics*]

Real collaboration networks exhibit critical threshold phenomena: small changes in similarity requirements can dramatically restructure the entire network.

+ *Critical threshold analysis:*
  As $theta$ increases from 0 to 1, the collaboration network loses edges and components merge or split.
  Find all threshold values where the number of connected components changes.
  Identify the critical threshold $theta^*$ where the network first disconnects, and describe how the component structure evolves at each transition.

+ *Diversity vs. connectivity:*
  Define each researcher's _diversity index_ as their number of expertise areas.
  Calculate each researcher's diversity index and average Jaccard similarity with all others.
  Determine the validity of the claim: "The researcher with the most expertise areas has the highest average Jaccard similarity."

+ *Network resilience:*
  If one researcher leaves the collaboration network, which departure causes the most fragmentation?
  Determine which researcher's absence results in the maximum number of connected components, and justify your answer using graph connectivity principles.


== Problem 5: Matrix Representations and Boolean Algebra

#block(sticky: true)[*Part (a): Boolean Matrix Operations*]

Any relation $R subset.eq M^2$ can be represented as a boolean matrix $[r_(i j)]$ where $r_(i j) = 1$ iff $pair(m_i, m_j) in R$.

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

// TODO: Warshall-like algorithm with boolean matrices


== Problem 6: Proof Validation and Counterexamples

#block(sticky: true)[*Part (a): Find the Error*]

Critique the following "proof":

_"Theorem":_ If relation $R$ is symmetric and transitive, then $R$ is reflexive.

_"Proof":_ Let $a in A$. Take $b in A$ such that $pair(a, b) in R$. Since $R$ is symmetric, $pair(b, a) in R$. By transitivity, with $pair(a, b) in R$ and $pair(b, a) in R$, we get $pair(a, a) in R$.

+ Identify the logical error.
+ Provide a counterexample showing a symmetric, transitive relation that isn't reflexive.

#block(sticky: true)[*Part (b): Closure Operations*]

Find a relation $R$ on ${a,b,c}$ such that the symmetric closure of the reflexive closure of the transitive closure of $R$ is _not_ transitive.

// *Hint:* Work backwards --- start with a non-transitive relation and see what $R$ could produce it.


== Problem 7: Geometric Transformations

Consider all colorings of a $2 times 2$ checkerboard using red (#Red[$square.filled$]) and blue (#Blue[$square.filled$]) squares.
Let $R$ relate two colorings if one can be obtained from the other by rotation (90°, 180°, 270°) or reflection.

Example colorings related by $R$:

#cetz.canvas({
  import cetz: draw

  draw.scale(50%)

  let draw-rect((x, y), color) = draw.rect(
    (x, y),
    (x + 1, y + 1),
    fill: color.lighten(80%),
    stroke: color.darken(20%),
  )

  let draw-red(pos) = draw-rect(pos, red)
  let draw-blue(pos) = draw-rect(pos, blue)

  draw-red((0, 0))
  draw-blue((1, 0))
  draw-blue((0, 1))
  draw-red((1, 1))

  draw-blue((3, 0))
  draw-red((4, 0))
  draw-red((3, 1))
  draw-blue((4, 1))
})

*Part (a):*
+ Prove that $R$ is an equivalence relation.
+ How many distinct colorings exist?
+ What are the equivalence classes under $R$?

*Part (b):*
+ Draw representatives for each equivalence class.
+ Calculate the size of each equivalence class.
+ Verify that Burnside's lemma gives the correct count.

*Challenge:* Extend to a $3 times 3$ board. How many equivalence classes are there?


== Problem 8: Composition Properties

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


== Problem 9: Cardinality and Infinity

For each set below, determine whether it is _countable_ (same size as natural numbers) or _uncountable_ (strictly larger than natural numbers).
Provide clear justifications, including explicit bijections or diagonalization arguments where appropriate.

+ The set of rational#footnote[A rational number is a fraction $m slash n$, where $m in ZZ$ is an integer and $n in NN^+$ is a natural number.] numbers $QQ$.
+ The power set of natural numbers $power(NN)$.
+ The set of all functions $f: NN -> NN$.
+ The union of countably many countable sets.
+ The set of all computer programs in a particular programming language.
+ The set of real roots of all quadratic equations $a x^2 + b x + c = 0$ with integer coefficients.


== Problem 10: Partial Orders and Hasse Diagrams

#block(sticky: true)[*Part (a): Divisibility Poset*]

Consider $H = {1,2,4,5,10,12,20}$ with divisibility relation $x R y$ iff $x | y$.

+ Verify that $R$ is a partial order.
+ Is $R$ a total order? Explain.
+ Find all minimal, maximal, minimum, and maximum elements.
+ Perform a topological sort of $H$.

#block(sticky: true)[*Part (b): Graded Poset Visualization*]

Define grading function $rho(n)$ to be the sum of exponents in prime factorization of $n$.
For example: $rho(20) = rho(2^2 dot 5^1) = 2 + 1 = 3$.

+ Calculate $rho(n)$ for each $n in H$.
+ Draw the Hasse diagram for $pair(H, R)$ with elements arranged by grade $rho(n)$.
+ Identify all chains and antichains of maximum length.


== Problem 11: Advanced Topics

#block(sticky: true)[*Part (a): Well-Founded Relations*]

A poset $pair(P, prec.eq)$ is _well-founded_ if it has no infinite decreasing chains.

// A poset is _well-ordered_ if every non-empty subset has a least element.

+ Is the set of lowercase English strings with lexicographic order well-founded?
+ What about finite strings vs. infinite strings?
+ Construct a poset that is well-founded but not well-ordered.

#block(sticky: true)[*Part (b): Partition Lattices*]

For a set $S$, define refinement relation $prec.eq$ on partitions: $P_1 prec.eq P_2$ if every block of $P_1$ is contained in some block of $P_2$.

+ Prove this forms a lattice.
+ For $S = {a,b,c}$, draw the partition lattice.
+ Find the meet and join of partitions ${{a},{b,c}}$ and ${{a,b},{c}}$.

*Challenge:* Prove that every finite lattice is isomorphic to a sublattice of some partition lattice.


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

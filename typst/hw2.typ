#import "common.typ": *
#show: template

#set page(
  paper: "a4",
  margin: (top: 3cm, rest: 2cm),
  header: [
    #set text(10pt)
    #smallcaps[*Homework Assignment \#2*]
    #h(1fr)
    *Discrete Mathematics*
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
#let FuzzyJaccard = $tilde(cal(J))$
#let Cosine = $cal(C)$
#let CosineDist = $d_cal(C)$
#let relmat(x) = $bracket.double.l #x bracket.double.r$
#let circ = math.class("relation", $circle.small$)

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

Social media platforms use various relationships between users.
For each relation below, determine whether it is _reflexive, irreflexive, symmetric, antisymmetric, asymmetric, transitive, or connex_.
Organize your findings in a table and provide counterexamples for properties that don't hold.

#tasklist("steps1", cols: 2)[
  + On $RR$, users $x$ and $y$ are "close" if $|x - y| <= 1$ (within 1 unit distance).

  + On $power({a,b,c})$, relation "subset or equal" ($subset.eq$).

  + On ${a,b,c,d}$ with adjacency matrix:
    $mat(
      0, 1, 0, 1;
      0, 0, 0, 1;
      1, 1, 0, 0;
      0, 0, 1, 0
    )$

  + Rock-paper-scissors where $x R y$ means "$x$ beats $y$".

  + On ${1,2,3,4,5}$, relation "happened before" with pairs: ${(1,3), (1,4), (2,3), (2,4), (3,1), (3,4)}$.

  + On $NN$, relation $x equiv y space (mod 7)$.
]


== Problem 2: Relation Composition Laws

For arbitrary homogeneous relations $R subset.eq M^2$ and $S subset.eq M^2$, prove or disprove each statement:

+ If $R$ and $S$ are _reflexive_, then $R inter S$ is reflexive.
+ If $R$ and $S$ are _symmetric_, then $R inter S$ is symmetric.
+ If $R$ and $S$ are _transitive_, then $R inter S$ is transitive.
+ If $R$ and $S$ are _reflexive_, then $R union S$ is reflexive.
+ If $R$ and $S$ are _symmetric_, then $R union S$ is symmetric.
+ If $R$ and $S$ are _transitive_, then $R union S$ is transitive.

For #True statements, provide rigorous proofs.
For #False statements, construct counterexamples.


== Problem 3: Equivalence Relations and Quotient Sets

#block(sticky: true)[*Part (a): Equinumerosity Relation*]

The _equinumerosity relation_ $tilde.equiv$ is defined as: $A tilde.equiv B$ iff $card(A) = card(B)$.

+ Prove that $tilde.equiv$ is an equivalence relation over finite sets.
+ Prove that $tilde.equiv$ is an equivalence relation over infinite sets#footnote[For infinite sets, $card(A) = card(B)$ means there exists a bijection between $A$ and $B$.].
+ Find the quotient set of $power({a,b,c,d})$ by $tilde.equiv$.

#block(sticky: true)[*Part (b): Student Course Enrollment*]

A university tracks student course enrollments. Students are considered "academically similar" if they share at least 60% of their courses.
Let $S_1 = {"Math", "CS", "Physics"}$, $S_2 = {"Math", "CS", "Biology"}$, $S_3 = {"Math", "Physics", "Chemistry"}$, $S_4 = {"CS", "Biology", "Statistics"}$.

+ Define this as a formal relation using the Jaccard index.
+ Determine if this relation is an equivalence relation.
+ Find all equivalence classes if it exists, or explain why it doesn't.


== Problem 4: Similarity Networks

Dating apps match users based on shared interests. The _θ-similarity relation_ $R_theta$ connects users $A$ and $B$ if their Jaccard similarity $Jaccard(A, B) = frac(card(A inter B), card(A union B))$ is at least $theta$.

Consider five users with interests:
- Anton: ${1,2,5,6}$ (hiking, movies, cooking, reading)
- Bogdan: ${2,3,4,5,7,9}$ (movies, gaming, music, cooking, travel, art)
- Valera: ${1,4,5,6}$ (hiking, music, cooking, reading)
- Gleb: ${3,7,9}$ (gaming, travel, art)
- Danil: ${1,5,6,8,9}$ (hiking, cooking, reading, fitness, art)

*Part (a):* For $theta = 0.25$:
+ Calculate all pairwise Jaccard similarities.
+ Draw the similarity network graph.
+ Identify connected components.

*Part (b):*
+ Prove that $theta$-similarity is a tolerance relation (reflexive and symmetric).
+ Determine for which values of $theta$ it becomes an equivalence relation.
+ What's the maximum $theta$ for which the network stays connected?


== Problem 5: Matrix Representations and Boolean Algebra

*Part (a): Boolean Matrix Operations*

Any relation $R subset.eq M^2$ can be represented as a boolean matrix $[r_(i j)]$ where $r_(i j) = 1$ iff $pair(m_i, m_j) in R$.

The _boolean product_ $A circ B = [c_(i j)]$ is defined as: $c_(i j) = or.big_k (a_(i k) and b_(k j))$.

+ Prove that if $R$ and $S$ are relations, then the matrix of $S compose R$ equals $relmat(R) circ relmat(S)$.
+ Compute the boolean product:
  $
    natrix.bnat(1, 0, 1; 0, 1, 0; 1, 1, 0)
    circ
    natrix.bnat(0, 1, 1; 1, 0, 1; 0, 1, 0)
  $

*Part (b): Transitive Closure Algorithm*

+ Define the _transitive closure_ $R^+$ formally.
+ Prove that $R^+$ is indeed transitive.
+ For relation $R = {(1,2), (2,3), (3,1), (1,4)}$ on ${1,2,3,4}$, compute $R^+$ step by step.


== Problem 6: Proof Validation and Counterexamples

*Part (a): Find the Error*

Critique the following "proof":

_"Theorem":_ If relation $R$ is symmetric and transitive, then $R$ is reflexive.

_"Proof":_ Let $a in A$. Take $b in A$ such that $pair(a, b) in R$. Since $R$ is symmetric, $pair(b, a) in R$. By transitivity, with $pair(a, b) in R$ and $pair(b, a) in R$, we get $pair(a, a) in R$.

+ Identify the logical error.
+ Provide a counterexample showing a symmetric, transitive relation that isn't reflexive.

*Part (b): Closure Operations*

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


== Problem 8: Relation Composition Properties

For relations $R subset.eq A times B$ and $S subset.eq B times C$, prove: $(S compose R)^(-1) = R^(-1) compose S^(-1)$.


== Problem 9: Function Composition Properties

For functions $f: A -> B$ and $g: B -> C$, analyze composition properties:

#tasklist("steps8", cols: 2)[
  + If $f$ and $g$ are injective, is $g compose f$ injective?
  + If $f$ and $g$ are surjective, is $g compose f$ surjective?
  + If $g compose f$ is injective, is $f$ injective?
  #colbreak()
  + If $g compose f$ is injective, is $g$ injective?
  + If $g compose f$ is surjective, is $f$ surjective?
  + If $g compose f$ is surjective, is $g$ surjective?
]


== Problem 10: Partial Orders and Hasse Diagrams

*Part (a): Divisibility Poset*

Consider $H = {1,2,4,5,10,12,20}$ with divisibility relation $x R y$ iff $x | y$.

+ Verify that $R$ is a partial order.
+ Is $R$ a total order? Explain.
+ Find all minimal, maximal, minimum, and maximum elements.
+ Perform a topological sort of $H$.

*Part (b): Graded Poset Visualization*

Define grading function $rho(n)$ to be the sum of exponents in prime factorization of $n$.
For example: $rho(20) = rho(2^2 dot 5^1) = 2 + 1 = 3$.

+ Calculate $rho(n)$ for each $n in H$.
+ Draw the Hasse diagram for $pair(H, R)$ with elements arranged by grade $rho(n)$.
+ Identify all chains and antichains of maximum length.


== Problem 11: Advanced Topics

*Part (a): Well-Founded Relations*

A poset $pair(P, prec.eq)$ is _well-founded_ if it has no infinite decreasing chains.

// A poset is _well-ordered_ if every non-empty subset has a least element.

+ Is the set of lowercase English strings with lexicographic order well-founded?
+ What about finite strings vs. infinite strings?
+ Construct a poset that is well-founded but not well-ordered.

*Part (b): Partition Lattices*

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

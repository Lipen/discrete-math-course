#import "common.typ": *
#show: template

#set page(
  paper: "a4",
  margin: (top: 3cm, rest: 2cm),
  header: [
    #set text(10pt)
    #smallcaps[*Homework Assignment #1*]
    #h(1fr)
    *Discrete Mathematics*
    \
    *Set Theory*
    #h(1fr)
    *Fall 2025*
    #place(bottom, dy: 0.4em)[
      #line(length: 100%, stroke: 0.6pt)
    ]
  ]
)

#set text(12pt)
#set par(justify: true)

// Symbols and notation
#let power(x) = $cal(P)(#x)$
#let pair(a, b) = $angle.l #a, #b angle.r$
#let card(x) = $|#x|$
#let Jaccard = $cal(J)$
#let JaccardDist = $d_cal(J)$
#let cat = emoji.cat.face

// Helper functions
#let tasklist(cols, body) = {
  columns(cols, gutter: 1em)[#body]
}

= Set Theory: Foundations and Applications

*Instructions:* Show all work clearly. For true/false questions, provide brief justifications. For computational problems, show intermediate steps.

== Problem 1: Truth Values and Basic Set Relations

Determine the truth value of each statement below.
Consider $a$ and $b$ to be distinct _urelements_ (atomic objects that are not sets).

#tasklist(3)[
  #let s = counter("steps")
  #s.step() // ???
  #let step-num(_) = context {
    s.step()
    s.display("(a)")
  }

  #set enum(numbering: step-num)

  + $a in {{a}, b}$
  + $a in {a, {b}}$
  + ${a} in {a, {a}}$
  + ${a} subset {a, b}$
  + ${a} subset.eq {{a}, {b}}$
  + ${{a}} subset {{a}, {a, b}}$
  + ${{a}, b} subset.eq {a, {a, b}, {b}}$
  + ${a, a} union {a, a, a} = {a, a, a, a, a}$

  #colbreak()
  #set enum(numbering: step-num)

  + ${a, a} union {a, a, a} = {a}$
  + ${a, a} inter {a, a, a} = {a}$
  + ${a, a} inter {a, a, a} = {a, a}$
  + ${a, a, a} without {a, a} = {a}$
  + $emptyset in emptyset$
  + $emptyset subset.eq emptyset$
  + $emptyset subset emptyset$
  + $emptyset in {emptyset}$

  #colbreak()
  #set enum(numbering: step-num)

  + $emptyset subset.eq {{emptyset}}$
  + ${emptyset, emptyset} subset {emptyset}$
  + ${{emptyset}} subset {{emptyset}, {emptyset}}$
  + $a in power({a})$
  + $power({a, emptyset}) subset power({a, b, emptyset})$
  + ${a, b} subset.eq power({a, b})$
  + ${a, a} in power({a, a})$
  + ${{a}, emptyset} subset.eq power({a, a})$
]

== Problem 2: Venn Diagrams and Set Operations

Given the universal set $U = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}$ and its subsets:
- $A = {x in U | x "is even"}$
- $B = {x in U | x "is prime"}$ (Note: 1 is _not_ considered prime)
- $C = {2, 4, 7, 9}$

*Part (a):* Draw a Venn diagram showing all three sets (and the universum), and label each element in the appropriate regions.

*Part (b):* Find the following sets:

#tasklist(3)[
  + $B without overline(C)$
  + $B triangle.small (A inter C)$
  + $U without (overline(C) union A)$
  + $card({A union B union power(emptyset) union power(U)})$
  + $card(power(A without C))$
  + $(power(A) inter power(C)) without power(B)$
]

== Problem 3: Complex Set Constructions

Consider the following sets:
- $A = {1, 2, 4}$
- $B = {square, cat} union emptyset$ (where $square$ and $cat$ are distinct symbols)
- $C = power(emptyset) without {emptyset}$
- $D = {4, card(power({emptyset, C}))}$

Find:

#tasklist(2)[
  + $A triangle.small D$
  + $C times B$
  + $B inter overline(A)$
  + $B times power({C})$
  + $D^(card(C))$
  + ${D inter {A}} times (D union {card(D)})$
]

== Problem 4: The Jaccard Index and Metric Properties

The *Jaccard index* $Jaccard(A, B)$ for two finite sets $A$ and $B$ measures their similarity:
$ Jaccard(A, B) = (card(A inter B))/(card(A union B)) $
with the convention that $Jaccard(emptyset, emptyset) = 1$.

The *Jaccard distance* $JaccardDist(A, B)$ measures their dissimilarity:
$ JaccardDist(A, B) = 1 - Jaccard(A, B) $

Prove the following properties for arbitrary finite sets $A$, $B$, and $C$:

#[
  #set enum(numbering: "(a)")
  + *Reflexivity:* $Jaccard(A, A) = 1$ and $JaccardDist(A, A) = 0$
  + *Symmetry:* $Jaccard(A, B) = Jaccard(B, A)$ and $JaccardDist(A, B) = JaccardDist(B, A)$
  + *Identity of indiscernibles:* $Jaccard(A, B) = 1$ and $JaccardDist(A, B) = 0$ if and only if $A = B$
  + *Boundedness:* $0 <= Jaccard(A, B) <= 1$ and $0 <= JaccardDist(A, B) <= 1$
  + *Triangle inequality:* $JaccardDist(A, C) <= JaccardDist(A, B) + JaccardDist(B, C)$
]

*Note:* Properties (a)-(c) and (e) show that $JaccardDist$ is _a metric_ on the space of finite sets.

== Problem 5: Cartesian Products and Geometric Visualization

Sketch each of the following sets of points in the coordinate plane $RR^2$:

#tasklist(1)[
  + ${1, 2, 3} times (1, 3]$
  + $[1, 5) times (1, 4] without {pair(2, 3)}$
  + $[1, 7] times (1, 5] without (1, 4] times (1, 3)$
  + ${pair(x, y) | y in {1, 2, 3, 4, 5}, x in [1, 6-y)}$
  + ${pair(x, y) in [1, 5] times [1, 4) | (y >= x) or (x > 4)}$
  + ${pair(x, y) in (1, 5]^2 | 4(x-2)^2 + 9(y-3)^2 <= 36}$
]

== Problem 6: Self-Referential Sets

Find all sets $A$, $B$, and $C$ that satisfy the following system:
$
  A & = {1, card(B), card(C)} \
  B & = {2, card(A), card(C)} \
  C & = {1, 2, card(A), card(B)}
$

*Hint:* Start by determining possible values for $card(A)$, $card(B)$, and $card(C)$.

== Problem 7: Fuzzy Sets and Extended Operations

*Fuzzy sets* generalize classical sets by allowing elements to have degrees of membership between 0 and 1. Each element $x$ in a universe $X$ has a *membership degree* $mu(x) in [0, 1]$.

Given fuzzy sets:
- $F = {a: 0.4, b: 0.8, c: 0.2, d: 0.9, e: 0.7}$
- $R = {a: 0.6, b: 0.9, c: 0.4, d: 0.1, e: 0.5}$

+ *Complement:* For fuzzy set $S$, define $overline(S)$ where $mu_(overline(S))(x) = 1 - mu_S(x)$. Find $overline(F)$ and $overline(R)$.

+ *Union:* Define $S union T$ where $mu_(S union T)(x) = max{mu_S(x), mu_T(x)}$. Find $F union R$.

+ *Intersection:* Define $S inter T$ where $mu_(S inter T)(x) = min{mu_S(x), mu_T(x)}$. Find $F inter R$.

+ *Difference:* Propose your own definition for fuzzy set difference $S without T$. Find $F without R$ and $R without F$ using your definition.

== Problem 8: Cardinality and Infinity

Determine whether each of the following sets is countable or uncountable. Provide justification for your answers.

+ The set of rational numbers $QQ$
+ The power set of natural numbers $power(NN)$
+ The set of all functions $f: NN -> NN$
+ The union of countably many countable sets
+ The set of all real roots of quadratic equations $a x^2 + b x + c = 0$ where $a, b, c in ZZ$

== Problem 9: Fundamental Properties

Prove or disprove each statement:

+ *Transitivity of inclusion:* If $A subset.eq B$ and $B subset.eq C$, then $A subset.eq C$

+ *Power set cardinality:* $card(power(A)) = 2^(card(A))$ for any finite set $A$

+ *Complex numbers:* $card(CC) = card(RR)$ (the complex and real numbers are equinumerous)

+ *Kuratowski pairs:* $pair(a, b) = pair(c, d)$ if and only if $(a = c) and (b = d)$, where ordered pairs are defined as $pair(x, y) = {{x}, {x, y}}$

#line(length: 100%, stroke: 0.4pt)

*Submission Guidelines:*
- Show all work and reasoning clearly.
- For proofs, state what you're proving, provide clear logical steps, and indicate the end with QED or $square.filled$.
- For false statements, provide counterexamples.
- Collaborate with classmates, but write solutions independently.

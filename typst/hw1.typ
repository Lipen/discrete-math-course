#import "common.typ": *
#show: template

#set page(
  paper: "a4",
  margin: (top: 3cm, rest: 2cm),
  header: [
    #set text(10pt)
    #smallcaps[*Homework Assignment \#1*]
    #h(1fr)
    *Discrete Mathematics*
    \
    *Set Theory*
    #h(1fr)
    *Fall 2025*
    #place(bottom, dy: 0.4em)[
      #line(length: 100%, stroke: 0.6pt)
    ]
  ],
)

#set text(12pt)
#set par(justify: true)

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

#let Green(x) = text(green.darken(20%), x)
#let Red(x) = text(red.darken(20%), x)

#let True = Green(`true`)
#let False = Red(`false`)

#let tasklist(id, cols: 1, body) = {
  let s = counter(id)
  s.update(1) // Start from 1

  set enum(numbering: _ => context {
    s.step()
    s.display("1.")
  })

  columns(cols, gutter: 1em)[#body]
}

== Problem 1: Set Theory Evaluation

Evaluate each statement as #True or #False.
Provide brief justifications.
Consider $a$ and $b$ to be distinct ($a eq.not b$) _urelements_ (atomic objects that are not sets).

#tasklist("steps1", cols: 3)[
  + $a in {{a}, b}$
  + ${a} in {a, {a}}$
  + ${a} subset {a, a}$
  + ${a} subset.eq {{a}, {b}}$
  + ${{a}, b} subset.eq {a, {a, b}, {b}}$
  + ${a, b} inter {{b}} = {b}$
  + ${a, a, a} without {a} = {a, a}$
  #colbreak()
  + $emptyset in emptyset$
  + $emptyset subset.eq emptyset$
  + $emptyset subset emptyset$
  + $emptyset in {emptyset}$
  + $emptyset subset.eq {{emptyset}}$
  + ${emptyset, emptyset} subset {emptyset}$
  + $power(emptyset) = {emptyset}$
  #colbreak()
  + $a in power({a})$
  + $power({a, emptyset}) subset power({a, b, emptyset})$
  + ${a, b} subset.eq power({a, b})$
  + ${a, a} in power({a, a})$
  + ${{a}, emptyset} subset.eq power({a, a})$
  // TODO: two more
]


== Problem 2: Set Operations

#let Threats = $T$
#let Active = $A$
#let Human = $P$
#let Network = $N$
#let Critical = $C$
#let High = $H$
#let Medium = $M$

A cybersecurity team monitors different types of _network threats_.
They classify threats into sets based on their characteristics:
- $Active = {"malware", "phishing", "ddos", "ransomware", "botnet"}$
  #h(1fr) (currently _actively_ detected threats)
- $Human = {"phishing", "social-eng", "ddos", "insider", "malware"}$
  #h(1fr) (threats targeting _humans_)
- $Network = {"ransomware", "cryptojack", "ddos", "botnet", "worm"}$
  #h(1fr) (threats requiring _network access_)

The universal set $Threats = Active union Human union Network$ contains all distinct threat types mentioned above.

*Part (a):*
Compute the following and interpret each result in cybersecurity context:
#tasklist("steps2a", cols: 4)[
  + $Active inter Human$
  + $Active union Network$
  #colbreak()
  + $(Active inter Human) without Network$
  + $overline(Active) inter Human$
  #colbreak()
  + $Active symdiff Human$
  + $Human without (Active union Network)$
  #colbreak()
  + $power({Active, Human, Network})$
  + $card((Human union Network) inter overline(Active))$
]

*Part (b):*
The security team wants to prioritize threats.
Define _priority levels_:
- Critical: $Critical = Active inter Human inter Network$
  #h(1fr) (active, human-targeted, network-based)
- High: $High = (Active inter Human) without Network$
  #h(1fr) (active and human-targeted, but not network-based)
- Medium: $Medium = Active without (Critical union High)$
  #h(1fr) (remaining active threats)

+ Compute $Critical$, $High$, $Medium$.
+ Determine whether ${Critical, High, Medium}$ is a partition of $Active$.

*Part (c):*
Draw a Venn diagram showing sets $Active$, $Human$, and $Network$ with all threat types labeled in their appropriate regions.
Annotate the priority categories.

== Problem 3: Similarity and Distance Metrics

Streaming services use similarity measures to recommend content.
Consider _user preferences_ as sets of genres they enjoy.

Users and their preferred genres:
- Anna: $A = {"sci-fi", "thriller"}$
- Boris: $B = {"thriller", "drama", "romance"}$
- Clara: $C = {"horror", "romance", "drama", "comedy"}$
- Diana: $D = {"action", "sci-fi", "comedy", "fantasy"}$

#v(2cm, weak: true)

*Part (a):*
The _Jaccard similarity_ between users $X$ and $Y$ is defined as:
$
  Jaccard(X, Y) = frac(
    card(X inter Y),
    card(X union Y)
  )
$
with the convention that $Jaccard(emptyset, emptyset) = 1$.

The _Jaccard distance_ measures dissimilarity:
$
  JaccardDist(X, Y) = 1 - Jaccard(X, Y)
$

+ Calculate $Jaccard(X, Y)$ and $JaccardDist(X, Y)$ for all pairs among given users.
+ Determine which pair is most similar and which is most dissimilar.
+ Draw a graph with users as nodes and edges weighted by Jaccard similarity.

*Part (b):*
The _Cosine similarity_ for sets can be defined#footnote[#link("https://en.wikipedia.org/wiki/Cosine_similarity#Otsuka–Ochiai_coefficient")[Otsuka–Ochiai coefficient]] as:
$
  Cosine(X, Y) = frac(
    card(X inter Y),
    sqrt(card(X) dot card(Y))
  )
$

The _Cosine distance_ is $CosineDist(X, Y) = 1 - Cosine(X, Y)$.

+ Calculate $Cosine(X, Y)$ and $CosineDist(X, Y)$ for all user pairs.
+ Determine which pair is most similar and which is most dissimilar.
+ Draw a graph with users as nodes and edges weighted by Cosine similarity.

*Part (c):*
Prove that Jaccard distance satisfies the triangle inequality:
$
  JaccardDist(A, C) <= JaccardDist(A, B) + JaccardDist(B, C)
$
for arbitrary finite sets $A$, $B$, and $C$.

*Part (d):*
Show that cosine distance does NOT satisfy the triangle inequality by providing a specific counterexample.
Find three non-empty sets $X$, $Y$, and $Z$ such that:
$
  CosineDist(X, Z) > CosineDist(X, Y) + CosineDist(Y, Z)
$

*Hint*: Try sets of different sizes where one set has no intersection with the others.

*Part (e):*
A user with preferences $U = {"thriller", "horror"}$ joins the platform.
Using Jaccard similarity, find:
+ Users with similarity $>= 0.25$ to user $U$.
+ The most similar user to $U$.


#pagebreak()

== Problem 5: Coordinate Systems

A game developer is designing a 2D puzzle game with different gameplay zones.
Each zone is defined by specific coordinate regions in $RR^2$.

*Part (a):*
Sketch each gameplay zone in the coordinate plane:
+ Safe Zone: $[1, 4] times [2, 5]$
+ Danger Zone: $(2, 6] times [1, 4)$
+ Treasure Zone: ${(x,y) | x in {1, 3, 5}, y in [2, 4)}$
+ Boss Arena: ${(x,y) in [1, 6] times [1, 6] | (x-6)^2 + (y-1)^2 < 9}$

*Part (b):*
Power-ups spawn at lattice points (integer coordinates) within zones.
+ Count lattice points in Safe Zone.
+ Count lattice points in the overlap of Safe and Danger zones.
+ Find lattice points in Treasure Zone.


== Problem 6: Recursive Data Structures

In computer science, data structures often have self-referential definitions.
Consider the following systems where sets reference their own cardinalities.

*Part (a):*
Find all sets $X$ and $Y$ that satisfy:
$
  X & = {1, 2, card(Y)} \
  Y & = {card(X), 3, 4}
$

Start by determining possible values for $card(X)$ and $card(Y)$, then verify which combinations work.

*Part (b):*
Consider a more complex system:
$
  A & = {1, card(B), card(C)} \
  B & = {2, card(A), card(C)} \
  C & = {1, 2, card(A), card(B)}
$

Find all valid solutions $(A, B, C)$.
Explain why some potential solutions don't work.

*Part (c):*
Design your own _non-trivial_ self-referential set system.


== Problem 7: Fuzzy Sets

In many real‑world systems, categorical boundaries are blurred.
_Fuzzy sets_ model the partial or probabilistic membership via a function $mu(x) in [0;1] subset.eq RR$ assigning each element a _membership degree_ representing how "strongly" the element belongs to the set.

Consider two fuzzy sets over the same finite universe $X = {a,b,c,d,e}$:
$
  F = { a:0.4, b:0.8, c:0.2, d:0.9, e:0.7 } \
  R = { a:0.6, b:0.9, c:0.4, d:0.1, e:0.5 }
$

*Part (a):*
Define the complement of a fuzzy set S to be $mu_overline(S)(x) = 1 - mu_S (x)$.
Compute $overline(F)$ and $overline(R)$.

*Part (b):*
For the union, define $mu_(S union T)(x) = max{mu_S (x), mu_T (x)}$.
Compute $F union R$.

*Part (c):*
For the intersection, define $mu_(S inter T)(x) = min{mu_S (x), mu_T (x)}$.
Compute $F inter R$.

*Part (d):*
Propose and justify a definition for $S without T$.
Compute $F without R$ and $R without F$.

*Part (e):*
One fuzzy analogue of Jaccard similarity is:
$
  FuzzyJaccard_f (F,R) = frac(
    sum_(x in X) min { mu_F (x), mu_R (x) },
    sum_(x in X) max { mu_F (x), mu_R (x) }
  )
$
Compute $FuzzyJaccard_f (F,R)$ and the corresponding distance $1 - FuzzyJaccard_f (F,R)$.

*Part (f): Defuzzification.*
Suppose a system triggers an alert if an element’s membership in #box[$F union R$] exceeds $0.75$.
List all triggered elements with their degrees and briefly comment on the trade‑off between using crisp vs fuzzy thresholds.


== Problem 8: Power Sets

Let $A$ and $B$ be finite sets.
Prove or disprove each statement:
+ If $A subset.eq B$, then $power(A) subset.eq power(B)$
+ $power(A inter B) = power(A) inter power(B)$
+ $power(A union B) = power(A) union power(B)$
+ $card(power(A times B)) = 2^(card(A) dot card(B))$

== Problem 9: Cardinality and Infinity

Determine whether the following sets are countable or uncountable.
Provide justifications, including explicit bijections or diagonalization arguments where appropriate.
+ The set of rational#footnote[A rational number can be represented as a fraction $m slash n$, where $m in ZZ$ is an integer and $n in NN$ is a natural number.] numbers $QQ$.
+ The power set of natural numbers $power(NN)$.
+ The set of all functions of the form $f: NN -> NN$.
+ The union of a countable number of countable sets.
+ The set of all computer programs in a particular programming language.
+ The set of real roots of all equations of the form $a x^2 + b x + c = 0$ with integer coefficients.


#line(length: 100%, stroke: 0.4pt)

*Submission guidelines:*
- Show all work and reasoning clearly for computational problems.
- For proofs, state what you're proving, provide clear logical steps, and conclude with QED or $square$.
- For false statements, provide specific counterexamples.
- Collaborate with classmates on concepts, but write all solutions independently.
- Submit as PDF with clearly labeled problems and legible work.

*Grading rubric:*
- Computational accuracy: 50%
- Mathematical reasoning and proof quality: 30%
- Presentation and clarity: 20%

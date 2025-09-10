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

#let Green(x) = text(green.darken(20%), x)
#let Red(x) = text(red.darken(20%), x)

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

== Problem 1: Set Theory Evaluation

Evaluate each statement as #True or #False.
Provide brief justifications.
Consider $a$ and $b$ to be distinct ($a eq.not b$) _urelements_ (atomic objects that are not sets).

#tasklist("steps1", cols: 3)[
  + $a in {{a}, b}$
  + ${a} in {a, {a}}$
  + ${a} subset.eq {{a}, {b}}$
  + ${a, b} in {a, b}$
  + ${{a}, b} subset.eq {a, {a, b}, {b}}$
  + ${{a}} subset {{a}, {a}}$
  + ${a, a, a} without {a} = {a, a}$
  #colbreak()
  + $emptyset in emptyset$
  + $emptyset in {emptyset}$
  + $emptyset in {{emptyset}}$
  + $emptyset subset.eq emptyset$
  + $emptyset subset emptyset$
  + $emptyset subset.eq {{emptyset}}$
  + ${emptyset, emptyset} subset {emptyset}$
  #colbreak()
  + $power(emptyset) = {emptyset}$
  + $a in power({a})$
  + $power({a, emptyset}) subset power({a, b, emptyset})$
  + ${a, b} subset.eq power({a, b})$
  + ${a, a} in power({a, a})$
  + ${{a}, emptyset} subset.eq power({a, a})$
  + $power({a, b}) supset.eq {{a}, {emptyset}}$
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
They classify threats into sets based on their attack vectors:
- $Active = {"malware", "phishing", "ddos", "ransomware", "botnet"}$
  #h(1fr) (currently _actively_ detected threats)
- $Human = {"phishing", "social-eng", "ddos", "insider", "malware"}$
  #h(1fr) (threats targeting _humans_)
- $Network = {"ransomware", "cryptojack", "ddos", "botnet", "worm"}$
  #h(1fr) (threats requiring _network access_)

The universal set $Threats = Active union Human union Network$ contains all distinct threat types mentioned above.

*Note:* All complements ($overline(X)$) are taken relative to the universal set $Threats$.

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
The security team needs to triage threats effectively.
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
Use colors to annotate the priority categories.


#pagebreak()

== Problem 3: Similarity and Distance Metrics

Streaming services use similarity measures to recommend content.

Consider _user preferences_ as sets of genres they enjoy.
For example, if Anna loves mind-bending plots, her preference set is $A = {"sci-fi", "thriller"}$.

#align(center, table(
  columns: 9,
  align: (x, y) => {
    let h = if x == 0 { right } else { center }
    let v = if y == 0 { bottom }
    h + v
  },
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header(
    [],
    rotate(-90deg, reflow: true)[Sci-fi],
    rotate(-90deg, reflow: true)[Thriller],
    rotate(-90deg, reflow: true)[Drama],
    rotate(-90deg, reflow: true)[Romance],
    rotate(-90deg, reflow: true)[Horror],
    rotate(-90deg, reflow: true)[Comedy],
    rotate(-90deg, reflow: true)[Action],
    rotate(-90deg, reflow: true)[Fantasy],
  ),
  [*Anna*], [#YES], [#YES], [#NO], [#NO], [#NO], [#NO], [#NO], [#NO],
  [*Boris*], [#NO], [#YES], [#YES], [#YES], [#NO], [#NO], [#NO], [#NO],
  [*Clara*], [#NO], [#NO], [#YES], [#YES], [#YES], [#YES], [#NO], [#NO],
  [*Diana*], [#YES], [#NO], [#NO], [#NO], [#NO], [#YES], [#YES], [#YES],
))

*Part (a):*
The _Jaccard similarity_ measures how much two users' tastes overlap:
$
  Jaccard(X, Y) = frac(
    card(X inter Y),
    card(X union Y)
  ) = frac(
    "shared preferences",
    "total unique preferences"
  )
$
with the convention that $Jaccard(emptyset, emptyset) = 1$.

The _Jaccard distance_ measures how different users are:
$
  JaccardDist(X, Y) = 1 - Jaccard(X, Y)
$

+ Calculate $Jaccard(X, Y)$ and $JaccardDist(X, Y)$ for all pairs among users.
+ Determine which pair is most similar and which is most dissimilar.
+ Draw a social network graph with users as nodes and edges weighted by Jaccard similarity.
+ Build $G_(0.25)$: the graph with edges where Jaccard $>= 0.25$.
  List connected components.

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
+ Show that $Jaccard(X, Y) <= Cosine(X, Y)$ for all nonempty finite sets $X, Y$.
  When the equality holds?

*Part (c):*
Prove that Jaccard distance satisfies the triangle inequality:
$
  JaccardDist(A, C) <= JaccardDist(A, B) + JaccardDist(B, C)
$
for arbitrary finite sets $A$, $B$, and $C$.

// Prove that equality holds if and only if $A subset.eq B subset.eq C$ or $C subset.eq B subset.eq A$.

*Part (d):*
Show that cosine distance does NOT satisfy the triangle inequality by providing a specific counterexample.
Find three non-empty sets $X$, $Y$, and $Z$ such that:
$
  CosineDist(X, Z) > CosineDist(X, Y) + CosineDist(Y, Z)
$

*Part (e):*
A new user joins with preferences $U = {"thriller", "horror"}$.
Using Jaccard similarity, find existing users with similarity $>= 0.25$ to recommend as "users with similar taste."

*Challenge:*
Design your own similarity metric that you think would work better than Jaccard for movie recommendations.
Explain your reasoning.


== Problem 4: Logic and Set Identities

This problem bridges set theory and logical reasoning, preparing for formal proofs.

*Part (a):*
Translate each statement to first-order logic with quantifiers over a universal set $U$:
+ $A subset.eq B$
+ $A = B$
+ $A subset.eq B iff power(A) subset.eq power(B)$

*Part (b):*
Prove the following identities using both Venn diagrams and symbolic reasoning:
+ $(A without B) union (B without A) = (A union B) without (A inter B)$
+ De Morgan's laws: $overline(A union B) = overline(A) inter overline(B)$ and $overline(A inter B) = overline(A) union overline(B)$
+ $A subset.eq B$ if and only if $A inter B = A$ if and only if $A union B = B$
+ Distributive law: $A inter (B union C) = (A inter B) union (A inter C)$

*Part (c):*
For any universe $U$ and a set $X subset.eq U$, prove that the complement operator is:
+ An _involution_: $overline(overline(X)) = X$
+ Order-reversing (_anti-monotonic_): if $X subset.eq Y$, then $overline(Y) subset.eq overline(X)$


== Problem 5: Coordinate Systems

A game developer is designing a 2D puzzle game with different gameplay zones.
Each zone is defined by specific coordinate regions in $RR^2$.

*Part (a):*
Sketch all gameplay zones on the coordinate plane:
+ Game Area: $G = [0; 8] times [1; 7]$
+ Safe Zone: $S = (1; 4) times (5, 7]$
+ Impassible Wall: $W = { pair(x, 4) | 0 <= x <= 6 }$
+ Danger Zone: $D = { pair(x, y) in G | y < x "or" y < 4 }$
+ Treasure Zones: $T = { pair(x, y) | x in {1,2,3}, 0 < y <= 3 }$
+ Boss Arena: $B = { pair(x, y) in G | 16 (x - 9)^2 + 25 y^2 <= 400 }$

*Part (b):*
Power-ups spawn at lattice points (integer coordinates) within the Danger Zone $D$, excluding the wall $W$ and borders of $G$.
Count the number of such points.

*Part (c):*
A player starts at position $P_0 = pair(2, 6)$ and moves according to vectors $v_1 = pair(4, 0)$, #box($v_2 = pair(1, -2)$), and $v_3 = pair(-4, -3)$.
+ Calculate the player's position after each move: $P_i = P_(i-1) + v_i$.
+ Determine which zones the player is in after each move.
+ Does the player ever enter the Boss Arena $B$?


== Problem 6: Self-Referential Set Puzzles

In computer science, recursive data structures reference themselves.
These mathematical puzzles explore similar self-referential concepts that appear in programming, logic, and even philosophy.

*Part (a):*
Find all sets $X$ and $Y$ that satisfy this system:
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
Design your own _non-trivial_ self-referential set system involving 2--4 sets.


== Problem 7: Fuzzy Logic

In the real world, boundaries aren't always crisp.
Is a 180cm person tall?
Is 10°C warm?
_Fuzzy sets_ model this uncertainty and are crucial in AI, machine learning, and control systems.

Unlike classical sets where membership is binary (in/out), fuzzy sets assign each element a _membership degree_ $mu(x) in [0;1] subset.eq RR$ representing how "strongly" the element belongs.

Consider two fuzzy sets over $X = {a,b,c,d,e}$:
$
  F & = { a:0.4, b:0.8, c:0.2, d:0.9, e:0.7 } \
  R & = { a:0.6, b:0.9, c:0.4, d:0.1, e:0.5 }
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
For each statement below, either provide a _rigorous proof_ or find a _counterexample_ that disproves the claim.

+ If $A subset.eq B$, then $power(A) subset.eq power(B)$
+ $power(A inter B) = power(A) inter power(B)$
+ $power(A union B) = power(A) union power(B)$
+ $card(power(A times B)) = 2^(card(A) dot card(B))$


#line(length: 100%, stroke: 0.4pt)

*Submission Guidelines:*
- Show all work and reasoning clearly for computational problems.
- For proofs, state what you're proving, provide clear logical steps, and conclude with QED or $square$.
- For false statements, provide specific counterexamples.
- Collaborate with classmates, but write all solutions independently.
- Submit as PDF with clearly labeled problems and legible work.

*Grading Rubric:*
- Computational accuracy: 50%
  #h(1fr) #text(.7em)[(Getting the right answer)]
- Mathematical reasoning and proof quality: 30%
  #h(1fr) #text(.7em)[(Showing clear logical thinking)]
- Presentation and clarity: 20%
  #h(1fr) #text(.7em)[(Making your solutions easy to follow)]

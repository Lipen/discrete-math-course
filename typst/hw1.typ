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
Consider $a$ and $b$ to be distinct _urelements_ (atomic objects that are not sets).

#tasklist("steps1", cols: 2)[
  + $a in {a, b}$
  + $a in {{a}, b}$
  + ${a} in {a, {a}}$
  + ${a} subset.eq {a, b}$
  + ${a} subset {a, a}$
  + ${{a}} subset {{a}, {a, b}}$
  + ${a, b} union {b, b} = {a, b}$
  + ${a, b} inter {{b}} = {b}$
  + $emptyset notin emptyset$
  + $emptyset subset.eq emptyset$
  #colbreak()
  + $emptyset in {emptyset}$
  + ${emptyset, emptyset} subset {emptyset}$
  + ${{emptyset}} subset {{emptyset}, {emptyset}}$
  + $power(emptyset) = {emptyset}$
  + $a in power({a})$
  + ${a, a} in power({a, a})$
  + ${a, b} subset power({a, b})$
  + ${{a}} subset power({a})$
  + ${a, b, b} without {b} = {a, b}$
  + ${{a}, emptyset} subset.eq power({a, emptyset})$
]


== Problem 2: Network Security and Set Operations

#let Active = $A$
#let Human = $P$
#let Network = $N$
#let Threats = $T$
#let Critical = $C$
#let High = $H$
#let Medium = $M$

A cybersecurity team monitors different types of network threats. They classify threats into sets based on their characteristics:
- $Active = {"malware", "phishing", "ddos", "ransomware", "botnet"}$ #h(1fr) (_active_ threats detected)
- $Human = {"phishing", "social-eng", "ddos", "insider", "malware"}$ #h(1fr) (threats targeting _humans_)
- $Network = {"ransomware", "cryptojack", "ddos", "botnet", "worm"}$ #h(1fr) (threats requiring _network access_)

The universal set $Threats$ contains all distinct threat types mentioned above.

*Part (a):*
Compute the following and interpret each result in cybersecurity context:
#tasklist("steps2a", cols: 3)[
  + $Active inter Human$ // (threats that are both active and target humans)
  + $Active union Network$ // (threats that are either active or need network access)
  #colbreak()
  + $(Active inter Human) without Network$ // (human-targeted active threats that don't need network)
  + $overline(Active) inter Human$ // (human-targeted threats that aren't currently active)
  #colbreak()
  + $Active symdiff Human$ // (threats that are either active or human-targeted, but not both)
  + $Human without (Active union Network)$ // (human-targeted threats that are neither active nor network-based)
]

*Part (b):*
The security team wants to prioritize threats.
Define priority levels:
- Critical: $Critical = Active inter Human inter Network$ #h(1fr) (active, human-targeted, network-based)
- High: $High = (Active inter Human) without Network$ #h(1fr) (active and human-targeted, but not network-based)
- Medium: $Medium = Active without (Critical union High)$ #h(1fr) (active but not in higher priorities)

Find each priority set and verify that they form a _partition_ of $Threats$.

*Part (c):*
Draw a Venn diagram showing sets $Active$, $Human$, and $Network$ with all threat types labeled in their appropriate regions.


== Problem 3: Social Media Content Moderation

#let Categories = $S$
#let Flagged = $T$ // F
#let Reported = $U$
#let Manual = $M$

A social media platform uses automated systems to detect problematic content. Posts are classified into several categories:
- $Flagged = {"spam", "hate", "fake_news", "violence"}$ #h(1fr) (content types flagged by AI)
- $Reported = {"spam", "bot", "fake_news", "harassment"}$ #h(1fr) (content reported by users)
- $Manual = {"hate", "violence", "harassment", "doxxing"}$ #h(1fr) (content requiring manual review)

Define $Categories = Flagged union Reported union Manual$ as the universal set of all content categories.

*Part (a):*
A post can have multiple classifications.
Find:
+ Posts flagged by AI but not reported by users: $Flagged without Reported$
+ Posts needing both AI and manual review: $Flagged inter Manual$
+ Posts in exactly one classification system: $Flagged symdiff Reported symdiff Manual$
+ The "oversight gap" (user-reported issues not covered by AI or manual review): $Reported without (Flagged union Manual)$

*Part (b):*
The platform creates action sets based on combinations:
- $A_1 = Flagged inter Reported$ #h(1fr) (automatic removal - both AI and user flagged)
- $A_2 = Manual without A_1$ #h(1fr) (manual review - not automatically removed)
- $A_3 = (Flagged union Reported) without (A_1 union A_2)$ #h(1fr) (warning only)

Compute each action set and verify they partition $Flagged union Reported union Manual$.

*Part (c):*
Calculate the power set $power({Flagged, Reported, Manual})$ and interpret what do subsets like ${Flagged, Reported}$ represent in terms of content moderation workflows?


== Problem 4: Similarity and Distance Metrics

Streaming services use similarity measures to recommend content.
Consider user preferences as sets of genres they enjoy.

Users and their preferred genres:
- Alice: $A = {"sci-fi", "thriller", "drama"}$
- Bob: $B = {"comedy", "thriller", "action"}$
- Carol: $C = {"drama", "romance", "thriller"}$
- David: $D = {"sci-fi", "action", "horror"}$

*Part (a): Jaccard Similarity and Distance*

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

*Part (b): Cosine Similarity and Distance*

The _Cosine similarity_ (simplified for sets) is:
$
  Cosine(X, Y) = frac(
    card(X inter Y),
    sqrt(card(X)) dot sqrt(card(Y))
  )
$

The _Cosine distance_ is:
$
  CosineDist(X, Y) = 1 - Cosine(X, Y)
$

+ Calculate $Cosine(X, Y)$ and $CosineDist(X, Y)$ for all user pairs.
+ Determine which pair is most similar and which is most dissimilar.

*Part (c): Metric Properties*

Prove that Jaccard distance satisfies the triangle inequality:
$
  JaccardDist(A, C) <= JaccardDist(A, B) + JaccardDist(B, C)
$
for arbitrary finite sets $A$, $B$, and $C$.

*Part (d): Counterexample for Cosine Distance*

Show that cosine distance does NOT satisfy the triangle inequality by providing a specific counterexample.
Find three non-empty sets $X$, $Y$, and $Z$ such that:
$
  CosineDist(X, Z) > CosineDist(X, Y) + CosineDist(Y, Z)
$

*Hint*: Try sets of different sizes where one set has no intersection with the others.

*Part (e): Recommendation Application*

A user with preferences $U = {"thriller", "horror"}$ joins the platform.
Using Jaccard similarity, find:
+ Users with similarity $>= 0.2$ to user $U$.
+ The most similar user to $U$.
+ Recommended genres based on the most similar user's preferences.


== Problem 5: Game Development and Coordinate Systems

A game developer is designing a 2D puzzle game with different gameplay zones.
Each zone is defined by specific coordinate regions in $RR^2$.

*Part (a):*
Sketch each gameplay zone in the coordinate plane:
+ Safe Zone: $[1, 4] times [2, 5]$
+ Danger Zone: $(2, 6) times (1, 4]$
+ Treasure Zone: ${(x,y) | x in {1, 3, 5}, y in [2, 4)}$
+ Boss Arena: ${(x,y) in [0, 6] times [0, 6] | x^2 + y^2 <= 9}$

*Part (b):*
The game mechanics require calculating the area of zone interactions:
+ Overlap of Safe and Danger zones: $(text("Safe Zone")) inter (text("Danger Zone"))$
+ Safe areas outside Danger zone: $(text("Safe Zone")) without (text("Danger Zone"))$
+ All special locations: $text("Treasure Zone") union text("Boss Arena")$

*Part (c):*
Power-ups spawn at lattice points (integer coordinates) within zones.
+ Count lattice points in Safe Zone.
+ Count lattice points in the overlap of Safe and Danger zones.
+ Find lattice points in Treasure Zone.

*Part (d):*
A player moves from point $(2,3)$ to $(4,1)$.
+ Through which zones does the straight-line path pass?
+ Through which zones does the Manhattan path pass?


== Problem 6: Recursive Data Structures

In computer science, data structures often have self-referential definitions.
Consider the following system where sets reference their own cardinalities.

*Part (a):*
Find all sets $A$ and $B$ that satisfy:
$
  A & = {1, 2, card(B)} \
  B & = {card(A), 3, 4}
$

Start by determining possible values for $card(A)$ and $card(B)$, then verify which combinations work.

*Part (b):*
Consider a more complex system:
$
  X & = {0, card(Y), card(Z)} \
  Y & = {1, card(X)} \
  Z & = {card(X), card(Y), 2}
$

Find all valid solutions $(X, Y, Z)$.
Explain why some potential solutions don't work.

*Part (c):*
Design your own self-referential system with three sets that has:
- Exactly one valid solution
- At least one set containing the number 5
- Each set having exactly 2 elements

Provide the system and prove your solution is unique.


== Problem 7: Machine Learning Feature Selection

#let Numerical = $N$
#let Categorical = $C$
#let Text = $T$
#let Important = $I$
#let Basic = $B$
#let Advanced = $A$
#let Core = $K$
#let Experimental = $E$
#let Overlapping = $O$

In machine learning, features are often represented as sets, and feature selection uses set operations.
A dataset has features grouped by type:

- Numerical features: $Numerical = {"age", "income", "score", "rating", "price"}$
- Categorical features: $Categorical = {"color", "brand", "category", "status", "type"}$
- Text features: $Text = {"description", "review", "comment", "title"}$
- Important features (from analysis): $Important = {"age", "brand", "score", "review", "price", "status"}$

*Part (a):*
Feature engineering creates new feature sets:
+ Basic features: $Basic = Numerical union Categorical$ #h(1fr) (traditional ML features)
+ Advanced features: $Advanced = Text union Important$ #h(1fr) (includes text and important features)
+ Core features: $Core = Important without Text$ #h(1fr) (important non-text features)
+ Experimental features: $Experimental = (Numerical union Categorical union Text) without Important$ #h(1fr) (all non-important features)

Calculate each set.

*Part (b):*
Model configurations use different feature combinations:
+ Configuration 1: Use only numerical important features.
+ Configuration 2: Use categorical features plus important text features.
+ Configuration 3: Use all features except experimental ones.

Express each configuration as a set operation and calculate the result.

*Part (c):*
The team discovers that features in set $Overlapping = {"age", "price", "income"}$ are highly correlated (overlapping information).
If they must remove all but one feature from $Overlapping$:
+ How many ways can they choose which feature to keep?
+ If they keep "price", how do the sets $Important$, $Core$, and $Basic$ change?
+ Calculate the new configurations from part (b) after this change.


== Problem 8: Cryptocurrency and Blockchain Analysis

#let Miners = $M$
#let Validators = $V$
#let Users = $U$
#let Stakers = $S$
#let Participants = $P$
#let HighValue = $H$
#let Transactions = $T$
#let Suspicious = $X$

A blockchain network has different types of participants and transactions.

*Part (a):*
Participant classification:
- Miners: $Miners = {"miner1", "miner2", "miner3", "miner4"}$
- Validators: $Validators = {"validator1", "validator2", "validator3"}$
- Regular users: $Users = {"user1", "user2", "user3", "user4", "user5"}$
- Nodes that stake coins: $Stakers = {"miner2", "validator1", "validator3", "user1", "user5"}$

Calculate:
+ All network participants: $Participants = Miners union Validators union Users$
+ Participants with dual roles: $(Miners inter Stakers) union (Validators inter Stakers) union (Users inter Stakers)$
+ Non-staking participants: $Participants without Stakers$
+ Staking miners only: $Miners inter Stakers$

*Part (b):*
Transaction analysis over one day:
- High-value transactions: $HighValue = {"tx1", "tx3", "tx7", "tx9"}$
- Validated transactions: $Transactions = {"tx1", "tx2", "tx4", "tx5", "tx7", "tx8"}$
- Suspicious transactions: $Suspicious = {"tx3", "tx6", "tx9", "tx10"}$

Find:
+ Confirmed high-value: $HighValue inter Transactions$
+ Unconfirmed suspicious: $Suspicious without Transactions$
+ Safe transactions: $Transactions without Suspicious$
+ All flagged transactions: $HighValue union Suspicious$

*Part (c):*
Security audit requires checking:
+ Are all high-value transactions either validated or suspicious? #h(1fr) (Is $HighValue subset.eq Transactions union Suspicious$?)
+ Do any transactions appear in all three categories? #h(1fr) (Is $HighValue inter Transactions inter Suspicious = emptyset$?)
+ What percentage of all transactions are validated? #h(1fr) (Calculate $card(Transactions) "/" card(HighValue union Transactions union Suspicious)$)


== Problem 9: Set Theory Foundations and Proofs

*Part (a):*
Consider the set $R = {x | x notin x}$ (the set of all sets that do not contain themselves).
+ Prove that assuming $R in R$ leads to a contradiction.
+ Prove that assuming $R notin R$ also leads to a contradiction.
+ Explain why this shows that naive set theory is inconsistent.
+ How do modern axiomatic set theories (like ZFC) avoid this paradox?

*Part (b):*
Let $A$ and $B$ be finite sets. Prove or disprove each statement:
+ If $A subset.eq B$, then $power(A) subset.eq power(B)$
+ $power(A inter B) = power(A) inter power(B)$
+ $power(A union B) = power(A) union power(B)$
+ $card(power(A times B)) = 2^(card(A) dot card(B))$

*Part (c):*
Provide complete proofs for each of the following statements:
+ Prove that the set of even natural numbers has the same cardinality as $NN$.
+ Prove that $card(NN times NN) = card(NN)$.
+ Show that if $A$ is countable and $B$ is uncountable, then $A union B$ is uncountable.
+ Prove or disprove: If $card(A) = card(B)$ and $card(C) = card(D)$, then $card(A times C) = card(B times D)$.


#line(length: 100%, stroke: 0.4pt)

*Submission Guidelines:*
- Show all work and reasoning clearly for computational problems.
- For proofs, state what you're proving, provide clear logical steps, and conclude with QED or $square$.
- For false statements, provide specific counterexamples.
- Real-world context problems should include brief explanations of practical significance.
- Collaborate with classmates on concepts, but write all solutions independently.
- Submit as PDF with clearly labeled problems and legible work.

*Grading Rubric:*
- Computational accuracy: 40%
- Mathematical reasoning and proof quality: 30%
- Application context understanding: 10%
- Presentation and clarity: 20%

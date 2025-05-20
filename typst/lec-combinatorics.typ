#import "theme.typ": *
#show: slides.with(
  title: [Discrete Mathematics],
  subtitle: "Combinatorics",
  date: "Spring 2025",
  authors: "Konstantin Chukharev",
  ratio: 16 / 9,
  // dark: true,
)

#show table.cell.where(y: 0): strong

// Style the quote block
#set quote(block: true)
#show quote: set par(justify: false)
#show quote: set align(left)

#let power(x) = $cal(P)(#x)$
#let stirling(n, k) = $vec(delim: "{", #n, #k)$
#let s2(n, k) = $s^("II")_(#k) (#n)$

#let operator(x) = math.op[*#x*]
#let shift = operator("E")

#let equ(eq, id: none) = {
  let numbering = if type(id) != none { "(1)" } else { none }
  let body = if type(id) == none { eq } else if type(id) == label [#eq #id] else [#eq #label(id)]
  set math.equation(numbering: numbering)
  body
}

#show ref: it => {
  let el = it.element
  if el != none and el.func() == math.equation {
    show underline: it => it.body
    link(
      el.location(),
      numbering(
        el.numbering,
        ..counter(math.equation).at(el.location()),
      ),
    )
  } else {
    it
  }
}

#let Green(x) = {
  show emph: set text(green.darken(20%))
  text(x, green.darken(20%))
}
#let Red(x) = {
  show emph: set text(red.darken(20%))
  text(x, red.darken(20%))
}

#let YES = Green[#sym.checkmark]
#let NO = Red[#sym.crossmark]

= Combinatorics

== Introduction to Combinatorics

#definition[
  Combinatorics is the branch of discrete mathematics that deals with _counting_, _arranging_, and analyzing _discrete structures_.

  *Three basic problems of Combinatorics:*
  + Existence: _Is there at least one arrangement of a particular kind?_
  + Counting: _How many arrangements are there?_
  + Optimization: _Which one is best according to some criteria?_
]

*Discrete structures*
- Graphs, sets, multisets, sequences, patterns, coverings, partitions...

*Enumeration*
- Permutations, combinations, inclusion/exclusion, generating functions, recurrence relations...

*Algorithms and optimization*
- Sorting, eulerian circuits, hamiltonian cycles, planarity testing, graph coloring, spanning trees, shortest paths, network flows, bipartite matchings, chain partitions...


== Discrete Structures

We investigate the _building blocks_ of combinatorics:

- Sets and multisets
- Sequences and strings
- Arrangements
- Graphs, networks, trees
- Posets and lattices
- Partitions
- Patterns, coverings, designs, configurations
- Schedules, assignments, distributions

_Used in data modeling, logic, cryptography, and the design of data structures._

== Enumerative Combinatorics

We learn how to count _without explicit listing_:

- Permutations and combinations
- Inclusion–Exclusion Principle
- Set partitions, integer partitions, Stirling numbers, Catalan numbers
- Recurrence relations
- Generating functions

_Used in probability theory, complexity theory, coding theory, computational biology._

== Algorithmic and Optimization Methods

Combinatorics powers _algorithm design_ and complexity analysis:

- Sorting
- Searching
- Eulerian paths and Hamiltonian cycles
- Planarity, colorings, cliques, coverings
- Spanning trees
- Shortest paths
- Network flows
- Bipartite matchings
- Dilworth's theorem, chain and antichain partitions

_Used in logistics, scheduling, routing, and complexity optimization._

= Basic Counting Principles

== Basic Counting Rules

#smallcaps[*Product rule*]:
If something can happen in $n_1$ ways, _and_ no matter how the first thing happens, a second thing can happen in $n_2$ ways, then the two things _together_ can happen in $n_1 dot n_2$ ways.

#smallcaps[*Sum rule*]:
If one event can occur in $n_1$ ways and a second event in $n_2$ (different) ways, then there are $n_1 + n_2$ ways in which _either_ the first event _or_ the second event can occur (_but not both_).

== Addition Principle

#definition[
  We say a finite set $S$ is _partitioned_ into _parts_ $S_1, dots, S_k$ if the parts are pairwise disjoint and their union is $S$.
  In other words, $S_i intersect S_j = emptyset$ for $i != j$ and $S_1 union S_2 union dots union S_k = S$.
  In that case:
  $
    abs(S) = abs(S_1) + abs(S_2) + dots + abs(S_k)
  $
]

#example[
  Let $S$ be the set of students attending the combinatorics lecture.
  It can be partitioned into parts $S_1$ and $S_2$ where
  $
    & S_1 = #[set of students that _like_ easy examples.] \
    & S_2 = #[set of students that _don't like_ easy examples.] \
  $
  If $abs(S_1) = 22$ and $abs(S_2) = 8$, then we can conclude $abs(S) = abs(S_1) + abs(S_2) = 30$.
]

== Multiplication Principle

#definition[
  If $S$ is a finite set that is the _product_ of $S_1, dots, S_k$, that is, $S = S_1 times dots times S_k$, then
  $
    abs(S) = abs(S_1) times dots times abs(S_k)
  $
]

#example[
  TODO: example with car plates
]

== Subtraction Principle

#definition[
  Let $S$ be a subset of a finite set $T$.
  We define the _complement_ of $S$ as $overline(S) = T setminus S$.
  Then
  $
    abs(overline(S)) = abs(T) - abs(S)
  $
]

#example[
  If $T$ is the set of students studying at KIT and $S$ the set of students studying neither math nor computer science.
  If we know $abs(T) = 23905$ and $abs(S) = 20178$, then we can compute the number $abs(S)$ of students studying either math or computer science:
  $
    abs(S) = abs(T) - abs(S) = 23905 - 20178 = 3727
  $
]

== Bijection Principle

#definition[
  If $S$ and $T$ are sets, then
  $
    abs(S) = abs(T) quad arrow.l.r.double.long quad "there exists a bijection between" S "and" T
  $
]

#example[
  Let $S$ be the set of students attending the combinatorics lecture and $T$ the set of homework submissions (unique per student) for the first problem sheet.
  If the number of students and the number of submissions coincide, then there is a bijection between students and submissions.
]

#note[
  The bijection principle works both for _finite_ and _infinite_ sets.
]

== Pigeonhole Principle

#definition[
  Let $S_1, dots, S_k$ be finite sets that are pairwise disjoint and #box[$abs(S_1) + abs(S_2) + dots + abs(S_k) = n$].
  // Then
  $
    exists i in {1,dots,k}: abs(S_i) >= floor(n / k)
    quad "and" quad
    exists j in {1,dots,k}: abs(S_j) <= ceil(n / k)
  $
]

#example[
  Assume there are 5 holes in the wall where pigeons nest.
  Say there is a set $S_i$ of pigeons nesting in hole $i$.
  Assume there are $n = 17$ pigeons in total.
  Then we know:
  - There is some hole with at least $d = 4$ pigeons.
  - There is some hole with at most $b = 3$ pigeons.
]

== Double Counting

If we count the same quantity in _two different ways_, then this gives us a (perhaps non-trivial) identity.

#example[Handshaking Lemma][
  Assume there are $n$ people at a party and everybody will shake hands with everybody else.
  How many handshakes will occur?
  We count this number in two ways:

  + Every person shakes $n - 1$ hands and there are $n$ people.
    However, two people are involved in a handshake so if we just multiply $n dot (n - 1)$, then every handshake is counted twice.
    The total number of handshakes is therefore $(n dot (n - 1)) / 2$.

  + We number the people from $1$ to $n$.
    To avoid counting a handshake twice, we count for person $i$ only the handshakes with persons of lower numbers.
    Then the total number of handshakes is:
    $
      sum_(i = 1)^n (i - 1) =
      sum_(i = 0)^{n - 1} i =
      sum_(i = 1)^(n - 1) i
    $

  The identity we obtain is therefore:~
  $display(sum_(i = 1)^(n - 1) i = (n dot (n - 1)) / 2)$
]

= Arrangements, Permutations, Combinations

== Ordered Arrangements

#definition[
  Denote by $[n] = {1,dots,n}$ the set of natural numbers from $1$ to $n$.
]

Hereinafter, let $X$ be a finite set.

#definition[
  An _ordered arrangement_ of $n$ elements of $X$ is a _map_ $s : [n] to X$.

  - Here, $[n]$ is the _domain_ of $s$, and $s(i)$ is the _image_ of $i in [n]$ under $s$.
  - The set ${ x in X | s(i) = x "for some" i in [n] }$ is the _range_ of $s$.

  Other common names for ordered arrangements are:
  - _string_ (or _word_), e.g. "Banana"
  - _sequence_, e.g. "0815422372"
  - _tuple_, e.g. $(3, 5, 2, 5, 8)$
]

#example[
  #box(baseline: 100% - 1em)[
    #grid(
      columns: 8,
      align: center,
      inset: (x: 5pt, y: 3pt),
      stroke: (x, y) => if x == 0 { (right: 0.4pt) } + if y == 0 { (bottom: 0.4pt) },
      $i$, [1], [2], [3], [4], [5], [6], [7],
      $s(i)$,
      [#emoji.crab],
      [#emoji.baguette],
      [#emoji.baguette],
      [#emoji.jar],
      [#emoji.baguette],
      [#emoji.crab],
      [#emoji.jar],
    )
  ]
]

== Permutations

#definition[
  A _permutation_ of $X$ is a _bijective_ map $pi : [n] to X$.

  Usually, $X = [n]$, and the set of all permutations of $[n]$ is denoted by $S_n$.
]

#example[
  #box(baseline: 100% - 1em)[
    #grid(
      columns: 8,
      align: center,
      inset: (x: 5pt, y: 3pt),
      stroke: (x, y) => if x == 0 { (right: 0.4pt) } + if y == 0 { (bottom: 0.4pt) },
      $i$, [1], [2], [3], [4], [5], [6], [7],
      $pi(i)$, [2], [7], [1], [3], [5], [4], [6],
    )
  ]
]

#definition[
  _$k$-permutation_ of $X$ is an ordered arrangement of $k$ _distinct_ elements of $X$, that is, an _injective_ map $pi : [k] to X$.

  The set of all $k$-permutations of $X = [n]$ is denoted by $P(n, k)$.
  In particular, $S_n = P(n, n)$.
]

TODO: circular permutations

== Counting Permutations

#theorem[
  For any natural numbers $0 <= k <= n$, we have
  $
    abs(P(n, k)) = n dot (n - 1) dot dots dot (n - k + 1) = n! / (n - k)!
  $
]

#proof[
  A permutation is an injective map $pi : [k] to [n]$.
  We count the number of ways to pick such a map, picking the images one after the other.
  There are $n$ ways to choose $pi(1)$.
  Given a value for $pi(1)$, there are $(n - 1)$ ways to choose $pi(2)$ (since we may not choose $pi(1)$ again).
  Continuing like this, there are #box[$(n - i + 1)$] ways to pick $pi(i)$, and the last value we pick is $pi(k)$ with #box[$(n - k + 1)$] possibilities.

  Every #box[$k$-permutation] can be constructed like this in _exactly one way_.
  The total number of #box[$k$-permutations] is therefore given as the product:
  $
    abs(P(n, k)) = n dot (n - 1) dot dots dot (n - k + 1) = n! / (n - k)!
  $
]

== Counting Circular Permutations

#theorem[
  For any natural numbers $0 <= k <= n$, we have
  $
    abs(P_c (n, k)) = n! / (k dot (n - k)!)
  $
]

#proof[
  We doubly count $P(n, k)$:
  + $abs(P(n, k)) = n! / (n - k)!$ which we proved before.

  + $abs(P(n, k)) = abs(P_c (n, k)) dot k$ because every equivalence class in $P_c (n, k)$ contains $k$ permutations from $P(n, k)$ since there are $k$ ways to rotate a $k$-permutation.

  From this we get $n! / (n - k)! = abs(P_c (n, k)) dot k$ which implies $abs(P_c (n, k)) = n! / (k dot (n - k)!)$.
]

== Unordered Arrangements

#definition[
  An _unordered arrangement_ of $k$ elements of $X$ is a _multiset_ $S = angle.l X, r angle.r$ of size $k$.

  In a multiset, $X$ is the set of _types_, and for each type $x in X$, $r_x$ is its _repetition number_.
]

#example[
  Let $X = { #emoji.hat, #emoji.seal, #emoji.cat, #emoji.accordion, #emoji.cactus }$.
  - An unordered arrangement of 7 elements could be $S = { #emoji.hat, #emoji.hat, #emoji.seal, #emoji.cat, #emoji.cat, #emoji.cat, #emoji.cactus }^*$.
  - The same multiset could be written as $S = { 2 #emoji.hat, 1 #emoji.seal, 3 #emoji.cat, 0 #emoji.accordion, 1 #emoji.cactus }$.
]

== Subsets

The most important special case of unordered arrangements is where all repetitions are $1$, i.e., $r_x = 1$ for all $x in X$.
Then $S$ is simply a _subset_ of $X$, denoted $S subset X$.

#definition[
  A _$k$-combination_ of $X$ is an unordered arrangement of $k$ _distinct_ elements of $X$.

  #note[
    The more standard term is _subset_.
    The term "combination" is only used to emphasize the selection process.
  ]

  // The set of all $k$-combinations of $X = [n]$ is denoted by $C(n, k)$.

  The set of all $k$-subsets of $X$ is denoted $binom(X, k) = {A subset.eq X | abs(A) = k}$.
  If $abs(X) = n$, then
  $
    binom(n, k) := abs(binom(X, k))
  $
]

#example[
  The set of edges in a simple undirected graph consists of 2-subsets of its vertices: $E subset.eq binom(V, 2)$.
]

== Counting $k$-Combinations

#theorem[
  For $0 <= k <= n$, we have
  $
    binom(n, k) = n! / (k! dot (n - k)!)
  $
]

#proof[
  $display(abs(P(n, k)) = n! / (n - k)! = binom(n, k) dot k!)$
]

= Multisets

== Multiset

#definition[
  A _multiset_ is a modification of the concept of a set that allows for _repetitions_ of its elements.
  Formally, it is denoted as a pair $M = angle.l X, r angle.r$, where $X$ is the _groundset_ (the set of _types_) and $r : X to NN_0$ is the _multiplicity function_.
]

#example[
  When the multiset is defined by enumeration, it is advisable to use the notation with the star:
  $
    M = { a, b, a, a, b }^* = {3 dot a, 2 dot b} quad X = { a, b } quad r_a = 3, r_b = 2
  $
]

#example[
  Prime factorization of a natural number $n$ is a multiset, e.g. $120 = 2^3 dot 3^1 dot 5^1$.
]

== $k$-Combinations of a Multiset

#definition[
  Let $X$ be a finite set of types, and let $M = angle.l X, r angle.r$ be a finite multiset with repetition numbers $r_1, dots, r_abs(X)$.
  A _$k$-combination of $M$_ is a multiset $S = angle.l X, s angle.r$ with types in $X$ and repetition numbers $s_1, dots, s_abs(X)$ such that #box[$s_i <= r_i$] for all #box[$1 <= i <= abs(X)$], and $sum_(i = 1)^abs(X) s_i = k$.
]

#example[
  Consider $M = { 2 #emoji.beaver, 1 #emoji.cup, 3 #emoji.watermelon, 1 #emoji.gem }$.
  - $T = { 1 #emoji.beaver, 2 #emoji.watermelon }$ is a 3-combination of $M$.
  - $T' = { 3 #emoji.gem }$ is not.
]

_Counting $k$-combinations of a multiset is not as simple as it might seem..._

== $k$-Permutations of a Multiset

#definition[
  Let $M$ be a finite multiset with set of types $X$.
  A _$k$-permutation of $M$_ is an ordered arrangement of $k$ elements of $M$ where different orderings of elements of the same type are _not distinguished_.
  This is an ordered multiset with types in $X$ and repetition numbers $s_1, dots, s_abs(X)$ such that #box[$s_i <= r_i$] for all #box[$1 <= i <= abs(X)$], and $sum_(i = 1)^abs(X) s_i = k$.
]

#note[
  There might be several elements of the same type compared to a permutation of a set (where each repetition number equals 1).
]
#example[
  Let $M = { 2 #emoji.beaver, 1 #emoji.cup, 3 #emoji.watermelon, 1 #emoji.gem }$, then $T = (#emoji.gem, #emoji.watermelon, #emoji.watermelon, #emoji.beaver)$ is a 4-permutation of multiset $M$.
]

== Binomial Theorem

#theorem[
  The expansion of any non-negative integer power $n$ of the binomial $(x + y)$ is a sum
  $
    (x + y)^n = sum_(k = 0)^n binom(n, k) dot x^k dot y^(n - k)
  $
  where each $binom(n, k)$ is a positive integer known as a _binomial coefficient_, defined as
  $
    binom(n, k) = n! / (k! dot (n - k)!) = (n (n-1) (n-2) dots (n-k+1)) / (k (k-1) (k-2) dots dot 2 dot 1)
  $
]

== Multinomial Theorem

#theorem[
  The generalization of the binomial theorem:
  $
    (x_1 + dots + x_r)^n = sum_(0 <= k_1, dots, k_r <= n \ k_1 + dots + k_r = n)^n binom(n, k_1, dots, k_r) dot x_1^k_1 dot dots dot x_r^k_r
  $

  _Multinomial coefficients_ are defined as
  $
    binom(n, k_1, dots, k_r) = n! / (k_1 ! dot dots dot k_r !)
  $
] <multinomial-theorem>

#note[
  Binomial coefficients are special cases of multinomial coefficients ($r = 2$):
  $
    binom(n, k) = binom(n, k_1, k_2) = binom(n, k, n-k) = n! / (k! dot (n - k)!)
  $
]

#proof[
  TODO
]

== Permutations of a Multiset

#theorem[
  Let $S$ be a finite multiset with $k$ different types and repetition numbers $r_1, dots, r_k$.
  Let the size of $S$ be $n = r_1 + dots + r_k$.
  Then the number of $n$-permutations of $S$ equals
  $
    binom(n, r_1, dots, r_k)
  $
]

#proof[
  // Label the $k$ types as $a_1, dots, a_k$.
  In an $n$-permutation there are $n$ positions that need to be assigned a type.

  First, choose the $r_1$ positions for the first type, there are $binom(n, r_1)$ ways to do so.
  Then, assign $r_2$ positions for the second type, out of the $(n - r_1)$ positions that are still available, there are $binom(n - r_1, r_2)$ ways to do so.
  Continue for all $k$ types.
  The total number of choices will be:
  $
    binom(n, r_1) dot binom(n - r_1, r_2) dot dots dot binom(n - r_1 - r_2 - dots - r_(k-1), r_k) = binom(n, r_1, dots, r_k)
  $
]

== $k$-Combinations of an _Infinite_ Multiset

#example[
  Suppose you have a _sufficiently large_ amount of each type of fruit (#emoji.banana, #emoji.apple.red, #emoji.pear) in the supermarket, and you want to buy _two_ fruits.
  How many choices do you have?

  There are exactly _six_ combinations: ${ #emoji.banana, #emoji.banana }, { #emoji.banana, #emoji.apple.red }, { #emoji.banana, #emoji.pear }, { #emoji.apple.red, #emoji.apple.red }, { #emoji.apple.red, #emoji.pear }, { #emoji.pear, #emoji.pear }$.

  Note that your selection is _not ordered_, so ${ #emoji.pear, #emoji.apple.red }$ and ${ #emoji.apple.red, #emoji.pear }$ are considered the _same_ choice.
]

#pagebreak()

#theorem[
  Let $k, s in NN$ and let $S$ be a multiset with $s$ types and large repetition numbers (each $r_1, dots, r_s$ is _at least $k$_), then the number of $k$-combinations of $S$ equals
  $
    binom(k + s - 1, k) = binom(k + s - 1, s - 1)
  $
]

#proof[
  Let $S = { infinity #emoji.banana, infinity #emoji.apple.red, infinity #emoji.pear }$, so $s = 3$.
  - Suppose $k = 5$.
  - Consider a 5-combination of $S$: ${ #emoji.banana, #emoji.apple.red, #emoji.banana, #emoji.pear, #emoji.pear }$.
  - Reorder and group: ${ #emoji.banana #emoji.banana | #emoji.apple.red | #emoji.pear #emoji.pear }$.
  - Convert to _dots_ and _bars_: #h(1em) $bullet bullet bar bullet bar bullet bullet$
  - Represent as a multiset: $M = { k dot bullet, (s-1) dot bar zws }$
  - Observe: each _permutation_ of $k$ dots and $(s-1)$ bars corresponds to a _$k$-combination_ of $S$.
  - Permute the 2-type multiset: $binom(k + s - 1, k, s - 1)$ ways, by @multinomial-theorem.
]

= Compositions

== Weak Compositions

#definition[
  A _weak composition_ of a non-negative integer $k >= 0$ into $s$ parts is a _solution_ to the equation $b_1 + dots + b_s = k$, where each $b_i >= 0$.
]

#example[
  Let $k = 5$, $s = 3$.
  Possible non-negative integer solutions for $b_1 + b_2 + b_3 = 5$ are:
  - $(b_1, b_2, b_3) = (1, 1, 3)$
  - $(b_1, b_2, b_3) = (1, 3, 1)$
  - $(b_1, b_2, b_3) = (2, 0, 3)$
  - $(b_1, b_2, b_3) = (0, 5, 0)$
  - ... (total 21 solutions)
]

#note[
  If $M$ is a multiset over groundset ${1, dots, s}$ with all multiplicities infinite ($r_i = infinity$), then for $k >= 0$, the number of sub-multisets of $M$ of size $k$ is exactly the number of weak compositions of $k$ into $s$ parts.
]

== Counting Weak Compositions

#theorem[
  There are $binom(k + s - 1, k, s - 1)$ _weak compositions_ of $k > 0$ into $s$ parts.
]

#proof[
  Observe that $k = overbrace(underbrace(1 + 1, b_1) + underbrace(dots, b_i) + underbrace(1 + 1, b_s), k "ones")$.

  Use the _stars-and-bars_ method to count the number of $s$ groups composed of $k$ "ones".
]

#example[
  Let $k = 3$.
  There are $binom(3 + 3 - 1, 3, 3 - 1) = binom(5, 3) = binom(5, 2) = 10$ ways to decompose $k = 3$ into $s = 3$ parts:
  $
    k &= 3 = \
    &= 0 + 1 + 2 = 0 + 2 + 1 \
    &= 1 + 0 + 2 = 1 + 2 + 0 = 1 + 1 + 1 \
    &= 2 + 0 + 1 = 2 + 1 + 0 \
    &= 3 + 0 + 0 = 0 + 3 + 0 = 0 + 0 + 3 \
  $
]

== Compositions

#definition[
  A _composition_ of a positive integer $k >= 1$ into $s$ _positive_ parts is a _solution_ to the equation $b_1 + dots + b_s = k$, where each $b_i > 0$.
]

#theorem[
  There are $binom(k - 1, s - 1)$ _compositions_ of $k > 0$ into $s$ positive parts.
]

#theorem[
  The total number of compositions of $k > 0$ into _some_ number of positive parts is
  $
    sum_(s = 1)^k binom(k - 1, s - 1) = 2^(k - 1)
  $
]

// TODO: proof, by induction, substitute t := s - 1, then apply Binomial theorem for (1+1)^(k-1)

== Parallel Summation Identity

*Q*: How many integer solutions are there to the _inequality_ $b_1 + dots + b_s <= k$, where each $b_i >= 0$?

#theorem[
  $display(sum_(m = 0)^k binom(m + s - 1, m) = binom(k + s, k))$
]

#proof[(hint)][
  Introduce a "dummy" variable $b_(s+1)$ to take up the _slack_ between $b_1 + dots + b_s$ and $k$.
  Construct a bijection with the solutions to $b_1 + dots + b_s + b_(s+1) = k$, where $b_i >= 0$.
]

= Set Partitions

== Set Partitions

#definition[
  A _partition_ of a set $X$ is a set of non-empty subsets of $X$ such that every element of $X$ belongs to exactly one of these subsets.

  Equivalently, a family of sets $P$ is a partition of $X$ iff:
  + The family $P$ does not contain the empty set: $emptyset notin P$.
  + The union of $P$ is $X$, that is, $union.big_(A in P) A = X$.
    The sets in $P$ are said to _cover_ $X$.
  + The intersection of any two distinct sets in $P$ is empty: $forall A, B in P . thin (A != B) imply (A intersect B = emptyset)$. \
    The sets in $P$ are said to be _pairwise disjoint_ or _mutually exclusive_.

  The sets in $P$ are called _blocks_, _parts_, or _cells_, of the partition.

  The block in $P$ containing an element $x in X$ is denoted by $[x]$.

  // The _rank_ of $P$ is $abs(X) - abs(P)$, if $X$ is finite.
]

== Examples of Set Partitions

#example[
  The empty set $X = emptyset$ has exactly one partition, $P = emptyset$.
]

#example[
  Any singleton set $X = {x}$ has exactly one partition, $P = { {x} }$.
]

#example[
  For any non-empty proper subset $A subset U$, the set $A$ and its complement form a partition of $U$, namely $P = {A, U - A}$.
]

#example[
  The set $X = {1,2,3}$ has five partitions:
  + ${ {1}, {2}, {3} }$ or $1 | 2 | 3$
  + ${ {1}, {2,3} }$ or $1 | 2 thick 3$
  + ${ {1,2}, {3} }$ or $1 thick 2 | 3$
  + ${ {1,3}, {2} }$ or $1 thick 3 | 2$
  + ${ {1,2,3} }$ or $1 thick 2 thick 3$
]

#example[
  The following are _not_ partitions of ${1,2,3}$:
  - ${ {}, {1, 3}, {2} }$, because it contains the empty set.
  - ${ {1, 2}, {2, 3} }$, because the element $2$ is contained in more than one block.
  - ${ {1}, {3} }$, because no block contains the element $3$.
]

// TODO: refinement of partitions (see, e.g., wiki)

// TODO: partitions of multisets

== Counting Set Partitions

#definition[
  The number of partitions of a set $X$ (of size $n = abs(X)$) into $k$ non-empty blocks ("unlabeled subsets") is called a _Stirling number of the second kind_ and denoted $S(n, k)$ or $stirling(n, k)$.
]

#example[
  Let $X = {1,2,3,4}$, $k = 2$.
  There are 7 possible partitions:

  #cetz.canvas({
    import cetz.draw: *
    let myfill = green.lighten(80%)
    scale(50%)
    set-style(stroke: 0.5pt)
    for (b1, b2, b3, b4) in (
      (true, false, false, false),
      (true, true, false, false),
      (true, false, true, false),
      (true, false, false, true),
      (true, true, true, false),
      (true, true, false, true),
      (true, false, true, true),
    ) {
      translate((3, 0))
      rect((-1, 0), (0, 1), radius: (north-west: .5), fill: if b1 { myfill })
      rect((0, 1), (1, 0), radius: (north-east: .5), fill: if b2 { myfill })
      rect((0, -1), (1, 0), radius: (south-east: .5), fill: if b3 { myfill })
      rect((-1, 0), (0, -1), radius: (south-west: .5), fill: if b4 { myfill })
      content((-0.5, 0.5))[$1$]
      content((0.5, 0.5))[$2$]
      content((-0.5, -0.5))[$3$]
      content((0.5, -0.5))[$4$]
    }
  })
]

#theorem[
  Let $stirling(n, 0) = 0$ for $n >= 1$, $stirling(0, k) = 0$ for $k >= 1$, and $stirling(0, 0) = 1$.
  For $n, k >= 1$, we have:
  $
    stirling(n, k) = stirling(n - 1, k - 1) + k dot stirling(n - 1, k)
  $
]

#proof[(informal)][
  TODO
]

== Bell Numbers

#definition[
  The total number of partitions of a set $X$ of size $n = abs(X)$ (into an arbitrary number of non-empty blocks) is called a _Bell number_ and denoted $B_n$.
  $
    B_n = sum_(k = 0)^(n) stirling(n, k)
  $
]

#note[
  Consider the special case of $n = 0$.
  There is exactly _one_ partition of $emptyset$ into non-empty parts: #box[$emptyset = union.big_(A in emptyset) A in emptyset$].
  Every $A in emptyset$ is non-empty, since no such $A$ exists.
  Thus, we have $B_0 = S(0, 0) = 1$.
]

#pagebreak()

#theorem[
  For $n >= 1$, we have the recursive identity for Bell numbers:
  $
    B_n = sum_(k = 0)^(n - 1) binom(n - 1, k) B_k
  $
]

#proof[
  Every partition of $[n]$ has one part that contains the number $n$.
  In addition to $n$, this part also contains $k$ other numbers (for some $0 <= k <= n-1$).
  The remaining $n - 1 - k$ elements are partitioned arbitrarily.
  From this correspondence, we obtain the desired identity:
  $
    B_n
    = sum_(k = 0)^(n - 1) binom(n - 1, k) B_(n-1-k)
    = sum_(k = 0)^(n - 1) binom(n - 1, n-1-k) B_(n-1-k)
    = sum_(k = 0)^(n - 1) binom(n - 1, k) B_k
  $
]

= Integer Partitions

== Integer Partitions

#definition[
  An _integer partition_ of a positive integer $n >= 1$ into $k$ _positive_ parts is a _solution_ to the equation $n = a_1 + dots + a_k$, where $a_1 >= a_2 >= dots >= a_k >= 1$.

  - The number of integer partitions of $n$ into $k$ positive non-decreasing parts is denoted $p_(k)(n)$ and defined recursively:
    $
      p_(k)(n) = cases(
        0 & "if" k > n,
        0 & "if" n >= 1 "and" k = 0,
        1 & "if" n = k = 0,
        p_(k)(n - k) + p_(k - 1)(n - 1) & "if" 1 <= k <= n,
      )
    $

  - The number of partitions of $n$ (into an arbitrary number of parts) is the _partition function_ $p(n)$:
    $
      p(n) = sum_(k = 0)^(n) p_(k)(n)
    $
]

== Ferrer Diagrams and Yound Tableaux

#let parts = (6, 4, 3, 1)
#let total = parts.sum()

#example[
  Consider an integer partition: $#total = #(parts.map(str)).join(" + ")$.
]

#let max(a) = {
  let m = 0
  for x in a {
    if x > m { m = x }
  }
  m
}

#let partition_diagram(parts, young: false) = cetz.canvas({
  import cetz.draw: *

  // Flip Y to grow DOWN
  scale(y: -1)

  // Visual parameters
  let spacing = 0.5 // space between cells
  let h = spacing // row height
  let w = spacing // column width

  // Diagram dimensions
  let cols = max(parts)
  let rows = parts.len()

  // Outer rectangle
  let gap = spacing // margin
  let left = -gap
  let top = -gap
  let right = (cols - 1) * w + gap
  let bottom = (rows - 1) * h + gap
  rect(
    (left, top),
    (right, bottom),
    stroke: 1pt + luma(80%),
    radius: 3pt,
  )

  // Element
  let c(x, y) = if young {
    // Box
    rect((x - w / 2, y - h / 2), (x + w / 2, y + h / 2), stroke: 0.8pt, radius: 1pt, fill: green.lighten(80%))
  } else {
    // Dot
    circle((x, y), radius: 0.1, stroke: 0.8pt, fill: green.lighten(80%))
  }

  // Partition
  for i in range(0, rows) {
    let p = parts.at(i)
    let y = i * h
    for j in range(0, p) {
      let x = j * w
      c(x, y)
    }
  }
})

#place(right)[
  #grid(
    columns: 2,
    align: center,
    column-gutter: 1em,
    row-gutter: 0.5em,
    link("https://en.wikipedia.org/wiki/Norman_Macleod_Ferrers", image("assets/Norman_Ferrer.jpg", height: 3cm)),
    link("https://en.wikipedia.org/wiki/Alfred_Young_(mathematician)", image("assets/Alfred_Young.jpg", height: 3cm)),

    [Norman Ferrer], [Alfred Young],
  )
]

#table(
  columns: 2,
  stroke: (x, y) => if y == 0 { (bottom: 0.4pt) },
  table.header[Ferrer Diagram][Young Tableaux],
  partition_diagram(parts, young: false), partition_diagram(parts, young: true),
)

= Inclusion–Exclusion

== The Inclusion–Exclusion Principle

TODO: small example of PIE with 2 or 3 sets

== Principle of Inclusion–Exclusion (PIE)

#theorem[
  Let $X$ be a finite set and $P_1, dots, P_m$ _properties_.
  - Define $X_i = { x in X | thin x "has" P_i }$, i.e. the set of all elements from $X$ having a property $P_i$.
  - Define for $S subset.eq [m]$ the set $N(S) = { x in X | forall i in S : thin x "has" P_i }$.
    Observe: $N(S) = intersect.big_(i in S) X_i$.

  The number of elements of $X$ that satisfy _none_ of the properties $P_1, dots, P_m$ is given by
  #equ(
    $
      abs(X setminus (X_1 union dots union X_m)) = sum_(S subset.eq [m]) (-1)^abs(S) abs(N(S))
    $,
    id: <eq:pie>,
  )
] <thm:pie>

#proof[
  Consider any $x in X$.
  If $x in X$ has none of the properties, then $x in N(emptyset)$ and $x notin N(S)$ for any other $S != emptyset$.
  Hence _$x$ contributes 1_ to the sum @eq:pie.

  If $x in X$ has exactly $k >= 1$ of the properties, call this set $T in binom([m], k)$.
  Then $x in N(S)$ iff $S subset.eq T$. \
  The _contribution of $x$_ to the sum @eq:pie is $sum_(S subset.eq T) (-1)^abs(S) = sum_(i = 0)^k binom(k, i) (-1)^i = 0$, i.e. _zero_.
]

#note[
  In the last step, we used that for any $y in RR$ we have $(1-y)^k = sum_(i = 0)^k binom(k, i) (-y)^i$ which implies #box[(for $y = 1$)] that $0 = sum_(i = 0)^k binom(k, i) (-1)^i$.
]

== Very Useful Corollary of PIE

#corollary[
  #emoji.cat.shock
  $
    abs(union.big_(i in [m]) X_i) = abs(X) - sum_(S subset.eq [m]) (-1)^abs(S) abs(N(S)) = sum_(emptyset != S subset.eq [m]) (-1)^(abs(S)-1) abs(N(S))
  $
]

// TODO: picture with 3 circles and plus/minus signs

== Applications of PIE

Let's state the principle of inclusion-exclusion using a rigid pattern:

+ _Define "bad" properties._

  Identify the things to count as the elements of some universe $X$ except for the whose having _at least one_ of the "bad" properties $P_1, dots, P_m$.
  In other words, we want to count $X setminus (X_1 union dots union X_m)$.

+ _Count $N(S)$._

  For each $S subset.eq [m]$, determine $N(S)$, the number of elements of $X$ having _all_ bad properties $P_i$ for $i in S$.

+ _Apply PIE_.

  Use @thm:pie to obtain a closed formula for $abs(X setminus (X_1 union dots union X_m))$.

== Counting Surjections via PIE

#theorem[
  The number of surjections from $[k]$ to $[n]$ is given by
  $
    abs({ f : [k] to_"surj." [n] }) = sum_(i = 0)^n (-1)^i binom(n, i) (n - i)^k
  $
]

#proof[
  Let $X$ be the set of all maps from $[k]$ to $[n]$.

  + _Define bad properties:_
    Define the "bad" property $P_i$ for $i in [n]$ as "$i$ is not in the image of $f$", i.e.
    $
      f : [k] to [n] "has property" P_i
      quad iff quad
      forall j in [k] : f(j) != i
    $

    The _surjective_ functions are exactly those functions that _do not_ have any of the "bad" properties.

  + _Count $N(S)$:_
    We claim $N(S) = (n - abs(S))^k$ for any $S subset.eq [n]$.
    To see this, observe that $f$ has all properties with indices from $S$ if and only if $f(i) notin S$ for all $i in [k]$.
    In other words, $f$ must be a function from~$[k]$~to~$[n] setminus S$, and there are $(n - abs(S))^k$ of those.

    #v(1fr)

  + _Apply PIE:_
    Using @thm:pie, the number of surjections from $[k]$ to $[n]$ is
    $
      abs(X setminus (X_1 union dots union X_n))
      &=^"PIE" sum_(S subset.eq [n]) (-1)^abs(S) abs(N(S)) \
      &= sum_(S subset.eq [n]) (-1)^abs(S) (n - abs(S))^k \
      &= sum_(i = 0)^n (-1)^i binom(n, i) (n - i)^k \
    $
    In the last step, we used that $(-1)^abs(S) (n - abs(S))^k$ only depends on the size of $S$, and there are $binom(n, i)$ sets #box[$S subset.eq [n]$] of size $i$.
]

== More Useful Corollaries

#corollary[
  Consider the case $n = k$.
  A function from $[n]$ to $[n]$ is a _surjection_ iff it is a _bijection_.
  Since there are $n!$ bijections on $[n]$ (namely, all permutations), we have the following identity:
  $
    n! = sum_(i = 0)^n (-1)^i binom(n, i) (n - i)^n
  $
]

#corollary[
  A surjection from $[k]$ to $[n]$ can be seen as a partition of $[k]$ into $n$ non-empty distinguishable (labeled) parts (the map assigns a part to each $i in [k]$).

  Since the partition of $[k]$ into $n$ non-empty indistinguishable parts is denoted $s2(k, n)$, and there are $n!$ ways to assign labels to $n$ parts, we obtain that the number of surjections is equal to $n! s2(k, n)$:
  $
    n! s2(k, n) = sum_(i = 0)^n (-1)^i binom(n, i) (n - i)^k
  $
]

== Derangements

#theorem[
  The _derangements_ $D_n$ on $n$ elements are permutations of $[n]$ without fixed points.

  The number of derangements is given by
  $
    abs(D_n) = sum_(i = 0)^n (-1)^i binom(n, i) (n - i)!
  $
]

#proof[
  Let $X$ be the set of all permutations of $[n]$.

  + Define the "bad" property $P_i$ to mean "$pi$ has a fixpoint $i$" ($i in [n]$):
    $
      pi in X "has property" P_i
      quad iff quad
      pi(i) = i
    $

  + We claim $N(S) = (n - abs(S))!$ for any $S subset.eq [n]$.

    Indeed, $pi in X$ has all properties with indices from $S$ if and only if all $i in S$ are fixed points of $pi$.
    On the other elements, i.e. on $[n] setminus S$, $pi$ may be an arbitrary bijection, so there are $(n - abs(S))!$ choices for $pi$.

    #v(1fr)

  + Using @thm:pie, the number of derangements is given by
    $
      abs(X setminus (X_1 union dots union X_n))
      &=^"PIE" sum_(S subset.eq [n]) (-1)^abs(S) abs(N(S)) \
      &= sum_(S subset.eq [n]) (-1)^abs(S) (n - abs(S))! \
      &= sum_(i = 0)^n (-1)^i binom(n, i) (n - i)!
    $

    In the last step, we used that $(-1)^abs(S) (n - abs(S))!$ only depends on the size of $S$, and there are $binom(n, i)$ sets #box[$S subset.eq [n]$] of size $i$.
]

= Generating Functions

== Generating Functions

#quote(attribution: [George Pólya, Mathematics and Plausible Reasoning @polya1954])[
  _A generating function is a device somewhat similar to a bag. Instead of carrying many little objects detachedly, which could be embarrassing, we put them all in a bag, and then we have only one object to carry, the bag._
]

#quote(attribution: [Herbert Wilf, generatingfunctionology @wilf2006])[
  _A generating function is a clothesline on which we hang up a sequence of numbers for display._
]

#place(bottom + left)[
  #grid(
    columns: 3,
    align: top + center,
    column-gutter: 1em,
    row-gutter: 0.5em,
    image("assets/Abraham_de_Moivre.jpg", height: 3cm),
    image("assets/George_Polya.jpg", height: 3cm),
    image("assets/Herbert_Wilf.jpg", height: 3cm),

    [Abraham \ de Moivre], [George Pólya], [Herbert Wilf],
  )
]

== Ordinary Generating Functions

#definition[
  An _ordinary generating function_ (OGF) of a sequence $a_n$ is a _power series_
  $
    G(a_n; x) = sum_(n = 0)^(infinity) a_n x^n
  $
]

#example[
  The _sequence_ $a_n = (a_0, a_1, a_2, dots)$ is _generated_ by the OGF $G(x) = a_0 + a_1 x + a_2 x^2 + dots$
]

#example[
  $G(x) = 3 + 8x^2 + x^3 + 1 / 7 x^5 + 100 x^6 + ...$ _generates_ the sequence $(3, 0, 8, 1, 0, 1 / 7, 100, 0, dots)$
]

#example[
  Consider a long division of $1$ by $(1 - x)$, the result is an infinite power series
  $
    frac(1, 1 - x) = 1 + x^1 + x^2 + x^3 + dots = sum_(n = 0)^(infinity) x^n
  $
  Note that all coefficients are $1$.
  Thus, the generating function of $(1, 1, 1, dots)$ is $G(x) = sum_(n = 0)^(infinity) x^n = frac(1, 1 - x)$.
]

== More Examples of Generating Functions

Another proof that $(1, 1, 1, dots)$ is generated by $G(x) = 1 + x + x^2 + x^3 + dots = sum_(n = 0)^(infinity) x^n = frac(1, 1 - x) = S$:
#grid(
  columns: 3,
  inset: (2pt, 5pt),
  align: (right + horizon, center + horizon, left + horizon),
  stroke: (x, y) => if y == 1 { (bottom: .6pt) },
  $S$, $=$, $1 + x + x^2 + x^3 + dots$,
  $x dot S$, $=$, $#hide($0 +$) x + x^2 + x^3 + dots$,
  $S - x dot S$, $=$, $1$,
)
Thus, $display(S = 1 / (1 - x))$

#pagebreak()

$
  & 1 / (1 - x) = sum_(n = 0)^(infinity) x^n = 1 + x + x^2 + x^3 + dots & "generates" & (1, 1, 1, dots) & "(constant "1")" \
  & 2 / (1 - x) = sum_(n = 0)^(infinity) 2 x^n = 2 + 2x + 2x^2 + 2x^3 + dots & "generates" & (2, 2, 2, dots) & "(constant "2")" \
  & x / (1 - x) = sum_(n = 1)^(infinity) x^n = x + x^2 + x^3 + dots & "generates" & (0, 1, 1, 1, dots) & "(right shift)" \
  & 1 / (1 + x) = sum_(n = 0)^(infinity) (-1)^n x^n = 0+ 1 - x + x^2 - x^3 + dots & "generates" & (1, -1, 1, dots) & "(sign-alternating "1"'s)" \
  & 1 / (1 - 3x) = sum_(n = 0)^(infinity) 3^n x^n = 1 + 3x + 9x^2 + 27x^3 + dots & "generates" & (1, 3, 9, dots) & "(powers of "3")" \
  & 1 / (1 - x^2) = sum_(n = 0)^(infinity) x^(2n) = 1 + x^2 + x^4 + x^6 + dots & "generates" & (1, 0, 1, 0, dots) & "(regular gaps)" \
  & 1 / (1 - x)^2 = sum_(n = 0)^(infinity) (n+1) x^n = 1 + 2x + 3x^2 + 4x^3 + dots & "generates" & (1, 2, 3, 4, dots) & "(natural numbers)" \
$

#pagebreak()

$
  frac(1-x^(n+1), 1-x)
  &= frac(1, 1-x) - frac(x^(n+1), 1-x) = \
  &eq.delta (1,1,1,dots) - \(underbrace(0\,0\,dots\,0, n+1 "zeros"),1,1,dots) = \
  &= \(underbrace(1\,1\,dots\,1, n+1 "ones"), 0,0,dots) = \
  &eq.delta 1 + x + x^2 + dots + x^n
$

== Exercises

#example[
  Find GF for odd numbers: $(1, 3, 5, dots)$.

  //      A(x) = 1 + 3x + 5x^2 + 7x^3 + 9x^4 + ...
  //  x * A(x) = 0 + 1x + 3x^2 + 5x^3 + 7x^4 + ...
  // ----------------------------------------------
  //   (1-x)*A = 1 + 2x + 2x^2 + 2x^3 + 2x^4 + ...
  //   (1-x)*A = 1 + 2x/(1-x)
  //
  // A(x) = 1/(1-x) + 2x/(1-x)^2  ===  (1+x) / (1-x)^2 =
  //  = (1,1,1,...) + (0,2,4,6,8,...) = (1,3,5,7,9,...)
]

#example[
  Find GF for $(1, 3, 7, 15, 31, 63)$, which satisfies $a_n = 3 a_(n-1) - 2 a_(n-2)$ with $a_0 = 1$, $a_1 = 3$.

  //      A = 1 + 3x + 7x^2 + 15x^3 + 31x^4 + ... + a_n x^n + ...
  //   -3xA = 0 - 3x - 9x^2 - 21x^3 - 45x^4 - ... - 3a_(n-1) x^n - ...
  //  2x^2A = 0 + 0x + 2x^2 +  6x^3 + 18x^4 + ... + 2a_(n-2) x^n + ...
  // ------------------------------------------------------------------
  // (1 - 3x + 2x^2) A = 1
  //
  // Thus, A(x) = 1 / (1 - 3x + 2x^2)

  // Note: rewrite (a_n) as a_n - 3a(n-1) + 2a(n-2) = 0
  // observe the similarity to A(x)
]

== Solving Combinatorial Problems via Generating Functions

#example[
  Find the number of integer solutions to $y_1 + y_2 + y_3 = 12$ with $0 <= x_i <= 6$.
  - Possible values for $y_1$ are $0 <= y_1 <= 6$.
    - There is a _single_ way to select $y_1 = 0$.
      The same for other values among $1, dots, 6$.
    - There are _no_ ways to select any value of $y_1$ higher than $6$.
    - The _number of ways to select $y_1$ to be equal to $n$_ forms a sequence $(1, 1, 1, 1, 1, 1, 1, 0, dots)$.
    - Write this sequence as a polynomial $x^0 + x^1 + dots + x^6$.
    - Do the same for $y_2$ and $y_3$ (_in isolation_!).
  - Since all combinations of $y_1$, $y_2$ and $y_3$ are valid non-conflicting solutions, we can multiply those polynomials and obtain the _generating function_ $G(x) = (1 + x + x^2 + dots + x^6)^3$.
    - For each $n$, the coefficient of $x^n$ in $G(x)$ is the number of integer solutions to $x_1 + x_2 + x_3 = n$.
    - In particular, we are interested in the coefficient of $x^12$ in $G(x)$, denoted $[x^12] G(x)$.
    - Use #strike[pen and paper] #link("https://www.wolframalpha.com/input?i=expand+%281%2Bx%2Bx%5E2%2Bx%5E3%2Bx%5E4%2Bx%5E5%2Bx%5E6%29%5E3")[Wolfram Alpha] to expand $G(x)$:
      $
        G(x) = x^18 + 3x^17 + 6x^16 + dots + underbracket(28x^12) + dots + 6x^2 + 3x + 1
      $
  - The _answer_ is $[x^12] G(x) = 28$ solutions.
]

== Slightly More Complex Combinatorial Problem

#example[
  Suppose we have marbles of three different colors (#emoji.circle.red, #emoji.circle.green, #emoji.circle.blue), and we want to _count_ the number of ways to select 20 marbles, such that:
  - There are an even number of #emoji.circle.red: $1 + x^2 + x^4 + dots + x^20$.
  - There are at least 12 #emoji.circle.green: $x^12 + x^13 + dots + x^20$.
  - There are at most 5 #emoji.circle.blue: $1 + x + x^2 + x^3 + x^4 + x^5$.

  Multiply polynomials and find $[x^20] G(x)$:
  $
    & [x^20] (1+x^2+x^4+dots+x^20) (x^12+x^13+dots+x^20) (1+x+x^2+x^3+x^4+x^5) = \
    & = [x^20] (x^45 + 2x^44 + dots + underbracket(21x^20) + dots + 2x^13 + x^12) \
    & = 21
  $
]

== Using Power Series in Combinatorial Problems

#example[
  Find the number of integer solutions to $a_1 + a_2 + a_3 = 12$ with $a_1 >= 2$, $3 <= a_2 <= 6$, $a_3 <= 9$.

  - Compose the generating function:
    $
      G(x) = (x^2 + x^3 + dots) dot (x^3 + x^4 + x^5 + x^6) dot (1 + x + x^2 + dots + x^9)
    $

  - Substitute the power series with the corresponding simple forms:
    $
      G(x) = (x^2 dot frac(1, 1-x)) dot (x^3 dot frac(1-x^4, 1-x)) dot (frac(1-x^10, 1-x))
    $

  - Expand the series:
    $
      G(x) = x^5 + 3x^6 + 6x^7 + 10x^8 + 14x^9 + 18x^10 + 22x^11 + underbracket(26x^12) + 30x^13 + \ 34x^14 + 37x^15 + 39x^16 + 40x^17 + dots + 40x^n + dots
    $

  - Sequence: $(g_n) = (0, 0, 0, 0, 0, 1, 3, 6, 10, 14, 18, 22, 26, 30, 34, 37, 39, overline(40), dots)$

  - Answer for $n = 12$ is $[x^12] G(x) = 26$.
]

= Recurrence Relations

== Recurrence Relations

#example[
  - _Recurrent relation_ defining a sequence $(a_n)$:
    $
      a_n = cases(
        a_0 = "const" & "if" n = 0,
        a_(n-1) + d & "if" n > 0,
      )
    $

  - _Solving_ it results in a non-recursive _closed_ formula:
    $
      a_n = a_0 + n dot d
    $

  - _Checking_ it confirms that the formula is correct:
    $
      a_n &= underbracket(a_(n-1)) + d = underbracket(a_0 + (n-1)d, a_(n-1)) + d = a_0 + n dot d quad qed
    $
]

== Linear Homogeneous Recurrence Relations

#definition[
  A _linear homogeneous_ recurrence relation _of degree $k$_ with constant coefficients is a recurrence relation of the form
  $
    a_n = c_1 a_(n-1) + c_2 a_(n-2) + dots + c_k a_(n-k),
  $
  where $c_1, c_2, dots, c_k$ are constants (real or complex numbers), and $c_k != 0$.
]

#examples[
  - $b_n = 2.71 b_(n-1)$ is a linear homogeneous recurrence relation of degree 1.
  - $F_n = F_(n-1) + F_(n-2)$ is a linear homogeneous recurrence relation of degree 2.
  - $g_n = 2 g_(n-5)$ is a linear homogeneous recurrence relation of degree 5.
  - The recurrence relation $a_n = a_(n-1) + a_(n-2)^2$ is _not linear_.
  - The recurrence relation $H_n = 2 H_(n-1) + 1$ is _not homogeneous_.
  - The recurrence relation $B_n = n B_(n-1)$ does _not_ have _constant_ coefficients.
]

== Characteristic Equations

Hereinafter, $(*)$ denotes a linear homogeneous recurrence relation $a_n = c_1 a_(n-1) + c_2 a_(n-2) + dots + c_k a_(n-k)$.

#theorem[
  $a_n = r^n$ is a solution to $(*)$ if and only if $r^n = c_1 r^(n-1) + c_2 r^(n-2) + dots + c_k r^(n-k)$.
]

// Divide both sides by $r^(n-k)$ and reorganize the terms:

#definition[
  A _characteristic equation_ for $(*)$ is the algebraic equation in $r$ defined as:
  $
    r^k - c_1 r^(k-1) - c_2 r^(k-2) - dots - c_k = 0
  $
]

The sequence $(a_n)$ with $a_n = r^n$ (with $r_n != 0$) is a solution if and only if $r$ is a solution of the characteristic equation.
Such solutions are called _characteristic roots_ of $(*)$.

== Distinct Roots Case

#theorem[
  Let $c_1$ and $c_2$ be real numbers.
  Suppose that $r^2 - c_1 r - c_2 = 0$ has two _distinct_ roots $r_1$~and~$r_2$.
  Then the sequence $(a_n)$ is a solution of the recurrence relation $a_n = c_1 a_(n-1) + c_2 a_(n-2)$ if and only if $a_n = alpha_1 r_1^n + alpha_2 r_2^n$ for $n = 0, 1, 2, dots$, where $alpha_1$ and $alpha_2$ are constants.
]

#proof[(sketch)][
  Since $r_1$ and $r_2$ are roots, then $r_1^2 = c_1 r_1 + c_2$ and $r_2^2 = c_1 r_2 + c_2$.
  Next, we can see:
  $
    c_1 a_(n-1) + c_2 a_(n-2)
    &= c_1 (alpha_1 r_1^(n-1) + alpha_2 r_2^(n-1)) + c_2 (alpha_1 r_1^(n-2) + alpha_2 r_2^(n-2)) \
    &= alpha_1 r_1^(n-2) (c_1 r_1 + c_2) + alpha_2 r_2^(n-2) (c_1 r_2 + c_2) \
    &= alpha_1 r_1^(n-2) r_1^2 + alpha_2 r_2^(n-2) r_2^2 \
    &= alpha_1 r_1^n + alpha_2 r_2^n \
    &= a_n
  $

  To show that every solution $(a_n)$ of the recurrence relation $a_n = c_1 a_(n-1) + c_2 a_(n-2)$ has $a_n = alpha_1 r_1^n + alpha_2 r_2^n$ for some constants $alpha_1$ and $alpha_2$, suppose that the initial condition are $a_0 = C_0$ and $a_1 = C_1$, and show that there exist constants $alpha_1$ and $alpha_2$ such that $a_n = alpha_1 r_1^n + alpha_2 r_2^n$ satisfies the same initial conditions.
]

== Solving Recurrence Relations using Characteristic Equations

#example[
  Solve $a_n = a_(n-1) + 2 a_(n-2)$ with $a_0 = 2$ and $a_1 = 7$.

  - The characteristic equation is $r^2 - r - 2 = 0$.
  - It has two distinct roots $r_1 = 2$ and $r_2 = -1$.
  - The sequence $(a_n)$ is a solution iff $a_n = alpha_1 r_1^n + alpha_2 r_2^n$ for $n = 0, 1, 2, dots$ and some constants $alpha_1$ and $alpha_2$.
    $
      cases(
        a_0 = 2 = alpha_1 + alpha_2,
        a_1 = 7 = alpha_1 dot 2 + alpha_2 dot (-1),
      )
    $
  - Solving these two equations gives $alpha_1 = 3$ and $alpha_2 = -1$.
  - Hence, the _solution_ to the recurrence equation with given initial conditions is the sequence $(a_n)$ with
    $
      a_n = 3 dot 2^n - (-1)^n
    $
]

== Fibonacci Numbers

#example[
  Find the closed formula for Fibonacci numbers.

  - The recurrence relation is $F_n = F_(n-1) + F_(n-2)$.
  - The characteristic equation is $r^2 - r - 1 = 0$.
  - The roots are $r_1 = \(1 + sqrt(5)) slash 2$ and $r_2 = \(1 - sqrt(5)) slash 2$.
  - Therefore, the solution is
    $F_n = alpha_1 \( (1 + sqrt(5)) / 2 \)^n + alpha_2 \( (1 - sqrt(5)) / 2 \)^n$
    for some constants $alpha_1$ and $alpha_2$.
  - Using the initial conditions $F_0 = 0$ and $F_1 = 1$, we get
    $
      cases(
        F_0 = alpha_1 + alpha_2 = 0,
        F_1 = alpha_1 dot \( (1 + sqrt(5)) / 2 \) + alpha_2 dot \( (1 - sqrt(5)) / 2 \) = 1,
      )
    $
  - Solving these two equations gives $alpha_1 = 1 slash sqrt(5)$ and $alpha_2 = -1 slash sqrt(5)$.
  - Hence, the _closed formula_ (also known as Binet's formula) for Fibonacci numbers is
    $
      F_n = 1 / sqrt(5) underbracket(((1+sqrt(5)) / 2), phi)^n - 1 / sqrt(5) underbracket(((1-sqrt(5)) / 2), psi)^n = (phi^n - psi^n) / sqrt(5)
    $
]

== Single Root Case

#theorem[
  Let $c_1$ and $c_2$ be real numbers.
  Suppose that $r^2 - c_1 r - c_2 = 0$ has a _single_ root $r_0$.
  A sequence $(a_n)$ is a solution of the recurrence relation $a_n = c_1 a_(n-1) + c_2 a_(n-2)$ if and only if #box[$a_n = alpha_1 r_0^n + alpha_2 n r_0^n$] for $n = 0, 1, 2, dots$, where $alpha_1$ and $alpha_2$ are constants.
]

#example[
  Solve $a_n = 6 a_(n-1) - 9 a_(n-2)$ with $a_0 = 1$ and $a_1 = 6$.

  The characteristic equation is $r^2 - 6 r + 9 = 0$ with a single (repeated) root $r_0 = 3$.
  Hence, the solutions is of the form $a_n = alpha_1 3^n + alpha_2 n 3^n$.
  $
    cases(
      a_0 = 1 = alpha_1,
      a_1 = 6 = alpha_1 dot 3 + alpha_2 dot 3,
    )
    quad arrow.long.double quad
    cases(
      alpha_1 = 1,
      alpha_2 = 1,
    )
  $
  Thus, the _solution_ is $a_n = 3^n + n 3^n$.
]

== Generic Case

TODO

== Linear Non-Homogeneous Recurrence Relations

$
  a_n = c_1 a_(n-1) + c_2 a_(n-2) + dots + c_k a_(n-k) + F(n)
$

#example[
  $a_n = 3 a_(n-1) + 2n$ is non-homogeneous.
]

#definition[
  An _associated homogeneous recurrence relation_ is the relation without the term $F(n)$.
]

== Solving Non-Homogeneous Recurrence Relations

#theorem[
  If $\(a_n^((p)))$ is a _particular_ solution of the non-homogeneous linear recurrence relation #box[$a_n = c_1 a_(n-1) + c_2 a_(n-2) + dots + c_k a_(n-k) + F(n)$], then _every solution_ is of the form $\(a_n^((p)) + a_n^((h)))$, where $\(a_n^((h)))$ is a solution of the associated homogeneous recurrence relation.
] <thm:non-homo>

#example[
  Find all solutions of the recurrence relation $a_n = 3 a_(n-1) + 2n$.
  What is the solution with $a_1 = 3$?

  - First, solve the associated homogeneous recurrence relation $a_n = 3 a_(n-1)$.
  - It has a general solution $a_n^((h)) = alpha 3^n$, where $alpha$ is a constant.
  - To find a particular solution, observe that $F(n) = 2n$ is a polynomial in $n$ of degree 1, so a reasonable trial solution is a linear function in $n$, for example, $p_n = c n + d$, where $c$ and $d$ are constants.
  - Thus, the equation $a_n = 3 a_(n-1) + 2n$ becomes $c n + d = 3 (c (n-1) + d) + 2n$.
  - Simplify and reorder: $(2 + 2c) n + (2d - 3c) = 0$.
    $
      cases(
        2 + 2c = 0,
        2d - 3c = 0,
      )
      quad arrow.long.double quad
      cases(
        c = -1,
        d = -3 slash 2,
      )
    $
  - Thus, $a_n^((p)) = -n - 3 slash 2$ is a _particular_ solution.
  - By @thm:non-homo, all solutions are of the form
    $
      a_n = a_n^((p)) + a_n^((h)) = -n - 3 slash 2 + alpha 3^n,
    $
    where $alpha$ is a constant.
  - To find the solution with $a_1 = 3$, let $n = 1$ in the formula: $3 = -1 - 3 slash 2 + 3 alpha$, thus $alpha = 11 slash 6$.
  - The _solution_ is $a_n = - n - 3 slash 2 + (11 slash 6) 3^n$.
]

= Annihilators

== Operators

#definition[
  _Operators_ are higher-order functions that transform functions into other functions.

  For example, differential and integral operators $d / (d x)$ and $integral d x$ are core operators in calculus.

  In combinatorics, we are interested in the following three operators:
  - _Sum_: $(f + g)(n) := f(n) + g(n)$
  - _Scale_: $(alpha dot f)(n) := alpha dot f(n)$
  - _Shift_: $(shift f)(n) := f(n + 1)$
]

#examples[
  - Scale and Shift operators are _linear_: $shift (f - 3 (g - h)) = shift f + (-3) shift g + 3 shift h$
  - Operators are _composable_: $(shift - 2) f := shift f + (-2) f$
  - $shift^2 f = shift (shift f)$
  - $shift^k f (n) = f(n + k)$
  - $(shift - 2)^2 = (shift - 2) (shift - 2)$
  - $(shift - 1)(shift -2) = shift^2 - 3 shift + 2$
]

== Applying Operators

#examples[
  Below are the results of applying different operators to $f(n) = 2^n$:
  $
    2 f(n) &= 2 dot 2^n = 2^(n+1) \
    3 f(n) &= 3 dot 2^n \
    shift f(n) &= 2^(n+1) \
    shift^2 f(n) &= 2^(n+2) \
    (shift - 2) f(n) &= shift f(n) - 2f(n) = 2^(n+1) - 2^(n+1) = 0 \
    (shift^2 - 1) f(n) &= shift^2 f(n) - f(n) = 2^(n+2) - 2^n = 3 dot 2^n
  $
]

== Compound Operators

#fancy-box[
  The compound operators can be seen as polynomials in "variable" $shift$.
]

#example[
  The compound operators $shift^2 - 3 shift + 2$ and $(shift - 1)(shift -2)$ are equivalent:
  $
    "Let" g(n) :=& (shift - 2) f(n) = f(n+1) - 2f(n) \
    "Then" (shift - 1) (shift - 2) f(n) =& (shift - 1) g(n) \
    =& g(n+1) - g(n) \
    =& [f(n+2) - 2f(n-1)] - [f(n+1) - 2f(n)] \
    =& f(n+2) - 3f(n+1) + 2f(n) \
    =& (shift^2 - 3 shift + 2) f(n) quad YES
  $
]

== Operators Summary

#table(
  columns: 2,
  stroke: (x, y) => if y == 0 { (bottom: 0.6pt) },
  table.header[Operator][Definition],
  [addition], $(f+g)(n) := f(n) + g(n)$,
  [subtraction], $(f-g)(n) := f(n) - g(n)$,
  [multiplication], $(alpha dot f)(n) := alpha dot f(n)$,
  [shift], $shift f(n) := f(n+1)$,
  [k-fold shift], $shift^k f(n) := f(n+k)$,
  table.cell(rowspan: 3)[composition],
  $(operator(X) + operator(Y)) f := operator(X) f + operator(Y) f$,
  $(operator(X) - operator(Y)) f := operator(X) f - operator(Y) f$,
  $operator(X) operator(Y) f := operator(X) (operator(Y) f) = operator(Y) (operator(X) f)$,
  [distribution], $operator(X) (f + g) = operator(X) f + operator(X) g$,
)

== Annihilators

#definition[
  An _annihilator_ of a function $f$ is any non-trivial operator that transforms $f$ into zero.
]

TODO: examples!

== Annihilators Summary

#table(
  columns: 2,
  stroke: (x, y) => if y == 0 { (bottom: 0.6pt) },
  table.header[Operator][Functions annihilated],
  $shift - 1$, $alpha$,
  $shift - a$, $alpha a^n$,
  $(shift - a)(shift - b)$, $alpha a^n + beta b^n quad ["if" a != b]$,
  $(shift - a_0)(shift - a_1) dots (shift - a_k)$, $sum_(i=0)^k alpha_i a_i^n quad ["if" a_i "are distinct"]$,
  $(shift - 1)^2$, $alpha n + beta$,
  $(shift - a)^2$, $(alpha n + beta) a^n$,
  $(shift - a)^2 (shift - b)$, $(alpha n + beta) a^n + gamma b^n quad ["if" a != b]$,
  $(shift - a)^d$, $(sum_(i=0)^(d-1) alpha_i n^i) a^n$,
)

== Properties of Annihilators

#theorem[
  If $operator(X)$ annihilates $f$, then $operator(X)$ also annihilates $alpha f$ for any constant $alpha$.
]
#theorem[
  If $operator(X)$ annihilates both $f$ and $g$, then $operator(X)$ also annihilates $f plus.minus g$.
]
#theorem[
  If $operator(X)$ annihilates $f$, then $operator(X)$ also annihilates $shift f$.
]
#theorem[
  If $operator(X)$ annihilates $f$ and $operator(Y)$ annihilates $g$, then $operator(X) operator(Y)$ annihilates $f plus.minus g$.
]

== Annihilating Recurrences

+ Write the recurrence in the _operator form_.
+ Find the _annihilator_ for the recurrence.
+ _Factor_ the annihilator, if necessary.
+ Find the _generic solution_ from the annihilator.
+ Solve for coefficients using the _initial conditions_.

#example[
  $r(n) = 5r(n-1)$ with $r(0) = 3$.

  + $r(n+1) - 5r(n) = 0$ \
    $(shift - 5) r(n) = 0$

  + $(shift - 5)$ annihilates $r(n)$.
  + $(shift - 5)$ is already factored.
  + $r(n) = alpha 5^n$ is a generic solution.
  + $r(0) = alpha = 3 quad arrow.r.double.long quad alpha = 3$

  Thus, $r(n) = 3 dot 5^n$.
]

#pagebreak()

#example[
  $T(n) = 2 T(n-1) + 1$ with $T(0) = 0$

  + $T(n+1) - 2T(n) = 1$ \
    $(shift - 2) T(n) = 1$

  + $(shift - 2)$ does _not_ annihilate $T(n)$: the residue is $1$. \
    $(shift - 1)$ annihilates the residue $1$. \
    Thus, $(shift - 1)(shift - 2)$ annihilates $T(n)$.
  + $(shift - 1)(shift - 2)$ is already factored.
  + $T(n) = alpha 2^n + beta$ is a generic solution.
  + $
      cases(
        reverse: #true,
        T(0) = 0 = alpha dot 2^0 + beta,
        T(1) = 1 = alpha dot 2^1 + beta,
      )
      quad arrow.long.double quad
      cases(
        alpha = 1,
        beta = -1,
      )
    $

  Thus, $T(n) = 2^n - 1$.
]

#pagebreak()

#example[
  $T(n) = T(n-1) + 2T(n-2) + 2^n - n^2$

  + Operator form: \
    $(shift^2 - shift - 2) T(n) = shift^2 (2^n - n^2)$

  + Annihilator: \
    $(shift^2 - shift - 2) (shift - 2) (shift - 1)^3$

  + Factorization: \
    $(shift + 1) (shift - 2)^2 (shift - 1)^3$

  + Generic solution: \
    $T(n) = alpha (-1)^n + (beta n + gamma) 2^n + delta n^2 + epsilon n + n$

  Thus, $T(n) in Theta(n 2^n)$
]


== Bibliography
#bibliography("refs.yml")

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

#let power(x) = $cal(P)(#x)$
#let stirling(n, k) = $vec(delim: "{", #n, #k)$
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
  We say a finite set $S$ is _partitioned_ into _parts_ $S_1, dots, S_m$ if the parts are pairwise disjoint and their union is $S$.
  In other words, $S_i intersect S_j = emptyset$ for $i != j$ and $S_1 union S_2 union dots union S_k = S$.
  In that case:
  $
    abs(S) = abs(S_1) + abs(S_2) + dots + abs(S_m)
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
  If $S$ is a finite set that is the _product_ of $S_1, dots, S_m$, that is, $S = S_1 times dots times S_m$, then
  $
    abs(S) = abs(S_1) times dots times abs(S_m)
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
  Let $S_1, dots, S_m$ be finite sets that are pairwise disjoint and #box[$abs(S_1) + abs(S_2) + dots + abs(S_m) = n$].
  // Then
  $
    exists i in {1,dots,m}: abs(S_i) >= floor(n / m)
    quad "and" quad
    exists j in {1,dots,m}: abs(S_j) <= ceil(n / m)
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
    abs(P_c (n, k)) = n! / (k! dot (n - k)!)
  $
]

#proof[
  We doubly count $P(n, k)$:
  + $abs(P(n, k)) = n! / (n - k)!$ which we proved before.

  + $abs(P(n, k)) = abs(P_c (n, k)) dot k$ because every equivalence class in $P_c (n, k)$ contains $k$ permutations from $P(n, k)$ since there are $k$ ways to rotate a $k$-permutation.

  From this we get $n! / (n - k)! = abs(P_c (n, k)) dot k$ which implies $abs(P_c (n, k)) = n! / (k! dot (n - k)!)$.
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
    = sum_(k = 0)^(n - 1) binom(n - 1, k) B_n
  $
]

= Integer Partitions

== Integer Partitions

#definition[
  An _integer partition_ of a positive integer $n >= 1$ into $k$ _positive_ parts is a _solution_ to the equation $n = a_1 + dots + a_k$, where $a_1 >= a_2 >= dots >= a_k >= 1$.

  - The number of integer partitions of $n$ into $k$ positive non-decreasing parts is denoted $p_k (n)$.

  - The number of integer partitions of $k$ into _some_ positive non-decreasing parts is called a _partition number_ and denoted $p(n)$, defined recursively:
    $
      p_k (n) = cases(
        1 & "if" n = k = 0,
        0 & "if" n >= 1 "and" k = 0,
        0 & "if" k > n,
        p_k (n - k) + p_(k - 1) (n - 1) & "if" 1 <= k <= n,
      )
    $
]

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
      abs(X setminus (X_1 union dots union X_m)) sum_(S subset.eq [m]) (-1)^abs(S) abs(N(S))
    $,
    id: <pie>,
  )
]

#proof[
  Consider any $x in X$.
  If $x in X$ has none of the properties, then $x in N(emptyset)$ and $x notin N(S)$ for any other $S != emptyset$.
  Hence _$x$ contributes 1_ to the sum @pie.

  If $x in X$ has exactly $k >= 1$ of the properties, call this set $T in binom([m], k)$.
  Then $x in N(S)$ iff $S subset.eq T$. \
  The _contribution of $x$_ to the sum @pie is $sum_(S subset.eq T) (-1)^abs(S) = sum_(i = 0)^k binom(k, i) (-1)^i = 0$, i.e. _zero_.
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

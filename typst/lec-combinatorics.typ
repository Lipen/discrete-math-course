#import "theme.typ": *
#show: slides.with(
  title: [Combinatorics],
  subtitle: "Discrete Math",
  date: "Spring 2026",
  authors: "Konstantin Chukharev",
  // dark: true,
)

#show heading.where(level: 1): none

#show table.cell.where(y: 0): strong

// Style the quote block
#set quote(block: true)
#show quote: set par(justify: false)
#show quote: set align(left)

#import "common-lec.typ": *

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
    link(el.location())[
      #numbering(el.numbering, ..counter(math.equation).at(el.location()))
    ]
  } else {
    it
  }
}

#CourseOverviewPage2()


= Combinatorics

#focus-slide(
  epigraph: [It is better to solve one problem five different ways, \ than to solve five problems one way.],
  epigraph-author: "George Pólya",
  scholars: (
    (
      name: "George Pólya",
      image: image("assets/Georg_Polya.jpg"),
    ),
    (
      name: "Abraham de Moivre",
      image: image("assets/Abraham_de_Moivre.jpg"),
    ),
    (
      name: "Leonhard Euler",
      image: image("assets/Leonhard_Euler.jpg"),
    ),
    (
      name: "Gottfried Wilhelm Leibniz",
      image: image("assets/Gottfried_Wilhelm_Leibniz.jpg"),
    ),
    (
      name: "Herbert Wilf",
      image: image("assets/Herbert_Wilf.jpg"),
    ),
    (
      name: "Arthur Cayley",
      image: image("assets/Arthur_Cayley.jpg"),
    ),
    (
      name: "Augustin-Louis Cauchy",
      image: image("assets/Augustin-Louis_Cauchy.jpg"),
    ),
  ),
)

== What is Combinatorics?

#definition[
  _Combinatorics_ is the branch of mathematics that studies the existence, enumeration, and structure of _finite_ discrete objects.
]

Three fundamental questions arise in every combinatorial problem:

#grid(
  columns: 3,
  gutter: 1em,

  Block(color: blue, width: 100%)[
    *Existence*

    Does an arrangement of the required kind _exist_ at all?

    _Example:_ Does a graph with 5 vertices where every vertex has exactly 3~neighbors exist?
  ],

  Block(color: yellow, width: 100%)[
    *Enumeration*

    _How many_ such arrangements are there?

    _Example:_ How many 4-digit PIN codes are possible?
  ],

  Block(color: orange, width: 100%)[
    *Optimization*

    Which arrangement is _best_ by some criterion?

    _Example:_ What is the shortest tour visiting all $n$~cities exactly once?
  ],
)


= Basic Counting Principles

#focus-slide(
  epigraph: [Music is the pleasure the human mind experiences from counting \ without being aware that it is counting.],
  epigraph-author: "Gottfried Wilhelm Leibniz",
)

== Basic Counting Rules

#grid(
  columns: 2,
  rows: (auto, auto),
  column-gutter: 1em,
  row-gutter: 1em,
  [
    #Block(color: green, width: 100%)[
      *Addition* (_either/or_)

      If $S$ splits into _disjoint_ parts $S_1, dots, S_k$, count each part separately:
      $abs(S) = abs(S_1) + dots + abs(S_k)$

      _Example:_ 26 vowels + 20 consonants = 46~letters.
    ]
  ],
  [
    #Block(color: yellow, width: 100%)[
      *Subtraction* (complement)

      Count what you _don't_ want and subtract from the universe $U$:
      $abs(overline(S)) = abs(U) - abs(S)$

      _Example:_ 8-bit strings _with_ a leading zero: #box[$2^8 - 2^7 = 128$].
    ]
  ],

  [
    #Block(color: red, width: 100%)[
      *Multiplication* (_and_)

      For _independent_ sequential choices of sizes $n_1, dots, n_k$, multiply:
      $abs(S) = n_1 dot n_2 dot dots dot n_k$

      _Example:_ $26 times 10 = 260$ two-character codes (letter then digit).
    ]
  ],
  [
    #Block(color: purple, width: 100%)[
      *Bijection* (one-to-one)

      If $S$ and $T$ are in _bijective correspondence_, they have the same size:
      $abs(S) = abs(T)$

      _Example:_ $binom(n, k) = binom(n, n-k)$ via $A mapsto [n] setminus A$.
    ]
  ],
)

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
  A _license plate_ consists of 3 letters followed by 3 digits.
  The letters are chosen from $\{"A", dots, "Z"\}$ (26~choices each) and the digits from $\{0, dots, 9\}$ (10 choices each).
  Since each position is filled independently:
  $
    26 times 26 times 26 times 10 times 10 times 10 = 26^3 dot 10^3 = 17\,576\,000
  $
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
  Let $T$ be the set of all students at a university ($abs(T) = 23905$).
  Let $S subset.eq T$ be the set of students studying _neither_ mathematics nor computer science ($abs(S) = 20178$).
  The complement $overline(S) = T setminus S$ consists of students studying mathematics or computer science:
  $
    abs(overline(S)) = abs(T) - abs(S) = 23905 - 20178 = 3727
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
  The number of $k$-subsets of $[n]$ equals the number of $(n-k)$-subsets: $binom(n, k) = binom(n, n-k)$.
  The map $S mapsto [n] setminus S$ is a bijection from $binom([n], k)$ to $binom([n], n-k)$:
  each $k$-subset maps to its $(n-k)$-element complement, and the map is its own inverse.
]

#note[
  The bijection principle works for _infinite_ sets too --- this is the foundation of Cantor's theory of cardinality.
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

#Block(color: blue)[
  *Birthday attack:* a hash function maps arbitrary inputs to $n$-bit digests.
  With $2^n + 1$ inputs, at least two must collide --- guaranteed by the pigeonhole principle.
  More subtly, with only $approx 2^(n slash 2)$ random inputs, collision probability already exceeds $50\%$.
  This is the _birthday bound_ and sets the security level of hash functions in cryptography.
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

#focus-slide(
  epigraph: [As for everything else, so for a mathematical theory: \ beauty can be perceived but not explained.],
  epigraph-author: "Arthur Cayley",
)

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

== Circular Permutations

#definition[
  A _circular $k$-permutation_ of $[n]$ arranges $k$ distinct elements of $[n]$ in a circle.
  Two such arrangements are considered the same if one is a cyclic rotation of the other.
  The set of all circular $k$-permutations of $[n]$ is denoted $P_c(n, k)$.
]

#grid(
  columns: (1fr, 1fr),
  column-gutter: 2em,
  [
    *Linear:* all $3! = 6$ are distinct:
    #align(center)[
      #cetz.canvas({
        import cetz.draw: *
        let nodes = ((0, 0), (2, 0), (4, 0))
        let labels = ("1", "2", "3")
        for (i, (x, y)) in nodes.enumerate() {
          circle((x, y), radius: 0.35, fill: blue.lighten(80%), stroke: blue.darken(20%), name: "n" + str(i + 1))
          content((x, y), text(size: 0.9em)[#labels.at(i)])
        }
        line("n1", "n2", mark: (end: ">", fill: black))
        line("n2", "n3", mark: (end: ">", fill: black))
      })
    ]
    $(1,2,3)$, $(1,3,2)$, $(2,1,3)$, \
    $(2,3,1)$, $(3,1,2)$, $(3,2,1)$
  ],
  [
    *Circular:* rotations are identical:
    #align(center)[
      #cetz.canvas({
        import cetz.draw: *
        // Equilateral triangle, radius 0.75, node radius 0.3
        // Node positions: top=(0,0.75), right=(0.65,-0.375), left=(-0.65,-0.375)
        circle((0, 0.75), radius: 0.3, fill: teal.lighten(80%), stroke: teal.darken(20%), name: "n1")
        circle((0.65, -0.375), radius: 0.3, fill: teal.lighten(80%), stroke: teal.darken(20%), name: "n2")
        circle((-0.65, -0.375), radius: 0.3, fill: teal.lighten(80%), stroke: teal.darken(20%), name: "n3")
        content((0, 0.75), text(size: 0.9em)[1])
        content((0.65, -0.375), text(size: 0.9em)[2])
        content((-0.65, -0.375), text(size: 0.9em)[3])
        // Arrows: 1→2, 2→3, 3→1 (pre-computed start/end with 0.3 offset)
        line("n1", "n2", mark: (end: ">", fill: black), stroke: 0.8pt)
        line("n2", "n3", mark: (end: ">", fill: black), stroke: 0.8pt)
        line("n3", "n1", mark: (end: ">", fill: black), stroke: 0.8pt)
      })
    ]
    $(1,2,3) tilde.op (2,3,1) tilde.op (3,1,2)$ --- same circle

    Only 2 distinct circles: $(1,2,3)$ and $(1,3,2)$
  ],
)

== Counting Permutations

#theorem[
  For any natural numbers $0 <= k <= n$, we have
  $
    abs(P(n, k)) = n dot (n - 1) dot dots dot (n - k + 1) = n! / (n - k)!
  $

  This formula is also called the _falling factorial_ and denoted $n^underline(k)$ or $(n)_k$.
]

#proof[
  A permutation is an injective map $pi : [k] to [n]$.
  We count the number of ways to pick such a map, picking the images one after the other.
  There are $n$ ways to choose $pi(1)$.
  Given a value for $pi(1)$, there are $(n - 1)$ ways to choose $pi(2)$ (since we may not choose $pi(1)$ again).
  Continuing like this, there are #box[$(n - i + 1)$] ways to pick $pi(i)$, and the last value we pick is $pi(k)$ with #box[$(n - k + 1)$] possibilities.

  Every #box[$k$-permutation] can be constructed like this in _exactly one way_.
  The total number of #box[$k$-permutations] is therefore given as the product:
  #place(center)[
    $
      abs(P(n, k)) = n dot (n - 1) dot dots dot (n - k + 1) = n! / (n - k)!
    $
  ]
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

  From this we get $display(n! / (n - k)! = abs(P_c (n, k)) dot k)$, which implies $display(abs(P_c (n, k)) = n! / (k dot (n - k)!))$.
]

== Unordered Arrangements

#definition[
  An _unordered arrangement_ of $k$ elements of $X$ is a _multiset_ $S = chevron.l X, r chevron.r$ of size $k$.

  In a multiset, $X$ is the set of _types_, and for each type $x in X$, $r_x$ is its _repetition number_.
]

#example[
  Let $X = { #emoji.hat, #emoji.seal, #emoji.cat, #emoji.accordion, #emoji.cactus }$.
  - An unordered arrangement of 7 elements could be $S = { #emoji.hat, #emoji.hat, #emoji.seal, #emoji.cat, #emoji.cat, #emoji.cat, #emoji.cactus }^*$.
  - The same multiset could be written as $S = { 2 #emoji.hat, 1 #emoji.seal, 3 #emoji.cat, 0 #emoji.accordion, 1 #emoji.cactus }$.
]

== Subsets

The most important special case of unordered arrangements is where all repetitions are $1$, that is, #box($r_x = 1$) for all $x in X$.
Then $S$ is simply a _subset_ of $X$, denoted $S subset.eq X$.

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

== Four Counting Problems

#align(center)[
  #table(
    columns: 3,
    align: (left, center, center),
    inset: 1em,
    stroke: (x, y) => {
      let s = (:)
      if y == 0 { s.insert("bottom", 0.8pt) }
      if x == 1 { s.insert("left", 0.4pt) }
      s
    },
    table.header([], [*No repetition*], [*With repetition*]),
    [*Ordered* ($k$-perm., sequence)], $display(n! / (n-k)!) = n^underline(k)$, $n^k$,
    [*Unordered* ($k$-comb., subset)], $display(binom(n, k) = n! / (k! dot (n - k)!))$, $display(binom(k + n - 1, k))$,
  )
]

#Block(color: yellow)[
  - $n$ is the size of the ground set $X$.
  - $k$ is the size of the arrangement we want to count.
  - "Ordered" means position matters: $(A, B) != (B, A)$.
  - "Unordered" means only the selection matters: ${A,B} = {B,A}$.
  - "With repetition" means the same element can appear multiple times.
]


= Multisets
#focus-slide()

== Multiset

#definition[
  A _multiset_ is a modification of the concept of a set that allows for _repetitions_ of its elements.
  Formally, it is denoted as a pair $M = chevron.l X, r chevron.r$, where $X$ is the _groundset_ (the set of _types_) and $r : X to NN_0$ is the _multiplicity function_.
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
  Let $X$ be a finite set of types, and let $M = chevron.l X, r chevron.r$ be a finite multiset with repetition numbers $r_1, dots, r_abs(X)$.
  A _$k$-combination of $M$_ is a multiset $S = chevron.l X, s chevron.r$ with types in $X$ and repetition numbers $s_1, dots, s_abs(X)$ such that #box[$s_i <= r_i$] for all #box[$1 <= i <= abs(X)$], and $sum_(i = 1)^abs(X) s_i = k$.
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
    binom(n, k) = n! / (k! dot (n - k)!) = (n dot (n-1) dot (n-2) dot dots dot (n-k+1)) / (k dot (k-1) dot (k-2) dot dots dot 2 dot 1)
  $
]

== Pascal's Triangle

Row $n$ of _Pascal's triangle_ lists $binom(n, 0), binom(n, 1), dots, binom(n, n)$.
Each entry is the sum of the two entries above it: $binom(n, k) = binom(n-1, k-1) + binom(n-1, k)$.

#grid(
  columns: (1fr, auto),
  column-gutter: 1em,
  [
    *Key identities:*
    - *Row sum:* $display(sum_(k=0)^n binom(n, k) = 2^n)$ (set $x = y = 1$)
    - *Symmetry:* $binom(n, k) = binom(n, n-k)$
    - *Absorption:* $n binom(n-1, k-1) = (k+1) binom(n, k+1)$
    - *Vandermonde:* $display(sum_k binom(m, k) binom(n, r-k) = binom(m+n, r))$
  ],
  align(center)[
    #cetz.canvas(length: 0.85cm, {
      import cetz.draw: *
      let bincoef(n, k) = {
        let r = 1.0
        for i in range(k) { r = r * (n - i) / (i + 1) }
        calc.round(r)
      }
      let cw = 1.2
      let rh = 0.88
      for row in range(7) {
        for col in range(row + 1) {
          let x = (col - row / 2) * cw
          let y = -row * rh
          let v = bincoef(row, col)
          let clr = if v == 1 { blue.lighten(88%) } else { blue.lighten(72%) }
          circle((x, y), radius: 0.38, fill: clr, stroke: 0.5pt + blue.darken(20%))
          content((x, y), str(v))
        }
      }
    })
  ],
)

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
  Expand $(x_1 + dots + x_r)^n$ by choosing one term from each of the $n$ factors.
  A monomial $x_1^(k_1) dot.c dots dot.c x_r^(k_r)$ with $k_1 + dots + k_r = n$ is produced whenever we choose $x_i$ from exactly $k_i$ of the $n$ factors.
  The number of ways to assign the $n$ factor-positions to the $r$ variables in groups of sizes $k_1, dots, k_r$ is $binom(n, k_1, dots, k_r) = n! / (k_1 ! dot.c dots dot.c k_r !)$.
]

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
  Let $S = chevron.l X, r_infinity chevron.r = { infinity #emoji.banana, infinity #emoji.apple.red, infinity #emoji.pear }$ with $r_x = infinity$ and $abs(X) = s = 3$.
  - Let $k = 5$ (as an example).
    Consider a 5-combination of $S$: ${ #emoji.banana, #emoji.apple.red, #emoji.banana, #emoji.pear, #emoji.pear }$.
  - Reorder and group: ${ #emoji.banana #emoji.banana | #emoji.apple.red | #emoji.pear #emoji.pear }$.
  - Convert to _dots_ and _bars_: #h(1em) $bullet bullet bar bullet bar bullet bullet$
  - Represent as a 2-type multiset: $M = { thin k dot bullet, thick (s-1) dot bar zws thin }$
  - Observe: each _permutation_ of $k$ dots and $(s-1)$ bars corresponds _uniquely_ to a _$k$-combination_ of $S$.
  - Permute the 2-type multiset: $binom(k + s - 1, k, s - 1)$ ways, by @multinomial-theorem.

  This method is also known as _Stars and Bars_.
]


= Compositions
#focus-slide()

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
  Observe that $k = overbrace(underbrace(1 + 1, inline(b_1)) + underbrace(dots, inline(b_i)) + underbrace(1 + 1, inline(b_s)), k "ones")$.

  Use the _stars-and-bars_ method to count the number of $s$ groups composed of $k$ "ones".
]

#example[
  Let $k = 3$.
  There are $binom(3 + 3 - 1, 3, 3 - 1) = binom(5, 3) = binom(5, 2) = 10$ ways to decompose $k = 3$ into $s = 3$ parts:
  $
    k & = 3 = \
      & = 0 + 1 + 2 = 0 + 2 + 1 \
      & = 1 + 0 + 2 = 1 + 2 + 0 = 1 + 1 + 1 \
      & = 2 + 0 + 1 = 2 + 1 + 0 \
      & = 3 + 0 + 0 = 0 + 3 + 0 = 0 + 0 + 3 \
  $
]

== Compositions

#definition[
  A _composition_ of a positive integer $k >= 1$ into $s$ _positive_ parts is a _solution_ to the equation $b_1 + dots + b_s = k$, where each $b_i > 0$.
]

#theorem[
  There are $binom(k - 1, s - 1)$ _compositions_ of $k > 0$ into $s$ positive parts.
]

#proof[
  Line up $k$ ones in a row.
  A composition $b_1 + dots + b_s = k$ with each $b_i >= 1$ corresponds to choosing $s - 1$ of the $k - 1$ _gaps between consecutive ones_ as dividers.
  There are $binom(k - 1, s - 1)$ such choices.
]

#pagebreak()

#theorem[
  The total number of compositions of $k > 0$ into _some_ number of positive parts is
  $
    sum_(s = 1)^k binom(k - 1, s - 1) = 2^(k - 1)
  $
]

#proof[
  Substituting $j = s - 1$:
  $
    sum_(s = 1)^k binom(k - 1, s - 1) = sum_(j = 0)^(k - 1) binom(k - 1, j) = (1 + 1)^(k - 1) = 2^(k - 1)
  $
  by the Binomial Theorem applied to $(1 + 1)^(k-1)$.
]

// TODO: add Stars and Bars visual diagram (see review)

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
#focus-slide()

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
  Consider the element $n$ in any partition of $[n]$ into $k$ blocks.
  There are exactly two cases:
  - $\{n\}$ forms a singleton block on its own.
    The remaining $n - 1$ elements are partitioned into $k - 1$ non-empty blocks: $stirling(n-1, k-1)$ ways.
  - $n$ joins an existing block of a partition of $[n-1]$.
    Start with any partition of $[n-1]$ into $k$ blocks ($stirling(n-1, k)$ ways), then insert $n$ into one of the $k$ blocks: $k dot stirling(n-1, k)$ ways.
  These two cases are exhaustive and disjoint.
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
#focus-slide()

== Integer Partitions

The integer $4$ can be written as a sum of positive integers in exactly $5$ ways:
$4 = 3 + 1 = 2 + 2 = 2 + 1 + 1 = 1 + 1 + 1 + 1$.
Order does _not_ matter: $3 + 1$ and $1 + 3$ are the same partition.

#definition[
  An _integer partition_ of a positive integer $n >= 1$ into $k$ _positive_ parts is a solution to the equation $n = a_1 + dots + a_k$, where $a_1 >= a_2 >= dots >= a_k >= 1$.

  - The number of such partitions is denoted $p_(k)(n)$ and defined recursively:
    $
      p_(k)(n) = cases(
        0 & "if" k > n,
        0 & "if" n >= 1 "and" k = 0,
        1 & "if" n = k = 0,
        p_(k)(n - k) + p_(k - 1)(n - 1) & "if" 1 <= k <= n,
      )
    $

  - The _partition function_ $p(n)$ counts all partitions of $n$:
    $
      p(n) = sum_(k = 0)^(n) p_(k)(n)
    $
]

#Block(color: teal)[
  *Rapid growth of $p(n)$:*
  $p(5) = 7$, $quad p(10) = 42$, $quad p(50) = 204{,}226$, $quad p(100) = 190{,}569{,}292$.
  Hardy and Ramanujan (1918) proved:
  $
    p(n) tilde frac(1, 4 n sqrt(3)) e^(pi sqrt(2n slash 3))
  $
  so the number of partitions grows _sub-exponentially_ but faster than any polynomial.
]

== Ferrers Diagrams and Young Tableaux

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
    link("https://en.wikipedia.org/wiki/Norman_Macleod_Ferrers", box(
      image("assets/Norman_Ferrer.jpg"),
      height: 3cm,
      radius: 20%,
      clip: true,
      stroke: 1pt + blue,
    )),
    link("https://en.wikipedia.org/wiki/Alfred_Young_(mathematician)", box(
      image("assets/Alfred_Young.jpg"),

      height: 3cm,
      radius: 20%,
      clip: true,
      stroke: 1pt + blue,
    )),

    [Norman Ferrer], [Alfred Young],
  )
]

#table(
  columns: 2,
  stroke: (x, y) => if y == 0 { (bottom: 0.4pt) },
  table.header([*Ferrer Diagram*], [*Young Tableaux*]),
  partition_diagram(parts, young: false), partition_diagram(parts, young: true),
)


= Inclusion--Exclusion

#focus-slide(
  epigraph: [There are very few things which we know, which are not capable \ of being reduced to a mathematical reasoning.],
  epigraph-author: "Abraham de Moivre, The Doctrine of Chances (1718)",
)

== Motivating Example

#example[
  How many integers in $\{1, dots, 100\}$ are divisible by $2$ _or_ by $3$?
  - Let $A = \{ k in [100] | 2 divides k \}$, so $abs(A) = 50$.
  - Let $B = \{ k in [100] | 3 divides k \}$, so $abs(B) = 33$.
  - Their intersection $A intersect B = \{ k in [100] | 6 divides k \}$ has $abs(A intersect B) = 16$.
  By inclusion--exclusion:
  $
    abs(A union B) = abs(A) + abs(B) - abs(A intersect B) = 50 + 33 - 16 = 67
  $
]

Generalizing this to an arbitrary number of sets gives the full PIE theorem.

== Principle of Inclusion--Exclusion (PIE)

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

== Counting the Union

#corollary[
  $
    abs(union.big_(i in [m]) X_i)
    = sum_(emptyset != S subset.eq [m]) (-1)^(abs(S) - 1) abs(N(S))
  $
]


// Venn diagram: three overlapping sets with +/- signs showing PIE
// #align(center)[
//   #cetz.canvas(length: 0.85cm, {
//     import cetz.draw: *
//     circle((-1.0, 0), radius: 1.5, fill: red.transparentize(80%), stroke: 1pt + red.darken(20%))
//     circle((1.0, 0), radius: 1.5, fill: blue.transparentize(80%), stroke: 1pt + blue.darken(20%))
//     circle((0, -1.6), radius: 1.5, fill: green.transparentize(80%), stroke: 1pt + green.darken(20%))
//     content((-2.1, 1.2), [$A$])
//     content((2.1, 1.2), [$B$])
//     content((1.2, -2.9), [$C$])
//     // Only A, B, C: counted once (+)
//     content((-2.1, 0), text(fill: green.darken(20%), size: 1.3em, weight: "bold")[$+$])
//     content((2.1, 0), text(fill: green.darken(20%), size: 1.3em, weight: "bold")[$+$])
//     content((0, -3.0), text(fill: green.darken(20%), size: 1.3em, weight: "bold")[$+$])
//     // Pairwise intersections: subtract (-)
//     content((0, 0.85), text(fill: red.darken(20%), size: 1.3em, weight: "bold")[$-$])
//     content((-0.75, -0.95), text(fill: red.darken(20%), size: 1.3em, weight: "bold")[$-$])
//     content((0.75, -0.95), text(fill: red.darken(20%), size: 1.3em, weight: "bold")[$-$])
//     // Triple intersection: add back (+)
//     content((0, -0.35), text(fill: green.darken(20%), size: 1.3em, weight: "bold")[$+$])
//   })
// ]

== Applications of PIE

// The following template organizes any PIE argument:

#grid(
  columns: 1,
  row-gutter: 0.6em,
  [
    #Block(color: teal, width: 100%)[
      *Step 1: Define "bad" properties*

      Identify elements of a universe $X$ to _exclude_: those having _at least one_ of properties $P_1, dots, P_m$.

      Target: count $X setminus (X_1 union dots union X_m)$.
    ]
  ],
  [
    #Block(color: blue, width: 100%)[
      *Step 2: Count $N(S)$*

      For each $S subset.eq [m]$, determine $N(S)$ --- number of elements of $X$ having _all_ bad properties $P_i$ for $i in S$.
    ]
  ],
  [
    #Block(color: yellow, width: 100%)[
      *Step 3: Apply PIE*

      Use @thm:pie to compute a closed formula:
      $ abs(X setminus (X_1 union dots union X_m)) = sum_(S subset.eq [m]) (-1)^abs(S) N(S) $
    ]
  ],
)

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
      abs(X setminus (X_1 union dots union X_n)) & =^"PIE" sum_(S subset.eq [n]) (-1)^abs(S) abs(N(S)) \
                                                 & = sum_(S subset.eq [n]) (-1)^abs(S) (n - abs(S))^k \
                                                 & = sum_(i = 0)^n (-1)^i binom(n, i) (n - i)^k \
    $
    In the last step, we used that $(-1)^abs(S) (n - abs(S))^k$ only depends on the size of $S$, and there are $binom(n, i)$ sets #box[$S subset.eq [n]$] of size $i$.
]

== Useful Corollaries

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
      abs(X setminus (X_1 union dots union X_n)) & =^"PIE" sum_(S subset.eq [n]) (-1)^abs(S) abs(N(S)) \
                                                 & = sum_(S subset.eq [n]) (-1)^abs(S) (n - abs(S))! \
                                                 & = sum_(i = 0)^n (-1)^i binom(n, i) (n - i)!
    $

    In the last step, we used that $(-1)^abs(S) (n - abs(S))!$ only depends on the size of $S$, and there are $binom(n, i)$ sets #box[$S subset.eq [n]$] of size $i$.
]

#pagebreak()

#Block(color: blue)[
  *Hat-check problem:* $n$ guests check their hats; the attendant loses the tickets.
  As $n to infinity$, the probability that no guest gets their own hat back converges to
  $
    lim_(n to infinity) abs(D_n) / n! = sum_(i=0)^infinity (-1)^i / i! = 1 / e approx 36.8%
  $
  This probability barely changes for $n >= 5$.
]


= Generating Functions

#focus-slide(
  epigraph: [A generating function is a clothesline on which \ we hang up a sequence of numbers for display.],
  epigraph-author: "Herbert Wilf, generatingfunctionology",
)

== Generating Functions

#quote(attribution: [George Pólya, Mathematics and Plausible Reasoning @polya1954])[
  _A generating function is a device somewhat similar to a bag. Instead of carrying many little objects detachedly, which could be embarrassing, we put them all in a bag, and then we have only one object to carry, the bag._
]

#Block(color: yellow)[
  Encode a sequence $(a_n)$ as coefficients of a formal power series $G(x) = sum_(n=0)^infinity a_n x^n$, then manipulate $G(x)$ _algebraically_ (multiply, differentiate, compose) to derive counting identities and closed forms.
]

== Counting with Polynomials

*Problem.* Two fair dice. How many outcomes give sum $n$?

Encode one die as a polynomial: the term $x^k$ stands for "rolling $k$ is possible."
$
  D(x) = x + x^2 + x^3 + x^4 + x^5 + x^6
$
Two independent dice → multiply:
$
  D(x)^2 = x^2 + 2x^3 + 3x^4 + 4x^5 + 5x^6 + underbracket(6 x^7) + 5x^8 + 4x^9 + 3x^10 + 2x^11 + x^12
$

The coefficient of $x^n$ gives the count for sum $n$.
For sum 7: $[x^7] D(x)^2 = 6$. #YES

#Block(color: yellow)[
  One multiplication solves the problem for _every_ $n$ simultaneously.

  This polynomial is a _generating function_ --- now let's understand what they are and why this works.
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

== The Core Generating Function

Another proof that $(1, 1, 1, dots)$ is generated by $G(x) = 1 + x + x^2 + x^3 + dots = sum_(n = 0)^(infinity) x^n = frac(1, 1 - x) = S$:
#grid(
  columns: 3,
  inset: (2pt, 5pt),
  align: (right, center, left).map(x => x + horizon),
  stroke: (x, y) => if y == 1 { (bottom: .6pt) },
  $S$, $=$, $1 + x + x^2 + x^3 + dots$,
  $x dot S$, $=$, $#hide($0 +$) x + x^2 + x^3 + dots$,
  $S - x dot S$, $=$, $1$,
)
Thus, $display(S = 1 / (1 - x))$.

The generating function $G(x) = 1 + x + x^2 + dots$ is also known as the _Maclaurin series_ of $display(1 / (1 - x))$.

== More Examples of Generating Functions

#table(
  columns: 4,
  align: (right, left, left, left).map(x => x + horizon),
  stroke: (x, y) => if y == 0 { (bottom: .8pt) },
  table.header([*Formula*], [*Power series*], [*Sequence*], [*Description*]),
  box($ 1 / (1 - x) $), box($ sum_(n = 0)^infinity x^n = 1 + x + x^2 + x^3 + dots $), $(1, 1, 1, dots)$, [constant 1],
  box($ 2 / (1 - x) $),
  box($ sum_(n = 0)^infinity 2 x^n = 2 + 2x + 2x^2 + 2x^3 + dots $),
  $(2, 2, 2, dots)$,
  [constant 2],

  box($ x / (1 - x) $),
  box($ sum_(n = 1)^infinity x^n = 0 + x + x^2 + x^3 + dots $),
  $(0, 1, 1, 1, dots)$,
  [right shift],

  box($ 1 / (1 + x) $),
  box($ sum_(n = 0)^infinity (-1)^n x^n = 0 + 1 - x + x^2 - x^3 + dots $),
  $(1, -1, 1, dots)$,
  [sign-alternating 1's],

  box($ 1 / (1 - 3x) $),
  box($ sum_(n = 0)^infinity 3^n x^n = 1 + 3x + 9x^2 + 27x^3 + dots $),
  $(1, 3, 9, dots)$,
  [powers of 3],

  box($ 1 / (1 - x^2) $),
  box($ sum_(n = 0)^infinity x^(2n) = 1 + x^2 + x^4 + x^6 + dots $),
  $(1, 0, 1, 0, dots)$,
  [regular gaps],

  box($ 1 / (1 - x)^2 $),
  box($ sum_(n = 0)^infinity (n+1) x^n = 1 + 2x + 3x^2 + 4x^3 + dots $),
  $(1, 2, 3, 4, dots)$,
  [natural numbers],
)

$
  frac(1-x^(n+1), 1-x) & = frac(1, 1-x) - frac(x^(n+1), 1-x) = \
                       & eq.delta (1,1,1,dots) - \(underbrace(0\,0\,dots\,0, n+1 "zeros"),1,1,dots) = \
                       & = \(underbrace(1\,1\,dots\,1, n+1 "ones"), 0,0,dots) = \
                       & eq.delta 1 + x + x^2 + dots + x^n
$

== Exercises

#example[
  Find the GF for odd numbers: $(1, 3, 5, 7, dots)$.

  #note(title: "Hint")[
    write $A(x) = 1 + 3x + 5x^2 + 7x^3 + dots$, then compute $x dot A(x)$ and subtract from $A(x)$.

    What familiar series do you see in the result?
  ]
]

#v(2em)

#example[
  Find the GF for $(1, 3, 7, 15, 31, 63, dots)$, which satisfies $a_n = 3 a_(n-1) - 2 a_(n-2)$ with $a_0 = 1$, $a_1 = 3$.

  #note(title: "Hint")[
    write $A(x)$, $-3x A(x)$, and $+2x^2 A(x)$ stacked and add them column by column.

    Most terms cancel because of the recurrence. What remains?
  ]
]

== Solutions

#example[
  *Odd numbers.* Let $A(x) = 1 + 3x + 5x^2 + 7x^3 + dots$
  $
    mat(
      delim: #none,
      align: #right,
      column-gap: #.5em,
      row-gap: #.5em,
      augment: #(hline: -1),
      A(x), =, 1, +, 3x, +, 5x^2, +, 7x^3, +, 9x^4, +, dots;
      x dot A(x), =, , +, x, +, 3x^2, +, 5x^3, +, 7x^4, +, dots;
      A - x dot A, =, 1, +, 2x, +, 2x^2, +, 2x^3, +, 2x^4, +, dots;
    )
  $
  The result is $1 + 2(x + x^2 + x^3 + dots) = 1 + 2 dot x / (1-x)$, so:
  $
    A(x) = (1 + 2 dot x / (1-x)) / (1-x) = (1-x + 2x) / (1-x)^2 = (1+x) / (1-x)^2
  $
  Check: $(1+x) / (1-x)^2 = (1,1,1,dots) + (0,2,4,6,8,dots) = (1,3,5,7,9,dots)$. #YES
]

#pagebreak()

#example[
  *Recurrence sequence.* Stack $A$, $-3x dot A$, $+2x^2 dot A$ and add:
  $
    mat(
      delim: #none,
      align: #right,
      column-gap: #.5em,
      row-gap: #.5em,
      augment: #(hline: -1),
      A(x), =, 1, +, 3x, +, 7x^2, +, 15x^3, +, 31x^4, +, dots;
      -3x dot A(x), =, , -, 3x, -, 9x^2, -, 21x^3, -, 45x^4, -, dots;
      2x^2 dot A(x), =, , , , , 2x^2, +, 6x^3, +, 18x^4, +, dots;
      (1-3x+2x^2) dot A(x), =, 1;
    )
  $
  Every column beyond $x^0$ vanishes because $a_n - 3 a_(n-1) + 2 a_(n-2) = 0$ by the recurrence.

  Thus $display(A(x) = 1 / (1 - 3x + 2x^2))$.
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
  Find the number of integer solutions to $a_1 + a_2 + a_3 = 12$ with $a_1 >= 2$, $3 <= a_2 <= 6$, $0 <= a_3 <= 9$.

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

== Operations on Generating Functions

Let $F(x) = sum_(n = 0)^infinity a_n x^n$ and $G(x) = sum_(n = 0)^infinity b_n x^n$ be ordinary generating functions.

#table(
  columns: 2,
  align: left + horizon,
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header([*Operation*], [*Result*]),
  [Differentiate $F(x)$ term-wise], box($ F'(x) = sum_(n = 0)^infinity (n + 1) a_(n + 1) x^n $),
  [Multiply $F(x)$ by a scalar $lambda in RR$ term-wise], box($ lambda F(x) = sum_(n = 0)^infinity lambda a_n x^n $),
  [Add $F(x)$ and $G(x)$ term-wise], box($ F(x) + G(x) = sum_(n = 0)^infinity (a_n + b_n) x^n $),
  [Multiply $F(x)$ and $G(x)$ term-wise \ (_Cauchy product_, or _convolution_)],
  box($ F(x) dot G(x) = sum_(n = 0)^infinity (sum_(k = 0)^n a_k b_(n - k)) x^n $),
)

== Catalan Numbers via Generating Functions

So far, we _composed_ generating functions from known polynomials and read off coefficients.

Now we turn the idea around: start from a _recursive counting argument_, derive a _functional equation_ for $F(x)$, and solve it.

This requires a heavier tool --- _Newton's binomial theorem_ for real-valued exponents --- but the payoff is one of the most famous sequences in combinatorics.

#Block(color: teal)[
  *Historical note:* Eugène Catalan (1814--1894) studied these numbers in the context of polygon triangulation.
  They appear in dozens of seemingly unrelated counting problems --- a phenomenon that generating functions help explain.
]

== Well-Formed Parenthesis Expressions

#example[
  Find the number of _well-formed parenthesis expressions_ with $n$ pairs of parenthesis.

  For example, "`(()())()`" is a well-formed parenthesis expression with 4 pairs of parenthesis.

  Formally, a permutation of the multiset ${n dot "\"(\"", n dot "\")\""}$ is _well-formed_ if reading it from left to right and counting "$+1$" for every opening parenthesis "(" and "$-1$" for every closing parenthesis ")" never yields a negative number at any time.

  Every well-formed expression with $n >= 1$ pairs of paranthesis starts with "(" and there is a unique matching ")" such that the sequence in between and the sequence after are well-formed.
  For example:
  $
    lr((()), size: #150%) () ()
    quad
    lr((() (())), size: #150%)
    quad
    lr((), size: #150%) (()(()))
  $
  In other words, a well-formed expression with $n$ pairs of parenthesis is obtained by putting a well-formed expression with $k$ pairs in between "(" and ")" and then appending a well-formed expression with #box($n-k-1$) pairs of parenthesis.
  This gives the equation:
  #place(center)[
    #v(1em)
    $
      a_n = sum_(k = 0)^(n - 1) a_k a_(n - k - 1)
    $
  ]
]

#pagebreak()

// $
//   a_n = sum_(k = 0)^(n - 1) a_k a_(n - k - 1)
// $

Let $F(x)$ be a generating function for $a_n$, then we know:
$
  F(x) & = sum_(n = 0)^infinity a_n x^n
         = 1 + sum_(n = 1)^infinity ( sum_(k = 0)^(n - 1) a_k a_(n - k - 1) ) x^n
         = 1 + sum_(n = 0)^infinity ( sum_(k = 0)^(n) a_k a_(n - k) ) x^(n+1) \
       & = 1 + x dot sum_(n = 0)^infinity ( sum_(k = 0)^(n) a_k a_(n - k) ) x^n
         = 1 + x dot F(x)^2
$

Solving the equation $x F^2 - F + 1 = 0$ for $F$ gives:
$
  F(x) = frac(1 plus.minus sqrt(1 - 4x), 2x)
$

We are only interested in the root with the _minus_ sign, since $lim_(x to 0) F(x) = a_0 = 1$:
$
  lim_(x to 0) F(x)
  = lim_(x to 0) frac(1 - sqrt(1 - 4x), 2x)
  = lim_(x to 0) frac(frac(2, sqrt(1 - 4x)), 2)
  = 1
$

== Newton's Binomial Theorem

To extract the coefficients of $F(x) = (1 - sqrt(1 - 4x)) / (2x)$, we need to expand $sqrt(1 - 4x)$ as a power series.

This requires extending the binomial theorem to _real_ exponents.

Let's revisit the binomial theorem:
$
  (1 + x)^n = sum_(k = 0)^n binom(n, k) x^k = sum_(k = 0)^infinity binom(n, k) x^k
  quad forall n in NN
$
where $binom(n, k) = 0$ for $k > n$.

#note[
  This shows that $(1 + x)^n$ is the generating function for the series $(a_k)_(k in NN)$ with $a_k = binom(n, k)$.
]

#Block(color: green)[
  We can extend this result from natural numbers $n in NN$ to any _real_ number $n in RR$.
]

== Binomial Coefficients for Real Numbers

#definition[
  Let $p(n, k) = n dot (n - 1) dot dots dot (n - k + 1)$, also called the _falling factorial_ $n^underline(k)$.

  Extend the definition of binomial coefficients for real numbers $n,k in RR$:
  $
    binom(n, k) = p(n, k) / k!
  $
]

#note[
  This definition aligns with the definition of binomial coefficients for natural numbers:
  $
    binom(n, k) = n! / (k! dot (n - k)!) = (n dot (n-1) dot dots dot (n-k+1)) / k!
  $
]

#example[
  Consider the number "$-7 \/ 2$ choose $5$":
  $
    binom(-7 \/ 2, 5) = (-7 \/ 2 dot -9 \/ 2 dot -11 \/ 2 dot -13 \/ 2 dot -15 \/ 2) / 5! = - 9009 / 256
  $
]

#note[
  $p(n, 0) = 1$ and for $k >= 1$, we have $p(n, k) = (n - k + 1) dot p(n, k - 1) = n dot p(n - 1, k - 1)$.
  #h(1fr) $(star.filled)$
]

== Extended Newton's Binomial Theorem

#theorem[
  For all non-zero $n in RR$, we have:
  $
    (1 + x)^n = sum_(k = 0)^infinity binom(n, k) x^k
  $
]

#example[
  Let $n = 1 \/ 2$, then we have an identity for $sqrt(1 + x)$:
  $
    sqrt(1 + x) = sum_(k = 0)^infinity binom(1 \/ 2, k) x^k
  $

  To actually _use_ this fact, we need some _lemma_...
]

#theorem(title: "Lemma")[
  For any integer $n >= 1$, we have:
  $
    binom(1 \/ 2, n) = (-1)^(n+1) dot binom(2n-2, n-1) dot 1 / (2^(2n-1)) dot 1 / n
  $
]

#proof[
  By induction on $n$.

  *Base*: $n = 1$.
  #v(-2em)
  $
    binom(1 \/ 2, 1)
    = (1 \/ 2) / 1!
    = 1 / 2 = 1 dot 1 dot 1 / 2 dot 1
    = underbracket((-1)^2, 1)
    dot underbracket(binom(2-2, 1-1), 1)
    dot underbracket(1 / (2^(2-1)), 1 / 2)
    dot underbracket(1 / 1, 1)
  $
  #v(-1em)

  *Induction step*: $n$ to $n + 1$ for $n > 1$.
  We use the recusion $(star.filled)$ $p(n, k) = n dot p(n - 1, k - 1)$:
  #place(center)[
    $
      binom(1 \/ 2, n + 1)
      &= p(1 \/ 2, n + 1) / (n + 1)!
      = ((1 \/ 2 - (n + 1) + 1) dot p(1 \/ 2, n)) / ((n + 1) dot n!)
      = - (n - 1 \/ 2) / (n + 1) binom(1 \/ 2, n) \
      &=^"IH" - (n - 1 \/ 2) / (n + 1) (-1)^(n+1) dot binom(2n-2, n-1) dot 1 / (2^(2n-1)) dot 1 / n \
      &= (2n) / (2n) dot (2n-1) / (2n) dot (-1)^(n+2) dot binom(2n-2, n-1) dot 1 / (2^(2n-1)) dot 1 / (n+1) \
      &= (-1)^(n+2) dot underbrace(((2n-2)! dot (2n-1) dot (2n)) / ((n-1)! dot (n-1) dot n dot n), display(binom(2n, n))) dot 1 / (2^(2n+1)) dot 1 / (n+1)
    $
  ]
]
#pagebreak()

== Catalan Numbers

#theorem(title: "Proposition")[
  Now we can expand $sqrt(1 + n)$ into the following series:
  $
    sqrt(1 + n) = sum_(n = 0)^infinity binom(1 \/ 2, n) x^n
    = 1 + sum_(n = 1)^infinity -2 dot binom(2n - 2, n - 1) dot (-1)^n dot 1 / (2^(2n)) dot 1 / n dot x^n
  $
]

#example[
  Going back to the example with the number of well-formed paranthesis expressions, we get:
  $
    F(x) & = (1 - sqrt(1 - 4x)) / (2x)
           = 1 / (2x) sum_(n = 1)^infinity 2 dot binom(2n - 2, n - 1) dot (-1)^n dot 1 / (2^(2n)) dot 1 / n dot (-4x)^n \
         & = 1 / x sum_(n = 1)^infinity binom(2n - 2, n - 1) 1 / n x^n
           = sum_(n = 0)^infinity binom(2n, n) 1 / (n+1) x^n
  $
  The numbers $C_n := display(binom(2n, n) 1 / (n+1))$ are called _Catalan numbers_.
]

#pagebreak()

#Block(color: yellow)[
  *Catalan numbers* $C_n = 1/(n+1) binom(2n, n)$ count many combinatorial structures:
  - well-formed parenthesis strings of length $2n$,
  - full binary trees with $n+1$ leaves,
  - triangulations of a convex $(n+2)$-gon,
  - monotone lattice paths from $(0,0)$ to $(n,n)$ not crossing the diagonal.

  $ C_0=1, quad C_1=1, quad C_2=2, quad C_3=5, quad C_4=14, quad C_5=42, quad dots $
]


= Recurrence Relations

#focus-slide(
  epigraph: [A certain man placed one pair of rabbits in a place enclosed on all sides by a wall. How many pairs of rabbits can be produced from that pair in one year?],
  epigraph-author: "Leonardo Fibonacci, Liber Abaci (1202)",
)

== Recurrence Relations

A _recurrence relation_ defines a sequence by expressing each term via its predecessors.
Solving one means finding a _closed-form_ formula that avoids recursion.

#example[
  _Arithmetic progression_ as a recurrence:
  $
    a_n = cases(
      a_0 = "const" & "if" n = 0,
      a_(n-1) + d & "if" n > 0,
    )
  $

  Solution by telescoping: $a_n = a_0 + n dot d$.
]

== Recursive Structure

Many combinatorial objects have _recursive structure_: a large instance can be decomposed into smaller instances of the same problem.
A recurrence captures this decomposition _exactly_.

#example[
  How many binary strings of length $n$ contain _no two consecutive_ 1s?
  Let $b(n)$ denote the count.

  Consider the last bit of a valid string of length $n$:
  - *Ends in 0:* the first $n - 1$ bits form any valid string of length $n - 1$, giving $b(n - 1)$ ways.
  - *Ends in 1:* the previous bit must be 0, so the first $n - 2$ bits form any valid string of length $n - 2$, giving $b(n - 2)$ ways.

  Therefore $b(n) = b(n - 1) + b(n - 2)$, with $b(1) = 2$ and $b(2) = 3$.

  This is the _Fibonacci recurrence_ with shifted initial conditions.
  Once we solve it (using the characteristic equation), we get a closed formula that avoids enumerating all $2^n$ strings.
]

== Telescoping

Before reaching for characteristic equations, try the simplest approach: _unwind the recurrence_.

#example[
  Solve $T(n) = T(n - 1) + n$ with $T(0) = 0$.

  Unwind by substitution:
  $
    T(n) & = T(n - 1) + n \
         & = T(n - 2) + (n - 1) + n \
         & = dots.v \
         & = T(0) + 1 + 2 + dots + n \
         & = n(n + 1) / 2
  $
]

#theorem[
  If $a_n = a_(n-1) + f(n)$, then $a_n = a_0 + sum_(i=1)^n f(i)$ (telescoping sum).
]

== Tower of Hanoi

#example[
  *Tower of Hanoi.*
  Move $n$ disks from peg A to peg C, one at a time, never placing a larger disk on a smaller one.
  Let $T(n)$ be the minimum number of moves.

  Recurrence: $T(n) = 2 T(n - 1) + 1$, with $T(1) = 1$.

  Unwind:
  $
    T(n) & = 2 T(n - 1) + 1 \
         & = 2(2 T(n - 2) + 1) + 1 = 4 T(n - 2) + 3 \
         & = 8 T(n - 3) + 7 \
         & = 2^k T(n - k) + (2^k - 1)
  $

  Setting $k = n - 1$: $T(n) = 2^(n-1) T(1) + 2^(n-1) - 1 = 2^n - 1$.
]

#note[
  Telescoping works well for first-order recurrences.
  For higher orders and constant-coefficient recurrences, we need more systematic methods.
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
  - The recurrence relation $a_n = a_(n-1) + a_(n-2)^2$ is _not linear_.
  - The recurrence relation $H_n = 2 H_(n-1) + 1$ is _not homogeneous_.
]

== Characteristic Equations

Fix a linear homogeneous recurrence of degree $k$:
$ a_n = c_1 a_(n-1) + c_2 a_(n-2) + dots + c_k a_(n-k) quad (star) $

If we try a solution of the form $a_n = r^n$ (with $r != 0$), substituting into $(star)$ and dividing by $r^(n-k)$ yields:

#definition[
  The _characteristic equation_ of $(star)$ is:
  $
    r^k - c_1 r^(k-1) - c_2 r^(k-2) - dots - c_k = 0
  $

  Its solutions $r_1, r_2, dots$ are the _characteristic roots_ of the recurrence.
  Each root yields a solution $a_n = r^n$.
]

== Distinct Roots Case

#theorem[
  Let $c_1$ and $c_2$ be real numbers.
  Suppose that $r^2 - c_1 r - c_2 = 0$ has two _distinct_ roots $r_1$~and~$r_2$.
  Then the sequence $(a_n)$ is a solution of the recurrence relation $a_n = c_1 a_(n-1) + c_2 a_(n-2)$ if and only if $a_n = alpha_1 r_1^n + alpha_2 r_2^n$ for $n = 0, 1, 2, dots$, where $alpha_1$ and $alpha_2$ are constants.
]

#proof[(sketch)][
  Since $r_i$ are roots, $r_i^2 = c_1 r_i + c_2$.
  By factoring $r_i^(n-2)$ from $c_1 a_(n-1) + c_2 a_(n-2)$, direct substitution shows $alpha_1 r_1^n + alpha_2 r_2^n$ satisfies the recurrence.
  The converse follows because distinct roots yield a Vandermonde system with a unique solution for $alpha_1, alpha_2$.
]

== Worked Example

#example[
  Solve $a_n = a_(n-1) + 2 a_(n-2)$ with $a_0 = 2$ and $a_1 = 7$.

  - The _characteristic_ equation is $r^2 - r - 2 = 0$.
  - It has two _distinct_ roots $r_1 = 2$ and $r_2 = -1$.
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
  The recurrence $F_n = F_(n-1) + F_(n-2)$ has characteristic equation $r^2 - r - 1 = 0$ with roots:
  $
    phi = (1 + sqrt(5)) / 2 approx 1.618, quad psi = (1 - sqrt(5)) / 2 approx -0.618.
  $

  The general solution is $F_n = alpha_1 phi^n + alpha_2 psi^n$ for constants $alpha_1, alpha_2$.
  Using initial conditions $F_0 = 0$ and $F_1 = 1$:
  $
    cases(
      alpha_1 + alpha_2 = 0,
      alpha_1 phi + alpha_2 psi = 1,
    )
  $
]

== Binet's Formula

Solving for $alpha_1, alpha_2$ yields $alpha_1 = 1 \/ sqrt(5)$ and $alpha_2 = -1 \/ sqrt(5)$, giving _Binet's formula_:

#align(center)[
  $ F_n = (phi^n - psi^n) / sqrt(5) $
]

Since $|psi| approx 0.618 < 1$, the term $psi^n to 0$, so $F_n$ is the nearest integer to $phi^n \/ sqrt(5)$.

In particular, $F_(n+1) \/ F_n to phi$ as $n to infinity$.

== Eigenvalues and the Companion Matrix

The characteristic equation of a recurrence is the _characteristic polynomial_ of its companion matrix.

For $a_n = c_1 a_(n-1) + c_2 a_(n-2) + dots + c_k a_(n-k)$, the _companion matrix_ $C$ is the $k times k$ matrix with coefficients in the first row and ones on the sub-diagonal:
$
  C = mat(
    c_1, c_2, c_3, dots, c_k;
    1, 0, 0, dots, 0;
    0, 1, 0, dots, 0;
    dots.v, dots.v, dots.v, dots.v, dots.v;
    0, 0, 0, dots, 0
  )
$

For $k = 2$: $C = mat(c_1, c_2; 1, 0)$, and $det(C - lambda I) = lambda^2 - c_1 lambda - c_2$.

#example[
  Fibonacci: $C = mat(1, 1; 1, 0)$, eigenvalues $phi, psi$.
  Matrix exponentiation computes $F_n$ in $O(log n)$ multiplications (binary exponentiation), vs. $O(n)$ for naive iteration.
]

== Single (Repeated) Root Case

#theorem[
  Let $c_1$ and $c_2$ be real numbers.
  Suppose that $r^2 - c_1 r - c_2 = 0$ has a _single_ _(repeated)_ root $r_0$.
  A sequence $(a_n)$ is a solution of the recurrence relation $a_n = c_1 a_(n-1) + c_2 a_(n-2)$ if and only if #box[$a_n = (alpha_1 + alpha_2 n) thin r_0^n$] for $n = 0, 1, 2, dots$, where $alpha_1$ and $alpha_2$ are constants.
]

#example[
  Solve $a_n = 6 a_(n-1) - 9 a_(n-2)$ with $a_0 = 1$ and $a_1 = 6$.

  The characteristic equation is $r^2 - 6 r + 9 = 0$ with a single (repeated) root $r_0 = 3$.
  Hence, the solutions is of the form $a_n = (alpha_1 + alpha_2 n) thin 3^n$.
  $
    cases(
      a_0 = 1 = alpha_1,
      a_1 = 6 = (alpha_1 + alpha_2) dot 3,
    )
    quad arrow.long.double quad
    cases(
      alpha_1 = 1,
      alpha_2 = 1,
    )
  $
  Thus, the _solution_ is $a_n = (1 + n) thin 3^n$.
]

== General Case

#theorem[
  Let $c_1, dots, c_k$ be real numbers.
  Suppose that the recurrence $a_n = c_1 a_(n-1) + dots + c_k a_(n-k)$ has $t$~distinct characteristic roots $r_1, dots, r_t$ with multiplicities $m_1, dots, m_t$, respectively, so that $m_i >= 1$ for $i = 1, dots, t$ and $m_1 + dots + m_t = k$.

  Then the general solution of the recurrence relation is given by
  $
    a_n = sum_(i = 1)^(t)(r_i^n dot sum_(j = 0)^(m_i - 1) alpha_(i,j) n^j)
  $
  where $alpha_(i,j)$ are constants for $1 <= i <= t$ and $0 <= j <= m_i - 1$.
]

#example[
  Find generic solution for $a_n = 7 a_(n-1) - 16 a_(n-2) + 12 a_(n-3)$.

  The characteristic equation $r^3 - 7 r^2 + 16 r - 12 = 0$ has $t = 2$ distinct roots: $r_1 = 2$ repeated $m_1 = 2$ times, and $r_2 = 3$ with multiplicity $m_2 = 1$.
  Hence, the solution is of the form
  $
    a_n = (alpha_(1,0) + alpha_(1,1) n) thin 2^n + alpha_(2,0) thin 3^n
  $
]

== Complex Roots

When the characteristic equation has complex roots, they come in _conjugate pairs_ $rho e^(plus.minus i theta)$ (for recurrences with real coefficients).

#definition[
  For conjugate roots $rho e^(plus.minus i theta)$, the real general solution is:
  $
    a_n = rho^n (alpha cos(n theta) + beta sin(n theta))
  $
  This follows from Euler's formula: $rho^n e^(i n theta) = rho^n (cos(n theta) + i sin(n theta))$.
]

#Block(color: blue)[
  Complex roots produce _oscillating exponential_ behavior: magnitude $rho^n$ grows (or decays), while $cos(n theta)$ and $sin(n theta)$ produce periodic oscillation with period $2 pi \/ theta$.
]

== Complex Roots Example

#example[
  Solve $a_n = 2 a_(n-1) - 2 a_(n-2)$ with $a_0 = 1$ and $a_1 = 1$.

  Characteristic equation $r^2 - 2r + 2 = 0$, roots $r = 1 plus.minus i$.

  Polar form: $1 + i = sqrt(2) e^(i pi\/4)$, so $rho = sqrt(2)$ and $theta = pi\/4$.

  General solution: $a_n = (sqrt(2))^n (alpha cos(n pi\/4) + beta sin(n pi\/4))$.

  Initial conditions: $a_0 = 1 arrow.r alpha = 1$ and $a_1 = 1 arrow.r beta = 0$.

  Therefore $a_n = (sqrt(2))^n cos(n pi\/4)$.
]

== Root Types Summary

For $a_n = c_1 a_(n-1) + c_2 a_(n-2)$, the solution method is always the same four steps. Only the _form_ depends on the roots.

#align(center)[
  #table(
    columns: 4,
    align: (left + horizon, center + horizon, center + horizon, center + horizon),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Step*], [*Distinct Real*], [*Repeated*], [*Complex*]),
    [1. Char. eq.], [$r^2 - c_1 r - c_2 = 0$], [$r^2 - c_1 r - c_2 = 0$], [$r^2 - c_1 r - c_2 = 0$],
    [2. Roots], [$r_1 != r_2$], [$r_0$ (multiplicity 2)], [$rho e^(plus.minus i theta)$],
    [3. Form],
    [$alpha_1 r_1^n + alpha_2 r_2^n$],
    [$(alpha_1 + alpha_2 n) r_0^n$],
    [$rho^n (alpha cos n theta + beta sin n theta)$],

    [4. Fit ICs], [2 equations], [2 equations], [2 equations],
  )
]

== Recurrences and Differential Equations

Linear recurrences are _discrete analogues_ of linear differential equations.
The entire theory mirrors the continuous case.

#align(center)[
  #table(
    columns: 3,
    align: (left, center, center).map(x => x + horizon),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Aspect*], [*Differential Equation*], [*Recurrence*]),
    [1st order], [$y' = c y arrow.r y_0 e^(c t)$], [$a_n = c a_(n-1) arrow.r a_0 c^n$],
    [2nd order], [$y'' + p y' + q y = 0$], [$a_n + p a_(n-1) + q a_(n-2) = 0$],
    [Char. eq.], [$lambda^2 + p lambda + q = 0$], [$r^2 + p r + q = 0$],
    [Double root], [$(c_1 + c_2 t) e^(lambda t)$], [$(alpha_1 + alpha_2 n) r_0^n$],
    [Particular sol.], [Undetermined coefficients], [Same method],
    [Resonance], [$t e^(lambda t)$ factors], [$n r_0^n$ factors],
  )
]

== Solving Linear Recurrences

#align(center)[
  #table(
    columns: 3,
    align: (left, left, left).map(x => x + horizon),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Step*], [*Homogeneous*], [*Non-homogeneous*]),
    [1. Classify], [No $F(n)$ term?], [Has $F(n)$ term?],
    [2. Char. eq.], [$r^k - c_1 r^(k-1) - dots - c_k = 0$], [Same (ignore $F(n)$)],
    [3. Roots], [Distinct / repeated / complex], [Same],
    [4. Homog. sol.], [$a_n^(("h"))$ from root type], [Same],
    [5. Partic. sol.], [---], [Guess form matching $F(n)$],
    [6. General], [$a_n = a_n^(("h"))$], [$a_n = a_n^(("h")) + a_n^(("p"))$],
    [7. Fit ICs], [Solve linear system], [Solve linear system],
  )
]

#Block(color: orange)[
  *Particular solution cheat sheet:*
  $F(n) =$ polynomial of degree $d$ $arrow.r.long$ try $c_0 + c_1 n + dots + c_d n^d$.
  $F(n) = c dot r^n$, $r$ not a root $arrow.r.long$ try $beta r^n$.
  $F(n) = c dot r^n$, $r$ is a root (mult. $m$) $arrow.r.long$ try $beta n^m r^n$ (resonance).
]

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
  If $\(a_n^(("p")))$ is a _particular_ solution of the non-homogeneous recurrence $a_n = c_1 a_(n-1) + dots + c_k a_(n-k) + F(n)$, then _every solution_ is of the form $a_n = a_n^(("p")) + a_n^(("h"))$, where $a_n^(("h"))$ is a solution of the associated homogeneous recurrence.
]

The recipe: (1) solve the homogeneous part, (2) find a particular solution by guessing a form matching $F(n)$, (3) add them, (4) fit initial conditions.

#example[
  Find all solutions of $a_n = 3 a_(n-1) + 2n$ with $a_1 = 3$.

  _Homogeneous part:_ $a_n^(("h")) = alpha 3^n$.

  _Particular solution:_ $F(n) = 2n$ is degree-1 polynomial, so try $p_n = c n + d$.
  Substituting: $c n + d = 3(c(n-1) + d) + 2n$.
  Equating coefficients: $c = -1$, $d = -3\/2$. So $a_n^(("p")) = -n - 3\/2$.

  _General solution:_ $a_n = -n - 3\/2 + alpha 3^n$.

  With $a_1 = 3$: $alpha = 11\/6$, giving $a_n = -n - 3\/2 + (11\/6) 3^n$.
]

== Exponential Forcing Term

When $F(n) = c dot r^n$, try $a_n^(("p")) = beta r^n$.

#Block(color: orange)[
  *Warning: resonance.* If $r$ is already a characteristic root, the trial $beta r^n$ fails.
  Instead, multiply by $n$: try $a_n^(("p")) = beta n r^n$ (or $n^m$ if $r$ has multiplicity $m$).
]

#example[
  Solve $a_n = 2 a_(n-1) + 3^n$ with $a_0 = 1$.

  - _Homogeneous solution:_ $a_n^(("h")) = alpha 2^n$.
  - _Particular solution._ Since $3$ is _not_ a characteristic root, try $a_n^(("p")) = beta dot 3^n$:
    $
      beta 3^n = 2 beta 3^(n-1) + 3^n
      quad arrow.long.double quad
      beta = 2 beta / 3 + 1
      quad arrow.long.double quad
      beta = 3
    $
    So $a_n^(("p")) = 3^(n+1)$.
  - _General solution:_ $a_n = alpha 2^n + 3^(n+1)$.
  - Using $a_0 = 1$: $1 = alpha + 3$, so $alpha = -2$.
  - The _solution_ is $a_n = 3^(n+1) - 2^(n+1)$.
]



== Recurrences and Generating Functions

Both characteristic equations and generating functions solve the same recurrences --- but from different angles.

#Block(color: yellow)[
  *Key idea.*
  A generating function encodes the _entire sequence_ $(a_n)$ as coefficients of a power series $A(x) = sum a_n x^n$.
  The recurrence turns into an _algebraic equation_ for $A(x)$.
]

#example[
  _Derive_ the generating function for Fibonacci: $F_n = F_(n-1) + F_(n-2)$, $F_0 = 0$, $F_1 = 1$.

  Write $G(x) = F_0 + F_1 x + F_2 x^2 + F_3 x^3 + dots = x + x^2 + 2x^3 + 3x^4 + dots$.

  Multiply by $x$ and $x^2$ to shift indices:
  $
    x G(x) & = \
           & = F_0 x + F_1 x^2 + F_2 x^3 + dots + x^2 G(x) = \
           & = F_0 x^2 + F_1 x^3 + dots
  $

  Since $F_n = F_(n-1) + F_(n-2)$ for $n >= 2$, each coefficient of $G - x G - x^2 G$ vanishes except $F_1 x = x$:
  $
    G(x) - x G(x) - x^2 G(x) = x
    quad arrow.r.double.long quad
    G(x) = x / (1 - x - x^2)
  $
]

Now factor the denominator.
The roots of $1 - x - x^2 = 0$ are:
$
  x = (1 plus.minus sqrt(5)) / (-2)
  quad arrow.r.double.long quad
  x_1 = -1\/phi, \ x_2 = -1\/psi
$
where $phi = (1 + sqrt(5))/2$, $psi = (1 - sqrt(5))/2$.

#Block(color: yellow)[
  *The connection.*
  The denominator $1 - x - x^2$ and the characteristic polynomial $r^2 - r - 1$ differ only by the substitution $x arrow.r 1/r$.
  Setting the denominator to zero gives values of $x$ where the series _diverges_ --- these are the _poles_ of $G(x)$.
  The characteristic roots $r_1, r_2$ are the _reciprocals_ of these poles.
]

Partial fraction decomposition of $G(x)$ then produces exactly Binet's formula:
$
  G(x) = x / (1 - x - x^2)
  = 1/sqrt(5) (1 / (1 - phi x) - 1 / (1 - psi x))
  = 1/sqrt(5) sum_(n=0)^infinity (phi^n - psi^n) x^n
$

#Block(color: blue)[
  *Why two methods?*

  - *Characteristic equations* are mechanical and fast for constant-coefficient recurrences.

  - *Generating functions* reveal combinatorial structure, handle variable coefficients, produce closed forms via partial fractions --- at the cost of more algebra.
]


= Annihilators
#focus-slide()

== Operators

#definition[
  _Operators_ are higher-order functions that transform functions into other functions.

  For example, differential and integral operators $d / (dif x)$ and $integral dif x$ are core operators in calculus.

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
                2 f(n) & = 2 dot 2^n = 2^(n+1) \
                3 f(n) & = 3 dot 2^n \
            shift f(n) & = 2^(n+1) \
          shift^2 f(n) & = 2^(n+2) \
      (shift - 2) f(n) & = shift f(n) - 2f(n) = 2^(n+1) - 2^(n+1) = 0 \
    (shift^2 - 1) f(n) & = shift^2 f(n) - f(n) = 2^(n+2) - 2^n = 3 dot 2^n
  $
]

== Compound Operators

#fancy-box[
  The compound operators can be seen as polynomials in "variable" $shift$.
]

#example[
  The compound operators $shift^2 - 3 shift + 2$ and $(shift - 1)(shift -2)$ are equivalent:
  $
                            "Let" g(n) := & (shift - 2) f(n) = f(n+1) - 2f(n) \
    "Then" (shift - 1) (shift - 2) f(n) = & (shift - 1) g(n) \
                                        = & g(n+1) - g(n) \
                                        = & [f(n+2) - 2f(n-1)] - [f(n+1) - 2f(n)] \
                                        = & f(n+2) - 3f(n+1) + 2f(n) \
                                        = & (shift^2 - 3 shift + 2) f(n) quad YES
  $
]

== Operators Summary

#table(
  columns: 2,
  align: (left, left),
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header([*Operator*], [*Definition*]),
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
  An _annihilator_ of a function $f$ is any non-trivial operator $op(X)$ such that $op(X) f = 0$.
]

#examples[
  - $(shift - 1)$ annihilates any constant $f(n) = c$: $(shift - 1) c = c - c = 0$.
  - $(shift - 2)$ annihilates $f(n) = alpha dot 2^n$: $(shift - 2)(alpha 2^n) = alpha 2^(n+1) - 2 alpha 2^n = 0$.
  - $(shift - 1)^2$ annihilates any linear $f(n) = alpha n + beta$:
    $(shift - 1)(alpha n + beta) = alpha$ (a constant), and $(shift - 1) alpha = 0$.
]

== Annihilators Summary

#table(
  columns: 2,
  align: (left, left),
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header([*Operator*], [*Functions annihilated*]),
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
  + Find the coefficients $alpha,beta$ using $T(0) = 0$ and $T(1) = 2 T(0) + 1 = 1$:

    $display(
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
    )$

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
    $T(n) = alpha (-1)^n + (beta n + gamma) 2^n + delta n^2 + epsilon n + zeta$

  + There are no initial conditions.
    We can only provide an asymptotic bound.

  Thus, $T(n) in Theta(n 2^n)$
]

== Annihilators and Characteristic Equations

Characteristic equations and annihilators are _two notations for the same algebraic structure_.

#theorem[
  For the linear homogeneous recurrence $a_n = c_1 a_(n-1) + c_2 a_(n-2) + dots + c_k a_(n-k)$:

  - *Characteristic polynomial:* $p(r) = r^k - c_1 r^(k-1) - dots - c_k$
  - *Annihilator polynomial:* $p(shift) = shift^k - c_1 shift^(k-1) - dots - c_k$

  If $r_1, dots, r_t$ are the distinct characteristic roots with multiplicities $m_1, dots, m_t$, then
  $
    p(r) = (r - r_1)^(m_1) dots (r - r_t)^(m_t) = p(shift)
  $

  The factorization is identical; only the interpretation differs.
]

#example[
  $a_n = 5 a_(n-1) - 6 a_(n-2)$.

  - *Characteristic:* $r^2 - 5r + 6 = (r - 2)(r - 3) = 0$.
  - *Annihilator:* $(shift - 2)(shift - 3) a_n = 0$.
  - Both give: $a_n = alpha 2^n + beta 3^n$.
]

== Common Mistakes

#example[
  *Problem:* Solve $a_n = 2 a_(n-1) - 2^n$ with $a_0 = 1$.

  *Wrong answer:* "Characteristic equation: $r - 2 = 0$, so $r = 2$. General solution: $a_n = c dot 2^n$."

  *Where's the error?*
  - This is _non-homogeneous_ (has a $-2^n$ term), but the student _ignored it_!
  - We need a _particular_ solution in addition to the homogeneous one.
  - Since $2$ is _also_ the characteristic root (resonance!), the simple trial $beta 2^n$ fails.
    We must try $a_n^(("p")) = beta n dot 2^n$.

  *Correct:* $a_n = (alpha + n) 2^n$. Using $a_0 = 1$: $alpha = 1$, so $a_n = (1 + n) 2^n$.
]

#Block(color: orange)[
  *Lesson:* Before solving, always ask:
  (1) Is it homogeneous or non-homogeneous?
  (2) Is the forcing term's base a characteristic root?
  These two questions prevent the most common errors.
]

== Exercises

#Block(color: blue, width: 100%)[
  *1.* Solve by telescoping: $T(n) = 2 T(n - 1) + n$ with $T(0) = 1$.

  *2.* Solve by characteristic equation: $a_n = 7 a_(n-1) - 10 a_(n-2)$ with $a_0 = 3$ and $a_1 = 11$.

  *3.* Solve $a_n = 4 a_(n-1) - 4 a_(n-2)$ with $a_0 = 1$ and $a_1 = 6$.

  *4.* Solve $a_n = 3 a_(n-1) + 2^n$ with $a_0 = 0$.
]

#Block(color: green, width: 100%)[
  *5.* Count binary strings of length $n$ that do _not_ contain the substring $"00"$.
  Set up the recurrence and solve it.

  *6.* \* Solve $a_n = 5 a_(n-1) - 6 a_(n-2) + 3^n$ with $a_0 = 0$, $a_1 = 1$.
  (Exponential forcing with second-order recurrence.)
]


= Asymptotic Analysis

#focus-slide(
  epigraph: [A mathematician who is not also something of a poet \ will never be a complete mathematician.],
  epigraph-author: "Karl Weierstrass",
)

== Asymptotic Notation

#definition[_Big-O notation_][
  The notation $f in O(g)$ means that the function $f(n)$ is _asymptotically bounded from above_ by the function $g(n)$, up to a constant factor.
  $
    f(n) in O(g(n))
    quad iff quad
    exists c > 0 .thin exists n_0 .thin forall n > n_0 : abs(f(n)) <= c dot g(n)
  $
]

#definition[_Small-o notation_][
  The notation $f in o(g)$ means that the function $f(n)$ is _asympotically dominated_ by $g(n)$, up to a constant factor.
  $
    f(n) in o(g(n))
    quad iff quad
    forall c > 0 .thin exists n_0 .thin forall n > n_0 : abs(f(n)) <= c dot g(n)
  $
]

#note[
  The difference is only in the $exists c$ and $forall c$ quantifier.
]

#note[
  Flip $<=$ to $>=$ in the above definitions to obtain the dual notations: $f in Omega(g)$ and $f in omega(g)$.
]

#definition[_Theta notation_][
  $f in Theta(g)$ iff $f in O(g)$ and $g in O(f)$.
]

== Limits

#table(
  columns: 4,
  align: left,
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header([*Notation*], [*Name*], [*Description*], [*Limit definition*]),
  $f in o(g)$, [Small Oh], [$f$ is dominated by $g$], $ lim_(n to infinity) f(n) / g(n) = 0 $,
  $f in O(g)$, [Big Oh], [$f$ is bounded above by $g$], $ limsup_(n to infinity) abs(f(n)) / g(n) < infinity $,
  $f tilde g$, [Equivalence], [$f$ is asympotically equal to $g$], $ lim_(n to infinity) f(n) / g(n) = 1 $,
  $f in Omega(g)$, [Big Omega], [$f$ is bounded below by $g$], $ liminf_(n to infinity) f(n) / g(n) > 0 $,
  $f in omega(g)$, [Small Omega], [$f$ dominates $g$], $ lim_(n to infinity) f(n) / g(n) = infinity $,
)

== Asymptotic Equivalence

#definition[
  The notation $f tilde g$ means that functions $f(n)$ and $g(n)$ are _asymptotically equivalent_.
  $
    f tilde g
    quad iff quad
    forall epsilon > 0 .thin exists n_0 .thin forall n > n_0 : abs(f(n) / g(n) - 1) <= epsilon
    quad iff quad
    lim_(n to infinity) f(n) / g(n) = 1
  $
]

#note[
  $f tilde g$ and $g tilde f$ are equivalent, since $tilde$ is an equivalence relation.
]

#note[
  $f tilde g$ and $f in Theta(g)$ are _different_ notions!
]

== Properties of Asymptotics

#box[
  $
    f in O(g) "and" f in Omega(g) & quad iff quad f in Theta(g) \
                        f in O(g) & quad iff quad g in Omega(f) \
                        f in o(g) & quad iff quad g in omega(f) \
                        f in o(g) & quad imply quad f in O(g) \
                    f in omega(g) & quad imply quad f in Omega(g) \
                        f tilde g & quad imply quad f in Theta(g) \
  $
]

== Divide-and-Conquer Algorithms Analysis

#image("assets/divide-and-conquer.png")

== Divide-and-Conquer Recurrence

$ T(n) = a dot T(n / b) + f(n) $

- $T(n)$ is the _cost_ of the recursive algorithm
- $a$ is the number of _parts_ (_sub-problems_)
- $n \/ b$ is the _size_ of each part
- $T(n / b)$ is the cost of each _sub-problem_
- $f(n)$ is the cost of _splitting_ and _merging_ the solutions of the subproblems

Hereinafter, $c_"crit" = log_b a$ is a _critical constant_.

== Master Theorem

The master theorem @entley1980 applies to divide-and-conquer recurrences of the form
$ T(n) = a dot T(n / b) + f(n) $

#table(
  columns: 4,
  align: (left, left, center, center),
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header([*Case*], [*Description*], [*Condition*], [*Bound*]),
  [Case I], ["merge" $<<$ "recursion"], [$f(n) in O(n^c)$, $c < c_"crit"$], [$T(n) in Theta(n^(c_"crit"))$],
  [Case II],
  ["merge" $approx$ "recursion"],
  [$f(n) in Theta(n^(c_"crit") log^k n)$, $k >= 0$],
  [$T(n) in Theta(n^(c_"crit") log^(k+1) n)$],

  [Case III], ["merge" $>>$ "recursion"], [$f(n) in Omega(n^c)$, $c > c_"crit"$], [$T(n) in Theta(f(n))$],
)

#note[
  Case III also requires the _regularity condition_ to hold: $a f(n \/ b) <= k f(n)$ for some constant $k < 1$ and all sufficiently large $n$.
]

#note[
  There is an _extended_ Case II, with three sub-cases (IIa, IIb, IIc) for other values of $k$.
  See #link("https://en.wikipedia.org/wiki/Master_theorem_(analysis_of_algorithms)#Generic_form")[wiki].
]

== Examples of Master Theorem Application

#examples[
  Determine the case of Master Theorem and the bound of $T(n)$ for the following recurrences.

  + $T(n) = 3 T(n \/ 9) + sqrt(n)$
  // Case 2
  // T(n) in Theta(n^(1/2) log n)

  + $T(n) = 2 T(n \/ 4) + n^(0.51)$
  // Case 3
  // T(n) in Theta(n^(0.51))

  + $T(n) = 5 T(n \/ 25) + n^(0.49)$
  // Case 1
  // T(n) in Theta(n^0.5)

  + $T(n) = T(floor(n \/ 2)) + T(ceil(n \/ 2))$
  // Case 2 (approximated)
  // T(n) in Theta(n log n)

  + $T(n) = 3 T(n \/ 9) + sqrt(n) \/ (log n)$
  // Case 2b
  // T(n) in Theta(n^(1/2) log log n)

  + $T(n) = 6 T(n \/ 36) + sqrt(n) \/ (log^2 n)$
  // Case 2c
  // T(n) in Theta(n^(1/2))

  + $T(n) = 4 T(n \/ 16) + sqrt(n \/ (log n))$
  // Case 2a
  // T(n) in Theta(n^(1/2) (log n)^(1/2))
]

== Akra--Bazzi Method

The Akra--Bazzi method @akra1998 is a _generalization_ of the master theorem to recurrences of the form
$
  T(n) = f(n) + sum_(i = 1)^k a_i T(b_i n + underbracket(h_i (n), *))
$

- $k$ is a constant
- $a_i > 0$
- $0 < b_i < 1$
- $h_i (n) in O(n / (log^2 n))$ is a _small perturbation_

Bound of $T(n)$ by Akra--Bazzi method:
$
  T(n) in Theta(n^p dot (1 + integral_1^n f(x) / x^(p+1) dif x))
$
where $p$ is the solution for the equation $display(sum_(i = 1)^k a_i b_i^p = 1)$

== Akra--Bazzi Example

#example[
  Suppose the runtime of an algorithm is expressed by the following recurrence relation:
  $
    T(n) = cases(
      1 "for" 0 <= n <= 3,
      n^2 + 7 / 4 T(floor(1 / 2 n)) + T(ceil(3 / 4 n)) "for" n > 3,
    )
  $

  - Note that the Master Theorem _is not_ applicable here, since there are _two_ different recursive terms.
  - Let's apply the Akra--Bazzi method.
    First, solve the equation $7 / 4 (1 / 2)^p + (3 / 4)^p = 1$.
    This gives us $p = 2$.
  - Next, use the formula from AB-method to obtain the bound:
    $
      T(x) & in Theta(x^p (1 + integral_1^x f(u) / u^(p+1) d u)) = \
           & = Theta(x^2 (1 + integral_1^x u^2 / u^3 d u)) = \
           & = Theta(x^2 (1 + ln x)) = \
           & = Theta(x^2 log x)
    $
]


= Advanced Topics

#focus-slide()

== Gamma Function

#definition[
  _Gamma function_ $Gamma(x)$ is the most common _extension_ of the factorial function to real and complex numbers.
  It is defined for all complex numbers $z in CC$ (except non-positive integers) as
  $
    Gamma(z) = integral_0^infinity t^(z - 1) e^(-t) d t
  $
  For positive integers $z = n$, it is defined as
  $
    Gamma(n) = (n - 1)!
  $
]

*Motivation*:
The factorial is defined for positive integers as $n! = 1 dot 2 dot dots dot n = (n - 1)! dot n$.
We want to _extend_ this definition to _all real numbers_ and capture its _recursive_ nature.
Specifically, we seek a smooth function $Gamma(x)$ such that:
- $Gamma(n + 1) = n!$ for all $n in NN$, matching the factorial.
- $Gamma(x + 1) = x dot Gamma(x)$, satisfying a recursive property.
- $Gamma(x)$ is defined for all real numbers $x > 0$.

== Alternative Definitions
$
  Gamma(z) = integral_0^infinity t^(z - 1) e^(-t) d t
$

Gauss proposed a function $Gamma(x)$ defined by the _limit_
$
  Gamma(x) := lim_(n to infinity) (n! dot n^x) / (x dot (x+1) dot dots dot (x+n)) = lim_(n to infinity) (n! dot n^x) / (product_(k = 0)^n (x + k))
  quad "for" x > 0
$

== Integral Definition

$
  Gamma(x) = integral_0^infinity t^(x - 1) e^(-t) d t
$
Let's check that the integral definition is indeed a suitable definition of a gamma function.

$
  Gamma(z + 1) & = integral_0^infinity t^z e^(-t) d t \
               & = [-t^z e^(-t)]_0^infinity + integral_0^infinity z t^(z-1) e^(-t) d t \
               & = lim_(t to infinity) (-t^z e^(-t)) - (-0^z e^(-0)) + z integral_0^infinity t^(z-1) e^(-t) d t
$
#v(-.5em)
Note that $-t^z e^(-t) to 0$ as $t to infinity$, so:
#v(-.5em)
$
  Gamma(z + 1)
  = z integral_0^infinity t^(z-1) e^(-t) d t
  = z dot Gamma(z)
$

== Limit Definition

$
  Gamma(x) = lim_(n to infinity) (n! dot n^x) / (product_(k = 0)^(n) (x + k))
$
Let's check that the limit definition is indeed a suitable definition of a gamma function.

*Step 1*. Write $Gamma(x + 1)$.
$
  Gamma(x + 1)
  = lim_(n to infinity) (n! dot n^(x+1)) / (product_(k = 0)^n (x + 1 + k))
  = lim_(n to infinity) (n! dot n^(x+1)) / (product_(k = 1)^(n + 1) (x + k))
$
*Step 2*. Multiply both numerator and denominator by $x$ and rearrange:
$
  = lim_(n to infinity) (n! dot n^(x+1)) / ((x+1) dot dots dot (x+n+1))
  = lim_(n to infinity) (n! dot n^x) / (x dot (x+1) dot dots dot (x+n)) dot n / (x + n + 1) dot x
$
*Step 3*. Take the limit.
As $n to infinity$, the ratio $n / (x + n + 1)$ approaches $1$.
$
  Gamma(x + 1) = x dot Gamma(x)
$

== Equivalence of Definitions

Let's prove the equivalence of two definitions: integral and limit.

We claim:
$
  integral_0^n t^(x-1) (1 - t / n)^n d t
  eq.quest
  lim_(n to infinity) (n! dot n^x) / (x dot (x + 1) dot dots dot (x + n))
$
Note that as $n to infinity$, the integrand $(1 - t / n)^n$ approaches $e^(-t)$, so this integral approximates $Gamma(x)$.

Substitute $u = t / n$:
$
  integral_0^n t^(x-1) (1 - t / n)^n d t
  = n^x integral_0^1 u^(x-1) (1-u)^n d u
  = n^x dot Beta(x, n + 1)
$
where $Beta(x, n + 1)$ is the Beta function:
$
  Beta(x, y) = integral_0^1 t^(x-1) (1-t)^(y-1) d t = (Gamma(x) dot Gamma(y)) / Gamma(x + y)
$

#pagebreak()

Then:
$
  I_n
  = n^x dot Beta(x, n + 1)
  = n^x dot (Gamma(x) dot Gamma(n + 1)) / Gamma(x + n + 1)
  = (n! dot n^x) / (x dot (x + 1) dot dots dot (x + n))
$

Take the limit on both sides.
Since $display(lim_(n to infinity) I_n = Gamma(x))$, we have:
$
  Gamma(x) = lim_(n to infinity) (n! dot n^x) / (x dot (x + 1) dot dots dot (x + n))
$

== Gamma Function Applications

The Gamma function provides closed forms for several important combinatorial expressions.

- *Factorial extension:*
  $
    n! = Gamma(n + 1), quad e.g. thin Gamma(1 slash 2) = sqrt(pi)
  $
  Extends factorial to non-integer arguments.

- *Generalized binomial coefficients* (for arbitrary $r in RR$):
  $
    binom(r, k) = Gamma(r + 1) / (Gamma(k + 1) dot Gamma(r - k + 1))
  $
  This is the definition underlying Newton's Binomial Theorem for real exponents.

- *Stirling's approximation:*
  $
    n! = Gamma(n + 1) approx sqrt(2 pi n) thin (n / e)^n quad "as" n to infinity
  $
  Useful for estimating $binom(2n, n)$, entropy bounds, and worst-case algorithm analysis.

- *Beta function:*
  $
    Beta(x, y) = (Gamma(x) Gamma(y)) / Gamma(x + y) = integral_0^1 t^(x-1) (1-t)^(y-1) d t
  $

#Block(color: yellow)[
  $Gamma$ shows up whenever factorials, binomial coefficients, or power series hit non-integer parameters: probability distributions (Beta, Gamma, Student's $t$), analytic combinatorics, and elsewhere.
]


== Bibliography
#bibliography("refs.yml")

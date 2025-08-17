#import "theme.typ": *
#show: slides.with(
  title: [Set Theory],
  subtitle: "Discrete Math",
  date: "Fall 2025",
  authors: "Konstantin Chukharev",
  // dark: true,
)

#show table.cell.where(y: 0): strong

#set quote(block: true)
#show quote: set par(justify: false)
#show quote: set align(left)

#let iff = symbol(math.arrow.double.l.r.long, ("not", math.arrow.double.l.r.not))
#let power(x) = $cal(P)(#x)$
#let pair(a, b) = $angle.l #a, #b angle.r$
#let rel(x) = math.class("relation", x)
#let nrel(x) = rel(math.cancel(x))
#let Dom = math.op("Dom")
#let Cod = math.op("Cod")
#let Range = math.op("Range")
#let equinumerous = symbol(math.approx, ("not", math.approx.not))
#let smaller = symbol(math.prec, ("eq", math.prec.eq))
#let Join = math.or
#let Meet = math.and
#let nand = $overline(and)$
#let nor = $overline(or)$

#let Green(x) = text(green.darken(20%), x)
#let Red(x) = text(red.darken(20%), x)
#let Blue(x) = text(blue.darken(20%), x)

#let True = Green(`true`)
#let False = Red(`false`)

#let YES = Green(sym.checkmark)
#let NO = Red(sym.crossmark)

#show heading.where(level: 1): none

= Set Theory
#focus-slide(
  epigraph: [A set is a Many that allows itself to be thought of as a One.],
  epigraph-author: "Georg Cantor",
  scholars: (
    (
      name: "Georg Cantor",
      image: image("assets/Georg_Cantor.jpg"),
    ),
    (
      name: "Richard Dedekind",
      image: image("assets/Richard_Dedekind.jpg"),
    ),
    (
      name: "Bertrand Russell",
      image: image("assets/Bertrand_Russell.jpg"),
    ),
    (
      name: "Ernst Zermelo",
      image: image("assets/Ernst_Zermelo.jpg"),
    ),
    (
      name: "Abraham Fraenkel",
      image: image("assets/Abraham_Fraenkel.jpg"),
    ),
  ),
)

== Introduction

Set theory provides a foundational language for all of mathematics.
_Everything_ from numbers and functions to spaces and relations can be defined using _sets_.
This lecture introduces the basic objects and operations of set theory and explores their deep structural and logical consequences.

Topics include:
- Basic concepts: elements, subsets, operations
- Relations and functions as sets
- Infinite sets and cardinality
- Axiomatic foundations
- Applications in logic and computer science

== Basic Notions

#definition[
  A _set_ is an unordered collection of distinct objects, called _elements_.

  - In _naïve_ set theory, sets can contain _any_ objects (including non-sets, called _urelements_).
  - In modern _axiomatic_ set theory, _everything is a set_ (no urelements).
]

#example[
  $A = {5, #emoji.koala, #emoji.bird}$ is a set of three elements: the number 5, a koala, and a birb.
]

*Notation:* $a in A$ means "$a$ is _an element of_ $A$".

#example[
  "$#emoji.koala in A$" is #True, while "$#emoji.penguin in A$" is #False, denoted as "$#emoji.penguin notin A$".
]

#definition[Extensionality][
  Two sets are _equal_, denoted $A = B$, if they have the same elements, that is, iff every element of $A$ is also in $B$, and vice versa.
  Formally, $A = B$ iff $A subset.eq B$ and $B subset.eq A$.
]

#example[
  ${a, b, b} = {a, b} = {b, a} = {b, a, b}$, all these denote the same set with elements $a$ and $b$.
]

== Set-Builder Notation

#definition[
  A set can be defined using _set-builder notation_ (_set comprehension_):
  $ A = { x | P(x) } $
  meaning "the set of all $x$ such that the property $P(x)$ holds".
]

#example[
  $A = { x | x in NN and x > 5 }$ is the set of natural numbers greater than 5, that is, $A = {6, 7, 8, dots}$.
]

#example[
  $S = { x^2 | x "is prime" } = {4, 9, 25, 49, dots}$ is the set of squares of prime numbers#footnote[*Note:* $1$ _is not_ a prime number.].
]

#example[
  $QQ = { a "/" b | a in ZZ, b in NN, b != 0 }$ is the set of rational numbers (fractions).
]

== Subsets

#definition[
  A set $A$ is a _subset_ of $B$, denoted $A subset.eq B$, if every element of $A$ is also an element of $B$.
  - Formally, $A subset.eq B iff forall x. thin (x in A) imply (x in B)$.
  - If $A$ is not a subset of $B$, we write $A subset.eq.not B$.
  - If $A subset.eq B$ and $A neq B$, we say $A$ is a _proper (or strict) subset_ of $B$, denoted $A subset B$ or $A subset.neq B$.
  - If $A$ is a subset of $B$, denoted $A subset.eq B$, then $B$ is a _superset_ of $A$, denoted $B supset.eq A$.
]

#example[
  Every set is a subset of itself: $A subset.eq A$.
]
#example[
  The empty set is a subset of every set: $emptyset subset.eq A$ for any set $A$.
]
#example[
  The set of even numbers is a proper subset of the set of integers: $ZZ_"even" subset ZZ$.
]
#example[
  ${a,b} subset.eq {a,b,c}$, but ${a,b,x} subset.eq.not {a,b,c}$.
]
#example[
  ${0} in {0, {0}}$ _and_ ${0} subset.eq {0, {0}}$, that is, ${0}$ is an element, and also a subset.
]

// TODO: visualize subsets using Euler diagrams (nested circles)

== Power Sets

#definition[
  The _power set_ of a set $A$, denoted $2^A$ or $power(A)$, is the set of all subsets of $A$.
  $ power(A) = { S | S subset.eq A } $
]

#example[
  If $A = {a, b}$, then $power(A) = {emptyset, {a}, {b}, {a, b}}$.
]
#example[
  If $A = {1, 2, 3}$, then $power(A) = {emptyset, {1}, {2}, {3}, {1, 2}, {1, 3}, {2, 3}, {1, 2, 3}}$.
]
#example[
  The power set of the empty set is $power(emptyset) = {emptyset}$, a _non-empty_ set containing the empty set.
]

#theorem[
  $abs(power(A)) = 2^abs(A)$ for any finite set $A$.
]

#proof[(combinatorial)][
  For each of the $n$ elements in the set, we can either include it in a subset or not.
  These $n$ independent binary choices yield $2^n$ possible subsets by the multiplication principle.
  #place(center)[
    $ underbrace(2 times 2 times dots times 2, n " times") = 2^n $
  ]
]

#pagebreak()

#proof[
  By _induction_ on $n = abs(A)$, the cardinality of the set $A$.

  *Base case:*
  If $n = 0$, then $A = emptyset$ and $power(A) = {emptyset}$.
  Thus, $abs(power(A)) = 1 = 2^0$.

  *Inductive step:*
  Assume the formula holds for any set of size $k$.
  Let $A$ be a set with $abs(A) = k+1$.
  Choose an arbitrary element $a in A$ and let $A' = A setminus {a}$, so $abs(A') = k$.

  The power set $power(A)$ can be partitioned into two _disjoint_ collections:
  + Subsets of $A$ that _do not_ contain $a$.
    This collection is exactly $power(A')$.
    By the inductive hypothesis, it has $abs(power(A')) = 2^k$ elements.
  + Subsets of $A$ that _do_ contain $a$.
    Each such subset is of the form $S union {a}$ where $S subset.eq A'$.
    This establishes a bijection with $power(A')$, so this collection also has $2^k$ elements.

  The total number of subsets of $A$ is the _sum_ of their sizes: $abs(power(A)) = 2^k + 2^k = 2 dot 2^k = 2^(k+1)$.
]

== Hasse Diagram of Power Set

The elements of the power set of ${a, b, c}$ ordered with respect to inclusion ($subset.eq$):

#align(center)[
  #import fletcher: diagram, edge, node
  #let myblob(pos, label, ..args) = blob(
    pos,
    label,
    tint: green,
    outset: 1pt,
    ..args,
  )
  #diagram(
    spacing: (1cm, 1cm),
    edge-stroke: .8pt,
    node-corner-radius: 2pt,
    myblob((0, 0), ${a,b,c}$, name: <s123>),
    myblob((-1, 1), ${a, b}$, name: <s12>),
    myblob((0, 1), ${a, c}$, name: <s13>),
    myblob((1, 1), ${b, c}$, name: <s23>),
    myblob((-1, 2), ${a}$, name: <s1>),
    myblob((0, 2), ${b}$, name: <s2>),
    myblob((1, 2), ${c}$, name: <s3>),
    myblob((0, 3), $emptyset$, name: <s0>),
    edge(<s12>, <s123>, "-}>"),
    edge(<s13>, <s123>, "-}>"),
    edge(<s23>, <s123>, "-}>"),
    edge(<s1>, <s12>, "-}>"),
    edge(<s1>, <s13>, "-}>"),
    edge(<s2>, <s12>, "-}>"),
    edge(<s2>, <s23>, "-}>"),
    edge(<s3>, <s13>, "-}>"),
    edge(<s3>, <s23>, "-}>"),
    edge(<s0>, <s1>, "-}>"),
    edge(<s0>, <s2>, "-}>"),
    edge(<s0>, <s3>, "-}>"),
  )
]

== Some Important Sets

#example[
  $NN = {0, 1, 2, dots}$ is the set of natural numbers.
]
#example[
  $ZZ = {dots, -2, -1, 0, 1, 2, dots}$ is the set of integers.
]
#example[
  $QQ = { a "/" b | a in ZZ, b in NN, b != 0 }$ is the set of rational numbers.
]
#example[
  $RR = (-infinity, +infinity)$ is the set of real numbers (the continuum).
]
#example[
  $BB = {0, 1}$ is the set of Boolean values (truth values).
]

#example[
  The set $A^*$ of _finite strings_ over an alphabet $A$ is defined as:
  $
    A^* = {epsilon} union { a_1 a_2 dots a_n | n in NN, a_i in A } = union.big_(n in NN) A^n
  $
  For example, $BB^* = { epsilon, 0, 1, 00, 01, 10, 11, 001, 010, 011, 100, 101, 110, 111, 0000, dots }$.
]

#example[
  The set $A^omega$ of _infinite sequences_ over $A$.
]

== Operations on Sets

// TODO: visualize set operations using Venn diagrams (overlapping circles)

#table(
  columns: 3,
  align: (left, right, left),
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header([Operation], [Notation], [Formal definition]),
  [Union], $A union B$, ${ x | x in A or x in B }$,
  [Intersection], $A intersect B$, ${ x | x in A and x in B }$,
  [Difference], $A setminus B$, ${ x | x in A and x notin B }$,
  [Symmetric diff.], $A triangle B$, $(A setminus B) union (B setminus A)$,
  [Complement], [$overline(A)$ or $A^c$], ${ x | x notin A }$,
  [Power set], [$2^A$ or $power(A)$], ${ S | S subset.eq A }$,
)

== Tuples and Ordered Pairs

#definition[
  A _tuple_ is an ordered collection of elements, denoted $(a_1, a_2, dots, a_n)$.

  A tuple of length $n$ is called an _n-tuple_.
]

#example[
  $(42, #emoji.crab, #emoji.cat.face.angry, #emoji.kiwi)$ is a 4-tuple.
]

#definition[
  An ordered pair $pair(a, b)$ is a special 2-tuple, defined#footnote[Kuratowski's definition is the most cited and now-accepted definition of an ordered pair. For others, see #link("https://en.wikipedia.org/wiki/Ordered_pair#Defining_the_ordered_pair_using_set_theory")[wiki].] as:
  $ pair(a, b) eq.def { {a}, {a, b} } $
]

#example[
  $pair(#emoji.pumpkin, #emoji.mage) != pair(#emoji.mage, #emoji.pumpkin)$, these are different ordered pairs.
]

#example[
  $pair(#emoji.cactus, #emoji.cactus) != (#emoji.cactus,) != #emoji.cactus != {#emoji.cactus}$, these are all different objects: an ordered pair, a 1-tuple, an~urelement, and a singleton~set.
  Note, however, that $pair(#emoji.cactus, #emoji.cactus) = {{#emoji.cactus}}$.
]

== Cartesian Product

#definition[
  The _Cartesian product_ of two sets $A$ and $B$, denoted $A times B$, is defined as:
  $ A times B = { pair(a, b) | a in A "and" b in B } $
]

#example[
  If $A = {1, 2}$ and $B = {x, y, z}$, then their product is
  $ A times B = { pair(1, x), pair(1, y), pair(1, z), pair(2, x), pair(2, y), pair(2, z) } $
]

#definition[
  The _n-fold Cartesian product_ (also known as the _Cartesian power_) of a set $A$ is defined as:
  $ A^n = underbrace(A times A times dots times A, n "times") = { (a_1, a_2, dots, a_n) | a_i in A } $
]

#example[
  ${a, b}^3 = { (a,a,a), (a,a,b), (a,b,a), (a,b,b), (b,a,a), (b,a,b), (b,b,a), (b,b,b) }$
]

#example[
  ${#emoji.eagle}^3 = { (#emoji.eagle, #emoji.eagle, #emoji.eagle) }$, the singleton set containing the 3-tuple of three eagles.
]

#example[
  $A^0 = { () }$, the singleton set containing the empty tuple.
]

// Recursively, #strike("ab")using the Kuratowski's definition and extending $n$-tuples to pairs as $(x, y, z) = pair(pair(x, y), z)$:
// - $A^1 = A$
// - $A^(k + 1) = A^k times A$

== Geometric Interpretation of Cartesian Product

// The Cartesian product $A times B$ can be visualized as a region on the coordinate plane, where each point $pair(a, b)$ represents an element of the product.

#place(bottom)[
  #import cetz: draw

  #let draw-grid(max-x, max-y) = {
    draw.grid(
      (0, 0),
      (max-x + 0.3, max-y + 0.3),
      stroke: gray + 0.4pt,
    )
  }
  #let draw-x-axis(max-x) = {
    draw.line((-0.3, 0), (max-x + 0.7, 0), name: "x-axis", mark: (end: "stealth", fill: black))
    draw.content("x-axis.end", [$x$], anchor: "north", padding: 0.1)
    for x in range(1, max-x + 1) {
      draw.line((x, -0.1), (x, 0.1), stroke: 0.5pt)
      draw.content((x, 0), [#x], anchor: "north", padding: 0.2)
    }
  }
  #let draw-y-axis(max-y) = {
    draw.line((0, -0.3), (0, max-y + 0.7), name: "y-axis", mark: (end: "stealth", fill: black))
    draw.content("y-axis.end", [$y$], anchor: "east", padding: 0.1)
    for y in range(1, max-y + 1) {
      draw.line((-0.1, y), (0.1, y), stroke: 0.5pt)
      draw.content((0, y), [#y], anchor: "east", padding: 0.2)
    }
  }
  #let draw-origin() = {
    draw.content((0, 0), [0], anchor: "north-east", padding: 0.2)
  }

  // First plot: Simple interval product
  #cetz.canvas(baseline: (0, 0), {
    let max-x = 5
    let max-y = 4

    // Draw the grid and axes
    draw-grid(max-x, max-y)
    draw-x-axis(max-x)
    draw-y-axis(max-y)
    draw-origin()

    // Set A: [1, 4) on x-axis
    draw.line((1, -0.7), (4, -0.7), stroke: 3pt + blue)
    draw.circle((1, -0.7), radius: 0.08, fill: blue, stroke: 1.5pt + blue) // closed at 1
    draw.circle((4, -0.7), radius: 0.08, fill: white, stroke: 1.5pt + blue) // open at 4
    draw.content((2.5, -0.7), text(fill: blue)[$A = \[1; 4\)$], anchor: "north", padding: 0.2)

    // Set B: (2, 4] on y-axis
    draw.line((-0.7, 2), (-0.7, 4), stroke: 3pt + blue)
    draw.circle((-0.7, 2), radius: 0.08, fill: white, stroke: 1.5pt + blue) // open at 2
    draw.circle((-0.7, 4), radius: 0.08, fill: blue, stroke: 1.5pt + blue) // closed at 4
    draw.content((-0.9, 3), text(fill: blue)[$B = \(2; 4\]$], angle: 90deg, anchor: "south")

    // Cartesian product A × B (filled rectangle)
    draw.rect((1, 2), (4, 4), fill: blue.transparentize(80%), stroke: none)

    // Boundary of A × B
    draw.line((1, 4), (4, 4), stroke: (paint: blue, thickness: 2pt)) // top
    draw.line((4, 4), (4, 2), stroke: (paint: blue, thickness: 2pt, dash: "dashed")) // right
    draw.line((4, 2), (1, 2), stroke: (paint: blue, thickness: 2pt, dash: "dashed")) // bottom
    draw.line((1, 2), (1, 4), stroke: (paint: blue, thickness: 2pt)) // left

    // Corner points
    draw.circle((1, 4), radius: 0.08, fill: blue, stroke: 2pt + blue) // (1,4) included
    draw.circle((4, 4), radius: 0.08, fill: white, stroke: 2pt + blue) // (4,4) excluded
    draw.circle((4, 2), radius: 0.08, fill: white, stroke: 2pt + blue) // (4,2) excluded
    draw.circle((1, 2), radius: 0.08, fill: white, stroke: 2pt + blue) // (1,2) excluded

    // Label
    draw.content((2.5, 3), $A times B$, frame: "rect", stroke: none, fill: blue.transparentize(80%), padding: 0.1)
    draw.content((3, 4.5), $#text(blue)[$A times B$] = \[1, 4\) times \(2, 4\]$)
  })
  #h(1fr)
  // Second plot: Set difference of products
  #cetz.canvas(baseline: (0, 0), {
    let max-x = 5
    let max-y = 4

    // Draw the grid and axes
    draw-grid(max-x, max-y)
    draw-x-axis(max-x)
    draw-y-axis(max-y)
    draw-origin()

    // Set A: (1, 5] on x-axis
    draw.line((1, -0.7), (5, -0.7), stroke: 3pt + blue)
    draw.circle((1, -0.7), radius: 0.08, fill: white, stroke: 1.5pt + blue) // open at 1
    draw.circle((5, -0.7), radius: 0.08, fill: blue, stroke: 1.5pt + blue) // closed at 5
    draw.content((3.2, -0.7), text(fill: blue)[$A = \(1; 5\]$], anchor: "north-west", padding: 0.2)

    // Set B: (1, 4] on y-axis
    draw.line((-0.7, 1), (-0.7, 4), stroke: 3pt + blue)
    draw.circle((-0.7, 1), radius: 0.08, fill: white, stroke: 1.5pt + blue) // open at 1
    draw.circle((-0.7, 4), radius: 0.08, fill: blue, stroke: 1.5pt + blue) // closed at 4
    draw.content((-0.7, 3.2), text(fill: blue)[$B = \(1; 4\]$], angle: 90deg, anchor: "south-west", padding: 0.2)

    // Set C: [2, 3] on x-axis (second level)
    draw.line((2, -1.1), (3, -1.1), stroke: 3pt + orange)
    draw.circle((2, -1.1), radius: 0.08, fill: orange, stroke: 1.5pt + orange) // closed at 2
    draw.circle((3, -1.1), radius: 0.08, fill: orange, stroke: 1.5pt + orange) // closed at 3
    draw.content((2.5, -1.1), text(fill: orange)[$C = \[2; 3\]$], anchor: "north", padding: 0.2)

    // Set D: (2, 3) on y-axis (second level)
    draw.line((-1.1, 2), (-1.1, 3), stroke: 3pt + orange)
    draw.circle((-1.1, 2), radius: 0.08, fill: white, stroke: 1.5pt + orange) // open at 2
    draw.circle((-1.1, 3), radius: 0.08, fill: white, stroke: 1.5pt + orange) // open at 3
    draw.content((-1.1, 2.5), text(fill: orange)[$D = \(2; 3\)$], angle: 90deg, anchor: "south", padding: 0.2)

    // A × B (outer rectangle)
    draw.rect((1, 1), (5, 4), fill: blue.transparentize(80%), stroke: none)

    // C × D (inner rectangle)
    draw.rect((2, 2), (3, 3), fill: white, stroke: none)

    // Outer boundary
    draw.line((1, 4), (5, 4), stroke: 2pt + blue) // top
    draw.line((5, 4), (5, 1), stroke: 2pt + blue) // right
    draw.line((5, 1), (1, 1), stroke: (thickness: 2pt, paint: blue, dash: "dashed")) // bottom
    draw.line((1, 1), (1, 4), stroke: (thickness: 2pt, paint: blue, dash: "dashed")) // left

    // Inner boundary (hole)
    draw.line((2, 2), (3, 2), stroke: 2pt + orange) // bottom
    draw.line((3, 2), (3, 3), stroke: (thickness: 2pt, paint: orange, dash: "dashed")) // right
    draw.line((3, 3), (2, 3), stroke: 2pt + orange) // top
    draw.line((2, 3), (2, 2), stroke: (thickness: 2pt, paint: orange, dash: "dashed")) // left

    // Corner points for outer rectangle
    draw.circle((5, 4), radius: 0.08, fill: blue, stroke: 1.5pt + blue) // (5,4) included
    draw.circle((5, 1), radius: 0.08, fill: white, stroke: 1.5pt + blue) // (5,1) excluded
    draw.circle((1, 1), radius: 0.08, fill: white, stroke: 1.5pt + blue) // (1,1) excluded
    draw.circle((1, 4), radius: 0.08, fill: white, stroke: 1.5pt + blue) // (1,4) excluded

    // Corner points for inner rectangle
    draw.circle((2, 2), radius: 0.08, fill: orange, stroke: 1.5pt + orange) // (2,2) included
    draw.circle((3, 2), radius: 0.08, fill: orange, stroke: 1.5pt + orange) // (3,2) included
    draw.circle((3, 3), radius: 0.08, fill: orange, stroke: 1.5pt + orange) // (3,3) included
    draw.circle((2, 3), radius: 0.08, fill: orange, stroke: 1.5pt + orange) // (2,3) included

    // Label
    draw.content(
      (3, 3.5),
      $(A times B) setminus (C times D)$,
      frame: "rect",
      stroke: none,
      fill: blue.transparentize(80%),
      padding: 0.1,
    )
    draw.content(
      (3.5, 4.8),
      $#text(blue)[$(A times B)$] setminus #text(orange)[$(C times D)$] =\ (\(1; 5\] times \(1; 4\]) setminus (\[2; 3\] times \(2; 3\))$,
    )
  })
]

== Russell’s Paradox

#place(right)[
  #grid(
    columns: 1,
    align: right,
    column-gutter: 1em,
    row-gutter: 0.5em,
    link("https://en.wikipedia.org/wiki/Bertrand_Russell", box(
      radius: 5pt,
      clip: true,
      stroke: 1pt + blue.darken(20%),
      image("assets/Bertrand_Russell.jpg", height: 3cm),
    )),
    [Bertrand Russell],
  )
]

Suppose a set can be either _"normal"_ or _"unusual"_.
- A set is considered _normal_ if it does _not contain itself_ as an element. That is, $A notin A$.
- Otherwise, it is _unusual_. That is, $A in A$.

*Note:* being "normal" or "unusual" is a predicate $P(x)$ that can be applied to any set $x$.

Consider the set $R$ of _all normal sets_: $R = { A | A notin A }$.

The paradox arises when we ask: #strong[Is $R$ a normal set?]
- Suppose $R$ is _normal_. By its definition, $R$ must be an element of $R$, so $R in R$. But elements of $R$ are normal sets, and normal sets do not contain themselves. So $R notin R$. Contradiction.
- Suppose $R$ is _unusual_. This means $R$ contains itself, so $R in R$. But the definition of $R$ only includes sets that do _not_ contain themselves. So $R$ cannot be a member of $R$, i.e. $R notin R$. Contradiction.

A contradiction is reached in both cases. The only possible conclusion is that #strong[the set $R$ cannot exist].

This paradox showed that _unrestricted comprehension_ --- the ability to form a set from any arbitrary property --- is logically inconsistent.

= Relations
#focus-slide(
  epigraph: [In mathematics you don't understand things. You just get used to them.],
  epigraph-author: "John von Neumann",
  scholars: (
    (
      name: "René Descartes",
      image: image("assets/Rene_Descartes.jpg"),
    ),
    (
      name: "Évariste Galois",
      image: image("assets/Evariste_Galois.jpg"),
    ),
    (
      name: "Ernst Schröder",
      image: image("assets/Ernst_Schroeder.jpg"),
    ),
    (
      name: "Michael Rabin",
      image: image("assets/Michael_Rabin.jpg"),
    ),
    (
      name: "Herbert Wilf",
      image: image("assets/Herbert_Wilf.jpg"),
    ),
  ),
)

== Relations as Sets

#definition[
  A _binary relation_ $R$ on sets $A$ and $B$ is a subset of the Cartesian product $A times B$.
]

*Notation:*
If $R subset.eq A times B$, we write "$a rel(R) b$" to mean that element $a in A$ is _related_ to element $b in B$.

Formally, $a rel(R) b$ iff $pair(a, b) in R$.

*Note:* $R$ is used to denote both the relation itself ($a rel(R) b$) _and_ the set of pairs ($R subset.eq A times B$).

*Note:* the _order_ of elements in the pair _matters_: $pair(a, b) in R$ denotes that $a$ is related to $b$, not the other way around, unless there is _another_ pair $pair(b, a)$ in the relation.

#example[
  $R = { pair(n, k) | n, k in NN "and" n < k }$
]

#definition[
  A binary relation $R subset.eq A times B$ on two different sets $A$ and $B$ is called _heterogeneous_.
]
#definition[
  A binary relation $R subset.eq M^2$ on the same set $M$ is called _homogeneous_.
]

/*

== examples

#cetz.canvas({
  import cetz.draw: *

  circle((0, 0), radius: (1, 2))
  circle((3, 0), radius: (1, 2))

  line((0, 1), (3, -1))
  line((0, 1), (3, 1))
  line((0, 0), (3, 0))
  line((0, 0), (3, -1))
  line((0, -1), (3, -1))

  circle((0, 0), radius: 0.1, fill: white)
  circle((0, 1), radius: 0.1, fill: white)
  circle((0, -1), radius: 0.1, fill: white)

  circle((3, 0), radius: 0.1, fill: white)
  circle((3, 1), radius: 0.1, fill: white)
  circle((3, -1), radius: 0.1, fill: white)
})

*/

== Properties of Homogeneous Relations

#definition[
  A relation $R subset.eq M^2$ is _reflexive_ if every element is related to itself:
  $ forall x in M. thin (x rel(R) x) $
]
#definition[
  A relation $R subset.eq M^2$ is _symmetric_ if for every pair of elements, if one is related to the other, then the reverse is also true:
  $ forall x, y in M. thin (x rel(R) y) imply (y rel(R) x) $
]
#definition[
  A relation $R subset.eq M^2$ is _transitive_ if for every three elements, if the first is related to the second, and the second is related to the third, then the first is also related to the third:
  $ forall x, y, z in M. thin (x rel(R) y and y rel(R) z) imply (x rel(R) z) $
]

== More Properties

#definition[
  A relation $R subset.eq M^2$ is _irreflexive_ if no element is related to itself:
  $ forall x in M. thin (x nrel(R) x) $
]
#definition[
  A relation $R subset.eq M^2$ is _antisymmetric_ if for every pair of elements, if both are related to each other, then they must be equal:
  $ forall x, y in M. thin (x rel(R) y and y rel(R) x) imply (x = y) $
]
#definition[
  A relation $R subset.eq M^2$ is _asymmetric_ if for every pair of elements, if one is related to the other, then the reverse is not true:
  $ forall x, y in M. thin (x rel(R) y) imply (y nrel(R) x) $
]

#note[
  _irreflexive_ + _antisymmetric_ = _asymmetric_.
]

== Equivalence Relations

#definition[
  A relation $R subset.eq M^2$ is an _equivalence relation_ if it is reflexive, symmetric and transitive.
]

#definition[
  Let $R subset.eq M^2$ be an equivalence relation on a set $M$.
  The _equivalence class_ of an element $x in M$ under $R$ is the set of all elements related to $x$:
  $ [x]_R = { y in M | x rel(R) y } $
]

#definition[
  The _quotient set_ of $M$ by the equivalence relation $R$ is the set of all equivalence classes:
  $ M slash_R = { [x]_R | x in M } $
]

#theorem[
  If $R subset.eq M^2$ is an equivalence relation, then $x rel(R) y$ iff $[x]_R = [y]_R$ for all $x, y in M$.
]

== Partitions

#definition[
  A _partition_ $cal(P)$ of a set $M$ is a family of non-empty, pairwise-disjoint subsets whose union is $M$:
  - (Non-empty) $forall B in cal(P). thin (B != emptyset)$
  - (Disjoint) $forall B_1, B_2 in cal(P). thin (B_1 != B_2) imply (B_1 intersect B_2 = emptyset)$
  - (Cover) $limits(union.big)_(B in cal(P)) B = M$

  Elements of $cal(P)$ are _blocks_ (or _cells_).
]

#example[
  For $M = {0,1,2,3,4,5}$: ${{0,2,4},{1,3,5}}$ (even / odd) and ${{0,5},{1,2,3},{4}}$ (arbitrary) are partitions.
]
// TODO: visualize partitions from the example

== Partitions and Equivalence Relations

#theorem[Equivalences $<=>$ Partitions][
  Each equivalence relation $R$ on $M$ yields the partition #box[$cal(P)_R = { [x]_R | x in M }$].
  Each partition $cal(P)$ yields an equivalence $R_cal(P)$ given by $x R_cal(P) y$ iff $x,y$ lie in the same block.
  These constructions invert one another.
]

#proof[(Sketch)][
  Classes of an equivalence are non-empty, disjoint, and cover $M$.
  Conversely "same block" relation is reflexive, symmetric, transitive.
  Composing the two constructions returns exactly the starting equivalence relation or partition (they are mutually inverse up to equality of sets of ordered pairs).
]

== Orders

#definition[
  A relation $R subset.eq M^2$ is called a _preorder_ if it is reflexive and transitive.
]
#definition[
  A _partial order_ is a relation $R subset.eq M^2$ that is reflexive, antisymmetric, and transitive.
]
#definition[
  A relation $R subset.eq M^2$ is _connected_ if for every pair of distinct elements, either one is related to the other or vice versa:
  $ forall x, y in M. thin (x neq y) imply (x rel(R) y or y rel(R) x) $
]
#definition[
  A partial order which is also connected is called a _total order_ (or _linear order_).
]

== Examples of Orders

#example[
  Consider the _no longer than_ relation $prec.curly.eq$ on $BB^*$: $x prec.curly.eq y$ iff $"len"(x) <= "len"(y)$.
  This is a preorder (reflexive and transitive), and even connected, but not a partial order, since it is not antisymmetric: for example, $01 prec.curly.eq 10$ and $10 prec.curly.eq 01$, but $01 neq 10$.
]

#example[
  The subset relation $subset.eq$ on $power(A)$ is a partial order (reflexive, antisymmetric, transitive); typically not total, since not all subsets are comparable (e.g., $A = {1}$ and $B = {2, 3}$).
]

#example[
  Divisibility $|$ on $D = {1,2,3,6}$: $1|2|6$, $1|3|6$; $2$ and $3$ incomparable. Partial, not total.
]

#example[
  Lexicographic order on $A^n$ (induced by a total order on $A$) is a total order.
]

== Composition of Relations

#definition[
  The _composition_ of two relations $R subset.eq A times B$ and $S subset.eq B times C$ is defined as:
  $
    R rel(";") S = S compose R = { pair(a, c) | exists b in B. thin (a rel(R) b) and (b rel(S) c) }
  $
]

// TODO: composition power
// TODO: examples
// TODO: visualize

== Associativity of Composition

#theorem[
  Composition of relations is associative:
  $(R rel(";") S) rel(";") T = R rel(";") (S rel(";") T)$.
]

#proof[
  Let $R subset.eq A times B$, $S subset.eq B times C$, and $T subset.eq C times D$ be three relations.

  *($subset.eq$):*
  Let $pair(a, d) in (R rel(";") S) rel(";") T$.
  - By definition of composition:
    $exists c in C. thin (pair(a, c) in R rel(";") S) and (pair(c, d) in T)$.
  - Since $pair(a, c) in (R rel(";") S)$, we have:
    $exists b in B. thin (pair(a, b) in R) and (pair(b, c) in S)$.
  - From $pair(b, c) in S$ and $pair(c, d) in T$, we have:
    $pair(b, d) in S rel(";") T$.
  - From $pair(a, b) in R$ and $pair(b, d) in S rel(";") T$, we have:
    $pair(a, d) in R rel(";") (S rel(";") T)$.

  *($supset.eq$):*
  Let $pair(a, d) in R rel(";") (S rel(";") T)$.
  - By definition of composition:
    $exists b in B. thin (pair(a, b) in R) and (pair(b, d) in S rel(";") T)$.
  - Since $pair(b, d) in S rel(";") T$, we have:
    $exists c in C. thin (pair(b, c) in S) and (pair(c, d) in T)$.
  - From $pair(a, b) in R$ and $pair(b, c) in S$, we have:
    $pair(a, c) in R rel(";") S$.
  - From $pair(a, c) in R rel(";") S$ and $pair(c, d) in T$, we have:
    $pair(a, d) in (R rel(";") S) rel(";") T$.

  Therefore, $(R rel(";") S) rel(";") T = R rel(";") (S rel(";") T)$.
]


= Functions
#focus-slide(
  epigraph: [A function is a machine which converts a certain class of inputs \ into a certain class of outputs.],
  epigraph-author: "Norbert Wiener",
  scholars: (
    (
      name: "Leonhard Euler",
      image: image("assets/Leonhard_Euler.jpg"),
    ),
    (
      name: "Augustin-Louis Cauchy",
      image: image("assets/Augustin-Louis_Cauchy.jpg"),
    ),
    (
      name: "Karl Weierstrass",
      image: image("assets/Karl_Weierstrass.jpg"),
    ),
    (
      name: "Joseph-Louis Lagrange",
      image: image("assets/Joseph-Louis_Lagrange.jpg"),
    ),
    (
      name: "George Pólya",
      image: image("assets/George_Polya.jpg"),
    ),
    (
      name: "Norbert Wiener",
      image: image("assets/Norbert_Wiener.jpg"),
    ),
  ),
)

== Definition of a Function

#definition[
  A _function_ $f$ from a set $A$ to a set $B$, denoted $f: A to B$, is a special kind of relation $f subset.eq A times B$ where every element of $A$ is paired with _exactly one_ element of $B$.

  This means two conditions must hold:
  + _Functional (left-total)_:
    For every $a in A$, there is _at least one_ pair $pair(a, b)$ in $f$.
    $ forall a in A, exists b in B: pair(a, b) in f $
  + _Serial (right-unique)_:
    For every $a in A$, there is _at most one_ pair $pair(a, b)$ in $f$.
    $ (pair(a, b_1) in f and pair(a, b_2) in f) ==> b_1 = b_2 $
]

#definition[
  A relation that satisfies the functional (left-total) property is called a _partial function_.

  A relation that satisfies _both_ properties is called a _total function_, or simply a _function_.
]

== Domain, Codomain, Range

#definition[
  For a function $f: A to B$:
  - The set $A$ is called the _domain_ of $f$, denoted $Dom(f)$.
  - The set $B$ is called the _codomain_ of $f$, denoted $Cod(f)$.
  - The _range_ (or _image_) of $f$ is the set of all values that $f$ actually takes:
    $ Range(f) = { b in B | exists a in A, f(a) = b } = { f(a) | a in A } $

    #note[
      $Range(f) subset.eq Cod(f)$
    ]
]

#example[
  Let $A = {1, 2, 3}$ and $B = {x, y, z}$.
  Let $f = {pair(1, x), pair(2, y), pair(3, x)}$.
  - $f$ is a function from $A$ to $B$.
  - $Dom(f) = A$
  - $Cod(f) = B$
  - $Range(f) = {x, y} subset.eq B$
  We have $f(1) = x$, $f(2) = y$, $f(3) = x$.

  #place(bottom + right)[
    #cetz.canvas({
      import cetz.draw: *

      scale(75%)

      circle((0, 0), radius: (1, 2))
      circle((3, 0), radius: (1, 2))

      set-style(mark: (scale: 1.5))
      line((0, 1), ((), 95%, (3, 1)), mark: (end: "stealth")) // 1 -> x
      line((0, 0), ((), 95%, (3, 0)), mark: (end: "stealth")) // 2 -> y
      line((0, -1), ((), 95%, (3, 1)), mark: (end: "stealth")) // 3 -> x

      circle((0, 0), radius: 0.1, fill: white)
      circle((0, 1), radius: 0.1, fill: white)
      circle((0, -1), radius: 0.1, fill: white)

      circle((3, 0), radius: 0.1, fill: white)
      circle((3, 1), radius: 0.1, fill: white)
      circle((3, -1), radius: 0.1, fill: white)

      content((-0.2, 1), anchor: "east")[$1$]
      content((-0.2, 0), anchor: "east")[$2$]
      content((-0.2, -1), anchor: "east")[$3$]
      content((3.2, 1), anchor: "west")[$x$]
      content((3.2, 0), anchor: "west")[$y$]
      content((3.2, -1), anchor: "west")[$z$]
    })
  ]
]

#example[
  Consider $g: ZZ to ZZ$ defined by $g(n) = n^2$.
  - $Dom(g) = ZZ$.
  - $Cod(g) = ZZ$.
  - $Range(g) = {0, 1, 4, 9, dots}$ (the set of non-negative perfect squares).
]

== Injective Functions

#definition[
  A function $f: A to B$ is _injective_ (or _one-to-one_#footnote[Do not confuse it with _one-to-one correspondence_, which is a bijection, not just injection!]) if distinct elements in the domain map to distinct elements in the codomain.
  $ forall a_1, a_2 in A, (f(a_1) = f(a_2)) ==> (a_1 = a_2) $
]

#example[
  $f: NN to NN$ defined by $f(n) = 2n$ is injective.
  If $f(n_1) = f(n_2)$, then $2n_1 = 2n_2$, so $n_1 = n_2$.
]
#example[
  $g: ZZ to ZZ$ defined by $g(n) = n^2$ is _not_ injective, because $g(-1) = 1$ and $g(1) = 1$, but $-1 != 1$.
]

== Surjective Functions

#definition[
  A function $f: A to B$ is _surjective_ (or _onto_) if every element in the codomain is the image of at least one element in the domain.
  $ forall b in B. thin exists a in A. thin f(a) = b $
  For surjective functions, $Range(f) = Cod(f)$.
]

#example[
  $f: RR to RR$ defined by $f(x) = x^3$ is surjective. For any $y in RR$, $x = root(3, y)$ is such that $f(x)=y$.
]
#example[
  $g: NN to NN$ defined by $g(n) = 2n$ is _not_ surjective, because odd numbers in $NN$ (the codomain) are not in the range of $g$. For example, there is no $n in NN$ such that $2n = 3$.
]

== Bijective Functions

#definition[
  A function $f: A to B$ is _bijective_ if it is both injective and surjective.
  A bijective function establishes a _one-to-one correspondence_ between the elements of $A$ and $B$.
]

#example[
  $f: RR to RR$ defined by $f(x) = 2x + 1$ is bijective.
  - Injective: If $2x_1+1 = 2x_2+1$, then $2x_1 = 2x_2$, so $x_1=x_2$.
  - Surjective: For any $y in RR$, let $x = (y-1) / 2$. Then $f(x) = 2((y-1) / 2) + 1 = y-1+1 = y$.
]
#example[
  The identity function $id_A: A to A$ defined by $id_A(x) = x$ for all $x in A$ is bijective.
]

== Function Composition

#definition[
  Let $f: A to B$ and $g: B to C$ be two functions.
  The _composition_ of $g$ and $f$, denoted $g compose f$ (read as "$g$ composed with $f$" or "$g$ after $f$"), is a function from $A$ to $C$ defined by:
  $ (g compose f)(a) = g(f(a)) $
  // for all $a in A$.
]

#example[
  Let $f: RR to RR$ be $f(x) = x^2$ and $g: RR to RR$ be $g(x) = x+1$.
  - $(g compose f)(x) = g(f(x)) = g(x^2) = x^2 + 1$.
  - $(f compose g)(x) = f(g(x)) = f(x+1) = (x+1)^2 = x^2 + 2x + 1$.
]

== Properties of Function Composition

- _Associativity:_ If $f: A to B$, $g: B to C$, and $h: C to D$, then $(h compose g) compose f = h compose (g compose f)$.

- The _identity_ function acts as a _neutral_ element for composition:
  - $id_B compose f = f$ for any function $f: A to B$.
  - $f compose id_A = f$ for any function $f: A to B$.

- Composition _preserves_ the properties of functions:
  - If $f$ and $g$ are injective, so is $g compose f$.
  - If $f$ and $g$ are surjective, so is $g compose f$.
  - If $f$ and $g$ are bijective, so is $g compose f$.

- Note that in general, $g compose f != f compose g$, i.e., function composition is _not commutative_.

== Inverse Functions

#definition[
  If $f: A to B$ is a bijective function, then its _inverse function_, denoted $f^(-1): B to A$, is defined as:
  $
    f^(-1)(b) = a quad "iff" quad f(a) = b
  $
]

#note[
  A function has an inverse _if and only if_ it is bijective.
]

#example[
  Let $f: RR to RR$ be $f(x) = 2x + 1$.
  We found it's bijective.
  To find $f^(-1)(y)$, let $y = 2x+1$.
  Solving for $x$, we get $x = (y-1) / 2$.
  So, $f^(-1)(y) = (y-1) / 2$.
]

#theorem[
  If $f: A to B$ is a bijective function with inverse $f^(-1): B to A$:
  - $f^(-1)$ is also bijective.
  - $(f^(-1) compose f)(a) = a$ for all $a in A$ (i.e., $f^(-1) compose f = id_A$).
  - $(f compose f^(-1))(b) = b$ for all $b in B$ (i.e., $f compose f^(-1) = id_B$).
  - If $f: A to B$ and $g: B to C$ are both bijective, then $(g compose f)^(-1) = f^(-1) compose g^(-1)$.
]

== Image and Preimage of Sets

#definition[
  Let $f: A to B$ be a function and let $S subset.eq A$.
  The _image of $S$ under $f$_ is the set:
  $ f(S) = { f(s) | s in S } $
  Note that $f(S) subset.eq B$.
  The range of $f$ is $f(A)$.
]

#definition[
  Let $f: A to B$ be a function and let $T subset.eq B$.
  The _preimage of $T$ under $f$_ (or _inverse image of $T$_) is the set of all elements in the domain that map into $T$:
  $ f^(-1)(T) = { a in A | f(a) in T } $
]

#note[
  The notation $f^(-1)(T)$ is used even if the inverse function $f^(-1)$ does not exist (i.e., if $f$ is not bijective).
  It always refers to the set of domain elements that map into $T$.
]

#pagebreak()

#example[
  Let $f: ZZ -> ZZ$ be $f(x) = x^2$.
  - Let $S = {-2, -1, 0, 1, 2}$. Then $f(S) = {f(-2), f(-1), f(0), f(1), f(2)} = {4, 1, 0, 1, 4} = {0, 1, 4}$.
  - Let $T_1 = {1, 9}$. The preimage is $f^(-1)(T_1) = {x in ZZ | x^2 in {1, 9}} = {-3, -1, 1, 3}$.
  - Let $T_2 = {2, 3}$. The preimage is $f^(-1)(T_2) = {x in ZZ | x^2 in {2, 3}} = emptyset$.
]

= Cardinality & Infinity
#focus-slide(
  epigraph: [God made the integers, all else is the work of man.],
  epigraph-author: "Leopold Kronecker",
  scholars: (
    (
      name: "Giuseppe Peano",
      image: image("assets/Giuseppe_Peano.jpg"),
    ),
    (
      name: "Leopold Kronecker",
      image: image("assets/Leopold_Kronecker.jpg"),
    ),
    (
      name: "David Hilbert",
      image: image("assets/David_Hilbert.jpg"),
    ),
    (
      name: "Kurt Gödel",
      image: image("assets/Kurt_Godel.jpg"),
    ),
    (
      name: "John von Neumann",
      image: image("assets/John_von_Neumann.jpg"),
    ),
  ),
)

== Size of Sets

#definition[
  The _size_ of a _finite_ set $X$, denoted $abs(X)$, is the number of elements it contains.

  // For a _finite_ set $X$, its _size_, denoted $abs(X)$, is the number of elements it contains.

  // If a finite set is enumerated as $X = {x_1, dots, x_n}$, then its size is $n$.
]

#examples[
  - Let $A = {#emoji.planet, #emoji.dino, #emoji.violin}$, then $abs(A) = 3$, since $A$ contains _exactly 3_ elements.
  - Let $B = {#emoji.kiwi, #emoji.kiwi, #emoji.kiwi}$, then $abs(B) = 1$, since $B$ contains _only one unique_ element (the kiwi).
  - $abs(power({1,2,#emoji.cat})) = 2^3 = 8$, since the power set consists of _all 8 possible subsets_ of ${1, 2, #emoji.cat}$.
  - $abs(emptyset) = 0$, since the _empty_ set contains _no elements_.
  - $abs(NN) = infinity$, since there are _infinitely many_ natural numbers.
  - $abs(RR) = infinity$, since there are _infinitely many_ real numbers.
]

== Cardinality of Sets

#definition[
  Two sets $A$ and $B$ have the same _cardinality_ and called _equinumerous_, denoted #box[$abs(A) = abs(B)$] or $A equinumerous B$, iff there is a _bijection_ (one-to-one correspondence) from $A$ to $B$.
]

// TODO: proposition
#theorem[
  Equinumerosity is an equivalence relation.
]

#proof[
  Let $A$, $B$, $C$ be sets.
  - _Reflexivity:_
    The identity map $id_A: A to A$, where $id_A (x) = x$, is a bijection, so $A equinumerous A$.
  - _Symmetry:_
    Suppose $A equinumerous B$, then there is a bijection $f: A to B$.
    Since it is a bijection, its inverse $f^(-1)$ exists and is also a bijection.
    Hence, $f^(-1): B to A$ is a bijection, so $B equinumerous A$.
  - _Transitivity:_
    Suppose that $A equinumerous B$ and $B equinumerous C$, i.e., there are bijections $f: A to B$ and $g: B to C$.
    Then~the composition $g compose f: A to C$ is also a bijection.
    So $A equinumerous C$.
]

// TODO: proposition
// #theorem[
//   If $A equinumerous B$, then $A$ is countable if and only if $B$ is.
// ]

== Countable Sets

#definition[
  A set called _countable_ if it is either finite or has the same cardinality as the set of natural numbers $NN$.
  Alternatively, a set is countable if there is a _bijection_ from $NN$ to that set.

  When an infinite set is _countable_, its cardinality is denoted $aleph_0$ (_"aleph-null"_ ).
]

#example[
  $abs(NN_"odd" = {1, 3, 5, dots}) = aleph_0$, the set of _odd_ natural numbers is countable, since there is a bijection $f: NN to NN_"odd"$ defined by $f(n) = 2n + 1$.
]

#example[
  $abs({x in NN | x "is prime"}) = aleph_0$, the set of _prime_ numbers is countable.
]

#example[
  $abs(ZZ) = aleph_0$, the set of _integers_ ($-infinity, dots, -2, -1, 0, 1, 2, dots, infinity$) is countable, since there is a bijection $f: NN to ZZ$ defined by $f(n)$:
  #align(center, grid(
    columns: (1fr, auto),
    align: horizon,
    $
      f(n) = (-1)^n ceil(n / 2) = cases(n/2 & "if" n "is even", -(n+1)/2 & "if" n "is odd")
    $,
    $
      mat(
        delim: "[",
        column-gap: #1em,
        row-gap: #0.5em,
        f(0), f(1), f(2), f(3), f(4), f(5), f(6), dots;
        ceil(0/2), -ceil(1/2), ceil(2/2), -ceil(3/2), ceil(4/2), -ceil(5/2), ceil(6/2), dots;
        0, -1, 1, -2, 2, -3, 3, dots
      )
    $,
  ))
]

// #example[
//   $abs(QQ) = aleph_0$, the set of rational numbers is countable.
// ]

== Countability Constructions

#definition[
  A set $X$ is _enumerable_ if there is a surjection $e: NN to X$ (equivalently a bijection with either $NN$ or an initial segment of $NN$ if $X$ finite).
]

#theorem[Zig-Zag Enumeration][
  $NN^2$ is countable.
]

#proof[
  List pairs by diagonals of constant sum: $pair(0, 0); pair(0, 1),pair(1, 0); pair(0, 2),pair(1, 1),pair(2, 0); dots$ giving a bijection with $NN$.
]

#theorem[
  $QQ$ is countable.
]

#proof[
  Enumerate positive reduced fractions $p "/" q$ ordered by $p+q$ and increasing $p$; skip non-reduced.
  Interleave $0$ and negatives.
  This yields _enumeration_, hence $QQ equinumerous NN$.
]

== Pairing Functions

#definition[
  A function $f: A times B to NN$ is an arithmetical _pairing function_ if it is injective.

  We say that $f$ _encodes_ $A times B$, and that $f(a, b)$ is the _code_ of the pair $pair(a, b)$.
]

#place(right)[
  #grid(
    columns: 1,
    align: right,
    column-gutter: 1em,
    row-gutter: 0.5em,
    link("https://en.wikipedia.org/wiki/Georg_Cantor", box(
      radius: 5pt,
      clip: true,
      stroke: 1pt + blue.darken(20%),
      image("assets/Georg_Cantor.jpg", height: 3cm),
    )),
    [Georg Cantor],
  )
]

#example[
  The _Cantor pairing function_ $g: NN^2 to NN$ is defined as:
  $
    g(n, k) = frac((n+k+1)(n+k), 2) + n
  $
]

== Uncountable Sets

#definition[
  A set is _uncountable_ if it is not countable.
]

In order to prove that a set $A$ is _uncountable_, we need to show that _no bijection $NN to A$ can exist_.

The general strategy for showing that is to use _Cantor's diagonal argument_.
Given a list of elements of $A$, say $x_1, x_2, dots$ (enumerated by natural numbers), we construct a _new_ element of $A$ that _differs_ from each $x_i$, thus showing that the list cannot be complete, and hence no bijection can exist.

#theorem[
  $B^omega$ is uncountable.
]

#proof[
  Recall that $BB^omega$ is the set of all _infinite sequences_ of elements from $BB = {0, 1}$. \
  For example, $BB^omega$ contains sequences like $0000dots$, $010101dots$, $1110dots$, etc.

  Suppose for contradiction that $BB^omega$ is countable.
  Then we can _enumerate_ its elements as $x_1, x_2, dots$, where each $x_i$ is an infinite sequence of bits, so we can represent it as $x_i = (b_(i 1), b_(i 2), b_(i 3), dots)$, where $b_(i j) in BB$ is the $j$-th bit of the $i$-th sequence.

  Now we construct a new sequence $Delta = (overline(b)_(1 1), overline(b)_(2 2), overline(b)_(3 3), dots)$, where $overline(b)_(i i) = 1 - b_(i i)$, i.e., we flip the $i$-th bit of the $i$-th sequence.
  This sequence _differs_ from each $x_i$ at least in the $i$-th position, so it cannot be equal to any $x_i$, so it is _not in_ the enumeration $x_1, x_2, dots$.

  #grid(
    columns: 5,
    align: center,
    inset: 5pt,
    stroke: (x, y) => if x == 0 { (right: .8pt) } + if y == 0 { (bottom: .8pt) },
    [], $1$, $2$, $3$, $dots$,
    $x_1$, $bold(b_(1 1))$, $b_(1 2)$, $b_(1 3)$, $dots$,
    $x_2$, $b_(2 1)$, $bold(b_(2 2))$, $b_(2 3)$, $dots$,
    $x_3$, $b_(3 1)$, $b_(3 2)$, $bold(b_(3 3))$, $dots$,
    $dots.v$, $dots.v$, $dots.v$, $dots.v$, $dots.down$,
    $Delta$, $overline(b)_(1 1)$, $overline(b)_(2 2)$, $overline(b)_(3 3)$, $dots$,
  )

  Since $Delta$ is constructed from the bits, it is also an _element_ of $BB^omega$.
  Thus, we have found an element of $BB^omega$ that is not in the enumeration $x_1, x_2, dots$, contradicting the assumption that $BB^omega$ is countable.
]

== Sets of Different Sizes

#definition[
  The cardinality of a set $A$ is _less than or the same_ as the cardinality of a set $B$, denoted $abs(A) <= abs(B)$ or $A smaller.eq B$, if there is an _injection_ (one-to-one function) from $A$ to $B$.
  // Set $A$ is _no larger than_ $B$, denoted $A smaller.eq B$, iff there is an _injection_ from $A$ to $B$.
]

#definition[
  Set $A$ is _smaller_ than $B$, denoted $abs(A) < abs(B)$ or $A smaller B$, iff there is an _injection_, but _no~bijection_ from $A$ to $B$, i.e., $A smaller.eq B$ and $A equinumerous.not B$.
]

#note[
  Using this notation, we can say that a set $X$ is _countable_ iff $X smaller.eq NN$, and _uncountable_ iff $NN smaller X$.
]

#example[
  ${1, 2} smaller {a, b, c}$, since there is an injection $f: {1, 2} to {a, b, c}$ defined by $f(1) = a$ and $f(2) = b$, but no bijection exists.
]

#example[
  $NN smaller.eq ZZ$, since there is bijection (and thus an injection) $f: NN to ZZ$.
]

#example[
  $ZZ smaller.eq NN$, since there is bijection (and thus an injection) $f: ZZ to NN$.
]

#example[
  $NN smaller power(NN)$, since there is an injection $f(x) = {x}$, but no bijection exists.
]

== Cantor's Theorem

#theorem[Cantor][
  $A smaller power(A)$, for any set $A$.
]

#proof[
  The map $f(x) = {x}$ is an injection $f: A to power(A)$, since if $x != y$, then also ${x} != {y}$ by extensionality, and so $f(x) != f(y)$.
  So we have that $A smaller.eq power(A)$.

  It remains to show that $A equinumerous.not B$.
  For reductio, suppose $A equinumerous B$, i.e., there is some bijection $g: A to B$.
  Now~consider $D = {x in A | x notin g(x)}$.
  Note that $D subset.eq A$, so $D in power(A)$.
  Since $g$ is a bijection, there exists some $y in A$ such that $g(y) = D$.
  But now we have
  $
    y in g(y) "iff" y in D "iff" y notin g(y)
  $
  This is a contradiction, since $y$ cannot be both _in_ and _not in_ $g(y)$.
  Thus, $A equinumerous.not power(A)$.
]

== Schröder--Bernstein Theorem

#theorem[Schröder--Bernstein][
  If $A smaller.eq B$ and $B smaller.eq A$, then $A equinumerous B$.
] <shroder-bernstein>

In other words, if there are injections in both directions between two sets, then there is a bijection.

#proof[
  Obvious, but difficult. #emoji.person.shrug
]

== Another Cantor's Theorem

Let $L$ be the unit line, i.e., the set of points $[0, 1]$.
Let $S$ be the unit square, i.e., the set of points $L times L$.

#columns(2)[
  #theorem[
    $L equinumerous S$.
  ]

  #colbreak()

  #align(center)[
    #cetz.canvas({
      import cetz.draw: *
      line((0, 0), (1, 0), mark: (symbol: "|"))
      content((.5, .5))[$L$]
      translate((1.5, 0))
      rect((0, 0), (1, 1), fill: luma(80%))
      content((.5, .5))[$S$]
    })
  ]
]

#proof[#footnote[See https://math.stackexchange.com/a/183383 for more detailed analysis.]][
  Consider the function $f: L to S$ defined by $f(x) = (x, x)$.
  This is an injection, since if #box[$f(a) = f(b)$], then $(a, a) = (b, b)$, so $a = b$.
  Thus, $L smaller.eq S$.

  Now consider the function $g: S to L$ that maps $(x, y)$ to the real number obtained by _interleaving_ the decimal expansions of $x$ and $y$.
  #v(-.5em)
  $
    cases(
      reverse: #true,
      x & = 0.#Blue($x_1 x_2 x_3 dots$),
      y & = 0.#Green($y_1 y_2 y_3 dots$),
    )
    #h(1em)
    g(x, y) & = 0.#Blue($x_1$) #Green($y_1$) #Blue($x_2$) #Green($y_2$) #Blue($x_3$) #Green($y_3$) dots
  $
  #v(-.5em)
  This is an injection, since if $g(a, b) = g(c, d)$, then $a_n = c_n$ and $b_n = d_n$ for all $n in NN$, so $(a, b) = (c, d)$.
  Thus, $S smaller.eq L$.

  By Schröder--Bernstein (@shroder-bernstein), we have that $L equinumerous S$.
]

= Order Theory
#focus-slide(
  epigraph: [Order is heaven's first law.],
  epigraph-author: "Alexander Pope",
  scholars: (
    (
      name: "Helmut Hasse",
      image: image("assets/Helmut_Hasse.jpg"),
    ),
    (
      name: "Alfred Tarski",
      image: image("assets/Alfred_Tarski.jpg"),
    ),
    (
      name: "Emmy Noether",
      image: image("assets/Emmy_Noether.jpg"),
    ),
    (
      name: "Garrett Birkhoff",
      image: image("assets/Garrett_Birkhoff.jpg"),
    ),
    (
      name: "Dana Scott",
      image: image("assets/Dana_Scott.jpg"),
    ),
    (
      name: "Felix Hausdorff",
      image: image("assets/Felix_Hausdorff.jpg"),
    ),
  ),
)

== Partially Ordered Sets

// Poset
#definition[
  A _partially ordered set_ (or _poset_) $pair(S, leq)$ is a set $S$ equipped with a partial order $leq$.

  // A partial order is a relation $leq$ over $S$ that is reflexive, antisymmetric, and transitive.
]

// TODO: linear order

// Chain
#definition[
  A _chain_ in a poset $pair(S, leq)$ is a subset $C subset.eq S$ such that any two elements $x, y in C$ are~_comparable_, i.e., either $x leq y$ or $y leq x$.
]

// TODO: anti-chain

// TODO: Hasse diagram

// Minimal element
#definition[
  An element $x in S$ is called a _minimal element_ of a poset $pair(S, leq)$ if there is no "greater" element $y in S$ such that $y < x$ (i.e., $y leq x$ and $y neq x$).
]

// Maximal element
#definition[
  A _maximal element_ $m$ satisfies: there is no $y in S$ with $m < y$.
]

#note[
  There may be multiple maximal (or minimal) elements.
]

// Greatest element
#definition[
  The _greatest element_ of a poset $pair(S, leq)$ is an element $g in S$ that is greater than or equal to every other element in $S$, i.e., for all $x in S$, $x leq g$.
]

// Least element
#definition[
  A _least element_ (bottom) $b$ satisfies $b leq x$ for all $x in S$.
]

#note[
  Greatest (top) and least (bottom) elements are _unique_ when they exist.
]

#examples[
  - $pair(power(A), subset.eq)$: least $emptyset$, greatest $A$.
  - $pair(NN^+, |)$: least $1$, no greatest element.
  - $pair(ZZ, <=)$: no least or greatest element.
  - $pair({1,...,6}, |)$: least $1$, no greatest element, maximal elements are $4$, $5$, $6$.
]

== Upper and Lower Bounds

// Upper bound
#definition[
  In a poset $pair(S, leq)$, an element $u in S$ is called an _upper bound_ of a subset $C subset.eq S$ if it is greater than or equal to every element in $C$, i.e., for all $x in C$, $x leq u$.
]

// Lower bound
#definition[
  In a poset $pair(S, leq)$, an element $l in S$ is called a _lower bound_ of a subset $C subset.eq S$ if it is less~than or equal to every element in $C$, i.e., for all $x in C$, $l leq x$.
]

#examples[
  - In $pair(RR, <=)$ for interval $C = (0,1)$: every $x <= 0$ is a lower bound; every $x >= 1$ an upper bound.
  - In $pair(power(A), subset.eq)$ for $C = {{1,2},{1,3}}$: lower bounds include ${1}$, $emptyset$; upper bounds include ${1,2,3}$.
  - In $pair(ZZ, |)$ for $C = {4,6}$: upper bounds are multiples of $12$; least upper bound $12$; lower bounds are divisors of $2$; greatest lower bound $2$.
]

== Suprema and Infima

// Supremum
#definition[
  In a poset $pair(S, leq)$, the _supremum_ (or _join_) of a subset $C subset.eq S$, denoted $sup(C)$ or $Join.big C$, is the _least upper bound_ of $C$, i.e., an upper bound $u in S$ s.t. for any other upper bound $v in S$, $u leq v$.

  #note[
    If it exists, the least upper bound is _unique_.
  ]
]

// Infimum
#definition[
  In a poset $pair(S, leq)$, the _infimum_ (or _meet_) of a subset $C subset.eq S$, denoted $inf(C)$ or $Meet.big C$, is the _greatest lower bound_ of $C$, i.e., a lower bound $l in S$ s.t. for any other lower bound $m in S$, $m leq l$.

  #note[
    If it exists, the greatest lower bound is _unique_.
  ]
]

#examples[
  - $pair(RR, <=)$: $sup({0,1}) = 1$, $inf({0,1}) = 0$, i.e., $sup(C) = max(C)$, $inf(C) = min(C)$.
  - $pair(power(A), subset.eq)$: $sup = union$, $inf = intersect$.
  - Divisibility on $NN_(>0)$: $sup {a, b} = lcm(a, b)$ (if any common multiple), $inf {a, b} = gcd(a, b)$.
]

== Lattices

// Upper semilattice
#definition[
  A poset $pair(S, leq)$ where every non-empty finite subset $C subset.eq S$ has a join (supremum) is called an _upper semilattice_ (or _join-semilattice_) and denoted $pair(S, Join)$.
]

// Lower semilattice
#definition[
  A poset $pair(S, leq)$ where every non-empty finite subset $C subset.eq S$ has a meet (infimum) is called a _lower semilattice_ (or _meet-semilattice_) and denoted $pair(S, Meet)$.
]

// Lattice
#definition[
  A poset $pair(S, leq)$ that is both an upper semilattice and a lower semilattice, i.e., every non-empty finite subset has both a join and a meet, is called a _lattice_, denoted $(S, Join, Meet)$.
]

== Why Lattices?

#block(
  width: 100%,
  fill: yellow.lighten(80%),
  stroke: 1pt + yellow.darken(20%),
  radius: 5pt,
  inset: 0.8em,
)[
  *Why study lattices?*
  Whenever you have:
  - Elements that can be _compared_ (ordered)
  - Ways to _combine_ elements (join, meet)
  - Consistent behavior under combination

  ...you likely have a lattice!
  This structure appears in programming languages, databases, security systems, logic circuits, and many other areas of computer science and mathematics.
]

== Properties of Lattices

#definition[
  A lattice is _bounded_ if it has a greatest element $top$ and a least element $bot$.
]

#definition[
  A lattice is _distributive_ if $x Meet (y Join z) = (x Meet y) Join (x Meet z)$ (and dually).
]

#definition[
  A lattice is _modular_ if $x leq z$ implies $x Join (y Meet z) = (x Join y) Meet z$.

  #note[
    Distributive $=>$ modular.
  ]
]

#example[Powerset Lattice][
  $pair(power(A), subset.eq)$ is a bounded distributive lattice with $Join = union$, $Meet = intersect$, $top = A$, $bot = emptyset$.

  #place(right)[
    #box(
      radius: 5pt,
      clip: true,
      stroke: 1pt + blue.darken(20%),
      image("assets/base.jpg", height: 2.5cm),
    )
  ]

  *Why this matters:*
  This is the foundation of set-based reasoning in:
  - Database theory (relational algebra)
  - Formal specification languages (Z, B-method)
  - Model checking and verification
]

== Examples of Lattices

// #example[
//   Subspaces of a vector space (ordered by inclusion) form a modular (not always distributive) lattice.

//   *Application:* Linear algebra, quantum mechanics (state spaces), signal processing (subspace methods).
// ]

#example[Divisibility Lattice][
  For positive integers, $a leq b$ iff $a$ divides $b$.
  - Join: Least Common Multiple (LCM)
  - Meet: Greatest Common Divisor (GCD)
  - Used in: Number theory, cryptography (RSA), computer algebra systems
]

#example[Partition Lattice][
  All partitions of a set $S$, ordered by refinement.
  - $pi_1 leq pi_2$ if $pi_1$ is a refinement of $pi_2$ (smaller blocks)
  - Join: Coarsest common refinement
  - Meet: Finest common coarsening
  - Applications: Clustering, database normalization
]

#block(
  inset: 0.8em,
  fill: luma(240),
  radius: 0.5em,
)[
  Lattices aren't just abstract algebra --- they appear everywhere in computer science and mathematics.

  The _join_ and _meet_ operations capture fundamental patterns of _combination_ and _interaction_.
]

== Why Lattices Matter [1]: Information Security Levels

#place(top + right)[
  #import fletcher: diagram, edge, node
  #diagram(
    spacing: 16pt,
    edge-stroke: 1pt + navy,
    node-corner-radius: 2pt,
    blob((0, 0), [Public], tint: green, name: <public>),
    edge("-}>"),
    blob((0, -1), [Internal], tint: yellow, name: <internal>),
    edge("-}>"),
    blob((0, -2), [Confidential], tint: orange, name: <confidential>),
    edge("-}>"),
    blob((0, -3), [Secret], tint: red, name: <secret>),
    edge("-}>"),
    blob((0, -4), [Top Secret], tint: purple, name: <top-secret>),
  )
]

#example[
  In computer security, information has _classification levels_ forming a lattice:

  - Elements: ${"Public", "Internal", "Confidential", "Secret", "Top Secret"}$
  - Order: $"Public" leq "Internal" leq "Confidential" leq "Secret" leq "Top Secret"$
  - Join ($Join$): Higher classification needed to combine information
  - Meet ($Meet$): Lower classification that both pieces can be declassified to

  For instance:
  - $"Internal" Join "Confidential" = "Confidential"$ (combination needs higher level)
  - $"Secret" Meet "Confidential" = "Confidential"$ (both can be declassified to this level)
]

== Why Lattices Matter [2]: Program Analysis and Type Systems

#example[
  In programming language theory, _types_ form lattices:

  *Subtype Lattice:*
  - Order: $#`int` subset.sq.eq #`number` subset.sq.eq #`any`$, $#`string` subset.sq.eq #`any`$
  - Join: Most general common supertype (for union types)
  - Meet: Most specific common subtype (for intersection types)

  *Control Flow Analysis:*
  - Elements: Sets of possible program states
  - Order: Subset inclusion ($subset.eq$)
  - Join: Union of possible states (at merge points)
  - Meet: Intersection of guaranteed properties
]

== Why Lattices Matter [3]: Database Query Optimization

#example[
  _Query execution plans_ form a lattice:

  - Elements: Different ways to execute a query
  - Order: "Plan A $leq$ Plan B" if A is more efficient than B
  - Join: Combine optimization strategies
  - Meet: Find common optimizations

  This structure helps database optimizers systematically explore the space of possible query plans.
]

== Why Lattices Matter [4]: Concept Hierarchies and Ontologies

#example[
  Knowledge representation uses _concept lattices_.

  For example, consider a biological taxonomy:
  #block[
    #import fletcher: diagram, edge, node
    #diagram(
      spacing: (1em, 2em),
      node-fill: luma(240),
      node-stroke: 0.5pt,
      edge-stroke: 1pt,
      node((.5, 0), [Animal], name: <animal>),
      node((0, 1), [Mammal], name: <mammal>),
      node((1, 1), [Bird], name: <bird>),
      node((0, 2), [Dog], name: <dog>),
      node((1, 2), [Eagle], name: <eagle>),
      edge(<mammal>, <animal>, "-}>"),
      edge(<bird>, <animal>, "-}>"),
      edge(<dog>, <mammal>, "-}>"),
      edge(<eagle>, <bird>, "-}>"),
    )
  ]

  - Elements: Biological concepts (e.g., Animal, Mammal, Dog)
  - Order: "Concept A $leq$ Concept B" if A is a more specific type of B, e.g., "Dog $leq$ Mammal"
  - Join: Most specific common ancestor, e.g., "Mammal $Join$ Bird $=$ Animal"
  - Meet: Most general common descendant, e.g., "Bird $Meet$ Eagle $=$ Eagle"
]

== Why Lattices Matter [5]: Distributed Systems and Causality

#example[
  In distributed systems, _events_ form a lattice _under causality_:

  - Elements: System events with vector timestamps
  - Order: "Event A $leq$ Event B" if A causally precedes B
  - Join: Latest information from both events
  - Meet: Common causal history

  This structure is crucial for:
  - Consistent distributed databases
  - Version control systems (Git DAG)
  - Blockchain consensus algorithms
]

== Why Lattices Matter [6]: Logic and Boolean Reasoning

#example[
  _Propositional formulas_ form lattices:

  - Elements: Boolean formulas over variables
  - Order: $phi leq psi$ if $phi$ implies $psi$ (semantic entailment)
  - Join: Disjunction ($or$) --- weaker condition
  - Meet: Conjunction ($and$) --- stronger condition

  Special case: _Boolean algebra_ $(True, False, or, and, not)$ used in:
  - Digital circuit design
  - Database query languages (SQL WHERE clauses)
  - Search engines (Boolean search)
]

= Boolean Algebra
#focus-slide(
  epigraph: [Мы почитаем всех нулями, \ А единицами — себя.],
  epigraph-author: [А.С. Пушкин, «Евгений Онегин»],
  scholars: (
    (
      name: "Gottfried Wilhelm Leibniz",
      image: image("assets/Gottfried_Wilhelm_Leibniz.jpg"),
    ),
    (
      name: "George Boole",
      image: image("assets/George_Boole.jpg"),
    ),
    (
      name: "Augustus De Morgan",
      image: image("assets/Augustus_De_Morgan.jpg"),
    ),
    (
      name: "Charles Sanders Peirce",
      image: image("assets/Charles_Sanders_Peirce.jpg"),
    ),
    (
      name: "Claude Shannon",
      image: image("assets/Claude_Shannon.jpg"),
    ),
  ),
)

== Definition and Basic Properties

#definition[
  A _Boolean algebra_ is a bounded distributive lattice $(B, Join, Meet, bot, top)$ with complement $(dot)': B to B$ such that $x Join x' = top$ and $x Meet x' = bot$.
]

#example[
  $(power(A), union, intersect, emptyset, A)$ with $X' = A setminus X$ is a Boolean algebra.
]

#example[Digital Circuit Design][
  Consider 3-bit binary values as Boolean algebra:
  - Elements: ${ 000, 001, 010, 011, 100, 101, 110, 111 }$
  - Order: Bitwise comparison ($001 leq 011$ since $0 leq 0$, $0 leq 1$, $1 leq 1$)
  - Join: Bitwise OR ($010 Join 101 = 111$)
  - Meet: Bitwise AND ($110 Meet 101 = 100$)
  - Complement: Bitwise NOT ($001' = 110$)

  This directly corresponds to logic gates: OR, AND, NOT gates in computer processors.
]

#note[
  Logical reading: "join" $mapsto or$, "meet" $mapsto and$, "complement" $mapsto not$.
]

== Example: Database Query Lattice

#example[
  A database has tables `Students`, `Courses`, `Enrollments`.
  - Let $Q_1 =$ "Computer Science students"
  - Let $Q_2 =$ "Students in Math courses"
  - Let $Q_3 =$ "Graduate students"

  Consider queries as lattice elements ordered by result size (specificity).

  *Lattice Operations:*
  - $Q_1 Join Q_2 =$ "Students in CS OR Math courses" (larger result set)
  - $Q_1 Meet Q_2 =$ "CS students taking Math courses" (smaller result set)
  - $Q_1 Meet Q_3 =$ "Graduate CS students" (most specific)

  *Why this matters:*
  Query optimizers use this structure to:
  + Find equivalent but more efficient queries.
  + Cache common subqueries.
  + Predict result set sizes for cost estimation.
]

== Complement is Unique

#theorem[
  Complements are unique in a Boolean algebra.
]

#proof[
  Suppose for some element $a$ we have _two_ complements $x$ and $y$.
  $
    x & = x Meet top                 & #[~] & top "is the identity for" Meet \
      & = x Meet (a Join y)          & #[~] & "by definition of complement:" top = a Join y \
      & = (x Meet a) Join (x Meet y) & #[~] & Meet "distributes over" Join \
      & = bot Join (x Meet y)        & #[~] & "by definition of complement: " x Meet a = bot \
      & = (a Meet y) Join (x Meet y) & #[~] & "by definition of complement: " bot = a Meet y \
      & = (a Join x) Meet y          & #[~] & Meet "distributes over" Join \
      & = top Meet y                 & #[~] & "by definition of complement: " a Join x = top \
      & = y                          & #[~] & top "is the identity for" Meet
  $
  That is, $x = y$.
]

== De Morgan's Laws

#theorem[De Morgan][
  $(x Join y)' = x' Meet y'$ and $(x Meet y)' = x' Join y'$ in any Boolean algebra.
]

== Digital Logic Circuits

#definition[
  A _logic gate_ is a physical device that implements a Boolean function, taking binary inputs and producing a binary output.
]

#place(right, dy: 1.5em)[
  #import "@preview/circuiteria:0.2.0"
  #circuiteria.circuit({
    import circuiteria: *
    import "@preview/cetz:0.3.2": draw
    draw.scale(80%)

    let label(s) = text(size: 10pt)[#s]

    element.gate-and(id: "and", x: 0, y: 0, w: 2, h: 2)
    draw.content("and", label[AND])

    element.gate-or(id: "or", x: 3.5, y: 0, w: 2, h: 2)
    draw.content("or", label[OR])

    element.gate-not(id: "not", x: 7, y: 0, w: 2, h: 2)
    draw.content((rel: (-5pt, 0), to: "not"), label[NOT])

    element.gate-nand(id: "nand", x: 0, y: -3, w: 2, h: 2)
    draw.content("nand", label[NAND])

    element.gate-nor(id: "nor", x: 3.5, y: -3, w: 2, h: 2)
    draw.content((rel: (3pt, 0), to: "nor"), label[NOR])

    element.gate-xor(id: "xor", x: 7, y: -3, w: 2, h: 2)
    draw.content((rel: (5pt, 0), to: "xor"), label[XOR])

    for id in ("and", "or", "not", "nand", "nor", "xor") {
      wire.stub(id + "-port-in0", "west")
      if id != "not" {
        wire.stub(id + "-port-in1", "west")
      }
      wire.stub(id + "-port-out", "east")
    }
  })
]

#v(-8pt)
#table(
  columns: 3,
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  inset: 4pt,
  table.header([Gate], [Formula], [Description]),
  [AND], $A and B$, [Outputs $1$ only when both inputs are $1$],
  [OR], $A or B$, [Outputs $1$ when at least one input is $1$],
  [NOT], $not A$, [Outputs the opposite of the input],
  [NAND], $not (A and B)$, [Outputs $0$ only when both inputs are $1$],
  [NOR], $not (A or B)$, [Outputs $0$ when at least one input is $1$],
  [XOR], $A xor B$, [Outputs $1$ when inputs differ],
  [XNOR], $A equiv B$, [Outputs $1$ when inputs are the same],
)

#note[
  NAND and NOR gates are _universal_ --- any Boolean function can be implemented using only NAND gates (or only NOR gates).
  For example, to implement AND using NAND:
  $
    A and B = not not (A and B) = not (A nand B) = (A nand B) nand (A nand B)
  $
]

== Combinational Logic

#definition[
  A _combinational circuit_ is a circuit where the output depends only on the current input values, without any memory or state.
]

#example[Half Adder][
  Adds two single bits:
  - Sum: $S = A xor B$
  - Carry: $C = A and B$
]

#example[Full Adder][
  Adds two bits plus a carry-in:
  - Sum: $S = A xor B xor C_"in"$
  - Carry-out: $C_"out" = (A and B) or (C_"in" and (A xor B))$
]

== Sequential Logic and Memory

#definition[
  A _sequential circuit_ is a circuit where the output depends on both current inputs and previous state (memory).
]

#example[Flip-Flops][
  - *SR Latch*: Set-Reset memory element.
  - *D Flip-Flop*: Data storage triggered by clock edge.
  - *JK Flip-Flop*: Eliminates forbidden state of SR latch.
  - *T Flip-Flop*: Toggle flip-flop for counters.
]

== Normal Forms

#definition[
  A _literal_ is a Boolean variable or its negation (e.g., $x$, $not x$).
]

// #definition[
//   A _clause_ is a disjunction (OR) of literals.
//   For example, $(x or not y)$ is a 2-clause.
// ]

// #definition[
//   A _term_ is a conjunction (AND) of literals.
//   For example, $(x and not y)$ is a 2-term.
// ]

#definition[DNF][
  A Boolean formula is in _disjunctive normal form (DNF)_ if it is a disjunction (OR) of _terms_ --- conjunctions (AND) of literals.
]
#example[
  $f(x,y,z) = underbracket((x and y and not z), "term") or underbracket((not x and z), "term") or underbracket((not y and not z), "term") or underbracket(#hide("(") x #hide(")"), "term")$
]

#definition[CNF][
  A Boolean formula is in _conjunctive normal form (CNF)_ if it is a conjunction (AND) of _clauses_ --- disjunctions (OR) of literals.
]
#example[
  $f(x,y,z) = underbracket((x or y or not z), "clause") and underbracket((not x or z), "clause") and underbracket((not y or not z), "clause") and underbracket(#hide("(") x #hide(")"), "clause")$
]

== Minterms and Maxterms

#definition[Minterm and Maxterm][
  - A _minterm_ is a product (AND) of literals where each variable appears exactly once.
  - A _maxterm_ is a sum (OR) of literals where each variable appears exactly once.
]

#note[
  A minterm (maxterm) is a function that evaluates to 1 (0, respectively) for exactly one combination of variable values.
]

#example[
  $f(x,y,z) = x overline(y) z$ is a minterm, and $g(x,y,z) = x + overline(y) + z$ is a maxterm for variables $x, y, z$.
  - $f(x,y,z) = 1$ only on input $101$, i.e., $x = 1$, $y = 0$, $z = 1$, correspending to the minterm $x overline(y) z$.
  - $g(x,y,z) = 0$ only on input $010$, i.e., $x = 0$, $y = 1$, $z = 0$, correspending to the maxterm $overline(x) + y + overline(z)$.
]

== Canonical Forms

#definition[SoP][
  Every Boolean function can be _uniquely_ expressed as a _sum of minterms_ (SoP, Sum of Products) corresponding to rows where the function evaluates to 1.

  // TODO: example
]

#definition[PoS][
  Every Boolean function can be _uniquely_ expressed as a _product of maxterms_ (PoS, Product of Sums) corresponding to rows where the function evaluates to 0.

  // TODO: example
]

// TODO: Blake canonical form

== Karnaugh Maps

#definition[
  A _Karnaugh map_ (K-map) is a graphical method for simplifying Boolean expressions by visually identifying adjacent minterms that can be combined.
]

#example[3-variable K-map][
  For function $f(A,B,C)$:
  ```
       C̄   C
  ĀB̄ | 0 | 1 |
  ĀB | 2 | 3 |
  AB | 6 | 7 |
  AB̄ | 4 | 5 |
  ```
  Adjacent cells (including wraparound) can be combined to eliminate variables.
]

== Zhegalkin Polynomials

#definition[
  A _Zhegalkin polynomial_ is a representation of a Boolean function as a polynomial over $"GF"(2)$ using XOR ($xor$) and AND ($and$, often omitted) operations.
]

// TODO: mention "algebraic normal form (ANF)"

#theorem[
  Every Boolean function has a unique representation as a Zhegalkin polynomial:
  $
    f(x_1, dots, x_n) = xor.big_(S subset.eq {1,dots,n}) (a_S product_(i in S) x_i)
  $
  where $a_S in {0,1}$ and $xor$ denotes XOR.
]

#example[
  $f(x,y) = x or y = x xor y xor x y$
]

== Binary Decision Diagrams (BDDs)

#definition[BDD][
  A _binary decision diagram (BDD)_ is a directed acyclic graph representing a Boolean function, where each non-terminal node represents a variable test and edges represent variable assignments.
]

// TODO: ordered BDD

#definition[ROBDD][
  A _reduced_ ordered binary decision diagram (ROBDD) is an ordered BDD with a fixed variable ordering where:
  - No variable appears more than once on any path
  - No two nodes have identical low and high successors
  - No node has identical low and high successors
]

#theorem[
  // For a fixed variable ordering, every Boolean function has a _unique_ ROBDD.
  Every Boolean function has a unique reduced ordered binary decision diagram (ROBDD) representation for a given variable ordering.
]

== TODO

- ...

// == Bibliography
// #bibliography("refs.yml")

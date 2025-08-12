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
#let dom = math.op("dom")
#let cod = math.op("cod")
#let range = math.op("range")
#let equinumerous = symbol(math.approx, ("not", math.approx.not))
#let smaller = symbol(math.prec, ("eq", math.prec.eq))
#let Join = math.or
#let Meet = math.and

#let Green(x) = text(green.darken(20%), x)
#let Red(x) = text(red.darken(20%), x)

#let True = Green(`true`)
#let False = Red(`false`)

#let YES = Green(sym.checkmark)
#let NO = Red(sym.crossmark)

= Sets

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

== Russell’s Paradox

#place(right)[
  #grid(
    columns: 1,
    align: right,
    column-gutter: 1em,
    row-gutter: 0.5em,
    link("https://en.wikipedia.org/wiki/Bertrand_Russell", image("assets/Bertrand_Russell.jpg", height: 3cm)),
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

== Partitions and Equivalence Relations

#definition[
  A _partition_ $cal(P)$ of a set $M$ is a family of non-empty, pairwise-disjoint subsets whose union is $M$:
  - (Non-empty) $forall B in cal(P). thin B != emptyset$.
  - (Disjoint) $forall B_1, B_2 in cal(P). thin B_1 != B_2 imply B_1 intersect B_2 = emptyset$.
  - (Cover) $union.big_(B in cal(P)) B = M$.
  Elements of $cal(P)$ are _blocks_ (or _cells_).
]

#example[
  For $M = {0,1,2,3,4,5}$: ${{0,2,4},{1,3,5}}$ (even / odd) and ${{0,5},{1,2,3},{4}}$ (arbitrary) are partitions.
]
// TODO: visualize partitions from the example

#pagebreak()

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

= Functions

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
  A relation that satisfies the functional property is called a _partial function_.

  A relation that satisfies both properties is called a _total function_, or simply a _function_.
]

== Domain, Codomain, Range

#definition[
  For a function $f: A to B$:
  - The set $A$ is called the _domain_ of $f$, denoted $dom(f)$.
  - The set $B$ is called the _codomain_ of $f$, denoted $cod(f)$.
  - The _range_ (or _image_) of $f$ is the set of all values that $f$ actually takes:
    $ range(f) = "Im"(f) = { b in B | exists a in A, f(a) = b } = { f(a) | a in A } $
  Note that $range(f) subset.eq cod(f)$.
]

#example[
  Let $A = {1, 2, 3}$ and $B = {x, y, z}$.
  Let $f = {pair(1, x), pair(2, y), pair(3, x)}$.
  - $f$ is a function from $A$ to $B$.
  - $dom(f) = A$.
  - $cod(f) = B$.
  - $range(f) = {x, y}$.
  We have $f(1)=x$, $f(2)=y$, $f(3)=x$.

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

      content((-0.2, 1), anchor: "east")[1]
      content((-0.2, 0), anchor: "east")[2]
      content((-0.2, -1), anchor: "east")[3]
      content((3.2, 1), anchor: "west")[x]
      content((3.2, 0), anchor: "west")[y]
      content((3.2, -1), anchor: "west")[z]
    })
  ]
]

#example[
  Consider $g: ZZ to ZZ$ defined by $g(n) = n^2$.
  - $dom(g) = ZZ$.
  - $cod(g) = ZZ$.
  - $range(g) = {0, 1, 4, 9, dots}$ (the set of non-negative perfect squares).
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
  For surjective functions, $range(f) = cod(f)$.
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
  Note that in general, $g compose f != f compose g$.
]

#theorem[Properties of Composition][
  - _Associativity:_ If $f: A to B$, $g: B to C$, and $h: C to D$, then $(h compose g) compose f = h compose (g compose f)$.
  - The _identity_ function acts as a _neutral_ element for composition:
    - $id_B compose f = f$ for any function $f: A to B$.
    - $f compose id_A = f$ for any function $f: A to B$.
  - Composition _preserves_ the properties of functions:
    - If $f$ and $g$ are injective, so is $g compose f$.
    - If $f$ and $g$ are surjective, so is $g compose f$.
    - If $f$ and $g$ are bijective, so is $g compose f$.
]

== Inverse Functions

#definition[
  If $f: A to B$ is a bijective function, then its _inverse function_, denoted $f^(-1): B to A$, is~defined as:
  $ f^(-1)(b) = a quad "iff" quad f(a) = b $.
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

= Cardinality

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
  $
    f(n) = (-1)^n ceil(n / 2) = cases(n/2 & "if" n "is even", -(n+1)/2 & "if" n "is odd")
    #h(2em)
    mat(
      delim: "[",
      column-gap: #1em,
      row-gap: #0.5em,
      f(0), f(1), f(2), f(3), f(4), f(5), f(6), dots;
      ceil(0/2), -ceil(1/2), ceil(2/2), -ceil(3/2), ceil(4/2), -ceil(5/2), ceil(6/2), dots;
      0, -1, 1, -2, 2, -3, 3, dots
    )
  $
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
  List pairs by diagonals of constant sum: $(0,0); (0,1),(1,0); (0,2),(1,1),(2,0); dots$ giving a bijection with $NN$.
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
    link("https://en.wikipedia.org/wiki/Georg_Cantor", image("assets/Georg_Cantor.jpg", height: 3cm)),
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
  This is an injection, since if $f(a) = f(b)$, then $(a, a) = (b, b)$, so $a = b$.
  Thus, $L smaller.eq S$.

  Now consider the function $g: S to L$ that maps $(x, y)$ to the real number obtained by interleaving the decimal expansions of $x$ and $y$.
  More precisely, if $x = 0.x_1 x_2 x_3 dots$ and $y = 0.y_1 y_2 y_3 dots$, then $g(x, y) = 0.x_1 y_1 x_2 y_2 x_3 y_3 dots$.
  This is an injection, since if $g(a, b) = g(c, d)$, then $a_n = c_n$ and $b_n = d_n$ for all $n in NN$, so $(a, b) = (c, d)$.
  Thus, $S smaller.eq L$.

  By Schröder--Bernstein (@shroder-bernstein), we have that $L equinumerous S$.
]

= Algebraic Structures

== Partially Ordered Sets

// Poset
#definition[
  A _partially ordered set_ (or _poset_) $pair(S, leq)$ is a set $S$ equipped with a partial order $leq$.

  // A partial order is a relation $leq$ over $S$ that is reflexive, antisymmetric, and transitive.
]

// Chain
#definition[
  A _chain_ in a poset $pair(S, leq)$ is a subset $C subset.eq S$ such that any two elements $x, y in C$ are~_comparable_, i.e., either $x leq y$ or $y leq x$.
]

// TODO: anti-chain

// Minimal element
#definition[
  An element $x in S$ is called a _minimal element_ of a poset $pair(S, leq)$ if there is no "greater" element $y in S$ such that $y < x$ (i.e., $y leq x$ and $y neq x$).
]
#definition[
  A _maximal element_ $m$ satisfies: there is no $y in S$ with $m < y$. There may be multiple maximal (or minimal) elements; contrast with unique greatest (if it exists).
]

// Greatest element
#definition[
  The _greatest element_ of a poset $pair(S, leq)$ is an element $g in S$ that is greater than or equal to every other element in $S$, i.e., for all $x in S$, $x leq g$.

  #note[
    Not all posets have a greatest element, but if they do, it is _unique_ and also a maximal element.
  ]
]

// Least element
#definition[
  A _least element_ (bottom) $b$ satisfies $b leq x$ for all $x in S$.
]

#note[
  Greatest (top) and least (bottom) elements are unique when they exist.
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
  - In $(RR, <=)$ for interval $C = (0,1)$: every $x <= 0$ is a lower bound; every $x >= 1$ an upper bound.
  - In $(power(A), subset.eq)$ for $C = {{1,2},{1,3}}$: lower bounds include ${1}$, $emptyset$; upper bounds include ${1,2,3}$.
  - In $(ZZ, |)$ for $C = {4,6}$: upper bounds are multiples of $12$; least upper bound $12$; lower bounds are divisors of $2$; greatest lower bound $2$.
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
  - Divisibility on $NN_(>0)$: $sup({a, b}) = lcm(a, b)$ (if any common multiple), $inf({a, b}) = gcd(a, b)$.
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

#example[
  $(power(A), subset.eq)$ is a bounded distributive lattice with $Join = union$, $Meet = intersect$, $top = A$, $bot = emptyset$.
]

#example[
  Subspaces of a vector space (ordered by inclusion) form a modular (not always distributive) lattice.
]

== Boolean Algebras

#definition[
  A _Boolean algebra_ is a bounded distributive lattice $(B, Join, Meet, bot, top)$ with complement $(dot)': B to B$ such that $x Join x' = top$ and $x Meet x' = bot$.
]

#example[
  $(power(A), union, intersect, emptyset, A)$ with $X' = A setminus X$ is a Boolean algebra.
]

#theorem[Unique Complement][
  Complements are unique in a Boolean algebra.
]

#proof[
  Suppose for some element $a$ we have two complements $x$ and $y$.
  $
    x
    = x Meet top
    = x Meet (a Join y)
    = (x Meet a) Join (x Meet y)
    = bot Join (x Meet y)
    = x Meet y
  $
  Identically, we can show that $y = x Meet y$.
  Hence, $x = y$.
]

#theorem[De Morgan][
  $(x Join y)' = x' Meet y'$ and $(x Meet y)' = x' Join y'$ in any Boolean algebra.
]

#note[
  Logical reading: "join" $mapsto or$, "meet" $mapsto and$, "complement" $mapsto not$.
]

== TODO

- ...

// == Bibliography
// #bibliography("refs.yml")

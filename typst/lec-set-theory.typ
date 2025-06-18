#import "theme.typ": *
#show: slides.with(
  title: [Discrete Mathematics],
  subtitle: "Set Theory",
  date: "Fall 2025",
  authors: "Konstantin Chukharev",
  ratio: 16 / 9,
)

#show table.cell.where(y: 0): strong

#set quote(block: true)
#show quote: set par(justify: false)
#show quote: set align(left)

#let iff = iff.double.long
#let power(x) = $cal(P)(#x)$
#let pair(a, b) = $angle.l #a, #b angle.r$
#let rel(x) = $class("relation", #x)$
#let nrel(x) = $class("relation", cancel(#x))$
#let dom = $op("dom")$
#let cod = $op("cod")$
#let range = $op("range")$

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
  A _set_ is an unordered collection of distinct objects (elements).

  - In _naïve_ set theory, sets can contain _any_ objects. Non-set objects are called _urelements_.
  - In _axiomatic_ set theory, _everything is a set_, there are no urelements.
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
  ${a, b, b} = {a, b} = {b, a} = {b, a, b}$
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
  ${0} in {0, {0}}$ _and_ ${0} subset.eq {0, {0}}$.
]

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
  The power set of the empty set is $power(emptyset) = {emptyset}$, _non-empty_ set containing the empty set.
]

#theorem[
  $abs(power(A)) = 2^abs(A)$ for any set $A$.
]

#proof[
  Each element in a set with $n$ elements can either be included or not, giving $2^n$ combinations.
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

#table(
  columns: 3,
  align: (left, right, left),
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header[Operation][Notation][Formal definition],
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

Consider the set $R$ of _all normal sets_:
$ R = { A | A notin A } $

_Paradox_ arises when we ask whether $R$ is normal or unusual:
- Suppose $R$ is _normal_. Then by definition, $R notin R$, which means $R$ is _not_ in the set of normal sets, _contradicting_ our assumption that it is normal.
- Suppose $R$ is _unusual_. Then by definition, $R in R$, which means $R$ _is_ in the set of normal sets, _contradicting_ our assumption that it is unusual.
- We reach a contradiction in both cases. Thus, _$R$ does not exist_.

This paradox shows that we cannot allow _unrestricted_ set formation via set-builder notation ${x | P(x)}$.

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

== Orders

#definition[
  A relation $R subset.eq M^2$ is called a _preorder_ if it is reflexive and transitive.
]
#definition[
  A preorder which is also antisymmetric is called a _partial order_.
]
#definition[
  A partial order which is also connected is called a _total order_ (or _linear order_).
]

#example[
  Consider the _no longer than_ relation $prec.curly.eq$ on $BB^*$: $x prec.curly.eq y$ iff $"len"(x) <= "len"(y)$.
  This is a preorder (reflexive and transitive), and even connected, but not partial order, since it is not antisymmetric: for example, $01 prec.curly.eq 10$ and $10 prec.curly.eq 01$, but $01 neq 10$.
]

== More Properties

#definition[
  A relation $R subset.eq M^2$ is _connected_ if for every pair of distinct elements, either one is related to the other or vice versa:
  $ forall x, y in M. thin (x neq y) imply (x rel(R) y or y rel(R) x) $
]

= Functions

== Definition of a Function

#definition[
  A *function* (or _map_, or _mapping_) $f$ from a set $A$ to a set $B$, denoted $f: A to B$, is a relation $f subset.eq A times B$ that satisfies the following properties:
  + _Functional_ (or _right-unique_): Each element in $A$ is related to _at most one_ element in $B$.
    $ forall a in A. thin forall b_1, b_2 in B. thin (pair(a, b_1) in f and pair(a, b_2) in f) imply (b_1 = b_2) $
  + _Serial_ (or _left-total_): Each element in $A$ is related to _at least one_ element in $B$.
    $ forall a in A. thin exists b in B. thin pair(a, b) in f $

  Together, these conditions mean that for every $a in A$, there is _exactly one_ $b in B$ such that $pair(a, b) in f$.

  *Notation:* We write $f(a) = b$ to denote that $pair(a, b) in f$.
]

#definition[
  A relation that satisfies the functional property is called a _partial function_.

  A relation that satisfies both properties is called a _total function_, or simply a _function_.
]

== Domain, Codomain, Range

#definition[
  For a function $f: A to B$:
  - The set $A$ is called the *domain* of $f$, denoted $dom(f)$.
  - The set $B$ is called the *codomain* of $f$, denoted $cod(f)$.
  - The *range* (or _image_) of $f$ is the set of all values that $f$ actually takes:
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
      line((0, 1), (3, 1), mark: (end: "stealth")) // 1 -> x
      line((0, 0), (3, 0), mark: (end: "stealth")) // 2 -> y
      line((0, -1), (3, 1), mark: (end: "stealth")) // 3 -> x

      circle((0, 0), radius: 0.1, fill: white)
      circle((0, 1), radius: 0.1, fill: white)
      circle((0, -1), radius: 0.1, fill: white)

      circle((3, 0), radius: 0.1, fill: white)
      circle((3, 1), radius: 0.1, fill: white)
      circle((3, -1), radius: 0.1, fill: white)

      content((-0.2, 1), anchor: "east")[1]
      content((-0.2, 0), anchor: "east")[2]
      content((-0.2, -1), anchor: "east")[3]
      content((3.2, -1), anchor: "west")[x]
      content((3.2, 0), anchor: "west")[y]
      content((3.2, 1), anchor: "west")[z]
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
  A function $f: A to B$ is *injective* (or _one-to-one_) if distinct elements in the domain map to distinct elements in the codomain.
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
  A function $f: A to B$ is *surjective* (or _onto_) if every element in the codomain is the image of at least one element in the domain.
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
  A function $f: A to B$ is *bijective* if it is both injective and surjective.
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
  Let $f: A to B$ and $g: B to C$ be two functions. The *composition* of $g$ and $f$, denoted $g compose f$ (read as "$g$ composed with $f$" or "$g$ after $f$"), is a function from $A$ to $C$ defined by:
  $ (g compose f)(a) = g(f(a)) $
  // for all $a in A$.
]

#example[
  Let $f: RR to RR$ be $f(x) = x^2$ and $g: RR to RR$ be $g(x) = x+1$.
  - $(g compose f)(x) = g(f(x)) = g(x^2) = x^2 + 1$.
  - $(f compose g)(x) = f(g(x)) = f(x+1) = (x+1)^2 = x^2 + 2x + 1$.
  Note that in general, $g compose f != f compose g$.
]

#theorem[
  Properties of function composition:
  - _Associativity_: If $f: A to B$, $g: B to C$, and $h: C to D$, then $(h compose g) compose f = h compose (g compose f)$.
  - The _identity_ function acts as a _neutral_ element for composition:
    - $id_B compose f = f$ for any function $f: A to B$.
    - $f compose id_A = f$ for any function $f: A to B$.
  - Composition preserves the properties of functions:
    - If $f: A to B$ and $g: B to C$ are both injective, then $g compose f$ is injective.
    - If $f: A to B$ and $g: B to C$ are both surjective, then $g compose f$ is surjective.
    - If $f: A to B$ and $g: B to C$ are both bijective, then $g compose f$ is bijective.
]

== Inverse Functions

#definition[
  If $f: A to B$ is a bijective function, then its *inverse function*, denoted $f^(-1): B to A$, is defined as:
  $ f^(-1)(b) = a quad "iff" quad f(a) = b $.
]

#note[
  A function has an inverse _if and only if_ it is bijective.
]

#example[
  Let $f: RR to RR$ be $f(x) = 2x + 1$. We found it's bijective.
  To find $f^(-1)(y)$, let $y = 2x+1$. Solving for $x$, we get $x = (y-1) / 2$.
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

#definition[Image of a Set][
  Let $f: A to B$ be a function and let $S subset.eq A$. The *image of $S$ under $f$* is the set:
  $ f(S) = { f(s) | s in S } $
  Note that $f(S) subset.eq B$. The range of $f$ is $f(A)$.
]

#definition[Preimage of a Set (Inverse Image)][
  Let $f: A to B$ be a function and let $T subset.eq B$. The *preimage of $T$ under $f$* (or _inverse image of $T$_) is the set:
  $ f^(-1)(T) = { a in A | f(a) in T } $
  Note that $f^(-1)(T) subset.eq A$.
  *Caution:* The notation $f^(-1)(T)$ is used even if $f$ is not bijective (and thus $f^(-1)$ as an inverse function does not exist). It always refers to the set of elements in the domain that map into $T$.
]

#example[
  Let $f: ZZ to ZZ$ be $f(x) = x^2$.
  - Let $S = {-2, -1, 0, 1, 2}$. Then $f(S) = {f(-2), f(-1), f(0), f(1), f(2)} = {4, 1, 0, 1, 4} = {0, 1, 4}$.
  - Let $T_1 = {1, 9}$. Then $f^(-1)(T_1) = {x in ZZ | x^2 in {1, 9}} = {-3, -1, 1, 3}$.
  - Let $T_2 = {2, 3}$. Then $f^(-1)(T_2) = {x in ZZ | x^2 in {2, 3}} = emptyset$.
]

== TODO

- ...

// == Bibliography
// #bibliography("refs.yml")

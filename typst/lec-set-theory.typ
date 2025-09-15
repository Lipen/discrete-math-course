#import "theme.typ": *
#show: slides.with(
  title: [Set Theory],
  subtitle: "Discrete Math",
  date: "Fall 2025",
  authors: "Konstantin Chukharev",
  // dark: true,
)

// Note: all 1-level (`=`) headers are hidden!
// In order to show the title page for the section,
//  use `#focus-slide()` after the `=` header.
// Use custom parameters, e.g. `epigraph`, `scholars`, etc.
//  to customize the section title slide.
#show heading.where(level: 1): none

#show table.cell.where(y: 0): strong

#set quote(block: true)
#show quote: set par(justify: false)
#show quote: set align(left)

#let iff = symbol(math.arrow.double.l.r.long, ("not", math.arrow.double.l.r.not))
#let power(x) = $cal(P)(#x)$
#let pair(a, b) = $angle.l #a, #b angle.r$
#let rel(x) = math.class("relation", x)
#let nrel(x) = rel(math.cancel(x))
#let matrel(x) = $bracket.double.l #x bracket.double.r$
#let eqclass(x, R) = $bracket.l #x bracket.r_#R$
#let quotient(M, R) = $M slash_(#R)$
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

#let Block(
  color: blue,
  body,
  ..args,
) = block(
  body,
  fill: color.lighten(90%),
  stroke: 1pt + color.darken(20%),
  radius: 5pt,
  inset: 1em,
  ..args.named(),
)

#import cetz: draw

#let draw-venn2(..args) = cetz.canvas({
  draw.scale(50%)
  cetz-venn.venn2(
    not-ab-fill: none,
    not-ab-stroke: none,
    padding: 0,
    ..args,
    name: "venn",
  )
  draw.content("venn.a", [A])
  draw.content("venn.b", [B])
})

#let draw-grid(max-x, max-y, overshoot: 0.3) = {
  draw.grid(
    (0, 0),
    (max-x + overshoot, max-y + overshoot),
    stroke: gray + 0.4pt,
  )
}
#let draw-x-axis(
  max-x,
  overshoot-x: 0.3,
  overshoot-y: 0.7,
) = {
  // Horizontal axis:
  draw.line((-overshoot-x, 0), (max-x + overshoot-y, 0), name: "x-axis", mark: (end: "stealth", fill: black))
  // Axis label:
  draw.content("x-axis.end", [$x$], anchor: "north", padding: 0.1)
  for x in range(1, max-x + 1) {
    // Tick:
    draw.line((x, -0.1), (x, 0.1), stroke: 0.5pt)
    // Label:
    draw.content((x, 0), [#x], anchor: "north", padding: 0.2)
  }
}
#let draw-y-axis(
  max-y,
  overshoot-x: 0.3,
  overshoot-y: 0.7,
) = {
  // Vertical axis:
  draw.line((0, -overshoot-x), (0, max-y + overshoot-y), name: "y-axis", mark: (end: "stealth", fill: black))
  // Axis label:
  draw.content("y-axis.end", [$y$], anchor: "east", padding: 0.1)
  for y in range(1, max-y + 1) {
    // Tick:
    draw.line((-0.1, y), (0.1, y), stroke: 0.5pt)
    // Label:
    draw.content((0, y), [#y], anchor: "east", padding: 0.2)
  }
}
#let draw-origin() = {
  // Origin label:
  draw.content((0, 0), [0], anchor: "north-east", padding: 0.2)
}

#[
  #set page(margin: 0pt)

  #let panel(
    tint: white,
    title,
    body,
  ) = block(
    height: 100%,
    width: 100%,
    fill: tint.lighten(85%),
  )[
    #stack(
      // Top part:
      box(
        width: 100%,
        height: 50%,
        inset: .5em,
        // stroke: .1pt,
      )[
        #set align(bottom + center)
        #set text(size: 1.4em)
        #box(
          inset: .5em,
          stroke: (bottom: .8pt),
        )[
          *#title*
        ]
      ],
      // Bottom part:
      box(
        width: 100%,
        inset: (right: .5em, rest: 1em),
        // stroke: .1pt,
      )[
        #body
      ],
    )
  ]

  #grid(
    columns: 4,
    panel(tint: blue)[Set \ Theory][
      - Basic concepts
      - Set operations
      - Power sets
      - Cardinality
    ],
    panel(tint: green)[Binary \ Relations][
      - Relation properties
      - Equivalence relations
      - Orders
      - Functions
    ],
    panel(tint: purple)[Boolean \ Albegra][
      - Boolean operations
      - Laws and identities
      - Normal forms
      - Logic circuits
    ],
    panel(tint: orange)[Formal \ Logic][
      - Propositional logic
      - Categorial logic
      - Predicate logic
      - Natural deduction
    ],
  )
]

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

== What is a Set?

#definition[
  A _set_ is an unordered collection of distinct objects, called _elements_.
]

#place(right)[
  #cetz.canvas({
    import cetz.draw: *

    // Back
    merge-path(
      stroke: (join: "round", paint: gray, dash: "dashed"),
      line((0, 0), (1, 1), (3, 1), (2, 0)),
    )
    merge-path(
      stroke: (join: "round", paint: gray, dash: "dashed"),
      line((0, 0), (0, 2), (1, 3), (1, 1)),
    )
    merge-path(
      stroke: (join: "round", paint: gray, dash: "dashed"),
      line((1, 3), (3, 3), (3, 1)),
    )

    // Inside
    content((1.5, 2.2), text(size: 4em)[#emoji.cat.face])
    content((2.2, 1.5), text(size: 4em)[#emoji.cat.face.laugh])
    content((1.2, 1.2), text(size: 4em)[#emoji.cat.face.shock])

    // Front
    merge-path(
      fill: blue.transparentize(80%),
      stroke: (join: "round"),
      line((0, 2), (1, 3), (3, 3), (2, 2), close: true),
    )
    merge-path(
      fill: red.transparentize(80%),
      stroke: (join: "round"),
      line((2, 0), (2, 2), (3, 3), (3, 1), close: true),
    )
    merge-path(
      fill: green.transparentize(80%),
      stroke: (join: "round"),
      line((0, 0), (0, 2), (2, 2), (2, 0), close: true),
    )
  })
]

#Block(color: blue)[
  Think of a set as a _"box"_ or _"bag"_ containing objects where:
  - The _order_ doesn't matter.
  - Each object appears _only once_ (no duplicates).
  - We can check if an object is _directly_ inside or not.

  *Note:* A set _can_ contain other sets.
  Nested set is considered a _single_ object.
]

*Basic notation:*
Sets are written within _curly braces_: ${...}$.

We use uppercase letters ($A, B, C, dots$) to denote sets and lowercase letters ($a, b, c, dots$) for their elements.

#example[
  $A = {5, triangle, #emoji.bird}$ is a set containing _three_ distinct elements: the number 5, a triangle, and a birb#footnote[A _birb_ is a _small bird_. Here, we assume it is distint from the number 5 and triangle.].
]

== Examples of Sets

#example[Simple sets][
  - $P = {2, 3, 5, 7, 11, 13}$ --- set of first six prime numbers
  - $E = {2, 4, 6, 8, 10, ...}$ --- _infinite_ set of even positive integers
  - $F = {#emoji.apple, #emoji.banana, #emoji.grapes}$ --- set of fruits
  - $C = {pi, e, sqrt(2), phi}$ --- set of famous mathematical constants
]

#example[Special sets][
  - $emptyset = {}$ --- the _empty set_ (contains no elements)
  - ${emptyset}$ --- _singleton_ set containing the empty set as its only element
  - $frak(U) = {...}$ -- the _universal set_ (contains all things in the considered universe)
]

#example[Nested sets][
  - $N = { {1, 2}, {3, 4} }$ --- set containing _two_ sets as elements
  - $M = \{ underbracket(emptyset, 1), underbracket({#emoji.heart}, 2), underbracket({a, {b, {c}}}, 3) }$ --- set with _three_ elements: (1) empty set, (2) singleton, (3) nested set
]

== Set Membership

We can check if an object is an _element_ of a set or not using the symbols $in$ and $notin$.
- $a in A$ means "$a$ is _an element of_ $A$"
- $a notin A$ means "$a$ is _not an element of_ $A$"

#example[
  Let $A = {42, #emoji.koala, #emoji.bread}$.
  - $#emoji.koala in A$ is #True, since the koala is indeed one of the elements of $A$.
  - $#emoji.penguin in A$ is #False, denoted as "$#emoji.penguin notin A$", since there is _no_ penguin in $A$.
]

#example[
  Let $B = {a, {b}}$.
  - $a in B$ is #True --- the element $a$ is directly in $B$
  - $b in B$ is #False --- the element $b$ is _not_ directly in $B$ (it's inside the nested set ${b}$)
  - ${b} in B$ is #True --- the nested set ${b}$ itself is a direct element of $B$
]

#note[
  Membership operator ($in$) only checks _direct_ elements, not what's inside nested sets.
]

== Urelements vs Sets Only

#definition[
  _Urelements_#footnote[From the German prefix _ur-_ meaning "primordial" (primitive)] are objects that:
  - Are _not_ sets themselves.
  - Can be _elements_ of sets.
  - Have no internal structure that set theory can examine.

  #examples[numbers, people, physical objects, symbols.]
]

#definition[
  In _pure set theory_:
  - _Everything is a set_ --- no urelements allowed.
  - Numbers, functions, relations are all constructed from sets.
  - Even "primitive" objects like 0, 1, 2 are defined as specific sets.
]

#pagebreak()

#grid(
  columns: 2,
  column-gutter: 1em,
  [
    *With Urelements:*
    - $A = {1, 2, #emoji.cat}$
    - 1 and 2 are numbers (urelements)
    - $#emoji.cat$ represents some object
    - Natural and intuitive
  ],
  [
    *Pure Sets Only:*
    - $0 = emptyset$
    - $1 = {emptyset} = {0}$
    - $2 = {emptyset, {emptyset}} = {0, 1}$
    - _Everything_ built from $emptyset$
  ],
)

#note[
  For this course, we'll often use urelements for intuitive examples, but remember that everything _can_ be constructed as pure sets in formal mathematics.
]

== The Extensionality Principle

#definition[
  Two sets are _equal_, denoted $A = B$, if and only if they have exactly the same elements.

  Formally: $A = B$ iff $forall x. thin (x in A iff x in B)$

  Equivalently: $A = B$ iff $A subset.eq B$ and $B subset.eq A$
]

#note[
  This is actually one of the fundamental _axioms_ of set theory!
]

#example[
  All of these represent the _same set_:

  #align(center)[
    #cetz.canvas({
      let w = 1.8
      let h = 1
      let gap = 1

      let box-style = (
        fill: blue.lighten(80%),
        stroke: 1pt + blue.darken(20%),
        radius: .2,
      )

      let draw-box(x, y) = {
        draw.rect((x, y), (x + w, y + h), ..box-style)
      }
      let draw-content(x, y, body) = {
        draw.content((x, y), text(size: 1.2em, body))
      }
      let draw-label(x, y, body) = {
        draw.content((x, y), text(size: .9em, body), anchor: "north", padding: .2)
      }

      let draw-set(x, y, body, label) = {
        draw-box(x, y)
        draw-content(x + w / 2, y + h / 2, body)
        draw-label(x + w / 2, y, label)
      }

      let x = 0
      draw-set(x, 0)[${a, b}$][normal form]

      x += w
      draw.content((x + gap / 2, h / 2), [$=$])

      x += gap
      draw-set(x, 0)[${b, a}$][different order]

      x += w
      draw.content((x + gap / 2, h / 2), [$=$])

      x += gap
      draw-set(x, 0)[${a, b, b}$][with duplicate]

      x += w
      draw.content((x + gap / 2, h / 2), [$=$])

      x += gap
      draw-set(x, 0)[${b, a, b}$][reorder + duplicates]
    })
  ]
]

#Block(color: yellow)[
  The extensionality principle makes set equality _well-defined_ and ensures that the representation of a set doesn't affect its identity --- only its _content_ matters.
]

== Set-Builder Notation

#definition[
  A set can be defined using _set-builder notation_ (_set comprehension_):
  $ A = { x | P(x) } $
  meaning "the set of all $x$ such that the property $P(x)$ holds".
]

#example[
  $A = { x | x in NN "and" x > 5 } = {6, 7, 8, dots}$ is the set of natural numbers greater than 5.
]

#example[
  $S = { x^2 | x "is prime" } = {4, 9, 25, 49, dots}$ is the set of squares of prime numbers#footnote[*Note:* $1$ _is not_ a prime number.].
]

#example[
  $QQ = { a "/" b | a in ZZ, b in NN, b != 0 }$ is the set of rational numbers (fractions).
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
  For example, $BB^* = { epsilon, 0, 1, 00, 01, 10, 11, 000, 001, 010, ..., 0000, dots }$, where $epsilon$ is the _empty string_.
]

#example[
  The set $A^omega$ of _infinite sequences_ over $A$.
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
    text(fill: blue.darken(20%))[Bertrand Russell],
  )
]

Suppose a set can be either _"normal"_ or _"unusual"_.
- A set is considered _normal_ if it does _not contain itself_ as an element. That is, $A notin A$.
- Otherwise, it is _unusual_. That is, $A in A$.

*Note:* being "normal" or "unusual" is a predicate $P(x)$ that can be applied to any set $x$.

#Block(
  color: yellow,
  inset: 0pt,
  outset: .5em,
)[
  Consider the set of _all normal sets_: $R = { A | A notin A }$.
]

The paradox arises when we ask: #strong[Is $R$ a normal set?]
- Suppose $R$ is _normal_. By its definition, $R$ must be an element of $R$, so $R in R$. But elements of $R$ are normal sets, and normal sets do not contain themselves. So $R notin R$. Contradiction.
- Suppose $R$ is _unusual_. This means $R$ contains itself, so $R in R$. But the definition of $R$ only includes sets that do _not_ contain themselves. So $R$ cannot be a member of $R$, i.e. $R notin R$. Contradiction.

A contradiction is reached in _both_ cases.
The only possible conclusion is that #strong[the set $R$ cannot exist].

This paradox showed that _unrestricted comprehension_ --- the ability to form a set from any arbitrary property --- is logically inconsistent.
How can we fix this?..

== From Naive to Axiomatic Set Theory

#Block(
  color: green,
  inset: 5pt,
)[
  #block(
    stroke: (bottom: 0.4pt),
    outset: (bottom: .3em),
  )[*Historical Note*]

  #set text(size: 0.8em)
  #set par(justify: true)

  *Georg Cantor* developed _naive set theory_ in the late 19th century, which *David Hilbert* famously called "a~paradise from which no one shall expel us".
  This intuitive approach revolutionized mathematics by providing a foundation for _infinite_ sets and real analysis.

  However, paradise was short-lived.
  In 1901, *Bertrand Russell* discovered his famous paradox, showing that unrestricted set formation leads to _contradictions_.
  This crisis motivated Russell and *Alfred Whitehead* to write _"Principia Mathematica"_ (1910-1913), attempting to rebuild mathematics on _logical foundations_.

  The modern solution came through _axiomatic set theory_: *Ernst Zermelo* (1908) and *Abraham Fraenkel* (1922) independently developed the _ZFC_ axiom system, providing the rigorous foundation we use today.
  Their work transformed Cantor's intuitive paradise into a mathematically _consistent_ framework.
]

#align(center)[
  #table(
    columns: 3,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([Criterion], [Naive], [Axiomatic]),
    [Set formation], [_Any collection_ of objects], [From _existing_ sets using _axioms_],
    [Comprehension], [Unrestricted: ${x | P(x)}$], [Restricted: ${x in A | P(x)}$],
    [Distinctions], [Simple and intuitive], [Mathematically rigorous],
    [Consistency], [Leads to _paradoxes_], [Axiomatically _consistent_],
  )
]

== ZFC Axioms

+ *Extensionality*: Sets with the same elements are equal.
+ *Empty Set*: There exists a set $emptyset$ with no elements.
+ *Pairing*: For any $a$ and $b$, there exists a set ${a, b}$.
+ *Union*: For any collection of sets, their union exists.
+ *Power Set*: For any set $A$, the power set $power(A)$ exists.
+ *Infinity*: There exists an infinite set (containing $NN$).
+ *Separation*: From any set $A$ and property $P$, we can form ${x in A | P(x)}$.
+ *Replacement*: If $F$ is a function-like relation, then for any set $A$, the image $F[A]$ exists.
+ *Foundation*: Every non-empty set has a minimal element (prevents self-membership).
+ *Choice*: Every collection of non-empty sets has a choice function.

#note[
  The *Separation* axiom prevents Russell's paradox by only allowing formation of subsets from existing sets, not arbitrary collections.
]

#place(bottom + center)[
  #Block(color: purple)[
    This is just an introductory course, so we won't delve into the formal axioms here, _yet_. \
    We'll use an intuitive approach while being aware of the foundations.
  ]
]


#focus-slide(
  title: "Sets: Basic Concepts",
)

== Size of Sets

#definition[
  The _size_ of a _finite_ set $X$, denoted $abs(X)$, is the number of elements it contains.
]

#examples[
  - Let $A = {#emoji.planet, #emoji.dino, #emoji.violin}$, then $abs(A) = 3$, since $A$ contains _exactly 3_ elements.
  - Let $B = {#emoji.kiwi, #emoji.kiwi, #emoji.kiwi}$, then $abs(B) = 1$, since $B$ contains _only one unique_ element (the kiwi).
  - $abs(emptyset) = 0$, since the _empty_ set contains _no elements_.
  - $abs(NN) = infinity$, since there are _infinitely many_ natural numbers.
  - $abs(RR) = infinity$, since there are _infinitely many_ real numbers.
]

#Block(color: yellow)[
  Later, we will explore _infinite_ sets and different "types of infinity" (_countable_ vs _uncountable_) in more detail.
  For now, we focus on _finite_ sets only, or treat infinite sets informally and naively.
]

== Subsets

#definition[
  A set $A$ is a _subset_ of $B$, denoted $A subset.eq B$, if every element of $A$ is also an element of $B$.
  - Formally, $A subset.eq B iff forall x. thin (x in A) imply (x in B)$.
  - If $A$ is not a subset of $B$, we write $A subset.eq.not B$.
  - If $A subset.eq B$ and $A neq B$, we say $A$ is a _proper_ (or _strict_) _subset_ of $B$, denoted $A subset B$ or $A subset.neq B$.
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

== Euler Circles

#definition[
  _Euler diagram_ is a graphical representation of sets and their relationships (subset, intersecting, disjoint) using closed shapes (usually circles).
]

#align(center)[
  #grid(
    columns: 2,
    column-gutter: 2em,
    align: left + horizon,
    [
      #set text(size: 1.5em)
      #cetz.canvas({
        import cetz.draw: *
        circle((0, 0), radius: 1, fill: green.transparentize(80%), name: "A")
        circle((0, 0.5), radius: (1.5, 2), fill: blue.transparentize(80%), name: "B")
        circle((3, 0.5), radius: 1, fill: red.transparentize(80%), name: "C")
        content((-0.3, -0.4), [$1$])
        content((0.3, -0.2), [$2$])
        content((0.4, .5), [$3$])
        content((-0.5, 1.7), [$4$])
        content((0.4, 1.6), [$5$])
        content((2.5, 0.7), [$6$])
        content((3.1, 0.0), [$7$])
        content((3.4, 0.8), [$8$])
        content("A.north-west", anchor: "north-west", padding: .1, text(fill: green.darken(20%))[$A$])
        content("B.north-east", anchor: "south-west", padding: .1, text(fill: blue.darken(20%))[$B$])
        content("C.south", anchor: "north", padding: .2, text(fill: red.darken(20%))[$C$])
      })
    ],
    [
      - $A subset.eq B subset.eq.not C$

      - $A = {1,2,3} subset.eq B$

      - $B = {1,2,3,4,5}$

      - $C = {6,7,8}$

      - $B intersect C = emptyset$
    ],
  )
]

== Set Partitions

#definition[
  A _partition_ of a set $M$ is a collection of non-empty, pairwise-disjoint subsets whose union is~$M$.
  Elements of the partition are called _blocks_ or _cells_.
]

// TODO: visualize set partition

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
    $ underbrace(2 times 2 times dots times 2, n "times") = 2^n $
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

  The total number of subsets of $A$ is the _sum_ of their sizes: $abs(power(A)) = 2^k + 2^k = 2 dot 2^k = 2^(k+1) = 2^abs(A)$.
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

== Venn Diagrams

#definition[
  A _Venn diagram_ is a visual representation of sets and their relationships using overlapping circles.
  Each circle represents a set, and overlapping regions show intersections.
]

#align(center)[
  #set text(1.5em)
  #cetz.canvas({
    import cetz.draw: *

    scale(150%)

    cetz-venn.venn3(
      a-fill: blue.transparentize(80%),
      b-fill: yellow.transparentize(80%),
      ab-fill: green.transparentize(80%),
      c-fill: red.transparentize(80%),
      ac-fill: purple.transparentize(80%),
      bc-fill: orange.transparentize(80%),
      abc-fill: gray.transparentize(80%),
      a-stroke: 1pt + blue.darken(20%),
      b-stroke: 1pt + yellow.darken(20%),
      c-stroke: 1pt + red.darken(20%),
      abc-stroke: 1pt + gray.darken(20%),
      padding: 0.3,
      name: "venn",
    )

    content("venn.a", [$A$])
    content("venn.b", [$B$])
    content("venn.c", [$C$])
    // content("venn.ab", text(size: 0.5em)[$A intersect B$])
    // content("venn.ac", text(size: 0.5em)[$A intersect C$])
    // content("venn.bc", text(size: 0.5em)[$B intersect C$])
    // content("venn.abc", text(size: 0.3em)[$A intersect B intersect C$])
    content("venn.not-abc", text(0.7em)[$overline(A union B union C)$], anchor: "south-west")

    line("venn.bc", (rel: (2.5, -1.2)), mark: (start: "o", fill: black), name: "arrow-bc")
    content("arrow-bc.end", [$(B intersect C) without A$], anchor: "west", padding: .1)

    line("venn.ac", (rel: (-2.5, -1.2)), mark: (start: "o", fill: black), name: "arrow-ac")
    content("arrow-ac.end", [$(A intersect C) without B$], anchor: "east", padding: .1)

    line((rel: (0, 0.1), to: "venn.ab"), (rel: (-2.3, .7)), mark: (start: "o", fill: black), name: "arrow-ab")
    content("arrow-ab.end", [$(A intersect B) without C$], anchor: "east", padding: .1)

    line("venn.abc", (rel: (2.5, .3)), mark: (start: "o", fill: black), name: "arrow-abc")
    content("arrow-abc.end", [$A intersect B intersect C$], anchor: "west", padding: .1)
  })
]

== Venn Diagrams vs Euler Circles

#align(center + horizon)[
  #grid(
    columns: 2,
    align: left + horizon,
    column-gutter: 1em,
    [
      #set text(1.5em)
      #cetz.canvas({
        import cetz.draw: *

        let x = 0.7
        let r = 1.5
        let r2 = 0.5
        circle((-x, 0), radius: r, fill: blue.transparentize(90%))
        circle((x, 0), radius: r, fill: yellow.transparentize(90%))
        circle((0, 0), radius: r2, fill: red.transparentize(80%))

        let t = 1.4
        content((-t, 0))[$1$]
        content((t, 0))[$2$]
        content((0, 0))[$3$]
      })
    ],
    [
      #set enum(numbering: "(1)")
      + people who know what a Venn diagram is
      + people who know what an Euler diagram is
      + people who know the difference
    ],
  )
]

== Operations on Sets

#table(
  columns: 4,
  align: (left, right, left, center).map(x => x + horizon),
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header([Operation], [Notation], [Formal definition], [Venn diagram]),

  [Union],
  $A union B$,
  ${ x | x in A or x in B }$,
  [
    #draw-venn2(
      a-fill: purple.transparentize(80%),
      b-fill: purple.transparentize(80%),
      ab-fill: purple.transparentize(80%),
    )
  ],

  [Intersection],
  $A intersect B$,
  ${ x | x in A and x in B }$,
  [
    #draw-venn2(
      ab-fill: purple.transparentize(80%),
    )
  ],

  [Difference],
  $A setminus B$,
  ${ x | x in A and x notin B }$,
  [
    #draw-venn2(
      a-fill: purple.transparentize(80%),
    )
  ],

  [Symmetric diff.],
  $A symdiff B$,
  $(A setminus B) union (B setminus A)$,
  [
    #draw-venn2(
      a-fill: purple.transparentize(80%),
      b-fill: purple.transparentize(80%),
    )
  ],

  [Complement],
  [$overline(A)$ or $A^c$],
  ${ x | x notin A }$,
  [
    #draw-venn2(
      not-ab-fill: purple.transparentize(80%),
      padding: .2,
      not-ab-stroke: 1pt + purple.darken(20%),
    )
  ],
  // [Power set], [$2^A$ or $power(A)$], ${ S | S subset.eq A }$, [],
)

== Laws of Set Operations

For any sets $A$, $B$, $C$, and the universal set $U$:

#columns(2)[
  *Commutative Laws:*
  - $A union B = B union A$
  - $A intersect B = B intersect A$

  *Associative Laws:*
  - $(A union B) union C = A union (B union C)$
  - $(A intersect B) intersect C = A intersect (B intersect C)$

  *Distributive Laws:*
  - $A union (B intersect C) = (A union B) intersect (A union C)$
  - $A intersect (B union C) = (A intersect B) union (A intersect C)$

  #colbreak()

  *De Morgan's Laws:*
  - $overline(A union B) = overline(A) intersect overline(B)$
  - $overline(A intersect B) = overline(A) union overline(B)$

  *Identity Laws:*
  - $A union emptyset = A$, $A intersect U = A$
  - $A intersect emptyset = emptyset$, $A union U = U$

  *Complement Laws:*
  - $A union overline(A) = U$, $A intersect overline(A) = emptyset$
  - $overline(overline(A)) = A$ (double complement)
]


#focus-slide(
  title: "Tuples, Pairs, and Products",
)

== Tuples

#definition[
  A _tuple_ is a finite ordered collection of elements, denoted $(a_1, a_2, dots, a_n)$.

  A tuple of length $n$ is called an _n-tuple_.
]

#example[
  $(42, #emoji.crab, #emoji.cat.face.angry, #emoji.kiwi)$ is a 4-tuple.
]

#definition[
  Two tuples are _equal_, denoted $(a_1, a_2, dots, a_n) = (b_1, b_2, dots, b_m)$, if and only if they have the same length ($n = m$) and corresponding elements are equal ($a_i = b_i$ for all $1 leq i leq n$).
]

#example[
  $(#emoji.owl, #emoji.owl) != (#emoji.owl, #emoji.owl, #emoji.owl)$, these tuples are _not equal_ because they have _different lengths_.
]

#example[
  $(#emoji.ram, #emoji.goat, #emoji.sheep) != (#emoji.sheep, #emoji.ram, #emoji.goat)$, these tuples are _not equal_ because the _order_ of elements _matters_.
]

#example[
  $(#emoji.fox, #emoji.fox) != (#emoji.fox, ) != #emoji.fox != {#emoji.fox}$, these are _all different_ objects: a 2-tuple, a 1-tuple, an~urelement, and a singleton~set.
]

== Ordered Pairs

#definition[
  An ordered pair $pair(a, b)$ is a special 2-tuple, defined#footnote[Kuratowski's definition is the most cited and now-accepted definition of an ordered pair. For others, see #link("https://en.wikipedia.org/wiki/Ordered_pair#Defining_the_ordered_pair_using_set_theory")[wiki].] as:
  $ pair(a, b) eq.def { {a}, {a, b} } $
]

#example[
  $pair(#emoji.pumpkin, #emoji.mage) != pair(#emoji.mage, #emoji.pumpkin)$, these are different ordered pairs.
]

#example[
  $pair(#emoji.cactus, #emoji.cactus) != (#emoji.cactus,) != #emoji.cactus != {#emoji.cactus}$, these are all different objects: an ordered pair, a 1-tuple, an~urelement, and a singleton~set.

  #note[
    $pair(#emoji.cactus, #emoji.cactus) = {{#emoji.cactus}}$, using Kuratowski's definition:
    $
      pair(#emoji.cactus, #emoji.cactus)
      = { {#emoji.cactus}, \{underbracket(#emoji.cactus, "same"), underbracket(#emoji.cactus, "same")\} }
      = { overbrace({#emoji.cactus}, "equal"), overbrace({underbracket(#emoji.cactus)}, "equal") }
      = { overbrace({#emoji.cactus}) }
    $
  ]
]

== $n$-Tuples as Nested Ordered Pairs

#definition[
  An _n-tuple_ $(a_1, a_2, dots, a_n)$ can be defined recursively using ordered pairs:
  - The 0-tuple (empty tuple) is represented by the empty set $emptyset$.
  - An $n$-tuple, for $n > 0$, is an ordered pair of its first element and the remaining $(n-1)$-tuple:
    $
      (a_1, a_2, dots, a_n) eq.def pair(a_1, (a_2, dots, a_n))
    $

  This gives the following _recursive structure_:
  $
    (a_1, a_2, dots, a_n) = pair(a_1, pair(a_2, pair(dots, pair(a_n, emptyset)...)))
  $
]

#examples[
  - $(1, 2, 3) = pair(1, pair(2, pair(3, emptyset)))$
  - $(#emoji.cat.face.angry, #emoji.cat.face.shock, #emoji.cat.face.heart, #emoji.cat.face.laugh) = pair(#emoji.cat.face.angry, pair(#emoji.cat.face.shock, pair(#emoji.cat.face.heart, pair(#emoji.cat.face.laugh, emptyset))))$
]

#note[
  _Alternatively_, we could "peel off" the _last_ element instead of the first:
  $
    (a_1, a_2, dots, a_n) eq.def pair((a_1, a_2, dots, a_(n-1)), a_n)
  $

  // This would yield _another valid definition_ of an $n$-tuple, with a different recursive structure:
  // $
  //   (a_1, a_2, dots, a_n) = pair(pair(pair(...pair(emptyset, a_1), a_2), dots), a_n)
  // $
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
  The _n-fold Cartesian product_ (also known as _Cartesian power_) of a set $A$ is defined as:
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

The Cartesian product $A times B$ can be visualized as a region on the coordinate plane $RR^2$, where each point $pair(a, b)$ represents an element of the product.

#example[
  Let $A = {1, 2, 3}$ and $B = {1, 2}$, then $A times B$ consists of six points:
  $
    A times B = {1,2,3} times {#Red[1],#Green[2]} = { pair(1, #Red[1]), pair(1, #Green[2]), pair(2, #Red[1]), pair(2, #Green[2]), pair(3, #Red[1]), pair(3, #Green[2]) }
  $

  Visually, these points can be arranged in a _grid pattern_:
  #align(center)[
    #cetz.canvas({
      import cetz.draw: *

      let A = (1, 2, 3)
      let B = (1, 2)

      let max-x = calc.max(..A)
      let max-y = calc.max(..B)

      // Draw the grid and axes
      draw-grid(max-x, max-y)
      draw-x-axis(max-x)
      draw-y-axis(max-y)
      draw-origin()

      // Draw the points in A x B
      for a in A {
        for b in B {
          draw.circle((a, b), radius: 0.1, fill: blue, stroke: blue)
          draw.content((a, b), anchor: "north", padding: .2, text(size: 0.6em)[$pair(#a, #b)$])
        }
      }
    })
  ]
]

#pagebreak()

#let example-data-2 = (
  A: (1, 4),
  B: (1, 3),
)

#example[
  #let (A, B) = example-data-2
  #let (Al, Ar) = A
  #let (Bl, Br) = B
  //
  If $A = [Al, Ar)$ and $B = (Bl, Br]$, then $A times B$ represents the _rectangular region_:
  $
    { pair(x, y) | Al <= x < Ar "and" Bl < y <= Br }
  $
]

#align(center + horizon)[
  #cetz.canvas({
    // Data for this plot
    let (A, B) = example-data-2
    let (Al, Ar) = A
    let (Bl, Br) = B

    let max-x = Ar + 1
    let max-y = Br

    // Draw the grid and axes
    draw-grid(max-x, max-y)
    draw-x-axis(max-x)
    draw-y-axis(max-y)
    draw-origin()

    // Set A: [1, 4) on x-axis
    draw.line((Al, -0.7), (Ar, -0.7), stroke: 3pt + blue)
    draw.circle((Al, -0.7), radius: 0.1, fill: blue, stroke: 1.5pt + blue) // closed at 1
    draw.circle((Ar, -0.7), radius: 0.1, fill: white, stroke: 1.5pt + blue) // open at 4
    draw.content(
      ((Al + Ar) / 2, -0.7),
      text(fill: blue)[$A = \[Al; Ar\)$],
      anchor: "north",
      padding: 0.2,
    )

    // Set B: (1, 3] on y-axis
    draw.line((-0.7, Bl), (-0.7, Br), stroke: 3pt + blue)
    draw.circle((-0.7, Bl), radius: 0.1, fill: white, stroke: 1.5pt + blue) // open at 2
    draw.circle((-0.7, Br), radius: 0.1, fill: blue, stroke: 1.5pt + blue) // closed at 4
    draw.content(
      (-0.9, (Bl + Br) / 2),
      text(fill: blue)[$B = \(Bl; Br\]$],
      angle: 90deg,
      anchor: "south",
    )

    // Cartesian product A × B (filled rectangle)
    draw.rect((Al, Bl), (Ar, Br), fill: blue.transparentize(80%), stroke: none)

    // Boundary of A × B
    draw.line((Al, Br), (Ar, Br), stroke: (paint: blue, thickness: 2pt)) // top
    draw.line((Ar, Br), (Ar, Bl), stroke: (paint: blue, thickness: 2pt, dash: "dashed")) // right
    draw.line((Ar, Bl), (Al, Bl), stroke: (paint: blue, thickness: 2pt, dash: "dashed")) // bottom
    draw.line((Al, Bl), (Al, Br), stroke: (paint: blue, thickness: 2pt)) // left

    // Corner points
    draw.circle((Al, Br), radius: 0.1, fill: blue, stroke: 1.5pt + blue) // (top-left) included
    draw.circle((Ar, Br), radius: 0.1, fill: white, stroke: 1.5pt + blue) // (top-right) excluded
    draw.circle((Ar, Bl), radius: 0.1, fill: white, stroke: 1.5pt + blue) // (bottom-right) excluded
    draw.circle((Al, Bl), radius: 0.1, fill: white, stroke: 1.5pt + blue) // (bottom-left) excluded

    // Label
    draw.content(
      ((Al + Ar) / 2, (Bl + Br) / 2),
      $A times B$,
      frame: "rect",
      stroke: none,
      fill: blue.transparentize(80%),
      padding: 0.1,
    )
    draw.content(
      (Al, max-y + 0.4),
      $#text(blue)[$A times B$] = \[Al; Ar\) times \(Bl , Br\]$,
      anchor: "south-west",
    )
  })
]

#pagebreak()

#let example-data-3 = (
  A: (1, 5),
  B: (1, 4),
  C: (2, 4),
  D: (2, 3),
)

#example[
  #let (
    A: (Al, Ar),
    B: (Bl, Br),
    C: (Cl, Cr),
    D: (Dl, Dr),
  ) = example-data-3
  The set difference $(A times B) setminus (C times D)$ where:
  - $A times B = \[Al; Ar\] times \[Bl; Br\]$ (outer rectangle)
  - $C times D = \(Cl; Cr\) times \(Dl; Dr\]$ (inner rectangle to subtract)

  #block(width: 40%)[
    The resulting set is visualized on the right as the blue-shaded area with blue (outer) and orange (inner) boundaries.
  ]
]

#place(right + bottom)[
  #cetz.canvas({
    // Data for this plot
    let (A, B, C, D) = example-data-3
    let (Al, Ar) = A
    let (Bl, Br) = B
    let (Cl, Cr) = C
    let (Dl, Dr) = D

    let max-x = Ar
    let max-y = Br

    // Draw the grid and axes
    draw-grid(max-x, max-y)
    draw-x-axis(max-x)
    draw-y-axis(max-y)
    draw-origin()

    // Set A: on x-axis
    draw.line((Al, -0.7), (Ar, -0.7), stroke: 3pt + blue)
    draw.circle((Al, -0.7), radius: 0.1, fill: white, stroke: 1.5pt + blue) // open at 1
    draw.circle((Ar, -0.7), radius: 0.1, fill: blue, stroke: 1.5pt + blue) // closed at 5
    draw.content(
      ((Al + Ar) / 2, -0.7),
      text(fill: blue)[$A = \(Al; Ar\]$],
      anchor: "north",
      padding: 0.2,
    )

    // Set B: on y-axis
    draw.line((-0.7, Bl), (-0.7, Br), stroke: 3pt + blue)
    draw.circle((-0.7, Bl), radius: 0.1, fill: white, stroke: 1.5pt + blue) // open at 1
    draw.circle((-0.7, Br), radius: 0.1, fill: blue, stroke: 1.5pt + blue) // closed at 4
    draw.content(
      (-0.7, (Bl + Br) / 2),
      text(fill: blue)[$B = \(Bl; Br\]$],
      angle: 90deg,
      anchor: "south",
      padding: 0.2,
    )

    // Set C: on x-axis (second level)
    draw.line((Cl, -1.5), (Cr, -1.5), stroke: 3pt + orange)
    draw.circle((Cl, -1.5), radius: 0.1, fill: orange, stroke: 1.5pt + orange) // closed at 2
    draw.circle((Cr, -1.5), radius: 0.1, fill: orange, stroke: 1.5pt + orange) // closed at 3
    draw.content(
      ((Cl + Cr) / 2, -1.5),
      text(fill: orange)[$C = \[Cl; Cr\]$],
      anchor: "north",
      padding: 0.2,
    )

    // Set D: on y-axis (second level)
    draw.line((-1.5, Dl), (-1.5, Dr), stroke: 3pt + orange)
    draw.circle((-1.5, Dl), radius: 0.1, fill: white, stroke: 1.5pt + orange) // open at 2
    draw.circle((-1.5, Dr), radius: 0.1, fill: white, stroke: 1.5pt + orange) // open at 3
    draw.content(
      (-1.5, (Dl + Dr) / 2),
      text(fill: orange)[$D = \(Dl; Dr\)$],
      angle: 90deg,
      anchor: "south",
      padding: 0.2,
    )

    let pat = tiling(size: (30pt, 30pt))[
      #place(rect(fill: blue.transparentize(80%)))
      #place(line(start: (0%, 100%), end: (100%, 0%), stroke: (paint: blue.transparentize(50%), thickness: 1pt)))
      #place(line(start: (-10%, 10%), end: (10%, -10%), stroke: (paint: blue.transparentize(50%), thickness: 1pt)))
      #place(line(start: (90%, 110%), end: (110%, 90%), stroke: (paint: blue.transparentize(50%), thickness: 1pt)))
    ]

    // A × B (outer rectangle)
    // draw.rect((1, 1), (5, 4), fill: blue.transparentize(80%), stroke: none)
    draw.rect((Al, Bl), (Ar, Br), fill: pat, stroke: none)

    // C × D (inner rectangle)
    draw.rect((Cl, Dl), (Cr, Dr), fill: white, stroke: 1pt + white)

    // Outer boundary
    draw.line((Al, Br), (Ar, Br), stroke: 2pt + blue) // top
    draw.line((Ar, Br), (Ar, Bl), stroke: 2pt + blue) // right
    draw.line((Ar, Bl), (Al, Bl), stroke: (thickness: 2pt, paint: blue, dash: "dashed")) // bottom
    draw.line((Al, Bl), (Al, Br), stroke: (thickness: 2pt, paint: blue, dash: "dashed")) // left

    // Inner boundary (hole)
    draw.line((Cl, Dl), (Cr, Dl), stroke: 2pt + orange) // bottom
    draw.line((Cr, Dl), (Cr, Dr), stroke: (thickness: 2pt, paint: orange, dash: "dashed")) // right
    draw.line((Cr, Dr), (Cl, Dr), stroke: 2pt + orange) // top
    draw.line((Cl, Dr), (Cl, Dl), stroke: (thickness: 2pt, paint: orange, dash: "dashed")) // left

    // Corner points for outer rectangle
    draw.circle((Ar, Br), radius: 0.1, fill: blue, stroke: 1.5pt + blue) // (top-right) included
    draw.circle((Ar, Bl), radius: 0.1, fill: white, stroke: 1.5pt + blue) // (bottom-right) excluded
    draw.circle((Al, Bl), radius: 0.1, fill: white, stroke: 1.5pt + blue) // (bottom-left) excluded
    draw.circle((Al, Br), radius: 0.1, fill: white, stroke: 1.5pt + blue) // (top-left) excluded

    // Corner points for inner rectangle
    draw.circle((Cl, Dl), radius: 0.1, fill: orange, stroke: 1.5pt + orange) // (bottom-left) included
    draw.circle((Cr, Dl), radius: 0.1, fill: orange, stroke: 1.5pt + orange) // (bottom-right) included
    draw.circle((Cr, Dr), radius: 0.1, fill: orange, stroke: 1.5pt + orange) // (top-right) included
    draw.circle((Cl, Dr), radius: 0.1, fill: orange, stroke: 1.5pt + orange) // (top-left) included

    // Label
    draw.content(
      ((Al + Ar) / 2, Br - 0.5),
      $(A times B) setminus (C times D)$,
      frame: "rect",
      stroke: none,
      fill: blue.transparentize(80%),
      padding: 0.1,
    )
    draw.content(
      (Al, max-y + 0.4),
      $#text(blue)[$(A times B)$] setminus #text(orange)[$(C times D)$] =\ (\(Al; Ar\] times \(Bl; Br\]) setminus (\[Cl; Cr\] times \(Dl; Dr\))$,
      anchor: "south-west",
    )
  })
]


#focus-slide(
  title: "Axiomatic Set Theory",
)

== The ZFC Axiom System

The _Zermelo-Fraenkel axioms with Choice_ (ZFC) form the standard foundation of modern set theory:

#grid(
  columns: 2,
  align: center,
  column-gutter: 1em,
  row-gutter: 0.5em,

  link("https://en.wikipedia.org/wiki/Ernst_Zermelo", box(
    radius: 5pt,
    clip: true,
    stroke: 1pt + blue.darken(20%),
    image("assets/Ernst_Zermelo.jpg", height: 3cm),
  )),
  link("https://en.wikipedia.org/wiki/Abraham_Fraenkel", box(
    radius: 5pt,
    clip: true,
    stroke: 1pt + blue.darken(20%),
    image("assets/Abraham_Fraenkel.jpg", height: 3cm),
  )),

  text(fill: blue.darken(20%))[Ernst \ Zermelo], text(fill: blue.darken(20%))[Abraham\ Fraenkel],
)

#definition[Extensionality][
  Sets with the same elements are equal.
  $
    forall A, B. (forall x. thin x in A iff x in B) imply A = B
  $
]

#definition[Empty Set][
  There exists a set with no elements:
  $
    exists emptyset. forall x. thin x notin emptyset
  $
]

#definition[Pairing][
  For any objects $a$ and $b$, there exists a set containing exactly them:
  $
    forall a, b. exists C. forall x. thin x in C iff (x = a or x = b)
  $
]

#definition[Union][
  For any family of sets, their union exists:
  $
    forall cal(F). exists U. forall x. thin x in U iff exists A in cal(F). thin x in A
  $
]

#definition[Power Set][
  For any set $A$, the set of all its subsets exists:
  $
    forall A. exists power(A). forall X. thin X in power(A) iff X subset.eq A
  $
]

#definition[Infinity][
  There exists an infinite set (intuitively, containing natural numbers):
  $
    exists S. thin emptyset in S and (forall x in S. thin x union {x} in S)
  $
]

#definition[Separation (Subset)][
  From any set and property, we can form the subset of elements satisfying that property:
  $
    forall A. forall P. exists B. forall x. thin x in B iff (x in A and P(x))
  $

  #note[This axiom prevents Russell's paradox by only allowing formation of subsets from existing sets.]
]

#definition[Replacement][
  If $F$ is a function-like relation, then for any set $A$, the image $F[A]$ exists.
]

#definition[Foundation (Regularity)][
  Every non-empty set has a minimal element (prevents sets from containing themselves):
  $
    forall A. thin A != emptyset imply exists x in A. thin A intersect x = emptyset
  $
]

#definition[Choice][
  Every collection of non-empty sets has a choice function:
  $
    forall cal(F). thin (emptyset notin cal(F)) imply exists f. forall A in cal(F). thin f(A) in A
  $
]

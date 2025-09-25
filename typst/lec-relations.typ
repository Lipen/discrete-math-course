#import "theme.typ": *
#show: slides.with(
  title: [Binary Relations],
  subtitle: "Discrete Math",
  date: "Fall 2025",
  authors: "Konstantin Chukharev",
  // dark: true,
)

#show heading.where(level: 1): none

// Show i.e. in italic:
#show "i.e.": set text(style: "italic")

#import "common-lec.typ": *

#let rel(x) = math.class("relation", x)
#let nrel(x) = rel(math.cancel(x))
#let matrel(x) = $bracket.double.l #x bracket.double.r$
#let eqclass(x, R) = $bracket.l #x bracket.r_#R$
#let quotient(M, R) = $#M slash_(#R)$
#let congruent(a, b, n) = $#a equiv #b space (mod #n)$
#let Dom = math.op("Dom")
#let Cod = math.op("Cod")
#let Range = math.op("Range")
#let equinumerous = symbol(math.approx, ("not", math.approx.not))
#let smaller = symbol(math.prec, ("eq", math.prec.eq))
#let covers = $lt.dot$
#let relcomp = rel(";")
#let Join = math.or
#let Meet = math.and
#let nand = $overline(and)$
#let nor = $overline(or)$
#let boolprod = $dot.circle$


#CourseOverviewPage()


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

#note(title: "Notation")[
  If $R subset.eq A times B$, we write "$a rel(R) b$" to mean that element $a in A$ is _related_ to element $b in B$.
]

#Block(
  color: yellow,
  inset: 0pt,
  outset: .5em,
)[
  Formally, $a rel(R) b$ iff $pair(a, b) in R$.
]

#note[
  $R$ is used to denote both the relation itself ($a rel(R) b$) _and_ the set of pairs ($R subset.eq A times B$).
]

#note[
  The _order_ of elements in the pair _matters_: $pair(a, b) in R$ denotes that $a$ is related to $b$, not the other way around, unless there is _another_ pair $pair(b, a)$ in the relation.
]

#example[
  $R = { pair(n, k) | n, k in NN "and" n < k }$
]

#definition[
  - A binary relation $R subset.eq A times B$ on two different sets $A$ and $B$ is called _heterogeneous_.
  - A binary relation $R subset.eq M^2$ on the same set $M$ is called _homogeneous_.
]

== Graph Representation

#definition[
  A homogeneous relation $R subset.eq M^2$ can be represented as a _directed graph_ where:
  - Vertices correspond to elements of $M$
  - There is a directed edge from $x$ to $y$ if $x rel(R) y$, i.e. $pair(x, y) in R$
]

#example[
  For $M = {1, 2, 3}$ and $R = {pair(1, 2), pair(2, 3), pair(1, 3)}$, the graph has vertices ${1, 2, 3}$ and directed edges $1 to 2$, $2 to 3$, and $1 to 3$.
]

#align(center)[
  #cetz.canvas({
    import cetz: draw

    let draw-vertex(pos, name, label) = {
      draw.circle(pos, radius: 0.4, stroke: 1pt, name: name)
      draw.content(pos, label, anchor: "center")
    }

    let draw-edge(start, end, label: none) = {
      draw.line(
        start,
        end,
        stroke: 2pt + blue,
        mark: (end: "stealth", fill: blue),
      )
      if label != none {
        assert(type(label) == dictionary)
        let t = label.at("text")
        let angle = label.at("angle", default: end)
        let anchor = label.at("anchor", default: "south")
        draw.content(
          (start, 50%, end),
          text(fill: blue)[#t],
          angle: angle,
          anchor: anchor,
          padding: 0.2,
        )
      }
    }

    draw-vertex((0, 0), "1", [$1$])
    draw-vertex((2, 0), "2", [$2$])
    draw-vertex((1, 2), "3", [$3$])

    draw-edge("1", "2", label: (
      text: [$1 rel(R) 2$],
      anchor: "north",
    ))
    draw-edge("2", "3", label: (
      text: [$2 rel(R) 3$],
      angle: "2",
      anchor: "south",
    ))
    draw-edge("1", "3", label: (
      text: [$1 rel(R) 3$],
      anchor: "south",
    ))
  })
]

#pagebreak()

#definition[
  A heterogeneous relation $R subset.eq A times B$ can be represented as a _bipartite graph_ where:
  - Vertices in one partition correspond to elements of $A$
  - Vertices in the other partition correspond to elements of $B$
  - There is a directed edge from $a in A$ to $b in B$ if $a rel(R) b$, i.e. $pair(a, b) in R$
]

#example[
  For animals $A = {#emoji.rabbit, #emoji.cat, #emoji.dog}$, food $B = {#emoji.carrot, #emoji.fish}$, and relation $R$ = "likes to eat", we have the bipartite graph with animal vertices on the left side and food vertices on the right side with four edges.
]

#align(center)[
  #cetz.canvas({
    import cetz: draw

    let draw-vertex(pos, name, label, fill: none) = {
      draw.circle(pos, radius: 0.4, stroke: 1pt, fill: fill, name: name)
      draw.content(pos, text(size: 1.2em)[#label], anchor: "center")
    }

    let draw-edge(start, end, label: none, stroke: 1.5pt + blue) = {
      draw.line(
        start,
        end,
        stroke: stroke,
        mark: (end: "stealth", fill: stroke.paint),
      )
      if label != none {
        draw.content(
          (start, 50%, end),
          text(fill: stroke.paint)[#label],
          anchor: "center",
          padding: 0.1,
        )
      }
    }

    // Left partition (animals)
    draw-vertex((-2.5, 1), "rabbit", [$#emoji.rabbit$], fill: green.lighten(80%))
    draw-vertex((-2.5, 0), "cat", [$#emoji.cat$], fill: green.lighten(80%))
    draw-vertex((-2.5, -1), "dog", [$#emoji.dog$], fill: green.lighten(80%))

    // Right partition (food)
    draw-vertex((2.5, 0.7), "carrot", [$#emoji.carrot$], fill: orange.lighten(80%))
    draw-vertex((2.5, -0.7), "fish", [$#emoji.fish$], fill: orange.lighten(80%))

    // Edges representing the "likes to eat" relation
    draw-edge("cat", "fish")
    draw-edge("dog", "fish")
    draw-edge("dog", "carrot")
    draw-edge("rabbit", "carrot")

    // Set labels
    draw.content(
      (-2.5, 1.5),
      text(fill: green.darken(20%), weight: "bold")[Animals ($A$)],
      anchor: "south",
      padding: 0.2,
    )
    draw.content(
      (2.5, 1.2),
      text(fill: orange.darken(20%), weight: "bold")[Food ($B$)],
      anchor: "south",
      padding: 0.2,
    )
  })
]

== Matrix Representation

#definition[
  A binary relation $R subset.eq A times B$ can be represented as a _matrix_ $M_R = matrel(R)$ where:
  - Rows correspond to elements of $A$
  - Columns correspond to elements of $B$
  - $M_R [i,j] = 1$ if $a_i rel(R) b_j$, and $M_R [i,j] = 0$ otherwise
]

#example[
  Let $A = {a, b, c}$, $B = {x, y}$, and $R = {pair(a, x), pair(b, x), pair(c, y)}$.
  The matrix representation is:
  $
    matrel(R) = natrix.bnat(
      1, 0;
      1, 0;
      0, 1
    ) quad "where rows are" {a, b, c} "and columns are" {x, y}
  $
]

== Special Relations

#definition[
  For any set $M$, we define these special relations:
  - _Empty relation_: $emptyset subset.eq M^2$ (no elements are related)
  - _Identity relation_: $I_M = {pair(x, x) | x in M}$ (each element related only to itself)
  - _Universal relation_: $U_M = M^2$ (every element related to every element)
]

#example[
  For $M = {a, b, c}$:
  - Empty: $emptyset$
  - Identity: ${pair(a, a), pair(b, b), (c,c)}$
  - Universal: ${pair(a, a), pair(a, b), pair(a, c) pair(b, a), pair(b, b), pair(b, c), pair(c, a), pair(c, b), pair(c, c)}$ (all 9 pairs)
]

== Operations on Relations

#definition[
  For relations $R, S subset.eq A times B$:
  - _Union_: $R union S = {pair(a, b) | pair(a, b) in R "or" pair(a, b) in S}$
  - _Intersection_: $R intersect S = {pair(a, b) | pair(a, b) in R "and" pair(a, b) in S}$
  - _Complement_: $overline(R) = (A times B) setminus R$
]

#definition[
  For a relation $R subset.eq A times B$, the _inverse_ (or _converse_, or _dual_) relation is:
  $
    R^(-1) = {pair(b, a) | pair(a, b) in R} subset.eq B times A
  $

  #note[
    Other notations include $R^T$ (transpose), $R^C$ (converse), $R^circle.small$ (reciprocal).
  ]
]

#example[
  If $R = {pair(1, x), pair(2, y), pair(2, z)}$, then $R^(-1) = {pair(x, 1), pair(y, 2), pair(z, 2)}$.
]

#example[
  For the usual order relations, the converse is the naively "opposite" order:
  - The converse of "less" is "greater": $class("normal", scripts(<)^T) = class("normal", >)$
  - The converse of "less or equal" is "greater or equal": $class("normal", scripts(<=)^T) = class("normal", >=)$
]


#focus-slide(
  title: "Properties of Relations",
)

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

== Notes on Properties

- Reflexivity and irreflexivity are _not_ mutually exclusive if $M = emptyset$ (both are _vacuously_#footnote[
    A statement "for all $x$ in emptyset, $P(x)$" is considered #True because there are _no counterexamples_ in the empty set.
  ] #True).

- Symmetry and antisymmetry are _not_ mutually exclusive (e.g. identity relation).

- Asymmetry implies irreflexivity and antisymmetry.

== Additional Properties

#definition[
  A relation $R subset.eq M^2$ is:

  - _Coreflexive_ if $R subset.eq I_M$ (only related to themselves, if at all):
    $
      forall x, y in M. thin (x rel(R) y) imply (x = y)
    $

  - _Right Euclidean_ if whenever an element is related to two others, those two are related:
    $
      forall x, y, z in M. thin (x rel(R) y and x rel(R) z) imply (y rel(R) z)
    $

  - _Left Euclidean_ if whenever two elements are both related to a third, they are related to each other:
    $
      forall x, y, z in M. thin (y rel(R) x and z rel(R) x) imply (y rel(R) z)
    $
]

#example[
  - Identity relation $I_M$ is coreflexive.
    Any subset of $I_M$ is also coreflexive.
  - Equality relation "$=$" is left and right Euclidean.
  - "Being in the same equivalence class" is Euclidean in both directions.
]


#focus-slide(
  title: "Equivalence Relations",
)

== Equivalence Relations

#definition[
  A relation $R subset.eq M^2$ is an _equivalence relation_ if it is reflexive, symmetric and transitive.
]

#example[Equality][
  The _identity relation_ $I_M = {pair(x, x) | x in M}$ is an equivalence relation on any set $M$.

  #note[
    The identity relation is just the common equality relation "$=$".
  ]

  *Verification:*
  - *Reflexive:* $x rel(I_M) x$ for all $x in M$ (by definition of $I_M$) #YES
  - *Symmetric:* If $x rel(I_M) y$, then $x = y$, thus $y = x$, so $y rel(I_M) x$ #YES
  - *Transitive:* If $x rel(I_M) y$ and $y rel(I_M) z$, then $x = y = z$, so $x rel(I_M) z$ #YES

  This is the "finest" possible equivalence relation --- it distinguishes every element.
]

== Equivalence Classes

#definition[
  Let $R subset.eq M^2$ be an equivalence relation on a set $M$.
  The _equivalence class_ of an element $x in M$ under $R$ is the set of all elements related to $x$:
  $ eqclass(x, R) = { y in M | x rel(R) y } $
]

#example[Equality][
  For the identity relation $I_M$ on set $M = {a, b, c}$:
  - $eqclass(a, I_M) = {a}$ (only $a$ is equal to $a$)
  - $eqclass(b, I_M) = {b}$ (only $b$ is equal to $b$)
  - $eqclass(c, I_M) = {c}$ (only $c$ is equal to $c$)

  Each element forms its own equivalence class under equality.
]

// TODO: where to include this?..
// #theorem[
//   If $R subset.eq M^2$ is an equivalence relation, then $x rel(R) y$ iff $eqclass(x, R) = eqclass(y, R)$ for all $x, y in M$.
// ]
// TODO: proof (sketch?)

== Examples of Equivalence Relations

#example[Modular arithmetic][
  For any positive integer $n$, _congruence modulo $n$_ on $ZZ$ is defined by:
  $
    congruent(a, b, n) quad "iff" quad n | (b - a)
  $

  *Verification:*
  - *Reflexive:* $congruent(a, a, n)$ since $n | (a - a) iff n | 0$ #YES
  - *Symmetric:* If $congruent(a, b, n)$, then $n | (b - a) iff n | (a - b)$, thus $congruent(b, a, n)$ #YES
  - *Transitive:* If $congruent(a, b, n)$ and $congruent(b, c, n)$, then $n | (b - a)$ and $n | (c - b)$, so #box[$n | ((c - b) + (b - a)) iff n | (c - a)$], thus $congruent(a, c, n)$ #YES

  *Equivalence classes (remainders):*
  Let $n = 5$ and $M = {0, 1, ..., 9}$.
  - $eqclass(0, equiv) = {0, 5} = {x in M | congruent(x, 0, 5)}$
  - $eqclass(1, equiv) = {1, 6} = {x in M | congruent(x, 1, 5)}$
  - $eqclass(2, equiv) = {2, 7} = {x in M | congruent(x, 2, 5)}$
  - $eqclass(3, equiv) = {3, 8} = {x in M | congruent(x, 3, 5)}$
  - $eqclass(4, equiv) = {4, 9} = {x in M | congruent(x, 4, 5)}$
]

#pagebreak()

#example[Same absolute value][
  On $M = {-3, -2, -1, 0, 1, 2, 3}$, define relation $R$ by:
  $
    x rel(R) y quad "iff" quad abs(x) = abs(y)
  $

  *Verification:*
  - *Reflexive:* $abs(x) = abs(x)$ for all $x$ #YES
  - *Symmetric:* If $abs(x) = abs(y)$, then $abs(y) = abs(x)$ #YES
  - *Transitive:* If $abs(x) = abs(y)$ and $abs(y) = abs(z)$, then $abs(x) = abs(z)$ #YES

  *Equivalence classes:*
  - $eqclass(0, R) = {0}$
  - $eqclass(1, R) = eqclass(-1, R) = {-1, 1}$
  - $eqclass(2, R) = eqclass(-2, R) = {-2, 2}$
  - $eqclass(3, R) = eqclass(-3, R) = {-3, 3}$

  Each positive number is equivalent to its negative counterpart.
]

#pagebreak()

#example[Same string length][
  On the set of all finite strings $Sigma^*$ over alphabet $Sigma$, define:
  $
    s_1 rel(R) s_2 quad "iff" quad abs(s_1) = abs(s_2)
  $
  where $abs(s)$ denotes the length of string $s$.

  *Verification:*
  - *Reflexive:* Every string has the same length as itself #YES
  - *Symmetric:* If two strings have the same length, the relation is symmetric #YES
  - *Transitive:* If $abs(s_1) = abs(s_2)$ and $abs(s_2) = abs(s_3)$, then $abs(s_1) = abs(s_3)$ #YES

  *Equivalence classes:* $eqclass(s, R) = {t in Sigma^* | abs(t) = abs(s)}$

  For example, over $Sigma = {a, b}$:
  - $eqclass(epsilon, R) = {epsilon}$ (empty string)
  - $eqclass("a", R) = {"a", "b"}$ (all strings of length 1)
  - $eqclass("ab", R) = {"aa", "ab", "ba", "bb"}$ (all strings of length 2)
]

#pagebreak()

#example[Living in the same city][
  Let $P$ be the set of people, and define relation $R$ by:
  $
    p_1 rel(R) p_2 quad "iff" quad p_1 "and" p_2 "live in the same city"
  $

  *Verification:*
  - *Reflexive:* Every person lives in the same city as themselves #YES
  - *Symmetric:* If person A and B live in the same city, then B and A live in the same city #YES
  - *Transitive:* If A and B live in the same city, and B and C do so, then A and C live in the same city #YES

  *Equivalence classes:* Each equivalence class consists of all people living in the same city.
  - $eqclass("Alice", R)$ = all people living in Alice's city
  - This naturally partitions the population by cities

  *Application:* This relation captures a common social grouping based on location.
]

#pagebreak()

#example[Similarity of triangles][
  Let $T$ be the set of all triangles in the plane. Define relation $sim$ by:
  $
    triangle_1 sim triangle_2 quad "iff" quad triangle_1 "and" triangle_2 "are similar" #footnote[
      Two triangles are similar if their corresponding angles are equal.
    ]
  $

  *Verification:*
  - *Reflexive:* Every triangle is similar to itself #YES
  - *Symmetric:* If triangle $A$ is similar to triangle $B$, then triangle $B$ is similar to triangle $A$ #YES
  - *Transitive:* If $A sim B$ and $B sim C$, then $A sim C$ (similarity is transitive) #YES

  *Equivalence classes:* Each class consists of all triangles with the same shape (but possibly different sizes).
  - All equilateral triangles form one equivalence class
  - All right triangles with legs in ratio 3:4:5 form another equivalence class

  *Geometric significance:* This relation captures the concept of "same shape, different size."
]

#pagebreak()

#example[Rational numbers][
  On the set of ordered pairs $ZZ times (ZZ setminus {0})$, define:
  $
    pair(a, b) sim pair(c, d) quad "iff" quad a dot d = b dot c
  $

  This relation is used to construct rational numbers $QQ$ from integer pairs.

  *Verification:*
  - *Reflexive:* $pair(a, b) sim pair(a, b)$ since $a dot b = b dot a$ #YES
  - *Symmetric:* If $a dot d = b dot c$, then $c dot b = d dot a$ #YES
  - *Transitive:* If $a dot d = b dot c$ and $c dot f = d dot e$, then $a dot f = b dot e$ #YES

  *Equivalence classes:* Each equivalence class represents a rational number.
  - $eqclass(pair(1, 2), sim) = {pair(1, 2), pair(2, 4), pair(3, 6), pair(-1, -2), ...}$ represents $1/2$
  - $eqclass(pair(3, 4), sim) = {pair(3, 4), pair(6, 8), pair(-3, -4), ...}$ represents $3/4$

  *Mathematical significance:* This construction shows how equivalence relations create new mathematical objects (rationals) from simpler ones (integers).
]

== Quotient Sets

#definition[
  The _quotient set_ of $M$ by the equivalence relation $R$ is the set of all equivalence classes:
  $ quotient(M, R) = { eqclass(x, R) | x in M } $
]

#example[
  Consider $M = {0, 1, 2, 3, 4, 5}$ with the equivalence relation "congruent modulo 3":
  $
    congruent(x, y, 3) quad "iff" quad 3 | (x - y)
  $

  *Equivalence classes:*
  - $eqclass(0, equiv) = {0, 3} = {x in M | congruent(x, 0, 3)}$
  - $eqclass(1, equiv) = {1, 4} = {x in M | congruent(x, 1, 3)}$
  - $eqclass(2, equiv) = {2, 5} = {x in M | congruent(x, 2, 3)}$

  *Quotient set:*
  $
    quotient(M, equiv) = { {0, 3}, {1, 4}, {2, 5} }
  $

  Note that $eqclass(3, equiv) = eqclass(0, equiv) = {0, 3}$, so we don't get a new equivalence class, since $quotient(M, R)$ is a _set_.
]

#pagebreak()

#example[
  Let $M = {"a", "ab", "abc", "x", "xy", "z"}$ with equivalence relation $R$ defined by:
  $
    s_1 rel(R) s_2 quad "iff" quad abs(s_1) = abs(s_2)
  $
  where $abs(s)$ denotes the length of string $s$.

  *Equivalence classes by length:*
  - $eqclass("a", R) = {"a", "x", "z"}$ (strings of length 1)
  - $eqclass("ab", R) = {"ab", "xy"}$ (strings of length 2)
  - $eqclass("abc", R) = {"abc"}$ (strings of length 3)

  *Quotient set:*
  $
    quotient(M, R) = { {"a", "x", "z"}, {"ab", "xy"}, {"abc"} }
  $

  This partitions strings by their length, creating 3 equivalence classes.
]

#pagebreak()

#example[Construction of rational numbers][
  Consider the set of ordered pairs $M = ZZ times (ZZ setminus {0})$.

  Define the equivalence relation $sim$ by:
  $
    pair(a, b) sim pair(c, d) quad "iff" quad a dot d = b dot c
  $

  *Equivalence classes:* Each represents a rational number in its "reduced form".

  #table(
    columns: 3,
    align: (left, left, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.6pt) },
    table.header([*Representative*], [*Equivalence Class*], [*Rational Number*]),

    [$pair(1, 2)$], [${pair(1, 2), pair(2, 4), pair(3, 6), pair(-1, -2), pair(-2, -4), ...}$], [$1"/"2$],

    [$pair(0, 1)$], [${pair(0, 1), pair(0, 2), pair(0, -3), pair(0, 7), ...}$], [$0$],

    [$pair(3, 4)$], [${pair(3, 4), pair(6, 8), pair(-3, -4), pair(9, 12), ...}$], [$3"/"4$],

    [$pair(-5, 3)$], [${pair(-5, 3), pair(5, -3), pair(-10, 6), pair(10, -6), ...}$], [$-5"/"3$],
  )

  *Quotient set:* All equivalence classes together form the set of rational numbers:
  $
    QQ := quotient((ZZ times (ZZ setminus {0})), sim) = { eqclass(pair(a, b), sim) | pair(a, b) in ZZ times (ZZ setminus {0}) }
  $

  *Interpretation:*
  Each equivalence class $eqclass(pair(a, b), sim)$ corresponds exactly to the rational number $a/b$.
  - Different representations $(a, b)$ and $(c, d)$ belong to the same equivalence class iff they represent the same fraction: $a/b = c/d$
  - The condition $a dot d = b dot c$ is the cross-multiplication test for fraction equality

  *Operations on the quotient set:*
  We can define arithmetic operations on $QQ$ by:
  $
      eqclass(pair(a, b), sim) + eqclass(pair(c, d), sim) & := eqclass(pair(a d + b c, b d), sim) \
    eqclass(pair(a, b), sim) dot eqclass(pair(c, d), sim) & := eqclass(pair(a c, b d), sim)
  $

  These operations are _well-defined_ because the result doesn't depend on the choice of representatives.

  *Mathematical significance:*
  - This construction shows that $QQ$ is literally _the_ quotient set $quotient(ZZ times (ZZ setminus {0}), sim)$
  - It demonstrates how equivalence relations and quotient sets create new mathematical structures
  - This is the rigorous foundation for rational number arithmetic taught in elementary school
]

#pagebreak()

#example[
  Consider the set of all points in the plane $M = RR^2$ with the equivalence relation:
  $
    pair(x_1, y_1) sim pair(x_2, y_2) quad "iff" quad x_1 + y_1 = x_2 + y_2
  $

  This relation groups points that lie on the same line of the form $x + y = c$ for some constant $c$.

  *Equivalence classes:*
  - $eqclass(pair(0, 0), sim) = {pair(x, y) | x + y = 0}$ (the line $x + y = 0$)
  - $eqclass(pair(1, 0), sim) = {pair(x, y) | x + y = 1}$ (the line $x + y = 1$)
  - $eqclass(pair(0, 2), sim) = {pair(x, y) | x + y = 2}$ (the line $x + y = 2$)

  *Quotient set:*
  $
    quotient(RR^2, sim) = { L_c | c in RR }
  $
  where $L_c = {pair(x, y) | x + y = c}$ is the line with equation $x + y = c$.

  Each equivalence class is an entire line, and the quotient set consists of all such parallel lines.
]

#pagebreak()

#example[
  Let $M = {"apple", "ant", "banana", "bee", "cherry", "cat"}$ with equivalence relation:
  $
    w_1 rel(R) w_2 quad "iff" quad "first letter of" w_1 = "first letter of" w_2
  $

  *Equivalence classes:*
  - $eqclass("apple", R) = {"apple", "ant"}$ (words starting with 'a')
  - $eqclass("banana", R) = {"banana", "bee"}$ (words starting with 'b')
  - $eqclass("cherry", R) = {"cherry", "cat"}$ (words starting with 'c')

  *Quotient set:*
  $
    quotient(M, R) = { {"apple", "ant"}, {"banana", "bee"}, {"cherry", "cat"} }
  $

  This creates a dictionary-like grouping by first letter.
]

#pagebreak()

#example[Trivial quotient sets][

  *Identity relation:* If $R = I_M$ (identity relation), then each element forms its own equivalence class:
  $
    quotient(M, I_M) = { {x} | x in M }
  $
  The quotient set has the same cardinality as the original set.

  *Universal relation:* If $R = M times M$ (universal relation), then all elements are equivalent:
  $
    quotient(M, M times M) = { M }
  $
  The quotient set contains exactly one equivalence class --- the entire set $M$.
]

== Set Partitions

#definition[
  A _partition_ $cal(P)$ of a set $M$ is a family of non-empty, pairwise-disjoint subsets whose union is $M$:
  - (Non-empty) $forall B in cal(P). thin (B != emptyset)$
  - (Disjoint) $forall B_1, B_2 in cal(P). thin (B_1 != B_2) imply (B_1 intersect B_2 = emptyset)$
  - (Cover) $limits(union.big)_(B in cal(P)) B = M$

  Elements of $cal(P)$ are _blocks_ (or _cells_).
]

#example[
  For $M = {0,1,2,3,4,5}$: ${{0,2,4},{1,3,5}}$ and ${{0,5},{1,2,3},{4}}$ are partitions.
]

#let draw-element(pos, anchor, name, label) = {
  import cetz: draw
  draw.circle(pos, radius: 0.1, fill: black, name: name)
  draw.content(name, label, anchor: anchor, padding: 0.2)
}

#align(center)[
  #cetz.canvas(baseline: (0, 0), {
    import cetz: draw

    draw.scale(50%)

    // Set M
    draw.rect((.2, -0.5), (3.8, 3.5), radius: .3)

    // Elements:
    draw-element((1, 2), "south", "0", [$0$])
    draw-element((1, 1), "north", "1", [$1$])
    draw-element((2, 2), "south", "2", [$2$])
    draw-element((2, 1), "north", "3", [$3$])
    draw-element((3, 2), "south", "4", [$4$])
    draw-element((3, 1), "north", "5", [$5$])

    // Partition block {0, 2, 4}:
    draw.rect(
      (0.5, 1.6),
      (3.5, 3.2),
      radius: .3,
      stroke: 1pt + blue,
      fill: blue.transparentize(80%),
    )
    // Partition block {1, 3, 5}:
    draw.rect(
      (0.5, 1.4),
      (3.5, -0.2),
      radius: .3,
      stroke: 1pt + orange,
      fill: orange.transparentize(80%),
    )
  })
  //
  #h(1em)
  //
  #cetz.canvas(baseline: (0, 0), {
    import cetz: draw

    draw.scale(50%)

    // Set M
    draw.rect((.2, -0.5), (3.8, 3.5), radius: .3)

    // Elements:
    draw-element((1, 2), "south", "0", [$0$])
    draw-element((1, 1), "north", "1", [$1$])
    draw-element((2, 2), "south", "5", [$5$])
    draw-element((2, 1), "north", "2", [$2$])
    draw-element((3, 2), "south", "4", [$4$])
    draw-element((3, 1), "north", "3", [$3$])

    // Partition block {0, 5}:
    draw.rect(
      (0.5, 1.6),
      (2.4, 3.2),
      radius: .3,
      stroke: 1pt + blue,
      fill: blue.transparentize(80%),
    )
    // Partition block {1, 2, 3}:
    draw.rect(
      (0.5, 1.4),
      (3.5, -0.2),
      radius: .3,
      stroke: 1pt + orange,
      fill: orange.transparentize(80%),
    )
    // Partition block {4}:
    draw.rect(
      (2.6, 1.6),
      (3.5, 3.2),
      radius: .3,
      stroke: 1pt + green.darken(20%),
      fill: green.darken(20%).transparentize(80%),
    )
  })
]

== Partitions and Equivalence Relations

#theorem[Equivalences $<=>$ Partitions][
  Each equivalence relation $R$ on $M$ yields the partition #box[$cal(P)_R = { eqclass(x, R) | x in M }$].
  Each partition $cal(P)$ yields an equivalence $R_cal(P)$ given by $pair(x, y) in R_cal(P)$ iff $x$ and $y$ lie in the same block.
  These constructions invert one another.
]

#proof[(Sketch)][
  Classes of an equivalence are non-empty, disjoint, and cover $M$.
  Conversely, "same block" relation is reflexive, symmetric, transitive.
  Composing the two constructions returns exactly the starting equivalence relation or partition (they are mutually inverse up to equality of sets of ordered pairs).
]


#focus-slide(
  title: "Composition of Relations",
)

== Composition of Relations

#definition[
  The _composition_ of two relations $R subset.eq A times B$ and $S subset.eq B times C$ is defined as:
  $
    R relcomp S = S compose R = { pair(a, c) | exists b in B. thin (a rel(R) b) and (b rel(S) c) }
  $
]

#example[
  Let $A = {1, 2, 3}$, $B = {a, b, c, d}$, $C = {x, y}$ with relations:
  - $R = {pair(1, a), pair(1, b), pair(2, c), pair(3, d)} subset.eq A times B$
  - $S = {pair(a, x), pair(b, y), pair(c, x)} subset.eq B times C$

  To find $R relcomp S$, we look for pairs $(i, z)$ where there exists $w$ such that $pair(i, w) in R$ and $pair(w, z) in S$:

  From $1$: can reach $a$ and $b$ via $R$
  - $a$ connects to $x$ via $S$ $=>$ $(1, x)$ is in the composition
  - $b$ connects to $y$ via $S$ $=>$ $(1, y)$ is in the composition

  From $2$: can reach $c$ via $R$
  - $c$ connects to $x$ via $S$ $=>$ $(2, x)$ is in the composition

  From $3$: can reach $d$ via $R$
  - $d$ has no outgoing connections in $S$ $=>$ no pairs from $3$ in the composition

  Therefore: $R relcomp S = {pair(1, x), pair(1, y), pair(2, x)}$
]

#align(center)[
  #cetz.canvas({
    import cetz: draw

    let draw-vertex(pos, name, label, color: none) = {
      draw.circle(
        pos,
        radius: 0.35,
        stroke: 1pt + color.darken(20%),
        fill: color.lighten(80%),
        name: name,
      )
      draw.content(name, [#label])
    }

    let draw-edge(start, end) = {
      let color = blue
      draw.line(
        start,
        end,
        stroke: 1.2pt + color,
        mark: (end: "stealth", fill: color),
      )
    }

    let draw-composition-edge(start, end) = {
      let color = green.darken(20%)
      draw.line(
        start,
        end,
        stroke: (paint: color, dash: "dashed", thickness: 1pt),
        mark: (end: "stealth", fill: color),
      )
    }

    // Set A (left column)
    draw-vertex((-2.5, 1), "1", [$1$], color: blue)
    draw-vertex((-2.5, 0), "2", [$2$], color: blue)
    draw-vertex((-2.5, -1), "3", [$3$], color: blue)

    // Set B (middle column)
    draw-vertex((0, 1.5), "a", [$a$], color: yellow)
    draw-vertex((0, 0.5), "b", [$b$], color: yellow)
    draw-vertex((0, -0.5), "c", [$c$], color: yellow)
    draw-vertex((0, -1.5), "d", [$d$], color: red)

    // Set C (right column)
    draw-vertex((2.5, 0.5), "x", [$x$], color: green)
    draw-vertex((2.5, -0.5), "y", [$y$], color: green)

    // Relation R edges (A to B)
    draw-edge("1", "a")
    draw-edge("1", "b")
    draw-edge("2", "c")
    draw-edge("3", "d")

    // Relation S edges (B to C)
    draw-edge("a", "x")
    draw-edge("b", "y")
    draw-edge("c", "x")
    // Note: d has no outgoing edges (dead end)

    // Composition R∘S (A to C) - dashed green lines
    draw-composition-edge("1", "x")
    draw-composition-edge("1", "y")
    draw-composition-edge("2", "x")

    // Labels
    draw.content("1.north", anchor: "south", padding: 0.2, text(fill: blue.darken(20%))[*Set $A$*])
    draw.content("a.north", anchor: "south", padding: 0.2, text(fill: orange.darken(20%))[*Set $B$*])
    draw.content("x.north", anchor: "south", padding: 0.2, text(fill: green.darken(20%))[*Set $C$*])

    // Legend
    draw.content(
      (-2, -2.2),
      anchor: "north-west",
      text(size: 0.8em)[
        Edges legend:
        - #text(fill: blue.darken(20%))[Solid: Relations $R$ and $S$] \
        - #text(fill: green.darken(20%))[Dashed: Composition $R relcomp S$] \
        - #text(fill: red.darken(20%))[Red: Dead end (no outgoing path)]
      ],
    )
  })
]

== Examples of Composition

#example[Composition in a social network][
  Consider three sets:
  - $"People" = {"Alice", "Bob", "Carol"}$
  - $"Skills" = {"Python", "Design", "Management"}$
  - $"Projects" = {"WebApp", "Mobile", "Analytics"}$

  Define relations:
  - $"HasSkill" = {pair("Alice", "Python"), pair("Alice", "Design"), pair("Bob", "Python"), pair("Carol", "Management")}$
  - #box(width: 100em)[
      $"RequiresSkill" = {pair("Python", "WebApp"), pair("Python", "Analytics"), pair("Design", "WebApp"), pair("Management", "Mobile")}$
    ]

  The composition $"HasSkill" relcomp "RequiresSkill"$ gives us $"CanWorkOn"$:
  - Alice can work on WebApp (via Python AND Design)
  - Alice can work on Analytics (via Python)
  - Bob can work on WebApp (via Python)
  - Bob can work on Analytics (via Python)
  - Carol can work on Mobile (via Management)

  So: $"CanWorkOn" = {pair("Alice", "WebApp"), pair("Alice", "Analytics"), pair("Bob", "WebApp"), pair("Bob", "Analytics"), pair("Carol", "Mobile")}$
]

#example[Matrix composition][
  Relations can be composed using Boolean matrix multiplication.

  Given $R subset.eq {1,2} times {a,b}$ and $S subset.eq {a,b} times {x,y}$:

  $
    matrel(R) = natrix.bnat(1, 0; 1, 1) quad
    matrel(S) = natrix.bnat(1, 1; 0, 1)
  $

  The composition $matrel(R relcomp S) = matrel(R) boolprod matrel(S)$ using Boolean matrix multiplication:

  $
    matrel(R relcomp S) = natrix.bnat(
      (1 and 1) or (0 and 0), (1 and 1) or (0 and 1);
      (1 and 1) or (1 and 0), (1 and 1) or (1 and 1)
    ) = natrix.bnat(1, 1; 1, 1)
  $

  This means $R relcomp S = {pair(1, x), pair(1, y), pair(2, x), pair(2, y)}$ (the universal relation).
]

#pagebreak()

#example[Path composition in a graph][
  Consider a directed graph with vertices ${A, B, C, D}$ and relation $R$ representing direct edges:
  $R = {pair(A, B), pair(B, C), pair(B, D), pair(C, D)}$

  Powers of $R$ represent paths of different lengths:
  - $R^1 = R$ (direct connections)
  - $R^2 = R compose R$ (2-step paths):
    - $pair(A, C)$: path $A to B to C$
    - $pair(A, D)$: path $A to B to D$
    - $pair(B, D)$: path $B to C to D$ (but $pair(B, D)$ already in $R^1$)

  So $R^2 = {pair(A, C), pair(A, D), pair(B, D)}$, but since $pair(B, D) in R^1$, the new 2-step paths are $pair(A, C)$ and $pair(A, D)$.
]

// TODO: visualize

== Powers of Relations

#definition[
  For a homogeneous relation $R subset.eq M^2$, we define _powers_ of $R$:
  - $R^0 = I_M$ (identity relation)
  - $R^1 = R$
  - $R^(n+1) = R^n compose R$ for $n >= 1$
]

#example[
  Let $M = {1, 2, 3, 4}$ and $R = {pair(1, 2), pair(2, 3), pair(3, 4)}$ (successor relation).
  - $R^1 = {pair(1, 2), pair(2, 3), pair(3, 4)}$
  - $R^2 = {pair(1, 3), pair(2, 4)}$ (two steps)
  - $R^3 = {pair(1, 4)}$ (three steps)
  - $R^4 = emptyset$ (no four-step paths)
]

#theorem[
  For any relation $R$ on a finite set with $n$ elements:
  - $R^+ = R^1 union R^2 union dots union R^n$ is a _transitive closure_.
  - $R^* = R^0 union R^+ = I union R^+$ is a _reflexive-transitive closure_.
]

== Associativity of Composition

#theorem[
  Composition of relations is associative:
  $(R relcomp S) relcomp T = R relcomp (S relcomp T)$.
]

#proof[
  Let $R subset.eq A times B$, $S subset.eq B times C$, and $T subset.eq C times D$ be three relations.

  *($subset.eq$):*
  Let $pair(a, d) in (R relcomp S) relcomp T$.
  - By definition of composition:
    $exists c in C. thin (pair(a, c) in R relcomp S) and (pair(c, d) in T)$.
  - Since $pair(a, c) in R relcomp S$, we have:
    $exists b in B. thin (pair(a, b) in R) and (pair(b, c) in S)$.
  - From $pair(b, c) in S$ and $pair(c, d) in T$, we have:
    $pair(b, d) in S relcomp T$.
  - From $pair(a, b) in R$ and $pair(b, d) in S relcomp T$, we have:
    $pair(a, d) in R relcomp (S relcomp T)$.

  *($supset.eq$):*
  Let $pair(a, d) in R relcomp (S relcomp T)$.
  - By definition of composition:
    $exists b in B. thin (pair(a, b) in R) and (pair(b, d) in S relcomp T)$.
  - Since $pair(b, d) in S relcomp T$, we have:
    $exists c in C. thin (pair(b, c) in S) and (pair(c, d) in T)$.
  - From $pair(a, b) in R$ and $pair(b, c) in S$, we have:
    $pair(a, c) in R relcomp S$.
  - From $pair(a, c) in R relcomp S$ and $pair(c, d) in T$, we have:
    $pair(a, d) in (R relcomp S) relcomp T$.

  Therefore, $(R relcomp S) relcomp T = R relcomp (S relcomp T)$.
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
      name: "Felix Hausdorff",
      image: image("assets/Felix_Hausdorff.jpg"),
    ),
    (
      name: "Henri Poincaré",
      image: image("assets/Henri_Poincare.jpg"),
    ),
    (
      name: "Robert Floyd",
      image: image("assets/Robert_Floyd.jpg"),
    ),
    (
      name: "Stephen Warshall",
      image: image("assets/Stephen_Warshall.jpg"),
    ),
    (
      name: "Stephen Kleene",
      image: image("assets/Stephen_Kleene.jpg"),
    ),
  ),
)

== Orders

// Preorder
#definition[
  A relation $R subset.eq M^2$ is called a _preorder_ if it is reflexive and transitive.
]

// Partial order
#definition[
  A _partial order_ is a relation $R subset.eq M^2$ that is reflexive, antisymmetric, and transitive.
]

// Connected relation
#definition[
  A relation $R subset.eq M^2$ is _connected_ if for every pair of distinct elements, either one is related to the other or vice versa:
  $ forall x, y in M. thin (x neq y) imply (x rel(R) y or y rel(R) x) $
]

// Linear/Total order
#definition[
  A partial order which is also connected is called a _total order_ (or _linear order_).
]

== Examples of Orders

#example[
  The relation $leq$ on real numbers $RR$ is a _total order_:
  - *Reflexive:* $x leq x$ for all $x in RR$
  - *Antisymmetric:* If $x leq y$ and $y leq x$, then $x = y$
  - *Transitive:* If $x leq y$ and $y leq z$, then $x leq z$
  - *Connected:* For any $x, y in RR$, either $x leq y$ or $y leq x$

  This is the most familiar example of an order relation.
  Similarly, $NN$, $ZZ$, and $QQ$ with $leq$ are all total orders.
]

// TODO: visualize the total order on a number line
//       draw ALL edges, but make transitive ones lighter

#pagebreak()

#example[
  The _subset relation_ $subset.eq$ on the power set $power(A)$ is a *partial order*:
  - *Reflexive:* Every set is a subset of itself: $X subset.eq X$
  - *Antisymmetric:* If $X subset.eq Y$ and $Y subset.eq X$, then $X = Y$
  - *Transitive:* If $X subset.eq Y$ and $Y subset.eq Z$, then $X subset.eq Z$

  For $A = {1, 2}$, we have $power(A) = {emptyset, {1}, {2}, {1,2}}$ with:
  - $emptyset subset.eq {1} subset.eq {1,2}$ (this is a chain)
  - $emptyset subset.eq {2} subset.eq {1,2}$ (another chain)
  - But ${1}$ and ${2}$ are *incomparable* (neither is a subset of the other)

  This is *not* a total order because not all pairs are comparable.
]
// TODO: visualize

#pagebreak()

#example[
  #let nolonger = $prec.curly.eq$
  Consider the _no longer than_ relation $nolonger$ on binary strings $BB^*$:
  $
    x nolonger y quad "iff" quad "len"(x) <= "len"(y)
  $
  This is a *preorder* (reflexive and transitive), and even connected, but *not* a partial order, since it is not antisymmetric: for example, $01 nolonger 10$ and $10 nolonger 01$, but $01 neq 10$.

  *Why it is only a preorder:*
  Different strings of the same length are all "equivalent" under this relation, but they're not actually equal.
]
// TODO: visualize

#pagebreak()

#example[
  _Divisibility_ $|$ on positive integers is a partial order.
  For $D = {1,2,3,4,6,12}$:
  - $1 | 2 | 4$ and $1 | 2 | 6 | 12$ (chains through divisibility)
  - $1 | 3 | 6 | 12$ (another chain)
  - But $2$ and $3$ are incomparable: $2 divides.not 3$ and $3 divides.not 2$
  - Similarly, $4$ and $6$ are incomparable

  *Visualization:*
  Think of this as a "family tree" of divisibility, where ancestors divide descendants.
]
// TODO: visualize

#pagebreak()

#example[
  _Lexicographic order_ on strings $A^n$ (like dictionary order) is a *total order*.

  For binary strings of length 2: $00 < 01 < 10 < 11$

  This extends the order on individual characters to entire strings:
  - Compare strings character by character from left to right
  - The first differing position determines the order
  - If one string is a prefix of another, the shorter one comes first

  *Key property:*
  Every pair of strings is comparable, making this a total order.
]

// TODO: strict orders!

== Partially Ordered Sets

// Poset
#definition[
  A _partially ordered set_ (or _poset_) $pair(S, leq)$ is a set $S$ equipped with a partial order $leq$.
]

#example[
  Consider the poset $(D, |)$ where $D = {1, 2, 3, 4, 6, 12}$ and $|$ is divisibility.

  #place(right, dx: -1cm)[
    #cetz.canvas({
      import cetz.draw: *

      let w = 1.4
      let h = 1
      let hgap = 1.2
      let vgap1 = 1
      let vgap2 = 1.5

      let draw-vertex((x, y), name, label) = {
        circle((x, y), radius: 0.4, fill: white, stroke: 1pt, name: name)
        content(name, [#label])
      }
      let draw-edge(start, end) = {
        line(start, end, stroke: 1pt, mark: (end: "stealth", fill: black))
      }
      let draw-transitive-edge(start, end) = {
        let color = luma(80%)
        line(start, end, stroke: 0.5pt + color, mark: (end: "stealth", fill: color))
      }

      // Vertices
      draw-vertex((0, 0), "1", [$1$])
      draw-vertex((-hgap, vgap1), "2", [$2$])
      draw-vertex((hgap, vgap1), "3", [$3$])
      draw-vertex((-hgap, vgap1 + vgap2), "4", [$4$])
      draw-vertex((hgap, vgap1 + vgap2), "6", [$6$])
      draw-vertex((0, vgap1 * 2 + vgap2), "12", [$12$])

      // Transitive edges
      draw-transitive-edge("1", "4")
      draw-transitive-edge("1", "6")
      draw-transitive-edge("1", "12")
      draw-transitive-edge("2", "12")
      draw-transitive-edge("3", "12")

      // TODO: Loops

      // Edges
      draw-edge("1", "2")
      draw-edge("1", "3")
      draw-edge("2", "4")
      draw-edge("2", "6")
      draw-edge("3", "4")
      draw-edge("3", "6")
      draw-edge("4", "12")
      draw-edge("6", "12")
    })
  ]

  *Order relation properties:*
  - Reflexive: $n | n$ for all $n in D$
  - Antisymmetric: If $a | b$ and $b | a$, then $a = b$
  - Transitive: If $a | b$ and $b | c$, then $a | c$

  *Special elements:*
  - Least element: $1$ (divides all others)
  - Greatest element: $12$ (divisible by all others)
  - Minimal elements: just $1$
  - Maximal elements: just $12$

  #note[
    This poset forms a _lattice_ since every pair has a supremum (LCM) and infimum (GCD).
  ]
]

// TODO: linearly ordered set

== Hasse Diagrams

// Hasse diagram
#definition[
  A _Hasse diagram_ is a visual representation of a poset where:
  - Each element is represented as a vertex.
  - If $x < y$ and there is no $z$ with $x < z < y$, draw an edge from $x$ to $y$.
  - Elements are arranged vertically by the order relation.
  - Transitive connections are omitted (implied by transitivity of the partial order).
]

#place(right)[
  #cetz.canvas({
    import cetz.draw: *

    let hgap = 1.6
    let vgap = 1.2

    let draw-vertex((x, y), name, label) = {
      circle((x, y), radius: 0.3, fill: white, stroke: 1pt, name: name)
      content(name, [#label])
    }
    let draw-edge(start, end) = {
      line(start, end, stroke: 1pt, mark: (end: "stealth", fill: black))
    }

    // Level 0 (bottom): 1
    draw-vertex((0, 0), "1", [$1$])

    // Level 1: primes 2, 3, 5
    draw-vertex((-hgap, vgap), "2", [$2$])
    draw-vertex((0, vgap), "3", [$3$])
    draw-vertex((hgap, vgap), "5", [$5$])

    // Level 2: composite numbers
    draw-vertex((-hgap, vgap * 2), "4", [$4$])
    draw-vertex((0, vgap * 2), "10", [$10$])
    draw-vertex((hgap, vgap * 2), "35", [$35$])

    // Level 3: maximal elements
    draw-vertex((0, vgap * 3), "20", [$20$])

    // Edges from 1 to primes
    draw-edge("1", "2")
    draw-edge("1", "3")
    draw-edge("1", "5")

    // Other edges
    draw-edge("2", "4") // 2|4
    draw-edge("2", "10") // 2|10
    draw-edge("5", "10") // 5|10
    draw-edge("4", "20") // 4|20
    draw-edge("10", "20") // 10|20
    draw-edge("5", "35") // 5|35
  })
]

#example[
  For $D = {1, 2, 3, 4, 5, 10, 20, 35}$ with divisibility $|$.

  *Reading the diagram:*
  - $1$ divides everything (least element at bottom)
  - Multiple maximal elements: $3$ and $20$ (no single greatest element)
  - Some chains (not necessarily maximal, can skip elements):
    - Chain: $1 | 2 | 4$ (powers of 2)
    - Chain: $1 | 10 | 20$ (multiples of 10)
    - Chain: $5 | 35$ (multiples of 5)
  - Primes $2$, $3$, $5$ are incomparable to each other
]

== Subset Poset

#example[
  For $power({a, b}) = {emptyset, {a}, {b}, {a,b}}$ with inclusion $subset.eq$:

  #align(center)[
    #cetz.canvas({
      import cetz.draw: *

      let w = 1.4
      let h = 1
      let hgap = 1.5
      let vgap = 2

      let draw-vertex((x, y), name, label) = {
        rect((x - w / 2, y - h / 2), (x + w / 2, y + h / 2), radius: 0.3, stroke: 1pt, name: name)
        content(name, [#label])
      }
      let draw-edge(start, end) = {
        line(start, end, stroke: 1pt, mark: (end: "stealth", fill: black))
      }

      // Vertices
      draw-vertex((0, 0), "empty", [$emptyset$])
      draw-vertex((-hgap, vgap), "a", [${a}$])
      draw-vertex((hgap, vgap), "b", [${b}$])
      draw-vertex((0, vgap * 2), "ab", [${a,b}$])

      // Edges
      draw-edge("empty", "a")
      draw-edge("empty", "b")
      draw-edge("a", "ab")
      draw-edge("b", "ab")
    })
  ]

  #note[
    This is the classic "diamond" shape characteristic of Boolean algebras.
  ]
  #note[
    $pair(power(A), subset.eq)$ is also called the _Boolean lattice_.
  ]
]

== Covering Relation

// Covering relation
#definition[
  In a poset $pair(S, leq)$, an element $y in S$ _covers_ $x in S$, denoted $x covers y$, if there is no other element in between them:
  $
    x covers y
    quad "iff" quad
    (x < y) and exists.not z in S. thin (x < z < y)
  $

  #note[
    "$<$" denotes the _induced strict order_:
    $
      x < y quad "iff" quad (x leq y) and (x neq y)
    $
  ]
]

#note[
  Hasse diagram is just a graph of a covering relation!
]

== Maximal and Minimal Elements

// Maximal element
#definition[
  An element $m in S$ is called a _maximal element_ of a poset $pair(S, leq)$ if it is not less than any other element, i.e., there is no even greater element.
  $
    forall x != m. thin not (x leq m)
    quad iff quad
    exists.not x != m. thin (m leq x)
  $
  Equivelently, $forall x in S. thin (m leq x) imply (m = x)$
]

// Minimal element
#definition[
  An element $m in S$ is called a _minimal element_ of a poset $pair(S, leq)$ if it is not greater than any other element, i.e., there is no even smaller element.
  $
    forall x != m. thin not (m leq x)
    quad iff quad
    exists.not x != m. thin (x leq m)
  $
  Equivelently, $forall x in S. thin (x leq m) imply (m = x)$
]

#note[
  There may be multiple maximal (or minimal) elements.
]

== Example of Maximal and Minimal Elements

#example[
  Consider the divisibility poset on $S = {2, 3, 4, 6, 8, 12}$:

  #columns(2)[
    *Maximal elements:* $8$ and $12$
    - $8$ divides nothing else in $S$ except itself
    - $12$ divides nothing else in $S$ except itself

    #colbreak()

    *Minimal elements:* $2$ and $3$
    - Nothing in $S$ properly divides $2$ (since $1 notin S$)
    - Nothing in $S$ properly divides $3$
  ]

  #note[
    This poset has no greatest or least element, but multiple minimal/maximal elements.
  ]
]

#place(right, dx: -3em)[
  #cetz.canvas({
    import cetz.draw: *

    let hgap = 1.4
    let vgap = 1.2

    let draw-vertex((x, y), name, label, color: white) = {
      circle((x, y), radius: 0.35, fill: color, stroke: 1pt, name: name)
      content(name, [#label])
    }
    let draw-edge(start, end) = {
      line(start, end, stroke: 1pt, mark: (end: "stealth", fill: black))
    }

    // Level 0 (minimal elements): 2, 3
    draw-vertex((-hgap / 2, 0), "2", [$2$], color: blue.lighten(80%))
    draw-vertex((hgap / 2, 0), "3", [$3$], color: blue.lighten(80%))

    // Level 1: 4, 6
    draw-vertex((-hgap / 2, vgap), "4", [$4$])
    draw-vertex((hgap / 2, vgap), "6", [$6$])

    // Level 2 (maximal elements): 8, 12
    draw-vertex((-hgap / 2, vgap * 2), "8", [$8$], color: red.lighten(80%))
    draw-vertex((hgap / 2, vgap * 2), "12", [$12$], color: red.lighten(80%))

    // Edges showing divisibility relationships
    draw-edge("2", "4") // 2|4
    draw-edge("2", "6") // 2|6
    draw-edge("3", "6") // 3|6
    draw-edge("4", "8") // 4|8
    draw-edge("4", "12") // 4|12
    draw-edge("6", "12") // 6|12
  })
]

*Hasse diagram:*
- #Red[Maximal elements] (8, 12) — they divide nothing else in $S$
- #Blue[Minimal elements] (2, 3) — nothing in $S$ divides them
- Two separate chains: $2 | 4 | 8$ and $3 | 6 | 12$

#pagebreak()

#example[
  #let prefix = $lt.dot$
  Let $S = {"ab", "abc", "abd", "ac", "b", "bc"}$ ordered by the _prefix_ relation $prefix$:
  $
    x prefix y "iff" x "is a prefix of" y
  $

  *Maximal elements:* $"abc"$, $"abd"$, #underline[$"ac"$], $"bc"$
  - These strings are not prefixes of any other string in $S$

  *Minimal elements:* $"ab"$, #underline[$"ac"$], $"b"$
  - These strings have no other string in $S$ that is a proper prefix of them

  The Hasse diagram shows three separate "trees" rooted at the minimal elements, with:
  - $"ab" prefix "abc"$ and $"ab" prefix "abd"$
  - $"b" prefix "bc"$
  - $"ac"$ stands alone (no other string extends it in $S$)
]

#place(right + bottom, dx: -1em, dy: -1em)[
  #cetz.canvas({
    import cetz.draw: *

    let w = 1.2
    let h = 0.8
    let hgap = 2.2
    let vgap = 1.8

    let draw-vertex((x, y), name, label, color: white) = {
      rect((x - w / 2, y - h / 2), (x + w / 2, y + h / 2), radius: 0.3, stroke: 1pt, fill: color, name: name)
      content(name, [#label], anchor: "center")
    }

    let draw-edge(start, end, color: black) = {
      line(start, end, stroke: 1pt + color, mark: (end: "stealth", fill: color))
    }

    // Tree 1: "ab" -> "abc", "abd"
    draw-vertex((0, 0), "ab", ["ab"], color: blue.lighten(80%))
    draw-vertex((-0.8, vgap), "abc", ["abc"], color: green.lighten(80%))
    draw-vertex((0.8, vgap), "abd", ["abd"], color: green.lighten(80%))

    draw-edge("ab", "abc", color: blue)
    draw-edge("ab", "abd", color: blue)

    // Tree 2: "b" -> "bc"
    draw-vertex((hgap, 0), "b", ["b"], color: blue.lighten(80%))
    draw-vertex((hgap, vgap), "bc", ["bc"], color: green.lighten(80%))

    draw-edge("b", "bc", color: blue)

    // Tree 3: "ac" (standalone)
    draw-vertex((-hgap, vgap / 2), "ac", ["ac"], color: orange.lighten(80%))

    // Labels
    // content((0, -1), text(fill: blue, weight: "bold")[Tree 1], anchor: "center")
    // content((hgap, -1), text(fill: blue, weight: "bold")[Tree 2], anchor: "center")
    // content((-hgap, -0.5), text(fill: orange.darken(30%), weight: "bold")[Tree 3], anchor: "center")

    // Legend
    content((-6, 0.4), text(size: 0.9em, fill: green.darken(30%))[Maximal elements], anchor: "west")
    content((-6, 0), text(size: 0.9em, fill: blue)[Minimal elements], anchor: "west")
    content((-6, -0.4), text(size: 0.9em, fill: orange.darken(30%))[Both minimal & maximal], anchor: "west")
  })
]

== Greatest and Least Elements

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
  - $pair(power(A), subset.eq)$: least $emptyset$ (contained in every set), greatest $A$ (contains every subset).
  - $pair(NN^+, |)$: least $1$ (divides every positive integer), no greatest element (no integer is divisible by all others).
  - $pair(ZZ, <=)$: no least or greatest element (integers extend infinitely in both directions).
  - $pair({1,2,3,4,5,6}, |)$: least $1$, no greatest element, maximal elements are $4$, $5$, $6$ (prime powers and primes that don't divide anything else in the given set).
]

#pagebreak()

// TODO: consider moving this example after chains or refactoring it, since it does not fit "greatest elements" example
#example[
  In project management, _tasks_ form a _scheduling poset_ under the "prerequisite" relation.

  Consider tasks: $A$ (Design), $B$ (Code), $C$ (Test), $D$ (Deploy), $E$ (Document)
  - $A prec B$ (we must design before coding)
  - $A prec E$ (we must design before documenting)
  - $B prec C$ (we must code before testing)
  - $C prec D$ (we must test before deploying)

  *Minimal element:* $A$ (Design) --- no prerequisites.

  *Maximal elements:* $D$ (Deploy) and $E$ (Document) --- nothing depends on them.

  *Chains:* $A to B to C to D$ represents one possible execution order.
]
// TODO: visualize

== Chains and Antichains

// Chain and Antichain
#definition[
  In a partially ordered set $(M, leq)$:

  - A _chain_ is a subset $C subset.eq M$ where every two elements are comparable.
    Formally:
    $
      forall x, y in C. thin (x leq y "or" y leq x)
    $

  - An _antichain_ is a subset $A subset.eq M$ where no two distinct elements are comparable.
    Formally:
    $
      forall x, y in A. thin
      (x != y) imply (x leq.not y "and" y leq.not x)
    $
]

// TODO: move to a separate slide
// TODO: visualize
#example[
  Consider the divisibility relation $|$ on ${1, 2, 3, 4, 6, 12}$:

  *Chains (totally ordered subsets):*
  - ${1, 2, 4}$: $1 | 2 | 4$ (each divides the next)
  - ${1, 2, 6, 12}$: $1 | 2 | 6 | 12$
  - ${1, 3, 6, 12}$: $1 | 3 | 6 | 12$
  - *Maximal chain:* ${1, 2, 6, 12}$ or ${1, 3, 6, 12}$ (length 4)

  *Antichains (mutually incomparable subsets):*
  - ${2, 3}$: neither divides the other
  - ${4, 6}$: $4 divides.not 6$ and $6 divides.not 4$
  - ${2, 3, 4}$: pairwise incomparable elements
  - *Maximum antichain:* ${2, 3, 4}$ (size 3)

  *Dilworth's theorem in action:* Maximum antichain size (3) equals minimum number of chains needed to cover the poset.
]

#example[
  In a Git repository, commits form a poset under the "ancestor" relation:
  - *Chain:* A sequence of commits on a single branch (linear history).
  - *Antichain:* Commits on different branches that have diverged (no ancestry relation).

  *Practical insight:* Merge commits combine multiple antichains back into a single chain.
]

== Dilworth's Theorem

#theorem[Dilworth][
  In any finite partially ordered set, the maximum size of an antichain equals the minimum number of chains needed to cover the entire set.
]

#example[
  In the Boolean lattice $power({a, b}) = {emptyset, {a}, {b}, {a,b}}$ with inclusion ($subset.eq$):

  // #align(center)[
  //   #cetz.canvas({
  //     import cetz.draw: *

  //     // Draw the Boolean lattice
  //     circle((0, 0), radius: 0.15, fill: blue.lighten(80%), stroke: 1pt, name: "empty")
  //     circle((-1, 1.5), radius: 0.15, fill: red.lighten(80%), stroke: 1pt, name: "a")
  //     circle((1, 1.5), radius: 0.15, fill: red.lighten(80%), stroke: 1pt, name: "b")
  //     circle((0, 3), radius: 0.15, fill: blue.lighten(80%), stroke: 1pt, name: "ab")

  //     content("empty", [$emptyset$], anchor: "center")
  //     content("a", [${a}$], anchor: "center")
  //     content("b", [${b}$], anchor: "center")
  //     content("ab", [${a,b}$], anchor: "center")

  //     line("empty", "a", stroke: 1pt + blue)
  //     line("empty", "b", stroke: 1pt + blue)
  //     line("a", "ab", stroke: 1pt + blue)
  //     line("b", "ab", stroke: 1pt + blue)

  //     // Add annotations
  //     content((-2, 1.5), text(fill: red)[Antichain], anchor: "east")
  //     content((0, -0.8), text(fill: blue)[Chain 1], anchor: "center", angle: 90deg)
  //     content((1.8, 2.2), text(fill: blue)[Chain 2], anchor: "center", angle: 90deg)
  //   })
  // ]

  - *Maximum antichain:* ${{a}, {b}}$ of size 2 (red nodes - incomparable elements)
  - *Minimum chain decomposition:*
    - Chain 1: $emptyset subset.eq {a} subset.eq {a,b}$
    - Chain 2: $emptyset subset.eq {b} subset.eq {a,b}$
  - *Dilworth's theorem:* Maximum antichain size (2) = minimum number of chains (2).

  #note[
    $emptyset$ and ${a,b}$ appear in both chains, which is allowed in chain decompositions.
  ]
]


#focus-slide(
  title: "Well Orders",
)

== Well-Ordered Sets

#definition[
  A poset $(M, leq)$ is _well-ordered_ if every non-empty subset $S subset.eq M$ has a _least element_.

  Formally: $forall S subset.eq M. thin (S != emptyset) imply (exists m in S. thin forall x in S. thin m leq x)$
]

#note[
  A well-ordered set is automatically a _total order_ (linear order) since comparability follows from the well-ordering property.
]

#example[
  The natural numbers $NN = {0, 1, 2, 3, dots}$ with the usual order $leq$ form a well-ordered set:
  - Any non-empty subset has a smallest element.
  - For instance, the subset ${5, 17, 23, 100}$ has least element $5$.
  - Even infinite subsets like ${2, 4, 6, 8, dots}$ (even numbers) have a least element ($2$).
]

#example[
  The integers $ZZ$ with the usual order are _not_ well-ordered:
  - The subset ${-1, -2, -3, dots}$ (negative integers) has no least element.
  - Any infinite descending sequence has no minimum.
]

== Examples of Well-Ordered Sets

// TODO: check/refine
#example[
  _Lexicographic order_ on finite strings over an alphabet is well-ordered:
  - Given any non-empty set of strings, there is always a lexicographically smallest one.
  - For example, in ${"cat", "dog", "apple", "zebra"}$, the least element is "$"apple"$".

  // TODO: add another example with set of "all" finite strings: {b, ab, aab, aaab, ...} has no least element

  // TODO: fix this incorrect (or unclear) example...
  // For infinite $omega$-strings, lexicographic order is _not_ well-ordered:
  // - The set of all infinite binary strings has no least element.
  // - For example, the subset of strings starting with "1" has no least element.
]

// TODO: add more lex orders (e.g. shortlex)

// TODO: add more examples of well-ordered sets

== Well-Founded Relations

// TODO: extract the equivalent part with descending chain into a separate definition, and focus here only on minimal elements
#definition[
  A relation $R subset.eq M^2$ is _well-founded_ if every non-empty subset $S subset.eq M$ has at least one _minimal element_ with respect to $R$.

  Formally: $forall S subset.eq M. thin (S != emptyset) imply (exists m in S. thin forall x in S. thin x nrel(R) m)$

  Equivalently, $R$ is well-founded if there are no infinite _descending chains_:
  $
    not exists (x_0, x_1, x_2, dots) in M^NN. thin
    forall i in NN. thin
    x_(i+1) rel(R) x_i
  $
]

#note[
  If $R$ is a strict order $<$, then the infinite descending chain can be written as:
  $
    x_0 > x_1 > x_2 > dots
  $
]

#note[
  _Well-founded_ $!=$ _well-ordered_:
  - Well-ordered requires a _least_ element (unique minimum)
  - Well-founded only requires _minimal_ elements (no element below them)
  - Every well-ordered set is well-founded, but not vice versa
]

== Examples of Well-Founded Relations

#example[
  Consider the _proper subset_ relation $subset$ on finite sets.
  Let $M = {emptyset, {a}, {b}, {a,b}}$.
  // with $A subset B$ meaning "$A$ is a proper subset of $B$", i.e. $A subset.eq B$, but $A != B$.

  *Well-founded:* #YES Every subset of $M$ has minimal elements.
  - _Example:_ The subset ${{a}, {b}, {a,b}}$ has minimal elements ${a}$ and ${b}$
    - Neither ${a} subset {b}$ nor ${b} subset {a}$ (they're incomparable)
    - Both are minimal since no set in the subset is a proper subset of them

  *Well-ordered:* #NO Some subsets lack a unique least element.
  - _Same example:_ ${{a}, {b}, {a,b}}$ has no "$subset$-least" element
    - For "$subset$-least", we'd need a set $L$ such that $L subset X$ for all other $X$
    - But ${a} subset.not {b}$ and ${b} subset.not {a}$, so neither can be least
    - No single set is a proper subset of all others in this collection

  #Block(color: yellow)[
    *Key insight:* Well-founded $!=$ well-ordered:
    - _Multiple minimal_ elements are allowed in well-founded relations.
    - Well-ordered relations require a _unique_ least element in every subset.
  ]
]

// #pagebreak()
//
// TODO: fix this BROKEN example
//
// #example[Comparing $(NN, leq)$ vs $(NN, >=)$][
//   Same set, different relations show how direction affects properties:

//   *$(NN, leq)$ --- standard "less than or equal":*
//   - *Well-ordered:* #YES Every subset has a least (smallest) element.
//   - *Well-founded:* #YES Every subset has minimal elements (same as least here).
//   - For example: ${3, 7, 12}$ has least element $3$, minimal element is also $3$.

//   *$(NN, >=)$ --- "greater than or equal":*
//   - *Well-ordered:* #NO Subsets like ${3, 7, 12}$ have no "$>=$-least" element
//     - The "$>=$-least" would be the element that is "$>=$-smallest", i.e., the largest!
//     - But ${3, 7, 12}$ has $>=$-least element $12$, while ${2, 4, 6, dots}$ has no $>=$-least element.
//   - *Well-founded:* #NO Has infinite descending chains like $10 >= 9 >= 8 >= dots$

//   #Block(color: yellow)[
//     *Key insight:* The same mathematical structure can be well-ordered under one relation but not under its "reverse"!
//   ]
// ]

#pagebreak()

#example[
  The _divisibility_ relation $(NN^+, |)$ is well-founded:
  - Every non-empty subset has minimal elements (numbers that divide no others in the subset)
  - For example, in ${6, 12, 18, 4, 8}$: minimal elements are ${6, 4}$
  - There are no infinite descending divisibility chains
]

#pagebreak()

#example[
  _Program termination analysis_ uses well-founded relations:
  - Define a measure that decreases with each recursive call
  - If the measure forms a well-founded order, the program terminates
  - Example: factorial function decreases argument from $n$ to $n-1$
]
// TODO: add Dafny example

== Noetherian Relations

#definition[
  A relation $R subset.eq S^2$ is _Noetherian_ if it satisfies the _descending chain condition (DCC)_:
  every sequence $x_1 rel(R) x_2 rel(R) x_3 rel(R) dots$ eventually stabilizes.

  Formally: $forall (x_i)_(i in NN) in S^NN. thin (forall i. thin x_i rel(R) x_(i+1)) imply (exists N in NN. thin forall n >= N. thin (x_n = x_(n+1)))$
]

// TODO: this is duplicated below in chain condition equivalences
#theorem[
  For any relation $R$, the following are equivalent:
  + $R$ is well-founded
  + $R$ is Noetherian (satisfies DCC)
  + $R$ has no infinite descending chains
]

#example[
  The usual order $leq$ on $NN$ is Noetherian:
  - Any descending sequence $n_1 >= n_2 >= n_3 >= dots$ must stabilize
  - Since natural numbers are bounded below by $0$, infinite descent is impossible
  - Eventually, some $n_k = n_(k+1) = n_(k+2) = dots$
]

#pagebreak()

#example[
  In ring theory, a _Noetherian ring_ has the property that every ascending chain of ideals stabilizes:
  $I_1 subset.eq I_2 subset.eq I_3 subset.eq dots$ eventually becomes constant.
  This connects to termination of algorithms in computational algebra.
]

#example[
  In rewriting systems and lambda calculus:
  - A _reduction relation_ $to$ is Noetherian if all reduction sequences terminate
  - Example: $beta$-reduction in simply typed lambda calculus is Noetherian
  - This guarantees that programs always terminate (no infinite loops)
]

== Chain Conditions

// Ascending chain condition (ACC)
#definition[
  A poset $P$ is said to satisfy the _ascending chain condition (ACC)_ if no strict ascending sequence $x_1 < x_2 < x_3 < dots$ of elements of $P$ exists.

  Equivalently, every weakly ascending sequence $x_1 <= x_2 <= x_3 <= dots$ eventually stabilizes.

  Formally: $forall (x_i)_(i in NN) in S^NN. thin (forall i in NN. thin x_i leq x_(i+1)) imply (exists N in NN. thin forall n >= N. thin x_n = x_(n+1))$
]

// Descending chain condition (DCC)
#definition[
  A poset $P$ is said to satisfy the _descending chain condition (DCC)_ if no strict descending sequence $x_1 > x_2 > x_3 > dots$ of elements of $P$ exists.

  Equivalently, every weakly descending sequence $x_1 >= x_2 >= x_3 >= dots$ eventually stabilizes.

  Formally: $forall (x_i)_(i in NN) in S^NN. thin (forall i in NN. thin x_i >= x_(i+1)) imply (exists N in NN. thin forall n >= N. thin x_n = x_(n+1))$
]

== Chain Condition Equivalences

#theorem[
  For a poset $(S, leq)$:
  - *DCC* $<==>$ the relation $leq$ is well-founded $<==>$ no infinite descending chains.
  - *ACC* $<==>$ the _dual_ relation $>=$ is well-founded $<==>$ no infinite ascending chains.
]

#proof[(sketch)][
  - *DCC implies well-founded:* If there were a non-empty subset without a minimal element, we could construct an infinite descending chain, contradicting DCC.
  - *Well-founded implies DCC:* If there were an infinite descending chain, its elements would form a non-empty subset without a minimal element, contradicting well-foundedness.
  - The equivalence for ACC follows by applying the same reasoning to the dual relation $>=$.
]

== Examples of ACC and DCC

#example[
  Consider the poset $(power({1,2,3}), subset.eq)$ of subsets ordered by inclusion:
  - *ACC holds:* #YES Any ascending chain $A_1 subset.eq A_2 subset.eq A_3 subset.eq dots$ must stabilize since we can't keep adding elements indefinitely.
  // TODO: check where this claim is correct:
  //  Here, it stabilizes to the full set ${1,2,3}$.
  - *DCC holds:* #YES Any descending chain $B_1 supset.eq B_2 supset.eq B_3 supset.eq dots$ must stabilize since we can't keep removing elements indefinitely.
  // TODO: check where this claim is correct:
  //  Here, it stabilizes to the empty set $emptyset$.
  - Both conditions hold because the set is finite.
]

#example[
  In the natural numbers $(NN, leq)$:
  - *DCC holds:* #YES Any sequence $n_1 >= n_2 >= n_3 >= dots$ must stabilize (well-founded).
  - *ACC fails:* #NO The sequence $1 < 2 < 3 < 4 < dots$ never stabilizes.
  - This shows that DCC and ACC are independent conditions.
]

#examples[Applications in algebra][
  - *Noetherian rings:* Satisfy ACC for ideals (every ascending chain of ideals stabilizes).
  - *Artinian rings:* Satisfy DCC for ideals (every descending chain of ideals stabilizes).
  - *Principal ideal domains:* Both conditions hold, enabling algorithms like Euclidean division.
]

== Connections and Applications

#theorem[Well-ordering principle][
  Every well-ordered set admits _transfinite induction_: to prove $P(x)$ for all $x in S$, it suffices to show:
  $forall x in S. thin (forall y < x. thin P(y)) imply P(x)$
]

#example[
  _Mathematical induction_ on $NN$ is a special case of transfinite induction using the well-ordering of natural numbers.
]

#examples[Computer science applications][
  - *Termination analysis:* Prove programs terminate by finding well-founded measures.
  - *Parsing algorithms:* Use well-founded recursion on parse tree depth.
  - *Datalog evaluation:* Stratified negation ensures termination via well-founded semantics.
  - *Model checking:* Well-founded relations ensure finite state exploration.
]

#Block(color: blue)[
  These concepts provide the mathematical foundation for reasoning about _termination_, _finiteness_, and _algorithmic complexity_ in computer science and mathematics.
]

// TODO: refine the summary

// == Summary: Order-Theoretic Properties

// #align(center)[
//   #table(
//     columns: 3,
//     align: (left, left, left),
//     stroke: (x, y) => if y == 0 { (bottom: 1pt) },
//     // fill: (x, y) => if y == 0 { luma(220) },
//     inset: 8pt,

//     table.header([*Property*], [*Definition*], [*Key Examples*]),

//     [*Well-Ordered*], [Every non-empty subset has a _least_ element], [$(NN, leq)$, lexicographic strings],

//     [*Well-Founded*], [Every non-empty subset has _minimal_ elements], [Proper subset $subset$],

//     [*Noetherian*],
//     [
//       No infinite descending chains
//       $x_0 > x_1 > x_2 > dots$
//     ],
//     [Same as well-founded],

//     [*Artinian*],
//     [
//       No infinite ascending chains
//       $x_0 < x_1 < x_2 < dots$
//     ],
//     [$(power(A), subset.eq)$, some ring ideals],

//     [*DCC*], [Descending Chain Condition:\ $x_1 >= x_2 >= dots$ stabilizes], [Same as Noetherian],

//     [*ACC*], [Ascending Chain Condition: \ $x_1 <= x_2 <= dots$ stabilizes], [Same as Artinian],
//   )
// ]

// #pagebreak()

// #Block(color: yellow)[
//   *Key Relationships:*
//   - Well-Ordered $=>$ Well-Founded (every least element is minimal)
//   - Well-Founded $<=>$ Noetherian $<=>$ DCC (equivalent conditions)
//   - ACC is the "dual" of DCC (flip the relation direction)
//   - Well-Founded + ACC $<=>$ finite chains in both directions
// ]

// == Detailed Comparison Table

// #align(center)[
//   #table(
//     columns: 6,
//     align: (left, center, center, center, center, left),
//     stroke: (x, y) => if y == 0 { (bottom: 1pt) } + if x > 0 { (left: 0.5pt) },

//     [*Property*], [$(NN, leq)$], [$(NN, >)$], [$(power(A_"fin"), subset.eq)$], [$(power(A_"inf"), subset.eq)$], [*Distinguishing Feature*],

//     [*Well-Ordered*], [#YES], [#NO], [#YES], [#NO], [Unique least in every subset],

//     [*Well-Founded*], [#YES], [#NO], [#YES], [#NO], [Minimal elements exist],

//     [*DCC*], [#YES], [#NO], [#YES], [#NO], [No infinite descent],

//     [*ACC*], [#NO], [#YES], [#YES], [#NO], [No infinite ascent],

//     [*Total Order*], [#YES], [#YES], [#NO], [#NO], [All elements comparable],

//     [*Finite*], [#NO], [#NO], [#YES], [#NO], [Bounded number of elements],
//   )
// ]

// #examples[Why $(NN, >)$ fails][
//   - *Not well-founded:* ${1,2,3,dots}$ has no maximal element
//   - *Not DCC:* Infinite descent $3 > 2 > 1 > 0 > -1 > dots$ (if extended to $ZZ$)
//   - *Has ACC:* Any ascending sequence $a_1 > a_2 > dots$ in $NN$ must stabilize
// ]

// #examples[Why $(power(A), subset.eq)$ succeeds][
//   - *Well-ordered:* $emptyset$ is least element of any non-empty collection
//   - *Well-founded:* Minimal sets exist (those contained in no others)
//   - *Both DCC & ACC:* Can't infinitely add/remove elements from finite universe
// ]


#focus-slide(
  title: "Suprema and Infima",
)

== Upper and Lower Bounds

// Upper bound
#definition[
  In a poset $pair(S, leq)$, an element $u in S$ is called an _upper bound_ of a subset $C subset.eq S$ if it is greater than or equal to every element in $C$, i.e., for all $x in C$, $x leq u$.
]

// Lower bound
#definition[
  In a poset $pair(S, leq)$, an element $l in S$ is called a _lower bound_ of a subset $C subset.eq S$ if it is less~than or equal to every element in $C$, i.e., for all $x in C$, $l leq x$.
]

#example[
  In $pair(RR, <=)$ for interval $C = (0;1)$:
  - *Lower bounds:* every $x <= 0$ (including $-infinity, -1, 0$)
  - *Upper bounds:* every $x >= 1$ (including $1, 2, +infinity$)
  - *No* greatest lower bound or least upper bound in $C$ (since $(0;1)$ is open)
]

#example[
  In $pair(power({1,2,3}), subset.eq)$ for $C = {{1,2},{1,3}}$:
  - *Lower bounds:* $emptyset$, ${1}$ (subsets of both sets in $C$)
  - *Upper bounds:* ${1,2,3}$ (supersets of both sets in $C$)
  - *Greatest lower bound:* ${1} = {1,2} intersect {1,3}$
  - *Least upper bound:* ${1,2,3} = {1,2} union {1,3}$
]

#example[
  In divisibility poset for $C = {4,6}$:
  - *Upper bounds:* multiples of $"lcm"(4,6) = 12$, i.e., ${12, 24, 36, dots}$
  - *Lower bounds:* common divisors, i.e., ${1, 2}$
  - *Least upper bound:* $12 = "lcm"(4,6)$
  - *Greatest lower bound:* $2 = "gcd"(4,6)$
]

#example[
  In the task scheduling poset from earlier:
  - For tasks $C = {B, E}$ (Code, Document):
    - *Lower bound:* $A$ (Design) --- prerequisite for both
    - *Upper bounds:* None in this poset
    - *Greatest lower bound:* $A$ (latest common prerequisite)

  This corresponds to finding the "merge point" in dependency graphs.
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

#example[
  $pair(RR, <=)$:
  - For finite subsets, $sup(C) = max(C)$ and $inf(C) = min(C)$.
  - For infinite subsets: $sup((0,1)) = 1$ and $inf((0,1)) = 0$ (even though $0, 1 notin (0,1)$)
]

#pagebreak()

#example[
  $pair(power(A), subset.eq)$:
  - $sup(cal(C)) = union.big_(X in cal(C)) X$ (union of all sets)
  - $inf(cal(C)) = inter.big_(X in cal(C)) X$ (intersection of all sets)
  - *Example:* $sup {{1,2}, {2,3}, {3,4}} = {1,2,3,4}$
]

#example[
  Divisibility on $NN_(>0)$:
  - $sup{a, b} = "lcm"(a, b)$ (least common multiple)
  - $inf{a, b} = "gcd"(a, b)$ (greatest common divisor)
  - *Example:* $sup {6, 10} = 30$, $inf {6, 10} = 2$
]

#example[Suprema and Infima in Programming][
  In type systems, types form a lattice under subtyping:
  - $sup{"int", "string"} = "any"$ (most general type containing both)
  - $inf{"number", "int"} = "int"$ (most specific type contained in both)

  In access control systems:
  - $sup{"read", "write"} = "read-write"$ (union of permissions)
  - $inf{"admin", "user"} = "guest"$ (intersection of permissions)
]


#focus-slide(
  title: "Closures of Relations",
)

== Closures of Relations

#definition[
  The _closure_ of a relation $R subset.eq M^2$ with respect to a property $P$ is the smallest relation containing $R$ that satisfies property $P$.
  - _Reflexive closure_: $r(R) = R union I_M$ (smallest reflexive relation containing $R$)
  - _Symmetric closure_: $s(R) = R union R^(-1)$ (smallest symmetric relation containing $R$)
  - _Transitive closure_: $t(R)$ is the smallest transitive relation containing $R$
]

#Block(color: blue)[
  The key insight is that closure operations _add the minimum_ number of pairs needed to achieve the desired property, while preserving all existing pairs in the original relation.
]

// TODO: visualize the extension of sets as blobs

== Reflexive Closure

#definition[
  The _reflexive closure_ $r(R)$ of a relation $R subset.eq M^2$ is defined as:
  $
    r(R) = R union I_M = R union { pair(x, x) | x in M }
  $
]

#example[
  Let $M = {1, 2, 3}$ and $R = {pair(1, 2), pair(2, 2), pair(2, 3)}$.

  The identity relation is $I_M = {pair(1, 1), pair(2, 2), pair(3, 3)}$.

  The reflexive closure is:
  $
    r(R) = R union I_M = {pair(1, 1), pair(1, 2), pair(2, 2), pair(2, 3), pair(3, 3)}
  $
]

== Symmetric Closure

#definition[
  The _symmetric closure_ $s(R)$ of a relation $R subset.eq M^2$ is defined as:
  $
    s(R) = R union R^(-1) = R union { pair(b, a) | pair(a, b) in R }
  $
]

#example[
  Let $M = {1, 2, 3}$ and $R = {pair(1, 2), pair(2, 3), pair(1, 3)}$.

  The converse relation is:
  $
    R^(-1) = {pair(2, 1), pair(3, 2), pair(3, 1)}
  $

  The symmetric closure is:
  $
    s(R) = R union R^(-1) = {pair(1, 2), pair(2, 3), pair(1, 3), pair(2, 1), pair(3, 2), pair(3, 1)}
  $
]

== Transitive Closure

#definition[
  The _transitive closure_ $t(R)$ of a relation $R subset.eq M^2$ is the smallest transitive relation containing $R$.
]

#theorem[
  The transitive closure can be computed as:
  $
    t(R) = union.big_(n=1)^infinity R^n
    quad "where" R^n = underbrace(R compose R compose dots compose R, n "times")
  $

  For finite sets with $abs(M) = k$, we have $t(R) = R^1 union R^2 union dots union R^k$.
]

#proof[
  Since $M$ is finite, any path of length greater than $abs(M)$ must repeat vertices, so we only need to consider paths of length at most $abs(M)$.
]

#pagebreak()

#example[Step-by-step transitive closure computation][
  Let $M = {1, 2, 3}$ and $R = {pair(1, 2), pair(2, 3)}$.

  #table(
    columns: 3,
    stroke: (x, y) => if y == 0 { (bottom: 0.6pt) },
    table.header([Step], [Description], [Result]),
    [*Step 1:*],
    [
      Compute $R^1 = R$.
    ],
    [$R^1 = {pair(1, 2), pair(2, 3)}$],

    [*Step 2:*],
    [
      Compute $R^2 = R compose R$.

      For $pair(a, c) in R^2$, we need $exists b: pair(a, b) in R and pair(b, c) in R$.
      - $pair(1, 3) in R^2$ since $pair(1, 2) in R$ and $pair(2, 3) in R$
    ],
    [$R^2 = {pair(1, 3)}$],

    [*Step 3:*],
    [
      Compute $R^3 = R^2 compose R$.

      For $pair(a, c) in R^3$, we need $exists b: pair(a, b) in R^2 and pair(b, c) in R$.
      - No such pairs exist.
    ],
    [$R^3 = emptyset$],

    [*Step 4:*],
    [
      Form the transitive closure:
      $t(R) = R^1 union R^2 union R^3$.
    ],
    [$t(R) = {pair(1, 2), pair(2, 3), pair(1, 3)}$],
  )
]

// #example[Transitive closure of a more complex relation][
//   Let $M = {a, b, c, d}$ and $R = {pair(a, b), pair(b, c), pair(c, d), pair(a, d)}$.

//   *Computing powers:*

//   $R^1 = {pair(a, b), pair(b, c), pair(c, d), pair(a, d)}$

//   $R^2$: Look for 2-step paths
//   - $pair(a, c)$: $a to b to c$
//   - $pair(b, d)$: $b to c to d$

//   $R^2 = {pair(a, c), pair(b, d)}$

//   $R^3$: Look for 3-step paths
//   - $pair(a, d)$: $a to b to c to d$ (but $pair(a, d)$ already in $R^1$)

//   $R^3 = emptyset$ (no new pairs)

//   *Transitive closure:*
//   $ t(R) = R^1 union R^2 = {pair(a, b), pair(b, c), pair(c, d), pair(a, d), pair(a, c), pair(b, d)} $
// ]

== Combined Closures

#definition[
  Closure operations can be combined to create relations with multiple properties:
  - _Reflexive-symmetric closure_: $r s(R) = s r(R) = r(R) union s(R) union I_M$
  - _Reflexive-transitive closure_: $r t(R) = t r(R) = t(R) union I_M$
  - _Equivalence closure_: $r s t(R) = t s r(R)$ (reflexive, symmetric, and transitive)
]

#theorem[Commutativity of closure operations][
  - Reflexive and symmetric closures commute: $r s(R) = s r(R)$
  - Reflexive and transitive closures commute: $r t(R) = t r(R)$
  - All three closures commute when applied together
]

== Reflexive-Symmetric Closure

#example[Reflexive-symmetric closure][
  Let $M = {1, 2, 3}$ and $R = {pair(1, 2), pair(2, 3)}$.

  *Method 1:* Apply reflexive closure first, then symmetric
  $ r(R) = R union I_M = {pair(1, 1), pair(1, 2), pair(2, 2), pair(2, 3), pair(3, 3)} $
  $ s r(R) = r(R) union r(R)^(-1) $
  $ = {pair(1, 1), pair(1, 2), pair(2, 2), pair(2, 3), pair(3, 3), pair(2, 1), pair(3, 2)} $

  *Method 2:* Apply symmetric closure first, then reflexive
  $ s(R) = R union R^(-1) = {pair(1, 2), pair(2, 3), pair(2, 1), pair(3, 2)} $
  $ r s(R) = s(R) union I_M $
  $ = {pair(1, 1), pair(1, 2), pair(2, 1), pair(2, 2), pair(2, 3), pair(3, 2), pair(3, 3)} $

  Both methods yield the same result, confirming commutativity.
]

== Reflexive-Transitive Closure

#example[Reflexive-transitive closure (Kleene star)][
  Let $M = {a, b, c}$ and $R = {pair(a, b), pair(b, c)}$.

  First, compute the transitive closure:
  $ t(R) = R union R^2 = {pair(a, b), pair(b, c), pair(a, c)} $

  Then add reflexivity:
  $ r t(R) = t(R) union I_M = {pair(a, a), pair(a, b), pair(a, c), pair(b, b), pair(b, c), pair(c, c)} $

  This is equivalent to the _reflexive-transitive closure_, often denoted $R^*$ (Kleene star).
]

== Equivalence Closure

#example[Complete equivalence closure][
  Let $M = {1, 2, 3, 4}$ and $R = {pair(1, 2), pair(3, 4)}$.

  *Step 1:* Make it reflexive
  $ r(R) = R union I_M = {pair(1, 1), pair(1, 2), pair(2, 2), pair(3, 3), pair(3, 4), pair(4, 4)} $

  *Step 2:* Make it symmetric
  $ s r(R) = r(R) union r(R)^(-1) $
  $ = {pair(1, 1), pair(1, 2), pair(2, 1), pair(2, 2), pair(3, 3), pair(3, 4), pair(4, 3), pair(4, 4)} $

  *Step 3:* Make it transitive
  Since $pair(1, 2), pair(2, 1) in s r(R)$, transitivity requires $pair(1, 1)$ (already present).
  Since $pair(3, 4), pair(4, 3) in s r(R)$, transitivity requires $pair(3, 3)$ (already present).

  $ t s r(R) = s r(R) $ (no new pairs needed)

  The equivalence closure partitions $M$ into equivalence classes ${1, 2}$ and ${3, 4}$.
]

#pagebreak()

#example[Equivalence closure [2]][
  Let $M = {a, b, c, d, e}$ and $R = {pair(a, b), pair(b, c), pair(d, e)}$.

  *Reflexive closure:*
  $ r(R) = R union {pair(a, a), pair(b, b), pair(c, c), pair(d, d), pair(e, e)} $

  *Symmetric closure:*
  $ s r(R) = r(R) union {pair(b, a), pair(c, b), pair(e, d)} $

  *Transitive closure:*
  We need to add pairs to ensure transitivity:
  - From $pair(a, b), pair(b, c)$: add $pair(a, c)$
  - From $pair(c, b), pair(b, a)$: add $pair(c, a)$

  $ t s r(R) \\ = s r(R) union {pair(a, c), pair(c, a)} $

  The final equivalence relation has equivalence classes ${a, b, c}$ and ${d, e}$.
]

== Warshall's Algorithm for Transitive Closure

#definition[
  _Warshall's algorithm_ computes the transitive closure of a relation using dynamic programming with time complexity $O(n^3)$.

  Given an $n times n$ matrix $M = matrel(R)$ representing relation $R$:
  ```
  M = matrix(R)
  for k = 1 to n:
      for i = 1 to n:
          for j = 1 to n:
              M[i,j] := M[i,j] OR (M[i,k] AND M[k,j])
  ```
]

#example[Warshall's algorithm step-by-step][
  Let $X = {1, 2, 3, 4}$ and relation $R$ with matrix $matrel(R)$:
  $
    M^((0)) = matrel(R) = natrix.bnat(
      0, 1, 0, 0;
      0, 0, 1, 0;
      0, 0, 0, 1;
      1, 0, 0, 0
    )
  $

  \

  *Iteration $k = 1$:* Consider paths through vertex 1
  $
    M^((1)) = natrix.bnat(
      0, 1, 0, 0;
      0, 0, 1, 0;
      0, 0, 0, 1;
      1, 1, 0, 0
    )
  $
  (Added $pair(4, 2)$: path $4 to 1 to 2$)

  *Iteration $k = 2$:* Consider paths through vertex 2
  $
    M^((2)) = natrix.bnat(
      0, 1, 1, 0;
      0, 0, 1, 0;
      0, 0, 0, 1;
      1, 1, 1, 0
    )
  $
  (Added $pair(1, 3)$ and $pair(4, 3)$)

  \

  *Iteration $k = 3$:* Consider paths through vertex 3
  $
    M^((3)) = natrix.bnat(
      0, 1, 1, 1;
      0, 0, 1, 1;
      0, 0, 0, 1;
      1, 1, 1, 1
    )
  $
  (Added $pair(1, 4)$, $pair(2, 4)$, and $pair(4, 4)$)

  *Iteration $k = 4$:* Consider paths through vertex 4
  $
    M^((4)) = natrix.bnat(
      1, 1, 1, 1;
      1, 1, 1, 1;
      1, 1, 1, 1;
      1, 1, 1, 1
    )
  $
  (The relation becomes universal since there's a cycle)
]

#pagebreak()

#example[Practical application: Reachability in graphs][
  Consider a social network where $R$ represents "follows" relationships:
  $
    R = {pair(A, B), pair(B, C), pair(C, D), pair(A, E)}
  $

  Using Warshall's algorithm, we can determine _indirect influence_:
  - $A$ can influence $C$ through $B$
  - $A$ can influence $D$ through $B$ and $C$
  - The transitive closure shows all possible influence paths

  This is crucial for analyzing _information propagation_ in social networks, _dependency resolution_ in software systems, and _route planning_ in transportation networks.
]

== Properties and Advanced Applications of Closures

#theorem[Closure properties][
  For any relation $R subset.eq M^2$:
  + _Idempotency_: $r(r(R)) = r(R)$, $s(s(R)) = s(R)$, $t(t(R)) = t(R)$
  + _Monotonicity_: If $R_1 subset.eq R_2$, then $r(R_1) subset.eq r(R_2)$, etc.
  + _Extensivity_: $R subset.eq r(R)$, $R subset.eq s(R)$, $R subset.eq t(R)$
  + _Distributivity over union_: $r(R_1 union R_2) = r(R_1) union r(R_2)$, etc.
]

#example[Closure of the empty relation][
  Let $M = {a, b, c}$ and $R = emptyset$.

  - $r(emptyset) = emptyset union I_M = I_M = {pair(a, a), pair(b, b), pair(c, c)}$
  - $s(emptyset) = emptyset union emptyset^(-1) = emptyset$
  - $t(emptyset) = emptyset$ (since $emptyset^n = emptyset$ for all $n >= 1$)

  The reflexive closure of the _empty_ relation is the _identity_ relation.
]

#pagebreak()

#example[Closure of the universal relation][
  Let $M = {1, 2}$ and $R = M times M = {pair(1, 1), pair(1, 2), pair(2, 1), pair(2, 2)}$.

  - $r(R) = R union I_M = R$ (since $I_M subset.eq R$)
  - $s(R) = R union R^(-1) = R$ (since $R = R^(-1)$ for universal relation)
  - $t(R) = R$ (universal relation is already transitive)

  The universal relation is its own closure under all three operations.
]

#pagebreak()

#example[Non-commutativity with other operations][
  Let $M = {1, 2, 3}$, $R_1 = {pair(1, 2)}$, and $R_2 = {pair(2, 3)}$.

  Consider $t(R_1 union R_2)$ vs $t(R_1) union t(R_2)$:
  - $R_1 union R_2 = {pair(1, 2), pair(2, 3)}$
  - $t(R_1 union R_2) = {pair(1, 2), pair(2, 3), pair(1, 3)}$
  - $t(R_1) = {pair(1, 2)}$
  - $t(R_2) = {pair(2, 3)}$
  - $t(R_1) union t(R_2) = {pair(1, 2), pair(2, 3)}$

  Since $pair(1, 3) in t(R_1 union R_2)$ but $pair(1, 3) notin t(R_1) union t(R_2)$, we have:
  $ t(R_1 union R_2) != t(R_1) union t(R_2) $

  However: $t(R_1) union t(R_2) subset.eq t(R_1 union R_2)$ always holds.
]

#pagebreak()

#example[Computing equivalence classes from closure][
  Let $M = {1, 2, 3, 4, 5}$ and $R = {pair(1, 3), pair(2, 4), pair(4, 5)}$.

  The equivalence closure gives us:
  $
    "equiv"(R) & = r s t(R) \
    & = {pair(1, 1), pair(1, 3), pair(2, 2), pair(2, 4), pair(2, 5), pair(3, 1), pair(3, 3), pair(4, 2), pair(4, 4), pair(4, 5), pair(5, 2), pair(5, 4), pair(5, 5)}
  $

  The equivalence classes are:
  - $[1] = {1, 3}$
  - $[2] = {2, 4, 5}$

  This partitions $M$ into ${{1, 3}, {2, 4, 5}}$.
]

#pagebreak()

#example[Closure in directed acyclic graphs (DAGs)][
  Consider a dependency graph where $R$ represents _"depends on"_ relationships:
  $
    R = {pair(A, B), pair(B, C), pair(A, D), pair(D, C)}
  $
  #place(right)[
    #cetz.canvas({
      import cetz.draw: *
      let w = 1
      let h = 1
      let hgap = 1
      let vgap = 1.6
      let draw-rect((x, y), name) = {
        rect((x - w / 2, y - h / 2), (x + w / 2, y + h / 2), radius: 0.3, stroke: 1pt, name: name)
        content(name, [#name], anchor: "center")
      }
      let draw-edge(from, to) = {
        line(from, to, stroke: 1pt, mark: (end: "stealth", fill: black))
      }
      draw-rect((0, 0), "A")
      draw-rect((-hgap, vgap), "B")
      draw-rect((hgap, vgap), "D")
      draw-rect((0, 2 * vgap), "C")
      draw-edge("A", "B")
      draw-edge("A", "D")
      draw-edge("B", "C")
      draw-edge("D", "C")
    })
  ]
  For example, component $A$ depends on $B$ and $D$, which both depend on $C$.

  The transitive closure reveals all _indirect_ dependencies:
  $ t(R) = R union {pair(A, C)} $

  This shows that component $A$ _transitively depends_ on $C$ through two paths:
  - $A to B to C$
  - $A to D to C$

  In software build systems, this helps determine the complete dependency tree.
]

#pagebreak()

== When Relation Closures Actually Matter

#grid(
  columns: 2,
  column-gutter: .8em,
  row-gutter: .8em,

  Block(color: blue.lighten(50%))[
    #text(
      size: 1.2em,
      weight: "bold",
      fill: blue.darken(20%),
    )[🎬 Netflix Knows You Too Well]

    *Transitive closure* powers recommendation systems and social networks:
    - You like movie A, Alice likes A and B, so you might like B.
    - Chain reactions: A $to$ B $to$ C $to$ D discovers surprising connections.

    #text(size: 0.8em, style: "italic")[
      That creepy moment when Netflix suggests something perfect?
      That's transitive closure finding paths through millions of user preferences.
    ]
  ],

  Block(color: green.lighten(50%))[
    #text(
      size: 1.2em,
      weight: "bold",
      fill: green.darken(20%),
    )[💸 How Money Actually Moves]

    *Transitive closure* tracks financial flows:
    - You pay bank $arrow.double$ bank pays merchant $arrow.double$ merchant pays supplier.
    - Money laundering detection: hidden chains of transactions.

    #text(size: 0.8em, style: "italic")[
      Banks use this to catch criminals who try to hide money through complex chains of fake transactions.
    ]
  ],

  grid.cell(colspan: 2)[
    #Block(color: orange.lighten(50%))[
      *Key insight:*
      If you can get from $A$ to $C$ by going through $B$, then _transitive closure_ provides the _direct_ $A to C$ relation --- whether it's movies, money, friends, or malware.
    ]
  ],
)


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
  + _Functional (right-unique)_:
    For every $a in A$, there is _at most one_ pair $pair(a, b)$ in $f$.
    $
      forall a in A. thin
      forall b_1, b_2 in B. thin
      (f(a) = b_1) and (f(a) = b_2) imply (b_1 = b_2)
    $
  + _Serial (left-total)_:
    For every $a in A$, there is _at least one_ pair $pair(a, b)$ in $f$.
    $
      forall a in A. thin
      exists b in B. thin
      f(a) = b
    $
]

#definition[
  A relation that satisfies the _functional_ property is called a _partial function_.

  A relation that satisfies _both_ properties is called a _total function_, or simply a _function_.
]

== Domain, Codomain, Range

#definition[
  For a function $f: A to B$:
  - The set $A$ is called the _domain_ of $f$, denoted $Dom(f)$.
  - The set $B$ is called the _codomain_ of $f$, denoted $Cod(f)$.
  - The _range_ (or _image_) of $f$ is the set of all values that $f$ actually takes:
    $
      Range(f) = { b in B | exists a in A. thin f(a) = b } = { f(a) | a in A }
    $

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

  #place(top + right)[
    #cetz.canvas({
      import cetz.draw: *

      scale(75%)

      circle((0, 0), radius: (1, 2))
      circle((3, 0), radius: (1, 2))

      circle((0, 1), radius: 0.1, fill: white, name: "1")
      circle((0, 0), radius: 0.1, fill: white, name: "2")
      circle((0, -1), radius: 0.1, fill: white, name: "3")

      circle((3, 1), radius: 0.1, fill: white, name: "x")
      circle((3, 0), radius: 0.1, fill: white, name: "y")
      circle((3, -1), radius: 0.1, fill: white, name: "z")

      content("1", [$1$], anchor: "east", padding: 0.2)
      content("2", [$2$], anchor: "east", padding: 0.2)
      content("3", [$3$], anchor: "east", padding: 0.2)
      content("x", [$x$], anchor: "west", padding: 0.2)
      content("y", [$y$], anchor: "west", padding: 0.2)
      content("z", [$z$], anchor: "west", padding: 0.2)

      line("1", "x", stroke: 2pt + blue, mark: (end: "stealth", fill: blue), name: "1-x")
      line("2", "y", stroke: 2pt + blue, mark: (end: "stealth", fill: blue), name: "2-y")
      line("3", "x", stroke: 2pt + blue, mark: (end: "stealth", fill: blue), name: "3-x")
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
  A function $f: A to B$ is _injective_ (or _one-to-one_#footnote[
    Do not confuse it with _one-to-one correspondence_, which is a bijection, not just injection!
  ]) if distinct elements in the domain map to distinct elements in the codomain.
  Formally:
  $
    forall a_1, a_2 in A. thin
    (f(a_1) = f(a_2)) imply (a_1 = a_2)
  $
]

#v(-.5em)
#align(center)[
  #import fletcher: diagram, edge, node, shapes
  #diagram(
    edge-stroke: 1pt,
    node((0cm, 0cm), $1$, shape: shapes.circle, fill: green.lighten(80%), stroke: green.darken(20%), name: <A>),
    node((0cm, -1.5cm), $2$, shape: shapes.circle, fill: green.lighten(80%), stroke: green.darken(20%), name: <B>),
    node((3cm, 0cm), $x$, shape: shapes.circle, fill: red.lighten(80%), stroke: red.darken(20%), name: <X>),
    node((3cm, -1.5cm), $y$, shape: shapes.circle, fill: red.lighten(80%), stroke: red.darken(20%), name: <Y>),
    edge(<A>, <X>, "-}>", label-side: center, label-angle: auto)[$f$],
    edge(<B>, <X>, "-}>", label-side: center, label-angle: auto)[$f$],
    render: (grid, nodes, edges, options) => {
      import fletcher: cetz
      cetz.canvas({
        // Background:
        cetz.draw.circle((0, -0.75), radius: (0.7, 1.4), stroke: 0.4pt)
        cetz.draw.circle((3, -0.75), radius: (0.7, 1.4), stroke: 0.4pt)

        // Main diagram:
        fletcher.draw-diagram(grid, nodes, edges, debug: options.debug)

        // Overlay:
        let (x, y) = (1.5, -0.5)
        let s = 1.8
        cetz.draw.line(
          (x - s / 2, y + s / 2),
          (x + s / 2, y - s / 2),
          stroke: (thickness: 2pt, paint: red, cap: "round"),
        )
        cetz.draw.line(
          (x - s / 2, y - s / 2),
          (x + s / 2, y + s / 2),
          stroke: (thickness: 2pt, paint: red, cap: "round"),
        )
      })
    },
  )
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
  Formally:
  $
    forall b in B. thin
    exists a in A. thin
    f(a) = b
  $

  For surjective functions, $Range(f) = Cod(f)$, i.e., there are _no "uncovered"_ elements in the right side.
]

#v(-.5em)
#align(center)[
  #import fletcher: diagram, edge, node, shapes
  #diagram(
    edge-stroke: 1pt,
    node((0cm, 0cm), $1$, shape: shapes.circle, fill: green.lighten(80%), stroke: green.darken(20%), name: <A>),
    node((0cm, -1.5cm), $2$, shape: shapes.circle, fill: green.lighten(80%), stroke: green.darken(20%), name: <B>),
    node((3cm, 0cm), $x$, shape: shapes.circle, fill: red.lighten(80%), stroke: red.darken(20%), name: <X>),
    node((3cm, -1.5cm), $y$, shape: shapes.circle, fill: red.lighten(80%), stroke: red.darken(20%), name: <Y>),
    edge(<A>, <X>, "-}>", label-side: center, label-angle: auto)[$f$],
    edge(<B>, <X>, "-}>", label-side: center, label-angle: auto)[$f$],
    render: (grid, nodes, edges, options) => {
      import fletcher: cetz
      cetz.canvas({
        // Background:
        cetz.draw.circle((0, -0.75), radius: (0.7, 1.4), stroke: 0.4pt)
        cetz.draw.circle((3, -0.75), radius: (0.7, 1.4), stroke: 0.4pt)

        // Main diagram:
        fletcher.draw-diagram(grid, nodes, edges, debug: options.debug)

        // Overlay:
        let (x, y) = (3, -1.5)
        let s = 1
        cetz.draw.line(
          (x - s / 2, y + s / 2),
          (x + s / 2, y - s / 2),
          stroke: (thickness: 2pt, paint: red, cap: "round"),
        )
        cetz.draw.line(
          (x - s / 2, y - s / 2),
          (x + s / 2, y + s / 2),
          stroke: (thickness: 2pt, paint: red, cap: "round"),
        )
      })
    },
  )
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
  The identity function $id_A: A to A$ defined by $id_A (x) = x$ for all $x in A$ is bijective.
]

== Function Composition

#definition[
  Let $f: A to B$ and $g: B to C$ be two functions.
  The _composition_ of $g$ and $f$, denoted $g compose f$ (read as "$g$ composed with $f$" or "$g$ after $f$"), is a function from $A$ to $C$ defined by:
  $
    (g compose f)(a) = g(f(a))
  $
  // for all $a in A$.
]

#example[
  Let $f: RR to RR$ be $f(x) = x^2$ and $g: RR to RR$ be $g(x) = x+1$.
  - $(g compose f)(x) = g(f(x)) = g(x^2) = x^2 + 1$.
  - $(f compose g)(x) = f(g(x)) = f(x+1) = (x+1)^2 = x^2 + 2x + 1$.
]

// TODO: functional powers
// (if Y subset.eq X, then f:X->Y can be composed with itself)

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
    (
      name: "Paul Cohen",
      image: image("assets/Paul_Cohen.jpg"),
    ),
  ),
)

== Size of Sets

#definition[
  The _size_ of a _finite_ set $X$, denoted $abs(X)$, is the number of elements it contains.
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
  The _cardinality_ of a set $X$, denoted $abs(X)$, is a measure of its "size".
  - For _finite_ sets, cardinality $abs(X)$ is the same as size, i.e., the number of elements in $X$.
  - For _infinite_ sets, cardinality $abs(X)$ describes the "type" of infinity, e.g. _countable_ vs _uncountable_.
]

#examples[
  - $abs(NN) = aleph_0$
  - $abs(QQ) = aleph_0$
  - $abs(RR) = 2^(aleph_0) = frak(c)$
]

#note[
  $abs(X)$ is _not_ just a number, but a _cardinal number_.
  - Cardinal numbers extend natural numbers to describe sizes of infinite sets.
  - The _finite_ cardinal numbers are just natural numbers: $0, 1, 2, 3, dots$.
  - The first (smallest) _infinite_ cardinal is $aleph_0$ (the cardinality of $NN$).
  - _Arithmetic_ operations on cardinal numbers _differ_ from those on natural numbers.
    - For example, $aleph_0 + 1 = aleph_0$ and $aleph_0 dot 2 = aleph_0$.
]

== Equinumerosity

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

#proof[#footnote[
  See https://math.stackexchange.com/a/183383 for more detailed analysis.
]][
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


#focus-slide(
  title: "Lattices",
  epigraph: [Order is the shape upon which beauty depends.],
  epigraph-author: "Pearl S. Buck",
  scholars: (
    (
      name: "Alfred Tarski",
      image: image("assets/Alfred_Tarski.jpg"),
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
      name: "Emmy Noether",
      image: image("assets/Emmy_Noether.jpg"),
    ),
    (
      name: "Marshall Stone",
      image: image("assets/Marshall_Stone.jpg"),
    ),
  ),
)

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

#Block(color: yellow)[
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
  - *Join (LCM):* $6 Join 10 = "lcm"(6,10) = 30$
  - *Meet (GCD):* $6 Meet 10 = "gcd"(6,10) = 2$
  - *Bottom element:* $1$ (divides everything)
  - *No top element:* No integer is divisible by all others

  *Applications:*
  - Number theory and cryptography (RSA key generation)
  - Computer algebra systems (polynomial GCD algorithms)
  - Scheduling problems (finding common time periods)
]

#pagebreak()

#example[File System Permissions][
  Unix file permissions form a lattice under inclusion:
  - Elements: Sets of permissions like ${r, w, x}$, ${r, x}$, ${w}$, etc.
  - Order: $P_1 leq P_2$ if $P_1 subset.eq P_2$ (fewer permissions $=>$ more restrictive)
  - Join: Union of permissions (less restrictive)
    - For example: ${"read"} Join {"execute"} = {"read", "execute"}$
  - Meet: Intersection of permissions (more restrictive)
    - For example: ${"read", "write"} Meet {"write", "execute"} = {"write"}$
]
// TODO: visualize

#pagebreak()

#example[Partition Lattice][
  All partitions of a set $S$, ordered by refinement.
  - $pi_1 leq pi_2$ if $pi_1$ is a refinement of $pi_2$ (smaller blocks)
  - Join: Finest common coarsening
    - For example: $(1 2 | 3) Join (1 | 2 3) = (1 2 3)$
  - Meet: Coarsest common refinement
    - For example: $(1 2 | 3) Meet (1 | 2 3) = (1 | 2 | 3)$
  - Applications: Clustering, database normalization
]
// TODO: visualize

#v(1fr)
#Block(color: blue)[
  Lattices aren't just abstract algebra --- they appear everywhere in computer science and mathematics.

  The _join_ and _meet_ operations capture fundamental patterns of _combination_ and _interaction_.
]
#v(1fr)

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

== TODO

- Applications of lattices in:
  - Formal concept analysis
  - Domain theory in computer science
  - Algebraic topology
  - Cryptography (lattice-based cryptography)
- Advanced topics in set theory:
  - Cardinal arithmetic
  - Ordinal numbers
  - Forcing and independence results
  - Large cardinals
- Connections to Boolean algebra (next lecture)
- Applications in formal logic and proof theory

== Looking Ahead: Boolean Algebra

The next lecture will explore _Boolean algebra_, which provides the mathematical foundation for:
- Digital circuit design and computer hardware
- Propositional logic and automated reasoning
- Database query optimization
- Formal verification of software and hardware systems

Key topics will include:
- Boolean functions and their representations
- Normal forms (CNF, DNF)
- Minimization techniques (Karnaugh maps, Quine-McCluskey)
- Functional completeness and Post's theorem
- The satisfiability problem (SAT) and its computational complexity

== Preview: Formal Logic

Following Boolean algebra, we will study _formal logic_, covering:
- Propositional and predicate logic
- Natural deduction and proof systems
- Completeness and soundness theorems
- Applications to program verification and AI reasoning

This progression from sets $to$ relations $to$ functions $to$ Boolean algebra $to$ logic provides a solid foundation for advanced topics in discrete mathematics and computer science.

#Block(color: purple)[
  *Binary relations* are the bridge between sets and functions --- they model how objects _connect_, _organize_, and _interact_ in mathematical structures and real-world systems.
]

// == Bibliography
// #bibliography("refs.yml")

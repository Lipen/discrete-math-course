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
// Show e.g. in italic:
#show "e.g.": set text(style: "italic")
// Shot etc. in italic:
#show "etc.": set text(style: "italic")

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
#let lexleq = math.prec.eq // $rel(scripts(leq)_"lex")$
#let lexlt = math.prec // $rel(scripts(lt)_"lex")$
#let subtype = $subset.sq.eq$
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


= Properties of Relations
#focus-slide()

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

#examples[
  - Identity relation $I_M$ is coreflexive.
    Any subset of $I_M$ is also coreflexive.
  - Equality relation "$=$" is left and right Euclidean.
  - "Being in the same equivalence class" is Euclidean in both directions.
]


= Equivalence Relations
#focus-slide()

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
  - Different representations $pair(a, b)$ and $pair(c, d)$ belong to the same equivalence class iff they represent the same fraction: $a/b = c/d$
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


= Composition of Relations
#focus-slide()

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

  To find $R relcomp S$, we look for pairs $pair(i, z)$ where there exists $w$ such that $pair(i, w) in R$ and $pair(w, z) in S$:

  From $1$: can reach $a$ and $b$ via $R$
  - $a$ connects to $x$ via $S$ $=>$ $pair(1, x)$ is in the composition
  - $b$ connects to $y$ via $S$ $=>$ $pair(1, y)$ is in the composition

  From $2$: can reach $c$ via $R$
  - $c$ connects to $x$ via $S$ $=>$ $pair(2, x)$ is in the composition

  From $3$: can reach $d$ via $R$
  - $d$ has no outgoing connections in $S$ $=>$ no pairs from $3$ in the composition

  Therefore: $R relcomp S = {pair(1, x), pair(1, y), pair(2, x)}$
]

#v(1em)
#place(center)[
  #import fletcher: diagram, edge, node
  #diagram(
    // debug: true,
    spacing: (5em, 2em),
    node-shape: fletcher.shapes.circle,
    edge-stroke: 1pt + blue,
    blob((-1, 0.5), [$1$], tint: blue, name: <1>),
    blob((-1, 1.5), [$2$], tint: blue, name: <2>),
    blob((-1, 2.5), [$3$], tint: blue, name: <3>),
    blob((0, 0), [$a$], tint: yellow, name: <a>),
    blob((0, 1), [$b$], tint: yellow, name: <b>),
    blob((0, 2), [$c$], tint: yellow, name: <c>),
    blob((0, 3), [$d$], tint: red, name: <d>),
    blob((1, 1), [$x$], tint: green, name: <x>),
    blob((1, 2), [$y$], tint: green, name: <y>),
    edge(<1>, <a>, "-}>"),
    edge(<1>, <b>, "-}>"),
    edge(<2>, <c>, "-}>"),
    edge(<3>, <d>, "-}>"),
    edge(<a>, <x>, "-}>"),
    edge(<b>, <y>, "-}>"),
    edge(<c>, <x>, "-}>"),
    edge(<1>, <x>, "--}>", bend: 10deg, stroke: green.darken(20%)),
    edge(<1>, <y>, "--}>", bend: -10deg, stroke: green.darken(20%)),
    edge(<2>, <x>, "--}>", bend: -10deg, stroke: green.darken(20%)),
    node((rel: (0cm, -2em), to: <d.south>), align(left)[
      #set text(size: 0.8em)
      Edges legend:
      - #text(fill: blue.darken(20%))[Solid: Relations $R$ and $S$]
      - #text(fill: green.darken(20%))[Dashed: Composition $R relcomp S$]
      - #text(fill: red.darken(20%))[Red: Dead end (no outgoing path)]
    ]),
  )
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

#place(center)[
  #import fletcher: diagram, edge, node
  #diagram(
    spacing: 3em,
    node-corner-radius: 2pt,
    edge-stroke: 1pt + navy,
    blob((0, 0), [$1$], tint: green, name: <1>),
    edge("-}>"),
    blob((1, 0), [$2$], tint: orange, name: <2>),
    edge("-}>"),
    blob((2, 0), [$3$], tint: blue, name: <3>),
    edge("-}>"),
    blob((3, 0), [$4$], tint: red, name: <4>),
    edge(<1>, <3>, "--}>", bend: 45deg, stroke: blue.darken(20%), label: [$R^2$]),
    edge(<2>, <4>, "--}>", bend: 45deg, stroke: blue.darken(20%), label: [$R^2$]),
    edge(<1>, <4>, "--}>", bend: -30deg, stroke: green.darken(20%), label: [$R^3$]),
  )
]

== Paths in Graphs

#example[Path composition in a graph][
  Consider a directed graph with vertices ${A, B, C, D}$ and relation~$R$ representing direct edges:
  $R = {pair(A, B), pair(B, C), pair(B, D), pair(C, D)}$

  #place(right, dx: -3cm, dy: 1em)[
    #import fletcher: diagram, edge, node
    #diagram(
      spacing: 2em,
      node-shape: fletcher.shapes.circle,
      edge-stroke: 1pt + navy,
      blob((0, 0), [$A$], tint: green, name: <a>),
      blob((1, 0), [$B$], tint: orange, name: <b>),
      blob((2, 1), [$C$], tint: blue, name: <c>),
      blob((2, -1), [$D$], tint: red, name: <d>),
      edge(<a>, <b>, "-}>"),
      edge(<b>, <c>, "-}>"),
      edge(<b>, <d>, "-}>"),
      edge(<c>, <d>, "-}>"),
      edge(<a>, <c>, "--}>", bend: -30deg, stroke: blue.darken(20%)),
      edge(<a>, <d>, "--}>", bend: 30deg, stroke: blue.darken(20%)),
      edge(<b>, <d>, "--}>", bend: 30deg, stroke: blue.darken(20%)),
      edge(<a>, <d>, "--}>", bend: 60deg, stroke: green.darken(20%)),
    )
  ]

  Powers of $R$ represent paths of different lengths:
  - $R^1 = R$ (direct connections)
  - $R^2 = R compose R$ (2-step paths):
    - $pair(A, C)$: path $A to B to C$
    - $pair(A, D)$: path $A to B to D$
    - $pair(B, D)$: path $B to C to D$
    - So $R^2 = {#Blue[$pair(A, C), pair(A, D), pair(B, D)$]}$.
  - $R^3 = R^2 compose R$ (3-step paths):
    - $pair(A, D)$: path $A to B to C to D$
    - No more 3-step paths!
    - So $R^3 = {#Green[$pair(A, D)$]}$.
  - $R^4 = emptyset$ (no 4-step paths)
]

// TODO: move this theorem after(into) closures
// #theorem[
//   For any relation $R$ on a finite set with $n$ elements:
//   - $R^+ = R^1 union R^2 union dots union R^n$ is a _transitive closure_.
//   - $R^* = R^0 union R^+ = I union R^+$ is a _reflexive-transitive closure_.
// ]

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
  - *Reflexive:* $x leq x$ for all $x in RR$ #YES
  - *Antisymmetric:* If $x leq y$ and $y leq x$, then $x = y$ #YES
  - *Transitive:* If $x leq y$ and $y leq z$, then $x leq z$ #YES
  - *Connected:* For any $x, y in RR$, either $x leq y$ or $y leq x$ #YES

  This is the most familiar example of an order relation.
  Similarly, $NN$, $ZZ$, and $QQ$ with $leq$ are all total orders.
]

#align(center)[
  #cetz.canvas(length: 1cm, {
    import cetz.draw: *

    // Custom function for curvy edges
    let curvy-edge(from, to, height: 0.5, color: blue, label: none) = {
      let mid-x = (from + to) / 2
      let control1 = (from + 0.3 * (to - from), height)
      let control2 = (to - 0.3 * (to - from), height)

      // Control points for the Bézier curve
      let p0 = (from, 0)
      let p1 = (from + 0.3 * (to - from), height)
      let p2 = (to - 0.3 * (to - from), height)
      let p3 = (to, 0)

      bezier(p0, p3, p1, p2, stroke: 1.5pt + color, mark: (end: ">", fill: color))

      // Function to calculate point on Bézier curve at parameter t
      // Cubic Bézier formula: B(t) = (1-t)³P₀ + 3(1-t)²tP₁ + 3(1-t)t²P₂ + t³P₃
      let point-on-bezier(t) = {
        let t1 = 1 - t
        cetz.vector.add(
          cetz.vector.add(
            cetz.vector.scale(p0, calc.pow(t1, 3)),
            cetz.vector.scale(p1, 3 * calc.pow(t1, 2) * t),
          ),
          cetz.vector.add(
            cetz.vector.scale(p2, 3 * t1 * calc.pow(t, 2)),
            cetz.vector.scale(p3, calc.pow(t, 3)),
          ),
        )
      }

      if label != none {
        // Use midpoint of the curve (t=0.5) for label positioning
        let label-pos = point-on-bezier(0.5)
        content(
          label-pos,
          text(10pt, fill: color)[#label],
          anchor: if height > 0 { "south" } else { "north" },
          padding: 0.1,
        )
      }
    }

    // Draw main number line
    line((-5, 0), (5, 0), stroke: 2pt + black, mark: (symbol: ">", fill: black))

    // Draw ticks and numbers
    for i in range(-4, 5) {
      line((i, -0.1), (i, 0.1), stroke: 1pt + black)
      content((i, 0), text(10pt, str(i)), anchor: "north", padding: 0.2)
    }

    // Add infinity labels
    content((-5, 0), anchor: "north", padding: 0.2, [$-infinity$])
    content((5, 0), anchor: "north", padding: 0.2, [$+infinity$])

    // Draw some curvy order edges
    curvy-edge(-3, -1, height: 0.6, color: blue, label: $-3 leq -1$)
    curvy-edge(-1, 2, height: 0.9, color: red, label: $-1 leq 2$)
    curvy-edge(0, 3, height: -0.9, color: green, label: $0 leq 3$)
    curvy-edge(-2, 1, height: -0.9, color: purple, label: $-2 leq 1$)

    // Add title
    content((0, -1.6))[Linear order $leq$ on real numbers $RR$]
  })
]

#pagebreak()

#example[
  The _subset relation_ $subset.eq$ on the power set $power(A)$ is a *partial order*.

  *Verification:*
  - *Reflexive:* $X subset.eq X$ for all $X subset.eq A$ #YES
    - Every set is a subset of itself by definition
  - *Antisymmetric:* If $X subset.eq Y$ and $Y subset.eq X$, then $X = Y$ #YES
    - If every element of $X$ is in $Y$, and every element of $Y$ is in $X$, then $X$ and $Y$ have the same elements
  - *Transitive:* If $X subset.eq Y$ and $Y subset.eq Z$, then $X subset.eq Z$ #YES
    - If every element of $X$ is in $Y$, and every element of $Y$ is in $Z$, then every element of $X$ is in $Z$

  For $A = {1, 2}$, we have $power(A) = {emptyset, {1}, {2}, {1,2}}$ with:
  - $emptyset subset.eq {1} subset.eq {1,2}$ (this is a chain)
  - $emptyset subset.eq {2} subset.eq {1,2}$ (another chain)
  - But ${1}$ and ${2}$ are _incomparable_ (neither is a subset of the other)

  This is _not_ a total order because not all pairs are comparable.
]
// TODO: visualize

#pagebreak()

#example[
  #let nolonger = $prec.curly.eq$
  Consider the _no longer than_ relation $nolonger$ on binary strings $BB^*$:
  $
    x nolonger y quad "iff" quad "len"(x) <= "len"(y)
  $

  *Verification:*
  - *Reflexive:* $x nolonger x$ for all $x in BB^*$ #YES
    - $"len"(x) <= "len"(x)$ is always true
  - *Transitive:* If $x nolonger y$ and $y nolonger z$, then $x nolonger z$ #YES
    - If $"len"(x) <= "len"(y)$ and $"len"(y) <= "len"(z)$, then $"len"(x) <= "len"(z)$ by transitivity of $<=$
  - *Antisymmetric:* #NO
    - Counter-example: $01 nolonger 10$ and $10 nolonger 01$ (since both have length 2), but $01 neq 10$
  - *Connected:* For any $x, y in BB^*$, either $x nolonger y$ or $y nolonger x$ #YES
    - Either $"len"(x) <= "len"(y)$ or $"len"(y) <= "len"(x)$ (or both)

  This is a _preorder_ (reflexive and transitive), and even connected, but _not a partial order_ due to lack of antisymmetry.
  Different strings of the same length are all "equivalent" under this relation, but they're not actually equal.
]
// TODO: visualize

#pagebreak()

#example[
  _Divisibility_ $|$ on positive integers $NN^+$ is a *partial order*.

  *Verification:*
  - *Reflexive:* $n | n$ for all $n in NN^+$ (every number divides itself) #YES
  - *Antisymmetric:* If $a | b$ and $b | a$, then $a = b$ #YES
    - If $a$ divides $b$, then $b = a k$ for some positive integer $k$
    - If $b$ divides $a$, then $a = b ell$ for some positive integer $ell$
    - Substituting: $b = a k = (b ell) k = b k ell$, so $k ell = 1$
    - Since $k, ell in NN^+$, we must have $k = ell = 1$, hence $a = b$
  - *Transitive:* If $a | b$ and $b | c$, then $a | c$ #YES
    - If $a | b$, then $b = a k$ for some integer $k$
    - If $b | c$, then $c = b ell$ for some integer $ell$
    - Therefore: $c = b ell = (a k) ell = a (k ell)$, so $a | c$
  - *Connected:* #NO
    - Counter-example: $2$ does not divide $3$, and $3$ does not divide $2$

  This is a _partial order_ but not a total order because some pairs are incomparable.
]
// TODO: visualize

#pagebreak()

#example[
  _Lexicographic order_ on strings $A^n$ (like dictionary order) is a *total order*.

  *Verification:*
  - *Reflexive:* $s lexleq s$ for all strings $s$ #YES
    - A string is lexicographically equal to itself
  - *Antisymmetric:* If $s lexleq t$ and $t lexleq s$, then $s = t$ #YES
    - If $s$ comes before or equals $t$ AND $t$ comes before or equals $s$, then $s = t$
  - *Transitive:* If $s lexleq t$ and $t lexleq u$, then $s lexleq u$ #YES
    - Lexicographic comparison preserves transitivity through character-by-character comparison
  - *Connected:* For any strings $s, t$, either $s lexleq t$ or $t lexleq s$ #YES
    - We can always compare strings lexicographically by comparing character by character

  For binary strings of length 2: $00 lexlt 01 lexlt 10 lexlt 11$

  // *Lexicographic Comparison Algorithm:*
  // - Compare strings character by character from left to right
  // - The first differing position determines the order
  // - If one string is a prefix of another, the shorter one comes first

  *Key property:* Every pair of strings is _comparable_, making this a _total order_.
]

// TODO: strict orders!

== Partially Ordered Sets

// Poset
#definition[
  A _partially ordered set_ (or _poset_) $pair(S, leq)$ is a set $S$ equipped with a partial order $leq$.
]

#example[
  Consider the poset $pair(D, |)$ where $D = {1, 2, 3, 4, 6, 12}$ and $|$ is divisibility.

  #place(right, dx: -1cm)[
    #cetz.canvas({
      import cetz.draw: *

      let w = 1.4
      let h = 1
      let hgap = 1.2
      let vgap1 = 1
      let vgap2 = 1.5

      let draw-vertex((x, y), name, label) = {
        circle((x, y), radius: 0.4, name: name)
        content(name, [#label])
      }
      let draw-edge(start, end) = {
        line(start, end, mark: (end: "stealth", fill: black))
      }
      let draw-transitive-edge(start, end) = {
        let color = gray
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
  - Multiple _maximal_ elements: $3$, $20$, $35$ (no single greatest element)
  - Some _chains_ (not necessarily maximal, can skip elements):
    - Chain: $1 | 2 | 4$ (powers of 2)
    - Chain: $1 | 10 | 20$ (multiples of 10)
    - Chain: $5 | 35$ (multiples of 5)
  - Primes $2$, $3$, $5$ are _incomparable_ to each other
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
]

#note[
  "$lt$" denotes the _induced strict order_:
  $
    x < y quad "iff" quad (x leq y) and (x neq y)
  $
]

#note[
  Hasse diagram is just a graph of a covering relation!
]

== Maximal and Minimal Elements

// Maximal element
#definition[
  An element $m in S$ is called a _maximal element_ of a poset $pair(S, leq)$ if it is not less than any other element, i.e., there is no even greater element.
  $
    forall x != m. thin not (m leq x)
    quad iff quad
    exists.not x != m. thin (m leq x)
  $
  Equivelently, $forall x in S. thin (m leq x) imply (m = x)$
]

// Minimal element
#definition[
  An element $m in S$ is called a _minimal element_ of a poset $pair(S, leq)$ if it is not greater than any other element, i.e., there is no even smaller element.
  $
    forall x != m. thin not (x leq m)
    quad iff quad
    exists.not x != m. thin (x leq m)
  $
  Equivelently, $forall x in S. thin (x leq m) imply (x = m)$
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

#place(right, dx: -5em)[
  #import fletcher: diagram, edge, node
  #diagram(
    spacing: 3em,
    node-shape: fletcher.shapes.circle,
    node-inset: 0pt,
    edge-stroke: 1pt + navy,
    blob((0, 0), [$2$], width: 1.5em, tint: blue, name: <2>),
    blob((1, 0), [$3$], width: 1.5em, tint: blue, name: <3>),
    blob((0, -1), [$4$], width: 1.5em, stroke: navy, name: <4>),
    blob((1, -1), [$6$], width: 1.5em, stroke: navy, name: <6>),
    blob((0, -2), [$8$], width: 1.5em, tint: red, name: <8>),
    blob((1, -2), [$12$], width: 1.5em, tint: red, name: <12>),
    edge(<2>, <4>, "-}>"),
    edge(<2>, <6>, "-}>"),
    edge(<3>, <6>, "-}>"),
    edge(<4>, <8>, "-}>"),
    edge(<4>, <12>, "-}>"),
    edge(<6>, <12>, "-}>"),
  )
]

*Hasse diagram:*
- #Red[Maximal elements] (8, 12) --- they divide nothing else in $S$
- #Blue[Minimal elements] (2, 3) --- nothing in $S$ divides them
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

== Converse Orders

#definition[
  The _dual_ (or _converse_) of a poset $pair(S, leq)$ is the poset $pair(S, geq)$ where $x geq y$ iff $y leq x$.
]

#example[
  Consider the $NN^+$ ordered naturally.
  - For $leq$ order:
    - The _$leq$-least_ element is $1$, since it is _$leq$-smaller_ than all others.
    - $1$ is also $leq$-minimal, since there are no other element which is $leq$-smaller than $1$.
    - There are _no $leq$-maximal_ elements, since the set is unbounded above.
    - On the Hasse diagram, $1$ is at the bottom, and the diagram extends infinitely _upwards_.

  - For $geq$ order, minimal and maximal elements "flip":
    - There are _no $geq$-minimal_ elements.
      A $geq$-minimal element would be an element $m$ such that there is no other ($geq$-smaller) element $n != m$ with $n geq m$.
      However, for any $m in NN^+$, there exists $n = m + 1$ which is $n geq m$, so no such $geq$-minimal element exists.
    - The _$geq$-greatest_ element is $1$, since all elements are _$geq$-smaller_ than it.
    // - $1$ is also $geq$-maximal, since there are no other element which is $geq$-greater than $1$.
    - On the Hasse diagram, $1$ is at the top, and the diagram extends infinitely _downwards_.
]

== Notes on Converse Orders

#note[
  - Maximal elements in $pair(S, leq)$ become minimal in $pair(S, geq)$ and vice versa.
  - Greatest element in $pair(S, leq)$ becomes least in $pair(S, geq)$ and vice versa.
  - Chains and antichains remain the same in both orders.
  - The Hasse diagram is flipped vertically when taking the dual order.
    - For $pair(NN^+, leq)$:
      - The _least_ element $1$ is at the bottom.
      - The diagram of $pair(NN^+, leq)$ extends infinitely _upwards_.
    - In the dual $pair(NN^+, geq)$:
      - $1$ becomes the _greatest_ element at the top.
      - The diagram of $pair(NN^+, geq)$ extends infinitely _downwards_.
]

== Chains and Antichains

// Chain and Antichain
#definition[
  In a partially ordered set $pair(M, leq)$:

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

#note[
  - Chains correspond to arbitrary paths or sub-sequences in the Hasse diagram.
  - A _maximal chain_ is a chain that cannot be extended by including any other elements from $M$.
  - A _maximum chain_ is a chain of the largest possible size in $M$.
  - A chain is a _totally ordered subset_ of the poset.
  - An antichain consists of _pairwise incomparable elements_.
  - Any singleton set is both a chain and an antichain.
]

== Examples of Chains and Antichains

#example[
  Consider the divisibility poset $pair(D, |)$ where $D = {1, 2, 3, 4, 5, 6, 10, 20, 35}$.

  #place(right, dx: -4em, dy: 0.5em)[
    #import fletcher: diagram, edge, node
    #diagram(
      spacing: (3em, 2.5em),
      node-shape: fletcher.shapes.circle,
      node-inset: 0pt,
      node-stroke: 1pt,
      edge-stroke: 1pt,
      mark-scale: 50%,
      node((0, 0), [1], width: 1.5em, name: <1>),
      node((-0.5, -1), [2], width: 1.5em, name: <2>),
      node((-0.5, -2), [4], width: 1.5em, name: <4>, fill: red.lighten(80%)),
      node((0.5, -1), [5], width: 1.5em, name: <5>),
      node((0.5, -2), [10], width: 1.5em, name: <10>, fill: red.lighten(80%)),
      node((0, -3), [20], width: 1.5em, name: <20>),
      node((1.5, -2), [35], width: 1.5em, name: <35>, fill: red.lighten(80%)),
      node((-1.5, -2), [3], width: 1.5em, name: <3>, fill: red.lighten(80%)),
      edge(<1>, <2>, "-}>", bend: 30deg, stroke: 2pt + blue),
      edge(<1>, <5>, "-}>", bend: -30deg),
      edge(<2>, <4>, "-}>", stroke: 2pt + blue),
      edge(<2>, <10>, "-}>"),
      edge(<5>, <10>, "-}>"),
      edge(<5>, <35>, "-}>", bend: -30deg),
      edge(<4>, <20>, "-}>", bend: 30deg, stroke: 2pt + blue),
      edge(<10>, <20>, "-}>", bend: -30deg),
      edge(<1>, <3>, "-}>", bend: 30deg),
    )
  ]

  *Chains:* (totally ordered subsets)
  - Maximal chain: #Blue[${1, 2, 4, 12}$] --- longest path
  - Not maximal: ${5, 10}$
  - Can _skip_ elements: ${1, 5, 20}$

  *Maximal elements:* $3$, $20$, $35$

  *Antichains:* (pairwise incomparable elements)
  - Maximal antichain: #Red[${3, 4, 10, 35}$]
  - Incomparable on the same level: ${2, 5}$
  - Incomparable from different levels: ${3, 2, 35}$

  *Dilworth's theorem:*
  Maximum antichain size (4) = minimum chains needed to cover (4).
]

#pagebreak()

#example[
  In a Git repository, commits form a poset under the "ancestor" relation:
  - *Chain:* A sequence of commits on a single branch (linear history).
  - *Antichain:* Commits on different branches that have diverged (no ancestry relation).

  *Practical insight:* Merge commits combine multiple antichains back into a single chain.
]

== Chains and Antichains in Scheduling

#example[
  In project management, tasks form a scheduling poset under the "_prerequisite_" relation.

  Consider web development tasks: Design, Backend, Frontend, Testing, Deploy, Documentation.

  #place(right, dx: -3em)[
    #import fletcher: diagram, edge, node
    #diagram(
      spacing: (2em, 2em),
      node-shape: fletcher.shapes.rect,
      node-corner-radius: 0.2em,
      node-stroke: 1pt,
      node-outset: 1pt,
      edge-stroke: 1pt,
      node((0, 0), [Design], name: <Des>),
      node((1, -1), [Backend], name: <Back>),
      node((1, 1), [Frontend], name: <Front>),
      node((2, 0), [Testing], name: <Test>),
      node((3, 0), [Deploy], name: <Deploy>),
      node((0, -1), [Documentation], name: <Doc>),
      edge(<Des>, <Back>, "-}>", stroke: 2pt + red, mark-scale: 50%),
      edge(<Des>, <Front>, "-}>"),
      edge(<Back>, <Test>, "-}>", stroke: 2pt + red, mark-scale: 50%),
      edge(<Front>, <Test>, "-}>"),
      edge(<Test>, <Deploy>, "-}>", stroke: 2pt + red, mark-scale: 50%),
      edge(<Des>, <Doc>, "-}>"),
    )
  ]

  *Dependencies:*
  - $"Design" prec "Back", "Front"$
  - $"Back", "Front" prec "Test"$
  - $"Test" prec "Deploy" prec "Doc"$

  *Antichain analysis:*
  - ${"Back", "Front"}$ can run in parallel after Design
  - ${"Deploy", "Doc"}$ can run in parallel (final tasks)

  #Red[*Critical path*]: $"Design" to "Back" to "Test" to "Deploy"$ (length 3 max chain)

  *Practical insights:*
  - Chains = sequential dependencies (critical path)
  - Antichains = tasks for parallel execution (resource allocation)
  - Project duration = length of longest chain
]

== Dilworth's Theorem

#theorem[Dilworth][
  In any finite partially ordered set, the maximum size of an antichain equals the minimum number of chains needed to cover the entire set.
]

#example[
  Consider the divisibility poset on $P = {2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60}$.

  #place(right, dy: -1em)[
    #import fletcher: diagram, edge, node
    #diagram(
      spacing: (1.8em, 1.4em),
      node-shape: fletcher.shapes.circle,
      node-stroke: 1pt,
      edge-stroke: 0.8pt,
      // Level 0: primes 2, 3, 5 (minimal elements)
      node((-1.5, 0), [2], width: 1.1em, name: <2>),
      node((0, 0), [3], width: 1.1em, name: <3>),
      node((1.5, 0), [5], width: 1.1em, name: <5>),
      // Level 1: products of two primes (antichain)
      node((-2, -1), [4], width: 1.1em, name: <4>, fill: red.lighten(80%)),
      node((-1, -1), [6], width: 1.1em, name: <6>, fill: red.lighten(80%)),
      node((0, -1), [10], width: 1.1em, name: <10>, fill: red.lighten(80%)),
      node((1.5, -1), [15], width: 1.1em, name: <15>, fill: red.lighten(80%)),
      // Level 2: products of three prime factors
      node((-1.5, -2), [12], width: 1.1em, name: <12>),
      node((0, -2), [20], width: 1.1em, name: <20>),
      node((1.5, -2), [30], width: 1.1em, name: <30>),
      // Level 3: 60
      node((0, -3), [60], width: 1.1em, name: <60>),

      // Edges to level 1
      edge(<2>, <4>, "-}>"),
      edge(<2>, <6>, "-}>"),
      edge(<2>, <10>, "-}>"),
      edge(<3>, <6>, "-}>"),
      edge(<3>, <15>, "-}>"),
      edge(<5>, <10>, "-}>"),
      edge(<5>, <15>, "-}>"),
      // Edges to level 2
      edge(<4>, <12>, "-}>"),
      edge(<6>, <12>, "-}>"),
      edge(<4>, <20>, "-}>"),
      edge(<10>, <20>, "-}>"),
      edge(<6>, <30>, "-}>"),
      edge(<10>, <30>, "-}>"),
      edge(<15>, <30>, "-}>"),
      // Edges to 60
      edge(<12>, <60>, "-}>"),
      edge(<20>, <60>, "-}>"),
      edge(<30>, <60>, "-}>"),
    )
  ]

  *Maximum antichain:* ${4, 6, 10, 15}$ (size 4)
  - These elements are pairwise _incomparable_ (none divides another).

  *Minimum chain decomposition:* We need exactly 4 chains that _cover_ $P$:
  - Chain 1: $2 | 4 | 12 | 60$
  - Chain 2: $3 | 6 | 30$
  - Chain 3: $5 | 10 | 20$
  - Chain 4: $15$ (singleton chain)

  Each element appears in exactly one chain, forming a _partition_ of $P$.

  *Dilworth's theorem:* Maximum _antichain_ size (4) = Minimum number of _disjoint chains_ (4). #YES
]

== Proof of Dilworth's Theorem

#proof[
  Let $pair(P, leq)$ be a finite poset.
  Let $alpha$ denote the maximum size of an antichain in $P$, and let $beta$ denote the minimum number of chains needed to cover $P$.
  We prove $alpha = beta$ by showing $alpha <= beta$ and $alpha >= beta$.

  *Easy part ($alpha <= beta$):*
  Suppose $P$ can be partitioned into $k$ chains $C_1, dots, C_k$.
  Let $A$ be any antichain in $P$.
  Since elements in an antichain are pairwise incomparable, each chain contains at most one element of $A$.
  Therefore $abs(A) <= k$.
  Taking the maximum over all antichains gives $alpha <= k$.
  Since this holds for any chain partition, we have $alpha <= beta$.
  #h(1fr) $qed$

  #colbreak()

  *Hard part ($alpha >= beta$):*
  Let $A subset.eq P$ be a maximal antichain of size $alpha$.

  We construct a chain partition of $P$ of size $alpha$ as follows:
  - Initialize $cal(C) := emptyset$.
  - While $P != emptyset$:
    + Choose a maximal element $x in P$ (no element above $x$ in the remaining poset).
    + Build a chain $C$ ending at $x$:
      - Start with $C := { x }$.
      - Repeatedly add a maximal _predecessor_ element $y in P setminus C$ such that $y < "current bottom of" C$.
    + Add $C$ to $cal(C)$ and remove all elements of $C$ from $P$.

  By construction:
  - Each $C in cal(C)$ is a chain (elements are added only below the current bottom).
  - Chains in $cal(C)$ cover all elements of $P$.
  - Each chain contains exactly one element of the maximal antichain $A$, so $abs(cal(C)) = alpha$.

  Therefore $P$ can be covered by $alpha$ chains, giving $beta <= alpha$.
]

== Summary: Orders

#Block(color: orange)[
  *Orders* provide structured ways to compare and rank elements:
  - _Preorders:_ Basic comparison (reflexive, transitive)
  - _Partial orders:_ Add antisymmetry for unique comparisons
  - _Total orders:_ Every pair of elements is comparable

  *Visualization:* Hasse diagrams clearly show structure and hierarchy by omitting redundant transitive edges, revealing _chains_ (ordered sequences) and _antichains_ (incomparable elements).
]

#Block(color: teal)[
  *Applications:* Task scheduling • Git version control • Database indexing • Type hierarchies • Boolean algebra • Concurrent systems • Build systems (dependency resolution) • Social networks • File system permissions • Web page ranking • Package managers • Distributed systems
]


// TODO: add intermediate slide to explain the abrupt transition from orders to functions: we need to cover cardinality, which requires bijections, which are special kinds of functions. After that, we are going to return back to cover well orders.


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

  This "exactly one" requirement breaks down into two conditions:
  + _Functional property_ (_right-unique_ or _well-defined_):
    Each input has _at most one_ output. No input can map to multiple different outputs.
    $
      forall a in A. thin
      forall b_1, b_2 in B. thin
      (f(a) = b_1) and (f(a) = b_2) imply (b_1 = b_2)
    $

  + _Total property_ (_left-total_ or _defined everywhere_):
    Each input has _at least one_ output. Every element in the domain must map to something.
    $
      forall a in A. thin
      exists b in B. thin
      f(a) = b
    $
]

#definition[
  A relation that satisfies only the _functional_ property (but not necessarily total) is called a _partial function_, denoted $f: A arrow.r.hook B$.
  It may be undefined for some inputs.

  A relation that satisfies _both_ properties is called a _total function_, denoted $f: A to B$.
  It is defined for every input in its domain.
]

#note[
  In most contexts, when we say "function" we mean _total function_.
  Partial functions are explicitly noted when needed, especially in computability theory and programming language semantics.
]

== Examples of Functions

#example[Partial functions][
  - *Division*: $f: RR times RR arrow.r.hook RR$ defined by $f(x, y) = x / y$ is partial because $f(x, 0)$ is undefined.

  - *Square root on integers*: $g: ZZ arrow.r.hook RR$ defined by $g(n) = sqrt(n)$ is partial because negative integers have no real square root.

  - *Array access*: $"arr": NN arrow.r.hook T$ where $"arr"(i)$ returns the element at index $i$, but is undefined for out-of-bounds indices.

  - *Head of list*: $"head": "List"[T] arrow.r.hook T$ returns the first element, but is undefined for empty lists.
]

#example[Total functions][
  - *Absolute value*: $|dot|: RR to RR$ is total --- defined for all real numbers.

  - *Successor*: $S: NN to NN$ defined by $S(n) = n + 1$ is total --- defined for all natural numbers.

  - *Constant function*: $f: A to B$ defined by $f(x) = b_0$ for some fixed $b_0 in B$ is always total.
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

#place(bottom + right)[
  #cetz.canvas({
    import cetz.draw: *

    scale(75%)

    let w = 3.2

    let draw-element((x, y), label, name, dir) = {
      circle((x, y), radius: 0.1, stroke: 1pt, name: name)
      content(
        name,
        [#label],
        anchor: if dir == left { "east" } else { "west" },
        padding: 0.2,
      )
    }

    let draw-edge(start, end, color: blue) = {
      line(
        start,
        end,
        stroke: 1pt + color,
        mark: (end: "stealth", fill: color),
        name: start + "-" + end,
      )
    }

    // Draw domain and codomain ellipses
    circle((0, 0), radius: (1, 2))
    circle((w, 0), radius: (1, 2))

    // Draw elements in domain and codomain
    draw-element((0, 1), $1$, "1", left)
    draw-element((0, 0), $2$, "2", left)
    draw-element((0, -1), $3$, "3", left)

    draw-element((w, 1), $x$, "x", right)
    draw-element((w, 0), $y$, "y", right)
    draw-element((w, -1), $z$, "z", right)

    // Draw edges representing the function
    draw-edge("1", "x")
    draw-edge("2", "y")
    draw-edge("3", "x")

    // Draw labels
    // content((w / 2, -2.4), [$f: A to B$])
  })
]

#example[
  Let $A = {1, 2, 3}$ and $B = {x, y, z}$, and define $f = {pair(1, x), pair(2, y), pair(3, x)}$.
  - $f: A to B$ is a function from $A$ to $B$
  - $Dom(f) = A = {1, 2, 3}$ ("from")
  - $Cod(f) = B = {x, y, z}$ ("to")
  - $Range(f) = {x, y} subset B$ (note that $z$ is not in the range)
  - We have $f(1) = x$, $f(2) = y$, $f(3) = x$

]

== Examples of Domain, Codomain, Range

#example[
  Consider the _squaring_ function $g: ZZ to ZZ$ defined by $g(n) = n^2$.
  - $Dom(g) = Cod(g) = ZZ$ (all integers)
  - $Range(g) = {0, 1, 4, 9, 16, dots} = {n^2 | n in NN}$ (non-negative perfect squares)

  Note that the range of $g$ is a proper subset of the codomain: $Range(g) subset Cod(g)$, since $-1 notin Range(g)$.
]

#example[
  The _absolute value_ function $f: RR to RR$ defined by $f(x) = abs(x)$:
  - $Dom(f) = Cod(f) = RR$ (all real numbers)
  - $Range(f) = [0, infinity) = {y in RR | y >= 0}$ (non-negative reals)
]

#example[
  The _exponential_ function $exp: RR to (0, infinity)$ defined by $exp(x) = e^x$:
  - $Dom(exp) = RR$ (all real numbers)
  - $Cod(exp) = (0, infinity)$ (positive real numbers)
  - $Range(exp) = (0, infinity)$ (same as codomain --- this function is _surjective_!)

  Note the careful choice of codomain: if we used $exp: RR to RR$, the range would still be $(0, infinity)$,
  making it not surjective.
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
  $
    f^(-1)(T) = { a in A | f(a) in T }
  $
]

#note[
  The notation $f^(-1)(S)$ is used even if the inverse function $f^(-1)$ does not exist (i.e., if $f$ is not bijective).
  It always refers to the set of domain elements that map into $S$.
]

== Examples of Image and Preimage

#example[
  Let $f: ZZ -> ZZ$ be $f(x) = x^2$.
  - Let $S = {-2, -1, 0, 1, 2}$.
    - Then $f(S) = {f(-2), f(-1), f(0), f(1), f(2)} = {4, 1, 0, 1, 4} = {0, 1, 4}$.

  - Let $T_1 = {1, 9}$.
    - The preimage is $f^(-1)(T_1) = {x in ZZ | x^2 in {1, 9}} = {-3, -1, 1, 3}$.

  - Let $T_2 = {2, 3}$.
    - The preimage is $f^(-1)(T_2) = {x in ZZ | x^2 in {2, 3}} = emptyset$.
]

== Injective Functions

#definition[
  A function $f: A to B$ is _injective_ (or _one-to-one_#footnote[
    Do not confuse "one-to-one" with "one-to-one correspondence", which refers to a _bijection_ --- another concept!
  ]) if distinct elements in the domain map to distinct elements in the codomain.
  Formally:
  $
    forall a_1, a_2 in A. thin
    (f(a_1) = f(a_2)) imply (a_1 = a_2)
  $

  Equivalent formulation:
  $
    forall a_1, a_2 in A. thin
    (a_1 != a_2) imply (f(a_1) != f(a_2))
  $
]

#align(center)[
  #import fletcher: diagram, edge, node
  #diagram(
    node-shape: fletcher.shapes.circle,
    edge-stroke: 1pt,
    blob((0cm, 0cm), $1$, tint: green, name: <A>),
    blob((0cm, -1.5cm), $2$, tint: green, name: <B>),
    blob((3cm, 0cm), $x$, tint: red, name: <X>),
    blob((3cm, -1.5cm), $y$, tint: red, name: <Y>),
    edge(<A>, <X>, "-}>", label-side: center, label-angle: auto)[$f$],
    edge(<B>, <X>, "-}>", label-side: center, label-angle: auto)[$f$],
    render: (grid, nodes, edges, options) => {
      import fletcher: cetz
      cetz.canvas({
        import cetz: draw

        // Background:
        draw.circle((0, -0.75), radius: (0.7, 1.4), stroke: 0.4pt)
        draw.circle((3, -0.75), radius: (0.7, 1.4), stroke: 0.4pt)

        // Main diagram:
        fletcher.draw-diagram(grid, nodes, edges, debug: options.debug)

        // Overlay:
        let (x, y) = (1.5, -0.5)
        let s = 1.8
        draw.line(
          (x - s / 2, y + s / 2),
          (x + s / 2, y - s / 2),
          stroke: (thickness: 2pt, paint: red, cap: "round"),
        )
        draw.line(
          (x - s / 2, y - s / 2),
          (x + s / 2, y + s / 2),
          stroke: (thickness: 2pt, paint: red, cap: "round"),
        )
      })
    },
  )
]

== Examples of Injective Functions

#Block(color: yellow)[
  *Key insight:* An injective function never "collapses" different inputs to the same output.
  Each output has at most one pre-image.
]

#example[
  $f: NN to NN$ defined by $f(n) = 2n$ is injective.
  - If $f(n_1) = f(n_2)$, then $2n_1 = 2n_2$, so $n_1 = n_2$. #YES
]

#example[
  $g: RR to RR$ defined by $g(x) = x^3$ is injective.
  - The cube function is strictly increasing, so distinct inputs give distinct outputs. #YES
]

#example[Computer science applications][
  - *Student ID assignment:* Each student gets a unique ID number.
  - *Hash functions (perfect):* Different data should hash to different values (to avoid collisions).
  - *Primary keys in databases:* Each record must have a unique identifier.
  - *Memory addresses:* Each memory location has a unique address.
]

== Examples of Non-Injective Functions

#example[Counter-examples (not injective functions)][
  - $g: ZZ to ZZ$ defined by $g(n) = n^2$ is _not_ injective.
    - $g(-1) = 1$ and $g(1) = 1$, but $-1 != 1$. #NO

  - $h: RR to RR$ defined by $h(x) = sin(x)$ is _not_ injective.
    - $h(0) = h(pi) = 0$, but $0 != pi$. #NO

  - $f: ZZ to ZZ_5$ defined by $f(x) = x mod 5$ is _not_ injective.
    - $f(2) = f(7) = 2$, but $2 != 7$. #NO
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

#align(center)[
  #import fletcher: diagram, edge, node
  #diagram(
    node-shape: fletcher.shapes.circle,
    edge-stroke: 1pt,
    blob((0cm, 0cm), $1$, tint: green, name: <A>),
    blob((0cm, -1.5cm), $2$, tint: green, name: <B>),
    blob((3cm, 0cm), $x$, tint: red, name: <X>),
    blob((3cm, -1.5cm), $y$, tint: red, name: <Y>),
    edge(<A>, <X>, "-}>", label-side: center, label-angle: auto)[$f$],
    edge(<B>, <X>, "-}>", label-side: center, label-angle: auto)[$f$],
    render: (grid, nodes, edges, options) => {
      import fletcher: cetz
      cetz.canvas({
        import cetz: draw

        // Background:
        draw.circle((0, -0.75), radius: (0.7, 1.4), stroke: 0.4pt)
        draw.circle((3, -0.75), radius: (0.7, 1.4), stroke: 0.4pt)

        // Main diagram:
        fletcher.draw-diagram(grid, nodes, edges, debug: options.debug)

        // Overlay:
        let (x, y) = (3, -1.5)
        let s = 1
        draw.line(
          (x - s / 2, y + s / 2),
          (x + s / 2, y - s / 2),
          stroke: (thickness: 2pt, paint: red, cap: "round"),
        )
        draw.line(
          (x - s / 2, y - s / 2),
          (x + s / 2, y + s / 2),
          stroke: (thickness: 2pt, paint: red, cap: "round"),
        )
      })
    },
  )
]

== Examples of Surjective Functions

#Block(color: yellow)[
  *Key insight:* A surjective function "covers" the entire codomain. Every possible output is actually achieved by some input.
]

#example[
  $f: RR to RR$ defined by $f(x) = x^3$ is surjective.
  - For any $y in RR$, let $x = root(3, y)$. Then $f(x) = (root(3, y))^3 = y$. #YES
]

#example[
  $g: RR to [0, infinity)$ defined by $g(x) = x^2$ is surjective.
  - For any $y >= 0$, let $x = sqrt(y)$. Then $g(x) = (sqrt(y))^2 = y$. #YES
]

#example[
  $f: ZZ to ZZ_5$ defined by $f(x) = x mod 5$ is surjective.
  - Every element ${0, 1, 2, 3, 4}$ is achieved: $f(0)=0, f(1)=1, f(2)=2, f(3)=3, f(4)=4$. #YES
]

#example[Computer science applications][
  - *Color quantization:* Map 24-bit colors to 8-bit palette (should cover all palette colors).
  - *Load balancing:* Distribute requests across servers (all servers should be used).
  - *Hash table design:* Hash function should potentially reach every bucket.
]

== Examples of Non-Surjective Functions

#example[Counter-examples (not surjective)][
  - $g: NN to NN$ defined by $g(n) = 2n$ is _not_ surjective.
    - Odd numbers like $3, 5, 7, ...$ are never achieved since $2n$ is always even. #NO

  - $h: RR to RR$ defined by $h(x) = x^2$ is _not_ surjective.
    - Negative numbers like $-1, -2, -3, ...$ are never achieved since $x^2 >= 0$. #NO

  - $f: RR to RR$ defined by $f(x) = e^x$ is _not_ surjective.
    - Negative numbers and zero are never achieved since $e^x > 0$ for all $x$. #NO
]

== Bijective Functions

#definition[
  A function $f: A to B$ is _bijective_ if it is both injective and surjective.
  A bijective function establishes a _one-to-one correspondence_ between the elements of $A$ and $B$.

  Equivelently, $f$ is bijective iff it has an inverse function $f^(-1): B to A$.
]

#example[
  $f: RR to RR$ defined by $f(x) = 2x + 1$ is bijective.
  - *Injective:* If $2x_1+1 = 2x_2+1$, then $x_1=x_2$. #YES
  - *Surjective:* For any $y in RR$, let $x = (y-1)/2$. Then $f(x) = y$. #YES
  - *Inverse:* $f^(-1)(y) = (y-1) / 2$.
]

#example[
  $g: [0, infinity) to [0, infinity)$ defined by $g(x) = x^2$ is bijective.
  - *Injective:* If $x_1^2 = x_2^2$ and $x_1, x_2 >= 0$, then $x_1 = x_2$. #YES
  - *Surjective:* For any $y >= 0$, let $x = sqrt(y)$. Then $g(x) = y$. #YES
  - *Inverse:* $g^(-1)(y) = sqrt(y)$.
]

== Examples of Bijective Functions

#Block(color: yellow)[
  *Key insight:* Bijective functions are "perfect matchings" between sets.
  Every element in $A$ pairs with _exactly one_ element in $B$, and vice versa.
]

#example[Computer science applications][
  - *Encryption algorithms:* Must be bijective to ensure decryption is possible.
  - *Base conversion:* Bijection between decimal and binary representations.
  - *Perfect hash functions:* Bijective mapping from keys to table positions.
  - *Coordinate transformations:* Reversible mappings between coordinate systems.
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
  - $(g compose f)(x) = g(f(x)) = g(x^2) = x^2 + 1$
  - $(f compose g)(x) = f(g(x)) = f(x+1) = (x+1)^2 = x^2 + 2x + 1$
]

#note[
  $g compose f != f compose g$ (composition is not commutative!)
]

#place(bottom + right)[
  #import fletcher: diagram, edge, node
  #diagram(
    spacing: (5em, 2em),
    node-shape: fletcher.shapes.circle,
    node-stroke: 1pt,
    edge-stroke: 1pt,
    // Set A
    blob((-1, 0.5), [$a_1$], tint: blue, name: <a1>),
    blob((-1, 1.5), [$a_2$], tint: blue, name: <a2>),
    blob((-1, 2.5), [$a_3$], tint: blue, name: <a3>),
    // Set B
    blob((0, 0.3), [$b_1$], tint: yellow, name: <b1>),
    blob((0, 1.5), [$b_2$], tint: yellow, name: <b2>),
    blob((0, 2.7), [$b_3$], tint: yellow, name: <b3>),
    // Set C
    blob((1, 1), [$c_1$], tint: green, name: <c1>),
    blob((1, 2), [$c_2$], tint: green, name: <c2>),
    // Function f: A -> B
    edge(<a1>, <b2>, "-}>", stroke: blue),
    edge(<a2>, <b1>, "-}>", stroke: blue),
    edge(<a3>, <b3>, "-}>", stroke: blue),
    // Function g: B -> C
    edge(<b1>, <c1>, "-}>", stroke: red),
    edge(<b2>, <c2>, "-}>", stroke: red),
    edge(<b3>, <c1>, "-}>", stroke: red),
    // Composition g ∘ f: A -> C (curly dashed edges)
    edge(<a1>, <c2>, "--}>", bend: 15deg, stroke: green.darken(20%)),
    edge(<a2>, <c1>, "--}>", bend: 10deg, stroke: green.darken(20%)),
    edge(<a3>, <c1>, "--}>", bend: -10deg, stroke: green.darken(20%)),
    // Legend
    // node((rel: (0cm, -2.5em), to: <b1.south>), align(left)[
    //   #set text(size: 0.8em)
    //   Edges legend:
    //   - #text(fill: blue)[Solid blue: Function $f: A to B$]
    //   - #text(fill: red)[Solid red: Function $g: B to C$]
    //   - #text(fill: green.darken(20%))[Dashed green: Composition $g compose f: A to C$]
    // ]),
  )
]

== Examples of Function Composition

#Block(color: yellow)[
  *Key insight:*
  Function composition is like a "pipeline" --- the output of $f$ becomes the input to $g$.

  Read right-to-left: $g compose f$ means "first apply $f$, then apply $g$", or rather, "do $g$ after $f$".
]

#example[Computer science applications][
  - *Function pipelines:* `data |> filter |> map |> reduce`
  - *Compiler design:* lexer $to$ parser $to$ optimizer $to$ code generator
  - *Data processing:* clean $to$ transform $to$ aggregate $to$ visualize
]

== Properties of Function Composition

- *Associativity:* If $f: A to B$, $g: B to C$, and $h: C to D$, then $(h compose g) compose f = h compose (g compose f)$.

- The _identity_ function acts as a _neutral_ element for composition:
  - $id_B compose f = f$ for any function $f: A to B$.
  - $f compose id_A = f$ for any function $f: A to B$.

- Composition _preserves_ the properties of functions:
  - If $f$ and $g$ are injective, so is $g compose f$.
  - If $f$ and $g$ are surjective, so is $g compose f$.
  - If $f$ and $g$ are bijective, so is $g compose f$.

- Note that in general, $g compose f != f compose g$, i.e., function composition is _not commutative_.

== Functional Powers

#definition[
  The _functional power_ of $f: A to A$ can defined inductively:
  $
        f^0 & = id_A \
    f^(n+1) & = f compose f^(n) = f^(n) compose f
  $

  #note[
    This definition also works for functions $f: X to Y$ with $Y subset.eq X$.
  ]

  #note[
    To avoid the confusion with exponential powers (e.g., $f^n (x)$ could be interpreted as $(f(x))^n$), we can use the notation $f^(circle.small n)$ to denote the $n$-th functional power.
  ]
]

#example[
  Let $f: RR to RR$ be $f(x) = 2x$.
  - $f^0(x) = x$ (identity)
  - $f^1(x) = 2x$
  - $f^2(x) = f(f(x)) = f(2x) = 2(2x) = 4x$
  - $f^3(x) = f(f^2 (x)) = f(4x) = 2(4x) = 8x$
  - In general: $f^n (x) = 2^n x$
]

== Examples of Functional Powers

#example[
  Let $g: ZZ to ZZ$ be $g(x) = x + 1$ (successor function).
  - $g^(circle.small 0) (x) = x$
  - $g^(circle.small 1) (x) = x + 1$
  - $g^(circle.small 2) (x) = g(g(x)) = g(x + 1) = (x + 1) + 1 = x + 2$
  - $g^(circle.small 3) (x) = g(g^(circle.small 2) (x)) = g(x + 2) = (x + 2) + 1 = x + 3$
  - In general: $g^(circle.small n) (x) = x + n$
]

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

#example[
  The exponential function $exp: RR to (0, infinity)$ defined by $exp(x) = e^x$ is bijective.
  - Its inverse is the natural logarithm: $ln: (0, infinity) to RR$.
  - We have: $ln(e^x) = x$ for all $x in RR$ and $e^(ln y) = y$ for all $y > 0$.

  #note[
    If we tried $exp: RR to RR$, it wouldn't be surjective (negative numbers never achieved), hence no inverse!
    The codomain restriction is essential.
  ]
]

#pagebreak()

#example[Polynomial with domain restriction][
  Consider $f: RR to RR$ defined by $f(x) = x^2$.
  - This is *not* injective: $f(-2) = f(2) = 4$, so no inverse exists.

  However, if we *restrict the domain* to $f: [0, infinity) to [0, infinity)$, then:
  - $f$ becomes bijective (both injective and surjective on non-negative reals).
  - The inverse is $f^(-1)(y) = sqrt(y)$ for $y >= 0$.

  #Block(color: yellow)[
    *Key insight:* Many functions need domain/codomain restrictions to become invertible.
    This is crucial in calculus when finding inverse functions!
  ]
]

#example[
  The sine function $sin: RR to RR$ is *not* injective (it's periodic), so it has no inverse.

  However, with domain restriction, $sin: [-pi/2, pi/2] to [-1, 1]$ *is* bijective, with inverse $arcsin: [-1, 1] to [-pi/2, pi/2]$.

  Similarly: $cos: [0, pi] to [-1, 1]$ has inverse $arccos$, and $tan: (-pi/2, pi/2) to RR$ has inverse $arctan$.
]

#theorem[
  If $f: A to B$ is a bijective function with inverse $f^(-1): B to A$:
  - $f^(-1)$ is also bijective.
  - $(f^(-1) compose f)(a) = a$ for all $a in A$ (i.e., $f^(-1) compose f = id_A$).
  - $(f compose f^(-1))(b) = b$ for all $b in B$ (i.e., $f compose f^(-1) = id_B$).
  - If $f: A to B$ and $g: B to C$ are both bijective, then $(g compose f)^(-1) = f^(-1) compose g^(-1)$.
]

== Monotonic Functions

#definition[
  A function $f: A to B$ is called _monotonic_ if it preserves order relationships.

  For real-valued functions $f: RR to RR$:
  - _Monotonic increasing_ (or _isotone_) if $x <= y imply f(x) <= f(y)$
  - _Strictly increasing_ if $x < y imply f(x) < f(y)$
  - _Monotonic decreasing_ (or _antitone_) if $x <= y imply f(x) >= f(y)$
  - _Strictly decreasing_ if $x < y imply f(x) > f(y)$

  #note[
    More generally, for any posets $pair(A, scripts(leq)_A)$ and $pair(B, scripts(leq)_B)$:
    - $f$ is _order-preserving_ (monotone) if $x scripts(leq)_A y imply f(x) scripts(leq)_B f(y)$
    - $f$ is _order-reversing_ (antitone) if $x scripts(leq)_A y imply f(x) scripts(geq)_B f(y)$
  ]
]

#pagebreak()

#theorem[Monotonicity implies injectivity][
  If $f: RR to RR$ is *strictly* increasing or *strictly* decreasing, then $f$ is *injective*.
]

#proof[
  Suppose $f$ is strictly increasing.
  Let $x_1, x_2 in RR$ with $x_1 != x_2$.
  Then either $x_1 < x_2$ or $x_2 < x_1$.
  - If $x_1 < x_2$, then $f(x_1) < f(x_2)$ by strict monotonicity, so $f(x_1) != f(x_2)$.
  - If $x_2 < x_1$, then $f(x_2) < f(x_1)$ by strict monotonicity, so $f(x_1) != f(x_2)$.

  In both cases, $f(x_1) != f(x_2)$, proving injectivity.
  The proof for strictly decreasing is analogous.
]

#Block(color: yellow)[
  *Key insights:*
  - Monotonic functions have predictable behavior: they never "change direction"
  - *Strictly* monotonic functions are always injective (one-to-one)
  - Non-strict monotonic functions may have "flat" regions where different inputs map to the same output
  - Connection to Order Theory: monotonic functions are _order-homomorphisms_ between posets
]

#example[
  Examples of *strictly monotonic functions* (which are always injective):
  - $f(x) = 2x + 1$ is strictly increasing on $RR$, hence injective. #YES
  - $g(x) = -x$ is strictly decreasing on $RR$, hence injective. #YES
  - $h(x) = x^3$ is strictly increasing on $RR$, hence injective. #YES
  - $k(x) = e^x$ is strictly increasing on $RR$, hence injective. #YES
]

#example[
  Examples of *monotonic but NOT strictly monotonic* functions (not necessarily injective):
  - $f(x) = floor(x)$ is monotonic increasing but NOT strictly increasing.
    - For $x in [2, 3)$, we have $f(x) = 2$ (constant on intervals).
    - This is NOT injective: $f(2.1) = f(2.9) = 2$ but $2.1 != 2.9$. #NO

  - $g(x) = cases(
      x & "if" x <= 0,
      0 & "if" 0 < x < 1,
      x - 1 &"if" x >= 1
    )$ ~ is monotonic but not injective.
]

== Function Properties Overview

Functions can be characterized by several key properties that determine their mathematical behavior.

#table(
  columns: 2,
  align: (left, left),
  stroke: (x, y) => if y == 0 { (bottom: 0.6pt) },
  table.header([*Property*], [*Definition*]),

  [*Well-defined*], [Each input maps to exactly one output],

  [*Total*], [Defined for all inputs in the domain],

  [*Partial*], [May be undefined for some inputs],

  [*Injective* (One-to-one)], [Different inputs → different outputs],

  [*Surjective* (Onto)], [Every codomain element is achieved],

  [*Bijective*], [Both injective and surjective, one-to-one correspondence],

  [*Monotonic*], [Preserves or reverses order relationships],

  [*Continuous*], [Small input changes → small output changes],
)

== Characteristic Functions

#definition[
  For any set $S subset.eq A$, the _characteristic function_ (or _indicator function_) $chi_S: A to {0, 1}$ is:
  $
    chi_S (x) = cases(
      1 & "if" x in S,
      0 & "if" x notin S
    )
  $
  This function "indicates" membership in set $S$.
]

#example[
  Let $A = {1, 2, 3, 4, 5}$ and $S = {2, 4}$.
  Then $chi_S$ maps:
  - $chi_S (1) = 0$ (since $1 notin S$)
  - $chi_S (2) = 1$ (since $2 in S$)
  - $chi_S (3) = 0$ (since $3 notin S$)
  - $chi_S (4) = 1$ (since $4 in S$)
  - $chi_S (5) = 0$ (since $5 notin S$)

  So $chi_S = {(1,0), (2,1), (3,0), (4,1), (5,0)}$.
]

#place(right + bottom)[
  #cetz.canvas({
    import cetz.draw: *

    // Draw axis
    line((-0.5, 0), (6, 0), stroke: 1pt, fill: black, mark: (end: "stealth"))
    line((0, -0.5), (0, 1.5), stroke: 1pt, fill: black, mark: (end: "stealth"))

    // Draw characteristic function as step function
    let points = ((1, 0), (2, 1), (3, 0), (4, 1), (5, 0))

    for (x, y) in points {
      // Vertical line at each point
      if y == 1 {
        line((x, 0), (x, 1), stroke: 2pt + blue)
        circle((x, 1), radius: 0.1, fill: blue, stroke: blue)
        circle((x, 0), radius: 0.08, fill: white, stroke: blue)
      } else {
        circle((x, 0), radius: 0.1, fill: red, stroke: red)
      }

      // Label x-axis
      content((x, 0), text(size: 0.9em)[#x], anchor: "north", padding: 0.2)
    }

    // Ticks
    line((-0.1, 1), (0.1, 1), stroke: 0.8pt)

    // Labels
    content((6, 0), [$x$], anchor: "north", padding: 0.2)
    content((0, 1.5), [$chi_S (x)$], anchor: "east", padding: 0.2)
    content((0, 0), [$0$], anchor: "north-east", padding: 0.2)
    content((0, 1), [$1$], anchor: "east", padding: 0.2)

    // Highlight the set S
    content(
      (3, 1.1),
      text(fill: blue, weight: "bold")[Elements in $S = {2, 4}$ map to $1$],
      anchor: "south",
      padding: 0.2,
    )
    content(
      (3, -0.5),
      text(fill: red, weight: "bold")[Elements not in $S$ map to $0$],
      anchor: "north",
      padding: 0.2,
    )
  })
]

== Properties of Characteristic Functions

#definition[
  For sets $A, B subset.eq U$:
  - $chi_(A intersect B) = chi_A dot chi_B$ (pointwise multiplication)
  - $chi_(A union B) = chi_A + chi_B - chi_A dot chi_B$
  - $chi_(overline(A)) = 1 - chi_A$ (complement)
  - $chi_(A triangle B) = chi_A + chi_B - 2 chi_A dot chi_B$ (symmetric difference)
  - $chi_emptyset = 0$ and $chi_U = 1$ (constant functions)
]

#example[Applications][
  - *Probability theory:* Indicator random variables
  - *Database queries:* Boolean conditions in WHERE clauses
  - *Set operations:* Converting logical operations to arithmetic
  - *Machine learning:* Feature encoding (one-hot encoding)
  - *Computer graphics:* Masking and selection operations
  - *Digital signal processing:* Window functions and filters
]

== Floor and Ceiling Functions

#definition[
  - _Floor function_ $floor: RR to ZZ$ maps $x$ to the largest integer $<= x$:
    $floor(x) = max{n in ZZ | n <= x}$

  - _Ceiling function_ $ceil: RR to ZZ$ maps $x$ to the smallest integer $>= x$:
    $ceil(x) = min{n in ZZ | n >= x}$
]

#place(right, dx: -1cm)[
  #cetz.canvas({
    import cetz.draw: *

    scale(70%)

    // Draw coordinate system
    line((-3, 0), (3, 0), stroke: 0.5pt, mark: (end: "stealth", fill: black))
    line((0, -2), (0, 4), stroke: 0.5pt, mark: (end: "stealth", fill: black))

    // Draw floor function (step function going down-left)
    for i in range(-2, 3) {
      line((i, i), (i + 1, i), stroke: 2pt + blue)
      circle((i, i), radius: 0.1, fill: blue, stroke: blue.darken(20%))
      circle((i + 1, i), radius: 0.1, fill: white, stroke: blue)
    }

    // Draw ceiling function (step function going up-right)
    for i in range(-2, 3) {
      line((i, i + 1), (i + 1, i + 1), stroke: 2pt + red)
      circle((i, i + 1), radius: 0.1, fill: white, stroke: red)
      circle((i + 1, i + 1), radius: 0.1, fill: red, stroke: red.darken(20%))
    }

    content((2.5, 1.5), text(fill: blue, weight: "bold")[$floor(x)$], anchor: "west")
    content((2.5, 3.5), text(fill: red, weight: "bold")[$ceil(x)$], anchor: "west")

    // Add axis labels
    content((3, -0.3), [$x$], anchor: "west")
    content((-0.3, 4), [$y$], anchor: "south")
  })
]

#example[
  #table(
    columns: 4,
    align: (center, center, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.6pt) },
    table.header([$x$], [$floor(x)$], [$ceil(x)$], [Note]),

    [$3.7$], [$3$], [$4$], [Positive non-integer],
    [$-2.3$], [$-3$], [$-2$], [Negative non-integer],
    [$5$], [$5$], [$5$], [Integer (floor = ceiling)],
    [$0$], [$0$], [$0$], [Zero],
    [$-1$], [$-1$], [$-1$], [Negative integer],
  )
]

== Summary: Functions

#Block(color: blue)[
  *Functions* establish relationships between sets where every input has exactly one output:
  - _Injective:_ Different inputs $to$ Different outputs (one-to-one)
  - _Surjective:_ Every output is achieved (onto)
  - _Bijective:_ Both injective and surjective (perfect correspondence)
]

#Block(color: green)[
  *Key applications in computer science:*
  - *Database design:* Functions model relationships
  - *Algorithm analysis:* Function properties affect complexity
  - *Cryptography:* Bijective functions enable encryption/decryption
  - *Type systems:* Function signatures and type hierarchies
  - *Data structures:* Mappings, hashing, and uniqueness constraints
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
  - For _finite_ sets, cardinality $abs(X)$ is the same as _size_, i.e., the number of elements in $X$.
  - For _infinite_ sets, cardinality $abs(X)$ describes the "type" of infinity, distinguishing between _countable_ (like $NN$) and _uncountable_ (like $RR$) infinities.
]

#example[Finite sets][
  - $abs({a, b, c}) = 3$ (three distinct elements)
  - $abs(emptyset) = 0$ (empty set has no elements)
  - $abs(power({1,2})) = abs({emptyset, {1}, {2}, {1,2}}) = 4 = 2^2$
]

#example[Infinite sets][
  - $abs(NN) = aleph_0$ ("aleph-null" --- smallest infinite cardinal, denoting _countable_ infinity)
  - $abs(ZZ) = aleph_0$ (same size as natural numbers!)
  - $abs(QQ) = aleph_0$ (rationals are also _countably_ infinite)
  - $abs(RR) = 2^(aleph_0) = frak(c)$ ("continuum" --- _uncountably_ infinite)
  - $abs(power(NN)) = 2^(aleph_0) > aleph_0$ (power set is always "larger")
]

== Cardinal Numbers

#note[
  $abs(X)$ is _not_ just a number, but a _cardinal number_.
  - Cardinal numbers extend natural numbers to describe sizes of infinite sets.
  - The _finite_ cardinal numbers are just natural numbers: $0, 1, 2, 3, dots$.
  - The first (smallest) _infinite_ cardinal is $aleph_0$ (the cardinality of $NN$).
  - _Arithmetic_ operations on cardinal numbers _differ_ from those on natural numbers.
    - For example, $aleph_0 + 1 = aleph_0$ and $aleph_0 dot 2 = aleph_0$.
]
// TODO: extend cardinal numbers

== Equinumerosity

#definition[
  Two sets $A$ and $B$ have the same _cardinality_ and are called _equinumerous_, denoted $abs(A) = abs(B)$ or $A equinumerous B$, iff there exists a _bijection_ (one-to-one correspondence) from $A$ to $B$.

  #note(title: "Intuition")[
    If you can pair up every element of $A$ with exactly one element of $B$, with nothing left over on either side, then $A$ and $B$ have the same cardinality.
  ]
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
  A set is _countable_ if it is either:
  + _Finite_, or
  + Has the same cardinality as $NN$ (i.e., there exists a bijection with $NN$)

  When an infinite set is countable, its cardinality is $aleph_0$ (_"aleph-null"_).

  #note(title: "Intuition")[
    A countable set is one whose elements can be "listed" or "enumerated" in a sequence.
  ]
]

#example[Basic countable sets][
  - $NN_"odd" = {1, 3, 5, 7, ...}$ with bijection $f: NN to NN_"odd"$ defined by $f(n) = 2n + 1$

  - $NN_"even" = {0, 2, 4, 6, ...}$ with bijection $f: NN to NN_"even"$ defined by $f(n) = 2n$

  - Prime numbers ${2, 3, 5, 7, 11, 13, ...}$ are countable (can be enumerated)
]

== Examples of Countable Sets

#Block(color: yellow)[
  *Key insight:* Two sets have the same cardinality if we can pair up their elements perfectly --- establishing a one-to-one correspondence (bijection) between them.
]

#example[
  The set of _integers_ $ZZ = {..., -2, -1, 0, 1, 2, ...}$ is _countable_: $abs(ZZ) = aleph_0$

  *Bijection* $f: NN to ZZ$ is defined by:
  #align(center)[
    $
      f(n) = cases(
        n / 2 & "if" n "is even",
        -(n+1) / 2 & "if" n "is odd"
      )
      wide
      natrix.bnat(
        row-gap: #0.5em,
        NN":", 0, 1, 2, 3, 4, 5, 6, 7, dots;
        ZZ":", 0, -1, 1, -2, 2, -3, 3, -4, dots
      )
    $
  ]

  This systematically pairs each natural number with exactly one integer, covering all integers exactly once.
]

// #example[
//   $abs(QQ) = aleph_0$, the set of rational numbers is countable.
// ]

== Properties of Countable Sets

#theorem[Properties of countable sets][
  + Any subset of a countable set is countable
  + The union of countably many countable sets is countable
  + The Cartesian product of two countable sets is countable ($NN times NN$ is countable)
  + The set of finite sequences over a countable alphabet is countable
]

#example[More countable sets][
  - *Rational numbers* $QQ$: Can be enumerated by listing fractions $p/q$ systematically

  - *Finite binary strings* ${0, 1, 00, 01, 10, 11, 000, ...}$: Countably infinite

  - *Polynomials with integer coefficients*: Can be systematically enumerated

  - *Finite subsets of $NN$*: Each finite subset can be encoded as a finite binary string
]

== Enumerable Sets

#definition[
  A set $X$ is _enumerable_ if there is a surjection $e: NN to X$ (equivalently a bijection with either $NN$ or an initial segment of $NN$ if $X$ finite).
]

#theorem[Zig-Zag Enumeration][
  $NN^2$ is countable.
]

#proof[
  List pairs by diagonals of constant sum: $pair(0, 0); pair(0, 1),pair(1, 0); pair(0, 2),pair(1, 1),pair(2, 0); dots$ which gives a bijection with $NN$.
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

// TODO: other pairing functions
// TODO: perfect hash functions

== Uncountable Sets

#definition[
  A set is _uncountable_ if it is infinite but not countable.

  In other words, there is _no_ bijection between the set and $NN$.
]

== Proving Uncountability

#Block(color: orange)[
  *Strategy for proving uncountability:* _Cantor's diagonal argument_.

  Given a list of elements, say $x_1, x_2, dots$ (enumerated by natural numbers), we construct a _new_ element that _differs_ from each $x_i$, showing that the list is incomplete.
]

#theorem[
  The set $BB^omega$ of all infinite binary sequences is _uncountable_.
]

#proof[
  $BB^omega$ contains sequences like $000000...$, $010101...$, $111000...$, etc.

  Suppose for contradiction that $BB^omega$ is countable.
  Then we can _enumerate_ its elements as $x_1, x_2, dots$, where each $x_i$ is an infinite sequence of bits, so we can represent it as $x_i = (b_(i 1), b_(i 2), b_(i 3), dots)$, where $b_(i j) in BB$ is the $j$-th bit of the $i$-th sequence.
  So we have a listing like:
  - $x_1 = (b_(1 1), b_(1 2), b_(1 3), b_(1 4), ...)$
  - $x_2 = (b_(2 1), b_(2 2), b_(2 3), b_(2 4), ...)$
  - $dots$

  Now we construct a new sequence $Delta = (overline(b)_(1 1), overline(b)_(2 2), overline(b)_(3 3), dots)$, where $overline(b)_(i i) = 1 - b_(i i)$, i.e., we flip the $i$-th bit of the $i$-th sequence.
  This sequence _differs_ from each $x_i$ at least in the $i$-th position, so it cannot be equal to any $x_i$, so it is _not in_ the enumeration $x_1, x_2, dots$.
  We place it "at the end" of our table for clarify:

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

  Since $Delta$ is constructed from the "bits", it is also an _element_ of $BB^omega$.

  Thus, we have found an element of $BB^omega$ that is _not_ in the enumeration $x_1, x_2, dots$, contradicting the assumption that $BB^omega$ is countable.
  // *Diagonal construction:* Create sequence $Delta = (d_1, d_2, d_3, d_4, ...)$ where:
  // $d_i = cases(0 & "if" b_(i,i) = 1, 1 & "if" b_(i,i) = 0)$ (flip the diagonal)
  //
  // *Key insight:* $Delta$ differs from $x_i$ in position $i$ for every $i$, so $Delta$ cannot equal any $x_i$.
  // Therefore, $Delta in BB^omega$ but $Delta$ is not in our "complete" listing --- contradiction!
]

== Examples of Uncountable Sets

#example[Important uncountable sets][
  - *Real numbers* $RR$: Can be put in bijection with $BB^omega$ via binary expansions
  - *Power set* $power(NN)$: By Cantor's theorem, always larger than the original set
  - *Irrational numbers* $II = RR setminus QQ$: Since $QQ$ is countable but $RR$ is not
  - *Transcendental numbers*: Numbers like $pi, e$ that are not algebraic
  - *Function spaces* $RR^RR$: All functions from reals to reals
  - *Infinite binary strings* $BB^omega$: As proved above
]

#example[Computer science connections][
  - *Undecidable problems*: There are uncountably many languages, but only countably many algorithms
  - *Real computation*: Continuous functions vs discrete algorithms
  - *Cryptographic keys*: Key spaces can be countable or uncountable depending on the system
  - *Information theory*: Continuous vs discrete information sources
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
  $A smaller power(A)$ for any set $A$.

  // In other words, $abs(A) < abs(power(A))$ --- the power set is always strictly larger.
]

#proof[
  The map $f(x) = {x}$ is an injection from $A$ to $power(A)$, since if $x != y$, then ${x} != {y}$, and so $f(x) != f(y)$.
  So~we have shown that $A smaller.eq power(A)$.

  To show that $A equinumerous.not power(A)$, suppose for reductio that there is a bijection $g: A to power(A)$.
  - Consider $D = {x in A | x notin g(x)}$.
    Note that $D subset.eq A$, so $D in power(A)$.
  - Since $g$ is surjective, there exists $y in A$ such that $g(y) = D$.
    - If $y in D$, then by definition of $D$, we have $y notin g(y)$, i.e., $y notin D$. Contradiction!
    - If $y notin D$, then $y notin g(y)$, so by definition of $D$, we have $y in D$. Contradiction!
  - Therefore, no bijection $A to power(A)$ can exist, so $A equinumerous.not power(A)$. #qedhere
]

#Block(color: purple)[
  *Profound implication:* There is no "largest" infinity!
  We can always construct a bigger one using the power set operation: $aleph_0 < 2^(aleph_0) < 2^(2^(aleph_0)) < ...$
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
      let w = 1
      let gap = 1
      line((0, 0), (w, 0), mark: (symbol: "|"))
      content((w / 2, w / 2))[$L$]
      translate((w, 0))
      content((gap / 2, w / 2))[$equinumerous$]
      translate((gap, 0))
      rect((0, 0), (w, w), fill: luma(80%))
      content((w / 2, w / 2))[$S$]
    })
  ]
]

#proof[#footnote[
  See https://math.stackexchange.com/a/183383 for more detailed analysis.
]][
  Consider the function $f: L to S$ defined by $f(x) = pair(x, x)$.
  This is an injection, since if #box[$f(a) = f(b)$], then $pair(a, a) = pair(b, b)$, so $a = b$.
  Thus, $L smaller.eq S$.

  Now consider the function $g: S to L$ that maps $pair(x, y)$ to the real number obtained by _interleaving_ the decimal expansions of $x$ and $y$.
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
  This is an injection, since if $g(a, b) = g(c, d)$, then $a_n = c_n$ and $b_n = d_n$ for all $n in NN$, so $pair(a, b) = pair(c, d)$.
  Thus, $S smaller.eq L$.

  By Schröder--Bernstein (@shroder-bernstein), we have that $L equinumerous S$.
]

== Summary: Cardinality

#Block(color: blue)[
  *Cardinality* measures set "size," revealing surprising facts about infinity:
  - _Finite sets:_ Count elements normally
  - _Countable_ infinity ($aleph_0$): Sets like $NN$, $ZZ$, $QQ$ that can be "listed" (enumerated)
  - _Uncountable_ infinity: Sets like $RR$, $power(NN)$ that are "too big" to list (enumerate with $NN$)
  - *Cantor's insight:* $abs(A) < abs(power(A))$ always --- there's no "largest" infinity!
]


= Closures of Relations
#focus-slide()

== Closures of Relations

#definition[
  The _closure_ of a relation $R subset.eq M^2$ with respect to a property $P$ is the smallest relation containing $R$ that satisfies property $P$.
  - _Reflexive closure_: $r(R) = R union I_M$ (smallest reflexive relation containing $R$)
  - _Symmetric closure_: $s(R) = R union R^(-1)$ (smallest symmetric relation containing $R$)
  - _Transitive closure_: $t(R)$ is the smallest transitive relation containing $R$
]

#Block(color: yellow)[
  *Key insight:* closure operations _add the minimum_ number of pairs needed to achieve the desired property, while preserving all existing pairs in the original relation.
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

  *Method 1:* Apply reflexive closure first, then symmetric:
  $
    r(R) = & R union I_M \
         = & {pair(1, 1), pair(1, 2), pair(2, 2), pair(2, 3), pair(3, 3)} \
           & slash.double s r(R) = r(R) union r(R)^(-1) \
         = & {pair(1, 1), pair(1, 2), pair(2, 2), pair(2, 3), pair(3, 3), pair(2, 1), pair(3, 2)}
  $

  *Method 2:* Apply symmetric closure first, then reflexive:
  $
    s(R) = & R union R^(-1) \
         = & {pair(1, 2), pair(2, 3), pair(2, 1), pair(3, 2)} \
           & slash.double r s(R) = s(R) union I_M \
         = & {pair(1, 1), pair(1, 2), pair(2, 1), pair(2, 2), pair(2, 3), pair(3, 2), pair(3, 3)}
  $

  Both methods yield the same result, confirming _commutativity_.
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

#example[
  Let $M = {1, 2, 3, 4}$ and $R = {pair(1, 2), pair(3, 4)}$.

  *Step 1:* Make it reflexive:
  $
    r(R) = R union I_M
    = {pair(1, 1), pair(1, 2), pair(2, 2), pair(3, 3), pair(3, 4), pair(4, 4)}
  $

  *Step 2:* Make it symmetric:
  $
    s r(R) = & r(R) union r(R)^(-1) \
           = & {pair(1, 1), pair(1, 2), pair(2, 1), pair(2, 2), pair(3, 3), pair(3, 4), pair(4, 3), pair(4, 4)}
  $

  *Step 3:* Make it transitive:
  - Since $pair(1, 2), pair(2, 1) in s r(R)$, transitivity requires $pair(1, 1)$ (already present).
  - Since $pair(3, 4), pair(4, 3) in s r(R)$, transitivity requires $pair(3, 3)$ (already present).

  $ t s r(R) = s r(R) quad "(no new pairs needed)" $

  The equivalence closure partitions $M$ into equivalence classes ${1, 2}$ and ${3, 4}$.
]

#pagebreak()

#example[
  Let $M = {a, b, c, d, e}$ and $R = {pair(a, b), pair(b, c), pair(d, e)}$.

  *Reflexive closure:*
  $ r(R) = R union {pair(a, a), pair(b, b), pair(c, c), pair(d, d), pair(e, e)} $

  *Symmetric closure:*
  $ s r(R) = r(R) union {pair(b, a), pair(c, b), pair(e, d)} $

  *Transitive closure:*
  We need to add pairs to ensure transitivity:
  - From $pair(a, b), pair(b, c)$: add $pair(a, c)$
  - From $pair(c, b), pair(b, a)$: add $pair(c, a)$

  $ t s r(R) = s r(R) union {pair(a, c), pair(c, a)} $

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

  #block(sticky: true)[
    *Iteration $k = 1$:* Consider paths through vertex 1.
  ]
  $
    M^((1)) = natrix.bnat(
      0, 1, 0, 0;
      0, 0, 1, 0;
      0, 0, 0, 1;
      1, 1, 0, 0
    )
  $
  (Added $pair(4, 2)$: path $4 to 1 to 2$)

  #block(sticky: true)[
    *Iteration $k = 2$:* Consider paths through vertex 2.
  ]
  $
    M^((2)) = natrix.bnat(
      0, 1, 1, 0;
      0, 0, 1, 0;
      0, 0, 0, 1;
      1, 1, 1, 0
    )
  $
  (Added $pair(1, 3)$ and $pair(4, 3)$)

  #block(sticky: true)[
    *Iteration $k = 3$:* Consider paths through vertex 3.]
  $
    M^((3)) = natrix.bnat(
      0, 1, 1, 1;
      0, 0, 1, 1;
      0, 0, 0, 1;
      1, 1, 1, 1
    )
  $
  (Added $pair(1, 4)$, $pair(2, 4)$, and $pair(4, 4)$)

  #block(sticky: true)[
    *Iteration $k = 4$:* Consider paths through vertex 4.
  ]
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

#example[Reachability in graphs][

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

== Properties of Closures

#theorem[
  For any relation $R subset.eq M^2$:
  + _Idempotency_: $r(r(R)) = r(R)$, $s(s(R)) = s(R)$, $t(t(R)) = t(R)$
  + _Monotonicity_: If $R_1 subset.eq R_2$, then $r(R_1) subset.eq r(R_2)$, etc.
  + _Extensivity_: $R subset.eq r(R)$, $R subset.eq s(R)$, $R subset.eq t(R)$
  + _Distributivity over union_: $r(R_1 union R_2) = r(R_1) union r(R_2)$, etc.
]

== Examples of Closures

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
    "equiv"(R) = & r s t(R) \
               = & {pair(1, 1), pair(1, 3), pair(2, 2), pair(2, 4), pair(2, 5), pair(3, 1), \
                 & quad pair(3, 3), pair(4, 2), pair(4, 4), pair(4, 5), pair(5, 2), pair(5, 4), pair(5, 5)}
  $

  The equivalence classes are:
  - $eqclass(1, R) = {1, 3}$
  - $eqclass(2, R) = {2, 4, 5}$

  This partitions $M$ into ${{1, 3}, {2, 4, 5}}$.
]

#pagebreak()

#example[
  Consider a directed acyclic graph (DAG) where $R$ represents _"depends on"_ relationships:
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

== Applications of Relation Closures

#example[*Graph Reachability*][
  In directed graphs, transitive closure determines reachability:
  - *Social networks:* Finding mutual connections and influence propagation
  - *Transportation:* Computing all possible routes between cities
  - *Citation networks:* Tracking intellectual dependencies in research
  - *Web crawling:* Discovering linked pages and site connectivity
]

#example[*Program Analysis*][
  Closure operations enable sophisticated program optimization:
  - *Data flow analysis:* Transitive closure computes variable dependencies
  - *Call graph construction:* Finding all possible function invocations
  - *Alias analysis:* Determining which pointers may reference the same memory
  - *Taint analysis:* Tracking information flow and potential vulnerabilities
]

#example[*Database Systems*][
  Relational databases extensively use closure computations:
  - *Recursive queries:* Computing organizational hierarchies and bill-of-materials
  - *Join optimization:* Finding efficient query execution plans
  - *Integrity constraints:* Ensuring referential consistency across tables
  - *Data lineage:* Tracking data provenance and transformation chains
]

== Complexity of Closure Computations

#theorem[
  For a relation $R$ on $n$ elements, the time complexities are:
  - *Reflexive closure:* $O(n)$ time
  - *Symmetric closure:* $O(|R|)$ time
  - *Transitive closure:* $O(n^3)$ time (Floyd-Warshall algorithm)
]

#note[
  The transitive closure bottleneck drives many algorithmic design decisions in practice.
]

// TODO: mention FO+TC = NL, FO+LFP = P, etc.


= Lattices
#focus-slide(
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
  - *No* greatest lower bound or least upper bound _in_ $C$ (since $(0;1)$ is open)
]

== Examples of Bounds

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
  - For infinite subsets: $sup((0;1)) = 1$ and $inf((0;1)) = 0$ (even though $0, 1 notin (0;1)$)
]

== Examples of Suprema and Infima

#example[
  $pair(power(A), subset.eq)$:
  - *Join:* $sup(cal(C)) = union.big_(X in cal(C)) X$ (union of all sets)
  - *Meet:* $inf(cal(C)) = inter.big_(X in cal(C)) X$ (intersection of all sets)
  - $sup {{1,2}, {2,3}, {3,4}} = {1,2,3,4}$
  - $inf {{1,2,3}, {2,3,4}, {3,4,5}} = {3}$
]

#example[
  Divisibility on $NN^+$:
  - *Join:* $sup{a, b} = "lcm"(a, b)$ (least common multiple)
  - *Meet:* $inf{a, b} = "gcd"(a, b)$ (greatest common divisor)
  - $sup {6, 10} = 30$
  - $inf {6, 10} = 2$
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

// == Examples of Lattices
//
// #example[Type Systems and Subtyping][
//   Types form a lattice under the subtyping relation $subset.eq$:
//   - $sup{#`int`, #`string`} = #`Object`$ or $#`any`$ (most general common supertype)
//   - $inf{#`Number`, #`int`} = #`int`$ (most specific common subtype)
//   - $sup{#`List<int>`, #`List<string>`} = #`List<Object>`$ (covariant generics)
//   - $sup{#`number`, #`string`} = #`number | string`$ (union types)
// ]
//
// #example[Access Control and Security Lattices][
//   Permissions form a lattice under the "includes" relation:
//   - $sup{"read", "write"} = "read-write"$ (union of capabilities)
//   - $inf{"admin", "read-write"} = "read-write"$ (intersection of permissions)
//   - $sup{"secret", "top-secret"} = "top-secret"$ (higher classification level)
//   - Bell-LaPadula model: $inf{"confidential", "public"} = "public"$ (lower bound for security)
// ]
//
// #example[Program Analysis and Abstract Interpretation][
//   Abstract values form lattices for static analysis:
//   - Value ranges: $sup{[1;5], [3;8]} = [1;8]$ (conservative approximation via union)
//   - Interval analysis: $inf{[−infinity;10], [5;infinity]} = [5;10]$ (intersection of constraints)
//   - Points-to analysis: $sup{{"x" maps "a"}, {"x" maps "b"}} = {"x" maps {"a","b"}}$ (may-alias)
// ]

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

== Why Lattices Matter: Information Security Levels

#place(top + right)[
  #import fletcher: diagram, edge, node
  #diagram(
    spacing: 16pt,
    edge-stroke: 1pt + navy,
    node-shape: fletcher.shapes.rect,
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

== Why Lattices Matter: Type Systems

#place(top + right)[
  #import fletcher: diagram, edge, node
  #diagram(
    spacing: (2em, 1.5em),
    edge-stroke: 1pt + blue,
    node-shape: fletcher.shapes.rect,
    node-corner-radius: 3pt,
    node-fill: blue.lighten(90%),
    node-stroke: 0.8pt + blue,

    // Top level
    node((1, 0), [`any`], name: <any>),

    // Second level
    node((0, 1), [`number`], name: <number>),
    node((2, 1), [`string`], name: <string>),

    // Third level
    node((-0.5, 2), [`int`], name: <int>),
    node((0.5, 2), [`float`], name: <float>),

    // Bottom level
    node((0, 3), [`never`], name: <never>),

    // Edges (subtype relations)
    edge(<int>, <number>, "-}>"),
    edge(<float>, <number>, "-}>"),
    edge(<number>, <any>, "-}>"),
    edge(<string>, <any>, "-}>"),
    edge(<never>, <int>, "-}>"),
    edge(<never>, <float>, "-}>"),
  )

  #block[
    #set align(left)
    #set text(size: 0.9em)
    *Type Lattice*
    - Arrows show subtype relation $subtype$
    - Join: Move up to common parent
    - Meet: Move down to common child
  ]
]

In programming language theory, _types_ form lattices.

```typescript
let x: int = 42;
let y: string = "hello";
let z = condition ? x : y;
// z has type: int ∨ string = any
```

*Subtyping Lattice:*
- Order: $#`int` subtype #`number` subtype #`any`$, ~$#`string` subtype #`any`$
- Join ($Join$): Most general common supertype (union type)
  - For example: $#`int` Join #`string` = #`any`$
- Meet ($Meet$): Most specific common subtype (intersection type)
  - Let $A = #`{ name: string }`$
  - Let $B = #`{ age: int }`$
  - Then $A Meet B = #`{ name: string, age: int }`$

== Why Lattices Matter: Program Analysis

TODO

*Control Flow Analysis:*
- Elements: Sets of possible program states
- Order: Subset inclusion ($subset.eq$)
- Join: Union of possible states (at merge points)
- Meet: Intersection of guaranteed properties

== Why Lattices Matter: Database Query Optimization

#example[
  _Query execution plans_ form a lattice:

  - Elements: Different ways to execute a query
  - Order: "Plan A $leq$ Plan B" if A is more efficient than B
  - Join: Combine optimization strategies
  - Meet: Find common optimizations

  This structure helps database optimizers systematically explore the space of possible query plans.
]

== Why Lattices Matter: Concept Hierarchies and Ontologies

#example[
  Knowledge representation uses _concept lattices_.

  For example, consider a biological taxonomy:
  #block[
    #import fletcher: diagram, edge, node
    #diagram(
      spacing: (1em, 2em),
      node-shape: fletcher.shapes.rect,
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

== Why Lattices Matter: Distributed Systems and Causality

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

== Why Lattices Matter: Logic and Boolean Reasoning

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


= Well Orders
#focus-slide()

== Well-Ordered Sets

#definition[
  A poset $pair(M, leq)$ is _well-ordered_ if every non-empty subset $S subset.eq M$ has a _least element_.

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

== Well-Ordered Induction

TODO

== Well-Founded Relations

#definition[
  A relation $R subset.eq M^2$ is _well-founded_ if every non-empty subset $S subset.eq M$ has at least one _minimal element_ with respect to $R$.

  Formally: $forall S subset.eq M. thin (S != emptyset) imply (exists m in S. thin forall x in S. thin x nrel(R) m)$
]

// TODO: add example with (NN, leq)

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
// #example[Comparing $pair(NN, leq)$ vs $pair(NN, >=)$][
//   Same set, different relations show how direction affects properties:

//   *$pair(NN, leq)$ --- standard "less than or equal":*
//   - *Well-ordered:* #YES Every subset has a least (smallest) element.
//   - *Well-founded:* #YES Every subset has minimal elements (same as least here).
//   - For example: ${3, 7, 12}$ has least element $3$, minimal element is also $3$.

//   *$pair(NN, >=)$ --- "greater than or equal":*
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
  The _divisibility_ relation $pair(NN^+, |)$ is well-founded:
  - Every non-empty subset has minimal elements (numbers that divide no others in the subset)
  - For example, in ${6, 12, 18, 4, 8}$:
    - $4$ is minimal because no other number in the set divides $4$
    - $6$ is minimal because no other number in the set divides $6$
    - Note: $6$ divides both $12$ and $18$, but that doesn't affect minimality
  - In ${2, 4, 8, 16}$: only $2$ is minimal (it divides all others, but nothing else divides it)
]

#pagebreak()

#example[
  Consider the relation _"properly contains"_ ($supset$) on finite sets.

  Let $S = {{1}, {2}, {1,2}, {1,2,3}}$.

  *Well-founded:* #YES Every subset has minimal elements.
  - The subset ${{1}, {2}, {1,2,3}}$ has minimal elements ${1}$ and ${2}$
    - Neither ${1} supset {2}$ nor ${2} supset {1}$ (they're incomparable)
    - ${1,2,3} supset {1}$ and ${1,2,3} supset {2}$, but they remain minimal in this subset
  - Any collection always has sets that contain no others in that collection
]

#pagebreak()

#example[
  _Program termination analysis_ uses well-founded relations:
  - Define a measure that decreases with each recursive call
  - If the measure forms a well-founded order, the program terminates
  - Example: factorial function decreases argument from $n$ to $n-1$
]
// TODO: add Dafny example

== Well-Founded Induction

TODO

== Induced Strict Order

#definition[
  Given a partial order $leq$, the _induced strict order_ $lt$ is defined as:
  $
    x lt y "iff" (x leq y "and" x != y)
  $
]

#note[
  Given a poset $pair(S, leq)$, we can use $lt$ to denote its associated strict order.
]

#note[
  $gt$ is the converse of $lt$, so we can write $b > a$ instead of $a < b$.
]

#note[
  _Hereinafter_, we will freely use $lt$ and $gt$ when given any poset $pair(S, leq)$.
]

== Descending Chain Condition

#definition[
  A poset $pair(S, leq)$ is said to satisfy the _descending chain condition (DCC)_ if no strict descending sequence $x_1 > x_2 > x_3 > dots$ of elements of $S$ exists.

  Equivalently, every weakly descending sequence $x_1 >= x_2 >= x_3 >= dots$ eventually stabilizes.

  Formally: $forall (x_i)_(i in NN) in S^NN. thin (forall i in NN. thin x_i >= x_(i+1)) imply (exists N in NN. thin forall n >= N. thin x_n = x_(n+1))$
]

#note[
  The term "_sequence_" does not mean we must list all elements consequently or uniquely.
  It simply means we have a function from $NN$ to $S$.
  Elements can repeat, and we can skip elements in $S$.
  However, when we say "_descending sequence_," we mean that each new element is less than the previous one.
]

#example[
  The natural numbers $pair(NN, leq)$ satisfy DCC:
  - Since natural numbers are bounded below by $0$, infinite descent is impossible.
  - Any (weakly) descending sequence $n_1 >= n_2 >= n_3 >= dots$ must stabilize.
  - Eventually, some $n_k = n_(k+1) = n_(k+2) = dots$
]

== Well-Founded Posets

#definition[
  A poset $pair(S, leq)$ is _well-founded_ if its associated strict order $lt$ is a well-founded relation.

  In other words, every non-empty subset of $S$ has $lt$-minimal elements.
]

// #note[
//   A relation $R$ is called _Artinian_ if it is well-founded (equivalently, satisfies DCC when $R$ is a partial order).
//   This is the "dual" concept to Noetherian relations.
// ]

== DCC and Well-Foundedness

#theorem[
  For any poset $pair(S, leq)$, the following are _equivalent_:
  + $pair(S, leq)$ is _well-founded_ (every non-empty subset has $lt$-minimal elements)
  + $pair(S, leq)$ satisfies _DCC_ (no infinite descending chains)
]

#note[
  Here, we again use "$lt$" (and its converse "$gt$") to denote the strict order induced by "$leq$".
]

#proof[($==>$)][
  *Well-founded implies DCC*

  Suppose $pair(S, leq)$ is well-founded but there exists an infinite strict descending sequence $x_0 > x_1 > x_2 > dots$.
  Consider the set $T = {x_0, x_1, x_2, dots}$.
  Since $pair(S, leq)$ is well-founded, $T$ must have a minimal element $x_k$ for some $k$.
  But then $x_k > x_(k+1)$, contradicting the minimality of $x_k$.
]

#proof[($<==$)][
  *DCC implies well-founded*

  Suppose $pair(S, leq)$ satisfies DCC.
  Let $T subset.eq S$ be any non-empty subset.
  If $T$ had no minimal elements, then for any $x_0 in T$, there would exist $x_1 in T$ with $x_0 > x_1$.
  Continuing this process, we could construct an infinite strict descending sequence $x_0 > x_1 > x_2 > dots$, contradicting DCC.
]

== Ascending Chain Condition

#definition[
  A poset $pair(S, leq)$ satisfies the _ascending chain condition (ACC)_ if no strict ascending sequence $x_1 < x_2 < x_3 < dots$ of elements of $S$ exists.

  Equivalently, every weakly ascending sequence $x_1 <= x_2 <= x_3 <= dots$ eventually stabilizes.
]

#example[
  $pair(NN, leq)$ does _not_ satisfy ACC since infinite ascending chains like $2 < 3 < 5 < 7 < dots$ exist.
]

#example[
  Consider the poset $pair(power(NN), subset.eq)$ of all subsets of natural numbers ordered by inclusion.
  - *ACC fails:* #NO \
    The ascending chain $emptyset subset.eq {1} subset.eq {1,2} subset.eq {1,2,3} subset.eq dots$ never stabilizes.
  - *DCC fails:* #NO \
    The descending chain $NN supset.eq (NN without {1}) supset.eq (NN without {1,2}) supset.eq dots$ never stabilizes.
]

== Noetherian Relations

#definition[
  A relation $R$ is _Noetherian_ (or _converse well-founded_, or _upwards well-founded_) if the converse relation $R^(-1)$ is well-founded.

  Equivalently, $R subset.eq M^2$ is Noetherian if every non-empty subset of $M$ has $R$-maximal elements.
]

#note[
  This means no infinite ascending chains $x_0 rel(R) x_1 rel(R) x_2 rel(R) dots$ exist.
]

#example[
  The usual order $leq$ on $NN$ is NOT Noetherian:
  - We can construct infinite ascending chains like $1 < 2 < 3 < 4 < dots$
  - However, its converse $geq$ would be well-founded (DCC holds for $leq$)
]

#pagebreak()

#example[
  In ring theory, a _Noetherian ring_ has the property that every ascending chain of ideals stabilizes:
  $I_1 subset.eq I_2 subset.eq I_3 subset.eq dots$ eventually becomes constant.
]

#example[
  In rewriting systems and lambda calculus:
  - A _reduction relation_ $to$ is Noetherian if all reduction sequences terminate
  - For example, $beta$-reduction in simply typed lambda calculus is Noetherian
  - This guarantees that programs always terminate (no infinite loops)
]

== Noetherian Relations and ACC

#theorem[
  For any poset $pair(S, leq)$, the following are equivalent:
  - $pair(S, leq)$ is Noetherian (coverse well-founded)
  - $pair(S, leq)$ satisfies ACC (no infinite ascending chains)
]

#proof[
  By definition, $pair(S, leq)$ is Noetherian iff its converse $geq$ is well-founded.
  By the earlier theorem, this is equivalent to $geq$ satisfying DCC, which is exactly the same as $leq$ satisfying ACC.
]

== Relationships Between Chain Conditions

#theorem[
  For a poset $pair(S, leq)$:
  - *DCC* $iff$ the relation $leq$ is well-founded $iff$ no infinite descending chains.
  - *ACC* $iff$ the _dual_ relation $geq$ is well-founded $iff$ no infinite ascending chains.
]

#proof[
  The first equivalence (DCC $iff$ well-founded) was proved earlier.
  The second equivalence for ACC follows by applying the same reasoning to the dual relation $geq$.
]

== Examples of ACC and DCC

#example[
  Consider the poset $pair(power({1,2,3}), subset.eq)$ of subsets ordered by inclusion:
  - *ACC holds:* #YES
    Any ascending chain $A_1 subset.eq A_2 subset.eq A_3 subset.eq dots$ must stabilize since we can't keep adding elements indefinitely.
  - *DCC holds:* #YES
    Any descending chain $B_1 supset.eq B_2 supset.eq B_3 supset.eq dots$ must stabilize since we can't keep removing elements indefinitely.
  - Both conditions hold because the set is finite.
]

#example[
  In the natural numbers $pair(NN, leq)$:
  - *DCC holds:* #YES
    Any sequence $n_1 >= n_2 >= n_3 >= dots$ must stabilize (well-founded).
  - *ACC fails:* #NO
    The sequence $1 < 2 < 3 < 4 < dots$ never stabilizes.
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

== Summary: Well-Founded Relations and Chain Conditions

#align(center)[
  #table(
    columns: 3,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },

    table.header([Concept], [Characterization], [Key Property]),

    [*Well-ordered*], [Every subset has unique least element], [Stronger than well-founded],

    [*Well-founded*], [Every subset has minimal elements], [DCC: no infinite descent],

    [*DCC (Artinian)*], [No infinite descending chains], [Same as well-founded],

    [*ACC (Noetherian)*], [No infinite ascending chains], [Dual of DCC],
  )
]

#Block[
  *Key relationships:*
  - Well-ordered $==>$ Total order (least elements imply comparability)
  - Well-ordered $==>$ Well-founded (every least element is minimal)
  - Well-founded $<=>$ Noetherian $<=>$ DCC (equivalent characterizations)
  - ACC is independent of DCC (a structure can satisfy one but not the other)
  - These concepts are fundamental for proving termination and finiteness properties
]


== Outline
#outline()

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

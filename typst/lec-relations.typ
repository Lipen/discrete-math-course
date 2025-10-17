#import "theme.typ": *
#show: slides.with(
  title: [Binary Relations],
  subtitle: "Discrete Math",
  date: "Fall 2025",
  authors: "Konstantin Chukharev",
  // dark: true,
)

#show heading.where(level: 1): none

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
      text(fill: green.darken(20%))[Animals ($A$)],
      anchor: "south",
      padding: 0.2,
    )
    draw.content(
      (2.5, 1.2),
      text(fill: orange.darken(20%))[Food ($B$)],
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
    table.header([*Step*], [*Description*], [*Result*]),
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
]

#definition[
  A relation that satisfies _both_ properties is called a _total function_, denoted $f: A to B$.
  It~is defined for every input in its domain.
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
  A function $f: A to B$ is _injective_ (_left-unique_ or _one-to-one_#footnote[
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
  *Key insight:*
  An injective function never "collapses" different inputs to the same output. \
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
  A function $f: A to B$ is _surjective_ (_right-total_ or _onto_) if every element in the codomain is the image of at least one element in the domain.
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
  *Key insight:*
  A surjective function "covers" the entire codomain. \
  Every possible output is actually achieved by some input.
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
  If $f: A to B$ is a bijective function, then its _inverse function_, denoted $f^(-1): B to A$, is:
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

== Examples of Inverse Functions

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

== Characterization of Invertible Functions

#theorem[
  A function $f: A to B$ has an inverse function $f^(-1): B to A$ _if and only if_ $f$ is bijective.
]

#proof[
  We prove both directions.

  *($arrow.r.double$):*
  If $f$ has an inverse, then $f$ is bijective.

  Assume $f^(-1) : B to A$ is an inverse of $f : A to B$ with the following properties:
  - $f^(-1)(f(x)) = x$ for all $x in A$
  - $f(f^(-1)(y)) = y$ for all $y in B$

  We are going to show that $f$ is both injective and surjective.

  + *$f$ is injective:*
    Let $x_1, x_2 in A$ such that $f(x_1) = f(x_2)$.
    Applying $f^(-1)$ to both sides, we get:
    $
      f^(-1)(f(x_1)) = f^(-1)(f(x_2))
    $
    By the property of the inverse, this simplifies to:
    $
      x_1 = x_2
    $
    Thus, $f$ is injective.

  + *$f$ is surjective:*
    Let $y in B$.
    We need to find an $x in A$ such that $f(x) = y$.
    Take $x = f^(-1)(y)$.
    Then by the property of the inverse, we have:
    $
      f(x) = f(f^(-1)(y)) = y
    $
    Hence, $f$ is surjective.

  Therefore, $f$ is bijective.
  #h(1fr)$qed$

  *($arrow.l.double$):*
  If $f$ is bijective, then $f$ has an inverse $f^(-1)$.

  Assume $f: A to B$ is bijective.
  This means:
  - $f$ is injective: $(f(x_1) = f(x_2)) imply (x_1 = x_2)$
  - $f$ is surjective: for every $y in B$, there exists $x in A$ such that $f(x) = y$

  We need to construct an inverse function $f^(-1): B to A$, satisfying:
  $
    f^(-1)(f(x)) = x
    quad "and" quad
    f(f^(-1)(y)) = y
  $

  *Construction of $f^(-1)$:*
  For each $y in B$:
  - Since $f$ is surjective, there exists at least one $x in A$ such that $f(x) = y$.
  - Since $f$ is injective, this $x$ is unique.
  We define a function $f^(-1) : B to A$ by:
  $
    f^(-1)(y) = "the unique" x in A "such that" f(x) = y
  $

  *Verification:*
  + For all $x in A$, by definition of $f^(-1)$:
    $
      f^(-1)(f(x)) = x
    $
  + For all $y in B$, since $f^(-1)(y)$ is defined as the unique $x$ with $f(x) = y$, we have:
    $
      f(f^(-1)(y)) = y
    $

  Therefore, $f^(-1)$ is indeed the inverse of $f$.
  #h(1fr)$qed$

  Thus, a function has an inverse _if and only if_ it is bijective.
]

== Some Properties of Inverse Functions

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

== Monotonicity implies Injectivity

#theorem[
  If $f: RR to RR$ is _strictly increasing_ or _strictly decreasing_, then $f$ is _injective_.
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
  - Monotonic functions have _predictable_ behavior: they never "change direction"
  - _Strictly monotonic_ functions are _always injective_ (one-to-one)
  - Non-strict monotonic functions may have "flat" regions (also known as "_plateaus_") where different inputs map to the same output
  - Fun fact: monotonic functions are _order-homomorphisms_ between posets!
]

== Examples of Monotonic Functions

#examples[
  _Strictly monotonic_ functions (which are always injective):
  - $f(x) = 2x + 1$ is strictly increasing on $RR$, hence injective. #YES
  - $g(x) = -x$ is strictly decreasing on $RR$, hence injective. #YES
  - $h(x) = x^3$ is strictly increasing on $RR$, hence injective. #YES
  - $k(x) = e^x$ is strictly increasing on $RR$, hence injective. #YES
]

#examples[
  _Monotonic_ but _NOT strictly_ monotonic functions (not necessarily injective):
  - $f(x) = floor(x)$ is monotonic increasing but NOT strictly increasing.
    - For $x in [2, 3)$, we have $f(x) = 2$ (constant on intervals).
    - This is NOT injective: $f(2.1) = f(2.9) = 2$ but $2.1 != 2.9$. #NO

  - $g(x) = cases(
      x & "if" x <= 0,
      0 & "if" 0 < x < 1,
      x - 1 &"if" x >= 1
    )$ ~ is monotonic but not injective.
]

#example[
  $f: (RR without {0}) to RR$ defined by $f(x) = 1 / x$ is *injective but not monotonic*.
  - If $f(x_1) = f(x_2)$, then $1/x_1 = 1/x_2$ implies $x_1 = x_2$. #YES
  - However, $f$ is not monotonic since it decreases on $(-infinity, 0)$ and $(0, infinity)$, but $f(-1) < f(1)$. #NO
]

== Function Properties Overview

Functions can be characterized by several key properties that determine their mathematical behavior.

#table(
  columns: 2,
  align: (left, left),
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header([*Property*], [*Definition*]),
  [*Functional* (Right-unique)], [Each input maps to _at most one_ output],
  [*Total* (Left-total)], [Each input maps to _at least one_ output (defined everywhere)],
  [*Partial*], [Functional but not total (may be undefined for some inputs)],
  [*Injective* (Left-unique)], [Different inputs $==>$ different outputs],
  [*Surjective* (Right-total)], [Every codomain element is covered],
  [*Bijective*], [Both injective and surjective (one-to-one correspondence)],
  [*Monotonic*], [Preserves or reverses order relationships],
  [*Continuous*], [Small input changes $==>$ small output changes],
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
      text(fill: blue)[Elements in $S = {2, 4}$ map to $1$],
      anchor: "south",
      padding: 0.2,
    )
    content(
      (3, -0.5),
      text(fill: red)[Elements not in $S$ map to $0$],
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

    content((2.5, 1.5), text(fill: blue)[$floor(x)$], anchor: "west")
    content((2.5, 3.5), text(fill: red)[$ceil(x)$], anchor: "west")

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
    table.header([*$x$*], [*$floor(x)$*], [*$ceil(x)$*], [*Note*]),
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

#definition[
  A _linear order_ is a partial order $R subset.eq M^2$ where every pair of elements is _comparable_:
  $
    forall x, y in M. thin (x rel(R) y or y rel(R) x)
  $
]

#note[
  The above condition is called _strong connectivity_.
  The similar property with the $x != y$ condition is called _semi-connectivity_.
  The corresponding relations are called _connex_ and _semi-connex_.
]

#note[
  Hereinafter, we mainly study the "non-strict" orders (e.g., $<=$, $subset.eq$), which require the _reflexivity_.
  The~"strict" orders (e.g., $<$, $subset$) require _irreflexivity_ instead, and are defined similarly.
]

#note[
  Strict linear orders require _semi-connectivity_ instead, since connectivity alone implies reflexivity!
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

  #place(right, dx: -1em)[
    #import fletcher: diagram, edge, node
    #diagram(
      spacing: (1em, 2.5em),
      node-shape: fletcher.shapes.circle,
      node-stroke: 1pt,
      edge-stroke: 1pt,
      // Vertices:
      node((0, 0), [$1$], width: 2em, inset: 0pt, name: <1>),
      node((-1, -0.9), [$2$], width: 2em, inset: 0pt, name: <2>),
      node((1, -0.9), [$3$], width: 2em, inset: 0pt, name: <3>),
      node((-1, -2.1), [$4$], width: 2em, inset: 0pt, name: <4>),
      node((1, -2.1), [$6$], width: 2em, inset: 0pt, name: <6>),
      node((0, -3), [$12$], width: 2em, inset: 0pt, name: <12>),
      // Main edges:
      edge(<1>, <2>, "-}>"),
      edge(<1>, <3>, "-}>"),
      edge(<2>, <4>, "-}>"),
      edge(<2>, <6>, "-}>"),
      edge(<3>, <6>, "-}>"),
      edge(<4>, <12>, "-}>"),
      edge(<6>, <12>, "-}>"),
      // Transitive edges:
      edge(<1>, <4>, "--}>", bend: -5deg, stroke: gray),
      edge(<1>, <6>, "--}>", bend: 5deg, stroke: gray),
      edge(<1>, <12>, "--}>", bend: 0deg, stroke: gray),
      edge(<2>, <12>, "--}>", bend: -5deg, stroke: gray),
      edge(<3>, <12>, "--}>", bend: 5deg, stroke: gray),
      // Loops:
      edge(<1>, <1>, "--}>", bend: 120deg, loop-angle: -30deg, stroke: gray),
      edge(<2>, <2>, "--}>", bend: 120deg, loop-angle: 150deg, stroke: gray),
      edge(<4>, <4>, "--}>", bend: 120deg, loop-angle: 150deg, stroke: gray),
      edge(<3>, <3>, "--}>", bend: 120deg, loop-angle: 30deg, stroke: gray),
      edge(<6>, <6>, "--}>", bend: 120deg, loop-angle: 30deg, stroke: gray),
      edge(<12>, <12>, "--}>", bend: 120deg, loop-angle: 30deg, stroke: gray),
    )
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
    // content((0, -1), text(fill: blue)[Tree 1], anchor: "center")
    // content((hgap, -1), text(fill: blue)[Tree 2], anchor: "center")
    // content((-hgap, -0.5), text(fill: orange.darken(30%))[Tree 3], anchor: "center")

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
  - Maximal chain: #Blue[${1, 2, 4, 20}$] --- longest path
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
#focus-slide(
  epigraph: [Every set can be well-ordered.],
  epigraph-author: "Ernst Zermelo (Axiom of Choice)",
)

== Well-Ordered Sets

#definition[
  A poset $pair(M, leq)$ is _well-ordered_ if every non-empty subset $S subset.eq M$ has a _least element_.

  Formally: $forall S subset.eq M. thin (S != emptyset) imply (exists m in S. thin forall x in S. thin m leq x)$
]

#Block(color: yellow)[
  *The key property:* No matter how you pick elements from a well-ordered set, there's always a "first" one in any selected subset.

  This is stronger than just having a minimum --- well-ordering means you can't descend infinitely!
]

#note[
  A well-ordered set is automatically a _total order_ (any two elements are comparable).
]

== Examples: Well-Ordered vs Not

#example[The natural numbers][
  $NN = {0, 1, 2, 3, dots}$ with $leq$ is _well-ordered_:
  - ${5, 17, 23, 100}$ has least element $5$
  - ${2, 4, 6, 8, dots}$ has least element $2$
  - Even ${n in NN | n >= 1000}$ has least element $1000$

  *Why this matters:* You can always find a "starting point" in any subset!
]

#example[The integers][
  $ZZ$ with $leq$ is _NOT well-ordered_:
  - ${-1, -2, -3, dots}$ has no minimum
  - $ZZ$ itself has no least element
  - Can descend forever: $0 > -1 > -2 > -3 > dots$

  *The problem:* Negative numbers allow infinite descent.
]

#Block(color: blue)[
  *Intuition:*
  Well-ordering prevents "falling forever."
  Every subset has a floor you can't go below.
]

== More Examples of Well-Orders

#example[Ordinals (preview)][
  Ordinal numbers extend natural numbers into the transfinite:
  - $omega$ = all natural numbers: $0, 1, 2, 3, dots$
  - $omega + 1$ = natural numbers plus one more element "at the end"
  - $omega + 2, omega dot 2, omega^2, omega^omega, dots$

  Each ordinal is well-ordered, and ordinals themselves are well-ordered!
]

#example[Lexicographic order][
  Finite strings with _shortlex order_ (shorter first, then alphabetically):
  - $epsilon < "a" < "b" < dots < "aa" < "ab" < dots < "aaa" < dots$
  - Any set of finite strings has a shortest, and among equals, an alphabetically first
  - Example: ${"cat", "dog", "amoeba", "zebra"}$ has least element "$"amoeba"$"

  #note[
    _Pure_ lexicographic order (alphabetical only) is _NOT_ well-ordered:
    - ${"b", "ab", "aab", "aaab", dots}$ has no least element -- we can always prefix more $"a"$'s!
  ]
]

== Induction on Well-Ordered Sets

The well-ordering property is the foundation of mathematical induction.

Let's see how different forms of induction work on $NN$, then generalize to arbitrary well-ordered sets.

#Block(color: yellow)[
  *Key insight:* Well-ordering means every non-empty set has a _first_ element.

  This is why induction works --- if a property fails somewhere, there must be a _smallest_ counterexample, which leads to contradiction!
]

== Two Forms of Induction on $NN$

#Block(color: blue)[
  *1. Weak (Standard) Induction:*
  - Base: Prove $P(0)$
  - Step: Prove $P(n) ==> P(n+1)$ for all $n$
  - Conclusion: $P(n)$ holds for all $n in NN$

  *2. Strong Induction* (also called _complete induction_ or _course-of-values induction_):
  - For all $n$: assume $P(k)$ holds for all $k < n$, then prove $P(n)$
  - Equivalently: Prove $(P(0) and P(1) and dots and P(n)) ==> P(n+1)$
  - Conclusion: $P(n)$ holds for all $n in NN$
]

#note[
  These are _equivalent_ for $NN$!

  Strong induction is more flexible --- you can use _any_ previous case, not just the immediate predecessor.
]

== Well-Ordering Principle

#definition[Well-Ordering Principle][
  Every non-empty subset of $NN$ has a least element.
]

#note[
  WOP is an _axiom_ in standard formulations of arithmetic (Peano axioms). \
  It cannot be proven from more basic principles --- we take it as a starting point.
]

#theorem[
  The following are _equivalent_:
  + Well-Ordering Principle (WOP)
  + Mathematical Induction
]

#proof[(WOP $==>$ Induction)][
  To prove $forall n in NN. thin P(n)$, assume for contradiction that $P$ fails somewhere.
  - Let $S = { n in NN | not P(n) }$ be the set of counterexamples.
  - By WOP, $S$ has a least element $m$.
    Then $P(k)$ holds for all $k < m$ (since $m$ is least).
  - But by the induction hypothesis $(forall k < m. thin P(k)) imply P(m)$, we have $P(m)$ holds --- contradiction! #qedhere
]

#note[
  The other direction (Induction $==>$ WOP) can also be proven, but is more involved.
  Since both are foundational axioms, we can take either as a starting point and derive the other.
]

== Well-Founded Relations: A Weaker Notion

#definition[
  A relation $R subset.eq M^2$ is _well-founded_ if every non-empty subset $S subset.eq M$ has at least one _minimal element_ with respect to $R$.

  Formally: $forall S subset.eq M. thin (S != emptyset) imply (exists m in S. thin forall x in S. thin x nrel(R) m)$
]

#Block(color: yellow)[
  _Well-founded_ $!=$ _well-ordered_:
  - *Well-ordered:* Every subset has a _unique least_ element (global minimum)
  - *Well-founded:* Every subset has _minimal_ elements (nothing strictly below)
  - Every well-ordered set is well-founded, but not vice versa!
]

== Example: Well-Founded but Not Well-Ordered

#example[Proper subset relation][
  Consider $subset$ on $M = {emptyset, {a}, {b}, {a,b}}$.

  *Well-founded?* #YES Every subset has minimal elements.
  - Take ${{a}, {b}, {a,b}}$:
    - Minimals: ${a}$ and ${b}$ (nothing is properly contained in them)
    - Note: ${a,b}$ is not minimal (${a} subset {a,b}$)

  *Well-ordered?* #NO Some subsets lack a unique least.
  - Same subset ${{a}, {b}, {a,b}}$:
    - ${a}$ and ${b}$ are incomparable (neither contains the other)
    - No single "smallest" set exists!

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

#example[Divisibility relation][
  $pair(NN^+, |)$ is well-founded:
  - In ${6, 12, 18, 4, 8}$, minimal elements are $4$ and $6$ (no smaller divisors in the set)
  - In ${2, 4, 8, 16}$, the only minimal is $2$ (divides all others in the set)
]

#example[Program termination][
  Well-founded relations prove programs terminate:
  ```python
  def factorial(n):
      if n == 0: return 1
      return n * factorial(n-1)
  ```

  *Termination proof:*
  Arguments form decreasing sequence $n > n-1 > n-2 > dots > 0$.

  Since $pair(NN, >)$ is well-founded, this chain must end!

  #Block(color: purple)[
    Well-founded relations are the foundation (pun intended) of _termination analysis_ in Dafny, Coq, and other verification tools.
  ]
]

== Well-Founded Induction

Well-founded relations enable a powerful generalization of mathematical induction.
Instead of working just with $NN$, we can prove properties about *any* well-founded relation.

#definition[
  Let $pair(S, <)$ be a well-founded relation, and let $P(x)$ be a property.

  _Well-founded induction_ (also called _Noetherian induction_) states that if
  $
    forall x in S. thin (forall y < x. thin P(y)) imply P(x)
  $
  then $P(x)$ holds for all $x in S$.
]

#Block(color: yellow)[
  *Key insight:*
  To prove $P(x)$, assume $P(y)$ holds for all $y$ that are _smaller_ than $x$.

  This is like strong induction, but with "smaller" defined by your well-founded relation $<$!
]

== Proof of Well-Founded Induction

#proof[
  We prove by contradiction. Suppose the property $P$ _fails_ for some elements.

  Let $S' = {x in S | not P(x)}$ be the set of "bad" elements where $P$ fails.

  By assumption, $S' != emptyset$. Since $pair(S, <)$ is well-founded, $S'$ must have a _minimal_ element --- call it $x_0$.

  Now consider any $y < x_0$:
  - Since $x_0$ is minimal in $S'$, we have $y in.not S'$
  - Therefore $P(y)$ holds for all $y < x_0$

  But by our hypothesis, $(forall y < x_0. thin P(y)) imply P(x_0)$.

  So $P(x_0)$ must hold --- contradicting the fact that $x_0 in S'$!
]

#Block(color: purple)[
  *The key:* Well-foundedness guarantees a _minimal_ counterexample, and the inductive hypothesis forces that minimal element to satisfy $P$ --- contradiction!
]

== Example: Proving Termination with Well-Founded Induction

```python
def process(S):
    if S == ∅: return "done"
    x = S.pop()  # Remove arbitrary element
    return process(S)
```

*Claim:* `process(S)` terminates for all finite sets $S$.

*Proof:*
Well-founded induction on $pair(cal(P)_("fin")(X), subset)$.

For any $S$, assume termination for all $T subset S$.
- If $S = emptyset$: returns immediately.
- If $S != emptyset$: recursive call uses $S without {x} subset S$, which terminates by hypothesis.

Therefore, `process(S)` terminates for all finite sets $S$!

#Block(color: purple)[
  The relation $subset$ on finite sets is well-founded but _not_ well-ordered (sets ${1}$ and ${2}$ are incomparable).

  This shows well-founded induction works even without total comparability.
]

== Special Cases of Well-Founded Induction

Well-founded induction goes by different names depending on the structure:

#Block(color: green)[
  - *Strong induction* (or *complete induction*): well-founded induction on $pair(NN, >)$
  - *Transfinite induction*: well-founded induction on well-ordered sets (arbitrary ordinals)
  - *Structural induction*: well-founded induction on inductively-defined structures (trees, lists, terms)
]

#note[
  Strong induction on $NN$ is transfinite induction on the ordinal $omega$ (since $pair(NN, >)$ is well-ordered).
]

#example[
  Structural induction on lists:
  - To prove $P(L)$ for all lists, assume $P(L')$ for all _shorter_ lists $L'$
  - "Shorter" means the sublist relation is well-founded (no infinite descending chains)
]

#Block(color: purple)[
  *The pattern:*
  All these variants follow the same approach --- assume the property for all "smaller" elements, then prove it for the current element.

  The only difference is the notion of "smaller" (ordinals, set sizes, tree depths, etc.).
]

== Induced Strict Order

From any partial order $leq$, we automatically get a strict order:

#definition[
  The _induced strict order_ from $leq$ is:
  $
    x lt y quad iff quad x leq y and x != y
  $
  Similarly, $x > y$ means $y < x$ (converse relation).
]

#Block(color: yellow)[
  *Convention:* Given any poset $pair(S, leq)$, we'll freely use $lt$ and $gt$ for the induced strict orders.

  *Why care?* Chain conditions (ascending/descending sequences) are naturally expressed with strict inequalities: $x_1 < x_2 < x_3 < dots$
]

== Descending Chain Condition (DCC)

#definition[
  A poset $pair(S, leq)$ satisfies the _descending chain condition (DCC)_ if there are no infinite strictly descending chains:
  $
    x_1 > x_2 > x_3 > x_4 > dots
  $

  Equivalently: every descending sequence $x_1 >= x_2 >= x_3 >= dots$ eventually _stabilizes_ (becomes constant).
]

#Block(color: blue)[
  *Intuition:* "You can't fall forever" --- every descending path eventually hits bottom or levels off.
]

#example[
  $pair(NN, leq)$ satisfies DCC:

  Any descending sequence must stabilize: $100 >= 50 >= 25 >= 12 >= 6 >= 3 >= 1 >= 0 >= 0 >= 0 >= dots$

  Why? Natural numbers are bounded below by $0$, so you eventually hit the bottom and can't go lower!
]

== The Fundamental Equivalence

#theorem[
  For any poset $pair(S, leq)$:
  $
    "well-founded" quad <==> quad "satisfies DCC"
  $
]

#Block(color: purple)[
  "Every subset has a floor" $iff$ "You can't fall forever"
]

#proof[($==>$)][
  *Well-founded implies DCC*

  Suppose there's an infinite descending chain $x_0 > x_1 > x_2 > dots$.

  Consider the set $T = {x_0, x_1, x_2, dots}$.

  By well-foundedness, $T$ has a minimal element $x_k$.
  But $x_k > x_(k+1)$, so $x_(k+1)$ is smaller than $x_k$ --- contradicting minimality!
]

#pagebreak()

#proof[($<==$)][
  *DCC implies well-founded*

  Let $T subset.eq S$ be non-empty.
  Pick any $x_0 in T$.
  - If $x_0$ is not minimal, pick $x_1 in T$ with $x_1 < x_0$.
  - If $x_1$ is not minimal, pick $x_2 in T$ with $x_2 < x_1$.
  - And so on...

  If this process never stops, we get an infinite descending chain $x_0 > x_1 > x_2 > dots$, contradicting DCC!

  Therefore, we must eventually find a minimal element.
]

== Ascending Chain Condition (ACC)

#definition[
  A poset $pair(S, leq)$ satisfies the _ascending chain condition (ACC)_ if there are no infinite strictly ascending chains:
  $
    x_1 < x_2 < x_3 < x_4 < dots
  $

  Equivalently: every ascending sequence $x_1 <= x_2 <= x_3 <= dots$ eventually _stabilizes_ (becomes constant).
]

#Block(color: blue)[
  *Intuition:* "You can't climb forever" --- every ascending path eventually reaches a ceiling or levels off.
]

#example[
  $pair(NN, leq)$ does _NOT_ satisfy ACC:

  The sequence $0 < 1 < 2 < 3 < 4 < dots$ never stabilizes --- no upper bound stops the ascent!
]

#example[
  $pair(power(NN), subset.eq)$ satisfies _neither_ ACC nor DCC:
  - *ACC fails:* $emptyset subset {1} subset {1,2} subset {1,2,3} subset dots$ (can climb forever)
  - *DCC fails:* $NN supset.eq NN without {1} supset.eq NN without {1,2} supset.eq dots$ (can fall forever)
]

== Noetherian Relations: The Dual Concept

Just as well-founded relations prevent infinite descent, _Noetherian_ relations prevent infinite ascent.

#definition[
  A relation $R$ is _Noetherian_ if its converse $R^(-1)$ is well-founded.

  Equivalently: every non-empty subset has _maximal_ elements (nothing strictly above them).
]

#Block(color: yellow)[
  *Well-founded vs Noetherian:*
  - Well-founded: every subset has _minimal_ elements → DCC (can't fall forever)
  - Noetherian: every subset has _maximal_ elements → ACC (can't climb forever)
  - They're perfect duals: flip the order and swap the roles!
]

#pagebreak()

#theorem[
  For any poset $pair(S, leq)$:
  $
    "Noetherian" quad <==> quad "satisfies ACC"
  $
]

#proof[
  Chain of equivalences:
  $
    pair(S, leq) "is Noetherian" & iff pair(S, geq) "is well-founded" \
                                 & iff pair(S, geq) "satisfies DCC" \
                                 & iff pair(S, leq) "satisfies ACC"
  $
  Each step follows from definitions and the well-founded $iff$ DCC equivalence.
]

== Applications of Noetherian Relations

#examples[Algebra][
  A ring is _Noetherian_ if every ascending chain of ideals stabilizes:
  $
    I_1 subset.eq I_2 subset.eq I_3 subset.eq dots quad "eventually becomes constant"
  $

  Examples: $ZZ$, polynomial rings $k[x_1, dots, x_n]$ over fields.

  This is fundamental in commutative algebra --- the Hilbert basis theorem guarantees that polynomial rings over Noetherian rings are Noetherian!
]

#example[Computer science][
  A term-rewriting system terminates if the reduction relation is Noetherian.

  - In simply-typed lambda calculus, $beta$-reduction is Noetherian, thus terminates.
    - Every reduction decreases a complexity measure
    - No infinite reduction sequences exist
    - Therefore: all well-typed programs halt!

  #Block(color: blue)[
    *General technique:* Find a Noetherian measure that strictly decreases with each computation step, proving termination.
  ]
]

== Chain Conditions: Key Examples

#align(center)[
  #table(
    columns: 3,
    align: (left, center, center),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Poset*], [*DCC?*], [*ACC?*]),
    [$pair(NN, leq)$], [#YES], [#NO],
    [$pair(power({1,2,3}), subset.eq)$ (finite)], [#YES], [#YES],
    [$pair(power(NN), subset.eq)$ (infinite)], [#NO], [#NO],
    [$pair(ZZ, |)$ (divisibility)], [#NO], [#NO],
  )
]

#Block(color: yellow)[
  *Key insight:*
  DCC and ACC are _independent_ --- a structure can satisfy one, both, or neither!
]

== Applications: From Theory to Practice

These abstract concepts --- well-orders, well-founded relations, and chain conditions --- are powerful tools for proving _termination_, reasoning about _infinity_, and establishing _finiteness_ properties.

#Block(color: purple)[
  *The unifying principle:*
  All capture variants of _"no infinite regress"_ --- essential for proving processes terminate and structures are well-behaved.
]

#examples[Computer science][
  - *Model checking:* Well-founded relations guarantee finite state-space exploration
  - *Database systems:* Datalog uses well-founded semantics for recursive queries
  - *Compiler optimization:* Prove termination of optimization passes via well-founded metrics
  - *Graph algorithms:* DFS/BFS termination follows from well-founded visit ordering
]

#pagebreak()

#examples[Mathematics & logic][
  - *Transfinite induction:* Well-ordering enables proofs about infinite ordinals
  - *Set theory:* Von Neumann ordinals constructed as well-ordered sets
  - *Rewriting systems:* Confluence and termination via Noetherian orderings (Knuth-Bendix)
  - *Combinatorics:* Dickson's lemma uses well-quasi-orders for finiteness results
]

#examples[Software engineering][
  - *Scheduling algorithms:* Priority queues maintain well-founded task ordering
  - *Garbage collection:* Reachability analysis uses well-founded heap traversal
  - *Distributed systems:* Lamport clocks establish well-founded event causality
  - *Version control:* Commit DAGs form well-founded partial orders
]

== Summary: Well-Founded Relations and Chain Conditions

#align(center)[
  #table(
    columns: 3,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Concept*], [*Definition*], [*Equivalent to*]),
    [*Well-ordered*], [Every subset has _unique least_ element], [Total + well-founded],
    [*Well-founded*], [Every subset has _minimal_ elements], [DCC],
    [*Noetherian*], [Every subset has _maximal_ elements], [ACC],
    [*DCC (Artinian)*], [No infinite descending chains], [Well-founded],
    [*ACC (Noetherian)*], [No infinite ascending chains], [Noetherian],
  )
]

#Block(color: purple)[
  *Key relationships:*
  - Well-ordered $imply$ well-founded (least $imply$ minimal)
  - Well-ordered $imply$ total order (least elements force comparability)
  - Well-founded $iff$ DCC (equivalent characterizations)
  - Noetherian $iff$ ACC (equivalent characterizations)
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

== Cardinality of Sets

#definition[
  The _cardinality_ of a set $X$, denoted $abs(X)$, is a measure of its "size".
  - For _finite_ sets, cardinality equals the number of elements: $abs({a, b, c}) = 3$.
  - For _infinite_ sets, cardinality describes the "type" of infinity, distinguishing between _countable_ (like $NN$) and _uncountable_ (like $RR$) infinities.
]

#Block(color: yellow)[
  *Key insight:* Not all infinities are equal! \
  Some infinite sets are "larger" than others in a precise mathematical sense.
]

#example[
  - $abs(NN) = aleph_0$ (_"aleph-null"_ --- the smallest infinite cardinal, denoting _countable_ infinity)
  - $abs(ZZ) = aleph_0$ (surprisingly, same size as $NN$!)
  - $abs(QQ) = aleph_0$ (rationals are also countably infinite)
  - $abs(RR) = 2^(aleph_0) = frak(c)$ (_"continuum"_ --- _uncountably_ infinite)
  - $abs(power(NN)) = 2^(aleph_0) > aleph_0$ (power set is always larger than the original set)
]

== Cardinal Numbers

#note[
  $abs(X)$ is not just a number, but a _cardinal number_.
  - Cardinal numbers extend natural numbers to describe sizes of infinite sets
  - The finite cardinals are: $0, 1, 2, 3, dots$
  - The first infinite cardinal is $aleph_0 = abs(NN)$
  - Arithmetic on infinite cardinals behaves differently: $aleph_0 + 1 = aleph_0$ and $aleph_0 dot 2 = aleph_0$
]

#Block(color: blue)[
  *Cantor's revolutionary insight (1874):*
  We can compare sizes of infinite sets using bijections, just as we compare finite sets by counting!
]

== Equinumerosity

#definition[
  Two sets $A$ and $B$ have the same _cardinality_ and are called _equinumerous_, denoted $abs(A) = abs(B)$ or $A equinumerous B$, iff there exists a _bijection_ (one-to-one correspondence) between $A$ and $B$.
]

#note(title: "Intuition")[
  If you can pair up every element of $A$ with exactly one element of $B$, with nothing left over on either side, then $A$ and $B$ have the same cardinality.
]

#theorem[
  Equinumerosity is an equivalence relation.
]

#proof[
  Let $A$, $B$, $C$ be sets.
  - *Reflexivity:*
    The identity map $id_A: A to A$, where $id_A (x) = x$, is a bijection, so $A equinumerous A$.
  - *Symmetry:*
    Suppose $A equinumerous B$, then there is a bijection $f: A to B$.
    Since it is a bijection, its inverse $f^(-1)$ exists and is also a bijection.
    Hence, $f^(-1): B to A$ is a bijection, so $B equinumerous A$.
  - *Transitivity:*
    Suppose that $A equinumerous B$ and $B equinumerous C$, i.e., there are bijections $f: A to B$ and $g: B to C$.
    Then~the composition $g compose f: A to C$ is also a bijection.
    So $A equinumerous C$.

  Therefore, equinumerosity is an equivalence relation.
]

== Hilbert's Grand Hotel

#Block(color: teal)[
  Imagine a hotel with _infinitely many_ rooms, numbered $1, 2, 3, dots$, and _all rooms are occupied_.

  A new guest arrives.
  Can we accommodate them?
  #h(1fr) *YES!*
]

#place(right)[
  #box(
    image("assets/grand-hotel.jpg", height: 6cm),
    stroke: 1pt + blue.darken(20%),
    radius: 5pt,
    clip: true,
  )
]

*The solution:*#h(.2em)
Move each guest in room $n$ to room $n + 1$.
- Guest in room 1 moves to room 2
- Guest in room 2 moves to room 3
- And so on...
Now room 1 is _vacant_ for the new guest!

*Formally:* #h(.2em)
Define the _shift map_ $f: NN to NN$ by $f(n) = n + 1$
- *Injective:* Different rooms map (shift) to different rooms
- *Not surjective:* Room 1 has no pre-image

#Block(color: blue)[
  The hotel can accommodate one more guest even though it is "full"!
]

== Dedekind-Infinite Sets

#definition[
  A set $X$ is _Dedekind-infinite_ if some proper subset $Y subset X$ is equinumerous to it, i.e., there is a _bijection_ between $X$ and one of its _proper_ subsets.

  Equivalently, $X$ is Dedekind-infinite if there exists an _injective_ but _not surjective_ function $f: X to X$.

  A set that is _not_ Dedekind-infinite is called _Dedekind-finite_.
]

#note[
  Intuitively, an "infinite" set can be put in one-to-one correspondence with a part of itself, which is impossible for finite sets.
]

#example[
  The set of natural numbers $NN$ is Dedekind-infinite:
  - Let $Y = {2, 4, 6, 8, ...} = NN_"even" subset NN$ (proper subset)
  - Define $f: NN to Y$ by $f(n) = 2n$ (bijection)
  - Since $NN equinumerous NN_"even"$ (equinumerous, bijection exists), the set $NN$ is Dedekind-infinite
]

== Examples of Dedekind-Infinite Sets

#example[
  *Integers* $ZZ$ are Dedekind-infinite:
  - Define $f: ZZ to ZZ_"even"$ by $f(n) = 2n$
  - This is a bijection: $ZZ equinumerous ZZ_"even" subset ZZ$
]

#example[
  *Rationals* $QQ$ are Dedekind-infinite:
  - Define $f: QQ to QQ without [0; 1)$ by $f(x) = cases(x &"if" x < 0, x + 1 &"if" x >= 0)$
  - This "skips" the interval $[0; 1)$, giving a bijection onto $QQ without [0, 1) subset QQ$
]

#example[
  *Real numbers* $(0; 1)$ are Dedekind-infinite:
  - Define $f: (0; 1) to (0; 1/2)$ by $f(x) = x/2$
  - This is a bijection: $(0; 1) equinumerous (0; 1/2) subset (0; 1)$
]

#Block(color: yellow)[
  *Key insight:* Being Dedekind-infinite is equivalent to being infinite (assuming the Axiom of Choice).

  This gives us a purely set-theoretic definition of infinity without counting!
]

== Hilbert's Hotel: Infinitely Many New Guests

#Block(color: orange)[
  *The Greater Challenge:*
  Now a _bus_ with infinitely many passengers arrives (numbered $1, 2, 3, dots$).
  The hotel is still completely full.
  Can we accommodate all of them?
  #h(1fr) *YES!*
]

*The solution:*

Ask each current guest in room $n$ to move to room $2n$:
$
  f_"current": NN to NN_"even", quad f_"current" (n) = 2n
$

This creates infinitely many vacant _odd-numbered_ rooms: ${1, 3, 5, 7, 9, ...}$

Then, assign bus passenger $k$ to room $2k - 1$:
$
  f_"new": NN to NN_"odd", quad f_"new" (k) = 2k - 1
$

#pagebreak()

#align(center)[
  #table(
    columns: 5,
    align: center + horizon,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    inset: (x, y) => if y == 0 { 5pt } else { 3pt },
    table.header([*Original*], [*Current Guest*], [*$-->$*], [*New Room*], [*New Guest*]),
    [Room 1], [Guest \#1], [], [Room 2], [],
    [Room 2], [Guest \#2], [], [Room 4], [],
    [Room 3], [Guest \#3], [], [Room 6], [],
    // [Room 4], [Guest \#4], [], [Room 8], [],
    [$dots.v$], [$dots.v$], [], [$dots.v$], [],
    [], [], [], [Room 1], [Bus passenger \#1],
    [], [], [], [Room 3], [Bus passenger \#2],
    [], [], [], [Room 5], [Bus passenger \#3],
    // [], [], [], [Room 7], [Bus passenger \#4],
    [], [], [], [$dots.v$], [$dots.v$],
  )
]

#Block(color: blue)[
  This demonstrates that $NN$ (all guests) is equinumerous to $NN_"even"$ (current guests) _and_ $NN_"odd"$ (new guests):
  $
    abs(NN) = abs(NN_"even") = abs(NN_"odd") = aleph_0
  $
  Moreover, we showed that $NN equinumerous NN_"even" union.sq NN_"odd"$, illustrating that $aleph_0 + aleph_0 = aleph_0$.
]

== Countable Sets

#definition[
  A set is _countable_ if it is either finite, or has the same cardinality as $NN$ (i.e., there exists a bijection with $NN$).

  An infinite countable set has cardinality $aleph_0$.
]

#Block(color: yellow)[
  *Key insight:* A countable set is one whose elements can be "listed" in a sequence $a_0, a_1, a_2, dots$, pairing each with a natural number.
]

#example[
  *Integers* $ZZ = {..., -2, -1, 0, 1, 2, ...}$ are countable: $abs(ZZ) = aleph_0$

  Bijection $f: NN to ZZ$:
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

  This systematically pairs each natural number with exactly one integer.
]

== Properties of Countable Sets

#theorem[
  + Any subset of a countable set is countable
  + The union of countably many countable sets is countable
  + The Cartesian product of two countable sets is countable
  + The set of finite sequences over a countable alphabet is countable
]

// #Block(color: blue)[
//   These closure properties let us build complex countable structures from simple ones!
// ]

== Examples of Countable Sets

#example[
  *Finite binary strings* $Sigma^* = {epsilon, 0, 1, 00, 01, 10, 11, 000, ...}$ over $Sigma = {0, 1}$:
  - List by length, then lexicographically: $epsilon$ (length 0), then $0, 1$ (length 1), then $00, 01, 10, 11$ (length 2), etc.
  - Since each length class is finite and there are countably many lengths, $Sigma^*$ is countable
]

#example[
  *Polynomials* with integer coefficients $ZZ[x]$:
  - Group by degree and coefficient sum, enumerate systematically
  - Countable because expressible as finite sequences over $ZZ$
]

#example[
  *Algebraic numbers* (roots of polynomials with integer coefficients):
  - Each polynomial has finitely many roots
  - "Countably many polynomials" $times$ "finitely many roots each" $=$ countable
]

== Zig-Zag Enumeration: $NN^2$ is Countable

#theorem[
  $NN times NN$ is countable.
]

#proof[
  We enumerate pairs by diagonals of constant sum $s = n + k$ for $s = 0, 1, 2, dots$

  #align(center)[
    #let cantor(n, k) = (n + k) * (n + k + 1) / 2 + k
    #table(
      columns: 6,
      align: center,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } + if x == 0 { (right: 0.8pt) },

      table.header([*$n arrow.b quad k arrow.r$*], [*$0$*], [*$1$*], [*$2$*], [*$3$*], [*$dots$*]),

      [*$0$*],
      [#text(fill: red.darken(20%))[$pair(0, 0)$] \ #text(size: 0.8em, fill: red.darken(20%))[$#cantor(0, 0)$]],
      [#text(fill: orange.darken(20%))[$pair(0, 1)$] \ #text(size: 0.8em, fill: orange.darken(20%))[$#cantor(0, 1)$]],
      [#text(fill: green.darken(20%))[$pair(0, 2)$] \ #text(size: 0.8em, fill: green.darken(20%))[$#cantor(0, 2)$]],
      [#text(fill: blue.darken(20%))[$pair(0, 3)$] \ #text(size: 0.8em, fill: blue.darken(20%))[$#cantor(0, 3)$]],
      [$dots$],

      [*$1$*],
      [#text(fill: orange.darken(20%))[$pair(1, 0)$] \ #text(size: 0.8em, fill: orange.darken(20%))[$#cantor(1, 0)$]],
      [#text(fill: green.darken(20%))[$pair(1, 1)$] \ #text(size: 0.8em, fill: green.darken(20%))[$#cantor(1, 1)$]],
      [#text(fill: blue.darken(20%))[$pair(1, 2)$] \ #text(size: 0.8em, fill: blue.darken(20%))[$#cantor(1, 2)$]],
      [#text(fill: purple.darken(20%))[$pair(1, 3)$] \ #text(size: 0.8em, fill: purple.darken(20%))[$#cantor(1, 3)$]],
      [$dots$],

      [*$2$*],
      [#text(fill: green.darken(20%))[$pair(2, 0)$] \ #text(size: 0.8em, fill: green.darken(20%))[$#cantor(2, 0)$]],
      [#text(fill: blue.darken(20%))[$pair(2, 1)$] \ #text(size: 0.8em, fill: blue.darken(20%))[$#cantor(2, 1)$]],
      [#text(fill: purple.darken(20%))[$pair(2, 2)$] \ #text(size: 0.8em, fill: purple.darken(20%))[$#cantor(2, 2)$]],
      [#text(fill: teal.darken(20%))[$pair(2, 3)$] \ #text(size: 0.8em, fill: teal.darken(20%))[$#cantor(2, 3)$]],
      [$dots$],

      [*$3$*],
      [#text(fill: blue.darken(20%))[$pair(3, 0)$] \ #text(size: 0.8em, fill: blue.darken(20%))[$#cantor(3, 0)$]],
      [#text(fill: purple.darken(20%))[$pair(3, 1)$] \ #text(size: 0.8em, fill: purple.darken(20%))[$#cantor(3, 1)$]],
      [#text(fill: teal.darken(20%))[$pair(3, 2)$] \ #text(size: 0.8em, fill: teal.darken(20%))[$#cantor(3, 2)$]],
      [#text(fill: navy.lighten(20%))[$pair(3, 3)$] \ #text(size: 0.8em, fill: navy.lighten(20%))[$#cantor(3, 3)$]],
      [$dots$],

      [*$dots.v$*], [$dots.v$], [$dots.v$], [$dots.v$], [$dots.v$], [$dots.down$],
    )
  ]

  The _Cantor pairing function_ gives an explicit bijection $f: NN^2 to NN$:
  $
    f(n, k) = underbrace(frac((n+k)(n+k+1), 2), "pairs before diagonal" n+k) + underbrace(k, "position within diagonal")
  $

  Therefore $NN^2 equinumerous NN$, so $abs(NN^2) = aleph_0$.
]

#Block(color: blue)[
  *Why this matters:*
  "2-dimensional infinity" is the same size as "1-dimensional infinity"!

  More generally, $NN^n$ is countable for any finite $n$.
]

== Rationals are Countable

#theorem[
  $QQ$ is countable.
]

#proof[
  We construct an injection from $QQ$ into $NN times NN$, which is countable.

  *Step 1:* Map each positive rational $p/q$ (as a reduced fraction) to $(p, q) in NN times NN$.
  - This is injective: different reduced fractions have different $(p,q)$ pairs
  - Since $NN times NN$ is countable, $QQ^+ smaller.eq NN times NN$ (injection) implies $QQ^+$ is countable

  *Step 2:* Decompose $QQ = QQ^+ union {0} union QQ^-$ (union of three disjoint sets).
  - $QQ^+$ is countable (Step 1), ~ ${0}$ is finite, ~ $QQ^- equinumerous QQ^+$ via $f(x) = -x$

  *Step 3:* Union of three countable sets is countable, so $QQ$ is countable.
]

#Block(color: yellow)[
  *Surprising fact:*
  There are "as many" rationals as integers, even though rationals are _dense_ (between any two, there's another) while integers are _discrete_!
]

== Uncountable Sets: Cantor's Diagonal Argument

#definition[
  A set is _uncountable_ if it is infinite but not countable (no bijection with $NN$ exists).
]

#Block(color: orange)[
  *Cantor's strategy:* Given any proposed "list" of all elements, construct a _new_ element that differs from each item in the list, proving the list is incomplete.
]

// == Diagonal Argument: $BB^omega$ is Uncountable

#theorem[
  The set $BB^omega$ of all infinite binary sequences is uncountable.
]

#Block(color: yellow)[
  *Why $BB^omega$?*
  It's simpler than $RR$ but has the same cardinality: $abs(BB^omega) = abs(RR) = 2^(aleph_0) = frak(c)$. \
  Binary sequences can represent real numbers via binary expansions!
]

#proof[
  Suppose for contradiction that $BB^omega$ is countable.
  Then we can enumerate its elements as $x_1, x_2, x_3, dots$, where $x_i = (b_(i 1), b_(i 2), b_(i 3), dots)$ is an infinite bit sequence.

  We can represent this enumeration as an infinite table, where each row corresponds to a (supposedly countable) sequence $x_i$ and each column corresponds to a bit position (natural numbers):

  #align(center)[
    #table(
      columns: 6,
      align: center,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } + if x == 0 { (right: 0.8pt) },
      table.header([*Seq*], [*Bit 1*], [*Bit 2*], [*Bit 3*], [*Bit 4*], [*$dots$*]),
      [$x_1$], [#text(fill: red)[*$b_(1 1)$*]], [$b_(1 2)$], [$b_(1 3)$], [$b_(1 4)$], [$dots$],
      [$x_2$], [$b_(2 1)$], [#text(fill: red)[*$b_(2 2)$*]], [$b_(2 3)$], [$b_(2 4)$], [$dots$],
      [$x_3$], [$b_(3 1)$], [$b_(3 2)$], [#text(fill: red)[*$b_(3 3)$*]], [$b_(3 4)$], [$dots$],
      [$x_4$], [$b_(4 1)$], [$b_(4 2)$], [$b_(4 3)$], [#text(fill: red)[*$b_(4 4)$*]], [$dots$],
      [$dots.v$], [$dots.v$], [$dots.v$], [$dots.v$], [$dots.v$], [$dots.down$],
      [#text(fill: blue)[*$Delta$*]],
      [#text(fill: blue)[*$overline(b)_(1 1)$*]],
      [#text(fill: blue)[*$overline(b)_(2 2)$*]],
      [#text(fill: blue)[*$overline(b)_(3 3)$*]],
      [#text(fill: blue)[*$overline(b)_(4 4)$*]],
      [$dots$],
    )
  ]

  Construct $Delta = (overline(b)_(1 1), overline(b)_(2 2), overline(b)_(3 3), dots)$ by flipping each diagonal bit:
  $
    overline(b)_(i i) = cases(
      1 & "if" b_(i i) = 0,
      0 & "if" b_(i i) = 1
    )
  $

  #colbreak()

  *Key observation:* $Delta != x_i$ for any $i$, because they differ at position $i$: $overline(b)_(i i) != b_(i i)$.

  But $Delta in BB^omega$, since it is an infinite binary sequence, so it _should_ appear in our enumeration.
  Contradiction!

  Therefore, $BB^omega$ is uncountable.
]

#Block(color: yellow)[
  *Connection to zig-zag:*
  - *Zig-zag* (for $NN^2$): Each diagonal is _finite_, we can list all pairs
  - *Diagonal argument* (for $BB^omega$): Sequences are _infinite_, impossible to list completely!
]

== More Uncountable Sets

#example[
  *Real numbers* $RR$ are uncountable:
  - Map each $x in (0; 1)$ to its binary expansion sequence in $BB^omega$
  - Since $BB^omega$ is uncountable and $(0, 1) equinumerous RR$, we have $abs(RR) = 2^(aleph_0) = frak(c)$
]

#example[
  *Power set* $power(NN)$ is uncountable:
  - Map each $S subset.eq NN$ to its characteristic sequence $(chi_S (0), chi_S (1), chi_S (2), dots) in BB^omega$
  - This is a bijection: $power(NN) equinumerous BB^omega$
  - Therefore $abs(power(NN)) = 2^(aleph_0)$ (matches Cantor's theorem!)
]

#pagebreak()

#example[
  *Irrational numbers* $II = RR setminus QQ$ are uncountable:
  - If $II$ were countable, then $RR = QQ union II$ would be a union of two countable sets, hence countable
  - But $RR$ is uncountable, contradiction!
  - Most real numbers are irrational (in a measure-theoretic sense)
]

#example[Computer science connections][
  - *Undecidable problems:*
    There are uncountably many _languages_ over any alphabet, but only countably many _algorithms_ (finite strings).
    Most languages have no decision algorithm!

  - *Real computation:*
    Real numbers are uncountable, but computable reals are countable

  - *Cryptography:*
    Security often relies on the vastness of uncountable key spaces
]

== Comparing Cardinalities

#definition[
  The cardinality of $A$ is _less than or equal to_ that of $B$, denoted $abs(A) <= abs(B)$ or $A smaller.eq B$, if~there exists an _injection_ $f: A to B$.
]

#definition[
  The cardinality of $A$ is _strictly less than_ that of $B$, denoted $abs(A) < abs(B)$ or $A smaller B$, if~#box[$A smaller.eq B$] and $A equinumerous.not B$ (injection exists, but no bijection).
]

#Block(color: yellow)[
  *Key insight:* Injections let us compare sizes without needing full bijections!
]

#example[
  - $abs({1, 2}) < abs({a, b, c})$ because $f(1)=a, f(2)=b$ is injective, but no bijection exists
  - $abs(NN) <= abs(ZZ)$ and $abs(ZZ) <= abs(NN)$ (both have bijections, so $abs(NN) = abs(ZZ)$)
  - $abs(NN) < abs(power(NN))$ because $f(n) = {n}$ is injective, but Cantor's theorem says no bijection exists
  - $abs(NN) < abs(RR)$ because $f: NN to RR$ via $f(n)=n$ is injective, but diagonal argument shows no bijection
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
  *Profound implication:*
  There is no "largest" infinity!
  We can always construct a bigger one using the power set operation: $aleph_0 < 2^(aleph_0) < 2^(2^(aleph_0)) < dots$
]

== Schröder--Bernstein Theorem

#theorem[Schröder--Bernstein][
  If $A smaller.eq B$ and $B smaller.eq A$, then $A equinumerous B$.

  Equivalently: if injections $f: A to B$ and $g: B to A$ both exist, then a bijection $h: A to B$ exists.
] <schroder-bernstein>

#Block(color: blue)[
  *What this means:* If each set "fits inside" the other, they have the same size! \
  This powerful result lets us prove equality of cardinalities without constructing explicit bijections.
]

#example[
  $(0; 1) equinumerous [0; 1]$ (open interval equals closed interval):
  - Injection $f: (0; 1) to [0; 1]$ by $f(x) = x$ (identity)
  - Injection $g: [0; 1] to (0; 1)$ by $g(x) = x/2 + 1/4$ (shrink and shift to $(1/4; 3/4)$)
  - By Schröder--Bernstein, there exists a bijection between them!
]

#note[
  The proof is non-trivial and constructive.
  We'll see it in a dedicated section later.
]

== Unit Line vs. Unit Square

#theorem[
  The unit line $L = [0; 1]$ and unit square $S = [0; 1]^2$ are equinumerous.
]

#grid(
  columns: (1fr, auto),
  gutter: 1em,

  align(center)[
    #cetz.canvas({
      import cetz.draw: *
      let w = 1
      let gap = 1
      line((0, 0), (w, 0), mark: (symbol: "|"))
      content((w / 2, w / 2))[$L$]
      translate((w, 0))
      content((gap / 2, w / 2))[$equinumerous$]
      translate((gap, 0))
      rect((0, 0), (w, w), fill: luma(90%))
      content((w / 2, w / 2))[$S$]
    })
  ],

  Block(color: yellow)[
    *Surprise!* A 1D object has the same cardinality as a 2D object!
  ],
)

#proof[#footnote[
  See https://math.stackexchange.com/a/183383 for more detailed analysis.
]][
  *Step 1:*
  Injection $f: L to S$ by $f(x) = pair(x, x)$ gives $L smaller.eq S$.
  - If $f(a) = f(b)$, then $pair(a, a) = pair(b, b)$, so $a = b$

  *Step 2:*
  Injection $g: S to L$ by _interleaving_ decimal digits gives $S smaller.eq L$:
  $
    cases(
      reverse: #true,
      x & = 0.#Blue($x_1 x_2 x_3 dots$),
      y & = 0.#Green($y_1 y_2 y_3 dots$),
    )
    quad
    g(x, y) = 0.#Blue($x_1$) #Green($y_1$) #Blue($x_2$) #Green($y_2$) #Blue($x_3$) #Green($y_3$) dots
  $
  - If $g(a,b) = g(c,d)$, then all digits match, so $pair(a, b) = pair(c, d)$

  *Step 3:*
  By Schröder--Bernstein (@schroder-bernstein), we conclude $L equinumerous S$.
]

== Summary: Cardinality & Infinity

#Block(color: blue)[
  *Cardinality* measures set "size," with surprising distinctions among infinities:
  - _Finite sets:_ Cardinality $=$ element count
  - _Countable infinity_ ($aleph_0$): Sets like $NN, ZZ, QQ$ that can be listed (bijection with $NN$)
  - _Uncountable infinity_: Sets like $RR$ and $power(NN)$ too large to enumerate (e.g., $abs(RR) = 2^(aleph_0) = frak(c)$)
]

#Block(color: green)[
  *Key techniques:*

  - _Equinumerosity:_ Sets have equal cardinality iff a bijection exists between them
  - _Injections:_ Prove $abs(A) <= abs(B)$ by constructing a one-to-one map
  - _Diagonal argument:_ Prove uncountability by showing no enumeration can be complete
  - _Schröder--Bernstein:_ Two injections (both ways) yield a bijection
]

#pagebreak()

#Block(color: orange)[
  *Mind-bending facts:*

  - $abs(NN) = abs(ZZ) = abs(QQ) = aleph_0$ ~ (integers and rationals are "same size" as naturals!)
  - $abs(NN times NN) = abs(NN)$ ~ (2D grid has same size as 1D line)
  - $[0;1] equinumerous [0;1]^2$ ~ (unit line equals unit square!)
  - $abs(NN) < abs(power(NN)) < abs(power(power(NN))) < dots$ ~ (infinitely many infinities!)
  - Most real numbers are _not_ algebraic (computable reals are countable, but all reals are uncountable)
]


= Enumerations and Countability
#focus-slide()

== Enumerable Sets

#definition[
  A set $X$ is _enumerable_ if there exists a surjection $e: NN to X$.

  The function $e$ is called an _enumeration_ of $X$.
]

#note(title: "Intuition")[
  An enumerable set can be "listed" as $e(0), e(1), e(2), dots$ (possibly with repetitions).
]

#note[
  Elements may appear multiple times since we only require a _surjection_, not a bijection.
]

#example[
  *Even numbers:* $e(n) = 2n$ gives $0, 2, 4, 6, 8, dots$
]
#example[
  *Perfect squares:* $e(n) = n^2$ gives $0, 1, 4, 9, 16, 25, dots$
]
#example[
  *Prime numbers:* $e(0)=2, e(1)=3, e(2)=5, e(3)=7, dots$ (via Sieve of Eratosthenes)
]

== Three Equivalent Characterizations

#theorem[
  For any set $X$, the following are equivalent:
  + $X$ is _countable_: $X$ is finite or has a bijection with $NN$
  + $X$ is _enumerable_: there exists a surjection $e: NN to X$
  + $X$ is _embeddable in $NN$_: $X = emptyset$ or there exists an injection $f: X to NN$
]

#Block(color: blue)[
  *Practical guide:*
  - Use _bijection_ when you can construct an explicit 1-1 correspondence
  - Use _surjection_ (enumeration) when you can algorithmically list elements
  - Use _injection_ when $X$ embeds naturally into $NN$ (often easiest!)
]

== Proof of Equivalence

#proof[
  We prove $(1) => (2) => (3) => (1)$.

  *$(1) => (2)$:* Suppose $X$ is countable.
  - If $X$ is finite: $X = {x_0, ..., x_(n-1)}$, define $e(k) = cases(x_k "if" k < n, x_0 "if" k >= n)$ (surjection)
  - If $X equinumerous NN$: any bijection $g: NN to X$ is also a surjection

  *$(2) => (3)$:* Suppose $e: NN to X$ is a surjection.
  - If $X = emptyset$, done
  - Otherwise, for each $x in X$, define $f(x) = min{n in NN | e(n) = x}$ (first occurrence)
  - This is injective: if $f(x) = f(y) = n$, then $e(n) = x$ and $e(n) = y$, so $x = y$

  *$(3) => (1)$:* Suppose $X = emptyset$ or $f: X to NN$ is injective.
  - If $X = emptyset$, then $X$ is finite (countable)
  - Otherwise, $X equinumerous f(X) subset.eq NN$
  - Since any subset of $NN$ is countable, $X$ is countable
]

== Infinite Subsets of $NN$

#theorem[
  Any infinite subset $A subset.eq NN$ is equinumerous to $NN$.
]

#proof[
  Construct a bijection $f: NN to A$ recursively:
  - $f(0) = min A$ ~ ($NN$ is well-ordered $=>$ any $A subset.eq NN$ has a least element)
  - $f(n+1) = min(A setminus {f(0), f(1), ..., f(n)})$

  Since $A$ is infinite, $A setminus {f(0), ..., f(n)}$ is always non-empty and has a minimum.

  *Injective:* By construction, all $f(i)$ are distinct.

  *Surjective:* Every $a in A$ eventually becomes the minimum of a remaining set.

  Therefore $f$ is a bijection, so $abs(A) = aleph_0$.
]

#Block(color: yellow)[
  *Key insight:* There's only "one size" of countably infinite set: $aleph_0$.
]

== Enumeration Examples

#example[Finite strings over $Sigma = {a, b}$][
  Enumerate $Sigma^*$ by length, then lexicographically:
  $
    epsilon, a, b, a a, a b, b a, b b, a a a, a a b, dots
  $
  - Length 0: $epsilon$ (1 string)
  - Length 1: $a, b$ (2 strings)
  - Length 2: $a a, a b, b a, b b$ (4 strings)
  - Length $n$: $2^n$ strings

  Since $union.big_(n=0)^infinity 2^n$ is a countable union of finite sets, $Sigma^*$ is countable.
]

#example[Rational numbers][
  List positive fractions $p/q$ by increasing $p + q$, skip non-reduced:
  $
    1/1, 1/2, 2/1, 1/3, 3/1, 1/4, 2/3, 3/2, 4/1, dots
  $

  Include $0$ and negatives by interleaving:
  $
    0, 1/1, -1/1, 1/2, -1/2, 2/1, -2/1, dots
  $
]


= Schröder--Bernstein
#focus-slide()

== Schröder--Bernstein Theorem: Proof

#theorem[
  If injections $f: A to B$ and $g: B to A$ exist, then a bijection $h: A to B$ exists.
]

#proof[
  Let $f : A to B$ and $g : B to A$ be injections.

  We use $g^(-1)$ to denote the inverse of $g$ restricted to its image: for any $a in g(B)$, we write $g^(-1)(a)$ for the unique $b in B$ satisfying $g(b) = a$.

  // TODO: visualize

  *Step 1: Construct auxiliary sets*

  Define inductively the sets $A_n subset.eq A$ and $B_n subset.eq B$ for $n >= 0$ by:
  $
        A_0 & := A without g(B) \
        B_n & := f(A_n) quad    & "for" n >= 0 \
    A_(n+1) & := g(B_n) quad    & "for" n >= 0
  $

  Define $A_infinity subset.eq A$ as the union of all $A_n$: $A_infinity := display(union.big_(n >= 0)) A_n$.

  #colbreak()

  *Step 2: Define the candidate bijection*

  Define $h: A to B$ by:
  $
    h(a) = cases(
      f(a) & "if" a in A_infinity,
      g^(-1)(a) & "if" a notin A_infinity
    )
  $

  *Step 3: Verify $h$ is well-defined*

  For all $a in A$, we need $h(a)$ to be defined:

  - *$a in A_infinity$:* Then $h(a) = f(a)$ is well-defined (since $f: A to B$).

  - *$a notin A_infinity$:* Then $a notin A_0$ (as $A_0 subset.eq A_infinity$), so $a in g(B)$.
    Thus $g^(-1)(a)$ exists and is unique.

  #colbreak()

  *Step 4: Prove the ranges are disjoint*

  We show that $f(A_infinity)$ and $g^(-1)(A without A_infinity)$ are disjoint.

  First, observe that:
  $
    f(A_infinity) = f(union.big_(n >= 0) A_n) = union.big_(n >= 0) f(A_n) = union.big_(n >= 0) B_n
  $

  Now take $a notin A_infinity$ and let $b = g^(-1)(a)$.
  We claim $b notin union.big_(n >= 0) B_n$:
  - Suppose for contradiction that $b in B_n$ for some $n$
  - Then $a = g(b) in g(B_n) = A_(n+1) subset.eq A_infinity$
  - This contradicts $a notin A_infinity$

  Hence $g^(-1)(A without A_infinity) subset.eq B without union.big_(n >= 0) B_n = B without f(A_infinity)$.

  Therefore, the ranges $f(A_infinity)$ and $g^(-1)(A without A_infinity)$ are disjoint.

  #colbreak()

  *Step 5: Prove $h$ is injective*

  Take $a, a' in A$ with $h(a) = h(a')$.
  Consider the cases:

  - *Both in $A_infinity$:*
    Then $f(a) = f(a')$, so $a = a'$ (since $f$ is injective).

  - *Both outside $A_infinity$:*
    Then $g^(-1)(a) = g^(-1)(a')$, so $a = a'$ (since $g$ is injective).

  - *Mixed case* (say $a in A_infinity$, $a' notin A_infinity$):
    Then $h(a) = f(a) in f(A_infinity)$ but $h(a') = g^(-1)(a') in B without f(A_infinity)$.
    By Step 4, these sets are disjoint, contradicting $h(a) = h(a')$.

  Therefore $h$ is injective.

  #colbreak()

  *Step 6: Prove $h$ is surjective*

  Let $b in B$.
  Consider the cases:

  - *$b in f(A_infinity)$:*
    Then $b = f(a)$ for some $a in A_infinity$, so $h(a) = f(a) = b$.

  - *$b notin f(A_infinity)$:*
    Let $a = g(b) in A$.
    We claim $a notin A_infinity$:
    - Suppose for contradiction that $a in A_infinity$
    - Then $a in A_n$ for some $n >= 1$ (as $a = g(b) in g(B)$, but $A_0 = A without g(B)$)
    - So $a in A_n = g(B_(n-1))$, meaning $a = g(b')$ for some $b' in B_(n-1)$
    - Since $g$ is injective and $a = g(b) = g(b')$, we have $b = b' in B_(n-1) subset.eq f(A_infinity)$
    - This contradicts $b notin f(A_infinity)$

    Therefore $a notin A_infinity$, and $h(a) = g^(-1)(a) = g^(-1)(g(b)) = b$.

  Therefore $h$ is surjective.

  *Conclusion:*
  Since $h$ is both injective and surjective, $h$ is a bijection, so $A equinumerous B$.
]


= Large Cardinal Numbers
#focus-slide(
  epigraph: [The essence of mathematics is its freedom.],
  epigraph-author: "Georg Cantor",
)

== Beyond $aleph_0$: Hierarchies of Infinity

We've seen that $aleph_0 = abs(NN)$ is the smallest infinite cardinality.
But are there _larger_ infinities beyond $aleph_0$?

#Block(color: blue)[
  *Cantor* showed that there are _infinitely many_ distinct sizes of infinity, forming an endless hierarchy of ever-growing infinities.
  $
    abs(NN) < abs(RR) < abs(power(RR)) < abs(power(power(RR))) < dots
  $

  This discovery fundamentally changed our understanding of the infinite.
]

Two key hierarchies help us organize these infinities:
- The *$beth$ (beth) numbers* $beth_0, beth_1, beth_2, dots$ --- _constructive hierarchy_ built by repeatedly taking powersets
- The *$aleph$ (aleph) numbers* $aleph_0, aleph_1, aleph_2, dots$ --- _ordinal hierarchy_ indexing all infinite cardinals by their order

== Beth Numbers: The Powerset Hierarchy

#definition[
  The _beth numbers_ (from Hebrew letter ב) form a _constructive_ hierarchy defined recursively using the powerset operation:

  - $beth_0 = aleph_0 = abs(NN)$
    #h(1em) (countable infinity --- the starting point)

  - $beth_(n+1) = 2^(beth_n) = abs(power("set of size" beth_n))$
    #h(1em) (apply powerset operation)

  - $beth_lambda = limits(sup)_(alpha < lambda) beth_alpha$
    #h(1em) (for limit ordinal $lambda$)
]

#Block(color: yellow)[
  *Key insight:*
  Each beth number is the cardinality of the _powerset_ of the previous one.

  This gives us a _concrete, algorithmic_ hierarchy: we know exactly how to construct each level!
]

#note[
  The beth hierarchy is a natural generalization of Cantor's diagonal argument: each step $beth_n to beth_(n+1)$ applies the result that $S smaller power(S)$ for any set $S$.
]

== Examples of Beth Numbers

#example[
  The first few beth numbers:

  #table(
    columns: 3,
    align: (center, left, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Beth*], [*Value*], [*Interpretation*]),
    [$beth_0$], [$aleph_0 = abs(NN)$], [Countable infinity],
    [$beth_1$], [$2^(aleph_0) = abs(power(NN)) = abs(RR) = frak(c)$], [The continuum (real numbers)],
    [$beth_2$], [$2^frak(c) = abs(power(RR))$], [All functions $RR to RR$, all subsets of $RR$],
    [$beth_3$], [$2^(beth_2) = abs(power(power(RR)))$], [All relations on $RR$],
  )
]

#Block(color: blue)[
  By Cantor's theorem, we know $beth_0 < beth_1 < beth_2 < beth_3 < dots$ is a _strictly increasing_ sequence.

  Each powerset operation produces a provably larger infinity!
]

== Aleph Numbers: Indexing All Infinite Cardinals

#definition[
  The _aleph numbers_ (from Hebrew letter א) enumerate *all* infinite cardinal numbers in their _natural order_:
  - $aleph_0 = abs(NN)$ --- the smallest infinite cardinal (countable infinity)

  - $aleph_1$ --- the _next_ infinite cardinal after $aleph_0$ (the smallest uncountable cardinal)
  - $aleph_2$ --- the next infinite cardinal after $aleph_1$
  - In general: $aleph_(alpha+1)$ is the _smallest cardinal strictly larger_ than $aleph_alpha$
]

#Block(color: orange)[
  Unlike beth numbers (defined by powerset), aleph numbers are defined _abstractly_ by their _order_.

  We don't know how to "construct" $aleph_1$ from $aleph_0$ --- we only know it is the "next" cardinal!
]

== Notes on Aleph Hierarchy

#note[
  Each aleph is actually an _initial ordinal_: the smallest ordinal of that cardinality.
  - For example, $aleph_0 = omega$, the first infinite ordinal.
  - $aleph_1 = omega_1$, the first uncountable ordinal.
  - "Intermediate" ordinals like $omega + 1, omega times 2, omega^2, omega^omega, dots$ all have cardinality $aleph_0$.
  This connects cardinality to ordinal number theory.
]

#note[
  The alephs are "ordinal-indexed": $aleph_0, aleph_1, dots, aleph_omega, aleph_(omega+1), dots$
  It extends through all ordinal numbers!
  For a limit ordinal $lambda$:
  $
    aleph_lambda = union.big_(alpha < lambda) aleph_alpha = sup_(alpha < lambda) aleph_alpha
  $
]

== Aleph vs Beth: Two Fundamentally Different Hierarchies

#columns(2)[
  *Beth hierarchy (constructive):*
  - Start: $beth_0 = aleph_0 = abs(NN)$
  - Rule: $beth_(n+1) = 2^(beth_n)$ (powerset)
  - _Algorithmic:_ built by iteration
  - We know _exactly_ what each is
  // - Grows "as fast as possible"

  #colbreak()

  *Aleph hierarchy (ordinal):*
  - Start: $aleph_0 = beth_0 = abs(NN)$
  - Rule: $aleph_(n+1)$ = "next cardinal"
  - _Axiomatic:_ built by well-ordering
  - We know the _order_, not values
  // - Grows "one step at a time"
]

#align(center)[
  #import fletcher: diagram, edge, node
  #diagram(
    spacing: (2em, 2em),
    node-shape: fletcher.shapes.pill,
    node-stroke: 1pt,
    edge-stroke: 1pt,

    // Starting point (both hierarchies agree)
    node((0, 0.5), $aleph_0 = beth_0$, stroke: blue, fill: blue.lighten(80%), name: <start>),

    // Aleph chain (top) - ordinal succession
    node((2, 1), $aleph_1$, stroke: red.darken(20%), fill: red.lighten(80%), name: <a1>),
    node((4, 1), $aleph_2$, stroke: red.darken(20%), fill: red.lighten(80%), name: <a2>),
    node((6, 1), $aleph_3$, stroke: red.darken(20%), fill: red.lighten(80%), name: <a3>),
    node((7, 1), $dots$, stroke: none, shape: fletcher.shapes.circle, name: <adots>),

    // Beth chain (bottom) - powerset iteration
    node((2, 0), $beth_1 = 2^(aleph_0)$, stroke: green.darken(20%), fill: green.lighten(80%), name: <b1>),
    node((4, 0), $beth_2 = 2^(beth_1)$, stroke: green.darken(20%), fill: green.lighten(80%), name: <b2>),
    node((6, 0), $beth_3 = 2^(beth_2)$, stroke: green.darken(20%), fill: green.lighten(80%), name: <b3>),
    node((7, 0), $dots$, stroke: none, shape: fletcher.shapes.circle, name: <bdots>),

    // Edges for aleph chain
    edge(<start>, <a1>, "-}>", label: "successor", label-angle: auto, label-side: right, stroke: red.darken(20%)),
    edge(<a1>, <a2>, "-}>", label: "successor", label-side: right, stroke: red.darken(20%)),
    edge(<a2>, <a3>, "-}>", label: "successor", label-side: right, stroke: red.darken(20%)),
    edge(<a3>, <adots>, "-}>", stroke: red.darken(20%)),

    // Edges for beth chain
    edge(<start>, <b1>, "-}>", label: "powerset", label-angle: auto, label-side: left, stroke: green.darken(20%)),
    edge(<b1>, <b2>, "-}>", label: "powerset", stroke: green.darken(20%), label-side: left),
    edge(<b2>, <b3>, "-}>", label: "powerset", stroke: green.darken(20%), label-side: left),
    edge(<b3>, <bdots>, "-}>", stroke: green.darken(20%)),

    // Question mark between a1 and b1
    edge(
      <a1>,
      <b1>,
      stroke: (paint: gray, thickness: 2pt, dash: "dashed"),
      label: [*?*],
      label-pos: 0.5,
      label-size: 1.5em,
    ),
  )
]

#Block(color: yellow)[
  Both hierarchies start at $aleph_0 = beth_0$, but then _diverge_. \
  The relationship between them is one of the deepest "unsolved" questions in mathematics! \
  *Central question:* Is $aleph_1 = beth_1$? This is the _Continuum Hypothesis_.
]

== The Continuum Hypothesis (CH): Cantor's Great Question

#definition[
  The _Continuum Hypothesis_ (CH) states that there is no infinite cardinal strictly between $aleph_0$ and the cardinality of the continuum:
  $
    aleph_1 = beth_1 = 2^(aleph_0) = abs(RR) = frak(c)
  $
  In other words: _every_ infinite subset of $RR$ is either countable ($aleph_0$) or has the same size as $RR$ ($frak(c)$).
]

#Block(color: teal)[
  *Cantor's lifelong quest (1878--1918):*
  Georg Cantor formulated CH in 1878 and believed it to be true.
  He spent decades trying to prove it, writing:

  _"The question whether there exists a transfinite number that is neither $aleph_0$ nor $2^(aleph_0)$ has tormented me."_

  Despite his genius in discovering the transfinite numbers, Cantor could neither prove nor disprove CH.
  This struggle contributed to his mental health difficulties in later life.
]

#pagebreak()

#example[if CH is true][
  - The real numbers $RR$ have cardinality $aleph_1$ (first uncountable cardinal)
  - Every uncountable subset of $RR$ is equinumerous to $RR$
  - There are "no infinities between" countable and continuum
  - The hierarchies align at the first step: $aleph_1 = beth_1$
  - All "naturally occurring" uncountable sets in analysis have the same size
]

== The Generalized Continuum Hypothesis (GCH)

#definition[
  The _Generalized Continuum Hypothesis_ (GCH) extends CH to all infinite cardinals:

  For every infinite cardinal $kappa$:
  $
    2^kappa = kappa^+
  $
  where $kappa^+$ denotes the _immediate successor cardinal_ after $kappa$.

  This means: $aleph_n = beth_n$ for all ordinals $n$ (finite and transfinite).
]

#Block(color: blue)[
  *What GCH claims:*
  The two hierarchies _completely coincide_ at every level!

  There is only _one_ natural hierarchy of infinite cardinals, and the powerset operation always produces the very next cardinal in the sequence.
]

#pagebreak()

#example[
  Under GCH, we would have:
  - $2^(aleph_0) = aleph_1$ (this is just CH)
  - $2^(aleph_1) = aleph_2$ (powerset gives next cardinal)
  - $2^(aleph_2) = aleph_3$
  - $2^(aleph_omega) = aleph_(omega+1)$
  - And so on for all infinite cardinals...
]

#note[
  GCH provides a "maximally simple" picture of the cardinal hierarchy.
  But is this simplicity true, or is reality more complex?
]

== Hilbert's First Problem

#Block(color: purple)[
  *In 1900, David Hilbert* presented *23 problems* that shaped 20th-century mathematics.

  *Problem #1* was to resolve the Continuum Hypothesis --- showing its fundamental importance.
]

#Block(color: teal)[
  *Early attempts to settle CH:*
  - *Cantor* (1878--1918): Believed CH was true, could not prove it
  - *Hilbert* (1900): Made it the first of his famous problems
  - *Zermelo* (1908): Developed axiomatic set theory (ZF), but CH remained open
  - *Fraenkel* (1922): Extended to ZFC (with Axiom of Choice), CH still unresolved
  - *Gödel* (1940): Proved CH is _consistent_ with ZFC (cannot be disproved)
  - *Cohen* (1963): Proved $not$CH is also consistent --- *breakthrough!*
]

== Cohen's Independence Result (1963)

#theorem[Cohen, 1963][
  The Continuum Hypothesis is _independent_ of ZFC (Zermelo--Fraenkel set theory with the Axiom of Choice):
  - ZFC *cannot prove* CH
  - ZFC *cannot disprove* CH
  - Both "ZFC + CH" and "ZFC + $not$CH" are consistent (assuming ZFC is consistent)
]

#Block(color: orange)[
  *What Cohen proved using _forcing_:*
  The value of $2^(aleph_0)$ is _not determined_ by the axioms of ZFC!

  We can construct models where:
  - $aleph_1 = beth_1 = 2^(aleph_0)$ ~ (CH holds)
  - $aleph_2 = beth_1 = 2^(aleph_0)$ ~ (one intermediate cardinal)
  - $aleph_omega = beth_1 = 2^(aleph_0)$ ~ (countably many intermediate cardinals)
  - $aleph_(omega_1) = beth_1 = 2^(aleph_0)$ ~ (uncountably many intermediate cardinals)
  - Even: $aleph_alpha = beth_1 = 2^(aleph_0)$ for arbitrarily large $alpha$!
]

== The Freedom of Infinity

Different models of ZFC can have wildly different cardinal structures!

#columns(2)[
  *Universe where CH holds:*
  - $aleph_1 = beth_1 = 2^(aleph_0) = abs(RR)$ --- hierarchies align
  - Every subset of $RR$ is either countable ($aleph_0$) or has the same cardinality $frak(c)$
  - No "intermediate" infinities

  #colbreak()

  *Universe where CH fails:*
  - $aleph_1 < 2^(aleph_0) = abs(RR)$ --- hierarchies diverge
  - "Intermediate" infinities exist (between $NN$ and $RR$)
  - $RR$ can be arbitrarily large
  - Much richer structure
]

#Block(color: orange)[
  *Before 1963:* We thought CH must be either true or false.

  *After Cohen:* CH is _independent_ --- both answers are mathematically valid!
]

#Block(color: yellow)[
  *Key insight:*
  There is no single fixed mathematical reality.

  Different axiom systems can give different but equally consistent answers.
]

== What Is Mathematical Truth?

#Block(color: purple)[
  If CH can be neither proved nor disproved, what does it even _mean_ to ask "Is CH true?"
]

Two philosophical perspectives:

#columns(2)[
  *Platonist view:*
  - Mathematical objects exist independently
  - CH _is_ either true or false in reality
  - We just haven't found the "right" axioms yet
  - _Approach:_ Search for natural axioms beyond ZFC (like large cardinal axioms)

  #colbreak()

  *Formalist view:*
  - Mathematics is just symbol manipulation
  - "Truth" depends on which axioms you choose
  - CH is true in some models, false in others
  - _Approach:_ Study all possible models ("multiverse") and their properties
]

== Modern Perspectives on CH

Most mathematicians today take a pragmatic approach:

#Block(color: blue)[
  Instead of asking "Is CH absolutely true?", modern set theory asks more productive questions:
  - In which models of ZFC does CH hold?
  - What interesting mathematics follows from CH? From $not$CH?
  - Do certain "natural" axioms beyond ZFC settle CH?
  - Which axiom systems are most useful for specific areas of mathematics?
]

#note[
  This shift mirrors similar debates in physics: rather than asking if _string theory_ is "The True Theory," physicists ask what predictions it makes and whether it's useful for understanding nature.
]

== Summary: Large Cardinal Numbers

#Block(color: blue)[
  *Two infinite hierarchies with different constructions:*
  - *Beth numbers:* $beth_0 = aleph_0$, $beth_(n+1) = 2^(beth_n)$ --- built step-by-step using powersets
  - *Aleph numbers:* $aleph_0, aleph_1, aleph_2, dots$ --- enumerate all infinite cardinals in order

  Both start at $aleph_0 = beth_0$, but their relationship afterward is _not fixed by ZFC axioms_.
]

#Block(color: orange)[
  *The Continuum Hypothesis:* Does $aleph_1 = 2^(aleph_0)$?
  - *Gödel (1940):* Showed ZFC + CH is consistent
  - *Cohen (1963):* Showed ZFC + $not$CH is also consistent

  *Conclusion:* CH is _independent_ of ZFC.
  The "size" of $RR$ depends on which axioms you choose.
]

#Block(color: teal)[
  *What we learned:*
  Mathematics does not have a unique "reality" --- different axiom systems can give different answers to the same question, yet remain equally consistent.
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

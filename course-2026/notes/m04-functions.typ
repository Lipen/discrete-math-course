// M04 --- Functions: the mathematical formalisation of computation.
#import "common-notes.typ": *
#import "notation.typ": *

= Functions

#chapter-overview[
  Functions are the mathematical abstraction of computation --- they map inputs to outputs with precision and determinism.
  This chapter defines functions as special relations, introduces the fundamental classification (injective, surjective, bijective), develops composition and inversion, and explores the algebraic properties of images and preimages.
  The chapter closes with special functions ubiquitous in discrete mathematics and CS: characteristic functions, floors and ceilings, and the Iverson bracket. ]

== Definitions and Basic Concepts

=== Function as a Relation

#definition[Function][
  A function $f$ from $A$ to $B$, written $f: A -> B$, is a binary relation $f subset.eq A times B$ satisfying: $(a, b_1) in f and (a, b_2) in f imply b_1 = b_2$.
  Each input has exactly one output. ]

#definition[Domain, codomain, image, preimage][
  - *Domain*: $A$ --- the set of valid inputs.
  - *Codomain*: $B$ --- the set of permitted outputs.
  - *Image*: $f(A) = {f(a) mid(|) a in A}$ --- outputs actually produced.
  - For $X subset.eq A$: $f(X) = {f(a) mid(|) a in X}$.
  - For $Y subset.eq B$: $f^(-1)(Y) = {a in A mid(|) f(a) in Y}$.
  - For $b in B$: $f^(-1)(b) = {a in A mid(|) f(a) = b}$ --- a set, not necessarily a singleton.
]

#note[
  $f^(-1)(b)$ is a preimage, always defined as a set.
  It does NOT imply $f$ is invertible. ]

=== Total and Partial Functions

#definition[Total vs partial][
  - *Total function* $f: A -> B$: defined for every $a in A$.
  - *Partial function* $f: A ⇀ B$: defined on a subset of $A$.
]

#example[Partial function][
  $f(x) = 1/x$ is partial on $RR$ (undefined at 0); total on $RR setminus {0}$. ]

#remark[
  Partial functions model computations that may not terminate or throw exceptions.
  The distinction between total and partial functions is the mathematical basis for the halting problem. ]

=== Graph of a Function

The _graph_ of $f: A -> B$ is ${(a, f(a)) mid(|) a in A}$ --- the same as $f$ viewed as a relation.

#note[
  Not every relation is a function.
  A relation $R subset.eq A times B$ is a function iff every $a in A$ appears in at most one pair (partial) or exactly one pair (total). ]


== Injection, Surjection, Bijection

=== Injection (One-to-One)

#definition[Injection][
  $f$ is *injective* if distinct inputs map to distinct outputs: $f(a_1) = f(a_2) arrow a_1 = a_2$, equivalently $a_1 eq.not a_2 imply f(a_1) eq.not f(a_2)$. ]

For finite sets: $|A| <= |B|$.

#example[Injective function][
  $f(x) = 2x + 1$ is injective. $g(x) = x^2$ is not ($g(2) = g(-2) = 4$). ]

#theorem[Left inverse][
  $f$ is injective iff there exists $g: B -> A$ with $g @ f = "id"_A$. ]

#example[Hash collisions][
  A hash function should ideally be injective; in practice, collisions are inevitable (pigeonhole). ]

=== Surjection (Onto)

#definition[Surjection][
  $f$ is *surjective* if every element of $B$ is hit: $forall b in B space exists a in A space f(a) = b$.
  Equivalently: $f(A) = B$. ]

For finite sets: $|A| >= |B|$.

#example[Surjective function][
  $f(x) = x^3$ is surjective on $RR$. $g(x) = e^x$ is not (never reaches 0 or negatives). ]

#theorem[Right inverse][
  $f$ is surjective iff there exists $g: B -> A$ with $f @ g = "id"_B$ (requires axiom of choice). ]

#remark[
  Serialisation is ideally injective; deserialisation is surjective onto valid objects.
  Together they form a bijection between objects and their representations. ]

=== Bijection

#definition[Bijection][
  $f$ is *bijective* if it is both injective and surjective. ]

#theorem[Inverse function][
  $f$ is bijective iff there exists $f^(-1): B -> A$ with $f @ f^(-1) = "id"_B$ and $f^(-1) @ f = "id"_A$.
  For finite sets: $|A| = |B|$. ]

#example[Base64 encoding][
  Base64 encoding is an injection from binary to text; within its image, decoding is the inverse.
  A proper encoding-decoding pair is a bijection. ]

#example[Proving bijectivity: $f(x) = 2x + 1$ on $ZZ$][
  *Injectivity*: $f(a) = f(b)$ $=>$ $2a + 1 = 2b + 1$ $=>$ $2a = 2b$ $=>$ $a = b$. *Surjectivity*: given $y in ZZ$, solve $2x + 1 = y$ $=>$ $x = (y-1)/2$.
  If $y$ is odd ($y = 2k + 1$), $x = k in ZZ$; if $y$ is even, no integer $x$ exists. $f$ restricted to odd codomain is bijective; on $ZZ$ it is injective but not surjective (outputs are odd). $f: ZZ -> {2k+1 mid(|) k in ZZ}$ is a bijection.
  Finding the inverse: $f^(-1)(y) = (y-1)/2$. ]

=== Cardinality Criteria

#proposition[Cardinality classification][
  #table(
    columns: 4,
    align: (center, center, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.4pt) },
    table.header([*Type*], [*Condition*], [*Cardinality*], [*Inverse*]),
    [Injection],
    [$f(a_1) = f(a_2) arrow a_1 = a_2$],
    [$|A| <= |B|$],
    [Left inverse $g @ f = "id"_A$],

    [Surjection],
    [$forall b exists a: f(a) = b$],
    [$|A| >= |B|$],
    [Right inverse $f @ g = "id"_B$],

    [Bijection],
    [Injective + surjective],
    [$|A| = |B|$],
    [Two-sided inverse $f^(-1)$],
  ) ]


== Composition of Functions

#definition[Composition][
  Given $f: A -> B$ and $g: B -> C$, $(g @ f)(a) = g(f(a))$.
  Composition is associative: $h @ (g @ f) = (h @ g) @ f$.
  Not commutative: $g @ f eq.not f @ g$ in general. ]

#theorem[Composition preserves function type][
  Injection @ injection = injection.
  Surjection @ surjection = surjection.
  Bijection @ bijection = bijection. ]

#theorem[Inverse of composition][
  $(g @ f)^(-1) = f^(-1) @ g^(-1)$ --- order reverses. ]

#remark[
  Functional pipelines `x |> f |> g |> h` are composition written left-to-right: $(h @ g @ f)(x)$. ]


== Image and Preimage Algebra

#proposition[Image of union and intersection][
  - $f(A union B) = f(A) union f(B)$.
  - $f(A inter B) subset.eq f(A) inter f(B)$.
    Equality holds if $f$ is injective.
]

#proof[
  First identity: $y in f(A union B)$ iff $exists x in A union B$ with $f(x) = y$ iff $exists x in A$ or $exists x in B$ with $f(x) = y$ iff $y in f(A) union f(B)$.
  Second: $y in f(A inter B)$ $=>$ $exists x in A inter B$ with $f(x) = y$ $=>$ $y in f(A)$ and $y in f(B)$.
  For injective $f$: $y in f(A) inter f(B)$ $=>$ $exists a in A, b in B$ with $f(a) = f(b) = y$ $=>$ $a = b$ (by injectivity) $=>$ $a in A inter B$ $=>$ $y in f(A inter B)$. ]

#proposition[Preimage preserves all operations][
  $f^(-1)(C union D) = f^(-1)(C) union f^(-1)(D)$. $f^(-1)(C inter D) = f^(-1)(C) inter f^(-1)(D)$. $f^(-1)(C setminus D) = f^(-1)(C) setminus f^(-1)(D)$.
  The preimage commutes with all Boolean operations. ]

#proof[
  $x in f^(-1)(C inter D)$ iff $f(x) in C inter D$ iff $f(x) in C$ and $f(x) in D$ iff $x in f^(-1)(C) inter f^(-1)(D)$.
  The other identities follow the same pattern --- replace set operation with its logical counterpart on the membership condition.
  Preimage is a homomorphism from the Boolean algebra of subsets of $B$ to the Boolean algebra of subsets of $A$. ]


== Special Functions

=== Characteristic Function

#definition[Characteristic function][
  For $X subset.eq U$, $chi_X: U -> {0, 1}$: $chi_X(x) = cases(1 space "if" space x in X, 0 space "if" space x in.not X)$. ]

=== Floor and Ceiling

#definition[Floor and ceiling][
  $floor(x)$ = greatest integer $<= x$. $ceil(x)$ = least integer $>= x$. ]

#example[
  $floor(3.7) = 3$, $ceil(3.7) = 4$. $floor(-3.7) = -4$, $ceil(-3.7) = -3$. ]

#remark[
  Binary search makes $floor(log_2 n) + 1$ comparisons.
  Partitioning $n$ items into blocks of size $k$: $ceil(n/k)$ blocks. ]

=== Iverson Bracket

#definition[Iverson bracket][
  $[P] = 1$ if $P$ is true, $0$ otherwise.
  Turns logical conditions into algebraic expressions: $sum_(i=1)^n [i "is even"] = floor(n/2)$. ]

=== Lambda Notation

#definition[Lambda abstraction][
  $lambda x in A dot e(x)$ denotes the function $f: A -> B$ mapping $x$ to $e(x)$.
  Foundation of anonymous functions, closures, and higher-order programming. ]

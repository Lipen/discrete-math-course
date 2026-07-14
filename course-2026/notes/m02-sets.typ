// M02 --- Sets: the universal container for discrete objects.
#import "common-notes.typ": *
#import "notation.typ": *

= Sets

#chapter-overview[
  *Chapter overview.*
  Sets are the most fundamental data structure in mathematics --- every discrete object is built from sets.
  This chapter introduces set notation, operations, and identities, then connects them to their computational counterparts: SQL queries, data types, bitwise operations, and hash functions.
  The language of sets established here underpins relations, functions, and every subsequent chapter.
]

== Definitions and Operations

=== Basic Definitions

A set is an unordered collection of distinct objects.
The objects in a set are its _elements_ (or _members_).
There is no notion of multiplicity or ordering: ${1, 2, 3}$ and ${3, 1, 2}$ are the same set, and ${1, 1, 2}$ is simply ${1, 2}$.

#definition[Set membership][
  $a in A$ means $a$ is an element of $A$.
  $a in.not A$ means $a$ is not an element of $A$.
]

A set can be specified in several ways:

#definition[Set specification][
  + *Enumeration*: list all elements between braces --- ${1, 2, 3, 4}$.
  + *Set-builder notation*: ${x in U mid(|) P(x)}$ --- the set of all $x$ in the universe $U$ satisfying property $P$.
  + *Recursive definition*: base set + generation rules (used later for formal languages, inductive structures).
]

#example[
  ${x in NN mid(|) x < 5} = {0, 1, 2, 3, 4}$.
  ${x in NN mid(|) x "is prime" and x < 10} = {2, 3, 5, 7}$.
]

#definition[Empty set][
  The _empty set_, denoted $nothing$ (or $emptyset$), is the unique set containing no elements.
]

#note[
  $nothing$ and ${nothing}$ are different: the former has zero elements; the latter has one element (the empty set itself).
]

=== Equality and Subsets

#definition[Extensionality][
  Two sets $A$ and $B$ are equal, written $A = B$, iff they have exactly the same elements:
  $A = B$ iff $forall x space (x in A arrow.l.r x in B)$.
]

#definition[Subset][
  + $A subset.eq B$: every element of $A$ is also an element of $B$ --- $forall x space (x in A arrow x in B)$.
  + $A subset B$: $A subset.eq B$ and $A eq.not B$ (proper subset).
]

#theorem[Subset equality][
  $A = B$ if and only if $A subset.eq B$ and $B subset.eq A$.
]

This theorem is the standard technique for proving set equality: show each side is contained in the other.

=== Powerset

#definition[Powerset][
  The _powerset_ of $A$, denoted $cal(P)(A)$ or $2^A$, is the set of all subsets of $A$:
  $cal(P)(A) = {X mid(|) X subset.eq A}$.
]

#theorem[Cardinality of powerset][
  If $A$ is a finite set with $|A| = n$, then $|cal(P)(A)| = 2^n$.
]

#example[
  For $A = {a, b}$, $cal(P)(A) = {nothing, {a}, {b}, {a, b}}$. Indeed $|cal(P)(A)| = 4 = 2^2$.
]

#remark[
  The powerset of ${1, ..., n}$ is in one-to-one correspondence with $n$-bit strings: each subset = a bit mask.
  Bitwise OR is union, AND is intersection, AND-NOT is difference.
]

=== Set Operations

#definition[Set operations][
  For sets $A$ and $B$ (subsets of a universal set $U$):
  + *Union*: $A union B = {x mid(|) x in A or x in B}$.
  + *Intersection*: $A inter B = {x mid(|) x in A and x in B}$.
  + *Difference*: $A setminus B = {x mid(|) x in A and x in.not B}$.
  + *Symmetric difference*: $A symdiff B = (A setminus B) union (B setminus A)$.
  + *Complement*: $overline(A) = U setminus A = {x in U mid(|) x in.not A}$.
]

Two sets are _disjoint_ if $A inter B = nothing$.

#example[
  Let $A = {1, 2, 3}$, $B = {2, 3, 4}$ with $U = {1, 2, 3, 4, 5}$.
  $A union B = {1, 2, 3, 4}$; $A inter B = {2, 3}$; $A setminus B = {1}$; $A symdiff B = {1, 4}$; $overline(A) = {4, 5}$.
]

=== Algebraic Laws

Set operations mirror propositional logic:

#proposition[Set--logic correspondence][
  #table(
    columns: 2,
    align: (left, left),
    table.header([*Set operation*], [*Logical counterpart*]),
    table.hline(),
    [$A union B$], [$x in A or x in B$],
    [$A inter B$], [$x in A and x in B$],
    [$overline(A)$], [$not(x in A)$],
    [$A setminus B$], [$x in A and not(x in B)$],
    [$A symdiff B$], [$x in A xor x in B$],
    [$A subset.eq B$], [$x in A arrow x in B$],
    [$A = B$], [$x in A arrow.l.r x in B$],
  )
]

Every set identity has a dual logical tautology, and vice versa.
This correspondence is a Boolean algebra isomorphism (studied in its own chapter).

#proposition[Laws of set algebra][
  For all sets $A$, $B$, $C$:
  + *Commutativity*: $A union B = B union A$, $A inter B = B inter A$.
  + *Associativity*: $(A union B) union C = A union (B union C)$, $(A inter B) inter C = A inter (B inter C)$.
  + *Distributivity*: $A inter (B union C) = (A inter B) union (A inter C)$, $A union (B inter C) = (A union B) inter (A union C)$.
  + *Idempotence*: $A union A = A$, $A inter A = A$.
  + *Identity*: $A union nothing = A$, $A inter U = A$.
  + *Complement*: $A union overline(A) = U$, $A inter overline(A) = nothing$.
  + *Double complement*: $overline(overline(A)) = A$.
]

#theorem[De Morgan's laws for sets][
  + $overline(A union B) = overline(A) inter overline(B)$.
  + $overline(A inter B) = overline(A) union overline(B)$.
]

#proof[
  First law by mutual inclusion.
  ($subset.eq$): $x in overline(A union B)$ $=>$ $x in.not A union B$ $=>$ $x in.not A$ and $x in.not B$ $=>$ $x in overline(A) inter overline(B)$.
  ($supset.eq$): $x in overline(A) inter overline(B)$ $=>$ $x in.not A$ and $x in.not B$ $=>$ $x in.not A union B$ $=>$ $x in overline(A union B)$.
]

#remark[
  Propositional logic and set algebra are both instances of Boolean algebra --- studied in its own chapter.
]

=== Venn Diagrams

Venn diagrams represent sets as overlapping regions inside a bounding rectangle (the universe $U$).
Effective for up to three sets; beyond that, algebraic reasoning takes over.

#note[
  Venn diagrams are a thinking tool, not a proof technique.
  A proper proof requires algebraic laws or element-chasing.
]

=== Cartesian Product

#definition[Cartesian product][
  $A times B = {(a, b) mid(|) a in A, b in B}$.
  Two ordered pairs $(a, b)$ and $(c, d)$ are equal iff $a = c$ and $b = d$.
]

#theorem[Cardinality of product][
  For finite sets, $|A times B| = |A| dot |B|$.
]

The product is not associative, but there is a canonical bijection, so we write $A times B times C$ and treat elements as tuples.

#definition[n-ary Cartesian product][
  $A_1 times A_2 times ... times A_n = {(a_1, ..., a_n) mid(|) a_i in A_i}$.
  When all $A_i$ are the same set $A$, we write $A^n$.
]

#example[
  $RR^2$ is the Euclidean plane. ${0, 1}^n$ is all $n$-bit strings.
]

#remark[
  A record type is $A times B$. A function of $n$ parameters is $A_1 times ... times A_n arrow R$.
  The Cartesian product underlies every struct, tuple, and parameter list.
]

=== Families and Partitions

#definition[Indexed family][
  ${A_i}_(i in I)$ where each $A_i$ is a set and $I$ is the index set.
  $union.big_(i in I) A_i = {x mid(|) exists i in I space x in A_i}$.
  $inter.big_(i in I) A_i = {x mid(|) forall i in I space x in A_i}$.
]

#definition[Partition][
  A partition of $X$ is a collection of non-empty, pairwise disjoint subsets whose union is $X$.
]

#example[Concrete partition][
  $X = {1, 2, 3, 4, 5, 6}$.
  Partition by parity: ${{1, 3, 5}, {2, 4, 6}}$ --- two parts, pairwise disjoint, union is $X$.
  Partition by remainder mod 3: ${{1, 4}, {2, 5}, {3, 6}}$ --- three parts.
  Each partition defines the equivalence relation "$a$ and $b$ have the same parity" or "$a equiv b (mod 3)$".
]

Partitions are tightly linked to equivalence relations --- explored in the next chapter.

#note[Russell's paradox][
  Not every property defines a set.
  Let $R = {x mid(|) x in.not x}$ --- "the set of all sets that do not contain themselves."
  If $R in R$, then $R in.not R$; if $R in.not R$, then $R in R$ --- contradiction.
  The resolution: axiomatic set theory (ZFC) restricts set formation to avoid self-reference.
  In practice, working within a fixed universal set $U$ avoids the paradox.
]


== Applications

=== Relational Algebra and SQL

A database table is a subset of a Cartesian product.

#definition[Relational algebra operations][
  + *Selection* $sigma_"condition"(R)$: ${t in R mid(|) "condition"(t)}$.
  + *Projection* $pi_"columns"(R)$: keep specified columns.
  + *Union*, *intersection*, *difference*: set operations on tuples.
  + *Cartesian product*: concatenate every row of $R$ with every row of $S$.
]

#example[
  `SELECT DISTINCT Name FROM Employees WHERE Age > 30`
  $=$ ${e."Name" mid(|) e in "Employees", e."Age" > 30}$.
]

#remark[
  SQL is set comprehension with syntactic sugar.
  Every `JOIN` is a Cartesian product with a selection; every `UNION` is a set union.
]

=== Data Types as Sets

#definition[Types as sets][
  + `bool` = ${T, F}$.
  + `uint8` = ${0, ..., 255}$.
  + `string` $subset.eq Sigma^*$ (finite sequences over alphabet $Sigma$).
  + $A -> B$ is the set $B^A$ of all functions from $A$ to $B$.
]

#definition[Sum and product types][
  + *Sum type*: disjoint union --- a value belongs to exactly one branch with a tag.
  + *Product type*: Cartesian product of component types.
]

#example[
  `Option<T>` = ${"None"} union {"Some"(v) mid(|) v in T}$ --- a disjoint union.
  `struct Point { x: f64, y: f64 }` is $RR times RR$.
]

=== Bitmasks

#proposition[Bitmask correspondence][
  For $X, Y subset.eq {1, ..., n}$ encoded as bitmasks:
  $b_(X union Y) = b_X | b_Y$,
  $b_(X inter Y) = b_X & b_Y$,
  $b_(X symdiff Y) = b_X^b_Y$,
  $b_(overline(X)) = tilde.op b_X$.
]

#remark[
  Bitmasks: Unix permissions (rwx = 3 bits), feature flags, graph bitsets, subset enumeration.
]

=== Hashing

A hash function $h: K arrow {0, ..., m-1}$ maps a large key space into fixed-size slots.
By pigeonhole, collisions are inevitable.

#definition[Collision][
  $h(k_1) = h(k_2)$ but $k_1 eq.not k_2$ --- the function is not injective.
]

#note[
  A dictionary (hash map) is a partial function $f subset.eq K times V$.
  Hashing provides efficient implementation of this set-theoretic structure.
]

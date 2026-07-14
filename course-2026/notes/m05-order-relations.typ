// M05 --- Order Relations: ranking, comparing, and structuring discrete objects.
#import "common-notes.typ": *
#import "notation.typ": *

= Order Relations

#chapter-overview[
    *Chapter overview.*
    Order relations capture the idea of "before and after" --- they rank elements, define hierarchies, and provide the structure needed to sort, schedule, and optimise.
    This chapter introduces partial orders, their visualisation via Hasse diagrams, and the key notions of extremal elements, bounds, and lattices.
    The chapter closes with lexicographic orders, topological sorting, and real-world applications from type systems to distributed computing.
]

== Partial Orders

=== Definitions

#definition[Partial order][
    A binary relation $prec.eq$ on $A$ is a *partial order* if it is reflexive, antisymmetric, and transitive.
    The pair $(A, prec.eq)$ is a *poset*.
]

#definition[Strict order][
    A *strict order* $<$ is irreflexive, asymmetric, and transitive.
    Given $prec.eq$, define $a < b$ iff $a prec.eq b$ and $a eq.not b$.
    Given $<$, define $a prec.eq b$ iff $a < b$ or $a = b$.
]

#definition[Total order][
    A *total order* is a partial order where every pair is comparable: $forall a eq.not b$, either $a prec.eq b$ or $b prec.eq a$.
]

#example[
    $(NN, <=)$ and $(RR, <=)$ are total.
    Divisibility $a | b$ on $NN^+$ is partial: 2 and 3 are incomparable.
    $(cal(P)({1, 2, 3}), subset.eq)$ is partial: ${1}$ and ${2}$ are incomparable.
]

#note[
    "Partial" means some pairs may be incomparable --- neither $a prec.eq b$ nor $b prec.eq a$.
    This is what makes orders useful for modelling dependencies, where some tasks are independent.
]

=== Hasse Diagrams

#definition[Hasse diagram][
    To draw the Hasse diagram of a finite poset $(A, prec.eq)$:
    1. Remove self-loops (reflexivity implicit).
    2. Remove edges implied by transitivity.
    3. Place $a$ lower than $b$ when $a < b$.
    4. Draw undirected lines --- direction implied by vertical position.
]

#example[
    The divisor poset on ${1, 2, 3, 4, 6, 12}$ ordered by $a | b$:
    1 at bottom, 12 at top, 2 and 3 above 1, 4 and 6 above them, 12 connected to 4 and 6.
]

#example[
    For $(cal(P)({1, 2, 3}), subset.eq)$, the Hasse diagram is a cube (3D Boolean lattice).
]

=== Extremal Elements

#definition[Minimal, maximal, least, greatest][
    + $m$ is *minimal* if no element is strictly smaller: $not(exists a space a < m)$.
    + $m$ is *maximal* if no element is strictly larger: $not(exists a space m < a)$.
    + $m$ is the *least element* if $m prec.eq a$ for all $a$ (unique when exists, also minimal).
    + $m$ is the *greatest element* if $a prec.eq m$ for all $a$ (unique when exists, also maximal).
]

#note[
    Minimal elements can be multiple (incomparable "bottom-most").
    In a finite poset, minimal and maximal elements always exist; least and greatest may not.
]

#example[
    In $({2, 3, 4, 6, 12}, |)$: minimal = ${2, 3}$, maximal = ${12}$, least = none, greatest = 12.
]

=== Bounds, Supremum, Infimum

#definition[Bounds][
    Let $(A, prec.eq)$ be a poset and $S subset.eq A$.
    + $u$ is an *upper bound* of $S$ if $s prec.eq u$ for all $s in S$.
    + $l$ is a *lower bound* of $S$ if $l prec.eq s$ for all $s in S$.
]

#definition[Supremum and infimum][
    + The *supremum* (sup, join $or$) is the _least_ upper bound.
    + The *infimum* (inf, meet $and$) is the _greatest_ lower bound.
    For a pair ${a, b}$: $a or b$ (join), $a and b$ (meet).
]

Suprema and infima are unique when they exist; they need not exist in an arbitrary poset.

=== Lattices

#definition[Lattice][
    A poset is a *lattice* if every pair has both a supremum and an infimum.
]

#example[
    $(cal(P)(A), subset.eq)$: join = $union$, meet = $inter$.
    $(NN^+, |)$: join = lcm, meet = gcd.
]

#definition[Distributive lattice][
    A lattice is *distributive* if $a and (b or c) = (a and b) or (a and c)$.
    A *Boolean algebra* is a distributive lattice with 0, 1, and complement $overline(a)$.
]

#note[
    Propositional logic, set algebra, and Boolean algebra are the same structure --- a complemented distributive lattice.
    This unification is studied in the Boolean algebra chapter.
]

#proposition[Modular lattices][
    A lattice is *modular* if $a prec.eq c$ implies $a or (b and c) = (a or b) and c$.
    Every distributive lattice is modular.
    Modular lattices (Dedekind algebras) arise in the study of normal subgroups and ring ideals.
]

=== Lexicographic Order

#definition[Lexicographic order][
    On $A times B$: $(a_1, b_1) <_"lex" (a_2, b_2)$ iff $a_1 < a_2$, or $a_1 = a_2$ and $b_1 < b_2$.
    Extends to $n$-tuples and strings.
    Total whenever component orders are total.
]

=== Topological Sorting

#definition[Topological sort][
    A *topological sort* of a finite poset $(A, prec.eq)$ is a total order $<=$ such that $a prec.eq b arrow a <= b$.
]

#theorem[Existence][
    Every finite poset has at least one topological sort.
]

#proof-sketch[
    Repeatedly pick a minimal element, output it, remove it, recurse.
]

#remark[
    *Build systems* (Make, Gradle): modules partially ordered by dependencies; any topological sort is a valid build order.
    *Task scheduling*: jobs with precedence constraints form a poset.
    *Compiler instruction scheduling*: instructions partially ordered by data dependencies.
]

== Applications of Orders

#remark[
    *Type hierarchies (OOP)*: subclassing is a partial order on types.
    `Dog <: Animal`, `Cat <: Animal` --- `Dog` and `Cat` are incomparable.
    Multiple inheritance introduces joins (least common supertype).

    *Versioning*: semantic versioning is not a total order --- versions on different major branches are incomparable in compatibility.

    *Distributed systems*: Lamport's happens-before ($arrow$) is a partial order on events.
    Concurrent events ($a not(arrow) b$ and $b not(arrow) a$) are incomparable --- capturing causality without synchronised clocks.
]

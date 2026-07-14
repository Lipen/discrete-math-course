// M11 --- Transfinite: counting beyond the finite.
#import "common-notes.typ": *
#import "notation.typ": *

= Transfinite Overview

#chapter-overview[
  How big is infinity?
  This chapter introduces cardinality as the rigorous measure of set size, proves that some infinities are larger than others (Cantor's diagonal argument), and sketches the landscape beyond: ordinals, the Continuum Hypothesis, and the Axiom of Choice.
  The treatment is conceptual --- the goal is to appreciate the structure of the infinite, not to master axiomatic set theory.
]

== Cardinality

=== Equinumerosity

#definition[Equinumerosity][
  $|A| = |B|$ if there exists a bijection $f: A -> B$.
  A set is *finite* if equinumerous with ${1, ..., n}$ for some $n in NN$; otherwise *infinite*.
]

#definition[Countable and uncountable][
  - $A$ is *countable* if finite or equinumerous with $NN$.
  - $A$ is *uncountable* if infinite but not countable.
]

=== Countable Sets

#theorem[$ZZ$ and $QQ$ are countable][
  - $ZZ$: bijection $0, 1, -1, 2, -2, ...$ given by $f(n) =$ if $n$ even: $n/2$, if $n$ odd: $-(n+1)/2$.
  - $QQ$: list fractions $p/q$ in reduced form by $|p| + q$ (height), then within each height by numerator.
  Height 1: $0/1$.
  Height 2: $-1/1$, $1/1$.
  Height 3: $-2/1$, $-1/2$, $1/2$, $2/1$.
  And so on.
  This is Cantor's first diagonal argument --- enumerate all pairs $(p, q)$ and skip non-reduced fractions.
]

#note[
  $QQ$ is dense (between any two rationals there is another), yet it is "the same size" as $NN$.
  Cardinality disregards topology --- a profound conceptual shift.
]

=== Uncountability of $RR$

#theorem[Cantor's diagonal argument][
  $RR$ is uncountable.
]

#proof[
  Show $(0, 1)$ is uncountable.

  Suppose $r_1, r_2, ...$ enumerates all reals in $(0, 1)$ in decimal:
  $r_1 = 0.d_(11) d_(12) d_(13) ...$
  $r_2 = 0.d_(21) d_(22) d_(23) ...$

  Construct $r = 0.e_1 e_2 e_3 ...$ where $e_i = 4$ if $d_(i i) eq.not 4$, else $e_i = 5$.
  Then $r$ differs from $r_i$ at the $i$-th digit, so $r$ is not in the list.
  Contradiction.
  Therefore $(0, 1)$ is uncountable.
]

#corollary[Cantor's theorem][
  $|A| < |cal(P)(A)|$ for any set $A$.
]

#proof[
  Define $D = {a in A mid(|) a in.not f(a)}$.
  If $D = f(d)$ for some $d in A$, then $d in D$ iff $d in.not D$, a contradiction.
  Hence $f$ is not surjective.
  Since $f$ was arbitrary, no surjection $A -> cal(P)(A)$ exists, so $|A| < |cal(P)(A)|$.
]

=== The Continuum Hypothesis

#definition[Cardinal numbers][
  $|NN| = aleph_0$.
  $|RR| = |cal(P)(NN))| = 2^(aleph_0)$.
]

Cantor's question: is there a set $A$ with $aleph_0 < |A| < 2^(aleph_0)$?
The *Continuum Hypothesis* (CH): no such set exists --- $2^(aleph_0) = aleph_1$.

#note[
  CH is independent of ZFC: Gödel (1940) proved it consistent; Cohen (1963) proved its negation consistent.
  CH is neither provable nor disprovable in standard set theory --- a genuine choice about the nature of sets.
]


#remark[Cardinal arithmetic][
  - $aleph_0 + aleph_0 = aleph_0$: two countably infinite sets together are still countable.
  - $aleph_0 dot aleph_0 = aleph_0$: countably many countable sets (e.g., $NN times NN$) are still countable.
  - $2^(aleph_0) = |RR|$: the power set of $NN$ has the cardinality of the continuum.
  - Under AC, cardinal addition and multiplication are trivial for infinite cardinals: $kappa + lambda = kappa dot lambda = max(kappa, lambda)$.
    Cardinal exponentiation is the interesting operation (Cantor's theorem, CH, Easton's theorem).
]

== Ordinals and the Axiom of Choice

=== Ordinals (Idea)

#note[
  Cardinals measure "how many"; ordinals measure "in what order."
]

#definition[Ordinal --- informal][
  An *ordinal* is the order type of a well-ordered set.
  Finite ordinals: $0, 1, 2, ...$.
  First infinite ordinal: $omega$ (order type of $NN$).
  Then $omega+1$, $omega+2$, ..., $omega dot 2$, ..., $omega^2$, ..., $omega^omega$, ...
]

#note[
  Ordinals generalise counting beyond the finite --- they are the foundation of transfinite induction.
]

#definition[Ordinal arithmetic --- informal][
  - *Successor*: $alpha + 1$ is the next ordinal after $alpha$ (like $omega + 1$ --- "infinity and then one more").
  - *Limit ordinals*: ordinals with no immediate predecessor, such as $omega$, $omega dot 2$, $omega^2$.
  - *Addition*: $1 + omega = omega$ (one then infinitely many = just infinitely many), $omega + 1 > omega$ (infinitely many then one more).\ Addition is not commutative.
  - *Multiplication*: $omega dot 2 = omega + omega$ (infinitely many, then infinitely many again). $2 dot omega = omega$ (two, repeated infinitely = just $omega$).\ Not commutative either.
]

#remark[Transfinite induction][
  To prove $forall alpha$ a property holds:
  1. Base: prove for $alpha = 0$.
  2. Successor step: if holds for $alpha$, prove for $alpha + 1$.
  3. Limit step: if holds for all $beta < lambda$ ($lambda$ a limit ordinal), prove for $lambda$.
  Transfinite induction is essential for proving results about well-orderings, ordinals, and in set theory.
]

=== Axiom of Choice

#definition[Axiom of Choice (AC)][
  For any family ${A_i}_(i in I)$ of non-empty sets, $product A_i eq.not nothing$ --- there exists a choice function selecting one element from each set.
]

#note[
  AC is independent of ZF --- it is neither provable nor refutable from the other axioms of set theory.
]

#proposition[Equivalents of AC][
  - *Zorn's Lemma*: if every chain in a poset has an upper bound, the poset has a maximal element.
  - *Well-Ordering Theorem*: every set can be well-ordered.
  - *Every vector space has a basis*.
  - *Tychonoff's theorem* (product of compact spaces is compact).
]

#remark[
  AC is non-constructive --- it asserts existence without providing a construction.
  Historically controversial (Zermelo, 1904); now accepted by the vast majority of mathematicians.
  The interesting question is not "is AC true?" but "what happens with and without it?"
]

=== The Banach-Tarski Paradox

#proposition[Banach-Tarski][
  Using AC, a solid ball in $RR^3$ can be decomposed into finitely many pieces and reassembled (by rotations and translations) into two solid balls, each identical to the original.
]

#remark[
  This is not a contradiction --- the pieces are non-measurable (no well-defined volume).
  AC enables constructions beyond physical intuition without breaking logical consistency.
]

#note[
  The transfinite is the mathematical basis for:
  - Existence of maximal ideals (Zorn's Lemma).
  - Hahn-Banach theorem in functional analysis.
  - Compactness theorem in model theory.
  The infinite, properly handled, is as rigorous as the finite.
]

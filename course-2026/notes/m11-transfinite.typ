// M11 --- Transfinite: counting beyond the finite.
#import "common-notes.typ": *
#import "notation.typ": *

= Transfinite Overview

#chapter-overview[
    *Chapter overview.*
    How big is infinity?
    This chapter introduces cardinality as the rigorous measure of set size, proves that some infinities are larger than others (Cantor's diagonal argument), and sketches the landscape beyond: ordinals, the Continuum Hypothesis, and the Axiom of Choice.
    The treatment is conceptual --- the goal is to appreciate the structure of the infinite, not to master axiomatic set theory.
]

== Cardinality

=== Equinumerosity

#definition[Equinumerosity][
    $|A| = |B|$ if there exists a bijection $f: A arrow B$.
    A set is *finite* if equinumerous with ${1, ..., n}$ for some $n in NN$; otherwise *infinite*.
]

#definition[Countable and uncountable][
    + $A$ is *countable* if finite or equinumerous with $NN$.
    + $A$ is *uncountable* if infinite but not countable.
]

=== Countable Sets

#theorem[$ZZ$ and $QQ$ are countable][
    + $ZZ$: bijection $0, 1, -1, 2, -2, ...$.
    + $QQ$: enumerate fractions $p/q$ diagonally (numerator × denominator grid), skip duplicates.
]

#note[
    $QQ$ is dense (between any two rationals there is another), yet it is "the same size" as $NN$.
    Cardinality disregards topology.
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
    $r$ differs from $r_i$ at digit $i$ --- not in the list. Contradiction.
    The list cannot be complete; $(0, 1)$ is uncountable.
]

#corollary[Cantor's theorem][
    $|A| < |cal(P)(A)|$ for any set $A$.
]

#proof[
    Define $D = {a in A mid(|) a in.not f(a)}$.
    If $D = f(d)$, then $d in D$ iff $d in.not D$ --- contradiction.
    No surjection $A arrow cal(P)(A)$ exists.
]

=== The Continuum Hypothesis

#definition[Cardinal numbers][
    $|NN| = aleph_0$. $|RR| = |cal(P)(NN))| = 2^(aleph_0)$.
]

Cantor's question: is there a set $A$ with $aleph_0 < |A| < 2^(aleph_0)$?
The *Continuum Hypothesis* (CH): no such set exists --- $2^(aleph_0) = aleph_1$.

#note[
    CH is independent of ZFC: Gödel (1940) proved it consistent; Cohen (1963) proved its negation consistent.
    CH is neither provable nor disprovable in standard set theory --- a genuine choice about the nature of sets.
]


== Ordinals and the Axiom of Choice

=== Ordinals (Idea)

Cardinals measure "how many"; ordinals measure "in what order":

#definition[Ordinal --- informal][
    An *ordinal* is the order type of a well-ordered set.
    Finite ordinals: $0, 1, 2, ...$.
    First infinite ordinal: $omega$ (order type of $NN$).
    Then $omega+1$, $omega+2$, ..., $omega dot 2$, ..., $omega^2$, ..., $omega^omega$, ...
]

Ordinals generalise counting beyond the finite --- they are the foundation of transfinite induction.

=== Axiom of Choice

#definition[Axiom of Choice (AC)][
    For any family ${A_i}_(i in I)$ of non-empty sets, $product A_i eq.not nothing$ --- there exists a choice function selecting one element from each set.
]

AC is independent of ZF. Equivalent formulations:

#proposition[Equivalents of AC][
    + *Zorn's Lemma*: if every chain in a poset has an upper bound, the poset has a maximal element.
    + *Well-Ordering Theorem*: every set can be well-ordered.
    + *Every vector space has a basis*.
    + *Tychonoff's theorem* (product of compact spaces is compact).
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

This is not a contradiction --- the pieces are non-measurable (no well-defined volume).
AC enables constructions beyond physical intuition without breaking logical consistency.

#note[
    The transfinite is the mathematical basis for:
    + Existence of maximal ideals (Zorn's Lemma).
    + Hahn-Banach theorem in functional analysis.
    + Compactness theorem in model theory.
    The infinite, properly handled, is as rigorous as the finite.
]

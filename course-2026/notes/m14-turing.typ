// M14 --- Turing Machines and Undecidability: the limits of computation.
#import "common-notes.typ": *
#import "notation.typ": *

= Turing Machines and Undecidability

#chapter-overview[
    *Chapter overview.*
    The Turing machine is the mathematical definition of "algorithm" --- it captures what it means to compute.
    This chapter defines Turing machines, proves the existence of undecidable problems (the Halting Problem), develops the technique of reduction, and presents Rice's theorem: any non-trivial semantic property of programs is undecidable.
    There are well-defined problems that no computer can ever solve.
]

== Turing Machines

=== Definition

#definition[Turing machine][
    $M = (Q, Gamma, Sigma, delta, q_0, q_"accept", q_"reject")$:
    + $Q$: finite states.
    + $Gamma$: tape alphabet (includes blank $Blank$).
    + $Sigma subset.eq Gamma setminus {Blank}$: input alphabet.
    + $delta: Q times Gamma arrow Q times Gamma times {L, R}$: partial transition function.
]

Infinite tape (both directions), one head. One step: read symbol, write symbol, move L/R, change state.

#definition[Configuration][
    $u q v$: tape content $u v$, head at first symbol of $v$, state $q$.
    Start: $q_0 w$. Accept: reach $q_"accept"$. Reject: reach $q_"reject"$. Loop: never halt.
]

#definition[Recognisable vs decidable][
    + $L$ is *recognisable* (r.e.): some TM accepts exactly $L$ (may loop on $w in.not L$).
    + $L$ is *decidable* (recursive): some TM always halts and accepts iff $w in L$.
]

Decidable → recognisable. $L$ decidable iff both $L$ and $overline(L)$ are recognisable.

=== Examples and Robustness

#example[
    + Increment binary, copy string, recognise ${0^n 1^n}$.
    + Multi-tape TMs: equivalent to single-tape (quadratic slowdown).
    + Nondeterministic TMs: equivalent to deterministic.
    All reasonable variants define the same class of computable functions.
]

=== Church-Turing Thesis

#proposition[Church-Turing thesis][
    Every intuitively computable function can be computed by a Turing machine.
    Not a theorem (notion of "intuitively computable" is informal) but an empirical fact: all proposed formalisations (lambda calculus, recursive functions, register machines) are equivalent.
]

=== Universal Turing Machine

#theorem[Universal TM][
    There exists a TM $U$ that, given encoding $chevron.l M chevron.r$ of TM $M$ and input $w$, simulates $M$ on $w$.
    $U$ is the mathematical precursor of the stored-program computer (von Neumann).
]

== The Halting Problem

#definition[Halting problem][
    $italic("HALT") = {chevron.l M chevron.r w mid(|) M "halts on" w}$.
]

#theorem[Undecidability of HALT][
    $italic("HALT")$ is undecidable.
]

#proof[
    Suppose $H$ decides HALT. Construct $D$: on input $chevron.l M chevron.r$, run $H$ on $chevron.l M chevron.r chevron.l M chevron.r$. If $H$ says "halt", $D$ loops; if "loop", $D$ halts.
    Run $D$ on $chevron.l D chevron.r$: $D$ halts iff $H$ says $D$ loops --- contradiction.
    Diagonal argument --- same pattern as Cantor and Russell.
]

#note[
    HALT is recognisable (simulate and accept if it halts) but not decidable.
    $overline(italic("HALT"))$ is not even recognisable.
]

== Reductions

#definition[Many-one reduction][
    $A #mreduce B$: exists computable $f$ s.t. $w in A$ iff $f(w) in B$.
]

#proposition[Using reductions][
    + $A #mreduce B$ and $B$ decidable → $A$ decidable.
    + $A #mreduce B$ and $A$ undecidable → $B$ undecidable.
]

#example[Undecidable via reduction][
    + *Emptiness*: $E_"TM" = {chevron.l M chevron.r mid(|) L(M) = nothing}$ --- undecidable.
    + *Totality*: does $M$ halt on every input? Undecidable.
    + *Equivalence*: $L(M_1) = L(M_2)$? Undecidable.
]

== Rice's Theorem

#theorem[Rice's theorem][
    Let $P$ be any non-trivial property of recognisable languages (depends only on $L(M)$, not on machine description; true for some but not all TMs).
    Then ${chevron.l M chevron.r mid(|) P(L(M))}$ is undecidable.
]

#proof-sketch[
    Reduce HALT to $P$. Construct $M'$ that simulates $M$ on $w$; if $M$ halts, $M'$ behaves like a fixed machine with/without property $P$.
    $P(L(M'))$ holds iff $M$ halts on $w$.
]

#example[Undecidable properties][
    Is $L(M)$ empty? Finite? Regular? Context-free? $= Sigma^*$?
    The only decidable properties are the trivial ones (always true / always false).
]

#remark[
    Rice's theorem explains why no perfect static analyser exists.
    Any interesting behavioural property of programs is undecidable.
    Practical tools are *conservative*: sound but incomplete, or complete but unsound.
]

== Beyond Turing Machines

#definition[Oracle TM][
    TM with access to an oracle that answers membership queries in one step.
    Formalises *relative computability*.
]

#proposition[Arithmetic hierarchy][
    $Sigma_1$ = recognisable (HALT is $Sigma_1$-complete).
    $Pi_1$ = co-recognisable.
    Hierarchy extends: $Sigma_n$, $Pi_n$, $Delta_n$ --- problems requiring $n$ quantifier alternations.
    HALT is just one rung on an infinite ladder of undecidability.
]

#note[
    Only countably many TMs exist → almost all languages (uncountably many) are undecidable.
    Undecidability is the norm, not the exception.
    Computation is a small island in a vast sea of uncomputability.
]

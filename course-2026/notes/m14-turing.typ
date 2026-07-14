// M14 --- Turing Machines and Undecidability: the limits of computation.
#import "common-notes.typ": *
#import "notation.typ": *

= Turing Machines and Undecidability

#chapter-overview[
  The Turing machine is the mathematical definition of "algorithm" --- it captures what it means to compute.
  This chapter defines Turing machines, proves the existence of undecidable problems (the Halting Problem), develops the technique of reduction, and presents Rice's theorem: any non-trivial semantic property of programs is undecidable.
  There are well-defined problems that no computer can ever solve.
]

== Turing Machines

=== Turing Machine Definition

#definition[Turing machine][
  $M = (Q, Gamma, Sigma, delta, q_0, q_"accept", q_"reject")$:
  - $Q$: finite states.
  - $Gamma$: tape alphabet (includes blank $Blank$).
  - $Sigma subset.eq Gamma setminus {Blank}$: input alphabet.
  - $delta: Q times Gamma -> Q times Gamma times {L, R}$: partial transition function.
]

Infinite tape (both directions), one head. One step: read symbol, write symbol, move L/R, change state.

#definition[Configuration][
  $u q v$: tape content $u v$, head at first symbol of $v$, state $q$.
  Start: $q_0 w$. Accept: reach $q_"accept"$. Reject: reach $q_"reject"$. Loop: never halt.
]

#definition[Recognisable vs decidable][
  - $L$ is *recognisable* (r.e.): some TM accepts exactly $L$ (may loop on $w in.not L$).
  - $L$ is *decidable* (recursive): some TM always halts and accepts iff $w in L$.
]

Decidable → recognisable. $L$ decidable iff both $L$ and $overline(L)$ are recognisable.

=== Robustness and Variants

#example[TM for ${0^n 1^n mid(|) n >= 0}$][
  Strategy: cross off one 0 at the left, one 1 at the right, repeat.
  States: $q_0$ (seek first 0), $q_1$ (seek right end), $q_2$ (seek first 1 from right), $q_3$ (return to left), $q_"accept"$, $q_"reject"$.
  Typical run on 0011:
  1. $q_0$: read 0, write X, move R to $q_1$.
  2. $q_1$: skip 0 and 1, reach blank, move L to $q_2$.
  3. $q_2$: read 1, write X, move L to $q_3$.
  4. $q_3$: skip back to first X, move R to $q_0$.
  Repeat: 0X11 → XX11 → ... → XXXX → accept.
  If a 0 is found after a 1, reject. If 1's run out before 0's, reject.
]

#remark[
  Multi-tape TMs are equivalent to single-tape (quadratic slowdown).
  Nondeterministic TMs are equivalent to deterministic (exponential slowdown via dovetailing).
  Two-stack machines, counter machines, register machines --- all equivalent.
  All "reasonable" computational models define the same class of computable functions.
  This is the empirical evidence for the Church-Turing thesis.
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

#theorem[Undecidability of halting problem][
  $italic("HALT")$ is undecidable.
]

#proof[
  Suppose $H$ decides HALT. Construct $D$: on input $chevron.l M chevron.r$, run $H$ on $chevron.l M chevron.r chevron.l M chevron.r$. If $H$ says "halt", $D$ loops; if "loop", $D$ halts.
  Run $D$ on $chevron.l D chevron.r$: $D$ halts iff $H$ says $D$ loops --- contradiction.
  Diagonal argument --- same pattern as Cantor and Russell.
]

#note[
  - HALT is recognisable (simulate and accept if it halts) but not decidable.

  - $overline(italic("HALT"))$ is not even recognisable.
]

== Reductions

#definition[Many-one reduction][
  $A #mreduce B$: exists computable $f$ s.t. $w in A$ iff $f(w) in B$.
]

#proposition[Using reductions][
  - $A #mreduce B$ and $B$ decidable → $A$ decidable.
  - $A #mreduce B$ and $A$ undecidable → $B$ undecidable.
]

#example[Reduction: HALT to Emptiness][
  Show $E_"TM" = {chevron.l M chevron.r mid(|) L(M) = nothing}$ is undecidable.
  Assume $E$ decides $E_"TM"$. Construct decider $H$ for HALT on input $chevron.l M chevron.r w$:
  1. Build $M'$: on any input, ignore it, simulate $M$ on $w$, accept iff $M$ halts on $w$.
    $L(M') =$ all strings (if $M$ halts on $w$), or $nothing$ (if $M$ loops on $w$).
  2. Feed $chevron.l M' chevron.r$ to $E$.
  3. If $E$ accepts ($L(M') = nothing$): $M$ loops → reject.
    If $E$ rejects ($L(M') eq.not nothing$): $M$ halts → accept.
  Thus HALT decidable --- contradiction. Therefore $E_"TM"$ is undecidable.
]

#example[Undecidable via reduction][
  - *Totality*: does $M$ halt on every input? Undecidable.\
    Reduce HALT: $M'$ ignores its own input, simulates $M$ on $w$; $M'$ is total iff $M$ halts on $w$.

  - *Equivalence*: $L(M_1) = L(M_2)$? Undecidable.\
    Even checking $L(M) = nothing$ (a special case) is undecidable.

  - *Regularity*: is $L(M)$ a regular language? Undecidable.
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

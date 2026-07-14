// M13 --- Finite Automata and Regular Languages: the simplest computational model.
#import "common-notes.typ": *
#import "notation.typ": *

= Finite Automata and Regular Languages

#chapter-overview[
  *Chapter overview.*
  Finite automata are the simplest model of computation --- machines with fixed finite memory that read input once, left to right.
  Despite their simplicity, they define exactly the regular languages, ubiquitous in programming: every regex search, every lexer, every input validator.
  This chapter covers DFA, NFA, their equivalence, regular expressions, the Pumping Lemma, and DFA minimisation.
]

== Deterministic Finite Automata (DFA)

=== Definition

#definition[DFA][
  $M = (Q, Sigma, delta, q_0, F)$:
  + $Q$: finite set of states.
  + $Sigma$: finite alphabet.
  + $delta: Q times Sigma arrow Q$: transition function (total).
  + $q_0 in Q$: start state.
  + $F subset.eq Q$: accepting states.
]

Extended transition: $hat(delta)(q, epsilon) = q$, $hat(delta)(q, a w) = hat(delta)(delta(q, a), w)$.
Language: $L(M) = {w in Sigma^* mid(|) hat(delta)(q_0, w) in F}$.

#example[
  DFA for strings over ${0, 1}$ ending with $"01"$: states $q_0$ (no match), $q_1$ (ends in 0), $q_2$ (ends in 01, accepting).
]

=== Closure Properties

#proposition[Boolean closure][
  Given DFAs for $L_1$, $L_2$, construct DFAs via product automaton:
  + *Union*: $F = (F_1 times Q_2) union (Q_1 times F_2)$.
  + *Intersection*: $F = F_1 times F_2$.
  + *Complement*: swap $F$ and $Q setminus F$ (requires total $delta$).
]

== Nondeterministic Finite Automata (NFA)

#definition[NFA][
  $delta: Q times (Sigma union {epsilon}) arrow cal(P)(Q)$.
  From a state on a symbol (or spontaneously via $epsilon$), the machine may transition to *any* of several states --- nondeterministic "guessing."
]

A string is accepted if *there exists* a path from $q_0$ to some accepting state.

#example[
  NFA for "third-to-last symbol is 1": guesses when it is 3 symbols from end, then checks. 4 states; minimal DFA needs $2^3 = 8$.
]

=== Subset Construction (NFA → DFA)

#theorem[Equivalence of DFA and NFA][
  For every NFA, there exists a DFA recognising the same language.
]

#proof[
  DFA states = $cal(P)(Q)$ (subsets of NFA states).
  Start: $epsilon$-closure(${q_0}$).
  Transition: $delta'(S, a) = epsilon$-closure($union.big_(q in S) delta(q, a)$).
  Accepting: $F' = {S mid(|) S inter F eq.not nothing}$.
  Exponential blowup possible ($2^n$ states from $n$-state NFA) --- worst-case unavoidable.
]

#proposition[DFA vs NFA --- comparison][
  #table(
    columns: 3,
    align: (left, left, left),
    stroke: (x, y) => if y == 0 { (top: 0.8pt, bottom: 0.4pt) },
    table.header([*Property*], [*DFA*], [*NFA*]),
    [Transition],
    [$delta(q, a)$ = single state],
    [$delta(q, a)$ = set of states],

    [$epsilon$-transitions], [Not allowed], [Allowed (spontaneous)],
    [States required], [Potentially exponential], [Often linear / polynomial],
    [Acceptance], [Unique computation path], [Some path leads to accept],
    [Implementation],
    [Table-driven, simple loop],
    [Backtracking or subset simulation],

    [Design difficulty],
    [Harder (explicitly handle all cases)],
    [Easier (nondeterminism helps)],

    [Complement], [Trivial (swap F)], [Require determinisation first],
  )
]

== Regular Expressions

#definition[Regular expression][
  Over $Sigma$:
  + $nothing$: empty language.
  + $epsilon$: ${epsilon}$.
  + $a$ ($a in Sigma$): ${a}$.
  + $R_1 | R_2$: $L(R_1) union L(R_2)$.
  + $R_1 R_2$: ${u v mid(|) u in L(R_1), v in L(R_2)}$.
  + $R^*$: zero or more repetitions.
  Precedence: $* >$ concatenation $> |$.
]

#theorem[Kleene's theorem][
  A language is regular (recognised by DFA/NFA) iff it can be described by a regular expression.
]

Proof: RE → NFA by structural induction; DFA → RE by state elimination.

#proposition[Closure properties][
  Regular languages are closed under:
  + Boolean operations: union, intersection, complement, difference (DFA constructions).
  + Concatenation and Kleene star (by regex definition).
  + Reversal $L^R$ (reverse NFA transitions).
  + Homomorphism and inverse homomorphism.
  + Prefix, suffix, and substring operations.
]

=== The Pumping Lemma

#theorem[Pumping Lemma for regular languages][
  If $L$ is regular, $exists p >= 1$ (pumping length) such that $forall w in L$, $|w| >= p$, $w = x y z$ with:
  + $|y| > 0$,
  + $|x y| <= p$,
  + $x y^i z in L$ for all $i >= 0$.
]

#proof-sketch[
  DFA with $p$ states. String length $>= p$ must visit some state twice (pigeonhole).
  The substring between visits is $y$ --- pumpable.
]

#example[Proving non-regularity of ${0^n 1^n mid(|) n >= 0}$][
  Suppose $L$ is regular with pumping length $p$.
  Take $w = 0^p 1^p in L$, $|w| = 2p >= p$.
  By the lemma, $w = x y z$ with $|x y| <= p$ and $|y| > 0$, so $y$ consists only of $0$'s.
  Then $x y^2 z = 0^(p+|y|) 1^p in L$ --- but it has more $0$'s than $1$'s, contradiction.
  Therefore $L$ is not regular.
]

#example[
  The language of palindromes over ${a, b}$ is not regular.
  The language ${a^(2^n) mid(|) n >= 0}$ is not regular (pumping would give lengths not powers of 2).
]

== DFA Minimisation

#definition[State equivalence][
  $p tilde.op q$ if $forall w: hat(delta)(p, w) in F$ iff $hat(delta)(q, w) in F$.
  Equivalent states are indistinguishable.
]

#proposition[Moore's table-filling algorithm][
  1. Mark pairs $(p, q)$ where exactly one is accepting.
  2. Iterate: if $(delta(p, a), delta(q, a))$ is marked for some $a$, mark $(p, q)$.
  3. Repeat till stable. Unmarked pairs = equivalent. Merge them → minimal DFA.
]

#theorem[Uniqueness][
  Every regular language has a unique minimal DFA (up to isomorphism).
]

== Applications

#remark[
  *Lexers*: flex/lex compile regex patterns to DFAs for tokenisation.
  *Protocols*: TCP states form a finite automaton; model checking verifies temporal properties.
  *Model checking*: hardware/software modelled as automata; specifications in temporal logic; exhaustive state-space verification (Clarke/Emerson/Sifakis, Turing Award 2007).
]

#import "theme.typ": *
#show: slides.with(
  title: [Discrete Mathematics],
  subtitle: "Formal Languages",
  date: "Spring 2025",
  authors: "Konstantin Chukharev",
  ratio: 16 / 9,
  // dark: true,
)

#show table.cell.where(y: 0): strong

#let regex(s) = raw(s)
#let conf(q, s) = $angle.l #q, #s angle.r$

= Formal Languages

== Basic Terminology

#definition[
  _Alphabet_ $Sigma$ is a finite non-empty set of symbols.

  #examples[
    $Sigma_1 = {"a", "b", "c"}$, $Sigma_2 = {0, 1}$, $Sigma_3 = {#emoji.crab, #emoji.cat, #emoji.seal, #emoji.lion}$.
  ]
]

#definition[
  A _word_, or a _string_, over $Sigma$ is a _finite_ sequence of symbols from $Sigma$.

  #examples[
    "abacaba", "10110001", "i am a word", "" (empty word $epsilon$).
  ]
]

#definition[
  The set of _all_ finite words over the alphabet $Sigma$ is called the _Kleene star_, $Sigma^* = limits(union.big)_(k = 0)^infinity Sigma^k$.
]

#definition[
  A _formal language_ $L subset.eq Sigma^*$ is a set of finite words over a finite alphabet.

  #examples[
    $L_1 = {0, 001, 0001, dots}$,
    $L_2 = {"a", "aba", "ababa", "abababa", dots}$,
    $L_3 = emptyset$,
    $L_4 = {epsilon, "ricercar"}$.
  ]
]

== Operations of Languages

- A formal language, $L subset.eq Sigma^*$, can be defined by:
  - a _enumeration_ of words, e.g. $L = {w_1, w_2, dots, w_n}$
  - a _regular expression_, e.g. $L eq.delta regex("01*")$
  - a _formal grammar_, e.g. $L tilde.equiv G$

- _Set-theoretic_ operations:
  - $L_1 union L_2 = {w | w in L_1 or w in L_2}$, the _union_ of $L_1$ and $L_2$
  - $overline(L) = {w | w notin L} = Sigma^* setminus L$, the _complement_ of $L$
  - $abs(L)$ is the _cardinality_ of $L$

- _Concatenation_:
  - $L_1 dot L_2 = {a b | a in L_1, b in L_2}$, where $a b$ is the concatenation of words $a$ and $b$.
  - $L^k = underbrace(L dot dots dot L, k "times") = \{ underbrace(w w dots w, k "words") | w in L \}$
  - $L^0 = {epsilon}$

- _Kleene star_: $L^* = limits(union.big)_(k = 0)^infinity L^k$

== Regular Languages

#definition[
  A class of regular languages $"REG"$ is defined inductively:
  - $"Reg"_0 = { emptyset, {epsilon} } union { {a} | a in Sigma }$, the _empty_ and _singleton_ languages.
  - $"Reg"_(i+1) = "Reg"_i union { A union B | A, B in "Reg"_i } union { A dot B | A, B in "Reg"_i } union { A^* | A in "Reg"_i }$, \ the inductively extended $(i+1)$-th _generation_ of regular languages.
  - $"REG" = limits(union.big)_(k = 0)^infinity "Reg"_k$, the _class_ of all regular languages.
]

#theorem[
  $"REG"$ is closed under union, concatenation, and Kleene star operations.
]
#proof[
  Let $A in "Reg"_i$, $B in "Reg"_j$.
  - $(A union B) in ("Reg"_i union "Reg"_j) in "Reg"_(max(i, j)+1) subset.eq "REG"$
  - $(A dot B) in ("Reg"_i dot "Reg"_j) in "Reg"_(max(i, j)+1) subset.eq "REG"$
  - $A^* in "Reg"_(i+1) subset.eq "REG"$
]

== Regular Expressions

#table(
  columns: 3,
  align: (center, center, left),
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header[Language][Expression][Description],
  $emptyset$, [], [Empty language],
  ${epsilon}$, $epsilon$, [Language with a single empty word],
  ${"a"}$, $regex("a")$, [Singleton language with a literal character "a"],
  $A$, $alpha$, [Language $A$ denoted by regex $alpha$],
  $B$, $beta$, [Language $B$ denoted by regex $beta$],
  $A union B$, $alpha | beta$, [Union of languages $A$ and $B$],
  $A dot B$, $alpha beta$, [Concatenation of languages $A$ and $B$],
  $A^*$, $alpha^*$, [Kleene star of language $A$],
  $A^+$, $alpha^+$, [Kleene plus of language $A$],
)

#example[
  $regex("(a|bc)*") = {epsilon, "a", "aa", "aaa", dots, "bc", "bcbc", "bcbcbc", dots, "abc", "bca", "abca", "abcbc", "bcabc", dots}$
]

See also: PCRE #href("https://en.wikipedia.org/wiki/Perl_Compatible_Regular_Expressions")

= Automata

== Deterministic Finite Automata

#definition[
  Deterministic Finite Automaton (DFA) is a 5-tuple $cal(A) = (Q, Sigma, delta, q_0, F)$ where:
  - $Q$ is a _finite_ set of states,
  - $Sigma$ is an _alphabet_ (finite set of input symbols),
  - $delta: Q times Sigma to Q$ is a _transition function_,
  - $q_0 in Q$ is the _start_ state,
  - $F subset.eq Q$ is a set of _accepting_ states.

  DFAs recognize _regular_ languages (Type 3).
]

#example[
  Automaton $cal(A)$ recognizing strings with an even number of 0s, $cal(L)(cal(A)) = { 0^n | n "is even" }$.

  #let aut = (
    q0: (q0: 1, q1: 0),
    q1: (q0: 0, q1: 1),
  )
  #grid(
    columns: 3,
    column-gutter: 2em,
    finite.transition-table(aut),
    finite.automaton(
      aut,
      final: ("q0",),
      style: (
        state: (radius: 0.5, extrude: 0.8),
        transition: (curve: 0.5),
      ),
    ),
    [Here, $q_0$ is the _start_ (denoted by an arrow) and also the~_accepting_ (denoted by double circle) state.],
  )
]

== Exercises

For each language below (over the alphabet $Sigma = {0, 1}$), draw a DFA recognizing it:
+ $L_1 = {"101", "110"}$
+ $L_2 = Sigma^* setminus {"101", "110"}$
+ $L_3 = {w | w "starts and ends with the same bit"}$
+ $L_4 = {"110"}^* = {epsilon, "110", "110110", "110110110", dots}$
+ $L_5 = {w | w "contains 110 as a substring"}$

== Recognizers vs Transducers

There are two main types of finite-state machines:

+ _Acceptors_ (or _recognizers_), automata that produce a binary _yes/no answer_, indicating whether or not the recieved input word $w in Sigma^*$ is _accepted_, i.e., belongs to the language $L$ recognized by the automaton.

#align(center)[
  #import fletcher: diagram, node, edge
  #diagram(
    // debug: true,
    edge-stroke: 0.8pt,
    node-corner-radius: 3pt,
    spacing: (5em, 2em),
    blob((-1, 0), name: <input>, tint: yellow)[$w in Sigma^*$],
    blob((0, 0), name: <automaton>, tint: blue)[Automaton $cal(A)$ \ $cal(L)(cal(A)) = L$],
    blob((1, -0.5), name: <acc>, tint: green)[accept],
    blob((1, 0.5), name: <rej>, tint: red)[reject],
    edge((-1, 0), <automaton>, "-|>")[$w in^quest L$],
    edge(<automaton>, <acc>, "-|>", label-angle: auto, label-side: left)[
      $w in cal(L)(cal(A))$
    ],
    edge(<automaton>, <rej>, "-|>", label-angle: auto, label-side: right)[
      $w notin cal(L)(cal(A))$
    ],
  )
]

+ _Transducers_, machines that produce an output action _for each_ symbol of an input.
  // TODO: cite
  - Moore machines (1956)
  - Mealy machines (1955)

== Computation

#definition[
  A process of _computation_ by a finite-state machine $cal(A)$ is a finite sequence of _configurations_, or _snapshots_.
  A set of all possible configurations is denoted $"SNAP" = Q times Sigma^*$.
]

#definition[
  A _reachability relation_ $tack$ is a binary relation over configurations:
  $
    conf(q, alpha) tack conf(r, beta) quad "iff" quad
    cases(
      alpha = c beta & "where" c in Sigma,
      r = delta(q, c),
    )
  $

  - $c_1 tack c_2$ means "configuration $c_2$ is reachable in _one step_ from $c_1$".
  - $scripts(tack)^*$, the reflexive-transitive closure of $tack$, denotes "reachable in _any_ number of steps".
]

== Automata Languages

#definition[
  A word $w in Sigma^*$ is _accepted_ by an automaton $cal(A)$ if the computation, starting in the initial configuration at state $q_0$ with input $w$, _can reach the final configuration $conf(f, epsilon)$_, where $f in F$ is any accepting state, and $epsilon$ denotes that the input has been fully consumed.

  Formally, $cal(A)$ accepts $w in Sigma^*$ if $conf(q_0, w) scripts(tack)^* conf(f, epsilon)$ for some $f in F$.
]

#definition[
  The language _recognized_ by an automaton $cal(A)$ is a set of all words accepted by $cal(A)$.
  $
    cal(L)(cal(A)) = { w in Sigma^* | conf(q_0, w) scripts(tack)^* conf(f, epsilon) "where" f in F }
  $
]

#definition[
  The class of _automaton languages_ recognized by DFAs is denoted $"AUT"$.
  $
    "AUT" = { X | exists cal(A) "such that" cal(L)(cal(A)) = X }
  $
]

== Kleene's Theorem

#theorem[
  $"REG" = "AUT"$.
]

#proof[($thin "REG" subset.eq "AUT" thin$)][
  _For every regular language, there is a DFA that accepts it._

  Proof by induction over the _generation index $k$_.
  Show that $forall k. thin "Reg"_k subset.eq "AUT"$.

  *Base:* $k = 0$, construct automata for $"Reg"_0 = { emptyset, {epsilon}, {c} "for" c in Sigma }$:

  #align(center)[
    #cetz.canvas({
      import cetz.draw: *
      import finite.draw: state, transition

      set-style(state: (radius: 0.5, extrude: 0.8, initial: (label: (text: none))))

      state((0, 0), "a1_q0", label: $q_0$, initial: true)
      state((1, 0), "a1_q1", label: $q_1$, final: true)

      state((4, 0), "a2_q0", label: $q_0$, initial: true)

      state((7, 0), "a3_q0", label: $q_0$, initial: true)
      state((8, 0), "a3_q1", label: $q_1$, final: true)
      transition("a3_q0", "a3_q1", inputs: "c", label: $c$, curve: 0.5)

      content((rel: (0, -1), to: ("a1_q0.center", 50%, "a1_q1.center")))[$L = emptyset$]
      content((rel: (0, -1), to: "a2_q0.center"))[$L = {epsilon}$]
      content((rel: (0, -1), to: ("a3_q0.center", 50%, "a3_q1.center")))[$L = {c}$]
    })
  ]

  *Induction step:* $k > 0$, already have automata for languages $L_1, L_2 in "Reg"_(k-1)$.

  TODO
]


= Extra slides

== Chomsky Hierarchy

#definition[Formal language][
  A set of strings over an alphabet $Sigma$, closed under concatenation.
]

#place(right)[
  #grid(
    columns: 1,
    align: center,
    column-gutter: 1em,
    row-gutter: 0.5em,
    link("https://en.wikipedia.org/wiki/Noam_Chomsky", image("assets/Noam_Chomsky.jpg", height: 3cm)),
    [Noam Chomsky],
  )
]

Formal languages are classified by _Chomsky hierarchy_:
- Type 0: Recursively Enumerable -- Turing Machines
- Type 1: Context-Sensitive -- Linear TMs
- Type 2: Context-Free -- Pushdown Automata
- Type 3: Regular -- Finite Automata

#v(1.5cm, weak: true)
_Examples_:
- $L = { a^n | n geq 0 }$
- $L = { a^n b^n | n geq 0 }$
- $L = { a^n b^n c^n | n geq 0 }$
- $L = { angle.l M, w angle.r | M "is a TM that halts on input" w }$

#place(horizon + center, dx: 1.7cm, dy: .6cm)[
  #cetz.canvas({
    import cetz.draw: *
    circle((0, 0), radius: (1, .5))
    circle((0, 0.5), radius: (1.4, 1))
    circle((0, 1), radius: (2, 1.5))
    circle((0, 1.6), radius: (2.8, 2.1))
    content((0, 0))[Regular]
    content((0, 0.9))[Context-Free]
    content((0, 1.9))[Context-Sensitive]
    content((0, 2.9))[Recursively Enumerable]
  })
]

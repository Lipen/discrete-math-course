#import "theme.typ": *
#show: slides.with(
  title: [Languages and Computation],
  subtitle: "Discrete Math",
  date: "Spring 2026",
  authors: "Konstantin Chukharev",
  // dark: true,
)

#show heading.where(level: 1): none

#import "common-lec.typ": *
#import finite: cetz

#show table.cell.where(y: 0): strong

// Custom helpers
#let power(x) = $cal(P)(#x)$
#let regex(s) = raw(s)
#let conf(q, s) = $chevron.l #q, #s chevron.r$
#let lang(x) = $cal(L)(#x)$
#let Blank = math.class("normal", sym.square.stroked)

#CourseOverviewPage2()


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1: Formal Languages
// ═══════════════════════════════════════════════════════════════════════════════

= Formal Languages

#focus-slide(
  epigraph: [The limits of my language mean the limits of my world.],
  epigraph-author: "Ludwig Wittgenstein",
  scholars: (
    (
      name: "Noam Chomsky",
      image: image("assets/Noam_Chomsky.jpg"),
    ),
    (
      name: "Stephen Kleene",
      image: image("assets/Stephen_Kleene.jpg"),
    ),
  ),
)

== Why Formal Languages?

Every non-trivial computation involves _processing structured input_:
- Compilers read _programs_ (strings over some alphabet).
- Databases evaluate _queries_ (strings with specific syntax).
- Network protocols parse _packets_ (sequences of bytes).
- Bioinformatics analyzes _DNA_ (strings over ${"A", "C", "G", "T"}$).

The theory of formal languages gives us a _mathematical framework_ for answering:
- What kinds of patterns can we _describe_?
- What kinds of patterns can we _recognize_ (and how efficiently)?
- What are the _fundamental limits_ of computation?

#Block(color: yellow)[
  *Key insight:* The study of formal languages is not just about strings --- it is the foundation of the _theory of computation_.

  Every computational problem can be phrased as: "Given a string $w$, does $w$ belong to language $L$?"
]

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

== Operations on Languages

- A formal language, $L subset.eq Sigma^*$, can be defined by:
  - an _enumeration_ of words, e.g. $L = {w_1, w_2, dots, w_n}$
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

== Chomsky Hierarchy

Formal languages are classified by _Chomsky hierarchy_ --- a nested family of increasingly powerful language classes, each recognized by a correspondingly more powerful machine.

#align(center)[
  #table(
    columns: 4,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Type*], [*Class*], [*Machine*], [*Example*]),
    [3], [Regular], [Finite Automata], [${ a^n | n >= 0 }$],
    [2], [Context-Free], [Pushdown Automata], [${ a^n b^n | n >= 0 }$],
    [1], [Context-Sensitive], [Linear-Bounded TMs], [${ a^n b^n c^n | n >= 0 }$],
    [0], [Recursively Enumerable], [Turing Machines], [${ angle.l M, w angle.r | M "halts on" w }$],
  )
]

#align(center)[
  #cetz.canvas({
    import cetz.draw: *
    circle((0, 0), radius: (1, 0.6))
    circle((0, 0.6), radius: (1.5, 1.2))
    circle((0, 1.2), radius: (2, 1.8))
    circle((0, 1.8), radius: (2.5, 2.4))
    content((0, 0))[Regular]
    content((0, 1.1))[Context-Free]
    content((0, 2.4))[Context-\ Sensitive]
    content((0, 3.5))[Recursively \ Enumerable]
  })
]

#Block(color: blue)[
  Each level of the hierarchy represents a _trade-off_ between _expressive power_ and _decidability_.

  More expressive languages come at the cost of harder (or impossible) algorithmic questions.
]

== Decision Problems as Languages

Any _decision problem_ --- a question with a "yes" or "no" answer --- can be reformulated as a _language membership test_.
The language encodes all inputs for which the answer is "yes".

#definition[
  A _decision problem_ is a question with a "yes" or "no" answer depending on the input.
  Formally, the set of inputs for which the answer is "yes" is a language $L subset.eq Sigma^*$.

  _Deciding_ the problem is equivalent to _recognizing_ the language $L$.
]

#example[
  *Satisfiability (SAT):* Given a Boolean formula $phi$, is it satisfiable?
  $ "SAT" = { phi | phi "is a satisfiable Boolean formula" } $
]

#example[
  *Validity (VALID):* Given a Boolean formula $phi$, is it a tautology?
  $ "VALID" = { phi | phi "is a valid (universally true) formula" } $
]

#example[
  *Halting Problem (HALT):* Given a TM $M$ and input $w$, does $M$ halt on $w$?
  $ "HALT" = { angle.l M, w angle.r | "TM" thin M "halts on input" thin w } $
]

#Block(color: yellow)[
  *Key insight:* Asking "is $w$ in $L$?" and asking "does the algorithm say yes on input $w$?" are _the same question_.
  This lets us use the theory of formal languages to study the limits of computation.
]


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2: Regular Languages
// ═══════════════════════════════════════════════════════════════════════════════

= Regular Languages

#focus-slide(
  epigraph: [A language that doesn't affect the way you think about programming is not worth knowing.],
  epigraph-author: "Alan Perlis",
)

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

Regular languages can be composed from "smaller" regular languages.

- _Atomic_ regular expressions:
  - $emptyset$, an empty language
  - $epsilon$, a singleton language consisting of a single $epsilon$ word
  - $regex("a")$, a singleton language consisting of a single 1-letter word $a$, for each $a in Sigma$

- _Compound_ regular expressions:
  - $R_1 R_2$, the concatenation of $R_1$ and $R_2$
  - $R_1 | R_2$, the union of $R_1$ and $R_2$
  - $R^* = R R R dots$, the Kleene star of $R$
  - $(R)$, just a bracketed expression
  - Operator precedence: $regex("ab*c|d") eq.delta ((regex("a") (regex("b")^*)) regex("c")) | regex("d")$

== Regular Expressions --- Summary Table

#align(center)[
  #table(
    columns: 3,
    align: (center, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Language*], [*Expression*], [*Description*]),
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
]

#example[
  $regex("(a|bc)*") = {epsilon, "a", "aa", "aaa", dots, "bc", "bcbc", "bcbcbc", dots, "abc", "bca", "abca", "abcbc", "bcabc", dots}$
]

See also: PCRE #href("https://en.wikipedia.org/wiki/Perl_Compatible_Regular_Expressions")

#Block(color: yellow)[
  *Key insight:* Regular expressions describe _exactly_ the regular languages.
  This is not obvious --- it takes Kleene's Theorem (stated later) to prove it.
]


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3: Finite Automata
// ═══════════════════════════════════════════════════════════════════════════════

= Finite Automata

#focus-slide(
  epigraph: [We may hope that machines will eventually compete with men in all purely intellectual fields.],
  epigraph-author: "Alan Turing",
  scholars: (
    (
      name: "Stephen Kleene",
      image: image("assets/Stephen_Kleene.jpg"),
    ),
    (
      name: "Michael Rabin",
      image: image("assets/Michael_Rabin.jpg"),
    ),
    (
      name: "Dana Scott",
      image: image("assets/Dana_Scott.jpg"),
    ),
  ),
)

== Recognizers vs Transducers

There are two main types of finite-state _machines_:

+ _Acceptors_ (or _recognizers_), automata that produce a binary _yes/no answer_, indicating whether or not the received input word $w in Sigma^*$ is _accepted_, i.e., belongs to the language $L$ recognized by the automaton.

#align(center)[
  #import fletcher: diagram, edge, node
  #diagram(
    spacing: (6em, 2em),
    node-shape: fletcher.shapes.rect,
    node-corner-radius: 3pt,
    edge-stroke: 0.8pt,
    blob((-1, 0), name: <input>, tint: yellow)[$w in Sigma^*$],
    blob((0, 0), name: <automaton>, tint: blue)[Automaton $cal(A)$ \ $lang(cal(A)) = L$],
    blob((1, -0.5), name: <acc>, tint: green)[accept],
    blob((1, 0.5), name: <rej>, tint: red)[reject],
    edge((-1, 0), <automaton>, "-|>")[$w in^quest L$],
    edge(<automaton>, <acc>, "-|>", label-angle: auto, label-side: left)[
      $w in lang(cal(A))$
    ],
    edge(<automaton>, <rej>, "-|>", label-angle: auto, label-side: right)[
      $w notin lang(cal(A))$
    ],
  )
]

2. _Transducers_, machines that produce an output action _for each_ symbol of an input.
  - Moore machines (1956)
  - Mealy machines (1955)

In this course, we focus on _acceptors_.

== Deterministic Finite Automata

#definition[
  A _Deterministic Finite Automaton_ (DFA) is a 5-tuple $cal(A) = (Q, Sigma, delta, q_0, F)$ where:
  - $Q$ is a _finite_ set of states,
  - $Sigma$ is an _alphabet_ (finite set of input symbols),
  - $delta: Q times Sigma to Q$ is a _transition function_,
  - $q_0 in Q$ is the _start_ state,
  - $F subset.eq Q$ is a set of _accepting_ (_final_) states.
]

A DFA is a machine that reads an input string _one symbol at a time_, transitioning between states.
After reading the entire input, the machine either _accepts_ or _rejects_ based on whether it ended in an accepting state.

#note[
  _Deterministic_ means: at every state, for every symbol, there is _exactly one_ transition.
]

== DFA --- Example

#example[
  Automaton $cal(A)$ recognizing strings with an even number of 0s, $lang(cal(A)) = { w in {0,1}^* | w "has even number of 0s" }$.

  #let aut = (
    q0: (q0: 1, q1: 0),
    q1: (q0: 0, q1: 1),
  )
  #grid(
    columns: 3,
    column-gutter: 2em,
    finite.transition-table(aut),
    finite.automaton(aut, final: ("q0",), style: (
      state: (radius: 0.5, extrude: 0.8),
      transition: (curve: 0.5),
    )),
    [Here, $q_0$ is the _start_ (denoted by an arrow) and also the _accepting_ (denoted by double circle) state.

    On input $1$, the machine stays. \
    On input $0$, the machine toggles.],
  )
]

== DFA --- Computation

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

#note[
  A configuration captures _everything_ the machine "knows" at a given moment: its current state and the remaining input.
]

== Automata Languages

#definition[
  A word $w in Sigma^*$ is _accepted_ by an automaton $cal(A)$ if the computation, starting in the initial configuration at state $q_0$ with input $w$, _can reach the final configuration $conf(f, epsilon)$_, where $f in F$ is any accepting state, and $epsilon$ denotes that the input has been fully consumed.

  Formally, $cal(A)$ _accepts_ $w in Sigma^*$ if $conf(q_0, w) scripts(tack)^* conf(f, epsilon)$ for some $f in F$.
]

#definition[
  The language _recognized_ by an automaton $cal(A)$ is a set of all words accepted by $cal(A)$.
  $
    lang(cal(A)) = { w in Sigma^* | conf(q_0, w) scripts(tack)^* conf(f, epsilon) "where" f in F }
  $
]

#definition[
  The class of _automaton languages_ recognized by DFAs is denoted $"AUT"$.
  $
    "AUT" = { X | exists cal(A) "such that" lang(cal(A)) = X }
  $
]

== DFA Exercises

For each language below (over the alphabet $Sigma = {0, 1}$), draw a DFA recognizing it:
+ $L_1 = {"101", "110"}$
+ $L_2 = Sigma^* setminus {"101", "110"}$
+ $L_3 = {w | w "starts and ends with the same bit"}$
+ $L_4 = {"110"}^* = {epsilon, "110", "110110", "110110110", dots}$
+ $L_5 = {w | w "contains 110 as a substring"}$


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4: Non-determinism
// ═══════════════════════════════════════════════════════════════════════════════

= Non-determinism

#focus-slide(
  epigraph: [A language is recognized by some NFA if and only if it is recognized by some DFA.],
  epigraph-author: "Michael Rabin & Dana Scott, 1959",
  scholars: (
    (
      name: "Michael Rabin",
      image: image("assets/Michael_Rabin.jpg"),
    ),
    (
      name: "Dana Scott",
      image: image("assets/Dana_Scott.jpg"),
    ),
  ),
)

== Non-deterministic Finite Automata

#definition[
  A _Non-deterministic Finite Automaton_ (NFA) is a 5-tuple $cal(A) = (Q, Sigma, delta, q_0, F)$, where
  - $Q$ is a _finite_ set of states,
  - $Sigma$ is an _alphabet_ (finite set of input symbols),
  - $delta: Q times Sigma to power(Q)$ is a _transition function_,
  - $q_0 in Q$ is an _initial_ (_start_) state,
  - $F subset.eq Q$ is a set of _accepting_ (_final_) states.
]

The key difference from a DFA: the transition function returns a _set_ of possible next states.

#note[
  $delta : (q, c) maps underbrace({q^((1))\, dots\, q^((n))}, "non-determinism")$
]

== NFA --- Example

#[
  // .* (110*)+
  #let aut = (
    q0: (q0: (0, 1), q1: 1),
    q1: (q2: 1),
    q2: (q1: 1, q2: 0),
  )
  #grid(
    columns: 2,
    column-gutter: 1em,
    finite.transition-table(aut),
    finite.automaton(aut, final: ("q2",), style: (
      state: (radius: 0.5, extrude: 0.8),
      transition: (curve: 0.6),
      q1: (label: $q_1$),
      q2: (label: $q_2$),
    )),
  )
]

This NFA has _two_ transitions from $q_0$ by the symbol $1$: it can go to $q_0$ or to $q_1$.

If an NFA needs to make a non-existent transition (e.g., at $q_1$ by $0$), it _dies_ and that particular path rejects.

== Determinism vs Non-determinism

#definition[
  A model of computation is _deterministic_ if at every point in the computation, there is exactly _one choice_ that can be made.
]
#note[
  The machine accepts if _that_ series of choices leads to an accepting state.
]

#definition[
  A model of computation is _non-deterministic_ if the computing machine may have _multiple decisions_ that it can make at one point.
]
#note[
  The machine accepts if _any_ series of choices leads to an accepting state.
]

#Block(color: yellow)[
  *Key insight:* Non-determinism is not about randomness.
  A non-deterministic machine accepts if _there exists_ at least one accepting path --- it doesn't matter how unlikely that path might be.
]

== Intuitions on Non-determinism

There are three useful ways to think about non-determinism:

*1. Tree Computation*

At each _decision point_, the automaton _clones_ itself for each possible decision.
The series of choices forms a directed, rooted _tree_.
If _any_ leaf is accepting, the machine accepts.

*2. Perfect Guessing*

A non-deterministic machine has _magic superpowers_: it can always _guess_ the right sequence of choices (if one exists).
No physical implementation is known.

*3. Massive Parallelism*

An NFA can be thought of as a machine that tries _all possibilities in parallel_, using an unlimited number of "processors".
Each symbol read causes a transition on every currently active state.

== Tree Computation --- Example

#[
  #let aut = (
    q0: (q1: "a", q3: "b"),
    q1: (q2: "b", q4: "b"),
    q2: (),
    q3: (q4: "a"),
    q4: (q4: ("a", "b"), q5: "a"),
    q5: (),
  )
  #grid(
    columns: (1fr, 1fr),
    align: center,
    column-gutter: 1em,
    [
      #finite.automaton(
        aut,
        final: ("q2", "q5"),
        style: (
          state: (radius: 0.5, extrude: 0.8),
          transition: (curve: 0.001),
          q0: (label: $0$),
          q1: (label: $1$),
          q2: (label: $2$),
          q3: (label: $3$),
          q4: (label: $4$),
          q5: (label: $5$),
          q4-q4: (curve: 0.5),
        ),
        layout: finite.layout.custom.with(positions: (
          q0: (0, 0),
          q1: (2, 0),
          q2: (5, 0),
          q3: (1, 2),
          q4: (3, 2),
          q5: (5, 2),
        )),
      )
      #box(stroke: 1pt, inset: 1em, radius: .5em, fill: blue.lighten(80%))[
        $
          w = "a b a b a"
        $
      ]
    ],
    [
      #import cetz.tree
      #let r = 0.3
      #let data = (
        $0$,
        (
          $1$,
          (
            $4$,
            (
              $4$,
              (
                $4$,
                $4$,
                $5$,
              ),
            ),
            $5$,
          ),
          $2$,
        ),
      )
      #cetz.canvas({
        tree.tree(data, draw-node: (node, ..) => {
          if node.children.len() == 0 {
            if node.content == $5$ and node.depth == 5 {
              cetz.draw.circle((), radius: r, fill: green.lighten(80%))
            } else {
              cetz.draw.circle((), radius: r, fill: red.lighten(80%))
            }
          } else {
            cetz.draw.circle((), radius: r, fill: yellow.lighten(80%))
          }
          cetz.draw.content((), node.content)
        })
      })
    ],
  )
]

- At each _decision point_, the automaton _clones_ itself for each possible decision.
- At the end, if _any_ active accepting (#text(green.darken(20%))[green]) states remain, we _accept_.

== NFA Computation Model

Reachability relation for NFA is very similar to DFA's:
$
  conf(q, x) scripts(tack)_"DFA" conf(r, y) quad & "iff" quad
                                                   cases(
                                                     x = c y & "where" c in Sigma,
                                                     r = delta(q, c)
                                                   ) \
  conf(q, x) scripts(tack)_"NFA" conf(r, y) quad & "iff" quad
                                                   cases(
                                                     x = c y & "where" c in Sigma,
                                                     r in delta(q, c)
                                                   )
$

#definition[
  An NFA _accepts_ a word $w in Sigma^*$ iff $conf(q_0, w) scripts(tack)^* conf(f, epsilon)$ for some $f in F$.
]

#definition[
  A language _recognized_ by an NFA is a set of all words accepted by the NFA.
  $
    lang(cal(A)) = { w in Sigma^* | conf(q_0, w) scripts(tack)^* conf(f, epsilon), f in F }
  $
]

== DFAs vs NFAs

#align(center)[
  #table(
    columns: 2,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Deterministic (DFA)*], [*Non-Deterministic (NFA)*]),
    [Single transition per symbol], [Multiple possible transitions],
    [No $epsilon$-transitions], [May have $epsilon$-transitions],
    [Unique computation path], [Multiple parallel paths],
    [$delta: Q times Sigma to Q$], [$delta: Q times Sigma to power(Q)$],
    [Easy to simulate], [Hard to simulate directly],
    [May need exponentially many states], [Can be exponentially more concise],
  )
]

#Block(color: blue)[
  *Why NFAs?* Despite having the same expressive power as DFAs, NFAs are often _exponentially more concise_.
  They are also the natural output of many constructions (e.g., Thompson's construction from regular expressions).
]

== $epsilon$-NFA

An _$epsilon$-NFA_ extends NFAs with $epsilon$-transitions --- transitions that consume _no input_.

#definition[
  _Epsilon closure_ of a state $q$, denoted $E(q)$ or $epsilon"-clo"(q)$, is a set of states reachable from $q$ by $epsilon$-transitions.
  #let clo-aut = cetz.canvas({
    import cetz.draw: *
    import finite.draw: state, transition

    set-style(state: (radius: 0.3))

    state((0, 0), "q", label: $q$)
    state((1.5, 0), "r", label: $r$)

    transition("q", "r", inputs: "eps", label: $epsilon$, curve: 0.001)
  })
  $
    E(q) = epsilon"-clo"(q) = { r in Q | #clo-aut }
  $
  This definition can be extended to the _sets of states_. For $P subset.eq Q$:
  $
    E(P) = union.big_(q in P) E(q)
  $
]

#note[
  $q in epsilon"-clo"(q)$ since each state has an _implicit_ $epsilon$-loop.
]

#example[
  For the following NFA, epsilon closure of $q$ is $epsilon"-clo"(q) = {q, r, s}$.

  #align(center)[
  #cetz.canvas({
    import cetz.draw: *
    import finite.draw: state, transition

    set-style(state: (radius: 0.3))

    state((0, 0), "q", label: $q$)
    state((1.5, 0), "r", label: $r$)
    state((3, 0), "s", label: $s$)

    transition("q", "r", inputs: "eps", label: $epsilon$, curve: 0.001)
    transition("r", "s", inputs: "eps", label: $epsilon$, curve: 0.001)
  })
  ]
]

== From $epsilon$-NFA to NFA

To construct an NFA from an $epsilon$-NFA:
+ Perform a _transitive closure_ of $epsilon$-transitions.
  - After that, accepted words contain _no two consecutive_ $epsilon$-transitions.
+ _Back-propagate_ accepting states over $epsilon$-transitions.
  - After that, accepted words _do not end_ with $epsilon$.
+ Perform _symbol-transition back-closure_ over $epsilon$-transitions.
  - After that, accepted words _do not contain_ $epsilon$-transitions.
+ _Remove_ $epsilon$-transitions.
  - After that, you get a plain NFA.

== Rabin--Scott Powerset Construction

Any NFA can be converted to a DFA using _Rabin--Scott subset construction_.

$cal(A)_"N" = chevron.l Sigma, Q_"N", delta_"N", q_0, F_"N" chevron.r$
- $Q_"N" = {q_1, q_2, ..., q_n}$
- $delta_"N" : Q_"N" times Sigma to power(Q_"N")$

$cal(A)_"D" = chevron.l Sigma, Q_"D", delta_"D", {q_0}, F_"D" chevron.r$
- $Q_"D" = power(Q_"N") = {emptyset, {q_1}, dots, {q_2, q_4, q_5}, dots, Q_"N"}$
- $delta_"D" : Q_"D" times Sigma to Q_"D"$
- $delta_"D" : (A, c) maps { r | exists q in A. thin r in delta_"N" (q, c) }$
- $F_"D" = { A | A intersect F_"N" != emptyset }$

#Block(color: orange)[
  *Warning:* The powerset construction can produce _exponentially many_ states.
  An NFA with $n$ states can require a DFA with up to $2^n$ states.
  In practice, many of these states are unreachable and can be pruned.
]

== NFA to DFA: Worked Example

Let's walk through a complete example of converting an NFA to a DFA using the powerset construction.

#example[
  Consider the NFA $cal(N)$ over alphabet $Sigma = {0, 1}$ that accepts strings ending with $01$:

  #let nfa-aut = (
    q0: (q0: 1, q1: 0),
    q1: (q2: 1),
    q2: (),
  )
  #let nfa-example = finite.automaton(nfa-aut, final: ("q2",))

  #align(center)[
    #nfa-example
  ]

  Formally, $cal(N) = (Sigma, Q, delta, q_0, F)$ where:
  - $Q = {q_0, q_1, q_2}$
  - $delta(q_0, 0) = {q_0, q_1}$, $delta(q_0, 1) = {q_0}$, $delta(q_1, 1) = {q_2}$, all other transitions go to $emptyset$
  - $q_0$ is start state
  - $F = {q_2}$
]

== Step 1: Determine Reachable States

We begin with the start state of the DFA: ${q_0}$.

Compute transitions from ${q_0}$:
- On $0$: $delta_D({q_0}, 0) = delta_N(q_0, 0) = {q_0, q_1}$
- On $1$: $delta_D({q_0}, 1) = delta_N(q_0, 1) = {q_0}$

Now we have new states ${q_0, q_1}$ and ${q_0}$. ${q_0}$ is already known.

== Step 2: Compute Transitions for New States

From ${q_0, q_1}$:
- On $0$: $delta_N(q_0, 0) union delta_N(q_1, 0) = {q_0, q_1} union emptyset = {q_0, q_1}$
- On $1$: $delta_N(q_0, 1) union delta_N(q_1, 1) = {q_0} union {q_2} = {q_0, q_2}$

New state: ${q_0, q_2}$

From ${q_0, q_2}$:
- On $0$: $delta_N(q_0, 0) union delta_N(q_2, 0) = {q_0, q_1} union emptyset = {q_0, q_1}$
- On $1$: $delta_N(q_0, 1) union delta_N(q_2, 1) = {q_0} union emptyset = {q_0}$

No new states.

== Step 3: Identify Accepting States

A DFA state is accepting if it contains any NFA accepting state:
- ${q_0}$: contains $q_0$? No ($q_0 notin F$). Not accepting.
- ${q_0, q_1}$: contains $q_2$? No. Not accepting.
- ${q_0, q_2}$: contains $q_2$? Yes ($q_2 in F$). Accepting.

== Step 4: Construct the DFA

We have three reachable states: $A = {q_0}$, $B = {q_0, q_1}$, $C = {q_0, q_2}$.

Transition table:
#table(
  columns: 4,
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header([*State*], [$0$], [$1$], [Accepting?]),
  [$A = {q_0}$], [$B$], [$A$], [$NO$],
  [$B = {q_0, q_1}$], [$B$], [$C$], [$NO$],
  [$C = {q_0, q_2}$], [$B$], [$A$], [$YES$],
)

#let dfa-aut = (
  A: (B: 0, A: 1),
  B: (B: 0, C: 1),
  C: (B: 0, A: 1),
)
#let dfa-example = finite.automaton(dfa-aut, final: ("C",))

#align(center)[
  #dfa-example
]

== Step 5: Verify Equivalence

Both automata accept the same language: strings ending with $01$.
- The NFA has 3 states, the DFA has 3 reachable states (out of possible $2^3 = 8$).
- Unreachable states like ${q_1}$, ${q_2}$, ${q_1, q_2}$, ${q_0, q_1, q_2}$, $emptyset$ were never generated.

#Block(color: green)[
  *Key observation:* Although the powerset construction can produce exponentially many states, in practice many states are unreachable. This example shows that sometimes the resulting DFA can be as small as the original NFA.
]

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5: Kleene's Theorem
// ═══════════════════════════════════════════════════════════════════════════════

= Kleene's Theorem

#focus-slide(
  epigraph: [Representation of events in nerve nets and finite automata.],
  epigraph-author: "Stephen Kleene, 1956",
  scholars: (
    (
      name: "Stephen Kleene",
      image: image("assets/Stephen_Kleene.jpg"),
    ),
  ),
)

== Kleene's Theorem

#theorem[Kleene][
  $"REG" = "AUT"$.

  That is, a language is _regular_ (definable by a regular expression) if and only if it is recognized by a _finite automaton_.
]

#proof[($thin "REG" subset.eq "AUT" thin$)][
  _For every regular language, there is a DFA that recognizes it._

  Use _Thompson's construction_ to build an $epsilon$-NFA from a regular expression, and then convert it to a DFA.
]

#proof[($thin "AUT" subset.eq "REG" thin$)][
  _The language recognized by a DFA is regular._

  Use _Kleene's algorithm_ to construct a regular expression from an automaton.
]

== The Equivalence Cycle

The following diagram summarizes the conversions between the four representations.
Each arrow represents a _constructive_ conversion algorithm.

#align(center)[
  #import fletcher: diagram, edge, node
  #diagram(
    spacing: (3em, 2em),
    node-shape: fletcher.shapes.rect,
    node-corner-radius: 3pt,
    edge-stroke: 1pt,
    blob((0, 0), [DFA], name: <dfa>, tint: yellow),
    blob((1, 0), [NFA], name: <nfa>, tint: yellow),
    blob((2, 0), [$epsilon$-NFA], name: <enfa>, tint: yellow),
    blob((3, 0), [RegExp], name: <re>, tint: yellow),
    edge(<nfa>, <dfa>, "-}>", bend: 45deg)[Powerset],
    edge(<enfa>, <nfa>, "-}>", bend: 45deg)[$epsilon$-closure],
    edge(<dfa>, "u,r,r,r", <re>, "-}>")[Kleene's algorithm],
    edge(<re>, <enfa>, "-}>", bend: 45deg)[Thompson's \ construction],
  )
]

#Block(color: yellow)[
  *Key insight:* All four representations --- DFA, NFA, $epsilon$-NFA, and regular expressions --- are _equally powerful_.
  They describe exactly the same class of languages: the _regular languages_.
]

== Thompson's Construction

#definition[
  _Thompson's construction_ is a method of constructing an $epsilon$-NFA from a regular expression.
]

Prove $"REG" subset.eq "AUT"$ by induction over the _generation index $k$_.
Show that $forall k. thin "Reg"_k subset.eq "AUT"$.

*Base:* $k = 0$, construct automata for $"Reg"_0 = { emptyset, {epsilon}, {c} "for" c in Sigma }$.

#align(center)[
  #cetz.canvas({
    import cetz.draw: *
    import finite.draw: state, transition

    set-style(state: (radius: 0.5, extrude: 0.8, initial: (label: (text: none))))

    state((0, 0), "a1_q0", label: $q_0$, initial: true)
    state((1.5, 0), "a1_q1", label: $q_1$, final: true)

    translate(x: 4)
    state((0, 0), "a2_q0", label: $q_0$, initial: true)
    state((1.5, 0), "a2_q1", label: $q_1$, final: true)
    transition("a2_q0", "a2_q1", inputs: "c", label: $epsilon$, curve: 0.5)

    translate(x: 4)
    state((0, 0), "a3_q0", label: $q_0$, initial: true)
    state((1.5, 0), "a3_q1", label: $q_1$, final: true)
    transition("a3_q0", "a3_q1", inputs: "c", label: $c$, curve: 0.5)

    content((rel: (0, -1), to: ("a1_q0.center", 50%, "a1_q1.center")))[$L = emptyset$]
    content((rel: (0, -1), to: ("a2_q0.center", 50%, "a2_q1.center")))[$L = {epsilon}$]
    content((rel: (0, -1), to: ("a3_q0.center", 50%, "a3_q1.center")))[$L = {c}$]
  })
]

*Induction step:* $k > 0$, already have automata $cal(A)_1, cal(A)_2$ for languages $L_1, L_2 in "Reg"_(k-1)$.

Construct automata for:
- $L_1 union L_2$ --- add new start state with $epsilon$-transitions to both $cal(A)_1$ and $cal(A)_2$
- $L_1 dot L_2$ --- connect accepting states of $cal(A)_1$ via $epsilon$-transitions to start of $cal(A)_2$
- $L_1^*$ --- add new start/accept state with $epsilon$-transitions forming a loop through $cal(A)_1$

== Kleene's Algorithm

#definition[
  _Kleene's algorithm_ is a method of constructing a regular expression from a DFA.
]

Let $R_(i j)^k$ be a set of all words that take $cal(A)$ from state $q_i$ to $q_j$ without going _through_ (both entering and leaving) any state numbered higher than $k$.
Note that $i$ and $j$ _can_ be higher than $k$.
Since all states are numbered 1 to $n$, $R_(i j)^n$ denotes the set of all words that take $q_i$ to $q_j$.
We can define $R_(i j)^k$ recursively:
$
  R_(i j)^k & = R_(i j)^(k-1) union R_(i k)^(k-1) (R_(k k)^(k-1))^* R_(k j)^(k - 1) \
  R_(i j)^0 & = cases(
                {a | delta(q_i, a) = q_j} & "if" i != j,
                {a | delta(q_i, a) = q_j} union {epsilon} & "if" i = j,
              )
$

#Block(color: blue)[
  *Connection to other topics:* Kleene's algorithm is structurally identical to the _Floyd--Warshall_ algorithm for shortest paths in graphs.
  Both use dynamic programming with "allowed intermediate nodes up to $k$".
]


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6: Limits of Finite Automata
// ═══════════════════════════════════════════════════════════════════════════════

= Limits of Finite Automata

#focus-slide(
  epigraph: [There are more things in heaven and earth, Horatio,\ than are dreamt of in your philosophy.],
  epigraph-author: "William Shakespeare",
)

== Re-visiting States

- Let $D$ be a DFA with $n$ states.
- Any string $w$ accepted by $D$ that has length at least $n$ must visit some state twice.
- Number of states visited is equal to $abs(w) + 1$.
- By the _pigeonhole principle_, some state is "duplicated", i.e. visited more than once.
- The substring of $w$ between those _revisited states_ can be removed, duplicated, tripled, etc. without changing the fact that $D$ accepts $w$.

#align(center)[
  #show: box.with(inset: -1em)
  #cetz.canvas({
    import cetz.draw: set-style
    import finite.draw: state, transition

    set-style(state: (radius: 0.5, extrude: 0.8))
    set-style(transition: (stroke: (dash: "dashed")))

    state((.565, 0), "q1", initial: true, label: $q_1$)
    state((2, 0), "q2", label: $q_2$)
    state((4, 0), "q3", label: $q_3$, final: true)

    transition("q1", "q2", inputs: "x", label: $x$, curve: 0.001)
    transition("q2", "q3", inputs: "z", label: $z$, curve: 0.001)
    transition("q2", "q2", inputs: "y", label: $y$)
  })
]

Informally:
- Let $L$ be a regular language.
- If we have a string $w in L$ that is "sufficiently long", then we can _split_ the string into _three pieces_ and _"pump"_ the middle.
- We can write $w = x y z$ such that $x y^0 z$, $x y^1 z$, $x y^2 z$, ..., $x y^n z$, ... are all in $L$.

== Weak Pumping Lemma

#theorem[Weak Pumping Lemma for Regular Languages][
  - For any regular language $L$,
    - There exists a positive natural number $n$ (also called _pumping length_) such that
      - For any $w in L$ with $abs(w) >= n$,
        - There exist strings $x$, $y$, $z$ such that
          - For any natural number $i$,
            - $w = x y z$ ($w$ can be broken into three pieces)
            - $y != epsilon$ (the middle part is not empty)
            - $x y^i z in L$ (the middle part can be repeated any number of times)
]

#example[
  Let $Sigma = {0, 1}$ and $L = { w in Sigma^* | w "contains" 00 "as a substring" }$.
  Any string of length 3 or greater can be split into three parts, the second of which can be "pumped".
]

#example[
  Let $Sigma = {0, 1}$ and $L = { epsilon, 0, 1, 00, 01, 10, 11 }$.
  The weak pumping lemma still holds for finite languages, because the pumping length $n$ can be longer than the longest word in the language!
]

== Non-regularity: The Equality Language

#definition[
  The _equality problem_ is, given two strings $x$ and $y$, to decide whether $x = y$.
]

#example[
  Let $Sigma = {0, 1, "#"}$.
  We can _encode_ the equality problem as a string of the form _$x "#" y$_.
  - "Is _001_ equal to _110_ ?" would be _$001 "#" 110$_.
  - "Is _11_ equal to _11_ ?" would be _$11 "#" 11$_.

  Let $"EQUAL" = { w "#" w | w in {0, 1}^* }$.

  *Question:* Is $"EQUAL"$ a _regular_ language?
]

#theorem[
  $"EQUAL"$ is not a regular language.
]

#proof[
  By contradiction.
  Assume that $"EQUAL"$ is a regular language.

  Let $n$ be the pumping length guaranteed by the weak pumping lemma.
  Let $w = 0^n "#" 0^n$, which is in $"EQUAL"$ and $abs(w) = 2n + 1 >= n$.
  By the weak pumping lemma, we can write $w = x y z$ such that $y != epsilon$ and for any $i in NN$, $x y^i z in "EQUAL"$.
  Then $y$ cannot contain $"#"$, since otherwise if we let $i = 0$, then $x y^0 z = x z$ does not contain $"#"$ and would not be in $"EQUAL"$.
  So $y$ is either completely to the left of $"#"$ or completely to the right of $"#"$.

  Let $abs(y) = k$, so $k > 0$.
  Since $y$ is completely to the left or right of $"#"$, then #box[$y = 0^k$].

  Now, we consider two cases:
  #enum(numbering: i => "Case " + str(i) + ":")[
    $y$ is to the left of $"#"$.
    Then $x y^2 z = 0^(n+k) "#" 0^n notin "EQUAL"$, contradicting the weak pumping lemma.
  ][
    $y$ is to the right of $"#"$.
    Then $x y^2 z = 0^n "#" 0^(n+k) notin "EQUAL"$, contradicting the weak pumping lemma.
  ]
  In either case we reach a contradiction, so our assumption was wrong.
  Thus, $"EQUAL"$ _is not regular_.
]

#Block(color: blue)[
  *Why this matters:* This result tells us that a finite automaton fundamentally _cannot compare_ two unbounded strings for equality.
  It lacks "memory" beyond its finite set of states.
]

== The Classic Non-regular Language

#example[
  Consider the language $L = {0^n 1^n | n in NN}$.
  - $L = {epsilon, 01, 0011, 000111, 00001111, ...}$
  - $L$ is a classic example of a non-regular language.
  - *Intuitively:* if you have _only finitely many states_ in a DFA, you cannot _"remember"_ an arbitrary number of $0$s to match _the same_ number of $1$s.

  How would we prove that $L$ is non-regular?
]

#fancy-box[
  Use the Pumping Lemma to show that $L$ _cannot_ be regular.
]

== Pumping Lemma as a Game

The weak pumping lemma can be thought of as a _game_ between #Green[*you*] and a #Red[*adversary*].
- #Green[*You win*] if you can prove that the pumping lemma _fails_.
- #Red[*The adversary wins*] if the adversary can make a choice for which the pumping lemma _succeeds_.

The game goes as follows:
- #Red[The adversary] chooses a pumping length $n$.
- #Green[You] choose a string $w$ with $abs(w) >= n$ and $w in L$.
- #Red[The adversary] breaks it into $x$, $y$, and $z$.
- #Green[You] choose an $i$ such that $x y^i z notin L$ _(if you can't, you lose!)_.

#pagebreak()

$
  L = { 0^n 1^n | n in NN }
$

#align(center)[
  #table(
    columns: 2,
    column-gutter: 1em,
    stroke: (x, y) => if y == 0 { (bottom: .8pt) },
    table.header([*#Red[Adversary]*], [*#Green[You]*]),
    [Maliciously choose \ pumping length $n$], [],
    [], [Cleverly choose a string \ $w in L$, $abs(w) >= n$],
    [Maliciously split \ $w = x y z$, $y != epsilon$], [],
    [], [Cleverly choose an $i$ \ such that $x y^i z notin L$],
    Red[Lose], Green[Win],
    table.cell(colspan: 2, stroke: (top: 0.4pt))[#Green[${0^n 1^n}$ is *not* regular]],
  )
]

== Formal Proof: $0^n 1^n$ is Not Regular

#theorem[
  $L = { 0^n 1^n | n in NN }$ is not regular.
]

#proof[
  By contradiction.
  Assume that $L$ is regular.

  Let $n$ be the pumping length guaranteed by the weak pumping lemma ("there exists $n$...").
  Consider the string $w = 0^n 1^n$.
  Then $abs(w) = 2n >= n$ and $w in L$, so we can write (split) $w = x y z$ such that $y != epsilon$ and for any $i in NN$, we have $x y^i z in L$.

  We consider three cases:
  #enum(numbering: i => "Case " + str(i) + ":")[
    $y$ consists solely of $0$s.
    Then $x y^0 z = x z = 0^(n-abs(y)) 1^n$, and since $abs(y) > 0$, $x z notin L$.
  ][
    $y$ consists solely of $1$s.
    Then $x y^0 z = x z = 0^n 1^(n-abs(y))$, and since $abs(y) > 0$, $x z notin L$.
  ][
    $y$ consists of $k > 0$ $0$s followed by $m > 0$ $1$s.
    Then $x y^2 z = 0^n 1^m 0^k 1^n$, so $x y^2 z notin L$.
  ]
  In all three cases we reach a contradiction, so our assumption was wrong and $L$ is not regular.
]

== A Word of Caution

- The weak and full pumping lemmas describe a _necessary_ condition of regular languages.
  - If $L$ is _regular_, then it _passes_ the conditions of the pumping lemma.
  - If a language _fails_ the pumping lemma, it is _definitely not regular_.

- The weak and full pumping lemmas are _not sufficient_ conditions for regularity.
  - If $L$ is _not regular_, it still _may pass_ the conditions of the pumping lemma.
  - If a language _passes_ the pumping lemma, we _learn nothing_ about whether it is regular.

#Block(color: orange)[
  *Common mistake:* "The language satisfies the pumping lemma, therefore it is regular."
  This is _invalid_ reasoning!
  The pumping lemma is a _one-way_ test: it can only _disprove_ regularity, never _prove_ it.
]

== The Full Pumping Lemma

For the intuition behind the "full" pumping lemma, let's revisit our original observation.
- Let $D$ be a DFA with $n$ states.
- Any string $w$ accepted by $D$ of length at least $n$ must visit some state twice _within its first $n$_ symbols.
  - The number of visited states is equal to $n + 1$.
  - By the pigeonhole principle, some state is _duplicated_.
- The substring of $w$ between those _revisited states_ can be removed, duplicated, tripled, etc. without changing the fact that $D$ accepts $w$.

This gives us an _additional constraint_:
$
  abs(x y) <= n
$
This restriction means that the "pump" $y$ must occur _within the first $n$_ characters of $w$.

#align(center)[
  #cetz.canvas({
    import cetz.draw: *
    import finite.draw: state, transition

    set-style(state: (radius: 0.5, extrude: 0.8))

    state((.565, 0), "q0", initial: true, label: $q_0$)
    state((2, 0), "q1", label: $q_1$)
    state((3, 2), "q2", label: $q_2$)
    state((4, 0), "q3", label: $q_3$)
    state((6, 0), "q4", label: $q_4$, final: true)
    state((3, 4), "q5", label: $q_5$)

    transition("q0", "q1", inputs: 0, curve: 0.001)
    transition("q0", "q5", inputs: 1, curve: 1.2, stroke: (dash: "dashed"))
    transition("q1", "q1", inputs: 0, curve: 0.5, anchor: bottom)
    transition("q1", "q2", inputs: 1, curve: 0.5)
    transition("q2", "q5", inputs: 0, curve: 0, stroke: (dash: "dashed"))
    transition("q2", "q3", inputs: 1, curve: 0.5)
    transition("q3", "q1", inputs: 0, curve: 0)
    transition("q3", "q4", inputs: 1, curve: 0.001)
    transition("q4", "q5", inputs: (0, 1), curve: -1.2, stroke: (dash: "dashed"))
    transition("q5", "q5", inputs: (0, 1), curve: 0.5, stroke: (dash: "dashed"))
  })
  $
    q_0
    to^0 q_1
    to^1 q_2
    to^1 q_3
    to^0 q_1
    to^1 q_2
    to^1 q_3
    to^0 q_1
    to^1 q_2
    to^1 q_3
    to^0 q_1
    to^1 q_2
    to^1 q_3
    to^1 q_4
  $
]

== Formal Proof: Equal 0s and 1s

Consider the language $L$ over $Sigma = {0, 1}$ of strings $w in Sigma^*$ that contain _an equal number_ of $0$s and $1$s.

For example:
- #Green[`01`] in $L$
- #Red[`11011`] not in $L$
- #Green[`110010`] in $L$

#theorem[
  $L = { w in {0,1}^* | w "has an equal number of 0s and 1s" }$ is _not regular_.
]

#proof[
  By contradiction.
  Assume that $L$ is regular.

  Let $n$ be the pumping length guaranteed by the full pumping lemma.
  Consider the string $w = 0^n 1^n$.
  Then $abs(w) = 2n >= n$ and $w in L$.
  Therefore, there exist strings $x$, $y$, and $z$ such that $w = x y z$, $abs(x y) <= n$, #box[$y != epsilon$], and for any $i in NN$, we have $x y^i z in L$.

  Since $abs(x y) <= n$, $y$ must consist solely of $0$s.
  But then $x y^2 z = 0^(n+abs(y)) 1^n$, and since $abs(y) > 0$, $x y^2 z notin L$.

  We have reached a contradiction, so our assumption was wrong and $L$ is not regular.
]

#note[
  This language _cannot_ be shown to be non-regular using the _weak_ pumping lemma alone (it passes the weak version!).
  The constraint $abs(x y) <= n$ from the full version is essential.
]

== More Non-Regular Language Proofs

Let's apply the pumping lemma to a few more interesting languages.

== Palindromes Over {0,1}

#definition[
  A _palindrome_ is a string that reads the same forwards and backwards.
  Let $"PAL" = { w in {0,1}^* | w = w^R }$ where $w^R$ is the reversal of $w$.
]

#theorem[
  $"PAL"$ is not regular.
]

#proof[
  Assume $"PAL"$ is regular. Let $n$ be the pumping length.
  Consider $w = 0^n 1 0^n$. Note $w in "PAL"$ and $abs(w) = 2n+1 >= n$.
  By the pumping lemma, $w = x y z$ with $y != epsilon$, $abs(x y) <= n$, and $x y^i z in "PAL"$ for all $i$.

  Since $abs(x y) <= n$, $y$ consists only of $0$s from the first block.
  Pumping $y$ (say $i=2$) gives $x y^2 z = 0^(n+k) 1 0^n$ where $k = abs(y) > 0$.
  This string is not a palindrome because the first block has $n+k$ zeros while the last block has $n$ zeros.
  Contradiction.
]

== Strings with More 0s than 1s

#definition[
  Let $"MORE0" = { w in {0,1}^* | w "has more 0s than 1s" }$.
]

#theorem[
  $"MORE0"$ is not regular.
]

#proof[
  Assume regularity. Let $n$ be pumping length.
  Consider $w = 0^n 1^n$. Note $w notin "MORE0"$ (equal counts). Wait, we need a string *in* the language.
  Instead, use $w = 0^(n+1) 1^n$, which is in $"MORE0"$ and has length $2n+1 >= n$.
  By pumping lemma, $w = x y z$ with $abs(x y) <= n$, $y$ consists of $0$s only.
  Pumping down ($i=0$) gives $x z = 0^(n+1-abs(y)) 1^n$. Since $abs(y) > 0$, the number of $0$s becomes $<= n$, so not more than $1$s.
  Contradiction.
]

== Strings with Unequal Counts

#definition[
  Let $"UNEQUAL" = { w in {0,1}^* | w "has different number of 0s and 1s" }$.
]

#theorem[
  $"UNEQUAL"$ is not regular.
]

#proof[
  Note that $"UNEQUAL" = overline("EQUAL")$, the complement of the language of strings with equal 0s and 1s.
  Since $"EQUAL"$ is not regular (proved earlier), and regular languages are closed under complement, $"UNEQUAL"$ cannot be regular either.
  (If $"UNEQUAL"$ were regular, its complement $"EQUAL"$ would also be regular — contradiction.)
]

== Contrast: A Regular Language That Seems Complex

#definition[
  Let $"DIV7" = { w in {0,1}^* | w "interpreted as binary number is divisible by 7" }$.
]

#theorem[
  $"DIV7"$ is regular.
]

#proof[
  Construct a DFA with 7 states representing the remainder modulo 7.
  As we read each bit $b in {0,1}$, update the remainder: $r_"new" = (2 * r_"old" + b) mod 7$.
  Accept if final remainder is 0.
  This DFA has exactly 7 states, so $"DIV7"$ is regular.
]

#Block(color: green)[
  *Key insight:* The pumping lemma helps prove non-regularity, but some languages that seem complex (like binary numbers divisible by 7) are actually regular because they only require *bounded memory* (the remainder).
]

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7: Myhill-Nerode Theorem
// ═══════════════════════════════════════════════════════════════════════════════

== Myhill-Nerode Theorem: A Fundamental Characterization

While the pumping lemma gives a _necessary_ condition for regularity, the Myhill-Nerode theorem provides a _necessary and sufficient_ condition. It connects regular languages to equivalence relations with finite index.

#definition[
  Given a language $L subset.eq Sigma^*$, define the _Myhill-Nerode equivalence relation_ $equiv_L$ on $Sigma^*$ as:
  $
    x equiv_L y quad "iff" quad forall z in Sigma^*. (x z in L iff y z in L)
  $

  That is, two strings $x$ and $y$ are equivalent if _no distinguishing extension_ $z$ can tell them apart with respect to $L$.
]

#example[
  Let $L = { w in {0,1}^* | w "ends with 01" }$.
  - Strings $"001"$ and $"101"$ are equivalent: for any $z$, both $"001"z$ and $"101"z$ end with 01 iff $z$ is empty.
  - Strings $"00"$ and $"0"$ are _not_ equivalent: take $z = "1"$, then $"00""1" = "001" in L$ but $"0""1" = "01" notin L$.
]

#theorem[Myhill-Nerode Theorem][
  A language $L$ is regular if and only if $equiv_L$ has _finite index_ (finitely many equivalence classes).

  Moreover, the number of equivalence classes equals the number of states in the _minimal DFA_ for $L$.
]

#proof[(Intuition)][
  - ($=>$) If $L$ is regular, accepted by DFA $M$ with states $Q$. Define $f: Sigma^* to Q$ by $f(w) = hat(delta)(q_0, w)$. Then $f(x) = f(y)$ implies $x equiv_L y$, so index is at most $|Q|$.
  - ($<=$) If $equiv_L$ has finite index $n$, construct DFA with states = equivalence classes. Transition on symbol $a$: $[x] ->^a [x a]$. Accepting: classes $[w]$ with $w in L$.
]

== Connection to Minimal DFAs

The Myhill-Nerode theorem provides a direct way to construct the _unique minimal DFA_ for a regular language:

#definition[
  To build minimal DFA for $L$:
  1. Compute equivalence classes of $equiv_L$
  2. States = these classes
  3. Start state = $[epsilon]$
  4. Accepting states = ${[w] | w in L}$
  5. Transitions on symbol $a$: $[x] ->^a [x a]$
]

#example[
  For $L = { w | w "has odd number of 1s" }$ over ${0,1}$:
  - Two equivalence classes: $C_0$ = strings with even \# of 1s, $C_1$ = strings with odd \# of 1s
  - Minimal DFA: 2 states, toggling on 1
]

== Proving Non-regularity with Myhill-Nerode

To prove $L$ is _not_ regular using Myhill-Nerode, exhibit an _infinite set of pairwise distinguishable strings_.

#definition[
  Strings $x_1, x_2, ...$ are _pairwise $L$-distinguishable_ if for all $i != j$, there exists $z$ such that exactly one of $x_i z$, $x_j z$ is in $L$.
]

#theorem[
  If there exists an infinite set of pairwise $L$-distinguishable strings, then $equiv_L$ has infinite index, so $L$ is not regular.
]

#example[${0^n 1^n | n >= 0}$ is not regular][
  Consider strings $x_i = 0^i$ for $i = 0, 1, 2, ...$

  For $i < j$, take $z = 1^i$. Then:
  - $x_i z = 0^i 1^i in L$
  - $x_j z = 0^j 1^i notin L$ (since $j > i$)

  Thus ${0^i}$ is infinite and pairwise distinguishable, so $L$ is not regular.
]

#example[${w w | w in {0,1}^*}$ is not regular][
  Consider strings $x_i = 0^i 1$ for $i = 0, 1, 2, ...$

  For $i < j$, take $z = 0^i 1$. Then:
  - $x_i z = 0^i 1 0^i 1 = (0^i 1)(0^i 1) in L$
  - $x_j z = 0^j 1 0^i 1 notin L$ (can't be written as $w w$)

  Infinite pairwise distinguishable set, so not regular.
]

== Comparison: Pumping Lemma vs Myhill-Nerode

#align(center)[
  #table(
    columns: 3,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Method*], [*Strength*], [*Application*]),
    [Pumping Lemma], [Necessary condition only], [Can disprove regularity, cannot prove it],
    [Myhill-Nerode], [Necessary and sufficient], [Can both prove and disprove regularity],
    [Pumping Lemma], [Constructive counterexample], [Game: adversary chooses split, you choose pump],
    [Myhill-Nerode], [Structural characterization], [Exhibit infinite distinguishable set],
    [Pumping Lemma], [Based on pigeonhole principle], [Focuses on long strings in the language],
    [Myhill-Nerode], [Based on equivalence relations], [Focuses on distinguishing extensions],
  )
]

#Block(color: blue)[
  *Key insight:* While the pumping lemma is often taught first due to its simpler game-like structure, the Myhill-Nerode theorem provides a deeper understanding of _why_ some languages aren't regular and directly connects to the minimal automaton.
]

== Visualizing Equivalence Classes

For a regular language, the equivalence classes correspond to states in the minimal DFA:

#align(center)[
  #cetz.canvas({
    import cetz.draw: *

    // Diagram showing equivalence classes merging into DFA states
    set-style(fill: none)

    // Equivalence classes as circles
    circle((0, 0), radius: 0.8, stroke: blue.darken(30%))
    circle((2, 0), radius: 0.8, stroke: blue.darken(30%))
    circle((4, 0), radius: 0.8, stroke: blue.darken(30%))
    circle((6, 0), radius: 0.8, stroke: blue.darken(30%))

    content((0, 0))[$[epsilon]$]
    content((2, 0))[$[0]$]
    content((4, 0))[$[00]$]
    content((6, 0))[$dots$]

    // Arrows showing transitions
    line((0.8, 0), (1.2, 0), stroke: 1pt, mark: (end: ">"))
    line((2.8, 0), (3.2, 0), stroke: 1pt, mark: (end: ">"))
    line((4.8, 0), (5.2, 0), stroke: 1pt, mark: (end: ">"))

    content((1, -0.7))[0]
    content((3, -0.7))[0]
    content((5, -0.7))[0]

    // DFA on the bottom
    translate((0, -3))

    circle((1, 0), radius: 0.5, stroke: green.darken(40%), fill: green.lighten(90%))
    circle((3, 0), radius: 0.5, stroke: green.darken(40%), fill: green.lighten(90%))
    circle((5, 0), radius: 0.5, stroke: green.darken(40%), fill: green.lighten(90%))

    content((1, 0))[$q_0$]
    content((3, 0))[$q_1$]
    content((5, 0))[$q_2$]

    line((1.5, 0), (2.5, 0), stroke: 1pt, mark: (end: ">"))
    line((3.5, 0), (4.5, 0), stroke: 1pt, mark: (end: ">"))
    line((5.3, 0), (5.7, 0), stroke: 1pt, mark: (end: ">"))
    line((5.7, 0), (5.3, 0), stroke: 1pt, mark: (end: ">"))

    content((2, -0.7))[0]
    content((4, -0.7))[0]
    content((5.5, 0.7))[0]

    // Labels
    content((0, 1.2))[Equivalence Classes]
    content((1, -1.7))[Minimal DFA States]
  })
]

#Block(color: yellow)[
  *Historical note:* The theorem is named after John Myhill and Anil Nerode, who independently discovered it in the late 1950s. It provides one of the most elegant characterizations of regular languages.
]


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 8: Closure and Decision Properties
// ═══════════════════════════════════════════════════════════════════════════════

= Closure and Decision Properties

#focus-slide()

== Closure of Regular Languages

#theorem[
  The class $"REG"$ is closed under all the following operations:
+ The _union_ of two regular languages is regular.
+ The _intersection_ of two regular languages is regular.
+ The _complement_ of a regular language is regular.
+ The _difference_ of two regular languages is regular.
+ The _reversal_ of a regular language is regular.
+ The _Kleene star_ of a regular language is regular.
+ The _concatenation_ of regular languages is regular.
+ A _homomorphism_ (substitution of strings for symbols) of a regular language is regular.
+ The _inverse homomorphism_ of a regular language is regular.
]

#Block(color: yellow)[
  Closure properties are a _powerful tool_ for proving languages are (or are not) regular.
  Instead of building automata from scratch, we can _compose_ known regular languages using these operations.
]

== Closure under Union

#theorem[
  If $L$ and $M$ are regular languages, then so is their union $L union M$.
]

#proof[
  Since $L$ and $M$ are regular, they have regular expressions, i.e. $L = lang(R)$ and $M = lang(S)$.

  Then $L union M = lang(R + S)$ by the definition of the union ($+$) operator for regular expressions.
]

#v(1em)
#align(center)[
  #cetz.canvas({
    import cetz.draw: *
    import finite.draw: state, transition

    set-style(state: (radius: 0.2, extrude: 0.6))

    group({
      state((0, 0), "q0", label: none, initial: (label: none))
      state((1, 0), "q1", label: none, final: true)
      state((0, -1), "q2", label: none)
      rect((-1, -1.5), (1.5, .5), name: "A", radius: 0.1)
      content("A.south-west", padding: .5em, anchor: "south-west")[$A$]
    })

    group({
      translate((0, -2.5))
      state((0, 0), "q0", label: none, initial: (label: none))
      state((1, 0), "q1", label: none)
      state((0, -1), "q2", label: none, final: true)
      rect((-1, -1.5), (1.5, .5), name: "B", radius: 0.1)
      content("B.south-west", padding: .5em, anchor: "south-west")[$B$]
    })

    group({
      translate((5, 0))
      group(name: "A", {
        state((-0.5, 0), "q0", label: none, initial: false)
        state((1, 0), "q1", label: none, final: true)
        state((0, -1), "q2", label: none)
        rect((-1, -1.5), (1.4, .4), name: "B", radius: 0.1, stroke: 0.2pt)
      })
      group(name: "B", {
        translate((0, -2.5))
        state((-0.5, 0), "q0", label: none, initial: false)
        state((1, 0), "q1", label: none)
        state((0, -1), "q2", label: none, final: true)
        rect((-1, -1.4), (1.4, .5), name: "B", radius: 0.1, stroke: 0.2pt)
      })
      state((-1.5, -1.5), "x", label: none, initial: (label: none))
      rect((-2.5, -4), (1.5, .5), name: "C", radius: 0.1)
      content("C.south-west", padding: .5em, anchor: "south-west")[$A union B$]
      transition("x", "A.q0", label: $epsilon$, curve: 0.1)
      transition("x", "B.q0", label: $epsilon$, curve: -0.1)
    })
  })
]

== Closure under Complement

#theorem[
  If $L$ is a regular language over the alphabet $Sigma$, then its complement $overline(L) = Sigma^* - L$ is also a regular language.
]

#proof[
  Let $L = lang(A)$ for some DFA $A = (Q, Sigma, delta, q_0, F)$.
  Then $overline(L) = lang(B)$, where $B$ is the DFA $(Q, Sigma, delta, q_0, Q - F)$.
  That is, $B$ is exactly like $A$, but with the accepting states _flipped_.
  Then $w$ is in $overline(L)$ if and only if $delta(q_0, w)$ is in $Q - F$, which occurs if and only if $w$ is not in $lang(A)$.
]

#example[
  The DFA $A$ below on the left accepts only the strings of 0's and 1's that end in $regex("01")$, $lang(A) = regex("(0+1)*01")$.
  The complement of $lang(A)$ is all strings of 0's and 1's that _do not_ end in $regex("01")$.
  Below on the right is the automaton for ${0,1}^* - lang(A)$.

  #v(1em)
  #place(center)[
    #cetz.canvas({
      import cetz.draw: *
      import finite.draw: state, transition

      set-style(state: (radius: 0.5, extrude: 0.8))

      let aut(complement) = group({
        state((0.566, 0), "q0", label: $q_0$, initial: true, final: complement)
        state((2, 0), "q1", label: $q_1$, final: complement)
        state((4, 0), "q2", label: $q_2$, final: not complement)

        transition("q0", "q1", inputs: 0, curve: 0)
        transition("q0", "q0", inputs: 1, curve: 0.5)
        transition("q1", "q1", inputs: 0, curve: 0.5)
        transition("q1", "q2", inputs: 1, curve: 0.5)
        transition("q2", "q1", inputs: 0, curve: 0.001)
        transition("q2", "q0", inputs: 1, curve: 1)
      })

      aut(false)
      translate((8, 0))
      aut(true)
    })
  ]
]

== Closure under Intersection

#theorem[
  If $L$ and $M$ are regular languages, then so is their intersection $L intersect M$.
]

#proof[(simple)][
  $L intersect M = overline(overline(L) union overline(M))$.
]
#proof[
  We can directly construct a "product" DFA for the intersection of two regular languages.

  Let $L$ and $M$ be the languages of automata $A_L = (Q_L, Sigma, delta_L, q_L, F_L)$ and $A_M = (Q_M, Sigma, delta_M, q_M, F_M)$.

  For $L intersect M$, we construct the automaton $A$ that simulates both $A_L$ and $A_M$.
  The states of $A$ are the product of the states of $A_L$ and $A_M$.
  The initial state is $(q_L, q_M)$, and the accepting states are $F_L times F_M$.
  The transitions: $delta(chevron.l p, q chevron.r, c) = chevron.l delta_L (p, c), delta_M (q, c) chevron.r$.

  $A$ accepts $w$ iff both $A_L$ and $A_M$ accept $w$.
]

#example[
  The first automaton accepts all strings that _have a 0_.
  The second accepts all strings that _have a 1_.
  The product automaton accepts the _intersection_: all strings that _have both a 0 and a 1_.

  #align(center)[
    #cetz.canvas({
      import cetz.draw: *
      import finite.draw: state, transition

      set-style(state: (radius: 0.5, extrude: 0.8))

      group({
        state((0, 0), "p", label: $p$, initial: true)
        state((2, 0), "q", label: $q$, final: true)

        transition("p", "q", inputs: 0, curve: 0.001)
        transition("p", "p", inputs: 1, curve: 0.5)
        transition("q", "q", inputs: (0, 1), curve: 0.5)
      })

      translate((5, 0))

      group({
        state((0, 0), "r", label: $r$, initial: true)
        state((2, 0), "s", label: $s$, final: true)

        transition("r", "s", inputs: 1, curve: 0.001)
        transition("r", "r", inputs: 0, curve: 0.5)
        transition("s", "s", inputs: (0, 1), curve: 0.5)
      })

      translate((5, 1))

      group({
        state((0, 0), "pr", label: $p r$, initial: true)
        state((2, 0), "ps", label: $p s$)
        state((0, -2), "qr", label: $q r$)
        state((2, -2), "qs", label: $q s$, final: true)

        transition("pr", "qr", inputs: 0, curve: 0)
        transition("pr", "ps", inputs: 1, curve: 0.001)
        transition("ps", "qs", inputs: 0, curve: 0)
        transition("ps", "ps", inputs: 1, curve: 0.5)
        transition("qr", "qr", inputs: 0, curve: 0.5, anchor: left)
        transition("qr", "qs", inputs: 1, curve: 0.001)
        transition("qs", "qs", inputs: (0, 1), curve: 0.5, anchor: right)
      })
    })
  ]
]

== Closure under Difference and Reversal

#theorem[
  If $L$ and $M$ are regular languages, then so is their difference $L minus M$.
]

#proof[
  $L minus M = L intersect overline(M)$.
  By previous theorems, $overline(M)$ is regular, and $L intersect overline(M)$ is also regular.
]

#definition[
  The _reversal_ of a string $w = a_1 a_2 dots a_n$ is the string $w^R = a_n a_(n-1) dots a_1$.
]

#definition[
  The _reversal_ of a language $L$ is the language $L^R = { w^R | w in L }$.
]

#theorem[
  If $L$ is a regular language, then so is its reversal $L^R$.
]

#proof[
  Structural induction on the regular expression $E$ defining $L$:
  - _Basis:_ If $E$ is $epsilon$, $emptyset$, or $regex("a")$, then $E^R = E$.
  - _Induction:_ $E = E_1 + E_2 => E^R = E_1^R + E_2^R$; $quad E = E_1 E_2 => E^R = E_2^R E_1^R$; $quad E = E_1^* => E^R = (E_1^R)^*$. #qedhere
]

== Decision Properties

#columns(2)[
  *Converting among representations*
  - $epsilon$-closure: $O(n^3)$
  - $epsilon$-NFA to DFA: $n^3 2^n$
  - DFA to $epsilon$-NFA: $O(n)$
  - $epsilon$-NFA to RegEx: $O(n^3 4^n)$
  - RegEx to $epsilon$-NFA: $O(n)$

  #colbreak()

  *Decidable questions about $"REG"$*
  + Is the language _empty_? $O(n^2)$
  + Is the language _finite_? $O(n^2)$
  + Is $w$ _in_ the language? $O(abs(w))$ for DFAs
  + Is $L subset.eq M$? Decidable
  + Is $L = M$? Decidable
]

#theorem[
  The language $L$ accepted by a finite automaton with $n$ states is _non-empty_ iff the finite automaton accepts a word of length less than $n$.
]

#theorem[
  The language $L$ accepted by a finite automaton $M$ with $n$ states is _infinite_ iff the automaton accepts some word of length $l$, where $n <= l < 2n$.
]


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 9: Beyond Regular Languages
// ═══════════════════════════════════════════════════════════════════════════════

= Beyond Regular Languages

#focus-slide(
  epigraph: [The good thing about regular languages is everything is decidable. \ The bad thing is they can't express much.],
  scholars: (
    (
      name: "Noam Chomsky",
      image: image("assets/Noam_Chomsky.jpg"),
    ),
  ),
)

== What Regular Languages Cannot Do

We have seen several non-regular languages:
- $L = { 0^n 1^n | n in NN }$ --- requires _counting_ to match $0$s and $1$s.
- $"EQUAL" = { w "#" w | w in {0,1}^* }$ --- requires _remembering_ an entire string.
- $L = { w in {0,1}^* | w "has equal number of 0s and 1s" }$ --- requires a _counter_.

The common pattern: regular languages cannot _count_ beyond a bounded amount.
A DFA has only _finitely many states_, so it cannot track _unbounded_ quantities.

#Block(color: yellow)[
  *Fundamental limitation:* A finite automaton is a machine with _constant memory_.
  It can remember only a _bounded_ amount of information about the input it has read.
]

== Context-Free Languages

To recognize languages like ${ a^n b^n | n >= 0 }$, we need more power: a _stack_.

#definition[
  A _context-free grammar_ (CFG) is a 4-tuple $G = (V, Sigma, R, S)$ where:
  - $V$ is a finite set of _variables_ (non-terminals),
  - $Sigma$ is a finite set of _terminals_ (disjoint from $V$),
  - $R subset.eq V times (V union Sigma)^*$ is a finite set of _production rules_,
  - $S in V$ is the _start symbol_.
]

#example[
  The CFG $G$ with rules $S -> 0 S 1 | epsilon$ generates $L = { 0^n 1^n | n >= 0 }$.

  Derivation of $000111$:
  $
    S => 0 S 1 => 0 0 S 1 1 => 0 0 0 S 1 1 1 => 000111
  $
]

#Block(color: blue)[
  Context-free grammars are the foundation of _programming language syntax_.
  Every compiler uses a CFG (or a variant) to parse source code.
  BNF notation used in language specifications _is_ a CFG.
]

== Pushdown Automata

#definition[
  A _Pushdown Automaton_ (PDA) is a 7-tuple $cal(P) = (Q, Sigma, Gamma, delta, q_0, Z_0, F)$ where:
  - $Q$ is a finite set of states,
  - $Sigma$ is the _input alphabet_,
  - $Gamma$ is the _stack alphabet_,
  - $delta: Q times (Sigma union {epsilon}) times Gamma to power(Q times Gamma^*)$ is the _transition function_,
  - $q_0 in Q$ is the _start state_,
  - $Z_0 in Gamma$ is the _initial stack symbol_,
  - $F subset.eq Q$ is the set of _accepting states_.
]

A PDA is like an NFA with an additional _stack_ that it can push to and pop from.

#note[
  The transition function reads the current state, the next input symbol (or $epsilon$), and the _top of the stack_.
  It then transitions to a new state and _replaces_ the top stack symbol with a string of stack symbols.
]

#example[
  A PDA for $L = { 0^n 1^n | n >= 0 }$:
  - On reading $0$: push a marker onto the stack.
  - On reading $1$: pop a marker from the stack.
  - Accept if the stack is empty when the input is exhausted.
]

== The Context-Free Hierarchy

#theorem[
  A language is context-free if and only if it is recognized by some pushdown automaton.
]

Context-free languages are _strictly more powerful_ than regular languages:
- Every regular language is context-free (a DFA is a PDA that ignores its stack).
- ${ a^n b^n | n >= 0 }$ is context-free but not regular.

However, context-free languages still have limits:
- ${ a^n b^n c^n | n >= 0 }$ is _not_ context-free (can be shown via a pumping lemma for CFLs).

#align(center)[
  #cetz.canvas({
    import cetz.draw: *
    circle((0, 0), radius: (1, .6), fill: green.transparentize(90%), stroke: green.darken(20%))
    circle((0, 0.5), radius: (1.5, 1.2), fill: blue.transparentize(90%), stroke: blue.darken(20%))
    content((0, 0), text(size: 0.8em)[Regular])
    content((0, 1.1), text(size: 0.8em)[Context-Free])
  })
]


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 10: Turing Machines
// ═══════════════════════════════════════════════════════════════════════════════

= Turing Machines

#focus-slide(
  epigraph: [We may compare a man in the process of computing ...to a machine.],
  epigraph-author: "Alan Turing, 1936",
  scholars: (
    (
      name: "Stephen Cook",
      image: image("assets/Stephen_Cook.jpg"),
    ),
  ),
)

== Motivation

Finite automata have _constant memory_ (finitely many states). \
Pushdown automata have a _stack_ (LIFO memory). \
What if we give the machine _unrestricted read/write access_ to a tape?

This leads us to the _Turing machine_ --- the most general model of computation we will study.

#Block(color: yellow)[
  *The fundamental question:* What problems can be solved _algorithmically_?
  Turing machines give us a precise mathematical framework to answer this.
]

== Turing Machine --- Definition

#definition[
  A _Turing Machine_ (TM) is a 7-tuple $cal(M) = (Q, Sigma, Gamma, delta, q_0, q_"accept", q_"reject")$ where:
  - $Q$ is a finite set of states,
  - $Sigma$ is the _input alphabet_ (not containing the blank symbol $Blank$),
  - $Gamma$ is the _tape alphabet_, where $Blank in Gamma$ and $Sigma subset Gamma$,
  - $delta: Q times Gamma to Q times Gamma times {L, R}$ is the _transition function_,
  - $q_0 in Q$ is the _start state_,
  - $q_"accept" in Q$ is the _accept state_,
  - $q_"reject" in Q$ is the _reject state_ ($q_"reject" != q_"accept"$).
]

#note[
  A Turing machine differs from finite automata in several crucial ways:
  - The tape is _infinite_ (unbounded in both directions).
  - The head can move _both left and right_.
  - The machine can _write_ to the tape.
  - The machine _halts_ when it enters $q_"accept"$ or $q_"reject"$.
]

== Turing Machine --- Visualization

A Turing machine operates on an infinite tape divided into cells, each containing a symbol from $Gamma$.

#align(center)[
  #cetz.canvas({
    import cetz.draw: *

    // Draw tape cells
    let n = 11
    let cell-size = 0.7
    for i in range(n) {
      rect(
        (i * cell-size, 0),
        ((i + 1) * cell-size, cell-size),
        stroke: 0.5pt,
        fill: if i >= 2 and i <= 6 { blue.lighten(90%) } else { luma(95%) },
      )
    }

    // Tape content
    content((0.5 * cell-size, 0.5 * cell-size))[$Blank$]
    content((1.5 * cell-size, 0.5 * cell-size))[$Blank$]
    content((2.5 * cell-size, 0.5 * cell-size))[$0$]
    content((3.5 * cell-size, 0.5 * cell-size))[$1$]
    content((4.5 * cell-size, 0.5 * cell-size))[$1$]
    content((5.5 * cell-size, 0.5 * cell-size))[$0$]
    content((6.5 * cell-size, 0.5 * cell-size))[$1$]
    content((7.5 * cell-size, 0.5 * cell-size))[$Blank$]
    content((8.5 * cell-size, 0.5 * cell-size))[$Blank$]
    content((9.5 * cell-size, 0.5 * cell-size))[$Blank$]
    content((10.5 * cell-size, 0.5 * cell-size))[$Blank$]

    // Dots at ends
    content((-0.3, 0.5 * cell-size))[$dots$]
    content((n * cell-size + 0.3, 0.5 * cell-size))[$dots$]

    // Head
    let head-pos = 4.5 * cell-size
    line((head-pos, -0.2), (head-pos, -0.6), stroke: 1pt, mark: (start: ">", fill: black))

    // State label
    content((head-pos, -0.9), text(fill: blue.darken(30%))[State $q_3$])

    // Annotation: input region
    line((2 * cell-size, cell-size + 0.2), (7 * cell-size, cell-size + 0.2), stroke: 0.5pt + blue.darken(20%), mark: (start: "|", end: "|"))
    content((4.5 * cell-size, cell-size + 0.5), text(size: 0.8em, fill: blue.darken(20%))[Input $w$])
  })
]

The machine starts with the input $w$ written on the tape, the head on the leftmost symbol, in state $q_0$.
At each step:
+ Read the symbol under the head.
+ Based on the current state and symbol, the transition function determines:
  - The _new state_ to enter.
  - The _symbol to write_ in the current cell.
  - The _direction to move_ the head ($L$ or $R$).

== Turing Machine --- Computation

#definition[
  A _configuration_ of a TM is a triple: the current state, the tape contents, and the head position.
  We write configurations as $u q v$, where $q$ is the current state, $u$ is the tape content to the left of the head, and $v$ is the tape content starting at the head position.
]

#definition[
  A TM $cal(M)$ on input $w$:
  - _Accepts_ $w$ if the computation reaches $q_"accept"$.
  - _Rejects_ $w$ if the computation reaches $q_"reject"$.
  - _Loops_ if it never halts (neither accepts nor rejects).
]

#definition[
  The language _recognized_ by $cal(M)$ is:
  $
    lang(cal(M)) = { w in Sigma^* | cal(M) "accepts" w }
  $
]

#Block(color: orange)[
  *Warning:* Unlike DFAs, a Turing machine may _never halt_ on some inputs.
  "Not accepted" and "rejected" are _different_ --- the machine might just run forever.
]

== Turing Machine --- Example

#example[
  A TM that recognizes $L = { 0^n 1^n | n >= 0 }$:

  *Idea:* Repeatedly scan the tape, crossing off one $0$ and one $1$ in each pass.

  + Scan right from the leftmost uncrossed $0$. If no $0$ found, check that no $1$ remains --- if so, _accept_.
  + Cross off this $0$ (replace with $times$).
  + Continue scanning right to find the leftmost uncrossed $1$. If no $1$ found, _reject_.
  + Cross off this $1$ (replace with $times$).
  + Move the head back to the left end of the tape.
  + Repeat from step 1.

  === Step-by-Step Visualization for Input $0011$

  Let's trace the computation visually. Each diagram shows the tape contents (with $Blank$ symbols omitted for clarity) and the head position (marked with state $q_i$ above the cell).

  #grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    // Step 1: Initial configuration
    table(
      columns: 5,
      stroke: 0.5pt,
      align: center,
      table.header([*Step 1: Initial*], [], [], [], []),
      [$q_0$], [], [], [], [],
      [$0$], [$0$], [$1$], [$1$], [$Blank$],
      [↑], [], [], [], [],
    ),
    // Step 2: After crossing off first 0
    table(
      columns: 5,
      stroke: 0.5pt,
      align: center,
      table.header([*Step 2*], [], [], [], []),
      [], [$q_1$], [], [], [],
      [$times$], [$0$], [$1$], [$1$], [$Blank$],
      [], [↑], [], [], [],
    ),
    // Step 3: Scanning right to first 1
    table(
      columns: 5,
      stroke: 0.5pt,
      align: center,
      table.header([*Step 3*], [], [], [], []),
      [], [], [$q_1$], [], [],
      [$times$], [$0$], [$1$], [$1$], [$Blank$],
      [], [], [↑], [], [],
    ),
    // Step 4: Crossing off first 1
    table(
      columns: 5,
      stroke: 0.5pt,
      align: center,
      table.header([*Step 4*], [], [], [], []),
      [], [], [], [$q_2$], [],
      [$times$], [$0$], [$times$], [$1$], [$Blank$],
      [], [], [], [↑], [],
    ),
    // Step 5: Moving head left
    table(
      columns: 5,
      stroke: 0.5pt,
      align: center,
      table.header([*Step 5*], [], [], [], []),
      [], [$q_3$], [], [], [],
      [$times$], [$0$], [$times$], [$1$], [$Blank$],
      [], [↑], [], [], [],
    ),
    // Step 6: Back to start
    table(
      columns: 5,
      stroke: 0.5pt,
      align: center,
      table.header([*Step 6*], [], [], [], []),
      [$q_3$], [], [], [], [],
      [$times$], [$0$], [$times$], [$1$], [$Blank$],
      [↑], [], [], [], [],
    ),
    // Step 7: Start second pass
    table(
      columns: 5,
      stroke: 0.5pt,
      align: center,
      table.header([*Step 7*], [], [], [], []),
      [], [$q_0$], [], [], [],
      [$times$], [$0$], [$times$], [$1$], [$Blank$],
      [], [↑], [], [], [],
    ),
    // Step 8: Cross off second 0
    table(
      columns: 5,
      stroke: 0.5pt,
      align: center,
      table.header([*Step 8*], [], [], [], []),
      [], [], [$q_1$], [], [],
      [$times$], [$times$], [$times$], [$1$], [$Blank$],
      [], [], [↑], [], [],
    ),
    // Step 9: Scan to second 1
    table(
      columns: 5,
      stroke: 0.5pt,
      align: center,
      table.header([*Step 9*], [], [], [], []),
      [], [], [], [$q_1$], [],
      [$times$], [$times$], [$times$], [$1$], [$Blank$],
      [], [], [], [↑], [],
    ),
    // Step 10: Cross off second 1
    table(
      columns: 5,
      stroke: 0.5pt,
      align: center,
      table.header([*Step 10*], [], [], [], []),
      [], [], [], [], [$q_2$],
      [$times$], [$times$], [$times$], [$times$], [$Blank$],
      [], [], [], [], [↑],
    ),
    // Step 11: Move left and accept
    table(
      columns: 5,
      stroke: 0.5pt,
      align: center,
      table.header([*Step 11: Accept*], [], [], [], []),
      [], [], [], [$q_3$], [],
      [$times$], [$times$], [$times$], [$times$], [$Blank$],
      [], [], [], [↑], [],
    ),
  )

  *Explanation:*
  1. Start with tape $0011$, head at leftmost cell, state $q_0$.
  2. Replace first $0$ with $times$, move right, state $q_1$.
  3. Scan right past $0$ to first $1$.
  4. Replace that $1$ with $times$, move right, state $q_2$.
  5. Move head left to previous cell, state $q_3$.
  6. Move head left again to start.
  7. Start second pass: scan right for uncrossed $0$, find it at position 2.
  8. Cross off that $0$.
  9. Scan right for uncrossed $1$, find it at position 4.
  10. Cross off that $1$.
  11. Move left, check for remaining $1$s (none), transition to accept.

  Formal trace (same as above): \
  $
    q_0 thin 0011 => times q_1 thin 011 => times 0 q_1 thin 11 => times 0 times q_2 thin 1 => times q_3 thin 0 times 1 => q_3 thin times 0 times 1 => times q_0 thin 0 times 1 => dots.c => "accept"
  $

  #Block(color: blue)[
    *Visual insight:* The TM uses the tape as a _scratch space_ to mark processed symbols. Each pass reduces the problem size until all symbols are crossed off, showing the count of $0$s equals count of $1$s.
  ]
]

== TM vs DFA vs PDA --- Comparison

#align(center)[
  #table(
    columns: 4,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Feature*], [*DFA*], [*PDA*], [*TM*]),
    [Memory], [Finite (states only)], [Stack (LIFO)], [Infinite tape],
    [Head movement], [Left to right only], [Left to right only], [Both directions],
    [Write?], [No], [Push/pop stack], [Yes (arbitrary)],
    [Halting], [Always halts], [Always halts], [May loop forever],
    [Languages], [Regular], [Context-free], [Recursively \ enumerable],
  )
]

#Block(color: teal)[
  *Historical context:* Alan Turing introduced his machine model in 1936, before electronic computers existed.
  He was trying to formalize the notion of "mechanical procedure" to resolve Hilbert's _Entscheidungsproblem_ (decision problem).
  The Turing machine remains the gold standard model of computation.
]

== Variants of Turing Machines

Several variants of TMs exist, all _equivalent in power_:
- _Multi-tape TMs:_ multiple tapes with independent heads.
- _Non-deterministic TMs:_ $delta$ returns a _set_ of possible transitions.
- _Two-way infinite tape:_ tape extends infinitely in both directions.
- _Multi-track tape:_ each cell holds a tuple of symbols.

#theorem[
  Every multi-tape TM can be simulated by a single-tape TM.
]
#theorem[
  Every non-deterministic TM can be simulated by a deterministic TM.
]

#note[
  These simulations may involve a _polynomial_ (multi-tape) or _exponential_ (non-deterministic) slowdown, but they always terminate.
]

#Block(color: blue)[
  *Connection:* The equivalence of deterministic and non-deterministic TMs is _not_ about efficiency.
  Whether they can solve the same problems _efficiently_ is the famous *P vs NP* problem --- one of the most important open questions in mathematics and computer science.
]

== Church--Turing Thesis

#theorem(title: "Thesis")[
  Every "effectively computable" function is computable by a Turing machine.
]

This is a _thesis_, not a theorem --- it cannot be proved mathematically because "effectively computable" is an informal notion.
However, every formal model of computation ever proposed has turned out to be _equivalent_ to Turing machines:
- Lambda calculus (Church, 1936)
- Recursive functions (Gödel, Kleene)
- Post systems (Post, 1936)
- Register machines
- Modern programming languages (C, Python, Haskell, ...)

#Block(color: yellow)[
  The Church--Turing thesis says that Turing machines capture _everything_ that can be computed.

  If a problem cannot be solved by a TM, it cannot be solved by _any_ mechanical procedure --- regardless of the programming language or hardware.
]

== Decidability and Recognizability

#definition[
  A language $L$ is _Turing-recognizable_ (or _recursively enumerable_, *RE*) if some TM _recognizes_ $L$.
  That is, the TM accepts every $w in L$, and either rejects or loops on $w notin L$.
]

#definition[
  A language $L$ is _decidable_ (or _recursive_, *R*) if some TM _decides_ $L$.
  That is, the TM halts on _every_ input: it accepts $w in L$ and rejects $w notin L$.
]

#definition[
  A language $L$ is _co-recognizable_ (*co-RE*) if its complement $overline(L)$ is Turing-recognizable.
]

#theorem[
  A language $L$ is decidable iff $L in "RE"$ and $L in "co-RE"$, i.e., $"R" = "RE" intersect "co-RE"$.
]

#columns(2)[
  #cetz.canvas({
    import cetz.draw: *
    // RE circle (blue, upper)
    circle((0, 2.4), radius: (4, 2.8), stroke: blue.darken(20%))
    // co-RE circle (red, lower)
    circle((0, 1.2), radius: (4, 2.8), stroke: red.darken(20%))
    // Chomsky hierarchy nested inside intersection
    circle((0, 0), radius: (0.8, 0.4))
    circle((0, 0.4), radius: (1.4, 0.8))
    circle((0, 0.8), radius: (2, 1.2))
    // circle((0, 1.2), radius: (2.6, 1.6))
    content((0, 0), text(size: .7em)[Regular])
    content((0, 0.8), text(size: .7em)[CF])
    content((0, 1.6), text(size: .7em)[CS])
    content((0, 3), text(size: .65em, fill: purple)[R = RE $intersect$ co-RE])
    content((0, 4.8), text(size: .7em, fill: blue.darken(20%))[RE])
    content((0, -0.9), text(size: .7em, fill: red.darken(20%))[co-RE])
    // Problem instances
    circle((2.5, 2.5), radius: 3pt, fill: yellow.darken(10%))
    content((2.5, 2.5), anchor: "north-west", padding: 4pt, text(size: .7em)[SAT])
    circle((1, 4.3), radius: 3pt, fill: yellow.darken(10%))
    content((1, 4.3), anchor: "south-west", padding: 4pt, text(size: .7em)[HALT])
    circle((2.5, 5.4), radius: 3pt, fill: yellow.darken(10%))
    content((2.5, 5.4), anchor: "south-west", padding: 4pt, text(size: .7em)[REGULAR])
  })

  #colbreak()

  *Class overview:*
  - *Regular* $subset$ *CF* $subset$ *CS* $subset$ *R* $subset$ *RE* --- the Chomsky hierarchy
  - *R* = *RE* $intersect$ *co-RE* --- decidable languages
  - *HALT* $in$ *RE* $setminus$ *R* --- recognizable but _not_ decidable; TM accepts but may loop
  - *SAT* $in$ *R* --- decidable (exhaustive search); NP-complete
  - *REGULAR* $in$ {"neither RE nor co-RE"} --- no TM can even confirm or deny it
]

#Block(color: orange)[
  *Warning:* Decidable $subset.neq$ Recognizable.
  There exist languages that are recognizable but _not_ decidable (e.g., HALT).
  There also exist languages that are _not even recognizable_ (e.g., $overline("HALT")$, $"REGULAR"_"TM"$).
]

== The Halting Problem

#definition[Halting Problem][
  Given a TM $cal(M)$ and an input $w$, does $cal(M)$ halt on $w$?

  $
    "HALT" = { angle.l cal(M), w angle.r | cal(M) "is a TM that halts on input" w }
  $
]

#theorem[
  $"HALT"$ is _undecidable_.
]

#proof[
  By _diagonalization_.
  Assume for contradiction that some TM $H$ decides $"HALT"$.
  Construct a TM $D$ that, on input $angle.l cal(M) angle.r$:
  + Run $H$ on $angle.l cal(M), angle.l cal(M) angle.r angle.r$.
  + If $H$ accepts (i.e., $cal(M)$ halts on $angle.l cal(M) angle.r$), then _loop forever_.
  + If $H$ rejects, then _accept_.

  Now consider $D$ on input $angle.l D angle.r$:
  - If $D$ halts on $angle.l D angle.r$, then $H$ accepts, so $D$ loops. Contradiction.
  - If $D$ does not halt on $angle.l D angle.r$, then $H$ rejects, so $D$ accepts (halts). Contradiction.

  In either case we get a contradiction, so $H$ cannot exist.
]

#Block(color: yellow)[
  *Key insight:* There exist well-defined mathematical problems that _no algorithm can solve_.

  This is not a limitation of current technology --- it is a _fundamental_ impossibility.

  The proof uses the same diagonal argument as Cantor's proof that $RR$ is uncountable.
]

== Rice's Theorem

The Halting Problem is just one undecidable problem. Rice's theorem shows that _any_ non-trivial property of what a TM computes is undecidable.

#definition[Semantic property][
  A property $P$ of Turing machines is _semantic_ if it depends only on the _language recognized_ by the TM, not on its internal structure.
  Formally: if $cal(L)(M_1) = cal(L)(M_2)$, then $P(M_1) iff P(M_2)$.

  A semantic property is _non-trivial_ if some TMs satisfy it and some do not.
]

#example[
  - "_$cal(L)(M)$ is finite_" --- semantic (about the language), non-trivial.
  - "_$cal(L)(M)$ is regular_" --- semantic, non-trivial ($"REGULAR"_"TM"$).
  - "_$cal(L)(M) = emptyset$_" --- semantic, non-trivial ($"EMPTY"_"TM"$).
  - "_$M$ has at most 5 states_" --- *not* semantic (depends on machine, not its language).
]

#theorem[Rice's Theorem][
  Every non-trivial semantic property of TMs is undecidable.
  That is, if $P$ is non-trivial and semantic, then ${ angle.l M angle.r | P(M) }$ is undecidable.
]

#proof[
  Assume WLOG that $P(M_emptyset) = "false"$ (where $cal(L)(M_emptyset) = emptyset$).
  Since $P$ is non-trivial, some $M_P$ satisfies $P(M_P) = "true"$.

  Reduce HALT to $P$: given $angle.l M, w angle.r$, build $M'$ that on input $x$:
  + Simulate $M$ on $w$. If $M$ halts and accepts, simulate $M_P$ on $x$.

  Then $M$ halts on $w$ $imply$ $cal(L)(M') = cal(L)(M_P)$ $imply$ $P(M') = "true"$; \
  and $M$ does not halt on $w$ $imply$ $cal(L)(M') = emptyset$ $imply$ $P(M') = "false"$.

  A decider for $P$ would decide HALT --- contradiction.
]

#Block(color: orange)[
  *Consequence:* No algorithm can answer any of these questions about an arbitrary program:
  - _"Does this program terminate on all inputs?"_
  - _"Does this program's output match its specification?"_
  - _"Are these two programs equivalent?"_
  Every interesting behavioral property is undecidable in general.
]

== The Landscape of Computability

#align(center)[
  #import fletcher: diagram, edge, node
  #diagram(
    spacing: (2em, 2em),
    node-shape: fletcher.shapes.rect,
    node-corner-radius: 3pt,
    edge-stroke: 0.8pt,
    blob((0, 0), [*DFA* \ finite memory], name: <dfa>, tint: green),
    blob((1, 0), [*PDA* \ stack memory], name: <pda>, tint: blue),
    blob((2, 0), [*TM* (decider) \ infinite tape, always halts], name: <dec>, tint: purple),
    blob((3, 0), [*TM* (recognizer) \ may not halt], name: <rec>, tint: orange),
    edge(<dfa>, <pda>, "-}>"),
    edge(<pda>, <dec>, "-}>"),
    edge(<dec>, <rec>, "-}>"),
  )
]

#align(center)[
  #table(
    columns: 3,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Language Class*], [*Machine*], [*Closure*]),
    [Regular], [DFA/NFA], [All Boolean operations],
    [Context-Free], [PDA], [Union, concat, star; \ not intersection or complement],
    [Decidable], [TM (decider)], [All Boolean operations],
    [Recognizable], [TM (recognizer)], [Union, intersection; \ not complement],
  )
]

== Summary

+ *Formal languages* provide a mathematical framework for computation: every problem is a language.

+ *Regular languages* (DFA $=$ NFA $=$ RegExp) are the simplest class --- powerful enough for pattern matching, too weak for counting.

+ *The Pumping Lemma* is the primary tool for proving languages are _not_ regular.

+ *Context-free languages* (CFG $=$ PDA) add a stack, enabling matching and nesting.

+ *Turing machines* capture _everything_ computable, with an infinite read/write tape.

+ *Decision problems are languages:* the set of "yes" inputs of any decision problem defines a formal language.

+ *The Halting Problem* shows that some problems are _fundamentally undecidable_.

+ *Rice's Theorem:* every non-trivial semantic property of TM behavior is undecidable.

+ The _language hierarchy_ organizes classes as: $"R" = "RE" intersect "co-RE"$, and
$
  "Regular" subset.neq "Context-Free" subset.neq "Decidable" subset.neq "RE" subset.neq "All Languages"$

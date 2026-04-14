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

#let tm-snapshot(
  tape,
  head: 0,
  state: none,
  focus: none,
  cell-size: 0.8,
  show-dots: false,
  caption: none,
) = {
  let n = tape.len()

  cetz.canvas({
    import cetz.draw: *

    for i in range(n) {
      let active = focus != none and i >= focus.at(0) and i <= focus.at(1)
      rect(
        (i * cell-size, 0),
        ((i + 1) * cell-size, cell-size),
        stroke: 0.5pt,
        fill: if active { blue.lighten(90%) } else { luma(95%) },
      )
    }

    let pos(i, j) = {
      let x = (i + 0.5) * cell-size
      let y = (0.5 - j) * cell-size
      (x, y)
    }

    for i in range(n) {
      let p = pos(i, 0)
      content(p, tape.at(i))
    }

    if show-dots {
      content(pos(-1, 0), $dots$)
      content(pos(n, 0), $dots$)
    }

    let head-pos = (head + 0.5) * cell-size
    line((head-pos, -0.08), (head-pos, -0.6), stroke: 1pt, mark: (start: ">", fill: black))

    if state != none {
      content((head-pos, -0.6), anchor: "north", padding: 0.1, Blue[state])
    }

    if focus != none and caption != none {
      let (x, y) = focus
      line(
        (x * cell-size, cell-size + 0.2),
        ((y + 1) * cell-size, cell-size + 0.2),
        stroke: 0.8pt + blue.darken(20%),
        mark: (start: "|", end: "|"),
      )
      content(
        ((x + y + 1) * 0.5 * cell-size, cell-size + 0.45),
        text(size: 0.8em, fill: blue.darken(20%))[#caption],
      )
    }
  })
}

#let tm-frame(
  title,
  tape,
  head: 0,
  state: none,
  focus: none,
  show-dots: false,
  caption: none,
) = box(
  inset: 1em,
  radius: 5pt,
  stroke: 0.5pt + luma(70%),
  fill: luma(98%),
)[
  #align(center)[*#title*]
  #align(center)[
    #tm-snapshot(
      tape,
      head: head,
      state: state,
      focus: focus,
      show-dots: show-dots,
      caption: caption,
    )
  ]
]

#let tm-excerpt(title, tape, head: 0, state: none) = tm-frame(
  title,
  tape,
  head: head,
  state: state,
  show-dots: true,
)

#CourseOverviewPage2()


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
      name: "Claude Shannon",
      image: image("assets/Claude_Shannon.jpg"),
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
  - $L_1 union L_2 = {w mid(|) w in L_1 or w in L_2}$, the _union_ of $L_1$ and $L_2$
  - $overline(L) = {w mid(|) w notin L} = Sigma^* setminus L$, the _complement_ of $L$
  - $abs(L)$ is the _cardinality_ of $L$

- _Concatenation_:
  - $L_1 dot L_2 = {a b mid(|) a in L_1, b in L_2}$, where $a b$ is the concatenation of words $a$ and $b$.
  - $L^k = underbrace(L dot dots dot L, k "times") = { w_1 w_2 dots w_k mid(|) w_i in L }$
  - $L^0 = {epsilon}$

- _Kleene star_: $L^* = limits(union.big)_(k = 0)^infinity L^k$

== Chomsky Hierarchy

Formal languages are classified by _Chomsky hierarchy_ --- a nested family of increasingly powerful language classes, each recognized by a correspondingly more powerful machine.

#align(center)[
  #table(
    columns: 4,
    align: (center, left, left, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Type*], [*Class*], [*Machine*], [*Example*]),
    [3], [Regular], [Finite Automata], [${ a^n mid(|) n >= 0 }$],
    [2], [Context-Free], [Pushdown Automata], [${ a^n b^n mid(|) n >= 0 }$],
    [1], [Context-Sensitive], [Linear-Bounded TMs], [${ a^n b^n c^n mid(|) n >= 0 }$],
    [0], [Recursively Enumerable], [Turing Machines], [${ angle.l M, w angle.r mid(|) M "halts on" w }$],
  )
]

#align(center)[
  #cetz.canvas({
    import cetz.draw: *
    circle((0, 0), radius: (1, 0.6))
    circle((0, 0.6), radius: (1.6, 1.2))
    circle((0, 1.2), radius: (2.4, 1.8))
    circle((0, 1.8), radius: (3, 2.4))
    content((0, 0))[Regular]
    content((0, 1.1))[Context-Free]
    content((0, 2.3))[Context-Sensitive]
    content((0, 3.4))[Recursively Enumerable]
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

  Deciding the problem means deciding membership in the language $L$.
]

#v(1em)
#place[
  #block(width: 100%)[
    *Satisfiability (SAT):* Given a Boolean formula $phi$, is it satisfiable?
    $ "SAT" = { phi mid(|) phi "is a satisfiable Boolean formula" } $

    *Validity (VALID):* Given a Boolean formula $phi$, is it a tautology?
    $ "VALID" = { phi mid(|) phi "is a valid (universally true) formula" } $

    *Halting Problem (HALT):* Given a TM $M$ and input $w$, does $M$ halt on $w$?
    $ "HALT" = { angle.l M, w angle.r mid(|) "TM" M "halts on input" w } $
  ]
]
#pagebreak()

#Block(color: yellow)[
  Asking "is $w$ in $L$?" and asking "does the algorithm say yes on input $w$?" are _the same question_.

  This lets us use the theory of _formal languages_ to study the limits of _computation_.
]


= Regular Languages
#focus-slide(
  epigraph: [A language that doesn't affect the way you think about programming, \ is not worth knowing.],
  epigraph-author: "Alan Perlis",
  scholars: (
    (
      name: "Ken Thompson",
      image: image("assets/Ken_Thompson.jpg"),
    ),
    (
      name: "Stephen Kleene",
      image: image("assets/Stephen_Kleene.jpg"),
    ),
    (
      name: "Marcel-Paul Schützenberger",
      image: image("assets/Marcel-Paul_Schutzenberger.jpg"),
    ),
    (
      name: "Alfred Aho",
      image: image("assets/Alfred_Aho.jpg"),
    ),
    (
      name: "John Hopcroft",
      image: image("assets/John_Hopcroft.jpg"),
    ),
    (
      name: "Jeffrey Ullman",
      image: image("assets/Jeffrey_Ullman.jpg"),
    ),
  ),
)

== Regular Languages

#definition[
  A class of regular languages $"REG"$ is defined inductively:
  - $"Reg"_0 = { emptyset, {epsilon} } union { {a} mid(|) a in Sigma }$, the _empty_ and _singleton_ languages.
  - $"Reg"_(i+1) = "Reg"_i union { A union B mid(|) A, B in "Reg"_i } union { A dot B mid(|) A, B in "Reg"_i } union { A^* mid(|) A in "Reg"_i }$, \ the inductively extended $(i+1)$-th _generation_ of regular languages.
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

== Summary of Regular Expressions

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

== Reading Regular Expressions

#example[
  $regex("(a|bc)*") = {epsilon, "a", "aa", "aaa", dots, "bc", "bcbc", "bcbcbc", dots, "abc", "bca", "abca", "abcbc", "bcabc", dots}$
]

#example[
  $regex("0(10)*1") = {"01", "0101", "010101", dots}$
]

See also: PCRE #href("https://en.wikipedia.org/wiki/Perl_Compatible_Regular_Expressions")

#Block(color: yellow)[
  *Key insight:* Regular expressions describe _exactly_ the regular languages.
  This is not obvious --- it takes Kleene's Theorem (stated later) to prove it.
]


= Finite Automata
#focus-slide(
  epigraph: [We may hope that machines will eventually compete with men \ in all purely intellectual fields.],
  epigraph-author: "Alan Turing",
  scholars: (
    (
      name: "Warren McCulloch",
      image: image("assets/Warren_McCulloch.jpg"),
    ),
    (
      name: "Walter Pitts",
      image: image("assets/Walter_Pitts.jpg"),
    ),
    (
      name: "Victor Glushkov",
      image: image("assets/Victor_Glushkov.jpg"),
    ),
    (
      name: "Janusz Brzozowski",
      image: image("assets/Janusz_Brzozowski.jpg"),
    ),
    (
      name: "Michael Rabin",
      image: image("assets/Michael_Rabin.jpg"),
    ),
    (
      name: "Dana Scott",
      image: image("assets/Dana_Scott.jpg"),
    ),
    // (
    //   name: "George Mealy",
    //   image: image("assets/George_Mealy.jpg"),
    // ),
    // (
    //   name: "Edward Moore",
    //   image: image("assets/Edward_Moore.jpg"),
    // ),
  ),
)

== Recognizers and Transducers

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

== Example of a DFA

#example[
  Automaton $cal(A)$ recognizing strings with an even number of 0s, $lang(cal(A)) = { w in {0,1}^* mid(|) w "has even number of 0s" }$.

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

== Computation in a DFA

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
  A configuration is a complete snapshot of the computation: once the current state and the remaining input are fixed, the future behavior is determined.
]

== Automata Languages

#definition[
  A word $w in Sigma^*$ is _accepted_ by an automaton $cal(A)$ if the computation, starting in the initial configuration at state $q_0$ with input $w$, _can reach the final configuration $conf(f, epsilon)$_, where $f in F$ is any accepting state, and $epsilon$ denotes that the input has been fully consumed.

  Formally, $cal(A)$ _accepts_ $w in Sigma^*$ if $conf(q_0, w) scripts(tack)^* conf(f, epsilon)$ for some $f in F$.
]

#definition[
  The language _recognized_ by an automaton $cal(A)$ is a set of all words accepted by $cal(A)$.
  $
    lang(cal(A)) = { w in Sigma^* mid(|) conf(q_0, w) scripts(tack)^* conf(f, epsilon) "where" f in F }
  $
]

#definition[
  The class of _automaton languages_ recognized by DFAs is denoted $"AUT"$.
  $
    "AUT" = { X mid(|) exists cal(A) "such that" lang(cal(A)) = X }
  $
]

== DFA Exercises

For each language below (over the alphabet $Sigma = {0, 1}$), draw a DFA recognizing it:
+ $L_1 = {"101", "110"}$
+ $L_2 = Sigma^* setminus {"101", "110"}$
+ $L_3 = {w mid(|) w "starts and ends with the same bit"}$
+ $L_4 = {"110"}^* = {epsilon, "110", "110110", "110110110", dots}$
+ $L_5 = {w mid(|) w "contains 110 as a substring"}$


= Non-deterministic Automata
#focus-slide()

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

== Example of an NFA

Consider the following NFA recognizing $lang(cal(A)) = Sigma^* (110^*)^+$ --- the strings containing at least one `11` followed by any number of `0`s:

#[
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

If an NFA needs to make a non-existent transition (for example, at $q_1$ on input $0$), that computation branch simply terminates and rejects.

== Determinism and Non-determinism

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

A non-deterministic machine can be imagined as making an idealized correct guess whenever an accepting branch exists.
This is only an intuition; actual machines must simulate the branching explicitly.

*3. Massive Parallelism*

An NFA can be thought of as a machine that tries _all possibilities in parallel_, using an unlimited number of "processors".
Each symbol read causes a transition on every currently active state.

== Tree Computation

#align(center)[
  #let aut = (
    q0: (q1: "a", q3: "b"),
    q1: (q2: "b", q4: "b"),
    q2: (),
    q3: (q4: "a"),
    q4: (q4: ("a", "b"), q5: "a"),
    q5: (),
  )
  #grid(
    columns: 2,
    align: center + horizon,
    column-gutter: 4em,
    [
      #finite.automaton(
        aut,
        final: ("q2", "q5"),
        style: (
          state: (radius: 0.5, extrude: 0.8),
          transition: (curve: 0.5),
          q0: (label: $0$),
          q1: (label: $1$),
          q2: (label: $2$),
          q3: (label: $3$),
          q4: (label: $4$),
          q5: (label: $5$),
          q0-q1: (curve: 0.001),
          q0-q3: (curve: 0.001),
          q1-q2: (curve: 0.001),
          q1-q4: (curve: 0.001),
          q3-q4: (curve: 0.001),
          q4-q5: (curve: 0.001),
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
    ],
    [
      #box(stroke: 1pt, inset: 1em, radius: .5em, fill: blue.lighten(80%))[
        *Input:* \
        $w = "a b a b a"$
      ]
    ],
  )
]

#Block(color: yellow)[
  *How to read this:* each time there are multiple outgoing transitions, the NFA branches into multiple active computations.
]

== Accepting Branches

#[
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
  #align(center)[
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
  ]
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
    lang(cal(A)) = { w in Sigma^* mid(|) conf(q_0, w) scripts(tack)^* conf(f, epsilon), f in F }
  $
]

== DFAs and NFAs

#align(center)[
  #table(
    columns: 2,
    align: left,
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
  *Why NFAs?*

  Despite having the same expressive power as DFAs, NFAs are often _exponentially more concise_.

  They are also the natural output of many constructions (e.g., Thompson's construction).
]

== $epsilon$-NFA

#definition[
  An _$epsilon$-NFA_ is a 5-tuple $(Q, Sigma, delta, q_0, F)$ with the same components as an NFA, but with a modified transition function:
  $
    delta: Q times (Sigma union {epsilon}) to power(Q)
  $
  From any state the machine may follow _$epsilon$-transitions_ without consuming any input symbol.
]

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
  #v(-.5em)
  $
    E(q) = epsilon"-clo"(q) = { r in Q mid(|) #clo-aut }
  $
  This definition can be extended to the _sets of states_. For $P subset.eq Q$:
  $
    E(P) = union.big_(q in P) E(q)
  $
]

#note[
  $q in epsilon"-clo"(q)$ by reflexivity: every state is reachable from itself by an $epsilon$-path of length $0$.
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

$cal(A)_"N" = (Q_"N", Sigma, delta_"N", q_0, F_"N")$
- $Q_"N" = {q_1, q_2, ..., q_n}$
- $delta_"N" : Q_"N" times Sigma to power(Q_"N")$

$cal(A)_"D" = (Q_"D", Sigma, delta_"D", {q_0}, F_"D")$
- $Q_"D" = power(Q_"N") = {emptyset, {q_1}, dots, {q_2, q_4, q_5}, dots, Q_"N"}$
- $delta_"D" : Q_"D" times Sigma to Q_"D"$
- $delta_"D" : (A, c) maps { r mid(|) exists q in A. thin r in delta_"N" (q, c) }$
- $F_"D" = { A mid(|) A intersect F_"N" != emptyset }$

#Block(color: orange)[
  *Warning:* The powerset construction can produce _exponentially many_ states.

  An NFA with $n$ states can require a DFA with up to $2^n$ states.

  In practice, many of these states are unreachable and can be pruned.
]

== Converting an NFA to a DFA

We now examine a complete example of the powerset construction.

#example[
  Consider the NFA $cal(N)$ over alphabet $Sigma = {0, 1}$ that accepts strings ending with $01$:

  #let nfa-aut = (
    q0: (q0: 1, q1: 0),
    q1: (q2: 1),
    q2: (),
  )
  #let nfa-example = finite.automaton(
    nfa-aut,
    final: ("q2",),
    style: (
      state: (radius: 0.5, extrude: 0.8),
      transition: (curve: 0.5),
      q0: (label: $q_0$),
      q1: (label: $q_1$),
      q2: (label: $q_2$),
    ),
  )

  #align(center)[
    #nfa-example
  ]

  Formally, $cal(N) = (Q, Sigma, delta, q_0, F)$ where:
  - $Q = {q_0, q_1, q_2}$
  - $delta(q_0, 0) = {q_0, q_1}$, $delta(q_0, 1) = {q_0}$, $delta(q_1, 1) = {q_2}$, all other transitions go to $emptyset$
  - $q_0$ is start state
  - $F = {q_2}$
]

== Reachable States

We begin with the start state of the DFA: ${q_0}$.

Compute transitions from ${q_0}$:
- On $0$: $delta_D({q_0}, 0) = delta_N(q_0, 0) = {q_0, q_1}$
- On $1$: $delta_D({q_0}, 1) = delta_N(q_0, 1) = {q_0}$

Now we have new states ${q_0, q_1}$ and ${q_0}$. ${q_0}$ is already known.

== New Transitions

From ${q_0, q_1}$:
- On $0$: $delta_N(q_0, 0) union delta_N(q_1, 0) = {q_0, q_1} union emptyset = {q_0, q_1}$
- On $1$: $delta_N(q_0, 1) union delta_N(q_1, 1) = {q_0} union {q_2} = {q_0, q_2}$

New state: ${q_0, q_2}$

From ${q_0, q_2}$:
- On $0$: $delta_N(q_0, 0) union delta_N(q_2, 0) = {q_0, q_1} union emptyset = {q_0, q_1}$
- On $1$: $delta_N(q_0, 1) union delta_N(q_2, 1) = {q_0} union emptyset = {q_0}$

No new states.

== Accepting States

A DFA state is accepting if it contains any NFA accepting state:
- ${q_0}$: contains $q_0$? No ($q_0 notin F$). Not accepting.
- ${q_0, q_1}$: contains $q_2$? No. Not accepting.
- ${q_0, q_2}$: contains $q_2$? Yes ($q_2 in F$). Accepting.

== The Resulting DFA

We have three reachable states: $A = {q_0}$, $B = {q_0, q_1}$, $C = {q_0, q_2}$.

Transition table:
#table(
  columns: 4,
  align: (left, center, center, left),
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
#let dfa-example = finite.automaton(dfa-aut, final: ("C",), style: (
  state: (radius: 0.5, extrude: 0.8),
  transition: (curve: 0.5),
  A: (label: $A$),
  B: (label: $B$),
  C: (label: $C$),
  A-A: (curve: 0.5, loop: true),
  C-A: (curve: 2),
))

#align(center)[
  #dfa-example
]

== Verifying Equivalence

Both automata accept the same language: strings ending with $01$.
- The NFA has 3 states, the DFA has 3 reachable states (out of possible $2^3 = 8$).
- Unreachable states like ${q_1}$, ${q_2}$, ${q_1, q_2}$, ${q_0, q_1, q_2}$, $emptyset$ were never generated.

#Block(color: green)[
  *Observation:* Although the powerset construction can produce exponentially many states, many of them are often unreachable. In this example, the resulting DFA is no larger than the original NFA.
]

So far, we have studied three different _representations_ of languages: regular expressions, DFAs, and NFAs.
A natural question arises: Are these representations equivalent? Can they express the same set of languages?
Kleene's theorem answers this definitively.

= Kleene's Theorem
#focus-slide()

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

The diagram below shows the constructive conversions between the four equivalent representations.
Each arrow denotes an explicit algorithm.

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
  All four representations --- DFA, NFA, $epsilon$-NFA, and regular expressions --- are _equally powerful_.

  They describe exactly the same class of languages: the _regular languages_.
]

== Thompson's Construction

_Thompson's construction_ is a method of constructing an $epsilon$-NFA from a regular expression.

Prove $"REG" subset.eq "AUT"$ by induction over the _generation index $k$_.
Show that $forall k. thin "Reg"_k subset.eq "AUT"$.

*Base:* $k = 0$, construct automata for $"Reg"_0 = { emptyset, {epsilon}, {c} "for" c in Sigma }$.

#v(-0.5em)
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
                {a mid(|) delta(q_i, a) = q_j} & "if" i != j,
                {a mid(|) delta(q_i, a) = q_j} union {epsilon} & "if" i = j,
              )
$

#Block(color: teal)[
  Kleene's algorithm is structurally identical to the _Floyd--Warshall_ algorithm for shortest paths in graphs.
  Both use dynamic programming with "allowed intermediate nodes up to $k$".
]


= Limits of Finite Automata

#focus-slide(
  epigraph: [There are more things in heaven and earth, Horatio,\ than are dreamt of in your philosophy.],
  epigraph-author: "William Shakespeare",
)

== The Memory Bottleneck of Finite Automata

When does a language fail to be regular?
Finite automata (DFAs and NFAs) possess exactly one form of memory: *their current state*.

- A DFA with $n$ states can distinguish at most $n$ different "situations" at any point while reading a string.

- It *cannot count* indefinitely. \
  (e.g., verifying if there are exactly 1,000,000 zeros vs 1,000,001 zeros might require 1M states).

- It *cannot match* unbounded nested structures. \
  (e.g., balancing parentheses in code, checking `<html>` tags).

#Block(color: yellow)[
  *Key insight:* If a language requires unbounded memory to recognize
  (for example, keeping track of an arbitrarily large number), it *cannot be regular*.
]

To formalize this, we exploit the simplest consequence of finite state spaces: the *Pigeonhole Principle*.

== Re-visiting States

- Let $D$ be a DFA with $n$ states.
- Any string $w$ accepted by $D$ that has length at least $n$ will force the DFA to take at least $n$ transitions.
- Taking $n$ transitions means visiting $n + 1$ states.
- By the _Pigeonhole Principle_, because the DFA only has $n$ distinct states, *at least one state must be visited twice*.
- Thus, the execution path contains a *loop*. The substring of $w$ that drives the DFA around this loop can be repeated (pumped) as many times as we want, or skipped entirely!

#align(center)[
  #show: box.with(inset: -1em)
  #cetz.canvas({
    import cetz.draw: set-style
    import finite.draw: state, transition

    set-style(state: (radius: 0.5, extrude: 0.8))
    set-style(transition: (stroke: (dash: "dashed"), mark: (end: (symbol: ">", fill: black))))

    state((0, 0), "q1", initial: true, label: $q_1$)
    state((2, 0), "q2", label: $q_2$)
    state((4, 0), "q3", label: $q_3$, final: true)

    transition("q1", "q2", inputs: "x", label: $x$, curve: 0.001)
    transition("q2", "q3", inputs: "z", label: $z$, curve: 0.001)
    transition("q2", "q2", inputs: "y", label: $y$, curve: 0.8)
  })
]

Informally:
- Let $L$ be a regular language.
- If we have a string $w in L$ that is "sufficiently long", then we can _split_ the string into _three pieces_ and _"pump"_ the middle.
- We can write $w = x y z$ such that $x y^0 z$, $x y^1 z$, $x y^2 z$, ..., $x y^n z$, ... are all in $L$.

== Weak Pumping Lemma

#theorem[Weak Pumping Lemma for Regular Languages][
  Let $L$ be regular.
  Then there exists a purely structural constant #box[$n in NN$] (the *pumping length*), $n > 0$, such that for every "sufficiently long" $w in L$ with #box[$abs(w) >= n$],
  there are strings $x, y, z$ where $w = x y z$, and:
  1. $y != epsilon$ (the loop can't be empty)
  2. For every $i >= 0$, $x y^i z in L$ (the loop can be skipped or repeated)
]

#v(-0.5em)
$
  underbrace(q_0 dots, x) underbrace(q_k dots, y) underbrace(q_k dots, z) q_f
$
#v(-0.5em)
Here, $x$ is the path to the loop, $y$ is the loop itself, $z$ is the path from the loop to the final state.

#example[
  Let $Sigma = {0, 1}$ and $L = { w in Sigma^* mid(|) w "contains" 00 "as a substring" }$.
  Given any string of length $>= 3$ in $L$, we can find a substring to pump. For instance, in $w = 100$, we let $x=1, y=0, z=0$. The pumped strings $1 0^i 0$ still contain "00" safely!
]

#example[
  Let $Sigma = {0, 1}$ and $L = { epsilon, 0, 1, 00, 01, 10, 11 }$.
  The weak pumping lemma trivially holds with pumping length $n = 3$. There are *no* strings in $L$ of length $>= 3$, so the condition "for every $w in L$ with $abs(w) >= 3$..." is vacuously true!
]

== The Equality Language

#definition[
  The _equality problem_ is, given two strings $x$ and $y$, to decide whether $x = y$.
]

#example[
  Let $Sigma = {0, 1, hash}$.
  We can _encode_ the equality problem as a string of the form _$x hash y$_.
  - "Is _001_ equal to _110_ ?" would be _$001 hash 110$_.
  - "Is _11_ equal to _11_ ?" would be _$11 hash 11$_.

  Let $"EQUAL" = { w hash w mid(|) w in {0, 1}^* }$.

  *Question:* Is $"EQUAL"$ a _regular_ language?
]

#Block(color: orange)[
  *Strategy:* Assume regularity, choose $w = 0^n hash 0^n$, then pump to destroy equality.
]

== *$"EQUAL"$* is Not Regular

#theorem[
  $"EQUAL"$ is not a regular language.
]

#proof[
  By contradiction.
  Assume $"EQUAL"$ is regular, and let $n$ be the pumping length. \
  Take $w = 0^n hash 0^n in "EQUAL"$.
  Write $w = x y z$ as in the weak pumping lemma.

  The block $y$ cannot contain $hash$, because pumping with $i = 0$ would remove $hash$ and produce a string outside $"EQUAL"$.
  Hence $y$ lies entirely to the left or entirely to the right of $hash$, so $y = 0^k$ for some $k > 0$.

  We now pump with $i = 2$:
  #enum(numbering: i => "Case " + str(i) + ":")[
    $y$ is to the left of $hash$.
    Then $x y^2 z = 0^(n+k) hash 0^n notin "EQUAL"$.
  ][
    $y$ is to the right of $hash$.
    Then $x y^2 z = 0^n hash 0^(n+k) notin "EQUAL"$.
  ]
  In both cases we contradict the pumping lemma.
  Therefore $"EQUAL"$ is not regular.
]

#Block(color: blue)[
  A finite automaton cannot compare two unbounded strings for equality, because it has only finitely many states, i.e. it lacks "memory".
]

== The Classic Non-regular Language

#example[
  Consider the language $L = {0^n 1^n mid(|) n in NN}$.
  - $L = {epsilon, 01, 0011, 000111, 00001111, ...}$
  - $L$ is a classic example of a non-regular language.
  - *Intuitively:* if you have _only finitely many states_ in a DFA, you cannot _"remember"_ an arbitrary number of $0$s to match _the same_ number of $1$s.

  How would we prove that $L$ is non-regular?
]

#Block[
  Use the Pumping Lemma to show that $L$ _cannot_ be regular.
]

== Pumping Lemma as a Game

#Block(color: yellow)[
  The Pumping Lemma contains alternating quantifiers ($exists, forall, exists, forall$).

  Any such statement can be framed naturally as a *two-player game*.
]

It is useful to view the lemma as a game between a #Green[*prover*] and an #Red[*adversary*].
- The #Green[*prover*] tries to force a contradiction and show that the language is not regular.
- The #Red[*adversary*] tries to produce a legal pumping decomposition.

The interaction has four steps:
1. The #Red[adversary] chooses a pumping length $n$.
2. The #Green[prover] chooses a word $w in L$ with $abs(w) >= n$.
3. The #Red[adversary] chooses a decomposition $w = x y z$ with $y != epsilon$.
4. The #Green[prover] chooses $i >= 0$ and tries to force $x y^i z notin L$.

#pagebreak()

== Pumping Game for *$L = { 0^n 1^n mid(|) n in NN }$*

#align(center)[
  #table(
    columns: (auto, auto),
    align: (center, center),
    column-gutter: 1em,
    stroke: (x, y) => if y == 0 { (bottom: .8pt) },
    table.header([*#Red[Adversary]*], [*#Green[Prover]*]),
    [Choose pumping length $n$],
    [Select the witness string $w = 0^n 1^n in L$ with $abs(w) = 2n >= n$],
    [Choose a legal split $w = x y z$ with $y != epsilon$],
    [Analyze the possible forms of $y$],
    [Maintain the pumping claim],
    [Choose a pumping index $i$],
    [If $y$ contains only $0$s or only $1$s, take $i = 0$; if it mixes both, take $i = 2$],
    [Then $x y^i z notin L$ in every case],
    Red[Lose], Green[Win],
    table.cell(colspan: 2, stroke: (
      top: 0.4pt,
    ))[#Green[$0^n 1^n$ cannot satisfy the pumping conclusion uniformly, so it is not regular]],
  )
]

== Proof that *$0^n 1^n$* is Not Regular

#theorem[
  $L = { 0^n 1^n mid(|) n in NN }$ is not regular.
]

#proof[
  By contradiction.
  Assume that $L$ is regular.

  Let $n$ be the pumping length guaranteed by the weak pumping lemma ("there exists $n$...").
  Consider the string $w = 0^n 1^n$.
  Then $abs(w) = 2n >= n$ and $w in L$, so we can write (split) $w = x y z$ such that $y != epsilon$ and for any $i in NN$, we have $x y^i z in L$.

  #[
    #set enum(numbering: i => "Case " + str(i) + ":")

    + $y$ consists solely of $0$s.
      Then $x y^0 z = x z = 0^(n-abs(y)) 1^n$. \
      Since $abs(y) > 0$, the number of $0$s is less than $n$, so $x z notin L$.

    + $y$ consists solely of $1$s.
      Then $x y^0 z = x z = 0^n 1^(n-abs(y))$. \
      Since $abs(y) > 0$, the number of $1$s is less than $n$, so $x z notin L$.

    + $y$ consists of some $0$s followed by some $1$s.
      If we pump $y$ with $i = 2$, then $y^2 = y y$, which places $1$s from the first copy of $y$ *before* the $0$s of the second copy. \
      Thus the resulting string $x y^2 z$ is not even of the form $0^*1^*$, so it cannot be in $L$.
  ]

  In all three possible ways the adversary splits the string, we found a choice of $i$ giving a string outside $L$.
  This contradicts the weak pumping lemma. Thus $L$ is *not regular*.
]

== Cautionary Note

- The pumping lemma describes a _necessary_ condition for regularity.
  - Regularity $implies$ Pumping Lemma holds.
  - Pumping Lemma FAILS $implies$ Not Regular (by contrapositive).

- It is _not a sufficient_ condition.
  - Pumping Lemma holds $cancel(implies)$ Regularity.
  - There exist non-regular languages that still satisfy the pumping lemma.

#Block(color: orange)[
  *Warning:* "The language satisfies the pumping lemma, therefore it is regular."

  This is a logic error. The pumping lemma is a tool for disproving regularity, not for establishing it. To prove that a language is regular, one must construct a DFA, NFA, or regular expression.
]

== The Full Pumping Lemma

By the pigeonhole principle: any accepting path visiting $n+1$ states must revisit some state --- and this state repeat occurs _within the first $n$ steps_.

#theorem[Full Pumping Lemma for Regular Languages][
  Let $L$ be a regular language.
  Then there exists $n in NN$, $n > 0$, such that for every $w in L$ with $abs(w) >= n$,
  there exist strings $x, y, z$ with:
  - $w = x y z$,
  - $y != epsilon$,
  - $abs(x y) <= n$, and
  - for every $i in NN$, $x y^i z in L$.
]

#Block(color: yellow)[
  *Upgrade from the weak version:* the additional constraint $abs(x y) <= n$ forces the pump $y$ to lie within the first $n$ characters of $w$.
  This closes a loophole: some non-regular languages (such as #box[${ w mid(|) w "has equal 0s and 1s" }$)] pass the _weak_ lemma, but are caught by the _full_ version.
]

== A DFA View of the Pumping Lemma

#align(center)[
  #cetz.canvas({
    import cetz.draw: *
    import finite.draw: state, transition

    set-style(state: (radius: 0.5, extrude: 0.8), transition: (mark: (end: (symbol: ">", fill: black))))

    scale(85%)

    state((0, 0), "q0", initial: true, label: $q_0$)
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
]

#v(-1em)
$
  q_0
  thick underbrace(to^0, x = 0) thick q_1
  thick underbrace(to^1 q_2 to^1 q_3 to^0, y = 110) thick q_1
  thick underbrace(to^1 q_2 to^1 q_3 to^0, y = 110) thick q_1
  thick underbrace(to^1 q_2 to^1 q_3 to^0, y = 110) thick q_1
  thick underbrace(to^1 q_2 to^1 q_3 to^1, z = 111) thick q_4
$
#v(-.5em)

#note[
  The first repeated state is $q_1$, revisited on step 4, so $y = 110$ lies within the first $n = 6$ symbols.
  Here $x = 0$, and pumping $y$ preserves acceptance until the suffix $z$ reaches $q_4$.
]

== Equal Numbers of 0s and 1s

Consider the language $L$ over $Sigma = {0, 1}$ of strings $w in Sigma^*$ that contain _an equal number_ of $0$s and $1$s.

For example, #Green[`01`] in $L$, #Red[`11011`] not in $L$, #Green[`110010`] in $L$.

#theorem[
  $L = { w in {0,1}^* mid(|) w "has an equal number of 0s and 1s" }$ is _not regular_.
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

== Palindromes Over *${0,1}$*

#definition[
  A _palindrome_ is a string that reads the same forwards and backwards.

  Let $"PAL" = { w in {0,1}^* mid(|) w = w^R }$ where $w^R$ is the reversal of $w$.
]

#theorem[
  $"PAL"$ is not regular.
]

#proof[
  Assume $"PAL"$ is regular, with pumping length $n$.
  Choose the string $w = 0^n 1 0^n$.
  Then $w in "PAL"$ and $abs(w) = 2n+1 >= n$.

  By the full pumping lemma, there exist strings $x, y, z$ such that $w = x y z$ and:
  - $y != epsilon$ (the loop is real)
  - $abs(x y) <= n$ (the loop happens entirely within the first $n$ characters)

  Since the first $n$ characters of $w$ are all $0$s, the string $y$ must be $0^k$ for some $k > 0$.
  Choosing $i = 2$ gives $x y^2 z = 0^(n+k) 1 0^n$, which is not a palindrome.
  This contradicts the lemma, so $"PAL"$ is not regular.
]

#pagebreak()

#example[
  For $n = 3$: the string $000100$ is a palindrome. The pumping lemma gives us $x y z$ with $abs(x y) <= 3$.
  The $y$ part is some prefix of $000$, say $y = 00$. Then:
  - $x y z$ (original): $000100$ #YES (palindrome)
  - $x y^2 z$ (pumped): $00000100$ #NO (not a palindrome: 5 leading zeros but only 2 trailing zeros)
]

== Strings with More 0s than 1s

#definition[
  Let $"MORE0" = { w in {0,1}^* mid(|) w "has strictly more 0s than 1s" }$.
]

#theorem[
  $"MORE0"$ is not regular.
]

#proof[
  Assume regularity, and let $n$ be the pumping length.
  Choose the string $w = 0^(n+1) 1^n$.
  - It clearly has $n+1 > n$ zeros, so $w in "MORE0"$.
  - Its length $2n+1 >= n$, so it works.

  The adversary splits $w = x y z$ such that $abs(x y) <= n$.
  The first $n$ characters of $w$ are all $0$s. Thus, $y$ captures exactly $k$ zeros (where $k > 0$).

  If we choose $i = 2$, the number of $0$s increases, so that does not help.
  Instead, choose $i = 0$ and delete the block $y$.
  Our modified string is $x z = 0^(n+1-k) 1^n$.
  Since $k >= 1$, the remaining zeros are at most $n$.

  The new string has at most $n$ zeros, but it still has exactly $n$ ones.
  Therefore it does not have strictly more $0$s than $1$s, so it is not in $"MORE0"$.
  This is a contradiction.
]

== Strings with Unequal Counts

#definition[
  Let $"UNEQUAL" = { w in {0,1}^* mid(|) w "has different number of 0s and 1s" }$.
]

#theorem[
  $"UNEQUAL"$ is not regular.
]

#proof[
  Note that $"UNEQUAL" = overline("EQUAL")$, the complement of the language of strings with equal 0s and 1s.
  Since $"EQUAL"$ is not regular (proved earlier), and regular languages are closed under complement, $"UNEQUAL"$ cannot be regular either.
  (If $"UNEQUAL"$ were regular, its complement $"EQUAL"$ would also be regular — contradiction.)
]

== A Complex-Looking Regular Language

#definition[
  Let $"DIV7" = { w in {0,1}^* mid(|) w "interpreted as binary number is divisible by 7" }$.
]

#theorem[
  $"DIV7"$ is regular.
]

#proof[
  Construct a DFA with 7 states representing the remainder modulo 7.
  As we read each bit #box[$b in {0,1}$], update the remainder: $r_"new" = (2 dot r_"old" + b) mod 7$.
  Accept if final remainder is 0.
]

#Block(color: yellow)[
  *Key insight:* The pumping lemma proves non-regularity. Some languages that seem complex are actually regular because they require only _bounded memory_.
  Here, the 7 states encode the remainder --- that's enough. EQUAL requires _unbounded_ memory (count of 0s), so it cannot be regular.
]


== Intuition Behind the Myhill-Nerode Theorem

The pumping lemma studies _loops_ in long computations.
The Myhill-Nerode theorem studies something even more basic: when two prefixes are _indistinguishable_ to a finite automaton.

Suppose a DFA has read two different prefixes $x$ and $y$ and, after each of them, ends in the same state.
From that moment on, the machine has exactly the same future behavior on both inputs.
No suffix can reveal which prefix was read earlier, because the automaton remembers only its current state.

#Block(color: yellow)[
  *Key insight:* If a language forces the machine to keep infinitely many different prefixes apart, then no finite automaton can recognize it.
]

== The Equivalence Relation

#definition[
  Let $L subset.eq Sigma^*$.
  Define a relation $scripts(equiv)_L$ on $Sigma^*$ by
  $
    x scripts(equiv)_L y quad "iff" quad forall z in Sigma^*. thin (x z in L iff y z in L).
  $

  Thus $x scripts(equiv)_L y$ means that _every_ suffix $z$ has the same effect on $x$ and on $y$.
  In other words, $x$ and $y$ are indistinguishable with respect to membership in $L$.
]

#example[
  Let $L = { w in {0,1}^* mid(|) w "ends with 01" }$.

  - The strings $001$ and $101$ are equivalent: both already end with $01$, so after appending any suffix $z$, the membership of $001 z$ and $101 z$ depends only on $z$, not on the earlier prefix.
  - The strings $0$ and $01$ are distinguishable: take $z = epsilon$. Then $0 z = 0 notin L$, but $01 z = 01 in L$.
]

== The Myhill-Nerode Theorem

#theorem[Myhill-Nerode Theorem][
  A language $L$ is regular if and only if the relation $scripts(equiv)_L$ has finite index, that is, only finitely many equivalence classes.

  Moreover, the number of equivalence classes is exactly the number of states in the minimal DFA for $L$.
]

#proof[(idea)][
  _($arrow.r.double$)_ Assume $L$ is regular, and let a DFA $A$ with state set $Q$ recognize it.
  Every string $w in Sigma^*$ sends the start state to one state of $Q$.
  If two strings $x$ and $y$ lead to the same state, then for every suffix $z$ the automaton behaves identically on $x z$ and $y z$.
  Hence $x scripts(equiv)_L y$.
  Therefore there can be at most $|Q|$ equivalence classes.

  _($arrow.l.double$)_ Now assume $scripts(equiv)_L$ has only finitely many equivalence classes.
  Build a DFA whose states are those classes.
  The start state is the class of $epsilon$.
  On symbol $a$, move from the class of $x$ to the class of $x a$.
  Accept exactly those classes containing strings from $L$.
  This automaton recognizes $L$, so $L$ is regular.
]

== Connection to Minimal DFAs

The theorem does more than characterize regular languages: it explains what the states of the minimal DFA _mean_.
Each state corresponds to one equivalence class of prefixes.

#definition[
  To construct the minimal DFA for $L$:
  1. Compute the equivalence classes of $scripts(equiv)_L$.
  2. Use these classes as the states.
  3. Take the class of $epsilon$ as the start state.
  4. Mark a class as accepting iff it contains a string from $L$.
  5. On input $a$, send the class of $x$ to the class of $x a$.
]

#example[
  Let $L = { w mid(|) w "has an odd number of 1s" }$ over ${0,1}$.
  There are exactly two equivalence classes:
  - prefixes with an even number of $1$s;
  - prefixes with an odd number of $1$s.

  Therefore the minimal DFA has exactly two states.
]

== Proof via Infinite Distinguishability

To prove that a language is _not_ regular using Myhill-Nerode, it is enough to exhibit infinitely many pairwise distinguishable strings.

#definition[
  A family of strings $x_0, x_1, x_2, dots$ is _pairwise $L$-distinguishable_ if for every $i != j$ there exists a suffix $z$ such that exactly one of $x_i z$ and $x_j z$ belongs to $L$.
]

#theorem[
  If $L$ contains an infinite pairwise $L$-distinguishable family, then $scripts(equiv)_L$ has infinite index.
  Consequently, $L$ is not regular.
]

#proof[
  If the strings are pairwise distinguishable, then no two of them can belong to the same equivalence class of $scripts(equiv)_L$.
  Hence infinitely many different strings yield infinitely many different equivalence classes.
  By the Myhill-Nerode theorem, a regular language can have only finitely many such classes.
  Therefore $L$ is not regular.
]

#pagebreak()

#example[${0^n 1^n mid(|) n >= 0}$ is not regular][
  Consider the infinite family $x_i = 0^i$ for $i in NN$.

  Take two distinct indices $i < j$.
  Choose the suffix $z = 1^i$.
  Then
  - $x_i z = 0^i 1^i in L$,
  - $x_j z = 0^j 1^i notin L$.

  Thus $x_i$ and $x_j$ are distinguishable.
  Since this works for every pair $i != j$, the family is infinite and pairwise distinguishable.
  Therefore $L$ is not regular.
]

#v(1em)

#example[${w w mid(|) w in {0,1}^*}$ is not regular][
  Consider the family $x_i = 0^i 1$ for $i in NN$.

  Take two indices $i < j$ and choose the suffix $z = 0^i 1$.
  Then
  - $x_i z = 0^i 1 0^i 1 = (0^i 1)(0^i 1) in L$,
  - $x_j z = 0^j 1 0^i 1 notin L$.

  Hence the strings $x_i$ are pairwise distinguishable, so the language is not regular.
]

== Pumping Lemma and Myhill-Nerode

#align(center)[
  #table(
    columns: 3,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Method*], [*Strength*], [*Application*]),
    [Pumping Lemma], [Necessary condition only], [Can disprove regularity, cannot prove it],
    [Myhill-Nerode], [Necessary and sufficient], [Can both prove and disprove regularity],
    [Pumping Lemma], [Constructive counterexample], [Adversary splits, you choose pump value],
    [Myhill-Nerode], [Structural characterization], [Exhibit infinite distinguishable set],
    [Pumping Lemma], [Based on pigeonhole principle], [Focuses on long strings in the language],
    [Myhill-Nerode], [Based on equivalence relations], [Focuses on distinguishing extensions],
  )
]

#Block(color: blue)[
  *Why this matters:* While the pumping lemma is taught first due to its simpler structure, Myhill-Nerode provides deeper insight into _why_ some languages aren't regular and connects directly to the minimal automaton structure.
]

== Visualizing Equivalence Classes

For a regular language, the equivalence classes correspond to states in the minimal DFA:

#align(center)[
  #cetz.canvas({
    import cetz.draw: *

    scale(80%)

    // Diagram showing equivalence classes merging into DFA states
    set-style(fill: none)

    // Equivalence classes as circles
    circle((0, 0), radius: 0.5, stroke: blue.darken(20%), fill: blue.lighten(90%))
    circle((2, 0), radius: 0.5, stroke: blue.darken(20%), fill: blue.lighten(90%))
    circle((4, 0), radius: 0.5, stroke: blue.darken(20%), fill: blue.lighten(90%))
    circle((6, 0), radius: 0.5, stroke: blue.darken(20%), fill: blue.lighten(90%))

    content((0, 0))[$[epsilon]$]
    content((2, 0))[$[0]$]
    content((4, 0))[$[00]$]
    content((6, 0))[$dots$]

    // Arrows showing transitions
    line((0.5, 0), (1.5, 0), stroke: 1pt, mark: (end: ">", fill: black))
    line((2.5, 0), (3.5, 0), stroke: 1pt, mark: (end: ">", fill: black))
    line((4.5, 0), (5.5, 0), stroke: 1pt, mark: (end: ">", fill: black))

    content((1 - 0.1, 0.4))[0]
    content((3 - 0.1, 0.4))[0]
    content((5 - 0.1, 0.4))[0]

    // Label
    content((3, -1))[Equivalence Classes]

    // DFA on the bottom
    translate((0, -2))

    circle((1, 0), radius: 0.5, stroke: green.darken(20%), fill: green.lighten(90%))
    circle((3, 0), radius: 0.5, stroke: green.darken(20%), fill: green.lighten(90%))
    circle((5, 0), radius: 0.5, stroke: green.darken(20%), fill: green.lighten(90%))

    content((1, 0))[$q_0$]
    content((3, 0))[$q_1$]
    content((5, 0))[$q_2$]

    line((1.5, 0), (2.5, 0), stroke: 1pt, mark: (end: ">", fill: black))
    line((3.5, 0), (4.5, 0), stroke: 1pt, mark: (end: ">", fill: black))
    line((5.5, 0), (6.5, 0), stroke: 1pt, mark: (end: ">", fill: black))

    content((2 - 0.1, 0.4))[0]
    content((4 - 0.1, 0.4))[0]
    content((6 - 0.1, 0.4))[0]

    // Label
    content((3, -1))[Minimal DFA States]
  })
]

// #pagebreak()

#align(center)[
  #table(
    columns: 2,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Diagram Part*], [*Meaning*]),
    [Top row: $[epsilon], [0], [00], dots$], [Myhill-Nerode equivalence classes of prefixes],
    [Bottom row: $q_0, q_1, q_2$], [States of the minimal DFA],
    [Arrows labeled 0], [Appending symbol $0$ and moving to the class of the extended prefix],
  )
]

#note[
  The same principle works for every symbol in the alphabet; only symbol $0$ is drawn to keep the picture readable.
]


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

#note[
  This proof is "algebraic" (via regular expressions).
  The picture below gives the automata-construction intuition.
]

#place(center)[
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
        state((0, 0), "q0", label: $q_0$, initial: true, final: complement)
        state((2, 0), "q1", label: $q_1$, final: complement)
        state((4, 0), "q2", label: $q_2$, final: not complement)
        transition("q0", "q1", inputs: 0, curve: 0)
        transition("q0", "q0", inputs: 1, curve: 0.5)
        transition("q1", "q1", inputs: 0, curve: 0.5)
        transition("q1", "q2", inputs: 1, curve: 0.5)
        transition("q2", "q1", inputs: 0, curve: 0.001)
        transition("q2", "q0", inputs: 1, curve: 1.5)
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

#note[
  De Morgan's identity gives a short proof; the product construction gives an explicit algorithm.
]

== Product Construction for Intersection

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
  The _reversal_ of a language $L$ is the language $L^R = { w^R mid(|) w in L }$.
]

#theorem[
  If $L$ is a regular language, then so is its reversal $L^R$.
]

#proof[
  Structural induction on the regular expression $E$ defining $L$:
  - _Basis:_ If $E$ is $epsilon$, $emptyset$, or $regex("a")$, then $E^R = E$.
  - _Induction:_ $E = E_1 + E_2 => E^R = E_1^R + E_2^R; thick E = E_1 E_2 => E^R = E_2^R E_1^R; thick E = E_1^* => E^R = (E_1^R)^*$. #qedhere
]

== Decision Properties

*Converting among representations*
- $epsilon$-closure: $cal(O)(n^3)$
- $epsilon$-NFA to DFA: $n^3 2^n$
- DFA to $epsilon$-NFA: $cal(O)(n)$
- $epsilon$-NFA to RegEx: $cal(O)(n^3 4^n)$
- RegEx to $epsilon$-NFA: $cal(O)(n)$

#Block(color: yellow)[
  Representation changes are computable but can be exponentially expensive in the worst case.
]

== Decidable Questions

*Decidable questions about $"REG"$*
+ Is the language _empty_? $cal(O)(n^2)$
+ Is the language _finite_? $cal(O)(n^2)$
+ Is $w$ _in_ the language? $cal(O)(abs(w))$ for DFAs
+ Is $L subset.eq M$? Decidable
+ Is $L = M$? Decidable

== Threshold Theorems

#theorem[
  The language $L$ accepted by a finite automaton with $n$ states is _non-empty_ iff the finite automaton accepts a word of length less than $n$.
]

#theorem[
  The language $L$ accepted by a finite automaton $M$ with $n$ states is _infinite_ iff the automaton accepts some word of length $l$, where $n <= l < 2n$.
]


== Summary of Regular Languages

+ *Equivalence* (Kleene's Theorem): DFA $=$ NFA $=$ $epsilon$-NFA $=$ Regular Expression. Different representations, same class.

+ *Pumping Lemma:* if $L$ is regular with DFA of $n$ states, every $w in L$ with $|w| >= n$ can be pumped: #box[$w = x y z$], $|y| >= 1$, $|x y| <= n$, $x y^i z in L$ for all $i >= 0$. A _necessary_ condition only.

+ *Myhill--Nerode Theorem:* $L$ is regular iff the equivalence $x scripts(equiv)_L y$ ("$x$ and $y$ lead to the same future") has _finitely many classes_. This is both necessary and sufficient, and characterizes the minimal DFA.

+ *Closure:* regular languages are closed under union, intersection, complement, concatenation, Kleene star, reversal, homomorphism, and inverse homomorphism.

+ *All key questions are decidable:* emptiness, finiteness, membership, subset, equality.

#Block(color: orange)[
  *Hard ceiling:* a DFA has only _constant memory_ (finitely many states). It cannot count, match, or track unbounded structure. Any language requiring counting or matching at arbitrary depth is _not_ regular.
  Canonical witnesses: ${ a^n b^n }$, $\{ w w \}$, balanced parentheses.
]

= Beyond Regular Languages

#focus-slide(
  epigraph: [A grammar is a device that specifies the infinite set of well-formed sentences of a language and gives a structural description of each.],
  epigraph-author: "Noam Chomsky",
  scholars: (
    (
      name: "John Backus",
      image: image("assets/John_Backus.jpg"),
    ),
    (
      name: "Peter Naur",
      image: image("assets/Peter_Naur.jpg"),
    ),
    (
      name: [Yehoshua\ Bar-Hillel],
      image: image("assets/Yehoshua_Bar-Hillel.jpg"),
    ),
    (
      name: "Aad van Wijngaarden",
      image: image("assets/Aad_van_Wijngaarden.jpg"),
    ),
    (
      name: "Andrey Terekhov",
      image: image("assets/Andrey_Terekhov.jpg"),
    ),
    (
      name: "Niklaus Wirth",
      image: image("assets/Niklaus_Wirth.jpg"),
    ),
    (
      name: "John McCarthy",
      image: image("assets/John_McCarthy.jpg"),
    ),
  ),
)

== What Regular Languages Cannot Do

We have seen several non-regular languages:
- $L = { 0^n 1^n mid(|) n in NN }$ --- requires _counting_ to match $0$s and $1$s.
- $"EQUAL" = { w hash w mid(|) w in {0,1}^* }$ --- requires _remembering_ an entire string.
- $L = { w in {0,1}^* mid(|) w "has equal number of 0s and 1s" }$ --- requires a _counter_.

The common pattern: regular languages cannot _count_ beyond a bounded amount.
A DFA has only _finitely many states_, so it cannot track _unbounded_ quantities.

#Block(color: yellow)[
  *Fundamental limitation:* A finite automaton is a machine with _constant memory_. \
  It can remember only a _bounded_ amount of information about the input it has read.
]

#Block(color: blue)[
  *Upgrade:* give the machine a _stack_ (last-in first-out memory).
  This gives the next level of computational power in the Chomsky hierarchy: _context-free languages_.
]

== Context-Free Languages

Regular languages cannot describe ${ a^n b^n mid(|) n >= 0 }$: any DFA only has finite memory.

The key idea is to allow _recursive_ rules --- a grammar that can expand itself to arbitrary depth.

#definition[
  A _context-free grammar_ (CFG) is a 4-tuple $G = (V, Sigma, R, S)$ where:
  - $V$ is a finite set of _variables_ (non-terminals),
  - $Sigma$ is a finite set of _terminals_ (disjoint from $V$),
  - $R subset.eq V times (V union Sigma)^*$ is a finite set of _production rules_ $A -> alpha$,
  - $S in V$ is the _start symbol_.

  The language of $G$ is the set of all terminal strings derivable from $S$:
  $
    cal(L)(G) = { w in Sigma^* mid(|) S scripts(=>)^* w }
  $
]

#example[
  Grammar $G$: $S -> 0 S 1 mid(|) epsilon$ generates $L = { 0^n 1^n mid(|) n >= 0 }$.

  $S => 0 S 1 => 0 0 S 1 1 => 0 0 0 S 1 1 1 => 000 epsilon 111 = 000111$
]

// #Block(color: blue)[
//   *CFGs are the foundation of programming language syntax.*
//   BNF (Backus--Naur Form) used in language standards _is_ a CFG.
//   Every compiler uses a CFG (or a variant) to parse source code into an _abstract syntax tree_.
// ]

== BNF and EBNF

_Backus--Naur Form_ (BNF) is the standard notation for writing CFGs in language specifications --- it is exactly the same formalism as CFGs, just a different syntax.

#definition[
  A _BNF rule_ has the form:
  $
    angle.l "symbol" angle.r quad ::= quad alpha_1 quad | quad alpha_2 quad | quad dots quad | quad alpha_k
  $
  - $angle.l "symbol" angle.r$ is a _non-terminal_ (written in angle brackets); corresponds to a CFG variable.
  - Each $alpha_i$ is a sequence of _terminals_ (quoted strings) and non-terminals.
  - "$::=$" means "is defined as".
  - "$|$" separates alternatives.
]

#example[
  BNF grammar for arithmetic expressions (from the ALGOL 60 report, Backus and Naur, 1960):
  ```
  <expr>   ::= <expr> "+" <term>  |  <term>
  <term>   ::= <term> "*" <factor>  |  <factor>
  <factor> ::= "(" <expr> ")"  |  <id>
  ```
  The stratified structure encodes _precedence_: `*` binds tighter than `+`.
  This is exactly the unambiguous grammar $E -> E + T mid(|) T$, $T -> T times F mid(|) F$, $F -> (E) mid(|) mono("id")$.
]

_Extended BNF_ (EBNF) adds shorthand notation --- no new expressive power, but much more readable:

#align(center)[
  #table(
    columns: 3,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*EBNF syntax*], [*Meaning*], [*BNF equivalent*]),
    [$[alpha]$], [Optional: zero or one $alpha$], [$S -> alpha mid(|) epsilon$],
    [${ alpha }$ or $alpha^*$], [Repetition: zero or more $alpha$], [$S -> alpha S mid(|) epsilon$],
    [$alpha^+$], [One or more $alpha$], [$S -> alpha alpha^*$],
    [$(alpha_1 | alpha_2)$], [Grouping with alternatives], [Inline alternative],
  )
]

#Block(color: blue)[
  *Where you'll encounter BNF/EBNF:* language reference manuals (Python, Rust, C), RFC protocol specifications, ISO SQL standard, JSON schema. Every modern compiler processes a grammar defined in BNF or EBNF.
]

== Derivations and Parse Trees

#definition[
  A _derivation step_ $alpha A beta => alpha gamma beta$ applies production $A -> gamma in R$, replacing one variable~$A$.
  _Derives_ $scripts(=>)^*$ is the reflexive-transitive closure: zero or more steps.
  A _leftmost derivation_ always replaces the leftmost variable first.
]

The same derivation information can be rendered as a _parse tree_:

#columns(2)[
  *Derivation* of $0011$ from $S -> 0 S 1 mid(|) epsilon$:
  $
    S & => 0 S 1 \
      & => 0 0 S 1 1 \
      & => 0 0 epsilon 1 1 = 0011
  $

  Each step expands one node. The _leaves_ (left to right) spell out the derived word.

  #colbreak()

  #align(center)[
    #cetz.canvas(length: 0.9cm, {
      import cetz.draw: *
      content((2.5, 3.2), $S$)
      line((2.4, 3), (1.0, 1.9), stroke: 0.6pt)
      line((2.5, 3), (2.5, 1.9), stroke: 0.6pt)
      line((2.6, 3), (4.0, 1.9), stroke: 0.6pt)
      content((1.0, 1.7), [0])
      content((2.5, 1.7), $S$)
      content((4.0, 1.7), [1])
      line((2.4, 1.5), (1.8, 0.9), stroke: 0.6pt)
      line((2.5, 1.5), (2.5, 0.9), stroke: 0.6pt)
      line((2.6, 1.5), (3.2, 0.9), stroke: 0.6pt)
      content((1.8, 0.7), [0])
      content((2.5, 0.7), $S$)
      content((3.2, 0.7), [1])
      line((2.5, 0.5), (2.5, 0.15), stroke: 0.6pt)
      content((2.5, 0), $epsilon$)
    })
  ]
]

#note[
  Compilers use parse trees as the _abstract syntax tree_ (AST) of source code.
  Different derivation _orders_ (leftmost, rightmost) produce identical parse trees in unambiguous grammars.
]

== Further CFG Examples

#align(center)[
  #table(
    columns: 3,
    align: (left, left, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Productions*], [*Language*], [*Application*]),
    [$S -> 0 S 1 mid(|) epsilon$], [${ 0^n 1^n mid(|) n >= 0 }$], [Classic matched pairs],
    [$S -> a S a mid(|) b S b mid(|) a mid(|) b mid(|) epsilon$],
    [Palindromes over ${ a, b }^*$],
    [Hashing, bioinformatics],

    [$S -> S S mid(|) mono("(") S mono(")") mid(|) epsilon$],
    [Balanced parentheses ${ mono("()"), mono("(())"), mono("()()"), dots }$],
    [Lisp, expression parsers],

    [
      $E -> E + T mid(|) T$ \
      $T -> T times F mid(|) F$ \
      $F -> (E) mid(|) mono("id")$
    ],
    [Arithmetic expressions with correct precedence],
    [Every compiler (real PLs)],

    [$S -> a S b mid(|) b S a mid(|) S S mid(|) epsilon$],
    [${ w in {a,b}^* mid(|) hash_a (w) = hash_b (w) }$],
    [Balance counting],
  )
]

#Block(color: yellow)[
  *Pattern:* A grammar variable acts as a "placeholder" carrying context through recursive structure --- exactly what a _stack_ does at runtime.
  This deep connection is Theorem: CFG $=$ PDA.
]

== Ambiguous Grammars

#definition[
  A grammar $G$ is _ambiguous_ if some word $w in cal(L)(G)$ has two distinct _leftmost derivations_ (equivalently, two distinct parse trees).
]

#example[
  Grammar $E -> E + E mid(|) E times E mid(|) (E) mid(|) mono("id")$ is _ambiguous_.
  The word $mono("id + id") times mono("id")$ has two parse trees with *different* root operators:
  - *Tree A* ($times$ at root): interprets as $(mono("id + id")) times mono("id")$ --- wrong precedence!
  - *Tree B* ($+$ at root): interprets as $mono("id") + (mono("id") times mono("id"))$ --- correct!
  Both are valid derivations in $E -> E + E mid(|) E times E mid(|) dots$, so the grammar cannot determine which.
]

The fix: _stratify_ the grammar so that higher-precedence operators are at deeper nesting levels.

$
  E -> E + T mid(|) T, quad T -> T times F mid(|) F, quad F -> (E) mid(|) mono("id")
$

Here $T$ (term) binds tighter than $E$ (expression): $times$ before $+$.
The stratified grammar has exactly _one_ parse tree per expression, reflecting the intended meaning.

// #Block(color: yellow)[
//   *Design principle:* Every grammar for a real programming language must be _unambiguous_.
//   Arithmetic, function calls, and control flow all require careful grammar stratification.
// ]

== Consequences of Ambiguous Grammars

#note(title: "Inherently ambiguous languages")[
  A _context-free language_ $L$ is _inherently ambiguous_ if *every* CFG for $L$ is ambiguous.
  This means no clever reformulation of the grammar can remove the ambiguity.

  Classic example: $L = { a^i b^j c^k mid(|) i = j } union { a^i b^j c^k mid(|) j = k }$.
  Any CFG for this union must handle both constraints simultaneously, leading to unavoidable
  ambiguity on words like $a^n b^n c^n$ (which are in the language for _both_ reasons).
]

#Block(color: orange)[
  *Compiler engineering:* Parser generators (yacc, Bison, ANTLR) _reject_ or _warn_ on ambiguous grammars.
  Ambiguity manifests as shift/reduce or reduce/reduce _conflicts_ in LR parsing tables.
  Resolving them requires either grammar rewriting or explicit precedence/associativity declarations.

  *Decidability:* "Is grammar $G$ ambiguous?" is _undecidable_ --- there is no algorithm that can
  check all grammars. Modern tools use heuristics and partial analyses.
]

== Chomsky Normal Form

#definition[
  A CFG $G$ is in _Chomsky Normal Form_ (CNF) if every production rule has one of two forms:
  - $A -> B C$ where $B, C in V$ (two variables), or
  - $A -> a$ where $a in Sigma$ (a single terminal).
  The only $epsilon$-production allowed is $S -> epsilon$ (only if $epsilon in cal(L)(G)$),
  and $S$ must not appear on any rule's right-hand side.
]

#theorem[
  Every context-free language has a CNF grammar.
]

CNF is a canonical form: it looks restrictive (no rule has more than two symbols on the right), but any CFL can be expressed in it without changing the language.

#Block(color: yellow)[
  *Why CNF exists:* Many algorithms and proofs about CFLs become significantly simpler when the grammar has a fixed, uniform shape.

  Two key applications:
  + *CYK membership algorithm:* $cal(O)(n^3)$ dynamic programming, only works on CNF grammars.
  + *Pumping Lemma proof:* The repeated variable on a long parse tree path is found via binary tree height bounds.
]

== CNF Properties

In a CNF parse tree, every internal node is either a _binary branching_ ($A -> B C$) or a _terminal_ ($A -> a$). This gives a clean structural guarantee:

#theorem[
  In a CNF parse tree for a word of length $n$, there are _exactly_ $2n - 1$ internal nodes.
]

This means: the tree height is at most $2n - 1$, and a tree with height $>= abs(V) + 1$ must contain a repeated variable on some root-to-leaf path (by Pigeonhole) --- the key to the Pumping Lemma proof.

== CYK Algorithm

#Block(color: blue)[
  *CYK algorithm* (Cocke--Younger--Kasami): given CNF grammar $G$ and string $w = a_1 dots a_n$,
  fill a triangular table $T[i][j]$ = set of variables that derive $a_i a_(i+1) dots a_j$.

  - Base: $T[i][i] = { A mid(|) A -> a_i in R }$
  - Step: $T[i][j] = { A mid(|) A -> B C in R, B in T[i][k], C in T[k+1][j] "for some" k }$
  - Accept iff $S in T[1][n]$.

  Running time: $cal(O)(n^3 dot abs(G))$.
]

#Block(color: teal)[
  *Historical note:*
  CYK was the first polynomial-time CFL membership algorithm, developed independently by Cocke (1960), Younger (1967), and Kasami (1966).
  It is the CFL analogue of Floyd--Warshall for shortest paths.
]

== CNF Conversion Algorithm

Any CFG can be mechanically transformed into CNF in five steps (applied in order):

+ *New start symbol.*
  Add $S_0 -> S$ and make $S_0$ the start.
  Ensures $S$ never appears on any RHS, satisfying the CNF constraint.

+ *Eliminate $epsilon$-productions.*
  Find all _nullable_ variables: those that can derive $epsilon$ in one or more steps.
  For every rule $A -> dots B dots$ where $B$ is nullable, add a copy of the rule with $B$ omitted.
  Then remove all $A -> epsilon$ rules (except $S_0 -> epsilon$ if $epsilon in cal(L)(G)$).

+ *Eliminate unit productions.*
  A _unit production_ is $A -> B$ where $B$ is a single variable.
  For each such rule, add $A -> alpha$ for every $B -> alpha$ (non-unit rule).
  Remove all $A -> B$ rules.
  Repeat until none remain.

+ *Binarize long rules.*
  A rule with $k >= 3$ symbols on the RHS violates CNF. Replace $A -> X_1 X_2 dots X_k$ with a chain:
  $A -> X_1 A_1, quad A_1 -> X_2 A_2, quad dots, quad A_(k-2) -> X_(k-1) X_k$
  Each $A_i$ is a fresh variable introduced for this rule.

+ *Isolate terminals in mixed rules.*
  For each terminal $a$ appearing in a rule body of length $>= 2$, introduce a fresh variable $U_a$ with production $U_a -> a$, and replace every occurrence of $a$ in rule bodies by $U_a$.

#Block(color: yellow)[
  Steps 1--5 are applied in order; each preserves the language.
  The result is a CNF grammar for the same CFL.
  The grammar may be larger, but structurally uniform.
]

== CNF Conversion Walkthrough

#example[Convert $G$: $S -> a S b mid(|) a b$ to CNF.][]

*Step 1* (new start): no $S$ on any RHS already, so skip.

*Step 2* ($epsilon$): neither $S$ rule derives $epsilon$ directly. Since $S$ is not nullable, skip.

*Step 3* (unit productions): no unit rules. Skip.

*Step 4* (binarize): $S -> a S b$ has length 3. Introduce $A_1$:
$
  S -> a A_1, quad A_1 -> S b
$
Rule $S -> a b$ has length 2 (fine as-is, for now).

*Step 5* (isolate terminals): in $S -> a A_1$, $a$ is a terminal in a two-symbol body. Introduce $U_a -> a$ and $U_b -> b$:
$
  S -> U_a A_1 mid(|) U_a U_b, quad A_1 -> S U_b, quad U_a -> a, quad U_b -> b
$

This is the final CNF grammar.
Check: every production is $A -> B C$ or $A -> a$. #YES

// #note[
//   Real grammar transformations for production-scale compilers produce dozens of fresh variables. The CNF form is used internally (for algorithms), while the _original_ readable grammar is what humans maintain.
// ]

== Pushdown Automata

#definition[
  A _Pushdown Automaton_ (PDA) is a 7-tuple $cal(P) = (Q, Sigma, Gamma, delta, q_0, Z_0, F)$ where:
  - $Q$ is a finite set of states,
  - $Sigma$ is the _input alphabet_,
  - $Gamma$ is the _stack alphabet_,
  - $delta: Q times (Sigma union {epsilon}) times Gamma to power(Q times Gamma^*)$ is the _transition function_,
  - $q_0 in Q$ is the _start state_,
  - $Z_0 in Gamma$ is the _initial stack symbol_ (bottom-of-stack marker),
  - $F subset.eq Q$ is the set of _accepting states_.
]

A PDA is an NFA augmented with an unbounded _stack_ that it can push to and pop from.

#pagebreak()

#note[
  Each transition reads:
  - the current _state_,
  - the current _input symbol_ (or $epsilon$ --- a "free move"),
  - the _top of the stack_,

  and produces: a new _state_ and a string to _replace_ the top stack symbol with.
  A "pop" is modeled by replacing the top symbol with $epsilon$ (nothing).
]

#example[
  A PDA for $L = { 0^n 1^n mid(|) n >= 0 }$:
  - On reading $0$: push a marker $\$$ onto the stack.
  - On reading the first $1$: switch to "popping" mode.
  - On reading $1$ in popping mode: pop a $\$$.
  - Accept when the input is exhausted and the stack contains only $Z_0$.
]

== PDA Computation Model

A _configuration_ $(q, w, gamma)$ captures the complete machine state:
$q in Q$ is the current state, $w in Sigma^*$ is remaining input, $gamma in Gamma^*$ is the stack (top on left).

#definition[
  The _step relation_ of a PDA:
  $
    (q, thin a w, thin Z gamma) scripts(tack) (p, thin w, thin alpha gamma) quad "iff" quad (p, alpha) in delta(q, a, Z)
  $
  Epsilon moves: $(q, thin w, thin Z gamma) scripts(tack) (p, thin w, thin alpha gamma)$ iff $(p, alpha) in delta(q, epsilon, Z)$.

  $scripts(tack)^*$ is the reflexive-transitive closure (zero or more steps).
]

#definition[
  Two equivalent _acceptance modes_ (both define the same class --- CFL):
  - *By final state:* $cal(L)(cal(P)) = { w mid(|) (q_0, w, Z_0) scripts(tack)^* (f, epsilon, gamma), thin f in F }$
  - *By empty stack:* $cal(L)(cal(P)) = { w mid(|) (q_0, w, Z_0) scripts(tack)^* (q, epsilon, epsilon) }$
]

#note[
  PDAs are _non-deterministic_ by definition.
  _Deterministic PDAs_ (DPDAs) recognize a strict subclass of CFLs.
  Example: palindromes require non-determinism --- a DPDA cannot recognize them.
]

#Block(color: blue)[
  LL and LR parsing is a _deterministic_ simulation of the PDA for a specific grammar.
  Parser generators (yacc, ANTLR, Bison) automate exactly this construction.
]

== PDA Trace for *$0^n 1^n$*

We trace the PDA for $L = { 0^n 1^n mid(|) n >= 0 }$ on input $mono("0011")$:

#align(center)[
  #table(
    columns: 5,
    align: (center, center, left, left, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Step*], [*State*], [*Input remaining*], [*Stack* (top $arrow.l$)], [*Action*]),
    [0], [$q_0$], [`0011`], [$Z_0$], [Initial configuration],
    [1], [$q_0$], [`011`], [$\$ Z_0$], [Read `0`, push $\$$],
    [2], [$q_0$], [`11`], [$\$ \$ Z_0$], [Read `0`, push $\$$],
    [3], [$q_1$], [`1`], [$\$ Z_0$], [Read `1`, pop $\$$ (switch to pop mode)],
    [4], [$q_1$], [``], [$Z_0$], [Read `1`, pop $\$$],
    [5], [$q_"acc"$], [``], [$Z_0$], [$epsilon$-move, *ACCEPT*],
  )
]

#Block(color: yellow)[
  *Why this works:* each `0` pushes a marker; each `1` pops one.
  If the counts match, the stack returns to exactly $Z_0$ when input is consumed.
  If there are more `0`s than `1`s, excess $\$$ remain. If more `1`s, the stack underflows (no $\$$ to pop $=>$ reject).
]

#note[
  The PDA non-deterministically guesses *when* to switch from pushing to popping.
  For $0^n 1^n$, a deterministic PDA also works: switch when the first `1` appears.
]

== The Context-Free Hierarchy

#theorem[
  A language is context-free iff it is recognized by some pushdown automaton.
]

#grid(
  columns: 2,
  column-gutter: 1em,
  [
    Context-free languages are _strictly more powerful_ than regular languages:
    - Every regular language is context-free: a DFA is a PDA that ignores its stack entirely.
    - ${ a^n b^n mid(|) n >= 0 }$ is context-free (by PDA above) but _not_ regular (by pumping lemma).

    But CFLs still have limits:
    - ${ a^n b^n c^n mid(|) n >= 0 }$ is *not* context-free.
    - Context-sensitive languages (linear-bounded automata) lie above CFLs.
  ],
  [
    The Chomsky hierarchy captures this nested structure precisely.

    #align(center)[
      #cetz.canvas({
        import cetz.draw: *
        set-style(stroke: 0.4pt)
        circle((0, 0), radius: (0.9, 0.5), fill: green.transparentize(85%))
        circle((0, 0.4), radius: (1.6, 1.0), fill: blue.transparentize(85%))
        circle((0, 0.8), radius: (2.3, 1.5), fill: purple.transparentize(85%))
        circle((0, 1.2), radius: (3.0, 2.0))
        content((0, 0), [Regular])
        content((0, 1.0), [CFL])
        content((0, 2.0), [CS])
        content((0, 2.9), [RE])
      })
    ]
  ],
)

#place[
  #v(1em)
  #Block(color: teal)[
    *Big picture:*
    Regular $subset$ Context-Free $subset$ Context-Sensitive $subset$ Recursive (Decidable) $subset$ RE.

    Each level strictly contains the one below, with concrete witness languages separating them.
  ]
]

== CFG $<=>$ PDA Equivalence

#theorem[
  $cal(L)$ is context-free iff $cal(L) = cal(L)(cal(P))$ for some PDA $cal(P)$.
]

#proof[($"CFG" => "PDA"$)][
  Given CFG $G$, construct a PDA simulating _leftmost derivation_:
  + _Push_ the start symbol $S$ onto the stack.
  + While the stack is non-empty:
    - If top is a _variable_ $A$: non-deterministically choose a production $A -> alpha$ and replace the top with $alpha$ ($epsilon$-move).
    - If top is a _terminal_ $a$: read $a$ from input and pop the top.
  + Accept when the stack and input are both empty.

  This PDA non-deterministically simulates all leftmost derivations of $G$.
]

#Block(color: blue)[
  The forward direction ($"CFG" => "PDA"$) is used by LL/LR parsing: the parser _simulates_ the leftmost derivation non-deterministically (with look-ahead to resolve choices).
  GLL and GLR parsers handle the non-determinism explicitly.
]

#pagebreak()

#proof[($"PDA" => "CFG"$)][
  Given PDA $cal(P)$, construct a CFG where each variable $[p X q]$ represents: "$cal(P)$ can go from state $p$ with $X$ on top to state $q$, emptying $X$".
  The construction is mechanical but tedious; the key insight is that each PDA transition translates into one or two grammar productions.
]

== Pumping Lemma for Context-Free Languages

The CFL counterpart of the Pumping Lemma for regular languages, proved using CNF trees.

#theorem[Pumping Lemma for CFLs (Bar-Hillel, Perles, Shamir, 1961)][
  Let $L$ be a context-free language.
  Then there exists $n >= 1$ such that for every $w in L$ with $abs(w) >= n$,
  there exist strings $u, v, x, y, z$ with $w = u v x y z$ satisfying:
  + $abs(v y) >= 1$ (the "pump" is non-empty),
  + $abs(v x y) <= n$ (the pump is not too long),
  + $u v^i x y^i z in L$ for all $i >= 0$ (pumping keeps the string in $L$).
]

Compared to the regular pumping lemma ($w = x y z$, pump $y$), the CFL version pumps _two_ substrings $v$ and $y$ _simultaneously_.
This reflects the stack: each time the outer variable expands, it contributes one segment $v$ on the left and one segment $y$ on the right.

#example[
  Grammar $S -> 0 S 1 mid(|) epsilon$ generates ${ 0^n 1^n }$.
  Taking $w = 0^n 1^n$: a valid split is $u = epsilon$, $v = 0^k$, $x = epsilon$, $y = 1^k$, $z = 0^(n-k) 1^(n-k)$.
  Then $u v^i x y^i z = 0^(n-k+i k) 1^(n-k+i k) in L$ for all $i >= 0$. #YES
]

== Proof Idea for the CFL Pumping Lemma

Use CNF to make every parse tree binary. \
The pumping length is $n = 2^(abs(V)+1)$, where $abs(V)$ is the number of variables.

#grid(
  columns: 2,
  column-gutter: 1em,
  [
    If $abs(w) >= 2^(abs(V)+1)$, the parse tree has height $>= abs(V) + 1$. \
    By the _Pigeonhole Principle_, some root-to-leaf path visits the same variable $A$ _twice_.

    + Let $A_"outer"$ be the higher occurrence, $A_"inner"$ the lower.
    + The subtree rooted at $A_"outer"$ derives $v x y$; \ the smaller subtree at $A_"inner"$ derives $x$.
    + $v$ and $y$ are the "side contributions" between the two $A$s.

    *Pumping:*
    - $i = 0$: replace $A_"outer"$'s subtree with $A_"inner"$'s subtree. \
      Result: $u x z in L$.
    - $i >= 2$: nest another copy of $A_"outer"$'s subtree inside itself. \
      Result: $u v^i x y^i z in L$.
  ],
  [#cetz.canvas({
      import cetz.draw: *
      // S above the outer A
      content((3, 6.2), $S$)
      line((3, 6.05), (3, 5.5), stroke: (paint: gray, dash: "dashed", thickness: 0.6pt))
      // Outer A
      circle((3, 5.2), radius: 0.3, fill: yellow.lighten(80%), stroke: blue.darken(20%) + 1pt)
      content((3, 5.2), text(fill: blue.darken(20%))[$A$])
      // Big outer triangle
      line((3, 4.9), (1, 0.5), stroke: 1pt + blue.darken(20%))
      line((3, 4.9), (5, 0.5), stroke: 1pt + blue.darken(20%))
      // Dashed path to inner A
      line((3, 4.9), (3, 2.7), stroke: (paint: gray, dash: "dashed", thickness: 0.6pt))
      // Inner A
      circle((3, 2.5), radius: 0.3, fill: yellow.lighten(80%), stroke: blue.darken(20%) + 1pt)
      content((3, 2.5), text(fill: blue.darken(20%))[$A$])
      // Small inner triangle
      line((3, 2.2), (2.1, 0.5), stroke: 1pt + blue.darken(20%))
      line((3, 2.2), (3.9, 0.5), stroke: 1pt + blue.darken(20%))
      // Baseline
      line((0.2, 0.3), (5.8, 0.3), stroke: 0.4pt + gray)
      // Region labels
      content((-0.1, -0.1), $u$)
      content((1.5, -0.1), text(fill: red.darken(20%))[$v$])
      content((3, -0.1), $x$)
      content((4.5, -0.1), text(fill: red.darken(20%))[$y$])
      content((6.1, -0.1), $z$)
      // Region ground bars
      line((-0.5, 0.3), (1, 0.3), stroke: 0.5pt)
      line((1, 0.3), (2.1, 0.3), stroke: (paint: red.darken(20%), thickness: 1.2pt))
      line((2.1, 0.3), (3.9, 0.3), stroke: 0.5pt)
      line((3.9, 0.3), (5, 0.3), stroke: (paint: red.darken(20%), thickness: 1.2pt))
      line((5, 0.3), (6.5, 0.3), stroke: 0.5pt)
    })
  ],
)

== *$a^n b^n c^n$* is Not Context-Free

#theorem[
  $L = { a^n b^n c^n mid(|) n >= 0 }$ is not context-free.
]

#proof[
  Assume $L$ is CFL and let $n$ be the pumping length.
  Choose $w = a^n b^n c^n in L$ with $abs(w) = 3n >= n$.

  By the CFL pumping lemma, $w = u v x y z$ with $abs(v y) >= 1$ and $abs(v x y) <= n$.

  Since $abs(v x y) <= n < 3n$, the segment $v x y$ can span _at most two_ of the three symbol blocks ($a$s, $b$s, $c$s).

  - *Case 1:* $v$ and $y$ lie entirely within two adjacent blocks (say $a$s and $b$s). \
    Pumping with $i = 2$ increases the count of $a$s and/or $b$s but _not_ $c$s. \
    The result $u v^2 x y^2 z$ has unequal symbol counts, so it $notin L$.
  - *Case 2:* $v$ or $y$ spans a block boundary, so pumped strings mix symbols out of order. \
    For example, if $v = a^j b^k$, then $v^2 = a^j b^k a^j b^k$, which is not of the form $a^* b^* c^*$.
    Hence $u v^2 x y^2 z notin L$.

  In both cases we reach a contradiction.
  Thus $L$ is not context-free.
]

#place[
  #v(1em)
  #Block(color: yellow)[
    *Intuition:* A stack can maintain _one_ counter (e.g., match $a$s with $b$s).
    Matching $a$s, $b$s, and $c$s _simultaneously_ requires _two_ independent counters --- beyond what any stack can do.
  ]
]

== *$w w$* is Not Context-Free

#theorem[
  $L = { w w mid(|) w in {0,1}^* }$ is not context-free.
]

#proof[
  Assume $L$ is CFL with pumping length $n$.
  Choose $w_0 = 0^n 1^n 0^n 1^n in L$ (set $w = 0^n 1^n$, so $w w = w_0$, and $abs(w_0) = 4n$).

  By the CFL pumping lemma, $w_0 = u v x y z$ with $abs(v x y) <= n$.
  Since $abs(v x y) <= n$ and $abs(w_0) = 4n$, the segment $v x y$ covers at most $n$ consecutive characters of $w_0$.
  It cannot straddle both the first half $0^n 1^n$ and the second half $0^n 1^n$ simultaneously.

  Hence $v$ and $y$ together modify the symbol counts in _at most one half_ of $w_0$.

  Pumping with $i = 2$ increases character counts in one half but not the other.
  The resulting $u v^2 x y^2 z$ cannot equal $w' w'$ for any $w'$ (the two halves become unequal).
  Thus $u v^2 x y^2 z notin L$, contradicting the lemma.
]

#Block(color: blue)[
  *Context:* The language ${ w w mid(|) w in {0,1}^* }$ is decidable by Turing machine (it just has two heads, or uses the marking trick from the TM trace slides).
  This shows Decidable $not subset.eq$ CFL.
]

== Closure Properties of CFLs

#align(center)[
  #table(
    columns: (auto, auto, auto),
    align: (left, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Operation*], [*CFLs closed?*], [*Proof idea*]),
    [Union $L_1 union L_2$], [#YES], [New start $S -> S_1 mid(|) S_2$],
    [Concatenation $L_1 dot L_2$], [#YES], [New start $S -> S_1 S_2$],
    [Kleene star $L^*$], [#YES], [New start $S -> S S' mid(|) epsilon$],
    [Reversal $L^R$], [#YES], [Reverse all production RHSs],
    [Homomorphism $h(L)$], [#YES], [Apply $h$ to each terminal in grammar],
    [$intersect$ with regular, $L inter R$], [#YES], [Product of PDA stack $times$ DFA state],
    [Intersection $L_1 inter L_2$], [#NO], [${ a^n b^n } inter { b^n c^n } = { a^n b^n c^n } notin "CFL"$],
    [Complement $overline(L)$], [#NO], [From non-closure under $intersect$ via De Morgan],
    [Difference $L_1 setminus L_2$],
    [#NO],
    [$L setminus R in "CFL"$ for regular $R$; but $L_1 setminus L_2$ may not be],
  )
]

#Block(color: orange)[
  *Key contrast with regular languages:* CFLs are NOT closed under intersection or complement.
  This means there is no direct "product PDA" construction analogous to the DFA product.

  Exception: _Deterministic_ CFLs (DCFL) *are* closed under complement.
  DCFL is the language class of most real programming languages (LR(1) grammars).
]

== Decision Properties of CFLs

#columns(2)[
  *_Decidable_ questions about CFLs:*

  - *Empty?* Is $cal(L)(G) = emptyset$? \
    Check whether $S$ can derive any terminal string. \
    $cal(O)(abs(G))$ time. #YES

  - *Membership:* Is $w in cal(L)(G)$? \
    Use CYK algorithm (CNF required): \
    $cal(O)(abs(w)^3 dot abs(G))$ time. #YES

  - *Finite?* Is $cal(L)(G)$ finite? \
    Decidable (check for useless variables). \
    $cal(O)(abs(G))$ time. #YES

  #colbreak()

  *_Undecidable_ questions about CFLs:*

  - *Universal?*
    Is $cal(L)(G) = Sigma^*$? \
    _Undecidable_. #NO

  - *Intersection empty?*
    Is $cal(L)(G_1) inter cal(L)(G_2) = emptyset$? \
    _Undecidable_. #NO

  - *Equivalence:*
    Is $cal(L)(G_1) = cal(L)(G_2)$? \
    _Undecidable_. #NO

  - *Ambiguous?*
    Is $G$ ambiguous? \
    _Undecidable_. #NO
]

#Block(color: yellow)[
  *The jump from decidable to undecidable happens exactly at intersection and universality* --- the same operations that break closure.
  Decidability and closure are deeply linked.
]

/*

== CFG Exercises

For each language, (1) give a CFG, (2) give a PDA (informal description), (3) determine if the language is also regular:

+ $L_1 = { a^i b^j mid(|) i >= j >= 0 }$ --- more $a$s than $b$s (or equal) \
  _(Hint: $S -> a S mid(|) a S b mid(|) epsilon$)_

+ $L_2 = { w in {a,b}^* mid(|) w = w^R }$ --- all palindromes over $\{a,b\}$

+ $L_3 = { a^i b^j c^k mid(|) i = j "or" j = k }$ --- union of two CFLs \
  _(Hint: give a grammar for each part, then combine with $S -> S' mid(|) S''$)_

+ $L_4 = { w \# v mid(|) w, v in {0,1}^*, thin abs(w) = abs(v) }$ --- same length strings around $\#$

+ $L_5 = { w mid(|) hash_0(w) + hash_1(w) = hash_2(w), thin w in {0,1,2}^* }$ --- counts: $\#0 + \#1 = \#2$

+ Prove that ${ 0^n 1^(2n) mid(|) n >= 0 }$ is context-free but ${ 0^n 1^n 0^n mid(|) n >= 0 }$ is not.

#Block(color: orange)[
  *Challenge:* Is ${ w \# v mid(|) w "is a substring of" v }$ context-free? Prove your answer.
]

Even context-free languages hit a ceiling: they still cannot express languages like ${ a^n b^n c^n mid(|) n >= 0 }$ that require _multiple independent_ counters.
We need a fundamentally more powerful model --- one with unrestricted memory and full read/write access to a tape.
This leads us to the _Turing machine_, the most general computational model we will study.

*/

== Summary of Context-Free Languages

+ *Equivalence* (CFL analogue of Kleene): CFG $=$ PDA. Grammars and stack automata define the same class.

+ *CNF + CYK:* every CFL has a grammar in Chomsky Normal Form. CYK decides membership in $cal(O)(n^3 dot |G|)$ time via dynamic programming on the parse tree structure.

+ *Pumping Lemma:* if $L$ is context-free with pumping length $n$, every long word $w in L$ has a split $w = u v x y z$ with $|v y| >= 1$, $|v x y| <= n$, and $u v^i x y^i z in L$ for all $i >= 0$. The pair $(v, y)$ comes from a repeated variable in the CNF parse tree.

+ *Closure:* union, concatenation, Kleene star, reversal, homomorphism, and intersection with regular languages. *Not* closed under intersection or complement.

+ *Decidable:* emptiness, membership (CYK), finiteness.
  *Undecidable:* universality ($cal(L)(G) = Sigma^*$?), equivalence, intersection emptiness, ambiguity.

#Block(color: orange)[
  *Hard ceiling:* a PDA has one _stack_ (LIFO memory). It can match one pair of counts, but not two independent ones simultaneously.
  Canonical witnesses above CFLs: ${ a^n b^n c^n }$, ${ w w }$, ${ w \# w }$.
]

#Block(color: blue)[
  *Where CFLs appear in practice:* the syntax of virtually every programming language is a CFL (or close to one: DCFL). Parser generators process CFG specifications; parse trees are the AST.
  The non-closure under intersection is why type-checking and semantic analysis go _beyond_ parsing.
]

= Turing Machines
#focus-slide(
  epigraph: [We may compare a man in the process of computing ...to a machine.],
  epigraph-author: "Alan Turing, 1936",
  scholars: (
    (
      name: "Alan Turing",
      image: image("assets/Alan_Turing.jpg"),
    ),
    (
      name: "Alonzo Church",
      image: image("assets/Alonzo_Church.jpg"),
    ),
    (
      name: "Emil Post",
      image: image("assets/Emil_Post.jpg"),
    ),
    (
      name: "Kurt Gödel",
      image: image("assets/Kurt_Godel.jpg"),
    ),
    (
      name: "Stephen Cook",
      image: image("assets/Stephen_Cook.jpg"),
    ),
    (
      name: "Richard Karp",
      image: image("assets/Richard_Karp.jpg"),
    ),
  ),
)

== From Automata to General Computation

Finite automata recognize regular patterns, and pushdown automata capture recursive structure.
But many computational tasks --- arithmetic on unbounded integers, execution of programs, symbolic reasoning, formal verification --- require a machine that can _store_, _rewrite_, and _revisit_ intermediate results.

A Turing machine is the simplest classical model with exactly this level of generality.
It is strong enough to express arbitrary algorithms, yet simple enough to study mathematically.

#Block(color: yellow)[
  This section formalizes three central notions: _algorithm_, _decidable problem_, and _computational limit_.

  At this point, automata theory becomes the general theory of computation.
]

== Definition of a Turing Machine

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
  Conceptually, a Turing machine has two parts:
  - a small _finite control_ (the current state), and
  - an unbounded _external memory_ (the tape).

  Compared with a finite automaton, it can move in both directions, rewrite symbols, and halt only when it reaches $q_"accept"$ or $q_"reject"$.
]

== Tape, Head, and State

A Turing machine operates on an infinite tape divided into cells, each containing a symbol from $Gamma$.

#align(center)[
  #tm-snapshot(
    ($Blank$, $Blank$, $0$, $0$, $1$, $1$, $0$, $1$, $Blank$, $Blank$, $Blank$),
    head: 4,
    state: [State $q_3$],
    focus: (2, 7),
    show-dots: true,
    caption: [Input $w$],
  )
]

== One Transition Step

The machine starts with the input $w$ written on the tape, the head on the leftmost symbol, in state $q_0$.

At each step:
+ Read the symbol currently under the head.
+ Use the transition function to decide three things:
  - which _state_ to enter next,
  - which _symbol_ to write in the current cell,
  - whether to move the head _left_ or _right_.

For example, if $delta(q, 0) = (r, times, R)$, then in state $q$ on symbol $0$ the machine writes $times$, changes to state $r$, and moves one cell to the right.

== Configurations

#definition[
  A _configuration_ of a TM is a complete snapshot of the computation.
  It records the current state, the tape contents, and the head position.

  We write configurations as $u q v$.
  Here $q$ is the current state.
  String $u$ is the tape content to the left of the head.
  String $v$ begins with the symbol currently under the head.
]

#note[
  Once a configuration is fixed, the entire future computation is determined for a deterministic TM.
]

== Acceptance, Rejection, and Looping

#definition[
  A TM $cal(M)$ on input $w$:
  - _accepts_ $w$ if the computation eventually reaches $q_"accept"$;
  - _rejects_ $w$ if it eventually reaches $q_"reject"$;
  - _loops_ if it never halts.
]

#Block(color: orange)[
  *Important distinction:*
  failing to accept is not the same as rejecting.

  A machine may halt and reject.
  Or it may continue forever without producing any answer.
  This distinction is central in computability theory.
]

== Languages Recognized by Turing Machines

#definition[
  The language _recognized_ by $cal(M)$ is
  $
    lang(cal(M)) = { w in Sigma^* mid(|) cal(M) "accepts" w }.
  $
]

#note[
  If the machine halts on every input, it is a _decider_.
  Otherwise it is only a _recognizer_.
]

== A Turing Machine for *$0^n 1^n$*

#example[
  A TM that recognizes $L = { 0^n 1^n mid(|) n >= 0 }$:

  *Operational idea:* match the symbols in pairs.

  + Start at the left end and find the first uncrossed $0$.
  + Replace it by $times$ to mark that this $0$ has been used.
  + Move right until you encounter the first uncrossed $1$.
  + Replace it by $times$ as well.
  + Return to the left and repeat the same procedure.

  The machine accepts when every $0$ has been matched with a later $1$.
  It rejects as soon as this matching process breaks down --- for example, if a needed $1$ does not exist, or if the order is wrong.
]

#Block(color: yellow)[
  *Why the procedure works:*
  each pass removes exactly one pair $(0,1)$.
  Successful completion therefore guarantees both _equal counts_ and the correct _left-to-right order_.
]

== Trace on $mono("0011")$ --- First Pass

The trace makes the strategy visible: the machine marks one matching $0$-$1$ pair, returns to the left, and repeats the process.

#grid(
  columns: 3,
  column-gutter: 1em,
  row-gutter: 1em,
  tm-excerpt([Step 1 --- Initial], ($0$, $0$, $1$, $1$, $Blank$), head: 0, state: [$q_0$]),
  tm-excerpt([Step 2], ($times$, $0$, $1$, $1$, $Blank$), head: 1, state: [$q_1$]),
  tm-excerpt([Step 3], ($times$, $0$, $1$, $1$, $Blank$), head: 2, state: [$q_1$]),
)

#note[
  The first $0$ has now been marked, and the machine is positioned at the $1$ that will be paired with it.
]

== Trace on $mono("0011")$ --- First Pass Continued

#grid(
  columns: 3,
  column-gutter: 1em,
  row-gutter: 1em,
  tm-excerpt([Step 4], ($times$, $0$, $times$, $1$, $Blank$), head: 3, state: [$q_2$]),
  tm-excerpt([Step 5], ($times$, $0$, $times$, $1$, $Blank$), head: 1, state: [$q_3$]),
  tm-excerpt([Step 6], ($times$, $0$, $times$, $1$, $Blank$), head: 0, state: [$q_3$]),
)

#note[
  One matching pair has been removed.
  The head has returned to the left end of the relevant tape segment.
  The machine is ready for the next iteration.
]

== Trace on $mono("0011")$ --- Second Pass

#grid(
  columns: 3,
  column-gutter: 1em,
  row-gutter: 1em,
  tm-excerpt([Step 7], ($times$, $0$, $times$, $1$, $Blank$), head: 1, state: [$q_0$]),
  tm-excerpt([Step 8], ($times$, $times$, $times$, $1$, $Blank$), head: 2, state: [$q_1$]),
  tm-excerpt([Step 9], ($times$, $times$, $times$, $1$, $Blank$), head: 3, state: [$q_1$]),
)

#note[
  The computation proceeds in the same way on the remaining unmatched symbols.
]

== Trace on $mono("0011")$ --- Acceptance

#grid(
  columns: 2,
  column-gutter: 1em,
  row-gutter: 1em,
  tm-excerpt([Step 10], ($times$, $times$, $times$, $times$, $Blank$), head: 4, state: [$q_2$]),
  tm-excerpt([Step 11 --- Accept], ($times$, $times$, $times$, $times$, $Blank$), head: 3, state: [$q_3$]),
)

Formal trace (abbreviated):
$
  q_0 thin 0011 => times q_1 thin 011 => dots.c => times q_0 thin 0 times 1 => dots.c => "accept"
$

#Block(color: blue)[
  *Visual insight:*
  the tape acts as writable memory.
  Crossing symbols out lets the machine record its progress without storing large counters in the finite control.
]

== DFA, PDA, and TM Compared

#align(center)[
  #table(
    columns: 4,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Feature*], [*DFA*], [*PDA*], [*TM*]),
    [Memory], [Finite control only], [One stack], [Read/write tape],
    [Input access], [Single left-to-right pass], [Single pass + stack access], [Move left or right],
    [Can modify memory?], [No], [Only push/pop], [Yes],
    [Typical task], [Pattern matching], [Parsing nested syntax], [General algorithmic computation],
    [Halting], [Always halts], [Always halts], [May run forever],
    [Language class], [Regular], [Context-free], [Decidable / recognizable],
  )
]

#Block(color: teal)[
  *Historical context:* Alan Turing introduced his machine model in 1936, before electronic computers existed.
  He was trying to formalize the notion of "mechanical procedure" to resolve Hilbert's _Entscheidungsproblem_ (decision problem).
  The Turing machine remains the standard reference model of computation.
]

== Variants of Turing Machines

Several variants of TMs exist, all _equivalent in computational power_:
- _Multi-tape TMs:_ several tapes with independent heads.
- _Non-deterministic TMs:_ $delta$ may branch into several possible moves.
- _Two-way infinite tape:_ the head may roam freely in both directions.
- _Multi-track or multi-head TMs:_ more structured storage, but the same computability.

#theorem[
  Every multi-tape TM can be simulated by a single-tape TM.
]
#proof[
  Encode all virtual tapes on one large tape using separators and marked head positions.
  One simulation round scans this encoding, updates the marked cells, and writes the new symbols.
]

#theorem[
  Every non-deterministic TM can be simulated by a deterministic TM.
]
#proof[
  Explore the entire computation tree systematically, for example breadth-first.
  If some branch accepts, the deterministic simulator will eventually discover it.
]

#note[
  These simulations may slow computation down --- sometimes polynomially, sometimes exponentially --- but they do _not_ change which problems are computable.
]

#place[
  #v(1em)
  #Block(color: blue)[
    The equivalence of deterministic and non-deterministic TMs is _not_ about efficiency.

    Whether they can solve the same problems _efficiently_ is the famous *P vs NP* problem --- one of the most important open questions in mathematics and computer science.
  ]
]

== Equivalent Models of Computation

Turing machines are not the only formal model of algorithmic computation.
What makes the notion of computability convincing is its _robustness_: several independently invented formalisms turn out to define exactly the same class of computable functions.

#align(center)[
  #table(
    columns: 3,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Model*], [*Main idea*], [*Where it appears*]),
    [Lambda calculus], [Computation by substitution], [Logic, proof theory, \ functional programming],
    [Recursive functions], [Composition, primitive recursion, \ minimization], [Number theory and \ mathematical logic],
    [Register / \ RAM machines], [Instructions on integer registers], [Assembly language and \ algorithm design],
    [Boolean circuits], [Finite networks of gates], [Hardware and complexity theory],
    [Cellular automata], [Simple local update rules], [Physics, emergence, simulation],
  )
]

#place[
  #v(1em)
  #Block(color: yellow)[
    *Key insight:* these models arise from logic, arithmetic, hardware, and programming --- yet they all capture the same notion of an _effective procedure_.
  ]
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
  A language $L$ is _Turing-recognizable_ --- also called _semi-decidable_ or _recursively enumerable_ (*RE*) --- if some TM accepts every $w in L$.
  On inputs $w notin L$, the machine may reject or loop forever.
]

#definition[
  A language $L$ is _decidable_ --- also called _recursive_ (*R*) --- if some TM halts on _every_ input and always gives the correct yes/no answer.
]

#definition[
  A language $L$ is _co-recognizable_ (*co-RE*) if its complement $overline(L)$ is Turing-recognizable.
]

#Block(color: yellow)[
  *Operational distinction:*
  a _decider_ always halts with a correct yes/no answer.
  A _recognizer_ is only required to halt on yes-instances.
]

#theorem[
  A language $L$ is decidable iff $L in "RE"$ and $L in "co-RE"$, i.e., $"R" = "RE" intersect "co-RE"$.
]

== Examples of Computability Classes

#align(center)[
  #table(
    columns: 3,
    align: (left, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Problem*], [*Class*], [*Reason*]),
    [DFA membership], [D], [Run the automaton once; it always halts],
    [CFG membership], [D], [Use CYK or another parsing algorithm],
    [SAT], [D], [There are finitely many assignments to try],
    [$"HALT"$], [$"RE" setminus "R"$], [Simulate and accept when halting is observed],
    [$overline("HALT")$], [$"co-RE" setminus "R"$], [Its complement is HALT],
    [$"REGULAR"_"TM"$], [Neither], [No recognizer exists in either direction],
  )
]

#Block(color: blue)[
  _Semi-decidable_ problems often arise when a positive witness can be found by search, but a negative answer would require proving that _no witness exists_.
]

== Decidable $=$ RE $intersect$ co-RE

#proof[
  The forward direction is easy: if $L$ is decidable, then the same decider recognizes $L$, and by swapping accept/reject it also recognizes $overline(L)$.

  For the converse, assume $L in "RE"$ and $L in "co-RE"$.
  Let $M_"yes"$ recognize $L$, and let $M_"no"$ recognize $overline(L)$.

  On input $w$, simulate both machines in _lockstep_:
  - Step 1 of $M_"yes"$, then Step 1 of $M_"no"$,
  - Step 2 of $M_"yes"$, then Step 2 of $M_"no"$,
  - and so on.

  Since every input belongs either to $L$ or to $overline(L)$, one of the two recognizers must eventually accept.
  As soon as that happens, we halt and return the corresponding answer.

  Therefore $L$ is decidable.
]

#Block(color: teal)[
  This trick is called _dovetailing_.
  It is one of the most useful proof ideas in computability theory.
]

== Programs as Data

To ask "does $M$ halt on $w$?" we need to _feed $M$ itself as an input_ to another TM.
That requires encoding machines as strings.

#definition[
  The _encoding_ $angle.l M angle.r in {0,1}^*$ of a TM $M$ is a canonical binary string representation of its description: the state list, alphabet, and transition table, encoded in some fixed format.

  We write $angle.l M, w angle.r$ for the encoding of the pair $(M, w)$.
]

#Block(color: yellow)[
  *Key insight:* TMs can read their _own descriptions_ as input.
  This is _programs as data_ --- and it is why the Halting Problem is well-formed.
  The question "does $M$ halt on $angle.l M angle.r$?" is mathematically well-defined.
]

#pagebreak()

#theorem[Counting Theorem][
  There exist languages over ${0,1}$ that are not Turing-recognizable.
]
#proof[
  There are only _countably many_ TMs, because each machine description is a finite string.
  But there are _uncountably many_ languages, since $power({0,1}^*)$ is uncountable by Cantor's theorem.
  So most languages cannot be matched with any TM at all.
]

#Block(color: blue)[
  *This perspective underlies modern computing:*
  - _Compilers:_ programs that take source code as input.
  - _Interpreters:_ programs that simulate another program on data.
  - _Formal verification:_ tools that analyse program behaviour --- and therefore encounter exactly the limits exposed by undecidability results.
]

== Universal Machines

#theorem[
  There exists a single TM $U$ such that, on input $angle.l M, w angle.r$, the machine $U$ simulates the computation of $M$ on $w$.
]

#proof[
  The encoded transition table of $M$ is part of the input.
  Machine $U$ stores a simulated configuration of $M$ on its own tape and repeatedly applies the next transition described by that table.
  So one fixed machine can imitate any other machine.
]

#Block(color: yellow)[
  *Why this matters:* interpreters, emulators, virtual machines, and stored-program computers all rely on this idea.
  A program is just _data that another program can execute_.
]

== Many-One Reductions

#definition[
  A _many-one reduction_ from $A$ to $B$, written $A scripts(<=)_m B$, is a computable function $f$ such that
  $
    x in A iff f(x) in B
  $
  for every input $x$.
]

#theorem[
  If $A scripts(<=)_m B$ and $B$ is decidable, then $A$ is decidable.
]
#proof[
  To decide whether $x in A$, compute $f(x)$ and run the decider for $B$ on the transformed input $f(x)$.
]

#Block(color: orange)[
  To prove that $B$ is undecidable, it is enough to reduce a known undecidable problem $A$ to it.
  Reductions let us _transfer impossibility_ from one problem to another.
]

== Map of Decidability and Recognizability

#grid(
  columns: 2,
  column-gutter: 1em,

  cetz.canvas({
    import cetz.draw: *
    // RE circle (blue, upper)
    circle((0, 1.6), radius: (3.4, 2.1), stroke: blue.darken(20%))
    // co-RE circle (red, lower)
    circle((0, 0.6), radius: (3.4, 2.1), stroke: red.darken(20%))
    // Chomsky hierarchy nested inside intersection
    circle((0, 0), radius: (0.8, 0.4))
    circle((0, 0.4), radius: (1.4, 0.8))
    circle((0, 0.8), radius: (2, 1.2))
    // circle((0, 1.2), radius: (2.6, 1.6))
    content((0, 0), text(size: .7em)[Regular])
    content((0, 0.8), text(size: .7em)[CF])
    content((0, 1.6), text(size: .7em)[CS])
    content((0, 2.4), text(size: .65em, fill: purple)[R = RE $intersect$ co-RE])
    content((0, 3.4), text(size: .7em, fill: blue.darken(20%))[RE])
    content((0, -1.2), text(size: .7em, fill: red.darken(20%))[co-RE])
    // Problem instances
    circle((2.2, 1.5), radius: 3pt, fill: yellow.darken(10%))
    content((2.2, 1.5), anchor: "north-west", padding: 4pt, text(size: .7em)[SAT])
    circle((1, 3), radius: 3pt, fill: yellow.darken(10%))
    content((1, 3), anchor: "south-west", padding: 4pt, text(size: .7em)[HALT])
    circle((2.5, 3.5), radius: 3pt, fill: yellow.darken(10%))
    content((2.5, 3.5), anchor: "south-west", padding: 4pt, text(size: .7em)[$"REGULAR"_"TM"$])
  }),

  [
    *Classes overview:*
    $ "Regular" subset "CF" subset "CS" subset "R" subset "RE" $
    - *R* = *RE* $intersect$ *co-RE* --- decidable languages
    - *HALT* and *$"A"_"TM"$* lie in *RE* $setminus$ *R* --- yes-instances can be confirmed by simulation
    - $overline("HALT")$ lies in *co-RE* $setminus$ *R*
    - *SAT* lies in *R* --- decidable by exhaustive search; #box[NP-complete]
    - *$"REGULAR"_"TM"$* lies in neither *RE* nor *co-RE*
  ],
)

#place[
  #v(1em)
#Block(color: orange)[
  *Warning:* Decidable $subset.neq$ Recognizable.
  - There exist languages that are recognizable but _not_ decidable (e.g., HALT).
  - Some languages are _not recognizable_ (for example $overline("HALT")$).
  - Some are in neither *RE* nor *co-RE* (for example $"REGULAR"_"TM"$).
]
]

== The Halting Problem

#definition[Halting Problem][
  Given a TM $cal(M)$ and an input $w$, does $cal(M)$ halt on $w$?

  $
    "HALT" = { angle.l cal(M), w angle.r mid(|) cal(M) "is a TM that halts on input" w }
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
  The proof is a precise self-reference paradox: the machine $D$ is forced to halt iff it does _not_ halt.

  This connects computation to Cantor's diagonal argument, Gödel's incompleteness ideas, and deep philosophical questions about the limits of mechanical reasoning.
]

== The Acceptance Problem

#definition[Acceptance Problem][
  $
    "A"_"TM" = { angle.l M, w angle.r mid(|) M "accepts" w }
  $
]

#theorem[
  $"A"_"TM"$ is Turing-recognizable but undecidable.
]

#proof[
  _Recognizable:_ simulate $M$ on $w$. If $M$ accepts, accept. If $M$ rejects or loops, our simulator may simply run forever.

  _Undecidable:_ reduce HALT to $"A"_"TM"$.
  Given $angle.l M, w angle.r$, construct a machine $N$ that ignores its own input, simulates $M$ on $w$, and accepts iff that simulation ever halts.
  Then
  $
    angle.l M, w angle.r in "HALT" iff angle.l N, 0 angle.r in "A"_"TM"
  $
  so a decider for $"A"_"TM"$ would also decide HALT.
]

#place[
  #v(1em)
  #set text(0.8em)
#Block(color: blue)[
  This is the prototypical _semi-decidable_ problem: successful computations can be witnessed, \ but unsuccessful ones may leave us waiting forever.
]
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
  That is, if $P$ is non-trivial and semantic, then ${ angle.l M angle.r mid(|) P(M) }$ is undecidable.
]

#proof[
  Assume WLOG that $P(M_emptyset) = "false"$ where $cal(L)(M_emptyset) = emptyset$.
  Since $P$ is non-trivial, there exists some machine $M_P$ with $P(M_P) = "true"$.

  Reduce HALT to $P$: given $angle.l M, w angle.r$, build a machine $M'$ that on input $x$ first simulates $M$ on $w$.
  - If the simulation of $M$ on $w$ ever halts, then $M'$ continues by simulating $M_P$ on $x$.
  - If the simulation never halts, then $M'$ never reaches the second phase.

  Therefore:
  - if $M$ halts on $w$, then $cal(L)(M') = cal(L)(M_P)$, so $P(M') = "true"$;
  - if $M$ does not halt on $w$, then $cal(L)(M') = emptyset$, so $P(M') = "false"$.

  A decider for $P$ would therefore decide HALT, which is impossible.
]

== Consequences of Rice's Theorem

#align(center)[
  #table(
    columns: (auto, auto, auto),
    align: (left, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Property of $cal(L)(M)$*], [*Decidable?*], [*Reason*]),
    [$cal(L)(M) = emptyset$ (empty language)], [#NO], [Semantic, non-trivial: Rice],
    [$cal(L)(M)$ is finite], [#NO], [Semantic, non-trivial: Rice],
    [$cal(L)(M)$ is infinite], [#NO], [Semantic, non-trivial: Rice],
    [$cal(L)(M)$ contains string $w_0$], [#NO], [Semantic, non-trivial: Rice],
    [$cal(L)(M)$ is regular], [#NO], [Semantic, non-trivial: Rice],
    [$cal(L)(M) = Sigma^*$ (accepts all)], [#NO], [Semantic, non-trivial: Rice],
    [$cal(L)(M_1) = cal(L)(M_2)$ (equivalence)], [#NO], [Semantic, non-trivial: Rice],
    [*$M$ has fewer than 100 states*], [#YES], [*Syntactic* (structural) --- NOT semantic!],
    [*$M$ halts on the empty string $epsilon$ within 100 steps*], [#YES], [*Syntactic:* simulate 100 steps directly],
    [*Is $w in cal(L)(M)$?* for a _fixed known decider_ $M$], [#YES], [Run $M$ on $w$; by assumption it always halts],
  )
]

#Block(color: orange)[
  *The critical distinction:* a property is _decidable_ only when it depends on the _machine description_ (syntactic) rather than on the _language it computes_ (semantic).

  "How many states does $M$ have?" --- we can read off the encoding. Decidable.
  "Does $M$ accept every input?" --- this is about the language. Undecidable.
]

#Block(color: yellow)[
  *Practical consequence:* No static analysis tool, linter, or type checker can ever be _both complete and sound_ for general semantic properties of programs.
  Every real tool is either _approximate_ (may miss bugs) or _conservative_ (may report false positives).
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
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Language Class*], [*Machine*], [*Closure*]),
    [Regular], [DFA/NFA], [All Boolean operations],
    [Context-Free], [PDA], [Union, concat, star; \ not intersection or complement],
    [Decidable], [TM (decider)], [All Boolean operations],
    [Recognizable], [TM (recognizer)], [Union, intersection; \ not complement],
  )
]

== Exercises on Turing Machines

+ *Design a TM* for $L = { a^n b^n c^n mid(|) n >= 0 }$.
  Describe the states and tape actions in plain English (no need for a full transition table).
  What does the tape look like mid-computation?

+ *Tracing:*
  Run the TM for $0^n 1^n$ (from the trace slides) on input $mono("000111")$.
  Write out the full configuration sequence. What happens on input $mono("0011")$? On $mono("001")$?

+ *Variants:*
  A two-tape TM can copy the first half of its input to the second tape.
  Use this to sketch a TM for $L = { w w mid(|) w in {0,1}^* }$.
  Why is this easy with two tapes but hard with one?

+ *Decidability:*
  Classify each property as decidable (D), recognizable but not decidable (R), or not even recognizable (N).
  Justify each answer:
  - ${ angle.l M angle.r mid(|) M "accepts the empty string" }$
  - ${ angle.l M angle.r mid(|) M "halts on all inputs" }$
  - ${ angle.l M angle.r mid(|) M "has exactly 7 states" }$
  - ${ angle.l M_1, M_2 angle.r mid(|) cal(L)(M_1) = cal(L)(M_2) }$

+ *Rice's Theorem:*
  For each property below, state whether Rice's Theorem applies.
  If it does, conclude undecidability.
  If it does not, say why (and determine decidability separately):
  - $cal(L)(M)$ is a regular language.
  - $M$ visits state $q_3$ on input $epsilon$.
  - $M$ accepts at least one palindrome.
  - $M$ has a transition on symbol $\$$.

#Block(color: orange)[
  *Challenge:* prove that $"HALT" scripts(<=)_m { angle.l M angle.r mid(|) cal(L)(M) != emptyset }$ by an explicit reduction.
  Then conclude $"EMPTY"_"TM"$ is undecidable.
]

== Summary of Formal Languages and Automata

+ *Formal languages:*
  every decision problem can be encoded as a language $L subset.eq Sigma^*$. \
  Deciding the problem means deciding whether the input word belongs to $L$.

+ *Regular languages* (DFA $=$ NFA $=$ $epsilon$-NFA $=$ RegExp) --- Kleene's Theorem.
  - Memory model: finitely many states.
  - Pumping Lemma: a _necessary_ test for non-regularity.
  - Myhill-Nerode: a _necessary and sufficient_ characterization.
  - Closure and decision properties are exceptionally strong.

+ *Context-free languages* (CFG $=$ PDA):
  - Memory model: one unbounded stack.
  - CNF and CYK provide a uniform recognition method in $cal(O)(n^3)$ time.
  - CFL Pumping Lemma reveals a higher expressiveness than regular languages.
  - Important questions are still undecidable, including equivalence and ambiguity.

#place(right + horizon, dy: -1.5em)[
  #cetz.canvas({
    import cetz.draw: *
    set-style(stroke: 0.6pt)
    circle((0, 0), radius: (0.8, 0.45), fill: green.transparentize(80%))
    circle((0, 0.35), radius: (1.4, 0.9), fill: blue.transparentize(85%))
    circle((0, 0.7), radius: (2.0, 1.35), fill: purple.transparentize(90%))
    circle((0, 1.05), radius: (2.6, 1.8))
    content((0, 0), text(size: 0.8em)[Regular])
    content((0, 0.9), text(size: 0.8em)[CFL])
    content((0, 1.7), text(size: 0.8em)[Decidable])
    content((0, 2.6), text(size: 0.8em)[RE])
  })
]

== Summary of Turing Machines and Computational Limits

+ *Turing machines* give a mathematically precise model of general computation.
  - They have finite control together with unbounded read/write memory.
  - Many alternative models are equivalent in expressive power.

+ *Decidability landscape:*
  - *R* consists of the decidable languages.
  - *RE* consists of the recognizable languages.
  - Recognizability is strictly weaker than decidability.
  - In fact, $"R" subset.neq "RE"$ and $"R" = "RE" intersect "co-RE"$.

+ *Undecidability is unavoidable:*
  - *HALT* is undecidable by diagonalization.
  - Reductions transfer undecidability from one problem to another.
  - *Rice's Theorem* rules out decision procedures for non-trivial semantic properties of programs.

+ *Big picture:* computation has extraordinary power, but it also has absolute mathematical limits.

+ *Counts argument:* countably many TMs, uncountably many languages --- most are not even RE.

#place(right + horizon, dy: -2em)[
  #set align(left)
  #set text(0.7em)
  #Block(color: yellow)[
    The _language hierarchy_:
    $
      "Regular" subset.neq "CFL" subset.neq "Decidable" subset.neq "RE" subset.neq "All Languages"
    $
    Each step up requires a strictly more powerful machine model:
    $ "DFA" prec "PDA" prec "TM-decider" prec "TM-recognizer" prec "✨" $
  ]
]

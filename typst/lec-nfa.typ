#import "theme.typ": *
#show: slides.with(
  title: [Discrete Mathematics],
  subtitle: "Non-determinism",
  date: "Spring 2025",
  authors: "Konstantin Chukharev",
  ratio: 16 / 9,
  // dark: true,
)

#show table.cell.where(y: 0): strong

#let power(x) = $cal(P)(#x)$
#let regex(s) = raw(s)
#let conf(q, s) = $angle.l #q, #s angle.r$

= Non-determinism

== Non-deterministic Finite Automata

#definition[
  A _non-deterministic finite automaton_ (NFA) is a 5-tuple $cal(A) = (Q, Sigma, delta, q_0, F)$, where
  - $Q$ is a _finite_ set of states,
  - $Sigma$ is an _alphabet_ (finite set of input symbols),
  - $delta: Q times Sigma to power(Q)$ is a _transition function_,
  - $q_0 in Q$ is an _initial_ (_start_) state,
  - $F subset.eq Q$ is a set of _accepting_ (_final_) states.
]

#place(right)[
  #grid(
    columns: 2,
    align: center,
    column-gutter: 1em,
    row-gutter: 0.5em,
    link("https://en.wikipedia.org/wiki/Michael_O._Rabin", image("assets/Michael_Rabin.jpg", height: 3cm)),
    link("https://en.wikipedia.org/wiki/Dana_Scott", image("assets/Dana_Scott.jpg", height: 3cm)),

    [Michael Rabin], [Dana Scott],
  )
]

#note[
  $delta : (q, c) maps underbrace({q^((1))\, dots\, q^((n))}, "non-determinism")$
]

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
    // .* (1 1 0*)+
    finite.automaton(
      aut,
      final: ("q2",),
      style: (
        state: (radius: 0.5, extrude: 0.8),
        transition: (curve: 0.6),
        q1: (label: $q_1$),
        q2: (label: $q_2$),
      ),
    ),
  )

  // This NFA has _two_ transitions from $q_0$ by the symbol $1$.

  // If an NFA needs to make a non-existent transition (e.g., at $q_1$ by $0$), it _dies_ and that particular path rejects.
]

// == DFAs vs NFAs

// #table(
//   columns: 2,
//   stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
//   table.header[Deterministic (DFA)][Non-Deterministic (NFA)],
//   [Single transition per symbol], [Multiple possible transitions],
//   [No $epsilon$-transitions], [May have $epsilon$-transitions],
//   [Unique computation path], [Multiple parallel paths],
// )

== Non-Determinism

#definition[
  A model of computation is _deterministic_ if at every point in the computation, there is exactly _one choice_ that can make.
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

*Intuition on non-determinism*:
+ Tree computation
+ Perfect guessing
+ Massive parallelism

== Tree Computation

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
        layout: finite.layout.custom.with(
          positions: (..) => (
            q0: (0, 0),
            q1: (2, 0),
            q2: (5, 0),
            q3: (1, 2),
            q4: (3, 2),
            q5: (5, 2),
          ),
        ),
      )
      #box(stroke: 1pt, inset: 1em, radius: .5em, fill: blue.lighten(80%))[
        $
          w = "a b a b a"
        $
      ]
    ],
    [
      #import cetz.tree
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
        tree.tree(
          data,
          draw-node: (node, ..) => {
            if node.children.len() == 0 {
              if node.content == $4$ {
                cetz.draw.circle((), radius: 0.3, fill: red.lighten(80%))
              } else if node.content == $5$ and node.depth == 5 {
                cetz.draw.circle((), radius: 0.3, fill: green.lighten(80%))
              } else if node.content == $2$ {
                cetz.draw.circle((), radius: 0.3, fill: red.lighten(80%))
              } else if node.content == $5$ and node.depth == 3 {
                cetz.draw.circle((), radius: 0.3, fill: red.lighten(80%))
              } else {
                cetz.draw.circle((), radius: 0.3, fill: yellow.lighten(80%))
              }
            } else {
              cetz.draw.circle((), radius: 0.3, fill: yellow.lighten(80%))
            }
            cetz.draw.content((), node.content)
          },
        )
      })
    ],
  )
]

- At each _decision point_, the automaton _clones_ itself for each possible decision.
- The series of choices forms a directed, rooted _tree_.
- At the end, if _any_ active accepting (#text(green.darken(20%))[green]) states remain, we _accept_.

== Perfect Guessing

- We can view nondeterministic machines as having _magic superpowers_ that enable them to _guess_ the _correct choice_ of moves to make.

- Machine can always guess the right choice if one exists.

- No physical implementation is known, yet.

== Massive Parallelism

- An NFA can be thought of as a DFA that can be in many states _at once_.

- Each symbol read causes a transition on every active state into each potential state that could be visited.

- Non-deterministic machines can be thought of as machines that can try any number of options in parallel (using an unlimited number of "processors").

== Computation Model

Reachability relation for NFA is very similar to DFA's:
$
  conf(q, x) scripts(tack)_"DFA" conf(r, y) quad &"iff" quad
  cases(
    x = c y & "where" c in Sigma,
    r = delta(q, c)
  ) \
  conf(q, x) scripts(tack)_"NFA" conf(r, y) quad &"iff" quad
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
    cal(L)(cal(A)) = { w in Sigma^* | conf(q_0, w) scripts(tack)^* conf(f, epsilon), f in F }
  $
]

== Rabin--Scott Powerset Construction

Any NFA can be converted to a DFA using _Rabin--Scott subset construction_.

$cal(A)_"N" = angle.l Sigma, Q_"N", delta_"N", q_0, F_"N" angle.r$
- $Q_"N" = {q_1, q_2, ..., q_n}$
- $delta_"N" : Q_"N" times Sigma to power(Q_"N")$

$cal(A)_"D" = angle.l Sigma, Q_"D", delta_"D", {q_0}, F_"D" angle.r$
- $Q_"D" = power(Q_"N") = {emptyset, {q_1}, dots, {q_2, q_4, q_5}, dots, Q_"N"}$
- $delta_"D" : Q_"D" times Sigma to Q_"D"$
- $delta_"D" : (A, c) maps { r | exists q in A. thin r in delta_"N" (q, c) }$
- $F_"D" = { A | A intersect F_"N" != emptyset }$

== $epsilon$-NFA

#definition[
  _Epsilon closure_ of a state $q$, denoted $E(q)$ or $epsilon"-clo"(q)$, is a set of states reachable from $q$ by $epsilon$-transitions.
  $
    E(q) = epsilon"-clo"(q) = { r in Q | #cetz.canvas({
      import cetz.draw: *
      import finite.draw: state, transition

      set-style(state: (radius: 0.3))

      state((0, 0), "q", label: $q$)
      state((1.5, 0), "r", label: $r$)

      transition("q", "r", inputs: "eps", label: $epsilon$, curve: 0.001)
    }) }
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

== From $epsilon$-NFA to NFA

To construct NFA from $epsilon$-NFA:
+ Perform a transitive closure of $epsilon$-transitions.
  - After that, accepted words contain _no two consecutive_ $epsilon$-transitions.
+ Back-propagate accepting states over $epsilon$-transitions.
  - After that, accepted words _do not end_ with $epsilon$.
+ Perform symbol-transition back-closure over $epsilon$-transitions.
  - After that, accepted words _do not contain_ $epsilon$-transitions.
+ Remove $epsilon$-transitions.
  - After that, you get an NFA.

== Kleene's Theorem

#theorem[
  $"REG" = "AUT"$.
]

#proof[($thin "REG" subset.eq "AUT" thin$)][
  _For every regular language, there is a DFA that recognizes it._

  Proof by induction over the _generation index $k$_.
  Show that $forall k. thin "Reg"_k subset.eq "AUT"$.

  Another name of this part: Thompson's construction (NFA from regular expression).

  *Base:* $k = 0$, construct automata for $"Reg"_0 = { emptyset, {epsilon}, {c} "for" c in Sigma }$, _showing $"Reg"_0 subset.eq "AUT"$_:

  #align(center)[
    #cetz.canvas({
      import cetz.draw: *
      import finite.draw: state, transition

      set-style(state: (radius: 0.5, extrude: 0.8, initial: (label: (text: none))))

      state((0, 0), "a1_q0", label: $q_0$, initial: true)
      state((1, 0), "a1_q1", label: $q_1$, final: true)

      translate(x: 4)
      state((0, 0), "a2_q0", label: $q_0$, initial: true)
      state((1, 0), "a2_q1", label: $q_1$, final: true)
      transition("a2_q0", "a2_q1", inputs: "c", label: $epsilon$, curve: 0.5)

      translate(x: 4)
      state((0, 0), "a3_q0", label: $q_0$, initial: true)
      state((1, 0), "a3_q1", label: $q_1$, final: true)
      transition("a3_q0", "a3_q1", inputs: "c", label: $c$, curve: 0.5)

      content((rel: (0, -1), to: ("a1_q0.center", 50%, "a1_q1.center")))[$L = emptyset$]
      content((rel: (0, -1), to: ("a2_q0.center", 50%, "a2_q1.center")))[$L = {epsilon}$]
      content((rel: (0, -1), to: ("a3_q0.center", 50%, "a3_q1.center")))[$L = {c}$]
    })
  ]

  *Induction step:* $k > 0$, already have automata for languages $L_1, L_2 in "Reg"_(k-1)$.

  //   #align(center)[
  //     #cetz.canvas({
  //       import cetz.draw: *
  //       import finite.draw: state, transition

  //       set-style(state: (radius: 0.5, extrude: 0.8, initial: (label: (text: none))))

  //       state((0, 0), "a1_q0", label: $q_0$, initial: true)
  //       state((2, 1), "a1_q1", label: [])
  //       state((2, -1), "a1_q2", label: [])
  //       rect((1, 0.2), (rel: (2, 1.6)))
  //       rect((1, -1.8), (rel: (2, 1.6)))

  //       // translate(x: 3)
  //       // state((0, 0), "a3_q0", label: $q_0$, initial: true)
  //       // state((1, 0), "a3_q1", label: $q_1$, final: true)
  //       // transition("a3_q0", "a3_q1", inputs: "c", label: $c$, curve: 0.5)

  //       content((rel: (0, 2), to: ("a1_q0.center", 50%, "a1_q1.center")))[$L' = L_1 union L_2$]
  //       // content((rel: (0, -1), to: "a2_q0.center"))[$L = {epsilon}$]
  //       // content((rel: (0, -1), to: ("a3_q0.center", 50%, "a3_q1.center")))[$L = {c}$]
  //     })
  //   ]
]

#pagebreak()

#proof[($thin "AUT" subset.eq "REG" thin$)][
  _The language recognized by a DFA is regular._

  TODO: Kleene's algorithm (regular expression from DFA):
  Given a deterministic automaton $cal(A)$, we can construct a regular expression for the regular language recognized by $cal(A)$.
]

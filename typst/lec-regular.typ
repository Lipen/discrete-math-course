#import "theme.typ": *
#show: slides.with(
  title: [Discrete Mathematics],
  subtitle: "(Not only) Regular Languages",
  date: "Spring 2025",
  authors: "Konstantin Chukharev",
  ratio: 16 / 9,
  // dark: true,
)

#show table.cell.where(y: 0): strong

#let power(x) = $cal(P)(#x)$
#let regex(s) = raw(s)
#let conf(q, s) = $angle.l #q, #s angle.r$
#let lang(x) = $cal(L)(#x)$

#let Green(x) = {
  show emph: set text(green.darken(20%))
  text(x, green.darken(20%))
}
#let Red(x) = {
  show emph: set text(red.darken(20%))
  text(x, red.darken(20%))
}

= Regular Languages

== Regular Expressions

Regular languages can be composed from "smaller" regular languages.

- Atomic regular expressions:
  - $emptyset$, an empty language
  - $epsilon$, a singleton language consisting of a single $epsilon$ word
  - $regex("a")$, a singleton language consisting of a single 1-letter word $a$, for each $a in Sigma$

- Compound regular expressions:
  - $R_1 R_2$, the concatenation of $R_1$ and $R_2$
  - $R_1 | R_2$, the union of $R_1$ and $R_2$
  - $R^* = R R R dots$, the Kleene star of $R$
  - $(R)$, just a bracketed expression
  - Operator precedence: $regex("ab*c|d") eq.delta ((regex("a") (regex("b")^*)) regex("c")) | regex("d")$

== Re-visiting States

- Let $D$ be a DFA with $n$ states.
- Any string $w$ accepted by $D$ that has length at least $n$ must visit some state twice.
- Number of states visited is equal to $abs(w) + 1$.
- By the pigeonhole principle, some state is "duplicated", i.e. visited more than once.
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
  - Notation: $y^n$ means "$n$ copies of $y$".

== Weak Pumping Lemma

#theorem[Weak Pumping Lemma for Regular Languages][
  - For any regular language $L$,
    - There exists a positive natural number $n$ (also called _pumping length_) such that
      - For any $w in L$ with $abs(w) >= n$,
        - There exists strings $x$, $y$, $z$ such that
          - For any natural number $i$,
            - $w = x y z$ ($w$ can be broken into three pieces)
            - $y != epsilon$ (the middle part is not empty)
            - $x y^i z in L$ (the middle part can repeated any number of times)
]

#example[
  Let $Sigma = {0, 1}$ and $L = { w in Sigma^* | w "contains" 00 "as a substring" }$.
  Any string of length 3 or greater can be split into three parts, the second of which can be "pumped".
]

#example[
  Let $Sigma = {0, 1}$ and $L = { epsilon, 0, 1, 00, 01, 10, 11 }$.
  The weak pumping lemma still holds for finite languages, because the pumping length $n$ can be longer than the longest word in the language!
]

== Testing Equality

#definition[
  The _equality problem_ is, given two strings $x$ and $y$, to decide whether $x = y$.
]

#example[
  Let $Sigma = {0, 1, "#"}$.
  We can _encode_ the equality problem as a string of the form _$x "#" y$_.
  - "Is _001_ equal to _110_ ?" would be _$001 "#" 110$_.
  - "Is _11_ equal to _11_ ?" would be _$11 "#" 11$_.
  - "Is _110_ equal to _110_ ?" would be _$110 "#" 110$_.

  Let $"EQUAL" = { w "#" w | w in {0, 1}^* }$.

  *Question:* Is $"EQUAL"$ a _regular_ language?
]

A typical word in $"EQUAL"$ looks like this: $001 "#" 001$.
- If the "middle" piece is just a symbol $"#"$, then observe that $001 thin 001 notin "EQUAL"$.
- If the "middle" piece is either completely to the left or completely to the right of $"#"$, then observe that any duplication or removal of this piece is not in $"EQUAL"$.
- If the "middle" piece includes $"#"$ and any symbols from the left/right of it, then, again, observe that any duplication or removal of this piece is not in $"EQUAL"$.

#theorem[
  $"EQUAL"$ is not a regular language.
]

#proof[
  By contradiction.
  Assume that $"EQUAL"$ is a regular language.

  Let $n$ be the pumping length guaranteed by the weak pumping lemma.
  Let $w = 0^n "#" 0^n$, which is in $"EQUAL"$ and $abs(w) = 2n + 1 >= n$.
  By the weak pumping lemma, we can write $w = x y z$ such that $y != epsilon$ and for any $i in NN$, $x y^i "#" z in "EQUAL"$.
  Then $y$ cannot contain $"#"$, since otherwise if we let $i = 0$, then $x y^0 "#" z = x "#" z$ does not contain $"#"$ and would not be in $"EQUAL"$.
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

= Non-regular Languages

== (Not only) Regular Languages

- The weak pumping lemma describes a property common to _all_ regular languages.
- Any language $L$ which does not have this property _cannot be regular_.
- What other languages can we find that are not regular?

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

The weak pumping lemma can be thought of as a _game_ between #Green[*you*] and an #Red[*adversary*].
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
    table.header[#Red[Adversary]][#Green[You]],
    [Maliciously choose \ pumping length $n$], [],
    [], [Cleverly choose a string \ $w in L$, $abs(w) >= n$],
    [Maliciously split \ $w = x y z$, $y != epsilon$], [],
    [], [Cleverly choose an $i$ \ such that $x y^i z notin L$],
    Red[Lose], Green[Win],
    table.cell(colspan: 2, stroke: (top: 0.4pt))[#Green[${0^n 1^n}$ is not regular]],
  )
]

// #[
//   #import fletcher: diagram, node, edge
//   #diagram(
//     // debug: true,
//     edge-stroke: 0.8pt,
//     node-corner-radius: 3pt,
//     spacing: (1em, 0.5em),
//     blob((0,0), Red[*Adversary*], tint: red),
//     blob((1,0), Green[*You*], tint: green),
//     blob((0,1), [Maliciously choose \ pumping length $n$], tint: red),
//     edge("-}>"),
//     blob((1,2), [Cleverly choose a string \ $w in L$, $abs(w) >= n$], tint: green),
//     edge("-}>"),
//     blob((0,3), [Maliciously split \ $w = x y z$, $y != epsilon$], tint: red),
//     edge("-}>"),
//     blob((1,4), [Cleverly choose an $i$ \ such that $x y^i z notin L$], tint: green),
//     edge("-}>"),
//     blob((0,5), [Lose], tint: red),
//     edge("-}>"),
//     blob((1,5), [Win], tint: green),
//   )
// ]


== Formal Proof of Non-regularity

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

= Pumping Lemma

== Pumping

Consider the language $L$ over $Sigma = {0, 1}$ of strings $w in Sigma^*$ that contain _an equal number_ of $0$s and $1$s.

For example:
- #Green[`01`] in $L$
- #Red[`11011`] not in $L$
- #Green[`110010`] in $L$

*Question:* Is $L$ a _regular_ language?

Let's _use_ the weak pumping lemma to show it is by _pumping all the strings_ in this language.

#proof[(incorrect)][
  We are going to show that $L$ satisfies the conditions of the weak pumping lemma.
  Let $n = 2$.
  Consider any string $w in L$ (i.e., $w$ contains the same number of $0$s and $1$s) with $abs(w) >= 2$.

  We can split $w = x y z$ such that $x = z = epsilon$ and $y = w$, so $y != epsilon$.
  Then, for any natural number $i in NN$, $x y^i z = w^i$, which has the same number of $0$s and $1$s.

  Since $L$ passes the conditions of the weak pumping lemma, $L$ is regular.
]

== A word of Caution

- The weak and full pumping lemmas describe the _necessary_ condition of regular languages.
  - If $L$ is _regular_, then it _passes_ the conditions of the pumping lemma.
  - If a language _fails_ the pumping lemma, it is _definitely not regular_.

- The weak and full pumping lemmas are _not a sufficient_ condition of regular languages.
  - If $L$ is _not regular_, then it still _may pass_ the conditions of the pumping lemma.
  - If a language _passes_ the pumping lemma, we _learn nothing_ about whether it is regular or not.

== The Stronger Pumping Lemma

The language $L$ _can_ be proven to be _non-regular_ using a _stronger version_ of the pumping lemma.

For the intuition behind the "full" pumping lemma, let's revisit our original observation.
- Let $D$ be a DFA with $n$ states.
- Any string $w$ accepted by $D$ of length at least $n$ must visit some state twice _within its first $n$_ symbols.
  - The number of visited states is equal to $n + 1$.
  - By the pigeonhole principle, some state is _duplicated_.
- The substring of $w$ between those _revisited states_ can be removed, duplicated, tripled, etc. without changing the fact that $D$ accepts $w$.

Overall, we can add the following condition to the weak pumping lemma:
$
  abs(x y) <= n
$
This restriction means that we can limit where the string to pump must be.
If we specifically choose the first $n$ characters of the string to pump, we can ensure $y$ (middle part) to have a specific property.

We can then show that $y$ cannot be pumped arbitrarily many times.

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

== Formal Proof of Non-regularity

#theorem[
  $L = { w in {0,1}^* | w "has an equal number of 0s and 1s" }$ is _not regular_.
]

#proof[
  By contradiction.
  Assume that $L$ is regular.

  Let $n$ be the pumping length guaranteed by the weak pumping lemma.
  Consider the string $w = 0^n 1^n$.
  Then $abs(w) = 2n >= n$ and $w in L$.
  Therefore, there exist strings $x$, $y$, and $z$ such that $w = x y z$, $abs(x y) <= n$, #box[$y != epsilon$], and for any $i in NN$, we have $x y^i z in L$.

  Since $abs(x y) <= n$, $y$ must consist solely of $0$s.
  But then $x y^2 z = 0^(n+abs(y)) 1^n$, and since $abs(y) > 0$, $x y^2 z notin L$.

  We have reached a contradiction, so our assumption was wrong and $L$ is not regular.
]

== Summary of the Pumping Lemma

+ Using the _pigeonhole principle_, we can prove the weak and full _pumping lemma_.

+ These lemmas describe essential properties of the _regular_ languages.

+ Any language that _fails_ to have these properties _can not be regular_.

= Closure Properties of Regular Languages

== Closure of Regular Languages

+ The _union_ of two regular languages is regular.
+ The _intersection_ of two regular languages is regular.
+ The _complement_ of a regular language is regular.
+ The _difference_ of two regular languages is regular.
+ The _reversal_ of a regular language is regular.
+ The _Kleene star_ of a regular language is regular.
+ The _concatenation_ of regular languages is regular.
+ A _homomorphism_ (substitution of strings for symbols) of a regular language is regular.
+ The _inverse homomorphism_ of a regular language is regular.

== Closure under Union

#theorem[
  If $L$ and $M$ are regular languages, then so is their union $L union M$.
]

#proof[
  Since $L$ and $M$ are regular, they have regular expressions, i.e. $L = lang(R)$ and $M = lang(S)$.

  Then $L union M = lang(R + S)$ by the definition of the union ($+$) operator for regular expressions.
]

== Closure under Complement

#theorem[
  If $L$ is a regular language over the alphabet $Sigma$, then its complement $overline(L) = Sigma^* - L$ is also a regular language.
]

#proof[
  Let $L = lang(A)$ for some DFA $A = (Q, Sigma, delta, q_0, F)$.
  Then $overline(L) = lang(B)$, where $B$ is the DFA $(Q, Sigma, delta, q_0, Q - F)$.
  That is, $B$ is exactly like $A$, but with the accepting states flipped.
  Then $w$ is in $overline(L)$ if and only if $delta(q_0, w)$ is in $Q - F$, which occurs if and only if $w$ is not in $lang(A)$.
]

#example[
  The DFA $A$ presented below on the left accepts only the strings of 0's and 1's that end in $regex("01")$, $lang(A) = regex("(0+1)*01")$.
  The complement of $lang(A)$ is therefore all strings of 0's and 1's that _do not_ end in $regex("01")$.
  Below on the right is the automaton for ${0,1}^* - lang(A)$.
  // It is the same as on the left, but with the accepting states flipped.

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

// TODO: example of a non-regular language NOTEQUAL = overline(EQUAL)

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
  Note that we assume that the alphabets of both automata are the same (or $Sigma$ is their union).
  // The product construction also works for NFAs, but to keep things simple we assume that both $A_L$ and $A_M$ are DFAs.

  For $L intersect M$, we construct the automaton $A$ that simulates both $A_L$ and $A_M$.
  The states of $A$ are the product of the states of $A_L$ and $A_M$.
  The initial state is $(q_L, q_M)$, and the accepting states are $F_L times F_M$.
  The transitions are defined as $delta(angle.l p, q angle.r, c) = angle.l delta_L (p, c), delta_M (q, c) angle.r$.

  To see why $lang(A) = lang(A_L) intersect lang(A_M)$, first observe that $hat(delta) (angle.l q_L, q_M angle.r, w) = angle.l hat(delta)_L (q_L, w), hat(delta)_M (q_M, w) angle.r$.
  But $A$ accepts $w$ if and only if $hat(delta) (q_0, w)$ is in $F_L times F_M$, which occurs if and only if $hat(delta)_L (q_L, w)$ is in $F_L$ and $hat(delta)_M (q_M, w)$ is in $F_M$.
  Or rather, $A$ accepts $w$ if and only if both $A_L$ and $A_M$ accept $w$.
  Thus, $A$ accepts the intersection of $L$ and $M$.
]

#example[
  The first automaton on the left accepts all strings that _have a 0_.
  The second automaton in the middle accepts all strings that _have a 1_.
  On the right, we show the _product_ of these two automata.
  Its states are labelled by the pairs of states of the two automata.
  It is easy to see that this automaton accepts the _intersection_ of the two languages: all strings that _have both a 0 and a 1_.

  #cetz.canvas({
    import cetz.draw: *
    import finite.draw: state, transition

    set-style(state: (radius: 0.5, extrude: 0.8))

    group({
      state((0.566, 0), "p", label: $p$, initial: true)
      state((2, 0), "q", label: $q$, final: true)

      transition("p", "q", inputs: 0, curve: 0.001)
      transition("p", "p", inputs: 1, curve: 0.5)
      transition("q", "q", inputs: (0, 1), curve: 0.5)
    })

    translate((5, 0))

    group({
      state((0.566, 0), "r", label: $r$, initial: true)
      state((2, 0), "s", label: $s$, final: true)

      transition("r", "s", inputs: 1, curve: 0.001)
      transition("r", "r", inputs: 0, curve: 0.5)
      transition("s", "s", inputs: (0, 1), curve: 0.5)
    })

    translate((5, 1))

    group({
      state((0.566, 0), "pr", label: $p r$, initial: true)
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

== Closure under Difference

#theorem[
  If $L$ and $M$ are regular languages, then so is their difference $L minus M$.
]

#proof[
  Observe that $L minus M = L intersect overline(M)$.
  By previous theorems, $overline(M)$ is regular, and $L intersect overline(M)$ is also regular.
]

== Closure under Reversal

#definition[
  The _reversal_ of a string $w = a_1 a_2 dots a_n$ is the string $w^R = a_n a_(n-1) dots a_1$.

  #example[
    $0010^R = 0100$ and $epsilon^R = epsilon$.
  ]
]

#definition[
  The _reversal_ of a language $L$ is the language $L^R = { w^R | w in L }$.

  #example[
    Let $L = { 001, 10, 111 }$, then $L^R = { 001^R, 10^R, 111^R } = { 100, 01, 111 }$.
  ]
]

#theorem[
  If $L$ is a regular language, then so its reversal $L^R$.
]

#proof[
  Assume $L$ is defined by regular expression $E$.
  The proof is a structural induction on the size of $E$.
  We show that there is another regular expression $E^R$ such that $lang(E^R) = (lang(E))^R$, that is, the language of $E^R$ is the reversal of the language of $E$.

  _Basis:_ If $E$ is $epsilon$, $emptyset$, or $regex("a")$ for some symbol $a$, then $E^R$ is the same as $E$.

  _Induction:_ There are three cases, depending on the form of $E$.
  + $E = E_1 + E_2$.
    Then $E^R = E_1^R + E_2^R$.

    The justification is that the reversal of the union of two languages is obtained by computing the reversals of the two languages and taking the union of those languages.

  + $E = E_1 E_2$. Then $E^R = E_2^R E_1^R$.
    Note that we reverse the order of the two languages, as well as reversing the languages themselves.
    For example, if $lang(E_1) = {0,1 111}$ and $lang(E_2) = {00, 10}$, then $lang(E_1 E_2) = {0100, 0110, 11100, 11110}$.
    The reversal of the latter language is
    $
      {0010, 0110, 00111, 01111}
    $
    If we concatenate the reversals of $lang(E_2)$ and $lang(E_1)$, we get
    $
      {00,01} {10, 111} = {0010, 00111, 0110, 01111}
    $
    which is the same language as $(lang(E_1 E_2))^R$.
    In general, if a word $w$ in $lang(E)$ is the concatenation of $w_1$ from $lang(E_1)$ and $w_2$ from $lang(E_2)$, then $w^R = w_2^R w_1^R$.

  + $E = E_1^*$. Then $E^R = (E_1^R)^*$.

    The justification is that any string $w$ in $lang(E)$ can be written as $w_1 w_2 dots w_n$, where each $w_i$ is in $lang(E_1)$.
    Then $w^R = w_n^R w_(n-1)^R dots w_1^R$.
    Each $w_i^R$ is in $lang(E^R)$, so $w^R$ is in $lang((E_1^R)^*)$.

    Conversely, any string in $lang((E_1^R)^*)$ is of the form $w_1 w_2 dots w_n$, where each $w_i$ is the reversal of a string in $lang(E_1)$.
    The reversal of this string, $w_n^R w_(n-1)^R dots w_1^R$, is therefore a string in $lang(E_1^*)$, which is $lang(E)$.

    We have thus shown that a string is in $lang(E)$ if and only if its reversal is in $lang((E_1^R)^*)$.
]

#example[
  Let $L$ be defined by the regular expression $regex("(0+1)0*")$.
  Then $L^R$ is the language of $(regex("0*"))^R (regex("0+1"))^R$.

  If we apply the rules for Kleene star and union to the two parts, and then apply the basis rule that says the reversals of $regex("0")$ and $regex("1")$ are unchanged, we find that $L^R$ has regular expression $regex("0*(0+1)")$.
]

= Decision Properties of Regular Languages

== Fundamental Questions about Languages

+ Is the language _empty_?

+ Is the language _finite_?

+ Is the particular string $w$ _in_ the language?

+ Is the language a _subset_ of another language?

+ Are the two languages _equivalent_?

== Converting Among Representations

- $epsilon$-closure: $O(n^3)$

- $epsilon$-NFA to DFA: $n^3 2^n$

- DFA to $epsilon$-NFA: $O(n)$

- $epsilon$-NFA to RegEx: $O(n^3 4^n)$

- RegEx to $epsilon$-NFA: $O(n)$

== Testing Emptiness of a Regular Language

Given an automaton, we can determine whether the accepting states are reachable, in $O(n^2)$ time.

Given a regular expression, we can construct an $epsilon$-NFA and then determine the reachability of the accepting states, in $O(n)$ time.
Alternatively, we can inspect the regex directly.

== Testing Membership in a Regular Language

Given an automaton with $s$ states and a string $w$ of size $n$, we can simulate the automaton for $w$ to determine whether it accepts $w$.
For DFA, this can be done in $O(n)$ time.
For NFA or $epsilon$-NFA, in $O(n s^2)$.

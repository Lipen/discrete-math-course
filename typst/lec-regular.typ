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

#import "common.typ": *
#show: template

#set page(
  paper: "a4",
  margin: (top: 3cm, rest: 2cm),
  header: [
    #set text(10pt)
    #smallcaps[*Homework Assignment \#6*]
    #h(1fr)
    #link("https://github.com/Lipen/discrete-math-course")[*Discrete Mathematics*]
    \
    *Languages and Computation*
    #h(1fr)
    *$#emoji.seedling$ Spring 2026*
    #place(bottom, dy: 0.4em)[
      #line(length: 100%, stroke: 0.6pt)
    ]
  ],
)

#set text(12pt)
#set par(justify: true)

#show table.cell.where(y: 0): strong
#show heading.where(level: 2): set block(below: 1em, above: 1.4em)
#show emph: set text(fill: blue.darken(20%))

// Custom operators for formal language theory
#let lang(x) = $cal(L)(#x)$
#let power(x) = $cal(P)(#x)$
#let conf(q, s) = $angle.l #q, #s angle.r$
#let Blank = math.class("normal", sym.square.stroked)
#let regex(s) = raw(s)

// Color helpers
#let Green(x) = text(green.darken(20%), x)
#let Red(x) = text(red.darken(20%), x)
#let Blue(x) = text(blue.darken(20%), x)
#let Orange(x) = text(orange.darken(20%), x)

#let True = Green(`true`)
#let False = Red(`false`)
#let YES = Green(sym.checkmark)
#let NO = Red(sym.crossmark)

// Task list helper
#let tasklist(id, cols: 1, format: "1.", body) = {
  let s = counter(id)
  s.update(1)
  set enum(numbering: _ => context {
    s.step()
    s.display(format)
  })
  columns(cols, gutter: 1em)[#body]
}

// Fancy box (italic, gray-bordered)
#let Box(body, align: left, inset: 0.8em) = std.align(align)[
  #box(
    stroke: 0.4pt + gray,
    inset: inset,
    radius: 3pt,
  )[
    #set std.align(left)
    #set text(size: 10pt, style: "italic")
    #body
  ]
]

// Fancy block (left-bordered, for hints and notes)
#let Block(body, ..args) = {
  block(
    body,
    inset: (x: 1em),
    stroke: (left: 3pt + gray),
    outset: (y: 3pt, left: -3pt),
    ..args,
  )
}

// Tag helpers
#let Tag(label, color) = {
  set text(size: 0.8em)
  box(
    label,
    radius: 5pt,
    inset: (x: 0.4em),
    outset: (y: 0.4em),
    stroke: 0.6pt + color.darken(20%),
    fill: color.lighten(80%),
  )
}
#let TagCore = Tag("Core", green)
#let TagChallenge = Tag("Challenge", purple)
#let TagBonus = Tag("Bonus", yellow)


// Import CeTZ for the crossword renderer
#import "@preview/cetz:0.4.2"

// Regex crossword renderer using CeTZ
//
// rpats-left:  row patterns shown to the LEFT  (required, one per row)
// cpats-top:   column patterns shown on TOP     (required, one per column)
// rpats-right: row patterns shown to the RIGHT  (optional)
// cpats-bot:   column patterns shown on BOTTOM  (optional)
// title:       optional title shown above
//
// Grid is drawn in CeTZ coordinates: origin = top-left of cell (0,0),
// x increases right, y increases down (we negate y internally).
#let crw(
  rpats-left,
  cpats-top,
  rpats-right: (),
  cpats-bot: (),
  title: none,
) = {
  let sz = 1.0 // cell size in cm
  let lpad = 0.2 // padding between label and cell edge
  let nr = rpats-left.len()
  let nc = cpats-top.len()

  let ltext(s) = text(.8em, raw(s))
  let col-label(s) = rotate(90deg, reflow: true, ltext(s))

  let has-right = rpats-right.len() > 0
  let has-bot = cpats-bot.len() > 0

  let grid-w = nc * sz
  let grid-h = nr * sz
  let left-w = 0.0
  let right-w = if has-right { 3.0 } else { 0.0 }
  let top-h = 0.0 // headroom for rotated labels
  let bot-h = if has-bot { 3.0 } else { 0.0 }

  align(center)[
    #cetz.canvas(length: 1cm, {
      import cetz.draw: *

      // ── Title: top-left corner of the canvas ────────────────────────
      if title != none {
        content((-lpad, lpad), anchor: "south-east", align(right + bottom, text(8pt, emph(title))))
      }

      // ── Grid cells ──────────────────────────────────────────────────
      for row in range(nr) {
        for col in range(nc) {
          let x = left-w + col * sz
          let y = -(top-h + row * sz)
          rect((x, y), (x + sz, y - sz), stroke: 0.6pt)
        }
      }

      // ── Top column labels ────────────────────────────────────────────
      for (col, pat) in cpats-top.enumerate() {
        let cx = left-w + col * sz + sz / 2
        content((cx, -top-h + lpad), anchor: "south", col-label(pat))
      }

      // ── Bottom column labels ─────────────────────────────────────────
      if has-bot {
        for (col, pat) in cpats-bot.enumerate() {
          let cx = left-w + col * sz + sz / 2
          content((cx, -(top-h + grid-h) - lpad), anchor: "north", col-label(pat))
        }
      }

      // ── Left row labels ──────────────────────────────────────────────
      for (row, pat) in rpats-left.enumerate() {
        let cy = -(top-h + row * sz + sz / 2)
        content((left-w - lpad, cy), anchor: "east", ltext(pat))
      }

      // ── Right row labels ─────────────────────────────────────────────
      if has-right {
        for (row, pat) in rpats-right.enumerate() {
          let cy = -(top-h + row * sz + sz / 2)
          content((left-w + grid-w + lpad, cy), anchor: "west", ltext(pat))
        }
      }
    })
  ]
}


// ─────────────────────────────────────────────────────────────────────────────

== Problem 1: Language Zoo #h(1fr)#TagCore

A _formal language_ over alphabet $Sigma$ is any set $L subset.eq Sigma^*$.

#tasklist("prob1")[
  + For each language below, list _three words in $L$_ and _three words not in $L$_:
    #tasklist("prob1a", format: "(a)")[
      + $L_1 = { w in {0,1}^* mid(|) w "contains" mono("010") "as a substring" }$
      + $L_2 = { a^n b^m mid(|) n >= 1, m >= 0 }$ over $Sigma = {a, b}$
      + $L_3 = { w in {a,b}^* mid(|) abs(w) "is prime" }$
      + $L_4 = { w \# w mid(|) w in {0,1}^* }$ over $Sigma = {0, 1, \#}$
    ]

  + Let $L = {mono("01"), mono("10")}$ over $Sigma = {0,1}$.
    Explicitly describe or list each of the following languages:
    #tasklist("prob1b", cols: 3, format: "(a)")[
      + $L^2 = L dot L$
      + $L^3$
      #colbreak()
      + $L^*$ and $L^+$
      + $overline(L) = Sigma^* setminus L$
      #colbreak()
      + $L dot {0, 1}$
    ]

  + Classify each language by the _lowest_ level of the Chomsky hierarchy it belongs to.
    #tasklist("prob1c", format: "(a)")[
      + ${ a^n mid(|) n >= 0 }$
      + ${ a^n b^n mid(|) n >= 0 }$
      + ${ a^n b^n c^n mid(|) n >= 0 }$
      + ${ angle.l M, w angle.r mid(|) "TM" M "halts on input" w }$
    ]

]


// ─────────────────────────────────────────────────────────────────────────────

== Problem 2: Regular Expressions #h(1fr)#TagCore

#Box[
  *Regex quick reference:*

  #grid(
    columns: 3,
    column-gutter: 2em,
    [
      - `ab` = concatenation.
      - `a|b` = alternation.
      - `(...)` = grouping.
    ],
    [
      - `a*` = zero or more.
      - `a+` = one or more.
      - `a?` = optional (0 or 1).
    ],
    [
      - `a{n}` = exactly $n$ times.
      - `[abc]` = any of the listed characters.
      - `[^abc]` = any character _except_ those listed.
    ],
  )

  // *PCRE extensions*:
  // - `.` = any single character.
  // - `\s` = whitespace (space, tab, ...).
  // - `\1` = backreference to group 1 (if group 1 matched `X`, then `\1` must also match `X`).
]

#tasklist("prob2")[
  + For each regular expression over $Sigma = {a, b, c, d}$, describe the formal language in plain natural language, and count the _exact number of words of length $<= 4$_ it accepts.

    #tasklist("prob2a", cols: 3, format: "(a)")[
      + #regex("ab*")
      + #regex("(a|b)+c?")
      #colbreak()
      + #regex("(ab|ba){2}")
      + #regex("[^ab]+(a|b)")
      #colbreak()
      + #regex("d(a|bc)*d")
    ]

  + Write a regular expression for each of the following languages over $Sigma = {0, 1}$:
    #tasklist("prob2b", format: "(a)")[
      + All strings that _start and end with the same symbol_.
      + All strings _with no two consecutive_ $mono("1")$s.
      + All strings of _even length_.
      + All strings whose _length is divisible by 3_.
      + All strings _containing_ $mono("110")$ as a substring.
      + All strings where _every_ $mono("1")$ is _immediately followed by_ a $mono("0")$.
    ]

  + Prove that $regex("(a*)* = a*")$.

  // #colbreak()

  + *(Regex Crosswords)*#footnote[
      Puzzles adapted from #link("https://regexcrossword.com").
      Visit for hundreds of crosswords at all difficulty levels!
    ]
    Fill each cell with a _single ASCII character_ (uppercase letter, digit, punctuation, or space).
    Every row and column must match the corresponding regex pattern (read from left to right and top to bottom, respectively).

    #Block[
      // *Notation:*
      - `[^ABC]` matches any character _except_ those listed.
      - "`.`" matches _any_ single character (unless escaped!).
      - `\1` is a PCRE _backreference_ to the first capturing group --- not a classical regex feature, but treat it concretely: if group 1 matched `X`, then `\1` must also match `X`.
    ]

    #grid(
      columns: 2,
      column-gutter: 1em,
      row-gutter: 1em,
      align: center + horizon,

      // ── Beatles (2 × 2, Beginner) ──────────────────────────────────
      crw(
        ("HE|LL|O+", "[PLEASE]+"),
        ("[^SPEAK]+", "EP|IP|EF"),
        title: [The Beatles \ (2 × 2)],
      ),

      // ── Royal Dinner (5 × 3, Experienced) ─────────────────────────
      crw(
        ("(Y|F)(.)\\ \\2[DAF]\\1", "(U|O|I)*T[FRO]+", "[KANE]*[GIN]*"),
        ("(FI|A)+", "(YE|OT)K", "(.)[IF]+", "[NODE]+", "(FY|F|RG)+"),
        title: [Royal Dinner \ (5 × 3)],
      ),

      // ── Technology (4 × 3, Intermediate) ───────────────────────────
      crw(
        ("[RUNT]*", "O.*[HAT]", "(.)*DO\\1"),
        ("[^NRU](NO|ON)", "(D|FU|UF)+", "(FO|A|R)*", "(N|A)*"),
        title: [Technology \ (4 × 3)],
      ),

      // ── GMC Vandura (3 × 2, Double Cross) ──────────────────────────
      crw(
        ("(CAT|A-T)+", "[MA\\-\\sE]+"),
        ("[^MCI]+", ".A", "(TM|BF)"),
        rpats-right: ("[^KI\\sP]+", "(M|APS|EA)*"),
        cpats-bot: ("[AI][E\\s]", "[A\\-Z]+", "[\\sT\\-M]+"),
        title: [GMC Vandura \ (3 × 2)],
      ),

      // ── Big Mac (3 × 4, Double Cross) ──────────────────────────────
      crw(
        (".[LUH]+", "(P|K)[^U]+", ".*C+[TIF]", "(NO|ONE|ION)*"),
        ("(.)\\ \\1(.)\\ \\2", "[C\\sOU]+", "[^PU\\sH]+"),
        rpats-right: (".*L+", "[PUF\\s]*", "[TIC]*", "[NOI\\sE]+"),
        cpats-bot: ("[PIF]+", ".*[OWE]*", "(TN|LF|TF)*"),
        title: [Big Mac \ (3 × 4)],
      ),

      // ── Time Walker (4 × 4, Palindromeda) ──────────────────────────
      crw(
        ("(EP|ST)*", "T[A-Z]*", ".M.T", ".*P.[S-X]+"),
        (".*E.*", "[^P]I(IT|ME)", "(EM|FE)(IT|IP)", "(TS|PE|KE)*"),
        title: [Time Walker \ (4 × 4)],
      ),
    )
]


// ─────────────────────────────────────────────────────────────────────────────

#pagebreak()

== Problem 3: DFA Construction #h(1fr)#TagCore

#tasklist("prob3")[
  + For each language over $Sigma = {0, 1}$, design a DFA (draw a state diagram _and_ write the transition table).
    Indicate the start state and all accepting states.
    #[
      #set enum(numbering: "(a)")
      + $L_A = { w mid(|) w "ends with" mono("101") }$
      + $L_B = { w mid(|) w "has an odd number of" mono("1")s "and an even number of" mono("0")s }$ \
        _(Hint: track parities of both counts --- 4 states suffice.)_
      + $L_C = { w mid(|) w "interpreted as a binary number is divisible by 3" }$ \
        _(Hint: track the remainder modulo 3 --- 3 states suffice.)_
      + $L_D = { w mid(|) w "contains neither" mono("00") "nor" mono("11") "as a substring" }$ \
        _(Hint: the "last symbol seen" determines the state.)_
    ]

  + The DFA $cal(A)$ below has states $Q = {q_0, q_1, q_2}$ over $Sigma = {"a", "b"}$.

    #align(center)[
      #let aut-given = (
        q0: (q0: "a", q1: "b"),
        q1: (q2: "a", q1: "b"),
        q2: (q0: "a", q1: "b"),
      )
      #grid(
        columns: 2,
        column-gutter: 3em,
        align: center + horizon,
        finite.transition-table(aut-given),
        finite.automaton(aut-given, final: ("q2",), style: (
          state: (radius: 0.5, extrude: 0.8),
          transition: (curve: 0.5),
          q0: (label: $q_0$),
          q1: (label: $q_1$),
          q2: (label: $q_2$),
          q2-q1: (curve: 0.2),
          q2-q0: (curve: 1.5),
        )),
      )
    ]
    #[
      #set enum(numbering: "(a)")
      + What language does $cal(A)$ recognize? Give a concise description _and_ a regular expression.
      + Trace the computation on each input: $epsilon$, $mono("ba")$, $mono("aba")$, $mono("bbba")$.
        Does $cal(A)$ accept or reject each?
      + Is $lang(cal(A))$ finite or infinite?
        How can you determine this from the DFA alone?
    ]

  + *Prove* that the DFA you constructed for $L_C$ is correct.
    Specifically, show by induction on $abs(w)$ that after reading prefix $w$, the automaton is in state $r_i$ if and only if $w equiv i thin (mod thin 3)$ (treating $w$ as a binary number).
    _(Remark: the empty string $epsilon$ represents the value $0$, so the machine starts in $r_0$.)_
]


// ─────────────────────────────────────────────────────────────────────────────

== Problem 4: Powerset Construction #h(1fr)#TagCore

Consider the NFA $cal(N)$ over $Sigma = {0, 1}$ with states $Q = {q_0, q_1, q_2, q_3}$, start state $q_0$, accepting state~$q_3$, and the transition table below.

#align(center)[
  #let nfa-010 = (
    q0: (q0: ("0", "1"), q1: "0"),
    q1: (q2: "1"),
    q2: (q3: "0"),
    q3: (q3: ("0", "1")),
  )
  #grid(
    columns: 2,
    column-gutter: 1em,
    align: center + horizon,
    [
      #table(
        columns: 4,
        align: center,
        stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
        table.header([*State*], [$delta(-, mono("0"))$], [$delta(-, mono("1"))$], [*Accepting?*]),
        [$q_0$], [${ q_0, q_1 }$], [${ q_0 }$], [],
        [$q_1$], [$emptyset$], [${ q_2 }$], [],
        [$q_2$], [${ q_3 }$], [$emptyset$], [],
        [$q_3$], [${ q_3 }$], [${ q_3 }$], [#YES],
      )
    ],
    finite.automaton(nfa-010, final: ("q3",), style: (
      state: (radius: 0.5, extrude: 0.8),
      transition: (curve: 0.5),
      q0: (label: $q_0$),
      q1: (label: $q_1$),
      q2: (label: $q_2$),
      q3: (label: $q_3$),
    )),
  )
]
#[
  #set enum(numbering: "(a)")
  + What language does $cal(N)$ recognize?
    Argue informally (what pattern must $w$ satisfy to be accepted?) and give a regular expression.
  + Apply the _Rabin--Scott powerset construction_ to convert $cal(N)$ to a DFA $cal(D)$.
    Enumerate all _reachable_ DFA states (as subsets of $Q$) and compute the transition table.
    Mark which states are accepting.
  + Draw $cal(D)$.
    How many reachable states does it have?
    How does this compare to the $2^4 = 16$ states that the powerset construction could in principle produce?
]


// ─────────────────────────────────────────────────────────────────────────────

== Problem 5: Kleene's Theorem in Action #h(1fr)#TagCore

#Block[
  *Kleene's Theorem:* A language is _regular_ (described by a regex) if and only if it is recognized by a _finite automaton_ (DFA/NFA/$epsilon$-NFA).
  The proof is constructive in both directions:
  - _Regex $to$ $epsilon$-NFA_: Thompson's construction (induction on the grammar).
  - _DFA $to$ Regex_: Kleene's algorithm (dynamic programming, analogous to Floyd--Warshall).
]

#tasklist("prob5")[
  + *Thompson's construction.*
    Consider the regular expression $regex("(0|01)*1")$ over $Sigma = {0, 1}$.
    #[
      #set enum(numbering: "(a)")
      + Construct an $epsilon$-NFA for this language using Thompson's construction.
      + Compute the $epsilon$-closure of each state.
      + Eliminate the $epsilon$-transitions to obtain a plain NFA.
        Test your NFA on the inputs $mono("1")$, $mono("01")$, $mono("001")$, $mono("011")$.
    ]

  + *Kleene's algorithm.*
    Consider the DFA $cal(D)$ with states ${ A, B, C }$ over $Sigma = {0, 1}$:

    #align(center)[
      #let dfa-kleene = (
        A: (B: "0", A: "1"),
        B: (B: "0", C: "1"),
        C: (B: "0", A: "1"),
      )
      #grid(
        columns: 2,
        column-gutter: 3em,
        align: center + horizon,
        finite.transition-table(dfa-kleene),
        finite.automaton(dfa-kleene, final: ("C",), style: (
          state: (radius: 0.5, extrude: 0.8),
          transition: (curve: 0.5),
          C-B: (curve: 0.2),
          C-A: (curve: 1.5),
        )),
      )
    ]
    #[
      #set enum(numbering: "(a)")
      + What language does $cal(D)$ accept?
        Give an informal English description.
      + Define the base cases $R_(i j)^0$ for all pairs of states $(A, B, C)$ numbered $1, 2, 3$.
      + Compute $R_(i j)^1$, $R_(i j)^2$, and finally $R_(i j)^3$ for the pair $(i,j) = (1, 3)$, i.e. extract the regex for words that take $A$ to $C$.
        Show all intermediate steps.
    ]

  + *Conversion cycle.*
    Let $L = { w in {0,1}^* mid(|) abs(w) equiv 0 thin (mod thin 2) }$ (strings of _even length_).
    #[
      #set enum(numbering: "(a)")
      + Write a regular expression $R$ for $L$.
      + Convert $R$ to an $epsilon$-NFA using Thompson's construction.
      + Convert the $epsilon$-NFA to a DFA using the powerset construction.
      + Convert the DFA back to a regex using Kleene's algorithm.
      + Is the resulting regex syntactically identical to $R$?
        Do the two regexes describe the same language?
        Explain briefly.
    ]
]


// ─────────────────────────────────────────────────────────────────────────────

== Problem 6: Pumping Lemma #h(1fr)#TagCore

#Box[
  *Full Pumping Lemma for Regular Languages.*
  Let $L$ be a regular language.
  Then there exists $n in NN$, $n > 0$, such that for every $w in L$ with $abs(w) >= n$,
  there exist strings $x, y, z$ satisfying:
  - $w = x y z$,
  - $y != epsilon$,
  - $abs(x y) <= n$, and
  - $x y^i z in L$ for every $i in NN$.
]

#tasklist("prob6")[
  + For each language, determine whether it is _regular_ or not.
    For regular languages, exhibit a DFA or regular expression.
    For non-regular languages, prove non-regularity using the pumping lemma.
    - Fix an arbitrary pumping length $n >= 1$.
    - Exhibit a specific $w in L$ with $abs(w) >= n$, expressed as a function of $n$.
    - Show that every valid split $w = x y z$ with $y != epsilon$ and $abs(x y) <= n$ leads to a contradiction: produce an explicit $i >= 0$ such that $x y^i z notin L$.

    #[
      #set enum(numbering: "(a)")
      + ${ 0^(2n) mid(|) n >= 0 }$
      + ${ 0^n 1^(2n) mid(|) n >= 0 }$
      + ${ w in {0,1}^* mid(|) w = w^R }$ (binary palindromes)
      + ${ w in {0,1}^* mid(|) hash_0 (w) eq.not hash_1 (w) }$ (unequal counts)
      + ${ w w mid(|) w in {0,1}^* }$
      + ${ 1^(n^2) mid(|) n >= 0 }$ (perfect-square lengths)
      + ${ w in {a,b}^* mid(|) w "has more" a"'s than" b"'s" }$
    ]

  + *(Weak vs. full pumping lemma.)*
    Consider $L = { w in {0,1}^* mid(|) hash_0 (w) = hash_1 (w) }$
    (strings with _equal_ numbers of $0$s and $1$s).
    #[
      #set enum(numbering: "(a)")
      + Show that $L$ _passes the weak pumping lemma_:
        for any $n$ and any $w = 0^n 1^n$, the adversary can always find a split $w = x y z$
        (without the constraint $abs(x y) <= n$) such that all pumpings stay in $L$.
        _(Hint: let $y$ span the boundary between $0$s and $1$s.)_
      + Now apply the _full_ pumping lemma (with the constraint $abs(x y) <= n$).
        Show that the adversary is forced to choose $y$ entirely from the leading $0$s,
        and derive a contradiction.
      + Conclude that $L$ is not regular.
        Explain in one sentence why the full version catches what the weak version misses.
    ]
]


// ─────────────────────────────────────────────────────────────────────────────

== Problem 7: Myhill--Nerode Theorem #h(1fr)#TagCore

#Box[
  *Myhill--Nerode Theorem.*
  A language $L subset.eq Sigma^*$ is _regular_ if and only if the relation $scripts(equiv)_L$ defined by
  $
    x scripts(equiv)_L y quad iff quad forall z in Sigma^*. (x z in L iff y z in L)
  $
  has _finite index_ (finitely many equivalence classes).
  Moreover, the number of classes equals the number of states in the _minimal DFA_ for $L$.
]

#tasklist("prob7")[
  + *Non-regularity via distinguishable strings.*
    Recall: strings $x_1, x_2, dots$ are _pairwise $L$-distinguishable_ if for every $i != j$
    there exists $z$ such that exactly one of $x_i z$, $x_j z$ is in $L$.
    An infinite set of pairwise distinguishable strings implies $L$ is not regular.

    For each language, exhibit an _infinite_ set of pairwise $L$-distinguishable strings:
    #[
      #set enum(numbering: "(a)")
      + $L = { 0^n 1^n mid(|) n >= 0 }$.
        _(Use the strings $0^0, 0^1, 0^2, dots$ and find the right $z$ for each pair.)_
      + $L = { w w mid(|) w in {0,1}^* }$.
        _(Use the strings $0^0 1, 0^1 1, 0^2 1, dots$)_
      + $L = { w in {0,1}^* mid(|) w "is a palindrome" }$.
        _(Find an appropriate infinite family.)_
    ]

  + *Minimal DFA via equivalence classes.*
    Identify the Myhill--Nerode equivalence classes of each language over $Sigma = {0,1}$,
    and draw the corresponding minimal DFA.
    Verify that the number of classes equals the number of DFA states.
    #[
      #set enum(numbering: "(a)")
      + $L = { w mid(|) w "ends with" mono("01") }$. _(Claim: exactly 3 classes.)_
      + $L = { w mid(|) w "has an odd number of" mono("1")s }$. _(Claim: exactly 2 classes.)_
      + $L = { w mid(|) w "has length divisible by 3" }$. _(Claim: exactly 3 classes.)_
    ]

  + *Conceptual question.*
    Explain in your own words:
    #[
      #set enum(numbering: "(a)")
      + Why does the number of Myhill--Nerode classes equal the number of states in the _minimal_ DFA?
        What is the role of the transition function $delta([x], a) = [x a]$?
      + What goes wrong (specifically, what does the DFA fail to do) if we try to _merge_
        two states that belong to different equivalence classes?
    ]
]


// ─────────────────────────────────────────────────────────────────────────────

== Problem 8: Closure Properties #h(1fr)#TagCore

#tasklist("prob8")[
  + *(True / False / Depends.)*
    For each statement, decide whether it is _always true_, _always false_,
    or _depends on the choice of languages_.
    For each answer, give a brief _proof_ (if always true/false) or a _counterexample_ (if depends).
    #[
      #set enum(numbering: "(a)")
      + If $L$ is regular, then $L^R = { w^R mid(|) w in L }$ is regular.
      + If $L_1$ and $L_2$ are both non-regular, then $L_1 union L_2$ is non-regular.
      + If $L_1 union L_2$ is regular and $L_1$ is regular, then $L_2$ is regular.
      + If $L_1 dot L_2$ is regular, then both $L_1$ and $L_2$ are regular.
      + If $L$ is regular, then ${ w mid(|) w w in L }$ is regular.
    ]

  + *(Product construction.)*
    Let $L_1 = { w in {0,1}^* mid(|) w "contains" mono("00") }$
    and $L_2 = { w in {0,1}^* mid(|) w "contains" mono("11") }$.
    Both are regular.
    #[
      #set enum(numbering: "(a)")
      + Construct a DFA $cal(A)_1$ for $L_1$ (3 states) and a DFA $cal(A)_2$ for $L_2$ (3 states).
        Draw both automata.
      + Construct the _product automaton_ $cal(A)_1 times cal(A)_2$ for $L_1 intersect L_2$.
        The product state space is $Q_1 times Q_2$; mark the initial and accepting states.
      + Which states of the product automaton are accepting for $L_1 union L_2$?
      + Draw the resulting product DFA (after removing unreachable states).
        What is the language $L_1 intersect L_2$ in plain English?
    ]

]


// ─────────────────────────────────────────────────────────────────────────────

== Problem 9: Context-Free Grammars #h(1fr)#TagCore

A _context-free grammar_ $G = (V, Sigma, R, S)$ has _variables_ $V$, _terminals_ $Sigma$,
_productions_ $R$, and a _start variable_ $S$.
The language $cal(L)(G)$ is the set of all terminal strings derivable from $S$.

#tasklist("prob9")[
  + *Reading grammar notation (warm-up).*
    Each grammar below is written in _EBNF_ (Extended Backus--Naur Form),
    a compact notation widely used in language specifications (Python grammar, JSON RFC, SQL standard).

    #Box[
      *EBNF quick reference:*

      #grid(
        columns: 3,
        column-gutter: 2em,
        [
          - `<name> ::= ...` defines a non-terminal.
          - `"x"` is a literal character.
        ],
        [
          - `AB` = concatenation.
          - `A | B` = alternation.
          - `(...)` = grouping.
        ],
        [
          - `A?` = optional (0 or 1).
          - `A+` = one or more.
          - `A*` = zero or more.
        ],
      )
    ]

    For each EBNF grammar, (i)~describe the language in _plain English_, (ii)~give a _regular expression_ defining the same language (if possible), and (iii)~argue whether the language is _regular_ or not.
    #[
      #set enum(numbering: "(a)")
      +
        ```
        <integer> ::= <sign>? <nonzero> <digit>*
        <sign>    ::= "+" | "-"
        <nonzero> ::= "1" | "2" | ... | "9"
        <digit>   ::= "0" | "1" | ... | "9"
        ```
        _(Examples: `42`, `-7`, `+100` are in; `007`, `0`, `+-5` are not.)_

      +
        ```
        <id>     ::= <letter> <rest>*
        <rest>   ::= <letter> | <digit> | "_"
        <letter> ::= "a" | ... | "z" | "A" | ... | "Z"
        <digit>  ::= "0" | ... | "9"
        ```
        _(This is the simplified token grammar for identifiers in most programming languages.)_
    ]

  + For each CFG, describe $cal(L)(G)$ (in English and set-builder notation)
    and show 4--5 example derivations to confirm your answer.
    Also exhibit _one string not in the language_ and briefly argue why no derivation of it exists.
    #[
      #set enum(numbering: "(a)")
      + $G_1$: $quad S -> mono("0") S mono("1") mid(|) epsilon$
      + $G_2$: $quad S -> a S b mid(|) b S a mid(|) S S mid(|) epsilon$
      + $G_3$: $quad S -> A B, quad A -> a A mid(|) a, quad B -> b B mid(|) b$
      + $G_4$: $quad S -> a S a mid(|) b S b mid(|) a mid(|) b mid(|) epsilon$
    ]

  + Design a CFG for each of the following languages:
    #[
      #set enum(numbering: "(a)")
      + ${ a^i b^j c^k mid(|) i = j space "or" space j = k }$

        #Block[
          *Hint:* Use the union: design $G'$ for ${a^n b^n c^k}$ and $G''$ for ${a^i b^n c^n}$, then combine with $S to S' mid(|) S''$.
        ]

      + ${ w in {a,b}^* mid(|) hash_a (w) = 2 dot.op hash_b (w) }$

        #Block[
          *Hint:* Each $b$ must be paired with two $a$'s.
          Think of productions that introduce two $a$'s alongside each $b$:
          for example, $S -> a a S b S mid(|) a S a S b mid(|) S a a S b mid(|) dots$
        ]

      + The set of all properly matched bracket strings over $Sigma = {mono("("), mono(")")}$. \
        For example, $mono("()")$, $mono("(())")$, $mono("()()")$ are properly matched; $mono(")(")$ and $mono("(()")$ are not.
    ]

  + *Chomsky Normal Form.*
    A CFG is in _Chomsky Normal Form_ (CNF) if every production has the form $A -> B C$ (two variables) or $A -> a$ (one terminal).

    #[
      #set enum(numbering: "(a)")
      + Convert the grammar $S -> mono("0") S mono("1") mid(|) epsilon$ into CNF.
        Show each step of the conversion: add new start symbol, eliminate $epsilon$-productions, then binarize rules.
      + Why is CNF useful?
        Name one algorithm that requires the grammar to be in CNF.
    ]
]


// ─────────────────────────────────────────────────────────────────────────────

== Problem 10: Turing Machines #h(1fr)#TagCore

#Box[
  *Turing Machine.*
  A TM $cal(M) = (Q, Sigma, Gamma, delta, q_0, q_"acc", q_"rej")$ reads and writes on an infinite tape.
  At each step, based on the current state and tape symbol, it: transitions to a new state,
  writes a symbol, and moves the head left ($L$) or right~($R$).
  It _accepts_ if it reaches $q_"acc"$, _rejects_ if it reaches $q_"rej"$, and may _loop_ forever.
  A language is _decidable_ if some TM always halts; _recognizable_ (RE) if some TM accepts every word in the language (but may loop on other inputs).
]

#tasklist("prob10")[
  + *Tracing.*
    Consider a Turing machine $cal(M)$ for ${ 0^n 1^n mid(|) n >= 0 }$ that works as follows:
    repeatedly find the leftmost uncrossed $mono("0")$, mark it, move right to find the leftmost uncrossed $mono("1")$,
    mark it, and return to the left; if it ever sees a $mono("1")$ before an unmatched $mono("0")$, it rejects;
    if all symbols are matched, it accepts.

    For each input, show the computation as a sequence of _configurations_
    (using the notation $angle.l alpha; q; beta angle.r$ where $q$ is the current state,
    $alpha$ is the tape to the left of the head, $beta$ is the tape at and to the right of the head).
    State whether $cal(M)$ _accepts_, _rejects_, or _loops_.
    #[
      #set enum(numbering: "(a)")
      + Input $0011$
      + Input $001$
      + Input $epsilon$ (empty input)
      + Input $10$
    ]

  + *Design.*
    Describe --- in clear informal pseudocode or numbered steps, _not_ a full state table ---
    a Turing machine for each language.
    For each, argue briefly why the machine _always halts_.
    #[
      #set enum(numbering: "(a)")
      + $L = { 0^(2^n) mid(|) n >= 0 }$, strings whose length is a _power of 2_.

        #Block[*Hint:* Repeatedly halve the tape: cross off every other $0$.
          Accept if exactly 1 unmarked $0$ remains; reject if an odd number $> 1$ remains.]

      + $L = { w \# w mid(|) w in {0,1}^* }$, the _equality language_.

        #Block[*Hint:* Match the $k$-th symbol on the left of $\#$ with the $k$-th symbol on the right.
          Use crossing-off and left-right zigzagging.]
    ]

  + *Decidability classification.*
    For each language, classify it as:
    *(R)* decidable, *(RE $setminus$ R)* recognizable but undecidable, or *(co-RE)* / *(neither)* as applicable.
    Justify briefly (cite Rice's theorem, known reductions, or direct arguments).
    #[
      #set enum(numbering: "(a)")
      + ${ angle.l M angle.r mid(|) M "is a TM with exactly 5 states" }$
      + ${ angle.l M, w angle.r mid(|) M "accepts" w "within 1000 steps" }$
      + ${ angle.l M angle.r mid(|) M "accepts the empty string" epsilon }$
      + ${ angle.l M angle.r mid(|) cal(L)(M) "is infinite" }$
      + ${ angle.l M angle.r mid(|) cal(L)(M) = Sigma^* }$ (the TM accepts _everything_)
    ]
]


// ─────────────────────────────────────────────────────────────────────────────
// ─── CHALLENGE SECTION ───────────────────────────────────────────────────────

// #pagebreak()

== Problem 11: Exact Counting vs Modular Counting #h(1fr)#TagChallenge

#tasklist("prob11")[
  + *(Closure instead of pumping.)*
    Consider $L = { 0^i 1^j mid(|) i != j }$.
    #[
      #set enum(numbering: "(a)")
      + Prove that $L$ is _not regular_ using _closure properties_, not the pumping lemma.

      + Explain briefly why closure is the natural tool here.
        What structure of the language does the closure argument expose?
    ]

  + *(Regularity from similarity.)*
    The language $L_(a=b) = { w in {a,b}^* mid(|) hash_a (w) = hash_b (w) }$, where $hash_a (w)$ and $hash_b (w)$ are the number of $a$'s and $b$'s in~$w$ respectively, is not regular (it requires unbounded counting).
    Now consider $L' = { w in {a,b}^* mid(|) hash_a (w) equiv hash_b (w) thick (mod thin 2) }$.
    #[
      #set enum(numbering: "(a)")
      + Is $L'$ regular?
        Prove your answer (build DFA/regex if yes, apply pumping lemma if no).
      + Explain intuitively why modular counting is "easier" for a DFA than exact counting.
    ]

  + *(Minimal automata for modular counting.)*
    Fix an integer $m >= 2$ and define the language
    $ L_m = { w in {a,b}^* mid(|) hash_a (w) equiv hash_b (w) thin (mod thin m) } $

    #[
      #set enum(numbering: "(a)")
      + Construct a DFA $cal(A)_m$ for $L_m$ with $m$ states.
        Prove that your DFA recognizes exactly $L_m$.
      + Describe the meaning of each state and the transition rule on input $a$ and $b$.
        State a precise invariant of the form "after reading $w$, the automaton is in state $q_k$ iff ..." and prove it.
      + Prove that no DFA with fewer than $m$ states can recognize $L_m$.
        #Block[
          *Hint:* Show that the strings $epsilon, a, a^2, dots, a^(m-1)$ are pairwise distinguishable w.r.t. $L_m$.
        ]
    ]
]


// ─────────────────────────────────────────────────────────────────────────────

#pagebreak()

== Problem 12: Non-Regular Languages and the Closure Game #h(1fr)#TagChallenge

#tasklist("prob12")[
  + *(Closure traps.)*
    For each claim, decide: is it *always* true, or can it *fail*?
    If it always holds, prove it.
    If it can fail, give an explicit counterexample (a concrete non-regular $L$, $L_1$, or $L_2$).
    #tasklist("prob12a", format: "(a)")[
      + $L$ non-regular $quad=>quad$ $L^2 = L dot L$ non-regular.
      + $L$ non-regular $quad=>quad$ $L^*$ non-regular.
      + $L_1, L_2$ non-regular $quad=>quad$ $L_1 intersect L_2$ non-regular.
      + $L_1$ regular, $L_2$ non-regular $quad=>quad$ $L_1 setminus L_2$ non-regular.
    ]

  + *(Mutual constraints.)*
    Suppose we are given that:
    - $L_1 union L_2 = Sigma^*$ (#emph[regular]),
    - $L_1 intersect L_2 = { a^n b^n mid(|) n >= 0 }$ (#emph[non-regular]).

    What can you conclude about $L_1$ and $L_2$?
    Can _both_ be regular?
    Can _exactly one_ be regular?
    Can _both_ be non-regular?
    Prove each case that is possible, and disprove each case that is not.

  // #colbreak()

  + *(Half-language.)*
    Define $"HALF"(L) = { x mid(|) exists y in Sigma^*. abs(y) = abs(x) "and" x y in L }$
    (the first half of strings in $L$).

    Prove: if $L$ is _regular_, then $"HALF"(L)$ is also _regular_.

    #Block[
      *Hint:* Start from a DFA for $L$.
      Think about what information about a prefix $x$ is enough to decide whether there exists a suffix $y$ with $abs(y) = abs(x)$ and $x y in L$.
    ]

  + *(Homomorphisms.)*
    A _string homomorphism_ $h : Sigma_1^* to Sigma_2^*$ replaces each symbol $a in Sigma_1$
    by a fixed string $h(a) in Sigma_2^*$.
    Define $h : {a, b}^* to {0, 1}^*$ by $h(a) = mono("01")$ and $h(b) = mono("10")$.

    #tasklist("prob12d", format: "(a)")[
      + Let $L = { w in {0,1}^* mid(|) w "starts with" mono("01") }$.
        Describe the inverse image
        $h^(-1)(L) = { x in {a,b}^* mid(|) h(x) in L }$,
        and determine whether it is regular.

      + Let $P = { w w^R mid(|) w in {a,b}^* }$ be the language of even-length palindromes over $\{a,b\}$.
        Is~the~image $h(P)$ regular?
        Justify your answer carefully.

      + State and prove the theorem:
        if $L subset.eq Sigma_2^*$ is regular, then $h^(-1)(L)$ is regular.
        Your proof should explain how to build a finite automaton for $h^(-1)(L)$ from a finite automaton for $L$.
    ]
]


// ─────────────────────────────────────────────────────────────────────────────

== Problem 13: Undecidability from First Principles #h(1fr)#TagChallenge

#tasklist("prob13")[
  + *Rice's Theorem* states: any non-trivial property of the _language_ of a TM is undecidable.

    #Box[
      *Rice's Theorem.*
      Let $P$ be a property of languages such that:
      - $P$ is _non-trivial_: there exist TMs $M_1, M_2$ with $cal(L)(M_1) in P$ and $cal(L)(M_2) notin P$.
      Then ${ angle.l M angle.r mid(|) cal(L)(M) in P }$ is _undecidable_.
    ]

    For each property $P$, determine whether ${ angle.l M angle.r mid(|) cal(L)(M) in P }$ is decidable or undecidable.
    If~undecidable, cite Rice's theorem and verify that $P$ is non-trivial.
    If decidable, explain why.
    #tasklist("prob13a", format: "(a)")[
      + $P$: "$cal(L)(M)$ contain s at least one string."
      + $P$: "$cal(L)(M)$ is empty."
      + $P$: "$cal(L)(M)$ is a regular language."
      + $P$: "$M$ has fewer than 100 states." _(Careful: is this a property of the language or the machine?)_
      + $P$: "$M$ halts on all inputs."
      + $P$: "$cal(L)(M)$ contains at least one palindrome."
    ]

  + *(Reduction: $"HALT" scripts(<=)_m A_"TM"$.)*
    Recall:
    $
      A_"TM" = { angle.l M, w angle.r mid(|) M "accepts" w }, quad
      "HALT" = { angle.l M, w angle.r mid(|) M "halts on" w }.
    $

    Show that $A_"TM"$ is undecidable by reducing from $"HALT"$:
    construct an explicit TM reduction $f$ such that
    $angle.l M, w angle.r in "HALT" iff f(angle.l M, w angle.r) in A_"TM"$.

    #[
      #set enum(numbering: "(a)")
      + Describe the reduction $f$ explicitly:
        given $angle.l M, w angle.r$, how do you build a new TM $M'$ such that
        $M'$ accepts its input iff $M$ halts on $w$?
      + Verify correctness: if $M$ halts on $w$, does $M'$ accept?
        If $M$ does not halt on $w$, does $M'$ reject (or loop)?
      + Conclude: if $A_"TM"$ were decidable, then $"HALT"$ would also be decidable --- contradiction.
    ]

  + *(Diagonalization.)*
    A student proposes the following "algorithm" $H$ for the halting problem:
    #Box[
      Simulate $M$ on $w$ step by step.
      After each step, check if $M$ has halted.\
      If $M$ halts, output _YES_.
      If $M$ has not halted after $k$ steps, output _NO_.
    ]
    #[
      #set enum(numbering: "(a)")
      + What is wrong with this algorithm?
        For which inputs does it give the wrong answer, and why?
      + Even if we let $k -> infinity$ ("simulate forever and wait"), why doesn't this solve the halting problem?
      + The actual undecidability proof constructs a TM $D$ that, on input $angle.l M angle.r$,
        loops iff $M$ halts on $angle.l M angle.r$, and halts iff $M$ does not halt on $angle.l M angle.r$.
        What happens when we run $D$ on $angle.l D angle.r$?
        Describe the contradiction that arises.
    ]
]


// ─────────────────────────────────────────────────────────────────────────────

#line(length: 100%, stroke: 0.4pt)

== Notes on Tag System

#Block[
  The problems in this assignment are _tagged_:

  #TagCore are essential problems that you _must solve_ to pass the assignment.

  #TagChallenge are _non-mandatory_ problems that could be _skipped_ for a passing grade.

  #TagBonus are _optional_ problems for _memorable experience_.
  They won't be graded.
]


// ─────────────────────────────────────────────────────────────────────────────

#pagebreak()

#align(center)[
  #set text(1.2em, weight: "bold")
  Optional Bonus Problems
]

#Block[
  The following problems are _"optional"_.
  They require programming and/or deeper theory.
  They will _not_ count toward your grade but may earn bonus points and --- more importantly --- genuine understanding.
]


// ─────────────────────────────────────────────────────────────────────────────

== Problem A: Regex Engine #h(1fr)#TagBonus

Implement a simplified regex-to-DFA compiler in a language of your choice (Python recommended).

#tasklist("probA")[
  + *Parsing.*
    Implement a _recursive-descent parser_ for the grammar below (no lookahead, no backreferences):
    #Box[
      ```
      <regex>  ::= <term> ( '|' <term> )*
      <term>   ::= <factor>+
      <factor> ::= <atom> ( '*' | '+' | '?' )?
      <atom>   ::= char | '(' <regex> ')'
      ```
    ]
    Represent the result as an AST (abstract syntax tree).

  + *Thompson's NFA.*
    Implement Thompson's construction to convert the AST to an $epsilon$-NFA.
    Represent states as integers and transitions as adjacency lists.

  + *Powerset (subset) construction.*
    Convert the $epsilon$-NFA to a DFA.
    Implement $epsilon$-closure and transition computation on sets of states.

  + *Testing.*
    Test your engine on the following and verify against Python's built-in `re` module:
    - regex `(a|b)*abb` on all strings over ${"a","b"}$ of length $<= 8$
    - regex `0*(10*10*)*` on all binary strings of length $<= 10$

  + *Count.*
    For regex `ab*c|d` over $Sigma = {"a","b","c","d"}$,
    use your engine to enumerate and count all accepted words of length $<= 6$.
]


// ─────────────────────────────────────────────────────────────────────────────

== Problem B: DFA Minimization #h(1fr)#TagBonus

Implement the _table-filling_ algorithm for DFA minimization.

#tasklist("probB")[
  + *Table-filling algorithm.*
    Given a complete DFA $(Q, Sigma, delta, q_0, F)$:
    #[
      #set enum(numbering: "(a)")
      + Mark all pairs $(p, q)$ where exactly one of $p, q$ is accepting.
      + Repeat: for each unmarked pair $(p, q)$, if there exists $a in Sigma$ such that
        $( delta(p, a), delta(q, a) )$ is already marked, mark $(p, q)$ as well.
        Stop when no new pair is marked in a full pass.
      + The _unmarked_ pairs are pairs of equivalent (indistinguishable) states.
        Merge them into single states.
    ]

  + Test your implementation on at least three nontrivial DFAs.
    At least one of them should come from applying the powerset construction to an NFA of your choice.
    Report the number of states before and after minimization in each case.

  + *Correctness.*
    Prove that the table-filling algorithm marks $(p, q)$ if and only if $p$ and $q$ are
    distinguishable (belong to different Myhill--Nerode equivalence classes).

  + *Benchmark.*
    Implement _Hopcroft's algorithm_ (time $O(n log n)$).
    - Randomly generate DFAs over $Sigma = {0, 1}$ with $n in {10, 50, 100, 500, 1000}$ states.
    - Compare runtimes of table-filling ($O(n^2 abs(Sigma))$) vs. Hopcroft.
    - Include a plot of "runtime vs. $n$".
]


// ─────────────────────────────────────────────────────────────────────────────

== Problem C: CYK Membership Testing #h(1fr)#TagBonus

Implement the _Cocke--Younger--Kasami_ (CYK) algorithm for context-free grammar membership.

#tasklist("probC")[
  + *CNF conversion.*
    Implement a general CFG to Chomsky Normal Form converter.
    Your algorithm should:
    #[
      #set enum(numbering: "(a)")
      + Add a new start symbol $S'$ with $S' -> S$.
      + Eliminate $epsilon$-productions (nullable variables).
      + Eliminate _unit productions_ ($A -> B$).
      + _Binarize_ all remaining productions of length $>= 3$.
    ]
    Verify your converter on the grammar
    $S -> mono("0") S mono("1") mid(|) epsilon$.

  + *CYK algorithm.*
    Implement CYK: given a CFG $G$ in CNF and a string $w = a_1 dots a_n$,
    compute the $n times n$ table $T[i,j] = { A in V mid(|) A scripts(=>)^* a_i dots a_j }$.
    Time complexity: $O(n^3 abs(G))$.

  + *Parse tree reconstruction.*
    Extend your CYK implementation to _reconstruct a parse tree_ (not just answer yes/no).

  + *Testing.*
    Test on:
    #[
      #set enum(numbering: "(a)")
      + The grammar $S -> mono("0") S mono("1") mid(|) epsilon$: verify all $0^n 1^n$ for $n = 1, dots, 8$ are accepted;
        verify $0^n 1^m$ for $n != m$ are rejected.
      + A small arithmetic expression grammar:
        $E -> E + T mid(|) T$, $T -> T * F mid(|) F$, $F -> mono("(")E mono(")") mid(|) "num"$.
        Test on `num + num * num` and `(num + num) * num`.
    ]

  + *Benchmark.*
    Measure parsing time vs. string length $n$ for $n = 10, 20, 50, 100, 200$.
    Verify the $O(n^3)$ scaling empirically (plot time vs. $n^3$; the line should be approximately linear).
]

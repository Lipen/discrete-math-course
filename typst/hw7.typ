#import "common.typ": *
#show: template

#set page(
  paper: "a4",
  margin: (top: 3cm, rest: 2cm),
  header: [
    #set text(10pt)
    #smallcaps[*Homework Assignment \#7*]
    #h(1fr)
    #link("https://github.com/Lipen/discrete-math-course")[*Discrete Mathematics*]
    \
    *Combinatorics*
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

// Stirling number of the second kind
#let stirling(n, k) = $vec(delim: "{", #n, #k)$

// Shorthand for C_n^k (k-combinations)
#let C(n, k) = $C_(#n)^(#k)$
// Shorthand for P(n, k) (k-permutations)
#let P(n, k) = $P(#n, #k)$

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

// Fancy block (left-bordered)
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

// Import CeTZ for diagrams
#import "@preview/cetz:0.4.2"

// ─── 3D Box drawing with CeTZ ───────────────────────────────────────────────
//
// Draws a pseudo-3D box (isometric) with optional balls inside.
// ox, oy are CeTZ coordinate offsets (not lengths).
//
#let box-w = 0.9
#let box-h = 0.4
#let box-d = 0.4
#let ball-r = 0.18

// Helper: draw a filled+stroked quadrilateral via merge-path + lines
#let quad(p1, p2, p3, p4, fill: none, stroke: 0.5pt + luma(30%)) = {
  import cetz.draw: line, merge-path
  merge-path(close: true, fill: fill, stroke: stroke, {
    line(p1, p2)
    line(p2, p3)
    line(p3, p4)
    line(p4, p1)
  })
}

#let draw-3d-box(label, balls: (), ox: 0, oy: 0) = {
  import cetz.draw: *
  let w = box-w
  let h = box-h
  let d = box-d

  // Back face
  quad(
    (ox + d, oy + d),
    (ox + w + d, oy + d),
    (ox + w + d, oy + h + d),
    (ox + d, oy + h + d),
    fill: luma(50%),
    stroke: 0.5pt + luma(30%),
  )

  // Back edges (depth lines)
  line((ox, oy), (ox + d, oy + d), stroke: 0.5pt + luma(30%))
  line((ox, oy + h), (ox + d, oy + h + d), stroke: 0.5pt + luma(30%))
  line((ox + w, oy + h), (ox + w + d, oy + h + d), stroke: 0.5pt + luma(30%))

  // Top face
  quad(
    (ox, oy + h),
    (ox + d, oy + h + d),
    (ox + w + d, oy + h + d),
    (ox + w, oy + h),
    fill: luma(85%),
    stroke: 0.5pt + luma(30%),
  )

  // Front-right top flap
  quad(
    (ox + w, oy + h),
    (ox + w + d, oy + h + d),
    (ox + w + d + 0.2, oy + h + d + 0.1),
    (ox + w + 0.2, oy + h + 0.1),
    fill: luma(70%).transparentize(40%),
    stroke: 0.5pt + luma(30%),
  )

  // Front-left top flap
  quad(
    (ox, oy + h),
    (ox + d, oy + h + d),
    (ox + d - 0.16, oy + h + d + 0.08),
    (ox - 0.16, oy + h + 0.08),
    fill: luma(85%).transparentize(40%),
    stroke: 0.5pt + luma(30%),
  )

  // Balls (drawn before front/right faces so they appear inside)
  for (bx, by, blabel) in balls {
    circle(
      (ox + bx, oy + by),
      radius: ball-r,
      fill: white,
      stroke: 0.4pt + luma(40%),
    )
    content((ox + bx, oy + by), anchor: "center", text(size: 0.55em, blabel))
  }

  // Right face (transparent, on top of balls)
  quad(
    (ox + w, oy),
    (ox + w + d, oy + d),
    (ox + w + d, oy + h + d),
    (ox + w, oy + h),
    fill: luma(70%).transparentize(60%),
    stroke: 0.5pt + luma(30%),
  )

  // Front face (transparent, on top of balls)
  rect(
    (ox, oy),
    (ox + w, oy + h),
    fill: luma(90%).transparentize(60%),
    stroke: 0.5pt + luma(30%),
  )

  // Label on front face (on top of transparent front face)
  content((ox + w / 2, oy + h / 2), anchor: "center", text(size: 0.65em, label))
}

// ─── RNA circle diagram with CeTZ ──────────────────────────────────────────
//
// Draws an RNA-like circular graph with vertices, labels, and edges.
// Parameters:
//   labels:       array of single-character labels for each vertex
//   basepairs:    array of (i, j) pairs to draw as dashed gray edges
//   matchings:    array of (i, j) pairs to draw as solid red edges
//
#let draw-rna(labels, basepairs: (), matchings: ()) = {
  import cetz.draw: *
  let n = labels.len()
  let r-node = 1.4
  let r-label = 1.8
  let angle-step = 360deg / n

  // Draw basepair edges (dashed, light gray)
  for (i, j) in basepairs {
    let a1 = 90deg - (i - 1) * angle-step
    let a2 = 90deg - (j - 1) * angle-step
    line(
      (r-node * calc.cos(a1), r-node * calc.sin(a1)),
      (r-node * calc.cos(a2), r-node * calc.sin(a2)),
      stroke: (dash: "dashed", paint: luma(70%), thickness: 1.2pt),
    )
  }

  // Draw matching edges (solid red, thick)
  for (i, j) in matchings {
    let a1 = 90deg - (i - 1) * angle-step
    let a2 = 90deg - (j - 1) * angle-step
    line(
      (r-node * calc.cos(a1), r-node * calc.sin(a1)),
      (r-node * calc.cos(a2), r-node * calc.sin(a2)),
      stroke: red.darken(20%) + 1.8pt,
    )
  }

  // Draw vertices and labels
  for (idx, ch) in labels.enumerate() {
    let a = 90deg - idx * angle-step
    let nx = r-node * calc.cos(a)
    let ny = r-node * calc.sin(a)
    let lx = r-label * calc.cos(a)
    let ly = r-label * calc.sin(a)
    circle((nx, ny), radius: 0.06, fill: black, stroke: none)
    content((lx, ly), anchor: "center", text(0.7em, raw(ch)))
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Epigraph
#align(right)[
  #text(style: "italic", size: 0.9em)[
    Do whatever you want, but always explain what you are doing.
  ]
  #v(1em, weak: true)
  --- #smallcaps[Konstantin], 2020
]

// ─────────────────────────────────────────────────────────────────────────────

#Block[
  The problems in this assignment are _tagged_:

  #TagCore are essential problems that you _must solve_ to pass the assignment.

  #TagChallenge are _non-mandatory_ problems that could be _skipped_ for a passing grade.

  #TagBonus are _optional_ problems for _memorable experience_.
  They won't be graded.
]

// ─────────────────────────────────────────────────────────────────────────────

== Problem 1: The Twelvefold Way #h(1fr)#TagCore

One of the classical combinatorial problems is counting the number of arrangements of $n$ balls into $k$ boxes.
There are at least #link("https://en.wikipedia.org/wiki/Twelvefold_way")[12 variations] of this problem: four cases (a--d) with three different constraints (1--3).
For each problem (case+constraint), derive the corresponding generic formula.
Additionally, pick several representative values for $n$ and $k$ and use your derived formulae to find the numbers of arrangements.
Visualize some arrangements for your chosen values of $n$ and $k$.

#text(style: "italic")[#underline[Cases with arrangement examples]]:

#tasklist("case", cols: 2, format: "(a)")[
  + $bold(U) to bold(L)$: #emph[Unlabeled] Balls, #emph[Labeled] Boxes.

    #align(center)[
      #cetz.canvas({
        draw-3d-box("A", balls: ((0.45, 0.4, ""), (0.6, 0.3, ""), (0.28, 0.28, "")), ox: 0)
        draw-3d-box("B", ox: 1.6)
        draw-3d-box("C", balls: ((0.5, 0.5, ""), (0.9, 0.5, ""), (0.31, 0.33, ""), (0.71, 0.3, "")), ox: 3.2)
        draw-3d-box("D", balls: ((0.4, 0.3, ""), (0.8, 0.5, "")), ox: 4.8)
        draw-3d-box("E", balls: ((0.6, 0.4, ""),), ox: 6.4)
      })
    ]

  + $bold(L) to bold(U)$: #emph[Labeled] Balls, #emph[Unlabeled] Boxes.

    #align(center)[
      #cetz.canvas({
        draw-3d-box("", balls: ((0.55, 0.3, "1"),), ox: 0)
        draw-3d-box("", balls: ((0.4, 0.3, "2"), (0.8, 0.5, "3")), ox: 1.6)
        draw-3d-box("", ox: 3.2)
        draw-3d-box("", balls: ((0.5, 0.55, "4"), (0.9, 0.5, "5"), (0.31, 0.33, "6"), (0.7, 0.3, "7")), ox: 4.8)
        draw-3d-box("", balls: ((0.6, 0.4, "8"), (0.9, 0.55, "9"), (0.3, 0.3, "10")), ox: 6.4)
      })
    ]

  #colbreak()

  + $bold(L) to bold(L)$: #emph[Labeled] Balls, #emph[Labeled] Boxes.

    #align(center)[
      #cetz.canvas({
        draw-3d-box("A", balls: ((0.3, 0.3, "1"), (0.8, 0.5, "2")), ox: 0)
        draw-3d-box("B", balls: ((0.6, 0.5, "3"),), ox: 1.6)
        draw-3d-box("C", balls: ((0.5, 0.55, "4"), (0.9, 0.5, "5"), (0.3, 0.3, "6")), ox: 3.2)
        draw-3d-box("D", ox: 4.8)
        draw-3d-box("E", balls: ((0.5, 0.55, "7"), (0.9, 0.55, "8"), (0.3, 0.3, "9"), (0.7, 0.3, "10")), ox: 6.4)
      })
    ]

  + $bold(U) to bold(U)$: #emph[Unlabeled] Balls, #emph[Unlabeled] Boxes.

    #align(center)[
      #cetz.canvas({
        draw-3d-box("", balls: ((0.5, 0.55, ""), (0.9, 0.5, ""), (0.3, 0.3, ""), (0.7, 0.3, "")), ox: 0)
        draw-3d-box("", balls: ((0.5, 0.5, ""), (0.9, 0.5, ""), (0.3, 0.3, "")), ox: 1.6)
        draw-3d-box("", balls: ((0.4, 0.3, ""), (0.8, 0.5, "")), ox: 3.2)
        draw-3d-box("", balls: ((0.6, 0.4, ""),), ox: 4.8)
        draw-3d-box("", ox: 6.4)
      })
    ]
]

#v(0.5em)
#text(style: "italic")[#underline[Constraints]]:

+ $<= 1$ ball per box --- #emph[injective] mapping.
+ $>= 1$ ball per box --- #emph[surjective] mapping.
+ Arbitrary number of balls per box.

#v(0.5em)
#text(style: "italic")[#underline[Notes]]:

#list(marker: [$ast$])[
  - #emph[U]nlabeled means "indistinguishable", and #emph[L]abeled means "distinguishable".

  - #link("https://en.wikipedia.org/wiki/Stirling_numbers_of_the_second_kind")[Stirling number of the second kind] $s^("II")_k (n) =$ $stirling(n, k)$ $= S(n, k)$ is the number of ways to partition a set of $n$ elements into $k$ non-empty subsets.
    Use $s^("II")_k (n)$ notation (or $stirling(n, k)$, or $S(n, k)$, to your preference) directly without expanding the closed formula.

  - #link("https://en.wikipedia.org/wiki/Partition_(number_theory)#Restricted_part_size_or_number_of_parts")[Partition function] $p_k (n)$ is the number of ways to partition the integer $n$ into $k$ positive parts, i.e. the number of solutions to the following equation: $n = a_1 + ... + a_k$, where $a_1 >= ... >= a_k >= 1$.
    Use $p_k (n)$ directly, since the closed-form expression is unknown.
]


#pagebreak()

== Problem 2: Password Counting #h(1fr)#TagCore

How many different passwords can be formed using the following rules?

#[
  - The password must be exactly 8 characters long.
  - The password must consist only of Latin letters (a--z, A--Z) and Arabic digits (0--9).
  - The password must contain at least 2 digits (0--9) and at least 1 uppercase letter (A--Z).
  - Each character can be used no more than once in the password.
]

Find the minimum password length $m$ (same alphabet and constraints) such that the number of valid passwords is at least $2^128$.
Also estimate what fraction of all 8-character strings over this alphabet are valid passwords under the given constraints.


== Problem 3: Five-Digit Numbers #h(1fr)#TagCore

Find the number of different 5-digit numbers using digits 1--9 under the given constraints.
For each case, provide examples of numbers that comply and do not comply with the constraints, and derive a generic formula that can be applied to other values of $n$ (total available digits) and $k$ (number of digits in the number).
Express the formula using standard combinatorial terms, such as $k$-combinations $C_n^k$ and $k$-permutations $P(n, k)$.

#tasklist("digits", format: "(a)")[
  + Digits #emph[can] be repeated.

  + Digits #emph[cannot] be repeated.

  + Digits #emph[can] be repeated and must be written in #emph[non-increasing]#footnote[
      A sequence $(x_n)$ is said to be #emph[strictly monotonically increasing] if each term is #emph[strictly greater] than the previous one, i.e. $x_i < x_(i+1)$.
      A sequence $(x_n)$ is called #emph[non-increasing] if each term is #emph[less than or equal to] the previous one, i.e. $x_i >= x_(i+1)$.
    ] order.

  + Digits #emph[cannot] be repeated and must be written in #emph[strictly increasing] order.

  + Digits #emph[cannot] be repeated and the sum of the digits must be even.

  + Digits #emph[cannot] be repeated and #emph[exactly two] of the five digits are even.
]


== Problem 4: Combinatorial Identity #h(1fr)#TagCore

Let $n$ be a positive integer.
Prove the following identity using a combinatorial argument:
$
  sum_(k=1)^n k dot C_n^k = n dot 2^(n-1)
$
// Then verify the same identity by an algebraic derivation (for example, via $k C_n^k = n C_(n-1)^(k-1)$ or from the binomial theorem).


== Problem 5: Vandermonde's Identity #h(1fr)#TagCore

Let $r, m, n$ be non-negative integers.
Prove the following identity using a combinatorial argument:
$
  binom(m + n, r) = sum_(k=0)^r binom(m, k) binom(n, r - k)
$
// Then verify it numerically for one nontrivial case, for example $(m,n,r) = (3,4,3)$.


== Problem 6: Generalized Pascal's Formula #h(1fr)#TagCore

Prove the Generalized Pascal's Formula (for $n >= 1$ and $k_1, ..., k_r >= 0$ with $k_1 + ... + k_r = n$):
$
  binom(n, k_1, ..., k_r) = sum_(i=1)^r binom(n-1, k_1, ..., k_i - 1, ..., k_r)
$
Treat terms with $k_i = 0$ as zero (equivalently, omit those terms from the sum).


== Problem 7: The Multinomial Walk #h(1fr)#TagCore

A robot starts at $(0,0,0)$ in a 3D integer lattice.
At each step it moves by one of the vectors $(1,0,0)$, $(0,1,0)$, or $(0,0,1)$.

#tasklist("multiwalk", format: "(a)")[
  + How many different paths of length 15 end at $(5,7,3)$?

  + Generalize to endpoint $(a,b,c)$ with $a+b+c=n$.

  + Generalize further to $d$ dimensions: endpoint $(a_1, ..., a_d)$ with $sum_i a_i = n$.
]


== Problem 8: Anagram Identities #h(1fr)#TagCore

Consider the word $"ASSESSMENTS"$.

#tasklist("anagram", format: "(a)")[
  + Count the number of distinct anagrams.

  + Count the number of distinct anagrams in which all four letters `S` appear consecutively.

  + Generalize: if a multiset has size $n$ with multiplicities $(m_1, ..., m_r)$, derive a formula for the number of permutations where all copies of one chosen symbol form a single consecutive block.

  + If two distinct symbols are each required to form a consecutive block, explain whether adjacency between the two blocks changes the counting argument.
]


== Problem 9: Non-Crossing Perfect Matchings #h(1fr)#TagChallenge

A #emph[non-crossing perfect matching]#footnote[
  Credits to #link("https://rosalind.info/about")[Rosalind] for this task.
] in a graph is a set of pairwise disjoint edges that cover all vertices and do not intersect with each other.
For example, consider a graph on $2n$ vertices numbered from 1 to $2n$ and arranged in a circle.
Additionally, assume that edges are straight lines.
In this case, edges ${i, j}$ and ${a, b}$ intersect whenever $i < a < j < b$.

#tasklist("rna", format: "(a)")[
  + Count the number of all possible non-crossing perfect matchings in a complete graph $K_(2n)$.

  + Consider a graph on vertices labeled with letters from ${mono("A"), mono("C"), mono("G"), mono("U")}$.
    Each pair of vertices labeled with `A` and `U` is connected with a #emph[basepair edge].
    Similarly, `C`--`G` pairs are also connected.

    The picture below illustrates some of possible non-crossing perfect matchings in the graph with 12 vertices `AUCGUAAUCGCG` arranged in a circle.
    Basepair edges are drawn dashed gray, matching is red.

    #align(center)[
      #grid(
        columns: 4,
        column-gutter: 0.5em,
        align: center + horizon,
        cetz.canvas(length: 1cm, {
          draw-rna(
            ("A", "U", "C", "G", "U", "A", "A", "U", "C", "G", "C", "G"),
            basepairs: (
              // Basepair edges (A-U and C-G pairs)
              (1, 5),
              (1, 8),
              (2, 6),
              (2, 7),
              (3, 10),
              (3, 12),
              (4, 9),
              (4, 11),
              (5, 7),
              (6, 8),
              (9, 10),
              (11, 12),
            ),
            matchings: (
              (1, 2),
              (3, 4),
              (5, 6),
              (7, 8),
              (9, 12),
              (10, 11),
            ),
          )
        }),
        cetz.canvas(length: 1cm, {
          draw-rna(
            ("A", "U", "C", "G", "U", "A", "A", "U", "C", "G", "C", "G"),
            basepairs: (
              (1, 2),
              (1, 5),
              (2, 6),
              (3, 10),
              (3, 12),
              (4, 9),
              (4, 11),
              (5, 7),
              (6, 8),
              (7, 8),
              (9, 10),
              (11, 12),
            ),
            matchings: (
              (1, 8),
              (2, 7),
              (3, 4),
              (5, 6),
              (9, 12),
              (10, 11),
            ),
          )
        }),
        cetz.canvas(length: 1cm, {
          draw-rna(
            ("A", "U", "C", "G", "U", "A", "A", "U", "C", "G", "C", "G"),
            basepairs: (
              (1, 5),
              (1, 8),
              (2, 6),
              (2, 7),
              (3, 4),
              (3, 10),
              (4, 9),
              (4, 11),
              (5, 7),
              (6, 8),
              (9, 12),
              (10, 11),
              (11, 12),
            ),
            matchings: (
              (1, 2),
              (3, 12),
              (4, 11),
              (5, 6),
              (7, 8),
              (9, 10),
            ),
          )
        }),
        cetz.canvas(length: 1cm, {
          draw-rna(
            ("A", "U", "C", "G", "U", "A", "A", "U", "C", "G", "C", "G"),
            basepairs: (
              (1, 2),
              (1, 5),
              (2, 6),
              (3, 10),
              (3, 12),
              (4, 9),
              (4, 11),
              (5, 7),
              (6, 8),
              (7, 8),
              (9, 12),
              (10, 11),
            ),
            matchings: (
              (1, 8),
              (2, 7),
              (3, 4),
              (5, 6),
              (9, 10),
              (11, 12),
            ),
          )
        }),
      )
    ]

    #let s = "CGUAAUUACGGCAUUAGCAU"
    Let $s = mono(#s)$ (#s.len() vertices).
    Count the number of all possible non-crossing perfect matchings in the graph on vertices arranged in a circle and labeled with $s$.
]


== Problem 10: Integer Solutions #h(1fr)#TagCore

How many integer solutions are there for each given equation?

#tasklist("eqs", format: "(a)")[
  #grid(
    columns: 2,
    column-gutter: 2em,
    [
      + $x_1 + x_2 + x_3 = 20$, where $x_i >= 0$
      + $x_1 + x_2 + x_3 = 20$, where $x_i >= 1$
      + $x_1 + x_2 + x_3 = 20$, where $x_i >= 5$
      + $x_1 + x_2 + x_3 <= 20$, where $x_i >= 0$
    ],
    [
      + $x_1 + x_2 + x_3 = 20$, where $1 <= x_1 <= x_2 <= x_3$
      + $x_1 + x_2 + x_3 = 20$, where $0 <= x_1 <= x_2 <= x_3$
      + $x_1 + x_2 + x_3 = 20$, where $0 <= x_1 <= x_2 <= x_3 <= 10$
      + $x_1 + x_2 + x_3 = 5$, where $-5 <= x_i <= 5$
    ],
  )
]

// Additionally, count the number of solutions to
// $x_1 + x_2 + x_3 + x_4 = 20$,
// where $x_i >= 0$ and exactly two variables are at least 6.


== Problem 11: Dice Probability #h(1fr)#TagCore

Consider three dice: one with 4 faces, one with 6 faces, and one with 8 faces.
The faces are numbered 1 to 4, 1 to 6, and 1 to 8, respectively.
Find the probability of rolling a total sum of 12.

// Find the full distribution of sums from 3 to 18.


== Problem 12: Interesting Subsets #h(1fr)#TagChallenge

Let $A = {1, 2, 3, ..., 12}$.
Define an #emph[interesting] subset of $A$ as a subset in which no two elements have a difference of 3.
Determine the number of interesting subsets of $A$.

// Start with warm-up cases ${1,2,3}$ and ${1,2,...,6}$ before solving the full set.


== Problem 13: People in a Line #h(1fr)#TagChallenge

Let $f(n)$ be the number of ways to arrange $n$ people of distinct heights in a line such that no three consecutive individuals form a strictly ascending or strictly descending height sequence.
Compute $f(n)$ for $n = 1, 2, ..., 7$ and propose a conjecture (pattern, recurrence, or asymptotic trend).


== Problem 14: GLaDOS Partitions #h(1fr)#TagChallenge

GLaDOS, the mastermind AI, is testing a new batch of first-year students in one of her infamous test chambers.
She assigns each test subject a unique number from 1 to $n$, and then splits the students into $k$ indistinguishable groups.
Furthermore, one student in each group is assigned as the group leader.
GLaDOS wants to know how many different ways she can arrange the students into groups and select group leaders, so that the students can navigate through the test chambers without getting lost.
She calls this arrangement a "GLaDOS Partition".

#v(0.5em)
For example, consider $n = 7$ students and $k = 3$ groups.
Here are three (out of many!) different partitions, with the group leaders underlined:
$(underline(1) | 2 underline(5) 6 7 | 3 underline(4))$,
$(underline(1) | 2 5 underline(6) 7 | underline(3) 4)$,
and $(underline(1) | 2 5 underline(6) 7 | 3 underline(4))$.

#v(0.5em)
Let the number of GLaDOS Partitions for $n$ students into $k$ groups, where each group has a designated leader, be denoted as $G(n, k)$.
Your task is to find a generic formula and/or recurrence relation for $G(n, k)$ and justify it.
Also compare $sum_k G(n,k)$ with Bell numbers and explain the relation.


== Problem 15: Stirling and Bell Synthesis #h(1fr)#TagCore

Let $S(n,k)$ be the Stirling numbers of the second kind and let $B_n$ be the $n$-th Bell number.

#tasklist("stbell", format: "(a)")[
  + Compute $S(5,k)$ for $k = 1,2,3,4,5$ and then compute $B_5$.

  + Prove the identity
    $B_n = sum_(k=1)^n S(n,k)$.

  + Using
    $S(n,k) = S(n-1,k-1) + k S(n-1,k)$,
    compute $B_6$.

  + Compare this problem with Problem 14 and express $G(n,k)$ in terms of $S(n,k)$.
]


#v(1em)
#align(center)[
  #line(length: 30%, stroke: 0.1pt) #h(0.5em) $ast$ #h(0.5em) $ast$ #h(0.5em) $ast$ #h(0.5em) #line(
    length: 30%,
    stroke: 0.1pt,
  )
]

#v(1em)

Please make sure to answer #emph[all] questions and provide #emph[clear] explanations for your solutions.

#v(0.5em)
#text(style: "italic")[Good luck!]


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


== Problem A: Burnside's Lemma and Pólya Enumeration #h(1fr)#TagBonus

Imagine you're coloring the faces of a cube with 3 colors.
Naively, that's $3^6 = 729$ colorings --- but if you rotate the cube, many of these look the same.
How many are _truly_ distinct?

This kind of question comes up all the time: distinct necklaces up to rotation, distinct molecules up to symmetry, distinct graph labelings up to automorphism.
The key insight is that _symmetries form a group_, and you can count orbits by averaging over the group.

#Box[
  *Burnside's Lemma.* Let a finite group $G$ act on a set $X$.
  The number of distinct orbits (equivalence classes) is the average number of fixed points:
  $ |X "/" G| = frac(1, |G|) sum_(g in G) |"Fix"(g)| $
  where $"Fix"(g) = {x in X mid(|) g dot x = x}$ is the set of colorings left unchanged by $g$.

  In words: to count distinct objects, average over all symmetries how many configurations each symmetry preserves.
]

#tasklist("probA")[
  + *Warm-up: binary bracelets.*
    You have $n$ beads in a circle, each black or white.
    Two bracelets are the same if you can rotate one to get the other.
    Use Burnside's lemma to count distinct bracelets for $n = 4$ and $n = 5$.
    #h(1fr)
    _(Try brute force first to check your answer.)_

  + *Necklaces with flips.*
    Now allow reflections too (you can flip the bracelet over).
    #tasklist("probA2", format: "(a)")[
      + How many distinct necklaces of $n = 6$ beads in $k = 3$ colors, up to rotation only?
      + Same question, but rotations and reflections are equivalent.
    ]

  + *Cube coloring.*
    How many ways to color the faces of a cube with $k$ colors, up to rotation?

    The cube's rotation group has 24 elements.
    Your job is to figure out what types of rotations exist (identity, face rotations, edge rotations, vertex rotations), how many of each type, and how many colorings each type fixes.

  + *Pólya's theorem* (optional, for the adventurous).
    Instead of just counting total colorings, Pólya's theorem gives you a _generating function_ that tells you how many colorings use each color how many times.
    For a cube colored with ${R, G, B}$, how many colorings use each color exactly twice?
]


#pagebreak()

== Problem B: Gray Codes and Iterative Generation #h(1fr)#TagBonus

Suppose you need to enumerate all $2^n$ bitstrings, or all $C_n^k$ combinations, or all $n!$ permutations.
You could just generate them in lexicographic order --- but consecutive objects might differ in many positions.
What if you want each step to change as _little_ as possible?

This idea leads to _Gray codes_ (flip one bit at a time), the _revolving door_ algorithm (swap one element in/out), and the _Johnson--Trotter_ algorithm (swap two adjacent elements).
Knuth devotes an entire volume (#link("https://en.wikipedia.org/wiki/The_Art_of_Computer_Programming")[TAOCP 4A]) to these and related algorithms.

#tasklist("probB")[
  + *Binary reflected Gray code.*
    The classic construction: $Gamma_1 = (0, 1)$, and $Gamma_n$ is $0$ prepended to $Gamma_(n-1)$, followed by $1$ prepended to the _reverse_ of $Gamma_(n-1)$.
    Implement this and verify for $n = 3, 4$ that consecutive strings differ in exactly one bit.

  + *Rank and unrank.*
    Can you go directly between a bitstring and its position in the Gray code, without generating the whole list?
    Implement $"rank"(b) arrow.r i$ and $"unrank"(i) arrow.r b$ in $O(n)$ time.

  + *Revolving door* (combinations).
    Generate all $k$-element subsets of ${1, ..., n}$ so that each subset differs from the previous one by exactly one element entering and one leaving --- like a revolving door.
    Test for $n = 5, k = 3$.

  + *Johnson--Trotter* (permutations).
    Generate all $n!$ permutations so that each consecutive pair differs by swapping two _adjacent_ elements.
    The trick: each element has a "direction" (left or right), and you always move the largest mobile element.
    Test for $n = 3, 4$.

  + *Benchmark.*
    Measure throughput (objects/second) for each algorithm:
    Gray code with $n in {10, 15, 20}$, combinations with $n = 20, k = 10$, permutations with $n in {8, 9, 10}$.
]


== Problem C: Möbius Inversion and Derangements #h(1fr)#TagBonus

You already know inclusion--exclusion: to count elements that have _none_ of the bad properties, you alternate between overcounting and undercounting.
It turns out this is a special case of something much more general --- #link("https://en.wikipedia.org/wiki/M%C3%B6bius_inversion_formula")[Möbius inversion] --- that works on _any_ partially ordered set, not just subsets.

The idea: if you know a "cumulative" function $g(x) = sum_(y <= x) f(y)$, you can recover $f$ from $g$ by inverting with the Möbius function of the poset.

#Box[
  *Möbius Inversion.* On a poset $(P, <=)$ with Möbius function $mu$, if $g(x) = sum_(y <= x) f(y)$, then
  $ f(x) = sum_(y <= x) mu(y, x) dot g(y) $
  Different posets give different $mu$, and thus different inversion formulas.
]

#tasklist("probC")[
  + *Warm-up: number theory.*
    On $ZZ^+$ ordered by divisibility, the Möbius function is the classical $mu(n)$ (the one from number theory).
    Use Möbius inversion to prove $phi(n) = sum_(d | n) mu(d) dot n "/" d$.
    Check by hand for $n = 12, 30$.

  + *Inclusion--exclusion is just a special case.*
    On the boolean lattice (subsets ordered by inclusion), show that $mu(A, B) = (-1)^(|B| - |A|)$.
    Conclude: inclusion--exclusion is Möbius inversion on the subset lattice.

  + *Derangements: permutations with no fixed points.*
    A #link("https://en.wikipedia.org/wiki/Derangement")[_derangement_] is a permutation where nothing stays in place.
    The number of derangements of $n$ elements is called $!n$ (subfactorial).
    #tasklist("probC3", format: "(a)")[
      + Derive $!n = n! sum_(k=0)^n frac((-1)^k, k!)$ via inclusion--exclusion.
      + Prove the recurrence $!n = (n - 1) dot (!(n - 1) + !(n - 2))$ by a combinatorial argument.
        #h(1fr)
        _(Hint: where does element 1 go? It has $n - 1$ choices...)_
      + Show that, as a formal power series, the EGF of derangements is $e^(-x) "/" (1 - x)$.
      + Prove that $!n "/" n! -> 1 "/" e$ as $n -> infinity$.
        Intuitively, if you shuffle a large number of cards --- how likely is it that no card ends up in its original position?

    ]

  + *Partition lattice*.
    Partitions of ${1, ..., n}$ ordered by refinement form a lattice $Pi_n$.
    Its Möbius function has a beautiful formula.
    Use it to derive the Stirling numbers $stirling(n, k)$ via Möbius inversion --- connecting this problem back to Problem 1.
]


== Problem D: Combinatorial Games and Sprague--Grundy #h(1fr)#TagBonus

Two players, perfect information, no randomness, last move wins.
Think Nim, or any game where you take turns and the one who can't move loses.
It turns out _every_ such game is secretly just Nim in disguise.

The key idea: each position has a _Grundy number_ (a non-negative integer), and a position is losing iff its Grundy number is 0.
To compute it, take the _mex_ (minimum excludant) of all Grundy numbers reachable in one move.
The #link("https://en.wikipedia.org/wiki/Sprague%E2%80%93Grundy_theorem")[Sprague--Grundy theorem] says this completely solves the game.

#Box[
  *Grundy number.* $g(p) = "mex"({ g(s) mid(|) s "is reachable from" p })$, where "mex" of a set of non-negative integers is the smallest non-negative integer _not_ in the set.

  *Key fact:* $g(p) = 0$ iff $p$ is a losing position (the previous player wins). Everything else is winning.

  *Composition:* if a game splits into independent sub-games, the combined Grundy number is the XOR of the parts.
]

#tasklist("probD")[
  + *Nim.*
    Several heaps of tokens. On your turn, remove any positive number of tokens from one heap.
    Prove Bouton's theorem: position $(h_1, ..., h_k)$ is losing iff $h_1 xor h_2 xor ... xor h_k = 0$.

  + *Subtraction games.*
    One heap of $n$ tokens. You may remove $t in T$ tokens per turn (say $T = {1, 2, 3}$).
    Compute Grundy numbers for $n = 0, ..., 20$.
    Notice the pattern? Now try $T = {1, 4, 5}$ --- still periodic?

  + *Wythoff's game.*
    Two heaps. On your turn: remove any number from one heap, or the _same_ number from both.
    This one is special --- the P-positions involve the golden ratio $phi$.
    #tasklist("probD3", format: "(a)")[
      + Compute the P-positions for heap sizes up to $(20, 20)$. Do you see the pattern?
      + The P-positions turn out to be $(floor(k phi), floor(k phi^2))$ for $k = 0, 1, 2, ...$, where $phi = (1 + sqrt(5)) "/" 2$.
        Verify this matches your computation.
      + Why does the golden ratio show up? (This is a deep and beautiful question --- even a partial answer is worth a lot.)
    ]

  + *Putting it together.*
    Suppose you're playing Nim with heaps $(7, 5, 3, 1)$.
    Is the first player winning? If yes, give a winning move.
    Now suppose the game is: one subtraction game with $T = {1, 3, 4}$ on a heap of 10, _plus_ a Nim heap of 5.
    Who wins?
]


#line(length: 100%, stroke: 0.4pt)

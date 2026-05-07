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
Visualize several possible arrangements for the chosen $n$ and $k$.

#text(style: "italic")[#underline[Cases with arrangement examples]]:

#tasklist("case", format: "(a)")[
  + $bold(U) arrow.r.long bold(L)$: Balls are #emph[Unlabeled], Boxes are #emph[Labeled].

    #align(center)[
      #cetz.canvas(length: 1cm, {
        draw-3d-box("A", balls: ((0.45, 0.38, ""), (0.62, 0.32, ""), (0.28, 0.28, "")), ox: 0)
        draw-3d-box("B", ox: 1.6)
        draw-3d-box("C", balls: ((0.52, 0.55, ""), (0.88, 0.51, ""), (0.31, 0.33, ""), (0.71, 0.3, "")), ox: 3.2)
        draw-3d-box("D", balls: ((0.54, 0.31, ""), (0.88, 0.51, "")), ox: 4.8)
        draw-3d-box("E", balls: ((0.52, 0.38, ""),), ox: 6.4)
      })
    ]

  + $bold(L) arrow.r.long bold(U)$: Balls are #emph[Labeled], Boxes are #emph[Unlabeled].

    #align(center)[
      #cetz.canvas(length: 1cm, {
        draw-3d-box("", balls: ((0.52, 0.38, "1"),), ox: 0)
        draw-3d-box("", balls: ((0.28, 0.28, "2"), (0.88, 0.51, "3")), ox: 1.6)
        draw-3d-box("", ox: 3.2)
        draw-3d-box("", balls: ((0.52, 0.55, "4"), (0.88, 0.51, "5"), (0.31, 0.33, "6"), (0.71, 0.3, "7")), ox: 4.8)
        draw-3d-box("", balls: ((0.52, 0.38, "8"), (0.88, 0.51, "9"), (0.31, 0.33, "10")), ox: 6.4)
      })
    ]

  + $bold(L) arrow.r.long bold(L)$: Balls are #emph[Labeled], Boxes are #emph[Labeled].

    #align(center)[
      #cetz.canvas(length: 1cm, {
        draw-3d-box("A", balls: ((0.28, 0.28, "1"), (0.88, 0.51, "2")), ox: 0)
        draw-3d-box("B", balls: ((0.52, 0.38, "3"),), ox: 1.6)
        draw-3d-box("C", balls: ((0.52, 0.55, "4"), (0.88, 0.51, "5"), (0.31, 0.33, "6")), ox: 3.2)
        draw-3d-box("D", ox: 4.8)
        draw-3d-box("E", balls: ((0.52, 0.55, "7"), (0.88, 0.51, "8"), (0.31, 0.33, "9"), (0.71, 0.3, "10")), ox: 6.4)
      })
    ]

  + $bold(U) arrow.r.long bold(U)$: Balls are #emph[Unlabeled], Boxes are #emph[Unlabeled].

    #align(center)[
      #cetz.canvas(length: 1cm, {
        draw-3d-box("", balls: ((0.52, 0.55, ""), (0.88, 0.51, ""), (0.31, 0.33, ""), (0.71, 0.3, "")), ox: 0)
        draw-3d-box("", balls: ((0.52, 0.38, ""), (0.88, 0.51, ""), (0.31, 0.33, "")), ox: 1.6)
        draw-3d-box("", balls: ((0.54, 0.31, ""), (0.88, 0.51, "")), ox: 3.2)
        draw-3d-box("", balls: ((0.52, 0.38, ""),), ox: 4.8)
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

  - #link("https://en.wikipedia.org/wiki/Stirling_numbers_of_the_second_kind")[Stirling number of the second kind] $s^("II")_k(n) =$ $stirling(n, k)$ $= S(n, k)$ is the number of ways to partition a set of $n$ elements into $k$ non-empty subsets.
    Use $s^("II")_k(n)$ notation (or $stirling(n, k)$, or $S(n, k)$, to your preference) directly without expanding the closed formula.

  - #link("https://en.wikipedia.org/wiki/Partition_(number_theory)#Restricted_part_size_or_number_of_parts")[Partition function] $p_k(n)$ is the number of ways to partition the integer $n$ into $k$ positive parts, i.e. the number of solutions to the following equation: $n = a_1 + ... + a_k$, where $a_1 >= ... >= a_k >= 1$.
    Use $p_k(n)$ directly, since the closed-form expression is unknown.
]


== Problem 2: Password Counting #h(1fr)#TagCore

How many different passwords can be formed using the following rules?

#list(marker: sym.bullet)[
  - The password must be exactly 8 characters long.
  - The password must consist only of Latin letters (a--z, A--Z) and Arabic digits (0--9).
  - The password must contain at least 2 digits (0--9) and at least 1 uppercase letter (A--Z).
  - Each character can be used no more than once in the password.
]

#v(0.5em)
How long does it take to crack such a password?


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
]


== Problem 4: A Combinatorial Identity #h(1fr)#TagCore

Let $n$ be a positive integer.
Prove the following identity using a combinatorial argument:
$
  sum_(k=1)^n k dot C_n^k = n dot 2^(n-1)
$


== Problem 5: Vandermonde's Identity #h(1fr)#TagCore

Let $r, m, n$ be non-negative integers.
Prove the following identity using a combinatorial argument:
$
  binom(m + n, r) = sum_(k=0)^r binom(m, k) binom(n, r - k)
$


== Problem 6: Generalized Pascal's Formula #h(1fr)#TagCore

Prove the Generalized Pascal's Formula (for $n >= 1$ and $k_1, ..., k_r >= 0$ with $k_1 + ... + k_r = n$):
$
  binom(n, k_1, ..., k_r) = sum_(i=1)^r binom(n-1, k_1, ..., k_i - 1, ..., k_r)
$


== Problem 7: Multinomial Coefficient #h(1fr)#TagCore

Find the coefficient of $x^5 y^7 z^3$ in the expansion of $(x + y + z)^(15)$.


== Problem 8: Permutations of a Multiset #h(1fr)#TagCore

Count the number of permutations of the multiset $Sigma^* = {2 dot #sym.triangle.stroked, 3 dot #sym.square.stroked, 1 dot #sym.sun}$.


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


== Problem 11: Dice Probability #h(1fr)#TagCore

Consider three dice: one with 4 faces, one with 6 faces, and one with 8 faces.
The faces are numbered 1 to 4, 1 to 6, and 1 to 8, respectively.
Find the probability of rolling a total sum of 12.


== Problem 12: Interesting Subsets #h(1fr)#TagChallenge

Let $A = {1, 2, 3, ..., 12}$.
Define an #emph[interesting] subset of $A$ as a subset in which no two elements have a difference of 3.
Determine the number of interesting subsets of $A$.


== Problem 13: People in a Line #h(1fr)#TagChallenge

Find the number of ways to arrange five people of distinct heights in a line such that no three consecutive individuals form a strictly ascending or descending height sequence.


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

Many counting problems ask: how many distinct objects can be formed if objects related by a _symmetry_ (rotation, reflection, etc.) are considered identical?
For example, how many distinct necklaces can be made from $n$ beads in $k$ colors, if rotations and flips of the necklace are considered the same?

#Box[
  *Burnside's Lemma.* Let $G$ be a finite group acting on a set $X$. The number of _orbits_ (equivalence classes) under this action is:
  $ |X "/" G| = 1 "/" |G| sum_(g in G) |"Fix"(g)| $
  where $"Fix"(g) = {x in X mid(|) g dot x = x}$ is the set of elements fixed by $g$.
]

#tasklist("probA")[
  + *Warm-up: rotating a flag.*
    A circular flag has $n$ positions arranged in a circle, each to be colored black or white.
    Two colorings are equivalent if one can be rotated to obtain the other.
    Use Burnside's lemma to count the number of distinct flags for $n = 4$ and $n = 5$.

  + *Necklaces.* How many distinct necklaces can be made from $n$ beads in $k$ colors if:
    #tasklist("probA2", format: "(a)")[
      + Rotations are considered equivalent (cyclic group $C_n$)?
      + Both rotations and reflections are equivalent (dihedral group $D_n$)?
    ]
    Compute explicit answers for $n = 6, k = 3$ and $n = 8, k = 2$.

  + *Cube coloring.* How many ways are there to color the faces of a cube with $k$ colors, up to rotation?
    The rotation group of the cube has 24 elements.
    Describe the conjugacy classes of rotations and compute $"Fix"(g)$ for each.

  + *Pólya enumeration theorem* (optional extension).
    Instead of just _counting_ colorings, determine the _generating function_ that records how many colorings use each color a given number of times.
    For the cube with colors ${R, G, B}$, find the number of colorings that use each color exactly twice.
]


#v(1em)


== Problem B: Gray Codes and Iterative Generation #h(1fr)#TagBonus

#Block[
  "Generate _all_ objects of type $X$, one at a time, changing as little as possible between consecutive outputs."
  This is the philosophy behind _Gray codes_ and _iterative combinatorial generation_ --- a rich topic explored in depth by Knuth (#link("https://en.wikipedia.org/wiki/The_Art_of_Computer_Programming")[TAOCP Vol. 4A]).
]

#tasklist("probB")[
  + *Binary reflected Gray code.*
    The standard Gray code lists all $2^n$ bitstrings of length $n$ so that consecutive strings differ in exactly one bit.
    Implement the recursive construction: $Gamma_n = 0 dot Gamma_(n-1) union 1 dot "reverse"(Gamma_(n-1))$.
    Verify for $n = 3, 4$ that consecutive strings differ in exactly one position.

  + *Rank and unrank.*
    Implement:
    - $"rank"(b)$: given a bitstring $b$ in the Gray code ordering, return its index $i in {0, ..., 2^n - 1}$.
    - $"unrank"(i)$: given index $i$, produce the corresponding bitstring.
    Both should run in $O(n)$ time without generating the entire list.

  + *Revolving door algorithm* (combinations).
    Implement the revolving door algorithm that generates all $C_n^k$ $k$-combinations of ${1, ..., n}$ such that each combination differs from the previous one by exactly one element entering and one leaving.
    Test for $n = 5, k = 3$.

  + *Johnson--Trotter algorithm* (permutations).
    Implement the Johnson--Trotter algorithm to generate all $n!$ permutations by adjacent transpositions (swapping one pair of adjacent elements at each step).
    Test for $n = 3, 4$.

  + *Benchmark.*
    For each algorithm, measure the time to enumerate all objects for $n in {10, 15, 20}$ (Gray code), $n = 20, k = 10$ (combinations), and $n = 8, 9, 10$ (permutations).
    Report throughput (objects/second).
]


#v(1em)


== Problem C: Möbius Inversion and Derangements #h(1fr)#TagBonus

The #link("https://en.wikipedia.org/wiki/M%C3%B6bius_inversion_formula")[Möbius inversion formula] is a powerful generalization of inclusion--exclusion that works on _any_ partially ordered set (poset).
It provides a systematic way to invert sums over poset ideals.

#Box[
  *Möbius Inversion on Posets.* Let $(P, <=)$ be a locally finite poset with Möbius function $mu$. If $f, g : P to ZZ$ satisfy
  $ g(x) = sum_(y <= x) f(y) quad "for all" x in P $
  then
  $ f(x) = sum_(y <= x) mu(y, x) dot g(y) $
]

#tasklist("probC")[
  + *Classical Möbius inversion* (number-theoretic).
    Let $P = ZZ^+$ ordered by divisibility ($a <= b$ iff $a | b$).
    The Möbius function in this poset is the classical $mu(n)$.
    Prove that $phi(n) = sum_(d | n) mu(d) dot n "/" d$, where $phi$ is Euler's totient.
    Verify for $n = 12, 30, 100$.

  + *Inclusion--exclusion as Möbius inversion.*
    Let $P = $ the boolean lattice of subsets of ${1, ..., n}$ ordered by inclusion.
    Show that the Möbius function of this poset satisfies $mu(A, B) = (-1)^(|B| - |A|)$.
    Conclude that the inclusion--exclusion principle is a special case of Möbius inversion.

  + *Derangements via Möbius inversion.*
    A #link("https://en.wikipedia.org/wiki/Derangement")[_derangement_] is a permutation with no fixed points.
    The number of derangements of $n$ elements is the _subfactorial_ $!n$.
    #tasklist("probC3", format: "(a)")[
      + Derive the formula $!n = n! sum_(k=0)^n frac((-1)^k, k!)$ using inclusion--exclusion (or Möbius inversion on the permutation lattice).
      + Prove the recurrence $!n = (n - 1) dot (!(n - 1) + !(n - 2))$ combinatorially.
      + Compute the exponential generating function for $!n$ and show that, as a formal power series,
        $ sum_(n >= 0) frac(!n, n!) dot x^n = e^(-x) / (1 - x) $
      + Show that $display(lim_(n to infinity) frac(!n, n!) = 1 / e)$.
      + What is the probability that a random permutation is a derangement?
    ]

  + *Möbius function on the partition lattice* (research).
    The set of all partitions of ${1, ..., n}$ ordered by refinement forms the _partition lattice_ $Pi_n$.
    Look up (or derive) the Möbius function of this lattice.
    Use it to count the number of ways to partition $n$ labeled elements into $k$ non-empty _unordered_ blocks (Stirling numbers of the second kind) via Möbius inversion.
]


#v(1em)


== Problem D: Combinatorial Games and Sprague--Grundy #h(1fr)#TagBonus

#link("https://en.wikipedia.org/wiki/Sprague%E2%80%93Grundy_theorem")[Combinatorial game theory] analyzes two-player perfect-information games where the last player to move wins (normal play convention).
The Sprague--Grundy theorem shows that every such impartial game is equivalent to a Nim heap.

#Box[
  *Sprague--Grundy Theorem.* Every impartial combinatorial game under normal play is equivalent to a Nim heap of size $g$, where $g$ is the _Grundy number_ (also called _nimber_ or _mex value_) defined recursively:
  $ g("position") = "mex"({ g(s) mid(|) s "is a reachable position"} ) $
  where "mex" of a set of non-negative integers is the smallest non-negative integer _not_ in the set.
  A position is losing (P-position) iff $g = 0$.
]

#tasklist("probD")[
  + *Nim.* The game of Nim consists of several heaps of tokens. On each turn, a player removes any positive number of tokens from a single heap.
    Prove Bouton's theorem: a Nim position $(h_1, h_2, ..., h_k)$ is losing iff $h_1 xor h_2 xor ... xor h_k = 0$, where $xor$ is bitwise XOR.

  + *Subtraction game.* In the subtraction game $S(n, T)$, there is one heap of $n$ tokens, and a player may remove $t in T$ tokens on each turn (where $T$ is a fixed finite set).
    For $T = {1, 2, 3}$, compute the Grundy numbers for $n = 0, 1, ..., 20$ and identify the pattern of P-positions.
    For $T = {1, 4, 5}$, do the same. Is the pattern periodic?

  + *Wythoff's game.* Two heaps of tokens. A move consists of removing any number of tokens from one heap, or the _same_ number of tokens from both heaps.
    #tasklist("probD3", format: "(a)")[
      + Compute the P-positions for heap sizes up to $(20, 20)$.
      + Show that the P-positions are $(floor(k dot phi), floor(k dot phi^2))$ for $k = 0, 1, 2, ...$, where $phi = (1 + sqrt(5)) "/" 2$ is the golden ratio.
      + Prove that these positions satisfy the "no two in same row/column/diagonal" property.
    ]

  + *Sprague--Grundy disjunctive sum.*
    Given two impartial games $G_1$ and $G_2$, the _disjunctive sum_ $G_1 + G_2$ is the game where on each turn, a player moves in exactly one of the two component games.
    Prove that $g(G_1 + G_2) = g(G_1) xor g(G_2)$ (the Grundy number of the sum is the XOR of the individual Grundy numbers).
    Use this to analyze a game of Nim with heaps $(7, 5, 3, 1)$: is the first player winning? Give a winning move.
]


#line(length: 100%, stroke: 0.4pt)

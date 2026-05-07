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

#set enum(numbering: "1.", tight: false)

+ One of the classical combinatorial problems is counting the number of arrangements of $n$ balls into $k$ boxes.
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


  + How many different passwords can be formed using the following rules?

    #list(marker: sym.bullet)[
      - The password must be exactly 8 characters long.
      - The password must consist only of Latin letters (a--z, A--Z) and Arabic digits (0--9).
      - The password must contain at least 2 digits (0--9) and at least 1 uppercase letter (A--Z).
      - Each character can be used no more than once in the password.
    ]

    #v(0.5em)
    How long does it take to crack such a password?


  + Find the number of different 5-digit numbers using digits 1--9 under the given constraints.
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


  + Let $n$ be a positive integer.
    Prove the following identity using a combinatorial argument:
    $
      sum_(k=1)^n k dot C_n^k = n dot 2^(n-1)
    $


  + Let $r, m, n$ be non-negative integers.
    Prove the following identity using a combinatorial argument:
    $
      binom(m + n, r) = sum_(k=0)^r binom(m, k) binom(n, r - k)
    $


  + Prove the Generalized Pascal's Formula (for $n >= 1$ and $k_1, ..., k_r >= 0$ with $k_1 + ... + k_r = n$):
    $
      binom(n, k_1, ..., k_r) = sum_(i=1)^r binom(n-1, k_1, ..., k_i - 1, ..., k_r)
    $


  + Find the coefficient of $x^5 y^7 z^3$ in the expansion of $(x + y + z)^(15)$.


  + Count the number of permutations of the multiset $Sigma^* = {2 dot #sym.triangle.stroked, 3 dot #sym.square.stroked, 1 dot #sym.sun}$.


  + A #emph[non-crossing perfect matching]#footnote[
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


  + How many integer solutions are there for each given equation?

    #columns(2, gutter: 1em)[
      #tasklist("eqs", format: "(a)")[
        + $x_1 + x_2 + x_3 = 20$, where $x_i >= 0$
        + $x_1 + x_2 + x_3 = 20$, where $x_i >= 1$
        + $x_1 + x_2 + x_3 = 20$, where $x_i >= 5$
        + $x_1 + x_2 + x_3 <= 20$, where $x_i >= 0$
        + $x_1 + x_2 + x_3 = 20$, where $1 <= x_1 <= x_2 <= x_3$
        + $x_1 + x_2 + x_3 = 20$, where $0 <= x_1 <= x_2 <= x_3$
        + $x_1 + x_2 + x_3 = 20$, where $0 <= x_1 <= x_2 <= x_3 <= 10$
        + $x_1 + x_2 + x_3 = 5$, where $-5 <= x_i <= 5$
      ]
    ]


  + Consider three dice: one with 4 faces, one with 6 faces, and one with 8 faces.
    The faces are numbered 1 to 4, 1 to 6, and 1 to 8, respectively.
    Find the probability of rolling a total sum of 12.


  + Let $A = {1, 2, 3, ..., 12}$.
    Define an #emph[interesting] subset of $A$ as a subset in which no two elements have a difference of 3.
    Determine the number of interesting subsets of $A$.


  + Find the number of ways to arrange five people of distinct heights in a line such that no three consecutive individuals form a strictly ascending or descending height sequence.


  + GLaDOS, the mastermind AI, is testing a new batch of first-year students in one of her infamous test chambers.
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

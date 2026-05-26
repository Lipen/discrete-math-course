#import "common.typ": *
#show: template

#set page(
  paper: "a4",
  margin: (top: 3cm, rest: 2cm),
  header: [
    #set text(10pt)
    #smallcaps[*Homework Assignment \#8*]
    #h(1fr)
    #link("https://github.com/Lipen/discrete-math-course")[*Discrete Mathematics*]
    \
    *Recurrences and Generating Functions*
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


#Block[
  The problems in this assignment are _tagged_:

  #TagCore are essential problems that you _must solve_ to pass the assignment.

  #TagChallenge are _non-mandatory_ problems that could be _skipped_ for a passing grade.

  #TagBonus are _optional_ problems for _memorable experience_.
  They won't be graded.
]


== Problem 1: Solving Recurrences #h(1fr)#TagCore

For each given recurrence relation, find the first five terms,
derive the closed-form solution, and check it by substituting it back to the recurrence relation.

#tasklist("prob1", cols: 2, format: "(a)")[
  + $a_n = a_(n-1) + n$ with $a_0 = 2$
  + $a_n = 2 a_(n-1) + 2$ with $a_0 = 1$
  + $a_n = 3 a_(n-1) + 2^n$ with $a_0 = 5$
  + $a_n = 4 a_(n-1) + 5 a_(n-2)$ with $a_0 = 1$, $a_1 = 17$
  + $a_n = 4 a_(n-1) - 4 a_(n-2)$ with $a_0 = 3$, $a_1 = 11$
  + $a_n = 2 a_(n-1) + a_(n-2) - 2 a_(n-3)$ with $a\_(0,1,2) = 3, 2, 6$
]


== Problem 2: Master Theorem and Akra--Bazzi #h(1fr)#TagCore

Solve the following recurrences by applying the #link("https://en.wikipedia.org/wiki/Master_theorem_(analysis_of_algorithms)")[Master theorem].
For the cases where the Master theorem does not apply,
use the #link("https://en.wikipedia.org/wiki/Akra-Bazzi_method")[Akra--Bazzi method].
In cases where neither of these two theorems apply,
explain why and solve the recurrence relation by closely examining the recursion tree.
Solutions must be in the form $T(n) in Theta(dots)$.

#tasklist("prob2", cols: 2, format: "(a)")[
  + $T(n) = 2 T(n \/ 2) + n$

  + $T(n) = T(3 n \/ 4) + T(n \/ 4) + n$
  + $T(n) = 3 T(n \/ 2) + n$
  + $T(n) = 2 T(n \/ 2) + n \/ log n$
  + $T(n) = 6 T(n \/ 3) + n^2 log n$
  + $T(n) = T(3 n \/ 4) + n log n$

  #colbreak()

  + $T(n) = T(floor(n \/ 2)) + T(ceil(n \/ 2)) + n$

  + $T(n) = T(n \/ 2) + T(n \/ 4) + 1$
  + $T(n) = T(n \/ 2) + T(n \/ 3) + T(n \/ 6) + n$
  + $T(n) = 2 T(n \/ 3) + 2 T(2 n \/ 3) + n$
  + $T(n) = sqrt(2 n) T(sqrt(2 n)) + sqrt(n)$
  + $T(n) = sqrt(2 n) T(sqrt(2 n)) + n$
]


== Problem 3: Estimating Square Roots via Recurrences #h(1fr)#TagChallenge

Consider a recurrence relation $a_n = 2 a_(n-1) + 2 a_(n-2)$ with $a_0 = a_1 = 2$.
Solve it (i.e. find a closed formula) and show how it can be used to estimate the value of $sqrt(3)$
(hint: observe $lim_(n -> infinity) a_n \/ a_(n-1)$).

After that, devise an algorithm for constructing a recurrence relation with integer coefficients
and initial conditions that can be used to estimate the square root $sqrt(k)$ of a given integer $k$.


#pagebreak()

== Problem 4: Generating Function --- Closed Formula #h(1fr)#TagCore

Find a closed formula for the $n$-th term of the sequence with generating function
$ frac(3 x, 1 - 4 x) + frac(1, 1 - x) $


== Problem 5: Partial Fractions Decomposition #h(1fr)#TagCore

Given the generating function $G(x) = frac(5 x^2 + 2 x + 1, (1 - x)^3)$,
decompose it into partial fractions and find the sequence that it represents.


== Problem 6: Pell--Lucas Numbers #h(1fr)#TagCore

#link("https://en.wikipedia.org/wiki/Pell_number")[Pell--Lucas numbers] are defined by
$Q_0 = Q_1 = 2$ and $Q_n = 2 Q_(n-1) + Q_(n-2)$ for $n >= 2$.

Derive the corresponding generating function and find a closed formula for the $n$-th Pell--Lucas number.


== Problem 7: Generating Functions for Recurrences #h(1fr)#TagCore

For each given recurrence relation, derive the corresponding generating function
and find a closed formula for the $n$-th term of the sequence.

#tasklist("prob7", format: "(a)")[
  + $a_n = 2 a_(n-1) - a_(n-2)$ with $a_0 = 3$, $a_1 = 5$
  + $a_n = a_(n-1) + a_(n-2) - a_(n-3)$ with $a_0 = 1$, $a_1 = 1$, $a_2 = 5$
  + $a_n = a_(n-1) + n$ with $a_0 = 0$
  + $a_n = a_(n-1) + 2 a_(n-2) + 2^n$ with $a_0 = 2$, $a_1 = 1$
]


== Problem 8: Diophantine Equation via Generating Functions #h(1fr)#TagCore

Find the number of non-negative integer solutions to the Diophantine equation
$ 3 x + 5 y = 100 $
using generating functions.


== Problem 9: Lucky Tickets #h(1fr)#TagChallenge

Consider a $2 n$-digit ticket number to be _lucky_ if the sum of its first $n$ digits
is equal to the sum of its last $n$ digits.
Each digit (including the first one!) in a number can take value from 0 to 9.
For example, a 6-digit ticket $345\,264$ is lucky since $3 + 4 + 5 = 2 + 6 + 4$.

#tasklist("prob9", format: "(a)")[
  + Find the number of lucky 6-digit and 8-digit tickets.
  + Find the generating function for the number of $2 n$-digit lucky tickets.
  + Find a closed formula for the number of $2 n$-digit lucky tickets.
]

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

#tasklist("prob1", cols: 1, format: "(a)")[
  + $a_n = a_(n-1) + n$ with $a_0 = 2$

  + $a_n = 2 a_(n-1) + 2$ with $a_0 = 1$

  + $a_n = 3 a_(n-1) + 2^n$ with $a_0 = 5$

  + $a_n = 4 a_(n-1) + 5 a_(n-2)$ with $a_0 = 1$, $a_1 = 17$

  + $a_n = 4 a_(n-1) - 4 a_(n-2)$ with $a_0 = 3$, $a_1 = 11$

  + $a_n = 2 a_(n-1) + a_(n-2) - 2 a_(n-3)$ with $a_(0,1,2) = 3, 2, 6$
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


#pagebreak()

#align(center)[
  #set text(1.2em, weight: "bold")
  Optional Bonus Problems
]

#Block[
  The following problems are _"optional"_.
  They require programming and/or deeper theory.
  They~will _not_ count toward your grade but _may_ earn bonus points and genuine understanding.
]


== Problem A: The Fibonacci Zoo #h(1fr)#TagBonus

In 1202, Leonardo of Pisa --- known as _Fibonacci_ --- posed a simple question about rabbit breeding.
The resulting sequence $0, 1, 1, 2, 3, 5, 8, 13, 21, dots$ appears in sunflower spirals, pinecone bracts, and the worst-case height of AVL trees.
But beneath the familiar $F_n = (phi^n - psi^n) \/ sqrt(5)$ lies a zoo of surprising phenomena.

#Box[
  *Fibonacci recurrence.* $F_0 = 0$, $F_1 = 1$, $F_n = F_(n-1) + F_(n-2)$ for $n >= 2$.
  Binet: $F_n = frac(phi^n - psi^n, sqrt(5))$ where $phi = frac(1 + sqrt(5), 2)$, $psi = frac(1 - sqrt(5), 2)$.
]

#tasklist("probA")[
  + *Pisano periods.*
    Reduce every Fibonacci number modulo $m$ and the remainders _always become periodic_.
    This period $pi(m)$ is the #link("https://en.wikipedia.org/wiki/Pisano_period")[_Pisano period_] --- nobody has a closed formula for it.
    - Compute $pi(m)$ for $m = 2, 3, 4, 5, 6, 7, 8, 9, 10, 100$ by brute force.
    - Prove: if $p$ is prime and $p equiv plus.minus 1 thin (mod thin 5)$, then $pi(p)$ divides $p - 1$.
      (Apply Fermat's little theorem to Binet's formula.)
    - The last digit of $F_n$ repeats every 60 terms.
      Explain why $pi(10) = "lcm"(pi(2), pi(5))$ and compute $pi(2)$, $pi(5)$.

  + *Zeckendorf: every number is a sum of non-consecutive Fibonaccis.*
    Zeckendorf (1939): _every_ positive integer has a _unique_ representation as a sum of non-consecutive Fibonacci numbers (from $F_2 = 1$).
    For example, $100 = 89 + 8 + 3 = F_(11) + F_6 + F_4$.
    - Prove that the greedy algorithm (always take the largest $F_k <= N$, subtract, repeat)
      never selects two consecutive Fibonacci numbers.
      (If it picks $F_k$ and $F_(k-1)$, then $F_k + F_(k-1) = F_(k+1)$ --- contradiction.)
    - Prove uniqueness: two different non-consecutive subsets of ${F_2, F_3, dots}$
      cannot sum to the same $N$.
    - Implement the greedy algorithm. Write the Zeckendorf representation of $42$, $100$, and $2025$.

  + *Fibonacci coding: turning Zeckendorf into a prefix code.*
    Write the Zeckendorf representation in reverse binary (bit $i$ = 1 iff $F_(i+2)$ is used), then append an extra `1`.
    The `11` suffix is a unique terminator --- no codeword is a prefix of another, so you can concatenate messages without delimiters.
    - Encode `"HELLO"` ($A to 1, dots, Z to 26$) using Fibonacci coding.
      Compare total bits with $5 times 5 = 25$ bits of fixed-width encoding.
    - Prove prefix-freeness: every codeword ends in `11` and no Zeckendorf representation has consecutive 1-bits.

]


== Problem B: Euler's Pentagonal Magic #h(1fr)#TagBonus

In 1741, Euler wrote to Berlin claiming an impossible identity: the infinite product $(1 - x)(1 - x^2)(1 - x^3) dots.c$ should have coefficients everywhere, but when expanded, _almost all vanish_ --- the only nonzero ones sit at the positions $1, 2, 5, 7, 12, 15, 22, 26, dots$, known as _pentagonal numbers_ $k(3k - 1) \/ 2$.
From this single identity, Euler derived a recurrence for $p(n)$, the number of partitions of $n$.
A century and a half later, Ramanujan discovered that $p(5k + 4)$ is always divisible by 5, and $p(7k + 5)$ by 7.
This problem follows the thread from Euler's product to Ramanujan's congruences.

#Box[
  *Euler's pentagonal number theorem.*
  $
    product_(k=1)^infinity (1 - x^k)
    = sum_(k=-infinity)^infinity (-1)^k x^(k(3k-1)\/2)
    = 1 - x - x^2 + x^5 + x^7 - x^12 - x^15 + dots
  $
  *Partition generating function.*
  $
    sum_(n=0)^infinity p(n) x^n
    = product_(k=1)^infinity frac(1, 1 - x^k)
  $
  where $p(n)$ counts the ways to write $n$ as a sum of positive integers in non-increasing order.
]

#tasklist("probB")[
  + *Vanishing coefficients and the partition GF.*
    Expand $(1 - x)(1 - x^2) dots.c (1 - x^{30})$ and inspect the coefficients:
    they are only $0, +1, -1$, and the nonzero indices form the sequence
    $1, 2, 5, 7, 12, 15, 22, 26, dots$
    - Verify that these are exactly $k(3k - 1) \/ 2$ for $k = plus.minus 1, plus.minus 2, plus.minus 3, dots$ and that the sign at index $k(3k-1)\/2$ is $(-1)^k$.
      Does the coefficient of $x^n$ vanish for _every_ $n$ that is _not_ a pentagonal number?
    - The partition GF is $sum_(n=0)^infinity p(n) x^n = product_(k=1)^infinity frac(1, 1 - x^k)$.
      Why? Each factor $frac(1, 1-x^k) = 1 + x^k + x^(2 k) + dots$ counts how many times part $k$ appears.
      Multiply 20 factors and read off $p(1)$ through $p(20)$.
      Verify: $p(5) = 7$.

  + *Euler's recurrence for $p(n)$.*
    Multiply the pentagonal theorem by the partition GF:
    $ 1 = (sum_k (-1)^k x^(k(3k-1)\/2)) dot (sum_n p(n) x^n) $
    For $n >= 1$, the coefficient of $x^n$ on the right must vanish.
    Setting it to zero gives a recurrence with pentagonal-number offsets:
    $ p(n) = p(n - 1) + p(n - 2) - p(n - 5) - p(n - 7) + p(n - 12) + p(n - 15) - dots $
    (signs alternate in pairs, negative indices treated as zero).
    - Implement this recurrence and compute $p(n)$ for $n = 0, dots, 100$.
      Verify $p(10) = 42$, $p(50) = 204226$, $p(100) = 190569292$.

  + *Ramanujan's congruences.*
    Ramanujan proved:
    $p(5k + 4) equiv 0 thin (mod thin 5)$,
    $p(7k + 5) equiv 0 thin (mod thin 7)$,
    $p(11k + 6) equiv 0 thin (mod thin 11)$.
    Verify all three for $k = 0, 1, dots, 50$ using your recurrence.

  + *The Hardy--Ramanujan asymptotic.*
    Hardy and Ramanujan (1918) proved: $p(n) sim frac(1, 4 n sqrt(3)) exp(pi sqrt(2 n \/ 3))$.
    Compute $p(n)$ exactly via the recurrence and compare with the asymptotic formula for $n = 5, 20, 50, 100, 500, 1000$.
    Plot the relative error.
    How many digits does the asymptotic get right for $p(1000)$?
]


== Problem C: Linear Recurrence Solver #h(1fr)#TagBonus

You've solved recurrences by hand --- characteristic polynomials, partial fractions, careful algebra.
Now build a _tool_ that does it automatically: from recurrence to closed form, and from closed form to
$a_n$ for $n = 10^(18)$ in milliseconds.

#Box[
  *Companion matrix.* $a_n = c_1 a_(n-1) + dots + c_k a_(n-k)$ becomes
  $
    vec(bold(v)_n) = mat(
      c_1, c_2, dots, c_k;
      1, 0, dots, 0;
      dots.v, , dots.down, dots.v;
      0, dots, 1, 0,
    ) vec(bold(v)_(n-1))
  $
  Repeated squaring computes $a_n$ in $O(k^3 log n)$ time.
]

#tasklist("probC")[
  + *Characteristic polynomial pipeline.*
    Given a recurrence and initial conditions, produce the closed form:
    (1)~characteristic polynomial from coefficients,
    (2)~all roots (complex, repeated, or both),
    (3)~solve a linear system for coefficients from initial conditions,
    (4)~assemble $a_n = sum_i p_i (n) r_i^n$ where $p_i$ has degree one less than the multiplicity of $r_i$.
    Test on every recurrence from Problem~1 --- verify the first 10 terms.

  + *Matrix exponentiation: when you need the number, not the formula.*
    Implement repeated squaring and compute:
    - $F_(100)$ (Fibonacci). Verify.
    - $F_(10^(18)) thin "mod" thin (10^9 + 7)$.
      If your code runs more than a second, something is wrong.
    - Problem~1(d): $a_n = 4 a_(n-1) + 5 a_(n-2)$, $a_0 = 1, a_1 = 17$.
      Compute $a_(10^(15)) thin "mod" thin (10^9 + 7)$.
      Benchmark against $O(n)$ iteration --- where is the crossover?

  + *Applications.* Find a recurrence for the number of domino tilings of a $3 times n$ board (compute small cases, spot the pattern), then use your solver for the closed form.

    Also compute $T_(10^(12)) thin "mod" thin (10^9 + 7)$ for the Tribonacci sequence: $T_n = T_(n-1) + T_(n-2) + T_(n-3)$ with #box[$T_0 = 0$], #box[$T_1 = 0$], #box[$T_2 = 1$].
]

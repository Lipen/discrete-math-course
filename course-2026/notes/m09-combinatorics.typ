// M09 --- Combinatorics: the art of counting without enumerating.
#import "common-notes.typ": *
#import "notation.typ": *

= Combinatorics

#chapter-overview[
  Combinatorics is the mathematics of counting --- how many ways to arrange, select, partition, or combine discrete objects.
  This chapter develops systematic counting tools: sum and product rules, permutations and combinations, binomial identities, inclusion-exclusion, recurrences, and the major sequences (Catalan, Stirling, Bell).
  Counting is the foundation of probability, algorithm analysis, and the enumeration of discrete structures throughout computer science.
]

== Counting Rules

=== Rule of Sum and Product

#definition[Rule of sum][
  If $A$ and $B$ are disjoint finite sets: $|A union B| = |A| + |B|$.
  Generalises to $n$ pairwise disjoint sets.
]

#definition[Rule of product][
  $|A times B| = |A| dot |B|$.
  Sequential choice with $k_1$, $k_2$, ... options: $k_1 dot k_2 dot dots.h$.
]

#example[Password counting][
  Password: 2 letters (26 each) + 4 digits (10 each) = $26^2 dot 10^4 = 6,760,000$.
]

#definition[Rule of complement][
  $|A| = |U| - |overline(A)|$. Count what you *don't* want, subtract from total.
]

#example[
  8-bit strings with at least one 1: $2^8 - 1 = 255$ (only all-zeros has no 1).
]

=== Balls and Boxes

#proposition[Four counting situations][
  #table(
    columns: 3,
    align: (center, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.4pt) },
    table.header([*Balls*], [*Boxes*], [*Count*]),
    [Distinct], [Distinct], [$k^n$ --- each ball chooses a box],
    [Identical], [Distinct], [$binom(n+k-1, n)$ --- stars and bars],
    [Distinct], [Identical], [$S(n,1) + ... + S(n,k)$ --- Stirling 2nd kind],
    [Identical], [Identical], [Integer partitions],
  )
]


== Permutations, Arrangements, Combinations

#definition[Permutation][
  An ordering of $n$ distinct objects. Count: $n! = 1 dot 2 dot ... dot n$.
]

#proposition[Stirling's approximation][
  $n! tilde.op sqrt(2 pi n) (n/e)^n$.
]

#definition[Arrangement ($k$-permutation)][
  Choose $k$ from $n$ distinct objects, order matters.
  $P(n, k) = n dot (n-1) dot ... dot (n-k+1) = n!/(n-k)!$.
]

#definition[Combination][
  Choose $k$ from $n$ distinct objects, order irrelevant.
  $binom(n, k) = (n!)/(k!(n-k)!) = P(n, k)/k!$.
]

#example[
  Committee of 3 from 10 people: $binom(10, 3) = 120$.
  Medal podium (gold, silver, bronze) from 10: $P(10, 3) = 720$.
]

#definition[Combinations with repetition][
  $binom(n + k - 1, k)$ --- choose $k$ items from $n$ types, repetition allowed, order irrelevant.
  Proof: $k$ stars, $n-1$ bars separating types.
]

#definition[Permutations with repetition][
  $n$ objects with $n_i$ identical of type $i$: $n!/(n_1! n_2! dots.h n_k!)$ (multinomial coefficient).
]

#example[
  "MISSISSIPPI": M×1, I×4, S×4, P×2. $11!/(1!4!4!2!) = 34,650$ distinct strings.
]


== Binomial Coefficients and Identities

#proposition[Pascal's identity][
  $binom(n, k) = binom(n-1, k-1) + binom(n-1, k)$ for $1 <= k <= n-1$.
]

#theorem[Binomial theorem][
  $(x + y)^n = sum_(k=0)^n binom(n, k) x^(n-k) y^k$.
]

#proposition[Core identities][
  - *Row sum*: $sum binom(n, k) = 2^n$ (all subsets).
  - *Alternating sum*: $sum (-1)^k binom(n, k) = 0$ for $n >= 1$.
  - *Hockey-stick*: $sum_(i=k)^n binom(i, k) = binom(n+1, k+1)$.
  - *Vandermonde*: $binom(m+n, r) = sum binom(m, k) binom(n, r-k)$.
  - *Weighted sum*: $sum k binom(n, k) = n 2^(n-1)$.
]

#proof-sketch[
  Each identity has two proofs: algebraic (manipulate factorials) and combinatorial (count a set two ways).
  The combinatorial proof is usually more illuminating.
]


== Inclusion-Exclusion

#theorem[Inclusion-Exclusion --- general form][
  $|union.big_(i=1)^n A_i| = sum |A_i| - sum_(i < j) |A_i inter A_j| + sum_(i < j < k) |A_i inter A_j inter A_k| - ... + (-1)^(n+1) |inter.big A_i|$.
]

#proof[
  An element in exactly $k$ of the $A_i$ is counted $binom(k, 1) - binom(k, 2) + ... + (-1)^(k+1)binom(k, k) = 1$ time.
]

#example[Derangements][
  Permutations where no element stays in place:
  $!n = n! sum_(i=0)^n ((-1)^i)/(i!) approx n!/e$.
]

#example[Euler's totient][
  $phi(n) = n product_(p|n) (1 - 1/p)$ --- count integers $<= n$ coprime to $n$.
]

#example[Surjections][
  Number of surjective functions $A arrow B$ ($|A|=n$, $|B|=k$):
  $k! S(n, k) = sum_(i=0)^k (-1)^i binom(k, i) (k-i)^n$.
]


== Recurrences

#definition[Linear recurrence with constant coefficients][
  $a_n = c_1 a_(n-1) + ... + c_k a_(n-k)$, with $a_0, ..., a_(k-1)$ given.
]

#proposition[Solving method][
  1. Characteristic polynomial: $r^k - c_1 r^(k-1) - ... - c_k = 0$.
  2. Distinct roots $r_i$: $a_n = sum alpha_i r_i^n$.
  3. Root $r$ of multiplicity $m$: terms $r^n$, $n r^n$, ..., $n^(m-1) r^n$.
  $alpha_i$ determined from initial conditions.
]

#example[Fibonacci][
  $F_n = F_(n-1) + F_(n-2)$, $F_0 = 0$, $F_1 = 1$.
  Characteristic: $r^2 - r - 1 = 0$, roots $phi = (1+sqrt(5))/2$, $psi = (1-sqrt(5))/2$.
  $F_n = (phi^n - psi^n)/sqrt(5)$ --- Binet's formula.
]

=== Non-Homogeneous Recurrences

For $a_n = c_1 a_(n-1) + ... + c_k a_(n-k) + f(n)$:
the solution is the general homogeneous solution plus a *particular solution*.
If $f(n)$ is a polynomial times $d^n$, guess a particular solution of the same form with undetermined coefficients.
If the guess overlaps with the homogeneous solution, multiply by $n$.

#example[Merge Sort][
  $T(n) = 2T(n/2) + n$, $T(1) = 0$.
  Substitute $n = 2^k$: $T(2^k) = 2T(2^(k-1)) + 2^k$.
  Let $t_k = T(2^k)$: $t_k = 2t_(k-1) + 2^k$, $t_0 = 0$.
  Homogeneous: $t_k^((h)) = A dot 2^k$. Particular: guess $t_k^((p)) = B k 2^k$.
  Solving: $B = 1$, so $t_k = k 2^k$.
  Thus $T(n) = n log_2 n$.
]

#remark[
  Recurrences model algorithm runtimes.
  The Master Theorem handles divide-and-conquer recurrences of the form $T(n) = a T(n/b) + f(n)$ by comparing $f(n)$ with $n^(log_b a)$.
]


== Special Numbers

=== Catalan Numbers

#definition[Catalan numbers][
  $C_n = 1/(n+1) binom(2n, n)$.
  Recurrence: $C_0 = 1$, $C_(n+1) = sum_(i=0)^n C_i C_(n-i)$.
]

$C_n$ counts: correct bracket sequences of $n$ pairs, binary trees with $n$ internal nodes, triangulations of $(n+2)$-gon, Dyck paths, matrix parenthesisation.

#remark[
  Catalan numbers appear in compiler design (parse trees), computational geometry, and algorithm analysis.
]

=== Stirling and Bell Numbers

#definition[Stirling numbers of the first kind][
  $c(n, k)$ = permutations of $n$ elements with exactly $k$ cycles.
  $c(n, k) = c(n-1, k-1) + (n-1) c(n-1, k)$.
]

#definition[Stirling numbers of the second kind][
  $S(n, k)$ = partitions of $n$-element set into $k$ non-empty unlabeled blocks.
  $S(n, k) = S(n-1, k-1) + k S(n-1, k)$.
]

#definition[Bell numbers][
  $B_n = sum_(k=0)^n S(n, k)$ = total partitions of $n$-element set.
  $B_3 = 5$, $B_4 = 15$, $B_5 = 52$.
]

#proposition[Multinomial theorem][
  $(x_1 + ... + x_m)^n = sum_(k_1+...+k_m=n) binom(n, k_1, ..., k_m) x_1^(k_1) ... x_m^(k_m)$,
  where $binom(n, k_1, ..., k_m) = n!/(k_1! dots.h k_m!)$.
]

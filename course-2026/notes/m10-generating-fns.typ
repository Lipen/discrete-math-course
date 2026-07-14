// M10 --- Generating Functions: the algebraic bridge from sequences to closed forms.
#import "common-notes.typ": *
#import "notation.typ": *

= Generating Functions

#chapter-overview[
  *Chapter overview.*
  A generating function packages an entire sequence into a single algebraic object, turning combinatorial problems into algebraic ones.
  This chapter introduces ordinary and exponential generating functions, the technique of solving recurrences via generating functions, and applications from Fibonacci numbers to algorithm analysis.
  The chapter closes with a glimpse of combinatorial species --- the structural theory behind generating functions.
]

== Ordinary Generating Functions

=== Definition

#definition[Ordinary generating function][
  The OGF of $(a_n)_(n=0)^oo$ is the formal power series $A(x) = sum_(n=0)^oo a_n x^n$.
  Convergence is irrelevant --- $x$ is a placeholder. Coefficient extraction: $[x^n] A(x) = a_n$.
]

=== Operations

#proposition[OGF operations][
  + *Addition*: $A(x) + B(x) = sum (a_n + b_n) x^n$.
  + *Right shift*: $x A(x) = sum a_n x^(n+1) = sum a_(n-1) x^n$.
  + *Left shift*: $(A(x) - a_0)/x = sum a_(n+1) x^n$.
  + *Convolution*: $A(x) B(x) = sum c_n x^n$ where $c_n = sum_(i=0)^n a_i b_(n-i)$.
  + *Partial sums*: $A(x)/(1-x) = sum s_n x^n$ where $s_n = sum_(i=0)^n a_i$.
]

=== Basic Series

#proposition[Standard OGFs][
  #table(
    columns: 2,
    align: (left, left),
    table.header([*Sequence* $a_n$], [*OGF* $A(x)$]),
    [$a_n = 1$], [$1/(1-x)$],
    [$a_n = n$], [$x/(1-x)^2$],
    [$a_n = binom(k, n)$], [$(1+x)^k$],
    [$a_n = binom(n+k-1, n)$], [$1/(1-x)^k$],
    [$a_n = c^n$], [$1/(1 - c x)$],
  )
]

=== Solving Recurrences via OGF

#proposition[OGF method][
  1. Write recurrence valid for $n >= k$.
  2. Multiply by $x^n$, sum over $n >= k$.
  3. Express sums in terms of $A(x)$ via shift operations.
  4. Solve for $A(x)$.
  5. Decompose into partial fractions.
  6. Expand each fraction as power series.
  7. Read $a_n = [x^n] A(x)$.
]

#example[Fibonacci via OGF][
  $F_n = F_(n-1) + F_(n-2)$, $n >= 2$, $F_0 = 0$, $F_1 = 1$.
  $F(x) - 0 - x = x(F(x) - 0) + x^2 F(x)$ $=>$ $F(x) = x/(1 - x - x^2)$.
  Factor: $1 - x - x^2 = (1 - phi x)(1 - psi x)$.
  Partial fractions: $F(x) = 1/sqrt(5) (1/(1 - phi x) - 1/(1 - psi x))$.
  $F_n = (phi^n - psi^n)/sqrt(5)$ --- Binet's formula.
]

#example[Catalan numbers via OGF][
  Recurrence: $C_0 = 1$, $C_(n+1) = sum_(i=0)^n C_i C_(n-i)$ for $n >= 0$.
  The right side is the convolution of $(C_n)$ with itself.
  $C(x) = sum C_n x^n = 1 + x sum_(n=0)^oo (sum_(i=0)^n C_i C_(n-i)) x^n = 1 + x C(x)^2$.
  Solve quadratic: $C(x) = (1 - sqrt(1 - 4x))/(2x)$ (the root with $C(0) = 1$).
  Expand via generalised binomial: $sqrt(1 - 4x) = sum_(n=0)^oo binom(1/2, n) (-4x)^n$.
  After simplification: $[x^n] C(x) = 1/(n+1) binom(2n, n)$ --- closed form for Catalan numbers.
]

#remark[
  Any linear recurrence with constant coefficients yields a rational OGF: $A(x) = P(x)/Q(x)$.
  The denominator $Q(x) = 1 - c_1 x - ... - c_k x^k$ is the reciprocal characteristic polynomial.
  Non-linear recurrences (like Catalan) yield algebraic equations on $A(x)$.
  The OGF approach is a unified algebraic machine for recurrences.
]


== Exponential Generating Functions

#definition[Exponential generating function][
  $E(x) = sum_(n=0)^oo a_n x^n/(n!)$.
  Convenient for sequences with $n!$ factors or labelled structures.
]

#proposition[EGF operations][
  + *Shift*: $dif/(dif x) E(x) = sum a_(n+1) x^n/(n!)$ --- differentiation shifts left.
  + *Binomial convolution*: $A(x) B(x) = sum c_n x^n/(n!)$ where $c_n = sum binom(n, i) a_i b_(n-i)$.
]

#proposition[Standard EGFs][
  #table(
    columns: 2,
    align: (left, left),
    table.header([*Sequence* $a_n$], [*EGF* $E(x)$]),
    [$a_n = 1$], [$e^x$],
    [$a_n = n!$], [$1/(1-x)$],
    [$a_n = c^n$], [$e^(c x)$],
    [$a_n = S(n, k)$], [$(e^x - 1)^k/(k!)$],
    [$a_n = B_n$ (Bell)], [$e^(e^x - 1)$],
  )
]

#remark[
  The EGF for Bell numbers --- $e^(e^x - 1)$ --- encodes an entire infinite sequence in one expression.
]


== Combinatorial Species (Teaser)

#definition[Combinatorial species --- idea][
  A *species* $F$ assigns to each finite set $U$ of labels a finite set $F[U]$ of structures.
  + Sets: $F[U] = {U}$.
  + Lists (permutations): all linear orders of $U$.
  + Trees, graphs, etc.
]

The EGF of a species: $F(x) = sum |F[{1,...,n}]| x^n/(n!)$.
Species operations (sum, product, composition) correspond exactly to EGF operations.

#example[Binary trees as a species][
  $T = 1 + X times T^2$ (a tree is empty or a root with two subtrees).
  Translates to $T(x) = 1 + x T(x)^2$.
  Solving: $T(x) = (1 - sqrt(1 - 4x))/(2x)$, coefficients are Catalan $C_n$.
]

#note[
  Combinatorial species, developed by André Joyal (1980s), unify enumeration, algebra, and structural decomposition.
  They turn informal reasoning into rigorous algebraic equations on generating functions.
]

== Applications

#remark[
  Generating functions not only give exact closed forms --- they also yield asymptotics.
  The dominant singularity (closest to 0) of $A(x)$ determines the growth rate of $a_n$: if the dominant singularity is $rho$ of type $(1 - x/rho)^(-alpha)$, then $a_n tilde.op C n^(alpha-1) rho^(-n)$.
  This is the basis of analytic combinatorics (Flajolet-Sedgewick).
  For Catalan: $rho = 1/4$, $alpha = -1/2$ → $C_n tilde.op 4^n/(sqrt(pi) n^(3/2))$.
]

#remark[Cayley's formula][
  Number of labelled trees on $n$ vertices: $n^(n-2)$.
  EGF for rooted labelled trees: $T(x) = x e^(T(x))$ (Lambert $W$).
  Lagrange inversion extracts $n^(n-2)$.
]

#example[Quicksort analysis via OGF][
  Expected comparisons for random pivot on input size $n$:
  $C_n = n-1 + 2/n sum_(k=0)^(n-1) C_k$, $quad C_0 = 0$.
  Multiply by $n$: $n C_n = n(n-1) + 2 sum_(k=0)^(n-1) C_k$.
  Let $C(x) = sum C_n x^n$.
  The recurrence translates to a differential equation in $C(x)$.
  Solving: $C(x) = 2/(1-x)^2 ln 1/(1-x) - 2x/(1-x)^2$.
  Extract $[x^n]$: $C_n = 2(n+1) H_n - 4n$, where $H_n = sum_(k=1)^n 1/k$ (harmonic numbers).
  Using $H_n tilde.op ln n + gamma$: $C_n tilde.op 2 n ln n$ --- the familiar $O(n log n)$.
]

#remark[Probability generating functions][
  For $P(X = k) = p_k$: $G_X(s) = E s^X = sum p_k s^k$.
  Moments: $E X = G_X'(1)$, $"Var"(X) = G_X''(1) + G_X'(1) - (G_X'(1))^2$.
]

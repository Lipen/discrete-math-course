// M06 --- Boolean Algebra: the algebraic structure of logic and computation.
#import "common-notes.typ": *
#import "notation.typ": *

= Boolean Algebra

#chapter-overview[
  Boolean algebra is the mathematical foundation of digital logic --- every circuit, every conditional, every bitwise operation is an expression in this algebra.
  This chapter studies Boolean functions, their normal forms, and the problem of minimisation.
  The chapter closes with the Zhegalkin polynomial, an algebraic normal form based on XOR, and its cryptographic significance.
]

== Boolean Functions

=== Definitions and Counting

#definition[Boolean function][
  An $n$-ary Boolean function is $f: {0, 1}^n arrow {0, 1}$.
  Fully specified by its truth table with $2^n$ rows.
]

#theorem[Counting Boolean functions][
  There are exactly $2^(2^n)$ distinct $n$-ary Boolean functions.
]

#proof[
  Truth table has $2^n$ rows; each output is 0 or 1 --- $2$ choices.
  Total: $2 dot 2 dot dots.h 2 = 2^(2^n)$.
]

For $n = 0$: constants 0, 1. $n = 1$: 4 functions. $n = 2$: 16 functions --- the classic logic gates.

=== Binary Boolean Functions

The 16 two-variable functions: FALSE, AND, inhibition ($x and not y$), projection $x$, inhibition ($not x and y$), projection $y$, XOR, OR, NOR, XNOR, NOT $y$, converse implication, NOT $x$, implication ($x imply y = not x or y$), NAND, TRUE.

#note[
  $x imply y = not x or y$ and $x equiv y = (x imply y) and (y imply x)$ --- implication and equivalence are expressible via NOT, AND, OR.
]

=== Functional Completeness

#definition[Functional completeness][
  A set $F$ of Boolean functions is *functionally complete* if every Boolean function can be written as a composition of functions from $F$.
]

#theorem[Sheffer stroke and Peirce arrow][
  Each of ${"NAND"}$ ($arrow.t$) and ${"NOR"}$ ($arrow.b$) alone is functionally complete.
]

#proof[
  Express NOT, AND, OR using only NAND:
  $not x = x arrow.t x$,
  $x and y = (x arrow.t y) arrow.t (x arrow.t y)$,
  $x or y = (x arrow.t x) arrow.t (y arrow.t y)$.
  Since ${"NOT"}, {"AND"}, {"OR"}$ is complete, so is NAND.
]

#proposition[Standard complete sets][
  ${"NOT"}, {"AND"}, {"OR"}$, ${"NOT"}, {"AND"}$, and ${"NOT"}, {"OR"}$ are functionally complete.
  ${"AND"}, {"OR"}$ alone is NOT complete --- both are monotone, cannot express negation.
]

=== Post's Criterion (Overview)

#proposition[Post's closed classes][
  Five maximal classes, each closed under composition:
  - $T_0$: preserving 0 --- $f(0, ..., 0) = 0$.
  - $T_1$: preserving 1 --- $f(1, ..., 1) = 1$.
  - $S$: self-dual --- $not f(not x_1, ..., not x_n) = f(x_1, ..., x_n)$.
  - $M$: monotone --- increasing inputs never decreases output.
  - $L$: linear --- expressible as XOR of a subset of variables (possibly plus 1).
]

#theorem[Post's criterion][
  A set $F$ is functionally complete iff it is NOT entirely contained in any one of $T_0$, $T_1$, $S$, $M$, $L$.
]

#example[Verifying completeness via Post's criterion][
  Is ${"NAND"}$ ($arrow.t$) complete?
  Check membership in each class:
  - $T_0$: $"NAND"(0, 0) = 1 eq.not 0$ → not in $T_0$.
  - $T_1$: $"NAND"(1, 1) = 0 eq.not 1$ → not in $T_1$.
  - $S$: $"NAND"(not x, not y) = not(not x and not y) = x or y$, but $not("NAND"(x, y)) = not(not(x and y)) = x and y eq.not x or y$ → not self-dual.
  - $M$: $"NAND"(0, 1) = 1$, $"NAND"(1, 1) = 0$ --- increasing input decreases output → not monotone.
  - $L$: $"NAND"(x, y) = not(x and y) = x y xor 1$ --- degree 2, not linear.
  NAND is in none of the five classes → ${"NAND"}$ is complete.
]

#note[
  NAND and NOR are universal gates in digital design --- each is complete and physically simple (4 transistors in CMOS).
]

=== Boolean Algebra as Algebraic Structure

#definition[Boolean algebra axioms][
  A Boolean algebra is $(B, and, or, bar(X), 0, 1)$ satisfying:
  - Commutativity, associativity, distributivity of $and$/$or$.
  - Identity: $a and 1 = a$, $a or 0 = a$.
  - Complement: $a and overline(a) = 0$, $a or overline(a) = 1$.
]

#proposition[Duality principle][
  Every identity remains valid if $and$ and $or$ are swapped, and $0$ and $1$ are swapped.
  Every theorem has a dual.
]


== Normal Forms

=== Literals, Minterms, Maxterms

#definition[Literals, minterms, maxterms][
  - *Literal*: variable $x_i$ or its negation $overline(x_i)$.
  - *Minterm*: conjunction of literals where each variable appears exactly once --- one per truth table row ($2^n$ total).
  - *Maxterm*: disjunction of literals where each variable appears exactly once.
]

#example[
  For $n = 3$: minterm $x and overline(y) and z$ is true only on $(1, 0, 1)$.
  Maxterm $x or overline(y) or z$ is false only on $(0, 1, 0)$.
]

=== DNF and CNF

#definition[DNF][
  Disjunctive Normal Form: disjunction of conjunctions of literals.
  $(l_(1,1) and ...) or ... or (l_(m,1) and ...)$.
]

#definition[CNF][
  Conjunctive Normal Form: conjunction of disjunctions of literals.
  $(l_(1,1) or ...) and ... and (l_(m,1) or ...)$.
]

#theorem[Existence][
  Every Boolean function has DNF and CNF representations.
]

Construction from truth table:
- DNF: for each row with $f = 1$, write conjunction of literals ($x_i$ if 1, $overline(x_i)$ if 0). Disjoin all.
- CNF (dual): for each row with $f = 0$, write disjunction ($overline(x_i)$ if 1, $x_i$ if 0). Conjoin all.

#definition[Perfect normal forms][
  - *Perfect DNF* (SDNF): every conjunction contains all $n$ variables.
  - *Perfect CNF* (SKNF): every disjunction contains all $n$ variables.
  Both unique up to order.
]

Non-perfect DNF/CNF are not unique --- this motivates minimisation.


== Minimisation

Goal: find a DNF with minimal literals (or terms).

=== Karnaugh Maps

#definition[Karnaugh map][
  A 2D truth table with Gray code ordering --- adjacent cells differ in one variable.
  Rectangular groups of $2^k$ adjacent 1-cells correspond to a conjunction of $n - k$ literals.
]

#definition[Prime implicant][
  A *prime implicant* is a conjunction implying the function, not expandable.
  On the K-map: maximal rectangular group of 1-cells (size = power of 2).
  *Essential prime implicant*: covers at least one 1-cell not covered by others.
]

Procedure: (1) identify all prime implicants, (2) mark essential ones, (3) cover remaining 1-cells minimally.

#note[
  *Don't-care conditions* (× on K-map): input combinations that never occur or whose output is irrelevant.
  Treated as 0 or 1, whichever creates larger groups.
  K-maps work for $n <= 4$; beyond that, algorithmic methods are needed.
]

=== Quine-McCluskey Algorithm

#proposition[Quine-McCluskey --- outline][
  1. List minterms in binary.
  2. *Merging phase*: combine pairs differing in one bit (replace bit with dash). Repeat until no merges.
    Unmerged terms = prime implicants.
  3. *Covering phase*: select minimal subset of prime implicants covering all minterms (set cover --- NP-hard in general, heuristics exist).
]

Modern tools (Espresso) use iterative improvement for near-minimal results on dozens of variables.


== Zhegalkin Polynomial (ANF)

#definition[Zhegalkin polynomial][
  The Algebraic Normal Form represents a Boolean function as XOR of conjunctions:
  $f(x_1, ..., x_n) = xor_(S subset.eq {1,...,n}) a_S dot product_(i in S) x_i$,
  where $a_S in {0, 1}$ and XOR is addition modulo 2.
]

#theorem[Uniqueness][
  Every Boolean function has exactly one Zhegalkin polynomial.
]

Three computation methods:
1. *Undetermined coefficients*: substitute all $2^n$ assignments, solve linear system over $italic("GF")(2)$.
2. *Equivalent transformations*: apply $x or y = x xor y xor x y$, $overline(x) = x xor 1$, simplify with $x xor x = 0$.
3. *Pascal triangle method*: XOR adjacent truth-table entries repeatedly.

#remark[
  The Zhegalkin polynomial is the basis of linear and differential cryptanalysis.
  A cipher's Boolean function should have high *nonlinearity* --- its ANF should be far from linear.
  Functions with simple algebraic structure are vulnerable to algebraic attacks.
]

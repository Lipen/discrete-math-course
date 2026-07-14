// M01 --- Logic and Proofs: the fundamental language for reasoning about discrete objects.
#import "common-notes.typ": *
#import "notation.typ": *

= Logic and Proofs

#chapter-overview[
  Logic is the grammar of mathematical reasoning --- it formalises what it means for a statement to be true, false, or provable.
  This chapter introduces propositional logic, predicates and quantifiers, and the standard proof techniques used throughout the course.
  Mastery of these foundations is essential: every definition, theorem, and proof in later chapters relies on the language built here.
  The chapter closes with applications to program correctness, connecting the formal machinery to everyday coding practice.
]

== Propositional Logic

=== Propositions and Connectives

A _proposition_ (or _statement_) is a declarative sentence that is either true or false, but not both.
Questions, commands, and self-referential paradoxes are excluded --- only closed, unambiguous assertions qualify.

#definition[Proposition][
  A proposition is a declarative statement with a definite truth value: true (#Green([T])) or false (#Red([F])).
]

Compound propositions are built from atomic propositions using logical connectives.
The standard connectives, listed by decreasing binding strength, are:

#definition[Logical connectives][
  Let $p$ and $q$ be propositions.
  The basic connectives are:
  - *Negation* $not p$: "not $p$" --- true when $p$ is false.
  - *Conjunction* $p and q$: "$p$ and $q$" --- true when both are true.
  - *Disjunction* $p or q$: "$p$ or $q$" (inclusive) --- true when at least one is true.
  - *Implication* $p imply q$: "if $p$ then $q$" --- false only when $p$ is true and $q$ is false.
  - *Equivalence* $p iff q$: "$p$ if and only if $q$" --- true when $p$ and $q$ have the same truth value.
]

In an implication $p imply q$, $p$ is the _antecedent_ (hypothesis) and $q$ is the _consequent_ (conclusion).
The truth table for implication often surprises beginners: $F imply T$ is true.
Think of it as a broken promise: "If it rains, I will bring an umbrella" is only false if it rains and I do not bring one.

#note[
  Implication does not require causation.
  "$2 + 2 = 5$ $imply$ pigs can fly" is true (vacuously) because the antecedent is false.
]

The formal syntax of propositional logic is defined recursively:

#definition[Well-formed formula][
  - Every propositional variable (atom) is a well-formed formula (wff).
  - If $phi$ and $psi$ are wffs, then $(not phi)$, $(phi and psi)$, $(phi or psi)$, $(phi imply psi)$, and $(phi iff psi)$ are wffs.
  - Nothing else is a wff.
]

Precedence conventions reduce parentheses: $not$ binds tightest, then $and$, then $or$, then $imply$, then $iff$.
Every formula corresponds to a unique parse tree, which makes its syntactic structure explicit.

=== Semantics: Truth Tables

An _interpretation_ assigns a truth value (#Green([T]) or #Red([F])) to each atomic proposition.
Given $n$ atoms, there are $2^n$ distinct interpretations --- each row of a truth table corresponds to one interpretation.

#definition[Truth table][
  A truth table lists all interpretations of the atoms and computes the truth value of a compound formula under each interpretation.
]

#example[Truth table for $p imply q$][
  #table(
    columns: 3,
    align: center,
    stroke: (x, y) => if y == 0 { (bottom: 0.4pt) },
    table.header([$p$], [$q$], [$p imply q$]),
    [#Green([T])], [#Green([T])], [#Green([T])],
    [#Green([T])], [#Red([F])], [#Red([F])],
    [#Red([F])], [#Green([T])], [#Green([T])],
    [#Red([F])], [#Red([F])], [#Green([T])],
  )
]

#definition[Tautology, contradiction, satisfiability][
  - A _tautology_ is a formula true under every interpretation.
  - A _contradiction_ (or unsatisfiable formula) is a formula false under every interpretation.
  - A _satisfiable_ formula is true under at least one interpretation.
  - A _contingent_ formula is true under some interpretations and false under others --- neither a tautology nor a contradiction.
]

#example[
  $p or not p$ is a tautology (the law of excluded middle). $p and not p$ is a contradiction. $p and q$ is satisfiable but not a tautology.
]

Two formulas are logically equivalent if they have the same truth value under every interpretation:

#definition[Logical equivalence][
  $phi equiv psi$ iff $phi iff psi$ is a tautology.
  Equivalent formulas are interchangeable in any context (substitution preserves equivalence).
]

#definition[Logical consequence][
  $psi$ is a logical consequence of $phi_1, ..., phi_n$, written $phi_1, ..., phi_n models psi$, if every interpretation that makes all $phi_i$ true also makes $psi$ true.
]

#theorem[Deduction theorem for propositional logic][
  $phi_1, ..., phi_n models psi$ if and only if $(phi_1 and ... and phi_n) imply psi$ is a tautology.
]

#note[
  The deduction theorem bridges semantic entailment ($models$) and syntactic implication ($imply$).
  It is the foundation for proof by assumption: to prove $p imply q$, assume $p$ and derive $q$.
]

=== Laws and Identities

Propositional logic satisfies algebraic laws that enable simplification of formulas --- analogous to simplifying arithmetic expressions.

#proposition[Laws of propositional logic][
  For all propositions $p$, $q$, $r$:
  - *Commutativity*: $p and q equiv q and p$, $p or q equiv q or p$.
  - *Associativity*: $(p and q) and r equiv p and (q and r)$, $(p or q) or r equiv p or (q or r)$.
  - *Distributivity*: $p and (q or r) equiv (p and q) or (p and r)$, $p or (q and r) equiv (p or q) and (p or r)$.
  - *Idempotence*: $p and p equiv p$, $p or p equiv p$.
  - *Absorption*: $p and (p or q) equiv p$, $p or (p and q) equiv p$.
  - *Double negation*: $not not p equiv p$.
  - *Identity*: $p and T equiv p$, $p or F equiv p$.
  - *Domination*: $p or T equiv T$, $p and F equiv F$.
  - *Complement*: $p and not p equiv F$, $p or not p equiv T$.
]

#theorem[De Morgan's laws][
  - $not (p and q) equiv not p or not q$.
  - $not (p or q) equiv not p and not q$.
]

De Morgan's laws generalise: the negation of a conjunction is the disjunction of the negations, and vice versa.
They are verified by truth table, but the intuition is memorable: "it is not the case that both are true" means "at least one is false."

#remark[
  De Morgan's laws are used constantly in programming: $not (x > 0 and y < 10)$ becomes $x <= 0 or y >= 10$.
  Every programmer who negates a compound condition applies De Morgan --- often without realising it.
]

#theorem[Substitution principle][
  If $phi equiv psi$ and $chi$ is a formula containing $phi$ as a subformula, then replacing $phi$ by $psi$ in $chi$ yields a formula equivalent to $chi$.
]

The substitution principle means we can replace any subformula with an equivalent one without changing the overall meaning.
This is how we simplify boolean expressions in code --- factoring out common sub-expressions, eliminating redundant checks, and applying short-circuit evaluation rules.

=== Normal Forms

Every propositional formula can be rewritten into a canonical shape.
Normal forms are essential for automated reasoning: SAT solvers, circuit minimisation, and constraint satisfaction all operate on normalised formulas.

#definition[Disjunctive Normal Form (DNF)][
  A formula is in DNF if it is a disjunction of conjunctions of literals (atoms or their negations): $(l_(1,1) and ... and l_(1,k_1)) or ... or (l_(n,1) and ... and l_(n,k_n))$.
]

#definition[Conjunctive Normal Form (CNF)][
  A formula is in CNF if it is a conjunction of disjunctions of literals: $(l_(1,1) or ... or l_(1,k_1)) and ... and (l_(n,1) or ... or l_(n,k_n))$.
]

Every propositional formula has equivalent DNF and CNF representations, obtained algorithmically from the truth table:
- DNF: take rows where the formula is true; each row becomes a conjunction of literals.
- CNF: take rows where the formula is false; each row becomes a disjunction of negated literals; conjoin them.


== Predicates and Quantifiers

=== Predicates

Propositional logic is too coarse to express statements like "every natural number is either even or odd."
We need variables and quantifiers.

#definition[Predicate][
  A _predicate_ $P(x)$ is a statement that contains a variable $x$ and becomes a proposition when $x$ is replaced by a specific value from the domain of discourse.
]

The _domain_ (or _universe of discourse_) is the set of values a variable may take.
A predicate is a template --- a function from the domain to truth values.

#example[Predicate with domain $NN$][
  Let $P(x)$ be "$x > 5$" with domain $NN$.
  Then $P(7)$ is true, $P(3)$ is false.
]

Predicates may involve multiple variables: $P(x, y)$ is "$x < y$" with domain $RR$.
A predicate with $k$ variables defines a $k$-ary relation on the domain.

=== Quantifiers

Quantifiers turn predicates into propositions by specifying how many domain elements satisfy the predicate.

#definition[Universal quantifier][
  $forall x space P(x)$ asserts that $P(x)$ is true for _every_ $x$ in the domain.
  It is read "for all $x$, $P(x)$."
]

#definition[Existential quantifier][
  $exists x space P(x)$ asserts that $P(x)$ is true for _at least one_ $x$ in the domain.
  It is read "there exists $x$ such that $P(x)$."
]

#example[
  With domain $NN$: $forall x space x >= 0$ is true. $exists x space x < 0$ is false. $forall x exists y space y > x$ is true (the natural numbers are unbounded).
]

A variable is _bound_ if it is quantified; otherwise it is _free_.
The scope of a quantifier is the subformula to which it applies.

=== Negation of Quantifiers

#theorem[Quantifier negation][
  - $not forall x space P(x) equiv exists x space not P(x)$.
  - $not exists x space P(x) equiv forall x space not P(x)$.
]

The negation of "everyone likes pizza" is "there exists someone who does not like pizza."
The negation of "there exists a unicorn" is "everything is not a unicorn."

=== Multiple Quantifiers

When a formula contains more than one quantifier, order matters critically.

#example[
  Let $P(x, y)$ be "$y$ is the mother of $x$" with domain "people."
  - $forall x exists y space P(x, y)$: "Everyone has a mother" --- true.
  - $exists y forall x space P(x, y)$: "There is a person who is the mother of everyone" --- false.
]

The rule: $forall x exists y$ says "for each $x$, choose a $y$ (which may depend on $x$)." $exists y forall x$ says "there is a single $y$ that works for all $x$."

#remark[
  Quantifier order is the logical analogue of loop nesting. $forall x exists y$ is like a nested loop where the inner computation depends on the outer index. $exists y forall x$ is like precomputing a value that works for the whole iteration.
]

=== Bounded Quantifiers

In practice, most quantification is over a restricted set:

#definition[Bounded quantifier][
  - $forall x in A space P(x)$ abbreviates $forall x space (x in A imply P(x))$.
  - $exists x in A space P(x)$ abbreviates $exists x space (x in A and P(x))$.
]

Bounded quantifiers are ubiquitous in mathematics and CS: "every element of the array is non-negative" translates to $forall i in {0, ..., n-1} space A[i] >= 0$.

=== Translation to Predicate Logic

A key skill is translating between natural language and predicate logic.
The translation must preserve meaning precisely --- ambiguity in the English must be resolved.

#example[
  "All that glitters is not gold" is ambiguous.
  - Reading 1: $forall x space ("glitters"(x) imply not "gold"(x))$ --- "nothing that glitters is gold" (false).
  - Reading 2: $not forall x space ("glitters"(x) imply "gold"(x))$ --- "not everything that glitters is gold" (true).
]

#example[
  "The array is sorted" (ascending): $forall i in {0, ..., n-2} space A[i] <= A[i+1]$.
]

#example[
  The definition of a limit $lim_(x -> a) f(x) = L$: $forall epsilon > 0 space exists delta > 0 space forall x space (0 < abs(x - a) < delta imply abs(f(x) - L) < epsilon)$.
  This packs five quantifiers and two inequalities into one sentence --- the power of predicate logic.
]


== Proof Methods

A proof is a formal argument that establishes the truth of a statement from axioms, definitions, and previously proven statements.
This section surveys the standard proof strategies.

=== Direct Proof

The simplest strategy: to prove $P imply Q$, assume $P$ and derive $Q$ through a chain of logical deductions.

#proposition(inline: true)[Even squares][
  If $n$ is even, then $n^2$ is even.
]

#proof[
  By direct proof.
  Assume $n$ is even, so $n = 2k$ for some integer $k$.

  Squaring: $n^2 = (2k)^2 = 4k^2 = 2(2k^2)$.
  Since $2k^2$ is an integer, $n^2 = 2 dot "integer"$, so $n^2$ is even.
]

=== Proof by Contrapositive

The implication $P imply Q$ is logically equivalent to its contrapositive $not Q imply not P$.
Sometimes the contrapositive is easier to prove than the original.

#proposition(inline: true)[Odd squares][
  If $n^2$ is odd, then $n$ is odd.
]

#proof[
  We prove the contrapositive: if $n$ is even, then $n^2$ is even.
  (Every integer is either even or odd, so "not odd" means "even".)

  This is exactly Proposition 2.2.
  The contrapositive is equivalent to the original, so the statement holds.
]

The contrapositive is especially useful when the negation of the conclusion ($not Q$) gives a concrete starting point.

=== Proof by Contradiction

To prove $P$, assume $not P$ and derive a contradiction ($R and not R$ for some $R$).
Since contradictions are impossible, $not P$ must be false, so $P$ is true.

#theorem(inline: true)[
  $sqrt(2)$ is irrational.
]

#proof[
  By contradiction.
  Suppose $sqrt(2)$ is rational: $sqrt(2) = p slash q$ with $p, q in ZZ^+$ and $gcd(p, q) = 1$ (the fraction is reduced).

  Squaring gives $sqrt(2)^2 = 2 = p^2 slash q^2$, so $p^2 = 2q^2$.
  Hence $p^2$ is even, which forces $p$ to be even (odd squared is odd).
  Write $p = 2k$.

  Substitute:
  $
    (2k)^2 = 2q^2
    => 4k^2 = 2q^2
    => q^2 = 2k^2.
  $
  Thus $q^2$ is even, so $q$ is even.

  Both $p$ and $q$ are even, so $gcd(p, q) >= 2$, contradicting $gcd(p, q) = 1$.
  Therefore $sqrt(2)$ is irrational.
]

#note[
  Proof by contradiction and proof by contrapositive are often confused:

  - *Contrapositive* of $P imply Q$: assume $not Q$, derive $not P$, and stop. \ The structure follows a single logical equivalence --- clean and direct.

  - *Contradiction* of $P imply Q$: assume $P and not Q$ and derive any contradiction ($R and not R$). \ The contradiction can be unrelated to the original hypothesis --- the method is more flexible.

  The contrapositive is "cleaner" when applicable; contradiction is more general.
]

=== Proof by Case Analysis

If the hypothesis can be partitioned into a finite set of mutually exclusive and exhaustive cases, proving the conclusion in each case suffices.

#proposition[Multiplicativity of absolute value][
  For all real $x$, $y$: $|x y| = |x| dot |y|$.
]

#proof[
  The sign of $x y$ depends on the signs of $x$ and $y$.
  We partition into four mutually exclusive cases and verify the equality in each.

  + *Case 1:* $x >= 0$, $y >= 0$.
    Then $|x| = x$, $|y| = y$, $x y >= 0$, so $|x y| = x y = |x| dot |y|$.
  + *Case 2:* $x >= 0$, $y < 0$.
    Then $|x| = x$, $|y| = -y$, $x y <= 0$, so $|x y| = -x y = x(-y) = |x| dot |y|$.
  + *Case 3:* $x < 0$, $y >= 0$.
    Symmetric to case 2.
  + *Case 4:* $x < 0$, $y < 0$.
    Then $|x| = -x$, $|y| = -y$, $x y > 0$, so $|x y| = x y = (-x)(-y) = |x| dot |y|$.
  All cases yield the equality, so the identity holds for all real $x$, $y$.
]

=== Proof of Equivalence

To prove $P iff Q$, prove both directions: $P imply Q$ and $Q imply P$.
Alternatively, construct a chain of equivalences: $P iff R_1 iff ... iff Q$.

#example[
  To prove "$n$ is even iff $n^2$ is even":
  + ($arrow.double.r$): Proved above (direct proof).
  + ($arrow.double.l$): Proved above (contrapositive: $n$ odd $=>$ $n^2$ odd).
]

=== Counterexamples

To disprove a universal statement $forall x space P(x)$, a single counterexample suffices.

#example[
  *Claim:* "All primes are odd." *Counterexample:* $2$ is prime and even.
  The statement is false.
]

A counterexample is the logical analogue of a failing test case --- it takes one to break a universal claim.

=== Mathematical Induction

Induction proves statements of the form $forall n in NN space P(n)$.
It is the engine of reasoning about recursively defined objects.

#theorem[Principle of mathematical induction][
  To prove $forall n >= 0 space P(n)$:
  1. *Base case:* Prove $P(0)$.
  2. *Inductive step:* Prove $forall k >= 0 space (P(k) imply P(k+1))$.
  Conclude $forall n >= 0 space P(n)$.
]

#proof[
  By induction on $n$.

  *Base.* $n = 1$: LHS $= 1$, RHS $= (1 dot 2)/2 = 1$.

  *Induction hypothesis.*
  Assume $sum_(i=1)^k i = (k(k+1))/2$ for some $k >= 1$.

  *Inductive step.*
  $
    sum_(i=1)^(k+1) i
    = (sum_(i=1)^k i) + (k+1)
    = (k(k+1))/2 + (k+1)
    = ((k+1)(k+2))/2.
  $
  This is exactly $(n(n+1))/2$ with $n = k+1$.

  By induction, the formula holds for all $n >= 1$.
]

#theorem[Strong induction][
  To prove $forall n >= 0 space P(n)$:
  1. *Base case:* Prove $P(0)$.
  2. *Inductive step:* Prove $forall k >= 0 space ((forall i < k space P(i)) imply P(k))$.
  Conclude $forall n >= 0 space P(n)$.
]

Strong induction is needed when $P(k+1)$ depends on earlier values beyond just $P(k)$.

#proof[
  By strong induction on $n$.

  *Base.* $n = 2$ is prime.

  *Induction hypothesis.*
  Assume every $m$ with $2 <= m < k$ can be factored into primes.

  *Inductive step.*
  If $k$ is prime, we are done.
  If $k$ is composite, $k = a b$ with $2 <= a, b < k$.
  By the hypothesis, $a$ and $b$ each factor into primes.
  Multiplying gives a prime factorisation of $k$.

  By strong induction, every integer $n >= 2$ factors into primes.
]

#theorem[Well-ordering principle][
  Every non-empty subset of $NN$ has a least element.
]

The well-ordering principle is logically equivalent to mathematical induction.
One can be derived from the other.

#remark[
  Induction is the mathematical basis for reasoning about loops and recursion.
  The base case is the empty input / termination condition.
  The inductive step is the loop body: assuming correctness after $k$ iterations, prove correctness after $k+1$.
  Structural induction generalises this to trees, formulas, and programs --- central to compiler correctness and programming language theory.
]

=== Structural Induction

For recursively defined sets (formulas, trees, lists, abstract syntax), structural induction proves that a property holds for all elements by verifying it for base elements and for each construction rule.

#definition[Structural induction for formulas][
  To prove $P(phi)$ for all propositional formulas $phi$:
  1. *Base:* Prove $P(A)$ for every atomic formula $A$.
  2. *Inductive steps:* Prove that if $P(phi)$ and $P(psi)$ hold, then $P(not phi)$, $P(phi and psi)$, $P(phi or psi)$, $P(phi imply psi)$, and $P(phi iff psi)$ hold.
]

This template applies to any inductively defined structure --- abstract syntax trees, regular expressions, parse trees.
Structural induction will be used extensively in the automata and formal language chapters.

=== Common Fallacies

Beginners make predictable mistakes in proofs.
Recognising them early saves time and embarrassment.

#definition[Circular reasoning (begging the question)][
  Assuming what you are trying to prove, perhaps in disguised form.
  "God exists because the Bible says so, and the Bible is the word of God" --- the premise already assumes the conclusion.
]

#definition[Affirming the consequent][
  From $P imply Q$ and $Q$, concluding $P$.
  "If it rains, the ground is wet.
  The ground is wet.
  Therefore it rained" --- the ground could be wet from a sprinkler.
]

#definition[Denying the antecedent][
  From $P imply Q$ and $not P$, concluding $not Q$.
  "If it rains, the ground is wet.
  It didn't rain.
  Therefore the ground is not wet" --- again, a sprinkler suffices.
]

#definition[False induction base][
  Proving $P(k) imply P(k+1)$ but neglecting to verify the base case, or using a wrong base.
  Example: "All horses are the same colour" --- the inductive step works only for $k >= 2$, but the base case $k=1$ does not bridge to $k=2$.
  The flaw is subtle: going from 1 horse to 2 horses uses an empty overlap of the two groups.
]

A proof that contains a fallacy is not a proof.
Checking each step against definitions and known facts catches most errors.


== Applications to Program Correctness

Logic is not just a theoretical exercise --- it is the foundation for reasoning about programs.
This section introduces the logical view of software correctness.

=== Assertions and Hoare Triples

An _assertion_ is a logical formula placed in code that must be true at that point of execution.
Assertions document expectations and catch bugs at runtime.

#definition[Hoare triple][
  A Hoare triple ${P} S {Q}$ means: if the precondition $P$ holds before executing statement $S$, then the postcondition $Q$ holds after $S$ terminates.
]

#example[
  ${x = 5} " " x := x + 1 " " {x = 6}$ --- if $x$ is 5 before the assignment, then $x$ is 6 after.
]

The precondition encodes the assumptions about program state; the postcondition encodes the guarantees.
Together they form a contract: if the caller satisfies $P$, the procedure delivers $Q$.

=== Loop Invariants

A loop invariant is a predicate that is true before the first iteration, remains true after each iteration, and, together with the loop exit condition, implies the desired postcondition.

#definition[Loop invariant][
  For a loop $"while" B "do" S$, a predicate $I$ is an invariant if:
  1. ${I and B} S {I}$ --- $S$ preserves $I$.
  2. $I$ holds before the loop.
  3. $I and not B$ implies the postcondition.
]

#example[
  Consider linear search: find the index of $x$ in array $A[0..n-1]$, or return $-1$.
  ```
  i := 0
  while i < n and A[i] != x do
  i := i + 1
  ```
  *Invariant:* $forall j in {0, ..., i-1} space A[j] != x$ --- all positions before $i$ have been checked and do not contain $x$.
  At exit, either $i = n$ (not found) or $A[i] = x$ (found).
]

#remark[
  Loop invariants are the conceptual bridge between induction and programming.
  Proving that the invariant is preserved by the loop body is an inductive step.
  The base case is the invariant established before the first iteration.
  This is exactly how verification tools (Dafny, Why3, Frama-C) prove program correctness: the programmer writes the invariant, the tool checks the inductive argument automatically.
]

=== Counterexamples and Testing

A failing test is a counterexample to the claim "the program is correct on this input."
Testing can demonstrate the _presence_ of bugs, never their _absence_ --- exactly as a single counterexample disproves $forall$ but no number of examples proves it.

#note[
  The logical connection between testing and proof:
  - Testing = searching for a counterexample.
  - Proof = demonstrating that no counterexample exists.
  Both are essential.
  Testing finds the easy bugs; proofs find the deep ones.
]

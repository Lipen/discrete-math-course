#import "theme.typ": *
#show: slides.with(
  title: [Boolean Algebra],
  subtitle: "Discrete Math",
  date: "Fall 2025",
  authors: "Konstantin Chukharev",
  // dark: true,
)

#show heading.where(level: 1): none

#import "common-lec.typ": *

#let rel(x) = math.class("relation", x)
#let nrel(x) = rel(math.cancel(x))
#let nand = $overline(and)$
#let nor = $overline(or)$
#let Join = $or$
#let Meet = $and$
#let cross = $class("normal", times)$

#let kcell(i, b) = [
  #b
  #place(bottom + right, dx: 5pt - 2pt, dy: 5pt - 2pt)[
    #text(size: 0.6em, fill: gray)[#i]
  ]
]


= Boolean Algebra
#focus-slide(
  epigraph: [Мы почитаем всех нулями, \ А единицами --- себя.],
  epigraph-author: [А.С. Пушкин, «Евгений Онегин»],
  scholars: (
    (
      name: "Gottfried Wilhelm Leibniz",
      image: image("assets/Gottfried_Wilhelm_Leibniz.jpg"),
    ),
    (
      name: "George Boole",
      image: image("assets/George_Boole.jpg"),
    ),
    (
      name: "Augustus De Morgan",
      image: image("assets/Augustus_De_Morgan.jpg"),
    ),
    (
      name: "Charles Sanders Peirce",
      image: image("assets/Charles_Sanders_Peirce.jpg"),
    ),
    (
      name: "Claude Shannon",
      image: image("assets/Claude_Shannon.jpg"),
    ),
  ),
)

== From Algebra to Digital Circuits

// Boolean algebra is the mathematical foundation of digital computing, developed by George Boole in 1854 as a way to formalize logical reasoning using algebraic operations.

#Block(color: teal)[
  #set par(justify: true)
  *Historical note:* #h(0.2em)
  George Boole's groundbreaking work _The Laws of Thought_ (1854) created an algebraic system for logic a full century before the first electronic computers.
  He showed that logical reasoning could be captured by equations, replacing Aristotle's verbal arguments with mathematical symbols.
  This~insight became the theoretical foundation for the digital age.
]

#Block(color: yellow)[
  *Key idea:* Just as ordinary algebra works with numbers and operations like $+$ and $times$, Boolean algebra works with *truth values* ($0$ and $1$, or #False and #True) and operations like AND, OR, and NOT.
]

#columns(2)[
  *Historical milestones:*
  - *1703:* Leibniz describes binary arithmetic
  - *1854:* Boole publishes algebraic logic
  - *1937:* Shannon applies it to circuits
  - *1940s:* First digital computers

  #colbreak()

  *Modern applications:*
  - Processor design (CPUs, GPUs)
  - Formal verification (correctness proofs)
  - Database optimization (queries)
  - AI reasoning (SAT, planning)
]

== Boolean Values: 0 and 1

In Boolean algebra, we work with exactly two values:
- *0* (#False, off, low voltage)
- *1* (#True, on, high voltage)

#example[
  In different contexts:
  - *Mathematics:* "Is $x > 5$?" → #True (1) or #False (0)
  - *Programming:* `if (x && y)` → evaluates to `true` or `false`
  - *Circuits:* Wire voltage → high (1) or low (0)
  - *Sets:* Is element in set? → yes (1) or no (0)
]

#Block(color: blue)[
  *Why this matters:*
  Modern computers represent all information using binary (0s and 1s).

  Boolean algebra is the mathematics that makes digital computation possible.
]

== What You Will Learn

In this lecture, you'll master Boolean algebra from foundations to applications:

+ Build Boolean expressions and evaluate them using *truth tables*
+ Prove identities using the *fundamental laws* (commutativity, De Morgan's laws, distributivity)
+ *Synthesize any Boolean function* from specifications using CNF, DNF, and Karnaugh maps
+ *Simplify complex expressions* through algebraic manipulation and graphical methods
+ Determine which operation sets are *functionally complete* using Post's criterion
+ *Design real digital circuits* with logic gates, flip-flops, and stateful elements
+ Apply Boolean algebra to *modern CS problems*: binary decision diagrams, SAT solving, and formal verification

#Block(color: purple)[
  *Our goal:*
  You'll gain both theoretical understanding (algebraic structure, formal proofs) and practical skills (circuit design, expression minimization).
  By the end, you'll see how the same mathematical framework powers everything from smartphone processors to AI planning algorithms.
]


= Variables and Expressions
#focus-slide()

== The Language of Boolean Logic

Just like natural languages have words and grammar rules, Boolean algebra has its own building blocks and composition rules.

#columns(2)[
  *Natural Language:*
  - Words: "cat", "dog"
  - Connectors: "and", "or", "not"
  - Sentences: "Cat is black and dog is not white"

  #colbreak()

  *Boolean Algebra:*
  - Variables: $x$, $y$
  - Operations: $and$, $or$, $not$
  - Expressions: $x and not y$
]

#Block(color: blue)[
  *Goal:*
  Learn the "grammar" of Boolean logic --- how to write and read Boolean expressions that represent logical relationships.
]

== Boolean Variables: The Atoms

#definition[
  A _Boolean variable_ is a variable that can take only one of two values: $0$ (false) or $1$ (true).
]

Think of Boolean variables as yes/no questions:

#example[
  Real-world Boolean variables (in programming):
  - `is_logged_in` --- Is the user logged in? (yes/no)
  - `has_permission` --- Does user have permission? (yes/no)
  - `sensor_triggered` --- Did the sensor activate? (yes/no)
  - $x > 5$ --- Is $x$ greater than 5? (true/false)
]

#Block(color: yellow)[
  *Why binary?*
  Digital circuits use voltage levels (high/low), making binary the natural choice for computation.
  Every piece of data in your computer is ultimately represented as 0s and 1s.
]

== Boolean Operations: Connecting Ideas

We combine Boolean variables using operations (connectives) to express complex logic:

#definition[
  Basic Boolean operations:
  - *NOT* ($not x$ or $overline(x)$) --- _reverses_ the value
  - *AND* ($x and y$ or $x dot y$) --- true only if _both_ are true
  - *OR* ($x or y$ or $x + y$) --- true if _at least one_ is true
]

#example[
  Access control logic:
  - `is_admin OR has_permission` --- User needs admin status OR explicit permission
  - `is_logged_in AND NOT is_banned` --- User must be logged in AND not banned
  - `NOT (sensor1 AND sensor2)` --- Not both sensors triggered simultaneously
]

#Block(color: orange)[
  *Watch out:*
  "OR" in Boolean logic is _inclusive_ (can be both), unlike everyday speech where "coffee or tea" usually means "pick one."
]

== Derived Operations: Shortcuts

More complex operations built from basic ones:

#definition[
  Derived Boolean operations:
  - *XOR* ($x xor y$): true if _exactly one_ is true
    - Formula: $(x and not y) or (not x and y)$
    - Example: "Dessert or coffee" (pick one, not both)

  - *Implication* ($x imply y$): "if $x$ then $y$"
    - Formula: $not x or y$
    - Example: "If it rains, bring umbrella"

  - *Equivalence* ($x iff y$): true when values _match_
    - Formula: $(x imply y) and (y imply x)$
    - Example: "Light is on if and only if switch is up"
]

== Building Boolean Expressions

#definition[
  A _Boolean expression_ is built recursively from variables and operations:
  + Variables ($x, y, z$) and constants ($0, 1$) are expressions
  + If $f$ and $g$ are expressions, so are: $not f$, $f and g$, $f or g$, $f xor g$, $f imply g$, $f iff g$
]

#example[
  Progressive complexity:
  + $x$ --- atomic variable
  + $not x$ --- negation
  + $x and y$ --- two variables connected
  + $(x and y) or z$ --- nested expression
  + $not (x or (y and z))$ --- deeply nested
  + $(x imply y) and (y imply z)$ --- transitivity pattern
]

#Block(color: yellow)[
  *Key idea:*
  Operations work on _any_ expressions, not just variables.
  This compositionality lets us build arbitrarily complex formulas.
]

== Truth Tables

#definition[
  A _truth table_ is a complete list of all possible input combinations for a Boolean expression and their corresponding output values.
]

#note[
  For $n$ Boolean variables, there are $2^n$ possible input combinations.
]

#example[
  Truth table for AND operation ($x and y$):

  #align(center)[
    #table(
      columns: 3,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
      table.header([*$x$*], [*$y$*], [*$x and y$*]),
      [0], [0], [0],
      [0], [1], [0],
      [1], [0], [0],
      [1], [1], [1],
    )
  ]
]

== Truth Tables for Compound Expressions

We can build truth tables for complex expressions step by step.

#example[
  Truth table for $(x and y) or (not x and z)$:

  // TODO: replace intermediate columns for sub-formulas with a single multi-column expression
  #align(center)[
    #table(
      columns: 6,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
      inset: (x, y) => if y == 0 { 5pt } else { 3pt },
      table.header([*$x$*], [*$y$*], [*$z$*], [*$x and y$*], [*$not x and z$*], [*$(x and y) or (not x and z)$*]),
      [0], [0], [0], [0], [0], [0],
      [0], [0], [1], [0], [1], [1],
      [0], [1], [0], [0], [0], [0],
      [0], [1], [1], [0], [1], [1],
      table.hline(stroke: 0.4pt + gray),
      [1], [0], [0], [0], [0], [0],
      [1], [0], [1], [0], [0], [0],
      [1], [1], [0], [1], [0], [1],
      [1], [1], [1], [1], [0], [1],
      table.hline(stroke: 0.4pt + gray),
    )
  ]
]

#Block(color: blue)[
  *Method:* Build intermediate columns for subexpressions, then combine them for the final result.
]

== Tautologies, Contradictions, Contingencies

#definition[
  - A _tautology_ is a Boolean expression that is always true (all 1s in output column)
  - A _contradiction_ is a Boolean expression that is always false (all 0s in output column)
  - A _contingency_ is a Boolean expression that is sometimes true and sometimes false
]

#example[
  - *Tautology:* $x or not x$ (law of excluded middle)
  - *Contradiction:* $x and not x$ (law of non-contradiction)
  - *Contingency:* $x and y$ (depends on values of $x$ and $y$)
]

#Block(color: orange)[
  *Warning:* In Boolean algebra, we typically care about expressions that are contingencies---those that represent actual functions. Tautologies and contradictions are constant functions.
]

== Logical Equivalence

#definition[
  Two Boolean expressions $f$ and $g$ are _logically equivalent_ (written $f equiv g$) if they have identical truth tables---they produce the same output for every possible input combination.
]

#example[
  Show that $not (x and y) equiv not x or not y$ (De Morgan's law):

  #align(center)[
    #table(
      columns: 5,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
      inset: (x, y) => if y == 0 { 5pt } else { 3pt },
      table.header([*$x$*], [*$y$*], [*$not (x and y)$*], [*$not x or not y$*], [*Equal?*]),
      [0], [0], [1], [1], [#YES],
      [0], [1], [1], [1], [#YES],
      [1], [0], [1], [1], [#YES],
      [1], [1], [0], [0], [#YES],
    )
  ]

  Since all rows match, $not (x and y) equiv not x or not y$.
  #h(1fr) $qed$
]

== Evaluating Boolean Expressions

Given values for all variables, we can evaluate any Boolean expression.

#example[
  Evaluate $f(x, y, z) = (x or y) and (not x or z)$ when $x = 1, y = 0, z = 1$:

  $
    f(1, 0, 1) & = (1 or 0) and (not 1 or 1) \
               & = 1 and (0 or 1) \
               & = 1 and 1 \
               & = 1
  $
]

#Block(color: yellow)[
  *Practice skill:* Being able to quickly evaluate Boolean expressions is essential for debugging circuits and verifying logical designs.
]

== Simplifying Boolean Expressions

Simple algebraic manipulation can simplify expressions:

#example[
  Simplify $f(x, y) = (x and y) or (x and not y)$:

  $
    f(x, y) & = (x and y) or (x and not y) \
            & = x and (y or not y)         && "(distributivity)" \
            & = x and 1                    && "(excluded middle)" \
            & = x                          && "(identity)"
  $
]

#example[
  Simplify $g(x, y, z) = (x or y) and (x or not y)$:

  $
    g(x, y, z) & = (x or y) and (x or not y) \
               & = x or (y and not y)        && "(distributivity)" \
               & = x or 0                    && "(contradiction)" \
               & = x                         && "(identity)"
  $
]


= Boolean Algebra Structure
#focus-slide()

== From Expressions to Algebraic Structure

We have seen Boolean expressions as formulas.
Now we study their _algebraic structure_: the operations and laws that govern how they behave.

#Block(color: blue)[
  *Why formalize?*
  Just as group theory abstracts the common structure of numbers, symmetries, and transformations, Boolean algebra abstracts the structure of logic, sets, and circuits.
]

#columns(2)[
  *What we already have:*
  - Variables and constants
  - Operations: $not$, $and$, $or$
  - Expressions
  - Truth tables

  #colbreak()

  *What we'll add:*
  - Formal axioms
  - Fundamental laws
  - Proof techniques
  - Connection to lattices
]

== Boolean Algebra: Formal Definition

#definition[
  A _Boolean algebra_ is a set $B$ with:
  - Two binary operations: $or$ (join) and $and$ (meet)
  - One unary operation: $not$ (complement)
  - Two special elements: $0$ (bottom) and $1$ (top)

  satisfying the axioms on the next slide.
]

#example[
  The two-element Boolean algebra ${0, 1}$ with:
  - $0 or 0 = 0$, $0 or 1 = 1$, $1 or 0 = 1$, $1 or 1 = 1$
  - $0 and 0 = 0$, $0 and 1 = 0$, $1 and 0 = 0$, $1 and 1 = 1$
  - $not 0 = 1$, $not 1 = 0$
]

== Boolean Algebra Axioms


#definition[Axioms of Boolean Algebra][
  For all $x, y, z in B$:
  + *Commutativity:* $x or y = y or x$ and $x and y = y and x$
  + *Associativity:* $(x or y) or z = x or (y or z)$ and $(x and y) and z = x and (y and z)$
  + *Distributivity:* $x and (y or z) = (x and y) or (x and z)$ and $x or (y and z) = (x or y) and (x or z)$
  + *Identity:* $x or 0 = x$ and $x and 1 = x$
  + *Complement:* $x or not x = 1$ and $x and not x = 0$
]

#note[
  Both $and$ and $or$ distribute over each other --- this is special to Boolean algebra (unlike ordinary arithmetic where only $times$ distributes over $+$).
]

== Examples of Boolean Algebras

#example[Power Set][
  For any set $A$, $(power(A), union, intersect, not, emptyset, A)$ is a Boolean algebra:
  - Join: $union$ (union)
  - Meet: $intersect$ (intersection)
  - Complement: $X^c = A setminus X$
  - Bottom: $emptyset$, Top: $A$
]

#example[Binary Strings][
  For $n$-bit binary strings with bitwise operations:
  - Join: bitwise OR
  - Meet: bitwise AND
  - Complement: bitwise NOT
  - Bottom: $000...0$, Top: $111...1$
]

#Block(color: yellow)[
  *Key insight:* The same algebraic structure appears in logic, set theory, circuits, and more.
]

== Fundamental Laws (Derived Properties)

From the axioms, we can prove many useful identities:

#theorem[Basic Laws][
  For all $x, y in B$:
  + *Idempotence:* $x or x = x$ and $x and x = x$
  + *Absorption:* $x or (x and y) = x$ and $x and (x or y) = x$
  + *Null (Domination):* $x or 1 = 1$ and $x and 0 = 0$
  + *Double Negation:* $not not x = x$
  + *Complement of Constants:* $not 0 = 1$ and $not 1 = 0$
]

#note[
  These can all be proven from the axioms using algebraic manipulation.
]

== Proving Identities: Idempotence

#theorem[
  $x or x = x$ for all $x$ in a Boolean algebra.
]

#proof[
  $
    x or x & = (x or x) and 1            && "(identity)" \
           & = (x or x) and (x or not x) && "(complement)" \
           & = x or (x and not x)        && "(distributivity)" \
           & = x or 0                    && "(complement)" \
           & = x                         && "(identity)"
  $
]

#Block(color: blue)[
  *Method:* Use axioms strategically --- introduce $1$ or $0$, apply distributivity, then simplify.
]

== Proving Identities: Absorption

#theorem[
  $x or (x and y) = x$ for all $x, y$ in a Boolean algebra.
]

#proof[
  $
    x or (x and y) & = (x and 1) or (x and y) && "(identity)" \
                   & = x and (1 or y)         && "(distributivity)" \
                   & = x and 1                && "(null law)" \
                   & = x                      && "(identity)"
  $
]

#example[
  Similarly, $x and (x or y) = x$ by dual reasoning.
]

== The Duality Principle

#theorem[Duality Principle][
  If an identity holds in any Boolean algebra, then the _dual_ identity (obtained by swapping $or arrow.l.r and$ and $0 arrow.l.r 1$) also holds.
]

#example[
  - Identity law: $x or 0 = x$, and its dual: $x and 1 = x$
  - Absorption: $x or (x and y) = x$, and its dual: $x and (x or y) = x$
  - De Morgan: $not (x or y) = not x and not y$, and its dual: $not (x and y) = not x or not y$
]

#Block(color: yellow)[
  *Power of duality:* Every theorem you prove gives you _two_ theorems for free!
]

== De Morgan's Laws

#theorem[De Morgan's Laws][
  For all $x, y$ in a Boolean algebra:
  - $not (x or y) = not x and not y$
  - $not (x and y) = not x or not y$
]

#proof[
  We prove $not (x or y) = not x and not y$ by showing that $not x and not y$ is the complement of $x or y$.

  Need to verify:
  + $(x or y) or (not x and not y) = 1$
  + $(x or y) and (not x and not y) = 0$

  (Full proof left as exercise --- use distributivity and complement laws.)
]

#Block(color: orange)[
  *Common application:* Negating complex conditions: `NOT (is_admin OR has_permission)` becomes `NOT is_admin AND NOT has_permission`.
]

== Connection to Lattices

#definition[
  A _lattice_ is a partially ordered set where any two elements $x, y$ have:
  - A _least upper bound_ (join): $x or y$
  - A _greatest lower bound_ (meet): $x and y$
]

#definition[
  A _bounded distributive lattice_ is a lattice with bottom $bot$, top $top$, and distributivity:
  $
    x and (y or z) = (x and y) or (x and z)
  $
]

#definition[
  A _complemented lattice_ is a bounded lattice where every element $x$ has a complement $y$ such that $x or y = top$ and $x and y = bot$.
]

#theorem[
  Every Boolean algebra is a complemented bounded distributive lattice.
]

// #Block(color: blue)[
//   *Why this matters:* Lattice theory provides the geometric intuition (Hasse diagrams, ordering) for Boolean algebra's algebraic structure.
// ]

== Complement Uniqueness

#theorem[
  In a Boolean algebra, each element has a _unique_ complement.
]

#proof[
  Suppose $y$ and $z$ are both complements of $x$. Then:
  $
    y & = y and 1                && "(identity)" \
      & = y and (x or z)         && "(" z "is complement of" x ")" \
      & = (y and x) or (y and z) && "(distributivity)" \
      & = 0 or (y and z)         && "(" y "is complement of" x ")" \
      & = (x and z) or (y and z) && "(" z "is complement of" x ")" \
      & = (x or y) and z         && "(distributivity)" \
      & = 1 and z                && "(" y "is complement of" x ")" \
      & = z                      && "(identity)"
  $

  Therefore $y = z$.
]

== Summary of Boolean Algebra Structure

#Block(color: purple)[
  *What we've established:*

  + Boolean algebra is an algebraic structure with operations $or$, $and$, $not$ and elements $0$, $1$
  + Five fundamental axioms govern the structure
  + Many useful laws (idempotence, absorption, De Morgan's) follow from the axioms
  + Duality principle: swap $or arrow.l.r and$ and $0 arrow.l.r 1$ to get new theorems
  + Boolean algebras are complemented bounded distributive lattices
  + Complements are unique
]

#Block(color: yellow)[
  *Next:* #h(0.2em)
  We'll use this algebraic structure to develop normal forms and minimization techniques.
]


= Normal Forms
#focus-slide()

== From Structure to Representation

We've established the algebraic structure of Boolean algebra.

Now: how do we _represent_ any Boolean function systematically?

#Block(color: blue)[
  *Goal:*
  Find standard forms that can express _any_ Boolean function.
  This lets us:
  + Synthesize circuits from specifications (truth tables)
  + Compare functions for equivalence
  + Systematically simplify expressions
]

#columns(2)[
  *What we have:*
  - Boolean algebra axioms
  - Proof techniques
  - Specific functions

  #colbreak()

  *What we need:*
  - Standard representations
  - Construction algorithms
  - Completeness guarantees
]

== Building Blocks: Literals

#definition[
  A _literal_ is either a Boolean variable or its negation.
]

Think of literals as the simplest meaningful statements:

#example[
  For variables $x$, $y$, $z$:
  - *Positive literals:* $x$, $y$, $z$ --- "is true"
  - *Negative literals:* $not x$, $not y$, $not z$ --- "is false"
]

#example[Real-world interpretation][
  - $x$ might mean "user is logged in"
  - $not x$ means "user is NOT logged in"
  - The expression $(x and not y) or z$ combines three literals: $x$, $not y$, and $z$
]

#Block(color: yellow)[
  *Key idea:*
  Literals are the atoms of Boolean logic.
  Every complex expression is ultimately built from these simple building blocks using $and$ and $or$.
]

== Terms and Clauses

#definition[
  - A _term_ (or _product_) is a conjunction (AND) of literals
  - A _clause_ (or _sum_) is a disjunction (OR) of literals
]

#columns(2)[
  *Terms (Products):*
  - $x and y$
  - $x and not y and z$
  - $not x and not y and not z$

  "ALL of these must be true"

  #colbreak()

  *Clauses (Sums):*
  - $x or y$
  - $x or not y or z$
  - $not x or not y or not z$

  "At least ONE must be true"
]

#example[
  - Term $x and not y and z$ is true only when: $x = 1$, $y = 0$, $z = 1$
  - Clause $x or not y or z$ is true when: $x = 1$ OR $y = 0$ OR $z = 1$ (or any combination)
]

#note[
  A single literal is both a 1-term and a 1-clause. Constants: $0$ (empty term) and $1$ (empty clause).
]

== Disjunctive Normal Form (DNF)

#definition[DNF][
  A Boolean formula is in _Disjunctive Normal Form (DNF)_ if it is a disjunction (OR) of terms.

  General form: $(t_1) or (t_2) or dots or (t_k)$ where each $t_i$ is a term (conjunction of literals).
]

#example[
  DNF formulas:
  - $(x and y) or (not x and z)$ --- "($x$ and $y$) OR ($not x$ and $z$)"
  - $(x and not y and z) or (not x and y) or z$ --- three alternatives
  - $x or (y and not z)$ --- still DNF (mixed form)
]

#example[
  *NOT* in DNF:
  - $(x or y) and z$ --- this is CNF (AND of ORs)
  - $x and (y or z)$ --- OR nested inside AND violates DNF structure
]

#Block(color: yellow)[
  *Intuition:*
  DNF says "the output is 1 if ANY of these scenarios happen," where each scenario is a specific combination of variable values.
]

== Conjunctive Normal Form (CNF)

#definition[CNF][
  A Boolean formula is in _Conjunctive Normal Form (CNF)_ if it is a conjunction (AND) of clauses.

  General form: $(c_1) and (c_2) and dots and (c_k)$ where each $c_i$ is a clause (disjunction of literals).
]

#example[
  CNF formulas:
  - $(x or y) and (not x or z)$ --- both constraints must hold
  - $(x or not y or z) and (not x or y) and z$ --- three constraints
  - $x and (y or not z)$ --- still CNF (mixed form)
]

#example[
  *NOT* in CNF:
  - $(x and y) or z$ --- this is DNF (OR of ANDs)
  - $x or (y and z)$ --- AND nested inside OR violates CNF structure
]

== CNF vs DNF

#Block(color: yellow)[
  *Intuition:*
  CNF says "ALL of these constraints must be satisfied," where each constraint offers multiple ways to be true.

  DNF says "the output is 1 if ANY of these scenarios happen," where each scenario is a specific combination of variable values.
]

#Block(color: blue)[
  *Duality:*
  DNF and CNF are _dual_ forms.
  Swap $and$ and $or$ to convert between them.
]

== Minterms and Maxterms

#definition[
  For $n$ variables:
  - A _minterm_ is a term containing all $n$ variables (each exactly once, positive or negated)
  - A _maxterm_ is a clause containing all $n$ variables (each exactly once, positive or negated)
]

#example[
  For variables $x$, $y$, $z$:
  - *Minterms:* $(x and y and z)$, $(x and y and not z)$, $(x and not y and z)$, ...
  - *Maxterms:* $(x or y or z)$, $(x or y or not z)$, $(x or not y or z)$, ...

  There are exactly $2^n = 2^3 = 8$ minterms and $8$ maxterms for $3$ variables.
]

#Block(color: blue)[
  *Key property:*
  - Each minterm is 1 for *exactly ONE* input combination
  - Each maxterm is 0 for *exactly ONE* input combination
  - This makes them perfect building blocks for representing any function!
]

== Minterm and Maxterm Indexing

We can index minterms and maxterms by their binary representations:

#example[
  For $x, y, z$ (interpreting as bits: $x y z$):

  #align(center)[
    #table(
      columns: 4,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
      table.header([*Index*], [*Binary*], [*Minterm $m_i$*], [*Maxterm $M_i$*]),
      [0], [000], [$not x and not y and not z$], [$x or y or z$],
      [1], [001], [$not x and not y and z$], [$x or y or not z$],
      [2], [010], [$not x and y and not z$], [$x or not y or z$],
      [3], [011], [$not x and y and z$], [$x or not y or not z$],
      [4], [100], [$x and not y and not z$], [$not x or y or z$],
      [5], [101], [$x and not y and z$], [$not x or y or not z$],
      [6], [110], [$x and y and not z$], [$not x or not y or z$],
      [7], [111], [$x and y and z$], [$not x or not y or not z$],
    )
  ]
]

== Sum of Products (SoP)

#definition[
  A _sum of products (SoP)_ (also called _canonical sum of minterms_) is a DNF where each term is a minterm.

  General form: $f(x_1, dots, x_n) = limits(or.big)_(i in I) m_i$ where $I subset.eq {0, 1, dots, 2^n - 1}$
]

#example[
  For the function with truth table:

  #align(center)[
    #table(
      columns: 4,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
      inset: (x, y) => if y == 0 { 5pt } else { 3pt },
      table.header([*$x$*], [*$y$*], [*$z$*], [*$f$*]),
      [0], [0], [0], [0],
      [0], [0], [1], [*1*],
      [0], [1], [0], [0],
      [0], [1], [1], [*1*],
      [1], [0], [0], [0],
      [1], [0], [1], [0],
      [1], [1], [0], [*1*],
      [1], [1], [1], [*1*],
    )
  ]

  *Algorithm:* Pick rows where $f = 1$ (rows 1, 3, 6, 7):
  $
    f & = m_1 or m_3 or m_6 or m_7 \
      & = (not x and not y and z) or (not x and y and z) or (x and y and not z) or (x and y and z)
  $
]

#Block(color: yellow)[
  *Recipe:*
  To build SoP, take each 1 in the truth table and OR the corresponding minterms.
]

== Product of Sums (PoS)

#definition[
  A _product of sums (PoS)_ (also called _canonical product of maxterms_) is a CNF where each clause is a maxterm.

  General form: $f(x_1, dots, x_n) = limits(and.big)_(i in I) M_i$ where $I subset.eq {0, 1, dots, 2^n - 1}$
]

#example[
  For the *same function*, use rows where $f = 0$ (rows 0, 2, 4, 5):
  $
    f & = M_0 and M_2 and M_4 and M_5 \
      & = (x or y or z) and (x or not y or z) and (not x or y or z) and (not x or y or not z)
  $
]

#grid(
  columns: (auto, 1fr),
  column-gutter: 1em,
  Block(color: blue)[
    *Two approaches:*
    - SoP uses 1s in truth table (where function is true)
    - PoS uses 0s in truth table (where function is false)
    - Both represent the same function!
  ],
  Block(color: orange)[
    *Why PoS?*
    Sometimes PoS is more compact than SoP (when function has fewer 0s than 1s).
  ],
)

== Completeness of Normal Forms

#theorem[
  Every Boolean function can be represented in both CNF and DNF.
]

#proof[Sketch for DNF (SoP)][
  Given a truth table:
  + For each row where output is 1, create the corresponding minterm
  + OR all these minterms together
  + The result is the function in DNF (SoP form)

  *Why this works:*
  - Each minterm is 1 for exactly one input combination
  - ORing them gives 1 exactly when the function should be 1
  - This construction is always possible and always correct
]

#Block(color: yellow)[
  *Power of synthesis:*
  Any Boolean function can be built from its truth table!
]

== Shannon Expansion

#theorem[Shannon Expansion][
  For any Boolean function $f$ and variable $x$:
  $
    f(x, y_1, dots, y_n) = (not x and f(0, y_1, dots, y_n)) or (x and f(1, y_1, dots, y_n))
  $

  $
    f(x, y_1, dots, y_n) = (x or f(0, y_1, dots, y_n)) and (not x or f(1, y_1, dots, y_n))
  $
]

#example[
  Expand $f(x, y) = x xor y$ by $x$:
  $
    f(x, y) & = (not x and f(0, y)) or (x and f(1, y)) \
            & = (not x and (0 xor y)) or (x and (1 xor y)) \
            & = (not x and y) or (x and not y)
  $

  This gives us the standard XOR representation!
]

// #Block(color: blue)[
//   *Application:* Shannon expansion is the theoretical foundation for:
//   - Binary Decision Diagrams (BDDs) in verification
//   - Recursive circuit design and decomposition
//   - Divide-and-conquer algorithms for Boolean functions
// ]

== Converting Between Forms

Converting between DNF and CNF can be tricky:

#example[DNF to CNF using De Morgan's laws][
  Start with DNF: $(x and y) or (not x and z)$

  *Step-by-step:*
  + Negate: $not ((x and y) or (not x and z))$
  + Apply De Morgan: $(not (x and y)) and (not (not x and z))$
  + Apply De Morgan again: $(not x or not y) and (x or not z)$
  + Double negate to get back: $not not ((not x or not y) and (x or not z))$

  Result is CNF: $(not x or not y) and (x or not z)$
]

#Block(color: orange)[
  *Warning:*
  Direct algebraic conversion can cause exponential blowup in formula size!
  For complex functions, use Karnaugh maps or other minimization techniques.
]

#Block(color: yellow)[
  *Alternative:*
  Build CNF/DNF directly from truth table using the SoP/PoS methods.
]

== Summary: Canonical Forms

#Block(color: purple)[
  *What we've learned:*

  + Literals, terms, clauses are the building blocks
  + DNF: OR of terms (conditions that make function true)
  + CNF: AND of clauses (constraints that must all hold)
  + Minterms/maxterms: complete terms/clauses with all variables
  + SoP/PoS: canonical forms using minterms/maxterms
  + Shannon expansion: recursive decomposition by variables
  + Every Boolean function has CNF and DNF representations
]

#Block(color: yellow)[
  *Next:* #h(0.2em)
  Minimization techniques to reduce the size of these expressions (K-Maps, Quine-McCluskey).
]


= Minimization
#focus-slide()

// TODO: use "overline" instead of "not" (not *everywhere*, but generally...), since it is easier to read. That way, "and" could be omitted, and "or" could be replaced by "+".

== The Minimization Problem

We can synthesize any Boolean function from its truth table using SoP or PoS.

But the result is often *not minimal*.

#example[
  Consider $f(x, y, z) = (not x and not y and z) or (not x and y and z) or (x and y and not z) or (x and y and z)$

  This CDNF has 4 terms with 3 literals each (12 literals total).

  But we can simplify: $f = (not x and z) or (x and y)$ (only 4 literals!)
]

#grid(
  columns: 2,
  column-gutter: 1em,

  Block(color: blue)[
    *Why minimize?*
    - Fewer gates $=>$ cheaper circuits
    - Less power consumption
    - Higher speed (fewer gate delays)
    - Easier to understand and verify
  ],

  Block(color: orange)[
    *The challenge:*

    Finding the minimal form is computationally hard (#box[NP-complete] in general).

    We need practical techniques!
  ],
)

== What Does "Minimal" Mean?

#Block(color: green)[
  Different minimization criteria (goals) exist:
  - *Minimum literals:* Fewest total literal occurrences
  - *Minimum terms:* Fewest product terms (DNF) or clauses (CNF)
  - *Minimum gates:* Fewest logic gates in circuit
  - *Minimum levels:* Shortest signal propagation path (depth)
]

#example[
  Function: $f = A B + A C + B C$

  - Has 6 literals, 3 terms
  - Can be reduced to: $f = A B + A C$ (using consensus theorem)
  - Now 4 literals, 2 terms
]

#Block(color: yellow)[
  *Usually*, we minimize the number of literals (most common criterion).
]

== Gray Code: Foundation of K-Maps

#definition[
  A _Gray code_ is a binary encoding where consecutive values differ in exactly one bit.
]

#example[
  3-bit Gray code sequence:

  #align(center)[
    #table(
      columns: 4,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
      inset: (x, y) => if y == 0 { 5pt } else { 3pt },
      table.header([*Decimal*], [*Binary*], [*Gray Code*], [*Change*]),
      [0], [000], [000], [---],
      [1], [001], [001], [bit 0],
      [2], [010], [011], [bit 1],
      [3], [011], [010], [bit 0],
      [4], [100], [110], [bit 2],
      [5], [101], [111], [bit 0],
      [6], [110], [101], [bit 1],
      [7], [111], [100], [bit 0],
    )
  ]

  #note[
    Here, bit 0 is LSB, bit 2 is MSB.
  ]
]

// #Block(color: yellow)[
//   *Why Gray code?*
//   Adjacent cells in a K-map differ by one variable, making groupings correspond to algebraic simplifications.
// ]

== Converting Binary and Gray Code

#Block(color: green)[
  *Binary to Gray*:
  - Keep MSB (most significant bit)
  - Each next bit: XOR current binary bit with previous binary bit

  *Gray to Binary*:
  - Keep MSB
  - Each next bit: XOR current Gray bit with previous binary bit
]

#example[
  Binary $#`1011` _2$ $to$ Gray:
  - Bit 3: $1$ (keep MSB)
  - Bit 2: $1 xor 0 = 1$
  - Bit 1: $0 xor 1 = 1$
  - Bit 0: $1 xor 1 = 0$
  - *Result:* $#`1110` _"Gray"$
]

== Introduction to Karnaugh Maps

#definition[
  A _Karnaugh map (K-map)_ is a 2D grid representation of a truth table, arranged using Gray code so that adjacent cells differ in exactly one variable.
]

#Block(color: yellow)[
  *Key insight:*
  K-maps visualize the algebraic identity: $(x and y) or (x and not y) = x$

  Adjacent 1s in the map represent terms that can be combined!
]

#columns(2)[
  *Advantages:*
  - Visual and intuitive
  - Fast for small functions
  - Shows all simplifications
  - No complex computation

  #colbreak()

  *Limitations:*
  - Practical only for $<=$ 5-6 variables
  - Doesn't scale to large functions
  - Requires manual grouping skill
  - Can miss some patterns in 6+ vars
]

// TODO: mention that K-map produces minimal DNF. It could also be used for min-CNF, if we analyze 0s instead of 1s.
//
// #Block[
//   K-maps produce minimal *DNF* by grouping 1s. \
//   For minimal *CNF*, group 0s instead and apply De Morgan's laws.
// ]

== 2-Variable K-Map: Step by Step

#example[
  Build K-map for $f(x, y) = x or y$.

  *Step 1:* Create 2×2 grid and fill in the truth values

  #place(right, dx: -3cm)[
    #k-mapper.karnaugh(
      4,
      y-label: $x$,
      x-label: $y$,
      manual-terms: (
        kcell(0, 0),
        kcell(1, 1),
        kcell(2, 1),
        kcell(3, 1),
      ),
      implicants: ((1, 3), (2, 3)),
    )
  ]

  *Step 2:* Group adjacent 1s
  - Horizontal pair (bottom row): $x = 1$ $->$ gives term $x$
  - Vertical pair (right column): $y = 1$ $->$ gives term $y$

  *Result:* $f = x or y$
]

== 3-Variable K-Map Structure

For 3 variables, we use a 4×2 grid (two variables for rows, one for columns):

#align(center)[
  #k-mapper.karnaugh(
    8,
    y-label: $x y$,
    x-label: $z$,
    manual-terms: (0, 1, 2, 3, 4, 5, 6, 7),
  )
]

#note[
  Row order: 00, 01, *11*, 10 (Gray code, NOT binary!)

  This ensures top-bottom adjacency and wrap-around (torus structure).
]

#Block(color: yellow)[
  *Remember:* The map wraps around --- top and bottom rows are adjacent!
]

== 3-Variable K-Map: Complete Example

#example[
  Minimize $f(x, y, z) = sum m(1, 3, 6, 7)$:

  *Step 1:* Draw 4×2 grid and fill in the truth values

  #place(right, dx: -5cm)[
    #k-mapper.karnaugh(
      8,
      y-label: $x y$,
      x-label: $z$,
      manual-terms: (
        kcell(0, 0),
        kcell(1, 1),
        kcell(2, 0),
        kcell(3, 1),
        kcell(4, 0),
        kcell(5, 0),
        kcell(6, 1),
        kcell(7, 1),
      ),
      implicants: ((1, 3), (6, 7)),
    )
  ]

  *Step 2:* Identify groupings

  - #Red[Red group]:
    - Variables: $x = 0$, $z = 1$, $y$ varies
    - Term: $not x and z$

  - #Green[Green group]:
    - Variables: $x = 1$, $y = 1$, $z$ varies
    - Term: $x and y$

  *Step 3:* Write minimal DNF

  $f = (not x and z) or (x and y) = overline(x) z + x y$
]

== How K-Map Grouping Works

#Block(color: blue)[
  *Grouping principles:*
  - Variables that _change_ within the group are eliminated
  - Variables that stay _constant_ remain in the term
  - Larger groups $=>$ more variables eliminated $=>$ simpler terms
]

#example[
  Group of 2 cells in 3-var K-map:

  #align(center)[
    #table(
      columns: 3,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
      table.header([*Cell*], [*$x y z$*], [*Analysis*]),
      [$m_1$], [001], [$x=0$, $y=0$, $z=1$],
      [$m_3$], [011], [$x=0$, $y=1$, $z=1$],
      [], [], [$x=0$, $z=1$, $y$ varies],
    )
  ]

  *Result:* $not x and z$ ~ ($y$ eliminated)
]

== 4-Variable K-Map Structure

For 4 variables, use a 4×4 grid with Gray code on both axes:

#align(center)[
  #k-mapper.karnaugh(
    16,
    y-label: $A B$,
    x-label: $C D$,
    manual-terms: (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15),
  )
]

#Block(color: orange)[
  *Important:*
  Both rows and columns wrap around!
  Treat the map as a _torus_:
  - Top $<==>$ Bottom are adjacent
  - Left $<==>$ Right are adjacent
  - Even corners can be grouped!
]

== 4-Variable K-Map: Complete Example

#example[
  #v(-1em)
  #align(center)[
    #k-mapper.karnaugh(
      16,
      x-label: $C D$,
      y-label: $A B$,
      manual-terms: (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15),
      implicants: ((5, 13),),
      corner-implicants: true,
    )
  ]

  #table(
    columns: 4,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Group*], [*Cells*], [*Pattern*], [*Term*]),
    [Corners], [0, 2, 8, 10], [$B = 0$, $D = 0$, $A$ and $C$ vary], [$overline(B) thin overline(D)$],
    [Vertical], [5, 13], [$B = 1$, $C = 0$, $D = 1$, $A$ varies], [$B thin overline(C) thin D$],
  )

  *Minimal DNF:* $f = overline(B) thin overline(D) + B thin overline(C) thin D$
]

== K-Map Grouping: Valid Group Sizes

#Block(color: purple)[
  *Rules for valid groups:*

  + Size must be a power of 2: 1, 2, 4, 8, or 16 cells
  + Shape must be rectangular (1×2, 2×2, 4×4, 1×8, etc.)
  + Can wrap around edges (torus topology)
  + Larger groups are always better (fewer literals)
]

#example[
  Relationship between group size and simplification:

  #align(center)[
    #table(
      columns: 4,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
      inset: (x, y) => if y == 0 { 5pt } else { 3pt },
      table.header([*Group \ Size*], [*Variables \ Eliminated*], [*Literals \ Left*], [*Example \ Term*]),
      [1 cell], [0], [4], [$A B C D$],
      [2 cells], [1], [3], [$A B C$],
      [4 cells], [2], [2], [$A B$],
      [8 cells], [3], [1], [$A$],
      [16 cells], [4], [0], [$1$ (tautology)],
    )
  ]
]

== K-Map Strategy: Optimal Grouping

#Block(color: yellow)[
  *Step-by-step grouping strategy:*

  + Mark all 1s in the K-map
  + Find cells that can *only* be covered by one group (essential)
  + Group these with largest possible rectangles
  + Cover remaining 1s with largest possible groups
  + Minimize overlap (but overlap is allowed!)
  + Verify all 1s are covered
]

#Block(color: blue)[
  *Pro tips:*
  - Start with isolated 1s (they need their own groups)
  - Look for groups of 8, then 4, then 2
  - Remember wraparound on all edges
  - Corner cells can also form groups ($2 times 2$ block)
]

== K-Maps with Don't-Care Conditions

#definition[Don't-Care Conditions][
  Situations where output value doesn't matter (marked as $cross$):
  - Invalid input combinations
  - Outputs that are never used
  - Incompletely specified functions
]

#example[
  BCD (Binary Coded Decimal) uses only 0-9:

  Inputs 1010-1111 are don't-cares (invalid BCD)
]

#Block(color: yellow)[
  *Strategy with don't-cares:*
  - Treat $cross$ as 0 or 1 to maximize group sizes
  - Include $cross$ in groups if it helps
  - Don't create groups containing only $cross$ values
]

== Don't-Care Example

#example[
  Function with don't-cares at positions 9, 11, 12, 15

  #align(center)[
    #k-mapper.karnaugh(
      16,
      x-label: $C D$,
      y-label: $A B$,
      manual-terms: (
        kcell(0, 0),
        kcell(1, 1),
        kcell(2, 0),
        kcell(3, 1),
        kcell(4, 0),
        kcell(5, 0),
        kcell(6, 0),
        kcell(7, 0),
        kcell(8, 1),
        kcell(9, cross),
        kcell(10, 0),
        kcell(11, cross),
        kcell(12, cross),
        kcell(13, 1),
        kcell(14, 0),
        kcell(15, cross),
      ),
      implicants: ((1, 3), (8, 13)),
    )
  ]

  - Group 1: includes cells 1, 3 (filled with 1s) $=>$ gives $overline(A) thin overline(B) thin D$
  - Group 2: includes cells 8, 9, 12, 13 (uses don't-cares) $=>$ gives $A thin overline(C)$

  Without don't-cares, we would need more terms to cover all 1s!
]

== Algebraic Minimization

Beyond K-maps, we can minimize algebraically using Boolean laws:

#Block(color: purple)[
  *Essential simplification laws:*

  #align(center)[
    #table(
      columns: 3,
      align: left,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
      table.header([*Law*], [*Sum Form*], [*Product Form*]),
      [Idempotent], [$X + X = X$], [$X dot X = X$],
      [Absorption], [$X + X Y = X$], [$X(X + Y) = X$],
      [Combining], [$X Y + X overline(Y) = X$], [$(X + Y)(X + overline(Y)) = X$],
      [Consensus],
      [$X Y + overline(X) Z + Y Z$ \ $= X Y + overline(X) Z$],
      [$(X + Y)(overline(X) + Z)(Y + Z)$ \ $= (X + Y)(overline(X) + Z)$],
    )
  ]
]

== Step-by-Step Algebraic Minimization

#example[
  Minimize $f = A B C + A B overline(C) + overline(A) B C + overline(A) overline(B) C$:

  *Step 1:* Look for combining opportunities
  $
    f & = A B C + A B overline(C) + overline(A) B C + overline(A) overline(B) C \
      & = A B (C + overline(C)) + overline(A) B C + overline(A) overline(B) C   && "(factor)" \
      & = A B + overline(A) B C + overline(A) overline(B) C                     && "(complement)"
  $

  *Step 2:* Apply more combining
  $
    f & = A B + overline(A) C (B + overline(B)) && "(factor)" \
      & = A B + overline(A) C                   && "(complement)"
  $

  *Final result:* $f = A B + overline(A) C$ (reduced from 12 to 4 literals!)
]

== Consensus Theorem

#theorem[Consensus Theorem][
  $X Y + overline(X) Z + Y Z = X Y + overline(X) Z$

  The term $Y Z$ is "absorbed" by the other two terms.
]

#proof[
  $
    X Y + overline(X) Z + Y Z & = X Y + overline(X) Z + (X + overline(X)) Y Z   && "(complement)" \
                              & = X Y + overline(X) Z + X Y Z + overline(X) Y Z && "(distributive)" \
                              & = X Y (1 + Z) + overline(X) Z (1 + Y)           && "(factor)" \
                              & = X Y + overline(X) Z                           && "(null: " 1 + X = 1 ")"
  $
]

#Block(color: blue)[
  *Intuition:* If $Y Z$ is true, then either $X Y$ or $overline(X) Z$ must already be true, so $Y Z$ is redundant.
]

== Multi-Level Minimization

#definition[Multi-Level Logic][
  Instead of two-level SoP/PoS, use multiple levels of gates to share common subexpressions.
]

#example[
  Two-level: $f_1 = A B C + A B D$, $f_2 = A B C + A B E$

  Total: $12$ literals ($6 + 6$)

  Multi-level with factoring:
  - $T = A B$ (common factor)
  - $f_1 = T (C + D)$
  - $f_2 = T (C + E)$

  Total: $6$ literals + reuse of $T$
]

#Block(color: yellow)[
  *Trade-off:* Multi-level uses fewer gates but has longer delay (more levels).
]

== When to Use CNF vs DNF

#columns(2)[
  *DNF (Sum of Products):*
  - Few 1s in truth table
  - OR-of-ANDs natural
  - Most circuit designs
  - Easy synthesis from minterms
  - K-map method works well

  #colbreak()

  *CNF (Product of Sums):*
  - Few 0s in truth table
  - AND-of-ORs structure
  - SAT solver input
  - Constraint representation
  - Built from maxterms
]

#example[
  Consider two functions:

  #align(center)[
    #table(
      columns: 3,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
      table.header([*Truth Table*], [*SoP Terms*], [*PoS Clauses*]),
      [2 ones, 6 zeros], [2 terms], [6 clauses],
      [6 ones, 2 zeros], [6 terms], [2 clauses],
    )
  ]

  Choose the form with fewer components!
]

== Introduction to Quine-McCluskey

#definition[
  The _Quine-McCluskey algorithm_ is a systematic tabular method for finding all prime implicants, guaranteed to produce a minimal form.

  The Q-M algorithm has two phases:
  + Generate all prime implicants from minterms
  + Select a minimal set of prime implicants covering all minterms
]

#grid(
  columns: 2,
  column-gutter: 1em,

  Block(color: blue)[
    *When to use Q-M:*
    - More than 4-5 variables (K-maps impractical)
    - Need guaranteed minimal solution
    - Computer-aided design tools
    - Can be automated (unlike K-maps)
  ],

  Block(color: orange)[
    *Limitation:* Complexity grows exponentially with variables --- practical for ≤ 6-8 variables.
  ],
)

== Quine-McCluskey Algorithm

The Q-M algorithm has two phases:

#grid(
  columns: 2,
  column-gutter: 1em,

  Block(color: purple)[
    *Phase 1: Generate Prime Implicants*

    + List all minterms in binary
    + Group by number of 1s (Hamming weight)
    + Combine pairs differing in exactly one bit
    + Replace differing bit with dash (--)
    + Repeat until no more combinations
    + Uncombined terms are prime implicants
  ],

  Block(color: purple)[
    *Phase 2: Select Minimal Cover*

    + Build prime implicant chart
    + Find essential prime implicants
    + Use Petrick's method or heuristics for rest
  ],
)

== Step-by-Step Example of Q-M Phase 1

#example[
  Minimize $f(A, B, C) = sum m(1, 3, 5, 6, 7)$
]

#Block[
  *Step 1:* Group minterms by number of 1-bits (Hamming weight).
]

#columns(2)[
  #align(center)[
    #table(
      columns: 3,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
      table.header([*Group*], [*Minterm*], [*Binary*]),
      [1], [$m_1$], [001],
      table.hline(stroke: 0.4pt),
      [2], [$m_3$], [011],
      [], [$m_5$], [101],
      [], [$m_6$], [110],
      table.hline(stroke: 0.4pt),
      [3], [$m_7$], [111],
    )
  ]

  #colbreak()

  #align(center)[
    #k-mapper.karnaugh(
      8,
      y-label: $A B$,
      x-label: $C$,
      manual-terms: (
        kcell(0, 0),
        kcell(1, 1),
        kcell(2, 0),
        kcell(3, 1),
        kcell(4, 0),
        kcell(5, 1),
        kcell(6, 1),
        kcell(7, 1),
      ),
      implicants: ((1, 5), (6, 7)),
    )
  ]
]

== Q-M Phase 1: First Combination

#Block[
  *Step 2:* Try to combine each minterm in group $i$ with each minterm in group $i+1$.
]

#align(center)[
  #table(
    columns: 4,
    align: (center, center, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*\# of 1s*], [*Minterm*], [*Cube*], [*Size 2 Implicants*]),

    [1],
    [$m_1$#YES],
    [001],
    [
      $m_1 + m_3 = m_(1,3)$ #YES 0−1 \
      $m_1 + m_5 = m_(1,5)$ #YES −01 \
      $m_1 + m_6$ #NO (differ in 3 positions)
    ],

    table.hline(stroke: 0.4pt),
    [2],
    [$m_3$#YES],
    [011],
    [
      $m_3 + m_7 = m_(3,7)$ #YES −11
    ],
    [],

    [$m_5$#YES],
    [101],
    [
      $m_5 + m_7 = m_(5,7)$ #YES 1−1
    ],
    [],

    [$m_6$#YES],
    [110],
    [
      $m_6 + m_7 = m_(6,7)$ #YES 11−
    ],

    table.hline(stroke: 0.4pt),
    [3], [$m_7$#YES], [111], [ --- ],
  )
]

*Result:* Five size-2 implicants formed: $m_(1,3)$, $m_(1,5)$, $m_(3,7)$, $m_(5,7)$, $m_(6,7)$

#note[
  Mark all "used" minterms with #YES and all "unused" with #NO
]

== Q-M Phase 1: Second Combination

#Block[
  *Step 3:* Try to combine each 2-size implicant with others having dashes in the SAME positions.
]

#align(center)[
  #table(
    columns: 4,
    align: (center, center, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Dash pos.*], [*Implicant*], [*Pattern*], [*Size 4 Implicant*]),
    [pos. 0],
    [$m_(1,5)$ #YES],
    [−01],
    [
      $m_(1,5)+m_(3,7) = m_(1,3,5,7)$ #YES −−1
    ],
    [],
    [$m_(3,7)$ #YES],
    [−11],
    [---],

    table.hline(stroke: 0.4pt),
    [pos. 1],
    [$m_(1,3)$ #YES],
    [0−1],
    [
      $m_(1,3) + m_(5,7) = m_(1,3,5,7)$ #YES −−1
    ],
    [],
    [$m_(5,7)$ #YES],
    [1−1],
    [---],

    table.hline(stroke: 0.4pt),
    [pos. 2],
    [$m_(6,7)$ #NO],
    [11−],
    [
      (no other implicant with dash at pos. 2)
    ],
  )
]

*Explanation:*
- $m_(1,5)$ (−01) and $m_(3,7)$ (−11): dashes align at pos. 0, differ only in bit 1 $=>$ #YES combine to −−1
- $m_(1,3)$ (0−1) and $m_(5,7)$ (1−1): dashes align at pos. 1, differ only in bit 0 $=>$ #YES combine to −−1
- $m_(6,7)$ (11−): alone with dash at pos. 2 $=>$ cannot combine

*Result:* One size-4 implicant formed: $m_(1,3,5,7)$ (−−1). \
Only one size-2 implicant remains uncombined: $m_(6,7)$ (11−).

== Q-M Phase 1: Finding Prime Implicants

#Block[
  *Step 4:* Identify prime implicants (uncombined terms).
]

From Step 3:
- Size-4 implicant: $m_(1,3,5,7)$ (−−1) is _prime_ since there are no other size-4 implicants to combine with
- Size-2 implicants NOT marked with #YES: $m_(6,7)$ are _prime_

#align(center)[
  #table(
    columns: 3,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Pattern*], [*Covers*], [*Boolean Term*]),
    [−−1], [{1, 3, 5, 7}], [$C$],
    [11−], [{6, 7}], [$A B$],
  )
]

These 4 prime implicants cannot be reduced further.

== Prime Implicant Chart

#definition[
  A _prime implicant chart_ is a table showing which minterms are covered by each prime implicant.
]

#note[
  Our goal in Q-M is to select a minimum set of prime implicants covering all minterms.
]

#example[
  For our example $sum m(1, 3, 5, 6, 7)$:

  #align(center)[
    #table(
      columns: 6,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } + if x == 0 { (right: 0.8pt) },
      table.header([*Prime Implicant*], [*$m_1$*], [*$m_3$*], [*$m_5$*], [*$m_6$*], [*$m_7$*]),
      [$C$ (−−1)], [$checkmark$], [$checkmark$], [$checkmark$], [], [$checkmark$],
      [$A B$ (11−)], [], [], [], [$checkmark$], [$checkmark$],
    )
  ]

  *Finding essential prime implicants:*
  - Look for columns with only ONE $checkmark$ $=>$ that PI is *essential*
    - Columns $m_1$, $m_3$, $m_5$ --- only covered by $C$ $=>$ $C$ is *essential*
    - Column $m_6$ --- only covered by $A B$ $=>$ $A B$ is *essential*

  *Selecting minimal cover:*
  - Must include: $C$ (essential), covers ${1, 3, 5, 7}$
  - Must include: $A B$ (essential), covers ${6, 7}$

  *Minimal solution:* $f = C + A B$ (3 literals)
]

== Essential Prime Implicants

#definition[
  An _essential prime implicant_ (EPI) is a prime implicant that covers at least one minterm not covered by any other prime implicant.
]

#note[
  EPIs must ("by definition") be included in the final minimal cover.
]

#grid(
  columns: (auto, 1fr),
  column-gutter: 1em,

  Block(color: yellow)[
    *Algorithm:*
    + Look for columns with only one $cross$ (essential)
    + Include those prime implicants
    + Remove covered minterms
    + Repeat for remaining minterms
  ],

  example[
    If a column has only one $cross$, that prime implicant is essential:

    #align(center)[
      #table(
        columns: 4,
        stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } + if x == 0 { (right: 0.8pt) },
        [], [$m_i$], [$m_j$], [$m_k$],
        [$"PI"_1$], [$cross$], [$cross$], [],
        [$"PI"_2$], [], [$cross$], [$cross$],
      )
    ]

    - $"PI"_1$ is essential (only one covering $m_i$)
    - $"PI"_2$ is essential (only one covering $m_k$)
  ],
)

== Petrick's Method

When multiple prime implicants remain after selecting essentials:

#definition[
  _Petrick's method_ is a systematic way to find all combinations of prime implicants that cover all remaining minterms, allowing selection of the minimal-cost cover.

  + Express "covering all minterms" as a Boolean formula
  + Each minterm needs at least one of its covering PIs
  + Formula in CNF (product of sums)
  + Convert to DNF to see all possible covers
  + Choose cover with minimum cost
]

#Block(color: blue)[
  *Why it works:*
  The CNF formula is satisfiable if and only if we can cover all minterms. \
  Each satisfying assignment is a valid cover.
]

== Petrick's Method: Example

#example[
  Prime implicants $P_1, P_2, P_3, P_4$ cover minterms as follows:

  #align(center)[
    #table(
      columns: 5,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } + if x == 0 { (right: 0.8pt) },
      [], [$m_1$], [$m_2$], [$m_3$], [$m_4$],
      [$P_1$], [$cross$], [$cross$], [], [],
      [$P_2$], [$cross$], [], [$cross$], [],
      [$P_3$], [], [$cross$], [$cross$], [$cross$],
      [$P_4$], [], [], [$cross$], [$cross$],
    )
  ]

  *Coverage formula (CNF):*
  - $m_1$: $P_1 + P_2$ (needs $P_1$ OR $P_2$)
  - $m_2$: $P_1 + P_3$ (needs $P_1$ OR $P_3$)
  - $m_3$: $P_2 + P_3 + P_4$
  - $m_4$: $P_3 + P_4$

  Formula: $(P_1 + P_2)(P_1 + P_3)(P_2 + P_3 + P_4)(P_3 + P_4)$
]

== Petrick's Method: Solving

#example[continued][
  *Expand to DNF:*

  $
    & (P_1 + P_2)(P_1 + P_3)(P_2 + P_3 + P_4)(P_3 + P_4) \
    & = (P_1 + P_2 P_3)(P_2 + P_3 + P_4)(P_3 + P_4) \
    & = P_1 (P_3 + P_4) + P_2 P_3 (P_3 + P_4) \
    & = P_1 P_3 + P_1 P_4 + P_2 P_3
  $

  *Possible covers:*
  + $P_1 P_3$ (2 implicants)
  + $P_1 P_4$ (2 implicants)
  + $P_2 P_3$ (2 implicants)

  All have same cost! Choose any: $f = P_1 + P_3$ (for example)
]

#Block(color: orange)[
  *Warning:* CNF to DNF expansion can explode exponentially!
]

== Quine-McCluskey: Complete Example

#example[
  Minimize $f(A, B, C, D) = sum m(0, 1, 2, 5, 6, 7, 8, 9, 10, 14)$
]

#align(center)[
  #table(
    columns: 7,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    inset: (x, y) => if x == 0 { 5pt } else { 3pt },
    table.header([*Group*], [*Minterm*], [*Binary*], [*$->$*], [*Comb 1*], [*$->$*], [*Comb 2*]),
    [0], [0], [0000], [], [0,1: 000−], [], [0,1,8,9: −00−],
    [1], [1], [0001], [], [0,2: 00−0], [], [0,2,8,10: −0−0],
    [], [2], [0010], [], [0,8: −000], [], [],
    [], [8], [1000], [], [1,9: 100−], [], [],
    [2], [5], [0101], [], [2,6: 0−10], [], [2,6,10,14: −−10],
    [], [6], [0110], [], [2,10: −010], [], [],
    [], [9], [1001], [], [5,7: 01−1], [], [],
    [], [10], [1010], [], [8,9: 100−], [], [],
    [3], [7], [0111], [], [8,10: 10−0], [], [],
    [], [14], [1110], [], [6,7: 011−], [], [],
    [], [], [], [], [6,14: −110], [], [],
    [], [], [], [], [10,14: 1−10], [], [],
  )
]

== Q-M Example: Finding Minimal Cover

*Prime implicants:*
- $P_1$: −00− covers {0, 1, 8, 9}
- $P_2$: −0−0 covers {0, 2, 8, 10}
- $P_3$: −−10 covers {2, 6, 10, 14}
- $P_4$: 01−1 covers {5, 7}

*Prime implicant chart:*
#box(baseline: 100% - 1em)[
  #table(
    columns: 11,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } + if x == 0 { (right: 0.8pt) },
    table.header([], [*0*], [*1*], [*2*], [*5*], [*6*], [*7*], [*8*], [*9*], [*10*], [*14*]),
    [$P_1$], [$cross$], [$cross$], [], [], [], [], [$cross$], [$cross$], [], [],
    [$P_2$], [$cross$], [], [$cross$], [], [], [], [$cross$], [], [$cross$], [],
    [$P_3$], [], [], [$cross$], [], [$cross$], [], [], [], [$cross$], [$cross$],
    [$P_4$], [], [], [], [$cross$], [], [$cross$], [], [], [], [],
  )
]

- $P_4$ is essential (only covers 5, 7)
- After selecting $P_4$, need to cover {0, 1, 2, 6, 8, 9, 10, 14}

*Minimal solution:* $f = P_1 + P_3 + P_4$ or $f = P_2 + P_3 + P_4$

== Complexity of Minimization

#theorem[
  Boolean function minimization is *NP-complete*.
]

#Block(color: purple)[
  *What this means:*
  - No polynomial-time algorithm known for optimal minimization
  - Problem difficulty grows exponentially with function size
  - For large functions, we must accept suboptimal solutions
  - Heuristics and approximations are necessary
]

#Block(color: teal)[
  *Historical context:*
  - 1950s-1970s: Minimization critical (gates expensive)
  - Quine-McCluskey (1956): First systematic method
  - ESPRESSO (1984): Major breakthrough in heuristics
  - Modern era: Focus shifted to power/delay over gate count
]

== Modern Minimization Tools

#grid(
  columns: 2,
  column-gutter: 1em,

  Block(color: blue)[
    *Industrial-strength tools:*

    *ESPRESSO:*
    - Heuristic multi-level minimizer
    - Handles 100+ variables
    - Used in major CAD tools

    *ABC (Berkeley):*
    - Academic tool for logic synthesis
    - Advanced algorithms for large designs

    *Commercial tools:*
    - Synopsys Design Compiler
    - Cadence Genus
  ],

  Block(color: yellow)[
    *Modern approach:*
    - Technology mapping (fit to available gates)
    - Timing-driven optimization
    - Power minimization
    - Multi-objective optimization
  ],
)

== Practical Minimization Strategy

#Block(color: green)[
  *Recommended approach by function size:*

  #columns(2)[
    *2-3 variables:*
    - Use K-maps (instant, visual)
    - Or simple algebra

    *4 variables:*
    - K-maps work well
    - Good for learning and verification

    *5-6 variables:*
    - K-maps possible but tedious
    - Q-M algorithm or tools

    #colbreak()

    *7+ variables:*
    - Use CAD tools (ESPRESSO, ABC)
    - Heuristic methods
    - Accept near-optimal solutions

    *Always:*
    - Verify by expanding result
    - Check against original truth table
    - Test edge cases
  ]
]

== Summary: Minimization Techniques

#Block(color: purple)[
  *What we've mastered:*

  #columns(2)[
    + *Why minimize:* Cost, power, speed, clarity

    + *Gray code:* Foundation for K-map adjacency

    + *K-maps:* Visual method for 2-5 variables
      - Grouping rules and strategies
      - Wrap-around and corners
      - Don't-care optimization

    + *Algebraic methods:* Laws, consensus, #box[multi-level], factoring

    #colbreak()
    #set enum(start: 5)

    + *Quine-McCluskey:*
      - Systematic prime implicant generation
      - Prime implicant chart
      - Essential implicants

    + *Petrick's method:* Minimum cover selection

    + *Minimization complexity:* NP-complete

    + *Practical tools:* ESPRESSO, ABC
  ]
]

#Block(color: yellow)[
  *Next:* #h(0.2em)
  Zhegalkin polynomials (ANF) --- a completely different normal form using XOR!
]


= Algebraic Normal Form
#focus-slide()

== Algebraic Normal Form

So far, we've worked with Boolean functions using AND ($and$), OR ($or$), and NOT ($overline(x)$).

These led to DNF, CNF, and various minimization techniques.

#Block(color: blue)[
  *New question:* Can we represent Boolean functions using *only* XOR ($xor$) and AND ($and$)?
]

#definition[
  An _Algebraic Normal Form_ (ANF) or _Zhegalkin polynomial_ is a representation of a Boolean function as a polynomial over $FF_2$ (the field with two elements ${0, 1}$) using:
  - Addition modulo 2 (XOR, $xor$)
  - Multiplication (AND, $and$)
  - Constants 0 and 1
]

== Why ANF?

#Block(color: yellow)[
  *Different algebraic properties:*
  - XOR is its own inverse: $x xor x = 0$
  - No need for negation (NOT)
  - Linear operations (important in cryptography, coding theory)
]

#columns(2)[
  *Applications:*
  - Cryptography (stream ciphers, S-boxes)
  - Coding theory (linear codes)
  - Hardware optimization (XOR gates)
  - Algebraic attacks on ciphers

  #colbreak()

  *Key properties:*
  - Unique representation (_canonical_$thin$)
  - Degree of polynomial = algebraic degree
  - Linear functions = degree 1
  - Affine functions = degree $<=$ 1
]

== ANF Structure

#example[
  The function $f(x, y, z) = x y xor x z xor y z xor x xor 1$ is in ANF.

  Terms:
  - $x y$ --- degree 2 (product of 2 variables)
  - $x z$ --- degree 2
  - $y z$ --- degree 2
  - $x$ --- degree 1 (linear term)
  - $1$ --- degree 0 (constant)

  The function has algebraic degree 2.
]

#note[
  In ANF, we write addition (XOR) as $xor$ or simply $+$.

  Multiplication (AND) can be written as $and$, $dot$, or juxtaposition (e.g., $x y$).
]

== ANF vs DNF

#align(center)[
  #table(
    columns: 3,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Property*], [*DNF*], [*ANF*]),
    [Operations], [AND, OR, NOT], [AND, XOR],
    [Form], [Sum of products], [XOR of products],
    [Canonical], [Yes (minterms)], [Yes (unique!)],
    [Negation], [Explicit ($overline(x)$)], [Using XOR ($x xor 1$)],
    [Idempotent], [$x or x = x$], [$x xor x = 0$],
    [Neutrality], [$x or 0 = x$], [$x xor 0 = x$],
    [Algebraic degree], [Not defined], [Maximum term degree],
  )
]

#Block(color: yellow)[
  *Key difference:* In DNF, $x or x = x$ (idempotent). In ANF, $x xor x = 0$ (self-inverse)!
]

== Canonicity of ANF

#theorem[
  Every Boolean function has a _unique_ ANF representation.
]

#proof[(sketch)][
  Consider the vector space $FF_2^n arrow.r FF_2$ of all Boolean functions on $n$ variables.

  - There are $2^(2^n)$ Boolean functions on $n$ variables
  - There are $2^(2^n)$ possible ANF polynomials (one for each subset of monomials)
  - The mapping from ANF to Boolean function is linear and bijective

  Therefore, each Boolean function has exactly one ANF representation.
]

#Block(color: yellow)[
  *Important:* Unlike DNF/CNF (which have minimal and non-minimal forms), ANF is always unique!
]

== Monomials in ANF

For $n$ variables, possible monomials in ANF:

#example[
  For $n = 3$ variables $(x, y, z)$:

  #align(center)[
    #table(
      columns: 3,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
      table.header([*Degree*], [*Count*], [*Monomials*]),
      [0], [1], [$1$],
      [1], [3], [$x, y, z$],
      [2], [3], [$x y, x z, y z$],
      [3], [1], [$x y z$],
    )
  ]

  Total: $2^3 = 8$ possible monomials (including constant 1).

  Each monomial either appears in ANF or doesn't → $2^8 = 256$ possible ANFs for 3 variables.
]

#note[
  For $n$ variables, there are $sum_(k=0)^n binom(n, k) = 2^n$ possible monomials.
]

== Algebraic Degree

#definition[
  The _algebraic degree_ of a Boolean function in ANF is the maximum number of variables in any monomial with non-zero coefficient.
]

#example[
  - $f(x, y) = x y xor x xor 1$ has degree 2
  - $f(x, y) = x xor y xor 1$ has degree 1 (affine function)
  - $f(x, y) = x xor y$ has degree 1 (linear function)
  - $f(x) = x xor 1$ has degree 1
  - $f(x) = 1$ has degree 0 (constant)
  - $f(x) = 0$ has degree $-infinity$ or undefined (zero function)
]

#Block(color: red)[
  Functions with low algebraic degree are vulnerable to certain cryptographic attacks!
]

== Computing ANF: Methods

We'll explore three methods to compute ANF from a truth table:

#align(center)[
  #table(
    columns: 4,
    align: (left, center, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Method*], [*Complexity*], [*Variables*], [*Best for*]),
    [Direct computation], [$O(2^(2n))$], [1-3], [Understanding],
    [Pascal's triangle], [$O(2^n)$], [1-4], [Hand calculation],
    [Karnaugh map], [$O(2^n)$], [2-4], [Visualization],
  )
]

We'll demonstrate each method with examples!

== Method 1: Direct Computation

#Block(color: teal)[
  *Idea:* Solve a system of linear equations over $FF_2$ (arithmetic mod 2).
]

For function $f: FF_2^n arrow.r FF_2$, we want to find coefficients $a_S$ such that:
$
  f(x_1, ..., x_n) = xor.big_(S subset.eq {1,...,n}) (a_S product_(i in S) x_i)
$

where $xor$ denotes XOR and $product$ denotes AND.

Each row of the truth table gives one linear equation!

#Block(color: orange)[
  *Remember:* In $FF_2$, addition is XOR: $1 + 1 = 0$, $1 + 0 = 1$, $0 + 0 = 0$
]

== Direct Computation: Example

#example[
  Find ANF for $f(x, y)$ with truth table:

  #align(center)[
    #table(
      columns: 3,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
      table.header([$x$], [$y$], [$f(x,y)$]),
      [0], [0], [1],
      [0], [1], [1],
      [1], [0], [1],
      [1], [1], [0],
    )
  ]

  _(Solution on next slide)_
]

#pagebreak()

Let ANF be: $f(x, y) = a_0 xor a_1 x xor a_2 y xor a_3 x y$

From truth table, substitute each $(x, y)$ to get 4 equations over $FF_2$:

#align(center)[
  #table(
    columns: 4,
    align: (center, left, center, center),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*$(x,y)$*], [*Substituted equation*], [], [*$f$*]),
    [(0,0)], [$a_0 xor (a_1 dot 0) xor (a_2 dot 0) xor (a_3 dot 0 dot 0) = a_0$], [$=$], [1],
    [(0,1)], [$a_0 xor (a_1 dot 0) xor (a_2 dot 1) xor (a_3 dot 0 dot 1) = a_0 xor a_2$], [$=$], [1],
    [(1,0)], [$a_0 xor (a_1 dot 1) xor (a_2 dot 0) xor (a_3 dot 1 dot 0) = a_0 xor a_1$], [$=$], [1],
    [(1,1)], [$a_0 xor a_1 xor a_2 xor a_3$], [$=$], [0],
  )
]

*Solving step-by-step:*
- Equation 1: $a_0 = 1$
- Equation 2: $(a_0 xor a_2 = 1) => (1 xor a_2 = 1) => a_2 = 0$
- Equation 3: $(a_0 xor a_1 = 1) => (1 xor a_1 = 1) => a_1 = 0$
- Equation 4: $(1 xor 0 xor 0 xor a_3 = 0) => (1 xor a_3 = 0) => a_3 = 1$

*Result:*~ $f(x, y) = 1 xor x y$, which is equivalent to $f = x nand y$.

== Method 2: Pascal's Triangle Method

#Block[
  *Fast systematic method* using a butterfly/pyramid pattern!
]

*Algorithm:*
1. Write function values $f$ in a column (in binary order: 000, 001, 010, ...)
2. Create next column: XOR each adjacent pair $(f_i xor f_(i+1))$
3. Repeat step 2 until only one value remains
4. The *first value* of each column is an ANF coefficient

#note[
  Also called the _Butterfly method_ or _ANF transform_.
]

#Block(color: yellow)[
  *Pattern:* Coefficients appear in binary order: $1$, $z$, $y$, $y z$, $x$, $x z$, $x y$, $x y z$
]

== Pascal's Triangle Method: Example

Find ANF for $f(x, y, z) = sum m(0, 1, 3, 7)$:

#align(center)[
  #let bb(it) = {
    box(stroke: red, outset: 3pt, radius: 2pt)[#it]
  }
  #table(
    columns: 10,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } + if x == 1 { (right: 0.8pt) },
    table.header(
      [$x y z$], [$f$], [$a_1$], [$a_z$], [$a_y$], [$a_(y z)$], [$a_x$], [$a_(x z)$], [$a_(x y)$], [$a_(x y z)$]
    ),
    [000], [1], bb[1], [0], bb[1], bb[1], bb[1], [0], bb[1], [0],
    [001], [1], [1], [1], [0], [0], [1], [1], [1], [ ],
    [010], [0], [0], [1], [0], [1], [0], [0], [ ], [ ],
    [011], [1], [1], [1], [1], [1], [0], [ ], [ ], [ ],
    [100], [0], [0], [0], [0], [1], [ ], [ ], [ ], [ ],
    [101], [0], [0], [0], [1], [ ], [ ], [ ], [ ], [ ],
    [110], [0], [0], [1], [ ], [ ], [ ], [ ], [ ], [ ],
    [111], [1], [1], [ ], [ ], [ ], [ ], [ ], [ ], [ ],
  )
]

*ANF:*~ $f = 1 xor y xor y z xor x xor x y$

== Pascal's Triangle: Why It Works

The transformation computes the _Möbius transform_ over the Boolean lattice:

$ a_S = xor.big_(T subset.eq S) f(T) $

Each coefficient $a_S$ is the XOR of all function values $f(T)$ where $T subset.eq S$.

#example[
  For $a_(x y)$ (corresponding to input 110 = {$x, y$}):
  $
    a_(x y) & = f(00) xor f(01) xor f(10) xor f(11) \
            & = 1 xor 1 xor 0 xor 0 = 0
  $
]

#Block(color: teal)[
  *Historical note:*~
  Related to Reed-Muller codes and Fast Walsh-Hadamard Transform!
]

== Method 3: Karnaugh Map Method

#Block(color: blue)[
  *Intuitive visual method* for 2-4 variables using K-maps!
]

*Algorithm:*
+ Fill K-map with function values
+ For each possible monomial (including constant 1):
  - Identify its rectangular region in K-map
  - Check if upper-left cell of region is 1
  - If yes, include monomial in ANF (with XOR)
+ Combine all included monomials with XOR

#note[
  *Key difference from minimization:*
  We check ALL possible groups (not just largest), and combine with XOR (not OR)!
]

== K-Map Method: Example

Find ANF for $f(x, y) = sum m(1, 2)$:

#grid(
  columns: (auto, 2cm, auto),
  column-gutter: 1em,
  [
    *K-map:*

    #align(center)[
      #k-mapper.karnaugh(
        4,
        y-label: $x$,
        x-label: $y$,
        manual-terms: (
          kcell(0, 0),
          kcell(1, 1),
          kcell(2, 1),
          kcell(3, 0),
        ),
        implicants: ((2, 3), (1, 3)),
        colors: (gray.transparentize(80%),),
      )
    ]
  ],
  [],
  [
    *Monomials to check:*

    + *Constant 1* (all 4 cells): \
      Top-left (0,0) = 0 $=>$ No
    + *$x$* (bottom row, cells $x=1$): \
      Top-left at (1,0) = 1 $=>$ *Include $x$*
    + *$y$* (right column, cells $y=1$): \
      Top-left at (0,1) = 1 $=>$ *Include $y$*
    + *$x y$* (single cell at $x=1$, $y=1$): \
      Value = 0 $=>$ No

    *ANF:* $f = x xor y$
  ],
)

#Block(color: yellow)[
  This is the XOR function!
  Notice: only linear terms, degree = 1.
]

== K-Map Method: Another Example

#example[
  Find ANF for $f(x, y, z) = sum m(0, 1, 3, 7)$
]

#align(center)[
  TODO
  //   #table(
  //     columns: 5,
  //     stroke: 0.5pt,
  //     align: center,
  //     [], [], [*$y z$*], [], [],
  //     [], [], [$00$], [$01$], [$11$],
  //     [$10$], [*$x$*], [0], [1], [1],
  //     [1], [0], [], [1], [0],
  //     [0], [1], [0],
  //   )
]

*Groups to check:*
+ *Constant* (all 8 cells): $1 xor 1 xor 1 xor 0 xor 0 xor 0 xor 1 xor 0 = 0$ $=>$ No constant term
+ *$z$* (columns 01, 11): Top-left at (0, 01) is 1 $=>$ Include $z$
+ *$y$* (columns 10, 11): Top-left at (0, 10) is 0 $=>$ No
+ *$x$* (bottom row): Top-left at (1, 00) is 0 $=>$ No
+ *$y z$* (column 11): Top-left at (0, 11) is 1 $=>$ Include $y z$
+ *$x y z$* (cell at $x = 1$, $y z = 11$): Value is 1 $=>$ Include $x y z$

*Result:*~ $f = 1 xor z xor y z xor x y z$ ✓

== Comparison of ANF Construction Methods

#align(center)[
  #table(
    columns: 4,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Method*], [*Pros*], [*Cons*], [*Best for*]),
    [
      *Direct computation*
    ],
    [
      - Systematic \
      - _Always works_ \
      - Clear math
    ],
    [
      - Tedious \
      - Many equations \
      - Error-prone
    ],
    [
      1-2 variables, \
      learning
    ],

    table.hline(stroke: 0.4pt + gray),
    [
      *Pascal's triangle*
    ],
    [
      - _Fast_ \
      - Mechanical \
      - Scales well
    ],
    [
      - Less intuitive \
      - Needs practice \
      - Easy to miscount
    ],
    [
      3-5 variables, \
      computation
    ],

    table.hline(stroke: 0.4pt + gray),
    [
      *K-map method*
    ],
    [
      - Visual \
      - _Intuitive_ \
      - Good for patterns
    ],
    [
      - Only 2-4 variables \
      - Can miss groups \
      - Needs care
    ],
    [
      2-4 variables, \
      understanding
    ],
  )
]

#Block(color: yellow)[
  *Recommendation:* Learn all three! Use Pascal's triangle for exams, K-map for intuition.
]

== Summary of ANF Properties

#Block(color: purple)[
  *Key properties of ANF:*

  + *Uniqueness:* Every Boolean function has exactly one ANF
  + *Completeness:* ANF can represent any Boolean function
  + *Operations:* Uses only XOR and AND (no NOT needed)
  + *Algebraic degree:* Maximum degree of monomials
  + *Self-inverse:* $x xor x = 0$ (unlike $x or x = x$)
  + *Linearity:* XOR is linear over $FF_2$
]

== ANF in Cryptography

#Block(color: blue)[
  *Why cryptographers care about ANF?*
]

#columns(2)[
  *Algebraic attacks:*
  - Express cipher as polynomial system
  - Solve over $FF_2$ (Gröbner bases)
  - Low degree = vulnerable!

  *S-box design:*
  - Need high algebraic degree
  - Balanced nonlinearity
  - Resistance to linear cryptanalysis

  #colbreak()

  *Stream ciphers:*
  - Boolean functions in LFSRs
  - Combining functions
  - Filter functions

  *Important classes:*
  - Bent functions (max nonlinearity)
  - Balanced functions
  - Correlation-immune functions
]

#Block(color: orange)[
  *Example:* AES S-box has algebraic degree 7 (near maximum of 8).
]

== Converting Between ANF and DNF

Two approaches for conversion:

#align(center)[
  #table(
    columns: 3,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Method*], [*Pros*], [*Cons*]),
    [
      *Algebraic* \
      Apply identities directly
    ],
    [
      - Direct \
      - Insightful
    ],
    [
      - Complex expansions \
      - Error-prone \
      - Gets messy quickly
    ],

    table.hline(stroke: 0.4pt + gray),
    [
      *Via truth table* \
      Use table as intermediate
    ],
    [
      - _Systematic_ \
      - _Always works_ \
      - Clear steps
    ],
    [
      - Requires table \
      - Extra step
    ],
  )
]

#Block(color: yellow)[
  *Recommendation:*
  Use truth table as intermediate step!
  It's systematic and reliable.
]

== Converting ANF to DNF

#example[
  Convert $f = x xor y xor x y$ (ANF) to DNF
]

*Step 1:* Build truth table by evaluating ANF:

#align(center)[
  #v(-.5em)
  #table(
    columns: 4,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([$x$], [$y$], [$f = x xor y xor x y$], [*Minterm*]),
    [0], [0], [$0 xor 0 xor 0 = 0$], [---],
    [0], [1], [$0 xor 1 xor 0 = 1$], [$overline(x) y$],
    [1], [0], [$1 xor 0 xor 0 = 1$], [$x overline(y)$],
    [1], [1], [$1 xor 1 xor 1 = 1$], [$x y$],
  )
]

*Step 2:* Read minterms where $f = 1$:

*DNF:* $f = overline(x) y or x overline(y) or x y = sum m(1, 2, 3)$

== Converting DNF to ANF

#example[
  Convert $f = overline(x) y or x overline(y)$ ~(DNF) to ANF
]

*Step 1:* Build truth table by evaluating DNF

*Step 2:* Apply Pascal's triangle method to get ANF:

#align(center)[
  #let bb(it) = {
    box(stroke: red, outset: 3pt, radius: 2pt)[#it]
  }
  #table(
    columns: 6,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } + if x == 1 { (right: 0.8pt) },
    table.header([$x y$], [$f$], [$a_1$], [$a_x$], [$a_y$], [$a_(x y)$]),
    [00], [0], [0], bb[1], bb[1], [0],
    [01], [1], [1], [0], [1], [ ],
    [10], [1], [1], [1], [ ], [ ],
    [11], [0], [0], [ ], [ ], [ ],
  )
]

*ANF:* $f = x xor y$ ~(the XOR function!)

== Summary: Algebraic Normal Form

#Block(color: purple)[
  *What we've learned?*

  + *ANF:* Polynomials over $FF_2$ using XOR and AND

  + *Canonicity:* Unique representation for each Boolean function

  + *Three ANF construction methods:*
    - Direct computation (solving linear system)
    - Pascal's triangle (fast, systematic)
    - K-map method (visual, intuitive)

  + *Applications:* Cryptography, coding theory, algebraic attacks

  + *Key difference from DNF/CNF:* Self-inverse property ($x xor x = 0$)
]

#Block(color: yellow)[
  *Next:*~
  Functional completeness --- how to build _any_ Boolean function with a minimal set of gates!
]


= Digital Circuits
#focus-slide()

== Digital Logic Circuits

#definition[
  A _logic gate_ is a physical device that implements a Boolean function, taking binary inputs and producing a binary output.
]

#place(right, dy: 1.5em)[
  #import "@preview/circuiteria:0.2.0"
  #circuiteria.circuit({
    import circuiteria: *
    import "@preview/cetz:0.3.2": draw
    draw.scale(80%)

    let label(s) = text(size: 10pt)[#s]

    element.gate-and(id: "and", x: 0, y: 0, w: 2, h: 2)
    draw.content("and", label[AND])

    element.gate-or(id: "or", x: 3.5, y: 0, w: 2, h: 2)
    draw.content("or", label[OR])

    element.gate-not(id: "not", x: 7, y: 0, w: 2, h: 2)
    draw.content((rel: (-5pt, 0), to: "not"), label[NOT])

    element.gate-nand(id: "nand", x: 0, y: -3, w: 2, h: 2)
    draw.content("nand", label[NAND])

    element.gate-nor(id: "nor", x: 3.5, y: -3, w: 2, h: 2)
    draw.content((rel: (3pt, 0), to: "nor"), label[NOR])

    element.gate-xor(id: "xor", x: 7, y: -3, w: 2, h: 2)
    draw.content((rel: (5pt, 0), to: "xor"), label[XOR])

    for id in ("and", "or", "not", "nand", "nor", "xor") {
      wire.stub(id + "-port-in0", "west")
      if id != "not" {
        wire.stub(id + "-port-in1", "west")
      }
      wire.stub(id + "-port-out", "east")
    }
  })
]

#v(-6pt)
#table(
  columns: 3,
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  inset: (x, y) => if y == 0 { 5pt } else { 3pt },
  table.header([*Gate*], [*Formula*], [*Description*]),
  [AND], $A and B$, [Outputs $1$ only when both inputs are $1$],
  [OR], $A or B$, [Outputs $1$ when at least one input is $1$],
  [NOT], $not A$, [Outputs the opposite of the input],
  [NAND], $A nand B$, [Outputs $0$ only when both inputs are $1$],
  [NOR], $A nor B$, [Outputs $0$ when at least one input is $1$],
  [XOR], $A xor B$, [Outputs $1$ when inputs differ],
  [XNOR], $A equiv B$, [Outputs $1$ when inputs are the same],
)

#note[
  NAND and NOR gates are _universal_ --- any Boolean function can be implemented using only NAND gates (or only NOR gates).
  For example, to implement AND using NAND:
  $
    A and B = not not (A and B) = not (A nand B) = (A nand B) nand (A nand B)
  $
]

== Combinational Logic

#definition[
  A _combinational circuit_ is a circuit where the output depends only on the current input values, without any memory or state.
]

#example[Half Adder][
  Adds two single bits:
  - Sum: $S = A xor B$
  - Carry: $C = A and B$
]

#example[Full Adder][
  Adds two bits plus a carry-in:
  - Sum: $S = A xor B xor C_"in"$
  - Carry-out: $C_"out" = (A and B) or (C_"in" and (A xor B))$
]

== Sequential Logic and Memory

#definition[
  A _sequential circuit_ is a circuit where the output depends on both current inputs and previous state (memory).
]

#example[Flip-Flops][
  - *SR Latch*: Set-Reset memory element.
  - *D Flip-Flop*: Data storage triggered by clock edge.
  - *JK Flip-Flop*: Eliminates forbidden state of SR latch.
  - *T Flip-Flop*: Toggle flip-flop for counters.
]

// == Bibliography
// #bibliography("refs.yml")

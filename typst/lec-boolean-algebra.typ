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

#definition[Basic Operations][
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

#definition[Derived Operations][
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
      table.header([$x$], [$y$], [$x and y$]),
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
      table.header([$x$], [$y$], [$z$], [$x and y$], [$not x and z$], [$(x and y) or (not x and z)$]),
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
      table.header([$x$], [$y$], [$not (x and y)$], [$not x or not y$], [Equal?]),
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
  - *Minterms:* $x and y and z$, $x and y and not z$, $x and not y and z$, ...
  - *Maxterms:* $x or y or z$, $x or y or not z$, $x or not y or z$, ...

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
      inset: (x, y) => if y == 0 { 5pt } else { 3pt },
      table.header([Index], [Binary], [Minterm $m_i$], [Maxterm $M_i$]),
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
      table.header([$x$], [$y$], [$z$], [$f$]),
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
  table.header([Gate], [Formula], [Description]),
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

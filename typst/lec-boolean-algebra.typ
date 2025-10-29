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

#Block(color: teal)[
  #set par(justify: true)
  *Historical context:* #h(0.2em)
  George Boole's _Laws of Thought_ (1854) created an algebraic system for logic a century before electronic computers.
  In 1937, Claude Shannon's Master's thesis demonstrated that Boolean algebra could systematically design switching circuits.
  This connection became the theoretical foundation for all digital computation.
]

#Block(color: yellow)[
  *Core principle:* Boolean algebra operates on truth values ($0$ and $1$) using operations like AND, OR, and NOT.
  This binary structure maps directly to voltage levels and logical decisions.
]

#columns(2)[
  *Timeline:*
  - *1703:* Leibniz --- binary arithmetic
  - *1854:* Boole --- algebraic logic
  - *1937:* Shannon --- circuit theory
  - *Today:* 100+ billion transistors per chip

  #colbreak()

  *Applications:*
  - Processor design (CPUs, GPUs)
  - Database queries and optimization
  - SAT solving and formal verification
  - Cryptographic algorithms
  - AI reasoning systems
]

== Boolean Values: 0 and 1

In Boolean algebra, we work with exactly two values:
- *0* (#False, off, low voltage, empty, ⊥)
- *1* (#True, on, high voltage, full, ⊤)

#example[
  In different contexts:
  - *Mathematics:* Predicate evaluation: "Is $x > 5$?" → 0 or 1
  - *Programming:* `if (user.isLoggedIn && user.hasPermission)` → boolean value
  - *Digital circuits:* Wire voltage → LOW (≈0V) or HIGH (≈3.3V)
  - *Set theory:* Characteristic function: $chi_A (x) = cases(1 "if" x in A, 0 "if" x in.not A)$
]

#Block(color: blue)[
  *Physical realization:*
  Modern computers represent all data using binary encoding.
  The two-valued logic maps naturally to physical systems: transistor states (on/off), voltage levels (high/low), magnetic orientation (north/south).
  Boolean algebra provides the mathematics for manipulating these binary representations.
]

== What You Will Master

In this lecture, you'll journey from abstract algebra to circuit implementation:

+ *Foundations:* Build Boolean expressions and evaluate them using truth tables
+ *Algebraic structure:* Master fundamental laws and prove identities
+ *Synthesis:* Construct any Boolean function from specifications (DNF, CNF)
+ *Optimization:* Minimize expressions using K-maps and Quine-McCluskey
+ *Completeness:* Determine which operation sets are functionally complete
+ *Implementation:* Design digital circuits with gates and memory elements
+ *Advanced topics:* Explore ANF, BDDs, and applications in cryptography


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
  - *NOT* ($not x$ or $overline(x)$) --- negation (reverses the value)
  - *AND* ($x and y$ or $x dot y$) --- conjunction (true only if both are true)
  - *OR* ($x or y$ or $x + y$) --- disjunction (true if at least one is true)
]

#example[Access control policy][
  Database query:

  `SELECT * FROM users WHERE (is_admin OR has_permission) AND NOT is_banned;`

  Formula: $(#`admin` or #`permission`) and not #`banned`$
  - admin=#True, permission=#False, banned=#False $=>$ access granted #YES
  - admin=#False, permission=#True, banned=#True $=>$ access denied #NO
]

#Block(color: orange)[
  *Note:* OR is _inclusive_ --- $x or y$ means "at least one," possibly both!
]

== Derived Operations: Building Blocks

More complex operations built from the basic three:

#definition[
  Derived Boolean operations:
  - *XOR* ($x xor y$): exclusive OR (true if exactly one is true)
    - Formula: $(x and not y) or (not x and y)$
    - Applications: error detection, encryption, bit manipulation

  - *Implication* ($x imply y$): "if $x$ then $y$"
    - Formula: $not x or y$
    - Applications: formal logic, theorem proving, constraint solving

  - *Equivalence* ($x iff y$): biconditional (true when values match)
    - Formula: $(x imply y) and (y imply x)$
    - Applications: equality testing, synchronization
]

== Example: XOR Operation

#example[
  XOR in computing:
  - Parity checking: $p = x_1 xor x_2 xor dots.h.c xor x_n$
  - Encryption: $c = m xor k$ (message XOR key)
  - Variable swap: `x ^= y; y ^= x; x ^= y`
  - Hash functions: mixing bits without bias
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
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } + if x == 2 { (right: 0.8pt) },
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
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } + if x == 1 { (right: 0.8pt) },
      inset: (x, y) => if y == 0 { 5pt } else { 3pt },
      table.header([*$x$*], [*$y$*], [*$not (x and y)$*], [*$not x or not y$*], [*Equal?*]),
      [0], [0], [1], [1], [#YES],
      [0], [1], [1], [1], [#YES],
      [1], [0], [1], [1], [#YES],
      [1], [1], [0], [0], [#YES],
    )
  ]

  Since all rows match, $not (x and y) equiv not x or not y$.
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
            & = x and (y or not y)         & quad & "(distributivity)" \
            & = x and 1                    & quad & "(excluded middle)" \
            & = x                          & quad & "(identity)"
  $
]

#example[
  Simplify $g(x, y, z) = (x or y) and (x or not y)$:

  $
    g(x, y, z) & = (x or y) and (x or not y) \
               & = x or (y and not y)        & quad & "(distributivity)" \
               & = x or 0                    & quad & "(contradiction)" \
               & = x                         & quad & "(identity)"
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
    x or x & = (x or x) and 1            & quad & "(identity)" \
           & = (x or x) and (x or not x) & quad & "(complement)" \
           & = x or (x and not x)        & quad & "(distributivity)" \
           & = x or 0                    & quad & "(complement)" \
           & = x                         & quad & "(identity)"
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
    x or (x and y) & = (x and 1) or (x and y) & quad & "(identity)" \
                   & = x and (1 or y)         & quad & "(distributivity)" \
                   & = x and 1                & quad & "(null law)" \
                   & = x                      & quad & "(identity)"
  $
]

#example[
  Similarly, $x and (x or y) = x$ by dual reasoning.
]

== The Duality Principle

#theorem[Duality Principle][
  If an identity holds in any Boolean algebra, then the _dual_ identity (obtained by swapping $or <=> and$ and $0 <=> 1$) also holds.
]

#align(center)[
  #table(
    columns: 3,
    align: (left, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Original Identity*], [*$<=>$*], [*Dual Identity*]),
    [$x or 0 = x$], [], [$x and 1 = x$],
    [$x or (x and y) = x$], [], [$x and (x or y) = x$],
    [$not (x or y) = not x and not y$], [], [$not (x and y) = not x or not y$],
    [$x or 1 = 1$], [], [$x and 0 = 0$],
  )
]

#Block(color: yellow)[
  *Practical consequence:* Every theorem proved gives two results.

  This symmetry reflects the dual structure of Boolean algebra axioms.
]

== De Morgan's Laws

#theorem[De Morgan's Laws][
  For all $x, y$ in a Boolean algebra:
  $
     not (x or y) & = not x and not y \
    not (x and y) & = not x or not y
  $
]

#Block(color: yellow)[
  *Intuition:* "NOT flips everything" --- negation distributes by _swapping_ AND $<=>$ OR!
]

#grid(
  columns: 2,
  gutter: 1em,
  example[
    Code conditionals

    `!(admin || vip)` $equiv$ `!admin && !vip`

    "Neither admin nor VIP"
  ],
  example[
    Circuit optimization

    $overline(A + B) = overline(A) dot overline(B)$

    NAND gate $equiv$ AND + NOT
  ],
)

== Connection to Lattices

#definition[
  A _lattice_ is a partially ordered set where any two elements $x, y$ have:
  - A _least upper bound_ (join): $x Join y$
  - A _greatest lower bound_ (meet): $x Meet y$
]

#definition[
  A _bounded distributive lattice_ is a lattice with bottom $bot$, top $top$, and distributivity:
  $
    x Meet (y Join z) = (x Meet y) Join (x Meet z)
  $
]

#definition[
  A _complemented lattice_ is a bounded lattice where every element $x$ has a complement $y$ such that $x Join y = top$ and $x Meet y = bot$.
]

#theorem[
  Every Boolean algebra is a complemented bounded distributive lattice.
]

== Complement Uniqueness

#theorem[
  In a Boolean algebra, each element has a _unique_ complement.
]

#proof[
  Suppose $y$ and $z$ are both complements of $x$. Then:
  $
    y & = y and 1                & quad & "(identity)" \
      & = y and (x or z)         & quad & "(" z "is complement of" x ")" \
      & = (y and x) or (y and z) & quad & "(distributivity)" \
      & = 0 or (y and z)         & quad & "(" y "is complement of" x ")" \
      & = (x and z) or (y and z) & quad & "(" z "is complement of" x ")" \
      & = (x or y) and z         & quad & "(distributivity)" \
      & = 1 and z                & quad & "(" y "is complement of" x ")" \
      & = z                      & quad & "(identity)"
  $

  Therefore $y = z$.
]

== Summary of Boolean Algebra Structure

#Block(color: purple)[
  *What we've established in this section:*

  + *Algebraic structure:* Boolean algebra $angle.l B, or, and, not, 0, 1 angle.r$ with five fundamental axioms
  + *Fundamental laws:* Idempotence, absorption, De Morgan's laws all follow from axioms
  + *Duality principle:* Swap $or <=> and$ and $0 <=> 1$ to get new theorems for free
  + *Connection to lattices:* Boolean algebras are complemented bounded distributive lattices
  + *Complement uniqueness:* Each element has exactly one complement
]

#Block(color: yellow)[
  *Key insight:*
  The same algebraic structure appears in logic (AND/OR/NOT), set theory ($union$, $inter$, $overline(x)$), and circuits (gates).
  This universality is why Boolean algebra is the foundation of computer science.
]

#Block(color: blue)[
  *What's next:*
  Now that we have the algebraic structure, we need systematic ways to _represent_ any Boolean function.
  This leads to normal forms (DNF, CNF) and minimization techniques (K-maps).
]


= Normal Forms
#focus-slide()

== From Structure to Representation

We've established the algebraic structure of Boolean algebra.

Now: how do we _represent_ any Boolean function systematically?

*The challenge:*
- There are $2^(2^n)$ different Boolean functions of $n$ variables
- For $n=3$: already 256 different functions!
- We need _canonical forms_ that work for ALL of them

*What we'll learn:*

#grid(
  columns: 2,
  gutter: 1em,
  [
    *Normal Forms*
    - DNF (Disjunctive Normal Form)
    - CNF (Conjunctive Normal Form)
    - Canonical forms (minterms/maxterms)
  ],
  [
    *Why they matter*
    - Circuit synthesis
    - Equivalence checking
    - Systematic simplification and minimization
  ],
)

#Block(color: yellow)[
  *Goal:* Express ANY Boolean function as a combination of simple building blocks.
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
  - A _term_ (or _product_, or _cube_) is a conjunction (AND) of literals
  - A _clause_ (or _sum_) is a disjunction (OR) of literals
]

#note[
  The term "cube" is commonly used in scientific literature for DNF components. \
  We use "term" and "cube" interchangeably, but "cube" provides a unique geometric interpretation!
]

#columns(2)[
  *Terms/Cubes (Products):*
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
  - Cube $x and not y and z$ is true only when: $x = 1$, $y = 0$, $z = 1$
  - Clause $x or not y or z$ is true when: $x = 1$ OR $y = 0$ OR $z = 1$ (or any combination)
]

#note[
  A single literal is both a 1-cube and a 1-clause. Constants: $0$ (empty cube) and $1$ (empty clause).
]

== Disjunctive Normal Form (DNF)

#definition[DNF][
  A Boolean formula is in _Disjunctive Normal Form (DNF)_ if it is a disjunction (OR) of cubes.

  General form: $(c_1) or (c_2) or dots or (c_k)$ where each $c_i$ is a cube (conjunction of literals).
]

#note[
  In DNF, we use "cube" to refer to each AND-component. This terminology emphasizes the geometric interpretation and aligns with scientific literature on minimization.
]

#example[
  DNF formulas:
  - $(x and y) or (not x and z)$ --- "($x$ and $y$) OR ($not x$ and $z$)" ~(2 cubes)
  - $(x and not y and z) or (not x and y) or z$ --- three alternatives ~(3 cubes)
  - $x or (y and not z)$ --- still DNF (mixed form) ~(2 cubes: $x$ and $y and not z$)
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
  - A _minterm_ is a maximal cube containing all $n$ variables (each exactly once, positive or negated)
  - A _maxterm_ is a maximal clause containing all $n$ variables (each exactly once, positive or negated)
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
  A _sum of products (SoP)_ (also called _canonical sum of minterms_) is a DNF where each cube is a minterm.

  General form: $f(x_1, dots, x_n) = limits(or.big)_(i in I) m_i$ where $I subset.eq {0, 1, dots, 2^n - 1}$
]

#note[
  In SoP, each cube is _maximal_ (contains all variables). This form is unique for any given function!
]

#Block(color: yellow)[
  *Recipe:* Find rows where $f = 1$ $=>$ write minterms $m_i$ $=>$ OR them together.
]

#Block(color: blue)[
  *Why it works:* Each minterm is 1 for exactly one row $=>$ OR gives 1 when ANY minterm is 1.
]

== SoP: Example

#example[
  For the function $f$ with truth table:

  #place(right, dx: -5cm, dy: -2em)[
    #table(
      columns: 4,
      align: center,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } + if x == 2 { (right: 0.4pt) },
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

  *Step 1:* Identify rows where $f = 1$: rows 1, 3, 6, 7

  *Step 2:* Write corresponding minterms:
  - Row 1 (001): $m_1 = not x and not y and z$
  - Row 3 (011): $m_3 = not x and y and z$
  - Row 6 (110): $m_6 = x and y and not z$
  - Row 7 (111): $m_7 = x and y and z$

  *Step 3:* OR them together:
  $
    f & = m_1 or m_3 or m_6 or m_7 = \
      & = (not x and not y and z) or (not x and y and z) or (x and y and not z) or (x and y and z) = \
      & = overline(x) thin overline(y) z + overline(x) y z + x y overline(z) + x y z
  $
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
  *What we've learned about normal forms:*

  + *Building blocks:* Literals, cubes (AND of literals), clauses (OR of literals)
  + *DNF (Disjunctive Normal Form):* OR of cubes --- "output is 1 if ANY scenario holds"
  + *CNF (Conjunctive Normal Form):* AND of clauses --- "ALL constraints must be satisfied"
  + *Minterms/Maxterms:* Maximal cubes/clauses containing all variables
  + *SoP/PoS (Canonical forms):* Unique representation using all minterms/maxterms
  + *Shannon expansion:* Recursive decomposition by cofactors
  + *Universality:* Every Boolean function has both DNF and CNF representations
]

#note(title: "Terminology")[
  "Cube" and "term" are interchangeable for DNF components, but "cube" provides unique geometric interpretation and aligns with minimization literature.
]

#Block(color: yellow)[
  *Key insight:*
  Normal forms let us synthesize ANY circuit from a truth table.
  But canonical forms are often huge --- we need minimization techniques!
]

// #Block(color: blue)[
//   *What's next:*
//   Canonical SoP/PoS work but are wasteful (many redundant gates).
//   We'll learn minimization techniques: algebraic manipulation, K-maps (visual), and Quine-McCluskey (systematic).
// ]


= Minimization
#focus-slide()

// TODO: use "overline" instead of "not" (not *everywhere*, but generally...), since it is easier to read. That way, "and" could be omitted, and "or" could be replaced by "+".

== The Minimization Problem

We can express _any_ Boolean function from its truth table using SoP or PoS.

But the result is often *not minimal*.

#example[
  Consider $f(x, y, z) = (not x and not y and z) or (not x and y and z) or (x and y and not z) or (x and y and z)$

  Canonical DNF: 4 terms, 12 literals total (7 gates needed).

  After minimization: $f = (not x and z) or (x and y)$ --- only 4 literals (3 gates).

  *Result:* 57% fewer gates, less power, faster operation.
]

#grid(
  columns: 2,
  column-gutter: 1em,

  Block(color: blue)[
    *Why minimize?*
    - Cheaper: Fewer gates = lower cost
    - Power: Each gate consumes energy
    - Speed: Fewer delays = faster
    - Yield: Fewer components = fewer defects
    - Verification: Simpler = easier to test
  ],

  Block(color: orange)[
    *The challenge:*
    Minimization is NP-complete.

    Practical techniques:
    - K-maps (2-5 vars)
    - Quine-McCluskey (6-8 vars)
    - ESPRESSO heuristics (100+ vars)
  ],
)

// #note[
//   - 1950s-70s: gates expensive, minimize for cost.
//   - Today: power expensive (battery, cooling), minimize for efficiency.
// ]

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
  This single-distance property eliminates transition errors in electromechanical systems.
]

#example[
  3-bit Gray code sequence:

  #align(center)[
    #table(
      columns: 4,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
      inset: (x, y) => if y == 0 { 5pt } else { 3pt },
      table.header([*Decimal*], [*Binary*], [*Gray Code*], [*Bit Changed*]),
      [0], [000], [000], [(bit 1)],
      [1], [001], [001], [bit 0],
      [2], [010], [011], [bit 1],
      [3], [011], [010], [bit 0],
      [4], [100], [110], [bit 2],
      [5], [101], [111], [bit 0],
      [6], [110], [101], [bit 1],
      [7], [111], [100], [bit 0],
    )
  ]
]

#Block(color: yellow)[
  *K-map connection:*
  Adjacent cells in Karnaugh maps use Gray code ordering.
  This ensures neighboring cells differ in exactly one variable, making algebraic simplification patterns visually apparent.

  *The key identity:* $(x and y) or (x and not y) = x$ #h(1em) (variable $y$ cancels out)
]

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
  A _Karnaugh map (K-map)_ is a 2D grid representation of a truth table, arranged using Gray code so that adjacent cells (including wraparound) differ in exactly one variable.
]

#Block(color: yellow)[
  *Core idea:* K-maps transform algebraic minimization into visual pattern recognition.
  Adjacent groups of 1s correspond to terms that can be simplified by eliminating variables.
]

#columns(2)[
  *Advantages:*
  - Visual pattern recognition
  - Fast for small functions (2-5 variables)
  - Shows all simplification opportunities
  - Educational value

  #colbreak()

  *Limitations:*
  - Practical only for ≤6 variables
  - Manual grouping required
  - Doesn't scale to large functions
  - Use Quine-McCluskey or ESPRESSO for 6+ variables
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
      align: (center, center, left),
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

*Grouping rules:*
1. Mark all 1s in the K-map
2. Find essential groups (cells covered by only one group)
3. Cover remaining 1s with largest rectangles (8, 4, 2, 1)
4. Use wraparound on edges and corners
5. Minimize overlap but allow if needed

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
      & = A B (C + overline(C)) + overline(A) B C + overline(A) overline(B) C   & quad & "(factor)" \
      & = A B + overline(A) B C + overline(A) overline(B) C                     & quad & "(complement)"
  $

  *Step 2:* Apply more combining
  $
    f & = A B + overline(A) C (B + overline(B)) & quad & "(factor)" \
      & = A B + overline(A) C                   & quad & "(complement)"
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
    X Y + overline(X) Z + Y Z & = X Y + overline(X) Z + (X + overline(X)) Y Z   & quad & "(complement)" \
                              & = X Y + overline(X) Z + X Y Z + overline(X) Y Z & quad & "(distributive)" \
                              & = X Y (1 + Z) + overline(X) Z (1 + Y)           & quad & "(factor)" \
                              & = X Y + overline(X) Z                           & quad & "(null: " 1 + X = 1 ")"
  $
]

#note[
  *Intuition:* If $Y Z$ is true, then either $X Y$ or $overline(X) Z$ must be true, so $Y Z$ is redundant.
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

#v(-0.5em)
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
#v(-0.5em)

*Explanation:*
- $m_(1,5)$ (−01) and $m_(3,7)$ (−11): dashes align at pos. 0, differ only in bit 1 $=>$ combine to $m_(1,3,5,7)$ (−−1) #YES
- $m_(1,3)$ (0−1) and $m_(5,7)$ (1−1): dashes align at pos. 1, differ only in bit 0 $=>$ combine to $m_(1,3,5,7)$ (−−1) #YES
- $m_(6,7)$ (11−): alone with dash at pos. 2 $=>$ cannot combine #NO

*Result:*
One size-4 implicant formed: $m_(1,3,5,7)$ (−−1).
One size-2 implicant remains uncombined: $m_(6,7)$ (11−).

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

#grid(
  columns: 2,
  gutter: 1em,

  example[
    Consider this prime implicant chart:

    #align(center)[
      #table(
        columns: 4,
        stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } + if x == 0 { (right: 0.8pt) },
        [], [$m_i$], [$m_j$], [$m_k$],
        [$"PI"_1$], [$cross$], [$cross$], [],
        [$"PI"_2$], [], [$cross$], [$cross$],
        [$"PI"_3$], [], [], [$cross$],
      )
    ]
  ],

  Block(color: yellow)[
    *Key insight:*
    If a minterm has _only one_ $cross$, the~corresponding prime implicant is _essential_ and must be included in any minimal cover.
  ],
)

- Minterm $m_i$ is covered only by $"PI"_1$ $=>$ $"PI"_1$ is _essential_ $=>$ it _must_ be included
- Minterm $m_j$ is covered by both $"PI"_1$ and $"PI"_2$ $=>$ no EPI
- Minterm $m_k$ is covered by both $"PI"_2$ and $"PI"_3$ $=>$ no EPI

*Conclusion:* $"PI"_1$ _must_ be included. For remaining minterms, choose either $"PI"_2$ or $"PI"_3$.

== Petrick's Method

When multiple prime implicants remain after selecting essentials:

#definition[
  _Petrick's method_ finds all combinations of prime implicants that cover the remaining minterms, so you can pick the one with the lowest cost.

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
    align: horizon,
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
- $P_1$: −00− covers ${0, 1, 8, 9}$
- $P_2$: −0−0 covers ${0, 2, 8, 10}$
- $P_3$: −−10 covers ${2, 6, 10, 14}$
- $P_4$: 01−1 covers ${5, 7}$

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

- $P_4$ is essential (only covers ${5, 7}$)
- After selecting $P_4$, need to cover ${0, 1, 2, 6, 8, 9, 10, 14}$

*Minimal solution:* $f = P_1 + P_3 + P_4$ ~_or_~ $f = P_2 + P_3 + P_4$

== Complexity of Minimization

#theorem[
  Boolean function minimization is *NP-complete*.
]

#note[
  *Consequence:* For large functions, we use heuristics (ESPRESSO, ABC) instead of exact methods. Modern CAD tools focus on technology mapping and multi-objective optimization (timing, power, area).
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
  *Key insight:*
  Minimization transforms algebraic simplification into visual pattern recognition (K-maps) or systematic algorithms (Q-M).
  For small functions (≤5 vars), K-maps are instant. For large functions, we use heuristics and accept near-optimal solutions.
]

#Block(color: blue)[
  *What's next:*
  All our techniques (DNF, CNF, minimization) use AND/OR/NOT. But there's a completely different approach using only XOR and AND --- Algebraic Normal Form (ANF). This gives us _unique_ canonical representation, crucial for cryptography.
]


= Algebraic Normal Form
#focus-slide()

== Motivation: A Different Representation

All our normal forms (DNF, CNF) use AND, OR, NOT. They work great for circuits but have redundancy: the same function has infinitely many equivalent representations.

#example[
  $f = (x and y) or (x and not y) = x and (y or not y) = x and 1 = x$
]

*For cryptography and formal verification, we need a _unique_ canonical form.*

#Block(color: blue)[
  *ANF (Algebraic Normal Form):* Use only XOR ($xor$) and AND ($and$).

  Result: Every Boolean function has a _unique_ polynomial representation over $"GF"(2)$.

  Note: $overline(x) = x xor 1$, so NOT is not needed.
]

== Why ANF? Applications and Advantages

So far, we've built Boolean functions using AND ($and$), OR ($or$), and NOT ($overline(x)$).

This led us to:
- DNF and CNF (canonical forms)
- K-maps and Quine-McCluskey (minimization)
- Circuit design with standard gates

#Block(color: blue)[
  *Question:* Can we represent Boolean functions using only AND ($and$) and XOR ($xor$)?

  That is, without OR and NOT operations?
]

The answer is yes, and this leads to a completely different algebraic structure with important theoretical and practical applications.

#Block(color: yellow)[
  *Why ANF matters:*
  - *Cryptography:* Analyze security of encryption algorithms (AES S-boxes)
  - *Coding theory:* Design error-correcting codes (Reed-Muller codes)
  - *Formal verification:* Unique canonical form simplifies equivalence checking
  - *Quantum computing:* XOR gates are easier to implement than OR gates
]

== Introducing Algebraic Normal Form

#definition[
  An _Algebraic Normal Form_ (ANF), also called a _Zhegalkin polynomial_, represents a Boolean function as a polynomial over $FF_2$ (the field {0, 1}) using:
  - XOR ($xor$) for addition (modulo 2)
  - AND ($and$) for multiplication
  - Constants 0 and 1
]

#example[
  The function $f(x, y, z) = x y xor x z xor y z xor x xor 1$ is in ANF.

  Term structure:
  - $x y$, $x z$, $y z$ are degree-2 terms (quadratic)
  - $x$ is a degree-1 term (linear)
  - $1$ is a degree-0 term (constant)

  The algebraic degree of this function is 2.
]

#note(title: "Notation")[
  We write XOR as $xor$ or $+$, and AND as $and$, $dot$, or by juxtaposition ($x y$).
]

== Properties of XOR

#table(
  columns: 3,
  align: left,
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  [*Property*], [*OR*], [*XOR*],
  [Characteristic], [Idempotent \ $x or x = x$], [Self-inverse \ $x xor x = 0$],
  [Negation], [Requires NOT], [$overline(x) = x xor 1$],
)

These differences enable important applications:

#grid(
  columns: 2,
  gutter: 1em,
  [
    *Cryptography* 🔐
    - Stream cipher design
    - S-box analysis (DES, AES)
    - Algebraic attacks
    - Linear cryptanalysis resistance
  ],
  [
    *Coding Theory* 📡
    - Error-correcting codes
    - Reed-Muller codes
    - Parity check matrices
    - LDPC codes
  ],
)

#note[
  In $FF_2$, XOR corresponds to addition and AND to multiplication. \
  ANF treats Boolean functions as polynomials over this field.
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

== Comparing ANF and DNF

#align(center)[
  #table(
    columns: 3,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Property*], [*DNF*], [*ANF*]),
    [*Operations*], [AND, OR, NOT], [AND, XOR only],
    [*Structure*], [OR of AND-terms], [XOR of AND-terms],
    [*Example*], [$x y or overline(x) z$], [$x y xor x z xor 1$],

    table.hline(stroke: 0.4pt + gray),
    [*Canonical form*], [Yes (via minterms)], [Yes (unique)],
    [*Representations*], [Many variants possible], [Exactly one],

    table.hline(stroke: 0.4pt + gray),
    [*Negation*], [Explicit ($overline(x)$)], [$x xor 1$],
    [*$x + x =$*], [$x$ (idempotent)], [$0$ (self-inverse)],
    [*Identity element*], [$x or 0 = x$], [$x xor 0 = x$],

    table.hline(stroke: 0.4pt + gray),
    [*Degree notion*], [Not applicable], [Max monomial size],
    [*Primary use*], [Circuit synthesis], [Cryptographic analysis],
  )
]

// #Block(color: orange)[
//   *Key observation:* The self-inverse property $(x xor x = 0)$ fundamentally distinguishes ANF from DNF, leading to different algebraic structures and applications.
// ]

== Uniqueness of ANF Representation

#theorem[
  Every Boolean function $f: {0,1}^n to {0,1}$ has _exactly one_ ANF representation.
]

#proof[
  Consider Boolean functions as a vector space over $FF_2$:

  + There are $2^(2^n)$ Boolean functions on $n$ variables
  + There are $2^n$ possible monomials, giving $2^(2^n)$ possible ANFs
  + The mapping $"ANF" to "Boolean function"$ is a linear bijection over $FF_2$

  Therefore, each function has exactly one ANF representation.
]

#Block(color: yellow)[
  *Significance:* Unlike DNF/CNF (which have multiple equivalent forms), ANF is always canonical.

  This eliminates the need for minimization in the ANF context.
]

#note[
  The uniqueness follows from the linear algebra structure over $FF_2$. \
  The Möbius transform (used in Pascal's triangle method) provides an explicit bijection.
]

== Monomials in ANF

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
  The _algebraic degree_ of a Boolean function in ANF is the maximum number of variables in any monomial with coefficient 1.
]

#example[
  #table(
    columns: 3,
    align: (left, left, center),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Function*], [*ANF*], [*Degree*]),
    [NOT], [$f(x) = x xor 1$], [1],
    [XOR], [$f(x,y) = x xor y$], [1],
    [AND], [$f(x,y) = x y$], [2],
    [NAND], [$f(x,y) = x y xor 1$], [2],
    [Majority], [$f(x,y,z) = x y xor x z xor y z$], [2],
    [Full ANF], [$f(x,y,z) = x y z xor x y xor dots.h xor 1$], [3],
  )
]

== Why Algebraic Degree Matters

*Application:* Cryptography and security

In encryption systems, functions transform data to hide it from attackers.
The algebraic degree determines how _complex_ these transformations are.

#Block(color: yellow)[
  *Key insight:* Low-degree functions can be broken using linear algebra!

  If a function has degree 2-3, an attacker can:
  1. Express it as ANF (polynomial over $FF_2$)
  2. Treat each product term (like $x y z$) as a _new variable_
  3. Solve the resulting _linear_ system of equations

  This is called *linearization attack*.
]

== Example: Breaking a Low-Degree Function

#example[
  Suppose an encryption system uses $f(x, y, z) = x xor y z$ (degree 2).

  *Linearization attack:*
  - *Step 1:* ANF has nonlinear term $y z$ $=>$ introduce variable $w = y z$
  - *Step 2:* Rewrite as $f = x xor w$ $=>$ now linear in $x, w$!
  - *Step 3:* Collect pairs $(x_i, y_i, z_i) maps f_i$ $=>$ equations $x_i xor w_i = f_i$ where $w_i = y_i z_i$
  - *Step 4:* Solve linear system over $FF_2$ $=>$ recover secret values $=>$ encryption broken!

  *Why it works:* Only 1 nonlinear term $=>$ only 1 new variable $=>$ system stays small and solvable.
]

#Block(color: orange)[
  *Defense:* High-degree function (7-8) has many nonlinear terms $=>$ too many new variables $=>$ system becomes huge and unsolvable.
]

== Degree in Real Encryption Systems

#Block(color: green)[
  *Why encryption functions need high degree:*

  Modern encryption (like AES, used in HTTPS, WiFi, banking) uses special functions called _S-boxes_.
  These are Boolean functions $FF_2^8 to FF_2^8$ (8 input bits $to$ 8 output bits).

  *Design requirement:* Degree must be close to maximum!
  - Maximum possible degree for 8 variables: 8
  - But degree-8 has special mathematical structure (too predictable)
  - *AES uses degree 7* --- highest practical degree

  If degree were 2-3, attackers could solve the system and break encryption.
]

#Block(color: teal)[
  *Historical context:* Older encryption (DES, 1970s) used degree 6. Later discovered vulnerable to algebraic attacks. Modern systems learned from this mistake.
]

== Methods for Computing ANF

We will examine three methods for computing ANF from truth tables:

#align(center)[
  #table(
    columns: 5,
    align: (left, center, center, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Method*], [*Complexity*], [*Variables*], [*Difficulty*], [*Best suited for*]),
    [Direct computation], [$O(2^(2n))$], [1-3], [High], [Theoretical understanding],
    [Pascal's triangle], [$O(2^n)$], [1-5], [Medium], [Hand calculations],
    [Karnaugh map], [$O(2^n)$], [2-4], [Low], [Visual intuition],
  )
]

#Block(color: blue)[
  *Learning approach:*
  + Begin with K-map method (most intuitive)
  + Master Pascal's triangle (most practical)
  + Understand direct method (theoretical foundation)
]

Each method provides different insights into the structure of ANF.

== Method 1: Direct Computation

#Block(color: teal)[
  *Idea:* Solve a system of linear equations over $FF_2$ (arithmetic mod 2).
]

For function $f: FF_2^n to FF_2$, we want to find coefficients $a_S$ such that:
$
  f(x_1, ..., x_n) = xor.big_(S subset.eq {1,...,n}) (a_S product_(i in S) x_i)
$

where $xor$ denotes XOR and $product$ denotes AND.

Each row of the truth table gives one linear equation!

#Block(color: orange)[
  *Remember:* In $FF_2$, addition is XOR:
  - $1 xor 1 = 0 xor 0 = 0$
  - $1 xor 0 = 0 xor 1 = 1$
]

== Direct Computation: Example (Setup)

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
]

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

== Direct Computation: Solution

*Solving the system step-by-step:*
- Equation 1: $a_0 = 1$
- Equation 2: $(a_0 xor a_2 = 1) => (1 xor a_2 = 1) => a_2 = 0$
- Equation 3: $(a_0 xor a_1 = 1) => (1 xor a_1 = 1) => a_1 = 0$
- Equation 4: $(1 xor 0 xor 0 xor a_3 = 0) => (1 xor a_3 = 0) => a_3 = 1$

*Result:*~ $f(x, y) = 1 xor x y$, which is equivalent to $f = x nand y$.

#Block(color: yellow)[
  *Key insight:* Each row in the truth table gives exactly one linear equation over $FF_2$.
  - With $n$ variables, we get $2^n$ equations in $2^n$ unknowns (the ANF coefficients)
  - The system is always solvable (ANF exists and is unique)
  - But for $n > 4$, solving $2^n$ equations manually becomes impractical!
]

== Method 2: Pascal's Triangle Method

#Block[
  *Fast systematic method* using a butterfly/pyramid pattern!
]

*Algorithm:*
+ Write function values $f$ in a column (in binary order: 000, 001, 010, ...)
+ Create next column: XOR each adjacent pair $(f_i xor f_(i+1))$
+ Repeat step 2 until only one value remains
+ The *first value* of each column is an ANF coefficient

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
  For $a_(x y)$, corresponding to input 110 = ${x, y}$:
  $
    a_(x y) & = f(000) xor f(010) xor f(100) xor f(110) \
            & = 1 xor 0 xor 0 xor 0 = 1
  $
]

#Block(color: teal)[
  *Historical note:*~
  Related to Reed-Muller codes and Fast Walsh-Hadamard Transform!
]

== Method 3: Karnaugh Map Method

#Block(color: blue)[
  Use K-map regions to identify monomials in ANF.
]

*Algorithm:*
+ Fill K-map with function values
+ For each possible monomial:
  - Identify its rectangular region in the K-map
  - If the top-left cell equals 1, include the monomial
+ Combine all selected monomials using XOR

#Block(color: orange)[
  *Key differences from minimization:*
  - Check _all_ rectangular regions, not just maximal ones
  - Combine terms with XOR instead of OR
  - Top-left cell determines inclusion
]

== K-Map Method: Example

#example[
  Find ANF for $f(x,y) = sum m(1,2)$:

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
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
    [
      *Monomial analysis:*
      + Constant (all cells): top-left = 0 $=>$ exclude
      + $x$ (row $x=1$): top-left = 1 $=>$ include
      + $y$ (column $y=1$): top-left = 1 $=>$ include
      + $x y$ (cell at 11): value = 0 $=>$ exclude

      *Result ANF:* $f = x xor y$
    ],
  )
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

*Result:*~ $f = 1 xor z xor y z xor x y z$

== Comparison of ANF Construction Methods

#align(center)[
  #table(
    columns: 4,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Method*], [*Pros*], [*Cons*], [*Best for*]),
    [
      📐*Direct computation*
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
      🔺*Pascal's triangle*
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
      🗺️*K-map method*
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

  + *Uniqueness:* Every Boolean function has exactly one ANF representation
  + *Completeness:* ANF can represent any Boolean function
  + *Operations:* Uses only XOR ($xor$) and AND --- no NOT needed
  + *Algebraic degree:* Maximum degree of monomials (crucial for cryptography)
  + *Self-inverse:* $x xor x = 0$ (unlike $x or x = x$)
  + *Linearity:* XOR is linear over $FF_2$, making polynomial algebra work
]

#Block(color: yellow)[
  *Key insight:*
  ANF trades circuit efficiency (uses more gates than DNF/CNF) for mathematical uniqueness.
  In cryptography, the algebraic degree in ANF is a direct measure of security against algebraic attacks.
]

#note[
  *Computational efficiency:* Pascal's triangle method is the fastest way to compute ANF from truth tables. K-map method is more intuitive but limited to small functions.
]

== ANF in Cryptography: Why It Matters

#Block(color: purple)[
  *Why cryptographers care about ANF?*

  ANF reveals the _algebraic structure_ of cryptographic functions.
  This structure determines vulnerability to algebraic attacks!
]

#grid(
  columns: 2,
  gutter: 1em,
  [
    *Algebraic Attacks*

    Express cipher as polynomial system over $FF_2$:
    - Each round forms polynomial equations
    - Solve using Gröbner basis algorithms
    - Low degree enables efficient attacks

    #note[
      If an S-box has degree 2, attackers can linearize the system and solve in polynomial time.
    ]
  ],
  [
    *S-Box Design Criteria*

    Secure S-boxes require:
    - High algebraic degree (nonlinearity)
    - Balanced output distribution
    - Absence of linear structures

    #note[
      The AES S-box has degree 7 (near maximum of 8), providing resistance to algebraic attacks.
    ]
  ],
)

== ANF in Cryptographic Primitives

#grid(
  columns: 2,
  gutter: 1em,
  [
    *Stream Cipher Design*

    Boolean functions in stream ciphers:
    - Filter functions for LFSRs
    - Combining functions
    - Must resist correlation and algebraic attacks

    Degree requirements depend on cipher structure.
  ],
  [
    *Important Function Classes*

    - *Bent functions:* Maximum nonlinearity
    - *Balanced functions:* Equal 0s and 1s in output
    - *Correlation-immune:* Statistical attack resistance
    - *Resilient:* Balanced and correlation-immune
  ],
)

#Block(color: orange)[
  *Case study:*
  The E0 stream cipher (used in Bluetooth) was cryptanalyzed due to insufficient algebraic degree in its combining function.
]

== Converting Between ANF and DNF

Two approaches for converting between representations:

#align(center)[
  #table(
    columns: 3,
    align: (left, left, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Method*], [*Advantages*], [*Disadvantages*]),
    [
      *Algebraic* \
      Direct application \
      of identities
    ],
    [
      - Direct transformation \
      - Shows structural relationships
    ],
    [
      - Complex algebraic expansions \
      - Error-prone for large functions \
      - Exponential term growth
    ],

    table.hline(stroke: 0.4pt),
    [
      *Via truth table* \
      Truth table as \
      intermediate form
    ],
    [
      - Systematic procedure \
      - Always succeeds \
      - Clear verification steps
    ],
    [
      - Requires complete enumeration \
      - Additional computational step
    ],
  )
]

#Block(color: yellow)[
  *Recommended approach:* Use truth table as intermediate representation.

  This method is systematic, reliable, and suitable for examination contexts.
]

#note[
  Direct algebraic conversion requires expanding $x xor y = (x and overline(y)) or (overline(x) and y)$, which becomes complex for multi-variable functions.
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
  *Key concepts covered:*

  #grid(
    columns: 2,
    gutter: 1em,
    [
      *Theoretical foundations*
      + ANF as polynomials over $FF_2$
      + Representation using XOR and AND
      + Unique canonical form
      + Algebraic degree as security parameter
    ],
    [
      *Computational methods*
      + Pascal's triangle (efficient)
      + Karnaugh map (intuitive)
      + Direct computation (theoretical)
      + Conversion via truth tables
    ],
  )

  *Applications*
  - Cryptographic analysis: S-box evaluation, algebraic attacks
  - Coding theory: Reed-Muller codes, error correction
  - Hardware optimization: XOR-based circuit design
]

#Block(color: yellow)[
  *Key insight:*
  ANF provides a _unique_ canonical form (unlike DNF/CNF which have infinite equivalent representations).
  The algebraic degree in ANF directly measures cryptographic security --- higher degree means more resistance to attacks.
]

#Block(color: blue)[
  *What's next:*
  We've seen many operation sets: {AND, OR, NOT}, {XOR, AND, 1}, {NAND}, etc.
  Which sets can express _every_ Boolean function? This leads to functional completeness and Post's criterion.
]


= Functional Completeness
#focus-slide()

== The Fundamental Question

We've seen many Boolean operations: AND, OR, NOT, XOR, NAND, NOR, implication, equivalence...

#Block(color: purple)[
  *The million-dollar question:*

  Imagine you're designing a new computer chip.
  Manufacturing costs depend on how many _different types_ of gates you need.
  Each gate type requires different masks, testing procedures, and inventory.

  *Question:* What's the _minimum_ set of operations needed to build _everything_?

  Can we manufacture chips with just ONE type of gate?
  Or do we absolutely need three types (AND, OR, NOT)?

  This isn't just theoretical --- Intel, AMD, and ARM face this question for every new processor!
]

*Central question:* Which sets of operations can express _every_ Boolean function?

For example:
- Can we build everything using only ${and, or, not}$? #YES
- Can we build everything using only ${"NAND"}$? #YES (just one gate type!)
- Can we build everything using only ${and, or}$? #NO (can't make NOT)
- Can we build everything using only ${xor}$? #NO (only linear functions)

#note[
  *Post's theorem (1941):* There are exactly FIVE "weaknesses" a set can have. If a set avoids all five, it's functionally complete. Having even one weakness means some functions cannot be expressed.
]

== Functional Closure

#definition[
  Let $F$ be a set of Boolean functions.
  The _functional closure_ $[F]$ is the smallest set containing $F$ and closed under:
  + *Composition:* If $f, g in [F]$, then $h(x) = f(g(x)) in [F]$
  + *Identification:* If $f(x_1, ..., x_n) in [F]$, then $f(x, x, x_3, ..., x_n) in [F]$
  + *Permutation:* If $f(x_1, ..., x_n) in [F]$, then $f(x_(sigma(1)), ..., x_(sigma(n))) in [F]$ for any permutation $sigma$
  + *Introduction of fictitious variables:* If $f(x_1, ..., x_n) in [F]$, then $f(x_1, ..., x_n, x_(n+1)) in [F]$
]

Informally, $[F]$ contains all functions you can build by _combining_ functions from $F$.

#note[
  The closure operations keep the important structure while allowing you combine functions freely.
]

== Functional Completeness

#definition[
  A set $F$ of Boolean functions is _functionally complete_ (or _universal_) if its closure $[F]$ contains all possible Boolean functions.

  Equivalently: every Boolean function can be expressed using only operations from $F$.
]

#example[
  *Complete sets:*
  - ${and, or, not}$ --- the classical basis
  - ${and, not}$ --- AND with negation
  - ${or, not}$ --- OR with negation
  - ${"NAND"}$ --- NAND alone (Sheffer stroke)
  - ${"NOR"}$ --- NOR alone (Peirce arrow)

  *Incomplete sets:*
  - ${and, or}$ --- cannot produce NOT
  - ${xor}$ --- only produces linear functions
  - ${not}$ --- only produces constants and negations
]

== Why Functional Completeness Matters

#grid(
  columns: (1fr, 1fr),
  gutter: 1.5em,
  [
    *Circuit Design*

    Functionally complete sets determine which gates are sufficient to build any digital circuit.

    #note[
      NAND and NOR gates are universal --- entire processors can be built using only NAND gates!
    ]
  ],
  [
    *Programming Languages*

    Programming languages must provide functionally complete sets of operators.

    #example[
      C provides: `&&`, `||`, `!`, `^` \
      Each subset {`&&`, `!`} or {`||`, `!`} is complete.
    ]
  ],
)

#note[
  *Practical constraint:* Manufacturing circuits with a single gate type (NAND or NOR) simplifies design, testing, and production.
]

== Post's Five Classes

#definition[
  A Boolean function $f: {0,1}^n to {0,1}$ belongs to class:

  + *$T_0$ (preserves 0):* $f(0, 0, ..., 0) = 0$
  + *$T_1$ (preserves 1):* $f(1, 1, ..., 1) = 1$
  + *$S$ (self-dual):* $f(overline(x)_1, ..., overline(x)_n) = overline(f(x_1, ..., x_n))$
  + *$M$ (monotone):* $x <= y => f(x) <= f(y)$ ~(bitwise comparison)
  + *$L$ (linear):* $f$ has ANF of degree $<= 1$ ~(no AND terms)
]

#note[
  These classes are _closed under composition_: combining functions from a class stays within that class.
  If all operations in $F$ belong to one class, $[F]$ cannot contain all Boolean functions.
]

== Post's Classes: Examples

#align(center)[
  #table(
    columns: 6,
    align: (right, center, center, center, center, center),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } + if x == 0 { (right: 0.4pt) },
    inset: (x, y) => if x == 0 { 5pt } else { 3pt },
    table.header([*Function*], [$T_0$], [$T_1$], [$S$], [$M$], [$L$]),
    [Constant 0], [#YES], [#NO], [#NO], [#YES], [#YES],
    [Constant 1], [#NO], [#YES], [#NO], [#YES], [#YES],
    [Identity $x$], [#YES], [#YES], [#YES], [#YES], [#YES],
    [NOT $overline(x)$], [#NO], [#NO], [#YES], [#NO], [#YES],
    [AND $x and y$], [#YES], [#YES], [#NO], [#YES], [#NO],
    [OR $x or y$], [#YES], [#YES], [#NO], [#YES], [#NO],
    [XOR $x xor y$], [#YES], [#NO], [#NO], [#NO], [#YES],
    [NAND $overline(x and y)$], [#NO], [#NO], [#NO], [#NO], [#NO],
    [NOR $overline(x or y)$], [#NO], [#NO], [#NO], [#NO], [#NO],
    [Implication $x imply y$], [#NO], [#YES], [#NO], [#NO], [#NO],
  )
]

#note[
  NAND and NOR belong to _none_ of the five classes --- this is why they are universal.
]

== Understanding Post's Classes

#grid(
  columns: 2,
  gutter: 1em,
  [
    *$T_0$ and $T_1$ (Constants)*

    $T_0$: maps all-0s to 0; $T_1$: maps all-1s to 1

    - AND, OR: both $T_0$ and $T_1$
    - XOR: $T_0$ only
    - NOT: neither
  ],
  [
    *$L$ (Linear)*

    ANF degree $<= 1$:~
    $f = a_0 xor a_1 x_1 xor dots.h.c xor a_n x_n$

    - Constants, NOT, XOR: linear
    - AND, OR: not linear
  ],

  [
    *$M$ (Monotone)*

    $x <= y => f(x) <= f(y)$

    - AND, OR: monotone
    - NOT, XOR: not monotone
  ],
  [
    *$S$ (Self-Dual)*

    $f(overline(x)) = overline(f(x))$

    - NOT: self-dual
    - Median: $x y + y z + x z$
  ],
)

#note[
  Each class is closed under composition. If $F subset.eq C$ for some class $C$, then $[F] subset.eq C$, preventing completeness.
]

== Post's Criterion

#theorem[
  A set $F$ of Boolean functions is functionally complete if and only if $F$ contains at least one function that does _not_ belong to each of the five Post classes:

  $
    F "is complete" <==> cases(
      exists f in F : f in.not T_0,
      exists f in F : f in.not T_1,
      exists f in F : f in.not S,
      exists f in F : f in.not M,
      exists f in F : f in.not L
    )
  $

  #note[
    Each $f$ can be different, or the _same_ function can escape multiple classes.
  ]
]

Equivalently: $F$ is complete $iff$ $F$ is not contained in any Post class.

#note[
  *Practical test:* To prove $F$ is complete, find five functions (possibly the same) escaping each class.
]

== Post's Criterion: Intuition

Each Post class represents a "weakness":
- *$T_0$:* Cannot create constant 1 from all-0 input
- *$T_1$:* Cannot create constant 0 from all-1 input
- *$S$:* Cannot break symmetry between $x$ and $overline(x)$
- *$M$:* Cannot decrease output when input increases
- *$L$:* Cannot create nonlinear interactions (AND-like)

Escaping all five weaknesses provides power to build any function.

== Post's Criterion: Proof Sketch

The full proof is technical, but the key steps are:

*Step 1:* Show that if $F subset.eq T_0$, then $[F] subset.eq T_0$ ~(similarly for $T_1, S, M, L$).

*Proof:* Composition preserves each class. For example, if $f, g in T_0$, then:
$
  h(0, ..., 0) = f(g(0, ..., 0), ...) = f(0, ..., 0) = 0
$

*Step 2:* If $F$ escapes all five classes, construct ${and, not}$ from $F$.

This involves:
- Using non-$T_0$ and non-$T_1$ to create constants
- Using non-$S$ to break self-duality
- Using non-$M$ to enable decreasing behavior
- Using non-$L$ to create nonlinear terms

*Step 3:* Since ${and, not}$ is complete, $[F]$ contains all functions. $qed$

== Verifying Completeness: Positive Examples

#example[
  *Is ${and, or, not}$ complete?*

  Check each class:
  - NOT $in.not T_0$: NOT(0) = 1 ≠ 0 #YES
  - NOT $in.not T_1$: NOT(1) = 0 ≠ 1 #YES
  - AND $in.not S$: non-self-dual #YES
  - NOT $in.not M$: NOT is not monotone #YES
  - AND $in.not L$: AND has degree 2 #YES

  *Conclusion:* Complete! #YES
]

#example[
  *Is ${"NAND"}$ complete?*

  NAND(x, y) = $overline(x and y)$:
  - NAND(0,0) = 1 ≠ 0 $=>$ $in.not T_0$ #YES
  - NAND(1,1) = 0 ≠ 1 $=>$ $in.not T_1$ #YES
  - NAND($overline(x), overline(y)$) ≠ $overline("NAND"(x,y))$ $=>$ $in.not S$ #YES
  - NAND(0,1) = 1 > NAND(1,1) = 0 $=>$ $in.not M$ #YES
  - ANF has degree 2 $=>$ $in.not L$ #YES

  *Conclusion:* Complete! #YES
]

== Incomplete Sets: Examples

#example[
  *Is ${and, or}$ complete?*

  - AND $in T_0$: $"AND"(0,0) = 0$
  - OR $in T_0$: $"OR"(0,0) = 0$
  - All functions in closure stay in $T_0$
  - Cannot escape $T_0$ (need function with $f(0,...,0) = 1$)

  *Conclusion:* Incomplete. Stuck in $T_0$. #NO
]

#line(length: 50%, stroke: 0.4pt + gray)

#example[
  *Is ${xor, not}$ complete?*

  - XOR $in L$: degree 1
  - NOT $in L$: $not x = x xor 1$, degree 1
  - All functions in closure stay in $L$
  - Cannot escape $L$ (need nonlinear function like AND)

  *Conclusion:* Incomplete. Stuck in $L$. #NO
]

// #example[
//   *Is ${and, or, xor}$ complete?*
//
//   Check classes:
//   - AND $in T_0$: $"AND"(0,0) = 0$
//   - OR $in T_0$: $"OR"(0,0) = 0$
//   - XOR $in T_0$: $"XOR"(0,0) = 0$
//   - All functions in closure stay in $T_0$
//   - Cannot escape $T_0$ (need NOT or constant 1)
//
//   *Conclusion:* Incomplete. Stuck in $T_0$. #NO
// ]

== Complete Sets in Practice

Common functionally complete sets:

#align(center)[
  #table(
    columns: 3,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Set*], [*Applications*], [*Notes*]),
    [${and, or, not}$], [Textbooks, theory], [Classical basis],
    [${and, not}$], [TTL logic families], [Two-level logic],
    [${or, not}$], [Alternative basis], [Dual to {AND, NOT}],
    [${not, imply}$], [Logic programming], [Implication-based],
    [${"NAND"}$], [Digital circuits], [Single gate type],
    [${"NOR"}$], [Digital circuits], [Single gate type],
    [${xor, and, 1}$], [ANF synthesis], [Algebraic forms],
  )
]

#note[
  *Design principle:* Minimal complete sets reduce hardware complexity and manufacturing costs.
]

== Definability and Applications

#definition[
  A function $f$ is _definable_ from set $F$ if $f in [F]$.
]

- XOR is definable from {AND, OR, NOT}: \
  $x xor y = (x and overline(y)) or (overline(x) and y)$

- NOT is definable from {NAND}: \
  $overline(x) = "NAND"(x, x)$

- AND is definable from {NAND}: \
  $x and y = overline("NAND"(x, y)) = "NAND"("NAND"(x,y), "NAND"(x,y))$

*Applications:*
+ *Circuit synthesis:* Convert expressions to available gate types
+ *Gate minimization:* Replace complex gates with universal gates
+ *Hardware verification:* Ensure gate library is sufficient
+ *Compiler optimization:* Transform logical expressions efficiently

== Building Functions from NAND

Since ${"NAND"} = {nand}$ is complete, we can build any function using only NAND gates.

#example[
  *Construct basic gates from NAND:*

  #align(center)[
    #table(
      columns: 3,
      align: left,
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
      table.header([*Gate*], [*Formula*], [*NAND equivalent*]),
      [NOT], [$not x$], [$x nand x$],
      [AND], [$x and y = not (x nand y)$], [$(x nand y) nand (x nand y)$],
      [OR], [$x or y = not (not x and not y)$], [$(x nand x) nand (y nand y)$],
      [XOR], [$x xor y = (x and not y) or (not x and not y)$], [$(x nand (x nand y)) nand (y nand (x nand y))$],
    )
  ]
]

#Block(color: yellow)[
  *Trade-off:* Using only NAND gates may increase circuit depth and gate count compared to mixed-gate designs.
]

#note[
  Similar constructions exist for NOR gates, providing alternative universal implementations.
]

== Summary: Functional Completeness

#Block(color: purple)[
  *Key concepts:*

  + *Functional closure* $[F]$: all functions expressible using $F$
  + *Functional completeness*: $[F]$ contains all Boolean functions
  + *Post's five classes*: $T_0$, $T_1$, $S$, $M$, $L$ (each closed under composition)
  + *Post's criterion*: $F$ is complete $<=>$ $F$ escapes all five classes
  + *Universal gates*: NAND and NOR are individually complete
]

#Block(color: yellow)[
  *Key insight:*
  Post's theorem gives us a _complete characterization_ of functional completeness.
  To check if a set is complete, just verify it has one function escaping each of the five classes.
  This is why NAND alone is universal --- it escapes all five classes.
]

#grid(
  columns: 2,
  gutter: 1em,

  Block(color: blue)[
    *Practical applications:*
    - Circuit design with minimal gate types
    - Optimization of Boolean expressions
    - Hardware verification and gate library design
    - Understanding expressiveness limits
  ],

  Block(color: blue)[
    *What's next:*
    We've mastered the _theory_: Boolean algebra, normal forms, minimization, ANF, completeness.
    Now we implement these ideas in _hardware_: logic gates, combinational circuits, sequential circuits.
  ],
)


= Digital Circuits
#focus-slide(
  epigraph: [It is software that gives form and purpose to a programmable machine,\ much as a sculptor shapes clay],
  epigraph-author: "Alan Key",
)

== From Boolean Algebra to Hardware

Boolean algebra provides the mathematical foundation for digital circuit design.

#grid(
  columns: 2,
  gutter: 1.5em,
  [
    *Mathematical abstraction:*
    - Boolean variables: $x, y, z$
    - Operations: $and, or, not, xor$
    - Functions: $f(x,y,z)$
    - Truth tables and expressions
    - Algebraic laws and transformations
  ],
  [
    *Physical implementation:*
    - Voltage levels: HIGH (1), LOW (0)
    - Transistor circuits (CMOS logic)
    - Propagation delays
    - Power consumption
    - Real constraints: noise, timing, fanout
  ],
)

*Connection:* Boolean expressions translate directly to logic gate networks. Circuit optimization uses the algebraic laws we've studied.

== Logic Gate Standards

Two main notation standards for logic gates:

#definition[
  *ANSI/IEEE Std 91-1984* and *IEC 60617* define standardized symbols for logic gates used in circuit diagrams.
]

#note[
  Two styles exist: *Distinctive shapes* (American: AND = D-shape, OR = shield) and *Rectangular* (IEC: rectangles with symbols). We use distinctive shapes. Both are widely used in industry.
]

== Standard Logic Gates: Visual Symbols

#align(center + horizon)[
  #import "@preview/circuiteria:0.2.0"
  #circuiteria.circuit({
    import circuiteria: *
    import "@preview/cetz:0.3.2": draw
    draw.scale(75%)

    let label(s) = text(size: 10pt, weight: "bold")[#s]

    // Top row
    element.gate-and(id: "and", x: 0, y: 0, w: 2, h: 2)
    draw.content("and", label[AND])

    element.gate-or(id: "or", x: 4, y: 0, w: 2, h: 2)
    draw.content("or", label[OR])

    element.gate-not(id: "not", x: 8, y: 0, w: 2, h: 2)
    draw.content((rel: (-5pt, 0), to: "not"), label[NOT])

    // Bottom row
    element.gate-nand(id: "nand", x: 0, y: -3.5, w: 2, h: 2)
    draw.content("nand", label[NAND])

    element.gate-nor(id: "nor", x: 4, y: -3.5, w: 2, h: 2)
    draw.content((rel: (3pt, 0), to: "nor"), label[NOR])

    element.gate-xor(id: "xor", x: 8, y: -3.5, w: 2, h: 2)
    draw.content((rel: (5pt, 0), to: "xor"), label[XOR])

    // Add stubs for all gates
    for id in ("and", "or", "not", "nand", "nor", "xor") {
      wire.stub(id + "-port-in0", "west", length: 0.5)
      if id != "not" {
        wire.stub(id + "-port-in1", "west", length: 0.5)
      }
      wire.stub(id + "-port-out", "east", length: 0.5)
    }
  })
]

#v(1em)
#Block(color: orange)[
  *Bubble notation:* Small circle (bubble) on gate input/output indicates logical negation.
]

== Basic Logic Gates

#align(center)[
  #table(
    columns: 4,
    align: (left, center, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    inset: 5pt,
    table.header([*Gate*], [*Symbol*], [*Expression*], [*Truth Pattern*]),
    [AND], [D-shape], [$A and B$], [Output 1 only when all inputs are 1],
    [OR], [Shield], [$A or B$], [Output 1 when any input is 1],
    [NOT], [Triangle + bubble], [$overline(A)$], [Inverts the input],
    [NAND], [D-shape + bubble], [$overline(A and B)$], [NOT-AND],
    [NOR], [Shield + bubble], [$overline(A or B)$], [NOT-OR],
    [XOR], [Shield + curve], [$A xor B$], [Output 1 when inputs differ],
    [XNOR], [Shield + curve + bubble], [$overline(A xor B)$], [Output 1 when inputs match],
  )
]

#note[
  XNOR is also called _equivalence_ gate: outputs 1 when inputs are equivalent.
]

== Universal Gates: The Ultimate Minimalism

#Block(color: teal)[
  *The manufacturing dream:*

  In the early days of computing (1950s-60s), every different gate type required:
  - Different design specifications
  - Different testing procedures
  - Different inventory management
  - Different failure modes to diagnose

  Engineers wondered: "What if we could build EVERYTHING with just ONE gate type?"

  *The answer:* NAND and NOR are _universal_ --- you can build any circuit using only NAND gates (or only NOR gates)!

  This revolutionized chip manufacturing.
  Today, while modern chips use mixed gates for optimization, the NAND-only design philosophy still influences architecture.
]

#theorem[
  NAND and NOR gates are _functionally complete_ --- any Boolean function can be implemented using only NAND gates (or only NOR gates).
]

#example[Building the basic gates from NAND (the "construction kit")][
  Starting with ONLY the NAND gate, we can build everything:

  *Step 1 --- Build NOT:*
  $overline(A) = A nand A$ #h(2em) "NAND a signal with itself to invert it"

  *Step 2 --- Build AND:*
  $A and B = overline(A nand B) = (A nand B) nand (A nand B)$ \
  "Do NAND, then invert the result with another NAND"

  *Step 3 --- Build OR:*
  $A or B = overline(A) nand overline(B) = (A nand A) nand (B nand B)$ \
  "Invert both inputs, then NAND them" (De Morgan's law in action!)

  *Step 4 --- Build anything:*
  Since ${and, or, not}$ is complete, and we can build all three from NAND, we're done! #text(green)[✓]
]

#Block(color: blue)[
  *Why this matters in practice:*
  - *Modern FPGA chips:* Built primarily from lookup tables (LUTs) that can implement any function
  - *ASIC design:* Standard cell libraries often emphasize NAND/NOR for uniformity
  - *Fault testing:* Easier to test one gate type comprehensively
  - *Academic value:* Proves minimality --- you can't do better than one operation!
]

#note[
  In reality, modern chip designers use mixed gates (AND, OR, NOT, XOR, etc.) because:
  - Lower power consumption
  - Faster operation (fewer gate delays)
  - Smaller area (1 AND gate vs. 2 NANDs)

  But NAND-only designs prove what's _possible_ and provide fallback when needed!
]

== Constructing Circuits from Boolean Expressions

*General procedure:*

+ *Start with Boolean expression:* Obtain from truth table (DNF/CNF) or specifications
+ *Minimize if desired:* Use K-maps, Quine-McCluskey, or algebraic methods
+ *Identify gate structure:* Break expression into hierarchical operations
+ *Draw circuit:* Connect gates according to expression structure
+ *Verify:* Check truth table matches specification

#Block(color: yellow)[
  *Key principle:* Expression evaluation order determines circuit topology (depth and gates).
]

== Circuit Construction: Example

#example[
  Build circuit for $f(A, B, C) = A and B or overline(A) and C$
]

*Step 1:* Identify operations:
- Two AND gates: $A and B$ and $overline(A) and C$
- One NOT gate: $overline(A)$
- One OR gate: combining the AND results

*Step 2:* Determine levels:
+ Level 0 (inputs): $A, B, C$
+ Level 1: $overline(A)$ ~(NOT gate)
+ Level 2: $A and B$ and $overline(A) and C$ ~(AND gates)
+ Level 3: Final OR gate

*Circuit depth:* 3 levels (excluding inputs)

#note[
  Depth affects propagation delay --- critical for circuit speed.
]

== Multi-Output Circuits

We often need to compute _multiple functions_ simultaneously, using one circiut with _shared inputs_.

#example[Half Adder][
  Adds two bits $A, B$, produces sum and carry:

  #grid(
    columns: 2,
    gutter: 2em,
    [
      *Outputs:*
      - Sum: $S = A xor B$
      - Carry: $C = A and B$

      *Truth table:*
      #v(-.5em)
      #table(
        columns: 4,
        align: center,
        stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } + if x == 1 { (right: 0.4pt) },
        inset: (x, y) => if y == 0 { 5pt } else { 3pt },
        table.header([$A$], [$B$], [$S$], [$C$]),
        [0], [0], [0], [0],
        [0], [1], [1], [0],
        [1], [0], [1], [0],
        [1], [1], [0], [1],
      )
    ],
    [
      #import "@preview/circuiteria:0.2.0"
      #circuiteria.circuit({
        import circuiteria: *
        import "@preview/cetz:0.3.2": draw

        let w = 1.2
        let h = w

        element.group(
          id: "half-adder",
          name: "Half Adder",
          padding: 1em,
          stroke: (dash: "dashed"),
          {
            // XOR gate for Sum
            element.gate-xor(id: "xor", x: 0, y: 0, w: w, h: h)

            // AND gate for Carry
            element.gate-and(id: "and", x: 0, y: -2, w: w, h: h)

            // Offset for XOR-0
            draw.hide(
              draw.line(name: "l1", "xor-port-in0", (rel: (-1, 0), to: ())),
            )
            let a = "l1.end"

            // Offset for XOR-1
            draw.hide(
              draw.line(name: "l2", "xor-port-in1", (rel: (-1.5, 0), to: ())),
            )
            let b = "l2.end"

            // Wires to XOR
            wire.wire(
              "wX0",
              (a, "xor-port-in0"),
            )
            wire.intersection(a)
            wire.wire(
              "wX1",
              (a, "and-port-in0"),
              style: "zigzag",
              zigzag-ratio: 0%,
            )

            // Wires to AND
            wire.wire(
              "wA0",
              (b, "xor-port-in1"),
            )
            wire.intersection(b)
            wire.wire(
              "wA1",
              (b, "and-port-in1"),
              style: "zigzag",
              zigzag-ratio: 0%,
            )
          },
        )

        // Input A
        let a = "l1.end"
        draw.line(
          name: "in-a",
          a,
          (
            rel: (-0.5, 0),
            to: (horizontal: "half-adder.west", vertical: ()),
          ),
        )
        draw.content("in-a.end", [$A$], anchor: "east", padding: 0.2)

        // Input B
        let b = "l2.end"
        draw.line(
          name: "in-b",
          b,
          (
            rel: (-0.5, 0),
            to: (horizontal: "half-adder.west", vertical: ()),
          ),
        )
        draw.content("in-b.end", [$B$], anchor: "east", padding: 0.2)

        // Output Sum
        draw.line(
          name: "w-sum",
          "xor-port-out",
          (
            rel: (0.5, 0),
            to: (horizontal: "half-adder.east", vertical: ()),
          ),
        )
        draw.content(
          "w-sum.end",
          [$S$ (sum)],
          anchor: "west",
          padding: 0.2,
        )

        // Output Carry
        draw.line(
          name: "w-carry",
          "and-port-out",
          (
            rel: (0.5, 0),
            to: (horizontal: "half-adder.east", vertical: ()),
          ),
        )
        draw.content(
          "w-carry.end",
          [$C$ (carry)],
          anchor: "west",
          padding: 0.2,
        )
      })

      *Gates needed:* 1 XOR, 1 AND
    ],
  )
]

#note[
  Half adder is the simplest arithmetic circuit --- no carry-in means independent bit addition.
]

== Full Adder: Definition

#definition[
  A _full adder_ is a combinational circuit that adds three bits: two operand bits $A, B$ and a carry-in bit $C_"in"$, producing a sum bit $S$ and a carry-out bit $C_"out"$.
]

#grid(
  columns: 2,
  gutter: 1.5em,
  [
    *Direct gate-level implementation:*

    *Outputs:*
    - Sum: $S = A xor B xor C_"in"$
    - Carry-out: $C_"out" = (A and B) or (C_"in" and (A xor B))$

    *Alternative carry:*
    $C_"out" = A B or A C_"in" or B C_"in"$
  ],
  [
    *Implementation using half adders:*

    + $"HA"_1$: Add $A$ and $B$ \
      $S_1 = A xor B$, $C_1 = A and B$
    + $"HA"_2$: Add $S_1$ and $C_"in"$ \
      $S = S_1 xor C_"in"$, $C_2 = S_1 and C_"in"$
    + Combine carries: $C_"out" = C_1 or C_2$
  ],
)

#Block(color: yellow)[
  *Key insight:* Both implementations are equivalent but differ in structure:
  - Gate-level uses 5 gates with shared $(A xor B)$ term
  - Half-adder-based uses 2 modular components + 1 OR gate
]

== Full Adder: Circuit Implementation

#grid(
  columns: 2,
  align: (center, left),
  gutter: 1em,
  [
    #import "@preview/circuiteria:0.2.0"
    #circuiteria.circuit({
      import circuiteria: *
      import "@preview/cetz:0.3.2": draw

      let w = 1.2
      let h = w

      element.group(
        id: "full-adder",
        name: "Full Adder",
        padding: (0.7em, 1em), // (vertical, horizontal)
        stroke: (dash: "dashed"),
        {
          // First Half Adder
          element.group(
            id: "ha1",
            name: [$"HA"_1$],
            padding: .8em,
            stroke: (paint: blue, thickness: 1.5pt),
            fill: blue.lighten(90%),
            {
              element.gate-xor(id: "xor1", x: 0, y: 0, w: w, h: h)
              element.gate-and(id: "and1", x: 0, y: -2, w: w, h: h)
            },
          )

          // Second Half Adder
          element.group(
            id: "ha2",
            name: [$"HA"_2$],
            padding: .8em,
            stroke: (paint: blue, thickness: 1.5pt),
            fill: blue.lighten(90%),
            {
              element.gate-xor(id: "xor2", x: 3.5, y: 0, w: w, h: h)
              element.gate-and(id: "and2", x: 3.5, y: -2, w: w, h: h)
            },
          )

          // OR gate for carries
          element.gate-or(
            id: "or",
            x: 6,
            y: -1.2,
            w: w,
            h: h,
          )

          // Wire from HA1 to HA2: XOR1 to XOR2 (Sum)
          wire.wire("w-s1", ("xor1-port-out", "xor2-port-in0"), style: "zigzag", zigzag-ratio: 30%)

          // Wire from HA1 to HA2: XOR1 to AND2 (S1 shared)
          wire.intersection("w-s1.zig")
          wire.wire("w-s1-and", ("w-s1.zig", "and2-port-in0"), style: "zigzag", zigzag-ratio: 0%)

          // Wires from carries to OR
          wire.wire("w-c1", ("and1-port-out", "or-port-in0"), style: "zigzag", zigzag-ratio: 30%)
          wire.wire("w-c2", ("and2-port-out", "or-port-in1"), style: "zigzag")

          // Input offsets
          draw.hide(draw.line(name: "l1", "xor1-port-in0", (rel: (-1, 0), to: ())))
          draw.hide(draw.line(name: "l2", "xor1-port-in1", (rel: (-1.5, 0), to: ())))

          let a = "l1.end"
          let b = "l2.end"
          let cin = (a, 200%, b)

          // A to HA1
          wire.wire("wA1", (a, "xor1-port-in0"))
          wire.intersection(a)
          wire.wire("wA2", (a, "and1-port-in0"), style: "zigzag", zigzag-ratio: 0%)

          // B to HA1
          wire.wire("wB1", (b, "xor1-port-in1"))
          wire.intersection(b)
          wire.wire("wB2", (b, "and1-port-in1"), style: "zigzag", zigzag-ratio: 0%)

          // Cin to HA2
          wire.wire("wC1", (cin, "xor2-port-in1"), style: "zigzag", zigzag-ratio: 75%)
          wire.intersection(cin)
          wire.wire("wC2", (cin, "and2-port-in1"), style: "dodge", dodge-y: -6.6em, dodge-margins: (0, 1))
        },
      )

      let a = "l1.end"
      let b = "l2.end"
      let cin = (a, 200%, b)

      // Input labels
      draw.line(name: "in-a", a, (rel: (-0.5, 0), to: (horizontal: "full-adder.west", vertical: ())))
      draw.content("in-a.end", [$A$], anchor: "east", padding: 0.2)

      draw.line(name: "in-b", b, (rel: (-0.5, 0), to: (horizontal: "full-adder.west", vertical: ())))
      draw.content("in-b.end", [$B$], anchor: "east", padding: 0.2)

      draw.line(name: "in-cin", cin, (rel: (-0.5, 0), to: (horizontal: "full-adder.west", vertical: ())))
      draw.content("in-cin.end", [$C_"in"$], anchor: "east", padding: 0.2)

      // Output Sum
      draw.line(name: "w-sum", "xor2-port-out", (rel: (0.5, 0), to: (horizontal: "full-adder.east", vertical: ())))
      draw.content("w-sum.end", [$S$], anchor: "west", padding: 0.2)

      // Output Carry
      draw.line(name: "w-cout", "or-port-out", (rel: (0.5, 0), to: (horizontal: "full-adder.east", vertical: ())))
      draw.content("w-cout.end", [$C_"out"$], anchor: "west", padding: 0.2)
    })
  ],
  [
    *Physical implementation:*
    - 2 XOR gates
    - 2 AND gates
    - 1 OR gate
    - Total: 5 gates

    *Logical structure:*
    - Two half adders (blue boxes)
    - One OR gate for carry combining
    - Modular hierarchical design
  ],
)

#place(bottom)[
  #Block(color: purple)[
    *Key insight:* The same circuit can be viewed two ways:
    - *Gate-level view:* 5 individual gates with wire sharing
    - *Module-level view:* 2 half-adder components + OR combiner

    The blue boxes show how the gates naturally group into half adders!
  ]
]

// #Block(color: blue)[
//   *Application:* Full adders chain to build n-bit adders:
//   - *Ripple-carry:* Simple but slow (carry ripples through all bits)
//   - *Carry-lookahead:* Faster but more complex (parallel carry computation)
//   - *Used in:* ALUs, processors, digital signal processors
// ]

== Other Arithmetic Circuits

#align(center)[
  #table(
    columns: 3,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Circuit*], [*Function*], [*Key Components*]),
    [Subtractor], [Compute $A - B$], [Use 2's complement, add with negation],
    [Comparator], [Test $A < B$, $A = B$, $A > B$], [XOR for equality, cascaded logic],
    [Multiplexer], [Select one of $n$ inputs], [$log_2 n$ select lines, AND-OR structure],
    [Demultiplexer], [Route input to one of $n$ outputs], [Inverse of multiplexer],
    [Encoder], [Convert $2^n$ inputs to $n$-bit code], [Priority encoding],
    [Decoder], [Convert $n$-bit code to $2^n$ outputs], [Minterm generation],
  )
]

== Multiplexers and Demultiplexers

#example[4-to-1 Multiplexer][

  *Function:* Select one of 4 inputs $(I_0, I_1, I_2, I_3)$ based on 2 select lines $(S_1, S_0)$

  *Truth:* If $(S_1 S_0) = 01_2$, then $"Out" = I_1$

  *Implementation:*
  - 4 AND gates (each enabled by specific select combination)
  - 1 OR gate (combines all enabled inputs)
  - $"Out" = overline(S_1) overline(S_0) I_0 or overline(S_1) S_0 I_1 or S_1 overline(S_0) I_2 or S_1 S_0 I_3$
]

#note[
  Decoders are useful because they generate all possible minterms. An $n$-to-$2^n$ decoder produces all minterms for $n$ variables, so you can build any Boolean function by just connecting the right outputs with OR gates.
]

== Circuit Minimization Goals

Now that we've seen various combinational circuits, let's consider: *How do we make them efficient?*

*Minimization objectives:*

+ *Gate count:* Fewer gates $=>$ lower cost, smaller chip area
+ *Circuit depth:* Fewer levels $=>$ faster operation (less delay)
+ *Fanout:* Number of gates driven by one output (affects loading)
+ *Power consumption:* Fewer transitions $=>$ less energy

#note[
  These objectives often conflict! Minimization requires trade-offs.
]

#example[
  DNF for $f = A B or A C or B C$ (3 terms, 3 gates):
  - Algebraic identity: $A B or A C or B C = A B or A C$ when $A = 1$
  - But for all cases, adding redundant term $B C$ eliminates hazards!
  - *Trade-off:* More gates for reliable behavior
]

== Circuit Minimization Techniques

#align(center)[
  #table(
    columns: 3,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Technique*], [*Best For*], [*Limitations*]),
    [Algebraic laws], [Small expressions, manual], [Error-prone, no guarantee],
    [K-maps], [2-4 variables, visualization], [Does not scale beyond 6 variables],
    [Quine-McCluskey], [Exact minimization, automation], [Exponential complexity],
    [Espresso], [Multi-output, heuristic], [May not find optimal solution],
    [Technology mapping], [Gate libraries, ASIC/FPGA], [Requires EDA tools],
  )
]

#note[
  Modern synthesis tools (e.g., Synopsys Design Compiler, Cadence Genus) combine multiple techniques and optimize for specific target technologies.
]

== Two-Level vs Multi-Level Logic

#align(center)[
  #table(
    columns: 3,
    align: left,
    stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
    table.header([*Aspect*], [*Two-Level Logic*], [*Multi-Level Logic*]),
    [*Form*], [SoP or PoS], [Factored expressions, nested gates],

    [*Advantages*],
    [
      #set list(marker: Green[*+*])
      - Fast (minimal depth = 2)
      - Easy to minimize (K-maps)
      - Predictable timing
    ],
    [
      #set list(marker: Green[*+*])
      - Fewer gates (shared sub-expressions)
      - Smaller area
      - Lower power
    ],

    [*Disadvantages*],
    [
      #set list(marker: Red[*–*])
      - More gates (exponential growth)
      - Large chip area
    ],
    [
      #set list(marker: Red[*–*])
      - Slower (deeper paths)
      - Harder to minimize
      - Complex timing analysis
    ],
  )
]

#Block(color: yellow)[
  *Modern approach:* Use multi-level logic for area/power optimization, then optimize critical paths for speed.
]

== Sequential Circuits: The Need for Memory

#Block(color: purple)[
  *Limitation of combinational circuits:* No memory!
]

#columns(2)[
  *What combinational circuits CAN do:*
  - Compute functions of current inputs #YES
  - Process data in one pass #YES
  - Adders, comparators, multiplexers, ALUs #YES

  #colbreak()

  *What combinational circuits CANNOT do:*
  - Remember past inputs or results #NO
  - Count events over time #NO
  - Implement algorithms with loops or state #NO
  - Build registers, counters, or processors #NO
]

#v(1em)
#Block(color: yellow)[
  *To build real computers, we need circuits that "remember"!*

  This needs a completely different approach than what we've seen so far.
]

== Combinational vs Sequential Circuits

#definition[
  A _sequential circuit_ has outputs that depend on:
  + Current inputs (like combinational circuits)
  + *Previous state* (memory)

  This requires _feedback_ --- outputs feed back to inputs.
]

#example[
  - *Combinational:* ALU, multiplexer, decoder (no memory)
  - *Sequential:* Registers, counters, state machines (with memory)
]

#note[
  Truth tables don't work for sequential circuits --- we need _state diagrams_ or _state tables_ instead.
]

== Latches: Basic Memory Elements

#definition[
  A _latch_ is a bistable circuit with two stable states, used to store one bit.
]

#example[SR Latch (Set-Reset)][

  *Inputs:* $S$ (set), $R$ (reset)

  *Outputs:* $Q$ (state), $overline(Q)$ (complementary)

  *Behavior:*
  - $S = 1, R = 0$: Set $Q = 1$
  - $S = 0, R = 1$: Reset $Q = 0$
  - $S = 0, R = 0$: Hold current state (memory!)
  - $S = 1, R = 1$: *Forbidden* (both outputs would be 0)

  *Implementation:* Two cross-coupled NOR gates (or NAND gates)
]

#Block(color: orange)[
  *Warning:* SR latch has a forbidden state $(S=1, R=1)$ that must be avoided by circuit design.
]

== SR Latch: Circuit and Behavior

*NOR-based SR Latch:*

#grid(
  columns: (1fr, 1fr),
  gutter: 1.5em,
  [
    *Circuit structure:*

    #import "@preview/circuiteria:0.2.0"
    #circuiteria.circuit({
      import circuiteria: *
      import "@preview/cetz:0.3.2": draw
      draw.scale(65%)

      // Top NOR gate
      element.gate-nor(id: "nor1", x: 2, y: 0, w: 1.8, h: 1.8)
      wire.stub("nor1-port-in0", "west", length: 1.5, name: "S")

      // Bottom NOR gate
      element.gate-nor(id: "nor2", x: 2, y: -3, w: 1.8, h: 1.8)
      wire.stub("nor2-port-in1", "west", length: 1.5, name: "R")

      // Output Q
      wire.stub("nor1-port-out", "east", length: 1.5, name: "Q")

      // Output Q-bar
      wire.stub("nor2-port-out", "east", length: 1.5, name: $overline(Q)$)

      // Feedback wires
      draw.line(
        "nor1-port-out",
        (rel: (.5, 0)),
        (rel: (0, -1)),
        (rel: (-1, 0.5), to: "nor2-port-in0"),
        (rel: (0, -0.5)),
        "nor2-port-in0",
        stroke: red,
      )
      draw.line(
        "nor2-port-out",
        (rel: (0.5, 0)),
        (rel: (0, 1)),
        (rel: (-1, -0.5), to: "nor1-port-in1"),
        (rel: (0, 0.5)),
        "nor1-port-in1",
        stroke: red,
      )
    })

    #v(0.5em)
    Feedback creates memory!
  ],
  [
    *State table:*
    #v(-0.5em)
    #table(
      columns: 5,
      align: (center, center, center, center, left),
      stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } + if x == 1 or x == 3 { (right: 0.4pt) },
      table.header([$S$], [$R$], [$Q_t$], [$Q_(t+1)$], [Action]),
      [0], [0], [0], [0], [Hold],
      [0], [0], [1], [1], [Hold],
      [0], [1], [0/1], [0], [Reset],
      [1], [0], [0/1], [1], [Set],
      [1], [1], [?], [?], [Forbidden],
    )

    *Equations:*
    - $Q = overline(S or overline(Q))$
    - $overline(Q) = overline(R or Q)$
  ],
)

#note[
  $Q_t$ = current state, $Q_(t+1)$ = next state. The latch "remembers" when $S = R = 0$.
]

== Why Truth Tables Fail for Sequential Circuits

#Block(color: yellow)[
  *Key insight:* An SR latch cannot be described by a simple Boolean function $Q = f(S, R)$ because it depends on _previous state_.
]

#place(right)[
  #set align(left)
  #Block(color: yellow)[
    *Sequential circuits need:*
    - State tables (not truth tables)
    - Finite state machines (FSMs)
    - Temporal logic (next-state functions)
    - Timing diagrams showing state transitions
  ]
]

*Why not?* The output $Q$ depends on:
- Current inputs $S, R$
- *Previous output* $Q_t$ (feedback)

This is a _state-dependent_ behavior:
- $(S, R) = (0, 0)$ with $Q_t = 0 => Q_(t+1) = 0$
- $(S, R) = (0, 0)$ with $Q_t = 1 => Q_(t+1) = 1$

Same inputs, different outputs! This violates the basic idea of a function.

#Block(color: purple)[
  *Bottom line:* Pure Boolean functions can only describe _combinational_ logic.
]

== Flip-Flops: Clocked Memory

#definition[
  A _flip-flop_ is an edge-triggered memory element that changes state only on clock transitions (rising or falling edge).
]

#Block(color: blue)[
  *Key difference from latches:*
  - *Latches:* Level-sensitive (transparent when enabled)
  - *Flip-flops:* Edge-triggered (change only on clock edge)

  Flip-flops are more predictable and easier to synchronize in complex systems.
]

== D Flip-Flop

#example[D (Data) Flip-Flop][
  *Input:* $D$ (data), $"CLK"$ (clock),~ *Output:* $Q$

  *Behavior:*
  - On clock edge (e.g., rising edge $arrow.t$):~ $Q_(t+1) = D_t$ ~(capture and store $D$ value)
  - Between clock edges: $Q$ holds value (ignores $D$ changes)

  *Characteristic equation:* $Q_(t+1) = D$
]

*Timing diagram:*
#place(right, dx: -1em, dy: -3.5em)[
  #cetz.canvas({
    import cetz.draw: *
    scale(70%)

    let y-clk = 2.5
    let y-d = 1.5
    let y-q = 0.5
    let y-time = 0
    let sig-height = 0.4

    // Labels
    content((-1, y-clk), anchor: "east", [$"CLK"$])
    content((-1, y-d), anchor: "east", [$D$])
    content((-1, y-q), anchor: "east", [$Q$])

    // Clock signal (5 periods)
    for i in range(5) {
      let x = i * 2
      line(
        (x, y-clk),
        (x, y-clk + sig-height),
        (x + 1, y-clk + sig-height),
        (x + 1, y-clk),
        (x + 2, y-clk),
        stroke: red + 1.5pt,
      )
      // Mark rising edge with arrow
      line((x, y-clk - 0.2), (x, y-clk + sig-height + 0.2), stroke: green + 1pt, mark: (end: ">"))
    }

    // D input signal
    line((0, y-d), (1.5, y-d), stroke: blue + 1.5pt)
    line((1.5, y-d), (1.5, y-d + sig-height), stroke: blue + 1.5pt)
    line((1.5, y-d + sig-height), (3.5, y-d + sig-height), stroke: blue + 1.5pt)
    line((3.5, y-d + sig-height), (3.5, y-d), stroke: blue + 1.5pt)
    line((3.5, y-d), (5.5, y-d), stroke: blue + 1.5pt)
    line((5.5, y-d), (5.5, y-d + sig-height), stroke: blue + 1.5pt)
    line((5.5, y-d + sig-height), (10, y-d + sig-height), stroke: blue + 1.5pt)

    // Q output signal (changes at rising edges: 0, 2, 4, 6, 8)
    line((0, y-q), (2, y-q), stroke: purple + 1.5pt)
    line((2, y-q), (2, y-q + sig-height), stroke: purple + 1.5pt)
    line((2, y-q + sig-height), (4, y-q + sig-height), stroke: purple + 1.5pt)
    line((4, y-q + sig-height), (4, y-q), stroke: purple + 1.5pt)
    line((4, y-q), (6, y-q), stroke: purple + 1.5pt)
    line((6, y-q), (6, y-q + sig-height), stroke: purple + 1.5pt)
    line((6, y-q + sig-height), (10, y-q + sig-height), stroke: purple + 1.5pt)

    // Time axis
    line((0, y-time), (10, y-time), stroke: gray + 0.5pt, mark: (end: ">"))
    content((10.5, y-time), anchor: "west", [time])
  })
]
#v(3em)

#note[
  Notice $Q$ changes _only_ at rising edges ($arrow.t$), capturing $D$'s value at that instant, regardless of $D$ changes between edges.
]

#Block(color: green)[
  *Use cases:* Registers, memory buffers, pipeline stages

  D flip-flops eliminate the forbidden state problem of SR latches.
]

== Other Flip-Flop Types

#grid(
  columns: 2,
  gutter: 1em,
  [
    #Block(color: green)[*JK Flip-Flop*]

    *Inputs:* $J$ (set), $K$ (reset), $"CLK"$

    *Behavior on clock edge:*
    - $(J, K) = (0, 0)$: Hold state
    - $(J, K) = (0, 1)$: Reset $(Q = 0)$
    - $(J, K) = (1, 0)$: Set $(Q = 1)$
    - $(J, K) = (1, 1)$: Toggle $(Q = overline(Q))$

    *Equation:* $Q_(t+1) = J overline(Q)_t or overline(K) Q_t$
  ],
  [
    #Block(color: blue)[*T (Toggle) Flip-Flop*]

    *Input:* $T$ (toggle), $"CLK"$

    *Behavior on clock edge:*
    - $T = 0$: Hold state
    - $T = 1$: Toggle $(Q_(t+1) = overline(Q)_t)$

    *Equation:* $Q_(t+1) = T xor Q_t$

    *Implementation:* JK with $J = K = T$
  ],

  Block(color: green)[
    Toggle mode $(J=K=1)$ ideal for counters and frequency dividers.
  ],
  Block(color: blue)[
    Common in binary counters (each stage divides frequency by 2).
  ],
)

#note[
  In practice, however, most designs use _D flip-flops_ because they're _simpler_ and more _predictable_.
]

== Clock Signals and Synchronization

#definition[
  A _clock signal_ is a periodic square wave that synchronizes state changes across a sequential circuit.
]

*Key clock parameters:*
- *Frequency:* Clock cycles per second (Hz)
- *Period:* Time for one complete cycle
- *Duty cycle:* Fraction of period when clock is HIGH
- *Rising edge* ($arrow.t$) or *Falling edge* ($arrow.b$): Transition points

#Block(color: yellow)[
  *Synchronous design:* All flip-flops share the same clock signal, so state updates happen together.

  *Asynchronous design:* No global clock (timing analysis is much harder).
]

#note[
  Most digital systems use _synchronous_ design because it's more predictable and _easier to verify_.
]

== Real Circuit Issues: Hazards

#definition[
  A _hazard_ (or _glitch_) is an unwanted transient change in circuit output due to:
  - Unequal propagation delays in different paths
  - Race conditions between signals
]

#example[Static-1 Hazard][
  Circuit: $f = A overline(B) or B C$ with $A = 1, C = 1$, while $B$ transitions $1 -> 0$

  #grid(
    columns: 2,
    gutter: 1.5em,
    [
      *K-map analysis:*

      #v(-1em)
      #align(center)[
        #k-mapper.karnaugh(
          8,
          y-label: $A B$,
          x-label: move(dy: .5em, $C$),
          manual-terms: (
            kcell(0, 0),
            kcell(1, 0),
            kcell(2, 1),
            kcell(3, 1),
            kcell(4, 0),
            kcell(5, 0),
            kcell(6, 0),
            kcell(7, 1),
          ),
          implicants: ((2, 3), (3, 7)),
        )
      ]

      Gap between rectangles causes hazard at transition!
    ],
    [
      *Fix:* Add redundant term $(A C)$

      #v(-1em)
      #align(center)[
        #k-mapper.karnaugh(
          8,
          y-label: $A B$,
          x-label: move(dy: .5em, $C$),
          manual-terms: (
            kcell(0, 0),
            kcell(1, 0),
            kcell(2, 1),
            kcell(3, 1),
            kcell(4, 0),
            kcell(5, 0),
            kcell(6, 1),
            kcell(7, 1),
          ),
          implicants: ((2, 3), (3, 7), (2, 6)),
        )
      ]

      Now the transition is covered by the new rectangle.
    ],
  )

  - Expected: $f$ stays 1 (both terms can be 1)
  - Actual (without fix): Brief glitch to 0 if delays differ
  - Solution: Redundant term eliminates the gap
]

#Block(color: orange)[
  *Types of hazards:*
  - *Static hazards:* Output should stay constant but glitches
  - *Dynamic hazards:* Multiple transitions during single input change
]

== Race Conditions and Metastability

#definition[
  A _race condition_ occurs when circuit behavior depends on the relative timing of multiple signals, leading to unpredictable outcomes.
]

#definition[
  _Metastability_ occurs when a flip-flop input changes too close to the clock edge, causing the output to hover in an undefined state before settling.
]

#note[
  *Timing constraints:* Setup time ($t_"setup"$): input stable before clock; Hold time ($t_"hold"$): input stable after clock. Violating these causes metastability. Proper synchronizer design (multi-stage flip-flops) reduces risk.
]

== Arithmetic Logic Unit (ALU) Overview

#definition[
  An _Arithmetic Logic Unit (ALU)_ is a combinational circuit that performs arithmetic and logical operations on integer operands.
]

*Typical ALU operations:*

#grid(
  columns: 2,
  gutter: 1em,
  [
    *Arithmetic:*
    - Addition, Subtraction
    - Increment, Decrement
    - Multiplication (in some ALUs)
    - Comparison
  ],
  [
    *Logical:*
    - AND, OR, XOR, NOT
    - Shift left, Shift right
    - Rotate operations
    - Bit manipulation
  ],
)

*Control:* Operation select lines determine which function the ALU performs.

#note[
  ALUs are central components of CPUs, performing the bulk of computational work.
]

== Summary: Digital Circuits

#Block(color: purple)[
  *Key concepts covered:*

  #grid(
    columns: 2,
    gutter: 1em,
    [
      *Combinational Logic*
      + Logic gates and standards (ANSI/IEC)
      + Circuit construction from Boolean expressions
      + Arithmetic circuits (adders, subtractors, comparators)
      + Multi-level vs two-level logic
      + Circuit minimization techniques
    ],
    [
      *Sequential Logic*
      + Latches (SR latch, forbidden states)
      + Flip-flops (D, JK, T, master-slave)
      + Clock signals and edge-triggering
      + State-dependent behavior
      + Timing constraints and hazards
    ],
  )
]

#Block(color: yellow)[
  *Key insight:*
  Boolean algebra provides the _perfect mathematical model_ for combinational circuits.
  Every gate, every circuit, every processor follows these algebraic laws.
  Sequential circuits add time and state, requiring flip-flops and temporal reasoning.
]

#Block(color: blue)[
  *From theory to silicon:*
  We've seen how abstract Boolean algebra (1854) connects to physical circuits (transistors, gates, propagation delays).
  This is the bridge from mathematics to the processors running everything in the digital world.
]


= The Journey Complete
#focus-slide()

== What You've Mastered

#grid(
  columns: 2,
  gutter: 1.5em,
  [
    *Theoretical Mastery:*
    - Design ANY Boolean function from scratch
    - Prove algebraic identities rigorously
    - Understand Post's completeness criterion
    - Analyze cryptographic security via ANF
    - Recognize lattice structure in Boolean algebra
  ],
  [
    *Practical Skills:*
    - Minimize circuits using K-maps
    - Build hardware from NAND gates alone
    - Optimize expressions algebraically
    - Design adders and arithmetic circuits
    - Understand sequential logic and timing
  ],
)

#Block(color: blue)[
  *The complete picture:*

  When you write `if (user.isLoggedIn && !user.isBanned)` in your code, you now understand the ENTIRE chain:
  - Boolean algebra: $x and (not y)$
  - Truth tables: evaluating all $2^2 = 4$ cases
  - Circuit synthesis: AND gate + NOT gate
  - Physical implementation: transistors switching at GHz speeds
  - Optimization: Can we use fewer gates?
  - Cryptographic perspective: What's the algebraic degree?

  You understand it ALL --- from philosophy (Boole, 1854) to physics (transistors, 2024)!
]

== Applications of Boolean Algebra

#Block(color: green)[
  *Where Boolean algebra lives in the real world:*

  #columns(2)[
    *Computing & Hardware:*
    - CPU architecture and processor design
    - FPGA programming and digital circuit synthesis
    - Memory systems (cache, RAM)
    - ALU design and arithmetic circuits

    *Security & Verification:*
    - Cryptography (AES S-boxes, stream ciphers)
    - Algebraic cryptanalysis and attacks
    - Formal verification (SAT/SMT solvers)
    - Hardware security modules

    #colbreak()

    *Software & Optimization:*
    - Compiler optimization (Boolean expression simplification)
    - Database query optimization
    - AI hardware accelerators (TPUs, GPUs)
    - Model checking and program analysis

    *Algorithms & Theory:*
    - Satisfiability problems (3-SAT, NP-completeness)
    - Binary decision diagrams (BDDs)
    - Coding theory (Reed-Muller codes)
    - Error detection and correction
  ]
]

== Summary: The Complete Journey

From George Boole's 1854 "Laws of Thought" to Claude Shannon's 1937 breakthrough connecting algebra to circuits, Boolean algebra became the foundation of digital computing.

#Block(color: purple)[
  *What we've mastered:*

  + *Algebraic structure:* Axioms, laws, duality, lattices
  + *Normal forms:* DNF/CNF, minterms/maxterms, SoP/PoS, Shannon expansion
  + *Minimization:* K-maps (visual), Quine-McCluskey (systematic), algebraic methods
  + *ANF:* Unique canonical form, algebraic degree, cryptographic applications
  + *Functional completeness:* Post's five classes, universal gates (NAND/NOR)
  + *Digital circuits:* Combinational (gates, adders) and sequential (latches, flip-flops)
]

#Block(color: yellow)[
  *Core insight:*
  Simple operations ($and$, $or$, $not$) on two values (0, 1) generate the entire computational universe.
  Boolean algebra provides the _perfect mathematical model_ for digital computation --- every gate, every circuit, every processor follows these algebraic laws.
]

#Block(color: blue)[
  *Tools you can now use:*
  Truth tables (enumeration), algebraic manipulation (laws), K-maps (visual optimization), Quine-McCluskey (systematic), ANF (cryptanalysis), Post's criterion (completeness), circuit design (from abstraction to silicon).
]


// == Bibliography
// #bibliography("refs.yml")

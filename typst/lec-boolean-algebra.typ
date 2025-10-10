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
  epigraph: [Мы почитаем всех нулями, \ А единицами — себя.],
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

== Logic: The Science of Valid Reasoning

Logic is the systematic study of the principles of valid inference and correct reasoning.
It provides the foundation for:
- Mathematical proof and rigor
- Computer science and algorithms
- Philosophical argumentation
- Everyday decision-making

#Block(color: blue)[
  *Why study logic?*
  Logic lets us distinguish valid arguments from fallacies, construct provably correct programs, and reason precisely about abstract systems.
]

== Historical Development of Logic

#columns(2)[
  *Ancient Period* (384-322 BCE)
  - *Aristotle*: Syllogistic logic, first formal system
  - Laws of thought: non-contradiction, excluded middle

  *Modern Period* (1600s-1800s)
  - *Leibniz* (1646-1716): Symbolic logic, binary arithmetic
  - *Boole* (1815-1864): _Laws of Thought_ (1854), algebraic approach

  #colbreak()

  *Contemporary Period* (1800s-1900s)
  - *De Morgan* (1806-1871): Logical laws, duality
  - *Peirce* (1839-1914): Boolean operations, truth tables
  - *Shannon* (1916-2001): Digital circuits (1937), information theory
]

#Block(color: teal)[
  *Historical note:*
  George Boole's _The Laws of Thought_ (1854) unified logic and algebra, creating the foundation for modern digital computing a century before the first computers.
]

== Statements: The Building Blocks

#definition[
  A _statement_ (or _proposition_) is a declarative sentence that is either true or false, but not both.
]

#example[
  These are statements:
  - "2 + 2 = 4" (#True)
  - "Paris is the capital of Germany" (#False)
  - "Every even number greater than 2 is the sum of two primes" (Goldbach's conjecture, truth unknown but definite)
  - "`x > 0`" when `x = 5` in a program (#True)
]

#Block(color: yellow)[
  *Key insight:*
  A statement must have a definite truth value, even if we don't know it yet.
]

== What Is NOT a Statement

Not every sentence is a statement:

#example[
  These are *NOT* statements:
  - "What time is it?" (question, not declarative)
  - "Close the door!" (command, not declarative)
  - "This sentence is false" (paradox, self-referential)
  - "Let $x$ be a real number" (definition, not assertion)
  - "She is tall" (ambiguous, depends on context)
]

#Block(color: orange)[
  *Warning:*
  Distinguish statements from definitions, questions, commands, and ambiguous expressions.
  Only statements can be assigned truth values.
]

== Truth Values and Classical Logic

#definition[
  Every statement has exactly one _truth value_: either *true* (often denoted $1$ or $top$) or *false* (often denoted $0$ or $bot$).
]

The classical (bivalent) logic assumes:
+ *Law of Identity*:
  Each statement is identical to itself
  - $P = P$ is always true

+ *Law of Non-Contradiction*:
  No statement can be both true and false simultaneously
  - $not (P and not P)$ is always true

+ *Law of Excluded Middle*:
  Every statement is either true or false (no third option)
  - $P or not P$ is always true

#note[
  These laws form the foundation of classical logic.
  Alternative logics (intuitionistic, many-valued) relax some of these assumptions, but we focus on classical logic.
]

== Why Formal Logic?

Logic provides essential tools for modern mathematics and computer science:

#columns(2)[
  *In Mathematics:*
  - Rigorous proofs
  - Axiomatic systems
  - Set theory foundations
  - Automated theorem proving

  #colbreak()

  *In Computer Science:*
  - Program verification
  - Digital circuit design
  - Database query optimization
  - Artificial intelligence reasoning
  - Compiler optimization
]

#Block(color: blue)[
  *Applications:* Boolean algebra directly powers digital circuits (CPUs, GPUs), SAT solvers (verification, planning), and logic programming (Prolog, answer set programming).
]

== What You Will Learn

By the end of this lecture, you will be able to:

+ *Construct and evaluate* Boolean expressions using truth tables
+ *Apply fundamental laws* of Boolean algebra (De Morgan's, distributivity, etc.)
+ *Synthesize functions* from specifications using CNF, DNF, and Karnaugh maps
+ *Minimize expressions* using algebraic identities and graphical methods
+ *Understand functional completeness* via Post's criterion
+ *Design digital circuits* using logic gates and flip-flops
+ *Connect to CS applications*: BDDs, SAT solving, verification
+ *Reason formally* about Boolean functions and their properties

#Block(color: blue)[
  *Goal:*
  Master both theory (formal proofs, algebraic structure) and practice (circuit design, expression minimization).
]


= Boolean Algebra Structure
#focus-slide(
  title: [Boolean Algebra Structure],
)

== Definition and Basic Properties

#definition[
  A _Boolean algebra_ is a bounded distributive lattice $(B, Join, Meet, bot, top)$ with complement $(dot)': B to B$ such that $x Join x' = top$ and $x Meet x' = bot$.
]

#example[
  $(power(A), union, intersect, emptyset, A)$ with $X' = A setminus X$ is a Boolean algebra.
]

#example[Digital Circuit Design][
  Consider 3-bit binary values as Boolean algebra:
  - Elements: ${ 000, 001, 010, 011, 100, 101, 110, 111 }$
  - Order: Bitwise comparison ($001 leq 011$ since $0 leq 0$, $0 leq 1$, $1 leq 1$)
  - Join: Bitwise OR ($010 Join 101 = 111$)
  - Meet: Bitwise AND ($110 Meet 101 = 100$)
  - Complement: Bitwise NOT ($001' = 110$)

  This directly corresponds to logic gates: OR, AND, NOT gates in computer processors.
]

#note[
  Logical reading: "join" $mapsto or$, "meet" $mapsto and$, "complement" $mapsto not$.
]

== Example: Database Query Lattice

#example[
  A database has tables `Students`, `Courses`, `Enrollments`.
  - Let $Q_1 =$ "Computer Science students"
  - Let $Q_2 =$ "Students in Math courses"
  - Let $Q_3 =$ "Graduate students"

  Consider queries as lattice elements ordered by result size (specificity).

  *Lattice Operations:*
  - $Q_1 Join Q_2 =$ "Students in CS OR Math courses" (larger result set)
  - $Q_1 Meet Q_2 =$ "CS students taking Math courses" (smaller result set)
  - $Q_1 Meet Q_3 =$ "Graduate CS students" (most specific)

  *Why this matters:*
  Query optimizers use this structure to:
  + Find equivalent but more efficient queries.
  + Cache common subqueries.
  + Predict result set sizes for cost estimation.
]

== Complement is Unique

#theorem[
  Complements are unique in a Boolean algebra.
]

#proof[
  Suppose for some element $a$ we have _two_ complements $x$ and $y$.
  $
    x & = x Meet top                 & #[~] & top "is the identity for" Meet \
      & = x Meet (a Join y)          & #[~] & "by definition of complement:" top = a Join y \
      & = (x Meet a) Join (x Meet y) & #[~] & Meet "distributes over" Join \
      & = bot Join (x Meet y)        & #[~] & "by definition of complement: " x Meet a = bot \
      & = (a Meet y) Join (x Meet y) & #[~] & "by definition of complement: " bot = a Meet y \
      & = (a Join x) Meet y          & #[~] & Meet "distributes over" Join \
      & = top Meet y                 & #[~] & "by definition of complement: " a Join x = top \
      & = y                          & #[~] & top "is the identity for" Meet
  $
  That is, $x = y$.
]

== De Morgan's Laws

#theorem[De Morgan][
  $(x Join y)' = x' Meet y'$ and $(x Meet y)' = x' Join y'$ in any Boolean algebra.
]

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

#v(-8pt)
#table(
  columns: 3,
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  inset: 4pt,
  table.header([Gate], [Formula], [Description]),
  [AND], $A and B$, [Outputs $1$ only when both inputs are $1$],
  [OR], $A or B$, [Outputs $1$ when at least one input is $1$],
  [NOT], $not A$, [Outputs the opposite of the input],
  [NAND], $not (A and B)$, [Outputs $0$ only when both inputs are $1$],
  [NOR], $not (A or B)$, [Outputs $0$ when at least one input is $1$],
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

== Normal Forms

#definition[
  A _literal_ is a Boolean variable or its negation (e.g., $x$, $not x$).
]

// #definition[
//   A _clause_ is a disjunction (OR) of literals.
//   For example, $(x or not y)$ is a 2-clause.
// ]

// #definition[
//   A _term_ is a conjunction (AND) of literals.
//   For example, $(x and not y)$ is a 2-term.
// ]

#definition[DNF][
  A Boolean formula is in _disjunctive normal form (DNF)_ if it is a disjunction (OR) of _terms_ --- conjunctions (AND) of literals.
]
#example[
  $f(x,y,z) = underbracket((x and y and not z), "term") or underbracket((not x and z), "term") or underbracket((not y and not z), "term") or underbracket(#hide("(") x #hide(")"), "term")$
]

#definition[CNF][
  A Boolean formula is in _conjunctive normal form (CNF)_ if it is a conjunction (AND) of _clauses_ --- disjunctions (OR) of literals.
]
#example[
  $f(x,y,z) = underbracket((x or y or not z), "clause") and underbracket((not x or z), "clause") and underbracket((not y or not z), "clause") and underbracket(#hide("(") x #hide(")"), "clause")$
]

== Minterms and Maxterms

#definition[Minterm and Maxterm][
  - A _minterm_ is a product (AND) of literals where each variable appears exactly once.
  - A _maxterm_ is a sum (OR) of literals where each variable appears exactly once.
]

#note[
  A minterm (maxterm) is a function that evaluates to 1 (0, respectively) for exactly one combination of variable values.
]

#example[
  $f(x,y,z) = x overline(y) z$ is a minterm, and $g(x,y,z) = x + overline(y) + z$ is a maxterm for variables $x, y, z$.
  - $f(x,y,z) = 1$ only on input $101$, i.e., $x = 1$, $y = 0$, $z = 1$, correspending to the minterm $x overline(y) z$.
  - $g(x,y,z) = 0$ only on input $010$, i.e., $x = 0$, $y = 1$, $z = 0$, correspending to the maxterm $overline(x) + y + overline(z)$.
]

== Canonical Forms

#definition[SoP][
  Every Boolean function can be _uniquely_ expressed as a _sum of minterms_ (SoP, Sum of Products) corresponding to rows where the function evaluates to 1.

  // TODO: example
]

#definition[PoS][
  Every Boolean function can be _uniquely_ expressed as a _product of maxterms_ (PoS, Product of Sums) corresponding to rows where the function evaluates to 0.

  // TODO: example
]

// TODO: Blake canonical form

== Karnaugh Maps

#definition[
  A _Karnaugh map_ (K-map) is a graphical method for simplifying Boolean expressions by visually identifying adjacent minterms that can be combined.
]

// #[
//   #import "karnaugh.typ": karnaugh
//   #let x = -1
//   #karnaugh(
//     ("AB", "CD"),
//     (
//       (0, 0, 0, x),
//       (0, 1, x, 0),
//       (1, 1, 1, 0),
//       (x, 1, 0, x),
//     ),
//     implicants: (
//       (1, 1, 2),
//       (2, 0, 2),
//     ),
//   )
// ]

#[
  #import "@preview/k-mapper:1.2.0": karnaugh

  #karnaugh(
    16,
    x-label: $C D$,
    y-label: $A B$,
    manual-terms: range(16),
    implicants: ((5, 7), (5, 13), (15, 15)),
    vertical-implicants: ((1, 11),),
    horizontal-implicants: ((4, 14),),
    // corner-implicants: true,
  )
]

== Zhegalkin Polynomials

#definition[
  A _Zhegalkin polynomial_ is a representation of a Boolean function as a polynomial over $"GF"(2)$ using XOR ($xor$) and AND ($and$, often omitted) operations.
]

// TODO: mention "algebraic normal form (ANF)"

#theorem[
  Every Boolean function has a unique representation as a Zhegalkin polynomial:
  $
    f(x_1, dots, x_n) = xor.big_(S subset.eq {1,dots,n}) (a_S product_(i in S) x_i)
  $
  where $a_S in {0,1}$ and $xor$ denotes XOR.
]

#example[
  $f(x,y) = x or y = x xor y xor x y$
]

== Binary Decision Diagrams (BDDs)

#definition[BDD][
  A _binary decision diagram (BDD)_ is a directed acyclic graph representing a Boolean function, where each non-terminal node represents a variable test and edges represent variable assignments.
]

// TODO: ordered BDD

#definition[ROBDD][
  A _reduced_ ordered binary decision diagram (ROBDD) is an ordered BDD with a fixed variable ordering where:
  - No variable appears more than once on any path
  - No two nodes have identical low and high successors
  - No node has identical low and high successors
]

#theorem[
  // For a fixed variable ordering, every Boolean function has a _unique_ ROBDD.
  Every Boolean function has a unique reduced ordered binary decision diagram (ROBDD) representation for a given variable ordering.
]

== TODO

- ...

// == Bibliography
// #bibliography("refs.yml")

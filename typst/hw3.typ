#import "common.typ": *
#show: template

#set page(
  paper: "a4",
  margin: (top: 3cm, rest: 2cm),
  header: [
    #set text(10pt)
    #smallcaps[*Homework Assignment \#3*]
    #h(1fr)
    #link("https://github.com/Lipen/discrete-math-course")[*Discrete Mathematics*]
    \
    *Boolean Algebra*
    #h(1fr)
    *$#emoji.leaf.maple$Fall 2025*
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

// Custom operators and notation
#let Bool = math.bb("B")
#let power(x) = $cal(P)(#x)$
#let pair(a, b) = $angle.l #a, #b angle.r$
#let triple(a, b, c) = $angle.l #a, #b, #c angle.r$
#let card(x) = $abs(#x)$
#let DNF = math.op("DNF")
#let CNF = math.op("CNF")
#let BCF = math.op("BCF")
#let ANF = math.op("ANF")
#let ITE = math.op("ITE")
#let majority = math.op("majority")

// Boolean function notation
#let bfunc(n, k) = $f^((#n))_#k$

// Color helpers
#let Green(x) = text(green.darken(20%), x)
#let Red(x) = text(red.darken(20%), x)
#let Blue(x) = text(blue.darken(20%), x)
#let Orange(x) = text(orange.darken(20%), x)

#let True = Green(`true`)
#let False = Red(`false`)

#let YES = Green(sym.checkmark)
#let NO = Red(sym.crossmark)

// Task list helper
#let tasklist(id, cols: 1, body) = {
  let s = counter(id)
  s.update(1)
  set enum(numbering: _ => context {
    s.step()
    s.display("1.")
  })
  columns(cols, gutter: 1em)[#body]
}


== Problem 1: Karnaugh Map Analysis

Boolean functions can be represented in various forms, and Karnaugh maps (K-maps) provide a visual method for simplification.
In this problem, you'll work with a 5-variable function derived from cryptographic hashing.

#block(sticky: true)[*Part (a): Hash-Based Function Generation*]

To generate a unique Boolean function for analysis:

+ Calculate the SHA-256 hash $h$ of the string $s = #`"DM Fall 2025 HW3"`$ (without quotes, encoded in UTF-8).
+ Convert the hash $h$ to a 256-bit binary string $b$ (prepend leading zeros if necessary).
+ Partition the binary string $b$ into eight 32-bit slices: $r_1 = b_(1 dots 32)$, $r_2 = b_(33 dots 64)$, ..., $r_8 = b_(225 dots 256)$.
+ Compute the XOR of all slices: $d = r_1 xor r_2 xor dots.c xor r_8$.
+ Apply a final mask: $w = d xor #`0x71be8976`$.

*Hint:* The last (least significant) 8 bits of $h$ should be $dots#`00010101`$, and the first (most significant) 4~bits of $d$ should be $dots#`0110`)$.

#block(sticky: true)[*Part (b): Karnaugh Map Construction*]

The 32-bit value $w = (w_1 w_2 dots.c w_(32))$ defines a Boolean function $f(A, B, C, D, E)$ via its truth table, where:
- The most significant bit (MSB) $w_1$ corresponds to $f(0,0,0,0,0)$
- The least significant bit (LSB) $w_(32)$ corresponds to $f(1,1,1,1,1)$

Draw a Karnaugh map for this function using the template structure below (you may use the CeTZ diagram or draw by hand):

#align(center)[
  #import cetz: canvas, draw
  #canvas({
    import draw: *

    // Grid
    grid(
      (0, 0),
      (8, 4),
      stroke: 0.4pt,
    )

    // Column headers (CDE)
    content((0.5, 4), [000], anchor: "south", padding: 0.2)
    content((1.5, 4), [001], anchor: "south", padding: 0.2)
    content((2.5, 4), [011], anchor: "south", padding: 0.2)
    content((3.5, 4), [010], anchor: "south", padding: 0.2)
    content((4.5, 4), [110], anchor: "south", padding: 0.2)
    content((5.5, 4), [111], anchor: "south", padding: 0.2)
    content((6.5, 4), [101], anchor: "south", padding: 0.2)
    content((7.5, 4), [100], anchor: "south", padding: 0.2)

    // Row headers (AB)
    content((0, 3.5), [00], anchor: "east", padding: 0.2)
    content((0, 2.5), [01], anchor: "east", padding: 0.2)
    content((0, 1.5), [11], anchor: "east", padding: 0.2)
    content((0, 0.5), [10], anchor: "east", padding: 0.2)

    // Side annotations for variables
    line((-0.7, 0), (-0.7, 2))
    content((-0.7, 1), std.rotate(-90deg)[$A$], anchor: "east", padding: 0.2)
    line((8.2, 2), (8.2, 4))
    content((8.2, 3), std.rotate(-90deg)[$B$], anchor: "west", padding: 0.2)
    line((4, 4.7), (8, 4.7))
    content((6, 4.7), [$C$], anchor: "south", padding: 0.2)
    line((2, -0.3), (6, -0.3))
    content((4, -0.3), [$D$], anchor: "north", padding: 0.2)
    line((1, 4.7), (3, 4.7))
    content((2, 4.7), [$E$], anchor: "south", padding: 0.2)
    line((5, -0.6), (7, -0.6))
    content((6, -0.6), [$E$], anchor: "north", padding: 0.2)
  })
]

#block(sticky: true)[*Part (c): Minimization*]

Using your Karnaugh map:

+ Find the *minimal DNF* (disjunctive normal form) for $f$.
+ Find the *minimal CNF* (conjunctive normal form) for $f$.
+ Determine the number of *prime implicants* (equivalently, find the size of the BCF).

#block(sticky: true)[*Part (d): Interpretation*]

+ How many minterms are in the minimal DNF compared to the full truth table representation?
+ Explain why K-maps become impractical for functions with more than 5-6 variables.


== Problem 2: Normal Forms and Zhegalkin Polynomials

For each given function $f_i$ of 4 arguments, perform comprehensive analysis using multiple representation methods.

#block(sticky: true)[*Required Tasks*]

For each function below:

+ Draw the *Karnaugh map* (4-variable, use standard Gray code ordering).
+ Find the *Blake Canonical Form (BCF)* --- the set of all prime implicants.
+ Find the *minimal DNF* (disjunctive normal form).
+ Find the *minimal CNF* (conjunctive normal form).
+ Construct the *ANF* (algebraic normal form / Zhegalkin polynomial) using one of:
  - K-map method
  - Tabular ("triangle") method
  - Pascal's triangle method

  *Requirement:* Use each ANF construction method at least once across all functions.

#block(sticky: true)[*Functions to Analyze*]

#tasklist("prob2", cols: 1)[
  + $f_1 = bfunc(4, 47541)$
    #footnote[
      The notation $bfunc(n, k)$ represents the $k$-th Boolean function of $n$ variables, where $k$ is the decimal representation of the truth table with MSB = $f(0,dots,0)$ and LSB = $f(1,dots,1)$.
    ]

  + $f_2 = sum m(1, 4, 5, 6, 8, 12, 13)$
    #footnote[
      The notation $sum m(dots)$ represents the sum of minterms (DNF) where each number indicates a minterm index.
    ]

  + $f_3 = bfunc(4, 51011) xor bfunc(4, 40389)$

  + $f_4 = A overline(B) D + overline(A) thin overline(C) D + overline(B) C overline(D) + A overline(C) D$
]

#note[
  WolframAlpha interprets "$n$-th Boolean function of $k$ variables" query with _reversed_ bit order.
  To use it correctly, flip the truth table first.
  For example, for $bfunc(2, 10)$, use the query "5th Boolean function of 2 variables" since $op("rev")(1010_2) = 0101_2 = 5_(10)$.
]

#block(sticky: true)[*Part (b): Comparison and Analysis*]

+ Which function has the most prime implicants? Which has the fewest?
+ For which function does the minimal DNF equal the minimal CNF in size (number of literals)?
+ Which function has the simplest ANF (fewest terms)?


== Problem 3: CNF Conversion Techniques

Converting arbitrary Boolean formulae to Conjunctive Normal Form (CNF) is a fundamental task in automated reasoning, SAT solving, and formal verification.
This problem explores systematic CNF conversion techniques.

#block(sticky: true)[*Part (a): Basic Conversions*]

Convert each of the following formulae to CNF. Show all intermediate steps.

#tasklist("prob3a", cols: 2)[
  + $X iff (A and B)$

  + $Z iff or.big_i C_i$
    #footnote[
      The notation $or.big_i C_i$ represents $C_1 or C_2 or dots.c or C_n$ for some finite set of variables.
    ]

  + $D_1 xor D_2 xor dots.c xor D_n$

  #colbreak()

  + $majority(X_1, X_2, X_3)$
    #footnote[
      The majority function returns 1 iff more than half of its inputs are 1.
    ]

  + $R arrow.r (S arrow.r (T arrow.r and.big_i F_i))$

  + $M arrow.r (H iff or.big_i D_i)$
]

#block(sticky: true)[*Part (b): Tseitin Transformation*]

The Tseitin transformation converts arbitrary formulae to equisatisfiable CNF by introducing auxiliary variables.

+ Apply the Tseitin transformation to: $(A or B) and (C or (D and E))$
+ Prove that your CNF is equisatisfiable with the original formula.
+ Compare the size (number of clauses and variables) of the Tseitin CNF with a direct CNF conversion.

#block(sticky: true)[*Part (c): Application to SAT Solving*]

Consider a constraint satisfaction problem --- a scheduling system must satisfy:
- Task $T_1$ requires either resource $R_1$ or both $R_2$ and $R_3$
- If $R_1$ is used, then either $R_4$ or $R_5$ must also be used
- Resources $R_2$ and $R_4$ cannot be used simultaneously
- At least two of ${R_1, R_2, R_3}$ must be allocated

+ Encode these constraints as Boolean formulae.
+ Convert to CNF.
+ Is there a satisfying assignment? If so, find all solutions.


== Problem 4: Functional Completeness and Post's Criterion

A set of Boolean functions is _functionally complete_ if every Boolean function can be expressed using only functions from that set.
Post's criterion provides a systematic way to verify completeness.

#definition[
  A set of Boolean functions $F$ is functionally complete if it is not contained in any of the following five classes:
  - $T_0$: functions preserving 0 (i.e., $f(0, dots, 0) = 0$)

  - $T_1$: functions preserving 1 (i.e., $f(1, dots, 1) = 1$)

  - $S$: self-dual functions (i.e., $f(overline(x)_1, dots, overline(x)_n) = overline(f(x_1, dots, x_n))$)

  - $M$: monotone functions (if $x <= y$ coordinate-wise, then $f(x) <= f(y)$)

  - $L$: linear functions (expressible as $a_0 xor a_1 x_1 xor dots.c xor a_n x_n$)
]

#block(sticky: true)[*Part (a): Completeness Analysis*]

For each system $F_i$ below, determine whether it is functionally complete using Post's criterion:

#tasklist("prob4a", cols: 2)[
  + $F_1 = {and, or, not}$

  + $F_2 = {bfunc(2, 14)}$
    #footnote[
      This is the NAND function: $bfunc(2, 14)(x, y) = overline(x and y)$
    ]

  + $F_3 = {arrow.r, arrow.r.not}$
    #footnote[
      Where $arrow.r.not$ denotes "does not imply": $A arrow.r.not B equiv A and not B$
    ]

  + $F_4 = {1, iff, and}$
]

#block(sticky: true)[*Part (b): Majority Function Representation*]

For each basis $F_i$ that you proved is complete in Part (a):

+ Express the $majority(A, B, C)$ function using only operations from $F_i$.
+ Draw a combinational Boolean circuit for your formula.
+ Count the number of gates used in your circuit.

#block(sticky: true)[*Part (c): Gate Complexity*]

+ Which basis from Part (a) gives the smallest circuit for $majority(A, B, C)$?
+ Prove that any circuit for $majority(A, B, C)$ using only NAND gates must use at least 9 gates.
  #footnote[Hint: Consider the relationship between circuit depth and the number of NAND gates needed.]


== Problem 5: Zhegalkin Polynomial Basis

The Zhegalkin polynomial (algebraic normal form) represents Boolean functions using XOR and AND operations over $bb(F)_2$, the field with two elements.

#definition[
  The *Zhegalkin basis* is the set ${xor, and, 1}$, where:
  - $xor$ is the XOR (exclusive or) operation
  - $and$ is the AND (conjunction) operation
  - $1$ is the constant function returning true
]

#block(sticky: true)[*Part (a): Direct Completeness Proof*]

Prove that the Zhegalkin basis ${xor, and, 1}$ is functionally complete *without* using Post's criterion.

Your proof should:
+ Show how to express NOT using ${xor, 1}$
+ Show how to express OR using ${and, xor, 1}$
+ Explain why this establishes completeness

#block(sticky: true)[*Part (b): Polynomial Degree Analysis*]

The _degree_ of a Zhegalkin polynomial is the maximum number of variables in any monomial.

+ Find the Zhegalkin polynomial for $majority(x_1, x_2, x_3)$ and determine its degree.
+ Prove that any Boolean function of $n$ variables has a unique Zhegalkin polynomial representation.
+ Show that the parity function $p_n (x_1, dots, x_n) = x_1 xor dots.c xor x_n$ has degree 1, while $and(x_1, dots, x_n)$ has degree $n$.

#block(sticky: true)[*Part (c): Cryptographic Applications*]

In cryptography, functions with high algebraic degree are desirable for security.

+ The S-box
  #footnote[
    An S-box (substitution box) is a basic component of symmetric key cryptography that performs substitution.
  ]
  function $S: Bool^3 to Bool$ defined by the truth table $(0,1,1,0,1,0,0,1)$ is used in a cipher. Find its Zhegalkin polynomial and degree.

+ Explain why cryptographic designers prefer Boolean functions with maximum algebraic degree.

+ Construct a 3-variable Boolean function with degree 3 that is balanced
  #footnote[A Boolean function is _balanced_ if it outputs 0 and 1 equally often.]
  and has no linear terms.


== Problem 6: Circuit Analysis and Truth Tables

Given the following combinational circuit with 3 inputs $(A, B, C)$ and 2 outputs $(f_1, f_2)$:

#align(center)[
  #import fletcher: diagram, edge, node
  #set text(9pt)
  #diagram(
    node-stroke: 1pt,
    edge-stroke: 1pt,
    spacing: (12mm, 10mm),

    // Inputs
    node((0, 0), $A$, name: <A>),
    node((0, 1), $B$, name: <B>),
    node((0, 2), $C$, name: <C>),

    // Gates - layer 1
    node((2, 0.5), $and$, shape: rect, name: <g2>), // AND(A,B) = g2

    // Gates - layer 2
    node((4, 1.5), $overline(or)$, shape: rect, name: <g3>), // NOR(g2,C) = g3
    node((4, 0.5), $and$, shape: rect, name: <g4>), // AND(g2,C) = g4

    // Gates - layer 3
    node((6, 1), $overline(or)$, shape: rect, name: <g5>), // NOR(g4,g3) = g5

    // Gates - layer 4
    node((8, 0), $and$, shape: rect, name: <g6>), // AND(A,g5) = g6
    node((8, 2), $or$, shape: rect, name: <g1>), // OR(A,B) = g1
    node((8, 3), $overline(and)$, shape: rect, name: <g7>), // NAND(B,g5) = g7

    // Gates - layer 5
    node((10, 2.5), $overline(and)$, shape: rect, name: <g8>), // NAND(g1,g7) = g8

    // Outputs
    node((11, 0), $f_1$, name: <out1>),
    node((11, 2.5), $f_2$, name: <out2>),

    // Connections - inputs to gates
    edge(<A>, <g2>, "->"),
    edge(<B>, <g2>, "->"),
    edge(<A>, <g6>, "->"),
    edge(<A>, <g1>, "->"),
    edge(<B>, <g1>, "->"),
    edge(<B>, <g7>, "->"),

    // g2 outputs
    edge(<g2>, <g3>, "->", label: $g_2$),
    edge(<g2>, <g4>, "->"),

    // C connections
    edge(<C>, <g3>, "->"),
    edge(<C>, <g4>, "->"),

    // g3, g4 to g5
    edge(<g3>, <g5>, "->", label: $g_3$),
    edge(<g4>, <g5>, "->", label: $g_4$),

    // g5 outputs
    edge(<g5>, <g6>, "->", label: $g_5$),
    edge(<g5>, <g7>, "->"),

    // g1, g7 to g8
    edge(<g1>, <g8>, "->", label: $g_1$),
    edge(<g7>, <g8>, "->", label: $g_7$),

    // Final outputs
    edge(<g6>, <out1>, "->"),
    edge(<g8>, <out2>, "->"),
  )
]

#block(sticky: true)[*Tasks*]

+ Compute the complete truth table for the function $f: Bool^3 to Bool^2$ with semantics $triple(A, B, C) maps.bar pair(f_1, f_2)$.

+ Express both $f_1$ and $f_2$ in minimal DNF.

+ Identify any redundant gates in the circuit. Can the circuit be simplified while maintaining the same functionality?

+ What is the maximum propagation delay through this circuit (measured in gate delays, assuming all gates have unit delay)?


#pagebreak()

== Problem 7: Gray Code Conversion Circuit

Gray code is a binary numeral system where consecutive values differ in only one bit.
This property makes it useful in error correction and digital communications.

#definition[
  _Gray code_ is a binary encoding where adjacent values differ in exactly one bit position.
  For a 4-bit binary number $(b_3 b_2 b_1 b_0)_2$, the corresponding Gray code $(g_3 g_2 g_1 g_0)_"Gray"$ is computed as:
  $
    g_i = cases(
      b_i & "if" i = 3,
      b_i xor b_(i+1) & "if" i < 3
    )
  $
]

#example[
  - Binary $#`0000` _2$ maps to Gray $#`0000` _"Gray"$
  - Binary $#`1001` _2$ maps to Gray $#`1101` _"Gray"$
  - Binary $#`1111` _2$ maps to Gray $#`1000` _"Gray"$
]

#block(sticky: true)[*Part (a): Truth Table Construction*]

+ Create a complete truth table showing the mapping from 4-bit binary $(b_3, b_2, b_1, b_0)$ to 4-bit Gray code $(g_3, g_2, g_1, g_0)$ for all 16 possible inputs.

+ Verify the key property: each consecutive binary number maps to a Gray code that differs from the previous one in exactly one bit.

#block(sticky: true)[*Part (b): Minimal Circuit Design*]

+ For each output bit $g_i$, find the minimal Boolean expression.

+ Design a circuit that implements the binary-to-Gray conversion using *only NAND and NOR gates*.

+ Count the total number of gates in your design.

#block(sticky: true)[*Part (c): Reverse Conversion*]

+ Derive the formula for converting from Gray code back to binary.

+ Design a circuit for Gray-to-binary conversion using only NAND gates.

+ Compare the complexity (gate count) of forward vs. reverse conversion circuits.


#pagebreak()

== Problem 8: Arithmetic Circuits

Digital circuits for arithmetic operations are fundamental building blocks in computer processors.

#definition[
  A _half subtractor_ takes two bits $(x, y)$ and produces a difference bit $d$ and a borrow bit $b$:
  - $d = x xor y$ (difference)
  - $b = overline(x) and y$ (borrow)

  A _full subtractor_ takes three bits $(x, y, b_"in")$ where $b_"in"$ is a borrow input, and produces:
  - $d = x xor y xor b_"in"$ (difference)
  - $b_"out" = (overline(x) and y) or (overline(x) and b_"in") or (y and b_"in")$ (borrow output)
]

#block(sticky: true)[*Part (a): Half Subtractor*]

+ Derive the Boolean expressions for the difference $d$ and borrow $b$ outputs of a half subtractor.

+ Construct a circuit using only AND, OR, and NOT gates.

+ Verify your design with a truth table.

#block(sticky: true)[*Part (b): Full Subtractor*]

+ Construct a full subtractor circuit using two half subtractors and NAND gates.

+ Draw the complete circuit diagram.

+ Calculate the propagation delay of your full subtractor (in gate delays).

#block(sticky: true)[*Part (c): Saturating Subtractor*]

Design a 4-bit *saturating subtractor* that computes $d = max(0, x - y)$ where $x = (x_3 x_2 x_1 x_0)_2$ and $y = (y_3 y_2 y_1 y_0)_2$:

- When $x >= y$: output bits $(d_3 d_2 d_1 d_0)$ represent $d = x - y$
- When $x < y$: output must be `0000` (saturate to zero)

+ Design the circuit using half/full subtractors, AND, OR, and NOT gates.

+ Explain how your circuit detects the condition $x < y$.

+ Test your design with examples: $(5 - 3)$, $(3 - 5)$, and $(15 - 8)$.


== Problem 9: Comparators and Multipliers

#block(sticky: true)[*Part (a): 2-bit Comparator*]

Design a circuit that compares two 2-bit integers $(x_1 x_0)_2$ and $(y_1 y_0)_2$, outputting 1 when $x > y$ and 0 otherwise.

+ Derive the Boolean expression for the output.

+ Construct the circuit using basic gates (AND, OR, NOT).

+ Extend your design to also output equality ($x = y$) and less-than ($x < y$) signals.

#block(sticky: true)[*Part (b): 2-bit Multiplier*]

Design a circuit that computes the product $p = x dot y$ where $x = (x_1 x_0)_2$ and $y = (y_1 y_0)_2$ are 2-bit integers.
The output is a 4-bit value $(p_3 p_2 p_1 p_0)_2$.

+ Create a truth table for all four output bits.

+ Find minimal Boolean expressions for each output bit $p_i$.

+ Draw the complete multiplier circuit.

+ Verify with examples: $3 times 2 = 6$, $3 times 3 = 9$, $1 times 1 = 1$.

#block(sticky: true)[*Part (c): Circuit Optimization*]

+ Compare the gate count of your multiplier with a design based on repeated addition.

+ Identify any shared sub-expressions that could reduce the total gate count.


== Problem 10: Conditional Logic and BDDs

#block(sticky: true)[*Part (a): If-Then-Else Function*]

Consider the ternary Boolean function $ITE: Bool^3 to Bool$ defined as:
$
  ITE(c, x, y) = cases(
    x & "if" c = 0,
    y & "if" c = 1
  )
$

This is the Boolean equivalent of the conditional operator `c ? y : x` in programming.

+ Construct a Boolean formula for $ITE(c, x, y)$ using the standard basis ${and, or, not}$.

+ Determine whether the set ${ITE}$ alone is functionally complete.
  Either prove completeness or show which Post classes it belongs to.

+ Express $x xor y$ using only the $ITE$ function.

#block(sticky: true)[*Part (b): Binary Decision Diagrams*]

For each function $f_i$ below, construct a Reduced Ordered Binary Decision Diagram (ROBDD) using the natural variable order $x_1 prec x_2 prec dots.c prec x_n$.

#definition[
  A _Binary Decision Diagram_ (BDD) is a rooted directed acyclic graph with:
  - Decision nodes labeled with Boolean variables, each having two outgoing edges (low/dashed for 0, high/solid for 1)
  - Two terminal nodes labeled 0 and 1

  A BDD is _ordered_ if variables appear in the same order on all paths.

  It is _reduced_ if:
  - No node $v$ has identical low and high children
  - No two nodes represent isomorphic sub-BDDs
]

#tasklist("prob10b", cols: 2)[
  + $f_1(x_1, x_2, x_3, x_4) = x_1 xor x_2 xor x_3 xor x_4$

  + $f_2(x_1, dots, x_5) = majority(x_1, dots, x_5)$

  #colbreak()

  + $f_3(x_1, dots, x_4) = sum m(1, 2, 5, 12, 15)$

  + $f_4(x_1, dots, x_6) = x_1 x_4 + x_2 x_5 + x_3 x_6$
]

#block(sticky: true)[*Part (c): Variable Ordering Impact*]

+ For each function in Part (b), determine whether a different variable ordering can produce a smaller ROBDD.
  If so, show the improved ordering and the resulting BDD.

+ Prove that for the parity function $f(x_1, dots, x_n) = x_1 xor dots.c xor x_n$, any variable ordering produces an ROBDD with $2^n$ nodes.

+ Find a variable ordering for $f_4$ that minimizes the number of nodes in the ROBDD.


#pagebreak()

#line(length: 100%, stroke: 0.4pt)

*Submission Guidelines:*
- Organize solutions clearly with problem numbers and parts (a, b, c, etc.).
- For circuit designs: Draw clear diagrams with labeled gates and signals.
- For proofs: State assumptions, show logical steps, and clearly mark conclusions.
- For truth tables: Use standard binary ordering (000, 001, 010, ..., 111).
- For K-maps: Show groupings clearly and indicate which groups form the minimal form.

*Grading Rubric:*
- Correctness of circuits and Boolean expressions: 40%
- Mathematical rigor and proof quality: 30%
- Clarity of diagrams and presentation: 20%
- Completeness and attention to detail: 10%

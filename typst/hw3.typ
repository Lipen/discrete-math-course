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


== Problem 1: Karnaugh Maps

You'll analyze a 5-variable Boolean function using Karnaugh maps.


#block(sticky: true)[*Part (a): Generate the Function*]

Compute a unique 5-variable Boolean function as follows:

+ Hash the string `"DM Fall 2025 HW3"` (UTF-8, no quotes) using SHA-256 to get 256 bits.
+ Split the result into eight 32-bit blocks and XOR them together to get 32 bits.
+ XOR with the mask `0x71be8976` to obtain $w = (w_1 w_2 dots.c w_(32))_2$.

This 32-bit value $w$ encodes the truth table of your function $f(A,B,C,D,E)$, where bit $w_1$ (MSB) gives $f(0,0,0,0,0)$ and bit $w_(32)$ (LSB) gives $f(1,1,1,1,1)$.

*Check:* The hash ends with $dots#`00010101`$, and after XORing the blocks, the result starts with $#`0110`dots$

#block(sticky: true)[*Part (b): Draw the K-Map*]

Construct a 5-variable Karnaugh map for your function using the template below:

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

#block(sticky: true)[*Part (c): Find Minimal Forms*]

Using your K-map:

+ Find the minimal DNF for $f$.
+ Find the minimal CNF for $f$.
+ Count all prime implicants.

#block(sticky: true)[*Part (d): Reflection*]

+ How much smaller is your minimal DNF compared to listing all minterms?
+ Why do K-maps become impractical beyond 5-6 variables?


#pagebreak()

== Problem 2: Boolean Function Analysis

Analyze the following 4-variable functions using multiple representation methods.

For each function:
- Draw the K-map.
- Find all prime implicants (Blake Canonical Form).
- Find the minimal DNF and minimal CNF.
- Construct the ANF using the K-map method, tabular method, or Pascal's triangle method.

*Requirement:* Use each ANF construction method at least once.

#tasklist("prob2", cols: 2)[
  + $f_1 = bfunc(4, 47541)$
    #footnote[
      Notation: $bfunc(n, k)$ is the $k$-th Boolean function of $n$ variables, where $k$ is the decimal value of the truth table with MSB = $f(0,dots,0)$ and LSB = $f(1,dots,1)$.
    ]

  + $f_2 = sum m(1, 4, 5, 6, 8, 12, 13)$
    #footnote[
      Notation: $sum m(dots)$ denotes the sum of minterms.
    ]

  #colbreak()

  + $f_3 = bfunc(4, 51011) xor bfunc(4, 40389)$

  + $f_4 = A overline(B) D + overline(A) thin overline(C) D + overline(B) C overline(D) + A overline(C) D$
]

#note[
  WolframAlpha reverses the bit order for "$n$-th Boolean function of $k$ variables". \
  For $bfunc(2, 10) = 1010_2$, query "5th Boolean function" since $op("rev")(1010_2) = 0101_2 = 5$.
]

#block(sticky: true)[*Analysis*]

+ Which function has the most/fewest prime implicants?
+ For which function do the minimal DNF and CNF have the same size?
+ Which function has the simplest ANF?


== Problem 3: CNF Conversion

Converting Boolean formulae to CNF is fundamental for SAT solving and automated reasoning.

#block(sticky: true)[*Part (a): Basic Conversions*]

Convert each formula to CNF, showing all steps:

#tasklist("prob3a", cols: 3)[
  + $X iff (A and B)$

  + $Z iff or.big_i C_i$

  #colbreak()

  + $D_1 xor D_2 xor dots.c xor D_n$

  + $majority(X_1, X_2, X_3)$
    #footnote[
      Majority function returns 1 iff more than half of its inputs are 1.
    ]

  #colbreak()

  + $R arrow.r (S arrow.r (T arrow.r and.big_i F_i))$

  + $M arrow.r (H iff or.big_i D_i)$
]

#block(sticky: true)[*Part (b): Tseitin Transformation*]

The Tseitin transformation introduces auxiliary variables to convert any formula to equisatisfiable CNF.

+ Apply Tseitin to: $(A or B) and (C or (D and E))$
+ Prove equisatisfiability of your CNF with the original.
+ Compare the size (clauses and variables) with direct CNF conversion.

#block(sticky: true)[*Part (c): Resource Allocation*]

A system has five resources ${R_1, R_2, R_3, R_4, R_5}$ and must satisfy:
- Either $R_1$ or both $R_2$ and $R_3$
- If $R_1$, then $R_4$ or $R_5$
- Not both $R_2$ and $R_4$
- At least two of ${R_1, R_2, R_3}$

+ Encode these constraints as Boolean formulae.
+ Convert to CNF.
+ Find all satisfying assignments.


== Problem 4: Functional Completeness

A set of Boolean functions is _functionally complete_ if it can express any Boolean function.
Post's criterion provides a systematic test using five special classes.

#block(sticky: true)[*Part (a): Apply Post's Criterion*]

Determine whether each system is functionally complete:

#tasklist("prob4a", cols: 2)[
  + $F_1 = {and, or, not}$

  + $F_2 = {bfunc(2, 14)}$

  + $F_3 = {arrow.r, arrow.r.not}$
    #footnote[
      $(A imply.not B) equiv (A and not B)$
    ]

  + $F_4 = {1, iff, and}$
]

#block(sticky: true)[*Part (b): Express Majority*]

For each complete basis from Part (a):

+ Express $majority(A, B, C)$ using only that basis.
+ Draw the corresponding circuit.
+ Count the gates.

#block(sticky: true)[*Part (c): NAND Complexity*]

+ Which complete basis yields the smallest circuit for $majority(A, B, C)$?
+ Prove that any NAND-only circuit for $majority(A, B, C)$ needs at least 9 gates.


== Problem 5: Zhegalkin Polynomials

The Zhegalkin basis ${xor, and, 1}$ provides an algebraic view of Boolean functions over the field $bb(F)_2$.

#block(sticky: true)[*Part (a): Prove Completeness*]

Prove that ${xor, and, 1}$ is functionally complete _without_ using Post's criterion.

+ Express $not x$ using ${xor, 1}$.
+ Express $x or y$ using ${and, xor, 1}$.
+ Explain why this establishes completeness.

#block(sticky: true)[*Part (b): Polynomial Degree*]

The _degree_ of a Zhegalkin polynomial is the size of the largest monomial.

+ Find the Zhegalkin polynomial and degree of $majority(x_1, x_2, x_3)$.
+ Prove that every Boolean function has a unique Zhegalkin representation.
+ Show that $x_1 xor dots.c xor x_n$ has degree 1, while $x_1 and dots.c and x_n$ has degree $n$.

#block(sticky: true)[*Part (c): Algebraic Degree in Cryptography*]

High algebraic degree is important for cryptographic security.

+ An S-box function $S: Bool^3 to Bool$ has truth table $(0,1,1,0,1,0,0,1)$. Find its ANF and degree.
+ Why do cryptographers prefer functions with high algebraic degree?
+ Construct a balanced 3-variable function of degree 3 with no linear terms.
  #footnote[
    A function is _balanced_ if it outputs 0 and 1 equally often.
  ]


== Problem 6: Circuit Analysis

Given a combinational circuit with 3 inputs $(A, B, C)$ and 2 outputs $(f_1, f_2)$:

#align(center)[
  #import "@preview/circuiteria:0.2.0"
  #circuiteria.circuit({
    import circuiteria: *
    import "@preview/cetz:0.3.2": draw
    draw.scale(80%)

    let label(s) = text(size: 10pt)[#s]

    // Gates
    element.gate-and(id: "g2", x: 2, y: 1, w: 1.8, h: 1.8)
    element.gate-nor(id: "g3", x: 5, y: -0.5, w: 1.8, h: 1.8)
    element.gate-and(id: "g4", x: 5, y: 2, w: 1.8, h: 1.8)
    element.gate-nor(id: "g5", x: 8, y: 0.8, w: 1.8, h: 1.8)
    element.gate-and(id: "g6", x: 11, y: 3, w: 1.8, h: 1.8)
    element.gate-or(id: "g1", x: 11, y: 0.5, w: 1.8, h: 1.8)
    element.gate-nand(id: "g7", x: 11, y: -1.5, w: 1.8, h: 1.8)
    element.gate-nand(id: "g8", x: 14, y: -0.5, w: 1.8, h: 1.8)

    // Input stubs
    wire.stub("g2-port-in0", "west") // A
    wire.stub("g6-port-in0", "west") // A
    wire.stub("g1-port-in0", "west") // A
    wire.stub("g2-port-in1", "west") // B
    wire.stub("g1-port-in1", "west") // B
    wire.stub("g7-port-in0", "west") // B
    wire.stub("g3-port-in1", "west") // C
    wire.stub("g4-port-in1", "west") // C

    // Output stubs
    wire.stub("g6-port-out", "east")
    wire.stub("g8-port-out", "east")

    // Gate-to-gate connections
    wire.wire("w1", ("g2-port-out", "g3-port-in0"))
    wire.wire("w2", ("g2-port-out", "g4-port-in0"))
    wire.wire("w3", ("g4-port-out", "g5-port-in0"))
    wire.wire("w4", ("g3-port-out", "g5-port-in1"))
    wire.wire("w5", ("g5-port-out", "g6-port-in1"))
    wire.wire("w6", ("g5-port-out", "g7-port-in1"))
    wire.wire("w7", ("g1-port-out", "g8-port-in0"))
    wire.wire("w8", ("g7-port-out", "g8-port-in1"))

    // Labels for inputs
    draw.content((rel: (-0.5, 0), to: "g2-port-in0"), anchor: "east", label[$A$], padding: .2)
    draw.content((rel: (-0.5, 0), to: "g6-port-in0"), anchor: "east", label[$A$], padding: .2)
    draw.content((rel: (-0.5, 0), to: "g1-port-in0"), anchor: "east", label[$A$], padding: .2)
    draw.content((rel: (-0.5, 0), to: "g2-port-in1"), anchor: "east", label[$B$], padding: .2)
    draw.content((rel: (-0.5, 0), to: "g1-port-in1"), anchor: "east", label[$B$], padding: .2)
    draw.content((rel: (-0.5, 0), to: "g7-port-in0"), anchor: "east", label[$B$], padding: .2)
    draw.content((rel: (-0.5, 0), to: "g3-port-in1"), anchor: "east", label[$C$], padding: .2)
    draw.content((rel: (-0.5, 0), to: "g4-port-in1"), anchor: "east", label[$C$], padding: .2)

    // Labels for outputs
    draw.content((rel: (0.5, 0), to: "g6-port-out"), anchor: "west", label[$f_1$], padding: .2)
    draw.content((rel: (0.5, 0), to: "g8-port-out"), anchor: "west", label[$f_2$], padding: .2)

    // Gate labels
    draw.content("g2", label[$g_2$])
    draw.content("g3", label[$g_3$])
    draw.content("g4", label[$g_4$])
    draw.content("g5", label[$g_5$])
    draw.content("g6", label[$g_6$])
    draw.content("g1", label[$g_1$])
    draw.content("g7", label[$g_7$])
    draw.content("g8", label[$g_8$])
  })
]

+ Compute the truth table for $f: Bool^3 to Bool^2$ where $triple(A, B, C) maps.bar pair(f_1, f_2)$.
+ Express $f_1$ and $f_2$ in minimal DNF.
+ Identify redundant gates and simplify the circuit if possible.
+ What is the maximum propagation delay (in gate delays)?


== Problem 7: Gray Code Circuits

Gray code encodes integers so consecutive values differ in exactly one bit.

#example[
  - $#`0000` _2 to #`0000` _"Gray"$
  - $#`1001` _2 to #`1101` _"Gray"$
  - $#`1111` _2 to #`1000` _"Gray"$
]

// For 4-bit binary $(b_3 b_2 b_1 b_0)_2$ to Gray $(g_3 g_2 g_1 g_0)_"Gray"$:
// $
//   g_i = cases(
//     b_i & "if" i = 3,
//     b_i xor b_(i+1) & "if" i < 3
//   )
// $

#block(sticky: true)[*Part (a): Truth Table*]

+ Build the complete 4-bit binary-to-Gray truth table.
+ Verify that consecutive binary numbers map to Gray codes differing by one bit.

#block(sticky: true)[*Part (b): Circuit Design*]

+ Find minimal Boolean expressions for each $g_i$.
+ Design a binary-to-Gray circuit using only NAND and NOR gates.
+ Count the gates.

#block(sticky: true)[*Part (c): Reverse Conversion*]

+ Derive the Gray-to-binary conversion formula.
+ Design a Gray-to-binary circuit using only NAND gates.
+ Compare circuit complexity for both directions.


== Problem 8: Arithmetic Circuits

#block(sticky: true)[*Part (a): Half Subtractor*]

+ Derive Boolean expressions for the difference $d$ and borrow $b$ outputs of a half subtractor.
+ Construct the circuit using AND, OR, and NOT gates.
+ Verify with a truth table.

#block(sticky: true)[*Part (b): Full Subtractor*]

+ Build a full subtractor using two half subtractors and NAND gates.
+ Draw the circuit.
+ Calculate propagation delay.

#block(sticky: true)[*Part (c): Saturating Subtractor*]

Design a 4-bit saturating subtractor that computes $d = max(0, x - y)$:
- If $x >= y$: output $d = x - y$
- If $x < y$: output $#`0000`$ (saturate to zero)

+ Design the circuit using subtractors and basic gates.
+ Explain how your circuit detects $x < y$.
+ Test with: $5 - 3$, $3 - 5$, and $15 - 8$.


== Problem 9: Comparators and Multipliers

#block(sticky: true)[*Part (a): 2-bit Comparator*]

Design a circuit comparing 2-bit integers $(x_1 x_0)_2$ and $(y_1 y_0)_2$, outputting 1 when $x > y$.

+ Derive the Boolean expression.
+ Build the circuit using AND, OR, NOT gates.
+ Extend to also output $x = y$ and $x < y$ signals.

#block(sticky: true)[*Part (b): 2-bit Multiplier*]

Design a circuit computing $p = x dot y$ for 2-bit integers, giving a 4-bit result $(p_3 p_2 p_1 p_0)_2$.

+ Create the truth table.
+ Find minimal expressions for each $p_i$.
+ Draw the circuit.
+ Verify: $3 times 2 = 6$, $3 times 3 = 9$, $1 times 1 = 1$.

#block(sticky: true)[*Part (c): Optimization*]

+ Compare gate count with a repeated-addition design.
+ Identify shared sub-expressions to reduce gates.


== Problem 10: Conditional Logic and BDDs

#block(sticky: true)[*Part (a): If-Then-Else Function*]

The ternary function $ITE: Bool^3 to Bool$ is defined as:
$
  ITE(c, x, y) = cases(
    x & "if" c = 0,
    y & "if" c = 1
  )
$

This is the Boolean equivalent of `c ? y : x`.

+ Express $ITE(c, x, y)$ using ${and, or, not}$.
+ Is ${ITE}$ functionally complete?
  Identify which Post classes it belongs to.
+ Express $x xor y$ using only $ITE$.

#block(sticky: true)[*Part (b): Binary Decision Diagrams*]

Construct a Reduced Ordered BDD (ROBDD) for each function using natural variable order $x_1 prec x_2 prec dots.c$:

#tasklist("prob10b", cols: 2)[
  + $f_1(x_1, x_2, x_3, x_4) = x_1 xor x_2 xor x_3 xor x_4$

  + $f_2(x_1, dots, x_5) = majority(x_1, dots, x_5)$

  #colbreak()

  + $f_3(x_1, dots, x_4) = sum m(1, 2, 5, 12, 15)$

  + $f_4(x_1, dots, x_6) = x_1 x_4 + x_2 x_5 + x_3 x_6$
]

#block(sticky: true)[*Part (c): Variable Ordering*]

Find the variable ordering minimizing ROBDD size for each function in Part (b).


#pagebreak()

#line(length: 100%, stroke: 0.4pt)

*Submission Guidelines:*
- Organize solutions clearly with problem numbers and parts.
- For circuit designs: Draw clear diagrams with labeled gates and signals.
- For proofs: State assumptions, show logical steps, and clearly mark conclusions.
- For truth tables: Use standard binary ordering (000, 001, 010, ..., 111).
- For K-maps: Show groupings clearly and indicate which groups form the minimal form.

*Grading Rubric:*
- Correctness of circuits and Boolean expressions: 40%
- Mathematical rigor and proof quality: 30%
- Clarity of diagrams and presentation: 20%
- Completeness and attention to detail: 10%

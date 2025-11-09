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

Analyze a 5-variable Boolean function using Karnaugh maps.

#block(sticky: true)[*Part (a): Generate the Function*]

Hash the string `"DM Fall 2025 HW3"` (UTF-8) using SHA-256, split into eight 32-bit blocks, XOR them together, then XOR with mask `0x71be8976` to get $w = (w_1 w_2 dots.c w_(32))_2$.

This 32-bit string encodes $f(A,B,C,D,E)$: bit $w_1$ (MSB) is $f(0,0,0,0,0)$, bit $w_(32)$ (LSB) is $f(1,1,1,1,1)$.

*Check:* Hash ends with $dots#`00010101`$; after XORing blocks, result starts with $#`0110`dots$

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
    line((8.2, 1), (8.2, 3))
    content((8.2, 2), std.rotate(-90deg)[$B$], anchor: "west", padding: 0.2)
    line((4, -0.6), (8, -0.6))
    content((6, -0.6), [$C$], anchor: "north", padding: 0.2)
    line((2, -0.3), (6, -0.3))
    content((3, -0.3), [$D$], anchor: "north", padding: 0.2)
    line((1, 4.7), (3, 4.7))
    content((2, 4.7), [$E$], anchor: "south", padding: 0.2)
    line((5, 4.7), (7, 4.7))
    content((6, 4.7), [$E$], anchor: "south", padding: 0.2)
  })
]

#block(sticky: true)[*Part (c): Find Minimal Forms*]

+ Find minimal DNF and CNF for $f$ using your K-map.
+ Count all prime implicants.
+ If inputs where $A and B and C = 1$ are don't-care conditions, how do the minimal forms change?

#block(sticky: true)[*Part (d): Analysis*]

+ Compare your minimal DNF size to the full minterm expansion.
+ Which is smaller: minimal DNF or minimal CNF?
+ Why do K-maps become impractical beyond 5-6 variables?


#pagebreak()

== Problem 2: Circuit Analysis

Reverse-engineer a combinational circuit: derive Boolean functions, identify redundancies, and analyze timing.

Given a circuit with 3 inputs $(A, B, C)$ and 2 outputs $(f_1, f_2)$:

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
    element.gate-and(id: "g6", x: 11, y: 2.5, w: 1.8, h: 1.8)
    element.gate-or(id: "g7", x: 11, y: 0.35, w: 1.8, h: 1.8)
    element.gate-nand(id: "g1", x: 11, y: -1.8, w: 1.8, h: 1.8)
    element.gate-nand(id: "g8", x: 14, y: -0.6, w: 1.8, h: 1.8)

    // Input stubs
    wire.stub("g2-port-in0", "west") // A
    wire.stub("g6-port-in0", "west") // A
    wire.stub("g1-port-in0", "west") // A
    wire.stub("g2-port-in1", "west") // B
    wire.stub("g1-port-in1", "west") // B
    wire.stub("g7-port-in1", "west") // B
    wire.stub("g3-port-in1", "west") // C
    wire.stub("g4-port-in0", "west") // C

    // Output stubs
    wire.stub("g6-port-out", "east")
    wire.stub("g8-port-out", "east")

    // Gate-to-gate connections
    wire.wire("w1", ("g2-port-out", "g3-port-in0"), style: "zigzag")
    wire.intersection("w1.zig")
    wire.wire("w2", ("w1.zig", "g4-port-in1"), style: "zigzag", zigzag-ratio: 0%)
    wire.wire("w3", ("g4-port-out", "g5-port-in0"), style: "zigzag")
    wire.wire("w4", ("g3-port-out", "g5-port-in1"), style: "zigzag")
    wire.wire("w5", ("g5-port-out", "g6-port-in1"), style: "zigzag")
    wire.intersection("w5.zig")
    wire.wire("w6", ("w5.zig", "g7-port-in0"))
    wire.wire("w7", ("g7-port-out", "g8-port-in0"), style: "zigzag")
    wire.wire("w8", ("g1-port-out", "g8-port-in1"), style: "zigzag")

    // Labels for inputs
    draw.content((rel: (-0.5, 0), to: "g2-port-in0"), anchor: "east", label[$A$], padding: .2)
    draw.content((rel: (-0.5, 0), to: "g6-port-in0"), anchor: "east", label[$A$], padding: .2)
    draw.content((rel: (-0.5, 0), to: "g1-port-in0"), anchor: "east", label[$A$], padding: .2)
    draw.content((rel: (-0.5, 0), to: "g2-port-in1"), anchor: "east", label[$B$], padding: .2)
    draw.content((rel: (-0.5, 0), to: "g1-port-in1"), anchor: "east", label[$B$], padding: .2)
    draw.content((rel: (-0.5, 0), to: "g7-port-in1"), anchor: "east", label[$B$], padding: .2)
    draw.content((rel: (-0.5, 0), to: "g3-port-in1"), anchor: "east", label[$C$], padding: .2)
    draw.content((rel: (-0.5, 0), to: "g4-port-in0"), anchor: "east", label[$C$], padding: .2)

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

#block(sticky: true)[*Part (a): Truth Table*]

Build the truth table mapping $triple(A, B, C) |-> pair(f_1, f_2)$ for all 8 inputs.

#block(sticky: true)[*Part (b): Boolean Expressions*]

+ Derive minimal DNF for both $f_1$ and $f_2$.
+ Verify against your truth table.
+ Count literals in each expression. Which output is more complex?

#block(sticky: true)[*Part (c): Optimization*]

+ Identify all redundant gates.
+ Draw the simplified circuit.
+ Verify identical outputs for all 8 inputs.

#block(sticky: true)[*Part (d): Timing Analysis*]

+ Compute maximum delay to each output (assume unit delay per gate).
+ Identify the critical path for each output.


#pagebreak()

== Problem 3: Boolean Function Analysis

Analyze functions
#footnote[
  Notation: $bfunc(n, k)$ is the $k$-th Boolean function of $n$ variables, where $k$ is the decimal truth table value with MSB = $f(0,dots,0)$, LSB = $f(1,dots,1)$.
]
in multiple representations: truth tables, DNF, CNF, ANF, and K-maps.

#tasklist("prob3", cols: 2)[
  + $f_1 = bfunc(4, 47541)$

  + $f_2 = sum m(1, 4, 5, 6, 8, 12, 13)$

  #colbreak()

  + $f_3 = bfunc(4, 51011) xor bfunc(4, 40389)$

  + $f_4 = A overline(B) D + overline(A) thin overline(C) D + overline(B) C overline(D) + A overline(C) D$
]

#block(sticky: true)[*Part (a): Karnaugh Maps*]

Draw and fill the K-map for each function.

#block(sticky: true)[*Part (b): Prime Implicants*]

+ Find _all_ prime implicants for each function (Blake Canonical Form).
+ Show each prime implicant as a maximal rectangle on your K-map.
+ Identify which are _essential_ (cover at least one minterm no other prime implicant covers).

#block(sticky: true)[*Part (c): Minimal DNF and CNF*]

+ Derive the minimal DNF using the prime implicants from Part (b).
+ Derive the minimal CNF using either dual K-map analysis or algebraic methods.
+ For each function, state whether the DNF or CNF is more compact (fewer literals).

#block(sticky: true)[*Part (d): Algebraic Normal Form*]

Construct the ANF for each function using any of the methods below:
- _Indeterminate coefficients_: Solve linear system of equations
- _Tabular_: Pascal's triangle-like XOR structure
- _K-map_: Identify XOR patterns geometrically

*Requirement:* Use each method at least once across the four functions.

#note[
  WolframAlpha reverses bit order! \
  For $bfunc(2, 10) = (1010)_2$, query "5th Boolean function of 2 vars" since $op("rev")(1010_2) = 0101_2 = 5$.
]


#pagebreak()

== Problem 4: CNF Conversion

Explore direct CNF conversion and Tseitin transformation.

#block(sticky: true)[*Part (a): Basic Conversions*]

Convert to CNF:

#tasklist("prob4a", cols: 3)[
  + $X iff (A and B)$

  + $Z iff or.big_i C_i$

  #colbreak()

  + $D_1 xor D_2 xor dots.c xor D_n$

  + $majority(X_1, X_2, X_3)$

  #colbreak()

  + $R imply (S imply (T imply and.big_i F_i))$

  + $M imply (H iff or.big_i D_i)$
]

#block(sticky: true)[*Part (b): Tseitin Transformation*]

The Tseitin transformation produces _equisatisfiable_ CNF by introducing auxiliary variables.
The transformed formula has different models, but they naturally correspond to the original's.

Consider $(A or B) and (C or (D and E))$:

+ Apply Tseitin: introduce variables for subformulae, encode each as CNF clauses.
+ Prove equisatisfiability both ways. Explain why logical equivalence fails.
+ Compare sizes (clauses, variables, literals) with direct CNF. When is each method better?

#block(sticky: true)[*Part (c): Resource Allocation*]

A system manages five resources ${R_1, R_2, R_3, R_4, R_5}$ with constraints:
- Either $R_1$ or both $R_2$ and $R_3$
- If $R_1$, then $R_4$ or $R_5$
- Not both $R_2$ and $R_4$
- At least two of ${R_1, R_2, R_3}$

+ Encode constraints as Boolean formulae.
+ Convert to CNF and combine.
+ Find all satisfying assignments.
+ Which resource appears in the most valid configurations?


== Problem 5: Functional Completeness

Determine which sets of Boolean operations are functionally complete using Post's criterion.

#block(sticky: true)[*Part (a): Apply Post's Criterion*]

For each system, check Post classes ($T_0$, $T_1$, $S$, $M$, $L$) and determine completeness:

#tasklist("prob5a", cols: 2)[
  + $F_1 = {and, or, not}$

  + $F_2 = \{ bfunc(2, 14) \}$

  #colbreak()

  + $F_3 = {imply, imply.not}$

  + $F_4 = {1, iff, and}$
]
- Determine if the class is preserved under composition.
+ Conclude whether the system is functionally complete.
+ If not complete, identify which Post class(es) prevent completeness.

*Hint:* A system is complete iff it does not preserve each of the five Post classes.

#block(sticky: true)[*Part (b): Express Majority*]

The majority function $majority(A, B, C)$ outputs 1 when at least two inputs are 1.

For each _complete_ basis from Part (a):

+ Express $majority(A, B, C)$ using only operations from that basis.
+ Draw the corresponding circuit diagram with clearly labeled gates.
+ Count the total number of gates required.
+ Verify your expression by checking the test cases: $(0,0,0)$, $(1,1,0)$, and $(1,1,1)$.

#block(sticky: true)[*Part (c): NAND Gates*]

+ Express $not A$, $A and B$, and $A or B$ using only NAND.
+ Build a NAND-only circuit for $majority(A, B, C)$. Count gates.
+ Which complete basis from Part (a) yields the smallest $majority$ circuit?

#block(sticky: true)[*Part (d): Custom Basis*]

+ Design a single 3-input Boolean function that is by itself functionally complete.
+ Prove completeness using Post's criterion.
+ Express $not A$ and $A and B$ using only your function.
+ Compare gate count for $majority(A, B, C)$ vs NAND implementation.


#pagebreak()

== Problem 6: Zhegalkin Polynomials

The Zhegalkin basis ${xor, and, 1}$ represents Boolean functions as polynomials over $FF_2$.
Every function has a unique ANF (Algebraic Normal Form) revealing its algebraic degree --- critical in cryptography.

#block(sticky: true)[*Part (a): Functional Completeness*]

+ Prove ${xor, and, 1}$ is functionally complete by expressing $not x$ and $x or y$.
+ Express $majority(x, y, z)$ using only ${xor, and, 1}$. Count operations.

#block(sticky: true)[*Part (b): Computing ANF*]

Find the ANF using different methods:

#tasklist("prob6b", cols: 2)[
  + $f_1 (a, b, c) = a b or b c or a c$

  + $f_2 (a, b, c, d) = sum m(1, 4, 6, 7, 10, 13, 15)$

  #colbreak()

  + $f_3 (a, b, c) = (a imply b) xor (b imply c)$

  + $f_4 (a, b, c, d) = (a xor b)(c xor d)$
]

#block(sticky: true)[*Part (c): Algebraic Degree*]

+ Identify the algebraic degree of each function from Part (b).
+ Which has highest degree? Is it maximal for that number of variables?
+ Prove $deg(f xor g) <= max(deg(f), deg(g))$. Find an example with strict inequality.

#block(sticky: true)[*Part (d): Cryptographic S-Box*]

S-box $S: Bool^3 to Bool$ has truth table $(0,1,1,0,1,0,0,1)$.

+ Find ANF and degree.
+ Is $S$ balanced? Affine?
+ Construct a different function $T: Bool^3 to Bool$ that is balanced and has degree 3.
+ For both $S$ and $T$, compute distance to the nearest affine function.


== Problem 7: Gray Code Circuits

Gray code ensures consecutive values differ in exactly one bit.

#example[
  4-bit: $0 to #`0000`, 1 to #`0001`, 2 to #`0011`, 3 to #`0010`, dots, 15 to #`1000`$
]

#block(sticky: true)[*Part (a): Binary-to-Gray Conversion*]

+ Build the 4-bit binary-to-Gray truth table.
+ Verify consecutive pairs differ in exactly one bit.
+ Derive the conversion formula for each $g_i$ in terms of $(b_3, b_2, b_1, b_0)$.

#block(sticky: true)[*Part (b): Gray-to-Binary Conversion*]

+ Derive the inverse formula for each $b_i$ in terms of $(g_3, g_2, g_1, g_0)$.
+ Prove "binary $->$ Gray $->$ binary" is the identity.
+ Test with examples: $#`1001`$ and $#`0110`$.

#block(sticky: true)[*Part (c): Circuit Implementation*]

+ Design both converters using XOR gates.
+ Count gates and compute propagation delay for each.
+ Compare complexity and explain structural differences.

#block(sticky: true)[*Part (d): NAND Implementation*]

Redesign binary-to-Gray using only NAND gates.
Compare gate count and delay with XOR design.
Which is more practical?

#block(sticky: true)[*Part (e): Timing Analysis*]

A 4-bit rotary encoder outputs Gray at 10,000 steps/second.
With 10ns gate delay, is your Gray-to-binary converter circuit fast enough?
What is the maximum step rate your circuit can handle?

#block(sticky: true)[*Part (f): Error Analysis*]

Why does Gray code eliminate glitches during mechanical transitions?
Show a concrete example: pick two consecutive binary values where multiple bits change, and demonstrate the incorrect intermediate value that could be read during transition.


== Problem 8: Arithmetic Circuits

Design circuits for subtraction, comparison, and multiplication.

#block(sticky: true)[*Part (a): Half Subtractor*]

Design a half subtractor for $x - y$ (outputs: difference $d$, borrow $b$).
Build truth table, derive expressions, construct circuit with AND/OR/NOT.
Relate to XOR.

#block(sticky: true)[*Part (b): Full Subtractor*]

+ Build truth table for $x - y - b_("in")$.
+ Design using two half subtractors. Explain borrow propagation.
+ Calculate critical path delay.
+ Verify: $(0,1,1)$ and $(1,0,1)$.

#block(sticky: true)[*Part (c): 4-bit Saturating Subtractor*]

A saturating subtractor computes $d = max(0, x - y)$, clamping negatives to zero.

+ Design using four full subtractors plus saturation logic. Which signal detects $x < y$?
+ Test: $5 - 3$, $3 - 5$ (saturates to 0), $15 - 8$.

#block(sticky: true)[*Part (d): 2-bit Comparator*]

+ Design for $x, y in {0,1,2,3}$ with outputs $gt, eq, lt$.
+ Verify: $(3,2)$, $(2,2)$, $(1,3)$.
+ Explain cascading for 4-bit comparator.

#block(sticky: true)[*Part (e): 2-bit Multiplier*]

+ Build 16-row truth table for $p = x times y$.
+ Find minimal expressions for $p_3, p_2, p_1, p_0$ using K-maps.
+ Draw optimized circuit exploiting shared sub-expressions.
+ Verify: $3 times 2 = 6$, $3 times 3 = 9$, $1 times 1 = 1$.


== Problem 9: Binary Decision Diagrams

BDDs represent Boolean functions as DAGs, providing canonical forms for efficient manipulation. Variable ordering can exponentially affect size.

#block(sticky: true)[*Part (a): If-Then-Else Function*]

$ITE(c, x, y)$ returns $x$ when $c=0$, otherwise $y$.

+ Express $ITE$ using ${and, or, not}$. Verify with truth table.
+ Prove ${ITE}$ alone is functionally complete via Post's criterion.
+ Express $x xor y$ and $majority(x, y, z)$ using only $ITE$. Count $ITE$ calls.

#block(sticky: true)[*Part (b): Construct ROBDDs with Natural Ordering*]

Use natural order $x_1 prec x_2 prec x_3 prec dots.c$ for:

#tasklist("prob9b", cols: 2)[
  + $f_1(x_1, x_2, x_3, x_4) = x_1 xor x_2 xor x_3 xor x_4$

  + $f_2(x_1, dots, x_5) = majority(x_1, dots, x_5)$

  #colbreak()

  + $f_3(x_1, dots, x_4) = sum m(1, 2, 5, 12, 15)$

  + $f_4(x_1, dots, x_6) = x_1 x_4 + x_2 x_5 + x_3 x_6$
]

For each function:

+ Build the complete decision tree (dashed edges = 0, solid = 1).
+ Reduce: (1) merge isomorphic subtrees, (2) eliminate redundant tests.
+ Draw final ROBDD with node count. Compare to unreduced size $2^(n+1) - 1$.
+ Verify by tracing two sample inputs to terminal values.

#block(sticky: true)[*Part (c): Variable Ordering Impact*]

For each function from Part (b):

+ Find an ordering producing smaller ROBDD than natural order.
+ Construct and count nodes.
+ Report reduction for each function.
+ For $f_4$, explain why interleaving paired variables helps.

#block(sticky: true)[*Part (d): Detailed Analysis of $f_4$*]

$f_4(x_1, dots, x_6) = x_1 x_4 + x_2 x_5 + x_3 x_6$:

+ Draw ROBDD with natural order $x_1 prec x_2 prec x_3 prec x_4 prec x_5 prec x_6$. Count nodes.
+ Draw ROBDD with interleaved order $x_1 prec x_4 prec x_2 prec x_5 prec x_3 prec x_6$. Count nodes.
+ Explain structural reduction. What sharing patterns emerge?
+ Give a function with ordering-invariant ROBDD size.

#block(sticky: true)[*Part (e): BDD Operations*]

+ Construct ROBDD for $f_1 and f_3$ (from Part b) using natural ordering.
+ Describe the _apply algorithm_: how to combine two ROBDDs without enumerating truth tables.
+ Compare the resulting BDD size to the sum of individual sizes.


#pagebreak()

== Problem 10: Reed–Muller Codes

Reed–Muller codes use Boolean functions with restricted degree for error correction. Mariner 9 used RM codes to transmit Mars images in 1971.

$op("RM")(r, m) = { f: FF_2^m to FF_2 | deg(f) <= r }$

*Parameters:* $n = 2^m$, $k = sum_(i=0)^r binom(m, i)$, $d = 2^(m-r)$, corrects $t = floor((d-1)/2)$ errors.

*Encoding:* List monomials of degree $<= r$ lexicographically, evaluate on all $2^m$ inputs for generator matrix $bold(G)$. Message $bold(u)$ encodes to $bold(c) = bold(u) bold(G)$.

#example[
  $op("RM")(1, 2)$: $bold(G) = mat(1, 1, 1, 1; 0, 0, 1, 1; 0, 1, 0, 1)$

  $(1, 0, 1)$ encodes to $(1, 0, 1, 0)$.
]

*Majority-logic decoding:* For each ANF coefficient, XOR pairs differing in one variable position. Each XOR votes; majority determines the coefficient.

#block(sticky: true)[*Part (a): Code Construction*]

$op("RM")(1, 3)$:

+ Calculate $n$, $k$, $d$. How many errors correctable?
+ List monomials of degree $<= 1$.
+ Construct $bold(G)$ (8 input vectors).
+ Encode $bold(u) = (1, 0, 1, 1)$.

#block(sticky: true)[*Part (b): Single-Error Correction*]

+ Flip one bit of $bold(c)$, producing $bold(r)$.
+ Apply majority-logic decoding.
+ Verify recovery of $bold(u)$. Trace voting for one coefficient.

#block(sticky: true)[*Part (c): Beyond Guaranteed Correction*]

+ Flip two bits of $bold(c)$, producing $bold(r)$.
+ Apply decoding. Success?
+ Explain why voting sometimes succeeds beyond guaranteed threshold.

#block(sticky: true)[*Part (d): Code Efficiency*]

+ Compare rate $k\/n$ of $op("RM")(1, 3)$ vs 3-repetition code. Which is more efficient?
+ Explain trade-off: how does $r$ affect correction capability and rate?


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

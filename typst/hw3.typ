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

Using your K-map:

+ Find the minimal DNF for $f$.
+ Find the minimal CNF for $f$.
+ Count all prime implicants.
+ Suppose inputs where $A and B and C = 1$ are _don't-care_ conditions. \
  How does this affect your minimal DNF and CNF?

#block(sticky: true)[*Part (d): Reflection*]

+ How much smaller is your minimal DNF compared to listing all minterms?
+ Compare the sizes of your minimal DNF vs minimal CNF. Which is smaller?
+ Why do K-maps become impractical beyond 5-6 variables?


#pagebreak()

== Problem 2: Circuit Analysis

Digital circuits transform input signals into outputs through interconnected logic gates.
Understanding how to analyze existing circuits --- deriving their Boolean functions, identifying redundancies, and computing timing --- is important for hardware design and verification.
In this problem, you'll reverse-engineer a combinational circuit to understand its behavior.

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

Build the complete truth table by tracing signal flow through the circuit.
Present your results as a table mapping $triple(A, B, C) |-> pair(f_1, f_2)$ for all 8 input combinations.

#block(sticky: true)[*Part (b): Boolean Expressions*]

+ Derive minimal DNF expressions for both $f_1$ and $f_2$.
  Use K-maps or algebraic simplification.
+ Verify your expressions produce the same truth table from Part (a).
+ Count the number of literals in each expression.
  Which output function is more complex?

#block(sticky: true)[*Part (c): Optimization*]

Real circuits often contain redundancies from iterative design or automated synthesis.

+ Identify all redundant gates (gates whose removal doesn't change the output).
+ Draw a simplified circuit with all redundancies eliminated.
+ Verify that your optimized circuit produces identical outputs for all 8 input combinations.

#block(sticky: true)[*Part (d): Timing Analysis*]

+ Assuming unit delay per gate, compute the maximum delay to each output.
+ For each output, identify its critical path (the longest path determining delay).
// TODO: more?


#pagebreak()

== Problem 3: Boolean Function Analysis

Boolean functions can be represented in many equivalent forms --- truth tables, DNF, CNF, ANF, K-maps, and more.
Each representation offers different insights and advantages for analysis, simplification, or implementation.
Understanding conversions between these forms is important for both theory and practice.

Analyze the following functions:
#footnote[
  Notation: $bfunc(n, k)$ is the $k$-th Boolean function of $n$ variables, where $k$ is the decimal value of the truth table with MSB = $f(0,dots,0)$ and LSB = $f(1,dots,1)$.
  For example, $bfunc(2, 11) = (1011)_2$, so the truth table is $(1,0,1,1)$.
]

#tasklist("prob3", cols: 2)[
  + $f_1 = bfunc(4, 47541)$

  + $f_2 = sum m(1, 4, 5, 6, 8, 12, 13)$

  #colbreak()

  + $f_3 = bfunc(4, 51011) xor bfunc(4, 40389)$

  + $f_4 = A overline(B) D + overline(A) thin overline(C) D + overline(B) C overline(D) + A overline(C) D$
]

#block(sticky: true)[*Part (a): Karnaugh Maps*]

For each function, draw and fill the K-map.

#block(sticky: true)[*Part (b): Prime Implicants*]

+ Find _all_ prime implicants for each function (Blake Canonical Form).
+ For each prime implicant, show the corresponding group on your K-map.
+ Identify which prime implicants are _essential_ (must be included in any minimal cover).

#block(sticky: true)[*Part (c): Minimal DNF and CNF*]

+ Derive the minimal DNF using the prime implicants from Part (b).
+ Derive the minimal CNF using either dual K-map analysis or algebraic methods.
+ For each function, state whether the DNF or CNF is more compact (fewer literals).

#block(sticky: true)[*Part (d): Algebraic Normal Form*]

Construct the ANF for each function using one of these methods:
- _K-map method_: Group minterms and use XOR relationships
- _Tabular method_: Build Pascal's triangle-like structure
- _Shannon decomposition_: Recursively decompose by variables

*Requirement:*
Use each method at least once across all four functions.
Clearly state which method you're using for each function.

#note[
  WolframAlpha reverses bit order for Boolean function indexing! \
  For $bfunc(2, 10) = (1010)_2$, query "5th Boolean function of 2 vars" since $op("rev")(1010_2) = 0101_2 = 5$.
]

// #block(sticky: true)[*Part (e): Analysis and Comparison*]
//
// + Which function has the highest algebraic degree (in ANF)?
// + Which representation (DNF, CNF, or ANF) is most compact for each function?
// + Identify any special properties: Is any function linear, affine, symmetric, or self-dual?


#pagebreak()

== Problem 4: CNF Conversion

// Conjunctive Normal Form (CNF) is the standard input format for SAT solvers --- the workhorses of modern verification, AI planning, and constraint solving.
// Converting arbitrary Boolean formulae to CNF has direct applications in automated reasoning, formal verification, and optimization.

This problem explores both direct CNF conversion and the Tseitin transformation, a powerful technique that trades formula size for satisfiability equivalence.

#block(sticky: true)[*Part (a): Basic Conversions*]

Convert each formula to CNF using truth tables, distribution laws, or equivalence transformations:

#tasklist("prob4a", cols: 3)[
  + $X iff (A and B)$

  + $Z iff or.big_i C_i$

  #colbreak()

  + $D_1 xor D_2 xor dots.c xor D_n$

  + $majority(X_1, X_2, X_3)$
    #footnote[
      Majority function returns 1 iff at least 2 of its 3 inputs are 1.
    ]

  #colbreak()

  + $R imply (S imply (T imply and.big_i F_i))$

  + $M imply (H iff or.big_i D_i)$
]

// For each:
// - Show all intermediate steps clearly.
// - Count the number of clauses and total literals in your final CNF.

#block(sticky: true)[*Part (b): Tseitin Transformation*]

The Tseitin transformation produces _equisatisfiable_ CNF by introducing auxiliary variables for subformulae.
While the resulting formula isn't logically equivalent to the original, both have satisfying assignments that correspond naturally.

Consider the formula: $(A or B) and (C or (D and E))$

+ Apply the Tseitin transformation:
  // - Identify all subformulae (compound expressions).
  - Introduce a fresh auxiliary variable for each subformula.
  - Write the CNF encoding for each auxiliary variable's definition.
  - Combine all clauses and add a unit clause asserting the top-level variable.

+ Prove equisatisfiability:
  - Show that if the original formula is satisfiable, the Tseitin CNF is satisfiable.
  - Show the converse: if the Tseitin CNF is satisfiable, the original formula is satisfiable.
  - Explain why logical equivalence doesn't hold.

+ Compare with direct CNF:
  - Convert the original formula to CNF using distribution laws.
  - Count clauses, variables, and total literals for both approaches.
  - Which is smaller? When would you prefer each method?

#block(sticky: true)[*Part (c): Resource Allocation*]

A distributed system manages five resources ${R_1, R_2, R_3, R_4, R_5}$ with constraints:

- Either $R_1$ is allocated, or both $R_2$ and $R_3$ are allocated
- If $R_1$ is allocated, then at least one of $R_4$ or $R_5$ must be allocated
- Resources $R_2$ and $R_4$ cannot be allocated simultaneously
- At least two of ${R_1, R_2, R_3}$ must be allocated

*Tasks:*
+ Encode each constraint as a Boolean formula using variables $R_1, dots, R_5$.
+ Convert each constraint to CNF.
+ Combine all CNF clauses into a single constraint system.
+ Find _all_ satisfying assignments (valid resource allocations).
+ Which resources are allocated in the maximum number of valid configurations?

// #block(sticky: true)[*Part (d): Complexity and Trade-offs*]
//
// + For the formula in Part (b), compute exact counts:
//   - Direct CNF: number of clauses, number of literals
//   - Tseitin CNF: number of clauses, number of literals, number of auxiliary variables
//
// + Explain the trade-off: Tseitin uses more variables but produces shorter, simpler clauses. When is each approach preferable? Consider:
//   - Formula size and structure
//   - SAT solver performance characteristics
//   - Memory constraints
//
// + Theoretical analysis: For a formula with $n$ binary connectives:
//   - What is the worst-case number of clauses from direct CNF conversion?
//   - What is the clause count from Tseitin transformation?
//   - At what formula size does Tseitin become preferable?


== Problem 5: Functional Completeness

A set of Boolean operations is _functionally complete_ if every Boolean function can be expressed using only those operations.
This concept is central to circuit design: a complete basis allows building any digital logic circuit from a single gate type (like NAND or NOR).

Post's criterion provides a systematic method to determine functional completeness by checking which classes of Boolean functions are _not_ preserved by the operations.

#block(sticky: true)[*Part (a): Apply Post's Criterion*]

Determine whether each system is functionally complete using Post's criterion.
Check closure under all five Post classes: $T_0$, $T_1$, $S$ (self-dual), $M$ (monotone), and $L$ (linear).

#tasklist("prob5a", cols: 2)[
  + $F_1 = {and, or, not}$

  + $F_2 = \{ bfunc(2, 14) \}$

  #colbreak()

  + $F_3 = {imply, imply.not}$
    #footnote[
      $(A imply.not B) equiv not (A imply B) equiv (A and not B)$
    ]

  + $F_4 = {1, iff, and}$
]

For each system:

+ Build the truth table for any unfamiliar operations.
+ Check each Post class:
  - List which functions in the basis belong to each class.
  - Determine if the class is preserved under composition.
+ Conclude whether the system is functionally complete.
+ If not complete, identify which Post class(es) prevent completeness.

*Hint:* A system is complete iff it fails to preserve at least one class from each of the five Post classes.

#block(sticky: true)[*Part (b): Express Majority*]

The majority function $majority(A, B, C)$ outputs 1 when at least two inputs are 1.

For each _complete_ basis from Part (a):

+ Express $majority(A, B, C)$ using only operations from that basis.
+ Draw the corresponding circuit diagram with clearly labeled gates.
+ Count the total number of gates required.
+ Verify your expression by checking the test cases: $(0,0,0)$, $(1,1,0)$, and $(1,1,1)$.

#block(sticky: true)[*Part (c): Efficiency Analysis*]

+ Which complete basis from Part (a) yields the smallest circuit for $majority(A, B, C)$?
+ The NAND gate is considered universal.
  Express $not A$, $A and B$, and $A or B$ using only NAND gates.
+ Build a NAND-only circuit for $majority(A, B, C)$.
  How many NAND gates it requires?
+ Research: Why do hardware designers often prefer NAND or NOR over mixed gate types?

#block(sticky: true)[*Part (d): Custom Basis*]

+ Design a single 3-input Boolean function that is by itself functionally complete.
+ Prove its completeness using Post's criterion.
+ Express $not A$ and $A and B$ using only your custom function.
+ Compare the gate count for $majority(A, B, C)$ using your function versus using NAND.


#pagebreak()

== Problem 6: Zhegalkin Polynomials

The Zhegalkin basis ${xor, and, 1}$ represents Boolean functions as polynomials over $FF_2$ (Algebraic Normal Form).
Every Boolean function has a _unique_ ANF, which reveals its algebraic degree --- a~critical property in cryptography and complexity theory.

#block(sticky: true)[*Part (a): Functional Completeness*]

+ Prove that ${xor, and, 1}$ is functionally complete by expressing $not x$ and $x or y$ using only operations from the basis.
+ Express $majority(x, y, z)$ using only ${xor, and, 1}$. Count the number of operations required.

#block(sticky: true)[*Part (b): Computing ANF*]

For each function below, find its ANF using _different_ methods (use each method at least once):

#tasklist("prob6b", cols: 2)[
  + $f_1 (a, b, c) = a b or b c or a c$

  + $f_2 (a, b, c, d) = sum m(1, 4, 6, 7, 10, 13, 15)$

  #colbreak()

  + $f_3 (a, b, c) = (a imply b) xor (b imply c)$

  + $f_4 (a, b, c, d) = (a xor b)(c xor d)$
]

*Available methods:*
- _Tabular (Pascal's triangle)_: Build XOR-sum table row by row
- _Shannon decomposition_: Recursively decompose $f = x f_(x=1) xor overline(x) f_(x=0)$ where $overline(x) = 1 xor x$
- _K-map with XOR groups_: Identify XOR patterns in the K-map
- _Algebraic manipulation_: Expand using $x or y = x xor y xor x y$ and simplify

For each function, state which method you're using and show all steps.

#block(sticky: true)[*Part (c): Algebraic Degree*]

The _algebraic degree_ is the maximum monomial size in the ANF.

+ For each function in Part (b), identify its algebraic degree.
+ Which function has the highest degree? Is this the maximum possible degree for its number of variables?
+ Prove that $deg(f xor g) <= max(deg(f), deg(g))$. Find an example where the inequality is strict.

#block(sticky: true)[*Part (d): Cryptographic S-Box Analysis*]

Consider an S-box function $S: BB^3 to BB$ with truth table $(0,1,1,0,1,0,0,1)$.

+ Find the ANF and determine the algebraic degree.
+ Is $S$ balanced (equal number of 0s and 1s)?
  Is it affine (degree $<= 1$)?
+ Construct a different 3-variable Boolean function $T: BB^3 to BB$ that is:
  - Balanced (outputs 0 and 1 exactly 4 times each)
  - Degree exactly 3
+ Compare the two functions: Which has better cryptographic properties and why?

// #block(sticky: true)[*Part (e): Uniqueness and Operations*]
//
// + Prove that the ANF representation is unique:
//   If two different ANFs produce the same truth table for all inputs, show they must be syntactically identical.
//
// + Prove that if $f$ and $g$ have ANFs, then $f xor g$ has ANF equal to the XOR of their individual ANFs (over $FF_2$).
//   Why does this not hold for $f and g$?


== Problem 7: Gray Code Circuits

Gray code is a binary encoding where consecutive values differ in exactly one bit, preventing glitches in digital circuits.
Frank Gray patented it in 1953 for shaft encoders, though the principle was known earlier.

#example[
  4-bit Gray code: $0 to #`0000`, 1 to #`0001`, 2 to #`0011`, 3 to #`0010`, dots, 15 to #`1000`$
]

#block(sticky: true)[*Part (a): Binary-to-Gray Conversion*]

+ Build the complete 4-bit binary-to-Gray truth table for inputs $(b_3 b_2 b_1 b_0)_2$ and outputs $(g_3 g_2 g_1 g_0)_"Gray"$.
+ Verify the single-bit-change property: show that consecutive pairs differ in exactly one bit.
+ Derive the conversion formula: express each $g_i$ in terms of binary bits $b_3, dots, b_0$.

#block(sticky: true)[*Part (b): Gray-to-Binary Conversion*]

+ Derive the inverse formula: express each $b_i$ in terms of $g_3, dots, g_0$.
+ Prove correctness: show that "binary $->$ Gray $->$ binary" is the identity.
+ Test your formulas with at least two examples (e.g., $#`1001`$ and $#`0110`$).

#block(sticky: true)[*Part (c): Circuit Implementation*]

+ Design both conversion circuits using only XOR gates (the natural choice given your formulas).
+ For each circuit, count gates and compute maximum propagation delay.
+ Compare complexity: which direction requires more gates?
  Which has longer delay?
  Explain why from the Boolean structure.

#block(sticky: true)[*Part (d): Universal Gate Implementation*]

Redesign the binary-to-Gray circuit using _only_ NAND gates.
Compare gate count and delay with the XOR-based design.
Which is more practical for actual hardware implementation and why?

#block(sticky: true)[*Part (e): Timing Analysis*]

A 4-bit rotary encoder outputs Gray code at up to 10,000 steps/second.
Your Gray-to-binary converter feeds a microcontroller.
Assuming 10ns per gate delay, is your circuit fast enough?
What~is the maximum step rate your design can handle?

#block(sticky: true)[*Part (f): Error Prevention*]

Explain why Gray code prevents read errors in mechanical encoders.
What specific problem occurs with binary encoding when the shaft position is between two values?
Give a concrete example showing how multiple bits changing simultaneously causes errors.


== Problem 8: Arithmetic Circuits

Arithmetic circuits implement mathematical operations in hardware. From simple half adders to complex floating-point units, all arithmetic in digital computers reduces to Boolean logic. This problem explores subtraction, comparison, and multiplication---building blocks of modern processors and FPGAs.

You'll design these circuits from scratch, understanding the Boolean algebra behind computer arithmetic.

#block(sticky: true)[*Part (a): Half Subtractor*]

A half subtractor computes $x - y$ for single bits, producing a difference $d$ and borrow-out $b$.

+ Build the truth table for inputs $x, y$ and outputs $d, b$:
  - When does $d = 1$?
  - When does $b = 1$ (need to borrow)?

+ Derive minimal Boolean expressions for $d$ and $b$:
  - Use K-maps or algebraic methods.
  - Simplify fully.

+ Construct the circuit using AND, OR, and NOT gates:
  - Draw a clear diagram.
  - Identify any relationship to familiar functions (XOR, etc.).

+ Verify correctness: Test all four input combinations $(0,0), (0,1), (1,0), (1,1)$ and confirm outputs match expected subtraction results.

#block(sticky: true)[*Part (b): Full Subtractor*]

A full subtractor computes $x - y - b_("in")$, handling borrow propagation in multi-bit subtraction.

+ Build the truth table for inputs $x, y, b_("in")$ and outputs $d, b_("out")$.

+ Design using half subtractors:
  - Show how to combine two half subtractors and additional gates to create a full subtractor.
  - Draw the complete circuit.
  - Explain the logic: how do borrows propagate?

+ Calculate propagation delay:
  - Assume each basic gate (AND, OR, NOT) has unit delay.
  - What is the worst-case delay from inputs to outputs?
  - Identify the critical path.

+ Verify with test cases: $(x, y, b_("in")) = (0,1,1)$ and $(1,0,1)$.

#block(sticky: true)[*Part (c): 4-bit Saturating Subtractor*]

A saturating subtractor computes $d = max(0, x - y)$ for 4-bit unsigned integers, clamping negative results to zero.

+ Design the circuit:
  - Use four full subtractors to compute $x - y$.
  - Detect when the result is negative (how?).
  - Add logic to output zero when negative, otherwise output the difference.
  - Draw the complete circuit diagram.

+ Explain the negative detection logic:
  - Which signal indicates $x < y$?
  - How does your circuit select between the difference and zero?

+ Test with examples:
  - $5 - 3 = ?$
  - $3 - 5 = ?$ (should saturate to 0)
  - $15 - 8 = ?$

  Show the bit-level computations and intermediate signals.

+ Gate count: How many gates total? Can you identify any optimizations?

#block(sticky: true)[*Part (d): 2-bit Comparator*]

Design a circuit comparing 2-bit unsigned integers $x = (x_1 x_0)_2$ and $y = (y_1 y_0)_2$.

+ Derive Boolean expressions for three outputs:
  - $gt$: equals 1 when $x > y$
  - $eq$: equals 1 when $x = y$
  - $lt$: equals 1 when $x < y$

  Use algebraic reasoning about when each condition holds.

+ Build the circuit using AND, OR, NOT gates:
  - Draw a clear diagram with all three outputs.
  - Look for opportunities to share logic between outputs.

+ Verify with test cases:
  - $(3, 2)$: expect $(gt, eq, lt) = (1, 0, 0)$
  - $(2, 2)$: expect $(gt, eq, lt) = (0, 1, 0)$
  - $(1, 3)$: expect $(gt, eq, lt) = (0, 0, 1)$

+ Extension: How would you chain multiple 2-bit comparators to build a 4-bit comparator?

#block(sticky: true)[*Part (e): 2-bit Multiplier*]

Design a circuit computing $p = x times y$ for 2-bit unsigned integers, producing a 4-bit result $p = (p_3 p_2 p_1 p_0)_2$.

+ Create the complete truth table:
  - All 16 combinations of $(x_1, x_0, y_1, y_0)$.
  - Compute $x times y$ for each row.
  - Express result as 4 bits.

+ Find minimal expressions for each output bit $p_3, p_2, p_1, p_0$:
  - Use K-maps for each output.
  - Identify prime implicants.
  - Minimize fully.

+ Draw the circuit:
  - Show all gates clearly.
  - Label intermediate signals if helpful.

+ Verify with multiplication examples:
  - $3 times 2 = 6$: $(11)_2 times (10)_2 = (0110)_2$
  - $3 times 3 = 9$: $(11)_2 times (11)_2 = (1001)_2$
  - $1 times 1 = 1$: $(01)_2 times (01)_2 = (0001)_2$

  Trace through your circuit for at least one example.

#block(sticky: true)[*Part (f): Analysis and Optimization*]

+ For the multiplier, identify shared sub-expressions:
  - Can any intermediate results be reused across multiple outputs?
  - Redraw the circuit to minimize gate count by sharing logic.
  - Count the gate savings.

+ Design an overflow detector for 2-bit addition:
  - Inputs: two 2-bit numbers and their 3-bit sum.
  - Output: 1 if the sum exceeds 3 (maximum 2-bit value).
  - Derive the Boolean expression and circuit.

+ Compare multiplication approaches:
  - Your optimized multiplier: gate count?
  - Repeated addition (add $x$ to itself $y$ times): What circuit complexity?
  - Which is better for hardware? For what range of bit widths?

+ Real-world consideration: Modern CPUs use Booth's algorithm or Wallace trees for fast multiplication. Research one method and briefly explain how it improves upon naive multiplication.


== Problem 9: Conditional Logic and BDDs

Binary Decision Diagrams (BDDs) are a powerful data structure for representing and manipulating Boolean functions. Used widely in formal verification, model checking, and symbolic computation, BDDs can compactly represent functions that would have exponentially large truth tables or DNF/CNF expressions.

The key insight: represent a Boolean function as a directed acyclic graph where each path from root to leaf encodes one assignment to variables. Variable ordering dramatically affects BDD size---choosing wisely can mean the difference between polynomial and exponential representation.

#block(sticky: true)[*Part (a): If-Then-Else Function*]

The ternary _if-then-else_ function forms the basis of BDD construction:
$
  ITE(c, x, y) = cases(
    x & "if" c = 0,
    y & "if" c = 1
  )
$

This is the Boolean equivalent of the ternary operator `c ? y : x`.

+ Express $ITE(c, x, y)$ using ${and, or, not}$:
  - Derive the formula logically: when does each branch activate?
  - Verify with a complete truth table.
  - Simplify the expression if possible.

+ Analyze functional completeness of ${ITE}$:
  - Check which Post classes $ITE$ belongs to.
  - Determine if ${ITE}$ alone is functionally complete.
  - If not, what operations must be added to achieve completeness?

+ Express $x xor y$ using only $ITE$:
  - Build the expression step by step.
  - Test with truth table to verify.
  - Count the number of $ITE$ operations required.

+ Express $majority(x, y, z)$ using only $ITE$. Compare the complexity with DNF representation.

#block(sticky: true)[*Part (b): Construct ROBDDs*]

A Reduced Ordered BDD (ROBDD) uses Shannon decomposition with a fixed variable order, eliminating redundant nodes. For each function, use the natural variable order $x_1 prec x_2 prec x_3 prec dots.c$

#tasklist("prob9b", cols: 2)[
  + $f_1(x_1, x_2, x_3, x_4) = x_1 xor x_2 xor x_3 xor x_4$

  + $f_2(x_1, dots, x_5) = majority(x_1, dots, x_5)$

  #colbreak()

  + $f_3(x_1, dots, x_4) = sum m(1, 2, 5, 12, 15)$

  + $f_4(x_1, dots, x_6) = x_1 x_4 + x_2 x_5 + x_3 x_6$
]

For each function:

+ Build the full binary decision tree:
  - Start with the root labeled $x_1$.
  - Each node branches on its variable (solid edge = 1, dashed = 0).
  - Label leaves with 0 or 1.

+ Apply reduction rules:
  - _Merge_ isomorphic subtrees (identical structure and labels).
  - _Eliminate_ redundant nodes where both children point to the same node.
  - Show intermediate steps.

+ Count nodes in the final ROBDD and compare with the truth table size ($2^n$ entries).

+ Verify correctness: Trace at least two paths from root to leaf and confirm they produce correct function values.

#block(sticky: true)[*Part (c): Optimal Variable Ordering*]

For each function in Part (b), find a variable ordering that minimizes ROBDD size.

+ Experiment with different orderings:
  - Try at least 3 different orderings for each function.
  - Construct the ROBDD for each ordering.
  - Count nodes.

+ Identify the optimal ordering:
  - Which ordering yields the smallest BDD?
  - By how much does it improve over natural ordering?

+ Explain your strategy:
  - What properties of the function suggest good orderings?
  - For $f_4$, why might interleaving related variables help?

#block(sticky: true)[*Part (d): Variable Ordering Impact*]

Focus on $f_4(x_1, dots, x_6) = x_1 x_4 + x_2 x_5 + x_3 x_6$:

+ Construct ROBDD with natural ordering:
  $x_1 prec x_2 prec x_3 prec x_4 prec x_5 prec x_6$
  - Draw the complete reduced BDD.
  - Count nodes at each level.
  - Total node count?

+ Construct ROBDD with interleaved ordering:
  $x_1 prec x_4 prec x_2 prec x_5 prec x_3 prec x_6$
  - Draw the complete reduced BDD.
  - Count nodes at each level.
  - Total node count?

+ Prove the size difference:
  - Show mathematically why the interleaved ordering produces fewer nodes.
  - Identify structural patterns that enable better sharing.
  - Calculate the exact node count ratio.

+ General principles:
  - Why does variable ordering matter more for some functions than others?
  - Give an example of a function whose BDD size is _invariant_ to variable ordering.
  - Research: What is the complexity of finding optimal variable ordering? (Hint: It's an NP-hard problem!)

#block(sticky: true)[*Part (e): BDD Operations*]

+ Apply operation: Construct the ROBDD for $f_1 and f_3$ (both from Part (b)) using the same variable ordering.

+ Explain the _apply algorithm_: How can two ROBDDs be combined to compute logical operations without expanding to truth tables?

+ Size analysis: Is the BDD for $f_1 and f_3$ larger, smaller, or equal to the sum of sizes of individual BDDs? Explain.


#pagebreak()

== Problem 10: Reed–Muller Codes

In 1954, David Muller proposed using Boolean functions for error correction, and Irving Reed discovered an efficient decoding method.
#link("https://w.wiki/FwR7")[_Reed–Muller (RM) codes_] became important in space communications --- most famously, Mariner 9 used RM codes to transmit the first close-up images of Mars in 1971.
The key insight: Boolean functions with restricted algebraic degree have built-in redundancy that enables error correction.

#block(sticky: true)[*Basic Construction*]

Recall that any Boolean function $f: FF_2^m to FF_2$ has a unique ANF representation:
$
  f(v_1, dots, v_m) = a_0 xor a_1 v_1 xor a_2 v_2 xor dots.c xor a_(i_1,i_2) v_(i_1) v_(i_2) xor dots.c
$

The _degree_ of $f$ is the size of the largest monomial (product term) with non-zero coefficient.

The _Reed–Muller code_ $op("RM")(r, m)$ consists of all Boolean functions on $m$ variables whose ANF has degree at most $r$:
$
  op("RM")(r, m) = { f: FF_2^m to FF_2 | deg(f) <= r }
$

*Code Parameters:*
- _Length_: $n = 2^m$ (number of truth table entries)
- _Dimension_: $k = sum_(i=0)^r binom(m, i)$ (one bit per monomial of degree $<= r$)
- _Minimum distance_: $d = 2^(m-r)$ (enables error correction)

The code can correct up to $t = floor((d-1)/2)$ errors with certainty.

#block(sticky: true)[*Encoding Process*]

To encode a message as a codeword:

+ List all monomials of degree $<= r$ in lexicographic order: \
  $1, v_1, v_2, dots, v_m, v_1 v_2, v_1 v_3, dots$

+ For each monomial, evaluate it on all $2^m$ binary input vectors $(v_1, dots, v_m) in FF_2^m$ (in standard binary order). This gives a row of the _generator matrix_ $bold(G)$.

+ A message $bold(u) = (a_0, a_1, dots, a_(k-1))$ represents the ANF coefficients for these monomials.

+ The codeword is $bold(c) = bold(u) bold(G)$ (matrix multiplication over $FF_2$).

#example[
  For $op("RM")(1, 2)$, the monomials are: $1, v_1, v_2$ (degree $<= 1$).

  Generator matrix rows come from evaluating each on ${00, 01, 10, 11}$:
  $
    bold(G) = mat(
      1, 1, 1, 1;
      0, 0, 1, 1;
      0, 1, 0, 1;
    )
  $

  Message $bold(u) = (1, 0, 1)$ encodes to: $bold(c) = (1, 0, 1)$, $bold(G) = (1, 0, 1, 0)$.
]

#block(sticky: true)[*Recursive Structure*]

Reed–Muller codes have elegant recursive properties:
$
  op("RM")(r, m) = { (bold(u), bold(u) xor bold(v)) | bold(u) in op("RM")(r, m-1), bold(v) in op("RM")(r-1, m-1) }
$

This structure enables _majority-logic decoding_:

+ Each ANF coefficient can be determined by XORing pairs of received bits that differ only in the corresponding variable.
+ Each such XOR is a "vote" for that coefficient.
+ Taking the majority of votes gives the most likely coefficient value.
+ After determining higher-degree terms, XOR them out and recursively decode lower-degree terms.

This algorithm corrects up to $t$ errors with certainty, and sometimes corrects more due to the voting mechanism.

#block(sticky: true)[*Part (a): Code Construction*]

Consider the Reed–Muller code $op("RM")(1, 3)$.

+ Calculate the length $n$, dimension $k$, and minimum distance $d$.
+ How many errors can this code correct with certainty?
+ List all monomials of degree $<= 1$ in lexicographic order.
+ Construct the generator matrix $bold(G)$ by evaluating each monomial on all 8 input vectors.
+ Encode the message vector $bold(u) = (1, 0, 1, 1)$ into a codeword $bold(c)$.

#block(sticky: true)[*Part (b): Single-Error Correction*]

Simulate a transmission error in your codeword from Part (a):

+ Flip _any one bit_ of $bold(c)$ to obtain a received vector $bold(r)$.
+ Apply majority-logic decoding:
  - For each ANF coefficient, compute all relevant XOR pairs from $bold(r)$.
  - Take the majority vote to determine each coefficient.
  - Start with higher-degree terms and work down.
+ Verify that you recover the original message $bold(u)$.
+ Explain which bit you flipped and trace through the voting process for at least one coefficient.

#block(sticky: true)[*Part (c): Double-Error Correction*]

Now simulate a more severe error:

+ Flip _any two bits_ of $bold(c)$ to obtain a received vector $bold(r)$.
+ Apply majority-logic decoding as in Part (b).
+ Does the algorithm successfully recover $bold(u)$?
+ Explain why the majority-logic method sometimes succeeds on 2 errors even though $op("RM")(1, 3)$ only guarantees correction of $t = floor((2^(3-1) - 1)/2) = 1$ error.

#note[
  The voting mechanism provides soft error correction: if errors are distributed favorably, more votes remain correct than incorrect, allowing the majority to prevail even beyond the guaranteed threshold.
]

#block(sticky: true)[*Part (d): Comparison with Other Codes*]

+ Compare the rate $k\/n$ of $op("RM")(1, 3)$ with a simple repetition code that corrects 1 error by repeating each bit 3 times. Which is more efficient?
+ Explain the trade-off between $r$ and $m$: How does increasing $r$ affect the code's error-correction capability and rate?
+ Research one modern application of Reed–Muller codes (space communications, 5G polar codes, quantum error correction, etc.) and briefly describe how the recursive structure is exploited.


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

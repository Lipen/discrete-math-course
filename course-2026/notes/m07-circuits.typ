// M07 --- Circuits: Boolean algebra becomes physical computation.
#import "common-notes.typ": *
#import "notation.typ": *

= Circuits

#chapter-overview[
Boolean algebra is the theory; logic circuits are the practice.
This chapter shows how Boolean functions are realised as physical gates, how arithmetic circuits (adders) are built, and how circuit complexity is measured.
The Gray code and circuit verification via SAT are covered as essential applications. ]

== Logic Gates and Circuits

=== Logic Gates

#definition[Logic gate][
A *logic gate* is a computational unit with binary inputs and one binary output.
Each gate type corresponds to a fixed Boolean function. ]

Standard gates: NOT ($f(x) = not x$), AND ($f(x, y) = x and y$), OR ($f(x, y) = x or y$), NAND ($not(x and y)$), NOR ($not(x or y)$), XOR ($x xor y$).

#note[
NAND and NOR are *universal gates*: each alone is functionally complete.
In CMOS, NAND requires 4 transistors --- the smallest complete gate. ]

=== Circuits as DAGs

#definition[Logic circuit][
  A *logic circuit* is a directed acyclic graph (DAG):
  - Source nodes = inputs (variables, constants 0/1).
  - Internal nodes = logic gates.
  - Sink nodes = outputs.
Acyclicity ensures combinational (not sequential) logic --- no feedback. ]

#definition[Circuit complexity measures][
  - *Size*: number of gates (hardware cost).
  - *Depth*: longest path from input to output (propagation delay).
  - *Fan-in*: maximum inputs per gate.
  - *Fan-out*: maximum gates driven by one output.
]

#note[
A truth table specifies *what* is computed; a circuit specifies *how*.
Many circuits can compute the same function --- design = minimise size/depth. ]

=== Circuit Families

#definition[Circuit family][
A sequence $C_1, C_2, ...$ where $C_n$ has $n$ inputs. *Uniform* if an algorithm constructs $C_n$ from $n$.
Uniform families = Turing machines in computational power. ]


== Adders

=== Half-Adder and Full-Adder

#definition[Half-adder][
Inputs $A, B in {0, 1}$.
$S = A xor B$ (sum), $C = A and B$ (carry).
Adds two bits; cannot handle incoming carry. ]

#definition[Full-adder][
Inputs $A, B, C_"in" in {0, 1}$.
$S = A xor B xor C_"in"$, $C_"out" = (A and B) or (C_"in" and (A xor B))$.
$C_"out" = 1$ when $>= 2$ of three inputs are 1 (majority function). ]

#example[Full-adder][
  #table(
columns: 5, align: center, stroke: (x, y) => if y == 0 { (bottom: 0.4pt) }, table.header([$A$], [$B$], [$C_"in"$], [$S$], [$C_"out"$]), [0], [0], [0], [0], [0], [0], [0], [1], [1], [0], [0], [1], [0], [1], [0], [0], [1], [1], [0], [1], [1], [0], [0], [1], [0], [1], [0], [1], [0], [1], [1], [1], [0], [0], [1], [1], [1], [1], [1], [1], ) ]

=== Ripple-Carry and ALU

#definition[Ripple-carry adder][
Chain $n$ full-adders for $n$-bit addition.
Carry propagates through all stages: size $O(n)$, depth $O(n)$. *Carry look-ahead* reduces depth to $O(log n)$ by computing carries in parallel. ]

Subtraction via two's complement: $A - B = A + (overline(B) + 1)$.
An ALU combines adder, logic gates, and control bits to perform multiple operations (AND, OR, ADD, SUB).

#remark[
The ALU is the computational heart of every CPU.
A 1-bit ALU slice is designed first; $n$ slices are combined with shared control. ]


== Gray Code

#definition[Gray code][
An $n$-bit Gray code orders all $2^n$ binary strings so consecutive strings differ in exactly one bit. ]

#proposition[Recursive construction][
$G_1 = [0, 1]$.
$G_(n+1) = [0 G_n, 1 G_n^R]$ (prefix 0 to $G_n$, then prefix 1 to reversed $G_n$). ]

#example[
$G_2 = [00, 01, 11, 10]$.
$G_3 = [000, 001, 011, 010, 110, 111, 101, 100]$. ]

#proposition[Binary ↔ Gray conversion][
  - *Binary to Gray*: $g_(n-1) = b_(n-1)$; $g_i = b_i xor b_(i+1)$.
  - *Gray to Binary*: $b_(n-1) = g_(n-1)$; $b_i = g_i xor b_(i+1)$ (cumulative XOR).
]

#remark[
Gray codes: rotary encoders (only one track changes at a time), Karnaugh maps (row/column ordering), genetic algorithms (avoid Hamming cliffs). ]


== Circuit Verification and Complexity

=== Verification via SAT

#proposition[Circuit equivalence to SAT][
To check if $C_1 equiv C_2$: build a *miter* --- XOR corresponding outputs, OR all XORs.
Miter outputs 1 on an input iff circuits disagree.
$C_1 equiv C_2$ iff the miter is unsatisfiable --- a SAT problem. ]

#remark[
Formal hardware verification: check that optimised circuit equals specification.
Modern SAT solvers verify circuits with millions of gates. ]

=== Circuit Complexity

#theorem[Shannon's counting argument][
Almost all $n$-ary Boolean functions require circuits of size $>= 2^n/(2n)$.
Most functions need exponential-size circuits. ]

#proof-sketch[
Number of circuits of size $s$: at most $(c s)^s$ (each gate = type + input choices).
Number of functions: $2^(2^n)$.
For $s = 2^n/(2n)$, $(c s)^s ≪ 2^(2^n)$ --- most functions cannot be represented. ]

This is non-constructive: we know complicated functions exist, but naming one and proving a lower bound is hard --- the "P vs NP" of circuit complexity.

# circuits

Combinational circuits as DAGs of gates.

A gate only references nodes created before it, so the builder keeps the node list in topological order and acyclicity holds by construction.
Simulation is a single ordered pass, and two numbers measure a circuit: **size** (gate count) and **depth** (longest input-to-output path).

## Quick start

```bash
cargo run --example half_adder
cargo run --example ripple_carry
cargo run --example fuzz
cargo test
```

## How it works

### Gates and nodes

A circuit is a directed acyclic graph: the sources are the primary inputs and the constants 0/1, the internal nodes are logic gates (AND, OR, XOR, NOT), and the sinks are the outputs.
Build a `Circuit`, create its sources, then combine them into gates.
Each constructor returns a `NodeId` that later gates may feed on, so one output can drive many inputs (fan-out).

```rust
use circuits::Circuit;

let mut c = Circuit::new();
let x = c.input(0);
let y = c.input(1);
let z = c.input(2);
// Size 3, depth 2: AND and NOT are parallel, then OR waits for both.
let f = c.or(c.and(x, y), c.not(z));
assert_eq!(c.size(), 3);
assert_eq!(c.depth(), 2);
assert!(c.eval(f, &[true, true, false]).unwrap());
```

### Size and depth

Size is the number of gates, the hardware cost.
Depth is the longest input-to-output path, the signal delay.
Sources sit at depth 0, and each gate adds one to its deepest input, so parallel branches count only once:

$$d(\text{source}) = 0 \qquad d(\text{gate}) = 1 + \max_{\text{inputs}} d(\text{input})$$

### Adders

The running example is addition.
A half adder is two gates, a full adder is five (two XOR, two AND, one OR), with `A XOR B` computed once and shared by the sum and the carry:

$$S = A \oplus B \qquad C = A \land B$$

$$S = A \oplus B \oplus C_{in} \qquad C_{out} = (A \land B) \lor \bigl(C_{in} \land (A \oplus B)\bigr)$$

Pairing `n` full adders gives a ripple-carry adder.
The carry travels through every bit, so size and depth both grow linearly with the width.

![The half adder: XOR for the sum, AND for the carry](assets/half-adder.svg)

## Demos

| Demo           | Shows                                                                           |
| -------------- | ------------------------------------------------------------------------------- |
| `half_adder`   | Truth tables of the half and full adder, with the size and depth of each        |
| `ripple_carry` | A 4-bit trace `0111 + 0001 = 1000`, then a wider sum checked against arithmetic |
| `fuzz`         | Random operands at many bit widths, compared with integer addition              |

## API

| Item                                     | Purpose                                                 |
| ---------------------------------------- | ------------------------------------------------------- |
| `Circuit::new`                           | A fresh empty circuit                                   |
| `Circuit::input(i)`                      | The `i`-th primary input (created once, then reused)    |
| `Circuit::constant(v)` / `zero` / `one`  | The constants 0/1                                       |
| `Circuit::and` / `or` / `xor` / `not`    | Add a gate and return its `NodeId`                      |
| `Circuit::size`                          | Gate count (the area)                                   |
| `Circuit::depth` / `node_depth`          | Longest input-to-output path (the delay)                |
| `Circuit::simulate` / `eval`             | One topological pass to evaluate every output           |
| `Circuit::node_count` / `input_count`    | All nodes (sources and gates) / distinct primary inputs |
| `half_adder`                             | `S = A XOR B`, `C = A AND B`                            |
| `full_adder`                             | `S = A XOR B XOR Cin`, `Cout` = majority                |
| `ripple_carry_adder(n)`                  | Chain of `n` full adders, size and depth `O(n)`         |
| `Adder::add` / `add_exact` / `add_bits`  | Evaluate an adder against integers or bit slices        |
| `bits_of` / `value_of`                   | Convert between integers and LSB-first bit slices       |

## Tests

- the half and full adder truth tables
- size and depth, including the rule that parallel branches count once
- input and constant reuse, missing-input errors
- a 4-bit ripple trace and a cross-check of ripple against integer arithmetic
- the bit conversions

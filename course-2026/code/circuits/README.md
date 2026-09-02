# circuits

Combinational circuits as DAGs of gates.

A circuit is a directed acyclic graph: the sources are the primary inputs and the constants 0/1, the internal nodes are logic gates (AND, OR, XOR, NOT), and the sinks are the outputs.
Because a gate only references earlier nodes, the builder keeps the graph in topological order and acyclicity holds by construction.
Simulating a circuit is a single ordered pass.
Measuring a circuit gives the two resources every design trades off — **size** (gate count, the chip area) and **depth** (the longest input-to-output path, the signal delay).

The running example is addition.
A half adder is two gates, a full adder is five, and chaining `n` full adders gives an `n`-bit ripple-carry adder.
The carry travels through every bit, so size and depth both grow linearly with the width — the compact, honest baseline.

## Quick start

```bash
cargo run --example half_adder
cargo run --example ripple_carry
cargo run --example fuzz
cargo test
```

## How it works

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

A full adder is five gates (two XOR, two AND, one OR) and computes `S = A XOR B XOR Cin` and `Cout = majority(A, B, Cin)`.
Pairing `n` full adders gives a ripple-carry adder.

![The half adder: XOR for the sum, AND for the carry](assets/half-adder.svg)

## Demos

| Demo           | Shows                                                                           |
| -------------- | ------------------------------------------------------------------------------- |
| `half_adder`   | Truth tables of the half and full adder, with the size and depth of each        |
| `ripple_carry` | A 4-bit trace `0111 + 0001 = 1000`, then a wider sum checked against arithmetic |
| `fuzz`         | Random operands at many bit widths, compared with integer addition              |

## API

| Item                                     | Purpose                                                     |
| ---------------------------------------- | ----------------------------------------------------------- |
| `Circuit::new`                           | A fresh empty circuit                                       |
| `Circuit::input(i)`                      | The `i`-th primary input (created once, then reused)        |
| `Circuit::constant(v)` / `zero` / `one`  | The constants 0/1                                           |
| `Circuit::and` / `or` / `xor` / `not`    | Add a gate and return its `NodeId`                          |
| `Circuit::size`                          | Gate count (the area)                                       |
| `Circuit::depth` / `node_depth`          | Longest input-to-output path (the delay)                    |
| `Circuit::simulate` / `eval`             | One topological pass to evaluate every output               |
| `half_adder`                             | `S = A XOR B`, `C = A AND B`                                |
| `full_adder`                             | `S = A XOR B XOR Cin`, `Cout` = majority                    |
| `ripple_carry_adder(n)`                  | Chain of `n` full adders, size and depth `O(n)`             |
| `Adder::add` / `add_exact` / `add_bits`  | Evaluate an adder against integers or bit slices            |
| `bits_of` / `value_of`                   | Convert between integers and LSB-first bit slices           |

## Tests

Unit tests cover the half and full adder truth tables, size and depth (including the rule that parallel branches count once), input and constant reuse, missing-input errors, a 4-bit ripple trace, a cross-check of ripple against integer arithmetic, and the bit conversions.

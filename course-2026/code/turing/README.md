# turing

Turing machines.

A concrete model: a tape held as two stacks, a transition table, accepting and rejecting states, and a trace of every configuration the machine visits.
The design mirrors the definition in the chapter, not any specific hardware.

## Quick start

```bash
cargo run -p turing --example zero_n_one_n
cargo run -p turing --example binary_increment
cargo run -p turing --example palindrome
cargo test -p turing
```

## The machine

A transition reads the symbol under the head, writes a new one, moves the head, and switches state:

$$ \delta(q, a) = (q', b, d), \qquad d \in \{L, R, S\} $$

A run records every configuration and stops at an accepting or a rejecting state; if no transition applies, it reports `Stuck`.

![Turing machine tape with head](assets/turing-machine.svg)

The tape cells live in two stacks (`left`, `right`) with the head between them, so moving is just moving a symbol between stacks.

## API

| Type | Purpose |
| --- | --- |
| `Tape` | Infinite tape with a head, modelled as two stacks (`left`, `right`) |
| `Direction` | `Left`, `Right`, or `Stay` |
| `Transition` | Write symbol, move head, go to next state |
| `Configuration` | Current state + tape snapshot |
| `Machine` | Transition table plus start, accept, and reject states |
| `Machine::run(tape, max_steps)` | Run with a step limit: a non-halting machine ends with `Outcome::Limit` instead of running forever |
| `Machine::next(config)` | Compute the next configuration (or `None` if stuck) |
| `Run`, `Outcome` | The full trace and its verdict (`Accepted`, `Rejected`, `Stuck`, `Limit`) |
| `Tape::content()` | The full tape content as a `Vec` |
| `Tape::content_trimmed()` | Tape content with leading/trailing blanks removed |

### Example machines

| Function | Language / function |
| --- | --- |
| `machines::ends_with_zero()` | Words over {0, 1} that end in `0` |
| `machines::zero_n_one_n()` | The language `0^n 1^n` (crossing out matching pairs) |
| `machines::binary_increment()` | Increments a binary number (adds 1) |
| `machines::palindrome()` | Words over {0, 1} that read the same forwards and backwards |

## Demo

| Demo | Shows |
| --- | --- |
| `zero_n_one_n` | The crossing-out algorithm for `0^n 1^n`, with a full trace on `0011` |
| `binary_increment` | Step-by-step binary increment on several inputs including overflow |
| `palindrome` | Palindrome checking with comparison traces: one accepted, one rejected |

## Tests

```bash
cargo test -p turing
```

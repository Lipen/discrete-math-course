# turing

Turing machines.

A concrete model: a tape held as two stacks, a transition table, accepting and rejecting states, and a trace of every configuration the machine visits.
The design follows the mathematical definition, not any specific hardware.

## Quick start

```bash
cargo test
cargo run --example zero_n_one_n
cargo run --example binary_increment
cargo run --example palindrome
```

## The machine

A transition reads the symbol under the head, writes a new one, moves the head, and switches state:

$$ \delta(q, a) = (q', b, d), \qquad d \in \{L, R, S\} $$

A run records every configuration and stops at an accepting or a rejecting state.
If no transition applies, it reports `Stuck`.

![Turing machine tape with head](assets/turing-machine.svg)

The tape cells live in two stacks (`left`, `right`) with the head between them.
Moving the head is moving a symbol between the stacks, so every operation costs $O(1)$.

## API

| Item                            | Purpose                                                                                            |
| ---                             | ---                                                                                                |
| `Tape`                          | Infinite tape with a head, modelled as two stacks (`left`, `right`)                                |
| `Direction`                     | `Left`, `Right`, or `Stay`                                                                         |
| `Transition`                    | Write symbol, move head, go to next state                                                          |
| `Configuration`                 | Current state plus a tape snapshot                                                                 |
| `Machine`                       | Transition table plus start, accept, and reject states                                             |
| `Machine::run(tape, max_steps)` | Run with a step limit: a non-halting machine ends with `Outcome::Limit` instead of running forever |
| `Machine::next(config)`         | Compute the next configuration, or `None` if stuck                                                 |
| `Run`, `Outcome`                | The full trace and its verdict: `Accepted`, `Rejected`, `Stuck`, `Limit`                           |
| `Tape::content()`               | The full tape content as a `Vec`                                                                   |
| `Tape::content_trimmed()`       | Tape content with leading and trailing blanks removed                                              |

### Example machines

| Function                       | Language or function computed                               |
| ---                            | ---                                                         |
| `machines::ends_with_zero()`   | Words over $\{0, 1\}$ that end in `0`                       |
| `machines::zero_n_one_n()`     | The language $0^n 1^n$, by crossing out matching pairs      |
| `machines::binary_increment()` | Increments a binary number, least significant bit first     |
| `machines::palindrome()`       | Words over $\{0, 1\}$ that read the same in both directions |

## Demos

| Demo               | Shows                                                                       |
| ---                | ---                                                                         |
| `zero_n_one_n`     | The crossing-out algorithm for $0^n 1^n$, with a full trace on `0011`       |
| `binary_increment` | Step-by-step binary increment on several inputs, including overflow         |
| `palindrome`       | Palindrome checking with comparison traces: one accepted word, one rejected |

## Tests

```bash
cargo test
```

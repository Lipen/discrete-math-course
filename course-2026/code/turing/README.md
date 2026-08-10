# turing

Turing machines.

A concrete model: a tape held as two stacks, a transition table, accepting and rejecting states, and a trace of every configuration the machine visits.
The design mirrors the definition in the chapter, not any specific hardware.

## Quick start

```bash
cargo run -p turing --example zero_n_one_n
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
| `Tape` | Tape with a head over `left`, `head`, `right` stacks |
| `Machine` | Transition table plus start, accept, and reject states |
| `Machine::run(tape, max_steps)` | Run with a step limit: a non-halting machine ends with `Outcome::Limit` instead of running forever |
| `Configuration`, `Run`, `Outcome` | A snapshot, the full trace, and its verdict (`Accepted`, `Rejected`, `Stuck`, `Limit`) |
| `examples::ends_with_zero` | Words over $\{0, 1\}$ that end in `0` |
| `examples::zero_n_one_n` | The language $0^n 1^n$ (crossing out matching pairs) |

## Demo

| Demo | Shows |
| --- | --- |
| `zero_n_one_n` | The crossing-out algorithm for $0^n 1^n$, with a full trace on `0011` |

## Tests

```bash
cargo test -p turing
```

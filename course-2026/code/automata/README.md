# automata

Finite automata and regular languages.

DFA, NFA with epsilon-transitions, the subset construction, and language operations (complement, union, intersection, difference).
Every idea has a runnable demo in `examples/`.

## Quick start

```bash
cargo run -p automata --example even_ones
cargo test -p automata
```

## What a DFA recognizes

A DFA is a tuple $(Q, \Sigma, \delta, q_0, F)$.
It accepts a word $w$ when the extended transition function lands in an accepting state:

$$ L(M) = \{ w \in \Sigma^* \mid \hat\delta(q_0, w) \in F \} $$

![DFA for an even number of 1s](assets/dfa-even-ones.svg)

The diagram shows the smallest useful example: words over $\{0, 1\}$ with an even number of `1`s.
State $q_0$ is both the start and the only accepting state; reading a `1` flips it, reading a `0` keeps it.

## API

| Type | Purpose | Key methods |
| --- | --- | --- |
| `Dfa` | Deterministic automaton | `accepts`, `is_empty`, `equivalent_to`, `complete`, `complement`, `union`, `intersection`, `difference` |
| `Nfa` | Nondeterministic automaton (with epsilon-transitions) | `epsilon_closure`, `accepts`, `to_dfa` |

## Demos

| Demo | Shows |
| --- | --- |
| `even_ones` | A DFA for an even number of `1`s, checked word by word |
| `nfa_to_dfa` | Subset construction on the "contains `00` or `11`" NFA |
| `language_ops` | Complement, union, intersection, difference on two DFAs |

## Tests

```bash
cargo test -p automata
```

Unit tests live next to the code in `src/`.
Run `cargo test -p automata` to also see doc-tests covering every public method.

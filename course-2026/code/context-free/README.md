# context-free

Context-free grammars and languages.

Parse trees, Chomsky normal form, and CYK recognition.
A runnable demo ships in `examples/`.

## Quick start

```bash
cargo test
cargo run --example cnf_cyk
```

## What a grammar generates

A context-free grammar is a tuple $G = (V, \Sigma, P, S)$: nonterminals $V$, terminals $\Sigma$, productions $A \to \alpha$, and a start symbol $S$.
It generates the language

$$ L(G) = \{ w \in \Sigma^* \mid S \Rightarrow^* w \} $$

A word may have several derivations.
The structure of one derivation is a parse tree.

![Parse tree of a³b³](assets/parse-tree-a3b3.svg)

The tree shows $S \to a S b \mid \varepsilon$ deriving $a^3 b^3$: three nested applications of $S \to a S b$, then $S \to \varepsilon$.
The leaves spell $a a a \varepsilon b b b = a^3 b^3$.

## Demos

| Demo      | Shows                                                                                          |
| ---       | ---                                                                                            |
| `cnf_cyk` | $S \to a S b \mid \varepsilon$ converted to Chomsky normal form, then the CYK table for `aabb` |

Chomsky normal form reshapes every production into $A \to B C$ or $A \to a$, the shape CYK requires.
The demo prints the converted grammar, acceptance verdicts for several words, and the triangular CYK table.

## API

| Item                 | Purpose                                                                                    |
| ---                  | ---                                                                                        |
| `Grammar`            | A context-free grammar: `lex`, `nullable`, `eliminate_epsilon`, `remove_unit_productions`  |
| `Symbol`             | Terminal or nonterminal, built by `t` and `nt`                                             |
| `ParseTree`          | One parse tree of a word: `yield_string`, `leaves`, `leftmost_derivation`, `parenthesized` |
| `all_parse_trees`    | Every parse tree of a word                                                                 |
| `to_cnf`             | Chomsky normal form                                                                        |
| `recognize`, `table` | CYK recognition and the CYK table                                                          |

## Parse trees

`all_parse_trees` enumerates every parse tree of a word.
Enumeration is capped at `MAX_PARSE_TREES` trees per `(nonterminal, substring)`: a grammar with an epsilon-cycle such as $S \to S S \mid \varepsilon$ is reported as `GrammarError::TooManyParseTrees` instead of looping forever.
Membership (`in_language`) is decided by CYK and always terminates.

## Tests

```bash
cargo test
```

Unit tests live next to the code in `src/`.
Doc-tests cover the public API.

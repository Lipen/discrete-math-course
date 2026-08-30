# context-free

Context-free grammars and languages.

Parse trees, Chomsky normal form, CYK recognition, and the ambiguity question -- a grammar is ambiguous when some word has more than one parse tree.
Every idea has a runnable demo in `examples/`.

## Quick start

```bash
cargo run -p context-free --example dyck
cargo run -p context-free --example arithmetic
cargo run -p context-free --example cnf_cyk
cargo test -p context-free
```

## What a grammar generates

A context-free grammar is a tuple $G = (V, \Sigma, P, S)$: nonterminals $V$, terminals $\Sigma$, productions $A \to \alpha$, and a start symbol $S$.
It generates the language

$$ L(G) = \{ w \in \Sigma^* \mid S \Rightarrow^* w \} $$

A word may have several derivations; the structure of one derivation is a parse tree.

![Parse tree of a³b³](assets/parse-tree-a3b3.svg)

The tree shows $S \to a S b \mid \varepsilon$ deriving $a^3 b^3$: three nested applications of $S \to a S b$, then $S \to \varepsilon$.
The leaves spell $a a a \varepsilon b b b = a^3 b^3$.

## API

| Type | Purpose | Key methods |
| --- | --- | --- |
| `Grammar` | A context-free grammar | `lex`, `nullable`, `eliminate_epsilon`, `remove_unit_productions` |
| `Symbol` | Terminal or nonterminal | `terminal`, `nonterminal` |
| `ParseTree` | One parse tree of a word | `yield_string`, `leaves`, `leftmost_derivation`, `parenthesized` |
| `all_parse_trees` | Every parse tree of a word | -- |
| `to_cnf` | Chomsky normal form | -- |
| `recognize` / `table` | CYK recognition / CYK table | -- |
| `count_trees` / `ambiguous_word` / `is_unambiguous` | Ambiguity analysis | -- |

## Demos

| Demo | Shows |
| --- | --- |
| `dyck` | The Dyck language is unambiguous; the naive grammar breaks at `()()()` |
| `arithmetic` | `id+id*id` has two trees; precedence levels fix it; division groups two ways |
| `cnf_cyk` | $S \to a S b \mid \varepsilon$ in CNF, then the CYK table |

## Ambiguity

`count_trees` counts parse trees under the book's convention: epsilon is eliminated first, so `()` in $S \to S S \mid (S) \mid \varepsilon$ has exactly one tree.
`ambiguous_word` returns the shortest word with at least two trees, and `is_unambiguous` gives a certificate up to a length bound.

Enumeration is capped at `MAX_PARSE_TREES` trees per `(nonterminal, substring)`: a grammar with an epsilon-cycle such as $S \to S S \mid \varepsilon$ is reported as `GrammarError::TooManyParseTrees` instead of looping forever.
Membership (`in_language`) is decided by CYK and always terminates.

## Tests

```bash
cargo test -p context-free
```

Unit tests live next to the code in `src/`.
Run `cargo test -p context-free` to also see doc-tests covering the public API.

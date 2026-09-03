# context-free

Context-free grammars and languages.

Grammars, parse trees, Chomsky normal form, and CYK recognition.
A runnable demo ships in `examples/`.

## Quick start

```bash
cargo test
cargo run --example cnf_cyk
```

## The model

A context-free grammar is a tuple $G = (V, \Sigma, P, S)$: nonterminals $V$, terminals $\Sigma$, productions $A \to \alpha$, and a start symbol $S$.
It generates the language

$$ L(G) = \{ w \in \Sigma^* \mid S \Rightarrow^* w \} $$

A word may have several derivations.
The structure of one derivation is a parse tree.

![Parse tree of a³b³](assets/parse-tree-a3b3.svg)

The tree shows $S \to a S b \mid \varepsilon$ deriving $a^3 b^3$: three nested applications of $S \to a S b$, then $S \to \varepsilon$.
The leaves spell $a a a \varepsilon b b b = a^3 b^3$.

### Chomsky normal form

Chomsky normal form (CNF) keeps only the shapes CYK needs:

$$ A \to B C \qquad \text{or} \qquad A \to a $$

plus $S \to \varepsilon$, and only when the start symbol derives the empty word.
The conversion in `to_cnf` runs four steps:

- eliminate epsilon-productions,
- remove unit productions $A \to B$,
- give each terminal inside a multi-symbol body a fresh nonterminal,
- split long bodies into binary chains.

### CYK

The Cocke–Younger–Kasami algorithm decides membership against a CNF grammar in $O(n^3)$.
Its cell `t[i][l]` collects the nonterminals that derive the substring `word[i..i+l]`:

$$ t[i][1] = \{ A \mid A \to a_i \}, \qquad
   t[i][l] = \bigcup_{m = 1}^{l - 1} \{ A \mid A \to B C,\ B \in t[i][m],\ C \in t[i + m][l - m] \} $$

The word belongs to the language exactly when the start symbol lands in `t[0][n]`.

### Ambiguity and the enumeration cap

`all_parse_trees` returns every parse tree of a word.
Epsilon and unit productions are kept, so the trees show the grammar exactly as written.
Enumeration caps each `(nonterminal, substring)` pair at `MAX_PARSE_TREES` trees: a grammar with an epsilon-cycle such as $S \to S S \mid \varepsilon$ reports `GrammarError::TooManyParseTrees` instead of looping forever.
Membership (`in_language`) goes through CYK and always terminates.

## Demos

| Demo      | Shows                                                                                          |
| --------- | ---------------------------------------------------------------------------------------------- |
| `cnf_cyk` | $S \to a S b \mid \varepsilon$ converted to Chomsky normal form, then the CYK table for `aabb` |

The demo prints the converted grammar, acceptance verdicts for several words, and the triangular CYK table.

## API

| Item                 | Purpose                                                                                    |
| -------------------- | ------------------------------------------------------------------------------------------ |
| `Grammar`            | A context-free grammar: `lex`, `nullable`, `eliminate_epsilon`, `remove_unit_productions`  |
| `Symbol`             | Terminal or nonterminal, built by `t` and `nt`                                             |
| `ParseTree`          | One parse tree of a word: `yield_string`, `leaves`, `leftmost_derivation`, `parenthesized` |
| `all_parse_trees`    | Every parse tree of a word                                                                 |
| `to_cnf`             | Chomsky normal form                                                                        |
| `recognize`, `table` | CYK recognition and the CYK table                                                          |

## Tests

Unit tests live next to the code in `src/`.
They check the CNF shape (every production is $A \to B C$, $A \to a$, or the restored $S \to \varepsilon$), language preservation under conversion, the CYK table cells for `aabb`, the tree count of an ambiguous grammar ($S \to S S \mid a$ gives two trees for `aaa`), and the cap that turns an epsilon-cycle into `GrammarError::TooManyParseTrees`.
Doc-tests cover the public API.

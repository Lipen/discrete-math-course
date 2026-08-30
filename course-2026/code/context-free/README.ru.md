# context-free

Контекстно-свободные грамматики и языки.

Деревья разбора, нормальная форма Хомского и распознавание CYK.
Демо-примеры лежат в `examples/`.

## Быстрый старт

```bash
cargo run -p context-free --example cnf_cyk
cargo test -p context-free
```

## Что порождает грамматика

Контекстно-свободная грамматика --- это кортеж $G = (V, \Sigma, P, S)$: нетерминалы $V$, терминалы $\Sigma$, продукции $A \to \alpha$ и начальный символ $S$.
Она порождает язык

$$ L(G) = \{ w \in \Sigma^* \mid S \Rightarrow^* w \} $$

У слова может быть несколько выводов; структура одного вывода --- это дерево разбора.

![Дерево разбора a³b³](assets/parse-tree-a3b3.svg)

Дерево показывает, как $S \to a S b \mid \varepsilon$ выводит $a^3 b^3$: три вложенных применения $S \to a S b$, затем $S \to \varepsilon$.
Листья дают $a a a \varepsilon b b b = a^3 b^3$.

## API

| Тип | Назначение | Ключевые методы |
| --- | --- | --- |
| `Grammar` | Контекстно-свободная грамматика | `lex`, `nullable`, `eliminate_epsilon`, `remove_unit_productions` |
| `Symbol` | Терминал или нетерминал | `terminal`, `nonterminal` |
| `ParseTree` | Одно дерево разбора слова | `yield_string`, `leaves`, `leftmost_derivation`, `parenthesized` |
| `all_parse_trees` | Все деревья разбора слова | -- |
| `to_cnf` | Нормальная форма Хомского | -- |
| `recognize` / `table` | Распознавание CYK / таблица CYK | -- |

## Демо

| Демо | Что показывает |
| --- | --- |
| `cnf_cyk` | $S \to a S b \mid \varepsilon$ в НФХ, затем таблица CYK |

## Деревья разбора

`all_parse_trees` перечисляет все деревья разбора слова.
Перечисление ограничено `MAX_PARSE_TREES` деревьями на `(nonterminal, substring)`: грамматика с ε-циклом, такая как $S \to S S \mid \varepsilon$, сообщается как `GrammarError::TooManyParseTrees` вместо бесконечного зацикливания.
Принадлежность (`in_language`) решается алгоритмом CYK и всегда завершается.

## Тесты

```bash
cargo test -p context-free
```

Модульные тесты лежат рядом с кодом в `src/`.
Запустите `cargo test -p context-free`, чтобы также увидеть doc-тесты, покрывающие публичное API.

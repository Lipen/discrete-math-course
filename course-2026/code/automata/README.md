# automata

Конечные автоматы и регулярные языки.

## Компоненты

- `Dfa` --- детерминированный автомат: приём слов, дополнение, объединение и пересечение языков, минимизация.
- `Nfa` --- недетерминированный автомат: ε-переходы, приём слов, детерминизация.
- `RegEx` --- регулярные выражения: парсер и конструкция Томпсона.

## Примеры

```bash
cargo run -p automata --example even_ones
cargo run -p automata --example nfa_to_dfa
cargo run -p automata --example regex_matching
cargo run -p automata --example language_ops
cargo run -p automata --example minimize
```

## Тесты

```bash
cargo test -p automata
```

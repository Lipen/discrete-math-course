# code

Rust-компаньон к курсу дискретной математики.

Воркспейс из самодостаточных модулей, по одному на тему.
Каждый крейт --- независимая единица: библиотека, тесты и запускаемые примеры.
Крейты собираются, тестируются и запускаются по отдельности.

## Крейты

| Крейт | Тема | Что внутри |
| --- | --- | --- |
| [`automata`](automata/README.md) | Конечные автоматы и регулярные языки | ДКА, НКА, конструкция подмножеств, регулярки через Томпсона, минимизация, операции над языками |
| [`codes`](codes/README.md) | Коды Хэмминга | Hamming(7,4), синдромное декодирование, исправление одиночной ошибки |
| [`sat`](sat/README.md) | Выполнимость | DPLL-солвер с единичным распространением и возвратом |
| [`smt`](smt/README.md) | Выполнимость с теориями (SMT) | Разностная логика `x - y <= c`, поиск отрицательного цикла через Беллмана-Форда; демо: [`solve`](smt/examples/solve.rs), [`unsat`](smt/examples/unsat.rs) |
| [`bdd`](bdd/README.md) | Диаграммы решений | ROBDD с дополняющими рёбрами, операция `ite` |
| [`circuits`](circuits/README.md) | Комбинационные схемы | Графы вентилей (DAG), топологическая симуляция, размер/глубина, полусумматор/полный сумматор, цепочка с последовательным переносом и с опережающим переносом; демо: [`half_adder`](circuits/examples/half_adder.rs), [`ripple_carry`](circuits/examples/ripple_carry.rs), [`carry_lookahead`](circuits/examples/carry_lookahead.rs), [`fuzz`](circuits/examples/fuzz.rs) |
| [`model-checking`](model-checking/README.md) | Проверка моделей (CTL) | Структуры Крипке, раскраска состояний, семантика неподвижных точек для EX/AX/EF/EG/EU; демо: [`mutex`](model-checking/examples/mutex.rs), [`deadlock`](model-checking/examples/deadlock.rs) |
| [`analysis`](analysis/README.md) | Абстрактная интерпретация | Домены знаков, интервалов и констант; переносящие функции; widening |
| [`crypto`](crypto/README.md) | Теория чисел и криптография | Модулярная арифметика, RSA, реальные атаки на него |
| [`lambda`](lambda/README.md) | Бестиповое λ-исчисление | Термы, подстановка без захвата, β-редукция, числа Чёрча |
| [`type-theory`](type-theory/README.md) | Простое типизированное λ-исчисление (λ→) | Типы и контексты, правила var/app/abs, вывод типа через унификацию, subject reduction; демо: [`typed_terms`](type-theory/examples/typed_terms.rs), [`inference`](type-theory/examples/inference.rs), [`subject_reduction`](type-theory/examples/subject_reduction.rs) |
| [`turing`](turing/README.md) | Машины Тьюринга | Лента на двух стеках, таблица переходов, трассы вычислений, примеры машин |
| [`graphs`](graphs/README.md) | Графы | Простая модель без дженериков, BFS/DFS, Дейкстра, Краскал, Эйлер, мосты, раскраска; рендер в SVG/DOT/cytoscape/HTML |
| [`matroids`](matroids/README.md) | Матроиды | Аксиомы независимости, графический/линейный/равномерный матроид и матроид расписаний, ранг, оптимальность жадного алгоритма; демо: [`counterexample`](matroids/examples/counterexample.rs), [`spanning`](matroids/examples/spanning.rs), [`scheduling`](matroids/examples/scheduling.rs), [`linear`](matroids/examples/linear.rs), [`rank`](matroids/examples/rank.rs) |
| [`prolog`](prolog/README.md) | Логическое программирование | Термы, унификация с occurs-check, SLD-резолюция с бэктрекингом |
| [`lattices`](lattices/README.md) | Решётки и порядки | join/meet, дистрибутивность, модулярность, характеризация Биркгофа (запрещённые подрешётки M3/N5) |
| [`heyting`](heyting/README.md) | Алгебры Гейтинга | Трёхэлементная алгебра {0, 1/2, 1}, относительное псевдодополнение, закон исключённого третьего не работает; демо: [`values`](heyting/examples/values.rs), [`excluded_middle`](heyting/examples/excluded_middle.rs) |
| [`fitch`](fitch/README.md) | Натуральная дедукция | Проверка доказательств в стиле Фитча, вложенные поддоказательства по глубине, разрядка допущений; демо: [`contrapositive`](fitch/examples/contrapositive.rs), [`rejected`](fitch/examples/rejected.rs) |
| [`algebra`](algebra/README.md) | Алгебраические структуры | Трейты полугруппы/моноида/группы/кольца/поля, гомоморфизмы и факторгруппы, конечные поля `GF(2^m)` |
| [`combinatorics`](combinatorics/README.md) | Генераторы комбинаторных объектов | Перестановки, сочетания, беспорядки, разбиения числа; лексикографическое перечисление, ранг/де-ранг; демо: [`permutations`](combinatorics/examples/permutations.rs), [`combinations`](combinatorics/examples/combinations.rs), [`derangements`](combinatorics/examples/derangements.rs), [`partitions`](combinatorics/examples/partitions.rs) |

## Структура

У всех крейтов одна и та же форма:

```
<корень воркспейса>
└── <крейт>/
    ├── Cargo.toml
    ├── src/lib.rs            # точка входа библиотеки
    ├── src/*.rs              # модули по теме
    ├── examples/*.rs         # запускаемые демо
    └── README.md             # руководство по крейту
```

## Сборка, тесты, запуск

```bash
# Собрать весь воркспейс.
cargo build --workspace

# Прогнать все тесты во всех крейтах.
cargo test --workspace

# Запустить одно демо из одного крейта.
cargo run -p <крейт> --example <имя>

# Линтить всё, включая демо и тесты.
cargo clippy --workspace --all-targets
```

`-p <крейт>` выбирает крейт, `--example <имя>` --- демо (без суффикса `.rs`).
Например, `cargo run -p automata --example even_ones`.

## Как читать демо

Каждое демо написано так, чтобы его читали, а не только запускали.
Оно печатает входные данные, промежуточные шаги и результат.
Имена один в один соответствуют понятиям главы книги.

README каждого крейта объясняет модуль и перечисляет все демо:

- [automata/README.md](automata/README.md)
- [codes/README.md](codes/README.md)
- [sat/README.md](sat/README.md)
- [smt/README.md](smt/README.md)
- [bdd/README.md](bdd/README.md)
- [circuits/README.md](circuits/README.md)
- [model-checking/README.md](model-checking/README.md)
- [analysis/README.md](analysis/README.md)
- [crypto/README.md](crypto/README.md)
- [lambda/README.md](lambda/README.md)
- [type-theory/README.md](type-theory/README.md)
- [turing/README.md](turing/README.md)
- [graphs/README.md](graphs/README.md)
- [matroids/README.md](matroids/README.md)
- [prolog/README.md](prolog/README.md)
- [lattices/README.md](lattices/README.md)
- [heyting/README.md](heyting/README.md)
- [fitch/README.md](fitch/README.md)
- [algebra/README.md](algebra/README.md)
- [context-free/README.md](context-free/README.md)
- [combinatorics/README.md](combinatorics/README.md)

## Английская версия

То же руководство на английском: [README.md](README.md).

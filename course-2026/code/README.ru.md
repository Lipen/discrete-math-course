# code

Rust-компаньон курса дискретной математики: **23 крейта, по одному на тему**.

Каждый крейт --- самодостаточное учебное пособие: библиотека, модульные тесты
и запускаемые примеры, которые читаешь как код, а не просто гоняешь.
Каждый крейт собирается, тестируется и запускается сам по себе; ни один не
импортирует другой.

## Крейты по темам

### Логика

| Крейт | Тема | Что внутри |
| --- | --- | --- |
| [`sat`](sat/README.ru.md) | Выполнимость | DPLL-солвер с единичным распространением и возвратом |
| [`smt`](smt/README.ru.md) | Выполнимость с теориями (SMT) | Разностная логика `x - y <= c`, поиск отрицательного цикла через Беллмана-Форда; демо: [`solve`](smt/examples/solve.rs), [`unsat`](smt/examples/unsat.rs) |
| [`fol`](fol/README.ru.md) | Логика предикатов | Термы, формулы, кванторы, подстановка без захвата, модели по Тарскому, общезначимость/выполнимость перебором конечного домена; демо: [`mortal`](fol/examples/mortal.rs), [`quantifier_scope`](fol/examples/quantifier_scope.rs), [`substitution`](fol/examples/substitution.rs), [`validity`](fol/examples/validity.rs) |
| [`fitch`](fitch/README.ru.md) | Натуральная дедукция | Проверка доказательств в стиле Фитча, вложенные поддоказательства по глубине, разрядка допущений; демо: [`contrapositive`](fitch/examples/contrapositive.rs), [`rejected`](fitch/examples/rejected.rs) |
| [`prolog`](prolog/README.ru.md) | Логическое программирование | Термы, унификация с occurs-check, SLD-резолюция с бэктрекингом |
| [`heyting`](heyting/README.ru.md) | Алгебры Гейтинга | Трёхэлементная алгебра {0, 1/2, 1}, относительное псевдодополнение, закон исключённого третьего не работает; демо: [`values`](heyting/examples/values.rs), [`excluded_middle`](heyting/examples/excluded_middle.rs) |
| [`fuzzy`](fuzzy/README.ru.md) | Нечёткие множества и нечёткая логика | Кусочно-линейные функции принадлежности, операции Заде (min/max/дополнение), t-нормы, α-срезы и декомпозиция, арифметика ТНЧ, max-min-композиция, вывод Мамдани с дефаззификацией (центроид, среднее максимума, биссектриса); демо: [`operations`](fuzzy/examples/operations.rs), [`fuzzy_numbers`](fuzzy/examples/fuzzy_numbers.rs), [`relations`](fuzzy/examples/relations.rs), [`controller`](fuzzy/examples/controller.rs) |

### Автоматы, языки, вычислимость

| Крейт | Тема | Что внутри |
| --- | --- | --- |
| [`automata`](automata/README.ru.md) | Конечные автоматы и регулярные языки | ДКА, НКА, конструкция подмножеств, регулярки через Томпсона, минимизация, операции над языками |
| [`context-free`](context-free/README.ru.md) | Контекстно-свободные грамматики | Деревья разбора, приведение к НФХ, распознавание по CYK, проверка неоднозначности; демо: [`dyck`](context-free/examples/dyck.rs), [`arithmetic`](context-free/examples/arithmetic.rs), [`cnf_cyk`](context-free/examples/cnf_cyk.rs) |
| [`turing`](turing/README.ru.md) | Машины Тьюринга | Лента на двух стеках, таблица переходов, трассы вычислений, примеры машин |
| [`codes`](codes/README.ru.md) | Коды Хэмминга | Hamming(7,4), синдромное декодирование, исправление одиночной ошибки |

### λ-исчисление и типы

| Крейт | Тема | Что внутри |
| --- | --- | --- |
| [`lambda`](lambda/README.ru.md) | Бестиповое λ-исчисление | Термы, подстановка без захвата, β-редукция, числа Чёрча |
| [`type-theory`](type-theory/README.ru.md) | Простое типизированное λ-исчисление (λ→) | Типы и контексты, правила var/app/abs, вывод типа через унификацию, сохранение типа при редукции; демо: [`typed_terms`](type-theory/examples/typed_terms.rs), [`inference`](type-theory/examples/inference.rs), [`subject_reduction`](type-theory/examples/subject_reduction.rs) |

### Алгебра и структуры

| Крейт | Тема | Что внутри |
| --- | --- | --- |
| [`algebra`](algebra/README.ru.md) | Алгебраические структуры | Трейты полугруппы/моноида/группы/кольца/поля, гомоморфизмы и факторгруппы, конечные поля `GF(2^m)` |
| [`lattices`](lattices/README.ru.md) | Решётки и порядки | join/meet, дистрибутивность, модулярность, характеризация Биркгофа (запрещённые подрешётки M3/N5) |
| [`crypto`](crypto/README.ru.md) | Теория чисел и криптография | Модулярная арифметика, RSA, реальные атаки на него |

### Графы и комбинаторика

| Крейт | Тема | Что внутри |
| --- | --- | --- |
| [`graphs`](graphs/README.ru.md) | Графы | Простая модель без дженериков, BFS/DFS, Дейкстра, Краскал, Эйлер, мосты, раскраска; рендер в SVG/DOT/cytoscape/HTML |
| [`matroids`](matroids/README.ru.md) | Матроиды | Аксиомы независимости, графический/линейный/равномерный матроид и матроид расписаний, ранг, оптимальность жадного алгоритма; демо: [`counterexample`](matroids/examples/counterexample.rs), [`spanning`](matroids/examples/spanning.rs), [`scheduling`](matroids/examples/scheduling.rs), [`linear`](matroids/examples/linear.rs), [`rank`](matroids/examples/rank.rs) |
| [`combinatorics`](combinatorics/README.ru.md) | Генераторы комбинаторных объектов | Перестановки, сочетания, беспорядки, разбиения числа; лексикографическое перечисление; демо: [`permutations`](combinatorics/examples/permutations.rs), [`combinations`](combinatorics/examples/combinations.rs), [`derangements`](combinatorics/examples/derangements.rs), [`partitions`](combinatorics/examples/partitions.rs) |

### Схемы и верификация

| Крейт | Тема | Что внутри |
| --- | --- | --- |
| [`circuits`](circuits/README.ru.md) | Комбинационные схемы | Графы вентилей (DAG), топологическая симуляция, размер/глубина, полусумматор/полный сумматор, сумматор с последовательным переносом; демо: [`half_adder`](circuits/examples/half_adder.rs), [`ripple_carry`](circuits/examples/ripple_carry.rs), [`fuzz`](circuits/examples/fuzz.rs) |
| [`bdd`](bdd/README.ru.md) | Диаграммы решений | ROBDD с дополняющими рёбрами, операция `ite` |
| [`model-checking`](model-checking/README.ru.md) | Проверка моделей (CTL) | Структуры Крипке, раскраска состояний, семантика неподвижных точек для EX/AX/EF/EG/EU; демо: [`mutex`](model-checking/examples/mutex.rs), [`deadlock`](model-checking/examples/deadlock.rs) |
| [`analysis`](analysis/README.ru.md) | Абстрактная интерпретация | Домены знаков, интервалов и констант; переносящие функции; widening |

## Быстрый старт

```bash
cargo build --workspace     # собрать все 23 крейта
cargo test --workspace      # прогнать все тесты во всех крейтах
cargo clippy --workspace --all-targets   # линт всего, без предупреждений

cargo run -p <крейт> --example <имя>    # запустить одно демо
```

`-p <крейт>` выбирает крейт, `--example <имя>` --- демо (без суффикса `.rs`).
Например, `cargo run -p automata --example even_ones`.

## Структура

У всех крейтов одна и та же форма:

```
<корень воркспейса>
└── <крейт>/
    ├── Cargo.toml
    ├── src/lib.rs            # точка входа библиотеки
    ├── src/*.rs              # модули по теме
    ├── examples/*.rs         # запускаемые демо
    ├── README.md             # руководство по крейту (по-английски)
    └── README.ru.md          # то же руководство по-русски
```

## Как читать демо

Каждое демо написано так, чтобы его читали, а не только запускали.
Оно печатает входные данные, промежуточные шаги и результат.
Имена один в один соответствуют понятиям главы книги.

README каждого крейта объясняет модули и перечисляет все демо.

## Английская версия

То же руководство на английском: [README.md](README.md).

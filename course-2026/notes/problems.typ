// Банк задач с подсказками и решениями.
// Компилируется самостоятельно: typst compile problems.typ
// Задачи → Подсказки → Решения.
//
// Мета-разделы (тематическая группировка задач, см. .dev/1_active/book-exercises/spec.md):
//   meta-01 language            m01-m04  логика, множества, отношения, функции
//   meta-02 order-infinity      m05-m06  кардиналы, порядок
//   meta-03 graphs              m07      графы
//   meta-04 boolean-circuits    m08-m09  булева алгебра, схемы
//   meta-05 codes-sat           m10-m11  коды, SAT
//   meta-06 counting-probability m12-m14 комбинаторика, вероятность, производящие функции
//   meta-07 constructions       m15      конструкции чисел
//   meta-08 automata-computation m16-m17 автоматы, Тьюринг
//   meta-09 lambda-types        m18-m19  лямбда-исчисление, теория типов
//   meta-10 fuzzy               m20-m22  за пределами N, сложность, нечёткие множества
//
// Каждый мета-раздел лежит в трёх файлах: meta-NN-topic-{problems,hints,solutions}.typ.
#import "common-notes.typ": *
#show: notes-template.with(theme: oklch(55%, 0.16, 230deg))

#set document(
  title: "Банк задач --- Дискретная математика",
  author: "Константин Чухарев",
)

#front-matter
#main-matter

#import "problem-bank/macros.typ": *

= Банк задач

#text(size: 0.95em, fill: luma(45%))[
  Задачи сгруппированы по мета-разделам.
  Для каждой задачи доступны подсказка и решение --- ссылки внизу блока.
  Подсказки и решения вынесены в конец, чтобы не мешать самостоятельным попыткам.
]

// ═══ Задачи ═══

#include "problem-bank/meta-01-language-problems.typ"
#include "problem-bank/meta-02-order-infinity-problems.typ"
#include "problem-bank/meta-03-graphs-problems.typ"
#include "problem-bank/meta-04-boolean-circuits-problems.typ"
#include "problem-bank/meta-05-codes-sat-problems.typ"
// #include "problem-bank/meta-06-counting-probability-problems.typ"
// #include "problem-bank/meta-07-constructions-problems.typ"
// #include "problem-bank/meta-08-automata-computation-problems.typ"
// #include "problem-bank/meta-09-lambda-types-problems.typ"
// #include "problem-bank/meta-10-fuzzy-problems.typ"

// ═══ Подсказки ═══

#pagebreak(weak: true)
= Подсказки

Подсказка не выдаёт ответ --- она указывает направление для самостоятельного решения.

#include "problem-bank/meta-01-language-hints.typ"
#include "problem-bank/meta-02-order-infinity-hints.typ"
#include "problem-bank/meta-03-graphs-hints.typ"
#include "problem-bank/meta-04-boolean-circuits-hints.typ"
#include "problem-bank/meta-05-codes-sat-hints.typ"
// #include "problem-bank/meta-06-counting-probability-hints.typ"

// ═══ Решения ═══

#pagebreak(weak: true)
= Решения

Решение содержит полную цепочку рассуждений.
Рекомендуется читать после самостоятельной попытки.

#include "problem-bank/meta-01-language-solutions.typ"
#include "problem-bank/meta-02-order-infinity-solutions.typ"
#include "problem-bank/meta-03-graphs-solutions.typ"
#include "problem-bank/meta-04-boolean-circuits-solutions.typ"
#include "problem-bank/meta-05-codes-sat-solutions.typ"
// #include "problem-bank/meta-06-counting-probability-solutions.typ"

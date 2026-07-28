// Банк задач с подсказками и решениями.
// Компилируется самостоятельно: typst compile problems.typ
// Задачи → Подсказки → Решения.
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

#include "problem-bank/01-language-problems.typ"
// #include "problem-bank/02-order-infinity-problems.typ"
// #include "problem-bank/meta-03-graphs.typ"
// #include "problem-bank/meta-04-boolean-circuits.typ"
// #include "problem-bank/meta-05-codes-sat.typ"
// #include "problem-bank/meta-06-counting-probability.typ"
// #include "problem-bank/meta-07-constructions.typ"
// #include "problem-bank/meta-08-automata-computation.typ"
// #include "problem-bank/meta-09-lambda-types.typ"
// #include "problem-bank/meta-10-fuzzy.typ"

// ═══ Подсказки ═══

#pagebreak(weak: true)
= Подсказки

Подсказка не выдаёт ответ --- она указывает направление для самостоятельного решения.

#include "problem-bank/01-language-hints.typ"

// ═══ Решения ═══

#pagebreak(weak: true)
= Решения

Решение содержит полную цепочку рассуждений.
Рекомендуется читать после самостоятельной попытки.

#include "problem-bank/01-language-solutions.typ"

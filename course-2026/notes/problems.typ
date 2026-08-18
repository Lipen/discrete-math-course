// Банк задач с подсказками и решениями.
// Компилируется самостоятельно: typst compile problems.typ
// Задачи → Подсказки → Решения.
//
// Разделы (по одной теме на раздел; главы mXX --- для ориентации):
//   language             m01, m03-m06  логика, FOL, множества, отношения, функции
//   cardinals            m07      кардиналы, бесконечность
//   order                m08      отношения порядка
//   graphs               m09      графы
//   boolean-circuits     m10-m11  булева алгебра, схемы
//   codes                m12      коды, исправляющие ошибки
//   sat                  m13      SAT, NP-полнота
//   counting-probability m17, m19-m20  комбинаторика, вероятность, производящие функции
//   constructions        m21      конструкции чисел
//   automata-computation m22, m24-m25  автоматы, Тьюринг, разрешимость
//   lambda-types         m26-m27  лямбда-исчисление, теория типов
//   beyond-n             m28      за пределами натуральных чисел
//   complexity           m29      сложность вычислений
//   fuzzy                m34      нечёткие множества
//
// Каждый раздел лежит в трёх файлах: topic-{problems,hints,solutions}.typ.
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
  Задачи сгруппированы по темам.
  Для каждой задачи доступны подсказка и решение --- ссылки внизу блока.
  Подсказки и решения вынесены в конец, чтобы не мешать самостоятельным попыткам.
]

// ═══ Задачи ═══

#include "problem-bank/language-problems.typ"
#include "problem-bank/cardinals-problems.typ"
#include "problem-bank/order-problems.typ"
#include "problem-bank/graphs-problems.typ"
#include "problem-bank/boolean-circuits-problems.typ"
#include "problem-bank/codes-problems.typ"
#include "problem-bank/sat-problems.typ"
#include "problem-bank/counting-probability-problems.typ"
#include "problem-bank/constructions-problems.typ"
#include "problem-bank/automata-computation-problems.typ"
#include "problem-bank/lambda-types-problems.typ"
#include "problem-bank/beyond-n-problems.typ"
#include "problem-bank/complexity-problems.typ"
#include "problem-bank/fuzzy-problems.typ"

// ═══ Подсказки ═══

#pagebreak(weak: true)

= Подсказки

Подсказка не выдаёт ответ --- она указывает направление для самостоятельного решения.

#include "problem-bank/language-hints.typ"
#include "problem-bank/cardinals-hints.typ"
#include "problem-bank/order-hints.typ"
#include "problem-bank/graphs-hints.typ"
#include "problem-bank/boolean-circuits-hints.typ"
#include "problem-bank/codes-hints.typ"
#include "problem-bank/sat-hints.typ"
#include "problem-bank/counting-probability-hints.typ"
#include "problem-bank/constructions-hints.typ"
#include "problem-bank/automata-computation-hints.typ"
#include "problem-bank/lambda-types-hints.typ"
#include "problem-bank/beyond-n-hints.typ"
#include "problem-bank/complexity-hints.typ"
#include "problem-bank/fuzzy-hints.typ"

// ═══ Решения ═══

#pagebreak(weak: true)

= Решения

Решение содержит полную цепочку рассуждений.
Рекомендуется читать после самостоятельной попытки.

#include "problem-bank/language-solutions.typ"
#include "problem-bank/cardinals-solutions.typ"
#include "problem-bank/order-solutions.typ"
#include "problem-bank/graphs-solutions.typ"
#include "problem-bank/boolean-circuits-solutions.typ"
#include "problem-bank/codes-solutions.typ"
#include "problem-bank/sat-solutions.typ"
#include "problem-bank/counting-probability-solutions.typ"
#include "problem-bank/constructions-solutions.typ"
#include "problem-bank/automata-computation-solutions.typ"
#include "problem-bank/lambda-types-solutions.typ"
#include "problem-bank/beyond-n-solutions.typ"
#include "problem-bank/complexity-solutions.typ"
#include "problem-bank/fuzzy-solutions.typ"

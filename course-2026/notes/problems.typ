// Банк задач с подсказками и решениями.
// Компилируется самостоятельно: typst compile problems.typ
// Задачи → Подсказки → Решения.
//
// Разделы (по одной теме на раздел; главы mXX --- для ориентации):
//   language             m01, m03-m06  логика, FOL, множества, отношения, функции
//   deduction            m02      дедукция, натуральная дедукция, системы вывода
//   cardinals            m07      кардиналы, бесконечность
//   order                m08      отношения порядка
//   graphs               m09      графы
//   boolean-circuits     m10-m11  булева алгебра, схемы
//   codes                m12      коды, исправляющие ошибки
//   sat                  m13      SAT, NP-полнота
//   smt                  m14      SMT, DPLL(T), EUF, разностная логика, битовые векторы
//   logic-programming    m15      логическое программирование
//   matroids             m16      матроиды, жадный алгоритм
//   counting-probability m17, m19-m20  комбинаторика, вероятность, производящие функции
//   number-theory-crypto m18      теория чисел и криптография
//   constructions        m21      конструкции чисел
//   automata-computation m22, m24-m25  автоматы, Тьюринг, разрешимость
//   context-free         m23      контекстно-свободные языки, МП-автоматы
//   lambda-types         m26-m27  лямбда-исчисление, теория типов
//   beyond-n             m28      за пределами натуральных чисел
//   complexity           m29      сложность вычислений
//   abstract-interpretation m30   абстрактная интерпретация, widening
//   verification         m31      формальная верификация, тройки Хоара
//   modal-temporal       m32      модальная и темпоральная логика, LTL/CTL, model checking
//   intuitionism         m33      интуиционизм, BHK, семантика Крипке
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
#include "problem-bank/deduction-problems.typ"
#include "problem-bank/cardinals-problems.typ"
#include "problem-bank/order-problems.typ"
#include "problem-bank/graphs-problems.typ"
#include "problem-bank/boolean-circuits-problems.typ"
#include "problem-bank/codes-problems.typ"
#include "problem-bank/sat-problems.typ"
#include "problem-bank/smt-problems.typ"
#include "problem-bank/logic-programming-problems.typ"
#include "problem-bank/matroids-problems.typ"
#include "problem-bank/counting-probability-problems.typ"
#include "problem-bank/number-theory-crypto-problems.typ"
#include "problem-bank/constructions-problems.typ"
#include "problem-bank/automata-computation-problems.typ"
#include "problem-bank/context-free-problems.typ"
#include "problem-bank/lambda-types-problems.typ"
#include "problem-bank/beyond-n-problems.typ"
#include "problem-bank/complexity-problems.typ"
#include "problem-bank/abstract-interpretation-problems.typ"
#include "problem-bank/verification-problems.typ"
#include "problem-bank/modal-temporal-problems.typ"
#include "problem-bank/intuitionism-problems.typ"
#include "problem-bank/fuzzy-problems.typ"

// ═══ Подсказки ═══

#pagebreak(weak: true)

= Подсказки

Подсказка не выдаёт ответ --- она указывает направление для самостоятельного решения.

#include "problem-bank/language-hints.typ"
#include "problem-bank/deduction-hints.typ"
#include "problem-bank/cardinals-hints.typ"
#include "problem-bank/order-hints.typ"
#include "problem-bank/graphs-hints.typ"
#include "problem-bank/boolean-circuits-hints.typ"
#include "problem-bank/codes-hints.typ"
#include "problem-bank/sat-hints.typ"
#include "problem-bank/smt-hints.typ"
#include "problem-bank/logic-programming-hints.typ"
#include "problem-bank/matroids-hints.typ"
#include "problem-bank/counting-probability-hints.typ"
#include "problem-bank/number-theory-crypto-hints.typ"
#include "problem-bank/constructions-hints.typ"
#include "problem-bank/automata-computation-hints.typ"
#include "problem-bank/context-free-hints.typ"
#include "problem-bank/lambda-types-hints.typ"
#include "problem-bank/beyond-n-hints.typ"
#include "problem-bank/complexity-hints.typ"
#include "problem-bank/abstract-interpretation-hints.typ"
#include "problem-bank/verification-hints.typ"
#include "problem-bank/modal-temporal-hints.typ"
#include "problem-bank/intuitionism-hints.typ"
#include "problem-bank/fuzzy-hints.typ"

// ═══ Решения ═══

#pagebreak(weak: true)

= Решения

Решение содержит полную цепочку рассуждений.
Рекомендуется читать после самостоятельной попытки.

#include "problem-bank/language-solutions.typ"
#include "problem-bank/deduction-solutions.typ"
#include "problem-bank/cardinals-solutions.typ"
#include "problem-bank/order-solutions.typ"
#include "problem-bank/graphs-solutions.typ"
#include "problem-bank/boolean-circuits-solutions.typ"
#include "problem-bank/codes-solutions.typ"
#include "problem-bank/sat-solutions.typ"
#include "problem-bank/smt-solutions.typ"
#include "problem-bank/logic-programming-solutions.typ"
#include "problem-bank/matroids-solutions.typ"
#include "problem-bank/counting-probability-solutions.typ"
#include "problem-bank/number-theory-crypto-solutions.typ"
#include "problem-bank/constructions-solutions.typ"
#include "problem-bank/automata-computation-solutions.typ"
#include "problem-bank/context-free-solutions.typ"
#include "problem-bank/lambda-types-solutions.typ"
#include "problem-bank/beyond-n-solutions.typ"
#include "problem-bank/complexity-solutions.typ"
#include "problem-bank/abstract-interpretation-solutions.typ"
#include "problem-bank/verification-solutions.typ"
#include "problem-bank/modal-temporal-solutions.typ"
#include "problem-bank/intuitionism-solutions.typ"
#include "problem-bank/fuzzy-solutions.typ"

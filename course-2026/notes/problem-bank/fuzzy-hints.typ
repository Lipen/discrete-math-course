// Подсказки к разделу Нечёткие множества (m22).
#import "macros.typ": pb-hint
#import "../notation.typ": *

#pb-hint("fuzzy:membership")[
  Кусочно-линейная: растёт от 0 к 1 на $[20, 35]$, равна 1 на $[35, 50]$, убывает на $[50, 65]$.
  Подставьте точки в линейные участки.
]

#pb-hint("fuzzy:operations")[
  Заде: пересечение --- $min$, объединение --- $max$, дополнение --- $1 - mu$.
  Применяйте поэлементно.
]

#pb-hint("fuzzy:support-core")[
  Носитель --- где $mu > 0$; ядро --- где $mu = 1$; высота --- максимальное значение $mu$.
]

#pb-hint("fuzzy:alpha-cuts")[
  Треугольное число $(l, m, r)$: $alpha$-срез --- интервал $[l + alpha (m - l), r - alpha (r - m)]$.
]

#pb-hint("fuzzy:triangular-arith")[
  Сложение по вершинам: $(l_1 + l_2, m_1 + m_2, r_1 + r_2)$.
  Для вычитания --- разности вершин.
]

#pb-hint("fuzzy:tnorms")[
  Заде: $min(a, b)$. Вероятностная: $a b$. Лукасевича: $max(0, a + b - 1)$.
  Подставьте $a = 0.6$, $b = 0.7$.
]

#pb-hint("fuzzy:distributivity")[
  Проверьте поточечно: образуют ли $min$ и $max$ дистрибутивную решётку на $[0, 1]$?
]

#pb-hint("fuzzy:controller")[
  Задайте треугольные функции принадлежности для температур и обогрева.
  Firing strength правила --- $mu$ входа в посылку (для «и» --- min).
]

#pb-hint("fuzzy:decomposition")[
  $x in A_alpha$ тогда и только тогда, когда $mu_A (x) >= alpha$.
  Верхняя грань таких $alpha$ --- сам $mu_A (x)$.
]

#pb-hint("fuzzy:defuzzification")[
  Centroid: $integral x mu (x) d x \/ integral mu (x) d x$.
  Mean of Max: середина отрезка, где $mu = 1$.
  Посчитайте площадь и моменты трапеции.
]

#pb-hint("fuzzy:excluded-middle")[
  Заде: при $mu = 0.5$ и $A union not A$, и $A inter not A$ дают 0.5.
  Лукасевича: $max(0, a + 1 - a - 1) = 0$; но $max(0, 2a - 1) < a$.
]

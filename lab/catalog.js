/* Catalog of the discrete-mathematics lab stand. */
(function () {
  "use strict";

  const modules = [
    {
      id: "sets",
      name: "Язык и множества",
      short: "Язык",
      accent: "#2d5fa8",
      soft: "#e8f0fb",
      blurb: "Высказывания, кванторы и множества: язык, на котором дальше строится весь курс.",
    },
    {
      id: "relations",
      name: "Отношения и порядок",
      short: "Отношения",
      accent: "#6a4c93",
      soft: "#efe9f7",
      blurb: "Отношения, эквивалентность, порядок, функции и бесконечности.",
    },
    {
      id: "logic",
      name: "Логика и вывод",
      short: "Логика",
      accent: "#2f7d5c",
      soft: "#e6f2ec",
      blurb: "Семантика, натуральная дедукция и логика первого порядка.",
    },
    {
      id: "boolean",
      name: "Булевы функции",
      short: "Булевы",
      accent: "#b45309",
      soft: "#fbf0dc",
      blurb: "Функции, минимизация, диаграммы решений и схемы.",
    },
    {
      id: "codes",
      name: "Коды и сжатие",
      short: "Коды",
      accent: "#0f766e",
      soft: "#e3f4f1",
      blurb: "Помехоустойчивые коды и префиксное сжатие.",
    },
  ];

  const labs = [
    {
      id: "statements", file: "statements.html", module: "sets", mark: "¬",
      topic: "Логика высказываний",
      title: "Высказывания и связки",
      blurb: "Соберите формулу, постройте таблицу истинности, разберите дерево разбора и проверьте закон.",
      tags: ["разбор", "таблица истинности", "законы"],
    },
    {
      id: "predicates", file: "predicates.html", module: "sets", mark: "∀",
      topic: "Кванторы",
      title: "Предикаты и кванторы",
      blurb: "Конечная модель, в которой видно, кто свидетель, а кто контрпример для ∀ и ∃.",
      tags: ["∀/∃", "свидетель", "отрицание"],
    },
    {
      id: "sets", file: "sets.html", module: "sets", mark: "∈",
      topic: "Множества",
      title: "Множества и диаграммы",
      blurb: "Соберите множества, проверьте операции, посмотрите Венна и степень множества.",
      tags: ["∪/∩/∖", "Венн", "2^A"],
    },
    {
      id: "relations", file: "relations.html", module: "relations", mark: "R",
      topic: "Отношения",
      title: "Отношения и эквивалентность",
      blurb: "Матрица и граф отношения, свойства, замыкания, классы эквивалентности и фактор.",
      tags: ["свойства", "замыкание", "фактор"],
    },
    {
      id: "order", file: "order.html", module: "relations", mark: "≤",
      topic: "Порядок",
      title: "Порядок и диаграмма Хассе",
      blurb: "Посета, диаграмма покрытий, минимумы, максимумы, цепи и линейное продолжение.",
      tags: ["Хассе", "границы", "цепи"],
    },
    {
      id: "functions", file: "functions.html", module: "relations", mark: "f",
      topic: "Функции",
      title: "Функции и отображения",
      blurb: "Инъекция, сюръекция, биекция, образ, прообраз, композиция и обратная функция.",
      tags: ["образ", "прообраз", "обратная"],
    },
    {
      id: "cardinality", file: "cardinality.html", module: "relations", mark: "ℵ₀",
      topic: "Счётность",
      title: "Счётность и бесконечность",
      blurb: "Отель Гильберта, биекция N→Z, канторовы пары и диагональ Кантора.",
      tags: ["биекция", "N×N", "диагональ"],
    },
    {
      id: "transfinite", file: "transfinite.html", module: "relations", mark: "ω",
      topic: "Ординалы",
      title: "Трансфинитные ординалы",
      blurb: "Лесенка ординалов, нормальная форма, пределы и сравнение.",
      tags: ["ω", "ординал", "кардинал"],
    },
    {
      id: "semantics", file: "semantics.html", module: "logic", mark: "⊨",
      topic: "Семантика",
      title: "Семантика и следствие",
      blurb: "Модели посылок, истинность заключения и конкретный контрпример.",
      tags: ["модель", "следствие", "контрпример"],
    },
    {
      id: "deduction", file: "deduction.html", module: "logic", mark: "⊢",
      topic: "Натуральная дедукция",
      title: "Натуральная дедукция",
      blurb: "Соберите вывод в стиле Фитча и проверьте каждое правило.",
      tags: ["Фитч", "правила", "вывод"],
    },
    {
      id: "fol", file: "fol.html", module: "logic", mark: "∀x",
      topic: "Логика первого порядка",
      title: "Модели первого порядка",
      blurb: "Домен, предикаты и кванторы: истинность, свидетели и порядок кванторов.",
      tags: ["модель", "кванторы", "R(x,y)"],
    },
    {
      id: "boolean-functions", file: "boolean-functions.html", module: "boolean", mark: "f₂",
      topic: "Булевы функции",
      title: "Булевы функции",
      blurb: "Таблица, вектор, полином Жегалкина, классы Поста, куб и карта.",
      tags: ["АНФ", "Пост", "куб"],
    },
    {
      id: "sat", file: "sat.html", module: "boolean", mark: "SAT",
      topic: "SAT",
      title: "SAT и DPLL",
      blurb: "CNF, трасса DPLL, решения, пропагации, конфликты и готовые задачи.",
      tags: ["CNF", "DPLL", "конфликт"],
    },
    {
      id: "minimization", file: "minimization.html", module: "boolean", mark: "K",
      topic: "Минимизация",
      title: "Карта Карно",
      blurb: "Простые импликанты и точный минимум ДНФ с безразличными наборами.",
      tags: ["Карно", "импликанты", "минимум"],
    },
    {
      id: "bdd", file: "bdd.html", module: "boolean", mark: "BDD",
      topic: "Диаграммы решений",
      title: "Диаграммы решений",
      blurb: "ROBDD, склейка поддиаграмм и цена порядка переменных.",
      tags: ["ROBDD", "порядок", "склейка"],
    },
    {
      id: "circuits", file: "circuits.html", module: "boolean", mark: "∧",
      topic: "Схемы",
      title: "Схемы",
      blurb: "Вентили, размер, глубина, таблица истинности и проверка против эталона.",
      tags: ["вентили", "глубина", "митер"],
    },
    {
      id: "hamming", file: "hamming.html", module: "codes", mark: "7,4",
      topic: "Коды Хэмминга",
      title: "Код Хэмминга",
      blurb: "Проверочные биты, синдром, позиция ошибки и исправление.",
      tags: ["синдром", "H", "ошибка"],
    },
    {
      id: "huffman", file: "huffman.html", module: "codes", mark: "H",
      topic: "Сжатие",
      title: "Дерево Хаффмана",
      blurb: "Жадное слияние, коды, средняя длина и энтропия.",
      tags: ["префиксный", "L", "энтропия"],
    },
  ];

  const byId = new Map(labs.map((lab) => [lab.id, lab]));

  function moduleOf(id) {
    return modules.find((module) => module.id === id) || modules[0];
  }

  function labsOf(moduleId) {
    return labs.filter((lab) => lab.module === moduleId);
  }

  window.LAB_CATALOG = {
    modules,
    labs,
    byId,
    moduleOf,
    labsOf,
  };
})();

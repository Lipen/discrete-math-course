/* Catalog of the first-semester lab stand. */
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
      blurb: "Функции, полиномы, минимизация, диаграммы решений и схемы.",
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

  const lectures = [
    { num: 1, title: "Высказывания и связки", week: "8–9 сентября", module: "sets", labs: ["statements"] },
    { num: 2, title: "Предикаты и доказательства", week: "15–16 сентября", module: "sets", labs: ["predicates"] },
    { num: 3, title: "Множества", week: "22–23 сентября", module: "sets", labs: ["sets"] },
    { num: 4, title: "Отношения и эквивалентность", week: "29–30 сентября", module: "relations", labs: ["relations"] },
    { num: 5, title: "Отношение порядка", week: "6–7 октября", module: "relations", labs: ["order"] },
    { num: 6, title: "Функции", week: "13–14 октября", module: "relations", labs: ["functions"] },
    { num: 7, title: "Счётность и несчётность", week: "20–21 октября", module: "relations", labs: ["cardinality"] },
    { num: 8, title: "Трансфинитное", week: "27–28 октября", module: "relations", labs: ["transfinite"] },
    { num: 9, title: "Язык и истина", week: "3–4 ноября", module: "logic", labs: ["semantics"] },
    { num: 10, title: "Натуральная дедукция", week: "10–11 ноября", module: "logic", labs: ["deduction"] },
    { num: 11, title: "Логика первого порядка", week: "17–18 ноября", module: "logic", labs: ["fol"] },
    { num: 12, title: "Алгебра булевых функций", week: "24–25 ноября", module: "boolean", labs: ["boolean-functions", "sat"] },
    { num: 13, title: "Минимизация и диаграммы решений", week: "1–2 декабря", module: "boolean", labs: ["minimization", "bdd"] },
    { num: 14, title: "Схемы: логика и проверка", week: "8–9 декабря", module: "boolean", labs: ["circuits"] },
    { num: 15, title: "Коды с исправлением ошибок", week: "15–16 декабря", module: "codes", labs: ["hamming"] },
    { num: 16, title: "Сжатие и код Хаффмана", week: "22–23 декабря", module: "codes", labs: ["huffman"] },
  ];

  const labs = [
    {
      id: "statements", file: "statements.html", lecture: 1, module: "sets", mark: "¬",
      title: "Высказывания и связки",
      blurb: "Соберите формулу, постройте таблицу истинности, разберите дерево разбора и проверьте закон.",
      tags: ["разбор", "таблица истинности", "законы"],
    },
    {
      id: "predicates", file: "predicates.html", lecture: 2, module: "sets", mark: "∀",
      title: "Предикаты и кванторы",
      blurb: "Конечная модель, в которой видно, кто свидетель, а кто контрпример для ∀ и ∃.",
      tags: ["∀/∃", "свидетель", "отрицание"],
    },
    {
      id: "sets", file: "sets.html", lecture: 3, module: "sets", mark: "∈",
      title: "Множества и диаграммы",
      blurb: "Соберите множества, проверьте операции, посмотрите Венна и степень множества.",
      tags: ["∪/∩/∖", "Венн", "2^A"],
    },
    {
      id: "relations", file: "relations.html", lecture: 4, module: "relations", mark: "R",
      title: "Отношения и эквивалентность",
      blurb: "Матрица и граф отношения, свойства, замыкания, классы эквивалентности и фактор.",
      tags: ["свойства", "замыкание", "фактор"],
    },
    {
      id: "order", file: "order.html", lecture: 5, module: "relations", mark: "≤",
      title: "Порядок и диаграмма Хассе",
      blurb: "Посета, диаграмма покрытий, минимумы, максимумы, цепи и линейное продолжение.",
      tags: ["Хассе", "границы", "цепи"],
    },
    {
      id: "functions", file: "functions.html", lecture: 6, module: "relations", mark: "f",
      title: "Функции и отображения",
      blurb: "Инъекция, сюръекция, биекция, образ, прообраз, композиция и обратная функция.",
      tags: ["образ", "прообраз", "обратная"],
    },
    {
      id: "cardinality", file: "cardinality.html", lecture: 7, module: "relations", mark: "ℵ₀",
      title: "Счётность и бесконечность",
      blurb: "Отель Гильберта, биекция N→Z, канторовы пары и диагональ Кантора.",
      tags: ["биекция", "N×N", "диагональ"],
    },
    {
      id: "transfinite", file: "transfinite.html", lecture: 8, module: "relations", mark: "ω",
      title: "Трансфинитные ординалы",
      blurb: "Лесенка ординалов, нормальная форма, пределы и сравнение.",
      tags: ["ω", "ординал", "кардинал"],
    },
    {
      id: "semantics", file: "semantics.html", lecture: 9, module: "logic", mark: "⊨",
      title: "Семантика и следствие",
      blurb: "Модели посылок, истинность заключения и конкретный контрпример.",
      tags: ["модель", "следствие", "контрпример"],
    },
    {
      id: "deduction", file: "deduction.html", lecture: 10, module: "logic", mark: "⊢",
      title: "Натуральная дедукция",
      blurb: "Соберите вывод в стиле Фитча и проверьте каждое правило.",
      tags: ["Фитч", "правила", "вывод"],
    },
    {
      id: "fol", file: "fol.html", lecture: 11, module: "logic", mark: "∀x",
      title: "Модели первого порядка",
      blurb: "Домен, предикаты и кванторы: истинность, свидетели и порядок кванторов.",
      tags: ["модель", "кванторы", "R(x,y)"],
    },
    {
      id: "boolean-functions", file: "boolean-functions.html", lecture: 12, module: "boolean", mark: "f₂",
      title: "Булевы функции",
      blurb: "Таблица, вектор, полином Жегалкина, классы Поста, куб и карта.",
      tags: ["АНФ", "Пост", "куб"],
    },
    {
      id: "sat", file: "sat.html", lecture: 12, module: "boolean", mark: "SAT",
      title: "SAT и DPLL",
      blurb: "CNF, трасса DPLL, решения, пропагации, конфликты и готовые задачи.",
      tags: ["CNF", "DPLL", "конфликт"],
    },
    {
      id: "minimization", file: "minimization.html", lecture: 13, module: "boolean", mark: "K",
      title: "Карта Карно",
      blurb: "Простые импликанты и точный минимум ДНФ с безразличными наборами.",
      tags: ["Карно", "импликанты", "минимум"],
    },
    {
      id: "bdd", file: "bdd.html", lecture: 13, module: "boolean", mark: "BDD",
      title: "Диаграммы решений",
      blurb: "ROBDD, склейка поддиаграмм и цена порядка переменных.",
      tags: ["ROBDD", "порядок", "склейка"],
    },
    {
      id: "circuits", file: "circuits.html", lecture: 14, module: "boolean", mark: "∧",
      title: "Схемы",
      blurb: "Вентили, размер, глубина, таблица истинности и проверка против эталона.",
      tags: ["вентили", "глубина", "митер"],
    },
    {
      id: "hamming", file: "hamming.html", lecture: 15, module: "codes", mark: "7,4",
      title: "Код Хэмминга",
      blurb: "Проверочные биты, синдром, позиция ошибки и исправление.",
      tags: ["синдром", "H", "ошибка"],
    },
    {
      id: "huffman", file: "huffman.html", lecture: 16, module: "codes", mark: "H",
      title: "Дерево Хаффмана",
      blurb: "Жадное слияние, коды, средняя длина и энтропия.",
      tags: ["префиксный", "L", "энтропия"],
    },
  ];

  const byId = new Map(labs.map((lab) => [lab.id, lab]));

  function moduleOf(id) {
    return modules.find((module) => module.id === id) || modules[0];
  }

  function lecturesOf(moduleId) {
    return lectures.filter((lecture) => lecture.module === moduleId);
  }

  function labsOfLecture(num) {
    const lecture = lectures.find((item) => item.num === num);
    return lecture ? lecture.labs.map((id) => byId.get(id)).filter(Boolean) : [];
  }

  window.LAB_CATALOG = {
    semester: "Осень 2026",
    modules,
    lectures,
    labs,
    byId,
    moduleOf,
    lecturesOf,
    labsOfLecture,
  };
})();

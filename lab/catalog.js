/* Catalog of the discrete-mathematics lab stand. */
(function () {
  "use strict";

  const modules = [
    {
      id: "structures",
      name: "Отношения и структуры",
      short: "Структуры",
      accent: "#6a4c93",
      soft: "#efe9f7",
      blurb: "Матрица отношения превращается в граф, классы, замыкания и диаграмму покрытий.",
    },
    {
      id: "infinity",
      name: "Множества и бесконечность",
      short: "Бесконечность",
      accent: "#2d5fa8",
      soft: "#e8f0fb",
      blurb: "Биекции, которые переселяют гостей и пересчитывают бесконечные множества.",
    },
    {
      id: "logic",
      name: "Логика и вывод",
      short: "Логика",
      accent: "#2f7d5c",
      soft: "#e6f2ec",
      blurb: "Вывод собирают: правило, ссылки и подвывод проверяются по шагам.",
    },
    {
      id: "boolean",
      name: "Булевы функции",
      short: "Булевы",
      accent: "#b45309",
      soft: "#fbf0dc",
      blurb: "Минимизация, диаграммы решений и SAT: одна функция, разные представления и цена.",
    },
    {
      id: "codes",
      name: "Коды и сжатие",
      short: "Коды",
      accent: "#0f766e",
      soft: "#e3f4f1",
      blurb: "Ошибка, синдром и префиксное дерево: видно, как код находит ошибку и исправляет её.",
    },
  ];

  const labs = [
    {
      id: "relations", file: "relations.html?v=2", module: "structures", mark: "R",
      topic: "Отношения",
      title: "Замкни отношение",
      blurb: "Щёлкайте пары в матрице и применяйте замыкания. Рядом меняются граф, свойства, классы эквивалентности и фактор.",
      tags: ["матрица", "замыкание", "фактор"],
    },
    {
      id: "order", file: "order.html", module: "structures", mark: "≤",
      topic: "Порядок",
      title: "Построй диаграмму Хассе",
      blurb: "Задайте отношение и получите диаграмму покрытий. Выбирайте подмножество и ищите минимумы, максимумы, границы и цепи.",
      tags: ["Хассе", "границы", "цепи"],
    },
    {
      id: "cardinality", file: "cardinality.html?v=4", module: "infinity", mark: "ℵ₀",
      topic: "Мощность",
      title: "Рассели бесконечность",
      blurb: "Переселяйте гостей, запускайте бесконечные автобусы, нумеруйте целые и ловите диагональ Кантора.",
      tags: ["биекция", "N×N", "диагональ"],
    },
    {
      id: "deduction", file: "deduction.html?v=5", module: "logic", mark: "⊢",
      topic: "Натуральная дедукция",
      title: "Собери вывод",
      blurb: "Строка за строкой собирайте вывод: выбирайте правило, ссылайтесь на номера, открывайте подвывод. Проверка ловит неверный шаг.",
      tags: ["Фитч", "правила", "подвывод"],
    },
    {
      id: "sat", file: "sat.html?v=2", module: "boolean", mark: "SAT",
      topic: "SAT",
      title: "Прокрути DPLL",
      blurb: "Введите CNF и пройдите DPLL: решения, юнит-пропагация, конфликт, откат. Счётчики показывают цену поиска.",
      tags: ["CNF", "DPLL", "откат"],
    },
    {
      id: "minimization", file: "minimization.html", module: "boolean", mark: "K",
      topic: "Минимизация",
      title: "Сожми карту Карно",
      blurb: "Расставьте единицы и безразличные наборы, получите простые импликанты и точный минимум ДНФ.",
      tags: ["Карно", "импликанты", "минимум"],
    },
    {
      id: "bdd", file: "bdd.html", module: "boolean", mark: "BDD",
      topic: "Диаграммы решений",
      title: "Сравни порядки ROBDD",
      blurb: "Меняйте порядок переменных и наблюдайте, как число узлов падает или взрывается при той же функции.",
      tags: ["ROBDD", "порядок", "узлы"],
    },
    {
      id: "hamming", file: "hamming.html", module: "codes", mark: "7,4",
      topic: "Коды Хэмминга",
      title: "Поймай ошибку Хэмминга",
      blurb: "Соберите кодовое слово, переверните бит и восстановите позицию по синдрому.",
      tags: ["синдром", "H", "исправление"],
    },
    {
      id: "huffman", file: "huffman.html?v=2", module: "codes", mark: "H",
      topic: "Сжатие",
      title: "Построй дерево Хаффмана",
      blurb: "Задайте частоты, разберите жадные слияния, получите коды и сравните среднюю длину с энтропией.",
      tags: ["жадность", "коды", "энтропия"],
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

/* Catalog of the discrete-mathematics lab stand. */

export interface ModuleEntry {
  id: string;
  name: string;
  short: string;
  accent: string;
  soft: string;
  blurb: string;
}

export interface LabEntry {
  id: string;
  file: string;
  module: string;
  mark: string;
  topic: string;
  title: string;
  blurb: string;
  tags: string[];
  top?: boolean;
}

export interface Catalog {
  modules: ModuleEntry[];
  labs: LabEntry[];
  byId: Map<string, LabEntry>;
  moduleOf(id: string): ModuleEntry;
  labsOf(moduleId: string): LabEntry[];
}

const modules: ModuleEntry[] = [
  {
    id: "structures",
    name: "Отношения и структуры",
    short: "Структуры",
    accent: "#6a4c93",
    soft: "#efe9f7",
    blurb: "Матрица, граф, замыкания и классы: одно отношение в нескольких представлениях.",
  },
  {
    id: "infinity",
    name: "Множества и бесконечность",
    short: "Бесконечность",
    accent: "#2d5fa8",
    soft: "#e8f0fb",
    blurb: "Отель Гильберта, нумерация целых и диагональ Кантора: от счётного к несчётному.",
  },
  {
    id: "logic",
    name: "Логика и вывод",
    short: "Логика",
    accent: "#2b7355",
    soft: "#e6f2ec",
    blurb: "Логика высказываний и предикатов: таблицы истинности, вывод, модели и контрпримеры.",
  },
  {
    id: "boolean",
    name: "Булевы функции",
    short: "Булевы",
    accent: "#b45309",
    soft: "#fbf0dc",
    blurb: "Одна функция в разных представлениях, DPLL и цена поиска: таблица, полином, карта Карно, ROBDD.",
  },
  {
    id: "codes",
    name: "Коды и сжатие",
    short: "Коды",
    accent: "#0f766e",
    soft: "#e3f4f1",
    blurb: "Код Хэмминга исправляет ошибку, код Хаффмана сжимает: синдром, дерево, энтропия.",
  },
];

const labs: LabEntry[] = [
  {
    id: "relations",
    file: "relations.html",
    module: "structures",
    mark: "R",
    topic: "Отношения",
    title: "Замыкания отношения",
    blurb: "Матрица и граф одного отношения. Замыкания, свойства, классы эквивалентности и фактор-множество.",
    tags: ["матрица", "замыкания", "фактор"],
  },
  {
    id: "order",
    file: "order.html",
    module: "structures",
    mark: "≤",
    topic: "Порядок",
    title: "Порядок, границы и цепи",
    blurb: "Отношение порядка, диаграмма покрытий, границы и линейное продолжение на маленьком множестве.",
    tags: ["Хассе", "границы", "цепи"],
  },
  {
    id: "functions",
    file: "functions.html",
    module: "structures",
    mark: "→",
    topic: "Функции",
    title: "Отображение и свойства",
    blurb: "Домен, кодомен и стрелки. Инъекция, сюръекция и биекция проверяются на месте.",
    tags: ["инъекция", "сюръекция", "биекция"],
  },
  {
    id: "sets",
    file: "sets.html",
    module: "infinity",
    mark: "∪",
    topic: "Множества",
    title: "Операции и диаграммы Венна",
    blurb: "Элементы, операции, диаграммы Венна, тождества и булеан на одном рабочем поле.",
    tags: ["Венн", "тождества", "булеан"],
  },
  {
    id: "cardinality",
    file: "cardinality.html",
    module: "infinity",
    mark: "ℵ₀",
    top: true,
    topic: "Мощность",
    title: "Отель Гильберта",
    blurb: "Один гость, конечная группа, бесконечный автобус и диагональ Кантора. На каждом шаге видна биекция.",
    tags: ["биекция", "N×N", "диагональ"],
  },
  {
    id: "statements",
    file: "statements.html",
    module: "logic",
    mark: "¬",
    topic: "Высказывания",
    title: "Формула и дерево разбора",
    blurb: "Таблица истинности, дерево разбора и проверка законов: связки в одном окне.",
    tags: ["таблица", "дерево", "закон"],
  },
  {
    id: "fol",
    file: "fol.html",
    module: "logic",
    mark: "∀",
    topic: "Логика первого порядка",
    title: "Модель и кванторы",
    blurb: "Предикаты, свободные переменные и порядок кванторов на конечной модели.",
    tags: ["FOL", "кванторы", "модель"],
  },
  {
    id: "deduction",
    file: "deduction.html",
    module: "logic",
    mark: "⊢",
    topic: "Натуральная дедукция",
    title: "Вывод в стиле Фитча",
    blurb: "Вывод из посылок к цели: правила, ссылки и подвыводы. Проверка каждого шага идёт сразу.",
    tags: ["Фитч", "правила", "подвывод"],
  },
  {
    id: "semantics",
    file: "semantics.html",
    module: "logic",
    mark: "⊨",
    topic: "Семантика",
    title: "Модели и следствие",
    blurb: "Посылки, заключение и контрпример. Таблица перебирает модели и показывает, где следствие ломается.",
    tags: ["⊨", "модель", "контрпример"],
  },
  {
    id: "boolean-functions",
    file: "boolean-functions.html",
    module: "boolean",
    mark: "f",
    top: true,
    topic: "Булевы функции",
    title: "Одна функция, четыре взгляда",
    blurb: "Таблица, вектор, полином Жегалкина и классы Поста для одной функции.",
    tags: ["таблица", "Жегалкин", "Пост"],
  },
  {
    id: "minimization",
    file: "minimization.html",
    module: "boolean",
    mark: "K",
    top: true,
    topic: "Минимизация",
    title: "Карта Карно",
    blurb: "До пяти переменных, безразличные наборы, простые импликанты и точный минимум ДНФ или КНФ.",
    tags: ["Карно", "импликанты", "минимум"],
  },
  {
    id: "bdd",
    file: "bdd.html",
    module: "boolean",
    mark: "BDD",
    top: true,
    topic: "Диаграммы решений",
    title: "Порядок переменных в ROBDD",
    blurb: "Одна функция при разных порядках переменных. Число узлов меняется, каноничность остаётся.",
    tags: ["ROBDD", "порядок", "каноничность"],
  },
  {
    id: "sat",
    file: "sat.html",
    module: "boolean",
    mark: "SAT",
    top: true,
    topic: "SAT",
    title: "DPLL по шагам",
    blurb: "CNF, юнит-пропагация, конфликт и откат. Трасса и счётчики показывают цену поиска.",
    tags: ["CNF", "DPLL", "откат"],
  },
  {
    id: "hamming",
    file: "hamming.html",
    module: "codes",
    mark: "7,4",
    top: true,
    topic: "Коды Хэмминга",
    title: "Синдром Хэмминга",
    blurb: "Информационные и проверочные биты, синдром. Одна ошибка исправляется, две обнаруживаются.",
    tags: ["синдром", "7,4", "исправление"],
  },
  {
    id: "huffman",
    file: "huffman.html",
    module: "codes",
    mark: "H",
    topic: "Сжатие",
    title: "Дерево Хаффмана",
    blurb: "Жадные слияния, коды, средняя длина и энтропия. Видно, сколько стоит префиксный код.",
    tags: ["жадность", "префикс", "энтропия"],
  },
];

const byId = new Map(labs.map((lab) => [lab.id, lab]));

export const catalog: Catalog = {
  modules,
  labs,
  byId,
  moduleOf(id) {
    return modules.find((module) => module.id === id) || modules[0];
  },
  labsOf(moduleId) {
    return labs.filter((lab) => lab.module === moduleId);
  },
};

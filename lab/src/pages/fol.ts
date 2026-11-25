import { clear, el, keepFocus, must, status, svg } from "../core/dom";
import { pointToward } from "../core/graph";
import { math } from "../core/math";
import { ribbon } from "../core/segmented";
import * as FOL from "../domain/fol";

type ScenarioName = "witness" | "counter" | "order";

interface Scenario {
  formula: string;
  p: number[];
  q: number[];
  r: Array<[number, number]>;
}

const INITIAL_FORMULA = "∀x ∃y R(x, y)";
const SCENARIOS: Record<ScenarioName, Scenario> = {
  witness: { formula: "∃x P(x)", p: [2], q: [], r: [] },
  counter: { formula: "∀x P(x)", p: [1, 2], q: [1], r: [] },
  order: {
    formula: "∀x ∃y R(x, y)",
    p: [1],
    q: [1, 2],
    r: [
      [1, 1],
      [2, 2],
      [3, 1],
    ],
  },
};
const EXAMPLES: Array<{ name: string; formula: string }> = [
  { name: "импликация", formula: "∀x (P(x) → Q(x))" },
  { name: "контрпример", formula: "∃x (P(x) ∧ ¬Q(x))" },
  { name: "свой y", formula: "∀x ∃y R(x, y)" },
  { name: "общий y", formula: "∃y ∀x R(x, y)" },
  { name: "де Морган", formula: "¬∀x P(x) ↔ ∃x ¬P(x)" },
];

let n = 3;
let model = FOL.initialModel(n);
model.preds.P = new Set([1]);
model.preds.Q = new Set([1, 2]);
model.preds.R = new Set(["1,1", "2,2", "3,1"]);
let ast: FOL.Formula | null = null;

const domainSizeNode = must<HTMLElement>("#domain-size");
const domainNode = must<HTMLElement>("#domain");
const countsNode = must<HTMLElement>("#counts");
const rMatrix = must<HTMLElement>("#r-matrix");
const rGraph = must<HTMLElement>("#r-graph");
const rCaption = must<HTMLElement>("#r-caption");
const formulaInput = must<HTMLInputElement>("#formula-input");
const formulaForm = must<HTMLFormElement>("#formula-form");
const formulaTex = must<HTMLElement>("#formula-tex");
const formulaKind = must<HTMLElement>("#formula-kind");
const verdict = must<HTMLElement>("#verdict");
const rowsNode = must<HTMLElement>("#rows");
const presetsNode = must<HTMLElement>("#presets");
const orderLeft = must<HTMLElement>("#order-left");
const orderRight = must<HTMLElement>("#order-right");
const orderLeftStatus = must<HTMLElement>("#order-left-status");
const orderRightStatus = must<HTMLElement>("#order-right-status");
const orderLeftWhy = must<HTMLElement>("#order-left-why");
const orderRightWhy = must<HTMLElement>("#order-right-why");
const orderMap = must<HTMLElement>("#order-map");
const orderMapNote = must<HTMLElement>("#order-map-note");
const orderVerdict = must<HTMLElement>("#order-verdict");
const scenariosNode = must<HTMLElement>("#scenarios");

const domainSize = ribbon(
  domainSizeNode,
  [
    { value: "2", label: "2" },
    { value: "3", label: "3" },
    { value: "4", label: "4" },
    { value: "5", label: "5" },
  ],
  "3",
  (value) => {
    n = Number(value);
    model = FOL.initialModel(n);
    setScenarioActive(null);
    renderAll();
  },
);

function setScenarioActive(name: ScenarioName | null): void {
  for (const button of scenariosNode.querySelectorAll<HTMLButtonElement>("button[data-scenario]")) {
    button.classList.toggle("is-active", button.dataset.scenario === name);
  }
}

function refreshCounts(): void {
  countsNode.replaceChildren(
    el("span", { text: "|P| = " + model.preds.P.size }),
    el("span", { text: "|Q| = " + model.preds.Q.size }),
  );
}

function togglePredicate(name: "P" | "Q", value: number): void {
  const set = model.preds[name];
  if (set.has(value)) set.delete(value);
  else set.add(value);
  setScenarioActive(null);
  renderAll();
}

function renderDomain(): void {
  clear(domainNode);
  for (const value of model.domain) {
    const tile = el("div", { class: "fol-element" });
    tile.appendChild(el("span", { class: "fol-element-index", text: String(value) }));
    const preds = el("div", { class: "fol-preds" });
    for (const name of ["P", "Q"] as const) {
      const active = model.preds[name].has(value);
      const button = el("button", {
        class: "fol-pred " + name.toLowerCase() + (active ? " on" : ""),
        type: "button",
        text: name,
        "aria-pressed": String(active),
        "aria-label": "Предикат " + name + " на элементе " + value + (active ? ", включён" : ", выключен"),
        "data-focus-key": "fol-" + name + "-" + value,
      });
      button.addEventListener("click", () => togglePredicate(name, value));
      preds.appendChild(button);
    }
    tile.appendChild(preds);
    domainNode.appendChild(tile);
  }
  refreshCounts();
}

function renderRMatrix(): void {
  clear(rMatrix);
  const table = el("table", { class: "fol-r-table" });
  table.appendChild(el("caption", { class: "sr-only", text: "Отношение R: строка x, столбец y" }));
  const head = el("tr");
  head.appendChild(el("th", { scope: "col", text: "" }));
  for (const y of model.domain) head.appendChild(el("th", { scope: "col", text: "y=" + y }));
  const thead = el("thead");
  thead.appendChild(head);
  table.appendChild(thead);

  const body = el("tbody");
  for (const x of model.domain) {
    const tr = el("tr");
    tr.appendChild(el("th", { scope: "row", text: "x=" + x }));
    for (const y of model.domain) {
      const key = x + "," + y;
      const on = model.preds.R.has(key);
      const button = el("button", {
        type: "button",
        class: "fol-r-cell" + (on ? " on" : "") + (x === y ? " diag" : ""),
        text: on ? "1" : "0",
        "aria-pressed": String(on),
        "aria-label": "R(" + x + "," + y + ")" + (on ? ", есть" : ", нет"),
        "data-focus-key": "fol-R-" + key,
      });
      button.addEventListener("click", () => {
        if (model.preds.R.has(key)) model.preds.R.delete(key);
        else model.preds.R.add(key);
        setScenarioActive(null);
        renderAll();
      });
      tr.appendChild(el("td", null, button));
    }
    body.appendChild(tr);
  }
  table.appendChild(body);
  rMatrix.appendChild(table);
}

function renderRGraph(): void {
  clear(rGraph);
  const width = 460;
  const height = 320;
  const cx = width / 2;
  const cy = 180;
  const radius = n === 2 ? 95 : 90;
  const coords = model.domain.map((_value, index) => {
    const angle = -Math.PI / 2 + (2 * Math.PI * index) / n;
    return { x: cx + radius * Math.cos(angle), y: cy + radius * Math.sin(angle) };
  });

  const root = svg("svg", {
    viewBox: "0 0 " + width + " " + height,
    role: "img",
    "aria-label": "Граф отношения R",
    class: "fol-r-graph-svg",
  });
  const edgeGap = 30;
  const defs = svg("defs");
  const marker = svg("marker", {
    id: "fol-arrow",
    viewBox: "0 0 10 10",
    refX: "9",
    refY: "5",
    markerWidth: "7",
    markerHeight: "7",
    orient: "auto-start-reverse",
  });
  marker.appendChild(svg("path", { d: "M 0 0 L 10 5 L 0 10 z", class: "fol-arrow-head" }));
  defs.appendChild(marker);
  root.appendChild(defs);

  for (let i = 0; i < n; i++) {
    for (let j = 0; j < n; j++) {
      if (!model.preds.R.has(model.domain[i] + "," + model.domain[j])) continue;
      const a = coords[i];
      const b = coords[j];
      if (i === j) {
        root.appendChild(
          svg("path", {
            d:
              "M " +
              (a.x - 15) +
              " " +
              (a.y - 26) +
              " C " +
              (a.x - 45) +
              " " +
              (a.y - 70) +
              ", " +
              (a.x + 45) +
              " " +
              (a.y - 70) +
              ", " +
              (a.x + 15) +
              " " +
              (a.y - 26),
            fill: "none",
            class: "fol-edge fol-loop",
            "marker-end": "url(#fol-arrow)",
          }),
        );
        continue;
      }
      const mutual = i < j && model.preds.R.has(model.domain[j] + "," + model.domain[i]);
      if (mutual) {
        const mx = (a.x + b.x) / 2;
        const my = (a.y + b.y) / 2;
        const dx = b.x - a.x;
        const dy = b.y - a.y;
        const len = Math.hypot(dx, dy) || 1;
        const ox = (-dy / len) * 20;
        const oy = (dx / len) * 20;
        const firstControl = { x: mx + ox, y: my + oy };
        const secondControl = { x: mx - ox, y: my - oy };
        const firstStart = pointToward(a, firstControl, edgeGap);
        const firstEnd = pointToward(b, firstControl, edgeGap);
        const secondStart = pointToward(b, secondControl, edgeGap);
        const secondEnd = pointToward(a, secondControl, edgeGap);
        root.appendChild(
          svg("path", {
            d:
              "M " +
              firstStart.x +
              " " +
              firstStart.y +
              " Q " +
              firstControl.x +
              " " +
              firstControl.y +
              " " +
              firstEnd.x +
              " " +
              firstEnd.y,
            fill: "none",
            class: "fol-edge",
            "marker-end": "url(#fol-arrow)",
          }),
        );
        root.appendChild(
          svg("path", {
            d:
              "M " +
              secondStart.x +
              " " +
              secondStart.y +
              " Q " +
              secondControl.x +
              " " +
              secondControl.y +
              " " +
              secondEnd.x +
              " " +
              secondEnd.y,
            fill: "none",
            class: "fol-edge",
            "marker-end": "url(#fol-arrow)",
          }),
        );
      } else {
        const start = pointToward(a, b, edgeGap);
        const end = pointToward(b, a, edgeGap);
        root.appendChild(
          svg("line", {
            x1: start.x,
            y1: start.y,
            x2: end.x,
            y2: end.y,
            class: "fol-edge",
            "marker-end": "url(#fol-arrow)",
          }),
        );
      }
    }
  }

  for (let i = 0; i < n; i++) {
    const p = coords[i];
    root.appendChild(svg("circle", { cx: p.x, cy: p.y, r: 24, class: "fol-gnode" }));
    root.appendChild(
      svg(
        "text",
        {
          x: p.x,
          y: p.y + 5,
          "text-anchor": "middle",
          class: "fol-glabel",
        },
        String(model.domain[i]),
      ),
    );
  }
  rGraph.appendChild(root);
}

function renderRCaption(): void {
  const pairs: string[] = [];
  for (const x of model.domain) {
    for (const y of model.domain) {
      if (model.preds.R.has(x + "," + y)) pairs.push("(" + x + "," + y + ")");
    }
  }
  rCaption.textContent = pairs.length ? "R = {" + pairs.join(", ") + "}" : "R = ∅";
}

function renderR(): void {
  renderRMatrix();
  renderRGraph();
  renderRCaption();
}

function setFormula(text: string): void {
  formulaInput.value = text;
  setScenarioActive(null);
  try {
    const parsed = FOL.parse(text);
    const free = FOL.freeVars(parsed);
    if (free.size) throw new Error("Свободные переменные: " + Array.from(free).join(", "));
    ast = parsed;
    formulaKind.textContent = "замкнутая";
    formulaKind.className = "pill info";
    formulaTex.classList.remove("is-error");
    formulaTex.replaceChildren(math(FOL.toTex(parsed), false));
    renderFormula();
  } catch (error) {
    ast = null;
    formulaKind.textContent = "ошибка";
    formulaKind.className = "pill no";
    formulaTex.classList.add("is-error");
    formulaTex.textContent = text;
    status(verdict, error instanceof Error ? error.message : String(error), "bad");
    clear(rowsNode);
  }
}

function renderFormula(): void {
  const formula = ast;
  if (!formula) return;
  const value = FOL.evalFormula(formula, {}, model);
  status(verdict, value ? "Истина в этой модели." : "Ложь в этой модели.", value ? "ok" : "bad");
  clear(rowsNode);
  if (formula.type !== "forall" && formula.type !== "exists") {
    rowsNode.appendChild(
      el("div", { class: "fol-trace-empty" }, [
        el("b", { text: "Верхний квантор не один" }),
        el("p", { class: "fol-why", text: "Значение вычислено по всему дереву формулы." }),
      ]),
    );
    return;
  }
  const rows = FOL.quantifierRows(formula, model) ?? [];
  let picked: number | null = null;
  if (formula.type === "exists") picked = rows.find((row) => row.truth)?.value ?? null;
  else picked = rows.find((row) => !row.truth)?.value ?? null;

  const head = el("div", { class: "fol-trace-head" }, [
    el("span", { text: "переменная " + formula.variable }),
    el("span", { text: "тело" }),
  ]);
  const strip = el("div", { class: "fol-witness-row" });
  for (const row of rows) {
    const chip = el("div", {
      class: "fol-witness-chip " + (row.truth ? "yes" : "no") + (row.value === picked ? " is-picked" : ""),
      "aria-label": formula.variable + " = " + row.value + ", тело " + (row.truth ? "истинно" : "ложно"),
    });
    chip.appendChild(el("span", { class: "fol-witness-index", text: String(row.value) }));
    chip.appendChild(el("span", { class: "fol-witness-truth", text: row.truth ? "1" : "0" }));
    strip.appendChild(chip);
  }
  rowsNode.appendChild(head);
  rowsNode.appendChild(strip);

  let why: string;
  if (formula.type === "forall") {
    const bad = rows.find((row) => !row.truth);
    why = bad ? "Контрпример: " + formula.variable + " = " + bad.value + "." : "Все элементы дают 1.";
  } else {
    const good = rows.find((row) => row.truth);
    why = good ? "Свидетель: " + formula.variable + " = " + good.value + "." : "Свидетеля нет: все значения 0.";
  }
  rowsNode.appendChild(el("p", { class: "fol-why", text: why }));
}

function renderOrder(): void {
  const leftAst = FOL.parse("∀x ∃y R(x, y)");
  const rightAst = FOL.parse("∃y ∀x R(x, y)");
  const left = FOL.evalFormula(leftAst, {}, model);
  const right = FOL.evalFormula(rightAst, {}, model);

  const rows = model.domain.map((x) => ({
    x,
    witness: model.domain.find((y) => model.preds.R.has(x + "," + y)) ?? null,
  }));
  const columns = model.domain.map((y) => ({
    y,
    full: model.domain.every((x) => model.preds.R.has(x + "," + y)),
  }));
  const emptyRows = rows.filter((row) => row.witness === null).map((row) => row.x);
  const fullColumns = columns.filter((column) => column.full).map((column) => column.y);

  orderLeft.replaceChildren(math(FOL.toTex(leftAst), false));
  orderRight.replaceChildren(math(FOL.toTex(rightAst), false));
  status(orderLeftStatus, left ? "Истина на этой модели." : "Ложь на этой модели.", left ? "ok" : "bad");
  status(orderRightStatus, right ? "Истина на этой модели." : "Ложь на этой модели.", right ? "ok" : "bad");
  orderLeftWhy.textContent = emptyRows.length
    ? "Пустая строка: x = " + emptyRows.join(", ") + "."
    : "В каждой строке есть хотя бы одна 1.";
  orderRightWhy.textContent = fullColumns.length
    ? "Общий столбец: y = " + fullColumns.join(", ") + "."
    : "Нет столбца, заполненного единицами целиком.";

  const table = el("table", { class: "fol-order-table", "aria-label": "Карта свидетелей для двух формул" });
  const head = el("tr");
  head.appendChild(el("th", { scope: "col", text: "" }));
  for (const column of columns) head.appendChild(el("th", { scope: "col", text: "y=" + column.y }));
  head.appendChild(el("th", { scope: "col", class: "fol-order-badge-head", text: "∃y" }));
  const thead = el("thead");
  thead.appendChild(head);
  table.appendChild(thead);

  const body = el("tbody");
  for (const row of rows) {
    const tr = el("tr");
    tr.appendChild(el("th", { scope: "row", text: "x=" + row.x }));
    for (const column of columns) {
      const on = model.preds.R.has(row.x + "," + column.y);
      const classes = ["fol-order-cell"];
      if (on) classes.push("on");
      if (row.witness === column.y) classes.push("is-witness");
      if (column.full) classes.push("is-universal");
      const cell = el("td", {
        class: classes.join(" "),
        "aria-label": "R(" + row.x + "," + column.y + ") = " + (on ? 1 : 0),
      });
      cell.appendChild(el("span", { text: on ? "1" : "0" }));
      tr.appendChild(cell);
    }
    const badge = el("td", {
      class: "fol-order-badge " + (row.witness === null ? "no" : "ok"),
      "aria-label":
        "Строка x = " + row.x + (row.witness === null ? " без свидетеля" : ", свидетель y = " + row.witness),
      text: row.witness === null ? "0" : "1",
    });
    tr.appendChild(badge);
    body.appendChild(tr);
  }
  table.appendChild(body);

  const foot = el("tr");
  foot.appendChild(el("th", { scope: "row", text: "∀x" }));
  for (const column of columns) {
    foot.appendChild(
      el("td", {
        class: "fol-order-badge " + (column.full ? "ok" : "no"),
        "aria-label": "Столбец y = " + column.y + (column.full ? " общий для всех x" : " не общий"),
        text: column.full ? "1" : "0",
      }),
    );
  }
  foot.appendChild(el("td", { class: "fol-order-badge-head", text: "" }));
  const tfoot = el("tfoot");
  tfoot.appendChild(foot);
  table.appendChild(tfoot);
  orderMap.replaceChildren(table);
  orderMapNote.textContent =
    "Строки это x, столбцы это y. Подсвеченная клетка входит в общий столбец, обводка отмечает выбранного свидетеля строки.";

  if (left && right) {
    status(orderVerdict, "Общий y существует, поэтому обе формулы истинны. Порядок не мешает.", "ok");
  } else if (left) {
    status(
      orderVerdict,
      "Слева у каждого x есть свой y. Справа одного общего y нет, поэтому формулы не равносильны.",
      "warn",
    );
  } else {
    status(orderVerdict, "Слева есть строка без единого y. Общего y тогда быть не может, и обе формулы ложны.", "bad");
  }
}

function paint(): void {
  renderDomain();
  renderR();
  renderFormula();
  renderOrder();
}

function renderAll(): void {
  keepFocus(paint);
}

function applyScenario(name: ScenarioName): void {
  const scenario = SCENARIOS[name];
  n = 3;
  domainSize.set("3");
  model = FOL.initialModel(n);
  model.preds.P = new Set(scenario.p);
  model.preds.Q = new Set(scenario.q);
  model.preds.R = new Set(scenario.r.map(([x, y]) => x + "," + y));
  setFormula(scenario.formula);
  renderAll();
  setScenarioActive(name);
}

scenariosNode.addEventListener("click", (event) => {
  if (!(event.target instanceof Element)) return;
  const button = event.target.closest<HTMLButtonElement>("button[data-scenario]");
  const name = button?.dataset.scenario;
  if (name === "witness" || name === "counter" || name === "order") applyScenario(name);
});

formulaForm.addEventListener("submit", (event) => {
  event.preventDefault();
  setFormula(formulaInput.value);
});

for (const example of EXAMPLES) {
  const button = el("button", { type: "button", class: "fol-preset", title: example.formula });
  button.appendChild(el("span", { class: "fol-preset-name", text: example.name }));
  button.appendChild(el("span", { class: "fol-preset-formula", text: example.formula }));
  button.addEventListener("click", () => setFormula(example.formula));
  presetsNode.appendChild(button);
}

must<HTMLButtonElement>("#random").addEventListener("click", () => {
  model.preds.P = new Set(model.domain.filter(() => Math.random() < 0.5));
  model.preds.Q = new Set(model.domain.filter(() => Math.random() < 0.5));
  model.preds.R = new Set();
  for (const x of model.domain) {
    for (const y of model.domain) if (Math.random() < 0.35) model.preds.R.add(x + "," + y);
  }
  setScenarioActive(null);
  renderAll();
});

must<HTMLButtonElement>("#reset").addEventListener("click", () => {
  n = 3;
  domainSize.set("3");
  model = FOL.initialModel(n);
  model.preds.P = new Set([1]);
  model.preds.Q = new Set([1, 2]);
  model.preds.R = new Set(["1,1", "2,2", "3,1"]);
  setFormula(INITIAL_FORMULA);
  renderAll();
});

setFormula(INITIAL_FORMULA);
renderAll();

import { clear, el, keepFocus, must, setPressed, status } from "../core/dom";
import { math } from "../core/math";
import * as FOL from "../domain/fol";

const presets = [
  "∀x (P(x) → Q(x))",
  "∃x (P(x) ∧ ¬Q(x))",
  "∀x P(x) → ∃x P(x)",
  "∀x ∃y R(x, y)",
  "∃y ∀x R(x, y)",
  "∃x ∀y R(x, y) → ∀y ∃x R(x, y)",
  "¬∀x P(x) ↔ ∃x ¬P(x)",
];

let n = 3;
let model = FOL.initialModel(n);
model.preds.P = new Set([1]);
model.preds.Q = new Set([1, 2]);
model.preds.R = new Set(["1,1", "2,2", "3,1"]);

let ast: FOL.Formula | null = null;

const domainSelect = must<HTMLSelectElement>("#domain-size");
const presetSelect = must<HTMLSelectElement>("#preset");
const pGrid = must<HTMLElement>("#p-grid");
const qGrid = must<HTMLElement>("#q-grid");
const rMatrix = must<HTMLElement>("#r-matrix");
const formulaTex = must<HTMLElement>("#formula-tex");
const verdict = must<HTMLElement>("#verdict");
const rowsNode = must<HTMLElement>("#rows");
const orderLeft = must<HTMLElement>("#order-left");
const orderRight = must<HTMLElement>("#order-right");
const orderLeftStatus = must<HTMLElement>("#order-left-status");
const orderRightStatus = must<HTMLElement>("#order-right-status");
const orderVerdict = must<HTMLElement>("#order-verdict");
const pSize = must<HTMLElement>("#p-size");
const qSize = must<HTMLElement>("#q-size");

for (const text of presets) presetSelect.appendChild(el("option", { value: text, text }));

function toggleSet(name: "P" | "Q", value: number): void {
  const set = model.preds[name];
  if (set.has(value)) set.delete(value); else set.add(value);
  renderAll();
}

function renderGrid(node: HTMLElement, name: "P" | "Q"): void {
  clear(node);
  for (const value of model.domain) {
    const active = model.preds[name].has(value);
    const button = el("button", {
      class: "toggle-chip" + (active ? " on" : ""),
      type: "button",
      text: String(value),
      "aria-label": "Элемент " + value + " предиката " + name + (active ? ", выбран" : ", не выбран"),
      "data-focus-key": "fol-" + name + "-" + value,
    });
    setPressed(button, active);
    button.addEventListener("click", () => toggleSet(name, value));
    node.appendChild(button);
  }
  (name === "P" ? pSize : qSize).textContent = "|" + name + "| = " + model.preds[name].size;
}

function renderR(): void {
  clear(rMatrix);
  const table = el("table", { class: "bit-matrix" });
  const head = el("tr");
  head.appendChild(el("th", { text: "" }));
  for (const j of model.domain) head.appendChild(el("th", { text: String(j) }));
  const thead = el("thead");
  thead.appendChild(head);
  table.appendChild(thead);
  const body = el("tbody");
  for (const i of model.domain) {
    const tr = el("tr");
    tr.appendChild(el("th", { text: String(i) }));
    for (const j of model.domain) {
      const td = el("td");
      const key = i + "," + j;
      const button = el("button", {
        type: "button",
        class: model.preds.R.has(key) ? "on" : "",
        text: model.preds.R.has(key) ? "1" : "0",
        "aria-label": "R(" + i + "," + j + ")",
        "data-focus-key": "fol-R-" + key,
      });
      setPressed(button, model.preds.R.has(key));
      button.addEventListener("click", () => {
        if (model.preds.R.has(key)) model.preds.R.delete(key); else model.preds.R.add(key);
        renderAll();
      });
      td.appendChild(button);
      tr.appendChild(td);
    }
    body.appendChild(tr);
  }
  table.appendChild(body);
  rMatrix.appendChild(table);
}

function setFormula(text: string): void {
  presetSelect.value = text;
  try {
    const parsed = FOL.parse(text);
    ast = parsed;
    const free = FOL.freeVars(parsed);
    if (free.size) throw new Error("Свободные переменные: " + Array.from(free).join(", "));
    formulaTex.replaceChildren(math(FOL.toTex(parsed), false));
    renderFormula();
  } catch (error) {
    ast = null;
    formulaTex.textContent = text;
    status(verdict, error instanceof Error ? error.message : String(error), "bad");
    clear(rowsNode);
  }
}

function renderFormula(): void {
  const formula = ast;
  if (!formula) return;
  const value = FOL.evalFormula(formula, {}, model);
  status(verdict, "Значение в модели: " + (value ? "истина" : "ложь") + ".", value ? "ok" : "bad");
  clear(rowsNode);
  if (formula.type !== "forall" && formula.type !== "exists") {
    rowsNode.appendChild(el("p", { class: "hint", text: "Верхний квантор не один. Значение посчитано по всему дереву формулы." }));
    return;
  }
  const rows = FOL.quantifierRows(formula, model);
  if (!rows) return;
  const table = el("table", { class: "data" });
  const head = el("tr");
  head.appendChild(el("th", { text: formula.variable }));
  head.appendChild(el("th", { text: "тело" }));
  const thead = el("thead");
  thead.appendChild(head);
  table.appendChild(thead);
  const body = el("tbody");
  for (const row of rows) {
    const tr = el("tr");
    tr.appendChild(el("td", { class: "mono", text: String(row.value) }));
    tr.appendChild(el("td", { class: "mono" }, math(row.truth ? "1" : "0")));
    body.appendChild(tr);
  }
  table.appendChild(body);
  rowsNode.appendChild(table);
  if (formula.type === "forall") {
    const bad = rows.find((row) => !row.truth);
    rowsNode.appendChild(el("p", { class: "hint", text: bad ? "Контрпример: " + bad.value + "." : "Все элементы удовлетворяют телу." }));
  } else {
    const good = rows.find((row) => row.truth);
    rowsNode.appendChild(el("p", { class: "hint", text: good ? "Свидетель: " + good.value + "." : "Свидетеля нет." }));
  }
}

function renderOrder(): void {
  const leftAst = FOL.parse("∀x ∃y R(x, y)");
  const rightAst = FOL.parse("∃y ∀x R(x, y)");
  const left = FOL.evalFormula(leftAst, {}, model);
  const right = FOL.evalFormula(rightAst, {}, model);
  orderLeft.replaceChildren(math(FOL.toTex(leftAst), false));
  orderRight.replaceChildren(math(FOL.toTex(rightAst), false));
  status(orderLeftStatus, "Значение: " + (left ? "истина" : "ложь"), left ? "ok" : "bad");
  status(orderRightStatus, "Значение: " + (right ? "истина" : "ложь"), right ? "ok" : "bad");
  status(orderVerdict, left === right
    ? "На этой модели значения совпали. Совпадение на одной модели не делает формулы равносильными."
    : "Значения различны. Вторая формула сильнее: она требует один y для всех x.", "warn");
}

function paint(): void {
  renderGrid(pGrid, "P");
  renderGrid(qGrid, "Q");
  renderR();
  renderFormula();
  renderOrder();
}

function renderAll(): void {
  keepFocus(paint);
}

domainSelect.addEventListener("change", () => {
  n = Number(domainSelect.value);
  model = FOL.initialModel(n);
  model.preds.P = new Set([1]);
  model.preds.Q = new Set(FOL.initialModel(n).domain.slice(0, 2));
  model.preds.R = new Set();
  for (const i of model.domain) model.preds.R.add(i + "," + i);
  renderAll();
});

presetSelect.addEventListener("change", () => setFormula(presetSelect.value));

must<HTMLButtonElement>("#random").addEventListener("click", () => {
  model.preds.P = new Set(model.domain.filter(() => Math.random() < 0.5));
  model.preds.Q = new Set(model.domain.filter(() => Math.random() < 0.5));
  model.preds.R = new Set();
  for (const i of model.domain) {
    for (const j of model.domain) if (Math.random() < 0.35) model.preds.R.add(i + "," + j);
  }
  renderAll();
});

must<HTMLButtonElement>("#reset").addEventListener("click", () => {
  n = 3;
  domainSelect.value = "3";
  model = FOL.initialModel(3);
  model.preds.P = new Set([1]);
  model.preds.Q = new Set([1, 2]);
  model.preds.R = new Set(["1,1", "2,2", "3,1"]);
  renderAll();
  setFormula(presets[0]);
});

setFormula(presets[0]);
renderAll();

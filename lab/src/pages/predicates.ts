import { clear, el, keepFocus, must, setPressed, status } from "../core/dom";
import { math } from "../core/math";
import { ribbon } from "../core/segmented";
import * as FOL from "../domain/fol";

const presets: Array<[string, string]> = [
  ["∀x P(x)", "все элементы в P"],
  ["∃x P(x)", "есть элемент в P"],
  ["∀x (P(x) → Q(x))", "P включено в Q"],
  ["∃x (P(x) ∧ ¬Q(x))", "есть элемент P вне Q"],
  ["∀x P(x) → ∃x P(x)", "из всеобщности следует существование"],
  ["¬∀x P(x) ↔ ∃x ¬P(x)", "отрицание всеобщности"],
  ["∀x (P(x) ∨ Q(x))", "каждый попал хотя бы в один предикат"],
];

let n = 3;
let model = FOL.initialModel(n);
let ast: FOL.Formula | null = null;

ribbon(must<HTMLElement>("#domain-size"), [
  { value: "2", label: "2" },
  { value: "3", label: "3" },
  { value: "4", label: "4" },
  { value: "5", label: "5" },
  { value: "6", label: "6" },
], "3", (value) => {
  n = Number(value);
  model = FOL.initialModel(n);
  renderAll();
});
const presetSelect = must<HTMLSelectElement>("#preset");
const pGrid = must<HTMLElement>("#p-grid");
const qGrid = must<HTMLElement>("#q-grid");
const formulaTex = must<HTMLElement>("#formula-tex");
const verdict = must<HTMLElement>("#verdict");
const metrics = must<HTMLElement>("#metrics");
const rowsNode = must<HTMLElement>("#rows");
const negLeft = must<HTMLElement>("#neg-left");
const negRight = must<HTMLElement>("#neg-right");
const negLeftStatus = must<HTMLElement>("#neg-left-status");
const negRightStatus = must<HTMLElement>("#neg-right-status");
const negVerdict = must<HTMLElement>("#neg-verdict");
const pSize = must<HTMLElement>("#p-size");
const qSize = must<HTMLElement>("#q-size");

for (const [formula, note] of presets) {
  presetSelect.appendChild(el("option", { value: formula, text: formula + "  ·  " + note }));
}

function togglePredicate(name: "P" | "Q", value: number): void {
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
      "data-focus-key": "pred-" + name + "-" + value,
    });
    setPressed(button, active);
    button.addEventListener("click", () => togglePredicate(name, value));
    node.appendChild(button);
  }
  (name === "P" ? pSize : qSize).textContent = "|" + name + "| = " + model.preds[name].size;
}

function setFormula(text: string): void {
  presetSelect.value = text;
  try {
    const parsed = FOL.parse(text);
    ast = parsed;
    const free = FOL.freeVars(parsed);
    if (free.size) throw new Error("Свободные переменные: " + Array.from(free).join(", "));
    formulaTex.replaceChildren(math(FOL.toTex(parsed), false));
    status(verdict, "Формула замкнута. Проверяем на домене.", "ok");
    renderFormula();
  } catch (error) {
    ast = null;
    formulaTex.textContent = text;
    status(verdict, error instanceof Error ? error.message : String(error), "bad");
    clear(rowsNode);
    clear(metrics);
  }
}

function renderFormula(): void {
  const formula = ast;
  if (!formula) return;
  const value = FOL.evalFormula(formula, {}, model);
  status(verdict, "Значение в модели: " + (value ? "истина" : "ложь") + ".", value ? "ok" : "bad");
  metrics.innerHTML = "";
  metrics.appendChild(el("div", { class: "metric" }, [el("span", { class: "k", text: "домен" }), el("span", { class: "v", text: String(n) })]));
  metrics.appendChild(el("div", { class: "metric" }, [el("span", { class: "k", text: "P" }), el("span", { class: "v", text: String(model.preds.P.size) })]));
  metrics.appendChild(el("div", { class: "metric" }, [el("span", { class: "k", text: "Q" }), el("span", { class: "v", text: String(model.preds.Q.size) })]));

  clear(rowsNode);
  const rows = FOL.quantifierRows(formula, model);
  if (!rows) {
    rowsNode.appendChild(el("p", { class: "hint", text: "У этой формулы верхний квантор не единственный. Значение уже посчитано полностью." }));
    return;
  }
  const table = el("table", { class: "data" });
  const head = el("tr");
  head.appendChild(el("th", { text: "x" }));
  head.appendChild(el("th", { text: "P(x)" }));
  head.appendChild(el("th", { text: "Q(x)" }));
  head.appendChild(el("th", { text: "тело" }));
  const thead = el("thead");
  thead.appendChild(head);
  table.appendChild(thead);
  const body = el("tbody");
  for (const row of rows) {
    const tr = el("tr");
    tr.appendChild(el("td", { class: "mono", text: String(row.value) }));
    tr.appendChild(el("td", { class: "mono", text: model.preds.P.has(row.value) ? "1" : "0" }));
    tr.appendChild(el("td", { class: "mono", text: model.preds.Q.has(row.value) ? "1" : "0" }));
    tr.appendChild(el("td", { class: "mono" }, math(row.truth ? "1" : "0")));
    body.appendChild(tr);
  }
  table.appendChild(body);
  rowsNode.appendChild(table);

  if (formula.type === "forall") {
    const bad = rows.find((row) => !row.truth);
    rowsNode.appendChild(el("p", { class: "hint", text: bad ? "Контрпример: x = " + bad.value + "." : "Все элементы удовлетворяют телу." }));
  } else if (formula.type === "exists") {
    const good = rows.find((row) => row.truth);
    rowsNode.appendChild(el("p", { class: "hint", text: good ? "Свидетель: x = " + good.value + "." : "Свидетеля нет." }));
  }
}

function renderNegation(): void {
  const leftAst = FOL.parse("¬∀x P(x)");
  const rightAst = FOL.parse("∃x ¬P(x)");
  const left = FOL.evalFormula(leftAst, {}, model);
  const right = FOL.evalFormula(rightAst, {}, model);
  negLeft.replaceChildren(math(FOL.toTex(leftAst), false));
  negRight.replaceChildren(math(FOL.toTex(rightAst), false));
  status(negLeftStatus, "Значение: " + (left ? "истина" : "ложь"), left ? "ok" : "bad");
  status(negRightStatus, "Значение: " + (right ? "истина" : "ложь"), right ? "ok" : "bad");
  status(negVerdict, left === right ? "Значения совпали на этой модели. Равносильность требует совпадения на всех моделях." : "Значения различны: на этой модели формулы не равносильны.", left === right ? "ok" : "bad");
}

function paint(): void {
  renderGrid(pGrid, "P");
  renderGrid(qGrid, "Q");
  renderFormula();
  renderNegation();
}

function renderAll(): void {
  keepFocus(paint);
}

presetSelect.addEventListener("change", () => setFormula(presetSelect.value));

must<HTMLButtonElement>("#random").addEventListener("click", () => {
  model = FOL.initialModel(n);
  model.preds.P = new Set(model.domain.filter(() => Math.random() < 0.55));
  model.preds.Q = new Set(model.domain.filter(() => Math.random() < 0.45));
  renderAll();
});

must<HTMLButtonElement>("#reset").addEventListener("click", () => {
  model = FOL.initialModel(n);
  renderAll();
});

setFormula(presets[2][0]);
renderAll();

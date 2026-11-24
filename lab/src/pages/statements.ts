import { clear, el, must, status, svg } from "../core/dom";
import { math } from "../core/math";
import * as Logic from "../domain/logic";

const presets: Array<[string, string]> = [
  ["A → (B → A)", "тавтология"],
  ["(A ∧ B) → A", "устранение конъюнкции"],
  ["A ∨ ¬A", "исключённое третье"],
  ["A ∧ ¬A", "противоречие"],
  ["A → B", "импликация"],
  ["¬(A ∧ B) ↔ (¬A ∨ ¬B)", "де Морган"],
  ["A ∧ (B ∨ C) ↔ (A ∧ B) ∨ (A ∧ C)", "дистрибутивность"],
];

const lawPresets: Array<[string, string, string]> = [
  ["¬(A ∧ B)", "¬A ∨ ¬B", "де Морган"],
  ["A → B", "¬A ∨ B", "импликация"],
  ["A → B", "¬B → ¬A", "контрапозиция"],
  ["A ∨ (B ∧ C)", "(A ∨ B) ∧ (A ∨ C)", "дистрибутивность"],
];

const formulaInput = must<HTMLInputElement>("#formula");
const formulaTex = must<HTMLElement>("#formula-tex");
const parseStatus = must<HTMLElement>("#parse-status");
const tableNode = must<HTMLElement>("#truth-table");
const classificationNode = must<HTMLElement>("#classification");
const treeNode = must<HTMLElement>("#tree");
const metricsNode = must<HTMLElement>("#metrics");
const presetsNode = must<HTMLElement>("#presets");
const lawLeft = must<HTMLInputElement>("#law-left");
const lawRight = must<HTMLInputElement>("#law-right");
const lawStatus = must<HTMLElement>("#law-status");
const lawTable = must<HTMLElement>("#law-table");
const lawPresetsNode = must<HTMLElement>("#law-presets");

function messageOf(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}

function showError(message: string): void {
  status(parseStatus, message, "bad");
  clear(tableNode);
  clear(treeNode);
  clear(metricsNode);
  status(classificationNode, "Формула не разобрана.", "warn");
  formulaTex.textContent = "...";
}

function renderTable(table: Logic.TruthTable): void {
  clear(tableNode);
  const node = el("table", { class: "data" });
  const head = el("tr");
  for (const name of table.vars) head.appendChild(el("th", { text: name }));
  head.appendChild(el("th", { text: "f" }));
  const thead = el("thead");
  thead.appendChild(head);
  node.appendChild(thead);
  const body = el("tbody");
  for (const row of table.rows) {
    const tr = el("tr", { class: row.value ? "hl" : "" });
    for (const bit of row.bits) tr.appendChild(el("td", { class: "mono", text: String(bit) }));
    const td = el("td", { class: "mono" });
    td.appendChild(math(row.value ? "1" : "0"));
    tr.appendChild(td);
    body.appendChild(tr);
  }
  node.appendChild(body);
  tableNode.appendChild(node);
}

interface PlacedNode extends Logic.FormulaTree {
  children: PlacedNode[];
  depth: number;
  x: number;
  y: number;
}

function layoutTree(ast: Logic.PropAst): { root: PlacedNode; width: number; height: number } {
  function placeTree(source: Logic.FormulaTree, depth: number): PlacedNode {
    return {
      label: source.label,
      children: source.children.map((child) => placeTree(child, depth + 1)),
      depth,
      x: 0,
      y: 0,
    };
  }
  const root = placeTree(Logic.tree(ast), 0);
  const leaves: PlacedNode[] = [];
  let maxDepth = 0;
  function collect(node: PlacedNode, depth: number): void {
    node.depth = depth;
    maxDepth = Math.max(maxDepth, depth);
    if (!node.children.length) leaves.push(node);
    for (const child of node.children) collect(child, depth + 1);
  }
  collect(root, 0);
  const width = Math.max(420, leaves.length * 84 + 80);
  const height = Math.max(220, (maxDepth + 1) * 82 + 50);
  let leafIndex = 0;
  function place(node: PlacedNode): void {
    if (!node.children.length) {
      node.x = 50 + leafIndex * ((width - 100) / Math.max(1, leaves.length - 1));
      leafIndex++;
    } else {
      for (const child of node.children) place(child);
      node.x = node.children.reduce((sum, child) => sum + child.x, 0) / node.children.length;
    }
    node.y = 36 + node.depth * 82;
  }
  place(root);
  return { root, width, height };
}

function renderTree(ast: Logic.PropAst): void {
  clear(treeNode);
  const layout = layoutTree(ast);
  const root = svg("svg", { viewBox: "0 0 " + layout.width + " " + layout.height, role: "img", "aria-label": "Дерево разбора" });
  function edges(node: PlacedNode): void {
    for (const child of node.children) {
      root.appendChild(svg("line", {
        x1: node.x, y1: node.y + 18,
        x2: child.x, y2: child.y - 18,
        stroke: "#b7ae9e", "stroke-width": 1.5,
      }));
      edges(child);
    }
  }
  edges(layout.root);
  function nodes(node: PlacedNode): void {
    const isLeaf = !node.children.length;
    root.appendChild(svg("circle", {
      cx: node.x, cy: node.y, r: 18,
      fill: isLeaf ? "#e8f0fb" : "#ffffff",
      stroke: isLeaf ? "#2d5fa8" : "#7b7366",
      "stroke-width": 1.5,
    }));
    root.appendChild(svg("text", {
      x: node.x, y: node.y + 5,
      "text-anchor": "middle",
      "font-family": "var(--mono)",
      "font-size": isLeaf ? 13 : 16,
      "font-weight": 650,
      fill: "#1d2733",
    }, node.label));
    for (const child of node.children) nodes(child);
  }
  nodes(layout.root);
  treeNode.appendChild(root);
}

function parseFormula(): Logic.PropAst | null {
  try {
    return Logic.parse(formulaInput.value);
  } catch (error) {
    showError(messageOf(error));
    return null;
  }
}

function update(): void {
  const ast = parseFormula();
  if (!ast) return;
  let vars: string[];
  try {
    vars = Logic.allVars(ast);
    if (vars.length > 6) throw new Error("Слишком много переменных для таблицы: " + vars.length + ".");
    const info = Logic.classify(ast, vars);
    status(parseStatus, "Формула разобрана. Переменных: " + vars.length + ".", "ok");
    formulaTex.replaceChildren(math(Logic.toTex(ast), false));
    renderTable(info.table);
    renderTree(ast);
    const total = info.table.rows.length;
    const summary = info.kind === "tautology"
      ? "Тавтология: истинна на всех наборах, всего " + total + "."
      : (info.kind === "contradiction"
        ? "Противоречие: ложно на всех наборах, всего " + total + "."
        : "Выполнима, но не тавтология: истинна на " + info.trueCount + " из " + total + " наборов.");
    status(classificationNode, summary, info.kind === "tautology" ? "ok" : (info.kind === "contradiction" ? "bad" : "warn"));
    metricsNode.innerHTML = "";
    metricsNode.appendChild(el("div", { class: "metric" }, [el("span", { class: "k", text: "переменных" }), el("span", { class: "v", text: String(vars.length) })]));
    metricsNode.appendChild(el("div", { class: "metric" }, [el("span", { class: "k", text: "строк" }), el("span", { class: "v", text: String(info.table.rows.length) })]));
    metricsNode.appendChild(el("div", { class: "metric" }, [el("span", { class: "k", text: "истин" }), el("span", { class: "v", text: String(info.trueCount) })]));
  } catch (error) {
    showError(messageOf(error));
  }
}

function parsePair(): { leftAst: Logic.PropAst; rightAst: Logic.PropAst } | null {
  try {
    return { leftAst: Logic.parse(lawLeft.value), rightAst: Logic.parse(lawRight.value) };
  } catch (error) {
    status(lawStatus, messageOf(error), "bad");
    clear(lawTable);
    return null;
  }
}

function checkLaw(): void {
  const pair = parsePair();
  if (!pair) return;
  const { leftAst, rightAst } = pair;
  const vars = Array.from(new Set(Logic.allVars(leftAst).concat(Logic.allVars(rightAst)))).sort();
  if (vars.length > 6) {
    status(lawStatus, "Слишком много переменных для сравнения.", "bad");
    clear(lawTable);
    return;
  }
  const table = Logic.truthTable(leftAst, vars);
  const rightTable = Logic.truthTable(rightAst, vars);
  let firstBad: { row: Logic.TruthRow; left: boolean; right: boolean } | null = null;
  for (let i = 0; i < table.rows.length; i++) {
    const left = table.rows[i].value;
    const right = rightTable.rows[i].value;
    if (left !== right) { firstBad = { row: table.rows[i], left, right }; break; }
  }
  if (firstBad) {
    const bad = firstBad;
    status(lawStatus, "Не эквивалентны. Контрпример: " + vars.map((name, i) => name + "=" + bad.row.bits[i]).join(", ") + ". Слева " + (bad.left ? 1 : 0) + ", справа " + (bad.right ? 1 : 0) + ".", "bad");
  } else {
    status(lawStatus, "Эквивалентны на всех " + table.rows.length + " наборах.", "ok");
  }
  clear(lawTable);
  const node = el("table", { class: "data" });
  const head = el("tr");
  for (const name of vars) head.appendChild(el("th", { text: name }));
  head.appendChild(el("th", { text: "левая" }));
  head.appendChild(el("th", { text: "правая" }));
  const thead = el("thead");
  thead.appendChild(head);
  node.appendChild(thead);
  const body = el("tbody");
  for (let i = 0; i < table.rows.length; i++) {
    const row = table.rows[i];
    const right = rightTable.rows[i];
    const bad = row.value !== right.value;
    const tr = el("tr", { class: bad ? "hl" : "" });
    for (const bit of row.bits) tr.appendChild(el("td", { class: "mono", text: String(bit) }));
    tr.appendChild(el("td", { class: "mono" }, math(row.value ? "1" : "0")));
    tr.appendChild(el("td", { class: "mono" }, math(right.value ? "1" : "0")));
    body.appendChild(tr);
  }
  node.appendChild(body);
  lawTable.appendChild(node);
}

function makePresetButtons(): void {
  for (const [formula, title] of presets) {
    const button = el("button", { type: "button", text: title, title: formula });
    button.addEventListener("click", () => {
      formulaInput.value = formula;
      update();
    });
    presetsNode.appendChild(button);
  }
  for (const [left, right, title] of lawPresets) {
    const button = el("button", { type: "button", text: title });
    button.addEventListener("click", () => {
      lawLeft.value = left;
      lawRight.value = right;
      checkLaw();
    });
    lawPresetsNode.appendChild(button);
  }
}

formulaInput.addEventListener("input", update);
formulaInput.addEventListener("keydown", (event) => { if (event.key === "Enter") update(); });
must<HTMLButtonElement>("#build").addEventListener("click", update);
lawLeft.addEventListener("input", checkLaw);
lawRight.addEventListener("input", checkLaw);
must<HTMLButtonElement>("#law-check").addEventListener("click", checkLaw);

makePresetButtons();
update();
checkLaw();

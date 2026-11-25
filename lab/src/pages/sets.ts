/* Sets lab: compare two expressions over A, B, C on all membership types. */

import { activate, clear, el, keepFocus, must, status, svg } from "../core/dom";
import { math } from "../core/math";
import * as SetExpr from "../domain/setexpr";

interface Case {
  id: string;
  name: string;
  left: string;
  right: string;
}

interface Row {
  pattern: SetExpr.Pattern;
  left: boolean;
  right: boolean;
  match: boolean;
}

const CASES: Case[] = [
  {
    id: "difference",
    name: "разность скобок",
    left: "A \\ (B \\ C)",
    right: "(A \\ B) ∪ C",
  },
  {
    id: "distributive",
    name: "дистрибутивность",
    left: "A ∩ (B ∪ C)",
    right: "(A ∩ B) ∪ (A ∩ C)",
  },
  {
    id: "symmetric",
    name: "симметрическая разность",
    left: "(A \\ B) ∪ (B \\ A)",
    right: "A △ B",
  },
  {
    id: "absorb",
    name: "поглощение",
    left: "A ∪ (A ∩ B)",
    right: "A",
  },
  {
    id: "de-morgan",
    name: "де Морган",
    left: "(A ∩ B)ᶜ",
    right: "Aᶜ ∪ Bᶜ",
  },
  {
    id: "union-difference",
    name: "объединение и разность",
    left: "(A ∪ B) \\ C",
    right: "(A \\ C) ∪ B",
  },
];

const leftInput = must<HTMLInputElement>("#left-input");
const rightInput = must<HTMLInputElement>("#right-input");
const form = must<HTMLFormElement>("#identity-form");
const casesNode = must<HTMLElement>("#cases");
const identityStatus = must<HTMLElement>("#identity-status");
const leftPreview = must<HTMLElement>("#left-preview");
const rightPreview = must<HTMLElement>("#right-preview");
const cubeNode = must<HTMLElement>("#cube");
const patternCount = must<HTMLElement>("#pattern-count");
const witnessNode = must<HTMLElement>("#witness");
const tableNode = must<HTMLElement>("#pattern-table");

let rows: Row[] = [];
let selectedPattern = 0;

const POSITIONS: Record<string, { x: number; y: number }> = {
  "000": { x: 90, y: 250 },
  "100": { x: 160, y: 190 },
  "010": { x: 260, y: 270 },
  "110": { x: 330, y: 210 },
  "001": { x: 90, y: 100 },
  "101": { x: 160, y: 40 },
  "011": { x: 260, y: 120 },
  "111": { x: 330, y: 60 },
};

const CUBE_EDGES = [
  ["000", "100"],
  ["000", "010"],
  ["000", "001"],
  ["100", "110"],
  ["100", "101"],
  ["010", "110"],
  ["010", "011"],
  ["001", "101"],
  ["001", "011"],
  ["110", "111"],
  ["101", "111"],
  ["011", "111"],
];

function selectedRow(): Row | null {
  return rows.find((row) => row.pattern.index === selectedPattern) ?? null;
}

function renderPreview(left: SetExpr.SetExpression, right: SetExpr.SetExpression): void {
  leftPreview.replaceChildren(math(SetExpr.toTex(left), false));
  rightPreview.replaceChildren(math(SetExpr.toTex(right), false));
}

function renderCases(): void {
  clear(casesNode);
  for (const item of CASES) {
    const button = el("button", {
      type: "button",
      class: "sets-case",
      "data-case": item.id,
      text: item.name,
      title: item.left + " = " + item.right,
    });
    button.addEventListener("click", () => {
      leftInput.value = item.left;
      rightInput.value = item.right;
      check();
    });
    casesNode.appendChild(button);
  }
}

function renderCube(): void {
  clear(cubeNode);
  if (!rows.length) return;
  const root = svg("svg", {
    viewBox: "0 0 420 320",
    role: "group",
    "aria-label": "Куб типов элементов",
    class: "sets-cube-svg",
  });

  for (const [from, to] of CUBE_EDGES) {
    const a = POSITIONS[from];
    const b = POSITIONS[to];
    root.appendChild(
      svg("line", {
        x1: a.x,
        y1: a.y,
        x2: b.x,
        y2: b.y,
        class: "sets-cube-edge",
      }),
    );
  }

  root.appendChild(svg("text", { x: 116, y: 210, class: "sets-axis-label", text: "A" }));
  root.appendChild(svg("text", { x: 208, y: 276, class: "sets-axis-label", text: "B" }));
  root.appendChild(svg("text", { x: 66, y: 170, class: "sets-axis-label", text: "C" }));

  for (const row of rows) {
    const p = POSITIONS[row.pattern.bits];
    const selected = row.pattern.index === selectedPattern;
    const group = svg("g", {
      class: "sets-cube-node " + (row.match ? "is-match" : "is-mismatch") + (selected ? " is-selected" : ""),
      "data-focus-key": "sets-pattern-" + row.pattern.bits,
      "data-pattern": row.pattern.bits,
    });
    group.appendChild(svg("circle", { cx: p.x, cy: p.y, r: 20, class: "sets-cube-circle" }));
    group.appendChild(
      svg(
        "text",
        {
          x: p.x,
          y: p.y + 4,
          "text-anchor": "middle",
          class: "sets-cube-label",
        },
        row.pattern.bits,
      ),
    );
    activate(
      group,
      () => {
        selectedPattern = row.pattern.index;
        keepFocus(() => {
          renderCube();
          renderTable();
          renderWitness();
        });
      },
      "Тип " +
        row.pattern.bits +
        ": " +
        SetExpr.patternDescription(row.pattern) +
        ", значения совпадают: " +
        (row.match ? "да" : "нет"),
    );
    group.setAttribute("aria-pressed", String(selected));
    root.appendChild(group);
  }
  cubeNode.appendChild(root);
}

function renderTable(): void {
  clear(tableNode);
  if (!rows.length) return;
  const table = el("table", { class: "data sets-pattern-table" });
  table.appendChild(el("caption", { class: "sr-only", text: "Значения обеих частей на всех типах элементов" }));
  const head = el("tr");
  for (const text of ["A", "B", "C", "левая", "правая", "итог"]) {
    head.appendChild(el("th", { scope: "col", text }));
  }
  const thead = el("thead");
  thead.appendChild(head);
  table.appendChild(thead);
  const body = el("tbody");
  for (const row of rows) {
    const tr = el("tr", {
      class: (row.match ? "" : "is-mismatch") + (row.pattern.index === selectedPattern ? " is-selected" : ""),
      "aria-label": "Тип " + row.pattern.bits + ", " + (row.match ? "совпало" : "различие"),
    });
    for (const bit of row.pattern.bits) tr.appendChild(el("td", { class: "mono", text: bit }));
    tr.appendChild(
      el("td", { class: "sets-value " + (row.left ? "is-true" : "is-false") }, math(row.left ? "1" : "0")),
    );
    tr.appendChild(
      el("td", { class: "sets-value " + (row.right ? "is-true" : "is-false") }, math(row.right ? "1" : "0")),
    );
    tr.appendChild(
      el(
        "td",
        null,
        el("span", { class: "pill " + (row.match ? "ok" : "no"), text: row.match ? "совпало" : "различие" }),
      ),
    );
    body.appendChild(tr);
  }
  table.appendChild(body);
  tableNode.appendChild(table);
}

function renderWitness(): void {
  clear(witnessNode);
  if (!rows.length) {
    witnessNode.appendChild(el("p", { class: "hint", text: "Введите корректные выражения и нажмите «Проверить»." }));
    return;
  }
  const row = selectedRow();
  if (!row) return;
  const badRows = rows.filter((item) => !item.match);
  if (!badRows.length) {
    witnessNode.appendChild(el("div", { class: "sets-witness-title ok", text: "Тождество" }));
    witnessNode.appendChild(
      el("p", {
        class: "sets-witness-copy",
        text: "Совпало во всех восьми типах элементов. Для выражений от A, B и C других вариантов нет.",
      }),
    );
    patternCount.textContent = "8 / 8";
    return;
  }
  patternCount.textContent = badRows.length + " различий";
  if (row.match) {
    witnessNode.appendChild(el("div", { class: "sets-witness-title", text: "Здесь совпало" }));
    witnessNode.appendChild(
      el("p", {
        class: "sets-witness-copy",
        text:
          "Левая и правая части дают " +
          (row.left ? "1." : "0.") +
          " Выберите красную вершину, чтобы увидеть контрпример.",
      }),
    );
    return;
  }

  witnessNode.appendChild(el("div", { class: "sets-witness-title bad", text: "Контрпример" }));
  witnessNode.appendChild(el("div", { class: "sets-witness-bits", text: row.pattern.bits }));
  witnessNode.appendChild(el("p", { class: "sets-witness-copy", text: SetExpr.patternDescription(row.pattern) }));
  const values = el("div", { class: "sets-witness-values" }, [
    el("span", { class: "sets-witness-value " + (row.left ? "is-true" : "is-false") }, [
      el("b", { text: "левая" }),
      math(row.left ? "1" : "0"),
    ]),
    el("span", { class: "sets-witness-value " + (row.right ? "is-true" : "is-false") }, [
      el("b", { text: "правая" }),
      math(row.right ? "1" : "0"),
    ]),
  ]);
  witnessNode.appendChild(values);
  witnessNode.appendChild(
    el("p", { class: "hint", text: "Возьмите один элемент x с такой принадлежностью. Значения уже различаются." }),
  );
}

function check(): void {
  try {
    const left = SetExpr.parse(leftInput.value);
    const right = SetExpr.parse(rightInput.value);
    renderPreview(left, right);
    rows = SetExpr.PATTERNS.map((pattern) => {
      const leftValue = SetExpr.evaluate(left, pattern.value);
      const rightValue = SetExpr.evaluate(right, pattern.value);
      return { pattern, left: leftValue, right: rightValue, match: leftValue === rightValue };
    });
    const mismatch = rows.find((row) => !row.match);
    selectedPattern = mismatch ? mismatch.pattern.index : 0;
    const bad = rows.filter((row) => !row.match).length;
    status(
      identityStatus,
      bad ? "Не тождество: различий " + bad + " из 8." : "Тождество: совпало 8 из 8.",
      bad ? "bad" : "ok",
    );
    renderCube();
    renderTable();
    renderWitness();
  } catch (error) {
    rows = [];
    clear(leftPreview);
    clear(rightPreview);
    clear(cubeNode);
    clear(tableNode);
    clear(witnessNode);
    patternCount.textContent = "";
    status(identityStatus, "Ошибка: " + (error instanceof Error ? error.message : String(error)), "bad");
  }
}

form.addEventListener("submit", (event) => {
  event.preventDefault();
  check();
});

renderCases();
check();

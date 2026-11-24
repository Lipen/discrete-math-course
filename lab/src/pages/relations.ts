/* Relations lab: matrix, graph, closures, equivalence classes and composition. */

import { $$, clear, el, keepFocus, must, setPressed, status, svg } from "../core/dom";
import { math } from "../core/math";
import { ribbon } from "../core/segmented";
import * as Sets from "../domain/sets";

let n = 4;
let R: Sets.Matrix = [];

ribbon(
  must<HTMLElement>("#size"),
  [
    { value: "3", label: "3" },
    { value: "4", label: "4" },
    { value: "5", label: "5" },
    { value: "6", label: "6" },
  ],
  "4",
  (value) => {
    n = Number(value);
    R = defaultMatrix(n);
    status(closureStatus, "", "");
    renderAll();
  },
);
const matrixNode = must<HTMLElement>("#matrix");
const graphNode = must<HTMLElement>("#graph");
const propertiesNode = must<HTMLElement>("#properties");
const kindNode = must<HTMLElement>("#kind");
const classesNode = must<HTMLElement>("#classes");
const closureStatus = must<HTMLElement>("#closure-status");
const squareNode = must<HTMLElement>("#square");
const inverseNode = must<HTMLElement>("#inverse");

function defaultMatrix(size: number): Sets.Matrix {
  const matrix: Sets.Matrix = Array.from({ length: size }, () => new Array<boolean>(size).fill(false));
  for (let i = 0; i < size; i++) {
    matrix[i][i] = true;
    if (i + 1 < size && i % 2 === 0) {
      matrix[i][i + 1] = true;
      matrix[i + 1][i] = true;
    }
  }
  return matrix;
}

function pairsText(matrix: Sets.Matrix): string {
  const pairs = Sets.relationPairs(matrix);
  return pairs.length ? "\\{" + pairs.map(([a, b]) => "(" + a + "," + b + ")").join(", ") + "\\}" : "\\varnothing";
}

function renderMatrix(): void {
  clear(matrixNode);
  const table = el("table", { class: "bit-matrix" });
  const head = el("tr");
  head.appendChild(el("th", { text: "" }));
  for (let j = 0; j < n; j++) head.appendChild(el("th", { text: String(j + 1) }));
  const thead = el("thead");
  thead.appendChild(head);
  table.appendChild(thead);
  const body = el("tbody");
  for (let i = 0; i < n; i++) {
    const tr = el("tr");
    tr.appendChild(el("th", { text: String(i + 1) }));
    for (let j = 0; j < n; j++) {
      const td = el("td", { class: i === j ? "diag" : "" });
      const button = el("button", {
        type: "button",
        class: R[i][j] ? "on" : "",
        text: R[i][j] ? "1" : "0",
        "aria-label": "пара (" + (i + 1) + "," + (j + 1) + ")",
        "data-focus-key": "rel-" + i + "-" + j,
      });
      setPressed(button, R[i][j]);
      button.addEventListener("click", () => {
        R[i][j] = !R[i][j];
        renderAll();
      });
      td.appendChild(button);
      tr.appendChild(td);
    }
    body.appendChild(tr);
  }
  table.appendChild(body);
  matrixNode.appendChild(table);
}

function renderGraph(): void {
  clear(graphNode);
  const width = 520;
  const height = 470;
  const cx = width / 2;
  const cy = height / 2;
  const radius = 175;
  const coords: Array<{ x: number; y: number }> = [];
  for (let i = 0; i < n; i++) {
    const angle = -Math.PI / 2 + (2 * Math.PI * i) / n;
    coords.push({ x: cx + radius * Math.cos(angle), y: cy + radius * Math.sin(angle) });
  }
  const root = svg("svg", { viewBox: "0 0 " + width + " " + height, role: "img", "aria-label": "Граф отношения" });
  const defs = svg("defs");
  const marker = svg("marker", {
    id: "rel-arrow",
    viewBox: "0 0 10 10",
    refX: "9",
    refY: "5",
    markerWidth: "6",
    markerHeight: "6",
    orient: "auto-start-reverse",
  });
  marker.appendChild(svg("path", { d: "M 0 0 L 10 5 L 0 10 z", fill: "#6a4c93" }));
  defs.appendChild(marker);
  root.appendChild(defs);

  for (let i = 0; i < n; i++) {
    for (let j = 0; j < n; j++) {
      if (!R[i][j]) continue;
      const a = coords[i];
      const b = coords[j];
      if (i === j) {
        root.appendChild(
          svg("path", {
            d:
              "M " +
              (a.x - 12) +
              " " +
              (a.y - 20) +
              " C " +
              (a.x - 45) +
              " " +
              (a.y - 70) +
              ", " +
              (a.x + 45) +
              " " +
              (a.y - 70) +
              ", " +
              (a.x + 12) +
              " " +
              (a.y - 20),
            fill: "none",
            stroke: "#6a4c93",
            "stroke-width": 1.5,
            "marker-end": "url(#rel-arrow)",
          }),
        );
        continue;
      }
      const mutual = R[j][i] && i < j;
      if (mutual) {
        const mx = (a.x + b.x) / 2;
        const my = (a.y + b.y) / 2;
        const dx = b.x - a.x;
        const dy = b.y - a.y;
        const len = Math.hypot(dx, dy) || 1;
        const ox = (-dy / len) * 20;
        const oy = (dx / len) * 20;
        root.appendChild(
          svg("path", {
            d: "M " + a.x + " " + a.y + " Q " + (mx + ox) + " " + (my + oy) + " " + b.x + " " + b.y,
            fill: "none",
            stroke: "#6a4c93",
            "stroke-width": 1.4,
            "marker-end": "url(#rel-arrow)",
          }),
        );
        root.appendChild(
          svg("path", {
            d: "M " + b.x + " " + b.y + " Q " + (mx - ox) + " " + (my - oy) + " " + a.x + " " + a.y,
            fill: "none",
            stroke: "#6a4c93",
            "stroke-width": 1.4,
            "marker-end": "url(#rel-arrow)",
          }),
        );
      } else {
        root.appendChild(
          svg("line", {
            x1: a.x,
            y1: a.y,
            x2: b.x,
            y2: b.y,
            stroke: "#6a4c93",
            "stroke-width": 1.4,
            "marker-end": "url(#rel-arrow)",
          }),
        );
      }
    }
  }

  for (let i = 0; i < n; i++) {
    const p = coords[i];
    root.appendChild(svg("circle", { cx: p.x, cy: p.y, r: 23, fill: "#fff", stroke: "#7b7366", "stroke-width": 1.5 }));
    root.appendChild(
      svg(
        "text",
        {
          x: p.x,
          y: p.y + 5,
          "text-anchor": "middle",
          "font-family": "var(--mono)",
          "font-size": 14,
          "font-weight": 700,
          fill: "#1d2733",
        },
        String(i + 1),
      ),
    );
  }
  graphNode.appendChild(root);
}

function badge(label: string, ok: boolean): HTMLElement {
  return el("span", { class: "pill " + (ok ? "ok" : "no"), text: label + (ok ? " ✓" : " ✗") });
}

function renderProperties(): { p: Sets.RelationProperties; equivalence: boolean } {
  const p = Sets.relationProperties(R);
  clear(propertiesNode);
  propertiesNode.appendChild(badge("рефлексивно", p.reflexive));
  propertiesNode.appendChild(badge("симметрично", p.symmetric));
  propertiesNode.appendChild(badge("транзитивно", p.transitive));
  propertiesNode.appendChild(badge("антисимметрично", p.antisymmetric));
  propertiesNode.appendChild(badge("иррефлексивно", p.irreflexive));
  const equivalence = p.reflexive && p.symmetric && p.transitive;
  const order = p.reflexive && p.antisymmetric && p.transitive;
  if (equivalence) status(kindNode, "Эквивалентность. Отношение разбивает множество на классы.", "ok");
  else if (order) status(kindNode, "Частичный порядок. Рефлексивно, антисимметрично и транзитивно.", "info");
  else status(kindNode, "Пока не эквивалентность и не порядок. Добавьте нужные пары.", "warn");
  return { p, equivalence };
}

function renderClasses(equivalence: boolean): void {
  clear(classesNode);
  if (!equivalence) {
    classesNode.appendChild(
      el("p", {
        class: "hint",
        text: "Классы появятся, когда отношение станет рефлексивным, симметричным и транзитивным.",
      }),
    );
    return;
  }
  const classes = Sets.equivalenceClasses(R);
  for (const cls of classes) {
    classesNode.appendChild(
      el("span", { class: "pill info", text: "{" + cls.join(", ") + "}", style: "margin:0 4px 6px 0" }),
    );
  }
  const quotient = classes.map((cls) => "\\{" + cls.join(",") + "\\}").join(", ");
  classesNode.appendChild(
    el("div", { class: "formula-box", style: "margin-top:8px" }, math("A/{\\sim} = \\{" + quotient + "\\}", false)),
  );
}

function renderComposition(): { square: Sets.Matrix; inverse: Sets.Matrix } {
  const square: Sets.Matrix = Array.from({ length: n }, () => new Array<boolean>(n).fill(false));
  for (let i = 0; i < n; i++) {
    for (let j = 0; j < n; j++) {
      for (let k = 0; k < n; k++) {
        if (R[i][k] && R[k][j]) {
          square[i][j] = true;
          break;
        }
      }
    }
  }
  const inverse = R.map((row, i) => row.map((_value, j) => R[j][i]));
  squareNode.replaceChildren(math("R^2 = " + pairsText(square), false));
  inverseNode.replaceChildren(math("R^{-1} = " + pairsText(inverse), false));
  return { square, inverse };
}

function paint(): void {
  renderMatrix();
  renderGraph();
  const { equivalence } = renderProperties();
  renderClasses(equivalence);
  renderComposition();
}

function renderAll(): void {
  keepFocus(paint);
}

function applyClosure(kind: string): void {
  if (kind === "reflexive") R = Sets.reflexiveClosure(R);
  else if (kind === "symmetric") R = Sets.symmetricClosure(R);
  else if (kind === "transitive") R = Sets.transitiveClosure(R);
  else if (kind === "equivalence") {
    R = Sets.transitiveClosure(Sets.symmetricClosure(Sets.reflexiveClosure(R)));
  }
  status(closureStatus, "Замыкание применено: " + kind + ".", "ok");
  renderAll();
}

for (const button of $$<HTMLButtonElement>("[data-closure]")) {
  button.addEventListener("click", () => applyClosure(button.dataset.closure ?? ""));
}

must<HTMLButtonElement>("#blocks").addEventListener("click", () => {
  R = defaultMatrix(n);
  status(closureStatus, "Поставлены блоки эквивалентности.", "ok");
  renderAll();
});

must<HTMLButtonElement>("#clear").addEventListener("click", () => {
  R = Array.from({ length: n }, () => new Array<boolean>(n).fill(false));
  status(closureStatus, "Матрица очищена.", "warn");
  renderAll();
});

must<HTMLButtonElement>("#random").addEventListener("click", () => {
  R = Array.from({ length: n }, () => Array.from({ length: n }, () => Math.random() < 0.35));
  status(closureStatus, "Случайное отношение.", "ok");
  renderAll();
});

must<HTMLButtonElement>("#apply-square").addEventListener("click", () => {
  const { square } = renderComposition();
  R = square;
  status(closureStatus, "R заменено на R².", "ok");
  renderAll();
});

must<HTMLButtonElement>("#apply-inverse").addEventListener("click", () => {
  const { inverse } = renderComposition();
  R = inverse;
  status(closureStatus, "R заменено на R⁻¹.", "ok");
  renderAll();
});

R = defaultMatrix(n);
renderAll();

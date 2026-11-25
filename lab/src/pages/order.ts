/* Order lab: relation matrix, Hasse diagram, bounds and chains. */

import { clear, el, keepFocus, must, setPressed, status, svg } from "../core/dom";
import { math } from "../core/math";
import { ribbon } from "../core/segmented";
import { type LayoutPoint, layoutHasse, rankOf } from "../domain/order-layout";
import * as Sets from "../domain/sets";

let n = 4;
let R: Sets.Matrix = [];
let focus: number | null = null;
let selected = new Set([2, 3]);

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
    focus = null;
    R = divisibility(n);
    selected = new Set([2, 3].filter((x) => x <= n));
    renderAll();
  },
);
const matrixNode = must<HTMLElement>("#matrix");
const propertiesNode = must<HTMLElement>("#properties");
const kindNode = must<HTMLElement>("#kind");
const hasseNode = must<HTMLElement>("#hasse");
const subsetNode = must<HTMLElement>("#subset");
const boundsNode = must<HTMLElement>("#bounds");
const boundMetrics = must<HTMLElement>("#bound-metrics");
const extremaNode = must<HTMLElement>("#extrema");
const longestNode = must<HTMLElement>("#longest-chain");
const linearNode = must<HTMLElement>("#linear-extension");
const elementsCount = must<HTMLElement>("#order-elements");
const coversCount = must<HTMLElement>("#order-covers");
const heightCount = must<HTMLElement>("#order-height");

function divisibility(size: number): Sets.Matrix {
  const matrix: Sets.Matrix = Array.from({ length: size }, () => new Array<boolean>(size).fill(false));
  for (let i = 1; i <= size; i++) {
    for (let j = 1; j <= size; j++) matrix[i - 1][j - 1] = j % i === 0;
  }
  return matrix;
}

function diagonal(size: number): Sets.Matrix {
  return Array.from({ length: size }, (_, i) => Array.from({ length: size }, (_, j) => i === j));
}

function randomOrder(size: number): Sets.Matrix {
  const linear = Array.from({ length: size }, (_, i) => i + 1).sort(() => Math.random() - 0.5);
  const matrix: Sets.Matrix = Array.from({ length: size }, () => new Array<boolean>(size).fill(false));
  for (let i = 0; i < size; i++) {
    for (let j = i; j < size; j++) {
      matrix[linear[i] - 1][linear[j] - 1] = true;
    }
  }
  return matrix;
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
        "aria-label": "(" + (i + 1) + "," + (j + 1) + ")",
        "data-focus-key": "ord-" + i + "-" + j,
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

function coverMatrix(): Sets.Matrix {
  return Sets.transitiveReduction(R);
}

function trimEdge(points: LayoutPoint[], radius: number): LayoutPoint[] {
  if (points.length < 2) return points;
  const first = points[0];
  const next = points[1];
  const firstLength = Math.hypot(next.x - first.x, next.y - first.y) || 1;
  const start = {
    x: first.x + ((next.x - first.x) / firstLength) * radius,
    y: first.y + ((next.y - first.y) / firstLength) * radius,
  };
  const last = points[points.length - 1];
  const previous = points[points.length - 2];
  const lastLength = Math.hypot(last.x - previous.x, last.y - previous.y) || 1;
  const end = {
    x: last.x - ((last.x - previous.x) / lastLength) * radius,
    y: last.y - ((last.y - previous.y) / lastLength) * radius,
  };
  return [start, ...points.slice(1, -1), end];
}

function edgePath(points: LayoutPoint[]): string {
  return points.map((point, index) => (index ? "L " : "M ") + point.x.toFixed(2) + " " + point.y.toFixed(2)).join(" ");
}

function renderHasse(isPoset: boolean): void {
  clear(hasseNode);
  if (!isPoset) {
    hasseNode.appendChild(
      el("p", {
        class: "muted",
        text: "Отношение не является частичным порядком. Диаграмма Хассе не строится, пока не исправлены свойства.",
      }),
    );
    return;
  }
  const layout = layoutHasse(coverMatrix());
  const root = svg("svg", {
    viewBox: "0 0 " + layout.width + " " + layout.height,
    role: "group",
    "aria-label": "Диаграмма Хассе",
  });
  const edges: Array<{ from: number; to: number; node: SVGElement }> = [];
  for (const edge of layout.edges) {
    const path = svg("path", {
      d: edgePath(trimEdge(edge.points, 23)),
      class: "ord-edge",
      "data-from": edge.from + 1,
      "data-to": edge.to + 1,
      "data-route": edge.points.length,
    });
    root.appendChild(path);
    edges.push({ from: edge.from, to: edge.to, node: path });
  }
  const circles: SVGElement[] = [];
  const texts: SVGElement[] = [];
  function paintFocus(): void {
    const idleStroke = "color-mix(in srgb, var(--ink) 30%, var(--card))";
    const relatedFill = "color-mix(in srgb, var(--accent) 28%, var(--card))";
    const active = focus !== null;
    for (let i = 0; i < n; i++) {
      const comparable = focus === null ? false : R[focus][i] || R[i][focus];
      const isFocus = focus === i;
      const faded = active && !isFocus && !comparable;
      const circle = circles[i];
      const text = texts[i];
      const isSelected = selected.has(i + 1);
      circle.classList.toggle("selected", isSelected);
      circle.style.fill = isFocus
        ? "var(--ink)"
        : isSelected
          ? "var(--accent-soft)"
          : comparable
            ? relatedFill
            : "var(--card)";
      circle.style.stroke = isFocus || isSelected || comparable ? "var(--accent)" : idleStroke;
      circle.style.strokeWidth = isFocus ? "3" : isSelected || comparable ? "2.4" : "1.5";
      circle.style.opacity = faded ? "0.4" : "1";
      text.style.fill = isFocus ? "var(--card)" : "var(--ink)";
      text.style.opacity = faded ? "0.4" : "1";
      text.style.fontWeight = isFocus || comparable ? "800" : "700";
    }
    for (const edge of edges) {
      const touches = focus !== null && (edge.from === focus || edge.to === focus);
      edge.node.style.stroke = touches ? "var(--accent)" : idleStroke;
      edge.node.style.strokeWidth = touches ? "2.6" : "1.6";
      edge.node.style.opacity = focus !== null && !touches ? "0.32" : "1";
    }
  }
  for (let i = 0; i < n; i++) {
    const point = layout.nodes[i];
    if (!point) continue;
    const circle = svg("circle", { cx: point.x, cy: point.y, r: 21, style: "cursor:pointer" });
    circles.push(circle);
    root.appendChild(circle);
    const text = svg(
      "text",
      {
        x: point.x,
        y: point.y + 5,
        "text-anchor": "middle",
        "font-family": "var(--mono)",
        "font-size": 13,
        "font-weight": 700,
      },
      String(i + 1),
    );
    texts.push(text);
    root.appendChild(text);
    const comparableList: number[] = [];
    for (let j = 0; j < n; j++) {
      if (j !== i && (R[i][j] || R[j][i])) comparableList.push(j + 1);
    }
    const hit = svg("circle", {
      cx: point.x,
      cy: point.y,
      r: 23,
      fill: "transparent",
      tabindex: "0",
      role: "img",
      style: "cursor:pointer",
      "data-focus-key": "hasse-" + (i + 1),
      "aria-label":
        "Элемент " +
        (i + 1) +
        (comparableList.length ? ", сравним с " + comparableList.join(", ") : ", не сравним ни с кем"),
    });
    hit.addEventListener("mouseenter", () => {
      focus = i;
      paintFocus();
    });
    hit.addEventListener("mouseleave", () => {
      if (document.activeElement !== hit) {
        focus = null;
        paintFocus();
      }
    });
    hit.addEventListener("focus", () => {
      focus = i;
      paintFocus();
    });
    hit.addEventListener("blur", () => {
      focus = null;
      paintFocus();
    });
    root.appendChild(hit);
  }
  paintFocus();
  hasseNode.appendChild(root);
}

function renderProperties(): boolean {
  const p = Sets.relationProperties(R);
  clear(propertiesNode);
  propertiesNode.appendChild(el("span", { class: "pill " + (p.reflexive ? "ok" : "no"), text: "рефлексивно" }));
  propertiesNode.appendChild(el("span", { class: "pill " + (p.antisymmetric ? "ok" : "no"), text: "антисимметрично" }));
  propertiesNode.appendChild(el("span", { class: "pill " + (p.transitive ? "ok" : "no"), text: "транзитивно" }));
  const isPoset = p.reflexive && p.antisymmetric && p.transitive;
  status(
    kindNode,
    isPoset ? "Частичный порядок. Диаграмма Хассе построена." : "Это не частичный порядок: исправьте свойства.",
    isPoset ? "ok" : "bad",
  );
  return isPoset;
}

function renderSubset(isPoset: boolean): void {
  clear(subsetNode);
  for (let i = 0; i < n; i++) {
    const value = i + 1;
    const button = el("button", {
      class: "toggle-chip" + (selected.has(value) ? " on" : ""),
      type: "button",
      text: String(value),
      "aria-label": "Элемент " + value + (selected.has(value) ? ", выбран" : ", не выбран"),
      "data-focus-key": "ord-sub-" + value,
    });
    setPressed(button, selected.has(value));
    button.addEventListener("click", () => {
      if (selected.has(value)) selected.delete(value);
      else selected.add(value);
      renderAll();
    });
    subsetNode.appendChild(button);
  }
  if (!isPoset) {
    clear(boundsNode);
    clear(boundMetrics);
    boundsNode.appendChild(el("p", { class: "hint", text: "Границы определены для частичного порядка." }));
    return;
  }
  const chosen = Sets.list(selected);
  if (!chosen.length) {
    clear(boundsNode);
    clear(boundMetrics);
    boundsNode.appendChild(el("p", { class: "hint", text: "Выберите хотя бы один элемент." }));
    return;
  }
  const lower: number[] = [];
  const upper: number[] = [];
  for (let x = 1; x <= n; x++) {
    if (chosen.every((s) => R[x - 1][s - 1])) lower.push(x);
    if (chosen.every((s) => R[s - 1][x - 1])) upper.push(x);
  }
  const glb = lower.find((x) => lower.every((y) => R[x - 1][y - 1]));
  const lub = upper.find((x) => upper.every((y) => R[y - 1][x - 1]));
  clear(boundsNode);
  boundsNode.appendChild(el("p", { class: "hint", text: "Подмножество S = {" + chosen.join(", ") + "}" }));
  boundsNode.appendChild(
    el(
      "div",
      { class: "formula-box" },
      math(
        "\\text{нижние} = \\{" + lower.join(",") + "\\},\\quad \\text{верхние} = \\{" + upper.join(",") + "\\}",
        false,
      ),
    ),
  );
  boundsNode.appendChild(
    el("p", {
      class: "hint",
      text: glb ? "Наибольшая нижняя граница: " + glb + "." : "Наибольшей нижней границы нет.",
    }),
  );
  boundsNode.appendChild(
    el("p", {
      class: "hint",
      text: lub ? "Наименьшая верхняя граница: " + lub + "." : "Наименьшей верхней границы нет.",
    }),
  );
  boundMetrics.innerHTML = "";
  boundMetrics.appendChild(
    el("div", { class: "metric" }, [
      el("span", { class: "k", text: "|S|" }),
      el("span", { class: "v", text: String(chosen.length) }),
    ]),
  );
  boundMetrics.appendChild(
    el("div", { class: "metric" }, [
      el("span", { class: "k", text: "нижних" }),
      el("span", { class: "v", text: String(lower.length) }),
    ]),
  );
  boundMetrics.appendChild(
    el("div", { class: "metric" }, [
      el("span", { class: "k", text: "верхних" }),
      el("span", { class: "v", text: String(upper.length) }),
    ]),
  );
}

function renderExtrema(isPoset: boolean): void {
  clear(extremaNode);
  if (!isPoset) {
    extremaNode.appendChild(el("p", { class: "hint", text: "Крайние элементы определены для частичного порядка." }));
    return;
  }
  const minimal: number[] = [];
  const maximal: number[] = [];
  for (let i = 1; i <= n; i++) {
    let hasPred = false;
    let hasSucc = false;
    for (let j = 1; j <= n; j++) {
      if (i !== j && R[j - 1][i - 1]) hasPred = true;
      if (i !== j && R[i - 1][j - 1]) hasSucc = true;
    }
    if (!hasPred) minimal.push(i);
    if (!hasSucc) maximal.push(i);
  }
  extremaNode.appendChild(
    el(
      "div",
      { class: "formula-box" },
      math("\\min = \\{" + minimal.join(",") + "\\},\\quad \\max = \\{" + maximal.join(",") + "\\}", false),
    ),
  );
}

function renderRail(node: HTMLElement, values: number[], separator: string): void {
  clear(node);
  values.forEach((value, index) => {
    if (index > 0) node.appendChild(el("span", { class: "chain-sep", text: separator }));
    node.appendChild(el("span", { class: "chain-chip", text: String(value) }));
  });
}

function renderChains(isPoset: boolean): void {
  clear(longestNode);
  clear(linearNode);
  if (!isPoset) {
    longestNode.textContent = "нужен частичный порядок";
    linearNode.textContent = "нужен частичный порядок";
    return;
  }
  const cover = coverMatrix();
  const indeg = new Array<number>(n).fill(0);
  for (let i = 0; i < n; i++) for (let j = 0; j < n; j++) if (cover[i][j]) indeg[j]++;
  const queue: number[] = [];
  for (let i = 0; i < n; i++) if (indeg[i] === 0) queue.push(i);
  const order: number[] = [];
  while (queue.length) {
    queue.sort((a, b) => a - b);
    const item = queue.shift();
    if (item === undefined) break;
    order.push(item + 1);
    for (let j = 0; j < n; j++) {
      if (cover[item][j]) {
        indeg[j]--;
        if (indeg[j] === 0) queue.push(j);
      }
    }
  }
  renderRail(linearNode, order, "→");

  const memo = new Map<number, number[]>();
  function longestFrom(i: number): number[] {
    const cached = memo.get(i);
    if (cached) return cached;
    let best = [i + 1];
    for (let j = 0; j < n; j++) {
      if (cover[i][j]) {
        const candidate = [i + 1].concat(longestFrom(j));
        if (candidate.length > best.length) best = candidate;
      }
    }
    memo.set(i, best);
    return best;
  }
  let longest: number[] = [];
  for (let i = 0; i < n; i++) {
    const candidate = longestFrom(i);
    if (candidate.length > longest.length) longest = candidate;
  }
  renderRail(longestNode, longest, "<");
}

function renderMetrics(isPoset: boolean): void {
  elementsCount.textContent = String(n);
  if (!isPoset) {
    coversCount.textContent = "—";
    heightCount.textContent = "—";
    return;
  }
  const cover = coverMatrix();
  let count = 0;
  for (let i = 0; i < n; i++) {
    for (let j = 0; j < n; j++) if (cover[i][j]) count++;
  }
  coversCount.textContent = String(count);
  heightCount.textContent = String(Math.max(0, ...rankOf(cover)) + 1);
}

function paint(): void {
  renderMatrix();
  const isPoset = renderProperties();
  renderMetrics(isPoset);
  renderHasse(isPoset);
  renderSubset(isPoset);
  renderExtrema(isPoset);
  renderChains(isPoset);
}

function renderAll(): void {
  keepFocus(paint);
}

must<HTMLButtonElement>("#divisors").addEventListener("click", () => {
  focus = null;
  R = divisibility(n);
  renderAll();
});
must<HTMLButtonElement>("#identity").addEventListener("click", () => {
  focus = null;
  R = diagonal(n);
  renderAll();
});
must<HTMLButtonElement>("#random-order").addEventListener("click", () => {
  focus = null;
  R = randomOrder(n);
  renderAll();
});

R = divisibility(n);
selected = new Set([2, 3].filter((x) => x <= n));
renderAll();

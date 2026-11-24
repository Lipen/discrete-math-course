/* Order lab: relation matrix, Hasse diagram, bounds and chains. */

import { clear, el, keepFocus, must, setPressed, status, svg } from "../core/dom";
import { math } from "../core/math";
import { ribbon } from "../core/segmented";
import * as Sets from "../domain/sets";

let n = 4;
let R: Sets.Matrix = [];
let focus: number | null = null;
let selected = new Set([2, 3]);

ribbon(must<HTMLElement>("#size"), [
  { value: "3", label: "3" },
  { value: "4", label: "4" },
  { value: "5", label: "5" },
  { value: "6", label: "6" },
], "4", (value) => {
  n = Number(value);
  focus = null;
  R = divisibility(n);
  selected = new Set([2, 3].filter((x) => x <= n));
  renderAll();
});
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

function rankOf(cover: Sets.Matrix): number[] {
  const rank = new Array<number>(n).fill(0);
  for (let step = 0; step < n; step++) {
    for (let i = 0; i < n; i++) {
      for (let j = 0; j < n; j++) {
        if (cover[i][j]) rank[j] = Math.max(rank[j], rank[i] + 1);
      }
    }
  }
  return rank;
}

function renderHasse(isPoset: boolean): void {
  clear(hasseNode);
  if (!isPoset) {
    hasseNode.appendChild(el("p", { class: "muted", text: "Отношение не является частичным порядком. Диаграмма Хассе не строится, пока не исправлены свойства." }));
    return;
  }
  const cover = coverMatrix();
  const rank = rankOf(cover);
  const layers = new Map<number, number[]>();
  for (let i = 0; i < n; i++) {
    const layer = layers.get(rank[i]);
    if (layer) layer.push(i); else layers.set(rank[i], [i]);
  }
  const maxRank = Math.max(0, ...rank);
  const width = 520;
  const height = Math.max(260, (maxRank + 1) * 86 + 60);
  const coords = new Map<number, { x: number; y: number }>();
  for (const [r, list] of layers) {
    list.forEach((item, index) => {
      coords.set(item, {
        x: (width * (index + 1)) / (list.length + 1),
        y: height - 50 - r * 82,
      });
    });
  }
  const root = svg("svg", { viewBox: "0 0 " + width + " " + height, role: "group", "aria-label": "Диаграмма Хассе" });
  const edges: Array<{ from: number; to: number; node: SVGElement }> = [];
  for (let i = 0; i < n; i++) {
    for (let j = 0; j < n; j++) {
      if (!cover[i][j]) continue;
      const a = coords.get(i);
      const b = coords.get(j);
      if (!a || !b) continue;
      const line = svg("line", {
        x1: a.x, y1: a.y - 20, x2: b.x, y2: b.y + 20,
        stroke: "#b7ae9e", "stroke-width": 1.6,
      });
      root.appendChild(line);
      edges.push({ from: i, to: j, node: line });
    }
  }
  const circles: SVGElement[] = [];
  const texts: SVGElement[] = [];
  function paintFocus(): void {
    const idleStroke = "color-mix(in srgb, var(--ink) 30%, var(--card))";
    const relatedFill = "color-mix(in srgb, var(--accent) 28%, var(--card))";
    const active = focus !== null;
    for (let i = 0; i < n; i++) {
      const comparable = focus === null ? false : (R[focus][i] || R[i][focus]);
      const isFocus = focus === i;
      const faded = active && !isFocus && !comparable;
      const circle = circles[i];
      const text = texts[i];
      circle.style.fill = isFocus ? "var(--ink)" : comparable ? relatedFill : "var(--card)";
      circle.style.stroke = isFocus ? "var(--ink)" : comparable ? "var(--accent)" : idleStroke;
      circle.style.strokeWidth = isFocus ? "3" : comparable ? "2.4" : "1.5";
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
    const p = coords.get(i);
    if (!p) continue;
    const circle = svg("circle", { cx: p.x, cy: p.y, r: 21, style: "cursor:pointer" });
    circles.push(circle);
    root.appendChild(circle);
    const text = svg("text", {
      x: p.x, y: p.y + 5, "text-anchor": "middle",
      "font-family": "var(--mono)", "font-size": 13, "font-weight": 700,
    }, String(i + 1));
    texts.push(text);
    root.appendChild(text);
    const comparableList: number[] = [];
    for (let j = 0; j < n; j++) {
      if (j !== i && (R[i][j] || R[j][i])) comparableList.push(j + 1);
    }
    const hit = svg("circle", {
      cx: p.x, cy: p.y, r: 23, fill: "transparent",
      tabindex: "0", role: "img", style: "cursor:pointer",
      "data-focus-key": "hasse-" + (i + 1),
      "aria-label": "Элемент " + (i + 1) + (comparableList.length
        ? ", сравним с " + comparableList.join(", ")
        : ", не сравним ни с кем"),
    });
    hit.addEventListener("mouseenter", () => { focus = i; paintFocus(); });
    hit.addEventListener("mouseleave", () => {
      if (document.activeElement !== hit) { focus = null; paintFocus(); }
    });
    hit.addEventListener("focus", () => { focus = i; paintFocus(); });
    hit.addEventListener("blur", () => { focus = null; paintFocus(); });
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
  status(kindNode, isPoset ? "Частичный порядок. Диаграмма Хассе построена." : "Это не частичный порядок: исправьте свойства.", isPoset ? "ok" : "bad");
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
      if (selected.has(value)) selected.delete(value); else selected.add(value);
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
  boundsNode.appendChild(el("div", { class: "formula-box" }, math("\\text{нижние} = \\{" + lower.join(",") + "\\},\\quad \\text{верхние} = \\{" + upper.join(",") + "\\}", false)));
  boundsNode.appendChild(el("p", { class: "hint", text: glb ? "Наибольшая нижняя граница: " + glb + "." : "Наибольшей нижней границы нет." }));
  boundsNode.appendChild(el("p", { class: "hint", text: lub ? "Наименьшая верхняя граница: " + lub + "." : "Наименьшей верхней границы нет." }));
  boundMetrics.innerHTML = "";
  boundMetrics.appendChild(el("div", { class: "metric" }, [el("span", { class: "k", text: "|S|" }), el("span", { class: "v", text: String(chosen.length) })]));
  boundMetrics.appendChild(el("div", { class: "metric" }, [el("span", { class: "k", text: "нижних" }), el("span", { class: "v", text: String(lower.length) })]));
  boundMetrics.appendChild(el("div", { class: "metric" }, [el("span", { class: "k", text: "верхних" }), el("span", { class: "v", text: String(upper.length) })]));
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
  extremaNode.appendChild(el("div", { class: "formula-box" }, math("\\min = \\{" + minimal.join(",") + "\\},\\quad \\max = \\{" + maximal.join(",") + "\\}", false)));
}

function renderChains(isPoset: boolean): void {
  clear(longestNode);
  clear(linearNode);
  if (!isPoset) {
    longestNode.textContent = "Нужен частичный порядок.";
    linearNode.textContent = "Нужен частичный порядок.";
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
  linearNode.replaceChildren(math("\\text{линейное продолжение} = (" + order.join(", ") + ")", false));

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
  longestNode.replaceChildren(math("\\text{длинная цепь} = (" + longest.join(" < ") + ")", false));
}

function paint(): void {
  renderMatrix();
  const isPoset = renderProperties();
  renderHasse(isPoset);
  renderSubset(isPoset);
  renderExtrema(isPoset);
  renderChains(isPoset);
}

function renderAll(): void {
  keepFocus(paint);
}

must<HTMLButtonElement>("#divisors").addEventListener("click", () => { focus = null; R = divisibility(n); renderAll(); });
must<HTMLButtonElement>("#identity").addEventListener("click", () => { focus = null; R = diagonal(n); renderAll(); });
must<HTMLButtonElement>("#random-order").addEventListener("click", () => { focus = null; R = randomOrder(n); renderAll(); });

R = divisibility(n);
selected = new Set([2, 3].filter((x) => x <= n));
renderAll();

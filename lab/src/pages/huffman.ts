/* Huffman lab: greedy merges, tree layout, prefix codes and code cost. */

import { fmt } from "../core/bits";
import { clear, el, must, status, svg } from "../core/dom";
import { math } from "../core/math";

interface Entry {
  symbol: string;
  weight: number;
}

interface TreeNode {
  id: number;
  symbol: string | null;
  weight: number;
  left: TreeNode | null;
  right: TreeNode | null;
  order: number;
}

interface Merge {
  left: TreeNode;
  right: TreeNode;
  weight: number;
}

interface Stats {
  total: number;
  L: number;
  H: number;
  gap: number;
  merges: Merge[];
}

const presets: Record<string, [string, number][]> = {
  classic: [["A", 45], ["B", 13], ["C", 12], ["D", 16], ["E", 9], ["F", 5]],
  equal: [["A", 1], ["B", 1], ["C", 1], ["D", 1]],
  skew: [["A", 70], ["B", 10], ["C", 10], ["D", 5], ["E", 5]],
  two: [["A", 1], ["B", 1]],
};

let entries: Entry[] = [];
let tree: TreeNode | null = null;
let codes = new Map<TreeNode, string>();
let stats: Stats | null = null;

const presetNode = must<HTMLSelectElement>("#preset");
const freqNode = must<HTMLTextAreaElement>("#freq");
const freqStatus = must<HTMLElement>("#freq-status");
const treeNode = must<HTMLElement>("#tree");
const codesNode = must<HTMLElement>("#codes");
const costNode = must<HTMLElement>("#cost");
const mergesNode = must<HTMLElement>("#merges");

function setPreset(name: string): void {
  entries = presets[name].map(([symbol, weight]) => ({ symbol, weight }));
  freqNode.value = entries.map((e) => e.symbol + " " + e.weight).join("\n");
  presetNode.value = name;
  compute();
  renderAll();
}

function parseFrequencies(text: string): Entry[] {
  const rows: Entry[] = [];
  const seen = new Set<string>();
  const lines = text.split(/\r?\n/);
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();
    if (!line) continue;
    const match = line.match(/^(.+?)[\s:=]+(\d+(?:[.,]\d+)?)$/);
    if (!match) throw new Error("Строка " + (i + 1) + ": ожидается имя и положительный вес.");
    const symbol = match[1].trim();
    const weight = Number(match[2].replace(",", "."));
    if (!Number.isFinite(weight) || weight <= 0) throw new Error("Строка " + (i + 1) + ": вес должен быть положительным.");
    if (seen.has(symbol)) throw new Error("Символ «" + symbol + "» повторяется.");
    seen.add(symbol);
    rows.push({ symbol, weight });
  }
  if (rows.length === 0) throw new Error("Нужен хотя бы один символ.");
  return rows;
}

function compute(): void {
  const nodes: TreeNode[] = [];
  const merges: Merge[] = [];
  let counter = 0;
  for (const entry of entries) {
    nodes.push({ id: counter++, symbol: entry.symbol, weight: entry.weight, left: null, right: null, order: counter });
  }
  while (nodes.length > 1) {
    nodes.sort((a, b) => a.weight - b.weight || a.order - b.order);
    const left = nodes[0];
    const right = nodes[1];
    nodes.splice(0, 2);
    const parent: TreeNode = {
      id: counter++,
      symbol: null,
      weight: left.weight + right.weight,
      left,
      right,
      order: counter,
    };
    nodes.push(parent);
    merges.push({ left, right, weight: parent.weight });
  }
  tree = nodes[0] || null;
  codes = new Map<TreeNode, string>();
  if (tree) {
    if (!tree.left && !tree.right) {
      codes.set(tree, "0");
    } else {
      assignCodes(tree, "");
    }
  }
  const total = entries.reduce((sum, e) => sum + e.weight, 0);
  let L = 0;
  let H = 0;
  for (const [node, code] of codes) {
    const p = node.weight / total;
    L += p * code.length;
    H -= p * Math.log2(p);
  }
  stats = { total, L, H, gap: L - H, merges };
}

function assignCodes(node: TreeNode, prefix: string): void {
  if (!node.left && !node.right) {
    codes.set(node, prefix || "0");
    return;
  }
  if (node.left) assignCodes(node.left, prefix + "0");
  if (node.right) assignCodes(node.right, prefix + "1");
}

function leafList(node: TreeNode | null): TreeNode[] {
  if (!node) return [];
  if (!node.left && !node.right) return [node];
  return leafList(node.left).concat(leafList(node.right));
}

function depthOf(node: TreeNode | null, target: TreeNode, depth: number): number {
  if (node === target) return depth;
  if (!node) return -1;
  const left = depthOf(node.left, target, depth + 1);
  if (left >= 0) return left;
  return depthOf(node.right, target, depth + 1);
}

function renderTree(): void {
  clear(treeNode);
  if (!tree) {
    treeNode.appendChild(el("p", { class: "muted", text: "Нет дерева." }));
    return;
  }
  const leaves = leafList(tree);
  const leafCount = Math.max(1, leaves.length);
  const maxDepth = Math.max(0, ...leaves.map((leaf) => depthOf(tree, leaf, 0)));
  const width = Math.max(620, leafCount * 96 + 120);
  const height = Math.max(260, (maxDepth + 1) * 90 + 90);
  const xs = new Map<TreeNode, number>();
  const ys = new Map<TreeNode, number>();
  const depths = new Map<TreeNode, number>();

  function layout(node: TreeNode, depth: number): number {
    depths.set(node, depth);
    ys.set(node, 46 + depth * 90);
    if (!node.left && !node.right) {
      const index = leaves.indexOf(node);
      const x = 70 + (index * (width - 140)) / Math.max(1, leaves.length - 1);
      xs.set(node, x);
      return x;
    }
    const leftX = node.left ? layout(node.left, depth + 1) : 0;
    const rightX = node.right ? layout(node.right, depth + 1) : 0;
    const x = (leftX + rightX) / 2;
    xs.set(node, x);
    return x;
  }
  layout(tree, 0);

  const root = svg("svg", { viewBox: "0 0 " + width + " " + height, role: "img", "aria-label": "Дерево Хаффмана" });

  function drawEdges(node: TreeNode | null): void {
    if (!node || (!node.left && !node.right)) return;
    const links: [TreeNode | null, string][] = [[node.left, "0"], [node.right, "1"]];
    for (const [child, bit] of links) {
      if (!child) continue;
      root.appendChild(svg("line", {
        x1: xs.get(node)!, y1: ys.get(node)! + 22,
        x2: xs.get(child)!, y2: ys.get(child)! - 22,
        stroke: "#b7ae9e", "stroke-width": 1.5,
      }));
      root.appendChild(svg("text", {
        x: (xs.get(node)! + xs.get(child)!) / 2 + (bit === "0" ? -9 : 9),
        y: (ys.get(node)! + ys.get(child)!) / 2,
        "text-anchor": "middle", "font-family": "var(--mono)", "font-size": 10, fill: "#6b6558",
      }, bit));
      drawEdges(child);
    }
  }
  drawEdges(tree);

  function drawNodes(node: TreeNode | null): void {
    if (!node) return;
    const x = xs.get(node)!;
    const y = ys.get(node)!;
    if (!node.left && !node.right) {
      const code = codes.get(node) || "";
      root.appendChild(svg("rect", {
        x: x - 30, y: y - 21, width: 60, height: 42, rx: 9,
        fill: "#fbf0dc", stroke: "#c79a4e", "stroke-width": 1.5,
      }));
      root.appendChild(svg("text", {
        x, y: y - 3, "text-anchor": "middle", "font-family": "var(--mono)",
        "font-size": 12, "font-weight": 700, fill: "#1d2733",
      }, node.symbol));
      root.appendChild(svg("text", {
        x, y: y + 13, "text-anchor": "middle", "font-family": "var(--mono)",
        "font-size": 10, fill: "#7c5210",
      }, String(node.weight) + " · " + code));
    } else {
      root.appendChild(svg("circle", {
        cx: x, cy: y, r: 20, fill: "#f1eee7", stroke: "#8c8374", "stroke-width": 1.4,
      }));
      root.appendChild(svg("text", {
        x, y: y + 5, "text-anchor": "middle", "font-family": "var(--mono)",
        "font-size": 11, "font-weight": 650, fill: "#1d2733",
      }, String(node.weight)));
    }
    drawNodes(node.left);
    drawNodes(node.right);
  }
  drawNodes(tree);

  treeNode.appendChild(root);
}

function renderCodes(): void {
  clear(codesNode);
  if (!tree || !stats) return;
  const total = stats.total;
  const rows: { symbol: string; weight: number; code: string }[] = [];
  for (const [node, code] of codes) {
    if (node.symbol === null) continue;
    rows.push({ symbol: node.symbol, weight: node.weight, code });
  }
  rows.sort((a, b) => a.code.length - b.code.length || a.symbol.localeCompare(b.symbol));
  const table = el("table", { class: "data" });
  const thead = el("thead");
  thead.appendChild(el("tr", {}, [
    el("th", { class: "left", text: "символ" }),
    el("th", { text: "вес" }),
    el("th", { text: "вероятность" }),
    el("th", { class: "left", text: "код" }),
    el("th", { text: "длина" }),
  ]));
  table.appendChild(thead);
  const tbody = el("tbody");
  for (const row of rows) {
    const tr = el("tr");
    const p = row.weight / total;
    tr.appendChild(el("td", { class: "left mono", text: row.symbol }));
    tr.appendChild(el("td", { class: "mono", text: String(row.weight) }));
    tr.appendChild(el("td", { class: "mono", text: fmt(p, 3) }));
    tr.appendChild(el("td", { class: "left mono", text: row.code }));
    tr.appendChild(el("td", { class: "mono", text: String(row.code.length) }));
    tbody.appendChild(tr);
  }
  table.appendChild(tbody);
  codesNode.appendChild(table);
}

function renderCost(): void {
  clear(costNode);
  if (!stats) return;
  function metric(tex: string, suffix: string, value: string): HTMLDivElement {
    const label = el("span", { class: "k" });
    label.appendChild(math(tex));
    if (suffix) label.appendChild(document.createTextNode(suffix));
    return el("div", { class: "metric" }, [label, el("span", { class: "v", text: value })]);
  }
  costNode.appendChild(metric("L", ", средняя длина", fmt(stats.L, 3)));
  costNode.appendChild(metric("H", ", энтропия", fmt(stats.H, 3)));
  costNode.appendChild(metric("L - H", "", fmt(stats.gap, 3)));
  costNode.appendChild(el("div", { class: "metric" }, [
    el("span", { class: "k", text: "символов" }), el("span", { class: "v", text: String(entries.length) }),
  ]));
}

function nodeLabel(node: TreeNode): string {
  return node.symbol ? node.symbol + " (" + node.weight + ")" : "(" + node.weight + ")";
}

function renderMerges(): void {
  clear(mergesNode);
  if (!stats || !stats.merges.length) {
    mergesNode.appendChild(el("p", { class: "muted", text: "Для одного символа слияний нет." }));
    return;
  }
  const table = el("table", { class: "data" });
  const thead = el("thead");
  thead.appendChild(el("tr", {}, [
    el("th", { text: "шаг" }),
    el("th", { class: "left", text: "слияние" }),
    el("th", { text: "вес" }),
  ]));
  table.appendChild(thead);
  const body = el("tbody");
  stats.merges.forEach((merge, index) => {
    const tr = el("tr");
    tr.appendChild(el("td", { class: "mono", text: String(index + 1) }));
    tr.appendChild(el("td", { class: "left mono", text: nodeLabel(merge.left) + " + " + nodeLabel(merge.right) }));
    tr.appendChild(el("td", { class: "mono", text: String(merge.weight) }));
    body.appendChild(tr);
  });
  table.appendChild(body);
  mergesNode.appendChild(table);
}

function renderAll(): void {
  renderTree();
  renderMerges();
  renderCodes();
  renderCost();
}

function applyText(): void {
  try {
    entries = parseFrequencies(freqNode.value);
    status(freqStatus, "Частоты приняты: " + entries.length + " символов.", "ok");
    compute();
    renderAll();
  } catch (error) {
    status(freqStatus, error instanceof Error ? error.message : String(error), "bad");
  }
}

presetNode.addEventListener("change", () => {
  try {
    setPreset(presetNode.value);
    status(freqStatus, "Готовый набор загружен.", "ok");
  } catch (error) {
    status(freqStatus, error instanceof Error ? error.message : String(error), "bad");
  }
});

must<HTMLButtonElement>("#apply").addEventListener("click", applyText);

setPreset("classic");
status(freqStatus, "Готовый набор загружен.", "ok");

/* Circuits lab: gate diagram, truth table and reference comparison. */

import { bitsOf } from "../core/bits";
import { activate, clear, el, keepFocus, must, setPressed, status, svg } from "../core/dom";
import { math } from "../core/math";

interface GateSpec {
  id: string;
  op: string;
  args: string[];
  label: string;
  tex?: string;
}

interface Preset {
  inputs: string[];
  gates: GateSpec[];
  ref: string;
  bad: string;
}

interface TruthRow {
  m: number;
  bits: number[];
  values: Record<string, number>;
}

const presets: Record<string, Preset> = {
  half: {
    inputs: ["a", "b"],
    gates: [
      { id: "s", op: "XOR", args: ["a", "b"], label: "S" },
      { id: "c", op: "AND", args: ["a", "b"], label: "C" },
    ],
    ref: "s",
    bad: "c",
  },
  full: {
    inputs: ["a", "b", "c"],
    gates: [
      { id: "x1", op: "XOR", args: ["a", "b"], label: "x1" },
      { id: "s", op: "XOR", args: ["x1", "c"], label: "S" },
      { id: "ab", op: "AND", args: ["a", "b"], label: "ab" },
      { id: "xc", op: "AND", args: ["x1", "c"], label: "xc" },
      { id: "co", op: "OR", args: ["ab", "xc"], label: "C" },
    ],
    ref: "s",
    bad: "co",
  },
  mux: {
    inputs: ["a", "b", "s"],
    gates: [
      { id: "ns", op: "NOT", args: ["s"], label: "¬s", tex: "\\neg s" },
      { id: "na", op: "AND", args: ["a", "ns"], label: "a∧¬s", tex: "a \\land \\neg s" },
      { id: "bs", op: "AND", args: ["b", "s"], label: "b∧s", tex: "b \\land s" },
      { id: "out", op: "OR", args: ["na", "bs"], label: "f" },
    ],
    ref: "out",
    bad: "na",
  },
  maj3: {
    inputs: ["a", "b", "c"],
    gates: [
      { id: "ab", op: "AND", args: ["a", "b"], label: "ab" },
      { id: "bc", op: "AND", args: ["b", "c"], label: "bc" },
      { id: "ac", op: "AND", args: ["a", "c"], label: "ac" },
      { id: "m1", op: "OR", args: ["ab", "bc"], label: "m1" },
      { id: "m", op: "OR", args: ["m1", "ac"], label: "m" },
    ],
    ref: "m",
    bad: "ab",
  },
};

let currentKey = "full";
let current: Preset = { inputs: [], gates: [], ref: "", bad: "" };
let selected = "co";

const presetNode = must<HTMLSelectElement>("#preset");
const outputNode = must<HTMLSelectElement>("#output");
const circuitNode = must<HTMLElement>("#circuit");
const tableNode = must<HTMLElement>("#table");
const metricsNode = must<HTMLElement>("#metrics");
const verifyNode = must<HTMLElement>("#verify");
const verifyHint = must<HTMLElement>("#verify-hint");

function evalOp(op: string, args: number[]): number {
  if (op === "NOT") return args[0] ? 0 : 1;
  if (op === "AND") return args[0] && args[1] ? 1 : 0;
  if (op === "OR") return args[0] || args[1] ? 1 : 0;
  if (op === "XOR") return args[0] !== args[1] ? 1 : 0;
  return 0;
}

function prepare(key: string): void {
  const spec = presets[key];
  currentKey = key;
  current = {
    inputs: spec.inputs.slice(),
    gates: spec.gates.map((g) => Object.assign({}, g, { args: g.args.slice() })),
    ref: spec.ref,
    bad: spec.bad,
  };
  selected = spec.bad;
  outputNode.innerHTML = "";
  for (const gate of current.gates) {
    outputNode.appendChild(el("option", {
      value: gate.id,
      text: gate.label + " (" + gate.op + ")",
    }));
  }
  outputNode.value = selected;
  evaluate();
}

function evaluate(): { values: Record<string, number>; depth: Record<string, number> } {
  const values: Record<string, number> = {};
  const depth: Record<string, number> = {};
  for (const name of current.inputs) {
    values[name] = 0;
    depth[name] = 0;
  }
  for (const gate of current.gates) {
    const args = gate.args.map((arg) => values[arg]);
    values[gate.id] = evalOp(gate.op, args);
    depth[gate.id] = 1 + Math.max(...gate.args.map((arg) => depth[arg]));
  }
  return { values, depth };
}

function renderCircuit(): void {
  const depth: Record<string, number> = {};
  for (const name of current.inputs) depth[name] = 0;
  for (const gate of current.gates) depth[gate.id] = 1 + Math.max(...gate.args.map((arg) => depth[arg]));
  const maxDepth = Math.max(0, ...current.gates.map((g) => depth[g.id]));

  const columns = new Map<number, GateSpec[]>();
  for (let d = 0; d <= maxDepth; d++) columns.set(d, []);
  for (const gate of current.gates) columns.get(depth[gate.id])?.push(gate);
  for (const list of columns.values()) list.sort((a, b) => a.id.localeCompare(b.id));

  const inputCount = current.inputs.length;
  const maxColumn = Math.max(1, ...Array.from(columns.values()).map((list) => list.length));
  const width = Math.max(760, 160 + maxDepth * 150 + 120);
  const height = Math.max(300, Math.max(inputCount, maxColumn) * 80 + 80);

  const coords = new Map<string, { x: number; y: number }>();
  current.inputs.forEach((name, i) => {
    coords.set(name, { x: 54, y: 70 + i * ((height - 110) / Math.max(1, inputCount - 1)) });
  });
  for (const [d, list] of columns) {
    if (d === 0) continue;
    list.forEach((gate, i) => {
      coords.set(gate.id, {
        x: 170 + (d - 1) * 150,
        y: 64 + i * ((height - 110) / Math.max(1, list.length)),
      });
    });
  }

  const root = svg("svg", { viewBox: "0 0 " + width + " " + height, role: "group", "aria-label": "Схема из вентилей" });

  for (const gate of current.gates) {
    const to = coords.get(gate.id);
    for (const arg of gate.args) {
      const from = coords.get(arg);
      if (!from || !to) continue;
      const midX = (from.x + to.x) / 2;
      const path = svg("path", {
        d: "M " + (from.x + 34) + " " + from.y + " C " + midX + " " + from.y + ", " + midX + " " + to.y + ", " + (to.x - 34) + " " + to.y,
        fill: "none",
        stroke: "#b7ae9e",
        "stroke-width": 1.5,
      });
      root.appendChild(path);
    }
  }

  for (const name of current.inputs) {
    const p = coords.get(name);
    if (!p) continue;
    const group = svg("g");
    group.appendChild(svg("rect", {
      x: p.x - 30, y: p.y - 19, width: 60, height: 38, rx: 8,
      fill: "#fbfaf7", stroke: "#9d9586", "stroke-width": 1.5,
    }));
    group.appendChild(svg("text", {
      x: p.x, y: p.y + 5, "text-anchor": "middle",
      "font-family": "var(--mono)", "font-size": 14, "font-weight": 650, fill: "#1d2733",
    }, name));
    root.appendChild(group);
  }

  for (const gate of current.gates) {
    const p = coords.get(gate.id);
    if (!p) continue;
    const isRef = gate.id === current.ref;
    const isSelected = gate.id === selected;
    const cls = "gate" + (isRef ? " ref" : "") + (isSelected ? " selected" : "");
    const group = svg("g", { class: cls, "data-gate": gate.id, tabindex: "0", style: "cursor:pointer", "data-focus-key": "gate-" + gate.id });
    group.appendChild(svg("rect", {
      x: p.x - 34, y: p.y - 23, width: 68, height: 46, rx: 10,
      fill: isSelected ? "#e8eef8" : (isRef ? "#e6f2ec" : "#ffffff"),
      stroke: isSelected ? "#2e5288" : (isRef ? "#2f7d5c" : "#9d9586"),
      "stroke-width": isSelected ? 2.6 : 1.5,
    }));
    group.appendChild(svg("text", {
      x: p.x, y: p.y + 1, "text-anchor": "middle",
      "font-family": "var(--mono)", "font-size": 12, "font-weight": 650, fill: "#1d2733",
    }, gate.label));
    group.appendChild(svg("text", {
      x: p.x, y: p.y + 14, "text-anchor": "middle",
      "font-family": "var(--mono)", "font-size": 9, fill: "#5f6d7c",
    }, gate.op));
    activate(group, () => {
      selected = gate.id;
      outputNode.value = selected;
      renderAll();
    }, "Вентиль " + gate.label + ", " + gate.op + (isRef ? ", эталонный выход" : "") + ", выбрать");
    setPressed(group, isSelected);
    root.appendChild(group);
  }

  clear(circuitNode);
  circuitNode.appendChild(root);
}

function renderMetrics(): void {
  const { depth } = evaluate();
  const maxDepth = Math.max(0, ...current.gates.map((g) => depth[g.id]));
  metricsNode.innerHTML = "";
  metricsNode.appendChild(el("div", { class: "metric" }, [
    el("span", { class: "k", text: "размер" }), el("span", { class: "v", text: String(current.gates.length) }),
  ]));
  metricsNode.appendChild(el("div", { class: "metric" }, [
    el("span", { class: "k", text: "глубина" }), el("span", { class: "v", text: String(maxDepth) }),
  ]));
  metricsNode.appendChild(el("div", { class: "metric" }, [
    el("span", { class: "k", text: "выбранный" }), el("span", { class: "v", text: selected, style: "font-size:15px" }),
  ]));
}

function allEvaluations(): TruthRow[] {
  const rows: TruthRow[] = [];
  for (let m = 0; m < (1 << current.inputs.length); m++) {
    const bits = bitsOf(m, current.inputs.length);
    const values: Record<string, number> = {};
    current.inputs.forEach((name, i) => { values[name] = bits[i]; });
    for (const gate of current.gates) {
      values[gate.id] = evalOp(gate.op, gate.args.map((arg) => values[arg]));
    }
    rows.push({ m, bits, values });
  }
  return rows;
}

function verify(rows: TruthRow[]): TruthRow | null {
  const ref = current.ref;
  const gate = current.gates.find((g) => g.id === selected);
  if (!gate) return null;
  let firstBad: TruthRow | null = null;
  for (const row of rows) {
    if (row.values[selected] !== row.values[ref]) { firstBad = row; break; }
  }
  if (!firstBad) {
    const trivial = selected === ref;
    status(verifyNode, trivial
      ? "Выбран эталонный выход. Он совпадает сам с собой на всех наборах."
      : "Выбранный выход совпадает с эталоном на всех наборах.", "ok");
    verifyHint.textContent = "Проверено " + rows.length + " наборов.";
  } else {
    const inputText = current.inputs.map((name, i) => name + "=" + firstBad.bits[i]).join(", ");
    status(verifyNode, "Расхождение: " + inputText + ". Выбранный выход " + selected + "=" + firstBad.values[selected] + ", эталон " + ref + "=" + firstBad.values[ref] + ".", "bad");
    verifyHint.textContent = "Первый контрпример в лексикографическом порядке наборов.";
  }
  return firstBad;
}

function renderTable(rows: TruthRow[], firstBad: TruthRow | null): void {
  clear(tableNode);
  const table = el("table", { class: "data" });
  const thead = el("thead");
  const headRow = el("tr");
  headRow.appendChild(el("th", { text: "#" }));
  for (const name of current.inputs) headRow.appendChild(el("th", { text: name }));
  for (const gate of current.gates) {
    const th = el("th", { class: gate.id === selected ? "selected" : "" });
    const labelSpan = el("span");
    if (gate.tex) labelSpan.appendChild(math(gate.tex));
    else labelSpan.textContent = gate.label;
    if (gate.id === current.ref) labelSpan.appendChild(document.createTextNode(" *"));
    th.appendChild(labelSpan);
    th.appendChild(el("br"));
    th.appendChild(el("span", { class: "small muted", text: gate.op }));
    headRow.appendChild(th);
  }
  thead.appendChild(headRow);
  table.appendChild(thead);

  const tbody = el("tbody");
  for (const row of rows) {
    const tr = el("tr", { class: firstBad && row.m === firstBad.m ? "hl" : "" });
    tr.appendChild(el("td", { class: "muted small", text: String(row.m) }));
    for (const bit of row.bits) tr.appendChild(el("td", { class: "mono", text: String(bit) }));
    for (const gate of current.gates) {
      const td = el("td", { class: "mono" + (gate.id === selected ? " selected" : "") });
      td.textContent = String(row.values[gate.id]);
      tr.appendChild(td);
    }
    tbody.appendChild(tr);
  }
  table.appendChild(tbody);
  tableNode.appendChild(table);
}

function paint(): void {
  const rows = allEvaluations();
  const firstBad = verify(rows);
  renderCircuit();
  renderMetrics();
  renderTable(rows, firstBad);
}

function renderAll(): void {
  keepFocus(paint);
}

presetNode.addEventListener("change", () => {
  prepare(presetNode.value);
  renderAll();
});

outputNode.addEventListener("change", () => {
  selected = outputNode.value;
  renderAll();
});

must<HTMLButtonElement>("#check").addEventListener("click", () => {
  const rows = allEvaluations();
  const firstBad = verify(rows);
  renderTable(rows, firstBad);
});

must<HTMLButtonElement>("#pick-ref").addEventListener("click", () => {
  selected = current.ref;
  outputNode.value = selected;
  renderAll();
});

prepare(currentKey);
renderAll();

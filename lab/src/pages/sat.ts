/* SAT lab: CNF presets, DPLL trace and solve metrics. */

import { fmt } from "../core/bits";
import { clear, el, must, status, svg } from "../core/dom";
// Side effect: renders the static [data-tex] placeholders in the page markup.
import "../core/math";

type ArtKind = "pigeon" | "color" | "random";

interface PresetData {
  n: number;
  clauses: number[][];
  ratio: number | null;
  art: ArtKind;
}

interface ParsedCnf {
  n: number;
  clauses: number[][];
}

interface TraceItem {
  type: "prop" | "decision" | "conflict" | "backtrack" | "sat";
  level: number;
  text: string;
}

interface SolveResult {
  model: number[] | null;
  decisions: number;
  propagations: number;
  conflicts: number;
  nodes: number;
  trace: TraceItem[];
  n: number;
}

let currentPreset = "pigeon";
let currentN = 6;
let currentClauses: number[][] = [];
let currentRatio: number | null = null;
let randomSeed = 20261119;
let currentTrace: TraceItem[] = [];
let tracePos = 0;

const presetNode = must<HTMLSelectElement>("#preset");
const cnfNode = must<HTMLTextAreaElement>("#cnf");
const parseStatus = must<HTMLElement>("#parse-status");
const resultNode = must<HTMLElement>("#result");
const metricsNode = must<HTMLElement>("#metrics");
const traceNode = must<HTMLElement>("#trace");
const traceHint = must<HTMLElement>("#trace-hint");
const artNode = must<HTMLElement>("#art");
const traceStepButton = must<HTMLButtonElement>("#trace-step");
const traceAllButton = must<HTMLButtonElement>("#trace-all");

function pigeonhole(pigeons: number, holes: number): PresetData {
  const clauses: number[][] = [];
  const varOf = (p: number, h: number) => p * holes + h + 1;
  for (let p = 0; p < pigeons; p++) {
    const clause: number[] = [];
    for (let h = 0; h < holes; h++) clause.push(varOf(p, h));
    clauses.push(clause);
  }
  for (let h = 0; h < holes; h++) {
    for (let p = 0; p < pigeons; p++) {
      for (let q = p + 1; q < pigeons; q++) {
        clauses.push([-varOf(p, h), -varOf(q, h)]);
      }
    }
  }
  return { n: pigeons * holes, clauses, ratio: null, art: "pigeon" };
}

function triangleColoring(): PresetData {
  const clauses: number[][] = [];
  const varOf = (v: number, c: number) => v * 2 + c + 1;
  for (let v = 0; v < 3; v++) {
    clauses.push([varOf(v, 0), varOf(v, 1)]);
    clauses.push([-varOf(v, 0), -varOf(v, 1)]);
  }
  const edges: Array<[number, number]> = [
    [0, 1],
    [1, 2],
    [0, 2],
  ];
  for (const [u, v] of edges) {
    for (let c = 0; c < 2; c++) clauses.push([-varOf(u, c), -varOf(v, c)]);
  }
  return { n: 6, clauses, ratio: null, art: "color" };
}

function mulberry32(seed: number): () => number {
  return () => {
    seed += 0x6d2b79f5;
    let t = seed;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function random3sat(n: number, m: number, seed: number): PresetData {
  const rng = mulberry32(seed);
  const clauses: number[][] = [];
  let guard = 0;
  while (clauses.length < m && guard++ < m * 40) {
    const chosen: number[] = [];
    while (chosen.length < 3) {
      const v = 1 + Math.floor(rng() * n);
      if (!chosen.includes(v)) chosen.push(v);
    }
    clauses.push(chosen.map((v) => (rng() < 0.5 ? -v : v)));
  }
  return { n, clauses, ratio: m / n, art: "random" };
}

function clauseText(clause: number[]): string {
  return clause.join(" ");
}

function presetData(name: string): PresetData {
  if (name === "pigeon") return pigeonhole(3, 2);
  if (name === "color") return triangleColoring();
  if (name === "random") {
    randomSeed = (randomSeed * 1664525 + 1013904223) >>> 0;
    return random3sat(6, 25, randomSeed);
  }
  return pigeonhole(3, 2);
}

function applyPreset(name: string): void {
  currentPreset = name;
  const data = presetData(name);
  currentN = data.n;
  currentClauses = data.clauses;
  currentRatio = data.ratio;
  cnfNode.value = currentClauses.map(clauseText).join("\n");
  parseStatus.className = "status";
  parseStatus.textContent = "Переменных: " + currentN + ", клауз: " + currentClauses.length + ".";
  renderArt(data.art);
  solveCurrent();
}

function parseCnf(text: string): ParsedCnf {
  const clauses: number[][] = [];
  let maxVar = 0;
  const lines = text.split(/\r?\n/);
  for (let lineNo = 0; lineNo < lines.length; lineNo++) {
    const line = lines[lineNo].trim();
    if (!line) continue;
    if (line.startsWith("c")) continue;
    const tokens = line.split(/\s+/).filter(Boolean);
    const clause: number[] = [];
    for (const token of tokens) {
      const value = Number(token);
      if (!Number.isInteger(value)) {
        throw new Error("Строка " + (lineNo + 1) + ": не число: " + token);
      }
      if (value === 0) continue;
      clause.push(value);
      maxVar = Math.max(maxVar, Math.abs(value));
    }
    if (clause.length) clauses.push(clause);
  }
  if (clauses.length === 0) throw new Error("Нет ни одной клаузы.");
  if (maxVar === 0) throw new Error("Нет ни одной переменной.");
  if (maxVar > 20) throw new Error("Слишком много переменных для этой лаборатории: " + maxVar + ".");
  return { n: maxVar, clauses };
}

function solveCnf(clauses: number[][], n: number): SolveResult {
  const assignment = new Array<number>(n + 1).fill(0);
  const trail: Array<{ v: number; level: number }> = [];
  const trace: TraceItem[] = [];
  let decisions = 0;
  let propagations = 0;
  let conflicts = 0;
  let nodes = 0;

  function assign(v: number, value: boolean, level: number): void {
    if (assignment[v] !== 0) return;
    assignment[v] = value ? 1 : -1;
    trail.push({ v, level });
  }

  function undoTo(length: number): void {
    while (trail.length > length) {
      const item = trail.pop();
      if (!item) break;
      assignment[item.v] = 0;
    }
  }

  function litValue(lit: number): number {
    const a = assignment[Math.abs(lit)];
    if (a === 0) return 0;
    return (lit > 0 ? a === 1 : a === -1) ? 1 : -1;
  }

  function clauseState(clause: number[]): { satisfied: boolean; unassigned: number; unassignedLit: number } {
    let satisfied = false;
    let unassigned = 0;
    let unassignedLit = 0;
    for (const lit of clause) {
      const value = litValue(lit);
      if (value === 1) {
        satisfied = true;
        break;
      }
      if (value === 0) {
        unassigned++;
        unassignedLit = lit;
      }
    }
    return { satisfied, unassigned, unassignedLit };
  }

  function propagate(level: number): boolean {
    let changed = true;
    while (changed) {
      changed = false;
      for (const clause of clauses) {
        const st = clauseState(clause);
        if (st.satisfied) continue;
        if (st.unassigned === 0) {
          conflicts++;
          trace.push({ type: "conflict", level, text: "конфликт: " + clauseText(clause) });
          return false;
        }
        if (st.unassigned === 1) {
          const lit = st.unassignedLit;
          const v = Math.abs(lit);
          const value = lit > 0;
          assign(v, value, level);
          propagations++;
          trace.push({ type: "prop", level, text: "x" + v + " = " + (value ? 1 : 0) + " из " + clauseText(clause) });
          changed = true;
        }
      }
    }
    return true;
  }

  function allAssigned(): boolean {
    for (let v = 1; v <= n; v++) if (assignment[v] === 0) return false;
    return true;
  }

  function search(level: number): number[] | null {
    nodes++;
    if (!propagate(level)) return null;
    if (allAssigned()) {
      trace.push({ type: "sat", level, text: "все переменные означены" });
      return assignment.slice();
    }
    let v = 1;
    while (v <= n && assignment[v] !== 0) v++;
    for (const value of [false, true]) {
      const mark = trail.length;
      assign(v, value, level + 1);
      decisions++;
      trace.push({ type: "decision", level: level + 1, text: "x" + v + " = " + (value ? 1 : 0) });
      const result = search(level + 1);
      if (result) return result;
      undoTo(mark);
      trace.push({ type: "backtrack", level: level + 1, text: "откат x" + v });
    }
    return null;
  }

  const model = search(0);
  return { model, decisions, propagations, conflicts, nodes, trace, n };
}

function formatModel(model: number[]): string {
  const parts: string[] = [];
  for (let v = 1; v < model.length; v++) {
    if (model[v] !== 0) parts.push("x" + v + "=" + (model[v] === 1 ? 1 : 0));
  }
  return parts.join(", ");
}

function renderTrace(trace: TraceItem[], upto: number): void {
  clear(traceNode);
  if (!trace.length) {
    traceNode.appendChild(el("div", { class: "muted", text: "Трасса пуста." }));
    traceHint.textContent = "";
    return;
  }
  if (!upto) {
    traceNode.appendChild(
      el("div", { class: "muted", text: "Трасса скрыта. Нажмите «Следующий шаг», чтобы разобрать решение." }),
    );
    traceHint.textContent = "Шаг 0 из " + trace.length + ".";
    traceStepButton.disabled = false;
    traceAllButton.disabled = false;
    return;
  }
  let shown = trace.slice(0, upto);
  let skipped = 0;
  const limit = 420;
  if (shown.length > limit) {
    const half = Math.floor(limit / 2);
    shown = shown.slice(0, half).concat(shown.slice(shown.length - half));
    skipped = upto - limit;
  }
  for (let i = 0; i < shown.length; i++) {
    if (skipped && i === Math.floor(limit / 2)) {
      traceNode.appendChild(el("div", { class: "muted", text: "… пропущено шагов: " + skipped + " …" }));
    }
    const item = shown[i];
    const kind = item.type === "prop" ? "prop" : item.type;
    const label =
      item.type === "prop"
        ? "юнит-пропагация"
        : item.type === "decision"
          ? "ветвление"
          : item.type === "conflict"
            ? "конфликт"
            : item.type === "backtrack"
              ? "откат"
              : "SAT";
    const line = el("div", { class: "ln" });
    line.appendChild(el("span", { class: "lv", text: "@" + item.level }));
    line.appendChild(el("span", { class: "kind " + kind, text: label }));
    line.appendChild(el("span", { text: item.text }));
    traceNode.appendChild(line);
  }
  traceHint.textContent = "Шаг " + upto + " из " + trace.length + ".";
  traceStepButton.disabled = upto >= trace.length;
  traceAllButton.disabled = upto >= trace.length;
}

function renderArt(kind: ArtKind): void {
  clear(artNode);
  if (kind === "pigeon") {
    artNode.appendChild(
      el("p", { class: "small muted", text: "Три птицы, две дырки. Переменная x(i,h): птица i сидит в дырке h." }),
    );
    const table = el("table", { class: "data" });
    const thead = el("thead");
    thead.appendChild(
      el("tr", {}, [
        el("th", { class: "left", text: "птица" }),
        el("th", { text: "дырка 1" }),
        el("th", { text: "дырка 2" }),
      ]),
    );
    table.appendChild(thead);
    const tbody = el("tbody");
    for (let p = 0; p < 3; p++) {
      const row = el("tr");
      row.appendChild(el("td", { class: "left", text: "P" + (p + 1) }));
      for (let h = 0; h < 2; h++) row.appendChild(el("td", { class: "mono", text: "x" + (p * 2 + h + 1) }));
      tbody.appendChild(row);
    }
    table.appendChild(tbody);
    artNode.appendChild(table);
  } else if (kind === "color") {
    artNode.appendChild(
      el("p", { class: "small muted", text: "Треугольник, два цвета. Соседние вершины должны получить разные цвета." }),
    );
    const root = svg("svg", { viewBox: "0 0 320 220", role: "img", "aria-label": "Раскраска треугольника" });
    const pts: Record<number, { x: number; y: number }> = {
      0: { x: 160, y: 34 },
      1: { x: 54, y: 178 },
      2: { x: 266, y: 178 },
    };
    const edges: Array<[number, number]> = [
      [0, 1],
      [1, 2],
      [2, 0],
    ];
    for (const [u, v] of edges) {
      root.appendChild(
        svg("line", { x1: pts[u].x, y1: pts[u].y, x2: pts[v].x, y2: pts[v].y, stroke: "#9d9586", "stroke-width": 2 }),
      );
    }
    const colors = ["#2d5fa8", "#a76a12"];
    for (let v = 0; v < 3; v++) {
      const p = pts[v];
      root.appendChild(
        svg("circle", { cx: p.x, cy: p.y, r: 24, fill: "#fff", stroke: "#7b7366", "stroke-width": 1.5 }),
      );
      root.appendChild(
        svg(
          "text",
          { x: p.x, y: p.y + 5, "text-anchor": "middle", "font-size": 13, "font-weight": 700, fill: "#1d2733" },
          String(v + 1),
        ),
      );
      for (let c = 0; c < 2; c++) {
        const cx = p.x + (c === 0 ? -18 : 18);
        const cy = p.y + 38;
        root.appendChild(svg("circle", { cx, cy, r: 7, fill: colors[c], opacity: 0.85 }));
        root.appendChild(
          svg(
            "text",
            { x: cx, y: cy + 20, "text-anchor": "middle", "font-size": 9, fill: "#5f6d7c" },
            "x" + (v * 2 + c + 1),
          ),
        );
      }
    }
    artNode.appendChild(root);
  } else {
    const ratio = currentRatio === null ? 0 : currentRatio;
    artNode.appendChild(
      el("p", { class: "small muted", text: "Случайная 3-SAT: n = 6, m = 25, отношение m/n = " + fmt(ratio, 2) + "." }),
    );
    const bar = el("div", { class: "gaugeline" });
    const marker = el("div", { class: "gauge-marker" });
    marker.style.left = Math.max(0, Math.min(100, (ratio / 8) * 100)) + "%";
    bar.appendChild(marker);
    artNode.appendChild(bar);
    artNode.appendChild(
      el("div", { class: "gauge-label" }, [
        el("span", { text: "0" }),
        el("span", { text: "порог 4.26" }),
        el("span", { text: "8" }),
      ]),
    );
  }
}

function renderResult(result: SolveResult): void {
  metricsNode.innerHTML = "";
  metricsNode.appendChild(
    el("div", { class: "metric" }, [
      el("span", { class: "k", text: "ветвлений" }),
      el("span", { class: "v", text: String(result.decisions) }),
    ]),
  );
  metricsNode.appendChild(
    el("div", { class: "metric" }, [
      el("span", { class: "k", text: "пропагаций" }),
      el("span", { class: "v", text: String(result.propagations) }),
    ]),
  );
  metricsNode.appendChild(
    el("div", { class: "metric" }, [
      el("span", { class: "k", text: "конфликтов" }),
      el("span", { class: "v", text: String(result.conflicts) }),
    ]),
  );
  metricsNode.appendChild(
    el("div", { class: "metric" }, [
      el("span", { class: "k", text: "узлов" }),
      el("span", { class: "v", text: String(result.nodes) }),
    ]),
  );
  if (result.model) {
    status(resultNode, "SAT. Модель: " + formatModel(result.model), "ok");
  } else {
    status(resultNode, "UNSAT. Все ветки закрыты конфликтом, модели нет.", "bad");
  }
  currentTrace = result.trace;
  tracePos = 0;
  renderTrace(currentTrace, tracePos);
}

function solveCurrent(): void {
  let parsed: ParsedCnf | null = null;
  try {
    parsed = parseCnf(cnfNode.value);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    status(parseStatus, message, "bad");
    status(resultNode, "Формула не разобрана.", "warn");
    metricsNode.innerHTML = "";
    clear(traceNode);
    currentTrace = [];
    tracePos = 0;
    traceHint.textContent = "";
    traceStepButton.disabled = true;
    traceAllButton.disabled = true;
    return;
  }
  if (!parsed) return;
  currentN = parsed.n;
  currentClauses = parsed.clauses;
  status(parseStatus, "Переменных: " + currentN + ", клауз: " + currentClauses.length + ".", "ok");
  const result = solveCnf(currentClauses, currentN);
  renderResult(result);
  renderArt(currentPreset === "random" ? "random" : currentPreset === "color" ? "color" : "pigeon");
}

presetNode.addEventListener("change", () => {
  applyPreset(presetNode.value);
});

must<HTMLButtonElement>("#solve").addEventListener("click", () => {
  solveCurrent();
});

traceStepButton.addEventListener("click", () => {
  if (tracePos < currentTrace.length) {
    tracePos += 1;
    renderTrace(currentTrace, tracePos);
  }
});

traceAllButton.addEventListener("click", () => {
  tracePos = currentTrace.length;
  renderTrace(currentTrace, tracePos);
});

must<HTMLButtonElement>("#trace-reset").addEventListener("click", () => {
  tracePos = 0;
  renderTrace(currentTrace, tracePos);
});

must<HTMLButtonElement>("#again").addEventListener("click", () => {
  presetNode.value = "random";
  applyPreset("random");
});

must<HTMLButtonElement>("#reset").addEventListener("click", () => {
  applyPreset(currentPreset);
});

applyPreset("pigeon");

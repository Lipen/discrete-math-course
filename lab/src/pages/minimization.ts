/* Minimization lab: Karnaugh map, prime implicants and the exact minimum. */

import { clear, el, focusSet, keepFocus, must, setPressed, svg } from "../core/dom";
import { bitsOf, graySeq, mapLayout, mintermOf, popcount, type MapLayout } from "../core/bits";
import { math } from "../core/math";
import { presets, VARIABLES, type Preset } from "../domain/presets";

type Form = "dnf" | "cnf";
type View = "map" | "truth";

interface Cube { fixedMask: number; value: number }
interface Prime extends Cube { covers: number[] }
interface Solution { selected: number[]; terms: number; literals: number; expression: string; mask?: number }
interface Result extends Solution { solutions: Solution[]; solutionIndex: number; essentials: Set<number> }
interface OpenEdges { top: boolean; bottom: boolean; left: boolean; right: boolean }
interface BadgeRequest { group: SVGElement; left: number; top: number; right: number; bottom: number; termNumber: number }
interface SavedSession {
  n: number;
  state: number[];
  xMemory: number[];
  form: Form;
  view: View;
  preset: string;
  solutionIndex: number;
}

const vars = VARIABLES;
const TERM_COUNT = 12;
const TERM_CLASSES = Array.from({ length: TERM_COUNT }, (_, index) => "term-" + index);
const STORAGE_KEY = "dm-lab:minimization:v1";
const STORAGE_TTL = 8 * 60 * 60 * 1000;

let n = 3;
let state = new Array<number>(1 << n).fill(0);
let xMemory = new Array<number>(1 << n).fill(0);
let primes: Prime[] = [];
let lastResult: Result | null = null;
let form: Form = "dnf";
let solutionIndex = 0;
let currentView: View = "map";

function termClass(index: number): string {
  return "term-" + (index % TERM_COUNT);
}

const focus = focusSet((key) => applyPrimeState(key));

const arity = must<HTMLElement>("#arity");
const preset = must<HTMLSelectElement>("#preset");
const mapNode = must<HTMLElement>("#map");
const mapNote = must<HTMLElement>("#map-note");
const mapAxis = must<HTMLElement>("#map-axis");
const primesNode = must<HTMLElement>("#primes");
const resultNode = must<HTMLElement>("#result");
const functionView = must<HTMLElement>("#function-view");
const functionSource = must<HTMLElement>("#function-source");
const resultTitle = must<HTMLElement>("#result-title");
const primesTitle = must<HTMLElement>("#primes-title");
const metricsNode = must<HTMLElement>("#metrics");
const truthTable = must<HTMLTableElement>("#truth-table");
const solutionsNode = must<HTMLElement>("#solutions");
const viewTabs = must<HTMLElement>("#view-tabs");
const formSwitch = must<HTMLElement>("#form-switch");

function markCustom(): void {
  preset.value = "custom";
}

function syncArity(): void {
  for (const button of arity.querySelectorAll<HTMLButtonElement>("button[data-n]")) {
    const active = Number(button.dataset.n) === n;
    button.classList.toggle("active", active);
    button.setAttribute("aria-pressed", String(active));
  }
}

function setArity(next: number): void {
  if (next === n) return;
  n = next;
  state = new Array<number>(1 << n).fill(0);
  xMemory = new Array<number>(1 << n).fill(0);
  markCustom();
  syncArity();
  renderAll();
}

function syncFormSwitch(): void {
  for (const button of formSwitch.querySelectorAll("button")) {
    const active = button.dataset.form === form;
    button.classList.toggle("active", active);
    button.setAttribute("aria-pressed", String(active));
  }
}

function saveSession(): void {
  try {
    sessionStorage.setItem(STORAGE_KEY, JSON.stringify({
      v: 1,
      n,
      state,
      xMemory,
      form,
      view: currentView,
      preset: preset.value,
      solutionIndex,
      savedAt: Date.now(),
    }));
  } catch {
  }
}

function isTriState(values: unknown, size: number): values is number[] {
  return Array.isArray(values) && values.length === size
    && values.every((value) => value === 0 || value === 1 || value === 2);
}

function isBitState(values: unknown, size: number): values is number[] {
  return Array.isArray(values) && values.length === size
    && values.every((value) => value === 0 || value === 1);
}

function readSession(): SavedSession | null {
  try {
    const raw = sessionStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    const parsed: unknown = JSON.parse(raw);
    if (typeof parsed !== "object" || parsed === null) return null;
    const data = parsed as Record<string, unknown>;
    if (data.v !== 1) return null;
    const savedAt = typeof data.savedAt === "number" ? data.savedAt : NaN;
    if (!Number.isFinite(savedAt) || Date.now() - savedAt > STORAGE_TTL) return null;
    const storedN = typeof data.n === "number" ? data.n : NaN;
    if (storedN !== 2 && storedN !== 3 && storedN !== 4 && storedN !== 5) return null;
    const size = 1 << storedN;
    const storedState = data.state;
    if (!isTriState(storedState, size)) return null;
    const storedX = data.xMemory;
    const xMemory = isBitState(storedX, size) ? storedX : new Array<number>(size).fill(0);
    const storedForm = data.form;
    const form: Form = storedForm === "cnf" ? "cnf" : "dnf";
    const storedView = data.view;
    const view: View = storedView === "truth" ? "truth" : "map";
    const storedIndex = data.solutionIndex;
    const solutionIndex = typeof storedIndex === "number" && Number.isInteger(storedIndex) && storedIndex >= 0 ? storedIndex : 0;
    return {
      n: storedN,
      state: storedState,
      xMemory,
      form,
      view,
      preset: typeof data.preset === "string" ? data.preset : "",
      solutionIndex,
    };
  } catch {
    return null;
  }
}

function applyState(ones: number[], xs: number[]): void {
  state = new Array<number>(1 << n).fill(0);
  xMemory = new Array<number>(1 << n).fill(0);
  for (const m of ones) state[m] = 1;
  for (const m of xs) state[m] = 2;
}

function termText(prime: Cube): string {
  if (prime.fixedMask === 0) return "1";
  const parts: string[] = [];
  for (let bit = n - 1; bit >= 0; bit--) {
    if (prime.fixedMask & (1 << bit)) {
      const name = vars[n - 1 - bit];
      parts.push((prime.value & (1 << bit)) ? name : "\\neg " + name);
    }
  }
  return parts.join(" \\cdot ");
}

function matchesPreset(p: Preset): boolean {
  if (p.n !== n) return false;
  const ones = new Set(p.ones);
  const xs = new Set(p.x);
  for (let m = 0; m < (1 << n); m++) {
    const expected = xs.has(m) ? 2 : ones.has(m) ? 1 : 0;
    if (state[m] !== expected) return false;
  }
  return true;
}

function presetLabel(): string {
  const option = preset.selectedOptions[0];
  return option ? option.textContent.trim() : preset.value;
}

function customFormula(): string {
  const ones: number[] = [];
  const xs: number[] = [];
  for (let m = 0; m < state.length; m++) {
    if (state[m] === 1) ones.push(m);
    else if (state[m] === 2) xs.push(m);
  }
  if (ones.length === (1 << n)) return "1";
  const parts: string[] = [];
  if (ones.length === 0) {
    parts.push("0");
  } else if (ones.length <= 4) {
    const allBits = (1 << n) - 1;
    parts.push(ones.map((m) => termText({ fixedMask: allBits, value: m })).join(" \\lor "));
  } else {
    parts.push("\\Sigma m(" + ones.join(",") + ")");
  }
  if (xs.length > 0 && xs.length < (1 << n)) parts.push("\\Sigma X(" + xs.join(",") + ")");
  return parts.join(" \\;+\\; ");
}

function renderFunction(): void {
  const chosen = presets[preset.value];
  const matched = chosen !== undefined && matchesPreset(chosen);
  const line = el("div", { class: "formula-line" });
  line.appendChild(el("span", { class: "formula-prefix" }, math("f =", false)));
  line.appendChild(math(matched ? chosen.formula : customFormula(), false));
  functionView.replaceChildren(line);
  functionSource.textContent = matched
    ? "готовая функция: " + presetLabel()
    : "функция по таблице истинности";
}

function targetValue(): number {
  return form === "dnf" ? 1 : 0;
}

function clauseText(prime: Cube): string {
  if (prime.fixedMask === 0) return "0";
  const literals: string[] = [];
  for (let bit = n - 1; bit >= 0; bit--) {
    if (!(prime.fixedMask & (1 << bit))) continue;
    const name = vars[n - 1 - bit];
    literals.push((prime.value & (1 << bit)) ? "\\neg " + name : name);
  }
  const body = literals.join(" \\lor ");
  return literals.length > 1 ? "\\left( " + body + " \\right)" : body;
}

function gridLayout(): MapLayout {
  if (n === 5) return { n, rowBits: 2, colBits: 2, rows: graySeq(2), cols: graySeq(2) };
  return mapLayout(n);
}

function axisVars(): { row: string[]; col: string[]; layer: string | null } {
  if (n === 5) return { row: ["A", "B"], col: ["C", "D"], layer: "E" };
  const layout = gridLayout();
  const row: string[] = [];
  const col: string[] = [];
  for (let bit = n - 1; bit >= layout.colBits; bit--) row.push(vars[n - 1 - bit]);
  for (let bit = layout.colBits - 1; bit >= 0; bit--) col.push(vars[n - 1 - bit]);
  return { row, col, layer: null };
}

function fullMinterm(inner: number, layer: number | null): number {
  return layer === null ? inner : (inner << 1) | layer;
}

function positiveRuns(codes: number[], bit: number, width: number): Array<[number, number]> {
  const indices: number[] = [];
  for (let i = 0; i < codes.length; i++) {
    if ((codes[i] >> (width - 1 - bit)) & 1) indices.push(i);
  }
  if (!indices.length) return [];
  const runs: Array<[number, number]> = [];
  let first = indices[0];
  let previous = indices[0];
  for (let i = 1; i < indices.length; i++) {
    if (indices[i] !== previous + 1) {
      runs.push([first, previous]);
      first = indices[i];
    }
    previous = indices[i];
  }
  runs.push([first, previous]);
  return runs;
}

function renderKeepingPosition(m: number): void {
  const x = window.scrollX;
  const y = window.scrollY;
  const root = document.documentElement;
  const previousBehavior = root.style.scrollBehavior;
  root.style.scrollBehavior = "auto";
  renderAll();
  const selector = currentView === "truth"
    ? '#truth-table .truth-bit[data-m="' + m + '"]'
    : '.map-cell[data-m="' + m + '"]';
  const next = document.querySelector<HTMLElement>(selector);
  if (next) {
    try { next.focus({ preventScroll: true }); } catch { next.focus(); }
  }
  window.scrollTo(x, y);
  requestAnimationFrame(() => {
    window.scrollTo(x, y);
    requestAnimationFrame(() => {
      window.scrollTo(x, y);
      if (previousBehavior) root.style.scrollBehavior = previousBehavior;
      else root.style.scrollBehavior = "";
    });
  });
}

function toggleMinterm(m: number, shift: boolean): void {
  const value = state[m];
  if (shift) {
    if (value === 2) state[m] = xMemory[m] === 1 ? 1 : 0;
    else {
      xMemory[m] = value;
      state[m] = 2;
    }
  } else {
    state[m] = value === 1 ? 0 : 1;
    xMemory[m] = 0;
  }
  markCustom();
  solutionIndex = 0;
  renderKeepingPosition(m);
}

function coveredMinterms(prime: Cube): number[] {
  const out: number[] = [];
  for (let m = 0; m < (1 << n); m++) {
    if ((m & prime.fixedMask) === prime.value) out.push(m);
  }
  return out;
}

function cubeKey(fixedMask: number, value: number): string { return fixedMask + ":" + value; }

function findPrimes(): Prime[] {
  const target = targetValue();
  const cubes: Prime[] = [];
  const seen = new Set<string>();

  function rec(bit: number, fixedMask: number, value: number): void {
    if (bit === n) {
      const key = cubeKey(fixedMask, value);
      if (!seen.has(key)) {
        seen.add(key);
        cubes.push({ fixedMask, value, covers: [] });
      }
      return;
    }
    rec(bit + 1, fixedMask, value);
    rec(bit + 1, fixedMask | (1 << bit), value);
    rec(bit + 1, fixedMask | (1 << bit), value | (1 << bit));
  }
  rec(0, 0, 0);

  const valid: Prime[] = [];
  for (const cube of cubes) {
    let ok = true;
    let hasOne = false;
    for (let m = 0; m < (1 << n); m++) {
      if ((m & cube.fixedMask) !== cube.value) continue;
      if (state[m] !== target && state[m] !== 2) { ok = false; break; }
      if (state[m] === target) hasOne = true;
    }
    if (ok && hasOne) {
      cube.covers = coveredMinterms(cube);
      valid.push(cube);
    }
  }

  const validKeys = new Set(valid.map((c) => cubeKey(c.fixedMask, c.value)));
  const out: Prime[] = [];
  for (const cube of valid) {
    let isPrime = true;
    for (let bit = 0; bit < n; bit++) {
      if (!(cube.fixedMask & (1 << bit))) continue;
      const key = cubeKey(cube.fixedMask & ~(1 << bit), cube.value & ~(1 << bit));
      if (validKeys.has(key)) { isPrime = false; break; }
    }
    if (isPrime) out.push(cube);
  }
  out.sort((a, b) => a.covers.length - b.covers.length || a.fixedMask - b.fixedMask || a.value - b.value);
  return out;
}

function solutionKey(selected: number[]): string {
  return selected.slice().sort((a, b) => a - b).join(",");
}

function computeMinimum(): Result {
  const target = targetValue();
  const needed: number[] = [];
  for (let m = 0; m < (1 << n); m++) if (state[m] === target) needed.push(m);

  if (needed.length === 0) {
    const expression = form === "dnf" ? "0" : "1";
    const solution: Solution = { selected: [], terms: 0, literals: 0, mask: 0, expression };
    return { selected: [], terms: 0, literals: 0, expression, solutions: [solution], solutionIndex: 0, essentials: new Set<number>() };
  }
  if (primes.length === 0) {
    const solution: Solution = { selected: [], terms: 0, literals: 0, mask: 0, expression: form === "dnf" ? "0" : "1" };
    return { selected: [], terms: 0, literals: 0, expression: solution.expression, solutions: [solution], solutionIndex: 0, essentials: new Set<number>() };
  }

  const limit = 1 << n;
  const coverMask = primes.map((prime) => {
    let mask = 0;
    for (const m of prime.covers) mask |= 1 << m;
    return mask;
  });
  const literalCount = primes.map((prime) => popcount(prime.fixedMask));
  const neededMask = needed.reduce((mask, m) => mask | (1 << m), 0);
  const byMinterm = new Map<number, number[]>();
  for (const m of needed) {
    const covering: number[] = [];
    for (let i = 0; i < primes.length; i++) {
      if (coverMask[i] & (1 << m)) covering.push(i);
    }
    byMinterm.set(m, covering);
  }

  const essentials = new Set<number>();
  for (const m of needed) {
    const covering = byMinterm.get(m) || [];
    if (covering.length === 1) essentials.add(covering[0]);
  }
  const forced = Array.from(essentials).sort((a, b) => a - b);
  let baseCovered = 0;
  let baseLiterals = 0;
  for (const i of forced) {
    baseCovered |= coverMask[i];
    baseLiterals += literalCount[i];
  }
  const baseTerms = forced.length;

  let bestTerms = Infinity;
  let bestLiterals = Infinity;
  let bestKeys: string[] = [];
  const bestSet = new Set<string>();

  function expressionOf(selected: number[]): string {
    return selected
      .map((index) => form === "dnf" ? termText(primes[index]) : clauseText(primes[index]))
      .join(form === "dnf" ? " \\lor " : " \\land ");
  }

  function packed(selected: number[]): number {
    let mask = 0;
    for (const i of selected) mask |= 1 << i;
    return mask;
  }

  function record(selected: number[]): void {
    const terms = selected.length;
    let literals = 0;
    for (const i of selected) literals += literalCount[i];
    const key = solutionKey(selected);
    if (terms < bestTerms || (terms === bestTerms && literals < bestLiterals)) {
      bestTerms = terms;
      bestLiterals = literals;
      bestKeys = [key];
      bestSet.clear();
      bestSet.add(key);
    } else if (terms === bestTerms && literals === bestLiterals && !bestSet.has(key)) {
      bestKeys.push(key);
      bestSet.add(key);
    }
  }

  function greedy(): void {
    let covered = baseCovered;
    const selected = forced.slice();
    const chosen = new Set(selected);
    let remaining = neededMask & ~covered;
    while (remaining) {
      let pick = -1;
      let pickGain = 0;
      let pickLiterals = Infinity;
      for (let i = 0; i < primes.length; i++) {
        if (chosen.has(i)) continue;
        const gain = popcount((coverMask[i] & remaining) >>> 0);
        if (gain > pickGain || (gain === pickGain && literalCount[i] < pickLiterals)) {
          pick = i;
          pickGain = gain;
          pickLiterals = literalCount[i];
        }
      }
      if (pick < 0 || pickGain === 0) return;
      selected.push(pick);
      chosen.add(pick);
      covered |= coverMask[pick];
      remaining = neededMask & ~covered;
    }
    record(selected);
  }

  const memo = new Map<number, { terms: number; literals: number }>();

  function dfs(covered: number, selected: number[], chosen: Set<number>, terms: number, literals: number): void {
    const remaining = neededMask & ~covered;
    if (!remaining) {
      record(selected);
      return;
    }
    if (terms >= bestTerms) return;
    const previous = memo.get(covered);
    if (previous && (previous.terms < terms || (previous.terms === terms && previous.literals < literals))) return;
    if (!previous || terms < previous.terms || (terms === previous.terms && literals < previous.literals)) {
      memo.set(covered, { terms, literals });
    }

    let pickList: number[] | null = null;
    for (let m = 0; m < limit; m++) {
      if (!(remaining & (1 << m))) continue;
      const candidates = (byMinterm.get(m) || []).filter((i) => !chosen.has(i));
      if (!candidates.length) return;
      if (!pickList || candidates.length < pickList.length) pickList = candidates;
    }
    if (!pickList) return;
    pickList.sort((a, b) => {
      const ga = popcount((coverMask[a] & remaining) >>> 0);
      const gb = popcount((coverMask[b] & remaining) >>> 0);
      return gb - ga || literalCount[a] - literalCount[b] || a - b;
    });
    for (const i of pickList) {
      selected.push(i);
      chosen.add(i);
      dfs(covered | coverMask[i], selected, chosen, terms + 1, literals + literalCount[i]);
      selected.pop();
      chosen.delete(i);
    }
  }

  greedy();
  const startSelected = forced.slice();
  dfs(baseCovered, startSelected, new Set(startSelected), baseTerms, baseLiterals);

  if (!bestKeys.length) {
    const solution: Solution = { selected: [], terms: 0, literals: 0, mask: 0, expression: form === "dnf" ? "0" : "1" };
    return { selected: [], terms: 0, literals: 0, expression: solution.expression, solutions: [solution], solutionIndex: 0, essentials };
  }

  const solutions: Solution[] = bestKeys.map((key) => {
    const selected = key ? key.split(",").map(Number) : [];
    return {
      selected,
      terms: selected.length,
      literals: bestLiterals,
      mask: packed(selected),
      expression: expressionOf(selected),
    };
  });
  const index = Math.min(solutionIndex, solutions.length - 1);
  return { ...solutions[index], solutions, solutionIndex: index, essentials };
}

function buildGrid(grid: HTMLElement, layer: number | null): void {
  const layout = gridLayout();
  const axis = axisVars();
  const cols = layout.cols.length;
  grid.style.gridTemplateColumns = "var(--map-cell) repeat(" + cols + ", var(--map-cell))";
  const corner = el("div", { class: "map-corner", text: axis.row.join("") + " / " + axis.col.join("") });
  corner.title = "Строки: " + axis.row.join("") + ", столбцы: " + axis.col.join("");
  grid.appendChild(corner);
  for (const c of layout.cols) {
    const bits = bitsOf(c, layout.colBits);
    const head = el("div", { class: "map-head", text: bits.join("") });
    head.title = axis.col.map((name, index) => name + "=" + bits[index]).join(", ");
    grid.appendChild(head);
  }
  for (const r of layout.rows) {
    const bits = bitsOf(r, layout.rowBits);
    const head = el("div", { class: "map-rowhead", text: bits.join("") });
    head.title = axis.row.map((name, index) => name + "=" + bits[index]).join(", ");
    grid.appendChild(head);
    for (const c of layout.cols) {
      const inner = mintermOf(r, c, layout.colBits);
      const m = fullMinterm(inner, layer);
      const value = state[m];
      const cls = value === 1 ? " v1" : (value === 2 ? " vx" : "");
      const cell = el("div", {
        class: "map-cell" + cls,
        "data-m": String(m),
        role: "button",
        tabindex: "0",
        "aria-label": "минтерм " + m + (layer === null ? "" : ", слой E=" + layer) + ", значение " + (value === 2 ? "X" : value),
        "data-focus-key": "kmap-" + m,
      });
      cell.appendChild(el("span", { class: "idx", text: String(m) }));
      cell.appendChild(el("span", { class: "val", text: value === 2 ? "X" : String(value) }));
      if (value === 2) cell.removeAttribute("aria-pressed");
      else setPressed(cell, value === 1);
      cell.addEventListener("click", (event) => toggleMinterm(m, event.shiftKey));
      cell.addEventListener("keydown", (event) => {
        if (event.key === "Enter" || event.key === " ") {
          event.preventDefault();
          toggleMinterm(m, event.shiftKey);
        }
      });
      grid.appendChild(cell);
    }
  }
}

function makeSheet(layer: number | null): { sheet: HTMLDivElement; top: HTMLDivElement; left: HTMLDivElement; grid: HTMLDivElement } {
  const sheet = el("div", { class: "map-sheet" });
  const top = el("div", { class: "map-anno map-anno-top" });
  const left = el("div", { class: "map-anno map-anno-left" });
  const grid = el("div", { class: "map map-grid" });
  if (layer !== null) grid.dataset.layer = String(layer);
  buildGrid(grid, layer);
  sheet.append(top, left, grid);
  return { sheet, top, left, grid };
}

function renderAxisBars(sheet: HTMLElement, top: HTMLElement, left: HTMLElement, grid: HTMLElement): void {
  const layout = gridLayout();
  const axis = axisVars();
  const track = 18;
  const gap = 4;
  sheet.style.gridTemplateColumns = (axis.row.length * track + gap) + "px auto";
  sheet.style.gridTemplateRows = (axis.col.length * track + gap) + "px auto";
  const colHeads = Array.from(grid.querySelectorAll<HTMLElement>(".map-head"));
  const rowHeads = Array.from(grid.querySelectorAll<HTMLElement>(".map-rowhead"));
  for (let j = 0; j < axis.col.length; j++) {
    const runs = positiveRuns(layout.cols, j, layout.colBits);
    for (const [a, b] of runs) {
      const first = colHeads[a];
      const last = colHeads[b];
      if (!first || !last) continue;
      const bar = el("div", { class: "axis-bar axis-bar-top" });
      bar.style.left = first.offsetLeft + "px";
      bar.style.width = (last.offsetLeft + last.offsetWidth - first.offsetLeft) + "px";
      bar.style.top = (j * track) + "px";
      bar.appendChild(el("span", { class: "axis-bar-label", text: axis.col[j] }));
      top.appendChild(bar);
    }
  }
  for (let j = 0; j < axis.row.length; j++) {
    const runs = positiveRuns(layout.rows, j, layout.rowBits);
    for (const [a, b] of runs) {
      const first = rowHeads[a];
      const last = rowHeads[b];
      if (!first || !last) continue;
      const bar = el("div", { class: "axis-bar axis-bar-left" });
      bar.style.top = first.offsetTop + "px";
      bar.style.height = (last.offsetTop + last.offsetHeight - first.offsetTop) + "px";
      bar.style.left = (j * track) + "px";
      bar.appendChild(el("span", { class: "axis-bar-label", text: axis.row[j] }));
      left.appendChild(bar);
    }
  }
}

function refreshAxisBars(): void {
  for (const sheet of mapNode.querySelectorAll<HTMLElement>(".map-sheet")) {
    const top = sheet.querySelector<HTMLElement>(".map-anno-top");
    const left = sheet.querySelector<HTMLElement>(".map-anno-left");
    const grid = sheet.querySelector<HTMLElement>(".map-grid");
    if (!top || !left || !grid) continue;
    clear(top);
    clear(left);
    renderAxisBars(sheet, top, left, grid);
  }
}

function renderMap(): void {
  clear(mapNode);
  const isLayer = n === 5;
  mapNode.className = isLayer ? "map-layers" : "map-stage";
  mapNode.style.gridTemplateColumns = "";
  if (isLayer) {
    mapAxis.textContent = "Слои: E · Столбцы: CD · строки: AB";
    for (const layer of [0, 1]) {
      const box = el("div", { class: "map-layer" });
      box.appendChild(el("div", { class: "map-layer-label", text: "E = " + layer }));
      const parts = makeSheet(layer);
      box.appendChild(parts.sheet);
      mapNode.appendChild(box);
      renderAxisBars(parts.sheet, parts.top, parts.left, parts.grid);
    }
  } else {
    const axis = axisVars();
    mapAxis.textContent = "Столбцы: " + axis.col.join("") + " · строки: " + axis.row.join("");
    const parts = makeSheet(null);
    mapNode.appendChild(parts.sheet);
    renderAxisBars(parts.sheet, parts.top, parts.left, parts.grid);
  }
  const grouping = form === "dnf" ? "единицы" : "нули";
  let note: string;
  if (n === 5) {
    note = "Два слоя по E. Внутри слоя карта замкнута в тор: верхний край соседний с нижним, левый с правым. Одинаковые клетки слоёв отличаются только переменной E.";
  } else if (n === 4) {
    note = "Карта замкнута в тор: верхний край соседний с нижним, левый с правым.";
  } else {
    note = "Соседние клетки, включая противоположные края, отличаются одной переменной.";
  }
  mapNote.textContent = note + " Для " + (form === "dnf" ? "ДНФ" : "КНФ") + " группируются " + grouping + ".";
}

function renderTruth(): void {
  clear(truthTable);
  const thead = el("thead");
  const headRow = el("tr");
  for (const name of vars.slice(0, n)) headRow.appendChild(el("th", { text: name }));
  headRow.appendChild(el("th", { text: "f" }));
  thead.appendChild(headRow);
  truthTable.appendChild(thead);
  const tbody = el("tbody");
  for (let m = 0; m < (1 << n); m++) {
    const bits = bitsOf(m, n);
    const row = el("tr");
    for (const bit of bits) row.appendChild(el("td", { class: "mono", text: String(bit) }));
    const value = state[m];
    const cell = el("td");
    const button = el("button", {
      class: "truth-bit" + (value === 1 ? " v1" : value === 2 ? " vx" : ""),
      type: "button",
      "data-m": String(m),
      "aria-label": "минтерм " + m + ", значение " + (value === 2 ? "X" : value),
      "data-focus-key": "truth-" + m,
      text: value === 2 ? "X" : String(value),
    });
    if (value === 2) button.removeAttribute("aria-pressed");
    else setPressed(button, value === 1);
    button.addEventListener("click", (event) => toggleMinterm(m, event.shiftKey));
    cell.appendChild(button);
    row.appendChild(cell);
    tbody.appendChild(row);
  }
  truthTable.appendChild(tbody);
}

function applyPrimeState(key: string | null | undefined): void {
  const active = key === null || key === undefined || key === "" ? null : String(key);
  for (const frame of mapNode.querySelectorAll(".k-frame")) {
    const primeKey = frame.getAttribute("data-prime");
    const selected = frame.getAttribute("data-selected") === "true";
    const isActive = active !== null && primeKey === active;
    frame.classList.toggle("is-active", isActive);
    frame.classList.toggle("is-dimmed", active !== null && selected && !isActive);
  }
  for (const cell of mapNode.querySelectorAll(".map-cell")) {
    cell.classList.remove("is-covered", ...TERM_CLASSES);
  }
  if (active === null) return;
  const prime = primes[Number(active)];
  if (!prime) return;
  const cls = termClass(Number(active));
  const seen = new Set<Element>();
  for (const m of prime.covers) {
    for (const cell of mapNode.querySelectorAll('.map-cell[data-m="' + m + '"]')) {
      if (seen.has(cell)) continue;
      seen.add(cell);
      cell.classList.add("is-covered", cls);
    }
  }
}

function cyclicSegments(indices: Set<number>, total: number): Array<[number, number]> {
  if (indices.size === total) return [[0, total - 1]];
  let start = -1;
  for (let i = 0; i < total; i++) {
    if (!indices.has(i) && indices.has((i + 1) % total)) { start = (i + 1) % total; break; }
  }
  if (start < 0) return [[0, total - 1]];
  const sequence: number[] = [];
  let cursor = start;
  while (indices.has(cursor)) {
    sequence.push(cursor);
    cursor = (cursor + 1) % total;
    if (sequence.length > total) break;
  }
  const runs: Array<[number, number]> = [];
  let first = sequence[0];
  let previous = sequence[0];
  for (let i = 1; i < sequence.length; i++) {
    if (sequence[i] !== (previous + 1) % total) {
      runs.push([first, previous]);
      first = sequence[i];
    }
    previous = sequence[i];
  }
  runs.push([first, previous]);
  const out: Array<[number, number]> = [];
  for (const [a, b] of runs) {
    if (a <= b) out.push([a, b]);
    else { out.push([a, total - 1]); out.push([0, b]); }
  }
  return out;
}

function drawFrame(root: Element, left: number, top: number, right: number, bottom: number, open: OpenEdges, options: { primeIndex: number; selected: boolean }): SVGElement {
  const gap = 5;
  const radius = Math.min(8, (right - left) / 2, (bottom - top) / 2);
  const d: string[] = [];
  const segment = (x1: number, y1: number, x2: number, y2: number) => d.push("M " + x1 + " " + y1 + " L " + x2 + " " + y2);
  const arc = (x1: number, y1: number, cx: number, cy: number, x2: number, y2: number) => d.push("M " + x1 + " " + y1 + " Q " + cx + " " + cy + " " + x2 + " " + y2);
  if (!open.top) segment(left + (open.left ? gap : radius), top, right - (open.right ? gap : radius), top);
  if (!open.bottom) segment(left + (open.left ? gap : radius), bottom, right - (open.right ? gap : radius), bottom);
  if (!open.left) segment(left, top + (open.top ? gap : radius), left, bottom - (open.bottom ? gap : radius));
  if (!open.right) segment(right, top + (open.top ? gap : radius), right, bottom - (open.bottom ? gap : radius));
  if (!open.top && !open.left) arc(left + radius, top, left, top, left, top + radius);
  if (!open.top && !open.right) arc(right - radius, top, right, top, right, top + radius);
  if (!open.bottom && !open.right) arc(right, bottom - radius, right, bottom, right - radius, bottom);
  if (!open.bottom && !open.left) arc(left + radius, bottom, left, bottom, left, bottom - radius);

  const group = svg("g", {
    class: "k-frame " + termClass(options.primeIndex),
    "data-prime": String(options.primeIndex),
    "data-selected": options.selected ? "true" : "false",
  });
  const fill = svg("rect", {
    x: left,
    y: top,
    width: right - left,
    height: bottom - top,
    rx: radius,
    class: "k-fill",
  });
  const path = svg("path", { d: d.join(" "), class: "k-stroke" });
  group.append(fill, path);
  root.appendChild(group);
  return group;
}

function addBadge(group: SVGElement, x: number, y: number, termNumber: number): void {
  const badge = svg("circle", { cx: x, cy: y, r: 8, class: "k-badge" });
  const text = svg("text", { x, y: y + 3.5, class: "k-badge-text" });
  text.textContent = String(termNumber);
  group.append(badge, text);
}

function placeBadges(requests: BadgeRequest[]): void {
  const placed: Array<{ x: number; y: number }> = [];
  const pad = 11;
  for (const request of requests) {
    const { group, left, top, right, bottom, termNumber } = request;
    const centerX = (left + right) / 2;
    const centerY = (top + bottom) / 2;
    const candidates: Array<[number, number]> = [
      [right - pad, top + pad],
      [right - pad, bottom - pad],
      [centerX, top + pad],
      [centerX, bottom - pad],
      [left + pad, top + pad],
      [left + pad, bottom - pad],
      [right - pad, centerY],
      [left + pad, centerY],
    ];
    for (let x = left + pad; x <= right - pad + 0.01; x += 18) {
      candidates.push([x, top + pad]);
      candidates.push([x, bottom - pad]);
    }
    let best = candidates[0];
    let bestDistance = -1;
    for (const candidate of candidates) {
      let nearest = Infinity;
      for (const point of placed) {
        nearest = Math.min(nearest, Math.hypot(candidate[0] - point.x, candidate[1] - point.y));
      }
      if (nearest >= 18) {
        best = candidate;
        break;
      }
      if (nearest > bestDistance) {
        bestDistance = nearest;
        best = candidate;
      }
    }
    const x = Math.max(left + 9, Math.min(right - 9, best[0]));
    const y = Math.max(top + 9, Math.min(bottom - 9, best[1]));
    addBadge(group, x, y, termNumber);
    placed.push({ x, y });
  }
}

function renderFrames(result: Result | null): void {
  const grids = Array.from(mapNode.querySelectorAll<HTMLElement>(".map-grid"));
  for (const grid of grids) {
    const old = grid.querySelector(".k-map-overlay");
    if (old) old.remove();
  }
  if (!result) {
    applyPrimeState(focus.activeKey());
    return;
  }

  const layout = gridLayout();
  const rowAt = new Map<number, number>(layout.rows.map((code, index): [number, number] => [code, index]));
  const colAt = new Map<number, number>(layout.cols.map((code, index): [number, number] => [code, index]));
  const selectedOrdinal = new Map<number, number>(result.selected.map((primeIndex, position): [number, number] => [primeIndex, position + 1]));
  const inset = 3;

  for (const grid of grids) {
    const layer: number | null = n === 5 ? Number(grid.dataset.layer) : null;
    const cells = new Map<number, HTMLElement>();
    for (const cell of grid.querySelectorAll<HTMLElement>(".map-cell")) cells.set(Number(cell.dataset.m), cell);
    const width = grid.clientWidth;
    const height = grid.clientHeight;
    if (!width || !height) continue;
    const root = svg("svg", {
      class: "k-map-overlay",
      viewBox: "0 0 " + width + " " + height,
      "aria-hidden": "true",
    });
    const badgeRequests: BadgeRequest[] = [];

    for (let primeIndex = 0; primeIndex < primes.length; primeIndex++) {
      const prime = primes[primeIndex];
      const selected = selectedOrdinal.has(primeIndex);
      const ordinal = selectedOrdinal.get(primeIndex);
      const covers = layer === null ? prime.covers : prime.covers.filter((m) => (m & 1) === layer);
      if (!covers.length) continue;
      const rows = new Set<number>();
      const cols = new Set<number>();
      for (const m of covers) {
        const inner = layer === null ? m : (m >> 1);
        const rowCode = inner >> layout.colBits;
        const colCode = inner & ((1 << layout.colBits) - 1);
        const rowIndex = rowAt.get(rowCode);
        if (rowIndex !== undefined) rows.add(rowIndex);
        const colIndex = colAt.get(colCode);
        if (colIndex !== undefined) cols.add(colIndex);
      }
      const rowSegments = cyclicSegments(rows, layout.rows.length);
      const colSegments = cyclicSegments(cols, layout.cols.length);
      const rowWrap = rowSegments.length > 1;
      const colWrap = colSegments.length > 1;
      let firstSegment = true;
      for (const [r0, r1] of rowSegments) {
        for (const [c0, c1] of colSegments) {
          const firstInner = mintermOf(layout.rows[r0], layout.cols[c0], layout.colBits);
          const lastInner = mintermOf(layout.rows[r1], layout.cols[c1], layout.colBits);
          const first = cells.get(fullMinterm(firstInner, layer));
          const last = cells.get(fullMinterm(lastInner, layer));
          if (!first || !last) continue;
          const left = first.offsetLeft + inset;
          const top = first.offsetTop + inset;
          const right = last.offsetLeft + last.offsetWidth - inset;
          const bottom = last.offsetTop + last.offsetHeight - inset;
          const group = drawFrame(root, left, top, right, bottom, {
            top: rowWrap && r0 === 0,
            bottom: rowWrap && r1 === layout.rows.length - 1,
            left: colWrap && c0 === 0,
            right: colWrap && c1 === layout.cols.length - 1,
          }, { primeIndex, selected });
          if (selected && firstSegment && ordinal !== undefined) {
            badgeRequests.push({ group, left, top, right, bottom, termNumber: ordinal });
          }
          firstSegment = false;
        }
      }
    }
    placeBadges(badgeRequests);
    grid.appendChild(root);
  }
  applyPrimeState(focus.activeKey());
}

function renderPrimes(result: Result): void {
  clear(primesNode);
  if (primes.length === 0) {
    const message = form === "dnf"
      ? "Простых импликант нет: функция равна нулю."
      : "Клауз нет: функция равна единице.";
    primesNode.appendChild(el("p", { class: "muted", text: message }));
    return;
  }
  const table = el("table", { class: "data" });
  const thead = el("thead");
  thead.appendChild(el("tr", {}, [
    el("th", { class: "left", text: form === "dnf" ? "терм" : "клауза" }),
    el("th", { class: "left", text: form === "dnf" ? "покрывает" : "покрывает нули" }),
    el("th", { text: "лит." }),
    el("th", { class: "left", text: "статус" }),
  ]));
  table.appendChild(thead);
  const tbody = el("tbody");
  for (let i = 0; i < primes.length; i++) {
    const p = primes[i];
    const selectedAt = result.selected.indexOf(i);
    const selected = selectedAt >= 0;
    const essential = result.essentials.has(i);
    const row = el("tr", {
      "data-prime": String(i),
      "data-focus-key": "prime-" + i,
      tabindex: "0",
    });
    const termCell = el("td", { class: "left" });
    const swatch = el("span", {
      class: "term-swatch " + termClass(i) + (selected ? "" : " is-empty"),
    });
    if (selected) swatch.textContent = String(selectedAt + 1);
    termCell.appendChild(swatch);
    termCell.appendChild(math(form === "dnf" ? termText(p) : clauseText(p)));
    row.appendChild(termCell);
    row.appendChild(el("td", { class: "left mono small", text: p.covers.join(", ") }));
    row.appendChild(el("td", { class: "mono", text: String(popcount(p.fixedMask)) }));
    const statusCell = el("td", { class: "left" });
    if (essential) statusCell.appendChild(el("span", { class: "pill warn", text: "обязательная" }));
    if (selected) statusCell.appendChild(el("span", { class: "pill ok", text: "в минимуме" }));
    if (!essential && !selected) statusCell.appendChild(el("span", { class: "pill", text: "свободная" }));
    row.appendChild(statusCell);
    focus.bind(row, i);
    tbody.appendChild(row);
  }
  table.appendChild(tbody);
  primesNode.appendChild(table);
}

function renderResult(result: Result): void {
  const isConstant = result.terms === 0;
  resultNode.className = "status " + (isConstant ? (form === "dnf" ? "warn" : "ok") : "ok");
  if (isConstant) {
    resultNode.replaceChildren(math(form === "dnf" ? "f = 0" : "f = 1", false));
  } else {
    const line = el("div", { class: "formula-line" });
    line.appendChild(el("span", { class: "formula-prefix" }, math("f =", false)));
    result.selected.forEach((primeIndex, position) => {
      if (position > 0) line.appendChild(el("span", { class: "formula-or" }, math(form === "dnf" ? "\\lor" : "\\land", false)));
      const term = el("span", {
        class: "formula-term " + termClass(primeIndex),
        "data-prime": String(primeIndex),
        "data-focus-key": "term-" + primeIndex,
        tabindex: "0",
      });
      term.appendChild(el("span", {
        class: "term-no " + termClass(primeIndex),
        text: String(position + 1),
      }));
      term.appendChild(math(form === "dnf" ? termText(primes[primeIndex]) : clauseText(primes[primeIndex]), false));
      focus.bind(term, primeIndex);
      line.appendChild(term);
    });
    resultNode.replaceChildren(line);
  }
  metricsNode.innerHTML = "";
  metricsNode.appendChild(el("div", { class: "metric" }, [
    el("span", { class: "k", text: form === "dnf" ? "термов" : "клауз" }),
    el("span", { class: "v", text: String(result.terms) }),
  ]));
  metricsNode.appendChild(el("div", { class: "metric" }, [
    el("span", { class: "k", text: "литералов" }),
    el("span", { class: "v", text: String(result.literals) }),
  ]));
  metricsNode.appendChild(el("div", { class: "metric" }, [
    el("span", { class: "k", text: "простых" }),
    el("span", { class: "v", text: String(primes.length) }),
  ]));
}

function renderSolutions(result: Result): void {
  clear(solutionsNode);
  if (!result.solutions || result.solutions.length <= 1) {
    solutionsNode.classList.add("hidden");
    return;
  }
  solutionsNode.classList.remove("hidden");
  solutionsNode.appendChild(el("div", {
    class: "solution-meta",
    text: "Вариант " + (result.solutionIndex + 1) + " из " + result.solutions.length,
  }));
  if (result.solutions.length <= 12) {
    const strip = el("div", { class: "solution-strip", role: "tablist", "aria-label": "Равноценные минимальные варианты" });
    result.solutions.forEach((_solution, index) => {
      const dot = el("button", {
        class: "solution-dot" + (index === result.solutionIndex ? " active" : ""),
        type: "button",
        role: "tab",
        "aria-selected": index === result.solutionIndex ? "true" : "false",
        "aria-label": "Вариант " + (index + 1),
        title: "Вариант " + (index + 1),
        text: String(index + 1),
      });
      dot.addEventListener("click", () => {
        solutionIndex = index;
        renderAll(true);
      });
      strip.appendChild(dot);
    });
    solutionsNode.appendChild(strip);
  } else {
    const select = el("select", { class: "solution-select", "aria-label": "Равноценные минимальные варианты" });
    result.solutions.forEach((_solution, index) => {
      select.appendChild(el("option", {
        value: String(index),
        text: "Вариант " + (index + 1),
        selected: index === result.solutionIndex ? "selected" : undefined,
      }));
    });
    select.addEventListener("change", () => {
      solutionIndex = Number(select.value);
      renderAll(true);
    });
    solutionsNode.appendChild(select);
  }
}

function paint(keepSolution?: boolean): void {
  focus.clear();
  if (!keepSolution) solutionIndex = 0;
  resultTitle.textContent = form === "dnf" ? "Минимальная ДНФ" : "Минимальная КНФ";
  primesTitle.textContent = form === "dnf" ? "Простые импликанты" : "Простые импликаты";
  primes = findPrimes();
  renderFunction();
  renderMap();
  renderTruth();
  const result = computeMinimum();
  solutionIndex = result.solutionIndex;
  renderResult(result);
  renderPrimes(result);
  renderSolutions(result);
  renderFrames(result);
  lastResult = result;
  saveSession();
}

function renderAll(keepSolution?: boolean): void {
  keepFocus(() => paint(keepSolution));
}

function setView(view: View): void {
  currentView = view;
  for (const button of viewTabs.querySelectorAll("button")) {
    const active = button.dataset.view === view;
    button.classList.toggle("active", active);
    button.setAttribute("aria-pressed", String(active));
  }
  must("#map-view").classList.toggle("hidden", view !== "map");
  must("#truth-view").classList.toggle("hidden", view !== "truth");
  if (view === "map") {
    requestAnimationFrame(() => {
      refreshAxisBars();
      if (lastResult) renderFrames(lastResult);
    });
  } else {
    renderTruth();
  }
  saveSession();
}

function setForm(next: Form): void {
  form = next;
  solutionIndex = 0;
  syncFormSwitch();
  renderAll();
}

function applyPreset(name: string): void {
  const p = presets[name];
  if (!p) return;
  n = p.n;
  syncArity();
  applyState(p.ones, p.x);
  preset.value = name;
  renderAll();
}

arity.addEventListener("click", (event) => {
  if (!(event.target instanceof Element)) return;
  const button = event.target.closest<HTMLButtonElement>("button[data-n]");
  if (!button) return;
  const next = Number(button.dataset.n);
  if (Number.isInteger(next)) setArity(next);
});

preset.addEventListener("change", () => {
  if (preset.value !== "custom") applyPreset(preset.value);
});

viewTabs.addEventListener("click", (event) => {
  if (!(event.target instanceof Element)) return;
  const button = event.target.closest<HTMLButtonElement>("button[data-view]");
  if (button) setView(button.dataset.view === "truth" ? "truth" : "map");
});

formSwitch.addEventListener("click", (event) => {
  if (!(event.target instanceof Element)) return;
  const button = event.target.closest<HTMLButtonElement>("button[data-form]");
  if (button) setForm(button.dataset.form === "cnf" ? "cnf" : "dnf");
});

must<HTMLButtonElement>("#zero").addEventListener("click", () => {
  state = state.map(() => 0);
  xMemory = state.map(() => 0);
  markCustom();
  renderAll();
});

must<HTMLButtonElement>("#fill").addEventListener("click", () => {
  state = state.map(() => 1);
  xMemory = state.map(() => 0);
  markCustom();
  renderAll();
});

must<HTMLButtonElement>("#reset").addEventListener("click", () => {
  try { sessionStorage.removeItem(STORAGE_KEY); } catch {}
  n = 3;
  syncArity();
  form = "dnf";
  syncFormSwitch();
  solutionIndex = 0;
  applyPreset("maj3");
  setView("map");
});

window.addEventListener("resize", () => {
  if (!lastResult || !mapNode.querySelector(".map-cell")) return;
  refreshAxisBars();
  renderFrames(lastResult);
});

const saved = readSession();
if (saved) {
  n = saved.n;
  syncArity();
  form = saved.form;
  syncFormSwitch();
  state = saved.state.slice();
  xMemory = saved.xMemory.slice();
  solutionIndex = saved.solutionIndex;
  preset.value = Array.from(preset.options).some((option) => option.value === saved.preset)
    ? saved.preset
    : "custom";
  renderAll(true);
  setView(saved.view);
} else {
  setView("map");
  applyPreset("maj3");
}

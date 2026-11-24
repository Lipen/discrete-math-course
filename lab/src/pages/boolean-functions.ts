/* Boolean functions lab: truth table, ANF, Post classes, cube and Karnaugh map. */

import { bitsOf, fmt, mapLayout, mintermOf, popcount } from "../core/bits";
import { activate, clear, el, keepFocus, must, setPressed, status, svg } from "../core/dom";
import { math } from "../core/math";

interface Preset {
  n: number;
  vals: number[];
}

interface PostClasses {
  t0: boolean;
  t1: boolean;
  selfDual: boolean;
  monotone: boolean;
  linear: boolean;
}

const presets: Record<string, Preset> = {
  and2: { n: 2, vals: [0, 0, 0, 1] },
  or2: { n: 2, vals: [0, 1, 1, 1] },
  xor2: { n: 2, vals: [0, 1, 1, 0] },
  nand2: { n: 2, vals: [1, 1, 1, 0] },
  nor2: { n: 2, vals: [1, 0, 0, 0] },
  impl2: { n: 2, vals: [1, 1, 0, 1] },
  maj3: { n: 3, vals: [0, 0, 0, 1, 0, 1, 1, 1] },
  parity3: { n: 3, vals: [0, 1, 1, 0, 1, 0, 0, 1] },
};

let n = 3;
let values = presets.maj3.vals.slice();
const vars = ["A", "B", "C", "D"];

const arity = must<HTMLSelectElement>("#arity");
const preset = must<HTMLSelectElement>("#preset");
const tableNode = must<HTMLElement>("#table");
const vectorNode = must<HTMLElement>("#vector");
const metricsNode = must<HTMLElement>("#metrics");
const anfNode = must<HTMLElement>("#anf");
const postNode = must<HTMLElement>("#post");
const verdictNode = must<HTMLElement>("#verdict");
const cubeNode = must<HTMLElement>("#cube");
const cubeHint = must<HTMLElement>("#cube-hint");
const mapNode = must<HTMLElement>("#map");
const mapNote = must<HTMLElement>("#map-note");

function markCustom(): void {
  preset.value = "custom";
}

function toggleMinterm(m: number): void {
  values[m] ^= 1;
  markCustom();
  renderAll();
}

function anfCoefficients(): number[] {
  const a = values.slice();
  for (let bit = 0; bit < n; bit++) {
    for (let mask = 0; mask < values.length; mask++) {
      if (mask & (1 << bit)) a[mask] ^= a[mask ^ (1 << bit)];
    }
  }
  return a;
}

function monomialText(mask: number): string {
  if (mask === 0) return "1";
  const parts: string[] = [];
  for (let bit = 0; bit < n; bit++) {
    if (mask & (1 << bit)) parts.push(vars[n - 1 - bit]);
  }
  return parts.join(" \\cdot ");
}

function renderTable(): void {
  clear(tableNode);
  const head = el("tr");
  head.appendChild(el("th", { text: "#" }));
  for (let i = 0; i < n; i++) head.appendChild(el("th", { text: vars[i] }));
  head.appendChild(el("th", { text: "f" }));
  const table = el("table", { class: "data" });
  const thead = el("thead");
  thead.appendChild(head);
  table.appendChild(thead);
  const tbody = el("tbody");
  for (let m = 0; m < (1 << n); m++) {
    const row = el("tr");
    row.appendChild(el("td", { class: "muted small", text: String(m) }));
    for (const bit of bitsOf(m, n)) row.appendChild(el("td", { class: "mono", text: String(bit) }));
    const outCell = el("td");
    const button = el("button", {
      class: "bit" + (values[m] ? " on" : ""),
      text: String(values[m]),
      title: "Переключить значение",
      "aria-label": "f(" + bitsOf(m, n).join("") + ") = " + values[m] + ", переключить",
      "data-focus-key": "bit-" + m,
    });
    setPressed(button, values[m] === 1);
    button.addEventListener("click", () => toggleMinterm(m));
    outCell.appendChild(button);
    row.appendChild(outCell);
    tbody.appendChild(row);
  }
  table.appendChild(tbody);
  tableNode.appendChild(table);
}

function renderVector(): void {
  vectorNode.textContent = "(" + values.join(", ") + ")";
  const ones = values.reduce((s, v) => s + v, 0);
  metricsNode.innerHTML = "";
  metricsNode.appendChild(el("div", { class: "metric" }, [
    el("span", { class: "k", text: "единиц" }), el("span", { class: "v", text: String(ones) }),
  ]));
  metricsNode.appendChild(el("div", { class: "metric" }, [
    el("span", { class: "k", text: "длина" }), el("span", { class: "v", text: String(values.length) }),
  ]));
  metricsNode.appendChild(el("div", { class: "metric" }, [
    el("span", { class: "k", text: "плотность" }), el("span", { class: "v", text: fmt(ones / values.length, 2) }),
  ]));
}

function checkPost(): PostClasses {
  const full = values.length - 1;
  const t0 = values[0] === 0;
  const t1 = values[full] === 1;
  let selfDual = true;
  for (let m = 0; m <= full; m++) {
    if (values[m] === values[full ^ m]) { selfDual = false; break; }
  }
  let monotone = true;
  for (let x = 0; x <= full && monotone; x++) {
    for (let y = 0; y <= full; y++) {
      if ((x & y) === x && values[x] > values[y]) { monotone = false; break; }
    }
  }
  const coeff = anfCoefficients();
  let linear = true;
  for (let mask = 0; mask <= full; mask++) {
    if (popcount(mask) > 1 && coeff[mask] === 1) { linear = false; break; }
  }
  return { t0, t1, selfDual, monotone, linear };
}

function renderPost(): void {
  const post = checkPost();
  const rows: [string, string, boolean, string][] = [
    ["T_0", "T0", post.t0, "сохраняет 0"],
    ["T_1", "T1", post.t1, "сохраняет 1"],
    ["S", "S", post.selfDual, "самодвойственна"],
    ["M", "M", post.monotone, "монотонна"],
    ["L", "L", post.linear, "линейна"],
  ];
  clear(postNode);
  for (const [tex, , ok, title] of rows) {
    const badge = el("span", {
      class: "pill " + (ok ? "ok" : "no"),
      title,
    });
    badge.appendChild(math(tex));
    badge.appendChild(document.createTextNode(ok ? " ✓" : " ✗"));
    postNode.appendChild(badge);
  }
  const outside = rows.filter(([, , ok]) => !ok).map(([, name]) => name);
  if (outside.length === 5) {
    status(verdictNode, "Функция вне всех пяти классов. Одна эта функция образует полный базис.", "ok");
  } else {
    const belongs = 5 - outside.length;
    status(verdictNode, "Функция лежит в " + belongs + " из 5 классов. Вне классов: " + (outside.join(", ") || "ничего") + ". Полного базиса из одной функции нет.", "warn");
  }
}

function renderAnf(): void {
  const coeff = anfCoefficients();
  const terms: number[] = [];
  for (let mask = 0; mask < coeff.length; mask++) if (coeff[mask]) terms.push(mask);
  terms.sort((a, b) => popcount(a) - popcount(b) || a - b);
  const tex = terms.length ? terms.map(monomialText).join(" \\oplus ") : "0";
  clear(anfNode);
  anfNode.appendChild(math(tex));
  const minterms = values.reduce((s, v) => s + v, 0);
  metricsNode.appendChild(el("div", { class: "metric" }, [
    el("span", { class: "k", text: "термов СДНФ" }), el("span", { class: "v", text: String(minterms) }),
  ]));
  metricsNode.appendChild(el("div", { class: "metric" }, [
    el("span", { class: "k", text: "мономов АНФ" }), el("span", { class: "v", text: String(terms.length) }),
  ]));
}

function vertexCoords(m: number): { x: number; y: number } {
  if (n === 2) {
    const [a, b] = bitsOf(m, 2);
    return { x: 70 + 170 * b, y: 250 - 170 * a };
  }
  const [a, b, c] = bitsOf(m, 3);
  return { x: 80 + 150 * b + 105 * c, y: 270 - 160 * a - 70 * c };
}

function renderCube(): void {
  clear(cubeNode);
  if (n === 4) {
    cubeHint.textContent = "Куб размерности 4 не помещается на лист. Карта справа показывает его раскладку, соседние края склеены.";
    cubeNode.appendChild(el("p", { class: "muted small", text: "При n = 4 карта показывает раскладку четырёхмерного куба." }));
    return;
  }
  cubeHint.textContent = "Вершина задаёт минтерм, нажатие переключает значение. Ребро соединяет наборы, различающиеся одним битом.";
  const width = 520;
  const height = 360;
  const root = svg("svg", { viewBox: "0 0 " + width + " " + height, role: "group", "aria-label": "Гиперкуб" });
  const coords: Record<number, { x: number; y: number }> = {};
  for (let m = 0; m < (1 << n); m++) coords[m] = vertexCoords(m);
  for (let m = 0; m < (1 << n); m++) {
    for (let bit = 0; bit < n; bit++) {
      const other = m ^ (1 << bit);
      if (other > m) {
        root.appendChild(svg("line", {
          x1: coords[m].x, y1: coords[m].y, x2: coords[other].x, y2: coords[other].y,
          stroke: "#c8c0b1", "stroke-width": 1.4,
        }));
      }
    }
  }
  for (let m = 0; m < (1 << n); m++) {
    const p = coords[m];
    const group = svg("g", { class: "hc-node", tabindex: "0", style: "cursor:pointer", "data-focus-key": "cube-" + m });
    group.appendChild(svg("circle", {
      cx: p.x, cy: p.y, r: 22,
      fill: values[m] ? "#dbe8fa" : "#ffffff",
      stroke: values[m] ? "#2d5fa8" : "#8c8374",
      "stroke-width": 1.5,
    }));
    group.appendChild(svg("text", {
      x: p.x, y: p.y - 2, "text-anchor": "middle", "font-family": "var(--mono)",
      "font-size": 11, fill: "#1d2733",
    }, bitsOf(m, n).join("")));
    group.appendChild(svg("text", {
      x: p.x, y: p.y + 13, "text-anchor": "middle", "font-size": 11,
      "font-weight": 700, fill: values[m] ? "#2d5fa8" : "#8c8374",
    }, String(values[m])));
    activate(group, () => toggleMinterm(m), "минтерм " + bitsOf(m, n).join("") + ", значение " + values[m] + ", переключить");
    setPressed(group, values[m] === 1);
    root.appendChild(group);
  }
  cubeNode.appendChild(root);
}

function renderMap(): void {
  clear(mapNode);
  const layout = mapLayout(n);
  const cols = layout.cols.length;
  mapNode.style.gridTemplateColumns = "64px repeat(" + cols + ", 64px)";
  mapNode.appendChild(el("div", { class: "map-corner" }));
  for (const c of layout.cols) {
    mapNode.appendChild(el("div", { class: "map-head", text: bitsOf(c, layout.colBits).join("") }));
  }
  for (const r of layout.rows) {
    mapNode.appendChild(el("div", { class: "map-rowhead", text: bitsOf(r, layout.rowBits).join("") }));
    for (const c of layout.cols) {
      const m = mintermOf(r, c, layout.colBits);
      const cell = el("div", {
        class: "map-cell" + (values[m] ? " v1" : ""),
        "data-m": String(m),
        "data-focus-key": "map-" + m,
      });
      cell.appendChild(el("span", { class: "idx", text: String(m) }));
      cell.appendChild(el("span", { class: "val", text: String(values[m]) }));
      activate(cell, () => toggleMinterm(m), "минтерм " + m + ", значение " + values[m] + ", переключить");
      setPressed(cell, values[m] === 1);
      mapNode.appendChild(cell);
    }
  }
  mapNote.textContent = n === 4
    ? "Карта замкнута в тор: верхний край соседний с нижним, левый с правым."
    : "Соседние клетки, включая противоположные края, отличаются одной переменной.";
}

function paint(): void {
  renderTable();
  renderVector();
  renderPost();
  renderAnf();
  renderCube();
  renderMap();
}

function renderAll(): void {
  keepFocus(paint);
}

function applyPreset(name: string): void {
  const p = presets[name];
  if (!p) return;
  n = p.n;
  values = p.vals.slice();
  arity.value = String(n);
  preset.value = name;
  renderAll();
}

arity.addEventListener("change", () => {
  n = Number(arity.value);
  values = Array.from({ length: 1 << n }, () => 0);
  markCustom();
  renderAll();
});

preset.addEventListener("change", () => {
  if (preset.value !== "custom") applyPreset(preset.value);
});

must<HTMLButtonElement>("#zero").addEventListener("click", () => {
  values = values.map(() => 0);
  markCustom();
  renderAll();
});

must<HTMLButtonElement>("#ones").addEventListener("click", () => {
  values = values.map(() => 1);
  markCustom();
  renderAll();
});

must<HTMLButtonElement>("#random").addEventListener("click", () => {
  values = values.map(() => (Math.random() < 0.5 ? 0 : 1));
  markCustom();
  renderAll();
});

renderAll();

/* Sets lab: operations, Venn diagram, identities and the power set. */

import { clear, el, keepFocus, must, setPressed, status, svg } from "../core/dom";
import { math } from "../core/math";
import { ribbon } from "../core/segmented";
import * as Sets from "../domain/sets";

interface Identity {
  id: string;
  name: string;
  tex: string;
  left: (a: boolean, b?: boolean, c?: boolean) => boolean;
  right: (a: boolean, b?: boolean, c?: boolean) => boolean;
}

const identities: Identity[] = [
  {
    id: "de-morgan",
    name: "де Морган: (A ∩ B)ᶜ = Aᶜ ∪ Bᶜ",
    tex: "(A \\cap B)^{c} = A^{c} \\cup B^{c}",
    left: (a, b) => !(a && b),
    right: (a, b) => !a || !b,
  },
  {
    id: "de-morgan-2",
    name: "де Морган: (A ∪ B)ᶜ = Aᶜ ∩ Bᶜ",
    tex: "(A \\cup B)^{c} = A^{c} \\cap B^{c}",
    left: (a, b) => !(a || b),
    right: (a, b) => !a && !b,
  },
  {
    id: "distrib",
    name: "дистрибутивность: A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C)",
    tex: "A \\cap (B \\cup C) = (A \\cap B) \\cup (A \\cap C)",
    left: (a, b, c) => Boolean(a && (b || c)),
    right: (a, b, c) => Boolean((a && b) || (a && c)),
  },
  {
    id: "absorb",
    name: "поглощение: A ∪ (A ∩ B) = A",
    tex: "A \\cup (A \\cap B) = A",
    left: (a, b) => a || Boolean(a && b),
    right: (a) => a,
  },
  {
    id: "diff",
    name: "разность: A ∖ B = A ∩ Bᶜ",
    tex: "A \\setminus B = A \\cap B^{c}",
    left: (a, b) => Boolean(a && !b),
    right: (a, b) => Boolean(a && !b),
  },
];

let n = 6;
let universe = Sets.range(n);
let A = new Set<number>([1, 2, 3]);
let B = new Set<number>([3, 4, 5]);
let C = new Set<number>([2, 5, 6]);

const sizeControl = ribbon(
  must<HTMLElement>("#universe-size"),
  [
    { value: "4", label: "4" },
    { value: "5", label: "5" },
    { value: "6", label: "6" },
    { value: "7", label: "7" },
    { value: "8", label: "8" },
  ],
  "6",
  (value) => {
    n = Number(value);
    normalizeSets();
    renderAll();
  },
);
const opControl = ribbon(
  must<HTMLElement>("#operation"),
  [
    { value: "union", label: "A ∪ B" },
    { value: "inter", label: "A ∩ B" },
    { value: "diff", label: "A ∖ B" },
    { value: "symdiff", label: "A △ B" },
    { value: "compl", label: "Aᶜ" },
    { value: "mix", label: "A ∩ (B ∪ C)" },
  ],
  "mix",
  () => renderAll(),
);
const aGrid = must<HTMLElement>("#a-grid");
const bGrid = must<HTMLElement>("#b-grid");
const cGrid = must<HTMLElement>("#c-grid");
const aSize = must<HTMLElement>("#a-size");
const bSize = must<HTMLElement>("#b-size");
const cSize = must<HTMLElement>("#c-size");
const vennNode = must<HTMLElement>("#venn");
const resultNode = must<HTMLElement>("#result-set");
const metricsNode = must<HTMLElement>("#metrics");
const membershipNode = must<HTMLElement>("#membership");
const identitySelect = must<HTMLSelectElement>("#identity");
const identityFormula = must<HTMLElement>("#identity-formula");
const identityStatus = must<HTMLElement>("#identity-status");
const powerControl = ribbon(
  must<HTMLElement>("#power-set"),
  [
    { value: "A", label: "A" },
    { value: "B", label: "B" },
    { value: "C", label: "C" },
  ],
  "A",
  () => renderPower(),
);
const powerMetrics = must<HTMLElement>("#power-metrics");
const powerList = must<HTMLElement>("#power-list");
const productNode = must<HTMLElement>("#product");

for (const item of identities) identitySelect.appendChild(el("option", { value: item.id, text: item.name }));

function normalizeSets(): void {
  universe = Sets.range(n);
  for (const set of [A, B, C]) {
    for (const value of Array.from(set)) if (value > n) set.delete(value);
  }
}

function operationResult(): Set<number> {
  switch (opControl.value()) {
    case "union":
      return Sets.union(A, B);
    case "inter":
      return Sets.inter(A, B);
    case "diff":
      return Sets.diff(A, B);
    case "symdiff":
      return Sets.symdiff(A, B);
    case "compl":
      return Sets.complement(A, universe);
    case "mix":
      return Sets.inter(A, Sets.union(B, C));
    default:
      return new Set();
  }
}

function operationTex(): string {
  switch (opControl.value()) {
    case "union":
      return "A \\cup B";
    case "inter":
      return "A \\cap B";
    case "diff":
      return "A \\setminus B";
    case "symdiff":
      return "A \\triangle B";
    case "compl":
      return "A^{c}";
    default:
      return "A \\cap (B \\cup C)";
  }
}

function operationLabel(): string {
  switch (opControl.value()) {
    case "union":
      return "A ∪ B";
    case "inter":
      return "A ∩ B";
    case "diff":
      return "A ∖ B";
    case "symdiff":
      return "A △ B";
    case "compl":
      return "Aᶜ";
    default:
      return "A ∩ (B ∪ C)";
  }
}

function renderGrid(node: HTMLElement, set: Set<number>, label: "A" | "B" | "C"): void {
  clear(node);
  for (const value of universe) {
    const active = set.has(value);
    const button = el("button", {
      class: "toggle-chip" + (active ? " on" : ""),
      type: "button",
      text: String(value),
      "aria-label": "Элемент " + value + " множества " + label + (active ? ", выбран" : ", не выбран"),
      "data-focus-key": "set-" + label + "-" + value,
    });
    setPressed(button, active);
    button.addEventListener("click", () => {
      if (set.has(value)) set.delete(value);
      else set.add(value);
      renderAll();
    });
    node.appendChild(button);
  }
  const sizeNode = label === "A" ? aSize : label === "B" ? bSize : cSize;
  sizeNode.textContent = "|" + label + "| = " + set.size;
}

function renderVenn(): void {
  clear(vennNode);
  const width = 540;
  const height = 430;
  const root = svg("svg", { viewBox: "0 0 " + width + " " + height, role: "img", "aria-label": "Диаграмма Венна" });
  const circles = [
    { cx: 190, cy: 175, r: 130, fill: "#2d5fa8", label: "A", lx: 90, ly: 65 },
    { cx: 350, cy: 175, r: 130, fill: "#6a4c93", label: "B", lx: 440, ly: 65 },
    { cx: 270, cy: 300, r: 130, fill: "#0f766e", label: "C", lx: 270, ly: 410 },
  ];
  for (const circle of circles) {
    root.appendChild(
      svg("circle", {
        cx: circle.cx,
        cy: circle.cy,
        r: circle.r,
        fill: circle.fill,
        opacity: 0.1,
        stroke: circle.fill,
        "stroke-width": 1.5,
      }),
    );
    root.appendChild(
      svg(
        "text",
        {
          x: circle.lx,
          y: circle.ly,
          "text-anchor": "middle",
          "font-family": "var(--mono)",
          "font-size": 15,
          "font-weight": 700,
          fill: circle.fill,
        },
        circle.label,
      ),
    );
  }
  const anchors: Record<string, { x: number; y: number }> = {
    "000": { x: 45, y: 42 },
    "100": { x: 100, y: 145 },
    "010": { x: 440, y: 145 },
    "110": { x: 270, y: 100 },
    "001": { x: 270, y: 398 },
    "101": { x: 170, y: 265 },
    "011": { x: 370, y: 265 },
    "111": { x: 270, y: 245 },
  };
  const groups: Record<string, number[]> = {};
  for (const value of universe) {
    const key = (A.has(value) ? "1" : "0") + (B.has(value) ? "1" : "0") + (C.has(value) ? "1" : "0");
    if (!groups[key]) groups[key] = [];
    groups[key].push(value);
  }
  for (const key of Object.keys(groups)) {
    const anchor = anchors[key];
    groups[key].forEach((value, index) => {
      root.appendChild(
        svg("circle", {
          cx: anchor.x + (index % 3) * 17,
          cy: anchor.y + Math.floor(index / 3) * 17,
          r: 7,
          fill: "#fff",
          stroke: "#1d2733",
          "stroke-width": 1,
        }),
      );
      root.appendChild(
        svg(
          "text",
          {
            x: anchor.x + (index % 3) * 17,
            y: anchor.y + 4 + Math.floor(index / 3) * 17,
            "text-anchor": "middle",
            "font-family": "var(--mono)",
            "font-size": 9,
          },
          String(value),
        ),
      );
    });
  }
  vennNode.appendChild(root);
}

function renderMembership(): void {
  clear(membershipNode);
  const result = operationResult();
  const table = el("table", { class: "data" });
  const head = el("tr");
  head.appendChild(el("th", { text: "x" }));
  head.appendChild(el("th", { text: "A" }));
  head.appendChild(el("th", { text: "B" }));
  head.appendChild(el("th", { text: "C" }));
  head.appendChild(el("th", { text: operationLabel() }));
  const thead = el("thead");
  thead.appendChild(head);
  table.appendChild(thead);
  const body = el("tbody");
  for (const value of universe) {
    const tr = el("tr", { class: result.has(value) ? "hl" : "" });
    tr.appendChild(el("td", { class: "mono", text: String(value) }));
    tr.appendChild(el("td", { class: "mono", text: A.has(value) ? "1" : "0" }));
    tr.appendChild(el("td", { class: "mono", text: B.has(value) ? "1" : "0" }));
    tr.appendChild(el("td", { class: "mono", text: C.has(value) ? "1" : "0" }));
    tr.appendChild(el("td", { class: "mono" }, math(result.has(value) ? "1" : "0")));
    body.appendChild(tr);
  }
  table.appendChild(body);
  membershipNode.appendChild(table);
}

function renderIdentity(): void {
  const item = identities.find((entry) => entry.id === identitySelect.value) || identities[0];
  identityFormula.replaceChildren(math(item.tex, false));
  let firstBad: { a: boolean; b: boolean; c: boolean } | null = null;
  for (let pattern = 0; pattern < 8; pattern++) {
    const a = Boolean(pattern & 4);
    const b = Boolean(pattern & 2);
    const c = Boolean(pattern & 1);
    const left = Boolean(item.left(a, b, c));
    const right = Boolean(item.right(a, b, c));
    if (left !== right) {
      firstBad = { a, b, c };
      break;
    }
  }
  if (firstBad) {
    status(
      identityStatus,
      "Не тождество. Контрпример: A=" +
        (firstBad.a ? 1 : 0) +
        ", B=" +
        (firstBad.b ? 1 : 0) +
        ", C=" +
        (firstBad.c ? 1 : 0) +
        ".",
      "bad",
    );
  } else {
    status(identityStatus, "Тождество: обе стороны совпадают на всех восьми вариантах принадлежности.", "ok");
  }
}

function renderPower(): void {
  const which = powerControl.value();
  const set = which === "A" ? A : which === "B" ? B : C;
  const subsets = Sets.powerSet(set);
  powerMetrics.innerHTML = "";
  powerMetrics.appendChild(
    el("div", { class: "metric" }, [
      el("span", { class: "k", text: "|" + which + "|" }),
      el("span", { class: "v", text: String(set.size) }),
    ]),
  );
  powerMetrics.appendChild(
    el("div", { class: "metric" }, [
      el("span", { class: "k", text: "|2^" + which + "|" }),
      el("span", { class: "v", text: String(subsets.length) }),
    ]),
  );
  powerList.textContent = subsets.map((subset) => "{" + subset.join(", ") + "}").join("  ");
}

function renderProduct(): void {
  const pairs: string[] = [];
  for (const a of Sets.list(A)) for (const b of Sets.list(B)) pairs.push("(" + a + ", " + b + ")");
  productNode.textContent = pairs.length ? pairs.join("  ") + "   ·   всего " + pairs.length : "A × B пусто.";
}

function paint(): void {
  renderGrid(aGrid, A, "A");
  renderGrid(bGrid, B, "B");
  renderGrid(cGrid, C, "C");
  renderVenn();
  const result = operationResult();
  resultNode.replaceChildren(math(operationTex() + " = \\{" + Sets.list(result).join(", ") + "\\}", false));
  metricsNode.innerHTML = "";
  metricsNode.appendChild(
    el("div", { class: "metric" }, [
      el("span", { class: "k", text: "результат" }),
      el("span", { class: "v", text: String(result.size) }),
    ]),
  );
  metricsNode.appendChild(
    el("div", { class: "metric" }, [
      el("span", { class: "k", text: "универсум" }),
      el("span", { class: "v", text: String(n) }),
    ]),
  );
  metricsNode.appendChild(
    el("div", { class: "metric" }, [
      el("span", { class: "k", text: "A ∪ B ∪ C" }),
      el("span", { class: "v", text: String(Sets.union(Sets.union(A, B), C).size) }),
    ]),
  );
  renderMembership();
  renderIdentity();
  renderPower();
  renderProduct();
}

function renderAll(): void {
  keepFocus(paint);
}

identitySelect.addEventListener("change", renderIdentity);

must<HTMLButtonElement>("#random").addEventListener("click", () => {
  A = new Set(universe.filter(() => Math.random() < 0.5));
  B = new Set(universe.filter(() => Math.random() < 0.5));
  C = new Set(universe.filter(() => Math.random() < 0.5));
  renderAll();
});

must<HTMLButtonElement>("#reset").addEventListener("click", () => {
  n = 6;
  sizeControl.set("6");
  universe = Sets.range(n);
  A = new Set([1, 2, 3]);
  B = new Set([3, 4, 5]);
  C = new Set([2, 5, 6]);
  renderAll();
});

renderAll();

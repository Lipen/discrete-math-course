/* Functions lab: mapping table, arrows, image/preimage and composition. */

import { clear, el, keepFocus, must, setPressed, status, svg } from "../core/dom";
import { math } from "../core/math";
import { ribbon } from "../core/segmented";
import * as Sets from "../domain/sets";

let m = 4;
let k = 4;
let f: Sets.Mapping = {};
let domainSubset = new Set([1, 2]);
let codomainSubset = new Set([1, 2]);

ribbon(
  must<HTMLElement>("#domain-size"),
  [
    { value: "3", label: "3" },
    { value: "4", label: "4" },
    { value: "5", label: "5" },
  ],
  "4",
  (value) => {
    m = Number(value);
    domainSubset = new Set(Sets.range(m).slice(0, 2));
    resetMapping();
    renderAll();
  },
);
ribbon(
  must<HTMLElement>("#codomain-size"),
  [
    { value: "3", label: "3" },
    { value: "4", label: "4" },
    { value: "5", label: "5" },
  ],
  "4",
  (value) => {
    k = Number(value);
    codomainSubset = new Set(Sets.range(k).slice(0, 2));
    resetMapping();
    renderAll();
  },
);
const mappingNode = must<HTMLElement>("#mapping");
const propertiesNode = must<HTMLElement>("#properties");
const kindNode = must<HTMLElement>("#kind");
const diagramNode = must<HTMLElement>("#diagram");
const domainSubsetNode = must<HTMLElement>("#domain-subset");
const codomainSubsetNode = must<HTMLElement>("#codomain-subset");
const imageNode = must<HTMLElement>("#image");
const preimageNode = must<HTMLElement>("#preimage");
const gPreset = must<HTMLSelectElement>("#g-preset");
const compositionNode = must<HTMLElement>("#composition");
const inverseNode = must<HTMLElement>("#inverse");

function domain(): number[] {
  return Sets.range(m);
}
function codomain(): number[] {
  return Sets.range(k);
}

function resetMapping(): void {
  f = {};
  for (let i = 1; i <= m; i++) f[i] = ((i - 1) % Math.max(1, k - 1)) + 1;
}

function setMapping(preset: string): void {
  if (preset === "bijection") {
    if (m !== k) {
      status(kindNode, "Биекция возможна только при равных размерах домена и кодомена.", "warn");
      return;
    }
    f = {};
    for (let i = 1; i <= m; i++) f[i] = i;
  } else if (preset === "surjection") {
    f = {};
    for (let i = 1; i <= m; i++) f[i] = ((i - 1) % k) + 1;
  } else if (preset === "injection") {
    if (m > k) {
      status(kindNode, "Инъекция невозможна: домен больше кодомена.", "warn");
      return;
    }
    f = {};
    for (let i = 1; i <= m; i++) f[i] = i;
  }
  renderAll();
}

function renderMapping(): void {
  clear(mappingNode);
  const table = el("table", { class: "data" });
  const head = el("tr");
  head.appendChild(el("th", { text: "x" }));
  head.appendChild(el("th", { text: "f(x)" }));
  const thead = el("thead");
  thead.appendChild(head);
  table.appendChild(thead);
  const body = el("tbody");
  for (const x of domain()) {
    const tr = el("tr");
    tr.appendChild(el("td", { class: "mono", text: String(x) }));
    const td = el("td");
    const select = el("select", { "aria-label": "Значение f(" + x + ")", "data-focus-key": "map-" + x });
    for (const y of codomain()) select.appendChild(el("option", { value: String(y), text: String(y) }));
    select.value = String(f[x]);
    select.addEventListener("change", () => {
      f[x] = Number(select.value);
      renderAll();
    });
    td.appendChild(select);
    tr.appendChild(td);
    body.appendChild(tr);
  }
  table.appendChild(body);
  mappingNode.appendChild(table);
}

function renderDiagram(): void {
  clear(diagramNode);
  const width = 520;
  const height = Math.max(320, Math.max(m, k) * 70 + 60);
  const leftX = 90;
  const rightX = 430;
  const leftY = (i: number): number => 50 + i * ((height - 100) / Math.max(1, m - 1));
  const rightY = (j: number): number => 50 + j * ((height - 100) / Math.max(1, k - 1));
  const root = svg("svg", { viewBox: "0 0 " + width + " " + height, role: "img", "aria-label": "Стрелки отображения" });
  const defs = svg("defs");
  const marker = svg("marker", {
    id: "fun-arrow",
    viewBox: "0 0 10 10",
    refX: "9",
    refY: "5",
    markerWidth: "6",
    markerHeight: "6",
    orient: "auto-start-reverse",
  });
  marker.appendChild(svg("path", { d: "M 0 0 L 10 5 L 0 10 z", fill: "#2d5fa8" }));
  defs.appendChild(marker);
  root.appendChild(defs);
  for (const x of domain()) {
    const y = f[x];
    if (y === undefined) continue;
    root.appendChild(
      svg("line", {
        x1: leftX + 25,
        y1: leftY(x - 1),
        x2: rightX - 25,
        y2: rightY(y - 1),
        stroke: "#2d5fa8",
        "stroke-width": 1.5,
        "marker-end": "url(#fun-arrow)",
      }),
    );
  }
  for (const x of domain()) {
    const py = leftY(x - 1);
    root.appendChild(
      svg("circle", { cx: leftX, cy: py, r: 23, fill: "#e8f0fb", stroke: "#2d5fa8", "stroke-width": 1.5 }),
    );
    root.appendChild(
      svg(
        "text",
        {
          x: leftX,
          y: py + 5,
          "text-anchor": "middle",
          "font-family": "var(--mono)",
          "font-size": 13,
          "font-weight": 700,
        },
        String(x),
      ),
    );
  }
  for (const y of codomain()) {
    const py = rightY(y - 1);
    root.appendChild(
      svg("circle", { cx: rightX, cy: py, r: 23, fill: "#efe9f7", stroke: "#6a4c93", "stroke-width": 1.5 }),
    );
    root.appendChild(
      svg(
        "text",
        {
          x: rightX,
          y: py + 5,
          "text-anchor": "middle",
          "font-family": "var(--mono)",
          "font-size": 13,
          "font-weight": 700,
        },
        String(y),
      ),
    );
  }
  diagramNode.appendChild(root);
}

function renderProperties(): Sets.FunctionProps {
  const props = Sets.functionProps(f, domain(), codomain());
  clear(propertiesNode);
  propertiesNode.appendChild(
    el("span", {
      class: "pill " + (props.injective ? "ok" : "no"),
      text: "инъекция" + (props.injective ? " ✓" : " ✗"),
    }),
  );
  propertiesNode.appendChild(
    el("span", {
      class: "pill " + (props.surjective ? "ok" : "no"),
      text: "сюръекция" + (props.surjective ? " ✓" : " ✗"),
    }),
  );
  propertiesNode.appendChild(
    el("span", { class: "pill " + (props.bijective ? "ok" : "no"), text: "биекция" + (props.bijective ? " ✓" : " ✗") }),
  );
  if (props.bijective) status(kindNode, "Биекция: у отображения есть обратное.", "ok");
  else if (props.injective)
    status(kindNode, "Инъекция, но не сюръекция. Осталось попасть в пропущенные элементы кодомена.", "warn");
  else if (props.surjective)
    status(kindNode, "Сюръекция, но не инъекция. Есть склейки: разные x дают один образ.", "warn");
  else status(kindNode, "Ни инъекция, ни сюръекция. Есть и склейки, и пропуски.", "bad");
  return props;
}

function renderSubsets(): void {
  clear(domainSubsetNode);
  for (const x of domain()) {
    const button = el("button", {
      class: "toggle-chip" + (domainSubset.has(x) ? " on" : ""),
      type: "button",
      text: String(x),
      "aria-label": "Элемент домена " + x + (domainSubset.has(x) ? ", выбран" : ", не выбран"),
      "data-focus-key": "dom-" + x,
    });
    setPressed(button, domainSubset.has(x));
    button.addEventListener("click", () => {
      if (domainSubset.has(x)) domainSubset.delete(x);
      else domainSubset.add(x);
      renderAll();
    });
    domainSubsetNode.appendChild(button);
  }
  clear(codomainSubsetNode);
  for (const y of codomain()) {
    const button = el("button", {
      class: "toggle-chip" + (codomainSubset.has(y) ? " on" : ""),
      type: "button",
      text: String(y),
      "aria-label": "Элемент кодомена " + y + (codomainSubset.has(y) ? ", выбран" : ", не выбран"),
      "data-focus-key": "cod-" + y,
    });
    setPressed(button, codomainSubset.has(y));
    button.addEventListener("click", () => {
      if (codomainSubset.has(y)) codomainSubset.delete(y);
      else codomainSubset.add(y);
      renderAll();
    });
    codomainSubsetNode.appendChild(button);
  }
  const image = Sets.image(f, domainSubset);
  imageNode.replaceChildren(math("f(A) = \\{" + Sets.list(image).join(", ") + "\\}", false));
  const preimage = Sets.preimage(f, codomainSubset);
  preimageNode.replaceChildren(math("f^{-1}(B) = \\{" + Sets.list(preimage).join(", ") + "\\}", false));
}

function renderComposition(): void {
  const g: Sets.Mapping = {};
  const values = codomain();
  if (gPreset.value === "identity") {
    for (const y of values) g[y] = y;
  } else if (gPreset.value === "cycle") {
    values.forEach((y, index) => {
      g[y] = values[(index + 1) % values.length];
    });
  } else if (gPreset.value === "swap") {
    for (const y of values) g[y] = y;
    if (values.length >= 2) {
      g[values[0]] = values[1];
      g[values[1]] = values[0];
    }
  } else {
    for (const y of values) g[y] = 1;
  }
  const composed = Sets.compose(f, g, domain());
  const parts = domain().map((x) => x + " \\mapsto " + String(composed[x]));
  compositionNode.replaceChildren(math("g \\circ f: " + parts.join(",\\ ") + "", false));
  const props = Sets.functionProps(f, domain(), codomain());
  if (props.bijective) {
    const inv = Sets.invert(f, domain());
    const entries = Object.keys(inv)
      .map(Number)
      .sort((a, b) => a - b)
      .map((y) => y + " \\mapsto " + String(inv[y]));
    inverseNode.replaceChildren(math("f^{-1}: " + entries.join(",\\ "), false));
  } else {
    inverseNode.textContent = "Обратной функции нет: отображение не биективно.";
  }
}

function paint(): void {
  renderMapping();
  renderDiagram();
  renderProperties();
  renderSubsets();
  renderComposition();
}

function renderAll(): void {
  keepFocus(paint);
}

must<HTMLButtonElement>("#bijection").addEventListener("click", () => setMapping("bijection"));
must<HTMLButtonElement>("#surjection").addEventListener("click", () => setMapping("surjection"));
must<HTMLButtonElement>("#injection").addEventListener("click", () => setMapping("injection"));
must<HTMLButtonElement>("#reset").addEventListener("click", () => {
  resetMapping();
  renderAll();
});
gPreset.addEventListener("change", renderComposition);

resetMapping();
renderAll();

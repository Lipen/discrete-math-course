/* Ordinals lab: compare ordinals, show their normal form and fundamental sequences. */

import { clear, el, keepFocus, must, status } from "../core/dom";
import { math } from "../core/math";

interface Ordinal {
  tex: string;
  kind: "zero" | "successor" | "limit";
  seq: string[];
}

const ordinals: Ordinal[] = [
  { tex: "0", kind: "zero", seq: [] },
  { tex: "1", kind: "successor", seq: [] },
  { tex: "2", kind: "successor", seq: [] },
  { tex: "3", kind: "successor", seq: [] },
  { tex: "\\omega", kind: "limit", seq: ["0", "1", "2", "3", "\\ldots"] },
  { tex: "\\omega + 1", kind: "successor", seq: [] },
  { tex: "\\omega + 2", kind: "successor", seq: [] },
  { tex: "\\omega \\cdot 2", kind: "limit", seq: ["\\omega", "\\omega + 1", "\\omega + 2", "\\ldots"] },
  { tex: "\\omega \\cdot 2 + 1", kind: "successor", seq: [] },
  { tex: "\\omega \\cdot 3", kind: "limit", seq: ["\\omega \\cdot 2", "\\omega \\cdot 2 + 1", "\\ldots"] },
  { tex: "\\omega^2", kind: "limit", seq: ["\\omega", "\\omega \\cdot 2", "\\omega \\cdot 3", "\\ldots"] },
  { tex: "\\omega^2 + 1", kind: "successor", seq: [] },
  { tex: "\\omega^2 + \\omega", kind: "limit", seq: ["\\omega^2", "\\omega^2 + 1", "\\omega^2 + 2", "\\ldots"] },
  { tex: "\\omega^2 \\cdot 2", kind: "limit", seq: ["\\omega^2", "\\omega^2 + \\omega", "\\omega^2 + \\omega \\cdot 2", "\\ldots"] },
  { tex: "\\omega^\\omega", kind: "limit", seq: ["\\omega", "\\omega^2", "\\omega^3", "\\ldots"] },
  { tex: "\\omega^\\omega + 1", kind: "successor", seq: [] },
];

const aSelect = must<HTMLSelectElement>("#a-select");
const bSelect = must<HTMLSelectElement>("#b-select");
const ladder = must<HTMLElement>("#ladder");
const aFormula = must<HTMLElement>("#a-formula");
const bFormula = must<HTMLElement>("#b-formula");
const aStatus = must<HTMLElement>("#a-status");
const bStatus = must<HTMLElement>("#b-status");
const compareNode = must<HTMLElement>("#compare");
const sequenceNode = must<HTMLElement>("#sequence");
const cardinalNode = must<HTMLElement>("#cardinal");

function plainOrdinal(tex: string): string {
  return tex.replace(/\\omega/g, "ω").replace(/\\cdot/g, "·").replace(/\\ldots/g, "…").replace(/\\/g, "");
}

ordinals.forEach((ordinal, index) => {
  aSelect.appendChild(el("option", { value: String(index), text: plainOrdinal(ordinal.tex) }));
  bSelect.appendChild(el("option", { value: String(index), text: plainOrdinal(ordinal.tex) }));
});
aSelect.value = "4";
bSelect.value = "5";

function renderLadder(): void {
  clear(ladder);
  ordinals.forEach((ordinal, index) => {
    const card = el("button", {
      class: "ordinal-card" + (String(index) === aSelect.value ? " selected-a" : "") + (String(index) === bSelect.value ? " selected-b" : ""),
      type: "button",
      "data-focus-key": "ordinal-" + index,
    });
    const mark = el("span", { class: "ordinal-mark" });
    mark.appendChild(math(ordinal.tex, false));
    card.appendChild(mark);
    card.appendChild(el("span", { class: "ordinal-kind", text: ordinal.kind === "limit" ? "предел" : (ordinal.kind === "zero" ? "нуль" : "следующий") }));
    card.appendChild(el("span", { class: "ordinal-index", text: "#" + index }));
    card.addEventListener("click", (event) => {
      if (event.shiftKey) bSelect.value = String(index);
      else aSelect.value = String(index);
      renderAll();
    });
    ladder.appendChild(card);
  });
}

function renderSelected(select: HTMLSelectElement, formulaNode: HTMLElement, statusNode: HTMLElement): Ordinal {
  const ordinal = ordinals[Number(select.value)];
  formulaNode.replaceChildren(math(ordinal.tex, false));
  if (ordinal.kind === "limit") status(statusNode, "Предельный ординал: непосредственного предшественника нет.", "info");
  else if (ordinal.kind === "zero") status(statusNode, "Нуль: наименьший ординал.", "warn");
  else status(statusNode, "Следующий ординал: есть непосредственный предшественник.", "ok");
  return ordinal;
}

function renderSequence(ordinal: Ordinal): void {
  clear(sequenceNode);
  if (!ordinal.seq.length) {
    sequenceNode.appendChild(el("p", { class: "hint", text: "Для этого ординала фундаментальная последовательность не нужна: он не предельный." }));
    return;
  }
  const row = el("div", { class: "seq" });
  for (const item of ordinal.seq) {
    const chip = el("span", { class: "seq-item" });
    chip.appendChild(math(item, false));
    row.appendChild(chip);
  }
  sequenceNode.appendChild(row);
  sequenceNode.appendChild(el("p", { class: "hint", text: "Предел этой возрастающей последовательности и есть выбранный ординал." }));
}

function paint(): void {
  const a = ordinals[Number(aSelect.value)];
  renderLadder();
  renderSelected(aSelect, aFormula, aStatus);
  renderSelected(bSelect, bFormula, bStatus);
  const ai = Number(aSelect.value);
  const bi = Number(bSelect.value);
  if (ai === bi) status(compareNode, "A и B совпадают.", "warn");
  else if (ai < bi) status(compareNode, "A < B. В порядке A стоит раньше B.", "ok");
  else status(compareNode, "A > B. В порядке A стоит позже B.", "ok");
  renderSequence(a);
  cardinalNode.replaceChildren(math("|A| = \\aleph_0", false));
}

function renderAll(): void {
  keepFocus(paint);
}

aSelect.addEventListener("change", renderAll);
bSelect.addEventListener("change", renderAll);
must<HTMLButtonElement>("#swap").addEventListener("click", () => {
  const value = aSelect.value;
  aSelect.value = bSelect.value;
  bSelect.value = value;
  renderAll();
});

renderAll();

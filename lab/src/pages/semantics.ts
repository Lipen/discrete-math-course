/* Semantics lab: models of the premises, entailment and counterexamples. */

import { clear, el, must, status } from "../core/dom";
import { math } from "../core/math";
import * as Logic from "../domain/logic";

interface Preset { name: string; premises: string[]; conclusion: string }

const presets: Preset[] = [
  { name: "modus ponens", premises: ["A → B", "A"], conclusion: "B" },
  { name: "modus tollens", premises: ["A → B", "¬B"], conclusion: "¬A" },
  { name: "гипотетический силлогизм", premises: ["A → B", "B → C"], conclusion: "A → C" },
  { name: "дизъюнктивный силлогизм", premises: ["A ∨ B", "¬A"], conclusion: "B" },
  { name: "обратная импликация", premises: ["A → B", "B"], conclusion: "A" },
  { name: "ошибка дизъюнкции", premises: ["A ∨ B", "A"], conclusion: "¬B" },
  { name: "де Морган", premises: ["¬(A ∧ B)", "A"], conclusion: "¬B" },
];

const premisesInput = must<HTMLTextAreaElement>("#premises");
const conclusionInput = must<HTMLInputElement>("#conclusion");
const checkButton = must<HTMLButtonElement>("#check");
const presetsNode = must<HTMLElement>("#presets");
const sequentNode = must<HTMLElement>("#sequent");
const statusNode = must<HTMLElement>("#status");
const tableNode = must<HTMLElement>("#table");
const modelsNode = must<HTMLElement>("#models");

function parseInputs(): { premises: Logic.PropAst[]; conclusion: Logic.PropAst } {
  const lines = premisesInput.value.split(/\r?\n/).map((line) => line.trim()).filter(Boolean);
  if (!lines.length) throw new Error("Нужна хотя бы одна посылка.");
  return {
    premises: lines.map((line) => Logic.parse(line)),
    conclusion: Logic.parse(conclusionInput.value),
  };
}

function render(): void {
  let parsed: { premises: Logic.PropAst[]; conclusion: Logic.PropAst };
  try {
    parsed = parseInputs();
  } catch (error) {
    status(statusNode, error instanceof Error ? error.message : String(error), "bad");
    clear(tableNode);
    clear(modelsNode);
    sequentNode.textContent = "...";
    return;
  }
  const result = Logic.entails(parsed.premises, parsed.conclusion);
  const all = parsed.premises.map((ast) => Logic.toTex(ast)).join(",\\; ");
  sequentNode.replaceChildren(math(all + " \\models " + Logic.toTex(parsed.conclusion), false));

  if (result.holds) {
    status(statusNode, "Следствие есть: на каждом наборе, где посылки истинны, заключение истинно.", "ok");
  } else {
    const ce = result.counterexample;
    if (ce) {
      const bits = result.vars.map((name, i) => name + "=" + ce.bits[i]).join(", ");
      status(statusNode, "Следствия нет. Контрпример: " + bits + ". Посылки истинны, заключение ложно.", "bad");
    }
  }

  clear(tableNode);
  const table = el("table", { class: "data" });
  const head = el("tr");
  for (const name of result.vars) head.appendChild(el("th", { text: name }));
  parsed.premises.forEach((_, index) => head.appendChild(el("th", { text: "P" + (index + 1) })));
  head.appendChild(el("th", { text: "φ" }));
  const thead = el("thead");
  thead.appendChild(head);
  table.appendChild(thead);
  const body = el("tbody");
  for (const row of result.rows) {
    const allTrue = row.premises.every(Boolean);
    const bad = allTrue && !row.conclusion;
    const tr = el("tr", { class: bad ? "bad-row" : (allTrue ? "hl" : "") });
    for (const bit of row.bits) tr.appendChild(el("td", { class: "mono", text: String(bit) }));
    for (const value of row.premises) tr.appendChild(el("td", { class: "mono" }, math(value ? "1" : "0")));
    tr.appendChild(el("td", { class: "mono" }, math(row.conclusion ? "1" : "0")));
    body.appendChild(tr);
  }
  table.appendChild(body);
  tableNode.appendChild(table);

  clear(modelsNode);
  const models = result.rows.filter((row) => row.premises.every(Boolean));
  const trueModels = models.filter((row) => row.conclusion);
  modelsNode.appendChild(el("div", { class: "metric-row" }, [
    el("div", { class: "metric" }, [el("span", { class: "k", text: "моделей посылок" }), el("span", { class: "v", text: String(models.length) })]),
    el("div", { class: "metric" }, [el("span", { class: "k", text: "с заключением" }), el("span", { class: "v", text: String(trueModels.length) })]),
    el("div", { class: "metric" }, [el("span", { class: "k", text: "всего строк" }), el("span", { class: "v", text: String(result.rows.length) })]),
  ]));
  if (!models.length) modelsNode.appendChild(el("p", { class: "hint", text: "Посылки несовместны: моделей нет, поэтому следствие выполняется." }));
}

function applyPreset(preset: Preset): void {
  premisesInput.value = preset.premises.join("\n");
  conclusionInput.value = preset.conclusion;
  render();
}

for (const preset of presets) {
  const button = el("button", { type: "button", text: preset.name });
  button.addEventListener("click", () => applyPreset(preset));
  presetsNode.appendChild(button);
}

checkButton.addEventListener("click", render);
premisesInput.addEventListener("input", render);
conclusionInput.addEventListener("input", render);

applyPreset(presets[0]);

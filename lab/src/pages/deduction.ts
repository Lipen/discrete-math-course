/* Natural deduction lab: a Fitch-style proof editor with nested subproofs. */

import { clear, el, must, status } from "../core/dom";
import { math } from "../core/math";
import * as Logic from "../domain/logic";

interface Exercise {
  title: string;
  premises: string[];
  goal: string;
}
interface Rule {
  id: string;
  label: string;
}

interface Line {
  ast: Logic.PropAst | null;
  formula: string;
  rule: string;
  refs: number[];
  refsRaw?: string;
  refsError?: string;
  depth: number;
  lemmaTitle?: string;
}

interface Candidate {
  ast?: Logic.PropAst | null;
  formula: string;
  rule: string;
  refs?: number[];
  depth: number;
}

interface Source {
  line: Line;
  ast: Logic.PropAst;
}

type StepStatus = "ok" | "warning" | "error";

interface Validity {
  status: StepStatus;
  ok: boolean;
  warning?: string;
  error?: string;
}

interface Draft {
  ast: Logic.PropAst | null;
  formula: string;
  rule: string;
  refs: number[];
  refsRaw?: string;
  refsError?: string;
  depth: number;
  title: string;
}

type ComposerMode = "add" | "edit" | "subproof" | "close";

interface Composer {
  mode: ComposerMode;
  at: number;
  depth: number;
  formula: string;
  rule: string;
  refsText: string;
  title?: string;
  index?: number;
  draft?: Draft;
}

interface ComposerOptions {
  at: number;
  depth: number;
  formula?: string;
  rule?: string;
  refsText?: string;
  title?: string;
  index?: number;
}

const exercises: Exercise[] = [
  { title: "modus ponens", premises: ["A → B", "A"], goal: "B" },
  { title: "конъюнкция", premises: ["A ∧ B"], goal: "B ∧ A" },
  { title: "тождество", premises: [], goal: "A → A" },
  { title: "modus tollens", premises: ["A → B", "¬B"], goal: "¬A" },
  { title: "дизъюнкция", premises: ["A"], goal: "A ∨ B" },
  { title: "цепочка", premises: ["A → B", "B → C"], goal: "A → C" },
  { title: "RAA", premises: ["¬A → B", "¬A → ¬B"], goal: "A" },
];

const rules: Rule[] = [
  { id: "assumption", label: "допущение" },
  { id: "reiterate", label: "повтор" },
  { id: "andi", label: "∧I" },
  { id: "ande", label: "∧E" },
  { id: "ori", label: "∨I" },
  { id: "implE", label: "→E" },
  { id: "implI", label: "→I" },
  { id: "notE", label: "¬E" },
  { id: "notI", label: "¬I" },
  { id: "botE", label: "⊥E" },
  { id: "iffE", label: "↔E" },
  { id: "raa", label: "RAA" },
];

const ruleById = new Map(rules.map((rule): [string, Rule] => [rule.id, rule]));
let current: Exercise = exercises[0];
let lines: Line[] = [];
let history: Line[][] = [];
let composer: Composer | null = null;

const exerciseSelect = must<HTMLSelectElement>("#exercise");
const goalNode = must<HTMLElement>("#goal");
const proofNode = must<HTMLElement>("#proof");
const statusNode = must<HTMLElement>("#status");
const countNode = must<HTMLElement>("#proof-count");
const undoButton = must<HTMLButtonElement>("#undo");
const addRowButton = must<HTMLButtonElement>("#add-row");
const addSubproofButton = must<HTMLButtonElement>("#add-subproof");
const resetButton = must<HTMLButtonElement>("#reset");

exercises.forEach((exercise, index) => {
  exerciseSelect.appendChild(el("option", { value: String(index), text: exercise.title + "   ⊢ " + exercise.goal }));
});

function errorText(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}

function cloneLines(): Line[] {
  return lines.map((line) => ({ ...line, refs: line.refs.slice() }));
}

function pushHistory(): void {
  history.push(cloneLines());
  if (history.length > 60) history.shift();
  updateUndo();
}

function updateUndo(): void {
  undoButton.disabled = history.length === 0;
}

function parse(text: string): Logic.PropAst {
  return Logic.parse(text);
}

function same(a: unknown, b: unknown): boolean {
  return JSON.stringify(a) === JSON.stringify(b);
}

function texOf(ast: Logic.PropAst): string {
  return Logic.toTex(ast);
}

function refsLabel(refs: number[]): string {
  if (!refs.length) return "·";
  const parts: string[] = [];
  let start = refs[0];
  let prev = refs[0];
  for (let i = 1; i < refs.length; i++) {
    const value = refs[i];
    if (value === prev + 1) {
      prev = value;
      continue;
    }
    parts.push(start === prev ? String(start) : start + "-" + prev);
    start = prev = value;
  }
  parts.push(start === prev ? String(start) : start + "-" + prev);
  return parts.join(", ");
}

function parseRefs(text: string): number[] {
  const out: number[] = [];
  for (const token of String(text || "")
    .split(",")
    .map((item) => item.trim())
    .filter(Boolean)) {
    if (token.includes("-")) {
      const [a, b] = token.split("-").map(Number);
      if (!Number.isInteger(a) || !Number.isInteger(b) || a > b || a < 1)
        throw new Error("Плохой диапазон ссылок: " + token);
      for (let i = a; i <= b; i++) out.push(i);
    } else {
      const value = Number(token);
      if (!Number.isInteger(value) || value < 1) throw new Error("Плохая ссылка: " + token);
      out.push(value);
    }
  }
  return out;
}

function contiguous(refs: number[]): boolean {
  for (let i = 1; i < refs.length; i++) if (refs[i] !== refs[i - 1] + 1) return false;
  return true;
}

class StepError extends Error {
  readonly kind: "warning";

  constructor(kind: "warning", message: string) {
    super(message);
    this.kind = kind;
  }
}

function stepWarn(message: string): never {
  throw new StepError("warning", message);
}

function validate(candidate: Candidate, previous: Line[]): { ast: Logic.PropAst } {
  const ast = candidate.ast || parse(candidate.formula);
  const depth = Number(candidate.depth);
  const refs = candidate.refs || [];
  function source(number: number): Source {
    if (!Number.isInteger(number) || number < 1 || number > previous.length)
      throw new Error("Ссылка на несуществующую строку.");
    const line = previous[number - 1];
    if (!line.ast) stepWarn("Ссылка на строку " + number + " без разобранной формулы.");
    return { line, ast: line.ast };
  }
  function accessible(number: number, sourceLine: Source): Source {
    for (let i = number; i < previous.length; i++) {
      if (previous[i].depth < sourceLine.line.depth)
        throw new Error("Ссылка на строку " + number + " уже закрыта: подвывод закончился раньше.");
    }
    if (depth < sourceLine.line.depth)
      throw new Error("Нельзя ссылаться на строку " + number + " из закрытого подвывода.");
    return sourceLine;
  }
  function needAccessible(count: number): Source[] {
    if (refs.length === 0) stepWarn("Ссылки не указаны: нужно " + count + ".");
    if (refs.length !== count) stepWarn("Нужно ссылок: " + count + ", указано " + refs.length + ".");
    return refs.map((number) => {
      const line = source(number);
      return accessible(number, line);
    });
  }
  function hasOpenAssumption(targetDepth: number): boolean {
    for (let i = previous.length - 1; i >= 0; i--) {
      if (previous[i].depth < targetDepth) return false;
      if (previous[i].depth === targetDepth && previous[i].rule === "assumption") return true;
    }
    return false;
  }
  if (depth > 0) {
    if (candidate.rule === "assumption") {
      if (hasOpenAssumption(depth))
        throw new Error("Подвывод этой глубины уже открыт. Закройте его или выберите большую глубину.");
      if (depth > 1 && !hasOpenAssumption(depth - 1)) throw new Error("Сначала откройте внешний подвывод.");
    } else if (!hasOpenAssumption(depth)) {
      throw new Error("На глубине " + depth + " нет открытого допущения.");
    }
  }
  if (candidate.rule === "assumption") {
    if (refs.length) throw new Error("У допущения не бывает ссылок.");
    if (depth < 1) throw new Error("Допущение должно быть в подвыводе, глубина хотя бы 1.");
    return { ast };
  }
  if (candidate.rule === "reiterate") {
    const [one] = needAccessible(1);
    if (!same(one.ast, ast)) throw new Error("Повтор должен совпадать с указанной формулой.");
    return { ast };
  }
  if (candidate.rule === "andi") {
    const [left, right] = needAccessible(2);
    if (!same(ast, { type: "and", a: left.ast, b: right.ast }))
      throw new Error("Заключение должно быть конъюнкцией указанных формул.");
    return { ast };
  }
  if (candidate.rule === "ande") {
    const [sourceLine] = needAccessible(1);
    if (sourceLine.ast.type !== "and") throw new Error("Нужна ссылка на конъюнкцию.");
    if (!same(ast, sourceLine.ast.a) && !same(ast, sourceLine.ast.b))
      throw new Error("Из конъюнкции выводится только её часть.");
    return { ast };
  }
  if (candidate.rule === "ori") {
    const [sourceLine] = needAccessible(1);
    const ok = ast.type === "or" && (same(sourceLine.ast, ast.a) || same(sourceLine.ast, ast.b));
    if (!ok) throw new Error("Заключение должно быть дизъюнкцией с указанной формулой.");
    return { ast };
  }
  if (candidate.rule === "implE") {
    const [one, two] = needAccessible(2);
    let impl: Extract<Logic.PropAst, { type: "impl" }> | null = null;
    if (one.ast.type === "impl" && same(two.ast, one.ast.a)) impl = one.ast;
    if (two.ast.type === "impl" && same(one.ast, two.ast.a)) impl = two.ast;
    if (!impl) throw new Error("Нужны импликация и её посылка.");
    if (!same(ast, impl.b)) throw new Error("Заключение должно быть следствием импликации.");
    return { ast };
  }
  if (candidate.rule === "notE") {
    const [one, two] = needAccessible(2);
    if (!(ast.type === "const" && ast.value === false)) throw new Error("¬E даёт ⊥.");
    const neg = one.ast.type === "not" ? one.ast : two.ast.type === "not" ? two.ast : null;
    const other = neg === one.ast ? two.ast : one.ast;
    if (!neg || !same(neg.a, other)) throw new Error("Нужны формула и её отрицание.");
    return { ast };
  }
  if (candidate.rule === "botE") {
    const [sourceLine] = needAccessible(1);
    if (sourceLine.ast.type !== "const" || sourceLine.ast.value !== false) throw new Error("⊥E требует ⊥.");
    return { ast };
  }
  if (candidate.rule === "iffE") {
    const [sourceLine] = needAccessible(1);
    if (sourceLine.ast.type !== "iff") throw new Error("↔E требует ссылку на эквивалентность.");
    const ok =
      ast.type === "impl" &&
      ((same(ast.a, sourceLine.ast.a) && same(ast.b, sourceLine.ast.b)) ||
        (same(ast.a, sourceLine.ast.b) && same(ast.b, sourceLine.ast.a)));
    if (!ok) throw new Error("Из φ↔ψ выводится φ→ψ или ψ→φ.");
    return { ast };
  }
  if (candidate.rule === "implI" || candidate.rule === "notI" || candidate.rule === "raa") {
    if (!refs.length) stepWarn("Укажите диапазон подвывода, например 3-5.");
    if (!contiguous(refs)) throw new Error("Диапазон подвывода должен идти подряд.");
    const start = source(refs[0]);
    const end = source(refs[refs.length - 1]);
    if (end.line !== previous[previous.length - 1])
      throw new Error("Подвывод должен заканчиваться прямо перед этой строкой.");
    if (start.line.rule !== "assumption") throw new Error("Подвывод должен начинаться с допущения.");
    if (start.line.depth !== depth + 1 || end.line.depth !== depth + 1)
      throw new Error("Глубина подвывода не совпадает.");
    for (const ref of refs) {
      if (source(ref).line.depth < depth + 1) throw new Error("Подвывод выходит за свою глубину.");
    }
    if (candidate.rule === "implI") {
      if (ast.type !== "impl" || !same(ast.a, start.ast) || !same(ast.b, end.ast))
        throw new Error("→I: из допущения φ и вывода ψ получается φ → ψ.");
    } else if (candidate.rule === "notI") {
      if (ast.type !== "not" || !same(ast.a, start.ast)) throw new Error("¬I: из допущения φ и ⊥ получается ¬φ.");
      if (end.ast.type !== "const" || end.ast.value !== false) throw new Error("¬I требует ⊥ в конце подвывода.");
    } else {
      if (start.ast.type !== "not" || !same(start.ast.a, ast))
        throw new Error("RAA: из допущения ¬φ и ⊥ получается φ.");
      if (end.ast.type !== "const" || end.ast.value !== false) throw new Error("RAA требует ⊥ в конце подвывода.");
    }
    return { ast };
  }
  throw new Error("Неизвестное правило.");
}

function analyzeLines(): Validity[] {
  return lines.map((line, index): Validity => {
    if (line.rule === "premise") {
      return line.ast ? { status: "ok", ok: true } : { status: "warning", ok: false, warning: "Посылка не разобрана." };
    }
    const formula = String(line.formula || "").trim();
    if (!formula) return { status: "warning", ok: false, warning: "Формула не задана." };
    let ast = line.ast;
    if (!ast) {
      try {
        ast = parse(formula);
        line.ast = ast;
      } catch (error) {
        return { status: "warning", ok: false, warning: "Формула не разобрана: " + errorText(error) };
      }
    }
    if (!line.rule)
      return {
        status: "warning",
        ok: false,
        warning: "Шаг не обоснован." + (line.refsError ? " Ссылки не разобраны: " + line.refsError : ""),
      };
    if (line.refsError) return { status: "warning", ok: false, warning: "Ссылки не разобраны: " + line.refsError };
    try {
      validate({ formula, ast, rule: line.rule, refs: line.refs, depth: line.depth }, lines.slice(0, index));
      return { status: "ok", ok: true };
    } catch (error) {
      if (error instanceof StepError && error.kind === "warning") {
        return { status: "warning", ok: false, warning: error.message };
      }
      return { status: "error", ok: false, error: errorText(error) };
    }
  });
}

function goalAst(): Logic.PropAst {
  return parse(current.goal);
}

function renderGoal(): void {
  clear(goalNode);
  goalNode.appendChild(el("span", { class: "goal-label", text: "Цель" }));
  const premises = current.premises.map((text) => Logic.toTex(parse(text)));
  const tex = (premises.length ? premises.join(",\\; ") + "\\;\\vdash\\; " : "\\vdash\\; ") + Logic.toTex(goalAst());
  goalNode.appendChild(math(tex, false));
}

function subproofEnd(index: number): number {
  const depth = lines[index].depth;
  let end = index;
  for (let i = index + 1; i < lines.length && lines[i].depth >= depth; i++) end = i;
  return end;
}

function ruleLabel(line: Line): string {
  if (line.rule === "premise") return "посылка";
  return line.rule ? ruleById.get(line.rule)?.label || line.rule : "не указано";
}

function lineDepthBars(depth: number): HTMLElement {
  const box = el("span", { class: "fitch-indent", "aria-hidden": "true" });
  for (let i = 0; i < depth; i++) box.appendChild(el("span", { class: "fitch-bar" }));
  return box;
}

function actionButton(label: string, action: string, index: number, extraClass?: string): HTMLButtonElement {
  return el("button", {
    class: "fitch-action" + (extraClass ? " " + extraClass : ""),
    type: "button",
    "data-action": action,
    "data-index": String(index),
    "aria-label": label + ", строка " + (index + 1),
    text: label,
  });
}

function levelCell(line: Line, index: number): HTMLElement {
  const box = el("div", { class: "fitch-level" });
  if (line.rule === "premise") {
    box.appendChild(el("span", { class: "fitch-level-value", text: "0", "aria-label": "Уровень 0" }));
    return box;
  }
  const less = el("button", {
    class: "fitch-level-btn",
    type: "button",
    "data-level": "-1",
    "data-index": String(index),
    "aria-label": "Уменьшить уровень строки " + (index + 1),
    title: "Уровень меньше",
    text: "←",
    disabled: line.depth <= 0 ? "disabled" : undefined,
  });
  const more = el("button", {
    class: "fitch-level-btn",
    type: "button",
    "data-level": "1",
    "data-index": String(index),
    "aria-label": "Увеличить уровень строки " + (index + 1),
    title: "Уровень больше",
    text: "→",
  });
  box.classList.add("has-pop");
  box.setAttribute("tabindex", "0");
  box.setAttribute("aria-label", "Уровень строки " + (index + 1));
  box.setAttribute("title", "Наведите или нажмите, чтобы изменить уровень");
  box.addEventListener("click", (event) => {
    if (!(event.target instanceof Element)) return;
    if (!event.target.closest("button")) box.focus();
  });
  box.appendChild(
    el("span", { class: "fitch-level-value", text: String(line.depth), "aria-label": "Уровень " + line.depth }),
  );
  const pop = el("div", { class: "fitch-level-pop", role: "group", "aria-label": "Уровень строки " + (index + 1) });
  pop.appendChild(less);
  pop.appendChild(
    el("span", { class: "fitch-level-value", text: String(line.depth), "aria-label": "Уровень " + line.depth }),
  );
  pop.appendChild(more);
  box.appendChild(pop);
  return box;
}

function enclosingAssumption(index: number): number {
  const depth = lines[index].depth;
  if (depth <= 0) return -1;
  for (let i = index; i >= 0; i--) {
    if (lines[i].depth < depth) return -1;
    if (lines[i].depth === depth && lines[i].rule === "assumption") return i;
  }
  return -1;
}

function lineActions(line: Line, index: number): HTMLElement {
  const box = el("div", {
    class: "fitch-actions",
    role: "toolbar",
    "aria-label": "Действия со строкой " + (index + 1),
  });
  if (line.rule !== "premise") {
    box.appendChild(actionButton("Изменить", "edit", index));
    box.appendChild(actionButton("Поднять", "above", index));
    box.appendChild(actionButton("Добавить ниже", "below", index));
    box.appendChild(actionButton("Открыть подвывод", "subproof", index));
    if (enclosingAssumption(index) >= 0) box.appendChild(actionButton("Закрыть подвывод", "close", index));
    box.appendChild(actionButton("Удалить", "delete", index, "danger"));
  } else {
    box.appendChild(actionButton("Добавить ниже", "below", index));
    box.appendChild(actionButton("Открыть подвывод", "subproof", index));
  }
  return box;
}

function renderRow(line: Line, index: number, validity: Validity): HTMLElement {
  const row = el("div", {
    class:
      "fitch-row" +
      (line.rule === "premise" ? " premise" : "") +
      (line.lemmaTitle ? " lemma" : "") +
      (validity.status === "error" ? " invalid" : validity.status === "warning" ? " warning" : "") +
      (composer && composer.mode === "edit" && composer.index === index ? " editing" : ""),
    role: "group",
    tabindex: "0",
    "aria-label": "Строка " + (index + 1),
    "data-index": String(index),
  });
  row.appendChild(levelCell(line, index));
  row.appendChild(el("div", { class: "fitch-no", text: String(index + 1) }));

  const formulaCell = el("div", { class: "fitch-formula-cell" });
  formulaCell.appendChild(lineDepthBars(line.depth));
  const formulaBox = el("div", { class: "fitch-formula-wrap" });
  const formula = el("div", { class: "fitch-formula" });
  if (line.ast) formula.appendChild(math(texOf(line.ast), false));
  else formula.appendChild(el("span", { class: "fitch-raw", text: line.formula.trim() || "…" }));
  if (line.lemmaTitle)
    formula.appendChild(el("span", { class: "fitch-lemma-tag", text: "подвывод · " + line.lemmaTitle }));
  formulaBox.appendChild(formula);
  if (validity.status === "warning")
    formulaBox.appendChild(el("div", { class: "fitch-warning", text: validity.warning }));
  if (validity.status === "error") formulaBox.appendChild(el("div", { class: "fitch-error", text: validity.error }));
  formulaCell.appendChild(formulaBox);
  row.appendChild(formulaCell);

  const ruleCell = el("div", { class: "fitch-rule-cell" });
  ruleCell.appendChild(
    el("span", {
      class: "fitch-rule" + (line.rule === "assumption" ? " assumption" : "") + (line.rule ? "" : " unspecified"),
      text: ruleLabel(line),
    }),
  );
  row.appendChild(ruleCell);

  const refsText = line.refs.length ? refsLabel(line.refs) : line.refsRaw || "·";
  const refsTitle = line.refs.length ? "Ссылки" : line.refsError ? "Ссылки не разобраны" : "Ссылок нет";
  row.appendChild(
    el("div", { class: "fitch-refs-cell", title: refsTitle }, [el("span", { class: "fitch-refs", text: refsText })]),
  );
  row.appendChild(lineActions(line, index));
  row.addEventListener("click", (event) => {
    if (!(event.target instanceof Element)) return;
    if (event.target.closest("button, input, select, a, .fitch-level")) return;
    row.focus({ preventScroll: true });
  });
  return row;
}

function composerTitle(): string {
  if (!composer) return "";
  if (composer.mode === "edit") return "Изменить строку " + ((composer.index ?? 0) + 1);
  if (composer.mode === "subproof") return "Новый подвывод";
  if (composer.mode === "close") return "Закрыть подвывод";
  return composer.at >= lines.length ? "Новая строка в конце" : "Новая строка перед строкой " + (composer.at + 1);
}

function renderComposer(): HTMLFormElement | null {
  const state = composer;
  if (!state) return null;
  const isSubproof = state.mode === "subproof";
  const isClose = state.mode === "close";
  const isEdit = state.mode === "edit";
  const showTitle = isSubproof || (isEdit && state.title !== undefined);
  const box = el("form", { class: "fitch-composer", "data-mode": state.mode, novalidate: "" });
  const head = el("div", { class: "composer-head" }, [
    el("div", { class: "composer-title", text: composerTitle() }),
    el("button", { class: "composer-cancel", type: "button", "data-role": "cancel", text: "Отмена" }),
  ]);
  box.appendChild(head);

  const grid = el("div", { class: "composer-grid" });
  grid.appendChild(
    el("div", { class: "composer-fixed" }, [el("span", { text: "Уровень" }), el("b", { text: String(state.depth) })]),
  );
  if (isSubproof) {
    grid.appendChild(
      el("div", { class: "composer-fixed" }, [el("span", { text: "Правило" }), el("b", { text: "допущение" })]),
    );
  }
  const formulaField = el("label", { class: "composer-field composer-formula" }, [
    el("span", { text: isSubproof ? "Допущение подвывода" : "Формула" }),
  ]);
  formulaField.appendChild(
    el("input", {
      "data-field": "formula",
      class: "formula-input",
      value: state.formula || "",
      placeholder: isSubproof ? "например, A" : "например, A → B",
      spellcheck: "false",
      autocomplete: "off",
    }),
  );
  grid.appendChild(formulaField);

  if (!isSubproof) {
    const ruleField = el("label", { class: "composer-field" }, [el("span", { text: "Правило" })]);
    const rule = el("select", { "data-field": "rule" });
    rule.appendChild(el("option", { value: "", text: "не указано", selected: state.rule ? undefined : "selected" }));
    for (const item of rules) {
      if (item.id === "premise") continue;
      rule.appendChild(
        el("option", { value: item.id, text: item.label, selected: item.id === state.rule ? "selected" : undefined }),
      );
    }
    ruleField.appendChild(rule);
    grid.appendChild(ruleField);
  }

  if (!isSubproof) {
    const refsField = el("label", { class: "composer-field" }, [el("span", { text: "Ссылки" })]);
    refsField.appendChild(
      el("input", {
        "data-field": "refs",
        class: "formula-input",
        value: state.refsText || "",
        placeholder: "1,2 или 3-5",
        spellcheck: "false",
        autocomplete: "off",
      }),
    );
    grid.appendChild(refsField);
  }

  if (showTitle) {
    const titleField = el("label", { class: "composer-field wide" }, [el("span", { text: "Название подвывода" })]);
    titleField.appendChild(
      el("input", {
        "data-field": "title",
        class: "formula-input",
        value: state.title || "",
        placeholder: "например, вспомогательный факт",
        autocomplete: "off",
      }),
    );
    grid.appendChild(titleField);
  }
  box.appendChild(grid);

  if (isClose)
    box.appendChild(
      el("p", {
        class: "composer-note",
        text: "Ссылки уже заполнены диапазоном подвывода. Измените правило, если закрываете его через ¬I или RAA.",
      }),
    );

  const preview = el("div", { class: "composer-preview", "data-role": "preview" });
  const message = el("span", { class: "composer-msg", "data-role": "message" });
  const submit = el("button", {
    class: "active",
    type: "submit",
    "data-role": "submit",
    text: isEdit ? "Сохранить" : isSubproof ? "Открыть подвывод" : "Добавить",
  });
  const foot = el("div", { class: "composer-foot" }, [
    preview,
    message,
    el("span", { class: "composer-foot-spacer" }),
    submit,
  ]);
  box.appendChild(foot);
  return box;
}

function renderProof(validity?: Validity[]): void {
  const checked = validity || analyzeLines();
  clear(proofNode);
  const head = el("div", { class: "fitch-head", "aria-hidden": "true" }, [
    el("span", { text: "ур." }),
    el("span", { text: "#" }),
    el("span", { text: "формула" }),
    el("span", { text: "правило" }),
    el("span", { text: "ссылки" }),
  ]);
  proofNode.appendChild(head);
  if (!lines.length && !composer) {
    proofNode.appendChild(
      el("div", { class: "fitch-empty" }, [
        el("b", { text: "Пока пусто." }),
        el("span", { text: "Добавьте строку или откройте подвывод, чтобы начать рассуждение." }),
      ]),
    );
  }
  let inserted = false;
  lines.forEach((line, index) => {
    if (composer && composer.at === index && composer.mode !== "edit") {
      const node = renderComposer();
      if (node) proofNode.appendChild(node);
      inserted = true;
    }
    proofNode.appendChild(renderRow(line, index, checked[index]));
    if (composer && composer.mode === "edit" && composer.index === index) {
      const node = renderComposer();
      if (node) proofNode.appendChild(node);
      inserted = true;
    }
  });
  if (composer && !inserted) {
    const node = renderComposer();
    if (node) proofNode.appendChild(node);
  }
  bindComposer();
}

function renderState(note?: string, noteKind?: string): { validity: Validity[]; reached: boolean; bad: number } {
  const validity = analyzeLines();
  renderProof(validity);
  const bad = validity.findIndex((item) => item.status === "error");
  const firstWarning = validity.findIndex((item) => item.status === "warning");
  const errorCount = validity.filter((item) => item.status === "error").length;
  const warningCount = validity.filter((item) => item.status === "warning").length;
  const parts = [lines.length + " " + plural(lines.length, "строка", "строки", "строк")];
  if (warningCount)
    parts.push(warningCount + " " + plural(warningCount, "предупреждение", "предупреждения", "предупреждений"));
  if (errorCount) parts.push(errorCount + " " + plural(errorCount, "ошибка", "ошибки", "ошибок"));
  else if (!warningCount) parts.push("ошибок нет");
  countNode.textContent = parts.join(" · ");
  const reached = bad < 0 && lines.some((line) => line.depth === 0 && line.ast && same(line.ast, goalAst()));
  if (bad >= 0) {
    status(
      statusNode,
      "Доказательство содержит ошибку. Строка " + (bad + 1) + ": " + (validity[bad].error || ""),
      "bad",
    );
  } else if (reached && warningCount === 0) {
    status(statusNode, "Цель достигнута: формула выведена на глубине 0 без ошибок.", "ok");
  } else if (reached) {
    status(
      statusNode,
      "Цель достигнута, но доказательство неполное. Строка " +
        (firstWarning + 1) +
        ": " +
        (validity[firstWarning].warning || ""),
      "warn",
    );
  } else if (firstWarning >= 0) {
    status(
      statusNode,
      "Доказательство неполное. Строка " + (firstWarning + 1) + ": " + (validity[firstWarning].warning || ""),
      "warn",
    );
  } else {
    status(statusNode, note || "Ошибок нет. Цель пока не достигнута.", noteKind || "");
  }
  updateUndo();
  return { validity, reached, bad };
}

function plural(n: number, one: string, few: string, many: string): string {
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 === 1 && mod100 !== 11) return one;
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return few;
  return many;
}

function openComposer(mode: ComposerMode, options: ComposerOptions): void {
  composer = {
    mode,
    at: options.at,
    depth: options.depth,
    formula: options.formula || "",
    rule: options.rule || "",
    refsText: options.refsText || "",
    title: options.title,
    index: options.index,
  };
  if (mode === "subproof" && !composer.title)
    composer.title = "№" + (lines.filter((line) => line.lemmaTitle).length + 1);
  renderState("Заполните строку: проверка появится сразу.", "info");
  focusComposer();
}

function focusComposer(): void {
  requestAnimationFrame(() => {
    const input = proofNode.querySelector<HTMLInputElement>("[data-field=formula]");
    if (input) {
      input.focus();
      if (composer && composer.mode === "edit") input.select();
    }
  });
}

function composerValues(): { depth: number; formula: string; rule: string; refsText: string; title: string } | null {
  const box = proofNode.querySelector<HTMLFormElement>(".fitch-composer");
  if (!box) return null;
  const state = composer;
  if (!state) return null;
  const field = (name: string): HTMLInputElement | HTMLSelectElement | null =>
    box.querySelector<HTMLInputElement | HTMLSelectElement>("[data-field=" + name + "]");
  return {
    depth: state.depth,
    formula: field("formula")?.value || "",
    rule: state.mode === "subproof" ? "assumption" : field("rule")?.value || "",
    refsText: state.mode === "subproof" ? "" : field("refs")?.value || "",
    title: field("title")?.value || state.title || "",
  };
}

function updateDraft(): void {
  const state = composer;
  if (!state) return;
  const box = proofNode.querySelector<HTMLFormElement>(".fitch-composer");
  if (!box) return;
  const values = composerValues();
  if (!values) return;
  const message = box.querySelector<HTMLElement>("[data-role=message]");
  const preview = box.querySelector<HTMLElement>("[data-role=preview]");
  const submit = box.querySelector<HTMLButtonElement>("[data-role=submit]");
  const formulaInput = box.querySelector<HTMLElement>("[data-field=formula]");
  const refsInput = box.querySelector<HTMLElement>("[data-field=refs]");
  const ruleInput = box.querySelector<HTMLElement>("[data-field=rule]");
  if (!message || !preview || !submit) return;
  message.className = "composer-msg";
  clear(preview);
  submit.disabled = false;

  const rawFormula = values.formula.trim();
  let ast: Logic.PropAst | null = null;
  let formulaWarning = "";
  if (!rawFormula) formulaWarning = "Формула не задана.";
  else {
    try {
      ast = parse(values.formula);
    } catch (error) {
      formulaWarning = "Формула не разобрана: " + errorText(error);
    }
  }
  if (ast) preview.appendChild(math(Logic.toTex(ast), false));
  else preview.appendChild(el("span", { class: "composer-raw", text: rawFormula || "…" }));

  let refs: number[] = [];
  let refsError = "";
  if (state.mode !== "subproof" && values.refsText.trim()) {
    try {
      refs = parseRefs(values.refsText);
    } catch (error) {
      refsError = errorText(error);
    }
  }

  const rule = state.mode === "subproof" ? "assumption" : values.rule;
  let stepState = "warning";
  let warning = formulaWarning;
  let error = "";
  if (!formulaWarning && !refsError) {
    if (!rule) {
      warning = "Шаг не обоснован.";
    } else {
      try {
        const previous = lines.slice(0, state.mode === "edit" ? (state.index ?? 0) : state.at);
        validate({ formula: values.formula, ast, rule, refs, depth: values.depth }, previous);
        stepState = "ok";
        warning = "";
      } catch (failure) {
        if (failure instanceof StepError && failure.kind === "warning") {
          warning = failure.message;
        } else {
          stepState = "error";
          warning = "";
          error = errorText(failure);
        }
      }
    }
  }
  if (refsError) {
    stepState = "warning";
    if (!formulaWarning) warning = warning ? warning + " " + refsError : refsError;
  }

  const mark = (input: Element | null, fieldState: string): void => {
    const field = input?.closest(".composer-field");
    if (!field) return;
    field.classList.remove("ok", "warn", "error");
    if (fieldState) field.classList.add(fieldState);
  };
  mark(formulaInput, formulaWarning ? "warn" : ast ? "ok" : "");
  mark(
    refsInput,
    refsError ? "error" : !formulaWarning && rule && stepState === "warning" ? "warn" : refs.length ? "ok" : "",
  );
  mark(ruleInput, state.mode === "subproof" ? "ok" : !rule ? "warn" : stepState === "error" ? "error" : "ok");

  if (stepState === "ok") {
    message.textContent = "Проверено.";
    message.classList.add("ok");
  } else if (stepState === "error") {
    message.textContent = "Ошибка: " + error + " Шаг можно сохранить и исправить позже.";
    message.classList.add("error");
  } else {
    message.textContent = (warning || "Шаг неполный.") + " Можно сохранить и дополнить позже.";
    message.classList.add("warn");
  }

  state.draft = {
    ast,
    formula: values.formula,
    rule,
    refs,
    refsRaw: refsError ? values.refsText : undefined,
    refsError: refsError || undefined,
    depth: values.depth,
    title: values.title,
  };
}

function bindComposer(): void {
  const box = proofNode.querySelector<HTMLFormElement>(".fitch-composer");
  if (!box) return;
  box.querySelector("[data-role=cancel]")?.addEventListener("click", () => {
    composer = null;
    renderState("Редактирование отменено.", "info");
  });
  box.addEventListener("submit", (event) => {
    event.preventDefault();
    saveComposer();
  });
  box.querySelectorAll<HTMLInputElement | HTMLSelectElement>("input, select").forEach((input) => {
    input.addEventListener("input", updateDraft);
    input.addEventListener("change", updateDraft);
    if (input instanceof HTMLInputElement) {
      input.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
          event.preventDefault();
          if (composer?.draft) saveComposer();
        }
      });
    }
  });
  updateDraft();
}

function saveComposer(): void {
  const state = composer;
  if (!state) return;
  updateDraft();
  const draft = state.draft;
  if (!draft) return;
  pushHistory();
  const lemmaTitle =
    state.mode === "subproof" || (state.mode === "edit" && state.title !== undefined)
      ? (draft.title || "").trim() || undefined
      : undefined;
  if (state.mode === "edit") {
    const index = state.index;
    if (index === undefined) return;
    lines[index] = {
      ast: draft.ast,
      formula: draft.formula,
      rule: draft.rule,
      refs: draft.refs,
      refsRaw: draft.refsRaw,
      refsError: draft.refsError,
      depth: draft.depth,
      lemmaTitle,
    };
    composer = null;
    renderState("Строка изменена.", "ok");
    return;
  }
  const at = Math.max(0, Math.min(state.at, lines.length));
  for (const line of lines) {
    const isRange = ["implI", "notI", "raa"].includes(line.rule) && line.refs.length >= 2;
    const insideRange = isRange && at > line.refs[0] - 1 && at <= line.refs[line.refs.length - 1];
    line.refs = line.refs.map((ref) => (ref > at ? ref + 1 : ref));
    if (insideRange) line.refs.push(at + 1);
    line.refs.sort((a, b) => a - b);
  }
  const refs = draft.refs.map((ref) => (ref > at ? ref + 1 : ref));
  lines.splice(at, 0, {
    ast: draft.ast,
    formula: draft.formula,
    rule: draft.rule,
    refs,
    refsRaw: draft.refsRaw,
    refsError: draft.refsError,
    depth: draft.depth,
    lemmaTitle,
  });
  composer = null;
  renderState("Строка добавлена.", "ok");
}

function deleteLine(index: number): void {
  if (index < 0 || index >= lines.length) return;
  const line = lines[index];
  if (line.rule === "premise") return;
  const lineNo = index + 1;
  const usedBy = lines.findIndex((other, otherIndex) => {
    if (otherIndex === index || !other.refs.includes(lineNo)) return false;
    const isRange = ["implI", "notI", "raa"].includes(other.rule) && other.refs.length >= 2;
    return !(isRange && lineNo > other.refs[0] && lineNo < other.refs[other.refs.length - 1]);
  });
  if (usedBy >= 0) {
    status(
      statusNode,
      "Строка " + lineNo + " используется в строке " + (usedBy + 1) + ". Сначала измените ссылки.",
      "bad",
    );
    return;
  }
  if (line.rule === "assumption" && subproofEnd(index) > index) {
    status(statusNode, "Сначала удалите строки подвывода, затем допущение.", "bad");
    return;
  }
  pushHistory();
  for (const other of lines) {
    other.refs = other.refs.filter((ref) => ref !== lineNo).map((ref) => (ref > lineNo ? ref - 1 : ref));
  }
  lines.splice(index, 1);
  composer = null;
  renderState("Строка удалена.", "info");
}

function changeDepth(index: number, delta: number): void {
  const line = lines[index];
  if (!line || line.rule === "premise") return;
  const next = line.depth + delta;
  if (next < 0) {
    status(statusNode, "Уровень не может быть меньше 0.", "bad");
    return;
  }
  try {
    if (line.ast && line.rule)
      validate(
        { formula: line.formula, ast: line.ast, rule: line.rule, refs: line.refs, depth: next },
        lines.slice(0, index),
      );
  } catch (error) {
    if (!(error instanceof StepError && error.kind === "warning")) {
      status(statusNode, errorText(error), "bad");
      return;
    }
  }
  pushHistory();
  if (line.rule === "assumption") {
    const end = subproofEnd(index);
    const closers = lines
      .map((other, otherIndex) => ({ other, otherIndex }))
      .filter(
        ({ other, otherIndex }) =>
          otherIndex > end && ["implI", "notI", "raa"].includes(other.rule) && other.refs[0] === index + 1,
      );
    for (let i = index; i <= end; i++) lines[i].depth += delta;
    for (const { other } of closers) other.depth += delta;
  } else {
    line.depth = next;
  }
  renderState("Уровень строки изменён.", "info");
}

function addAbove(index: number): void {
  const line = lines[index];
  openComposer("add", { at: index, depth: line.rule === "assumption" ? Math.max(0, line.depth - 1) : line.depth });
}

function addBelow(index: number): void {
  openComposer("add", { at: index + 1, depth: lines[index].depth });
}

function addSubproofBelow(index: number): void {
  openComposer("subproof", { at: index + 1, depth: lines[index].depth + 1 });
}

function openClose(index: number): void {
  const assumption = enclosingAssumption(index);
  if (assumption < 0) return;
  const line = lines[assumption];
  const end = subproofEnd(assumption);
  const refs: number[] = [];
  for (let i = assumption + 1; i <= end + 1; i++) refs.push(i);
  openComposer("close", {
    at: end + 1,
    depth: Math.max(0, line.depth - 1),
    rule: "implI",
    refsText: refs[0] === refs[refs.length - 1] ? String(refs[0]) : refs[0] + "-" + refs[refs.length - 1],
  });
}

function openEdit(index: number): void {
  const line = lines[index];
  openComposer("edit", {
    at: index,
    index,
    depth: line.depth,
    formula: line.formula,
    rule: line.rule,
    refsText: line.refs.length ? refsLabel(line.refs) : line.refsRaw || "",
    title: line.lemmaTitle,
  });
}

function handleAction(action: string | undefined, index: number): void {
  if (action === "above") addAbove(index);
  else if (action === "below") addBelow(index);
  else if (action === "subproof") addSubproofBelow(index);
  else if (action === "edit") openEdit(index);
  else if (action === "close") openClose(index);
  else if (action === "delete") deleteLine(index);
}

function loadExercise(): void {
  current = exercises[Number(exerciseSelect.value)];
  lines = current.premises.map((text) => ({ ast: parse(text), formula: text, rule: "premise", refs: [], depth: 0 }));
  history = [];
  composer = null;
  renderGoal();
  renderState();
}

proofNode.addEventListener("click", (event) => {
  if (!(event.target instanceof Element)) return;
  const level = event.target.closest<HTMLElement>("[data-level]");
  if (level) {
    changeDepth(Number(level.dataset.index), Number(level.dataset.level));
    return;
  }
  const action = event.target.closest<HTMLElement>("[data-action]");
  if (action) handleAction(action.dataset.action, Number(action.dataset.index));
});

document.addEventListener("click", (event) => {
  if (!(event.target instanceof Element)) return;
  if (event.target.closest(".fitch-row, .fitch-composer")) return;
  const focused = document.activeElement;
  if (focused instanceof HTMLElement && focused.closest(".fitch-row")) focused.blur();
});

document.addEventListener("keydown", (event) => {
  if (event.key === "Escape" && composer) {
    composer = null;
    renderState("Редактирование отменено.", "info");
  }
});

exerciseSelect.addEventListener("change", loadExercise);
addRowButton.addEventListener("click", () => {
  const depth = lines.length ? lines[lines.length - 1].depth : 0;
  openComposer("add", { at: lines.length, depth });
});
addSubproofButton.addEventListener("click", () => {
  const depth = (lines.length ? lines[lines.length - 1].depth : 0) + 1;
  openComposer("subproof", { at: lines.length, depth });
});
undoButton.addEventListener("click", () => {
  if (!history.length) return;
  lines = history.pop() || [];
  composer = null;
  renderState("Действие отменено.", "info");
});
resetButton.addEventListener("click", loadExercise);

loadExercise();

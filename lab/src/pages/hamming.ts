/* Hamming (7,4) lab: codeword, syndrome matrix and single-error correction. */

import { popcount } from "../core/bits";
import { activate, clear, el, keepFocus, must, setPressed, status } from "../core/dom";
import { math } from "../core/math";

interface Syndrome {
  s1: number;
  s2: number;
  s4: number;
  value: number;
}

interface Role {
  cls: string;
  label: string;
}

interface CellOptions {
  error?: boolean;
  corrected?: boolean;
  title?: string;
}

let data = [1, 0, 1, 1];
let errorMask = 0;

const dataBitsNode = must<HTMLElement>("#data-bits");
const formulasNode = must<HTMLElement>("#formulas");
const cRow = must<HTMLElement>("#c-row");
const rRow = must<HTMLElement>("#r-row");
const fixRow = must<HTMLElement>("#fix-row");
const wordHead = must<HTMLElement>("#word-head");
const syndromeBits = must<HTMLElement>("#syndrome-bits");
const syndromeStatus = must<HTMLElement>("#syndrome-status");
const dataResult = must<HTMLElement>("#data-result");
const hmatrixNode = must<HTMLElement>("#hmatrix");

function codeword(): number[] {
  const d1 = data[0], d2 = data[1], d3 = data[2], d4 = data[3];
  const p1 = d1 ^ d2 ^ d4;
  const p2 = d1 ^ d3 ^ d4;
  const p4 = d2 ^ d3 ^ d4;
  return [p1, p2, d1, p4, d2, d3, d4];
}

function received(c: number[]): number[] {
  const r = c.slice();
  for (let i = 0; i < 7; i++) if (errorMask & (1 << i)) r[i] ^= 1;
  return r;
}

function syndrome(r: number[]): Syndrome {
  const s1 = r[0] ^ r[2] ^ r[4] ^ r[6];
  const s2 = r[1] ^ r[2] ^ r[5] ^ r[6];
  const s4 = r[3] ^ r[4] ^ r[5] ^ r[6];
  return { s1, s2, s4, value: s4 * 4 + s2 * 2 + s1 };
}

function corrected(r: number[], s: number): number[] {
  const out = r.slice();
  if (s >= 1 && s <= 7) out[s - 1] ^= 1;
  return out;
}

function roleOf(pos: number): Role {
  if (pos === 1 || pos === 2 || pos === 4) return { cls: "parity", label: "p" + pos };
  if (pos === 3) return { cls: "data", label: "d1" };
  if (pos === 5) return { cls: "data", label: "d2" };
  if (pos === 6) return { cls: "data", label: "d3" };
  return { cls: "data", label: "d4" };
}

function positionCell(pos: number, bit: number, options: CellOptions): HTMLDivElement {
  const role = roleOf(pos);
  const cell = el("div", {
    class: "pos " + role.cls + (options.error ? " error" : "") + (options.corrected ? " corrected" : ""),
    title: options.title || role.label,
  });
  cell.appendChild(el("div", { class: "pbit", text: String(bit) }));
  return cell;
}

function headCell(pos: number): HTMLDivElement {
  const role = roleOf(pos);
  const cell = el("div", { class: "pos head " + role.cls });
  cell.appendChild(el("span", { class: "pnum", text: String(pos) }));
  cell.appendChild(el("span", { class: "prole", text: role.label }));
  return cell;
}

function renderDataBits(): void {
  clear(dataBitsNode);
  data.forEach((bit, i) => {
    const button = el("button", {
      class: "bit" + (bit ? " on" : ""),
      text: String(bit),
      title: "d" + (i + 1),
      "aria-label": "d" + (i + 1) + " = " + bit + ", переключить",
      "data-focus-key": "data-" + i,
    });
    setPressed(button, bit === 1);
    button.addEventListener("click", () => {
      data[i] ^= 1;
      errorMask = 0;
      renderAll();
    });
    dataBitsNode.appendChild(button);
    dataBitsNode.appendChild(el("span", { class: "small muted", text: "d" + (i + 1) }));
  });
}

function renderFormulas(): void {
  const d = data;
  const p1 = d[0] ^ d[1] ^ d[3];
  const p2 = d[0] ^ d[2] ^ d[3];
  const p4 = d[1] ^ d[2] ^ d[3];
  const tex = "\\begin{aligned} p_1 &= d_1 \\oplus d_2 \\oplus d_4 = " + p1 + " \\\\ p_2 &= d_1 \\oplus d_3 \\oplus d_4 = " + p2 + " \\\\ p_4 &= d_2 \\oplus d_3 \\oplus d_4 = " + p4 + " \\end{aligned}";
  clear(formulasNode);
  formulasNode.appendChild(math(tex, true));
}

function renderWords(c: number[], r: number[], fix: number[], s: number, actualErrors: number): void {
  clear(wordHead);
  for (let pos = 1; pos <= 7; pos++) wordHead.appendChild(headCell(pos));
  clear(cRow);
  clear(rRow);
  clear(fixRow);
  for (let pos = 1; pos <= 7; pos++) {
    cRow.appendChild(positionCell(pos, c[pos - 1], { title: "Передано" }));
  }
  for (let pos = 1; pos <= 7; pos++) {
    const hasError = Boolean(errorMask & (1 << (pos - 1)));
    const cell = positionCell(pos, r[pos - 1], {
      error: hasError,
      title: "Принято, нажатие переворачивает",
    });
    cell.setAttribute("data-focus-key", "r-" + pos);
    activate(cell, () => {
      errorMask ^= 1 << (pos - 1);
      renderAll();
    }, "Позиция " + pos + ", " + roleOf(pos).label + ", принятый бит " + r[pos - 1] + (hasError ? ", ошибка" : ", без ошибки") + ", переключить");
    setPressed(cell, hasError);
    rRow.appendChild(cell);
  }
  for (let pos = 1; pos <= 7; pos++) {
    const isCorrected = actualErrors === 1 && s === pos;
    fixRow.appendChild(positionCell(pos, fix[pos - 1], {
      corrected: isCorrected,
      title: "После декодера",
    }));
  }
}

function renderSyndrome(s: Syndrome): void {
  clear(syndromeBits);
  for (const tex of ["s_1 = " + s.s1, "s_2 = " + s.s2, "s_4 = " + s.s4]) {
    const chip = el("span", { class: "sbit" });
    chip.appendChild(math(tex));
    syndromeBits.appendChild(chip);
  }
  const total = el("span", { class: "sbit" });
  total.appendChild(math("s = (s_4 s_2 s_1)_2 = (" + s.s4 + s.s2 + s.s1 + ")_2 = " + s.value));
  syndromeBits.appendChild(total);
}

function renderHMatrix(s: number): void {
  clear(hmatrixNode);
  const table = el("table", { class: "data hmatrix" });
  const thead = el("thead");
  const head = el("tr");
  head.appendChild(el("th", { class: "left", text: "H" }));
  for (let pos = 1; pos <= 7; pos++) head.appendChild(el("th", { text: String(pos) }));
  thead.appendChild(head);
  table.appendChild(thead);
  const tbody = el("tbody");
  const rows: [string, number][] = [["s_4", 4], ["s_2", 2], ["s_1", 1]];
  for (const [name, mask] of rows) {
    const row = el("tr");
    const first = el("td", { class: "left" });
    first.appendChild(math(name));
    row.appendChild(first);
    for (let pos = 1; pos <= 7; pos++) {
      const bit = (pos & mask) ? 1 : 0;
      row.appendChild(el("td", { class: "mono" + (s === pos ? " sel" : ""), text: String(bit) }));
    }
    tbody.appendChild(row);
  }
  table.appendChild(tbody);
  hmatrixNode.appendChild(table);
}

function paint(): void {
  const c = codeword();
  const r = received(c);
  const s = syndrome(r);
  const fix = corrected(r, s.value);
  const actualErrors = popcount(errorMask);
  renderDataBits();
  renderFormulas();
  renderWords(c, r, fix, s.value, actualErrors);
  renderSyndrome(s);
  renderHMatrix(s.value);

  if (actualErrors === 0 && s.value === 0) {
    status(syndromeStatus, "Ошибки нет: синдром 0.", "ok");
  } else if (actualErrors === 1) {
    status(syndromeStatus, "Одна ошибка. Синдром указывает на позицию " + s.value + ". Декодер переворачивает этот бит.", "ok");
  } else if (actualErrors >= 2) {
    const action = s.value === 0
      ? "Синдром 0: декодер ошибку не видит и ничего не исправляет."
      : "Декодер переворачивает позицию " + s.value + ", это может быть неверно.";
    status(syndromeStatus, "Перевёрнутых битов: " + actualErrors + ". " + action, "warn");
  } else {
    status(syndromeStatus, "Синдром " + s.value + ", ошибок не внесено. Проверьте слово.", "warn");
  }

  const correctedData = [fix[2], fix[4], fix[5], fix[6]].join("");
  const originalData = data.join("");
  dataResult.textContent = "Информационные биты: " + originalData + " → после декодера " + correctedData;
}

function renderAll(): void {
  keepFocus(paint);
}

must<HTMLButtonElement>("#random-error").addEventListener("click", () => {
  errorMask ^= 1 << Math.floor(Math.random() * 7);
  renderAll();
});

must<HTMLButtonElement>("#clear-errors").addEventListener("click", () => {
  errorMask = 0;
  renderAll();
});

must<HTMLButtonElement>("#preset-1011").addEventListener("click", () => {
  data = [1, 0, 1, 1];
  errorMask = 0;
  renderAll();
});

must<HTMLButtonElement>("#preset-zero").addEventListener("click", () => {
  data = [0, 0, 0, 0];
  errorMask = 0;
  renderAll();
});

renderAll();

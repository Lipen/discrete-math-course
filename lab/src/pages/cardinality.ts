/* Cardinality lab: Hilbert hotel, integer numbering and the Cantor diagonal. */

import { clear, el, keepFocus, must, status as setStatus } from "../core/dom";
import { math } from "../core/math";
import { ribbon } from "../core/segmented";

const ROOM_COUNT = 10;
const BUS_ROWS = 4;
const BUS_SEATS = 4;
const COLORS = {
  old: "var(--blue)",
  new: "var(--green)",
  bus: "var(--amber)",
  free: "var(--red)",
} as const;

type Kind = keyof typeof COLORS;

function rowColor(row: string): string {
  return row === "old" ? COLORS.old : row === "new" ? COLORS.new : COLORS.bus;
}

interface Room { guest: string; kind: Kind }

interface Source { row: string; label: string }

interface Transfer {
  row: string;
  label: string;
  room: number;
  kind: Kind;
  fromRoom?: number;
  fromIndex?: number;
}

interface Move { label: string; room: number; kind: Kind }

interface HotelState {
  rooms: Room[];
  sources: Source[];
  arrows: Transfer[];
  note: string;
  localHint: string;
  equationTex: string;
  formulaTex: string;
  calloutText: string;
  maxStep: number;
  currentStep: number;
}

let scenario = "one";
let step = 0;
let groupSize = 2;
let hotelTimer: number | null = null;
let integerSteps = 8;
let diagonalStep = 0;
let diagonalTable: number[][] = [];
let finiteTried = false;

const tabs = must<HTMLElement>("#tabs");
const stage = must<HTMLElement>("#hotel-stage");
const title = must<HTMLElement>("#hotel-title");
const hint = must<HTMLElement>("#hotel-hint");
const statusNode = must<HTMLElement>("#hotel-status");
const formula = must<HTMLElement>("#hotel-formula");
const equation = must<HTMLElement>("#hotel-equation");
const callout = must<HTMLElement>("#hotel-callout");
const groupWrap = must<HTMLElement>("#group-wrap");
ribbon(must<HTMLElement>("#group-size"), [
  { value: "2", label: "2" },
  { value: "3", label: "3" },
  { value: "4", label: "4" },
  { value: "5", label: "5" },
], String(groupSize), (value) => {
  groupSize = Number(value);
  step = 0;
  renderHotel();
  startAuto();
});
const stepsNode = must<HTMLElement>("#hotel-steps");
const movesNode = must<HTMLElement>("#hotel-moves");
const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

function showTab(name: string): void {
  for (const button of tabs.querySelectorAll<HTMLButtonElement>("button")) {
    const active = button.dataset.tab === name;
    button.classList.toggle("active", active);
    button.setAttribute("aria-pressed", String(active));
  }
  for (const panel of document.querySelectorAll<HTMLElement>(".tab-panel")) panel.classList.toggle("hidden", panel.id !== "tab-" + name);
  if (name === "hotel") { renderHotel(); startAuto(); } else { stopAuto(); }
  if (name === "integers") renderIntegers();
  if (name === "diagonal") renderDiagonal();
}

tabs.addEventListener("click", (event) => {
  if (!(event.target instanceof Element)) return;
  const button = event.target.closest<HTMLButtonElement>("button[data-tab]");
  if (button && button.dataset.tab) showTab(button.dataset.tab);
});

function stopAuto(): void {
  if (hotelTimer !== null) {
    clearInterval(hotelTimer);
    hotelTimer = null;
  }
}

function startAuto(): void {
  stopAuto();
  if (reduceMotion) {
    step = stateFor(scenario, step).maxStep;
    paintHotel();
    return;
  }
  hotelTimer = window.setInterval(() => {
    const max = stateFor(scenario, step).maxStep;
    step = step >= max ? 0 : step + 1;
    renderHotel();
  }, 2400);
}

function roomList(n: number): Room[] {
  return Array.from({ length: n }, (_, i): Room => ({ guest: "G" + (i + 1), kind: "old" }));
}

function stateFor(s: string, currentStep: number): HotelState {
  const rooms = roomList(ROOM_COUNT);
  let sources: Source[] = [];
  let arrows: Transfer[] = [];
  let note = "";
  let localHint = "";
  let equationTex = "";
  let calloutText = "";
  let formulaTex = "";
  let maxStep = 0;

  if (s === "one") {
    maxStep = 2;
    sources = currentStep === 2 ? [] : [{ row: "new", label: "новый" }];
    localHint = "Все комнаты заняты. Сдвиг освобождает первую комнату.";
    if (currentStep === 0) {
      note = "Комнат и гостей одинаково много. Свободных комнат нет.";
      equationTex = "\\left|\\mathbb{N}\\right| + 1 = \\left|\\mathbb{N}\\right|";
      formulaTex = "g(n) = n + 1";
    } else {
      rooms[0] = { guest: "", kind: currentStep === 1 ? "free" : "new" };
      for (let i = 1; i < ROOM_COUNT; i++) rooms[i] = { guest: "G" + i, kind: "old" };
      for (let i = 1; i < ROOM_COUNT; i++) arrows.push({ row: "old", label: "G" + i, fromRoom: i, room: i + 1, kind: "old" });
      if (currentStep === 1) {
        note = "Каждый жилец переезжает на одну комнату вправо. Комната 1 пуста, новый гость ждёт снаружи.";
        equationTex = "\\left|\\mathbb{N}\\right| + 1 = \\left|\\mathbb{N}\\right|";
        formulaTex = "g(n) = n + 1";
      } else {
        rooms[0] = { guest: "новый", kind: "new" };
        const newGuest: Transfer = { row: "new", label: "новый", fromIndex: 0, room: 1, kind: "new" };
        arrows = [newGuest];
        note = "Новый гость занимает комнату 1. Никто не потерян: старый гость n теперь в комнате n+1.";
        equationTex = "\\left|\\mathbb{N}\\right| + 1 = \\left|\\mathbb{N}\\right|";
        formulaTex = "G_n \\mapsto n + 1, \\quad \\text{новый} \\mapsto 1";
      }
    }
    calloutText = "В конечном отеле сдвиг не помогает: четыре гостя не помещаются в три комнаты. В бесконечном отеле гостей и комнат одинаково много, поэтому сдвиг освобождает место.";
  } else if (s === "group") {
    maxStep = 2;
    const k = groupSize;
    sources = currentStep < 2 ? Array.from({ length: k }, (_, i) => ({ row: "new", label: "N" + (i + 1) })) : [];
    localHint = "Сдвиг освобождает начало ряда.";
    if (currentStep === 0) {
      note = "Все комнаты заняты. Снаружи ждут " + k + " новых гостей.";
      equationTex = "\\left|\\mathbb{N}\\right| + " + k + " = \\left|\\mathbb{N}\\right|";
      formulaTex = "g(n) = n + " + k;
    } else if (currentStep === 1) {
      for (let i = 0; i < k; i++) rooms[i] = { guest: "", kind: "free" };
      for (let i = k; i < ROOM_COUNT; i++) rooms[i] = { guest: "G" + (i - k + 1), kind: "old" };
      for (let i = 1; i <= ROOM_COUNT - k; i++) arrows.push({ row: "old", label: "G" + i, fromRoom: i, room: i + k, kind: "old" });
      note = "Жильцы сдвигаются вправо. Первые " + k + " комнат свободны, новые гости ждут снаружи.";
      equationTex = "\\left|\\mathbb{N}\\right| + " + k + " = \\left|\\mathbb{N}\\right|";
      formulaTex = "g(n) = n + " + k;
    } else {
      for (let i = 0; i < k; i++) rooms[i] = { guest: "N" + (i + 1), kind: "new" };
      for (let i = k; i < ROOM_COUNT; i++) rooms[i] = { guest: "G" + (i - k + 1), kind: "old" };
      for (let i = 1; i <= k; i++) {
        const guest: Transfer = { row: "new", label: "N" + i, fromIndex: i - 1, room: i, kind: "new" };
        arrows.push(guest);
      }
      note = "Новые гости занимают первые " + k + " комнат. Жильцы остаются в сдвинутых комнатах.";
      equationTex = "\\left|\\mathbb{N}\\right| + " + k + " = \\left|\\mathbb{N}\\right|";
      formulaTex = "G_n \\mapsto n + " + k + ", \\quad N_j \\mapsto j";
    }
    calloutText = "Сдвиг на конечное k ничего не меняет: натуральный ряд сдвигом на k снова покрывает всё, кроме первых k мест, а эти места заняли новые гости.";
  } else if (s === "bus") {
    maxStep = 2;
    const shown = 5;
    sources = Array.from({ length: shown }, (_, i) => ({ row: "bus", label: "B" + (i + 1) }));
    localHint = "Сначала жильцы переезжают в чётные комнаты, затем пассажиры занимают нечётные.";
    if (currentStep === 0) {
      note = "В отеле заняты все комнаты. У автобуса бесконечно много пассажиров.";
      equationTex = "\\left|\\mathbb{N}\\right| + \\left|\\mathbb{N}\\right| = \\left|\\mathbb{N}\\right|";
      formulaTex = "G_n \\mapsto 2n, \\quad B_n \\mapsto 2n - 1";
    } else if (currentStep === 1) {
      for (let i = 1; i <= shown; i++) {
        rooms[2 * i - 2] = { guest: "", kind: "free" };
        rooms[2 * i - 1] = { guest: "G" + i, kind: "old" };
        arrows.push({ row: "old", label: "G" + i, fromRoom: i, room: 2 * i, kind: "old" });
      }
      note = "Жильцы переезжают на чётные места: G_n → 2n. Нечётные комнаты свободны, автобус ждёт.";
      equationTex = "\\left|\\mathbb{N}\\right| + \\left|\\mathbb{N}\\right| = \\left|\\mathbb{N}\\right|";
      formulaTex = "G_n \\mapsto 2n, \\quad B_n \\mapsto 2n - 1";
    } else {
      for (let i = 1; i <= shown; i++) {
        rooms[2 * i - 2] = { guest: "B" + i, kind: "bus" };
        rooms[2 * i - 1] = { guest: "G" + i, kind: "old" };
        arrows.push({ row: "bus", label: "B" + i, fromIndex: i - 1, room: 2 * i - 1, kind: "bus" });
      }
      note = "Пассажиры занимают нечётные комнаты: B_n → 2n − 1. Каждая комната снова занята ровно одним гостем.";
      equationTex = "\\left|\\mathbb{N}\\right| + \\left|\\mathbb{N}\\right| = \\left|\\mathbb{N}\\right|";
      formulaTex = "G_n \\mapsto 2n, \\quad B_n \\mapsto 2n - 1";
    }
    calloutText = "Два счётных множества вместе снова счётны. Новая бесконечность не появилась: чётные и нечётные номера задают две копии N внутри одного N.";
  } else {
    maxStep = BUS_ROWS + BUS_SEATS - 1;
    localHint = "Автобусов счётно много. Каждая пара (автобус, место) получает свой номер комнаты.";
    sources = [];
    if (currentStep === 0) {
      note = "Ничего не размещено.";
    } else {
      const diagonal = currentStep - 1;
      const pairs: string[] = [];
      for (let bus = 0; bus < BUS_ROWS; bus++) {
        for (let seat = 1; seat <= BUS_SEATS; seat++) {
          if (bus + seat - 1 === diagonal) pairs.push("B" + bus + "·" + seat + " → " + busRoom(bus, seat));
        }
      }
      note = "Диагональ " + diagonal + ": " + pairs.join(", ") + ".";
    }
    equationTex = "\\left|\\mathbb{N}\\right| \\times \\left|\\mathbb{N}\\right| = \\left|\\mathbb{N}\\right|";
    formulaTex = "\\operatorname{room}(b,n) = \\frac{s(s+1)}{2} + b + 1, \\quad s = b+n-1";
    calloutText = "Старых жильцов можно отправить в чётные комнаты, а пары (автобус, место) в нечётные. Счётное объединение счётных множеств счётно: диагональная нумерация превращает двумерную таблицу в один список.";
  }

  return { rooms, sources, arrows, note, localHint, equationTex, formulaTex, calloutText, maxStep, currentStep };
}

function sourceY(row: string): number {
  return row === "bus" ? 268 : 222;
}

function sourceX(index: number): number {
  return 88 + index * 148;
}

function roomX(index: number): number {
  return 32 + index * 87;
}

function hotelSvg(state: HotelState): string {
  const parts: string[] = [];
  parts.push('<svg class="hotel-svg" viewBox="0 0 920 380" role="img" aria-label="Схема переезда гостей в отеле">');
  parts.push('<defs>');
  for (const kind of ["old", "new", "bus"] as const) {
    parts.push('<marker id="hotel-arrow-' + kind + '" viewBox="0 0 10 10" refX="10" refY="5" markerWidth="8" markerHeight="8" markerUnits="userSpaceOnUse" orient="auto"><path d="M0 0 L10 5 L0 10 Z" fill="' + COLORS[kind] + '"></path></marker>');
  }
  parts.push('</defs>');
  parts.push('<rect x="16" y="12" width="888" height="100" rx="14" fill="#fcfbf8" stroke="#d9d3c6" stroke-width="1.2"></rect>');
  parts.push('<text x="30" y="31" font-size="10" font-weight="700" letter-spacing=".12em" fill="#5e6a75">ОТЕЛЬ</text>');

  for (let i = 0; i < state.rooms.length; i++) {
    const room = state.rooms[i];
    const x = roomX(i);
    const isFree = room.kind === "free";
    const fill = isFree ? "#fff5f3" : (room.kind === "new" ? "#e3f2eb" : (room.kind === "bus" ? "#faeed9" : "#ffffff"));
    const stroke = isFree ? COLORS.free : (room.kind === "new" ? COLORS.new : (room.kind === "bus" ? COLORS.bus : "#cfc7b8"));
    parts.push('<g class="h-room">');
    parts.push('<rect x="' + x + '" y="40" width="74" height="58" rx="9" fill="' + fill + '" stroke="' + stroke + '" stroke-width="1.4"' + (isFree ? ' stroke-dasharray="5 4"' : '') + '></rect>');
    parts.push('<text x="' + (x + 37) + '" y="57" text-anchor="middle" font-size="9" fill="#5e6a75">комната ' + (i + 1) + '</text>');
    parts.push('<text x="' + (x + 37) + '" y="80" text-anchor="middle" font-size="12" font-weight="700" fill="' + (isFree ? COLORS.free : '#18222d') + '">' + (isFree ? "пусто" : room.guest) + '</text>');
    parts.push('</g>');
  }

  const exitKind = new Map<number, string>();
  const entryKind = new Map<number, string>();
  for (const arrow of state.arrows) {
    if (arrow.fromRoom) exitKind.set(arrow.fromRoom, COLORS[arrow.kind]);
    entryKind.set(arrow.room, COLORS[arrow.kind]);
  }
  for (const [room, color] of exitKind) {
    parts.push('<circle cx="' + (roomX(room - 1) + 14) + '" cy="98" r="2.5" fill="' + color + '"></circle>');
  }
  for (const [room, color] of entryKind) {
    parts.push('<circle cx="' + (roomX(room - 1) + 60) + '" cy="98" r="2.5" fill="' + color + '"></circle>');
  }

  const rows: Record<string, Source[]> = {};
  for (const source of state.sources) {
    if (!rows[source.row]) rows[source.row] = [];
    rows[source.row].push(source);
  }

  const externalRows = new Set(state.sources.map((source) => source.row));
  const entryKeys = new Set<string>();
  for (const arrow of state.arrows) {
    if (arrow.fromRoom) continue;
    externalRows.add(arrow.row);
    const rowSources = rows[arrow.row] || [];
    let fromIndex = arrow.fromIndex;
    if (fromIndex === undefined) fromIndex = rowSources.findIndex((source) => source.label === arrow.label);
    if (fromIndex >= 0 && !rowSources[fromIndex]) entryKeys.add(arrow.row + ":" + fromIndex);
  }

  const sourceParts: string[] = [];
  for (const rowName of externalRows) {
    const y = sourceY(rowName);
    const label = rowName === "bus" ? "автобус" : "снаружи";
    sourceParts.push('<text x="14" y="' + (y + 21) + '" font-size="10" fill="#5e6a75">' + label + '</text>');
    (rows[rowName] || []).forEach((source, index) => {
      const x = sourceX(index);
      const fill = rowName === "bus" ? "#faeed9" : "#e3f2eb";
      const stroke = rowColor(rowName);
      sourceParts.push('<rect x="' + x + '" y="' + y + '" width="72" height="34" rx="7" fill="' + fill + '" stroke="' + stroke + '" stroke-width="1.1"></rect>');
      sourceParts.push('<text x="' + (x + 36) + '" y="' + (y + 21) + '" text-anchor="middle" font-size="11" font-weight="700" fill="#18222d">' + source.label + '</text>');
    });
    for (const key of entryKeys) {
      if (!key.startsWith(rowName + ":")) continue;
      const index = Number(key.split(":")[1]);
      const x = sourceX(index);
      sourceParts.push('<rect x="' + x + '" y="' + y + '" width="72" height="34" rx="7" fill="#fff" stroke="' + rowColor(rowName) + '" stroke-width="1" stroke-dasharray="4 4" opacity=".55"></rect>');
      sourceParts.push('<text x="' + (x + 36) + '" y="' + (y + 21) + '" text-anchor="middle" font-size="10" fill="#5e6a75">вход</text>');
    }
  }

  const arrowParts: string[] = [];
  for (const arrow of state.arrows) {
    let path = "";
    if (arrow.fromRoom) {
      const to = arrow.room;
      const x1 = roomX(arrow.fromRoom - 1) + 14;
      const x2 = roomX(to - 1) + 60;
      const lane = 106 + Math.min(5, Math.max(1, to - arrow.fromRoom)) * 9 + (arrow.fromRoom % 3) * 7;
      path = 'M ' + x1 + ' 98 C ' + x1 + ' ' + lane + ', ' + x2 + ' ' + lane + ', ' + x2 + ' 98';
    } else {
      const rowSources = rows[arrow.row] || [];
      let fromIndex = arrow.fromIndex;
      if (fromIndex === undefined) fromIndex = rowSources.findIndex((source) => source.label === arrow.label);
      if (fromIndex < 0) continue;
      const x1 = sourceX(fromIndex) + 36;
      const y1 = sourceY(arrow.row);
      const x2 = roomX(arrow.room - 1) + 60;
      const lift = arrow.row === "bus" ? 64 : 44;
      path = 'M ' + x1 + ' ' + y1 + ' C ' + x1 + ' ' + (y1 - lift) + ', ' + x2 + ' 170, ' + x2 + ' 98';
    }
    arrowParts.push('<path class="hotel-arrow" d="' + path + '" stroke="' + COLORS[arrow.kind] + '" marker-end="url(#hotel-arrow-' + arrow.kind + ')"></path>');
    if (!reduceMotion) {
      const tokenText = arrow.label === "новый" ? "N" : arrow.label;
      arrowParts.push('<g class="hotel-token" aria-hidden="true"><circle r="8" fill="' + COLORS[arrow.kind] + '"></circle><text x="0" y="3" text-anchor="middle" font-size="8" font-weight="700" fill="#fff">' + tokenText + '</text><animateMotion dur="0.95s" begin="0s" fill="freeze" path="' + path + '"></animateMotion><animate attributeName="opacity" values="1;1;0" keyTimes="0;0.9;1" dur="1.05s" fill="freeze"></animate></g>');
    }
  }

  parts.push('<text x="900" y="80" text-anchor="middle" font-size="20" fill="#5e6a75">…</text>');
  parts.push(arrowParts.join(""));
  parts.push(sourceParts.join(""));
  parts.push('</svg>');
  return parts.join("");
}

function busRoom(bus: number, seat: number): number {
  const s = bus + seat - 1;
  return (s * (s + 1)) / 2 + bus + 1;
}

function renderBusGrid(): void {
  clear(stage);
  const buses = BUS_ROWS;
  const seats = BUS_SEATS;
  const grid = el("div", { class: "bus-grid" });
  grid.appendChild(el("div", { class: "bus-corner", text: "автобус \\ место" }));
  for (let seat = 1; seat <= seats; seat++) grid.appendChild(el("div", { class: "bus-head", text: "место " + seat }));
  for (let bus = 0; bus < buses; bus++) {
    grid.appendChild(el("div", { class: "bus-row", text: "B" + bus }));
    for (let seat = 1; seat <= seats; seat++) {
      const room = busRoom(bus, seat);
      const sum = bus + seat - 1;
      const diagonal = step - 1;
      const shown = step > 0 && sum <= diagonal;
      const current = step > 0 && sum === diagonal;
      const cell = el("div", {
        class: "bus-cell" + (shown ? " assigned" : "") + (current ? " current" : ""),
      }, [
        el("span", { class: "bus-room", text: "№" + room }),
        el("small", { text: (shown ? "занята" : "ждёт") }),
      ]);
      grid.appendChild(cell);
    }
  }
  stage.appendChild(grid);

  const assignment = new Map<number, { label: string; sum: number }>();
  for (let bus = 0; bus < buses; bus++) {
    for (let seat = 1; seat <= seats; seat++) {
      assignment.set(busRoom(bus, seat), { label: "B" + bus + "·" + seat, sum: bus + seat - 1 });
    }
  }
  const diagonal = step - 1;
  const roomLane = el("div", { class: "bus-rooms" });
  for (let room = 1; room <= 10; room++) {
    const info = assignment.get(room);
    const assigned = step > 0 && info !== undefined && info.sum <= diagonal;
    const isNew = assigned && info !== undefined && info.sum === diagonal;
    roomLane.appendChild(el("div", { class: "bus-room-card" + (assigned ? " assigned" : "") + (isNew ? " current" : "") }, [
      el("small", { text: "комната " + room }),
      el("b", { text: assigned && info ? info.label : "…" }),
    ]));
  }
  stage.appendChild(el("p", { class: "hint", text: "Нижняя лента показывает окно комнат. В сетке отмечено, какая пара займёт комнату." }));
  stage.appendChild(roomLane);
}

function renderMoves(state: HotelState): void {
  clear(movesNode);
  let moves: Move[];
  if (scenario === "buses" && step > 0) {
    const diagonal = step - 1;
    moves = [];
    for (let bus = 0; bus < BUS_ROWS; bus++) {
      for (let seat = 1; seat <= BUS_SEATS; seat++) {
        if (bus + seat - 1 === diagonal) {
          moves.push({ label: "B" + bus + "·" + seat, room: busRoom(bus, seat), kind: "bus" });
        }
      }
    }
  } else {
    moves = state.arrows.map((arrow) => ({ label: arrow.label, room: arrow.room, kind: arrow.kind }));
  }
  if (!moves.length) {
    movesNode.appendChild(el("p", { class: "hint", text: "Пока никто не двигался." }));
    return;
  }
  for (const move of moves) {
    movesNode.appendChild(el("div", { class: "move-row " + move.kind }, [
      el("span", { class: "move-from", text: move.label }),
      el("span", { class: "move-arrow", text: "→" }),
      el("span", { class: "move-to", text: "комната " + move.room }),
    ]));
  }
  if (scenario === "one" && step === 1) {
    movesNode.appendChild(el("p", { class: "hint", text: "G10 уезжает в комнату 11 и дальше, за пределы окна." }));
  } else if (scenario === "group" && step === 1) {
    movesNode.appendChild(el("p", { class: "hint", text: "Последние " + groupSize + " жильцов уезжают за пределы окна." }));
  } else if (scenario === "bus" && step === 1) {
    movesNode.appendChild(el("p", { class: "hint", text: "G6 и дальше уезжают в комнаты 12, 14, …" }));
  }
}

function stepTitle(index: number): string {
  if (scenario === "buses") return index === 0 ? "Старт" : "Диагональ " + (index - 1);
  if (scenario === "bus") return ["Занято", "Чётные", "Нечётные"][index] ?? "";
  return ["Занято", "Сдвиг", "Заселение"][index] ?? "";
}

function stepDetail(index: number): string {
  if (scenario === "one") {
    return ["свободных комнат нет", "жилец n переезжает в n+1", "новый гость в комнате 1"][index] ?? "";
  }
  if (scenario === "group") {
    return ["снаружи " + groupSize + " гостей", "сдвиг на " + groupSize, "первые " + groupSize + " комнат заняты"][index] ?? "";
  }
  if (scenario === "bus") {
    return ["автобус ждёт", "жильцы в чётные: G_n → 2n", "пассажиры в нечётные: B_n → 2n − 1"][index] ?? "";
  }
  return index === 0 ? "ничего не размещено" : "пары диагонали получают комнаты";
}

function paintHotel(): void {
  const state = stateFor(scenario, step);
  groupWrap.classList.toggle("hidden", scenario !== "group");
  title.textContent = scenario === "one" ? "Один гость" : (scenario === "group" ? "Конечная группа" : (scenario === "bus" ? "Бесконечный автобус" : "Бесконечно много автобусов"));
  hint.textContent = state.localHint;
  clear(stepsNode);
  for (let i = 0; i <= state.maxStep; i++) {
    const item = el("li", {
      class: "hotel-step" + (i === step ? " active" : "") + (i < step ? " done" : ""),
      "aria-current": i === step ? "step" : undefined,
    }, [
      el("b", { text: scenario === "buses" ? (i === 0 ? "S" : String(i - 1)) : String(i) }),
      el("span", {}, [
        el("strong", { text: stepTitle(i) }),
        el("small", { text: stepDetail(i) }),
      ]),
    ]);
    stepsNode.appendChild(item);
  }

  if (scenario === "buses") {
    renderBusGrid();
  } else {
    clear(stage);
    const wrap = el("div", { class: "hotel-svg-wrap" });
    wrap.innerHTML = hotelSvg(state);
    stage.appendChild(wrap);
  }

  setStatus(statusNode, state.note, step === 0 ? "warn" : "ok");
  formula.replaceChildren(math(state.formulaTex, true));
  equation.replaceChildren(math(state.equationTex, true));
  callout.textContent = state.calloutText;
  renderMoves(state);
}

function renderHotel(): void {
  keepFocus(paintHotel);
}

function setScenario(name: string): void {
  stopAuto();
  scenario = name;
  step = 0;
  for (const button of document.querySelectorAll<HTMLButtonElement>("#hotel-scenarios button")) {
    const active = button.dataset.scenario === name;
    button.classList.toggle("active", active);
    button.setAttribute("aria-pressed", String(active));
  }
  renderHotel();
  startAuto();
}

must<HTMLElement>("#hotel-scenarios").addEventListener("click", (event) => {
  if (!(event.target instanceof Element)) return;
  const button = event.target.closest<HTMLButtonElement>("button[data-scenario]");
  if (button && button.dataset.scenario) setScenario(button.dataset.scenario);
});

function renderFinite(): void {
  const rooms = must<HTMLElement>("#finite-rooms");
  clear(rooms);
  for (let i = 1; i <= 3; i++) {
    rooms.appendChild(el("div", { class: "finite-room" }, [
      el("small", { text: "комната " + i }),
      el("b", { text: "G" + i }),
    ]));
  }
  if (finiteTried) {
    rooms.appendChild(el("div", { class: "finite-room waiting" }, [
      el("small", { text: "снаружи" }),
      el("b", { text: "новый" }),
    ]));
  }
  setStatus(must<HTMLElement>("#finite-status"), finiteTried ? "Гостей четыре, комнат три. Свободной комнаты нет, сдвиг не помогает." : "Три комнаты заняты тремя гостями.", finiteTried ? "bad" : "warn");
}

must<HTMLButtonElement>("#finite-try").addEventListener("click", () => { finiteTried = true; renderFinite(); });
must<HTMLButtonElement>("#finite-reset").addEventListener("click", () => { finiteTried = false; renderFinite(); });

function renderArithmetic(): void {
  const wrap = must<HTMLElement>("#arithmetic");
  clear(wrap);
  const rows: [string, string, string][] = [
    ["\\left|\\mathbb{N}\\right| + 1 = \\left|\\mathbb{N}\\right|", "один гость", "one"],
    ["\\left|\\mathbb{N}\\right| + k = \\left|\\mathbb{N}\\right|", "конечная группа", "group"],
    ["\\left|\\mathbb{N}\\right| + \\left|\\mathbb{N}\\right| = \\left|\\mathbb{N}\\right|", "бесконечный автобус", "bus"],
    ["\\left|\\mathbb{N}\\right| \\times \\left|\\mathbb{N}\\right| = \\left|\\mathbb{N}\\right|", "бесконечно много автобусов", "buses"],
    ["2^{\\left|\\mathbb{N}\\right|} > \\left|\\mathbb{N}\\right|", "диагональ Кантора", "diagonal"],
  ];
  const table = el("table", { class: "data arithmetic-table" });
  const head = el("tr");
  head.appendChild(el("th", { class: "left", text: "равенство" }));
  head.appendChild(el("th", { class: "left", text: "что показывает" }));
  head.appendChild(el("th", { class: "left", text: "открыть" }));
  const thead = el("thead");
  thead.appendChild(head);
  table.appendChild(thead);
  const body = el("tbody");
  for (const [tex, label, target] of rows) {
    const tr = el("tr");
    const texCell = el("td", { class: "left" });
    texCell.appendChild(math(tex, false));
    tr.appendChild(texCell);
    tr.appendChild(el("td", { class: "left", text: label }));
    const actionCell = el("td", { class: "left" });
    const button = el("button", {
      type: "button",
      text: "Показать",
      "aria-label": "Показать сценарий: " + label,
    });
    button.addEventListener("click", () => {
      if (target === "diagonal") {
        showTab("diagonal");
      } else {
        showTab("hotel");
        setScenario(target);
      }
    });
    actionCell.appendChild(button);
    tr.appendChild(actionCell);
    body.appendChild(tr);
  }
  table.appendChild(body);
  wrap.appendChild(table);
}

function integerOf(n: number): number {
  if (n === 0) return 0;
  return n % 2 === 1 ? (n + 1) / 2 : -n / 2;
}

function renderIntegers(): void {
  const list = must<HTMLElement>("#integers-list");
  clear(list);
  for (let n = 0; n <= integerSteps; n++) {
    const value = integerOf(n);
    list.appendChild(el("div", { class: "map-column" }, [
      el("small", { text: "n=" + n }),
      el("span", { class: "map-arrow", text: "↓" }),
      el("b", { text: String(value) }),
    ]));
  }
  must<HTMLElement>("#integers-formula").replaceChildren(math("f(n) = \\begin{cases} 0, & n = 0 \\\\ (n+1)/2, & n \\text{ нечётно} \\\\ -n/2, & n \\text{ чётно} \\end{cases}", true));
  setStatus(must<HTMLElement>("#integers-status"), "Каждое целое появляется ровно один раз: 0, 1, −1, 2, −2, …", "ok");
}

must<HTMLButtonElement>("#integers-add").addEventListener("click", () => { integerSteps += 4; renderIntegers(); });
must<HTMLButtonElement>("#integers-reset").addEventListener("click", () => { integerSteps = 8; renderIntegers(); });

function makeDiagonal(): void {
  diagonalTable = [];
  for (let i = 0; i < 5; i++) {
    const row: number[] = [];
    for (let j = 0; j < 6; j++) row.push(Math.random() < 0.5 ? 0 : 1);
    diagonalTable.push(row);
  }
  diagonalStep = 0;
}

function renderDiagonal(): void {
  const node = must<HTMLElement>("#diagonal-table");
  clear(node);
  const table = el("table", { class: "data" });
  const head = el("tr");
  head.appendChild(el("th", { text: "строка" }));
  for (let j = 0; j < 6; j++) head.appendChild(el("th", { text: String(j + 1) }));
  const thead = el("thead");
  thead.appendChild(head);
  table.appendChild(thead);
  const body = el("tbody");
  for (let i = 0; i < 5; i++) {
    const tr = el("tr");
    tr.appendChild(el("th", { text: "s" + (i + 1) }));
    for (let j = 0; j < 6; j++) {
      const cls = "mono" + (diagonalStep >= 1 && i === j ? " diag" : "");
      tr.appendChild(el("td", { class: cls, text: String(diagonalTable[i][j]) }));
    }
    body.appendChild(tr);
  }
  if (diagonalStep >= 2) {
    const dRow = el("tr", { class: "hl" });
    dRow.appendChild(el("th", { text: "d" }));
    for (let j = 0; j < 5; j++) dRow.appendChild(el("td", { class: "mono diag", text: String(1 - diagonalTable[j][j]) }));
    dRow.appendChild(el("td", { class: "muted", text: "…" }));
    body.appendChild(dRow);
  }
  table.appendChild(body);
  node.appendChild(table);
  must<HTMLElement>("#diagonal-formula").replaceChildren(math("d_i = 1 - b_{ii}", false));
  const diagonalStatus = must<HTMLElement>("#diagonal-status");
  const diagonalHint = must<HTMLElement>("#diagonal-hint");
  if (diagonalStep === 0) {
    setStatus(diagonalStatus, "Список строк готов. Нажмите шаг, чтобы выделить диагональ.", "warn");
    diagonalHint.textContent = "Пока перед нами только список. Диагональ ещё не построена.";
  } else if (diagonalStep === 1) {
    setStatus(diagonalStatus, "Диагональ задают клетки b_ii. Они берут по одному биту из каждой строки.", "warn");
    diagonalHint.textContent = "На следующем шаге каждый диагональный бит перевернётся.";
  } else {
    setStatus(diagonalStatus, "Строка d отличается от каждой строки s_i в позиции i. Значит списка всех последовательностей нет.", "ok");
    diagonalHint.textContent = "Для любой строки i выполнено d_i ≠ b_ii, поэтому d не равна ни одной строке списка.";
  }
  const stepButton = must<HTMLButtonElement>("#diagonal-step");
  stepButton.disabled = diagonalStep >= 2;
  stepButton.textContent = diagonalStep >= 2 ? "Готово" : "Следующий шаг";
}

must<HTMLButtonElement>("#diagonal-step").addEventListener("click", () => {
  if (diagonalStep < 2) {
    diagonalStep += 1;
    renderDiagonal();
  }
});
must<HTMLButtonElement>("#diagonal-random").addEventListener("click", () => { makeDiagonal(); renderDiagonal(); });

makeDiagonal();
renderHotel();
renderIntegers();
renderDiagonal();
renderFinite();
renderArithmetic();
showTab("hotel");

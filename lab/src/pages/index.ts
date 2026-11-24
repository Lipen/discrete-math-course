/* Hub page: catalog by module, filters, poster. */

import type { ModuleEntry } from "../catalog";
import { catalog } from "../catalog";
import { el, must } from "../core/dom";

const listNode = must<HTMLElement>("#module-list");
const filtersNode = must<HTMLElement>("#filters");
const posterModules = must<HTMLElement>("#poster-modules");

function moduleVars(moduleInfo: ModuleEntry): string {
  return "--m:" + moduleInfo.accent + ";--m-soft:" + moduleInfo.soft;
}

for (const moduleInfo of catalog.modules) {
  const row = el("a", { class: "poster-module", href: "#module-" + moduleInfo.id });
  row.style.cssText = moduleVars(moduleInfo);
  row.innerHTML = `<i></i><span>${moduleInfo.short}</span>`;
  posterModules.appendChild(row);
}

catalog.modules.forEach((moduleInfo, moduleIndex) => {
  const block = el("section", { class: "module-block", id: "module-" + moduleInfo.id });
  block.dataset.module = moduleInfo.id;
  block.style.cssText = moduleVars(moduleInfo);
  block.innerHTML = `
    <div class="module-head">
      <span class="module-index">${String(moduleIndex + 1).padStart(2, "0")}</span>
      <div>
        <h3>${moduleInfo.name}</h3>
        <p>${moduleInfo.blurb}</p>
      </div>
    </div>
    <div class="module-grid"></div>
  `;
  const grid = block.querySelector<HTMLElement>(".module-grid");
  if (!grid) throw new Error("Нет сетки карточек для модуля " + moduleInfo.id);
  for (const lab of catalog.labsOf(moduleInfo.id)) {
    const card = el("a", { class: "lab-card" + (lab.top ? " is-top" : ""), href: lab.file });
    card.dataset.top = lab.top ? "1" : "0";
    card.style.cssText = moduleVars(moduleInfo);
    card.innerHTML = `
      ${lab.top ? '<span class="top-star" title="Эталонная лаборатория"><span aria-hidden="true">★</span><span class="sr-only">эталонная лаборатория</span></span>' : ""}
      <div class="mark">${lab.mark}</div>
      <span class="topic">${lab.topic}</span>
      <h4>${lab.title}</h4>
      <p>${lab.blurb}</p>
      <div class="tags">${lab.tags.map((tag) => `<span class="tag">${tag}</span>`).join("")}</div>
      <span class="go">Открыть →</span>
    `;
    grid.appendChild(card);
  }
  listNode.appendChild(block);
});

const allButton = el("button", { class: "filter active", type: "button", text: "Все" });
allButton.dataset.module = "all";
allButton.setAttribute("aria-pressed", "true");
filtersNode.appendChild(allButton);

for (const moduleInfo of catalog.modules) {
  const button = el("button", { class: "filter", type: "button", text: moduleInfo.short });
  button.dataset.module = moduleInfo.id;
  button.setAttribute("aria-pressed", "false");
  filtersNode.appendChild(button);
}

const topButton = el("button", { class: "filter top-filter", type: "button" });
topButton.dataset.top = "1";
topButton.setAttribute("aria-pressed", "false");
topButton.setAttribute("aria-label", "Только эталонные лаборатории");
topButton.innerHTML = '<span aria-hidden="true">★</span> эталон';
filtersNode.appendChild(topButton);

let activeModule = "all";
let topOnly = false;

function applyFilters(): void {
  for (const block of Array.from(listNode.querySelectorAll<HTMLElement>(".module-block"))) {
    let visible = 0;
    for (const card of Array.from(block.querySelectorAll<HTMLElement>(".lab-card"))) {
      const moduleOk = activeModule === "all" || block.dataset.module === activeModule;
      const topOk = !topOnly || card.dataset.top === "1";
      const show = moduleOk && topOk;
      card.hidden = !show;
      if (show) visible++;
    }
    block.classList.toggle("is-hidden", visible === 0);
  }
}

filtersNode.addEventListener("click", (event) => {
  if (!(event.target instanceof Element)) return;
  const button = event.target.closest<HTMLElement>(".filter");
  if (!button) return;
  if (button.dataset.top === "1") {
    activeModule = "all";
    topOnly = true;
  } else if (button.dataset.module === "all") {
    activeModule = "all";
    topOnly = false;
  } else {
    activeModule = button.dataset.module || "all";
    topOnly = false;
  }
  for (const item of Array.from(filtersNode.querySelectorAll<HTMLElement>(".filter"))) {
    const active = item === button;
    item.classList.toggle("active", active);
    item.setAttribute("aria-pressed", String(active));
  }
  applyFilters();
});

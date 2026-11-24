/* Smoke pass over the built lab: every page loads clean and the shared layer works. */

import { readdir } from "node:fs/promises";
import { join } from "node:path";
import { pathToFileURL } from "node:url";
import { chromium } from "playwright";

const dist = join(import.meta.dir, "..", "dist");
const failures: string[] = [];
const rows: string[] = [];

const browser = await chromium.launch();
const pages = (await readdir(dist)).filter((name) => name.endsWith(".html")).sort();

for (const page of pages) {
  const tab = await browser.newPage();
  const errors: string[] = [];
  tab.on("pageerror", (error) => errors.push(error.message));
  tab.on("console", (message) => {
    if (message.type() === "error") errors.push(message.text());
  });

  try {
    await tab.goto(pathToFileURL(join(dist, page)).href);
    await tab.waitForTimeout(200);

    const state = await tab.evaluate(() => {
      const count = (selector: string): number => document.querySelectorAll(selector).length;
      const text = (selector: string): string => (document.querySelector(selector)?.textContent || "").trim();
      const katexNodes = count("[data-tex]");
      return {
        title: document.title,
        sitebar: count(".sitebar"),
        pager: count(".lab-pager"),
        theme: document.documentElement.dataset.theme || null,
        katex: count(".katex"),
        katexNodes,
        main: (document.querySelector("main")?.textContent || "").trim().length,
        cards: count(".lab-card"),
        modules: count(".module-block"),
        buttons: count("button"),
        status: text(".status"),
        meter: text(".metric-row"),
      };
    });

    if (!state.title) failures.push(`${page}: пустой заголовок`);
    if (state.sitebar !== 1) failures.push(`${page}: sitebar=${state.sitebar}`);
    if (!state.theme) failures.push(`${page}: тема не применена`);
    if (state.katexNodes > 0 && state.katex === 0) failures.push(`${page}: KaTeX не отрендерил ${state.katexNodes} узлов`);
    if (state.main < 200) failures.push(`${page}: пустое содержимое (${state.main})`);

    if (page === "index.html") {
      if (state.cards !== 18) failures.push(`${page}: карточек ${state.cards}, ожидалось 18`);
      if (state.modules !== 5) failures.push(`${page}: модулей ${state.modules}, ожидалось 5`);
      await tab.click(".filter[data-module='logic']");
      const visible = await tab.evaluate(() => Array.from(document.querySelectorAll<HTMLElement>(".lab-card")).filter((card) => !card.hidden).length);
      if (visible !== 5) failures.push(`${page}: фильтр логики показал ${visible} карточек, ожидалось 5`);
    } else {
      if (state.pager !== 1) failures.push(`${page}: нет навигации по соседним лабораториям`);
    }

    if (page === "sets.html") {
      const before = await tab.locator("#metrics").textContent();
      await tab.click("#a-grid button");
      const after = await tab.locator("#metrics").textContent();
      if (before === after) failures.push(`${page}: переключение элемента не изменило метрики`);
    }

    if (page === "minimization.html") {
      const before = await tab.locator("#function-view").textContent();
      await tab.selectOption("#preset", "consensus");
      const after = await tab.locator("#function-view").textContent();
      if (before === after) failures.push(`${page}: выбор функции не изменил блок «Функция»`);
      await tab.click('#arity button[data-n="4"]');
      const pressed = await tab.getAttribute('#arity button[data-n="4"]', "aria-pressed");
      if (pressed !== "true") failures.push(`${page}: лента переменных не переключилась`);
    }

    const beforeTheme = await tab.evaluate(() => document.documentElement.dataset.theme);
    await tab.click("#theme");
    const afterTheme = await tab.evaluate(() => document.documentElement.dataset.theme);
    if (beforeTheme === afterTheme) failures.push(`${page}: переключатель темы не сработал`);

    if (errors.length) failures.push(`${page}: ошибки консоли: ${errors.slice(0, 3).join(" | ")}`);
    rows.push(`${page.padEnd(22)} ${state.buttons.toString().padStart(3)} кнопок  ${state.main.toString().padStart(5)} символов`);
  } catch (error) {
    failures.push(`${page}: ${String(error)}`);
  } finally {
    await tab.close();
  }
}

for (const page of pages) {
  const tab = await browser.newPage({ viewport: { width: 390, height: 844 } });
  try {
    await tab.goto(pathToFileURL(join(dist, page)).href);
    await tab.waitForTimeout(150);
    const overflow = await tab.evaluate(() => {
      const root = document.documentElement;
      return root.scrollWidth - root.clientWidth;
    });
    if (overflow > 1) failures.push(`${page}: горизонтальное переполнение на 390px (${overflow}px)`);
  } catch (error) {
    failures.push(`${page} (390px): ${String(error)}`);
  } finally {
    await tab.close();
  }
}

await browser.close();

console.log(rows.join("\n"));
if (failures.length) {
  console.error("\nПровалы:");
  for (const failure of failures) console.error("  " + failure);
  process.exit(1);
}
console.log(`\nsmoke: ${pages.length} страниц без ошибок`);

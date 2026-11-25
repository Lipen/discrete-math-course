/* Smoke pass over the built lab: every page loads clean and the shared layer works. */

import { readdir } from "node:fs/promises";
import { join } from "node:path";
import { pathToFileURL } from "node:url";
import { chromium } from "playwright";
import { catalog } from "../src/catalog";

const dist = join(import.meta.dir, "..", "dist");
const failures: string[] = [];
const rows: string[] = [];
const expectedLabs = catalog.labs.length;
const expectedLogic = catalog.labsOf("logic").length;

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
        segmented: Array.from(document.querySelectorAll<HTMLElement>(".segmented[role='group']")).map((group) => ({
          id: group.id || group.className,
          active: group.querySelectorAll("button[aria-pressed='true']").length,
        })),
      };
    });

    if (!state.title) failures.push(`${page}: пустой заголовок`);
    if (state.sitebar !== 1) failures.push(`${page}: sitebar=${state.sitebar}`);
    if (!state.theme) failures.push(`${page}: тема не применена`);
    if (state.katexNodes > 0 && state.katex === 0)
      failures.push(`${page}: KaTeX не отрендерил ${state.katexNodes} узлов`);
    if (state.main < 200) failures.push(`${page}: пустое содержимое (${state.main})`);
    for (const group of state.segmented) {
      if (group.active !== 1) failures.push(`${page}: ${group.id} активных кнопок ${group.active}`);
    }

    if (page === "index.html") {
      if (state.cards !== expectedLabs) failures.push(`${page}: карточек ${state.cards}, ожидалось ${expectedLabs}`);
      if (state.modules !== 5) failures.push(`${page}: модулей ${state.modules}, ожидалось 5`);
      await tab.click(".filter[data-module='logic']");
      const visible = await tab.evaluate(
        () => Array.from(document.querySelectorAll<HTMLElement>(".lab-card")).filter((card) => !card.hidden).length,
      );
      if (visible !== expectedLogic)
        failures.push(`${page}: фильтр логики показал ${visible} карточек, ожидалось ${expectedLogic}`);
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

    if (page === "cardinality.html") {
      const steps = await tab.locator("#hotel-steps .hotel-step").count();
      const active = await tab.locator("#hotel-steps .hotel-step.active").count();
      if (steps < 2) failures.push(`${page}: шагов ${steps}, ожидалось не меньше двух`);
      if (active !== 1) failures.push(`${page}: активных шагов ${active}`);
      const tabStyle = await tab.evaluate(() => {
        const node = document.querySelector<HTMLElement>("#tabs button.active");
        if (!node) return null;
        const style = getComputedStyle(node);
        return { color: style.color, background: style.backgroundColor };
      });
      if (!tabStyle || tabStyle.color === tabStyle.background)
        failures.push(`${page}: активная вкладка сливается с фоном`);
    }

    if (page === "relations.html") {
      await tab.click("#clear");
      await tab.click("[data-closure=reflexive]");
      const delta = await tab.locator("#closure-delta").textContent();
      if (!delta?.includes("добавлено")) failures.push(`${page}: замыкание не показало добавку`);

      await tab.click("#clear");
      for (const pair of ["1,2", "2,3", "3,4"]) {
        const [a, b] = pair.split(",");
        await tab.click(`#matrix button[aria-label="пара (${a},${b})"]`);
      }
      await tab.click("#transitive-steps");
      if (await tab.locator("#closure-stepper").isHidden()) failures.push(`${page}: шаги замыкания не открылись`);
      await tab.click("#step-next");
      const added = await tab.locator("#matrix button.added").count();
      if (added < 1) failures.push(`${page}: шаг замыкания не подсветил пары`);
      await tab.click("#step-end");
      if (!(await tab.locator("#step-next").isDisabled())) failures.push(`${page}: шаги не дошли до конца`);
      await tab.click("#step-exit");
    }

    if (page === "order.html") {
      await tab.click("#identity");
      for (const pair of ["1,4", "2,3"]) {
        const [a, b] = pair.split(",");
        await tab.click(`#matrix button[aria-label="(${a},${b})"]`);
      }
      const crossed = await tab.evaluate(() => {
        const paths = Array.from(document.querySelectorAll<SVGPathElement>(".ord-edge"));
        const point = (path: SVGPathElement, end: boolean) => {
          const length = path.getTotalLength();
          const at = path.getPointAtLength(end ? length : 0);
          return { x: at.x, y: at.y };
        };
        const a = paths.find((path) => path.dataset.from === "1");
        const b = paths.find((path) => path.dataset.from === "2");
        if (!a || !b) return true;
        const a1 = point(a, false);
        const a2 = point(a, true);
        const b1 = point(b, false);
        const b2 = point(b, true);
        return (a1.x - b1.x) * (a2.x - b2.x) < 0;
      });
      if (crossed) failures.push(`${page}: рёбра Хассе пересеклись`);
      await tab.click("#subset button");
      const selected = await tab.locator("#hasse .selected").count();
      if (selected < 1) failures.push(`${page}: подмножество не подсветилось на диаграмме`);
    }

    const beforeTheme = await tab.evaluate(() => document.documentElement.dataset.theme);
    await tab.click("#theme");
    const afterTheme = await tab.evaluate(() => document.documentElement.dataset.theme);
    if (beforeTheme === afterTheme) failures.push(`${page}: переключатель темы не сработал`);

    if (errors.length) failures.push(`${page}: ошибки консоли: ${errors.slice(0, 3).join(" | ")}`);
    rows.push(
      `${page.padEnd(22)} ${state.buttons.toString().padStart(3)} кнопок  ${state.main.toString().padStart(5)} символов`,
    );
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
    const tinyTargets = await tab.evaluate(() =>
      Array.from(document.querySelectorAll<HTMLElement>("button, a, select, input, [role='button']"))
        .filter((node) => {
          const style = getComputedStyle(node);
          const rect = node.getBoundingClientRect();
          return style.display !== "none" && style.visibility !== "hidden" && rect.width > 0 && rect.height > 0;
        })
        .filter((node) => {
          const rect = node.getBoundingClientRect();
          return rect.width < 24 || rect.height < 24;
        })
        .map((node) => `${node.tagName}:${(node.textContent || "").trim().slice(0, 20)}`),
    );
    if (tinyTargets.length) failures.push(`${page}: цели меньше 24px: ${tinyTargets.slice(0, 5).join(", ")}`);
  } catch (error) {
    failures.push(`${page} (390px): ${String(error)}`);
  } finally {
    await tab.close();
  }
}

const wide = await browser.newPage({ viewport: { width: 1440, height: 900 } });
try {
  await wide.goto(pathToFileURL(join(dist, "index.html")).href);
  await wide.waitForTimeout(150);
  const collision = await wide.evaluate(() => {
    const heading = document.querySelector("h1");
    const poster = document.querySelector(".hero-poster");
    if (!heading || !poster) return true;
    const range = document.createRange();
    range.selectNodeContents(heading);
    return range.getBoundingClientRect().right > poster.getBoundingClientRect().left;
  });
  if (collision) failures.push("index.html: заголовок заходит на постер на 1440px");
} finally {
  await wide.close();
}

await browser.close();

console.log(rows.join("\n"));
if (failures.length) {
  console.error("\nПровалы:");
  for (const failure of failures) console.error("  " + failure);
  process.exit(1);
}
console.log(`\nsmoke: ${pages.length} страниц без ошибок`);

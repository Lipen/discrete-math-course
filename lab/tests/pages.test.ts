/* Build gates: catalog integrity, page wiring, no legacy globals. */

import { describe, expect, test } from "bun:test";
import { readdir, readFile } from "node:fs/promises";
import { join } from "node:path";
import { catalog } from "../src/catalog";

const pagesDir = join(import.meta.dir, "..", "src", "pages");

async function pageFiles(): Promise<string[]> {
  return (await readdir(pagesDir)).sort();
}

describe("catalog", () => {
  test("ids, modules and files are consistent", async () => {
    const ids = new Set<string>();
    for (const lab of catalog.labs) {
      expect(ids.has(lab.id)).toBe(false);
      ids.add(lab.id);
      expect(catalog.byId.get(lab.id)).toBe(lab);
      expect(catalog.modules.some((module) => module.id === lab.module)).toBe(true);
      expect(lab.tags.length).toBeGreaterThan(0);
    }
  });

  test("every catalog page exists with a matching entry module", async () => {
    const files = await pageFiles();
    for (const lab of catalog.labs) {
      expect(files).toContain(lab.file);
      expect(files).toContain(lab.file.replace(".html", ".ts"));
    }
  });

  test("there are no pages missing from the catalog", async () => {
    const files = (await pageFiles()).filter((name) => name.endsWith(".html") && name !== "index.html");
    expect(files.length).toBe(catalog.labs.length);
    for (const file of files) {
      expect(catalog.labs.some((lab) => lab.file === file)).toBe(true);
    }
  });

  test("top labs are a small curated set", () => {
    const top = catalog.labs.filter((lab) => lab.top).map((lab) => lab.id);
    expect(top.length).toBeGreaterThan(0);
    expect(top.length).toBeLessThan(catalog.labs.length / 2);
  });
});

describe("page wiring", () => {
  test("every page uses the shared head and the new bundle order", async () => {
    const files = (await pageFiles()).filter((name) => name.endsWith(".html"));
    for (const file of files) {
      const html = await readFile(join(pagesDir, file), "utf8");
      expect(html).toContain("<!-- @head -->");
      expect(html).not.toContain("<script>");
      expect(html).not.toContain('src="lab-core.js"');
      expect(html).not.toContain('src="lab-math.js"');
      expect(html).not.toContain('src="catalog.js"');
      expect(html).not.toContain('src="lab-site.js"');
      expect(html).toContain('<script src="site.js"></script>');
      expect(html).toContain(`<script src="${file.replace(".html", ".js")}"></script>`);
      expect(html.indexOf('src="site.js"')).toBeLessThan(html.indexOf(`src="${file.replace(".html", ".js")}"`));
    }
  });

  test("no page module uses the old global namespaces", async () => {
    const files = (await pageFiles()).filter((name) => name.endsWith(".ts"));
    for (const file of files) {
      const source = await readFile(join(pagesDir, file), "utf8");
      expect(source).not.toContain("window.Lab");
      expect(source).not.toContain("window.Logic");
      expect(source).not.toContain("window.FOL");
      expect(source).not.toContain("window.Sets");
      expect(source).not.toContain("window.LAB_CATALOG");
    }
  });

  test("every must(#id) points at an id present in the page", async () => {
    const problems: string[] = [];
    for (const file of await pageFiles()) {
      if (!file.endsWith(".ts")) continue;
      const source = await readFile(join(pagesDir, file), "utf8");
      const html = await readFile(join(pagesDir, file.replace(".ts", ".html")), "utf8");
      for (const match of source.matchAll(/must(?:<[^>]+>)?\(\s*["'`]#([\w-]+)["'`]/g)) {
        const id = match[1];
        if (!html.includes(`id="${id}"`)) problems.push(`${file}: #${id}`);
      }
    }
    expect(problems).toEqual([]);
  });

  test("pages with static formulas import the math renderer", async () => {
    const problems: string[] = [];
    for (const file of await pageFiles()) {
      if (!file.endsWith(".html")) continue;
      const html = await readFile(join(pagesDir, file), "utf8");
      if (!html.includes("data-tex=")) continue;
      const source = await readFile(join(pagesDir, file.replace(".html", ".ts")), "utf8");
      if (!source.includes("core/math")) problems.push(file);
    }
    expect(problems).toEqual([]);
  });

  test("querySelector ids used for required nodes exist too", async () => {
    const problems: string[] = [];
    for (const file of await pageFiles()) {
      if (!file.endsWith(".ts")) continue;
      const source = await readFile(join(pagesDir, file), "utf8");
      const html = await readFile(join(pagesDir, file.replace(".ts", ".html")), "utf8");
      for (const match of source.matchAll(/querySelector(?:<[^>]+>)?\(\s*["'`]#([\w-]+)["'`]/g)) {
        const id = match[1];
        if (!html.includes(`id="${id}"`)) problems.push(`${file}: #${id}`);
      }
    }
    expect(problems).toEqual([]);
  });
});

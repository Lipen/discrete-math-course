/* Build the static lab: bundles from src, pages with shared head, vendored assets. */

import { cp, mkdir, readdir, readFile, rm, writeFile } from "node:fs/promises";
import { join } from "node:path";

export const labRoot = import.meta.dir;
export const srcDir = join(labRoot, "src");
export const distDir = join(labRoot, "dist");

async function moduleEntries(dir: string): Promise<string[]> {
  const names = await readdir(dir);
  return names.filter((name) => name.endsWith(".ts")).map((name) => join(dir, name));
}

async function checkReferences(page: string, html: string, missing: string[]): Promise<void> {
  const refs = [
    ...Array.from(html.matchAll(/<script src="([^"]+)"/g), (match) => match[1]),
    ...Array.from(html.matchAll(/<link rel="stylesheet" href="([^"]+)"/g), (match) => match[1]),
  ];
  for (const ref of refs) {
    if (ref.startsWith("http")) continue;
    if (!(await Bun.file(join(distDir, ref)).exists())) missing.push(`${page} -> ${ref}`);
  }
}

export async function build(): Promise<void> {
  const started = performance.now();
  await rm(distDir, { recursive: true, force: true });
  await mkdir(distDir, { recursive: true });

  const entrypoints = [
    ...(await moduleEntries(join(srcDir, "pages"))),
    ...(await moduleEntries(join(srcDir, "entries"))),
  ];
  const result = await Bun.build({
    entrypoints,
    outdir: distDir,
    naming: "[name].js",
    target: "browser",
    format: "iife",
    minify: true,
    sourcemap: "linked",
  });
  if (!result.success) {
    for (const log of result.logs) console.error(log);
    throw new Error("Бандлы не собрались.");
  }

  await cp(join(srcDir, "static", "lab.css"), join(distDir, "lab.css"));
  await cp(join(srcDir, "static", "fonts"), join(distDir, "fonts"), { recursive: true });
  await cp(join(srcDir, "static", "vendor"), join(distDir, "vendor"), { recursive: true });

  const head = (await readFile(join(srcDir, "partials", "head.html"), "utf8")).trimEnd();
  const pages = (await readdir(join(srcDir, "pages"))).filter((name) => name.endsWith(".html"));
  const missing: string[] = [];
  const strict = process.argv.includes("--strict");
  const pending: string[] = [];

  for (const page of pages) {
    const source = await readFile(join(srcDir, "pages", page), "utf8");
    if (!source.includes("<!-- @head -->")) {
      if (strict) throw new Error(`${page}: нет маркера <!-- @head -->`);
      pending.push(page);
      continue;
    }
    const html = source.replace("<!-- @head -->", head);
    if (html.includes("<!-- @")) throw new Error(`${page}: остался необработанный маркер`);
    await writeFile(join(distDir, page), html);
    await checkReferences(page, html, missing);
  }
  if (missing.length) throw new Error("Страницы ссылаются на отсутствующие файлы:\n" + missing.join("\n"));

  const bundles = result.outputs
    .map((output) => ({ name: output.path.split("/").pop() || "", size: output.size }))
    .filter((output) => output.name.endsWith(".js"))
    .sort((a, b) => b.size - a.size);
  const total = bundles.reduce((sum, bundle) => sum + bundle.size, 0);
  const maps = result.outputs
    .filter((output) => output.path.endsWith(".map"))
    .reduce((sum, output) => sum + output.size, 0);

  console.log(
    `страниц: ${pages.length - pending.length}/${pages.length}, бандлов: ${bundles.length}, JS: ${(total / 1024).toFixed(1)} KiB, карты: ${(maps / 1024).toFixed(0)} KiB`,
  );
  if (pending.length) console.warn(`не переведены (нет <!-- @head -->): ${pending.join(", ")}`);
  for (const bundle of bundles.slice(0, 5))
    console.log(`  ${bundle.name.padEnd(24)} ${(bundle.size / 1024).toFixed(1)} KiB`);
  console.log(`сборка: ${(performance.now() - started).toFixed(0)} ms`);
}

if (import.meta.main) await build();

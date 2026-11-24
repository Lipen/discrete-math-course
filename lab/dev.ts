/* Watch src, rebuild, and serve dist on http://localhost:8765. */

import { watch } from "node:fs";
import { resolve, sep } from "node:path";
import { build, distDir, srcDir } from "./build";

await build();

const server = Bun.serve({
  port: Number(process.env.PORT || 8765),
  async fetch(request) {
    const path = decodeURIComponent(new URL(request.url).pathname);
    const target = resolve(distDir, "." + (path === "/" ? "/index.html" : path));
    if (target !== distDir && !target.startsWith(distDir + sep)) {
      return new Response("Not found", { status: 404 });
    }
    const file = Bun.file(target);
    if (!(await file.exists())) return new Response("Not found", { status: 404 });
    return new Response(file);
  },
});

console.log(`dev: ${server.url}`);

let timer: Timer | undefined;
watch(srcDir, { recursive: true }, () => {
  clearTimeout(timer);
  timer = setTimeout(async () => {
    try {
      await build();
    } catch (error) {
      console.error(String(error));
    }
  }, 150);
});

process.on("SIGINT", async () => {
  await server.stop();
  process.exit(0);
});

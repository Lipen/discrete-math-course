/* Static server for the built site: bun site/serve.ts <dir> [port]. */

import { resolve, sep } from "node:path";

const [root = "site/dist", portArg = "8765"] = process.argv.slice(2);
const base = resolve(root);
const port = Number(portArg);

if (!Number.isInteger(port) || port <= 0) throw new Error(`Плохой порт: ${portArg}`);

const server = Bun.serve({
  port,
  hostname: "127.0.0.1",
  async fetch(request) {
    const url = new URL(request.url);
    let path = decodeURIComponent(url.pathname);
    if (path.endsWith("/")) path += "index.html";
    let target = resolve(base, "." + path);
    if (target !== base && !target.startsWith(base + sep)) return new Response("Not found", { status: 404 });

    let file = Bun.file(target);
    if (!(await file.exists())) {
      target = resolve(target, "index.html");
      if (!target.startsWith(base + sep)) return new Response("Not found", { status: 404 });
      file = Bun.file(target);
      if (!(await file.exists())) return new Response("Not found", { status: 404 });
    }
    return new Response(file, { headers: { "cache-control": "no-store" } });
  },
});

console.log(`serve: ${server.url} → ${base}`);

process.on("SIGINT", async () => {
  await server.stop();
  process.exit(0);
});

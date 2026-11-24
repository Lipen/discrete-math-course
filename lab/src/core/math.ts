/* KaTeX bridge: render formulas and upgrade [data-tex] nodes. */

import { el } from "./dom";

export function renderMath(node: HTMLElement, tex: string, display = false): HTMLElement {
  if (!window.katex) {
    node.textContent = tex;
    return node;
  }
  try {
    window.katex.render(tex, node, {
      displayMode: display,
      throwOnError: false,
      strict: false,
      trust: false,
      output: "html",
    });
  } catch {
    node.textContent = tex;
  }
  return node;
}

export function math(tex: string, display = false): HTMLElement {
  const node = el(display ? "div" : "span", { class: display ? "math-display" : "math-inline" });
  return renderMath(node, tex, display);
}

export function scanMath(root: ParentNode = document): void {
  root.querySelectorAll<HTMLElement>("[data-tex]").forEach((node) => {
    renderMath(node, node.getAttribute("data-tex") || "", node.getAttribute("data-display") === "1");
  });
}

function scanWhenReady(): void {
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", () => scanMath(document));
  } else {
    scanMath(document);
  }
}

scanWhenReady();

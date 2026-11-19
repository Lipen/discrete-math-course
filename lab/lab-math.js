/* KaTeX helpers for the lab pages. */
(function () {
  "use strict";

  function render(node, tex, display) {
    if (!window.katex) {
      node.textContent = tex;
      return node;
    }
    try {
      katex.render(tex, node, {
        displayMode: Boolean(display),
        throwOnError: false,
        strict: false,
        trust: false,
        output: "html",
      });
    } catch (error) {
      node.textContent = tex;
    }
    return node;
  }

  function math(tex, display) {
    const node = document.createElement(display ? "div" : "span");
    node.className = display ? "math-display" : "math-inline";
    return render(node, tex, display);
  }

  function scan(root) {
    const scope = root || document;
    scope.querySelectorAll("[data-tex]").forEach((node) => {
      render(node, node.getAttribute("data-tex"), node.getAttribute("data-display") === "1");
    });
  }

  window.Lab = window.Lab || {};
  window.Lab.math = math;
  window.Lab.renderMath = render;
  window.Lab.scanMath = scan;

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", () => scan(document));
  } else {
    scan(document);
  }
})();

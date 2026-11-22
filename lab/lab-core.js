/* Shared helpers for the discrete-mathematics lab pages. */
(function () {
  "use strict";

  const $ = (sel, root) => (root || document).querySelector(sel);
  const $$ = (sel, root) => Array.from((root || document).querySelectorAll(sel));

  function el(tag, attrs, children) {
    const node = document.createElement(tag);
    if (attrs) {
      for (const key of Object.keys(attrs)) {
        const value = attrs[key];
        if (value === undefined || value === null) continue;
        if (key === "class") node.className = value;
        else if (key === "text") node.textContent = value;
        else if (key === "html") node.innerHTML = value;
        else if (key.startsWith("on") && typeof value === "function") node.addEventListener(key.slice(2), value);
        else node.setAttribute(key, value);
      }
    }
    if (children !== undefined) {
      const list = Array.isArray(children) ? children : [children];
      for (const child of list) {
        if (child === null || child === undefined) continue;
        node.appendChild(typeof child === "string" || typeof child === "number"
          ? document.createTextNode(String(child))
          : child);
      }
    }
    return node;
  }

  function svg(tag, attrs, children) {
    const node = document.createElementNS("http://www.w3.org/2000/svg", tag);
    if (attrs) {
      for (const key of Object.keys(attrs)) {
        if (attrs[key] === undefined || attrs[key] === null) continue;
        node.setAttribute(key, attrs[key]);
      }
    }
    if (children !== undefined) {
      const list = Array.isArray(children) ? children : [children];
      for (const child of list) {
        if (child === null || child === undefined) continue;
        node.appendChild(typeof child === "string" || typeof child === "number"
          ? document.createTextNode(String(child))
          : child);
      }
    }
    return node;
  }

  function clear(node) {
    while (node && node.firstChild) node.removeChild(node.firstChild);
    return node;
  }

  function bitsOf(value, width) {
    const out = [];
    for (let i = width - 1; i >= 0; i--) out.push((value >> i) & 1);
    return out;
  }

  function bin(value, width) {
    return bitsOf(value, width).join("");
  }

  function popcount(value) {
    let count = 0;
    let x = value;
    while (x) {
      x &= x - 1;
      count++;
    }
    return count;
  }

  function graySeq(width) {
    const out = [];
    const size = 1 << width;
    for (let i = 0; i < size; i++) out.push(i ^ (i >> 1));
    return out;
  }

  function truthRows(n) {
    const out = [];
    for (let m = 0; m < (1 << n); m++) out.push(bitsOf(m, n));
    return out;
  }

  function mapLayout(n) {
    const rowBits = n <= 2 ? 1 : (n === 3 ? 1 : 2);
    const colBits = n - rowBits;
    const rows = graySeq(rowBits);
    const cols = graySeq(colBits);
    return { n, rowBits, colBits, rows, cols };
  }

  function mintermOf(rowCode, colCode, colBits) {
    return (rowCode << colBits) | colCode;
  }

  function escapeHtml(text) {
    return String(text)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  function fmt(value, digits) {
    const d = digits === undefined ? 2 : digits;
    return Number(value).toFixed(d).replace(/\.0+$/, "");
  }

  function status(node, text, kind) {
    if (!node) return;
    node.className = "status" + (kind ? " " + kind : "");
    node.textContent = text;
    if (!node.hasAttribute("role")) node.setAttribute("role", "status");
    if (!node.hasAttribute("aria-live")) node.setAttribute("aria-live", "polite");
    node.setAttribute("aria-atomic", "true");
  }

  function activate(node, handler, label) {
    if (!node) return node;
    node.setAttribute("role", "button");
    if (!node.hasAttribute("tabindex")) node.tabIndex = 0;
    if (label) node.setAttribute("aria-label", label);
    node.addEventListener("click", handler);
    node.addEventListener("keydown", (event) => {
      if (event.key === "Enter" || event.key === " " || event.key === "Spacebar") {
        event.preventDefault();
        handler(event);
      }
    });
    return node;
  }

  function setPressed(node, pressed) {
    if (node) node.setAttribute("aria-pressed", pressed ? "true" : "false");
    return node;
  }

  function keepFocus(render) {
    const active = document.activeElement;
    const key = active && active.getAttribute("data-focus-key");
    render();
    if (!key) return;
    const next = Array.from(document.querySelectorAll("[data-focus-key]"))
      .find((node) => node.getAttribute("data-focus-key") === key);
    if (!next) return;
    if (!next.disabled) {
      next.focus({ preventScroll: true });
      return;
    }
    const fallback = next.parentElement && next.parentElement.querySelector("button:not([disabled])");
    if (fallback) fallback.focus({ preventScroll: true });
  }

  function setActive(buttons, active) {
    buttons.forEach((button) => button.classList.toggle("active", button === active));
  }

  /* One active key for a set of hover and focus triggers. */
  function focusSet(onChange) {
    const sources = new Map();
    const ids = new WeakMap();
    let nextId = 0;
    function sourceId(node) {
      let id = ids.get(node);
      if (!id) {
        id = ++nextId;
        ids.set(node, id);
      }
      return id;
    }
    function activeKey() {
      let key = null;
      for (const value of sources.values()) key = value;
      return key;
    }
    function emit() {
      onChange(activeKey());
    }
    function bind(node, key) {
      if (!node) return node;
      const id = sourceId(node);
      node.addEventListener("mouseenter", () => {
        sources.set("mouse:" + id, String(key));
        emit();
      });
      node.addEventListener("mouseleave", () => {
        sources.delete("mouse:" + id);
        emit();
      });
      node.addEventListener("focus", () => {
        sources.set("focus:" + id, String(key));
        emit();
      });
      node.addEventListener("blur", () => {
        sources.delete("focus:" + id);
        emit();
      });
      return node;
    }
    function clear() {
      sources.clear();
      emit();
    }
    return { bind, clear, activeKey };
  }

  function downloadText(name, text, type) {
    const blob = new Blob([text], { type: type || "text/plain;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const link = el("a", { href: url, download: name });
    document.body.appendChild(link);
    link.click();
    link.remove();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
  }

  window.Lab = {
    $, $$, el, svg, clear, bitsOf, bin, popcount, graySeq, truthRows,
    mapLayout, mintermOf, escapeHtml, fmt, status, activate, setPressed, keepFocus, setActive, focusSet, downloadText,
  };
})();

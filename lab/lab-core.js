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
  }

  function setActive(buttons, active) {
    buttons.forEach((button) => button.classList.toggle("active", button === active));
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
    mapLayout, mintermOf, escapeHtml, fmt, status, setActive, downloadText,
  };
})();

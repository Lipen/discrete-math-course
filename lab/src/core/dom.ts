/* DOM helpers shared by every lab page. */

export type Child = Node | string | number | null | undefined;
export type Attrs = Record<string, unknown>;
export type Handler = (event: Event) => void;

export function $<T extends Element = HTMLElement>(selector: string, root: ParentNode = document): T | null {
  return root.querySelector<T>(selector);
}

export function $$<T extends Element = Element>(selector: string, root: ParentNode = document): T[] {
  return Array.from(root.querySelectorAll<T>(selector));
}

/** Query an element the page cannot work without. */
export function must<T extends Element = HTMLElement>(selector: string, root: ParentNode = document): T {
  const node = root.querySelector<T>(selector);
  if (!node) throw new Error(`Элемент не найден: ${selector}`);
  return node;
}

function appendChildren(node: Element, children: Child | Child[]): void {
  const list = Array.isArray(children) ? children : [children];
  for (const child of list) {
    if (child === null || child === undefined) continue;
    node.appendChild(typeof child === "string" || typeof child === "number"
      ? document.createTextNode(String(child))
      : child);
  }
}

export function el<K extends keyof HTMLElementTagNameMap>(
  tag: K, attrs?: Attrs | null, children?: Child | Child[],
): HTMLElementTagNameMap[K];
export function el(tag: string, attrs?: Attrs | null, children?: Child | Child[]): HTMLElement;
export function el(tag: string, attrs?: Attrs | null, children?: Child | Child[]): HTMLElement {
  const node = document.createElement(tag);
  if (attrs) {
    for (const key of Object.keys(attrs)) {
      const value = attrs[key];
      if (value === undefined || value === null) continue;
      if (key === "class") node.className = String(value);
      else if (key === "text") node.textContent = String(value);
      else if (key === "html") node.innerHTML = String(value);
      else if (key.startsWith("on") && typeof value === "function") {
        node.addEventListener(key.slice(2), value as EventListener);
      } else node.setAttribute(key, String(value));
    }
  }
  if (children !== undefined) appendChildren(node, children);
  return node;
}

export function svg(tag: string, attrs?: Attrs | null, children?: Child | Child[]): SVGElement {
  const node = document.createElementNS("http://www.w3.org/2000/svg", tag) as SVGElement;
  if (attrs) {
    for (const key of Object.keys(attrs)) {
      const value = attrs[key];
      if (value === undefined || value === null) continue;
      node.setAttribute(key, String(value));
    }
  }
  if (children !== undefined) appendChildren(node, children);
  return node;
}

export function clear<T extends Element>(node: T): T {
  while (node.firstChild) node.removeChild(node.firstChild);
  return node;
}

export function escapeHtml(text: unknown): string {
  return String(text)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

export function status(node: Element | null, text: string, kind?: string): void {
  if (!node) return;
  node.className = "status" + (kind ? " " + kind : "");
  node.textContent = text;
  if (!node.hasAttribute("role")) node.setAttribute("role", "status");
  if (!node.hasAttribute("aria-live")) node.setAttribute("aria-live", "polite");
  node.setAttribute("aria-atomic", "true");
}

export function activate<T extends Element>(node: T | null, handler: Handler, label?: string): T | null {
  if (!node) return node;
  node.setAttribute("role", "button");
  if (!node.hasAttribute("tabindex")) {
    if (node instanceof HTMLElement || node instanceof SVGElement) node.tabIndex = 0;
    else node.setAttribute("tabindex", "0");
  }
  if (label) node.setAttribute("aria-label", label);
  node.addEventListener("click", handler);
  node.addEventListener("keydown", (event) => {
    if (!(event instanceof KeyboardEvent)) return;
    if (event.key === "Enter" || event.key === " " || event.key === "Spacebar") {
      event.preventDefault();
      handler(event);
    }
  });
  return node;
}

export function setPressed(node: Element | null, pressed: boolean): Element | null {
  if (node) node.setAttribute("aria-pressed", pressed ? "true" : "false");
  return node;
}

export function keepFocus(render: () => void): void {
  const active = document.activeElement;
  const key = active && active.getAttribute("data-focus-key");
  render();
  if (!key) return;
  const next = $$("[data-focus-key]").find((node) => node.getAttribute("data-focus-key") === key);
  if (!next) return;
  if (next instanceof HTMLElement || next instanceof SVGElement) {
    if (!next.hasAttribute("disabled")) {
      next.focus({ preventScroll: true });
      return;
    }
  }
  const fallback = next.parentElement && next.parentElement.querySelector<HTMLElement>("button:not([disabled])");
  if (fallback) fallback.focus({ preventScroll: true });
}

export function setActive(buttons: Iterable<Element>, active: Element): void {
  for (const button of buttons) button.classList.toggle("active", button === active);
}

export interface FocusSet {
  bind(node: Element | null, key: string | number): Element | null;
  clear(): void;
  activeKey(): string | null;
}

/** One active key for a set of hover and focus triggers. */
export function focusSet(onChange: (key: string | null) => void): FocusSet {
  const sources = new Map<string, string>();
  const ids = new WeakMap<Element, number>();
  let nextId = 0;
  function sourceId(node: Element): number {
    let id = ids.get(node);
    if (!id) {
      id = ++nextId;
      ids.set(node, id);
    }
    return id;
  }
  function activeKey(): string | null {
    let key: string | null = null;
    for (const value of sources.values()) key = value;
    return key;
  }
  function emit(): void {
    onChange(activeKey());
  }
  function bind(node: Element | null, key: string | number): Element | null {
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
  function clearKeys(): void {
    sources.clear();
    emit();
  }
  return { bind, clear: clearKeys, activeKey };
}

export function downloadText(name: string, text: string, type?: string): void {
  const blob = new Blob([text], { type: type || "text/plain;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const link = el("a", { href: url, download: name });
  document.body.appendChild(link);
  link.click();
  link.remove();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}

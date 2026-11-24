/* Segmented ribbon: one active value, buttons, arrow keys. */

import { el } from "./dom";

export interface RibbonOption {
  value: string;
  label: string;
}

export interface Ribbon {
  readonly element: HTMLElement;
  value(): string;
  set(value: string, notify?: boolean): void;
}

export function ribbon(
  container: HTMLElement,
  options: RibbonOption[],
  initial: string,
  onChange: (value: string) => void,
): Ribbon {
  let current = initial;
  container.classList.add("segmented");
  if (!container.hasAttribute("role")) container.setAttribute("role", "group");

  const buttons = options.map((option) => el("button", {
    type: "button",
    "data-value": option.value,
    text: option.label,
    "aria-pressed": "false",
  }));
  container.replaceChildren(...buttons);

  function paint(): void {
    for (const button of buttons) {
      const active = button.dataset.value === current;
      button.classList.toggle("active", active);
      button.setAttribute("aria-pressed", String(active));
    }
  }

  function set(value: string, notify = false): void {
    if (!options.some((option) => option.value === value)) return;
    const changed = value !== current;
    current = value;
    paint();
    if (changed && notify) onChange(current);
  }

  container.addEventListener("click", (event) => {
    if (!(event.target instanceof Element)) return;
    const button = event.target.closest<HTMLButtonElement>("button[data-value]");
    if (!button || !container.contains(button)) return;
    const value = button.dataset.value;
    if (value !== undefined) set(value, true);
  });

  container.addEventListener("keydown", (event) => {
    if (event.key !== "ArrowLeft" && event.key !== "ArrowRight") return;
    const index = buttons.indexOf(document.activeElement as HTMLButtonElement);
    if (index < 0) return;
    const step = event.key === "ArrowRight" ? 1 : -1;
    const next = (index + step + buttons.length) % buttons.length;
    event.preventDefault();
    buttons[next].focus();
    set(buttons[next].dataset.value ?? "", true);
  });

  paint();
  return { element: container, value: () => current, set };
}

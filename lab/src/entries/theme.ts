/* Theme preference shared with the course site: system default, then a light/dark switch. */

const KEY = "dm-theme";
const media = window.matchMedia("(prefers-color-scheme: dark)");

let pref: "auto" | "light" | "dark" = "auto";
try {
  const stored = localStorage.getItem(KEY);
  if (stored === "light" || stored === "dark") pref = stored;
} catch {
  pref = "auto";
}

function resolved(): "light" | "dark" {
  return pref === "auto" ? (media.matches ? "dark" : "light") : pref;
}

function apply(): void {
  const theme = resolved();
  document.documentElement.dataset.theme = theme;
  document.documentElement.dataset.pref = theme;
}

apply();
media.addEventListener("change", () => {
  if (pref === "auto") apply();
});

window.__theme = {
  get: resolved,
  set(next) {
    pref = next === "light" ? "light" : "dark";
    try {
      localStorage.setItem(KEY, pref);
    } catch {
      // The preference still applies for this page when storage is unavailable.
    }
    apply();
  },
};

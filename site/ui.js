// Переключатель темы и кнопка «наверх».
const NAMES = { auto: "авто", light: "светлая", dark: "тёмная" };
const ORDER = ["auto", "light", "dark"];
const theme = document.getElementById("theme");

if (theme && window.__theme) {
  const label = () => {
    const pref = window.__theme.get();
    theme.title = `Тема: ${NAMES[pref]}`;
    theme.setAttribute("aria-label", `Тема оформления: ${NAMES[pref]}. Переключить`);
  };
  label();
  theme.addEventListener("click", () => {
    const pref = window.__theme.get();
    window.__theme.set(ORDER[(ORDER.indexOf(pref) + 1) % ORDER.length]);
    label();
  });
}

// Кнопка «наверх» появляется, когда шапка уехала, и не сдвигает табы: место под неё занято всегда.
const up = document.getElementById("up");
if (up) {
  const mark = () => document.body.classList.toggle("scrolled", window.scrollY > 320);
  mark();
  addEventListener("scroll", mark, { passive: true });
  up.addEventListener("click", () => {
    scrollTo({ top: 0, behavior: matchMedia("(prefers-reduced-motion: reduce)").matches ? "auto" : "smooth" });
  });
}

// Активная вкладка: подсвечивается раздел, заголовок которого прошёл линию вкладок.
const tabLinks = [...document.querySelectorAll(".tabs a")];
if (tabLinks.length) {
  const targets = tabLinks
    .map((link) => document.querySelector(link.getAttribute("href")))
    .filter(Boolean);
  const bar = document.querySelector(".tabs");
  const sync = () => {
    const line = (bar ? bar.getBoundingClientRect().bottom : 0) + 8;
    let current = null;
    for (const target of targets) {
      if (target.getBoundingClientRect().top <= line) current = target;
    }
    for (const link of tabLinks) {
      const on = current !== null && link.getAttribute("href") === `#${current.id}`;
      link.classList.toggle("is-on", on);
      if (on) link.setAttribute("aria-current", "true");
      else link.removeAttribute("aria-current");
    }
  };
  let frame = 0;
  const schedule = () => {
    if (frame) return;
    frame = requestAnimationFrame(() => {
      frame = 0;
      sync();
    });
  };
  addEventListener("scroll", schedule, { passive: true });
  addEventListener("resize", schedule);
  sync();
}

/* Shared site bar, topic accent and previous/next navigation. */
(function () {
  "use strict";

  const THEME_ICONS = `
    <svg class="i-light" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="4.2" fill="none" stroke="currentColor" stroke-width="1.8"/><g stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><path d="M12 2.6v2.2M12 19.2v2.2M2.6 12h2.2M19.2 12h2.2M5.4 5.4l1.6 1.6M17 17l1.6 1.6M18.6 5.4L17 7M7 17l-1.6 1.6"/></g></svg>
    <svg class="i-dark" viewBox="0 0 24 24" aria-hidden="true"><path d="M20 14.5A8.6 8.6 0 0 1 9.5 4a8.6 8.6 0 1 0 10.5 10.5z" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/></svg>
  `;

  const THEME_NAMES = { light: "светлая", dark: "тёмная" };
  const THEME_ORDER = ["light", "dark"];

  const catalog = window.LAB_CATALOG;
  if (!catalog) return;

  const page = (location.pathname.split("/").pop() || "index.html").toLowerCase();
  const currentLab = catalog.labs.find((lab) => lab.file.split("?")[0].toLowerCase() === page) || null;
  const isHub = page === "" || page === "index.html";

  if (currentLab) {
    document.body.dataset.module = currentLab.module;
    const moduleInfo = catalog.moduleOf(currentLab.module);
    document.body.style.setProperty("--module-accent", moduleInfo.accent);
    document.body.style.setProperty("--module-soft", moduleInfo.soft);
    document.body.style.setProperty("--accent", moduleInfo.accent);
    document.body.style.setProperty("--accent-soft", moduleInfo.soft);
  }

  function sitebar() {
    const bar = document.createElement("div");
    bar.className = "sitebar";
    bar.innerHTML = `
      <a class="skip-link" href="#lab-main">К содержанию</a>
      <a class="sitebar-brand" href="index.html">
        <span class="sitebar-mark">ДМ</span>
        <span class="sitebar-title"><b>Лаборатории</b><small>дискретная математика</small></span>
      </a>
      <nav class="sitebar-nav" aria-label="Навигация">
        <a href="index.html">Главная</a>
        <a href="index.html#labs">Каталог</a>
      </nav>
      <div class="sitebar-actions">
        <a class="sitebar-gh" href="https://github.com/Lipen/discrete-math-course" target="_blank" rel="noopener" aria-label="Исходники на GitHub" title="Исходники на GitHub">
          <svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M12 .5C5.73.5.99 5.24.99 11.5c0 4.85 3.15 8.96 7.5 10.42.55.1.75-.24.75-.53v-1.9c-3.05.66-3.7-1.3-3.7-1.3-.5-1.27-1.22-1.6-1.22-1.6-1-.68.07-.67.07-.67 1.1.08 1.68 1.13 1.68 1.13.98 1.68 2.57 1.2 3.2.92.1-.71.38-1.2.7-1.48-2.44-.28-5-1.22-5-5.42 0-1.2.43-2.18 1.13-2.95-.11-.28-.49-1.4.11-2.9 0 0 .92-.3 3.01 1.12.87-.24 1.8-.36 2.73-.36.93 0 1.86.12 2.73.36 2.09-1.42 3.01-1.12 3.01-1.12.6 1.5.22 2.62.11 2.9.7.77 1.13 1.75 1.13 2.95 0 4.21-2.57 5.13-5.02 5.41.39.34.74 1.01.74 2.04v3.02c0 .3.2.64.76.53 4.35-1.46 7.49-5.57 7.49-10.42C23.01 5.24 18.27.5 12 .5z"/></svg>
        </a>
        <button class="sitebar-theme" id="theme" type="button" aria-label="Тема оформления" title="Тема оформления">
          ${THEME_ICONS}
        </button>
      </div>
    `;
    document.body.insertBefore(bar, document.body.firstChild);
    bindTheme(bar.querySelector("#theme"));
  }

  function bindTheme(button) {
    if (!button || !window.__theme) return;
    const label = () => {
      const pref = window.__theme.get();
      button.title = `Тема: ${THEME_NAMES[pref]}`;
      button.setAttribute("aria-label", `Тема оформления: ${THEME_NAMES[pref]}. Переключить`);
    };
    label();
    button.addEventListener("click", () => {
      const pref = window.__theme.get();
      window.__theme.set(THEME_ORDER[(THEME_ORDER.indexOf(pref) + 1) % THEME_ORDER.length]);
      label();
    });
  }

  function prepareMain() {
    const main = document.querySelector("main.lab-main");
    if (!main) return;
    if (!main.id) main.id = "lab-main";
    for (const status of document.querySelectorAll(".status")) {
      if (!status.hasAttribute("role")) status.setAttribute("role", "status");
      if (!status.hasAttribute("aria-live")) status.setAttribute("aria-live", "polite");
      status.setAttribute("aria-atomic", "true");
    }
    const firstH3 = main.querySelector("h3");
    if (!firstH3) return;
    const headingBefore = Array.from(main.querySelectorAll("h2")).some((heading) => (
      heading.compareDocumentPosition(firstH3) & Node.DOCUMENT_POSITION_FOLLOWING
    ));
    if (headingBefore) return;
    const card = firstH3.closest("section.card") || main;
    const heading = document.createElement("h2");
    heading.className = "sr-only";
    heading.textContent = "Интерактивная модель";
    card.prepend(heading);
  }

  function pager() {
    if (!currentLab) return;
    const index = catalog.labs.indexOf(currentLab);
    const previous = index > 0 ? catalog.labs[index - 1] : null;
    const next = index < catalog.labs.length - 1 ? catalog.labs[index + 1] : null;
    const nav = document.createElement("nav");
    nav.className = "lab-pager";
    nav.setAttribute("aria-label", "Соседние лаборатории");

    if (previous) {
      const link = document.createElement("a");
      link.href = previous.file;
      link.className = "pager-link prev";
      link.innerHTML = `<span class="pager-kicker">← предыдущая</span><span class="pager-title">${previous.title}</span>`;
      nav.appendChild(link);
    } else {
      nav.appendChild(document.createElement("span"));
    }

    const all = document.createElement("a");
    all.href = "index.html#labs";
    all.className = "pager-all";
    all.textContent = "Все лаборатории";
    nav.appendChild(all);

    if (next) {
      const link = document.createElement("a");
      link.href = next.file;
      link.className = "pager-link next";
      link.innerHTML = `<span class="pager-kicker">следующая →</span><span class="pager-title">${next.title}</span>`;
      nav.appendChild(link);
    } else {
      nav.appendChild(document.createElement("span"));
    }

    const footer = document.querySelector(".footer");
    if (footer && footer.parentNode) footer.parentNode.insertBefore(nav, footer);
    else document.body.appendChild(nav);
  }

  if (!document.querySelector(".sitebar")) sitebar();
  prepareMain();
  if (!isHub) pager();

  if (currentLab) {
    const badge = document.querySelector(".lab-header .eyebrow");
    if (badge) badge.textContent = currentLab.topic;

    const header = document.querySelector(".lab-header");
    if (header) {
      if (!header.querySelector(".lab-watermark")) {
        const watermark = document.createElement("div");
        watermark.className = "lab-watermark";
        watermark.setAttribute("aria-hidden", "true");
        const mark = document.createElement("span");
        mark.className = "wm-mark";
        mark.textContent = currentLab.mark;
        watermark.append(mark);
        header.prepend(watermark);
      }

      let meta = header.querySelector(".lab-meta");
      const hadMeta = Boolean(meta);
      if (!meta) {
        meta = document.createElement("div");
        meta.className = "lab-meta";
        const lead = header.querySelector(".lead");
        if (lead && lead.parentNode) lead.parentNode.insertBefore(meta, lead.nextSibling);
        else header.appendChild(meta);
      }
      if (!hadMeta) {
        for (const tag of currentLab.tags) {
          const pill = document.createElement("span");
          pill.className = "pill";
          pill.textContent = tag;
          meta.appendChild(pill);
        }
      }
      if (currentLab.top && !meta.querySelector(".pill.top")) {
        const star = document.createElement("span");
        star.className = "pill top";
        star.innerHTML = '<span aria-hidden="true">★</span> эталон';
        meta.prepend(star);
      }
    }

    const footer = document.querySelector(".footer");
    if (footer) footer.textContent = "Лаборатория · " + currentLab.topic;
  }
})();

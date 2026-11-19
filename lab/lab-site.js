/* Shared site bar, topic accent and previous/next navigation. */
(function () {
  "use strict";

  const catalog = window.LAB_CATALOG;
  if (!catalog) return;

  const page = (location.pathname.split("/").pop() || "index.html").toLowerCase();
  const currentLab = catalog.labs.find((lab) => lab.file.toLowerCase() === page) || null;
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
      <a class="sitebar-brand" href="index.html">
        <span class="sitebar-mark">ДМ</span>
        <span class="sitebar-title"><b>Лаборатории</b><small>дискретная математика</small></span>
      </a>
      <nav class="sitebar-nav" aria-label="Навигация">
        <a href="index.html">Главная</a>
        <a href="index.html#labs">Каталог</a>
      </nav>
    `;
    document.body.insertBefore(bar, document.body.firstChild);
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
  if (!isHub) pager();

  if (currentLab) {
    const badge = document.querySelector(".lab-header .eyebrow");
    if (badge) badge.textContent = currentLab.topic;

    const header = document.querySelector(".lab-header");
    if (header && !header.querySelector(".lab-watermark")) {
      const watermark = document.createElement("div");
      watermark.className = "lab-watermark";
      watermark.setAttribute("aria-hidden", "true");
      const mark = document.createElement("span");
      mark.className = "wm-mark";
      mark.textContent = currentLab.mark;
      watermark.append(mark);
      header.prepend(watermark);

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
    }

    const footer = document.querySelector(".footer");
    if (footer) footer.textContent = "Лаборатория · " + currentLab.topic;
  }
})();

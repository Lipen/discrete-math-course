/* Shared site bar, module accent, progress and previous/next navigation. */
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

  const visitedKey = "dm-lab-visited-v1";
  function visited() {
    try {
      return new Set(JSON.parse(localStorage.getItem(visitedKey) || "[]"));
    } catch (error) {
      return new Set();
    }
  }
  function saveVisited(set) {
    try {
      localStorage.setItem(visitedKey, JSON.stringify(Array.from(set)));
    } catch (error) {
      /* localStorage can be unavailable under file:// restrictions. */
    }
  }

  const seen = visited();
  if (currentLab) {
    seen.add(currentLab.id);
    saveVisited(seen);
  }
  const total = catalog.labs.length;
  const done = Array.from(seen).filter((id) => catalog.byId.has(id)).length;
  const percent = total ? Math.round((done / total) * 100) : 0;

  function sitebar() {
    const bar = document.createElement("div");
    bar.className = "sitebar";
    bar.innerHTML = `
      <a class="sitebar-brand" href="index.html">
        <span class="sitebar-mark">ДМ</span>
        <span class="sitebar-title"><b>Лаборатории</b><small>первый семестр</small></span>
      </a>
      <nav class="sitebar-nav" aria-label="Навигация стенда">
        <a href="index.html">Главная</a>
        <a href="index.html#map">Карта</a>
        <a href="index.html#labs">Все лаборатории</a>
      </nav>
      <div class="sitebar-progress" title="Пройдено лабораторий: ${done} из ${total}">
        <span>${done} / ${total}</span>
        <div class="meter"><i style="width:${percent}%"></i></div>
      </div>
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
    all.href = "index.html";
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
    const moduleInfo = catalog.moduleOf(currentLab.module);
    const badge = document.querySelector(".lab-header .eyebrow");
    if (badge && !badge.dataset.withModule) {
      badge.dataset.withModule = "1";
      badge.textContent = badge.textContent + " · " + moduleInfo.name;
    }

    const header = document.querySelector(".lab-header");
    if (header && !header.querySelector(".lab-watermark")) {
      const number = catalog.labs.indexOf(currentLab) + 1;
      const watermark = document.createElement("div");
      watermark.className = "lab-watermark";
      watermark.setAttribute("aria-hidden", "true");
      const mark = document.createElement("span");
      mark.className = "wm-mark";
      mark.textContent = currentLab.mark;
      const lecture = document.createElement("em");
      lecture.className = "wm-no";
      lecture.textContent = String(currentLab.lecture).padStart(2, "0");
      watermark.append(mark, lecture);
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
      const chip = document.createElement("span");
      chip.className = "pill lab-index-pill";
      chip.textContent = "лаборатория " + String(number).padStart(2, "0") + " / " + total;
      meta.prepend(chip);
      if (!hadMeta) {
        for (const tag of currentLab.tags) {
          const pill = document.createElement("span");
          pill.className = "pill";
          pill.textContent = tag;
          meta.appendChild(pill);
        }
      }
    }
  }
})();

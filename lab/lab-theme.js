/* Theme preference shared with the course site: system default, then a light/dark switch. */
(function () {
  "use strict";

  var key = "dm-theme";
  var pref = "auto";
  try {
    var stored = localStorage.getItem(key);
    if (stored === "light" || stored === "dark") pref = stored;
  } catch (error) {
    pref = "auto";
  }

  var media = window.matchMedia("(prefers-color-scheme: dark)");

  function resolved() {
    return pref === "auto" ? (media.matches ? "dark" : "light") : pref;
  }

  function apply() {
    var theme = resolved();
    document.documentElement.dataset.theme = theme;
    document.documentElement.dataset.pref = theme;
  }

  apply();
  media.addEventListener("change", function () {
    if (pref === "auto") apply();
  });

  window.__theme = {
    get: function () {
      return resolved();
    },
    set: function (next) {
      pref = next === "light" ? "light" : "dark";
      try {
        localStorage.setItem(key, pref);
      } catch (error) {
        // The preference still applies for this page when storage is unavailable.
      }
      apply();
    },
  };
})();

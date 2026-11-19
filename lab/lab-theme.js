/* Theme preference shared with the course site: auto, light, dark. */
(function () {
  "use strict";

  var key = "dm-theme";
  var pref = "auto";
  try {
    pref = localStorage.getItem(key) || "auto";
  } catch (error) {
    pref = "auto";
  }

  var media = window.matchMedia("(prefers-color-scheme: dark)");

  function apply() {
    var dark = pref === "dark" || (pref === "auto" && media.matches);
    document.documentElement.dataset.theme = dark ? "dark" : "light";
    document.documentElement.dataset.pref = pref;
  }

  apply();
  media.addEventListener("change", function () {
    if (pref === "auto") apply();
  });

  window.__theme = {
    get: function () {
      return pref;
    },
    set: function (next) {
      pref = next;
      try {
        localStorage.setItem(key, next);
      } catch (error) {
        // The preference still applies for this page when storage is unavailable.
      }
      apply();
    },
  };
})();

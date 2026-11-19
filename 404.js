(function () {
  var torch = document.querySelector(".torch");
  if (!torch) return;
  var cave = document.querySelector(".d1 .cave");
  var copy = document.querySelector(".d1 .copy");
  var raf = 0;
  function setDefault() {
    if (!cave) return;
    var r = cave.getBoundingClientRect();
    torch.style.setProperty("--mx", (r.left + r.width * 0.75) + "px");
    torch.style.setProperty("--my", (r.top + r.height * 0.54) + "px");
    if (copy) {
      var c = copy.getBoundingClientRect();
      torch.style.setProperty("--cx", (c.left + c.width / 2) + "px");
      torch.style.setProperty("--cy", (c.top + c.height / 2) + "px");
    }
    torch.style.setProperty("--lx", (r.left + r.width * 0.25) + "px");
    torch.style.setProperty("--ly", (r.top + r.height * 0.55) + "px");
  }
  function move(e) {
    if (raf) return;
    raf = requestAnimationFrame(function () {
      raf = 0;
      torch.style.setProperty("--mx", e.clientX + "px");
      torch.style.setProperty("--my", e.clientY + "px");
    });
  }
  addEventListener("pointermove", move, { passive: true });
  addEventListener("pointerdown", move, { passive: true });
  document.addEventListener("pointerleave", setDefault);
  addEventListener("blur", setDefault);
  addEventListener("resize", setDefault);
  setDefault();
})();

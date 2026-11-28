(()=>{var o=window.matchMedia("(prefers-color-scheme: dark)"),e="auto";try{let t=localStorage.getItem("dm-theme");if(t==="light"||t==="dark")e=t}catch{e="auto"}function d(){return e==="auto"?o.matches?"dark":"light":e}function a(){let t=d();document.documentElement.dataset.theme=t,document.documentElement.dataset.pref=t}a();o.addEventListener("change",()=>{if(e==="auto")a()});window.__theme={get:d,set(t){e=t==="light"?"light":"dark";try{localStorage.setItem("dm-theme",e)}catch{}a()}};})();

//# debugId=13A9D709FB9B395364756E2164756E21
//# sourceMappingURL=theme.js.map

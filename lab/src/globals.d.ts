/* Globals provided by the vendored KaTeX script and the theme bootstrap. */

export {};

declare global {
  interface KatexOptions {
    displayMode?: boolean;
    throwOnError?: boolean;
    strict?: boolean | string;
    trust?: boolean;
    output?: "html" | "mathml" | "htmlAndMathml";
  }

  interface KatexApi {
    render(tex: string, node: HTMLElement, options?: KatexOptions): void;
  }

  interface ThemeApi {
    get(): "light" | "dark";
    set(next: "light" | "dark"): void;
  }

  interface Window {
    katex?: KatexApi;
    __theme?: ThemeApi;
  }
}

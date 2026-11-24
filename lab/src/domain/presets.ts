/* Ready-made boolean functions for the minimization lab. */

import { parse, toTex } from "./logic";

export type PresetSpec =
  | { kind: "expr"; expr: string }
  | { kind: "popcount"; test: "odd" | "even" | "at-least"; k?: number }
  | { kind: "minterms" };

export interface PresetData {
  n: number;
  ones: number[];
  x: number[];
  spec: PresetSpec;
}

export interface Preset extends PresetData {
  formula: string;
}

export const VARIABLES = ["A", "B", "C", "D", "E"] as const;

function buildFormula(p: PresetData): string {
  const names = VARIABLES.slice(0, p.n);
  switch (p.spec.kind) {
    case "expr":
      return toTex(parse(p.spec.expr)).replace(/\\land/g, "\\cdot");
    case "popcount": {
      const chain = names.join(" \\oplus ");
      if (p.spec.test === "odd") return chain;
      if (p.spec.test === "even") return "\\overline{" + chain + "}";
      return "[" + names.join("+") + " \\ge " + (p.spec.k ?? 0) + "]";
    }
    case "minterms": {
      const parts = ["\\Sigma m(" + p.ones.join(",") + ")"];
      if (p.x.length > 0) parts.push("\\Sigma X(" + p.x.join(",") + ")");
      return parts.join(" + ");
    }
  }
}

const data: Record<string, PresetData> = {
  and2: {
    n: 2,
    ones: [3],
    x: [],
    spec: { kind: "expr", expr: "A & B" },
  },
  impl2: {
    n: 2,
    ones: [0, 1, 3],
    x: [],
    spec: { kind: "expr", expr: "A -> B" },
  },
  maj3: {
    n: 3,
    ones: [3, 5, 6, 7],
    x: [],
    spec: { kind: "expr", expr: "A & B | A & C | B & C" },
  },
  sum3: {
    n: 3,
    ones: [0, 1, 2, 5, 6, 7],
    x: [],
    spec: { kind: "minterms" },
  },
  xor3: {
    n: 3,
    ones: [1, 2, 4, 7],
    x: [],
    spec: { kind: "popcount", test: "odd" },
  },
  consensus: {
    n: 3,
    ones: [2, 3, 5, 7],
    x: [],
    spec: { kind: "expr", expr: "!A & B | A & C | B & C" },
  },
  odd4: {
    n: 4,
    ones: [1, 2, 4, 7, 8, 11, 13, 14],
    x: [],
    spec: { kind: "popcount", test: "odd" },
  },
  even4: {
    n: 4,
    ones: [0, 3, 5, 6, 9, 10, 12, 15],
    x: [],
    spec: { kind: "popcount", test: "even" },
  },
  segA: {
    n: 4,
    ones: [0, 2, 3, 5, 6, 7, 8, 9],
    x: [10, 11, 12, 13, 14, 15],
    spec: { kind: "minterms" },
  },
  maj5: {
    n: 5,
    ones: [7, 11, 13, 14, 15, 19, 21, 22, 23, 25, 26, 27, 28, 29, 30, 31],
    x: [],
    spec: { kind: "popcount", test: "at-least", k: 3 },
  },
  xor5: {
    n: 5,
    ones: [1, 2, 4, 7, 8, 11, 13, 14, 16, 19, 21, 22, 25, 26, 28, 31],
    x: [],
    spec: { kind: "popcount", test: "odd" },
  },
};

export const presets: Record<string, Preset> = Object.fromEntries(
  Object.entries(data).map(([name, p]) => [name, { ...p, formula: buildFormula(p) }]),
);

/* Ready-made boolean functions for the minimization lab. */

export type PresetSpec =
  | { kind: "expr"; expr: string }
  | { kind: "popcount"; test: "odd" | "even" | "at-least"; k?: number }
  | { kind: "minterms" };

export interface Preset {
  n: number;
  ones: number[];
  x: number[];
  formula: string;
  spec: PresetSpec;
}

export const presets: Record<string, Preset> = {
  and2: {
    n: 2,
    ones: [3],
    x: [],
    formula: "A \\cdot B",
    spec: { kind: "expr", expr: "A & B" },
  },
  impl2: {
    n: 2,
    ones: [0, 1, 3],
    x: [],
    formula: "A \\to B",
    spec: { kind: "expr", expr: "A -> B" },
  },
  maj3: {
    n: 3,
    ones: [3, 5, 6, 7],
    x: [],
    formula: "A B \\lor A C \\lor B C",
    spec: { kind: "expr", expr: "A & B | A & C | B & C" },
  },
  sum3: {
    n: 3,
    ones: [0, 1, 2, 5, 6, 7],
    x: [],
    formula: "\\Sigma m(0,1,2,5,6,7)",
    spec: { kind: "minterms" },
  },
  xor3: {
    n: 3,
    ones: [1, 2, 4, 7],
    x: [],
    formula: "A \\oplus B \\oplus C",
    spec: { kind: "popcount", test: "odd" },
  },
  consensus: {
    n: 3,
    ones: [2, 3, 5, 7],
    x: [],
    formula: "\\neg A \\cdot B \\lor A \\cdot C \\lor B \\cdot C",
    spec: { kind: "expr", expr: "!A & B | A & C | B & C" },
  },
  odd4: {
    n: 4,
    ones: [1, 2, 4, 7, 8, 11, 13, 14],
    x: [],
    formula: "A \\oplus B \\oplus C \\oplus D",
    spec: { kind: "popcount", test: "odd" },
  },
  even4: {
    n: 4,
    ones: [0, 3, 5, 6, 9, 10, 12, 15],
    x: [],
    formula: "\\overline{A \\oplus B \\oplus C \\oplus D}",
    spec: { kind: "popcount", test: "even" },
  },
  segA: {
    n: 4,
    ones: [0, 2, 3, 5, 6, 7, 8, 9],
    x: [10, 11, 12, 13, 14, 15],
    formula: "\\Sigma m(0,2,3,5,6,7,8,9) + \\Sigma X(10\\ldots15)",
    spec: { kind: "minterms" },
  },
  maj5: {
    n: 5,
    ones: [7, 11, 13, 14, 15, 19, 21, 22, 23, 25, 26, 27, 28, 29, 30, 31],
    x: [],
    formula: "[A+B+C+D+E \\ge 3]",
    spec: { kind: "popcount", test: "at-least", k: 3 },
  },
  xor5: {
    n: 5,
    ones: [1, 2, 4, 7, 8, 11, 13, 14, 16, 19, 21, 22, 25, 26, 28, 31],
    x: [],
    formula: "A \\oplus B \\oplus C \\oplus D \\oplus E",
    spec: { kind: "popcount", test: "odd" },
  },
};

export const VARIABLES = ["A", "B", "C", "D", "E"] as const;

/* Presets are data: every hand-written truth table must match its declared function. */

import { describe, expect, test } from "bun:test";
import { evaluate, parse } from "../src/domain/logic";
import type { PropAst } from "../src/domain/logic";
import { presets, VARIABLES } from "../src/domain/presets";
import type { Preset } from "../src/domain/presets";

function popcount(value: number): number {
  let count = 0;
  let x = value;
  while (x) {
    x &= x - 1;
    count++;
  }
  return count;
}

/** The lab maps bit 0 of a minterm to the last variable, as termText does. */
function envOf(p: Preset, minterm: number): Record<string, boolean> {
  const env: Record<string, boolean> = {};
  for (let bit = 0; bit < p.n; bit++) {
    env[VARIABLES[p.n - 1 - bit]] = Boolean(minterm & (1 << bit));
  }
  return env;
}

function popcountValue(p: Preset, minterm: number): boolean {
  if (p.spec.kind !== "popcount") return false;
  const count = popcount(minterm);
  if (p.spec.test === "odd") return count % 2 === 1;
  if (p.spec.test === "even") return count % 2 === 0;
  return count >= (p.spec.k ?? 0);
}

describe("presets", () => {
  for (const [name, p] of Object.entries(presets)) {
    test(name, () => {
      expect(p.n).toBeGreaterThanOrEqual(2);
      expect(p.n).toBeLessThanOrEqual(VARIABLES.length);
      expect(p.formula.length).toBeGreaterThan(0);
      switch (p.spec.kind) {
        case "expr":
          expect(p.formula).not.toContain("\\Sigma");
          expect(p.formula.length).toBeGreaterThan(0);
          break;
        case "popcount":
          if (p.spec.test === "odd") expect(p.formula).toContain("\\oplus");
          if (p.spec.test === "even") expect(p.formula).toContain("\\overline{");
          if (p.spec.test === "at-least") expect(p.formula).toContain("\\ge " + (p.spec.k ?? 0));
          break;
        case "minterms":
          expect(p.formula).toContain("\\Sigma m(");
          if (p.x.length > 0) expect(p.formula).toContain("\\Sigma X(");
          break;
      }

      const size = 1 << p.n;
      const ones = new Set(p.ones);
      const xs = new Set(p.x);
      expect(ones.size).toBe(p.ones.length);
      expect(xs.size).toBe(p.x.length);

      for (const minterm of [...p.ones, ...p.x]) {
        expect(Number.isInteger(minterm)).toBe(true);
        expect(minterm).toBeGreaterThanOrEqual(0);
        expect(minterm).toBeLessThan(size);
      }
      for (const minterm of ones) expect(xs.has(minterm)).toBe(false);

      const ast: PropAst | null = p.spec.kind === "expr" ? parse(p.spec.expr) : null;
      for (let minterm = 0; minterm < size; minterm++) {
        if (xs.has(minterm)) continue;
        if (p.spec.kind === "minterms") continue;
        const expected = ast ? evaluate(ast, envOf(p, minterm)) : popcountValue(p, minterm);
        expect(ones.has(minterm)).toBe(expected);
      }
    });
  }
});

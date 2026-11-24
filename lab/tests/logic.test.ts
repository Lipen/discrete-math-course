/* Propositional parser, truth tables and entailment. */

import { describe, expect, test } from "bun:test";
import { allVars, classify, entails, evaluate, normalize, parse, toTex, tree, truthTable } from "../src/domain/logic";

describe("parse and evaluate", () => {
  test("respects precedence: p | q & !r", () => {
    const ast = parse("p | q & !r");
    expect(evaluate(ast, { p: false, q: true, r: false })).toBe(true);
    expect(evaluate(ast, { p: false, q: false, r: true })).toBe(false);
  });

  test("implication is right associative", () => {
    const ast = parse("p -> q -> r");
    expect(evaluate(ast, { p: true, q: true, r: false })).toBe(false);
    expect(evaluate(ast, { p: false, q: true, r: false })).toBe(true);
  });

  test("normalizes unicode connectives", () => {
    expect(normalize("p ∧ q → r")).toBe("p & q -> r");
    expect(evaluate(parse("p ∧ ¬p"), { p: true })).toBe(false);
    expect(evaluate(parse("⊤"), {})).toBe(true);
    expect(evaluate(parse("⊥"), {})).toBe(false);
  });

  test("rejects trailing fragments", () => {
    expect(() => parse("p q")).toThrow();
    expect(() => parse("")).toThrow();
  });

  test("collects variables in sorted order", () => {
    expect(allVars(parse("q & (p | q)"))).toEqual(["p", "q"]);
  });
});

describe("truth tables", () => {
  test("tautology, contradiction and contingency", () => {
    expect(classify(parse("p | !p")).kind).toBe("tautology");
    expect(classify(parse("p & !p")).kind).toBe("contradiction");
    expect(classify(parse("p & q")).kind).toBe("contingent");
  });

  test("table has 2^n rows and counts agree", () => {
    const result = classify(parse("p -> q"));
    expect(result.table.rows).toHaveLength(4);
    expect(result.trueCount + result.falseCount).toBe(4);
    expect(result.trueCount).toBe(3);
  });

  test("truthTable honours an explicit variable order", () => {
    const table = truthTable(parse("a & b"), ["b", "a"]);
    expect(table.vars).toEqual(["b", "a"]);
    expect(table.rows.map((row) => row.bits)).toEqual([[0, 0], [0, 1], [1, 0], [1, 1]]);
  });
});

describe("entailment", () => {
  test("modus ponens holds", () => {
    const result = entails([parse("p"), parse("p -> q")], parse("q"));
    expect(result.holds).toBe(true);
    expect(result.counterexample).toBeNull();
  });

  test("affirming the consequent fails with a counterexample", () => {
    const result = entails([parse("p -> q"), parse("q")], parse("p"));
    expect(result.holds).toBe(false);
    expect(result.counterexample?.env).toEqual({ p: false, q: true });
  });

  test("union of variables across premises and conclusion", () => {
    const result = entails([parse("p")], parse("q"));
    expect(result.vars).toEqual(["p", "q"]);
    expect(result.rows).toHaveLength(4);
  });
});

describe("rendering", () => {
  test("toTex parenthesizes weaker subformulas", () => {
    const ast = parse("(p | q) & r");
    expect(toTex(ast)).toBe("\\left(p \\lor q\\right) \\land r");
  });

  test("tree labels use symbols", () => {
    expect(tree(parse("p -> q"))).toEqual({
      label: "→",
      children: [{ label: "p", children: [] }, { label: "q", children: [] }],
    });
  });
});

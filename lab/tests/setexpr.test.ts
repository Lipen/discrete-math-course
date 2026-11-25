/* Set expressions, exhaustive membership patterns and TeX. */

import { describe, expect, test } from "bun:test";
import { evaluate, PATTERNS, parse, patternDescription, toTex } from "../src/domain/setexpr";

describe("set expressions", () => {
  test("all eight membership patterns exist", () => {
    expect(PATTERNS.map((pattern) => pattern.bits)).toEqual(["000", "001", "010", "011", "100", "101", "110", "111"]);
  });

  test("distributivity holds on every pattern", () => {
    const left = parse("A ∩ (B ∪ C)");
    const right = parse("(A ∩ B) ∪ (A ∩ C)");
    for (const pattern of PATTERNS) expect(evaluate(left, pattern.value)).toBe(evaluate(right, pattern.value));
  });

  test("a false identity has a concrete counterexample", () => {
    const left = parse("A \\ (B \\ C)");
    const right = parse("(A \\ B) ∪ C");
    const bad = PATTERNS.filter((pattern) => evaluate(left, pattern.value) !== evaluate(right, pattern.value));
    expect(bad.map((pattern) => pattern.bits)).toEqual(["001", "011"]);
  });

  test("difference binds tighter than union", () => {
    const expression = parse("A \\ B ∪ C");
    expect(expression.type).toBe("or");
    expect(toTex(expression)).toBe("A \\setminus B \\cup C");
  });

  test("postfix and prefix complements both work", () => {
    expect(toTex(parse("Aᶜ"))).toBe("A^{c}");
    expect(toTex(parse("!(A ∩ B)"))).toBe("\\left(A \\cap B\\right)^{c}");
  });

  test("pattern descriptions name every membership", () => {
    expect(patternDescription(PATTERNS[5])).toBe("x ∈ A, x ∉ B, x ∈ C");
  });

  test("missing operands and unclosed parentheses are explained", () => {
    expect(() => parse("A &")).toThrow("Ожидалось множество A, B или C.");
    expect(() => parse("(A ∪ B")).toThrow("Ожидалась закрывающая скобка.");
  });
});

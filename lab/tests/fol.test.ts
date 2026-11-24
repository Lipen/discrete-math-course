/* First-order parsing and evaluation on finite models. */

import { describe, expect, test } from "bun:test";
import type { Model } from "../src/domain/fol";
import { evalFormula, freeVars, initialModel, parse, quantifierRows, toTex } from "../src/domain/fol";

function model(): Model {
  return {
    domain: [1, 2],
    preds: { P: new Set([1]), Q: new Set([1, 2]), R: new Set(["1,2"]) },
  };
}

describe("parsing", () => {
  test("quantifier binds tighter than conjunction", () => {
    const ast = parse("forall x P(x) & Q(1)");
    expect(ast.type).toBe("and");
    if (ast.type !== "and") throw new Error("unreachable");
    expect(ast.a.type).toBe("forall");
  });

  test("free variables ignore bound names", () => {
    expect(Array.from(freeVars(parse("forall x R(x, y)")).values())).toEqual(["y"]);
    expect(Array.from(freeVars(parse("P(1)")).values())).toEqual([]);
  });

  test("rejects unknown predicates and arities", () => {
    expect(() => parse("S(1)")).toThrow();
    expect(() => parse("R(1)")).toThrow();
    expect(() => parse("P(1, 2)")).toThrow();
  });

  test("unicode quantifiers normalize", () => {
    expect(freeVars(parse("∃x P(x)")).size).toBe(0);
  });
});

describe("evaluation", () => {
  test("existential and universal over the domain", () => {
    expect(evalFormula(parse("forall x Q(x)"), {}, model())).toBe(true);
    expect(evalFormula(parse("forall x P(x)"), {}, model())).toBe(false);
    expect(evalFormula(parse("exists x P(x)"), {}, model())).toBe(true);
    expect(evalFormula(parse("exists x R(x, x)"), {}, model())).toBe(false);
  });

  test("mixed order of quantifiers changes meaning", () => {
    const m: Model = {
      domain: [1, 2],
      preds: { P: new Set(), Q: new Set(), R: new Set(["1,1", "2,2"]) },
    };
    expect(evalFormula(parse("forall x exists y R(x, y)"), {}, m)).toBe(true);
    expect(evalFormula(parse("exists y forall x R(x, y)"), {}, m)).toBe(false);
  });

  test("quantifier rows expose each witness", () => {
    const rows = quantifierRows(parse("exists x P(x)"), model());
    expect(rows).toEqual([
      { value: 1, truth: true },
      { value: 2, truth: false },
    ]);
  });

  test("free variable without assignment throws", () => {
    expect(() => evalFormula(parse("P(y)"), {}, model())).toThrow();
  });

  test("initial model has a stable shape", () => {
    const m = initialModel(3);
    expect(m.domain).toEqual([1, 2, 3]);
    expect(m.preds.P).toEqual(new Set([1]));
    expect(m.preds.R.size).toBe(0);
  });
});

describe("rendering", () => {
  test("toTex keeps quantifier scope", () => {
    expect(toTex(parse("forall x P(x) & Q(1)"))).toBe("\\left(\\forall x\\,P(x)\\right) \\land Q(1)");
  });

  test("nested quantifiers need no extra parentheses", () => {
    expect(toTex(parse("forall x exists y R(x, y)"))).toBe("\\forall x\\,\\exists y\\,R(x, y)");
  });

  test("binary quantifier body is parenthesized", () => {
    expect(toTex(parse("forall x (P(x) -> Q(x))"))).toBe("\\forall x\\,\\left(P(x) \\to Q(x)\\right)");
  });
});

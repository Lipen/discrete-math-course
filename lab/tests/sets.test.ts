/* Relation closures, equivalence classes and function properties. */

import { describe, expect, test } from "bun:test";
import {
  compose,
  diff,
  equivalenceClasses,
  functionProps,
  inter,
  invert,
  isPartialOrder,
  list,
  powerSet,
  reflexiveClosure,
  relationMatrix,
  relationProperties,
  subset,
  symmetricClosure as symmetric,
  symmetricClosure,
  transitiveClosure,
  transitiveReduction,
  union,
} from "../src/domain/sets";

describe("set operations", () => {
  test("union, intersection and difference", () => {
    const a = new Set([1, 2, 3]);
    const b = new Set([3, 4]);
    expect(list(union(a, b))).toEqual([1, 2, 3, 4]);
    expect(list(inter(a, b))).toEqual([3]);
    expect(list(diff(a, b))).toEqual([1, 2]);
    expect(subset(new Set([1]), a)).toBe(true);
    expect(subset(a, new Set([1]))).toBe(false);
  });

  test("power set enumerates by size, then lexicographically", () => {
    expect(powerSet(new Set([1, 2]))).toEqual([[], [1], [2], [1, 2]]);
  });
});

describe("relations", () => {
  const matrix = relationMatrix(3, [
    [1, 2],
    [2, 3],
  ]);

  test("properties of the raw relation", () => {
    const props = relationProperties(matrix);
    expect(props.reflexive).toBe(false);
    expect(props.irreflexive).toBe(true);
    expect(props.symmetric).toBe(false);
    expect(props.transitive).toBe(false);
  });

  test("transitive closure adds the missing shortcut", () => {
    const closure = transitiveClosure(matrix);
    expect(closure[0][2]).toBe(true);
    expect(relationProperties(transitiveClosure(closure)).transitive).toBe(true);
  });

  test("reflexive and symmetric closures", () => {
    expect(reflexiveClosure(matrix)[0][0]).toBe(true);
    expect(symmetricClosure(matrix)[1][0]).toBe(true);
  });

  test("transitive reduction drops shortcuts only", () => {
    const reach = transitiveClosure(matrix);
    const reduced = transitiveReduction(reach);
    expect(reduced[0][2]).toBe(false);
    expect(reduced[0][1]).toBe(true);
    expect(transitiveClosure(reduced)[0][2]).toBe(true);
  });

  test("equivalence classes on a block diagonal relation", () => {
    const equivalence = relationMatrix(4, [
      [1, 1],
      [2, 2],
      [3, 3],
      [4, 4],
      [1, 2],
      [2, 1],
      [3, 4],
      [4, 3],
    ]);
    expect(equivalenceClasses(equivalence)).toEqual([
      [1, 2],
      [3, 4],
    ]);
  });

  test("partial order needs reflexivity", () => {
    expect(isPartialOrder(transitiveClosure(reflexiveClosure(matrix)))).toBe(true);
    expect(isPartialOrder(matrix)).toBe(false);
  });

  test("symmetric alias stays wired", () => {
    expect(symmetric(matrix)).toEqual(symmetricClosure(matrix));
  });
});

describe("functions", () => {
  test("bijection on a two-element domain", () => {
    const props = functionProps({ 1: 2, 2: 1 }, [1, 2], [1, 2]);
    expect(props.injective).toBe(true);
    expect(props.surjective).toBe(true);
    expect(props.bijective).toBe(true);
  });

  test("collisions and missing values are reported", () => {
    const props = functionProps({ 1: 1, 2: 1 }, [1, 2], [1, 2]);
    expect(props.injective).toBe(false);
    expect(props.missing).toEqual([2]);
    expect(props.collisions).toBe(1);
  });

  test("composition and inverse", () => {
    const first = { 1: 2, 2: 3 };
    const second = { 2: 20, 3: 30 };
    expect(compose(first, second, [1, 2])).toEqual({ 1: 20, 2: 30 });
    expect(invert({ 1: 5, 2: 6 }, [1, 2])).toEqual({ 5: 1, 6: 2 });
  });
});

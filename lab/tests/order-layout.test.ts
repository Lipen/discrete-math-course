/* Layered Hasse layout: crossing reduction and long-edge routing. */

import { describe, expect, test } from "bun:test";
import { layoutHasse, rankOf } from "../src/domain/order-layout";
import { relationMatrix } from "../src/domain/sets";

function crosses(
  a: { points: Array<{ x: number; y: number }> },
  b: { points: Array<{ x: number; y: number }> },
): boolean {
  const [a1, a2] = [a.points[0], a.points[a.points.length - 1]];
  const [b1, b2] = [b.points[0], b.points[b.points.length - 1]];
  const orient = (p: { x: number; y: number }, q: { x: number; y: number }, r: { x: number; y: number }) =>
    (q.x - p.x) * (r.y - p.y) - (q.y - p.y) * (r.x - p.x);
  const d1 = orient(a1, a2, b1);
  const d2 = orient(a1, a2, b2);
  const d3 = orient(b1, b2, a1);
  const d4 = orient(b1, b2, a2);
  return d1 * d2 < 0 && d3 * d4 < 0;
}

describe("Hasse layout", () => {
  test("ranks follow the longest chain", () => {
    expect(
      rankOf(
        relationMatrix(4, [
          [1, 2],
          [2, 3],
          [3, 4],
        ]),
      ),
    ).toEqual([0, 1, 2, 3]);
  });

  test("swaps a crossed layer into a clean order", () => {
    const cover = relationMatrix(4, [
      [1, 4],
      [2, 3],
    ]);
    const layout = layoutHasse(cover);
    const left = layout.edges.find((edge) => edge.from === 0 && edge.to === 3);
    const right = layout.edges.find((edge) => edge.from === 1 && edge.to === 2);
    expect(left).toBeDefined();
    expect(right).toBeDefined();
    expect(layout.crossings).toBe(0);
    expect(left && right && crosses(left, right)).toBe(false);
    expect(layout.nodes[3].x).toBeLessThan(layout.nodes[2].x);
  });

  test("routes a cover over skipped ranks through a dummy point", () => {
    const cover = relationMatrix(4, [
      [1, 2],
      [2, 3],
      [4, 3],
    ]);
    const layout = layoutHasse(cover);
    const long = layout.edges.find((edge) => edge.from === 3 && edge.to === 2);
    expect(long?.points.length).toBe(3);
    expect(long?.points[1].y).toBeLessThan(long?.points[0].y ?? 0);
    expect(long?.points[1].y).toBeGreaterThan(long?.points[2].y ?? 0);
  });

  test("keeps nodes inside the viewbox and separated", () => {
    const cover = relationMatrix(6, [
      [1, 4],
      [1, 5],
      [1, 6],
      [2, 4],
      [2, 5],
      [2, 6],
      [3, 4],
      [3, 5],
      [3, 6],
    ]);
    const layout = layoutHasse(cover);
    for (const node of layout.nodes) {
      expect(node.x).toBeGreaterThanOrEqual(28);
      expect(node.x).toBeLessThanOrEqual(layout.width - 28);
    }
    for (let i = 0; i < layout.nodes.length; i++) {
      for (let j = i + 1; j < layout.nodes.length; j++) {
        const a = layout.nodes[i];
        const b = layout.nodes[j];
        expect(Math.hypot(a.x - b.x, a.y - b.y)).toBeGreaterThan(40);
      }
    }
  });
});

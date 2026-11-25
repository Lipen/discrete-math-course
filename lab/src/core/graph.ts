/* Geometry for directed graph edges. */

export interface GraphPoint {
  x: number;
  y: number;
}

/** Point on the segment from `from` toward `to`, at a fixed distance. */
export function pointToward(from: GraphPoint, to: GraphPoint, distance: number): GraphPoint {
  const dx = to.x - from.x;
  const dy = to.y - from.y;
  const length = Math.hypot(dx, dy) || 1;
  return { x: from.x + (dx / length) * distance, y: from.y + (dy / length) * distance };
}

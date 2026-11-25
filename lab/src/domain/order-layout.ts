/* Layered Hasse layout: rank assignment, crossing reduction and coordinates. */

import type { Matrix } from "./sets";

export interface LayoutPoint {
  x: number;
  y: number;
}

export interface HasseNode {
  id: number;
  rank: number;
  x: number;
  y: number;
}

export interface HasseEdge {
  from: number;
  to: number;
  points: LayoutPoint[];
}

export interface HasseLayout {
  nodes: HasseNode[];
  edges: HasseEdge[];
  width: number;
  height: number;
  maxRank: number;
  crossings: number;
}

interface Vertex {
  key: string;
  real: number;
  rank: number;
  pred: Vertex[];
  succ: Vertex[];
  order: number;
  x: number;
  y: number;
}

const MIN_GAP = 48;
const MARGIN = 28;
const RANK_GAP = 82;
const TOP = 50;

export function rankOf(matrix: Matrix): number[] {
  const n = matrix.length;
  const rank = new Array<number>(n).fill(0);
  for (let step = 0; step < n; step++) {
    for (let i = 0; i < n; i++) {
      for (let j = 0; j < n; j++) {
        if (matrix[i][j]) rank[j] = Math.max(rank[j], rank[i] + 1);
      }
    }
  }
  return rank;
}

function link(from: Vertex, to: Vertex): void {
  from.succ.push(to);
  to.pred.push(from);
}

function setOrder(layer: Vertex[]): void {
  layer.forEach((vertex, index) => {
    vertex.order = index;
  });
}

function positionsOf(layer: Vertex[]): Map<Vertex, number> {
  const positions = new Map<Vertex, number>();
  layer.forEach((vertex, index) => {
    positions.set(vertex, index);
  });
  return positions;
}

function barycenter(vertex: Vertex, side: "pred" | "succ", positions: Map<Vertex, number>): number {
  const neighbours = vertex[side];
  if (!neighbours.length) return vertex.order;
  let sum = 0;
  for (const neighbour of neighbours) sum += positions.get(neighbour) ?? 0;
  return sum / neighbours.length;
}

function sortLayer(layer: Vertex[], side: "pred" | "succ", positions: Map<Vertex, number>): void {
  layer.sort((a, b) => {
    const diff = barycenter(a, side, positions) - barycenter(b, side, positions);
    return diff || a.order - b.order;
  });
  setOrder(layer);
}

function countCrossings(layers: Vertex[][]): number {
  let total = 0;
  for (let rank = 0; rank < layers.length - 1; rank++) {
    const upper = positionsOf(layers[rank]);
    const lower = positionsOf(layers[rank + 1]);
    const segments: Array<{ from: number; to: number }> = [];
    for (const vertex of layers[rank]) {
      for (const next of vertex.succ) {
        segments.push({ from: upper.get(vertex) ?? 0, to: lower.get(next) ?? 0 });
      }
    }
    for (let i = 0; i < segments.length; i++) {
      for (let j = i + 1; j < segments.length; j++) {
        const a = segments[i];
        const b = segments[j];
        if (a.from === b.from || a.to === b.to) continue;
        if ((a.from - b.from) * (a.to - b.to) < 0) total++;
      }
    }
  }
  return total;
}

function transpose(layers: Vertex[][]): void {
  for (let pass = 0; pass < 4; pass++) {
    let improved = false;
    for (const layer of layers) {
      for (let i = 0; i + 1 < layer.length; i++) {
        const before = countCrossings(layers);
        [layer[i], layer[i + 1]] = [layer[i + 1], layer[i]];
        setOrder(layer);
        const after = countCrossings(layers);
        if (after < before) improved = true;
        else {
          [layer[i], layer[i + 1]] = [layer[i + 1], layer[i]];
          setOrder(layer);
        }
      }
    }
    if (!improved) break;
  }
}

function snapshot(layers: Vertex[][]): string[][] {
  return layers.map((layer) => layer.map((vertex) => vertex.key));
}

function restore(layers: Vertex[][], saved: string[][]): void {
  const rankByKey = new Map<string, number>();
  saved.forEach((keys, rank) => {
    keys.forEach((key, index) => {
      rankByKey.set(key, rank * 1000 + index);
    });
  });
  for (const layer of layers) {
    layer.sort((a, b) => (rankByKey.get(a.key) ?? 0) - (rankByKey.get(b.key) ?? 0));
    setOrder(layer);
  }
}

function enforce(layer: Vertex[], desired: number[], width: number): void {
  if (!layer.length) return;
  for (let i = 0; i < layer.length; i++) {
    layer[i].x = Math.min(width - MARGIN, Math.max(MARGIN, desired[i] ?? layer[i].x));
  }
  for (let i = 1; i < layer.length; i++) {
    layer[i].x = Math.max(layer[i].x, layer[i - 1].x + MIN_GAP);
  }
  if (layer[layer.length - 1].x > width - MARGIN) {
    layer[layer.length - 1].x = width - MARGIN;
    for (let i = layer.length - 2; i >= 0; i--) {
      layer[i].x = Math.min(layer[i].x, layer[i + 1].x - MIN_GAP);
    }
  }
  if (layer[0].x < MARGIN) {
    layer[0].x = MARGIN;
    for (let i = 1; i < layer.length; i++) {
      layer[i].x = Math.max(layer[i].x, layer[i - 1].x + MIN_GAP);
    }
  }
}

export function layoutHasse(cover: Matrix): HasseLayout {
  const n = cover.length;
  if (!n) return { nodes: [], edges: [], width: 520, height: 260, maxRank: 0, crossings: 0 };
  const rank = rankOf(cover);
  const maxRank = Math.max(0, ...rank);
  const layers: Vertex[][] = Array.from({ length: maxRank + 1 }, () => []);
  const real: Vertex[] = [];
  for (let i = 0; i < n; i++) {
    const vertex: Vertex = {
      key: "r" + i,
      real: i,
      rank: rank[i],
      pred: [],
      succ: [],
      order: 0,
      x: 0,
      y: 0,
    };
    real.push(vertex);
    layers[vertex.rank].push(vertex);
  }

  let dummyCount = 0;
  const chains = new Map<string, Vertex[]>();
  for (let i = 0; i < n; i++) {
    for (let j = 0; j < n; j++) {
      if (!cover[i][j] || rank[j] <= rank[i]) continue;
      const chain: Vertex[] = [real[i]];
      let previous = real[i];
      for (let r = rank[i] + 1; r < rank[j]; r++) {
        const dummy: Vertex = {
          key: "d" + dummyCount++,
          real: -1,
          rank: r,
          pred: [],
          succ: [],
          order: 0,
          x: 0,
          y: 0,
        };
        layers[r].push(dummy);
        link(previous, dummy);
        chain.push(dummy);
        previous = dummy;
      }
      link(previous, real[j]);
      chain.push(real[j]);
      chains.set(i + ":" + j, chain);
    }
  }

  for (const layer of layers) setOrder(layer);
  let best = snapshot(layers);
  let bestCrossings = countCrossings(layers);
  for (let iteration = 0; iteration < 8; iteration++) {
    for (let r = 1; r <= maxRank; r++) {
      sortLayer(layers[r], "pred", positionsOf(layers[r - 1]));
    }
    transpose(layers);

    for (let r = maxRank - 1; r >= 0; r--) {
      sortLayer(layers[r], "succ", positionsOf(layers[r + 1]));
    }
    transpose(layers);

    const crossings = countCrossings(layers);
    if (crossings < bestCrossings) {
      best = snapshot(layers);
      bestCrossings = crossings;
    }
    if (bestCrossings === 0) break;
  }
  restore(layers, best);

  const maxLayer = Math.max(...layers.map((layer) => layer.length));
  const width = Math.max(520, (maxLayer - 1) * MIN_GAP + 2 * MARGIN);
  const height = Math.max(260, (maxRank + 1) * 86 + 60);
  for (const layer of layers) {
    layer.forEach((vertex, index) => {
      vertex.x = MARGIN + ((width - 2 * MARGIN) * (index + 1)) / (layer.length + 1);
      vertex.y = height - TOP - vertex.rank * RANK_GAP;
    });
  }

  for (let iteration = 0; iteration < 6; iteration++) {
    for (let r = 1; r <= maxRank; r++) {
      const desired = layers[r].map((vertex) => {
        if (!vertex.pred.length) return vertex.x;
        let sum = 0;
        for (const parent of vertex.pred) sum += parent.x;
        return sum / vertex.pred.length;
      });
      enforce(layers[r], desired, width);
    }
    for (let r = maxRank - 1; r >= 0; r--) {
      const desired = layers[r].map((vertex) => {
        if (!vertex.succ.length) return vertex.x;
        let sum = 0;
        for (const child of vertex.succ) sum += child.x;
        return sum / vertex.succ.length;
      });
      enforce(layers[r], desired, width);
    }
  }

  const nodes: HasseNode[] = real.map((vertex) => ({
    id: vertex.real,
    rank: vertex.rank,
    x: vertex.x,
    y: vertex.y,
  }));
  const edges: HasseEdge[] = [];
  for (const [key, chain] of chains) {
    const [from, to] = key.split(":").map(Number);
    edges.push({ from, to, points: chain.map((vertex) => ({ x: vertex.x, y: vertex.y })) });
  }
  return { nodes, edges, width, height, maxRank, crossings: countCrossings(layers) };
}

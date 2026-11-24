/* Finite sets, relations, orders and functions. */

export type NumSet = Set<number>;
export type Matrix = boolean[][];
export type Mapping = Record<number, number | undefined>;

export function range(n: number): number[] {
  return Array.from({ length: n }, (_, i) => i + 1);
}

export function list(set: NumSet): number[] {
  return Array.from(set).sort((a, b) => a - b);
}

export function union(a: NumSet, b: NumSet): NumSet {
  return new Set([...a, ...b]);
}

export function inter(a: NumSet, b: NumSet): NumSet {
  return new Set([...a].filter((x) => b.has(x)));
}

export function diff(a: NumSet, b: NumSet): NumSet {
  return new Set([...a].filter((x) => !b.has(x)));
}

export function symdiff(a: NumSet, b: NumSet): NumSet {
  return union(diff(a, b), diff(b, a));
}

export function complement(a: NumSet, universe: Iterable<number>): NumSet {
  return diff(new Set(universe), a);
}

export function subset(a: NumSet, b: NumSet): boolean {
  return [...a].every((x) => b.has(x));
}

export function equal(a: NumSet, b: NumSet): boolean {
  return subset(a, b) && subset(b, a);
}

export function card(a: NumSet): number {
  return a.size;
}

export function powerSet(a: NumSet): number[][] {
  const items = list(a);
  const out: number[][] = [];
  for (let mask = 0; mask < 1 << items.length; mask++) {
    const subsetItems: number[] = [];
    for (let i = 0; i < items.length; i++) if (mask & (1 << i)) subsetItems.push(items[i]);
    out.push(subsetItems);
  }
  out.sort((x, y) => x.length - y.length || x.join(",").localeCompare(y.join(",")));
  return out;
}

export function relationMatrix(n: number, pairs: Array<[number, number]>): Matrix {
  const matrix = Array.from({ length: n }, () => new Array<boolean>(n).fill(false));
  for (const [a, b] of pairs) matrix[a - 1][b - 1] = true;
  return matrix;
}

export function relationPairs(matrix: Matrix): Array<[number, number]> {
  const out: Array<[number, number]> = [];
  for (let i = 0; i < matrix.length; i++) {
    for (let j = 0; j < matrix.length; j++) if (matrix[i][j]) out.push([i + 1, j + 1]);
  }
  return out;
}

export interface RelationProperties {
  reflexive: boolean;
  irreflexive: boolean;
  symmetric: boolean;
  antisymmetric: boolean;
  transitive: boolean;
}

export function relationProperties(matrix: Matrix): RelationProperties {
  const n = matrix.length;
  let reflexive = true,
    irreflexive = true,
    symmetric = true,
    antisymmetric = true,
    transitive = true;
  for (let i = 0; i < n; i++) {
    if (!matrix[i][i]) reflexive = false;
    if (matrix[i][i]) irreflexive = false;
  }
  for (let i = 0; i < n; i++) {
    for (let j = 0; j < n; j++) {
      if (matrix[i][j] !== matrix[j][i]) symmetric = false;
      if (i !== j && matrix[i][j] && matrix[j][i]) antisymmetric = false;
    }
  }
  for (let i = 0; i < n; i++) {
    for (let j = 0; j < n; j++) {
      if (!matrix[i][j]) continue;
      for (let k = 0; k < n; k++) {
        if (matrix[j][k] && !matrix[i][k]) {
          transitive = false;
          break;
        }
      }
      if (!transitive) break;
    }
    if (!transitive) break;
  }
  return { reflexive, irreflexive, symmetric, antisymmetric, transitive };
}

export function copyMatrix(matrix: Matrix): Matrix {
  return matrix.map((row) => row.slice());
}

export function reflexiveClosure(matrix: Matrix): Matrix {
  const out = copyMatrix(matrix);
  for (let i = 0; i < out.length; i++) out[i][i] = true;
  return out;
}

export function symmetricClosure(matrix: Matrix): Matrix {
  const out = copyMatrix(matrix);
  for (let i = 0; i < out.length; i++) {
    for (let j = 0; j < out.length; j++) if (out[i][j]) out[j][i] = true;
  }
  return out;
}

export function transitiveClosure(matrix: Matrix): Matrix {
  const out = copyMatrix(matrix);
  const n = out.length;
  for (let k = 0; k < n; k++) {
    for (let i = 0; i < n; i++) {
      if (!out[i][k]) continue;
      for (let j = 0; j < n; j++) if (out[k][j]) out[i][j] = true;
    }
  }
  return out;
}

export function equivalenceClasses(matrix: Matrix): number[][] {
  const n = matrix.length;
  const seen = new Set<number>();
  const out: number[][] = [];
  for (let i = 0; i < n; i++) {
    if (seen.has(i)) continue;
    const cls: number[] = [];
    for (let j = 0; j < n; j++) {
      if (matrix[i][j] && matrix[j][i]) {
        cls.push(j + 1);
        seen.add(j);
      }
    }
    if (cls.length) out.push(cls);
  }
  return out;
}

export function transitiveReduction(matrix: Matrix): Matrix {
  const closure = transitiveClosure(matrix);
  const out = copyMatrix(matrix);
  const n = matrix.length;
  for (let i = 0; i < n; i++) {
    for (let j = 0; j < n; j++) {
      if (!matrix[i][j] || i === j) continue;
      for (let k = 0; k < n; k++) {
        if (k !== i && k !== j && matrix[i][k] && closure[k][j]) {
          out[i][j] = false;
          break;
        }
      }
    }
  }
  for (let i = 0; i < n; i++) out[i][i] = false;
  return out;
}

export function isPartialOrder(matrix: Matrix): boolean {
  const p = relationProperties(matrix);
  return p.reflexive && p.antisymmetric && p.transitive;
}

export interface FunctionProps {
  injective: boolean;
  surjective: boolean;
  bijective: boolean;
  image: Set<number | undefined>;
  missing: number[];
  collisions: number;
}

export function functionProps(map: Mapping, domain: number[], codomain: number[]): FunctionProps {
  const values = domain.map((x) => map[x]);
  const image = new Set(values.filter((v) => v !== undefined));
  const injective = image.size === values.length;
  const surjective = [...codomain].every((y) => image.has(y));
  return {
    injective,
    surjective,
    bijective: injective && surjective,
    image,
    missing: [...codomain].filter((y) => !image.has(y)),
    collisions: values.length - image.size,
  };
}

export function compose(first: Mapping, second: Mapping, domain: number[]): Mapping {
  const out: Mapping = {};
  for (const x of domain) {
    const y = first[x];
    if (y !== undefined && second[y] !== undefined) out[x] = second[y];
  }
  return out;
}

export function invert(map: Mapping, domain: number[]): Mapping {
  const out: Mapping = {};
  for (const x of domain) if (map[x] !== undefined) out[map[x]] = x;
  return out;
}

export function image(map: Mapping, subsetSet: Set<number>): Set<number> {
  return new Set([...subsetSet].map((x) => map[x]).filter((v): v is number => v !== undefined));
}

export function preimage(map: Mapping, subsetSet: Set<number>): Set<number> {
  const out = new Set<number>();
  for (const key of Object.keys(map)) {
    const value = map[Number(key)];
    if (value !== undefined && subsetSet.has(value)) out.add(Number(key));
  }
  return out;
}

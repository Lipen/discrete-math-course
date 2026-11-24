/* Bit vectors, truth rows and Karnaugh layouts. */

export function bitsOf(value: number, width: number): number[] {
  const out: number[] = [];
  for (let i = width - 1; i >= 0; i--) out.push((value >> i) & 1);
  return out;
}

export function popcount(value: number): number {
  let count = 0;
  let x = value;
  while (x) {
    x &= x - 1;
    count++;
  }
  return count;
}

export function graySeq(width: number): number[] {
  const out: number[] = [];
  const size = 1 << width;
  for (let i = 0; i < size; i++) out.push(i ^ (i >> 1));
  return out;
}

export interface MapLayout {
  n: number;
  rowBits: number;
  colBits: number;
  rows: number[];
  cols: number[];
}

export function mapLayout(n: number): MapLayout {
  const rowBits = n <= 2 ? 1 : (n === 3 ? 1 : 2);
  const colBits = n - rowBits;
  return { n, rowBits, colBits, rows: graySeq(rowBits), cols: graySeq(colBits) };
}

export function mintermOf(rowCode: number, colCode: number, colBits: number): number {
  return (rowCode << colBits) | colCode;
}

export function fmt(value: number, digits?: number): string {
  const d = digits === undefined ? 2 : digits;
  return Number(value).toFixed(d).replace(/\.0+$/, "");
}

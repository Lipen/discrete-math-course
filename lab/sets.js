/* Finite sets, relations, orders and functions. */
(function () {
  "use strict";

  function range(n) { return Array.from({ length: n }, (_, i) => i + 1); }

  function make(values) { return new Set(values); }
  function list(set) { return Array.from(set).sort((a, b) => a - b); }
  function union(a, b) { return new Set([...a, ...b]); }
  function inter(a, b) { return new Set([...a].filter((x) => b.has(x))); }
  function diff(a, b) { return new Set([...a].filter((x) => !b.has(x))); }
  function symdiff(a, b) { return union(diff(a, b), diff(b, a)); }
  function complement(a, universe) { return diff(new Set(universe), a); }
  function subset(a, b) { return [...a].every((x) => b.has(x)); }
  function equal(a, b) { return subset(a, b) && subset(b, a); }
  function card(a) { return a.size; }
  function fmtSet(a) { return "{" + list(a).join(", ") + "}"; }

  function powerSet(a) {
    const items = list(a);
    const out = [];
    for (let mask = 0; mask < (1 << items.length); mask++) {
      const subsetItems = [];
      for (let i = 0; i < items.length; i++) if (mask & (1 << i)) subsetItems.push(items[i]);
      out.push(subsetItems);
    }
    out.sort((x, y) => x.length - y.length || x.join(",").localeCompare(y.join(",")));
    return out;
  }

  function relationMatrix(n, pairs) {
    const matrix = Array.from({ length: n }, () => new Array(n).fill(false));
    for (const [a, b] of pairs) matrix[a - 1][b - 1] = true;
    return matrix;
  }

  function relationPairs(matrix) {
    const out = [];
    for (let i = 0; i < matrix.length; i++) {
      for (let j = 0; j < matrix.length; j++) if (matrix[i][j]) out.push([i + 1, j + 1]);
    }
    return out;
  }

  function relationProperties(matrix) {
    const n = matrix.length;
    let reflexive = true, irreflexive = true, symmetric = true, antisymmetric = true, transitive = true;
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
          if (matrix[j][k] && !matrix[i][k]) { transitive = false; break; }
        }
        if (!transitive) break;
      }
      if (!transitive) break;
    }
    return { reflexive, irreflexive, symmetric, antisymmetric, transitive };
  }

  function copyMatrix(matrix) { return matrix.map((row) => row.slice()); }

  function reflexiveClosure(matrix) {
    const out = copyMatrix(matrix);
    for (let i = 0; i < out.length; i++) out[i][i] = true;
    return out;
  }

  function symmetricClosure(matrix) {
    const out = copyMatrix(matrix);
    for (let i = 0; i < out.length; i++) {
      for (let j = 0; j < out.length; j++) if (out[i][j]) out[j][i] = true;
    }
    return out;
  }

  function transitiveClosure(matrix) {
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

  function equivalenceClasses(matrix) {
    const n = matrix.length;
    const seen = new Set();
    const out = [];
    for (let i = 0; i < n; i++) {
      if (seen.has(i)) continue;
      const cls = [];
      for (let j = 0; j < n; j++) {
        if (matrix[i][j] && matrix[j][i]) { cls.push(j + 1); seen.add(j); }
      }
      if (cls.length) out.push(cls);
    }
    return out;
  }

  function transitiveReduction(matrix) {
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

  function isPartialOrder(matrix) {
    const p = relationProperties(matrix);
    return p.reflexive && p.antisymmetric && p.transitive;
  }

  function functionProps(map, domain, codomain) {
    const values = domain.map((x) => map[x]);
    const image = new Set(values.filter((v) => v !== undefined));
    const injective = image.size === values.length;
    const surjective = [...codomain].every((y) => image.has(y));
    return { injective, surjective, bijective: injective && surjective, image, missing: [...codomain].filter((y) => !image.has(y)), collisions: values.length - image.size };
  }

  function compose(first, second, domain) {
    const out = {};
    for (const x of domain) {
      const y = first[x];
      if (y !== undefined && second[y] !== undefined) out[x] = second[y];
    }
    return out;
  }

  function invert(map, domain) {
    const out = {};
    for (const x of domain) if (map[x] !== undefined) out[map[x]] = x;
    return out;
  }

  function image(map, subset) {
    return new Set([...subset].map((x) => map[x]).filter((v) => v !== undefined));
  }

  function preimage(map, subset) {
    const out = new Set();
    for (const key of Object.keys(map)) {
      if (subset.has(map[key])) out.add(Number(key));
    }
    return out;
  }

  window.Sets = {
    range, make, list, union, inter, diff, symdiff, complement, subset, equal, card, fmtSet, powerSet,
    relationMatrix, relationPairs, relationProperties, copyMatrix, reflexiveClosure, symmetricClosure,
    transitiveClosure, equivalenceClasses, transitiveReduction, isPartialOrder,
    functionProps, compose, invert, image, preimage,
  };
})();

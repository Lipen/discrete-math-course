//! Reduced ordered binary decision diagrams (ROBDDs) with complement edges.
//!
//! A BDD represents a boolean function as a directed acyclic graph built by
//! Shannon expansion: a node `(v, lo, hi)` means "if variable `v` then `hi`
//! else `lo`". Reduction removes redundant nodes (lo == hi) and merges equal
//! subgraphs, so every function has exactly one diagram. Complement edges
//! store negation as a flag on the edge: `NOT` costs nothing and the node
//! count is roughly halved.

use std::collections::HashMap;

/// An edge is a node index shifted left by one, with the low bit as a
/// complement flag. Edge `0` is the constant TRUE, edge `1` is FALSE.
pub type Edge = u32;

/// The constant TRUE.
pub const TRUE: Edge = 0;
/// The constant FALSE.
pub const FALSE: Edge = 1;

/// A BDD node: test variable `var`, `lo` when false, `hi` when true.
#[derive(Clone, Copy)]
struct Node {
    var: u32,
    lo: Edge,
    hi: Edge,
}

/// A manager for a family of BDDs over a common node table.
pub struct Bdd {
    nodes: Vec<Node>,
    unique: HashMap<(u32, Edge, Edge), u32>,
    ite_cache: HashMap<(Edge, Edge, Edge), Edge>,
}

impl Bdd {
    /// A fresh manager with the constant node TRUE.
    pub fn new() -> Bdd {
        Bdd {
            nodes: vec![Node {
                var: u32::MAX,
                lo: TRUE,
                hi: TRUE,
            }],
            unique: HashMap::new(),
            ite_cache: HashMap::new(),
        }
    }

    /// The BDD for the single variable `x_i`.
    ///
    /// It is the node `(i, FALSE, TRUE)`: if `x_i` then TRUE else FALSE.
    pub fn var(&mut self, i: u32) -> Edge {
        self.mk(i, FALSE, TRUE)
    }

    /// The BDD for the negation of `u`: flipping the complement flag.
    pub fn not(&self, u: Edge) -> Edge {
        u ^ 1
    }

    /// The BDD for `u and v`.
    pub fn and(&mut self, u: Edge, v: Edge) -> Edge {
        self.ite(u, v, FALSE)
    }

    /// The BDD for `u or v`.
    pub fn or(&mut self, u: Edge, v: Edge) -> Edge {
        self.ite(u, TRUE, v)
    }

    /// The BDD for `u xor v`.
    pub fn xor(&mut self, u: Edge, v: Edge) -> Edge {
        self.ite(u, self.not(v), v)
    }

    /// Number of nodes in the manager (including the constant node).
    pub fn size(&self) -> usize {
        self.nodes.len()
    }

    /// Evaluates the function of edge `u` under the assignment `assign`.
    ///
    /// `assign[i]` is the value of variable `x_i`.
    pub fn eval(&self, u: Edge, assign: &[bool]) -> bool {
        let idx = (u >> 1) as usize;
        if idx == 0 {
            return u & 1 == 0;
        }
        let node = &self.nodes[idx];
        let child = if assign[node.var as usize] {
            node.hi
        } else {
            node.lo
        };
        self.eval(child, assign) ^ (u & 1 == 1)
    }

    /// The canonical `(var, lo, hi)` node: `ite(x_var, hi, lo)`.
    ///
    /// Applies reduction (drop redundant nodes) and the standard complement-edge
    /// normalization: the `hi` child is never complemented.
    fn mk(&mut self, var: u32, lo: Edge, hi: Edge) -> Edge {
        if lo == hi {
            return lo;
        }
        if hi & 1 == 1 {
            // Negate both children and complement the result.
            return self.mk(var, lo ^ 1, hi ^ 1) ^ 1;
        }
        if let Some(&idx) = self.unique.get(&(var, lo, hi)) {
            return (idx as Edge) << 1;
        }
        let idx = self.nodes.len() as u32;
        self.nodes.push(Node { var, lo, hi });
        self.unique.insert((var, lo, hi), idx);
        (idx as Edge) << 1
    }

    /// The ternary operator `ite(f, g, h)`: if `f` then `g` else `h`.
    ///
    /// This is the fundamental BDD operation; `and`, `or`, `xor` are special
    /// cases. It builds the result by Shannon expansion on the top variable,
    /// memoized so the cost stays polynomial in the result size.
    pub fn ite(&mut self, f: Edge, g: Edge, h: Edge) -> Edge {
        // Base cases.
        if f == TRUE {
            return g;
        }
        if f == FALSE {
            return h;
        }
        if g == h {
            return g;
        }
        if g == TRUE && h == FALSE {
            return f;
        }
        if g == FALSE && h == TRUE {
            return self.not(f);
        }
        if let Some(&r) = self.ite_cache.get(&(f, g, h)) {
            return r;
        }

        // The top variable is the smallest variable among the arguments.
        let mut v = u32::MAX;
        for e in [f, g, h] {
            let idx = e >> 1;
            if idx != 0 {
                v = v.min(self.nodes[idx as usize].var);
            }
        }

        let (f_lo, f_hi) = self.cofactor(f, v);
        let (g_lo, g_hi) = self.cofactor(g, v);
        let (h_lo, h_hi) = self.cofactor(h, v);

        let lo = self.ite(f_lo, g_lo, h_lo);
        let hi = self.ite(f_hi, g_hi, h_hi);
        let r = self.mk(v, lo, hi);
        self.ite_cache.insert((f, g, h), r);
        r
    }

    /// Restricts `e` to `v = 0` (lo) and `v = 1` (hi).
    ///
    /// If `e` is a constant or a node on a variable below `v`, the restriction
    /// is a no-op; a node on `v` splits into its two children. A complement
    /// flag on the edge negates both children.
    fn cofactor(&self, e: Edge, v: u32) -> (Edge, Edge) {
        let idx = e >> 1;
        if idx == 0 {
            return (e, e);
        }
        let node = &self.nodes[idx as usize];
        if node.var == v {
            (node.lo ^ (e & 1), node.hi ^ (e & 1))
        } else {
            (e, e)
        }
    }
}

impl Default for Bdd {
    fn default() -> Bdd {
        Bdd::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Checks that the BDD function matches a reference truth table.
    fn check_table(f: Edge, bdd: &Bdd, nvars: usize, table: &[bool]) {
        assert_eq!(table.len(), 1 << nvars);
        for (mask, &expected) in table.iter().enumerate() {
            let assign: Vec<bool> = (0..nvars).map(|i| mask & (1 << i) != 0).collect();
            assert_eq!(
                bdd.eval(f, &assign),
                expected,
                "mask {mask:0b} (x1..x{nvars})"
            );
        }
    }

    #[test]
    fn xor_of_two_variables() {
        let mut bdd = Bdd::new();
        let x1 = bdd.var(0);
        let x2 = bdd.var(1);
        let f = bdd.xor(x1, x2);
        // 00→0, 01→1, 10→1, 11→0.
        check_table(f, &bdd, 2, &[false, true, true, false]);
    }

    #[test]
    fn majority_of_three() {
        let mut bdd = Bdd::new();
        let (x1, x2, x3) = (bdd.var(0), bdd.var(1), bdd.var(2));
        // majority = (x1∧x2) ∨ (x1∧x3) ∨ (x2∧x3).
        let a = bdd.and(x1, x2);
        let b = bdd.and(x1, x3);
        let c = bdd.and(x2, x3);
        let ab = bdd.or(a, b);
        let f = bdd.or(ab, c);
        let table = [false, false, false, true, false, true, true, true];
        check_table(f, &bdd, 3, &table);
    }

    #[test]
    fn negation_is_free_and_shares_nodes() {
        let mut bdd = Bdd::new();
        let x1 = bdd.var(0);
        let nx1 = bdd.not(x1);
        // NOT costs no new node: same diagram, flipped flag.
        assert_eq!(bdd.size(), 2); // the constant node + the x1 node
        check_table(nx1, &bdd, 1, &[true, false]);
    }

    #[test]
    fn identical_subfunctions_are_shared() {
        let mut bdd = Bdd::new();
        let x1 = bdd.var(0);
        let x2 = bdd.var(1);
        // (x1 ∧ x2) ∨ (x1 ∧ x2) shares the same sub-BDD.
        let a = bdd.and(x1, x2);
        let dup = bdd.and(x1, x2);
        let b = bdd.or(a, dup);
        assert_eq!(a, b);
        check_table(b, &bdd, 2, &[false, false, false, true]);
    }

    #[test]
    fn reduction_drops_redundant_nodes() {
        let mut bdd = Bdd::new();
        // x1 ∨ ¬x1 = TRUE: the built node is redundant and collapses.
        let x1 = bdd.var(0);
        let f = bdd.or(x1, bdd.not(x1));
        assert_eq!(f, TRUE);
    }
}

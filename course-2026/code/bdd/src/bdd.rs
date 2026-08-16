use std::collections::HashMap;

/// An edge in the BDD: a node index shifted left by one, with the low bit
/// storing a complement flag. Edge `0` is TRUE, edge `1` is FALSE.
///
/// ```
/// use bdd::{Edge, TRUE, FALSE};
///
/// assert_eq!(TRUE, 0);
/// assert_eq!(FALSE, 1);
/// // Negation flips the low bit.
/// assert_eq!(TRUE ^ 1, FALSE);
/// ```
pub type Edge = u32;

/// The constant TRUE edge.
pub const TRUE: Edge = 0;
/// The constant FALSE edge.
pub const FALSE: Edge = 1;

/// A BDD node: test variable `var`, go to `lo` when false, `hi` when true.
/// The `hi` edge is always non-complemented (`hi & 1 == 0`) -- this is the
/// standard complement-edge normalisation.
#[derive(Clone, Copy, Debug)]
struct Node {
    var: u32,
    lo: Edge,
    hi: Edge,
}

/// A manager for a family of BDDs over a common node table.
///
/// Every boolean function gets a unique canonical edge under a fixed variable
/// order. Complement edges store negation as a flag on the edge: `NOT` costs
/// nothing, and a function and its negation share a single diagram.
///
/// ```
/// use bdd::Bdd;
///
/// let mut bdd = Bdd::new();
/// let x = bdd.var(0);
/// let y = bdd.var(1);
/// let f = bdd.xor(x, y);
///
/// assert!(!bdd.eval(f, &[false, false]));
/// assert!(bdd.eval(f, &[false, true]));
/// assert!(bdd.eval(f, &[true, false]));
/// assert!(!bdd.eval(f, &[true, true]));
/// ```
pub struct Bdd {
    nodes: Vec<Node>,
    unique: HashMap<(u32, Edge, Edge), u32>,
    ite_cache: HashMap<(Edge, Edge, Edge), Edge>,
}

impl Bdd {
    /// A fresh manager with the constant node already in place.
    ///
    /// ```
    /// use bdd::Bdd;
    ///
    /// let bdd = Bdd::new();
    /// assert_eq!(bdd.size(), 1); // the constant node
    /// ```
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

    /// The BDD for the single variable `x_i`: the node `(i, FALSE, TRUE)`.
    ///
    /// ```
    /// use bdd::Bdd;
    ///
    /// let mut bdd = Bdd::new();
    /// let x0 = bdd.var(0);
    /// assert!(!bdd.eval(x0, &[false]));
    /// assert!(bdd.eval(x0, &[true]));
    /// ```
    pub fn var(&mut self, i: u32) -> Edge {
        self.mk(i, FALSE, TRUE)
    }

    /// The negation of `u`: flips the complement flag on the edge.
    ///
    /// ```
    /// use bdd::Bdd;
    ///
    /// let mut bdd = Bdd::new();
    /// let x = bdd.var(0);
    /// let nx = bdd.not(x);
    /// assert!(bdd.eval(nx, &[false]));
    /// assert!(!bdd.eval(nx, &[true]));
    /// assert_eq!(bdd.size(), 2); // no new node built
    /// ```
    pub fn not(&self, u: Edge) -> Edge {
        u ^ 1
    }

    /// The BDD for `u and v`.
    ///
    /// ```
    /// use bdd::Bdd;
    ///
    /// let mut bdd = Bdd::new();
    /// let x = bdd.var(0);
    /// let y = bdd.var(1);
    /// let f = bdd.and(x, y);
    /// assert!(!bdd.eval(f, &[false, false]));
    /// assert!(bdd.eval(f, &[true, true]));
    /// ```
    pub fn and(&mut self, u: Edge, v: Edge) -> Edge {
        self.ite(u, v, FALSE)
    }

    /// The BDD for `u or v`.
    ///
    /// ```
    /// use bdd::Bdd;
    ///
    /// let mut bdd = Bdd::new();
    /// let x = bdd.var(0);
    /// let y = bdd.var(1);
    /// let f = bdd.or(x, y);
    /// assert!(!bdd.eval(f, &[false, false]));
    /// assert!(bdd.eval(f, &[true, false]));
    /// ```
    pub fn or(&mut self, u: Edge, v: Edge) -> Edge {
        self.ite(u, TRUE, v)
    }

    /// The BDD for `u xor v`.
    ///
    /// ```
    /// use bdd::Bdd;
    ///
    /// let mut bdd = Bdd::new();
    /// let x = bdd.var(0);
    /// let y = bdd.var(1);
    /// let f = bdd.xor(x, y);
    /// assert!(!bdd.eval(f, &[false, false]));
    /// assert!(bdd.eval(f, &[true, false]));
    /// assert!(!bdd.eval(f, &[true, true]));
    /// ```
    pub fn xor(&mut self, u: Edge, v: Edge) -> Edge {
        self.ite(u, self.not(v), v)
    }

    /// Number of nodes in the manager (including the constant node).
    ///
    /// ```
    /// use bdd::Bdd;
    ///
    /// let mut bdd = Bdd::new();
    /// assert_eq!(bdd.size(), 1);
    /// bdd.var(0);
    /// assert_eq!(bdd.size(), 2);
    /// ```
    pub fn size(&self) -> usize {
        self.nodes.len()
    }

    /// Evaluates the function of edge `u` under `assign`, where `assign[i]`
    /// is the value of variable `x_i`.
    ///
    /// ```
    /// use bdd::Bdd;
    ///
    /// let mut bdd = Bdd::new();
    /// let x = bdd.var(0);
    /// let y = bdd.var(1);
    /// let f = bdd.and(x, y);
    /// assert!(bdd.eval(f, &[true, true]));
    /// assert!(!bdd.eval(f, &[true, false]));
    /// ```
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

    /// The ternary operator `ite(f, g, h)`: if `f` then `g` else `h`.
    ///
    /// This is the fundamental BDD operation -- `and`, `or`, `xor` are special
    /// cases. It builds the result by Shannon expansion on the top variable,
    /// memoized so the cost stays polynomial in the result size.
    ///
    /// ```
    /// use bdd::Bdd;
    ///
    /// let mut bdd = Bdd::new();
    /// let x = bdd.var(0);
    /// let y = bdd.var(1);
    /// let z = bdd.var(2);
    /// // ite(x, y, z) = (x ∧ y) ∨ (¬x ∧ z)
    /// let f = bdd.ite(x, y, z);
    /// assert!(bdd.eval(f, &[true, true, false]));
    /// assert!(bdd.eval(f, &[false, false, true]));
    /// assert!(!bdd.eval(f, &[true, false, false]));
    /// ```
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

    /// Counts how many assignments of `nvars` variables (x_0 ... x_{n-1})
    /// satisfy the function represented by edge `u`.
    ///
    /// Runs in time proportional to the number of reachable nodes. Returns
    /// `u64::MAX` when the true count exceeds `u64::MAX`.
    ///
    /// ```
    /// use bdd::Bdd;
    ///
    /// let mut bdd = Bdd::new();
    /// let x = bdd.var(0);
    /// let y = bdd.var(1);
    /// let f = bdd.xor(x, y);
    /// assert_eq!(bdd.sat_count(f, 2), 2); // (0,1) and (1,0)
    ///
    /// let t = bdd.or(x, bdd.not(x));
    /// assert_eq!(bdd.sat_count(t, 1), 2); // TRUE with 1 var: 2 assignments
    /// ```
    pub fn sat_count(&self, u: Edge, nvars: u32) -> u64 {
        let mut memo = HashMap::new();
        self.sat_count_rec(u, 0, nvars, &mut memo)
    }

    /// Restricts variable `var` to `value` in the function of edge `u`.
    ///
    /// ```
    /// use bdd::Bdd;
    ///
    /// let mut bdd = Bdd::new();
    /// let x = bdd.var(0);
    /// let y = bdd.var(1);
    /// // f = x ∧ y
    /// let f = bdd.and(x, y);
    /// // f restricted to x=true is just y
    /// let fy = bdd.restrict(f, 0, true);
    /// assert!(!bdd.eval(fy, &[false, false]));
    /// assert!(bdd.eval(fy, &[false, true]));
    /// ```
    pub fn restrict(&mut self, u: Edge, var: u32, value: bool) -> Edge {
        let idx = u >> 1;
        if idx == 0 {
            return u;
        }
        let node = self.nodes[idx as usize];
        if node.var > var {
            return u;
        }
        let c = u & 1;
        if node.var == var {
            let child = if value { node.hi } else { node.lo };
            return child ^ c;
        }
        // node.var < var -- recurse into both children.
        let lo = self.restrict(node.lo ^ c, var, value);
        let hi = self.restrict(node.hi ^ c, var, value);
        self.mk(node.var, lo, hi)
    }

    /// Returns `true` iff `u` represents the constant TRUE function.
    ///
    /// Every tautology collapses to the single canonical edge `TRUE`.
    ///
    /// ```
    /// use bdd::{Bdd, TRUE, FALSE};
    ///
    /// let mut bdd = Bdd::new();
    /// let x = bdd.var(0);
    /// let t = bdd.or(x, bdd.not(x));
    /// assert_eq!(t, TRUE);
    /// assert!(Bdd::is_tautology(t));
    /// assert!(!Bdd::is_tautology(FALSE));
    /// ```
    pub fn is_tautology(u: Edge) -> bool {
        u == TRUE
    }

    /// Returns `true` iff `u` is satisfiable (not the constant FALSE function).
    ///
    /// ```
    /// use bdd::{Bdd, TRUE, FALSE};
    ///
    /// let mut bdd = Bdd::new();
    /// let x = bdd.var(0);
    /// assert!(Bdd::is_satisfiable(x));
    /// assert!(!Bdd::is_satisfiable(FALSE));
    /// ```
    pub fn is_satisfiable(u: Edge) -> bool {
        u != FALSE
    }

    // ==================================================================
    // Internal helpers
    // ==================================================================

    /// The canonical `(var, lo, hi)` node.
    ///
    /// Applies reduction (drops redundant nodes where lo == hi) and the
    /// complement-edge normalisation: the `hi` child is never complemented.
    fn mk(&mut self, var: u32, lo: Edge, hi: Edge) -> Edge {
        if lo == hi {
            return lo;
        }
        if hi & 1 == 1 {
            // Push complement from hi to the result edge.
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

    /// Restricts `e` to `v = 0` (lo) and `v = 1` (hi).
    ///
    /// If `e` is a constant or a node below `v`, the restriction is a no-op;
    /// a node on `v` splits into its two children. A complement flag on the
    /// edge negates both children.
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

    /// Recursive worker for `sat_count`, with memoisation on edges.
    fn sat_count_rec(
        &self,
        e: Edge,
        cur_var: u32,
        nvars: u32,
        memo: &mut HashMap<Edge, u64>,
    ) -> u64 {
        let idx = e >> 1;
        if idx == 0 {
            // Constants are not memoized: the result depends on cur_var,
            // and the same constant edge can be reached at different
            // variable levels through different paths.
            return if e & 1 == 0 {
                pow2_sat(nvars - cur_var)
            } else {
                0
            };
        }
        let node = &self.nodes[idx as usize];
        // Variables cur_var..node.var do not occur on this path; each one
        // doubles the count. The count from node.var down is memoized per
        // node, so it does not depend on the level we are reached from.
        let skipped = pow2_sat(node.var - cur_var);
        let base = if let Some(&c) = memo.get(&e) {
            c
        } else {
            let c = e & 1;
            let lo = self.sat_count_rec(node.lo ^ c, node.var + 1, nvars, memo);
            let hi = self.sat_count_rec(node.hi ^ c, node.var + 1, nvars, memo);
            let b = lo.saturating_add(hi);
            memo.insert(e, b);
            b
        };
        skipped.saturating_mul(base)
    }
}

impl Default for Bdd {
    fn default() -> Bdd {
        Bdd::new()
    }
}

/// Compute `2^n` saturating at `u64::MAX`.
fn pow2_sat(n: u32) -> u64 {
    if n >= 64 {
        u64::MAX
    } else {
        1u64 << n
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Checks that a BDD edge matches a reference truth table over all
    /// assignments of `nvars` variables (x_0 ... x_{nvars-1}).
    fn check_table(f: Edge, bdd: &Bdd, nvars: usize, table: &[bool]) {
        assert_eq!(table.len(), 1 << nvars);
        for (mask, &expected) in table.iter().enumerate() {
            let assign: Vec<bool> = (0..nvars).map(|i| mask & (1 << i) != 0).collect();
            assert_eq!(
                bdd.eval(f, &assign),
                expected,
                "mask {mask:0b} (x_0..x_{})",
                nvars - 1
            );
        }
    }

    // -- boolean operations ==================================================

    #[test]
    fn xor_of_two_variables() {
        let mut bdd = Bdd::new();
        let x1 = bdd.var(0);
        let x2 = bdd.var(1);
        let f = bdd.xor(x1, x2);
        // 00->0, 01->1, 10->1, 11->0.
        check_table(f, &bdd, 2, &[false, true, true, false]);
    }

    #[test]
    fn majority_of_three() {
        let mut bdd = Bdd::new();
        let (x1, x2, x3) = (bdd.var(0), bdd.var(1), bdd.var(2));
        // majority = (x1 ∧ x2) ∨ (x1 ∧ x3) ∨ (x2 ∧ x3).
        let a = bdd.and(x1, x2);
        let b = bdd.and(x1, x3);
        let c = bdd.and(x2, x3);
        let ab = bdd.or(a, b);
        let f = bdd.or(ab, c);
        let table = [false, false, false, true, false, true, true, true];
        check_table(f, &bdd, 3, &table);
    }

    // -- structural properties ================================================

    #[test]
    fn negation_is_free_and_shares_nodes() {
        let mut bdd = Bdd::new();
        let x0 = bdd.var(0);
        let nx0 = bdd.not(x0);
        // NOT costs no new node: same diagram, flipped flag.
        assert_eq!(bdd.size(), 2); // the constant node + the x0 node
        check_table(nx0, &bdd, 1, &[true, false]);
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

    #[test]
    fn unique_table_reuses_nodes() {
        let mut bdd = Bdd::new();
        let x0 = bdd.var(0);
        let x1 = bdd.var(1);
        let a = bdd.and(x0, x1);
        let b = bdd.and(x0, x1);
        // Same operation twice returns the same edge.
        assert_eq!(a, b);
        // Building the same thing again shouldn't grow the table.
        let size_before = bdd.size();
        let _c = bdd.and(x0, x1);
        assert_eq!(bdd.size(), size_before);
    }

    // -- sat_count ============================================================

    #[test]
    fn sat_count_xor_two_vars() {
        let mut bdd = Bdd::new();
        let x = bdd.var(0);
        let y = bdd.var(1);
        let f = bdd.xor(x, y);
        assert_eq!(bdd.sat_count(f, 2), 2);
    }

    #[test]
    fn sat_count_majority_three() {
        let mut bdd = Bdd::new();
        let (x0, x1, x2) = (bdd.var(0), bdd.var(1), bdd.var(2));
        let a = bdd.and(x0, x1);
        let b = bdd.and(x0, x2);
        let c = bdd.and(x1, x2);
        let ab = bdd.or(a, b);
        let f = bdd.or(ab, c);
        // Majority of three: 4 out of 8 satisfy it.
        assert_eq!(bdd.sat_count(f, 3), 4);
    }

    #[test]
    fn sat_count_tautology() {
        let mut bdd = Bdd::new();
        let x0 = bdd.var(0);
        let t = bdd.or(x0, bdd.not(x0));
        assert_eq!(bdd.sat_count(t, 1), 2); // TRUE with 1 var has 2 assignments
        assert_eq!(bdd.sat_count(t, 3), 8); // TRUE with 3 vars has 8
    }

    #[test]
    fn sat_count_false_is_zero() {
        assert_eq!(Bdd::new().sat_count(FALSE, 5), 0);
    }

    #[test]
    fn sat_count_with_complement() {
        let mut bdd = Bdd::new();
        let x = bdd.var(0);
        let y = bdd.var(1);
        let xy = bdd.and(x, y);
        let f = bdd.not(xy);
        assert_eq!(bdd.sat_count(f, 2), 3);
    }

    #[test]
    fn sat_count_shared_subgraph_reached_at_different_levels() {
        // f = x2 ∧ (x0 ∨ x1): the x2 node is reached both directly from x0
        // (skipping x1) and through x1, so the same subgraph is counted from
        // two different variable levels.
        let mut bdd = Bdd::new();
        let x0 = bdd.var(0);
        let x1 = bdd.var(1);
        let x2 = bdd.var(2);
        let or = bdd.or(x0, x1);
        let f = bdd.and(x2, or);
        assert_eq!(bdd.sat_count(f, 3), 3);

        // (x0 ∧ x1) ∨ (x2 ∧ x3) over four variables: 4 + 4 - 1 = 7 models.
        let mut bdd = Bdd::new();
        let x0 = bdd.var(0);
        let x1 = bdd.var(1);
        let x2 = bdd.var(2);
        let x3 = bdd.var(3);
        let l = bdd.and(x0, x1);
        let r = bdd.and(x2, x3);
        let f = bdd.or(l, r);
        assert_eq!(bdd.sat_count(f, 4), 7);
    }

    // -- is_tautology / is_satisfiable ========================================

    #[test]
    fn tautology_detection() {
        let mut bdd = Bdd::new();
        let x = bdd.var(0);
        assert!(Bdd::is_tautology(bdd.or(x, bdd.not(x))));
        assert!(!Bdd::is_tautology(x));
        assert!(!Bdd::is_tautology(bdd.and(x, bdd.not(x))));
    }

    #[test]
    fn satisfiability_detection() {
        let mut bdd = Bdd::new();
        let x = bdd.var(0);
        assert!(Bdd::is_satisfiable(x));
        assert!(!Bdd::is_satisfiable(bdd.and(x, bdd.not(x))));
        assert!(Bdd::is_satisfiable(TRUE));
        assert!(!Bdd::is_satisfiable(FALSE));
    }

    // -- restrict =============================================================

    #[test]
    fn restrict_var_to_true() {
        let mut bdd = Bdd::new();
        let x = bdd.var(0);
        let y = bdd.var(1);
        // f = x ∧ y, restrict x to true => y
        let f = bdd.and(x, y);
        let fy = bdd.restrict(f, 0, true);
        // After restriction, the function depends only on y (var 1).
        assert!(!bdd.eval(fy, &[false, false]));
        assert!(bdd.eval(fy, &[false, true]));
    }

    #[test]
    fn restrict_var_to_false() {
        let mut bdd = Bdd::new();
        let x = bdd.var(0);
        let y = bdd.var(1);
        // f = x ∨ y, restrict x to false => y
        let f = bdd.or(x, y);
        let fy = bdd.restrict(f, 0, false);
        assert!(!bdd.eval(fy, &[false, false]));
        assert!(bdd.eval(fy, &[false, true]));
    }

    #[test]
    fn restrict_missing_var_is_noop() {
        let mut bdd = Bdd::new();
        let x = bdd.var(0);
        // x doesn't depend on var 5.
        let r = bdd.restrict(x, 5, true);
        assert_eq!(r, x);
    }

    #[test]
    fn restrict_under_complement() {
        let mut bdd = Bdd::new();
        let x = bdd.var(0);
        let y = bdd.var(1);
        // f = ¬(x ∧ y), restrict x to true => ¬y
        let xy = bdd.and(x, y);
        let f = bdd.not(xy);
        let fy = bdd.restrict(f, 0, true);
        // ¬y: y=0 => true, y=1 => false
        assert!(bdd.eval(fy, &[false, false]));
        assert!(!bdd.eval(fy, &[false, true]));
    }

    // -- ite ================================================================

    #[test]
    fn ite_base_cases() {
        let mut bdd = Bdd::new();
        let x = bdd.var(0);
        // ite(TRUE, x, y) = x
        assert_eq!(bdd.ite(TRUE, x, FALSE), x);
        // ite(FALSE, x, y) = y
        assert_eq!(bdd.ite(FALSE, TRUE, x), x);
        // ite(f, g, g) = g
        assert_eq!(bdd.ite(x, TRUE, TRUE), TRUE);
        // ite(f, TRUE, FALSE) = f
        assert_eq!(bdd.ite(x, TRUE, FALSE), x);
    }

    // -- complement edge edge cases =========================================

    #[test]
    fn double_negation_is_identity() {
        let mut bdd = Bdd::new();
        let x = bdd.var(0);
        assert_eq!(bdd.not(bdd.not(x)), x);
    }

    #[test]
    fn complemented_edge_eval() {
        let mut bdd = Bdd::new();
        let x = bdd.var(0);
        // not(x) evaluated on x=true should be false.
        assert!(!bdd.eval(bdd.not(x), &[true]));
        // not(x) evaluated on x=false should be true.
        assert!(bdd.eval(bdd.not(x), &[false]));
    }
}

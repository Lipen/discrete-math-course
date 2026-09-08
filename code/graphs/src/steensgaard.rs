//! Steensgaard's pointer analysis: unification-based alias analysis.
//!
//! A tiny C-like language with pointers and four statements:
//!
//! - `x = &y` -- take the address of `y`.
//! - `x = y` -- copy a pointer.
//! - `x = *y` -- load a pointer through another pointer.
//! - `*x = y` -- store a pointer through another pointer.
//!
//! The analysis computes, for every variable, the set of locations it may point to.
//! The trick that makes Steensgaard's algorithm run in $O(n alpha(n))$: every variable and every location is a node, and every node has at most one outgoing points-to edge.
//! When a constraint demands that a node point to two different targets, those targets are *unified* into a single abstract location (a union-find class).
//! One representative per class keeps the invariant, and the union-find absorbs the merging cost.
//! The price is precision: `p = &x; q = &y; p = q;` merges `x` and `y`, so afterwards both `p` and `q` may point to either.
//!
//! Points-to sets are the equivalence classes of the union-find: the set that `x` points to is the class of `x`'s target node.
//!
//! Worked example.
//! The program
//!
//! ```text
//! p = &x;
//! q = &y;
//! p = q;
//! ```
//!
//! is analyzed as follows.
//! The first two statements give `pt(p) = {x}` and `pt(q) = {y}`.
//! The copy `p = q` demands `pt(p) sup pt(q)`, and with a single target per node the only way is to merge the two targets: `x` and `y` become one abstract location, and `pt(p) = pt(q) = {x, y}`.
//! The analysis is safe (both pointers really point to both locations in some run) but coarse: it cannot tell `x` and `y` apart anymore.
//!
//! ```
//! use graphs::{Stmt, Steensgaard};
//!
//! let mut s = Steensgaard::new();
//! s.run(&[
//!     Stmt::AddrOf { x: "p".into(), y: "x".into() }, // p = &x
//!     Stmt::AddrOf { x: "q".into(), y: "y".into() }, // q = &y
//!     Stmt::Copy { x: "p".into(), y: "q".into() },   // p = q
//! ]);
//!
//! // p and q may point to x or y -- the two locations got unified.
//! let p = s.points_to("p");
//! assert_eq!(p, vec!["x", "y"]);
//! assert_eq!(s.points_to("q"), p);
//! assert!(s.may_alias("p", "q"));
//! ```

use std::collections::HashMap;

use crate::UnionFind;

/// A statement of the tiny pointer language.
///
/// The four forms match the four statements of the module documentation.
/// Every `x` and `y` is a variable name (never a literal address).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Stmt {
    /// `x = &y` -- `x` points to the location of `y`.
    AddrOf { x: String, y: String },
    /// `x = y` -- copy the pointer value of `y` into `x`.
    Copy { x: String, y: String },
    /// `x = *y` -- `x` gets the pointer stored at the location `y` points to.
    Load { x: String, y: String },
    /// `*x = y` -- the location `x` points to receives the pointer `y`.
    Store { x: String, y: String },
}

/// A unification-based pointer analysis (Steensgaard's algorithm).
///
/// Nodes are variables and abstract locations.
/// `find`/`union` come from [`UnionFind`].
/// `target` records the single points-to edge of each class representative.
///
/// ```
/// use graphs::Steensgaard;
///
/// let mut s = Steensgaard::new();
/// s.assign_addr("x", "y"); // x = &y
/// s.assign_addr("p", "x"); // p = &x
/// s.assign_deref("q", "p"); // q = *p  -- q points to what x points to
/// assert_eq!(s.points_to("q"), vec!["y"]);
/// ```
#[derive(Debug)]
pub struct Steensgaard {
    /// `names[i]` -- the variable name of node `i` (`None` for anonymous locations created by the dereference rules).
    names: Vec<Option<String>>,
    /// Variable name -> node id.
    vars: HashMap<String, usize>,
    /// The union-find over nodes.
    uf: UnionFind,
    /// `target[r]` -- the node that the representative `r` points to (`None`: nothing known).
    /// Only meaningful for representatives.
    target: Vec<Option<usize>>,
}

impl Steensgaard {
    /// A new empty analysis: no variables yet.
    ///
    /// ```
    /// use graphs::Steensgaard;
    ///
    /// let mut s = Steensgaard::new();
    /// assert!(s.points_to_sets().is_empty());
    /// ```
    pub fn new() -> Self {
        Steensgaard {
            names: Vec::new(),
            vars: HashMap::new(),
            uf: UnionFind::new(0),
            target: Vec::new(),
        }
    }

    /// Declare a variable.
    /// Returns its node id.
    /// Repeated declarations return the same id (the analysis is flow-insensitive).
    ///
    /// ```
    /// use graphs::Steensgaard;
    ///
    /// let mut s = Steensgaard::new();
    /// assert_eq!(s.declare("x"), s.declare("x"));
    /// ```
    pub fn declare(&mut self, name: &str) -> usize {
        if let Some(&id) = self.vars.get(name) {
            return id;
        }
        let id = self.uf.push();
        self.names.push(Some(name.to_string()));
        self.target.push(None);
        self.vars.insert(name.to_string(), id);
        id
    }

    /// Apply a whole program, one statement at a time.
    ///
    /// ```
    /// use graphs::{Stmt, Steensgaard};
    ///
    /// let mut s = Steensgaard::new();
    /// s.run(&[Stmt::AddrOf { x: "p".into(), y: "x".into() }]);
    /// assert_eq!(s.points_to("p"), vec!["x"]);
    /// ```
    pub fn run(&mut self, program: &[Stmt]) {
        for stmt in program {
            self.apply(stmt);
        }
    }

    /// Apply one statement.
    ///
    /// ```
    /// use graphs::{Stmt, Steensgaard};
    ///
    /// let mut s = Steensgaard::new();
    /// s.apply(&Stmt::AddrOf { x: "p".into(), y: "x".into() });
    /// assert_eq!(s.points_to("p"), vec!["x"]);
    /// ```
    pub fn apply(&mut self, stmt: &Stmt) {
        match stmt {
            Stmt::AddrOf { x, y } => self.assign_addr(x, y),
            Stmt::Copy { x, y } => self.assign_copy(x, y),
            Stmt::Load { x, y } => self.assign_deref(x, y),
            Stmt::Store { x, y } => self.deref_assign(x, y),
        }
    }

    /// `x = &y`: `x` points to `y`.
    /// If `x` already points to a different location, the two targets are unified.
    ///
    /// ```
    /// use graphs::Steensgaard;
    ///
    /// let mut s = Steensgaard::new();
    /// s.assign_addr("p", "x");
    /// s.assign_addr("p", "y"); // two targets merge into one location
    /// assert_eq!(s.points_to("p"), vec!["x", "y"]);
    /// ```
    pub fn assign_addr(&mut self, x: &str, y: &str) {
        let nx = self.declare(x);
        let ny = self.declare(y);
        let rx = self.uf.find(nx);
        match self.target[rx] {
            None => self.target[rx] = Some(ny),
            Some(t) => self.unify(t, ny),
        }
    }

    /// `x = y`: the two variables share storage, so their nodes (and, transitively, their targets) are unified.
    ///
    /// ```
    /// use graphs::Steensgaard;
    ///
    /// let mut s = Steensgaard::new();
    /// s.assign_addr("p", "x");
    /// s.assign_copy("q", "p"); // q points to the same location as p
    /// assert_eq!(s.points_to("q"), vec!["x"]);
    /// ```
    pub fn assign_copy(&mut self, x: &str, y: &str) {
        let nx = self.declare(x);
        let ny = self.declare(y);
        self.unify(nx, ny);
    }

    /// `x = *y`: `x` must point to whatever the location that `y` points to points to, so `x` and that location are unified.
    /// If `y` points to nothing known yet, a fresh location is created for it.
    ///
    /// ```
    /// use graphs::Steensgaard;
    ///
    /// let mut s = Steensgaard::new();
    /// s.assign_addr("p", "x"); // p -> x
    /// s.assign_addr("x", "y"); // x -> y
    /// s.assign_deref("q", "p"); // q = *p = *x -> y
    /// assert_eq!(s.points_to("q"), vec!["y"]);
    /// ```
    pub fn assign_deref(&mut self, x: &str, y: &str) {
        let nx = self.declare(x);
        let ny = self.declare(y);
        let loc = self.target_or_fresh(ny);
        self.unify(nx, loc);
    }

    /// `*x = y`: the location that `x` points to receives `y`, so `y` and that location are unified.
    /// If `x` points to nothing known yet, a fresh location is created for it.
    ///
    /// ```
    /// use graphs::Steensgaard;
    ///
    /// let mut s = Steensgaard::new();
    /// s.assign_addr("p", "x"); // p -> x
    /// s.deref_assign("p", "q"); // *p = q  -- x and q unify
    /// assert_eq!(s.points_to("x"), s.points_to("q"));
    /// ```
    pub fn deref_assign(&mut self, x: &str, y: &str) {
        let nx = self.declare(x);
        let ny = self.declare(y);
        let loc = self.target_or_fresh(nx);
        self.unify(loc, ny);
    }

    /// The points-to set of a variable: the names of the declared variables in the class of its target.
    /// An empty set means "points to nothing known".
    ///
    /// ```
    /// use graphs::Steensgaard;
    ///
    /// let mut s = Steensgaard::new();
    /// s.assign_addr("p", "x");
    /// assert_eq!(s.points_to("p"), vec!["x"]);
    /// assert!(s.points_to("x").is_empty());
    /// ```
    pub fn points_to(&mut self, name: &str) -> Vec<String> {
        let id = self.declare(name);
        let r = self.uf.find(id);
        match self.target[r] {
            None => Vec::new(),
            Some(t) => {
                let rt = self.uf.find(t);
                let mut out = Vec::new();
                for (i, nm) in self.names.iter().enumerate() {
                    if let Some(nm) = nm {
                        if self.uf.find(i) == rt {
                            out.push(nm.clone());
                        }
                    }
                }
                out.sort();
                out
            }
        }
    }

    /// The points-to sets of all declared variables, in declaration order: pairs (variable, set of variables it may point to).
    ///
    /// ```
    /// use graphs::Steensgaard;
    ///
    /// let mut s = Steensgaard::new();
    /// s.assign_addr("p", "x");
    /// s.assign_addr("q", "y");
    /// let sets = s.points_to_sets();
    /// assert_eq!(sets, vec![("p".to_string(), vec!["x".to_string()]),
    ///                        ("x".to_string(), Vec::new()),
    ///                        ("q".to_string(), vec!["y".to_string()]),
    ///                        ("y".to_string(), Vec::new())]);
    /// ```
    pub fn points_to_sets(&mut self) -> Vec<(String, Vec<String>)> {
        let names: Vec<String> = self.names.iter().filter_map(|nm| nm.clone()).collect();
        names
            .into_iter()
            .map(|name| {
                let set = self.points_to(&name);
                (name, set)
            })
            .collect()
    }

    /// Whether `x` and `y` may alias: they are the same storage, or their points-to sets overlap.
    /// Unification-based analysis answers "may", so a `true` here means the two variables could be the same memory in some run of the program.
    ///
    /// ```
    /// use graphs::Steensgaard;
    ///
    /// let mut s = Steensgaard::new();
    /// s.assign_addr("p", "x");
    /// s.assign_addr("q", "y");
    /// s.assign_copy("p", "q"); // merges x and y
    /// assert!(s.may_alias("p", "q")); // both point to the merged location
    /// assert!(s.may_alias("x", "y")); // x and y became one location
    /// assert!(!s.may_alias("p", "x"));
    /// ```
    pub fn may_alias(&mut self, x: &str, y: &str) -> bool {
        let nx = self.declare(x);
        let ny = self.declare(y);
        if self.uf.same(nx, ny) {
            return true;
        }
        // Points-to sets overlap?
        let px = self.points_to(x);
        let py = self.points_to(y);
        px.iter().any(|a| py.iter().any(|b| a == b))
    }

    /// The target of the representative of `node`, creating a fresh abstract location if the node points to nothing yet.
    fn target_or_fresh(&mut self, node: usize) -> usize {
        let r = self.uf.find(node);
        match self.target[r] {
            Some(t) => t,
            None => {
                let fresh = self.uf.push();
                self.names.push(None);
                self.target.push(None);
                self.target[r] = Some(fresh);
                fresh
            }
        }
    }

    /// Merge the classes of `a` and `b`, and merge their points-to targets the same way (recursively).
    fn unify(&mut self, a: usize, b: usize) {
        let ra = self.uf.find(a);
        let rb = self.uf.find(b);
        if ra == rb {
            return;
        }
        let ta = self.target[ra];
        let tb = self.target[rb];
        self.uf.union(ra, rb);
        let r = self.uf.find(ra);
        match (ta, tb) {
            (Some(x), Some(y)) => {
                self.unify(x, y);
                self.target[r] = Some(self.uf.find(x));
            }
            (Some(x), None) => self.target[r] = Some(x),
            (None, Some(y)) => self.target[r] = Some(y),
            (None, None) => self.target[r] = None,
        }
    }
}

impl Default for Steensgaard {
    fn default() -> Self {
        Steensgaard::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn addr_of_and_copy() {
        let mut s = Steensgaard::new();
        s.assign_addr("p", "x");
        s.assign_addr("q", "y");
        s.assign_copy("p", "q");
        // The two targets merged: p and q point to both.
        assert_eq!(s.points_to("p"), vec!["x", "y"]);
        assert_eq!(s.points_to("q"), vec!["x", "y"]);
        assert!(s.may_alias("p", "q"));
        assert!(s.may_alias("x", "y"));
        assert!(!s.may_alias("p", "x"));
    }

    #[test]
    fn load_through_pointer() {
        let mut s = Steensgaard::new();
        s.assign_addr("p", "x"); // p -> x
        s.assign_addr("x", "y"); // x -> y
        s.assign_deref("q", "p"); // q = *p = *x -> y
        assert_eq!(s.points_to("q"), vec!["y"]);
    }

    #[test]
    fn store_through_pointer() {
        let mut s = Steensgaard::new();
        s.assign_addr("p", "x"); // p -> x
        s.deref_assign("p", "q"); // *p = q  =>  x = q
        assert_eq!(s.points_to("x"), s.points_to("q"));
        assert!(s.may_alias("x", "q"));
    }

    #[test]
    fn later_constraints_flow_back() {
        // q = *p with p -> x, then x = &y: q must end up pointing to y.
        let mut s = Steensgaard::new();
        s.assign_addr("p", "x");
        s.assign_deref("q", "p");
        assert!(s.points_to("q").is_empty()); // nothing known yet
        s.assign_addr("x", "y");
        assert_eq!(s.points_to("q"), vec!["y"]);
    }

    #[test]
    fn program_run_equivalence() {
        let mut direct = Steensgaard::new();
        direct.assign_addr("p", "x");
        direct.assign_copy("q", "p");

        let mut via_run = Steensgaard::new();
        via_run.run(&[
            Stmt::AddrOf {
                x: "p".into(),
                y: "x".into(),
            },
            Stmt::Copy {
                x: "q".into(),
                y: "p".into(),
            },
        ]);
        assert_eq!(direct.points_to_sets(), via_run.points_to_sets());
    }

    #[test]
    fn repeated_declare_is_idempotent() {
        let mut s = Steensgaard::new();
        let a = s.declare("x");
        let b = s.declare("x");
        assert_eq!(a, b);
    }
}

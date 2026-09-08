//! Disjoint-set union (union-find / DSU).
//!
//! Keeps a partition of vertices into components and supports two operations: `find(x)` -- the representative of `x`'s component, `union(a, b)` -- merge the components of `a` and `b`.
//! Used by Kruskal's algorithm (minimum spanning tree) and by cycle detection in undirected graphs: an edge joining vertices already in one component -- means a cycle.

/// A partition of the set `{0, 1, ..., n-1}` into components.
///
/// ```
/// use graphs::UnionFind;
///
/// let mut uf = UnionFind::new(5);
/// assert!(!uf.same(0, 1));
/// uf.union(0, 1);
/// uf.union(2, 3);
/// uf.union(1, 2);
/// assert!(uf.same(0, 3));
/// assert!(!uf.same(0, 4));
/// ```
#[derive(Debug)]
pub struct UnionFind {
    /// `parent[x]` -- the parent of `x` in the representative forest.
    parent: Vec<usize>,
    /// `size[x]` -- the component size, if `x` is its representative.
    size: Vec<usize>,
}

impl UnionFind {
    /// A new partition: every vertex is its own component.
    ///
    /// ```
    /// use graphs::UnionFind;
    ///
    /// let mut uf = UnionFind::new(3);
    /// for i in 0..3 {
    ///     for j in 0..3 {
    ///         assert_eq!(uf.same(i, j), i == j);
    ///     }
    /// }
    /// ```
    pub fn new(n: usize) -> Self {
        UnionFind {
            parent: (0..n).collect(),
            size: vec![1; n],
        }
    }

    /// The representative of `x`'s component (with path compression).
    ///
    /// ```
    /// use graphs::UnionFind;
    ///
    /// let mut uf = UnionFind::new(4);
    /// uf.union(0, 1);
    /// uf.union(2, 3);
    /// uf.union(1, 3);
    /// let r = uf.find(0);
    /// assert_eq!(uf.find(1), r);
    /// assert_eq!(uf.find(2), r);
    /// assert_eq!(uf.find(3), r);
    /// ```
    pub fn find(&mut self, x: usize) -> usize {
        if self.parent[x] != x {
            self.parent[x] = self.find(self.parent[x]);
        }
        self.parent[x]
    }

    /// Merge the components of vertices `a` and `b`.
    ///
    /// Returns `false` if the vertices were already in one component (and nothing changed), and `true` if the components merged.
    ///
    /// ```
    /// use graphs::UnionFind;
    ///
    /// let mut uf = UnionFind::new(3);
    /// assert!(uf.union(0, 1));  // merged
    /// assert!(uf.union(1, 2));  // merged
    /// assert!(!uf.union(0, 2)); // already same component
    /// ```
    pub fn union(&mut self, a: usize, b: usize) -> bool {
        let ra = self.find(a);
        let rb = self.find(b);
        if ra == rb {
            return false;
        }
        // Hang the smaller component under the bigger one -- the tree stays shallow.
        if self.size[ra] < self.size[rb] {
            self.parent[ra] = rb;
            self.size[rb] += self.size[ra];
        } else {
            self.parent[rb] = ra;
            self.size[ra] += self.size[rb];
        }
        true
    }

    /// Whether vertices `a` and `b` are in one component.
    ///
    /// ```
    /// use graphs::UnionFind;
    ///
    /// let mut uf = UnionFind::new(3);
    /// assert!(!uf.same(0, 1));
    /// uf.union(0, 1);
    /// assert!(uf.same(0, 1));
    /// ```
    pub fn same(&mut self, a: usize, b: usize) -> bool {
        self.find(a) == self.find(b)
    }

    /// Add a new element as its own component.
    /// Returns its id.
    ///
    /// The structure grows by one: useful when the number of elements is not known in advance (for example, fresh locations in a pointer analysis).
    /// Existing ids stay valid.
    ///
    /// ```
    /// use graphs::UnionFind;
    ///
    /// let mut uf = UnionFind::new(2);
    /// let id = uf.push();
    /// assert_eq!(id, 2);
    /// uf.union(0, id);
    /// assert!(uf.same(0, 2));
    /// assert!(!uf.same(1, 2));
    /// ```
    pub fn push(&mut self) -> usize {
        let id = self.parent.len();
        self.parent.push(id);
        self.size.push(1);
        id
    }

    /// The equivalence classes of the current partition.
    ///
    /// Each class is a sorted list of element ids, and the classes themselves are ordered by their smallest element, so the result is deterministic.
    /// Runs in $O(n alpha(n))$.
    ///
    /// ```
    /// use graphs::UnionFind;
    ///
    /// let mut uf = UnionFind::new(6);
    /// uf.union(0, 1);
    /// uf.union(2, 3);
    /// uf.union(1, 2); // 0, 1, 2, 3 now form one class
    ///
    /// let classes = uf.classes();
    /// assert_eq!(classes, vec![vec![0, 1, 2, 3], vec![4], vec![5]]);
    /// ```
    pub fn classes(&mut self) -> Vec<Vec<usize>> {
        let n = self.parent.len();
        let mut by_root: Vec<Vec<usize>> = vec![Vec::new(); n];
        for x in 0..n {
            let r = self.find(x);
            by_root[r].push(x);
        }
        let mut classes: Vec<Vec<usize>> = by_root.into_iter().filter(|c| !c.is_empty()).collect();
        classes.sort_by_key(|c| c[0]);
        classes
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn initially_everything_is_separate() {
        let mut uf = UnionFind::new(5);
        for i in 0..5 {
            for j in 0..5 {
                assert_eq!(uf.same(i, j), i == j);
            }
        }
    }

    #[test]
    fn union_merges_components() {
        let mut uf = UnionFind::new(6);
        assert!(uf.union(0, 1));
        assert!(uf.union(2, 3));
        assert!(uf.union(1, 2));
        assert!(uf.same(0, 3));
        assert!(!uf.same(0, 4));
        assert!(!uf.union(0, 3)); // already in one component
    }

    #[test]
    fn find_is_representative_after_path_compression() {
        let mut uf = UnionFind::new(4);
        uf.union(0, 1);
        uf.union(2, 3);
        uf.union(1, 3);
        let r = uf.find(0);
        assert_eq!(uf.find(1), r);
        assert_eq!(uf.find(2), r);
        assert_eq!(uf.find(3), r);
    }

    #[test]
    fn push_grows_the_partition() {
        let mut uf = UnionFind::new(2);
        assert_eq!(uf.push(), 2);
        assert_eq!(uf.push(), 3);
        uf.union(0, 2);
        assert!(uf.same(0, 2));
        assert!(!uf.same(1, 2));
        assert!(!uf.same(3, 0));
    }

    #[test]
    fn classes_reflect_the_partition() {
        let mut uf = UnionFind::new(6);
        uf.union(0, 1);
        uf.union(2, 3);
        uf.union(1, 2);
        assert_eq!(uf.classes(), vec![vec![0, 1, 2, 3], vec![4], vec![5]]);
    }

    #[test]
    fn classes_after_push_include_the_new_elements() {
        let mut uf = UnionFind::new(3);
        uf.union(0, 1);
        let fresh = uf.push();
        uf.union(fresh, 2);
        assert_eq!(uf.classes(), vec![vec![0, 1], vec![2, 3]]);
    }
}

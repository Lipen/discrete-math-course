//! A general table-driven finite Heyting algebra.
//!
//! An [`Algebra`] is a finite lattice whose elements are numbered `0..n`, with meet, join and implication stored as lookup tables.
//! Everything is plain data: no traits, no generics, so the tables are directly printable and checkable.
//!
//! ```
//! use heyting::Algebra;
//!
//! // The four-element Boolean algebra on the subsets of {0, 1}.
//! let bool4 = heyting::bool_algebra(2);
//! assert_eq!(bool4.size(), 4);
//!
//! // In a Boolean algebra, double negation is the identity.
//! for a in 0..bool4.size() {
//!     assert_eq!(bool4.not(bool4.not(a)), a);
//! }
//! ```

/// A finite Heyting algebra given by operation tables.
///
/// `meet[a][b]`, `join[a][b]` and `implies[a][b]` are the results of `a ∧ b`, `a ∨ b` and `a -> b`.
/// `bottom` and `top` are the indices of `0` and `1`.
/// `labels` gives each element a human-readable name (e.g. the set it stands for in the downset construction).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Algebra {
    /// Number of elements: the elements are the indices `0..size`.
    pub size: usize,
    /// Meet table: `meet[a][b] = a ∧ b`.
    pub meet: Vec<Vec<usize>>,
    /// Join table: `join[a][b] = a ∨ b`.
    pub join: Vec<Vec<usize>>,
    /// Relative pseudo-complement: `implies[a][b] = a -> b`.
    pub implies: Vec<Vec<usize>>,
    /// Index of the bottom element `0`.
    pub bottom: usize,
    /// Index of the top element `1`.
    pub top: usize,
    /// Display name of each element, e.g. `"{a,b}"` in the downset algebra.
    pub labels: Vec<String>,
}

impl Algebra {
    /// Meet `a ∧ b`.
    pub fn meet(&self, a: usize, b: usize) -> usize {
        self.meet[a][b]
    }

    /// Join `a ∨ b`.
    pub fn join(&self, a: usize, b: usize) -> usize {
        self.join[a][b]
    }

    /// Relative pseudo-complement `a -> b`.
    pub fn implies(&self, a: usize, b: usize) -> usize {
        self.implies[a][b]
    }

    /// Negation `!a = a -> 0`.
    pub fn not(&self, a: usize) -> usize {
        self.implies(a, self.bottom)
    }

    /// Number of elements.
    pub fn size(&self) -> usize {
        self.size
    }

    /// Is `a <= b` in the lattice order?
    ///
    /// In a lattice `a <= b` iff `a ∧ b = a`, so the meet table decides.
    pub fn leq(&self, a: usize, b: usize) -> bool {
        self.meet(a, b) == a
    }

    /// Does this algebra satisfy the Boolean law `¬¬a = a` for every `a`?
    pub fn is_boolean(&self) -> bool {
        (0..self.size).all(|a| self.not(self.not(a)) == a)
    }

    /// Build an algebra from meet and join tables, deriving implication.
    ///
    /// The tables must describe a finite distributive lattice, which is not checked.
    /// The implication is forced by the Heyting adjunction: `a -> b` is the join of all `c` with `a ∧ c <= b`.
    /// In a finite distributive lattice this join is the unique largest such `c`, so the result is a Heyting algebra.
    ///
    /// ```
    /// use heyting::Algebra;
    ///
    /// // The two-element Boolean algebra: elements 0 = false, 1 = true.
    /// let meet = vec![vec![0, 0], vec![0, 1]];
    /// let join = vec![vec![0, 1], vec![1, 1]];
    /// let a = Algebra::from_meet_join("bool2", meet, join, vec!["0".into(), "1".into()]);
    /// assert_eq!(a.implies(1, 0), 0); // true -> false = false
    /// assert_eq!(a.not(a.not(0)), 0);
    /// ```
    pub fn from_meet_join(
        name: &str,
        meet: Vec<Vec<usize>>,
        join: Vec<Vec<usize>>,
        labels: Vec<String>,
    ) -> Algebra {
        let size = meet.len();
        let bottom = (0..size).fold(0, |acc, a| meet[acc][a]);
        let top = (0..size).fold(0, |acc, a| join[acc][a]);

        // a -> b = join of all c with a ∧ c <= b.
        let mut implies = vec![vec![0; size]; size];
        for a in 0..size {
            for b in 0..size {
                let mut out = 0;
                let mut any = false;
                for c in 0..size {
                    // meet(a, c) <= b, i.e. meet(meet(a, c), b) == meet(a, c).
                    if meet[meet[a][c]][b] == meet[a][c] {
                        out = join[out][c];
                        any = true;
                    }
                }
                debug_assert!(any, "the join over c is never empty: b itself qualifies");
                implies[a][b] = out;
            }
        }

        let _ = name;
        Algebra {
            size,
            meet,
            join,
            implies,
            bottom,
            top,
            labels,
        }
    }
}

/// The canonical example: the three-element chain `{0, 1/2, 1}` as a table algebra.
///
/// It is the downset algebra of the two-element chain `a < b`: the ideals are `∅`, `{a}` and `{a, b}`, which play the roles of `Bot`, `Mid` and `Top`.
/// This algebra is exactly the algebra of [`crate::Value`]: the same three elements with the same meet, join and implication tables.
///
/// ```
/// use heyting::{chain_three, Value};
///
/// let a = chain_three();
/// assert_eq!(a.size(), 3);
///
/// // The tables agree with the Value-based operations.
/// let v = |x: usize| match x { 0 => Value::Bot, 1 => Value::Mid, _ => Value::Top };
/// for x in 0..3 {
///     for y in 0..3 {
///         assert_eq!(a.meet(x, y) as i32, v(x).meet(v(y)) as i32);
///         assert_eq!(a.join(x, y) as i32, v(x).join(v(y)) as i32);
///         assert_eq!(a.implies(x, y) as i32, v(x).implies(v(y)) as i32);
///     }
/// }
/// ```
pub fn chain_three() -> Algebra {
    // Two-element chain a < b; its ideals are {}, {a}, {a,b} = Bot, Mid, Top.
    let poset = crate::poset::Poset::from_relations(2, &[(0, 1)]);
    let mut a = poset.downset_algebra();
    a.labels = vec!["Bot".into(), "Mid".into(), "Top".into()];
    a
}

/// The Boolean algebra of all subsets of an `n`-element set.
///
/// The elements are the subsets of `{0, 1, ..., n-1}` (up to `2^n` of them, so keep `n` small).
/// Meet is intersection, join is union, and implication is `¬a ∨ b`, derived from the lattice by [`Algebra::from_meet_join`].
/// For `n = 1` this is the two-element Boolean algebra `{0, 1}`, and for `n = 2` the four-element one.
///
/// ```
/// use heyting::bool_algebra;
///
/// let b = bool_algebra(2); // subsets of {0, 1}: 4 elements
/// assert_eq!(b.size(), 4);
/// assert!(b.is_boolean());
///
/// // Excluded middle holds in every Boolean algebra.
/// let lem = |a: usize| b.join(a, b.not(a));
/// for a in 0..4 {
///     assert_eq!(lem(a), b.top);
/// }
/// ```
pub fn bool_algebra(n: usize) -> Algebra {
    let count = 1usize << n;
    let labels: Vec<String> = (0..count).map(|mask| format_subset(mask, n)).collect();
    let index_of: Vec<usize> = (0..count).collect();

    let mut meet = vec![vec![0; count]; count];
    let mut join = vec![vec![0; count]; count];
    for a in 0..count {
        for b in 0..count {
            meet[a][b] = index_of[a & b];
            join[a][b] = index_of[a | b];
        }
    }

    Algebra::from_meet_join(&format!("bool({n})"), meet, join, labels)
}

/// Render a subset of `{0..n-1}` as `"{1,3}"` (empty set as `"{}"`).
pub(crate) fn format_subset(mask: usize, n: usize) -> String {
    let mut s = String::from("{");
    let mut first = true;
    for i in 0..n {
        if mask & (1 << i) != 0 {
            if !first {
                s.push(',');
            }
            first = false;
            s.push_str(&i.to_string());
        }
    }
    s.push('}');
    s
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::Value;

    #[test]
    fn chain_three_matches_value() {
        let a = chain_three();
        assert_eq!(a.size(), 3);
        let v = |x: usize| match x {
            0 => Value::Bot,
            1 => Value::Mid,
            _ => Value::Top,
        };
        for x in 0..3 {
            for y in 0..3 {
                assert_eq!(a.meet(x, y), v(x).meet(v(y)) as usize);
                assert_eq!(a.join(x, y), v(x).join(v(y)) as usize);
                assert_eq!(a.implies(x, y), v(x).implies(v(y)) as usize);
            }
        }
        // Element order in the chain: Bot < Mid < Top.
        assert_eq!(a.bottom, 0);
        assert_eq!(a.top, 2);
    }

    #[test]
    fn bool_algebra_is_boolean() {
        for n in 0..=3 {
            let b = bool_algebra(n);
            assert_eq!(b.size(), 1 << n);
            assert!(b.is_boolean());
            for a in 0..b.size() {
                assert_eq!(b.join(a, b.not(a)), b.top);
                assert_eq!(b.meet(a, b.not(a)), b.bottom);
            }
        }
    }

    #[test]
    fn bool2_tables_are_classical() {
        // Elements 0 = {}, 1 = {0}, 2 = {1}, 3 = {0,1}.
        let b = bool_algebra(2);
        assert_eq!(b.meet(3, 1), 1); // {0,1} ∩ {0}
        assert_eq!(b.join(1, 2), 3); // {0} ∪ {1}
        assert_eq!(b.implies(1, 2), b.not(1)); // {0} -> {1} = ¬{0} = {1}
        assert_eq!(b.not(0), 3);
        assert_eq!(b.not(3), 0);
    }

    #[test]
    fn from_meet_join_derives_heyting_implication() {
        // The 3-element chain 0 < 1 < 2: meet = min, join = max.
        let meet = vec![vec![0, 0, 0], vec![0, 1, 1], vec![0, 1, 2]];
        let join = vec![vec![0, 1, 2], vec![1, 1, 2], vec![2, 2, 2]];
        let a = Algebra::from_meet_join(
            "chain3",
            meet,
            join,
            vec!["0".into(), "1".into(), "2".into()],
        );
        // Implication of the chain: a -> b = top when a <= b, else b.
        assert_eq!(a.implies(1, 0), 0);
        assert_eq!(a.implies(2, 1), 1);
        assert_eq!(a.implies(0, 1), 2);
        assert_eq!(a.implies(1, 2), 2);
        assert_eq!(a.not(1), 0); // ¬1/2 = 0 in the chain
        assert!(!a.is_boolean());
    }

    #[test]
    fn implies_satisfies_adjunction() {
        // For every pair (a, b): a ∧ (a -> b) <= b and a -> b is the largest
        // such element: c <= a -> b iff a ∧ c <= b.
        for (name, a) in [
            ("chain3", chain_three()),
            ("bool2", bool_algebra(2)),
            ("bool3", bool_algebra(3)),
        ] {
            for x in 0..a.size() {
                for y in 0..a.size() {
                    let ab = a.implies(x, y);
                    assert!(a.leq(a.meet(x, ab), y), "{name}: a∧(a->b) <= b");
                    for c in 0..a.size() {
                        if a.leq(a.meet(x, c), y) {
                            assert!(a.leq(c, ab), "{name}: c <= a->b for every c with a∧c <= b");
                        }
                    }
                }
            }
        }
    }

    #[test]
    fn leq_reflects_meet() {
        let b = bool_algebra(2);
        // {0} <= {0,1} because {0} ∩ {0,1} = {0}.
        assert!(b.leq(1, 3));
        assert!(!b.leq(2, 1));
        assert!(b.leq(0, b.top));
        assert!(b.leq(b.bottom, 3));
    }
}

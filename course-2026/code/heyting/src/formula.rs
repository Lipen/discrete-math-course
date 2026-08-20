//! A tiny propositional formula type evaluated in finite Heyting algebras.
//!
//! Formulas are built from atoms (numbered `0, 1, 2, ...`) with the
//! connectives `∧`, `∨`, `->`, `¬` and the constants `⊤`, `⊥`.  A formula is
//! evaluated in an [`Algebra`] under a **valuation**: a choice of one element
//! for every atom.
//!
//! ```
//! use heyting::{Formula, chain_three};
//!
//! let a = chain_three(); // the three-element chain {0, 1/2, 1}
//! let p = Formula::atom(0);
//! let lem = p.clone().or(!p.clone()); // p ∨ ¬p
//!
//! // At the valuation p = 1/2 (element 1) excluded middle gives 1/2, not 1.
//! assert_eq!(lem.eval(&a, &[1]), 1);
//! assert_ne!(lem.eval(&a, &[1]), a.top);
//! ```

use crate::Algebra;

/// A propositional formula over atoms `0, 1, 2, ...`.
///
/// The type is intentionally tiny: atoms plus `∧`, `∨`, `->`, `¬`, `⊤`, `⊥`.
/// Formulas are compared structurally, so equal formulas are equal values.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum Formula {
    /// A propositional atom, identified by its number.
    Atom(usize),
    /// Truth `⊤`.
    Top,
    /// Falsehood `⊥`.
    Bottom,
    /// Conjunction `a ∧ b`.
    And(Box<Formula>, Box<Formula>),
    /// Disjunction `a ∨ b`.
    Or(Box<Formula>, Box<Formula>),
    /// Implication `a -> b`.
    Implies(Box<Formula>, Box<Formula>),
    /// Negation `¬a`.
    Not(Box<Formula>),
}

impl Formula {
    /// The atom `i`.
    ///
    /// ```
    /// use heyting::Formula;
    ///
    /// let p = Formula::atom(0);
    /// let q = Formula::atom(1);
    /// let f = p.implies(q); // p -> q
    /// assert_eq!(f.atom_count(), 2);
    /// ```
    pub fn atom(i: usize) -> Formula {
        Formula::Atom(i)
    }

    /// Truth `⊤`.
    pub fn top() -> Formula {
        Formula::Top
    }

    /// Falsehood `⊥`.
    pub fn bottom() -> Formula {
        Formula::Bottom
    }

    /// Conjunction `self ∧ other`.
    pub fn and(self, other: Formula) -> Formula {
        Formula::And(Box::new(self), Box::new(other))
    }

    /// Disjunction `self ∨ other`.
    pub fn or(self, other: Formula) -> Formula {
        Formula::Or(Box::new(self), Box::new(other))
    }

    /// Implication `self -> other`.
    pub fn implies(self, other: Formula) -> Formula {
        Formula::Implies(Box::new(self), Box::new(other))
    }

    /// Negation `¬self` (also available as the `!` operator).
    ///
    /// The name deliberately echoes [`std::ops::Not`]; use `!f` for the
    /// operator form.
    #[allow(clippy::should_implement_trait)] // `not` is the teaching name, like `Value::not`
    pub fn not(self) -> Formula {
        Formula::Not(Box::new(self))
    }

    /// Evaluate the formula in an algebra under a valuation.
    ///
    /// `valuation[i]` is the element assigned to atom `i` (atoms used by the
    /// formula must be covered by the valuation slice).
    ///
    /// ```
    /// use heyting::{Formula, bool_algebra};
    ///
    /// let b = bool_algebra(1); // two-element Boolean algebra {0, 1}
    /// let p = Formula::atom(0);
    /// let lem = p.clone().or(!p);
    ///
    /// // Excluded middle is true under both valuations.
    /// assert_eq!(lem.eval(&b, &[0]), b.top);
    /// assert_eq!(lem.eval(&b, &[1]), b.top);
    /// ```
    pub fn eval(&self, a: &Algebra, valuation: &[usize]) -> usize {
        match self {
            Formula::Atom(i) => valuation[*i],
            Formula::Top => a.top,
            Formula::Bottom => a.bottom,
            Formula::And(x, y) => a.meet(x.eval(a, valuation), y.eval(a, valuation)),
            Formula::Or(x, y) => a.join(x.eval(a, valuation), y.eval(a, valuation)),
            Formula::Implies(x, y) => a.implies(x.eval(a, valuation), y.eval(a, valuation)),
            Formula::Not(x) => a.not(x.eval(a, valuation)),
        }
    }

    /// The number of atoms used by the formula (one more than the largest
    /// atom index, or 0 for a formula without atoms).
    ///
    /// ```
    /// use heyting::Formula;
    ///
    /// let f = Formula::atom(2).implies(Formula::atom(0));
    /// assert_eq!(f.atom_count(), 3);
    /// ```
    pub fn atom_count(&self) -> usize {
        match self {
            Formula::Atom(i) => i + 1,
            Formula::Top | Formula::Bottom => 0,
            Formula::And(x, y) | Formula::Or(x, y) | Formula::Implies(x, y) => {
                x.atom_count().max(y.atom_count())
            }
            Formula::Not(x) => x.atom_count(),
        }
    }
}

/// Negation: `!f = f -> ⊥`.
///
/// ```
/// use heyting::Formula;
///
/// let p = Formula::atom(0);
/// assert_eq!((!p.clone()).not(), p.clone().not().not());
/// ```
impl std::ops::Not for Formula {
    type Output = Formula;

    fn not(self) -> Formula {
        Formula::Not(Box::new(self))
    }
}

/// All valuations of `n` atoms in an algebra of `size` elements.
///
/// Each valuation is a slice of `n` element indices; the iterator yields them
/// in lexicographic order (atom 0 varying slowest).  Use it to check a
/// formula under every valuation.
///
/// ```
/// use heyting::{Formula, chain_three, all_valuations};
///
/// let a = chain_three();
/// let p = Formula::atom(0);
/// let lem = p.clone().or(!p);
///
/// // 3^1 = 3 valuations; at p = 1/2 excluded middle gives 1/2, not 1.
/// let hits: Vec<usize> = all_valuations(1, a.size())
///     .map(|v| lem.eval(&a, &v))
///     .collect();
/// assert_eq!(hits, vec![a.top, 1, a.top]);
/// ```
pub fn all_valuations(n_atoms: usize, size: usize) -> impl Iterator<Item = Vec<usize>> {
    let total = size.pow(n_atoms as u32);
    (0..total).map(move |k| {
        let mut v = vec![0usize; n_atoms];
        let mut x = k;
        // Atom 0 is the slowest-varying digit, atom n-1 the fastest.
        for slot in v.iter_mut().rev() {
            *slot = x % size;
            x /= size;
        }
        v
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::{bool_algebra, chain_three};

    #[test]
    fn eval_matches_connectives() {
        let a = chain_three();
        let p = Formula::atom(0);
        let q = Formula::atom(1);

        // p ∧ q at (1, 2) = meet(1, 2) = 1; p -> q at (2, 0) = 0.
        assert_eq!(p.clone().and(q.clone()).eval(&a, &[1, 2]), a.meet(1, 2));
        assert_eq!(p.clone().implies(q.clone()).eval(&a, &[2, 0]), 0);
        assert_eq!(Formula::top().eval(&a, &[]), a.top);
        assert_eq!(Formula::bottom().eval(&a, &[]), a.bottom);
    }

    #[test]
    fn excluded_middle_fails_in_chain_but_holds_in_boolean() {
        let chain = chain_three();
        let bool2 = bool_algebra(1);
        let p = Formula::atom(0);
        let lem = p.clone().or(!p);

        // In the chain, valuation p = 1/2 gives 1/2 ≠ top.
        assert_ne!(lem.eval(&chain, &[1]), chain.top);
        // In the two-element Boolean algebra, always top.
        assert_eq!(lem.eval(&bool2, &[0]), bool2.top);
        assert_eq!(lem.eval(&bool2, &[1]), bool2.top);
    }

    #[test]
    fn atom_count_ignores_repetition() {
        let f = Formula::atom(0).implies(Formula::atom(2).or(Formula::atom(2)));
        assert_eq!(f.atom_count(), 3);
        assert_eq!(Formula::top().atom_count(), 0);
    }

    #[test]
    fn valuations_exhaust_all_assignments() {
        let vs: Vec<Vec<usize>> = all_valuations(2, 3).collect();
        assert_eq!(vs.len(), 9);
        assert_eq!(vs[0], vec![0, 0]);
        assert_eq!(vs[8], vec![2, 2]);
        // Atom 1 varies fastest, atom 0 slowest.
        assert_eq!(vs[1], vec![0, 1]);
        assert_eq!(vs[3], vec![1, 0]);
        assert_eq!(vs[4], vec![1, 1]);
    }
}

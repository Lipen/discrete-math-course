//! A logic program: a database of clauses.
//!
//! Clauses are indexed by the predicate of their head, so that a goal is resolved only against the clauses that can possibly prove it.

use std::collections::HashMap;

use crate::clause::Clause;
use crate::term::Term;

/// A logic program: clauses indexed by the predicate of their head.
///
/// The index key is `(name, arity)`: an atom `p` has arity 0, a structure
/// `parent(alice, bob)` has arity 2. Clauses are kept in the order they
/// were added, because the solver tries them in program order.
///
/// ```
/// use prolog::term::Term;
/// use prolog::clause::Clause;
/// use prolog::database::Database;
///
/// let mut db = Database::new();
/// db.add(Clause::fact(Term::struct_("parent", vec![Term::atom("a"), Term::atom("b")])));
/// db.add(Clause::fact(Term::struct_("parent", vec![Term::atom("b"), Term::atom("c")])));
///
/// let goal = Term::struct_("parent", vec![Term::var(0), Term::var(1)]);
/// assert_eq!(db.clauses_for(&goal).map(|c| c.len()), Some(2));
/// ```
#[derive(Debug, Clone, Default)]
pub struct Database {
    clauses: HashMap<(String, usize), Vec<Clause>>,
}

impl Database {
    /// An empty program.
    ///
    /// ```
    /// use prolog::database::Database;
    /// let db = Database::new();
    /// assert!(db.is_empty());
    /// ```
    pub fn new() -> Self {
        Database::default()
    }

    /// Add a clause, indexed by the predicate of its head.
    ///
    /// A clause whose head is a variable has no predicate and is ignored:
    /// it could never be selected.
    ///
    /// ```
    /// use prolog::term::Term;
    /// use prolog::clause::Clause;
    /// use prolog::database::Database;
    ///
    /// let mut db = Database::new();
    /// db.add(Clause::fact(Term::atom("alice")));
    /// assert_eq!(db.len(), 1);
    /// ```
    pub fn add(&mut self, clause: Clause) {
        if let Some(key) = predicate_key(&clause.head) {
            self.clauses.entry(key).or_default().push(clause);
        }
    }

    /// The clauses whose head predicate matches `term`, in program order.
    ///
    /// Returns `None` when `term` is a variable (no predicate) or when no
    /// clause matches.
    ///
    /// ```
    /// use prolog::term::Term;
    /// use prolog::database::Database;
    ///
    /// let db = Database::new();
    /// assert!(db.clauses_for(&Term::var(0)).is_none());
    /// ```
    pub fn clauses_for(&self, term: &Term) -> Option<&[Clause]> {
        predicate_key(term).and_then(|key| self.clauses.get(&key).map(Vec::as_slice))
    }

    /// The number of clauses in the program.
    ///
    /// ```
    /// use prolog::term::Term;
    /// use prolog::clause::Clause;
    /// use prolog::database::Database;
    ///
    /// let mut db = Database::new();
    /// db.add(Clause::fact(Term::atom("a")));
    /// db.add(Clause::fact(Term::atom("b")));
    /// assert_eq!(db.len(), 2);
    /// ```
    pub fn len(&self) -> usize {
        self.clauses.values().map(Vec::len).sum()
    }

    /// Whether the program has no clauses.
    ///
    /// ```
    /// use prolog::database::Database;
    /// assert!(Database::new().is_empty());
    /// ```
    pub fn is_empty(&self) -> bool {
        self.clauses.is_empty()
    }
}

/// The predicate `(name, arity)` of a term, if it has one.
///
/// Variables have no predicate: they cannot name a goal.
fn predicate_key(term: &Term) -> Option<(String, usize)> {
    match term {
        Term::Atom(name) => Some((name.clone(), 0)),
        Term::Struct(name, args) => Some((name.clone(), args.len())),
        Term::Var(_) => None,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn same_predicate_shares_a_bucket() {
        let mut db = Database::new();
        db.add(Clause::fact(Term::struct_("p", vec![Term::atom("a")])));
        db.add(Clause::fact(Term::struct_("p", vec![Term::atom("b")])));
        db.add(Clause::fact(Term::atom("q")));
        assert_eq!(db.len(), 3);
        let goal = Term::struct_("p", vec![Term::var(0)]);
        assert_eq!(db.clauses_for(&goal).map(|c| c.len()), Some(2));
        assert_eq!(db.clauses_for(&Term::atom("q")).map(|c| c.len()), Some(1));
    }

    #[test]
    fn variable_head_is_ignored() {
        let mut db = Database::new();
        db.add(Clause::fact(Term::var(0)));
        assert!(db.is_empty());
    }

    #[test]
    fn program_order_is_preserved() {
        let mut db = Database::new();
        db.add(Clause::fact(Term::struct_("p", vec![Term::atom("first")])));
        db.add(Clause::fact(Term::struct_("p", vec![Term::atom("second")])));
        let goal = Term::struct_("p", vec![Term::var(0)]);
        let clauses = db.clauses_for(&goal).unwrap();
        assert_eq!(clauses[0].head.to_string(), "p(first)");
        assert_eq!(clauses[1].head.to_string(), "p(second)");
    }
}

//! Definite clauses: facts and rules.
//!
//! A logic program is a finite set of clauses.
//! A clause is either a fact, `head.`, or a rule, `head :- body.`.
//! Logically every clause is a universally quantified Horn clause, and operationally a clause says "to prove the head, prove the body".

use std::fmt::{self, Display};

use crate::goal::Goal;
use crate::term::Term;

/// A definite clause: a fact or a rule.
///
/// A fact `parent(alice, bob).` has an empty body.
/// A rule `ancestor(X, Y) :- parent(X, Y).` proves its head whenever its body holds.
/// Variables are shared between head and body: the rule above says "if there are `X` and `Y` with `parent(X, Y)`, then `ancestor(X, Y)`".
/// ```
/// use prolog::term::Term;
/// use prolog::goal::Goal;
/// use prolog::clause::Clause;
///
/// let fact = Clause::fact(Term::struct_("parent", vec![Term::atom("a"), Term::atom("b")]));
/// assert_eq!(fact.to_string(), "parent(a, b).");
///
/// let rule = Clause::rule(
///     Term::struct_("ancestor", vec![Term::var(0), Term::var(1)]),
///     Goal::call(Term::struct_("parent", vec![Term::var(0), Term::var(1)])),
/// );
/// assert_eq!(rule.to_string(), "ancestor(_0, _1) :- parent(_0, _1).");
/// ```
#[derive(Debug, Clone)]
pub struct Clause {
    /// The head: the atom the clause proves.
    pub head: Term,
    /// The body: goals that must hold for the head to hold.
    pub body: Goal,
}

impl Clause {
    /// A fact: a head with no body.
    ///
    /// ```
    /// use prolog::term::Term;
    /// use prolog::clause::Clause;
    /// let c = Clause::fact(Term::atom("alice"));
    /// assert!(c.body.is_empty());
    /// ```
    pub fn fact(head: Term) -> Self {
        Clause {
            head,
            body: Goal::True,
        }
    }

    /// A rule: a head implied by a body.
    ///
    /// ```
    /// use prolog::term::Term;
    /// use prolog::goal::Goal;
    /// use prolog::clause::Clause;
    /// let c = Clause::rule(
    ///     Term::struct_("p", vec![Term::var(0)]),
    ///     Goal::call(Term::struct_("q", vec![Term::var(0)])),
    /// );
    /// assert_eq!(c.to_string(), "p(_0) :- q(_0).");
    /// ```
    pub fn rule(head: Term, body: Goal) -> Self {
        Clause { head, body }
    }
}

impl Display for Clause {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match &self.body {
            Goal::True => write!(f, "{}.", self.head),
            body => write!(f, "{} :- {}.", self.head, body),
        }
    }
}

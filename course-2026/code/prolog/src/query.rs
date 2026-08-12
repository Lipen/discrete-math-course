//! Queries: a goal together with names for the answer variables.
//!
//! A query is what a user runs against a logic program. The solver answers
//! with substitutions; a query knows how to render a substitution as an
//! answer line like `X = alice, Y = bob`.

use std::fmt::{self, Display};

use crate::goal::Goal;
use crate::subst::{apply, Subst};
use crate::term::Term;

/// A query: a goal to prove and names for its answer variables.
///
/// A query `?- ancestor(X, Y).` is written with the goal
/// `Call(ancestor(_0, _1))` and the variables `[(0, "X"), (1, "Y")]`.
///
/// ```
/// use prolog::term::Term;
/// use prolog::goal::Goal;
/// use prolog::query::Query;
/// use prolog::subst::Subst;
///
/// let query = Query::new(
///     Goal::call(Term::struct_("parent", vec![Term::var(0), Term::var(1)])),
///     vec![(0, "X"), (1, "Y")],
/// );
/// assert_eq!(query.to_string(), "?- parent(_0, _1).");
///
/// let mut subst = Subst::new();
/// subst.insert(0, Term::atom("alice"));
/// subst.insert(1, Term::atom("bob"));
/// assert_eq!(query.answer(&subst), "X = alice, Y = bob");
/// ```
#[derive(Debug, Clone)]
pub struct Query {
    /// The goal to solve.
    pub goal: Goal,
    /// Answer variables in display order: `(variable id, name)`.
    pub vars: Vec<(usize, String)>,
}

impl Query {
    /// A new query with named answer variables.
    ///
    /// ```
    /// use prolog::term::Term;
    /// use prolog::goal::Goal;
    /// use prolog::query::Query;
    /// let q = Query::new(Goal::call(Term::var(0)), vec![(0, "X")]);
    /// assert_eq!(q.vars.len(), 1);
    /// ```
    pub fn new(goal: Goal, vars: Vec<(usize, &str)>) -> Self {
        Query {
            goal,
            vars: vars
                .into_iter()
                .map(|(id, name)| (id, name.to_string()))
                .collect(),
        }
    }

    /// Render one answer (a solution substitution) as `X = alice, Y = bob`.
    ///
    /// An unbound variable renders as its bare name; a query with no
    /// variables renders as `true`.
    ///
    /// ```
    /// use prolog::term::Term;
    /// use prolog::goal::Goal;
    /// use prolog::query::Query;
    /// use prolog::subst::Subst;
    ///
    /// let q = Query::new(Goal::call(Term::atom("p")), vec![]);
    /// assert_eq!(q.answer(&Subst::new()), "true");
    /// ```
    pub fn answer(&self, subst: &Subst) -> String {
        let mut parts = Vec::new();
        for (id, name) in &self.vars {
            match apply(&Term::var(*id), subst) {
                Term::Var(_) => parts.push(name.clone()),
                value => parts.push(format!("{} = {}", name, value)),
            }
        }
        if parts.is_empty() {
            "true".to_string()
        } else {
            parts.join(", ")
        }
    }
}

impl Display for Query {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "?- {}.", self.goal)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn unbound_variable_renders_bare() {
        let q = Query::new(Goal::call(Term::atom("p")), vec![(0, "X")]);
        assert_eq!(q.answer(&Subst::new()), "X");
    }

    #[test]
    fn answer_resolves_through_chains() {
        let mut subst = Subst::new();
        subst.insert(0, Term::var(1));
        subst.insert(1, Term::atom("alice"));
        let q = Query::new(Goal::call(Term::atom("p")), vec![(0, "X")]);
        assert_eq!(q.answer(&subst), "X = alice");
    }
}

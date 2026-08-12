//! Standardizing clauses apart.
//!
//! A clause used in a proof must not share variable ids with the goals it
//! is matched against, or with other uses of the same clause. Renaming
//! gives every variable of a clause a fresh id before it is unified with a
//! goal.

use std::collections::HashMap;

use crate::clause::Clause;
use crate::goal::Goal;
use crate::term::Term;

/// Standardize a clause apart: give every variable a fresh id.
///
/// The head and the body are renamed together, so shared variables keep
/// sharing: `ancestor(_0, _1) :- parent(_0, _1)` stays coherent under
/// renaming. `fresh` is a running counter that must not be reused between
/// renamings.
///
/// ```
/// use prolog::term::Term;
/// use prolog::goal::Goal;
/// use prolog::clause::Clause;
/// use prolog::rename::rename_clause;
///
/// let clause = Clause::rule(
///     Term::struct_("ancestor", vec![Term::var(0), Term::var(1)]),
///     Goal::call(Term::struct_("parent", vec![Term::var(0), Term::var(1)])),
/// );
/// let mut fresh = 5;
/// let renamed = rename_clause(&clause, &mut fresh);
/// // Variable ids were shifted above the query's variables, but the
/// // sharing between head and body is preserved.
/// let head_vars = renamed.head.vars();
/// let body_vars = match renamed.body {
///     Goal::Call(t) => t.vars(),
///     _ => unreachable!(),
/// };
/// assert_eq!(head_vars, body_vars);
/// assert!(head_vars[0] >= 5);
/// assert_eq!(fresh, 7);
/// ```
pub fn rename_clause(clause: &Clause, fresh: &mut usize) -> Clause {
    let mut mapping = HashMap::new();
    let head = rename_term(&clause.head, &mut mapping, fresh);
    let body = rename_goal(&clause.body, &mut mapping, fresh);
    Clause { head, body }
}

/// Rename the variables of a term, remembering the mapping in `mapping`.
///
/// Every distinct source id is assigned a fresh id once; later occurrences
/// of the same source id reuse it.
fn rename_term(term: &Term, mapping: &mut HashMap<usize, usize>, fresh: &mut usize) -> Term {
    match term {
        Term::Var(id) => {
            let new_id = *mapping.entry(*id).or_insert_with(|| {
                let assigned = *fresh;
                *fresh += 1;
                assigned
            });
            Term::Var(new_id)
        }
        Term::Struct(functor, args) => {
            let new_args = args
                .iter()
                .map(|arg| rename_term(arg, mapping, fresh))
                .collect();
            Term::Struct(functor.clone(), new_args)
        }
        Term::Atom(_) => term.clone(),
    }
}

/// Rename the variables of a goal, sharing the mapping with the head.
fn rename_goal(goal: &Goal, mapping: &mut HashMap<usize, usize>, fresh: &mut usize) -> Goal {
    match goal {
        Goal::True => Goal::True,
        Goal::Call(term) => Goal::Call(rename_term(term, mapping, fresh)),
        Goal::Conj(goals) => Goal::Conj(
            goals
                .iter()
                .map(|g| rename_goal(g, mapping, fresh))
                .collect(),
        ),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn constants_and_atoms_are_untouched() {
        let clause = Clause::fact(Term::struct_(
            "parent",
            vec![Term::atom("a"), Term::atom("b")],
        ));
        let mut fresh = 0;
        let renamed = rename_clause(&clause, &mut fresh);
        assert_eq!(renamed.head, clause.head);
        assert_eq!(fresh, 0);
    }

    #[test]
    fn renames_distinct_variables_distinctly() {
        let clause = Clause::rule(
            Term::struct_("p", vec![Term::var(0), Term::var(1)]),
            Goal::call(Term::struct_("q", vec![Term::var(2)])),
        );
        let mut fresh = 10;
        let renamed = rename_clause(&clause, &mut fresh);
        let mut ids = renamed.head.vars();
        ids.sort();
        assert_eq!(ids, vec![10, 11]);
        // The body variable _2 is renamed too, so three ids are consumed.
        assert_eq!(fresh, 13);
    }
}

//! The SLD search, traced: goals tried, clauses selected, answers found.
//!
//! The solver records the search as a flat transcript: each `call` is an
//! atomic goal the solver tried to prove, each `select` is a clause whose
//! head unified with that goal, and each `solution` closes a successful
//! branch. Reading the transcript as a tree shows where the search
//! branches (one `select` per matching clause) and where it backtracks
//! (the branch that dies leaves the alternatives on the stack).
//!
//! Run with `cargo run -p prolog --example sld_trace`.

use prolog::clause::Clause;
use prolog::database::Database;
use prolog::goal::Goal;
use prolog::solver::{Solver, TraceEvent};
use prolog::term::Term;

fn parent(a: &str, b: &str) -> Term {
    Term::struct_("parent", vec![Term::atom(a), Term::atom(b)])
}

fn main() {
    let mut db = Database::new();
    db.add(Clause::fact(parent("alice", "bob")));
    db.add(Clause::fact(parent("bob", "carol")));

    // ancestor(X, Y) :- parent(X, Y).
    db.add(Clause::rule(
        Term::struct_("ancestor", vec![Term::var(0), Term::var(1)]),
        Goal::call(Term::struct_("parent", vec![Term::var(0), Term::var(1)])),
    ));
    // ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).
    db.add(Clause::rule(
        Term::struct_("ancestor", vec![Term::var(0), Term::var(1)]),
        Goal::conj(vec![
            Goal::call(Term::struct_("parent", vec![Term::var(0), Term::var(2)])),
            Goal::call(Term::struct_("ancestor", vec![Term::var(2), Term::var(1)])),
        ]),
    ));

    // ?- ancestor(alice, Y).
    let goal = Goal::call(Term::struct_(
        "ancestor",
        vec![Term::atom("alice"), Term::var(0)],
    ));
    println!("query: ?- ancestor(alice, _0).\n");

    let (answers, events) = Solver::new(db).solve_traced(&goal, 10);
    for event in &events {
        match event {
            TraceEvent::Call(term) => println!("call     {}", term),
            TraceEvent::Select(head) => println!("  select {}", head),
            TraceEvent::Solution(subst) => println!("  => answer: {}", format_subst(subst)),
        }
    }
    println!("\n{} answers", answers.len());
}

fn format_subst(subst: &prolog::Subst) -> String {
    let mut ids: Vec<usize> = subst.keys().copied().collect();
    ids.sort();
    ids.iter()
        .map(|id| format!("_{} = {}", id, subst[id]))
        .collect::<Vec<_>>()
        .join(", ")
}

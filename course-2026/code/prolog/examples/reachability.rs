//! Reachability in a graph: recursive rules over `edge` facts.
//!
//! The reachability predicate is the graph analogue of `ancestor`: two
//! rules say that `reachable(X, Y)` holds when there is an edge, or when
//! there is an edge to an intermediate node that can reach `Y`. The second
//! rule recurses on the *second* argument, so the search makes progress and
//! terminates on a finite acyclic graph.
//!
//! Run with `cargo run -p prolog --example reachability`.

use prolog::clause::Clause;
use prolog::database::Database;
use prolog::goal::Goal;
use prolog::query::Query;
use prolog::solver::Solver;
use prolog::term::Term;

fn edge(a: &str, b: &str) -> Term {
    Term::struct_("edge", vec![Term::atom(a), Term::atom(b)])
}

fn main() {
    let mut db = Database::new();

    // The directed graph a -> b -> c -> d, with a shortcut b -> e.
    for (u, v) in [("a", "b"), ("b", "c"), ("c", "d"), ("b", "e")] {
        db.add(Clause::fact(edge(u, v)));
    }

    // reachable(X, Y) :- edge(X, Y).
    db.add(Clause::rule(
        Term::struct_("reachable", vec![Term::var(0), Term::var(1)]),
        Goal::call(edge_term(0, 1)),
    ));
    // reachable(X, Y) :- edge(X, Z), reachable(Z, Y).
    db.add(Clause::rule(
        Term::struct_("reachable", vec![Term::var(0), Term::var(1)]),
        Goal::conj(vec![
            Goal::call(edge_term(0, 2)),
            Goal::call(Term::struct_("reachable", vec![Term::var(2), Term::var(1)])),
        ]),
    ));

    let query = Query::new(
        Goal::call(Term::struct_(
            "reachable",
            vec![Term::atom("a"), Term::var(0)],
        )),
        vec![(0, "Y")],
    );
    println!("query: {}", query);
    let mut solver = Solver::new(db);
    solver.query(query.goal.clone());
    let mut count = 0;
    while let Some(subst) = solver.next_solution() {
        count += 1;
        println!("answer {}: {}", count, query.answer(&subst));
    }
    println!("{} answers", count);
}

fn edge_term(x: usize, y: usize) -> Term {
    Term::struct_("edge", vec![Term::var(x), Term::var(y)])
}

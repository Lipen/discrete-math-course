//! The SLD solver: depth-first proof search with backtracking.
//!
//! This is the executable face of SLD resolution. The solver keeps a stack
//! of suspended derivations (choice points); each step takes the leftmost
//! goal of the derivation on top, matches it against the program clauses in
//! order, and pushes one new derivation per matching clause. When a
//! derivation reaches the empty goal, a solution has been found. A
//! derivation that dead-ends is dropped and the solver falls back to the
//! next choice point on the stack: that is backtracking.

use crate::clause::Clause;
use crate::database::Database;
use crate::goal::Goal;
use crate::rename::rename_clause;
use crate::subst::{apply_goal, Subst};
use crate::term::Term;
use crate::unify::unify;

/// A suspended derivation: goals still to prove and the substitution
/// accumulated so far.
#[derive(Debug, Clone)]
struct ChoicePoint {
    goals: Vec<Goal>,
    subst: Subst,
}

/// An event recorded during a traced search.
///
/// A trace records which goals the solver tried to prove, which clause
/// heads it selected against them, and which answers it found. The
/// `Call`/`Select` pairs sketch the SLD search tree: each `Select` is one
/// branch, and a `Solution` closes a branch successfully.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum TraceEvent {
    /// The solver schedules an atomic goal for proof.
    Call(Term),
    /// A clause head unified with the goal; the clause body is scheduled.
    Select(Term),
    /// A solution substitution was found.
    Solution(Subst),
}

/// A depth-first SLD solver over a logic program.
///
/// ```
/// use prolog::term::Term;
/// use prolog::goal::Goal;
/// use prolog::clause::Clause;
/// use prolog::database::Database;
/// use prolog::solver::Solver;
///
/// let mut db = Database::new();
/// db.add(Clause::fact(Term::struct_("parent", vec![Term::atom("alice"), Term::atom("bob")])));
/// db.add(Clause::fact(Term::struct_("parent", vec![Term::atom("alice"), Term::atom("carol")])));
///
/// let goal = Goal::call(Term::struct_("parent", vec![Term::var(0), Term::var(1)]));
/// let answers = Solver::new(db).solve(&goal, 10);
/// // Two facts match parent(_0, _1): (alice, bob) and (alice, carol).
/// assert_eq!(answers.len(), 2);
/// assert_eq!(answers[0][&0], Term::atom("alice"));
/// assert_eq!(answers[0][&1], Term::atom("bob"));
/// ```
#[derive(Debug, Clone)]
pub struct Solver {
    db: Database,
    stack: Vec<ChoicePoint>,
    fresh: usize,
    events: Vec<TraceEvent>,
    tracing: bool,
}

impl Solver {
    /// A solver over the given program.
    ///
    /// ```
    /// use prolog::database::Database;
    /// use prolog::solver::Solver;
    /// let solver = Solver::new(Database::new());
    /// assert!(solver.is_exhausted());
    /// ```
    pub fn new(db: Database) -> Self {
        Solver {
            db,
            stack: Vec::new(),
            fresh: 0,
            events: Vec::new(),
            tracing: false,
        }
    }

    /// Schedule a query: reset the search and start from `goal`.
    ///
    /// Fresh ids for clause renaming start above the largest variable of
    /// the query, so query variables are never touched by renaming.
    ///
    /// ```
    /// use prolog::term::Term;
    /// use prolog::goal::Goal;
    /// use prolog::database::Database;
    /// use prolog::solver::Solver;
    ///
    /// let mut solver = Solver::new(Database::new());
    /// solver.query(Goal::call(Term::atom("p")));
    /// assert!(!solver.is_exhausted());
    /// ```
    pub fn query(&mut self, goal: Goal) {
        self.fresh = max_var(&goal).map_or(0, |id| id + 1);
        self.events.clear();
        self.stack = vec![ChoicePoint {
            goals: sequence(goal),
            subst: Subst::new(),
        }];
    }

    /// The next solution, or `None` when the search is exhausted.
    ///
    /// Each call continues the search from where the previous one stopped,
    /// so repeated calls enumerate all solutions.
    ///
    /// ```
    /// use prolog::term::Term;
    /// use prolog::goal::Goal;
    /// use prolog::clause::Clause;
    /// use prolog::database::Database;
    /// use prolog::solver::Solver;
    ///
    /// let mut db = Database::new();
    /// db.add(Clause::fact(Term::struct_("p", vec![Term::atom("a")])));
    /// db.add(Clause::fact(Term::struct_("p", vec![Term::atom("b")])));
    /// let mut solver = Solver::new(db);
    /// solver.query(Goal::call(Term::struct_("p", vec![Term::var(0)])));
    /// let first = solver.next_solution().unwrap();
    /// let second = solver.next_solution().unwrap();
    /// assert_eq!(first[&0], Term::atom("a"));
    /// assert_eq!(second[&0], Term::atom("b"));
    /// assert_eq!(solver.next_solution(), None);
    /// ```
    pub fn next_solution(&mut self) -> Option<Subst> {
        while let Some(ChoicePoint { goals, subst }) = self.stack.pop() {
            if let Some(solution) = self.expand(goals, subst) {
                return Some(solution);
            }
        }
        None
    }

    /// Solve a goal and collect up to `max` solutions.
    ///
    /// ```
    /// use prolog::term::Term;
    /// use prolog::goal::Goal;
    /// use prolog::clause::Clause;
    /// use prolog::database::Database;
    /// use prolog::solver::Solver;
    ///
    /// let mut db = Database::new();
    /// db.add(Clause::fact(Term::atom("a")));
    /// let answers = Solver::new(db).solve(&Goal::call(Term::atom("a")), 3);
    /// assert_eq!(answers.len(), 1);
    /// ```
    pub fn solve(&mut self, goal: &Goal, max: usize) -> Vec<Subst> {
        self.query(goal.clone());
        let mut out = Vec::new();
        while out.len() < max {
            match self.next_solution() {
                Some(solution) => out.push(solution),
                None => break,
            }
        }
        out
    }

    /// Solve a goal under a step budget, collecting up to `max_solutions`.
    ///
    /// A clause order like `p :- p, ...` (left recursion) makes the search
    /// descend forever without ever producing an answer. A real Prolog
    /// would not return; this variant caps the number of expansion steps
    /// and returns whatever it found, so the behavior can be studied.
    ///
    /// ```
    /// use prolog::term::Term;
    /// use prolog::goal::Goal;
    /// use prolog::clause::Clause;
    /// use prolog::database::Database;
    /// use prolog::solver::Solver;
    ///
    /// // ancestor(X, Y) :- ancestor(X, Z), parent(Z, Y). with no base case.
    /// let mut db = Database::new();
    /// db.add(Clause::rule(
    ///     Term::struct_("ancestor", vec![Term::var(0), Term::var(1)]),
    ///     Goal::conj(vec![
    ///         Goal::call(Term::struct_("ancestor", vec![Term::var(0), Term::var(2)])),
    ///         Goal::call(Term::struct_("parent", vec![Term::var(2), Term::var(1)])),
    ///     ]),
    /// ));
    /// let goal = Goal::call(Term::struct_(
    ///     "ancestor",
    ///     vec![Term::atom("alice"), Term::atom("bob")],
    /// ));
    /// // Bounded: returns promptly, finds nothing inside the budget.
    /// let answers = Solver::new(db).solve_bounded(&goal, 100, 1);
    /// assert!(answers.is_empty());
    /// ```
    pub fn solve_bounded(
        &mut self,
        goal: &Goal,
        max_steps: usize,
        max_solutions: usize,
    ) -> Vec<Subst> {
        self.query(goal.clone());
        let mut out = Vec::new();
        let mut steps = 0usize;
        while out.len() < max_solutions && steps < max_steps {
            let Some(ChoicePoint { goals, subst }) = self.stack.pop() else {
                break;
            };
            steps += 1;
            if let Some(solution) = self.expand(goals, subst) {
                out.push(solution);
            }
        }
        out
    }

    /// Solve a goal, returning solutions together with the search trace.
    ///
    /// The trace is a transcript of the proof search, in the order the
    /// solver performed it.
    ///
    /// ```
    /// use prolog::term::Term;
    /// use prolog::goal::Goal;
    /// use prolog::clause::Clause;
    /// use prolog::database::Database;
    /// use prolog::solver::{Solver, TraceEvent};
    ///
    /// let mut db = Database::new();
    /// db.add(Clause::fact(Term::struct_("p", vec![Term::atom("a")])));
    /// db.add(Clause::fact(Term::struct_("p", vec![Term::atom("b")])));
    /// let goal = Goal::call(Term::struct_("p", vec![Term::var(0)]));
    /// let (answers, events) = Solver::new(db).solve_traced(&goal, 2);
    /// assert_eq!(answers.len(), 2);
    /// assert!(events.iter().any(|e| matches!(e, TraceEvent::Call(_))));
    /// ```
    pub fn solve_traced(&mut self, goal: &Goal, max: usize) -> (Vec<Subst>, Vec<TraceEvent>) {
        self.tracing = true;
        self.events.clear();
        let solutions = self.solve(goal, max);
        let events = std::mem::take(&mut self.events);
        self.tracing = false;
        (solutions, events)
    }

    /// Whether the search stack is empty (no more solutions).
    ///
    /// ```
    /// use prolog::database::Database;
    /// use prolog::solver::Solver;
    /// let solver = Solver::new(Database::new());
    /// assert!(solver.is_exhausted());
    /// ```
    pub fn is_exhausted(&self) -> bool {
        self.stack.is_empty()
    }

    /// Expand one choice point into its successors.
    ///
    /// A choice point whose goal list is empty is a solution. Otherwise the
    /// leftmost goal is matched against the program: each unifying clause
    /// schedules one new choice point with the clause body prepended.
    ///
    /// Returns `Some(subst)` for a solution, `None` otherwise.
    fn expand(&mut self, goals: Vec<Goal>, subst: Subst) -> Option<Subst> {
        if goals.is_empty() {
            self.record(TraceEvent::Solution(subst.clone()));
            return Some(subst);
        }
        let mut goals = goals;
        let head = goals.remove(0);
        let rest = goals;
        match apply_goal(&head, &subst) {
            Goal::True => {
                self.stack.push(ChoicePoint { goals: rest, subst });
            }
            Goal::Conj(inner) => {
                let mut combined = Vec::new();
                for goal in inner {
                    collect(goal, &mut combined);
                }
                combined.extend(rest);
                self.stack.push(ChoicePoint {
                    goals: combined,
                    subst,
                });
            }
            Goal::Call(term) => {
                self.record(TraceEvent::Call(term.clone()));
                self.expand_call(&term, rest, subst);
            }
        }
        None
    }

    /// Match an atomic goal against the program clauses and schedule the
    /// successful matches as new choice points.
    ///
    /// Clauses are tried in program order: iterating in reverse pushes the
    /// first clause last, so it is popped first.
    fn expand_call(&mut self, term: &Term, rest: Vec<Goal>, subst: Subst) {
        let Some(clauses) = self.db.clauses_for(term) else {
            return;
        };
        // Clone to release the borrow on `self` before recording events.
        let clauses: Vec<Clause> = clauses.to_vec();
        for clause in clauses.iter().rev() {
            let fresh_clause = rename_clause(clause, &mut self.fresh);
            let mut candidate = subst.clone();
            if unify(term, &fresh_clause.head, &mut candidate).is_ok() {
                self.record(TraceEvent::Select(fresh_clause.head.clone()));
                let mut combined = sequence(fresh_clause.body);
                combined.extend(rest.clone());
                self.stack.push(ChoicePoint {
                    goals: combined,
                    subst: candidate,
                });
            }
        }
    }

    /// Record an event when tracing is enabled.
    fn record(&mut self, event: TraceEvent) {
        if self.tracing {
            self.events.push(event);
        }
    }
}

/// Flatten a goal into a front-slice of a goal sequence.
fn sequence(goal: Goal) -> Vec<Goal> {
    let mut out = Vec::new();
    collect(goal, &mut out);
    out
}

/// Append the atoms of a goal to `out`, flattening conjunctions.
fn collect(goal: Goal, out: &mut Vec<Goal>) {
    match goal {
        Goal::True => {}
        Goal::Call(_) => out.push(goal),
        Goal::Conj(goals) => {
            for goal in goals {
                collect(goal, out);
            }
        }
    }
}

/// The largest variable id in a goal, if any.
fn max_var(goal: &Goal) -> Option<usize> {
    match goal {
        Goal::Call(term) => max_var_term(term),
        Goal::Conj(goals) => goals.iter().filter_map(max_var).max(),
        Goal::True => None,
    }
}

fn max_var_term(term: &Term) -> Option<usize> {
    match term {
        Term::Var(id) => Some(*id),
        Term::Struct(_, args) => args.iter().filter_map(max_var_term).max(),
        Term::Atom(_) => None,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::subst::apply;

    fn atom(name: &str) -> Term {
        Term::atom(name)
    }

    fn parent(a: &str, b: &str) -> Clause {
        Clause::fact(Term::struct_("parent", vec![atom(a), atom(b)]))
    }

    fn family() -> Database {
        let mut db = Database::new();
        db.add(parent("alice", "bob"));
        db.add(parent("bob", "carol"));
        db.add(parent("carol", "dave"));
        db
    }

    fn ancestor_rule() -> Clause {
        Clause::rule(
            Term::struct_("ancestor", vec![Term::var(0), Term::var(1)]),
            Goal::conj(vec![
                Goal::call(Term::struct_("parent", vec![Term::var(0), Term::var(2)])),
                Goal::call(Term::struct_("ancestor", vec![Term::var(2), Term::var(1)])),
            ]),
        )
    }

    /// The resolved value of the query variable in each answer. Direct map
    /// lookup would surface intermediate renamed variables; applying the
    /// substitution resolves them all the way down.
    fn answers_for(answers: &[Subst], var: usize) -> Vec<String> {
        answers
            .iter()
            .map(|s| apply(&Term::var(var), s).to_string())
            .collect()
    }

    #[test]
    fn ancestor_answers_in_program_order() {
        let mut db = family();
        // The base case comes first, so depth-first search finds the direct
        // children before the deeper ones.
        db.add(Clause::rule(
            Term::struct_("ancestor", vec![Term::var(0), Term::var(1)]),
            Goal::call(Term::struct_("parent", vec![Term::var(0), Term::var(1)])),
        ));
        db.add(ancestor_rule());
        let goal = Goal::call(Term::struct_(
            "ancestor",
            vec![Term::atom("alice"), Term::var(0)],
        ));
        let answers = Solver::new(db).solve(&goal, 10);
        assert_eq!(answers_for(&answers, 0), vec!["bob", "carol", "dave"]);
    }

    #[test]
    fn clause_order_changes_answer_order() {
        let mut db = family();
        db.add(ancestor_rule());
        db.add(Clause::rule(
            Term::struct_("ancestor", vec![Term::var(0), Term::var(1)]),
            Goal::call(Term::struct_("parent", vec![Term::var(0), Term::var(1)])),
        ));
        let goal = Goal::call(Term::struct_(
            "ancestor",
            vec![Term::atom("alice"), Term::var(0)],
        ));
        let answers = Solver::new(db).solve(&goal, 10);
        // The recursive clause is tried first, so depth-first search runs
        // down to the deepest ancestor before backtracking to the base case.
        assert_eq!(answers_for(&answers, 0), vec!["dave", "carol", "bob"]);
    }

    #[test]
    fn shared_variable_constrains_the_body() {
        // sibling(X, Y) :- parent(Z, X), parent(Z, Y).
        let mut db = Database::new();
        db.add(parent("alice", "bob"));
        db.add(parent("alice", "carol"));
        db.add(Clause::rule(
            Term::struct_("sibling", vec![Term::var(0), Term::var(1)]),
            Goal::conj(vec![
                Goal::call(Term::struct_("parent", vec![Term::var(2), Term::var(0)])),
                Goal::call(Term::struct_("parent", vec![Term::var(2), Term::var(1)])),
            ]),
        ));
        let goal = Goal::call(Term::struct_(
            "sibling",
            vec![Term::atom("bob"), Term::atom("carol")],
        ));
        let answers = Solver::new(db).solve(&goal, 3);
        assert_eq!(answers.len(), 1);
    }

    #[test]
    fn left_recursion_needs_a_step_bound() {
        // ancestor(X, Y) :- ancestor(X, Z), parent(Z, Y). with no base case
        // never terminates; the bounded search must return instead of hang.
        let mut db = Database::new();
        db.add(parent("alice", "bob"));
        db.add(ancestor_rule());
        let goal = Goal::call(Term::struct_(
            "ancestor",
            vec![Term::atom("alice"), Term::atom("bob")],
        ));
        let answers = Solver::new(db).solve_bounded(&goal, 100, 1);
        assert!(answers.is_empty());
    }

    #[test]
    fn trace_records_calls_selections_and_solutions() {
        let mut db = Database::new();
        db.add(parent("alice", "bob"));
        db.add(parent("alice", "carol"));
        let goal = Goal::call(Term::struct_("parent", vec![Term::var(0), Term::var(1)]));
        let (answers, events) = Solver::new(db).solve_traced(&goal, 2);
        assert_eq!(answers.len(), 2);
        let calls = events
            .iter()
            .filter(|e| matches!(e, TraceEvent::Call(_)))
            .count();
        let selects = events
            .iter()
            .filter(|e| matches!(e, TraceEvent::Select(_)))
            .count();
        let solutions = events
            .iter()
            .filter(|e| matches!(e, TraceEvent::Solution(_)))
            .count();
        assert_eq!(calls, 1);
        assert_eq!(selects, 2);
        assert_eq!(solutions, 2);
    }
}

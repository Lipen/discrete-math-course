//! LTL model checking via Büchi automata.
//!
//! A linear-time property is checked over the *infinite runs* of a Kripke
//! structure: every state is treated as an initial state, and the formula
//! holds iff every run starting in every state satisfies it. When a run
//! violates the formula, the checker returns a **lasso** counterexample:
//! a finite `prefix` of states followed by a `cycle` of states that repeats
//! forever.
//!
//! ```
//! use model_checking::{Kripke, ltl};
//!
//! // Traffic light: green -> yellow -> red -> green.
//! let m = Kripke::new(
//!     vec![vec![1], vec![2], vec![0]],
//!     vec![vec![0], vec![1], vec![2]],
//! );
//!
//! // "green implies eventually yellow" holds on every run.
//! let prop = ltl::Formula::G(Box::new(ltl::Formula::Or(
//!     Box::new(ltl::Formula::Not(Box::new(ltl::Formula::Atom(0)))),
//!     Box::new(ltl::Formula::F(Box::new(ltl::Formula::Atom(1)))),
//! )));
//! assert_eq!(ltl::check(&m, &prop), Ok(()));
//!
//! // "always green" fails: the light turns yellow. The counterexample is
//! // the lasso `prefix ++ cycle ++ cycle ++ ...`:
//! // 1, 2, 0, 1, 2, 0, ... -- green is followed by yellow and red.
//! let always_green = ltl::Formula::G(Box::new(ltl::Formula::Atom(0)));
//! let err = ltl::check(&m, &always_green).unwrap_err();
//! assert_eq!(err.prefix, vec![1]);
//! assert_eq!(err.cycle, vec![2, 0, 1]);
//! ```
//!
//! # How it works (Vardi–Wolper, simplified)
//!
//! 1. The negated property `¬f` is converted to *negation normal form*,
//!    pushing `¬` down to the atoms (`¬F φ = G ¬φ`, `¬G φ = F ¬φ`,
//!    `¬(φ U ψ) = ¬φ R ¬ψ`, `¬(φ R ψ) = ¬φ U ¬ψ`).
//!    This matters: the tableau below is only sound when no negated
//!    `U`/`R`/`G` formula is asked to drive a transition.
//! 2. From `¬f` a *generalized Büchi automaton* is built. Its states are
//!    the maximal consistent subsets of the closure (all subformulas and
//!    their negations). A transition `X -> Y` must satisfy, for every
//!    closure member:
//!    - `X φ ∈ X  ⟺  φ ∈ Y`;
//!    - `φ U ψ ∈ X  ⟺  ψ ∈ X ∨ (φ ∈ X ∧ φ U ψ ∈ Y)`;
//!    - `φ R ψ ∈ X  ⟺  φ ∈ X ∨ (ψ ∈ X ∧ φ R ψ ∈ Y)`;
//!    - `F φ ∈ X  ⟺  φ ∈ X ∨ F φ ∈ Y`;  `G φ ∈ X  ⟺  φ ∈ X ∧ G φ ∈ Y`.
//!    A run is accepting iff, for every `φ U ψ` and `F φ` in the closure,
//!    it visits infinitely often a state with `ψ ∈ X ∨ φ U ψ ∉ X`
//!    (resp. `φ ∈ X ∨ F φ ∉ X`). Runs of this automaton are exactly the
//!    runs that satisfy `¬f`.
//! 3. The automaton is synchronized with the Kripke structure: a product
//!    state `(s, X)` is valid iff `X` agrees with the atoms of `s`. The
//!    product has an accepting cycle iff some run of the model violates
//!    `f`, and that cycle is unwound into a lasso counterexample.
//!
//! The construction is deliberately unoptimized: the automaton can have
//! up to `2^|closure|` states, so the formula size is the bottleneck
//! (exponential blowup is possible, as in any automata-theoretic check).
//! The Kripke structure is small by design.
//!
//! # Dead ends
//!
//! LTL talks about *infinite* runs. A state with no successors starts no
//! run, so a property holds vacuously there — even if a finite path into
//! the dead end would have violated it. To check a property along finite
//! paths, add self-loops to the dead ends of the model first.

use crate::kripke::Kripke;
use std::collections::{HashMap, VecDeque};

/// An LTL formula over atoms indexed by `usize`.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum Formula {
    Atom(usize),
    Not(Box<Formula>),
    And(Box<Formula>, Box<Formula>),
    Or(Box<Formula>, Box<Formula>),
    /// `X φ` — φ holds in the next state.
    X(Box<Formula>),
    /// `F φ` — φ holds eventually (equivalent to `true U φ`).
    F(Box<Formula>),
    /// `G φ` — φ holds always (equivalent to `false R φ`).
    G(Box<Formula>),
    /// `φ U ψ` — φ holds until ψ holds.
    U(Box<Formula>, Box<Formula>),
    /// `φ R ψ` — ψ holds at least until φ (weak until).
    R(Box<Formula>, Box<Formula>),
}

/// A lasso-shaped counterexample: the run is `prefix` followed by `cycle`
/// repeated forever. The first element of `prefix` is the state where the
/// violating run starts; `cycle` is never empty.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Counterexample {
    /// The finite stem of the counterexample run.
    pub prefix: Vec<usize>,
    /// The repeating cycle; `cycle[0]` is a successor of `prefix`'s last
    /// element and the cycle is closed (`cycle.last() -> cycle[0]`).
    pub cycle: Vec<usize>,
}

/// Check the LTL formula `f` on the Kripke structure `m`.
///
/// The formula holds iff every infinite run starting in every state
/// satisfies it. On failure, a lasso counterexample is returned.
pub fn check(m: &Kripke, f: &Formula) -> Result<(), Counterexample> {
    // The negated property, in negation normal form: a counterexample is
    // an accepting run of the automaton for `¬f`.
    let psi = nnf(&Formula::Not(Box::new(f.clone())));
    let cl = closure(&psi);
    let (states, succ, accepting) = tableau(&cl);

    let nq = states.len();
    let np = m.n * nq;

    // Product states (s, q): valid iff q agrees with the atoms of s.
    let mut valid = vec![false; np];
    for s in 0..m.n {
        for q in 0..nq {
            let idx = s * nq + q;
            valid[idx] = cl.iter().all(|member| match member {
                Formula::Atom(a) => states[q].contains(member) == m.atoms[s].contains(a),
                _ => true,
            });
        }
    }

    // Product transitions.
    let mut adj: Vec<Vec<usize>> = vec![Vec::new(); np];
    for s in 0..m.n {
        for q in 0..nq {
            let idx = s * nq + q;
            if !valid[idx] {
                continue;
            }
            for &t in &m.successors[s] {
                for &r in &succ[q] {
                    let jdx = t * nq + r;
                    if valid[jdx] {
                        adj[idx].push(jdx);
                    }
                }
            }
        }
    }

    // Initial states: the negated property must hold at the start.
    let mut is_initial = vec![false; np];
    for s in 0..m.n {
        for q in 0..nq {
            let idx = s * nq + q;
            is_initial[idx] = valid[idx] && states[q].contains(&psi);
        }
    }

    // Breadth-first search from the initial states.
    let mut parent = vec![usize::MAX; np];
    let mut queue = VecDeque::new();
    for idx in 0..np {
        if is_initial[idx] {
            parent[idx] = idx;
            queue.push_back(idx);
        }
    }
    while let Some(u) = queue.pop_front() {
        for &v in &adj[u] {
            if parent[v] == usize::MAX {
                parent[v] = u;
                queue.push_back(v);
            }
        }
    }

    // The language is nonempty iff some reachable accepting state lies on
    // a cycle. The first such state, in index order, yields the lasso.
    for idx in 0..np {
        if parent[idx] == usize::MAX || !accepting[idx % nq] {
            continue;
        }
        if !can_reach_self(idx, &adj) {
            continue;
        }
        // Prefix: walk the BFS tree back to an initial state.
        let mut rev = vec![idx];
        let mut cur = idx;
        while parent[cur] != cur {
            cur = parent[cur];
            rev.push(cur);
        }
        rev.reverse();
        let prefix: Vec<usize> = rev.iter().map(|&x| x / nq).collect();
        // Cycle: the shortest cycle through the accepting state, written
        // as the cycle body followed by the entry state, so that the lasso
        // `prefix ++ cycle ++ cycle ++ ...` is a valid run (the entry's
        // successor is cycle[0], and cycle.last() leads back to the entry).
        let cyc = shortest_cycle(idx, &adj);
        let mut cycle: Vec<usize> = cyc[1..].iter().map(|&x| x / nq).collect();
        cycle.push(idx / nq);
        return Err(Counterexample { prefix, cycle });
    }

    Ok(())
}

/// Push negations down to the atoms.
fn nnf(f: &Formula) -> Formula {
    use Formula::*;
    match f {
        Atom(_) => f.clone(),
        And(a, b) => And(Box::new(nnf(a)), Box::new(nnf(b))),
        Or(a, b) => Or(Box::new(nnf(a)), Box::new(nnf(b))),
        X(g) => X(Box::new(nnf(g))),
        F(g) => F(Box::new(nnf(g))),
        G(g) => G(Box::new(nnf(g))),
        U(a, b) => U(Box::new(nnf(a)), Box::new(nnf(b))),
        R(a, b) => R(Box::new(nnf(a)), Box::new(nnf(b))),
        Not(g) => match g.as_ref() {
            Atom(_) => Not(Box::new(nnf(g))),
            Not(h) => nnf(h),
            And(a, b) => Or(Box::new(nnf(&neg(a))), Box::new(nnf(&neg(b)))),
            Or(a, b) => And(Box::new(nnf(&neg(a))), Box::new(nnf(&neg(b)))),
            X(h) => X(Box::new(nnf(&neg(h)))),
            F(h) => G(Box::new(nnf(&neg(h)))),
            G(h) => F(Box::new(nnf(&neg(h)))),
            U(a, b) => R(
                Box::new(And(
                    Box::new(nnf(&neg(b))),
                    Box::new(nnf(&neg(a))),
                )),
                Box::new(nnf(&neg(b))),
            ),
            R(a, b) => U(
                Box::new(nnf(&neg(a))),
                Box::new(nnf(&neg(b))),
            ),
        },
    }
}

/// The formula `¬f`.
fn neg(f: &Formula) -> Formula {
    Formula::Not(Box::new(f.clone()))
}

/// All subformulas of `f`, plus their negations, deduplicated.
fn closure(f: &Formula) -> Vec<Formula> {
    let mut subs: Vec<Formula> = Vec::new();
    collect_subformulas(f, &mut subs);
    let mut cl = subs.clone();
    for s in &subs {
        cl.push(Formula::Not(Box::new(s.clone())));
    }
    let mut out: Vec<Formula> = Vec::new();
    for x in cl {
        if !out.contains(&x) {
            out.push(x);
        }
    }
    out
}

fn collect_subformulas(f: &Formula, out: &mut Vec<Formula>) {
    if out.contains(f) {
        return;
    }
    match f {
        Formula::Atom(_) => {}
        Formula::Not(g) => collect_subformulas(g, out),
        Formula::And(a, b) | Formula::Or(a, b) | Formula::U(a, b) | Formula::R(a, b) => {
            collect_subformulas(a, out);
            collect_subformulas(b, out);
        }
        Formula::X(g) | Formula::F(g) | Formula::G(g) => collect_subformulas(g, out),
    }
    out.push(f.clone());
}

/// Build the generalized Büchi automaton for the NNF formula `psi`.
///
/// Returns the maximal consistent states, the transition relation, and a
/// flag per state saying whether all acceptance conditions hold there.
fn tableau(cl: &[Formula]) -> (Vec<Vec<Formula>>, Vec<Vec<usize>>, Vec<bool>) {
    // Representatives: closure members that are not themselves negations.
    // Every other member is `Not(g)` for a representative (or sub-)formula
    // `g`, so its truth is the opposite of `g`'s.
    let reps: Vec<&Formula> = cl.iter().filter(|f| !matches!(f, Formula::Not(_))).collect();
    let mut rep_pos: Vec<Option<usize>> = vec![None; cl.len()];
    for (i, f) in cl.iter().enumerate() {
        if !matches!(f, Formula::Not(_)) {
            rep_pos[i] = reps.iter().position(|r| *r == f);
        }
    }
    let idx: HashMap<Formula, usize> = cl.iter().enumerate().map(|(i, f)| (f.clone(), i)).collect();

    // Enumerate the maximal consistent sets.
    let mut states: Vec<Vec<Formula>> = Vec::new();
    for mask in 0..(1usize << reps.len()) {
        let truth: Vec<bool> = (0..cl.len())
            .map(|i| member_truth(cl, &idx, &rep_pos, mask, i))
            .collect();
        let mut ok = true;
        for (i, m) in cl.iter().enumerate() {
            match m {
                Formula::And(a, b) => {
                    if truth[i] != (truth[idx[a]] && truth[idx[b]]) {
                        ok = false;
                        break;
                    }
                }
                Formula::Or(a, b) => {
                    if truth[i] != (truth[idx[a]] || truth[idx[b]]) {
                        ok = false;
                        break;
                    }
                }
                _ => {}
            }
        }
        if ok {
            states.push(
                cl.iter()
                    .enumerate()
                    .filter(|(i, _)| truth[*i])
                    .map(|(_, f)| f.clone())
                    .collect(),
            );
        }
    }

    // Transitions: the local consistency conditions of the tableau.
    let mut succ: Vec<Vec<usize>> = vec![Vec::new(); states.len()];
    for i in 0..states.len() {
        for j in 0..states.len() {
            if transition_ok(&states[i], &states[j], cl) {
                succ[i].push(j);
            }
        }
    }

    // Acceptance: for every `φ U ψ` and `F φ` in the closure, the state
    // must satisfy the corresponding eventuality condition.
    let mut accepting = vec![true; states.len()];
    for (i, s) in states.iter().enumerate() {
        for m in cl {
            match m {
                Formula::U(_, b) => {
                    if !(has(s, b) || !has(s, m)) {
                        accepting[i] = false;
                    }
                }
                Formula::F(a) => {
                    if !(has(s, a) || !has(s, m)) {
                        accepting[i] = false;
                    }
                }
                _ => {}
            }
        }
    }

    (states, succ, accepting)
}

/// Truth of closure member `i` under the representative assignment `mask`.
fn member_truth(
    cl: &[Formula],
    idx: &HashMap<Formula, usize>,
    rep_pos: &[Option<usize>],
    mask: usize,
    i: usize,
) -> bool {
    match &cl[i] {
        Formula::Not(g) => !member_truth(cl, idx, rep_pos, mask, idx[g]),
        _ => (mask >> rep_pos[i].unwrap()) & 1 == 1,
    }
}

fn has(state: &[Formula], f: &Formula) -> bool {
    state.contains(f)
}

fn transition_ok(x: &[Formula], y: &[Formula], cl: &[Formula]) -> bool {
    for m in cl {
        match m {
            Formula::X(a) => {
                if has(x, m) != has(y, a) {
                    return false;
                }
            }
            Formula::U(a, b) => {
                if has(x, m) != (has(x, b) || (has(x, a) && has(y, m))) {
                    return false;
                }
            }
            Formula::R(a, b) => {
                if has(x, m) != (has(x, a) || (has(x, b) && has(y, m))) {
                    return false;
                }
            }
            Formula::F(a) => {
                if has(x, m) != (has(x, a) || has(y, m)) {
                    return false;
                }
            }
            Formula::G(a) => {
                if has(x, m) != (has(x, a) && has(y, m)) {
                    return false;
                }
            }
            _ => {}
        }
    }
    true
}

/// Is `start` on a cycle (can it reach itself via at least one edge)?
fn can_reach_self(start: usize, adj: &[Vec<usize>]) -> bool {
    let mut visited = vec![false; adj.len()];
    let mut stack: Vec<usize> = Vec::new();
    for &v in &adj[start] {
        if v == start {
            return true;
        }
        if !visited[v] {
            visited[v] = true;
            stack.push(v);
        }
    }
    while let Some(u) = stack.pop() {
        for &v in &adj[u] {
            if v == start {
                return true;
            }
            if !visited[v] {
                visited[v] = true;
                stack.push(v);
            }
        }
    }
    false
}

/// The shortest cycle through `start` (as a path `start -> ... -> u`, with
/// the closing edge `u -> start` implicit). The caller has verified that a
/// cycle exists.
fn shortest_cycle(start: usize, adj: &[Vec<usize>]) -> Vec<usize> {
    let mut parent = vec![usize::MAX; adj.len()];
    let mut queue = VecDeque::new();
    for &v in &adj[start] {
        if v == start {
            return vec![start];
        }
        parent[v] = start;
        queue.push_back(v);
    }
    while let Some(u) = queue.pop_front() {
        for &v in &adj[u] {
            if v == start {
                let mut rev = vec![u];
                let mut cur = u;
                while cur != start {
                    cur = parent[cur];
                    rev.push(cur);
                }
                rev.reverse();
                return rev;
            }
            if parent[v] == usize::MAX {
                parent[v] = u;
                queue.push_back(v);
            }
        }
    }
    unreachable!("a cycle through the accepting state was verified to exist");
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::kripke::Kripke;

    fn atom(a: usize) -> Formula {
        Formula::Atom(a)
    }

    fn not(f: Formula) -> Formula {
        Formula::Not(Box::new(f))
    }

    fn and(a: Formula, b: Formula) -> Formula {
        Formula::And(Box::new(a), Box::new(b))
    }

    fn or(a: Formula, b: Formula) -> Formula {
        Formula::Or(Box::new(a), Box::new(b))
    }

    /// Every consecutive pair is a transition, the cycle is closed, and the
    /// prefix connects to the cycle.
    fn lasso_valid(m: &Kripke, ce: &Counterexample) -> bool {
        let mut path = ce.prefix.clone();
        path.extend(&ce.cycle);
        for w in path.windows(2) {
            if !m.successors[w[0]].contains(&w[1]) {
                return false;
            }
        }
        if ce.cycle.is_empty() {
            return true;
        }
        m.successors[*ce.cycle.last().unwrap()].contains(&ce.cycle[0])
    }

    #[test]
    fn g_p_holds_on_a_fully_p_model() {
        // Two states, both p, with a branch and a self-loop: every run has
        // p at every position.
        let m = Kripke::new(
            vec![vec![0, 1], vec![1]],
            vec![vec![0], vec![0]],
        );
        let prop = Formula::G(Box::new(atom(0)));
        assert_eq!(check(&m, &prop), Ok(()));
    }

    #[test]
    fn g_p_fails_with_lasso_on_one_bad_state() {
        // State 2 is not p and loops to itself; from state 0 the run
        // 0, 2, 2, ... violates G p. The shortest violating lasso is the
        // self-loop at the bad state itself.
        let m = Kripke::new(
            vec![vec![0, 2], vec![1], vec![2]],
            vec![vec![0], vec![0], vec![]],
        );
        let prop = Formula::G(Box::new(atom(0)));
        let ce = check(&m, &prop).unwrap_err();
        assert_eq!(ce.prefix, vec![2]);
        assert_eq!(ce.cycle, vec![2]);
        assert!(lasso_valid(&m, &ce));
    }

    #[test]
    fn g_p_fails_from_the_bad_state() {
        // 0 -> 1 -> {1, 2}, 2 loops; p fails only at 2. Since every state
        // is an initial state, the shortest violating lasso is the
        // self-loop at the bad state itself.
        let m = Kripke::new(
            vec![vec![1], vec![1, 2], vec![2]],
            vec![vec![0], vec![0], vec![]],
        );
        let prop = Formula::G(Box::new(atom(0)));
        let ce = check(&m, &prop).unwrap_err();
        assert_eq!(ce.prefix, vec![2]);
        assert_eq!(ce.cycle, vec![2]);
        assert!(lasso_valid(&m, &ce));
    }

    #[test]
    fn f_p_holds_when_every_run_reaches_p() {
        // Chain 0 -> 1 -> 2 -> 2 with p only at 2: every run reaches p.
        let m = Kripke::new(
            vec![vec![1], vec![2], vec![2]],
            vec![vec![], vec![], vec![0]],
        );
        let prop = Formula::F(Box::new(atom(0)));
        assert_eq!(check(&m, &prop), Ok(()));
    }

    #[test]
    fn f_p_fails_when_a_path_avoids_p() {
        // From 0 the run 0, 0, ... never reaches p (state 1).
        let m = Kripke::new(
            vec![vec![0, 1], vec![1]],
            vec![vec![], vec![0]],
        );
        let prop = Formula::F(Box::new(atom(0)));
        let ce = check(&m, &prop).unwrap_err();
        assert_eq!(ce.prefix, vec![0]);
        assert_eq!(ce.cycle, vec![0]);
        assert!(lasso_valid(&m, &ce));
    }

    #[test]
    fn until_holds_when_q_eventually_comes() {
        // p at 0 and 1, q at 2: every run keeps p until q.
        let m = Kripke::new(
            vec![vec![1], vec![2], vec![2]],
            vec![vec![0], vec![0], vec![1]],
        );
        let prop = Formula::U(Box::new(atom(0)), Box::new(atom(1)));
        assert_eq!(check(&m, &prop), Ok(()));
    }

    #[test]
    fn until_fails_when_q_never_comes() {
        // p forever, q never: p U q fails on the only run.
        let m = Kripke::new(
            vec![vec![0]],
            vec![vec![0]],
        );
        let prop = Formula::U(Box::new(atom(0)), Box::new(atom(1)));
        let ce = check(&m, &prop).unwrap_err();
        assert_eq!(ce.prefix, vec![0]);
        assert_eq!(ce.cycle, vec![0]);
        assert!(lasso_valid(&m, &ce));
    }

    #[test]
    fn cycle_itself_contains_the_violation() {
        // 0 -> 1 -> 2 <-> 3; p fails at 2 and 3. The violating lasso has
        // the bad states inside its cycle.
        let m = Kripke::new(
            vec![vec![1], vec![2], vec![3], vec![2]],
            vec![vec![0], vec![0], vec![], vec![]],
        );
        let prop = Formula::G(Box::new(atom(0)));
        let ce = check(&m, &prop).unwrap_err();
        assert_eq!(ce.prefix, vec![2]);
        assert_eq!(ce.cycle, vec![3, 2]);
        assert!(lasso_valid(&m, &ce));
    }

    #[test]
    fn release_holds_when_q_holds_until_p() {
        // q (atom 1) holds at 0 and 1, p (atom 0) at 1 only: q W p from
        // every state on the runs 0 -> 0 and 0 -> 1 -> 1.
        let m = Kripke::new(
            vec![vec![0, 1], vec![1]],
            vec![vec![1], vec![0, 1]],
        );
        let prop = Formula::R(Box::new(atom(0)), Box::new(atom(1)));
        assert_eq!(check(&m, &prop), Ok(()));
    }

    #[test]
    fn release_fails_when_q_stops_before_p() {
        // State 2 has neither p nor q: the run 0, 2, 2, ... stops q before
        // p ever appears, so q W p fails.
        let m = Kripke::new(
            vec![vec![0, 2], vec![1], vec![2]],
            vec![vec![1], vec![0, 1], vec![]],
        );
        let prop = Formula::R(Box::new(atom(0)), Box::new(atom(1)));
        let ce = check(&m, &prop).unwrap_err();
        assert_eq!(ce.prefix, vec![2]);
        assert_eq!(ce.cycle, vec![2]);
        assert!(lasso_valid(&m, &ce));
    }

    #[test]
    fn next_holds_and_fails() {
        // 0 -> 1 -> 1, p at 1: X p holds everywhere.
        let m = Kripke::new(
            vec![vec![1], vec![1]],
            vec![vec![], vec![0]],
        );
        let prop = Formula::X(Box::new(atom(0)));
        assert_eq!(check(&m, &prop), Ok(()));

        // 0 -> 1 -> 1, p at 0 only: X p fails; the shortest violating
        // lasso starts at state 1 itself (its next state is not p).
        let m2 = Kripke::new(
            vec![vec![1], vec![1]],
            vec![vec![0], vec![]],
        );
        let ce = check(&m2, &prop).unwrap_err();
        assert_eq!(ce.prefix, vec![1]);
        assert_eq!(ce.cycle, vec![1]);
        assert!(lasso_valid(&m2, &ce));
    }

    #[test]
    fn g_implies_eventually_holds_and_fails() {
        // p at 0 and 1, q at 1: every run has q right after p.
        let good = Kripke::new(
            vec![vec![1], vec![1]],
            vec![vec![0], vec![0, 1]],
        );
        let prop = Formula::G(Box::new(or(not(atom(0)), Formula::F(Box::new(atom(1))))));
        assert_eq!(check(&good, &prop), Ok(()));

        // p at 0 with a self-loop and q nowhere: p is never followed by q.
        let bad = Kripke::new(
            vec![vec![0]],
            vec![vec![0]],
        );
        let ce = check(&bad, &prop).unwrap_err();
        assert_eq!(ce.prefix, vec![0]);
        assert_eq!(ce.cycle, vec![0]);
        assert!(lasso_valid(&bad, &ce));
    }

    #[test]
    fn g_f_p_holds_when_p_is_periodic() {
        // 0 -> 1 -> 2 -> 3 -> 0, p at 1 and 3: every run sees p
        // infinitely often, so G (F p) holds.
        let m = Kripke::new(
            vec![vec![1], vec![2], vec![3], vec![0]],
            vec![vec![], vec![0], vec![], vec![0]],
        );
        let prop = Formula::G(Box::new(Formula::F(Box::new(atom(0)))));
        assert_eq!(check(&m, &prop), Ok(()));
    }

    #[test]
    fn g_f_p_fails_when_p_is_transient() {
        // 0 -> 1 -> 1, p only at 0: the run 0, 1, 1, ... sees p once, so
        // G (F p) fails; the counterexample loops in the ¬p region.
        let m = Kripke::new(
            vec![vec![1], vec![1]],
            vec![vec![0], vec![]],
        );
        let prop = Formula::G(Box::new(Formula::F(Box::new(atom(0)))));
        let ce = check(&m, &prop).unwrap_err();
        assert_eq!(ce.prefix, vec![1]);
        assert_eq!(ce.cycle, vec![1]);
        assert!(lasso_valid(&m, &ce));
    }

    #[test]
    fn tautology_holds_and_contradiction_fails() {
        // The traffic light from the doctest: p ∨ ¬p is always true.
        let m = Kripke::new(
            vec![vec![1], vec![2], vec![0]],
            vec![vec![0], vec![1], vec![2]],
        );
        let taut = or(atom(0), not(atom(0)));
        assert_eq!(check(&m, &taut), Ok(()));

        // p ∧ ¬p is never true: every run violates it, so the checker
        // finds a lasso on the light's cycle.
        let contra = and(atom(0), not(atom(0)));
        let ce = check(&m, &contra).unwrap_err();
        assert!(lasso_valid(&m, &ce));
        assert!(!ce.prefix.is_empty() && !ce.cycle.is_empty());
    }
}

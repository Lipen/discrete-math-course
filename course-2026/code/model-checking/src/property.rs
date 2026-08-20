//! A uniform `holds` interface for CTL and LTL properties.
//!
//! CTL properties are checked with the labeling algorithm and fail with a
//! *path witness*: a finite path (or lasso) through the Kripke structure
//! that demonstrates the violation. LTL properties are checked with the
//! Büchi automaton and fail with a lasso counterexample. Both are reported
//! in the same `Counterexample` format (`prefix` + `cycle`; CTL finite
//! witnesses leave `cycle` empty).
//!
//! ```
//! use model_checking::{Formula, Kripke, Prop, holds, ltl};
//!
//! // Traffic light: green -> yellow -> red -> green.
//! let m = Kripke::new(
//!     vec![vec![1], vec![2], vec![0]],
//!     vec![vec![0], vec![1], vec![2]],
//! );
//!
//! // CTL: AG green fails -- from green the light goes to yellow, a state
//! // that is not green.
//! let p = Prop::Ctl(Formula::Ag(Box::new(Formula::Atom(0))));
//! let err = holds(&m, &p).unwrap_err();
//! assert_eq!(err.prefix, vec![0, 1]);
//! assert_eq!(err.cycle, vec![]);
//!
//! // LTL: G green fails too, with a lasso around the whole light cycle:
//! // 1, 2, 0, 1, 2, 0, ...
//! let q = Prop::Ltl(ltl::Formula::G(Box::new(ltl::Formula::Atom(0))));
//! let err = holds(&m, &q).unwrap_err();
//! assert_eq!(err.prefix, vec![1]);
//! assert_eq!(err.cycle, vec![2, 0, 1]);
//! ```
//!
//! The CTL counterexamples are extracted directly from the failing
//! formula: `AG φ` fails with a path to a `¬φ` state, `AF φ` with a lasso
//! inside `¬φ`, `EG φ` with a path that leaves `φ`, `E[φ U ψ]` / `A[φ U ψ]`
//! with a path on which `ψ` never occurs before `φ` fails, and so on.
//! Extraction works on the failing state chosen by the checker; for
//! formulas whose failure is purely local (atoms, `¬`, `∧`, `∨`) the
//! witness is the single state itself.

use crate::ctl;
use crate::kripke::Kripke;
use crate::ltl;
use crate::ltl::Counterexample;
use std::collections::{HashMap, HashSet, VecDeque};

/// A property: either a CTL or an LTL formula.
#[derive(Debug, Clone)]
pub enum Prop {
    /// A CTL formula, checked by state labeling.
    Ctl(ctl::Formula),
    /// An LTL formula, checked via its Büchi automaton.
    Ltl(ltl::Formula),
}

/// Check whether `p` holds on `m`: every state satisfies a CTL property,
/// every state starts only runs satisfying an LTL property.
///
/// Returns a counterexample witness when the property fails.
pub fn holds(m: &Kripke, p: &Prop) -> Result<(), Counterexample> {
    match p {
        Prop::Ltl(f) => ltl::check(m, f),
        Prop::Ctl(f) => {
            let sat = ctl::check(m, f);
            match sat.iter().position(|&x| !x) {
                None => Ok(()),
                Some(s) => Err(ctl_witness(m, f, s)),
            }
        }
    }
}

/// A witness that the CTL formula `f` fails at state `s`.
fn ctl_witness(m: &Kripke, f: &ctl::Formula, s: usize) -> Counterexample {
    use crate::ctl::Formula as C;
    match f {
        C::Atom(_) | C::Not(_) => Counterexample {
            prefix: vec![s],
            cycle: vec![],
        },
        C::And(a, b) => {
            let sa = ctl::check(m, a);
            if !sa[s] {
                ctl_witness(m, a, s)
            } else {
                ctl_witness(m, b, s)
            }
        }
        C::Or(a, b) => {
            // When the disjunction fails at s, both sides fail there.
            if !ctl::check(m, a)[s] {
                ctl_witness(m, a, s)
            } else {
                ctl_witness(m, b, s)
            }
        }
        C::Ex(_) => {
            // Every successor falsifies a; any one of them is a witness.
            let t = m.successors[s].first().copied();
            Counterexample {
                prefix: t.map_or_else(|| vec![s], |t| vec![s, t]),
                cycle: vec![],
            }
        }
        C::Ax(a) => {
            // Some successor falsifies a.
            let sa = ctl::check(m, a);
            let t = m.successors[s]
                .iter()
                .copied()
                .find(|&t| !sa[t])
                .expect("AX fails: some successor falsifies the formula");
            Counterexample {
                prefix: vec![s, t],
                cycle: vec![],
            }
        }
        C::Ef(a) => {
            // No path reaches a: show a run (lasso, or path to a dead end)
            // that avoids a forever.
            lasso_in_region(m, s, &negate(&ctl::check(m, a)))
        }
        C::Af(a) => {
            // Some run avoids a forever: a lasso inside the ¬a region
            // (dead ends are vacuously in AF, so they are never reached).
            lasso_in_region(m, s, &negate(&ctl::check(m, a)))
        }
        C::Eg(a) => {
            // Every run leaves a: walk through a-states to the first ¬a
            // state; if none exists, every run ends at an a-dead-end.
            let a_sat = ctl::check(m, a);
            let na = negate(&a_sat);
            match bfs_through(m, s, &a_sat, &na) {
                Some(path) => Counterexample {
                    prefix: path,
                    cycle: vec![],
                },
                None => lasso_in_region(m, s, &a_sat),
            }
        }
        C::Ag(a) => {
            // Some run reaches a ¬a state.
            let a_sat = ctl::check(m, a);
            let path = bfs_through(m, s, &vec![true; m.n], &negate(&a_sat))
                .expect("AG fails: a ¬a state is reachable");
            Counterexample {
                prefix: path,
                cycle: vec![],
            }
        }
        C::Eu(a, b) | C::Au(a, b) => {
            // No (Eu) or not every (Au) run has a-until-b: exhibit a run
            // where b never occurs before a fails.
            until_failure_witness(m, s, &ctl::check(m, a), &ctl::check(m, b))
        }
    }
}

fn negate(v: &[bool]) -> Vec<bool> {
    v.iter().map(|&x| !x).collect()
}

/// Shortest path from `s` to a `target` state, passing only through
/// `allowed` states (the target itself may lie outside `allowed`).
fn bfs_through(m: &Kripke, s: usize, allowed: &[bool], target: &[bool]) -> Option<Vec<usize>> {
    if target[s] {
        return Some(vec![s]);
    }
    if !allowed[s] {
        return None;
    }
    let mut parent = vec![usize::MAX; m.n];
    let mut queue = VecDeque::new();
    parent[s] = s;
    queue.push_back(s);
    while let Some(u) = queue.pop_front() {
        for &t in &m.successors[u] {
            if parent[t] != usize::MAX {
                continue;
            }
            if target[t] {
                let mut rev = vec![u];
                let mut cur = u;
                while cur != s {
                    cur = parent[cur];
                    rev.push(cur);
                }
                rev.reverse();
                rev.push(t);
                return Some(rev);
            }
            if allowed[t] {
                parent[t] = u;
                queue.push_back(t);
            }
        }
    }
    None
}

/// A lasso inside `region` reachable from `s`: either a cycle (the run can
/// stay in the region forever) or a maximal path ending at a region dead
/// end (the run leaves the region or stops).
fn lasso_in_region(m: &Kripke, s: usize, region: &[bool]) -> Counterexample {
    if !region[s] {
        return Counterexample {
            prefix: vec![s],
            cycle: vec![],
        };
    }
    // Iterative DFS restricted to the region. A back edge yields a cycle;
    // the DFS stack up to the back edge is the prefix.
    let mut stack: Vec<usize> = vec![s];
    let mut pos: HashMap<usize, usize> = HashMap::new();
    let mut done: HashSet<usize> = HashSet::new();
    let mut iter: Vec<usize> = vec![0];
    let mut best: Vec<usize> = Vec::new();
    pos.insert(s, 0);
    while let Some(&u) = stack.last() {
        let depth = stack.len() - 1;
        if iter[depth] < m.successors[u].len() {
            let t = m.successors[u][iter[depth]];
            iter[depth] += 1;
            if !region[t] {
                continue;
            }
            if let Some(&p) = pos.get(&t) {
                // A back edge u -> t: the cycle is stack[p..] (t ... u) and
                // the closing edge u -> t. The prefix is the path from the
                // start state s to t, i.e. stack[..p] (the DFS tree edge
                // stack[p-1] -> stack[p] closes into the cycle). When the
                // cycle re-enters the start state (p == 0) the prefix would
                // be empty, so the run is the cycle itself with s repeated
                // at the seam: prefix [s], cycle stack[1..] ++ [s].
                if p == 0 {
                    let mut cycle = stack[1..].to_vec();
                    cycle.push(stack[0]);
                    return Counterexample {
                        prefix: vec![s],
                        cycle,
                    };
                }
                return Counterexample {
                    prefix: stack[..p].to_vec(),
                    cycle: stack[p..].to_vec(),
                };
            }
            if done.contains(&t) {
                continue;
            }
            pos.insert(t, stack.len());
            stack.push(t);
            iter.push(0);
        } else {
            if best.is_empty() {
                best = stack.clone();
            }
            let u = stack.pop().expect("stack is non-empty");
            pos.remove(&u);
            done.insert(u);
            iter.pop();
        }
    }
    Counterexample {
        prefix: best,
        cycle: vec![],
    }
}

/// A witness that `a U b` fails at `s`: a run on which `b` never occurs
/// before the first `¬a` state. If a `¬a` state is reachable through
/// `¬b` states, the path to it is the witness; otherwise every run stays
/// in `a ∧ ¬b`, so a lasso (or dead-end path) inside that region works.
fn until_failure_witness(m: &Kripke, s: usize, a_sat: &[bool], b_sat: &[bool]) -> Counterexample {
    let not_a = negate(a_sat);
    let not_b = negate(b_sat);
    if let Some(path) = bfs_through(m, s, &not_b, &not_a) {
        return Counterexample {
            prefix: path,
            cycle: vec![],
        };
    }
    let region: Vec<bool> = a_sat.iter().zip(&not_b).map(|(&x, &y)| x && y).collect();
    lasso_in_region(m, s, &region)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::Formula as C;

    fn atom(a: usize) -> C {
        C::Atom(a)
    }

    fn ag(f: C) -> C {
        C::Ag(Box::new(f))
    }

    fn af(f: C) -> C {
        C::Af(Box::new(f))
    }

    fn eg(f: C) -> C {
        C::Eg(Box::new(f))
    }

    fn eu(a: C, b: C) -> C {
        C::Eu(Box::new(a), Box::new(b))
    }

    fn au(a: C, b: C) -> C {
        C::Au(Box::new(a), Box::new(b))
    }

    #[test]
    fn ctl_ag_holds() {
        // p everywhere, self-loops: AG p holds from every state.
        let m = Kripke::new(
            vec![vec![0, 1], vec![1]],
            vec![vec![0], vec![0]],
        );
        assert_eq!(holds(&m, &Prop::Ctl(ag(atom(0)))), Ok(()));
    }

    #[test]
    fn ctl_ag_failure_is_a_path() {
        // Traffic light: AG green fails at 0 with the path 0 -> 1.
        let m = Kripke::new(
            vec![vec![1], vec![2], vec![0]],
            vec![vec![0], vec![1], vec![2]],
        );
        let err = holds(&m, &Prop::Ctl(ag(atom(0)))).unwrap_err();
        assert_eq!(err.prefix, vec![0, 1]);
        assert_eq!(err.cycle, vec![]);
    }

    #[test]
    fn ctl_af_failure_is_a_lasso() {
        // p nowhere: AF p fails from every state; the witness is a lasso
        // inside the ¬p region.
        let m = Kripke::new(
            vec![vec![1], vec![1]],
            vec![vec![], vec![]],
        );
        let err = holds(&m, &Prop::Ctl(af(atom(0)))).unwrap_err();
        // The lasso 0 -> 1 -> 1 -> ... : prefix [0] ends at the cycle
        // entry, cycle [1] is the self-loop.
        assert_eq!(err.prefix, vec![0]);
        assert_eq!(err.cycle, vec![1]);
    }

    #[test]
    fn ctl_eg_failure_leaves_the_region() {
        // p at 0 only: EG p fails at 0 -- the run leaves p at state 1.
        let m = Kripke::new(
            vec![vec![1], vec![1]],
            vec![vec![0], vec![]],
        );
        let err = holds(&m, &Prop::Ctl(eg(atom(0)))).unwrap_err();
        assert_eq!(err.prefix, vec![0, 1]);
        assert_eq!(err.cycle, vec![]);
    }

    #[test]
    fn ctl_eu_and_au_failures() {
        // p at 0, q nowhere: E[p U q] and A[p U q] both fail at 0; the
        // witness keeps p forever without q.
        let m = Kripke::new(
            vec![vec![0]],
            vec![vec![0]],
        );
        let err = holds(&m, &Prop::Ctl(eu(atom(0), atom(1)))).unwrap_err();
        assert_eq!(err.prefix, vec![0]);
        assert_eq!(err.cycle, vec![0]);

        let err = holds(&m, &Prop::Ctl(au(atom(0), atom(1)))).unwrap_err();
        assert_eq!(err.prefix, vec![0]);
        assert_eq!(err.cycle, vec![0]);
    }

    #[test]
    fn ltl_under_the_wrapper() {
        // The traffic light: G green fails with a lasso.
        let m = Kripke::new(
            vec![vec![1], vec![2], vec![0]],
            vec![vec![0], vec![1], vec![2]],
        );
        let prop = Prop::Ltl(ltl::Formula::G(Box::new(ltl::Formula::Atom(0))));
        let err = holds(&m, &prop).unwrap_err();
        assert_eq!(err.prefix, vec![1]);
        assert_eq!(err.cycle, vec![2, 0, 1]);
    }
}

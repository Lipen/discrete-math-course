//! A Kripke structure: states, transitions, and atom labeling.

/// A finite Kripke structure `(S, R, L)`.
///
/// States are indexed `0..n`. Atoms are indexed `0..`; `atoms[s]` lists the
/// atoms true in state `s`.
#[derive(Debug, Clone)]
pub struct Kripke {
    /// Number of states.
    pub n: usize,
    /// `successors[s]` — the states reachable in one transition from `s`.
    pub successors: Vec<Vec<usize>>,
    /// `atoms[s]` — the atoms (by index) true in state `s`.
    pub atoms: Vec<Vec<usize>>,
}

impl Kripke {
    /// Build a Kripke structure; panics if the three vectors differ in length.
    pub fn new(successors: Vec<Vec<usize>>, atoms: Vec<Vec<usize>>) -> Self {
        assert_eq!(successors.len(), atoms.len());
        Self {
            n: successors.len(),
            successors,
            atoms,
        }
    }

    /// States with at least one successor in `set`.
    pub fn pre_exists(&self, set: &[bool]) -> Vec<bool> {
        let mut out = vec![false; self.n];
        for (s, succ) in self.successors.iter().enumerate() {
            out[s] = succ.iter().any(|&t| set[t]);
        }
        out
    }

    /// States whose every successor lies in `set` (true also for states with
    /// no successors — vacuous truth).
    pub fn pre_forall(&self, set: &[bool]) -> Vec<bool> {
        let mut out = vec![false; self.n];
        for (s, succ) in self.successors.iter().enumerate() {
            out[s] = succ.iter().all(|&t| set[t]);
        }
        out
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn pre_exists_is_false_at_a_dead_end() {
        // EX φ needs a successor in the set; a state with no successors
        // cannot have one, even when the set is everything.
        let m = Kripke::new(vec![vec![], vec![0]], vec![vec![], vec![]]);
        assert_eq!(m.pre_exists(&[true, true]), vec![false, true]);
    }

    #[test]
    fn pre_forall_is_vacuous_at_a_dead_end() {
        // AX φ: every successor satisfies φ. A state with no successors
        // satisfies this vacuously -- even for the empty set.
        let m = Kripke::new(vec![vec![], vec![0]], vec![vec![], vec![]]);
        assert_eq!(m.pre_forall(&[false, false]), vec![true, false]);
    }

    #[test]
    fn eg_fixed_point_keeps_only_infinite_paths() {
        // EG φ is the greatest fixed point of Y = φ ∧ pre_exists(Y).
        // State 0 satisfies φ but is a dead end: every run through it is
        // finite, so it drops out. State 1 loops to itself, so EG φ holds.
        let m = Kripke::new(
            vec![vec![], vec![1]],  // 0: dead end, 1: self-loop
            vec![vec![0], vec![0]], // both states satisfy atom 0
        );
        let mut y = vec![true, true];
        loop {
            let next: Vec<bool> = y.iter().zip(m.pre_exists(&y)).map(|(a, b)| *a && b).collect();
            if next == y {
                break;
            }
            y = next;
        }
        assert_eq!(y, vec![false, true]);
    }

    #[test]
    fn iterated_pre_exists_is_backwards_reachability() {
        // Chain 0 -> 1 -> 2 with a self-loop at 2. Iterating pre_exists
        // from {2} adds one predecessor per round: {2}, {1, 2}, {0, 1, 2}.
        let m = Kripke::new(vec![vec![1], vec![2], vec![2]], vec![vec![], vec![], vec![]]);
        let mut y = vec![false, false, true];
        let mut seen = vec![y.clone()];
        loop {
            let next = m.pre_exists(&y);
            if next == y {
                break;
            }
            y = next;
            seen.push(y.clone());
        }
        assert_eq!(
            seen,
            vec![
                vec![false, false, true],
                vec![false, true, true],
                vec![true, true, true],
            ]
        );
    }

    #[test]
    fn iterated_pre_forall_climbs_the_chain() {
        // The same chain: iterating pre_forall from {2} also reaches every
        // state, in the same number of rounds as pre_exists.
        let m = Kripke::new(vec![vec![1], vec![2], vec![2]], vec![vec![], vec![], vec![]]);
        let mut y = vec![false, false, true];
        let mut rounds = 0;
        loop {
            let next = m.pre_forall(&y);
            if next == y {
                break;
            }
            y = next;
            rounds += 1;
        }
        assert_eq!(y, vec![true, true, true]);
        assert_eq!(rounds, 2);
    }

    #[test]
    fn self_loop_is_its_own_successor() {
        // A reflexive state is a successor of itself: EX φ and AX φ both
        // hold there for the same set.
        let m = Kripke::new(vec![vec![0]], vec![vec![]]);
        assert_eq!(m.pre_exists(&[true]), vec![true]);
        assert_eq!(m.pre_forall(&[true]), vec![true]);
    }
}

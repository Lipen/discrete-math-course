//! A Kripke structure: states, transitions, and atom labeling.

/// A finite Kripke structure `(S, R, L)`.
///
/// States are indexed `0..n`, and atoms are indexed `0..`.
/// `atoms[s]` lists the atoms true in state `s`.
#[derive(Debug, Clone)]
pub struct Kripke {
    /// Number of states.
    pub n: usize,
    /// `successors[s]` -- the states reachable in one transition from `s`.
    pub successors: Vec<Vec<usize>>,
    /// `atoms[s]` -- the atoms (by index) true in state `s`.
    pub atoms: Vec<Vec<usize>>,
}

impl Kripke {
    /// Build a Kripke structure. Panics if the three vectors differ in length.
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
    /// no successors -- vacuous truth).
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
        // EX φ needs a successor in the set, so a state with no successors
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
    fn self_loop_is_its_own_successor() {
        // A reflexive state is a successor of itself: EX φ and AX φ both
        // hold there for the same set.
        let m = Kripke::new(vec![vec![0]], vec![vec![]]);
        assert_eq!(m.pre_exists(&[true]), vec![true]);
        assert_eq!(m.pre_forall(&[true]), vec![true]);
    }
}

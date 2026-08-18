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

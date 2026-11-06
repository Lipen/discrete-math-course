//! Greatest bisimulation between two finite Kripke structures.
//!
//! Two states are bisimilar when they carry the same atoms and every step
//! from one side can be matched by a step from the other side, in both
//! directions. Bisimilar states satisfy the same modal formulas, so a model
//! can be reduced to its bisimulation quotient before checking.
//!
//! ```
//! use model_checking::{greatest_bisimulation, Kripke};
//!
//! // Left: one state with two successors. Right: one successor.
//! let left = Kripke::new(
//!     vec![vec![1, 2], vec![], vec![]],
//!     vec![vec![0], vec![0], vec![0]],
//! );
//! let right = Kripke::new(vec![vec![1], vec![]], vec![vec![0], vec![0]]);
//!
//! let z = greatest_bisimulation(&left, &right);
//! assert!(z[0][0]);
//! ```

use crate::kripke::Kripke;

/// Compute the greatest bisimulation between two finite Kripke structures.
///
/// The result is a matrix `z` with `z[s][t] == true` exactly when state `s`
/// of `left` is bisimilar to state `t` of `right`.
/// The algorithm starts with all pairs that agree on atoms and repeatedly
/// removes a pair when some step on one side has no matching step on the
/// other side.
pub fn greatest_bisimulation(left: &Kripke, right: &Kripke) -> Vec<Vec<bool>> {
    let mut z = vec![vec![false; right.n]; left.n];
    for (s, row) in z.iter_mut().enumerate() {
        for (t, cell) in row.iter_mut().enumerate() {
            *cell = same_atoms(&left.atoms[s], &right.atoms[t]);
        }
    }

    loop {
        let mut changed = false;
        for s in 0..left.n {
            for t in 0..right.n {
                if !z[s][t] {
                    continue;
                }
                let forth = left.successors[s]
                    .iter()
                    .all(|&u| right.successors[t].iter().any(|&v| z[u][v]));
                let back = right.successors[t]
                    .iter()
                    .all(|&v| left.successors[s].iter().any(|&u| z[u][v]));
                if !forth || !back {
                    z[s][t] = false;
                    changed = true;
                }
            }
        }
        if !changed {
            return z;
        }
    }
}

/// Merge bisimilar states of one model into a quotient model.
///
/// Returns the quotient and a map from each old state to its class.
/// States in one class have the same atoms, and the successors of a class are
/// the classes of the successors of any representative.
pub fn quotient(model: &Kripke) -> (Kripke, Vec<usize>) {
    let z = greatest_bisimulation(model, model);
    let mut class = vec![usize::MAX; model.n];
    let mut representatives = Vec::new();

    for s in 0..model.n {
        if class[s] != usize::MAX {
            continue;
        }
        let c = representatives.len();
        representatives.push(s);
        for t in 0..model.n {
            if class[t] == usize::MAX && z[s][t] {
                class[t] = c;
            }
        }
    }

    let k = representatives.len();
    let mut successors = vec![Vec::new(); k];
    for s in 0..model.n {
        let c = class[s];
        for &t in &model.successors[s] {
            let d = class[t];
            if !successors[c].contains(&d) {
                successors[c].push(d);
            }
        }
    }
    for row in &mut successors {
        row.sort_unstable();
    }

    let atoms = representatives
        .iter()
        .map(|&s| {
            let mut a = model.atoms[s].clone();
            a.sort_unstable();
            a.dedup();
            a
        })
        .collect();

    (Kripke::new(successors, atoms), class)
}

/// Compare two atom lists as sets, ignoring order and duplicates.
fn same_atoms(a: &[usize], b: &[usize]) -> bool {
    let mut a = a.to_vec();
    let mut b = b.to_vec();
    a.sort_unstable();
    a.dedup();
    b.sort_unstable();
    b.dedup();
    a == b
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn branching_is_bisimilar_to_a_single_successor() {
        let left = Kripke::new(
            vec![vec![1, 2], vec![], vec![]],
            vec![vec![0], vec![0], vec![0]],
        );
        let right = Kripke::new(vec![vec![1], vec![]], vec![vec![0], vec![0]]);

        let z = greatest_bisimulation(&left, &right);
        assert!(z[0][0]);
        assert!(z[1][1]);
        assert!(z[2][1]);
    }

    #[test]
    fn different_atoms_block_bisimilarity() {
        let left = Kripke::new(vec![vec![]], vec![vec![0]]);
        let right = Kripke::new(vec![vec![]], vec![vec![1]]);

        let z = greatest_bisimulation(&left, &right);
        assert!(!z[0][0]);
    }

    #[test]
    fn a_missing_matching_step_breaks_bisimilarity() {
        // The left successor carries atoms {0, 1}, the right successor only {0}.
        let left = Kripke::new(vec![vec![1], vec![]], vec![vec![], vec![0, 1]]);
        let right = Kripke::new(vec![vec![1], vec![]], vec![vec![], vec![0]]);

        let z = greatest_bisimulation(&left, &right);
        assert!(!z[0][0]);
    }

    #[test]
    fn a_dead_end_does_not_match_a_live_state() {
        let left = Kripke::new(vec![vec![1], vec![]], vec![vec![], vec![]]);
        let right = Kripke::new(vec![vec![1], vec![1]], vec![vec![], vec![]]);

        let z = greatest_bisimulation(&left, &right);
        assert!(!z[1][1]);
    }

    #[test]
    fn every_state_is_bisimilar_to_itself() {
        let m = Kripke::new(
            vec![vec![1], vec![2], vec![0]],
            vec![vec![0], vec![1], vec![0]],
        );

        let z = greatest_bisimulation(&m, &m);
        for (s, row) in z.iter().enumerate() {
            assert!(row[s]);
        }
    }

    #[test]
    fn quotient_merges_bisimilar_dead_ends() {
        let m = Kripke::new(
            vec![vec![1, 2], vec![], vec![]],
            vec![vec![], vec![7], vec![7]],
        );

        let (q, class) = quotient(&m);
        assert_eq!(q.n, 2);
        assert_eq!(class[1], class[2]);
        assert_eq!(class[0], 0);
        assert_eq!(q.successors[0], vec![class[1]]);
        assert_eq!(q.atoms[class[1]], vec![7]);
    }

    #[test]
    fn quotient_of_three_distinct_states_keeps_them() {
        let m = Kripke::new(
            vec![vec![1], vec![2], vec![0]],
            vec![vec![0], vec![1], vec![2]],
        );

        let (q, class) = quotient(&m);
        assert_eq!(q.n, 3);
        assert_eq!(class, vec![0, 1, 2]);
    }

    #[test]
    fn quotient_preserves_formulas() {
        let m = Kripke::new(
            vec![vec![1, 2], vec![], vec![]],
            vec![vec![], vec![0], vec![0]],
        );
        let (q, class) = quotient(&m);
        let f = crate::Formula::Ex(Box::new(crate::Formula::Atom(0)));
        let before = crate::check(&m, &f);
        let after = crate::check(&q, &f);
        for s in 0..m.n {
            assert_eq!(before[s], after[class[s]]);
        }
    }
}

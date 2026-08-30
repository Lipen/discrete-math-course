//! CTL formulas and the labeling model-checking algorithm.
//!
//! Only the single-step modalities `EX` and `AX` are covered here; the
//! fixed-point modalities (`EF`, `EG`, `EU`, and their `A`-duals) are the
//! subject of a later project.

use crate::kripke::Kripke;

/// A CTL formula over atoms indexed by `usize`.
#[derive(Debug, Clone)]
pub enum Formula {
    Atom(usize),
    Not(Box<Formula>),
    And(Box<Formula>, Box<Formula>),
    Or(Box<Formula>, Box<Formula>),
    /// `EX φ` -- some successor satisfies `φ`.
    Ex(Box<Formula>),
    /// `AX φ` -- every successor satisfies `φ`.
    Ax(Box<Formula>),
}

/// Compute the set of states (as a bitmask over `0..m.n`) where `f` holds.
pub fn check(m: &Kripke, f: &Formula) -> Vec<bool> {
    let sat = |g: &Formula| check(m, g);
    match f {
        Formula::Atom(a) => m.atoms.iter().map(|s| s.contains(a)).collect(),
        Formula::Not(g) => {
            let s = sat(g);
            s.iter().map(|b| !b).collect()
        }
        Formula::And(g, h) => {
            let (sg, sh) = (sat(g), sat(h));
            sg.iter().zip(&sh).map(|(a, b)| *a && *b).collect()
        }
        Formula::Or(g, h) => {
            let (sg, sh) = (sat(g), sat(h));
            sg.iter().zip(&sh).map(|(a, b)| *a || *b).collect()
        }
        Formula::Ex(g) => m.pre_exists(&sat(g)),
        Formula::Ax(g) => m.pre_forall(&sat(g)),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::kripke::Kripke;

    // Traffic light: 0=green -> 1=yellow -> 2=red -> 0=green.
    fn traffic() -> Kripke {
        Kripke::new(
            vec![vec![1], vec![2], vec![0]],
            vec![vec![0], vec![1], vec![2]], // atoms: 0=green, 1=yellow, 2=red
        )
    }

    #[test]
    fn atomic_and_boolean() {
        let m = traffic();
        let green = Formula::Atom(0);
        let red = Formula::Atom(2);
        assert_eq!(check(&m, &green), vec![true, false, false]);
        assert_eq!(
            check(&m, &Formula::Or(Box::new(green), Box::new(red))),
            vec![true, false, true]
        );
    }

    #[test]
    fn ax_and_ex() {
        let m = traffic();
        // AX green: every successor is green -- true only where all succ are green.
        let ax_green = Formula::Ax(Box::new(Formula::Atom(0)));
        assert_eq!(check(&m, &ax_green), vec![false, false, true]);
        // EX green: some successor is green -- state 2 (red -> green).
        let ex_green = Formula::Ex(Box::new(Formula::Atom(0)));
        assert_eq!(check(&m, &ex_green), vec![false, false, true]);
    }
}

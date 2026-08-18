//! CTL formulas and the labeling model-checking algorithm.

use crate::kripke::Kripke;

/// A CTL formula over atoms indexed by `usize`.
#[derive(Debug, Clone)]
pub enum Formula {
    Atom(usize),
    Not(Box<Formula>),
    And(Box<Formula>, Box<Formula>),
    Or(Box<Formula>, Box<Formula>),
    /// `EX φ` — some successor satisfies `φ`.
    Ex(Box<Formula>),
    /// `AX φ` — every successor satisfies `φ`.
    Ax(Box<Formula>),
    /// `EF φ` — some path reaches `φ`.
    Ef(Box<Formula>),
    /// `AF φ` — every path eventually reaches `φ`.
    Af(Box<Formula>),
    /// `EG φ` — some path where `φ` always holds.
    Eg(Box<Formula>),
    /// `AG φ` — every path where `φ` always holds.
    Ag(Box<Formula>),
    /// `E[φ U ψ]` — some path: `φ` holds until `ψ`.
    Eu(Box<Formula>, Box<Formula>),
    /// `A[φ U ψ]` — every path: `φ` holds until `ψ`.
    Au(Box<Formula>, Box<Formula>),
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
        Formula::Ef(g) => {
            // least fixed point: Y = g ∪ pre_exists(Y)
            let sg = sat(g);
            let mut y = sg.clone();
            loop {
                let next = or(&sg, &m.pre_exists(&y));
                if next == y {
                    return y;
                }
                y = next;
            }
        }
        Formula::Af(g) => {
            // least fixed point: Y = g ∪ pre_forall(Y)
            let sg = sat(g);
            let mut y = sg.clone();
            loop {
                let next = or(&sg, &m.pre_forall(&y));
                if next == y {
                    return y;
                }
                y = next;
            }
        }
        Formula::Eg(g) => {
            // greatest fixed point: Y = g ∩ pre_exists(Y), by deletion
            let sg = sat(g);
            let mut y = sg.clone();
            loop {
                let mut next = y.clone();
                for (s, val) in next.iter_mut().enumerate() {
                    if *val && !m.successors[s].iter().any(|&t| y[t]) {
                        *val = false;
                    }
                }
                if next == y {
                    return y;
                }
                y = next;
            }
        }
        Formula::Ag(g) => {
            // greatest fixed point: Y = g ∩ pre_forall(Y), by deletion
            let sg = sat(g);
            let mut y = sg.clone();
            loop {
                let mut next = y.clone();
                for (s, val) in next.iter_mut().enumerate() {
                    if *val && !m.successors[s].iter().all(|&t| y[t]) {
                        *val = false;
                    }
                }
                if next == y {
                    return y;
                }
                y = next;
            }
        }
        Formula::Eu(g, h) => {
            // least fixed point: Y = h ∪ (g ∩ pre_exists(Y))
            let (sg, sh) = (sat(g), sat(h));
            let mut y = sh.clone();
            loop {
                let next = or(&sh, &and(&sg, &m.pre_exists(&y)));
                if next == y {
                    return y;
                }
                y = next;
            }
        }
        Formula::Au(g, h) => {
            // least fixed point: Y = h ∪ (g ∩ pre_forall(Y))
            let (sg, sh) = (sat(g), sat(h));
            let mut y = sh.clone();
            loop {
                let next = or(&sh, &and(&sg, &m.pre_forall(&y)));
                if next == y {
                    return y;
                }
                y = next;
            }
        }
    }
}

fn or(a: &[bool], b: &[bool]) -> Vec<bool> {
    a.iter().zip(b).map(|(x, y)| *x || *y).collect()
}

fn and(a: &[bool], b: &[bool]) -> Vec<bool> {
    a.iter().zip(b).map(|(x, y)| *x && *y).collect()
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
        assert_eq!(check(&m, &Formula::Or(Box::new(green), Box::new(red))), vec![true, false, true]);
    }

    #[test]
    fn ax_and_ex() {
        let m = traffic();
        // AX green: every successor is green — true only where all succ are green.
        let ax_green = Formula::Ax(Box::new(Formula::Atom(0)));
        assert_eq!(check(&m, &ax_green), vec![false, false, true]);
        // EX green: some successor is green — state 2 (red -> green).
        let ex_green = Formula::Ex(Box::new(Formula::Atom(0)));
        assert_eq!(check(&m, &ex_green), vec![false, false, true]);
    }

    #[test]
    fn ag_green_implies_af_red() {
        // On a 3-cycle, "after green, eventually red" (AG green -> AF red) holds
        // from every state: check AG green is empty, so the implication holds.
        let m = traffic();
        let ag_green = Formula::Ag(Box::new(Formula::Atom(0)));
        assert_eq!(check(&m, &ag_green), vec![false, false, false]);
    }

    #[test]
    fn ef_red_everywhere() {
        // EF red: some path reaches red — from every state on the cycle.
        let m = traffic();
        let ef_red = Formula::Ef(Box::new(Formula::Atom(2)));
        assert_eq!(check(&m, &ef_red), vec![true, true, true]);
    }

    #[test]
    fn mutual_exclusion_deadlock() {
        // Two states: 0 = neither in critical section, 1 = both (the bad state),
        // self-loops. AG !(crit1 ∧ crit2) must hold only in state 0.
        let m = Kripke::new(
            vec![vec![0], vec![1]],
            vec![vec![], vec![0, 1]], // atoms: 0=crit1, 1=crit2
        );
        let both = Formula::And(Box::new(Formula::Atom(0)), Box::new(Formula::Atom(1)));
        let ag_not_both = Formula::Ag(Box::new(Formula::Not(Box::new(both))));
        assert_eq!(check(&m, &ag_not_both), vec![true, false]);
    }
}

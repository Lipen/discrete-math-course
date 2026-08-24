//! Fitch-style natural deduction proof checker for propositional logic.
//!
//! A proof is a flat list of [`Step`]s. Each step carries a formula, a nesting
//! [`Step::depth`] (0 = main proof, 1 = inside one subproof, ...), and a
//! [`Just`]ification: an assumption, or a rule applied to earlier lines.
//!
//! [`check`] verifies that every inference step is an instance of its rule and
//! that all referenced lines are in scope (not inside a discharged subproof).
//!
//! ```
//! use fitch::{check, Step, Just};
//! use fitch::{atom, implies, not, bottom};
//!
//! // Proves (P -> Q) -> (¬Q -> ¬P): the contrapositive.
//! let p = atom("P");
//! let q = atom("Q");
//! let steps = vec![
//!     Step { depth: 0, formula: implies(p.clone(), q.clone()), just: Just::Assumption },
//!     Step { depth: 1, formula: not(q.clone()),              just: Just::Assumption },
//!     Step { depth: 2, formula: p.clone(),                   just: Just::Assumption },
//!     Step { depth: 2, formula: q.clone(),                   just: Just::ImpliesElim { imp: 1, ante: 3 } },
//!     Step { depth: 2, formula: bottom(),                    just: Just::NotElim { neg: 2, pos: 4 } },
//!     Step { depth: 1, formula: not(p.clone()),              just: Just::NotIntro { assump: 3, concl: 5 } },
//!     Step { depth: 0, formula: implies(not(q.clone()), not(p.clone())), just: Just::ImpliesIntro { assump: 2, concl: 6 } },
//!     Step { depth: 0, formula: implies(implies(p.clone(), q.clone()), implies(not(q), not(p))), just: Just::ImpliesIntro { assump: 1, concl: 7 } },
//! ];
//!
//! assert!(check(&steps).is_ok());
//! ```

use std::fmt;

/// A propositional formula.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Formula {
    Atom(String),
    /// Contradiction: `⊥`.
    Bottom,
    Not(Box<Formula>),
    And(Box<Formula>, Box<Formula>),
    Or(Box<Formula>, Box<Formula>),
    Implies(Box<Formula>, Box<Formula>),
}

/// An atomic formula.
pub fn atom(name: &str) -> Formula {
    Formula::Atom(name.to_string())
}

/// Contradiction `⊥`.
pub fn bottom() -> Formula {
    Formula::Bottom
}

pub fn not(f: Formula) -> Formula {
    Formula::Not(Box::new(f))
}

pub fn and(a: Formula, b: Formula) -> Formula {
    Formula::And(Box::new(a), Box::new(b))
}

pub fn or(a: Formula, b: Formula) -> Formula {
    Formula::Or(Box::new(a), Box::new(b))
}

pub fn implies(a: Formula, b: Formula) -> Formula {
    Formula::Implies(Box::new(a), Box::new(b))
}

impl fmt::Display for Formula {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Formula::Atom(s) => write!(f, "{s}"),
            Formula::Bottom => write!(f, "⊥"),
            Formula::Not(x) => write!(f, "¬{x}"),
            Formula::And(a, b) => write!(f, "({a} ∧ {b})"),
            Formula::Or(a, b) => write!(f, "({a} ∨ {b})"),
            Formula::Implies(a, b) => write!(f, "({a} -> {b})"),
        }
    }
}

/// A 1-based line reference.
pub type Line = usize;

/// The justification of a proof step.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Just {
    /// A premise, or the hypothesis of a subproof.
    Assumption,
    /// `A ∧ B` from `A` and `B`.
    AndIntro { left: Line, right: Line },
    /// `A` from `A ∧ B`.
    AndElimLeft { conj: Line },
    /// `B` from `A ∧ B`.
    AndElimRight { conj: Line },
    /// `A ∨ B` from `A`.
    OrIntroLeft { disj: Line },
    /// `A ∨ B` from `B`.
    OrIntroRight { disj: Line },
    /// `C` from `A ∨ B`, a subproof `A ⊢ C`, and a subproof `B ⊢ C`.
    OrElim { disj: Line, left: Line, right: Line },
    /// `A -> B` from a subproof `A ⊢ B`.
    ImpliesIntro { assump: Line, concl: Line },
    /// `B` from `A -> B` and `A` (modus ponens).
    ImpliesElim { imp: Line, ante: Line },
    /// `¬A` from a subproof `A ⊢ ⊥`.
    NotIntro { assump: Line, concl: Line },
    /// `⊥` from `¬A` and `A`.
    NotElim { neg: Line, pos: Line },
    /// `A` from `⊥` (ex falso).
    BotElim { bot: Line },
    /// `A` from `¬¬A` (classical).
    Dne { notnot: Line },
}

/// One line of a Fitch proof.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Step {
    /// Nesting level: 0 = main proof, 1 = inside one subproof, and so on.
    pub depth: usize,
    /// The formula asserted on this line.
    pub formula: Formula,
    /// How the line is justified.
    pub just: Just,
}

/// A proof-checking failure.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Error {
    /// A referenced line does not exist or is out of scope.
    OutOfScope(Line),
    /// A referenced line has the wrong formula.
    WrongFormula { line: Line, expected: Formula, found: Formula },
    /// A subproof reference does not point at an open assumption.
    NotAnAssumption(Line),
    /// A rule derives a formula different from the one stated on the step.
    Mismatch { line: Line, derived: Formula, stated: Formula },
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Error::OutOfScope(l) => write!(f, "line {l} is out of scope"),
            Error::WrongFormula { line, expected, found } => {
                write!(f, "line {line}: expected {expected}, found {found}")
            }
            Error::NotAnAssumption(l) => write!(f, "line {l} is not an open assumption"),
            Error::Mismatch { line, derived, stated } => {
                write!(f, "line {line}: rule derives {derived}, but {stated} is stated")
            }
        }
    }
}

impl std::error::Error for Error {}

/// Check a Fitch proof. Returns `Ok(())` if every step is valid.
pub fn check(steps: &[Step]) -> Result<(), Error> {
    let mut formulas: Vec<Formula> = Vec::new();
    let mut depths: Vec<usize> = Vec::new();
    // Lines currently referencable, in ascending order.
    let mut active: Vec<Line> = Vec::new();
    // Stack of open assumptions: (line, formula).
    let mut assumptions: Vec<(Line, Formula)> = Vec::new();

    for (i, step) in steps.iter().enumerate() {
        let line = i + 1;
        formulas.push(step.formula.clone());
        depths.push(step.depth);

        // The formula the rule derives; None for Assumption.
        let derived: Formula = match step.just {
            Just::Assumption => {
                active.push(line);
                assumptions.push((line, step.formula.clone()));
                continue;
            }
            Just::AndIntro { left, right } => {
                let a = scope(&active, &formulas, left)?;
                let b = scope(&active, &formulas, right)?;
                and(a, b)
            }
            Just::AndElimLeft { conj } => match scope(&active, &formulas, conj)? {
                Formula::And(a, _) => *a,
                f => return Err(Error::WrongFormula { line: conj, expected: and(atom("_"), atom("_")), found: f }),
            },
            Just::AndElimRight { conj } => match scope(&active, &formulas, conj)? {
                Formula::And(_, b) => *b,
                f => return Err(Error::WrongFormula { line: conj, expected: and(atom("_"), atom("_")), found: f }),
            },
            Just::OrIntroLeft { disj } => {
                let (x, _) = match &step.formula {
                    Formula::Or(x, y) => ((**x).clone(), (**y).clone()),
                    f => return Err(Error::WrongFormula { line, expected: or(atom("_"), atom("_")), found: f.clone() }),
                };
                let a = scope(&active, &formulas, disj)?;
                if a != x {
                    return Err(Error::WrongFormula { line: disj, expected: x, found: a });
                }
                step.formula.clone()
            }
            Just::OrIntroRight { disj } => {
                let (_, y) = match &step.formula {
                    Formula::Or(x, y) => ((**x).clone(), (**y).clone()),
                    f => return Err(Error::WrongFormula { line, expected: or(atom("_"), atom("_")), found: f.clone() }),
                };
                let b = scope(&active, &formulas, disj)?;
                if b != y {
                    return Err(Error::WrongFormula { line: disj, expected: y, found: b });
                }
                step.formula.clone()
            }
            Just::OrElim { disj, left, right } => {
                let (a, b) = match scope(&active, &formulas, disj)? {
                    Formula::Or(a, b) => (*a, *b),
                    f => return Err(Error::WrongFormula { line: disj, expected: or(atom("_"), atom("_")), found: f }),
                };
                let c1 = scope(&active, &formulas, left)?;
                let c2 = scope(&active, &formulas, right)?;
                if c1 != c2 {
                    return Err(Error::Mismatch {
                        line: right,
                        derived: c2,
                        stated: c1,
                    });
                }
                // The two case hypotheses sit on top of the assumption stack.
                close_case(&mut active, &depths, &mut assumptions, &b)?;
                close_case(&mut active, &depths, &mut assumptions, &a)?;
                c1
            }
            Just::ImpliesIntro { assump, concl } => {
                let a = scope(&active, &formulas, assump)?;
                let b = scope(&active, &formulas, concl)?;
                close_subproof(&mut active, &depths, &mut assumptions, assump)?;
                implies(a, b)
            }
            Just::ImpliesElim { imp, ante } => {
                let (a, b) = match scope(&active, &formulas, imp)? {
                    Formula::Implies(a, b) => (*a, *b),
                    f => return Err(Error::WrongFormula { line: imp, expected: implies(atom("_"), atom("_")), found: f }),
                };
                let x = scope(&active, &formulas, ante)?;
                if x != a {
                    return Err(Error::WrongFormula { line: ante, expected: a, found: x });
                }
                b
            }
            Just::NotIntro { assump, concl } => {
                let a = scope(&active, &formulas, assump)?;
                let c = scope(&active, &formulas, concl)?;
                if c != Formula::Bottom {
                    return Err(Error::WrongFormula { line: concl, expected: Formula::Bottom, found: c });
                }
                close_subproof(&mut active, &depths, &mut assumptions, assump)?;
                not(a)
            }
            Just::NotElim { neg, pos } => {
                let n = scope(&active, &formulas, neg)?;
                let p = scope(&active, &formulas, pos)?;
                match n {
                    Formula::Not(x) if *x == p => Formula::Bottom,
                    _ => return Err(Error::WrongFormula { line: neg, expected: not(p.clone()), found: n }),
                }
            }
            Just::BotElim { bot } => {
                let c = scope(&active, &formulas, bot)?;
                if c != Formula::Bottom {
                    return Err(Error::WrongFormula { line: bot, expected: Formula::Bottom, found: c });
                }
                step.formula.clone()
            }
            Just::Dne { notnot } => match scope(&active, &formulas, notnot)? {
                Formula::Not(n) => match *n {
                    Formula::Not(x) => *x,
                    f => return Err(Error::WrongFormula { line: notnot, expected: not(not(atom("_"))), found: not(f) }),
                },
                f => return Err(Error::WrongFormula { line: notnot, expected: not(not(atom("_"))), found: f }),
            },
        };

        if derived != step.formula {
            return Err(Error::Mismatch { line, derived, stated: step.formula.clone() });
        }
        active.push(line);
    }

    Ok(())
}

/// Look up the formula of `line` if it is currently in scope.
fn scope(active: &[Line], formulas: &[Formula], line: Line) -> Result<Formula, Error> {
    if !active.contains(&line) {
        return Err(Error::OutOfScope(line));
    }
    Ok(formulas[line - 1].clone())
}

/// Discharge a subproof opened by the assumption at `assump`.
fn close_subproof(
    active: &mut Vec<Line>,
    depths: &[usize],
    assumptions: &mut Vec<(Line, Formula)>,
    assump: Line,
) -> Result<(), Error> {
    if assumptions.last().map(|(l, _)| *l) != Some(assump) {
        return Err(Error::NotAnAssumption(assump));
    }
    assumptions.pop();
    let barrier = depths[assump - 1];
    active.retain(|&l| depths[l - 1] < barrier);
    Ok(())
}

/// Discharge one case of an `OrElim`: the hypothesis must equal `expected`.
fn close_case(
    active: &mut Vec<Line>,
    depths: &[usize],
    assumptions: &mut Vec<(Line, Formula)>,
    expected: &Formula,
) -> Result<(), Error> {
    let (assump, a) = assumptions
        .pop()
        .ok_or(Error::NotAnAssumption(0))?;
    if a != *expected {
        return Err(Error::WrongFormula { line: assump, expected: expected.clone(), found: a });
    }
    let barrier = depths[assump - 1];
    active.retain(|&l| depths[l - 1] < barrier);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn contrapositive_is_provable() {
        let p = atom("P");
        let q = atom("Q");
        let steps = vec![
            Step { depth: 0, formula: implies(p.clone(), q.clone()), just: Just::Assumption },
            Step { depth: 1, formula: not(q.clone()), just: Just::Assumption },
            Step { depth: 2, formula: p.clone(), just: Just::Assumption },
            Step { depth: 2, formula: q.clone(), just: Just::ImpliesElim { imp: 1, ante: 3 } },
            Step { depth: 2, formula: bottom(), just: Just::NotElim { neg: 2, pos: 4 } },
            Step { depth: 1, formula: not(p.clone()), just: Just::NotIntro { assump: 3, concl: 5 } },
            Step { depth: 0, formula: implies(not(q.clone()), not(p.clone())), just: Just::ImpliesIntro { assump: 2, concl: 6 } },
            Step {
                depth: 0,
                formula: implies(implies(p.clone(), q.clone()), implies(not(q), not(p))),
                just: Just::ImpliesIntro { assump: 1, concl: 7 },
            },
        ];
        assert!(check(&steps).is_ok(), "{:?}", check(&steps));
    }

    #[test]
    fn double_negation_elimination_is_classical() {
        // ¬¬P ⊢ P needs DNE.
        let p = atom("P");
        let steps = vec![
            Step { depth: 0, formula: not(not(p.clone())), just: Just::Assumption },
            Step { depth: 0, formula: p.clone(), just: Just::Dne { notnot: 1 } },
        ];
        assert!(check(&steps).is_ok(), "{:?}", check(&steps));
    }

    #[test]
    fn or_elimination_is_valid() {
        // (A ∨ B), (A -> C), (B -> C) ⊢ C.
        let a = atom("A");
        let b = atom("B");
        let c = atom("C");
        let steps = vec![
            Step { depth: 0, formula: or(a.clone(), b.clone()), just: Just::Assumption },
            Step { depth: 0, formula: implies(a.clone(), c.clone()), just: Just::Assumption },
            Step { depth: 0, formula: implies(b.clone(), c.clone()), just: Just::Assumption },
            Step { depth: 1, formula: a.clone(), just: Just::Assumption },
            Step { depth: 1, formula: c.clone(), just: Just::ImpliesElim { imp: 2, ante: 4 } },
            Step { depth: 1, formula: b.clone(), just: Just::Assumption },
            Step { depth: 1, formula: c.clone(), just: Just::ImpliesElim { imp: 3, ante: 6 } },
            Step { depth: 0, formula: c.clone(), just: Just::OrElim { disj: 1, left: 5, right: 7 } },
        ];
        assert!(check(&steps).is_ok(), "{:?}", check(&steps));
    }

    #[test]
    fn or_introduction_derives_from_a_disjunct() {
        // A ⊢ A ∨ B (left) and A ⊢ B ∨ A (right).
        let a = atom("A");
        let b = atom("B");
        let steps = vec![
            Step { depth: 0, formula: a.clone(), just: Just::Assumption },
            Step { depth: 0, formula: or(a.clone(), b.clone()), just: Just::OrIntroLeft { disj: 1 } },
            Step { depth: 0, formula: or(b.clone(), a.clone()), just: Just::OrIntroRight { disj: 1 } },
        ];
        assert!(check(&steps).is_ok(), "{:?}", check(&steps));
    }

    #[test]
    fn or_introduction_rejects_wrong_disjunct() {
        // From A, left-intro cannot state B ∨ C (B ≠ A).
        let a = atom("A");
        let b = atom("B");
        let c = atom("C");
        let steps = vec![
            Step { depth: 0, formula: a.clone(), just: Just::Assumption },
            Step { depth: 0, formula: or(b.clone(), c.clone()), just: Just::OrIntroLeft { disj: 1 } },
        ];
        assert!(matches!(check(&steps), Err(Error::WrongFormula { line: 1, .. })));
    }

    #[test]
    fn out_of_scope_reference_is_rejected() {
        // Reference a line inside a closed subproof.
        let p = atom("P");
        let q = atom("Q");
        let steps = vec![
            Step { depth: 0, formula: p.clone(), just: Just::Assumption },
            Step { depth: 1, formula: q.clone(), just: Just::Assumption },
            Step { depth: 0, formula: implies(q.clone(), q.clone()), just: Just::ImpliesIntro { assump: 2, concl: 2 } },
            // Line 4 tries to use line 2, which is now discharged.
            Step { depth: 0, formula: q.clone(), just: Just::AndElimLeft { conj: 2 } },
        ];
        assert!(matches!(check(&steps), Err(Error::OutOfScope(2))));
    }

    #[test]
    fn wrong_formula_is_rejected() {
        // Claim `Q` from `P` via ∧-elimination-left of a non-conjunction.
        let p = atom("P");
        let q = atom("Q");
        let steps = vec![
            Step { depth: 0, formula: p.clone(), just: Just::Assumption },
            Step { depth: 0, formula: q.clone(), just: Just::AndElimLeft { conj: 1 } },
        ];
        assert!(matches!(check(&steps), Err(Error::WrongFormula { .. })));
    }
}

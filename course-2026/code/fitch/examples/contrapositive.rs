//! Check a proof of the contrapositive `(P -> Q) -> (~Q -> ~P)`.
//!
//! The demo builds the proof line by line, prints the nested subproof
//! structure with the rule and line references used at each step, and lets
//! the checker give its verdict.

use fitch::{atom, bottom, check, implies, not, Just, Step};

fn main() {
    let p = atom("P");
    let q = atom("Q");
    let steps = vec![
        Step { depth: 0, formula: implies(p.clone(), q.clone()), just: Just::Assumption },
        Step { depth: 1, formula: not(q.clone()), just: Just::Assumption },
        Step { depth: 2, formula: p.clone(), just: Just::Assumption },
        Step { depth: 2, formula: q.clone(), just: Just::ImpliesElim { imp: 1, ante: 3 } },
        Step { depth: 2, formula: bottom(), just: Just::NotElim { neg: 2, pos: 4 } },
        Step { depth: 1, formula: not(p.clone()), just: Just::NotIntro { assump: 3, concl: 5 } },
        Step {
            depth: 0,
            formula: implies(not(q.clone()), not(p.clone())),
            just: Just::ImpliesIntro { assump: 2, concl: 6 },
        },
        Step {
            depth: 0,
            formula: implies(implies(p.clone(), q.clone()), implies(not(q), not(p))),
            just: Just::ImpliesIntro { assump: 1, concl: 7 },
        },
    ];

    println!("Proving (P -> Q) -> (~Q -> ~P), the contrapositive.");
    println!();
    for (i, step) in steps.iter().enumerate() {
        println!("{:>2}. {}{}    {:?}", i + 1, "  ".repeat(step.depth), step.formula, step.just);
    }
    println!();
    match check(&steps) {
        Ok(()) => println!("verdict: the proof is valid."),
        Err(e) => println!("verdict: rejected -- {e}"),
    }
}

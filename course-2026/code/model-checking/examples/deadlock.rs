//! Deadlock detection.
//!
//! A deadlock is a state with no successors: every run that enters it stops.
//! The demo scans for such states structurally, then uses the checker to
//! find which states can reach a deadlock (EF deadlock) and from which
//! states every path can always take a step (AG EX true).

use model_checking::{check, Formula, Kripke};

fn main() {
    let labels = ["P running", "P waits on Q", "Q waits on P", "R running", "R done"];

    // States 0 -> 1 -> 2: a circular wait -- P holds a resource Q wants,
    // Q holds the one P wants, so state 2 has no successors.
    // States 3 -> 4 -> 4: a healthy process that runs forever.
    let m = Kripke::new(
        vec![
            vec![1], // 0
            vec![2], // 1
            vec![],  // 2 -- deadlock
            vec![4], // 3
            vec![4], // 4
        ],
        vec![
            vec![],
            vec![],
            vec![0], // atom 0 marks the deadlock state
            vec![],
            vec![],
        ],
    );

    println!("structural scan -- states with no successors:");
    for (s, succ) in m.successors.iter().enumerate() {
        if succ.is_empty() {
            println!("  {} ({}) is a deadlock", s, labels[s]);
        }
    }

    let deadlock = Formula::Atom(0);
    let ef_deadlock = check(&m, &Formula::Ef(Box::new(deadlock)));
    println!("\nEF deadlock -- states from which a deadlock is reachable:");
    for (s, &holds) in ef_deadlock.iter().enumerate() {
        println!("  {}: {}", labels[s], holds);
    }

    // EX true, expressed as EX (p ∨ ¬p).
    let taut = Formula::Or(
        Box::new(Formula::Atom(0)),
        Box::new(Formula::Not(Box::new(Formula::Atom(0)))),
    );
    let ag_can_step = check(&m, &Formula::Ag(Box::new(Formula::Ex(Box::new(taut)))));
    println!("\nAG EX true -- states where every path can always take a step:");
    for (s, &holds) in ag_can_step.iter().enumerate() {
        println!("  {}: {}", labels[s], holds);
    }
}

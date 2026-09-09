//! EX vs AX on a branching Kripke structure.
//!
//! State 0 branches into 1 and 2, state 1 continues into 2, and state 2 is
//! a dead end. The single atom holds only in state 2. The example contrasts
//! the existential and universal next-step modalities and shows the vacuous
//! truth of `AX` at the dead end.

use model_checking::{check, Formula, Kripke};

/// Render a label as a compact bit vector, one bit per state.
fn bits(label: &[bool]) -> String {
    let cells: Vec<&str> = label.iter().map(|b| if *b { "1" } else { "0" }).collect();
    format!("[{}]", cells.join(", "))
}

/// Print a formula, its label over the structure, and one reason per state.
fn report(m: &Kripke, formula: &str, reading: &str, f: &Formula, reasons: [&str; 3]) {
    println!("{formula}");
    println!("  reading: {reading}");
    println!("  label: {}", bits(&check(m, f)));
    for (s, why) in reasons.iter().enumerate() {
        println!("  s{}: {}", s, why);
    }
    println!();
}

fn main() {
    let m = Kripke::new(
        vec![vec![1, 2], vec![2], vec![]],
        vec![vec![], vec![], vec![0]], // the atom holds only in s2
    );

    println!("Kripke structure (atom 0 holds only where listed):");
    for (s, succ) in m.successors.iter().enumerate() {
        let next = if succ.is_empty() {
            "none (dead end)".to_string()
        } else {
            let targets: Vec<String> = succ.iter().map(|t| format!("s{t}")).collect();
            targets.join(", ")
        };
        let held: Vec<String> = m.atoms[s].iter().map(|a| a.to_string()).collect();
        println!(
            "  s{}: successors = {}, atoms = {{{}}}",
            s,
            next,
            held.join(", ")
        );
    }
    println!();

    report(
        &m,
        "EX atom",
        "some successor carries the atom",
        &Formula::Ex(Box::new(Formula::Atom(0))),
        [
            "one branch reaches s2, which carries the atom -- one good successor is enough",
            "its single successor s2 carries the atom",
            "a dead end has no successors, so no successor carries the atom",
        ],
    );

    report(
        &m,
        "AX atom",
        "every successor carries the atom",
        &Formula::Ax(Box::new(Formula::Atom(0))),
        [
            "branch s1 lacks the atom, so not every successor qualifies",
            "its only successor s2 carries the atom",
            "no successors at all -- every (zero) successor qualifies: vacuously true",
        ],
    );

    report(
        &m,
        "AX (not atom)",
        "every successor lacks the atom",
        &Formula::Ax(Box::new(Formula::Not(Box::new(Formula::Atom(0))))),
        [
            "successor s2 carries the atom, so not every successor lacks it",
            "successor s2 carries the atom, so not every successor lacks it",
            "vacuously true again -- at a dead end AX holds for any formula",
        ],
    );

    println!("Takeaway:");
    println!("  - s0 splits the modalities: EX atom is true (the s2 branch works)");
    println!("    while AX atom is false (the s1 branch spoils universality).");
    println!("  - s2 satisfies AX atom and AX (not atom) at once: with no");
    println!("    successors a universal claim is vacuously true, and EX is");
    println!("    always false there.");
}

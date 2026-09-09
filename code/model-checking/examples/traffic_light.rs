//! CTL model checking on a traffic-light Kripke structure.
//!
//! The light cycles green -> yellow -> red -> green forever. The example
//! labels three formulas over the cycle: `EX red`, `AX green`, and the
//! boolean combination `red OR (not green)`, printing the bit vector per
//! formula and the reason behind each bit.

use model_checking::{check, Formula, Kripke};

/// Atom names: atom 0 = green, atom 1 = yellow, atom 2 = red.
const NAMES: [&str; 3] = ["green", "yellow", "red"];

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
        vec![vec![1], vec![2], vec![0]],
        vec![vec![0], vec![1], vec![2]], // atoms: 0 = green, 1 = yellow, 2 = red
    );

    println!("Kripke structure (the light cycles forever):");
    println!("  atoms: 0 = green, 1 = yellow, 2 = red");
    for s in 0..m.n {
        let held: Vec<&str> = m.atoms[s].iter().map(|&a| NAMES[a]).collect();
        let next: Vec<String> = m.successors[s].iter().map(|t| format!("s{t}")).collect();
        println!(
            "  s{}: atoms = {{{}}}, successors = {{{}}}",
            s,
            held.join(", "),
            next.join(", ")
        );
    }
    println!();

    report(
        &m,
        "EX red",
        "some successor state satisfies red",
        &Formula::Ex(Box::new(Formula::Atom(2))),
        [
            "its only successor s1 is yellow, so no successor is red",
            "its successor s2 is red",
            "its successor s0 is green, so no successor is red",
        ],
    );

    report(
        &m,
        "AX green",
        "every successor state satisfies green",
        &Formula::Ax(Box::new(Formula::Atom(0))),
        [
            "its successor s1 is yellow, so not every successor is green",
            "its successor s2 is red, so not every successor is green",
            "its successor s0 is green -- the only state whose next light is green",
        ],
    );

    report(
        &m,
        "red OR (not green)",
        "red holds, or green does not hold",
        &Formula::Or(
            Box::new(Formula::Atom(2)),
            Box::new(Formula::Not(Box::new(Formula::Atom(0)))),
        ),
        [
            "green holds and red does not, so both disjuncts fail",
            "neither red nor green holds, so not green makes the disjunction true",
            "red holds, so the disjunction is true regardless of green",
        ],
    );

    println!("Takeaway: the two modalities light up different states even on a");
    println!("simple cycle -- EX red holds in yellow, AX green holds in red, and");
    println!("the purely boolean red OR (not green) already covers yellow and red.");
}

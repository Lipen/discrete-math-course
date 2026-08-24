//! Mutual exclusion in LTL.
//!
//! The same two-process lock as the CTL `mutex` example, checked with a
//! linear-time property: `G ¬(critA ∧ critB)`. For the correct protocol
//! the Büchi check passes; for the broken protocol it returns a lasso
//! counterexample -- a finite prefix followed by a repeating cycle -- that
//! ends in the state `(c, c)` where both processes are critical.

use model_checking::{Counterexample, Kripke, ltl};

fn main() {
    let labels = [
        "(t,t)", "(t,w)", "(t,c)", "(w,t)", "(c,t)", "(w,w)", "(w,c)", "(c,w)", "(c,c)",
    ];

    // Correct protocol: waiting processes hand the lock over; the state
    // (c, c) does not exist in the transition graph.
    let good = Kripke::new(
        vec![
            vec![1, 3], // 0 (t,t)
            vec![2, 5], // 1 (t,w)
            vec![0, 6], // 2 (t,c)
            vec![4, 5], // 3 (w,t)
            vec![0, 7], // 4 (c,t)
            vec![6, 7], // 5 (w,w)
            vec![3],    // 6 (w,c)
            vec![1],    // 7 (c,w)
        ],
        vec![
            vec![],     // 0
            vec![],     // 1
            vec![1],    // 2: B critical
            vec![],     // 3
            vec![0],    // 4: A critical
            vec![],     // 5
            vec![1],    // 6: B critical
            vec![0],    // 7: A critical
        ],
    );

    // Broken protocol: state 8 = (c, c), reachable from the "both
    // waiting" state -- the classic non-atomic test-and-set bug.
    let bad = Kripke::new(
        vec![
            vec![1, 3],    // 0
            vec![2, 5],    // 1
            vec![0, 6],    // 2
            vec![4, 5],    // 3
            vec![0, 7],    // 4
            vec![6, 7, 8], // 5 (w,w) -- both grab the lock at once
            vec![3],       // 6
            vec![1],       // 7
            vec![8],       // 8 (c,c) -- both critical, self-loop
        ],
        vec![
            vec![],     // 0
            vec![],     // 1
            vec![1],    // 2
            vec![],     // 3
            vec![0],    // 4
            vec![],     // 5
            vec![1],    // 6
            vec![0],    // 7
            vec![0, 1], // 8
        ],
    );

    // G ¬(critA ∧ critB) -- atoms 0 and 1 mark the critical sections.
    let prop = ltl::Formula::G(Box::new(ltl::Formula::Not(Box::new(
        ltl::Formula::And(
            Box::new(ltl::Formula::Atom(0)),
            Box::new(ltl::Formula::Atom(1)),
        ),
    ))));

    println!("correct protocol: G ¬(critA ∧ critB)");
    match ltl::check(&good, &prop) {
        Ok(()) => println!("  holds"),
        Err(ce) => print_lasso("  violated", &labels, &ce),
    }

    println!("\nbroken protocol: G ¬(critA ∧ critB)");
    match ltl::check(&bad, &prop) {
        Ok(()) => println!("  holds"),
        Err(ce) => print_lasso("  violated", &labels, &ce),
    }
}

/// Print a lasso counterexample as a run of named states.
fn print_lasso(what: &str, labels: &[&str], ce: &Counterexample) {
    println!("  {}:", what);
    let mut run: Vec<usize> = ce.prefix.clone();
    run.extend(&ce.cycle);
    let names: Vec<String> = run
        .iter()
        .map(|&s| format!("{} ({})", s, labels[s]))
        .collect();
    println!("  prefix + one cycle: {}", names.join(" -> "));
    println!("  the cycle repeats forever");
}

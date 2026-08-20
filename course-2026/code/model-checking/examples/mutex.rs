//! Mutual exclusion in CTL.
//!
//! Two processes share a lock. Each state records the program counters
//! (t = thinking, w = waiting, c = critical); atoms are 0 = A critical and
//! 1 = B critical. A correct protocol never allows both processes into the
//! critical section; a broken one adds the state (c, c) and lets it be
//! reached, and the checker proves the difference.

use model_checking::{check, Formula, Kripke};

fn main() {
    let labels = [
        "(t,t)", "(t,w)", "(t,c)", "(w,t)", "(c,t)", "(w,w)", "(w,c)", "(c,w)", "(c,c)",
    ];

    // Correct protocol: waiting processes hand the lock over; the state
    // (c, c) simply does not exist in the transition graph.
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

    // Broken protocol: state 8 = (c, c), reachable from the "both waiting"
    // state -- the classic non-atomic test-and-set bug.
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

    println!("correct protocol: AG ¬(critA ∧ critB)");
    for (s, &holds) in mutex_holds(&good).iter().enumerate() {
        println!("  {}: {}", labels[s], holds);
    }

    println!("\nbroken protocol: AG ¬(critA ∧ critB)");
    for (s, &holds) in mutex_holds(&bad).iter().enumerate() {
        println!("  {}: {}", labels[s], holds);
    }

    println!("\nbroken protocol: EF (critA ∧ critB) -- the violation is reachable from");
    let reach_bad = check(
        &bad,
        &Formula::Ef(Box::new(Formula::And(
            Box::new(Formula::Atom(0)),
            Box::new(Formula::Atom(1)),
        ))),
    );
    for (s, &holds) in reach_bad.iter().enumerate() {
        println!("  {}: {}", labels[s], holds);
    }
}

/// The mutual-exclusion property: AG ¬(crit₁ ∧ crit₂).
fn mutex_holds(m: &Kripke) -> Vec<bool> {
    check(
        m,
        &Formula::Ag(Box::new(Formula::Not(Box::new(Formula::And(
            Box::new(Formula::Atom(0)),
            Box::new(Formula::Atom(1)),
        ))))),
    )
}

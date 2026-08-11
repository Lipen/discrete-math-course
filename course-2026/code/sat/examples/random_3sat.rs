//! Random 3-SAT: generate instances at increasing clause-to-variable ratios
//! and observe the phase transition from mostly-SAT to mostly-UNSAT.
//!
//! Run with `cargo run -p sat --example random_3sat`.

use sat::cnf::Cnf;
use sat::solve;

fn main() {
    let nvars = 6;
    let ratios = [1, 2, 3, 4, 5, 6];

    println!("Random 3-SAT with {nvars} variables (20 instances per ratio)\n");
    println!("{:<10} {:<10} {:<10}", "ratio", "#SAT", "#UNSAT");
    println!("{}", "-".repeat(30));

    for &ratio in &ratios {
        let nclauses = ratio * nvars;
        let mut sat_count = 0;
        let mut unsat_count = 0;

        for seed in 0..20 {
            let cnf = Cnf::random_3sat(nvars, nclauses, seed as u64);
            match solve(&cnf) {
                Some(_) => sat_count += 1,
                None => unsat_count += 1,
            }
        }

        println!(
            "{:<10} {:<10} {:<10}",
            format!("{:.1}", ratio as f64),
            sat_count,
            unsat_count
        );
    }

    println!(
        "\nAround ratio 4--5 most random 3-SAT instances become unsatisfiable\n\
         (the phase transition)."
    );
}

//! Pigeonhole principle: PHP(n, n-1) places n pigeons into n-1 holes so that no two pigeons share a hole.
//! This is impossible, and the CNF formula is unsatisfiable.
//!
//! The pigeonhole principle is a classic hard case for SAT solvers: the formula is UNSAT, but unit propagation alone cannot detect it.
//!
//! Run with `cargo run --example pigeonhole`.

use sat::cnf::{neg, pos, Cnf};
use sat::solve;

fn main() {
    for n in 2..=5 {
        let cnf = php_cnf(n, n - 1);
        println!(
            "PHP({n}, {}): {nvars} variables, {nclauses} clauses... ",
            n - 1,
            nvars = cnf.num_vars,
            nclauses = cnf.clauses.len()
        );
        match solve(&cnf) {
            Some(_) => println!("  SAT (that is a bug -- PHP should be UNSAT!)"),
            None => println!("  UNSAT (as expected)"),
        }
    }
}

/// Build the pigeonhole principle PHP(n, holes).
///
/// Variable index: pigeon i in hole j -> variable (i-1)*holes + j.
fn php_cnf(n: usize, holes: usize) -> Cnf {
    let nvars = n * holes;
    let mut clauses = Vec::new();

    // Each pigeon occupies at least one hole.
    for i in 0..n {
        let mut clause = Vec::new();
        for j in 0..holes {
            clause.push(pos(i * holes + j + 1));
        }
        clauses.push(clause);
    }

    // No two pigeons share the same hole.
    for i1 in 0..n {
        for i2 in (i1 + 1)..n {
            for j in 0..holes {
                let v1 = i1 * holes + j + 1;
                let v2 = i2 * holes + j + 1;
                clauses.push(vec![neg(v1), neg(v2)]);
            }
        }
    }

    Cnf::new(nvars, clauses).unwrap()
}

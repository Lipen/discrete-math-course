//! Validity and satisfiability over finite domains, by exhaustion.

use fol::enumerate::{domain, enumerate_structures, satisfiable_over, valid_over};
use fol::formula::{exists, forall, not, or, pred};
use fol::signature::Signature;
use fol::term::var;
fn main() {
    // A signature with a single unary predicate P.
    let sig = Signature::new().predicate("P", 1);

    // ∀x (P(x) ∨ ¬P(x)) -- an instance of the excluded middle.
    let lem = forall(
        "x",
        or(pred("P", vec![var("x")]), not(pred("P", vec![var("x")]))),
    );
    println!("formula: {lem}\n");

    for n in [1, 2] {
        let d = domain(n);
        let structures = enumerate_structures(&sig, &d);
        println!("domain of size {n}: {} structures", structures.len());
        println!("  valid over this domain? {}", valid_over(&sig, &lem, &d));
        println!();
    }

    // ∃x P(x) -- satisfiable, but not valid.
    let some_p = exists("x", pred("P", vec![var("x")]));
    let d = domain(2);
    match satisfiable_over(&sig, &some_p, &d) {
        Some(m) => {
            println!("formula: {some_p}");
            println!("  satisfiable over domain {d:?} -- a witness model:");
            println!("    domain = {:?}", m.domain);
            println!("    P      = {:?}", m.predicates.get("P").unwrap());
        }
        None => println!("unexpected: no model found"),
    }
    println!(
        "  valid over this domain? {}",
        valid_over(&sig, &some_p, &d)
    );
}

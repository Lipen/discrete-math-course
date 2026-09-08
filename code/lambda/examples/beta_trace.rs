//! Step-by-step beta-reduction trace.
//!
//! Demonstrates how to inspect each reduction step, showing the term
//! before and after each beta-contraction.

use lambda::{church, Term};

fn main() {
    // (λx. λy. y x) (λz. z) a  -- a term with nested redexes
    let body = Term::abs("y", Term::app(Term::var("y"), Term::var("x")));
    let fun = Term::abs("x", body);
    let id = Term::abs("z", Term::var("z"));
    let term = Term::app(Term::app(fun, id), Term::var("a"));

    println!("Starting term:  {}", term);
    println!();

    let trace = term.trace(20);
    for (i, step) in trace.iter().enumerate() {
        if i == 0 {
            continue;
        }
        println!("After step {}:  {}", i, step);
    }
    println!();
    let final_term = trace.last().unwrap();
    println!("Normal form:  {}", final_term);
    assert!(final_term.is_normal_form());

    // -- Church arithmetic with trace ========================================
    println!();
    println!("== Church succ 2 with trace ==");

    let c2 = church(2);
    let succ_term = Term::app(lambda::succ(), c2);
    println!("Starting:  {}", succ_term);

    let succ_trace = succ_term.trace(10);
    for (i, step) in succ_trace.iter().enumerate() {
        if i == 0 {
            continue;
        }
        println!("  step {}: {}", i, step);
    }
    println!(
        "Result as nat: {}",
        lambda::church::to_nat(succ_trace.last().unwrap()).unwrap()
    );
}

//! Interval analysis of the counter loop from the abstract-interpretation
//! chapter: `i := 0; while ... do i := i + 1`.
//!
//! Naive iteration would climb [0,0], [0,1], [0,2], ... forever; widening drops
//! the moving bound and converges on [0, +∞) in two steps.

use analysis::program::{assign, exec_interval, inc, State, Stmt};
use analysis::Interval;

fn main() {
    let program = vec![
        assign("i", 0),
        Stmt::While {
            body: vec![inc("i")],
        },
    ];

    let mut st: State<Interval> = State::new();
    exec_interval(&program, &mut st);

    println!("i := 0");
    println!("while ... do i := i + 1");
    println!("\nnaive iteration: [0,0], [0,1], [0,2], ... never stops");
    println!("after widening:  i ∈ {}", st["i"]);
    println!("the upper bound that kept moving was dropped to +∞, and the fixpoint converged.");
}

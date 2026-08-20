//! An unsatisfiable system and the negative cycle behind it.
//!
//! x0 - x1 <= 2 and x1 - x0 <= -3 together force x0 - x1 <= 2 and
//! x0 - x1 >= 3 at once -- the constraint graph contains a cycle of
//! total weight 2 + (-3) = -1, which Bellman-Ford detects.

use smt::difference::{solve, Constraint};

fn main() {
    let cs = vec![
        Constraint { x: 0, y: 1, c: 2 },  // x0 - x1 <= 2
        Constraint { x: 1, y: 0, c: -3 }, // x1 - x0 <= -3, i.e. x0 - x1 >= 3
    ];

    println!("constraints:");
    for c in &cs {
        println!("  x{} - x{} <= {}", c.x, c.y, c.c);
    }

    match solve(&cs) {
        Some(a) => println!("\nverdict: satisfiable, assignment {a:?}"),
        None => {
            println!("\nverdict: unsatisfiable");
            println!("core: the cycle x0 - x1 <= 2 with x1 - x0 <= -3");
            println!("      sums to 0 <= -1, a contradiction.");
        }
    }
}

//! Solving a small difference-logic system.
//!
//! Variable 0 is a task finish, variable 1 its start: the task takes
//! between 4 and 5 time units (4 <= x0 - x1 <= 5). Variable 2 is a
//! deadline: it may lag the start by at most 2 units (x2 - x1 <= 2).
//! The solver returns an assignment; the demo re-checks every constraint.

use smt::difference::{solve, Constraint};

fn main() {
    let cs = vec![
        Constraint { x: 0, y: 1, c: 5 },  // x0 - x1 <= 5
        Constraint { x: 1, y: 0, c: -4 }, // x1 - x0 <= -4, i.e. x0 - x1 >= 4
        Constraint { x: 2, y: 1, c: 2 },  // x2 - x1 <= 2
    ];

    println!("constraints:");
    for c in &cs {
        println!("  x{} - x{} <= {}", c.x, c.y, c.c);
    }

    let a = solve(&cs).expect("the system is satisfiable");
    println!("\nassignment: x0 = {}, x1 = {}, x2 = {}", a[0], a[1], a[2]);

    println!("\nre-check:");
    for c in &cs {
        let lhs = a[c.x] - a[c.y];
        println!("  x{} - x{} = {} <= {}: {}", c.x, c.y, lhs, c.c, lhs <= c.c);
    }
}

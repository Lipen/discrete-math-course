//! Steensgaard's pointer analysis on a tiny C-like program.
//!
//! The program uses all four statement forms. After every statement the
//! current points-to sets are printed, so the unification steps -- the
//! places where two locations merge into one -- are visible.

use graphs::{Steensgaard, Stmt};

fn main() {
    // A tiny C-like program:
    //
    //   p = &x;   // p points to x
    //   q = &y;   // q points to y
    //   *p = q;   // store: x receives q, so x and q unify
    //   r = q;    // copy: r unifies with q (and hence with x)
    //   p = &z;   // p already points to x; now it also points to z,
    //             // so x and z merge into one location
    //   z = &w;   // z's location must hold y and w: y and w merge too
    let program = [
        Stmt::AddrOf {
            x: "p".into(),
            y: "x".into(),
        },
        Stmt::AddrOf {
            x: "q".into(),
            y: "y".into(),
        },
        Stmt::Store {
            x: "p".into(),
            y: "q".into(),
        },
        Stmt::Copy {
            x: "r".into(),
            y: "q".into(),
        },
        Stmt::AddrOf {
            x: "p".into(),
            y: "z".into(),
        },
        Stmt::AddrOf {
            x: "z".into(),
            y: "w".into(),
        },
    ];

    println!("Program:");
    for stmt in &program {
        println!("  {}", format_stmt(stmt));
    }
    println!();

    let mut s = Steensgaard::new();
    for stmt in &program {
        s.apply(stmt);
        println!("after {}:", format_stmt(stmt));
        for (name, set) in s.points_to_sets() {
            let shown = if set.is_empty() {
                "nothing".to_string()
            } else {
                set.join(", ")
            };
            println!("  {name} points to {{{shown}}}");
        }
        println!();
    }

    println!("May-alias questions:");
    println!(
        "  q and r: {}  (unified by the copy r = q)",
        s.may_alias("q", "r")
    );
    println!("  x and z: {}  (merged by p = &z)", s.may_alias("x", "z"));
    println!("  y and w: {}  (merged by z = &w)", s.may_alias("y", "w"));
    println!(
        "  p and q: {}  (their points-to sets are disjoint)",
        s.may_alias("p", "q")
    );

    assert!(s.may_alias("q", "r"));
    assert!(s.may_alias("x", "z"));
    assert!(s.may_alias("y", "w"));
    assert!(!s.may_alias("p", "q"));
    println!("\nall checks passed");
}

fn format_stmt(stmt: &Stmt) -> String {
    match stmt {
        Stmt::AddrOf { x, y } => format!("{x} = &{y}"),
        Stmt::Copy { x, y } => format!("{x} = {y}"),
        Stmt::Load { x, y } => format!("{x} = *{y}"),
        Stmt::Store { x, y } => format!("*{x} = {y}"),
    }
}

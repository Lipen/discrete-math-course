//! A declarative model builder and the symbolic engine, side by side.
//!
//! First a traffic light is declared with the SMV/SPIN-inspired
//! `ModelBuilder` (a variable, a next-expression, an always-enabled
//! guarded transition) and compiled to a `Kripke` structure, which the
//! CTL checker verifies. Then the same idea is explored symbolically: a
//! 2-bit saturating counter is given as a Boolean transition formula, and
//! `EF top` / `AG top` are computed by fixed-point iteration over
//! formulas.

use model_checking::{Expr, Formula, ModelBuilder, check};
use model_checking::symbolic::{BoolExpr as B, System, models, sat_count};

fn main() {
    // --- 1. Traffic light via the declarative builder ---
    let mut b = ModelBuilder::new();
    let light = b.var("light", 0); // 0 = green, 1 = yellow, 2 = red
    b.next(
        "light",
        Expr::mod_(
            Expr::add(Expr::var(light), Expr::val(1)),
            Expr::val(3),
        ),
    );
    b.transition(Expr::val(1)); // always enabled: one deterministic step

    let m = b.build();
    let green = b.atom("light", 0);
    let red = b.atom("light", 2);

    // AG (green -> AF red): after green, every path eventually sees red.
    let prop = Formula::Ag(Box::new(Formula::Or(
        Box::new(Formula::Not(Box::new(Formula::Atom(green)))),
        Box::new(Formula::Af(Box::new(Formula::Atom(red)))),
    )));
    let sat = check(&m, &prop);

    println!("traffic light (declarative builder):");
    for s in 0..m.n {
        println!(
            "  {}: AG(green -> AF red) = {}",
            b.state_label(s),
            sat[s]
        );
    }

    // --- 2. Symbolic engine: the saturating 2-bit counter ---
    // Current bits: x = 0, y = 1; next bits: x' = 2, y' = 3.
    // 00 -> 01 -> 10 -> 11 -> 11.
    let trans = B::and(
        B::iff(B::Var(2), B::or(B::Var(0), B::Var(1))), // x' = x ∨ y
        B::iff(B::Var(3), B::or(B::Var(0), B::not(B::Var(1)))), // y' = x ∨ ¬y
    );
    let sys = System {
        nvars: 2,
        init: B::and(B::not(B::Var(0)), B::not(B::Var(1))),
        trans,
    };

    let top = B::and(B::Var(0), B::Var(1)); // the state 11
    let ef = sys.ef(&top);
    let ag = sys.ag(&top);

    println!("\nsymbolic 2-bit counter (00 -> 01 -> 10 -> 11 -> 11):");
    println!(
        "  EF top: {} of 4 states (models: {:?})",
        sat_count(&ef, 2),
        models(&ef, 2)
    );
    println!(
        "  AG top: {} of 4 states (models: {:?})",
        sat_count(&ag, 2),
        models(&ag, 2)
    );
}

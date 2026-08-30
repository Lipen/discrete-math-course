//! A tiny world where "every human is mortal" holds -- and one where it fails.

use std::collections::HashSet;

use fol::formula::{forall, implies, pred};
use fol::structure::Structure;
use fol::term::var;

fn main() {
    // ∀x (Human(x) -> Mortal(x))
    let all_humans_mortal = forall(
        "x",
        implies(
            pred("Human", vec![var("x")]),
            pred("Mortal", vec![var("x")]),
        ),
    );
    println!("formula: {all_humans_mortal}\n");

    // World 1: the only human, Socrates, is mortal (Zeus is not human).
    let world1 = Structure::new(vec!["socrates".into(), "zeus".into()])
        .with_predicate("Human", set(&[&["socrates"]]))
        .with_predicate("Mortal", set(&[&["socrates"], &["zeus"]]));

    // World 2: Zeus is human too, but not mortal.
    let world2 = Structure::new(vec!["socrates".into(), "zeus".into()])
        .with_predicate("Human", set(&[&["socrates"], &["zeus"]]))
        .with_predicate("Mortal", set(&[&["socrates"]]));

    for (name, world) in [("world 1", &world1), ("world 2", &world2)] {
        println!("{name}: domain = {:?}", world.domain);
        println!("  Human  = {:?}", world.predicates.get("Human").unwrap());
        println!("  Mortal = {:?}", world.predicates.get("Mortal").unwrap());
        println!(
            "  truth of formula: {}",
            world.eval(&all_humans_mortal).unwrap()
        );
        println!();
    }
}

fn set(tuples: &[&[&str]]) -> HashSet<Vec<String>> {
    tuples
        .iter()
        .map(|t| t.iter().map(|s| s.to_string()).collect())
        .collect()
}

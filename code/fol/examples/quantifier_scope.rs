//! Quantifier order changes meaning: ∀x∃y L(x,y) vs ∃y∀x L(x,y).

use std::collections::HashSet;

use fol::formula::{exists, forall, pred};
use fol::structure::Structure;
use fol::term::var;

fn main() {
    let each_loves_someone = forall("x", exists("y", pred("L", vec![var("x"), var("y")])));
    let someone_loved_by_all = exists("y", forall("x", pred("L", vec![var("x"), var("y")])));

    println!("a) {each_loves_someone}   (everyone loves someone)");
    println!("b) {someone_loved_by_all}   (someone is loved by all)\n");

    // Two people, each loves only themselves: L = {(a, a), (b, b)}.
    let self_love = Structure::new(vec!["a".into(), "b".into()])
        .with_predicate("L", set(&[&["a", "a"], &["b", "b"]]));

    println!(
        "model 1: each loves only themselves, L = {:?}",
        self_love.predicates.get("L").unwrap()
    );
    println!(
        "  a) holds? {}",
        self_love.eval(&each_loves_someone).unwrap()
    );
    println!(
        "  b) holds? {}",
        self_love.eval(&someone_loved_by_all).unwrap()
    );
    println!();

    // Everyone (including c) loves c: L = {(a, c), (b, c), (c, c)}. Now b)
    // holds -- c is loved by all -- and a) follows from it.
    let shared_love = Structure::new(vec!["a".into(), "b".into(), "c".into()])
        .with_predicate("L", set(&[&["a", "c"], &["b", "c"], &["c", "c"]]));

    println!(
        "model 2: everyone loves c, L = {:?}",
        shared_love.predicates.get("L").unwrap()
    );
    println!(
        "  a) holds? {}",
        shared_love.eval(&each_loves_someone).unwrap()
    );
    println!(
        "  b) holds? {}",
        shared_love.eval(&someone_loved_by_all).unwrap()
    );
}

fn set(tuples: &[&[&str]]) -> HashSet<Vec<String>> {
    tuples
        .iter()
        .map(|t| t.iter().map(|s| s.to_string()).collect())
        .collect()
}

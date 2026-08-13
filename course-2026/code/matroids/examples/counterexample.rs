//! Greedy fails on a non-matroid: a(5), b(4), c(4).
//!
//! Independent sets: {}, {a}, {b}, {c}, {b,c}. The pairs {a,b} and {a,c}
//! are forbidden, so the exchange property fails. Greedy takes the heaviest
//! element `a` and gets stuck at weight 5, while {b,c} weighs 8.

use matroids::examples::SimpleIndependenceSystem;
use matroids::{greedy, weight};

fn main() {
    let system = SimpleIndependenceSystem {
        n: 3,
        max_size: 2,
        forbidden: vec![vec![0, 1], vec![0, 2]],
    };
    let weights = [5u32, 4, 4];

    let base = greedy(&system, &weights);
    let base_weight = weight(&base, &weights);
    let names: Vec<char> = base.iter().map(|&i| (b'a' + i as u8) as char).collect();

    println!("weights: a = 5, b = 4, c = 4");
    println!("independent sets: {{}}, {{a}}, {{b}}, {{c}}, {{b,c}}");
    println!("greedy picks: {:?}", names);
    println!("greedy weight: {}", base_weight);
    println!("optimal weight: 8 ({{b,c}})");

    assert!(base_weight < 8, "greedy should miss the optimum here");
}

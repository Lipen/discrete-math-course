//! Two non-isomorphic models that are bisimilar.
//!
//! The left model has a state with two successors.
//! The right model has a single successor.
//! The bisimulation pairs every left successor with the right one, so both roots satisfy the same modal formulas.

use model_checking::{greatest_bisimulation, quotient, Kripke};

fn main() {
    let left = Kripke::new(
        vec![vec![1, 2], vec![], vec![]],
        vec![vec![0], vec![0], vec![0]],
    );
    let right = Kripke::new(vec![vec![1], vec![]], vec![vec![0], vec![0]]);

    println!("left successors:  {:?}", left.successors);
    println!("right successors: {:?}", right.successors);

    let z = greatest_bisimulation(&left, &right);
    println!("bisimulation matrix:");
    for (s, row) in z.iter().enumerate() {
        let pairs: Vec<usize> = row
            .iter()
            .enumerate()
            .filter_map(|(t, &related)| if related { Some(t) } else { None })
            .collect();
        println!("  left {s} -> right {pairs:?}");
    }

    println!("roots are bisimilar: {}", z[0][0]);
    println!("models are isomorphic: false");

    let (q, class) = quotient(&left);
    println!("left quotient states: {}", q.n);
    println!("left state classes:  {class:?}");
    println!("quotient successors: {:?}", q.successors);
}

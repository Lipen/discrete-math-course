//! Join and meet on the divisor lattice of 12.
//!
//! Prints upper/lower bounds and the join/meet of a few pairs: the supremum
//! of {2, 3} is 6, their infimum is 1.
//! The second part rebuilds the same poset from a divisibility predicate
//! with `relation_pairs` and derives its Hasse diagram (cover relation),
//! which is also the shape of the printed lattice.

use lattices::examples::divisors_12;
use lattices::{hasse, relation_pairs};

fn main() {
    let d = divisors_12();
    for (a, b) in [(2, 3), (4, 6), (2, 4)] {
        println!("pair ({a}, {b})");
        println!("  upper bounds: {:?}", d.upper_bounds(a, b));
        println!("  lower bounds: {:?}", d.lower_bounds(a, b));
        println!(
            "  join = {}, meet = {}",
            d.join(a, b).map_or("none".to_string(), |j| j.to_string()),
            d.meet(a, b).map_or("none".to_string(), |m| m.to_string())
        );
    }

    // The same poset, built from a predicate: elements 1, 2, 3, 4, 6, 12.
    let elements = [1u32, 2, 3, 4, 6, 12];
    let pairs = relation_pairs(elements.len(), |i, j| {
        elements[j].is_multiple_of(elements[i])
    });
    println!("\nrelation pairs: {}", pairs.len());
    let covers = hasse(&pairs);
    println!("Hasse diagram (covers):");
    for &(i, j) in &covers {
        println!("  {} < {}", elements[i], elements[j]);
    }
}

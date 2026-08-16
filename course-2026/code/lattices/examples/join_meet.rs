//! Join and meet on the divisor lattice of 12.
//!
//! Prints upper/lower bounds and the join/meet of a few pairs: the supremum
//! of {2, 3} is 6, their infimum is 1.

use lattices::examples::divisors_12;

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
}

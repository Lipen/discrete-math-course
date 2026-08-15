//! The Birkhoff characterization of distributive lattices.
//!
//! A lattice is distributive exactly when it contains no sublattice
//! isomorphic to M3 or N5. The demo checks this on the running examples:
//! the divisor lattice of 12 and the Boolean lattice B3 are distributive;
//! M3 and N5 are not.

use lattices::examples::{boolean_3, divisors_12, m3, n5};

fn report(name: &str, l: &lattices::Lattice) {
    println!("{name}");
    println!(
        "  lattice: {}\n  distributive: {} (laws) / {} (Birkhoff)\n  modular: {}\n  M3 sublattice: {}\n  N5 sublattice: {}",
        l.is_lattice(),
        l.is_distributive(),
        l.is_distributive_birkhoff(),
        l.is_modular(),
        l.has_m3_sublattice(),
        l.has_n5_sublattice(),
    );
}

fn main() {
    report("divisors of 12", &divisors_12());
    report("boolean lattice B3", &boolean_3());
    report("M3 (diamond)", &m3());
    report("N5 (pentagon)", &n5());
}

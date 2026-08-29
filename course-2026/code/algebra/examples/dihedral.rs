//! The dihedral group D_4: the symmetries of the square.

use algebra::dihedral::D4;
use algebra::order;
use algebra::traits::Semigroup;

fn main() {
    let elems = D4::elements();
    let r = D4::r();
    let s = D4::s();

    println!(
        "D_4 = {{{}}}",
        elems.iter().map(D4::name).collect::<Vec<_>>().join(", ")
    );

    println!("\norders:");
    for g in &elems {
        println!("  order({}) = {}", g.name(), order(g, 8).unwrap());
    }

    println!("\nCayley table (row · column):");
    print!("{:>4}", "·");
    for b in &elems {
        print!("{:>4}", b.name());
    }
    println!();
    for a in &elems {
        print!("{:>4}", a.name());
        for b in &elems {
            print!("{:>4}", a.op(b).name());
        }
        println!();
    }

    println!(
        "\nr·s = {},  s·r = {}  (non-abelian)",
        r.op(&s).name(),
        s.op(&r).name()
    );

    let rotations: Vec<D4> = (0..4).map(D4::rotation).collect();
    println!(
        "\nrotations C_4 = {{{}}} (a cyclic subgroup of order 4)",
        rotations
            .iter()
            .map(D4::name)
            .collect::<Vec<_>>()
            .join(", ")
    );
}

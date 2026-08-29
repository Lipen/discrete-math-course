//! The dihedral group D_4: the symmetries of the square.

use algebra::dihedral::D4;
use algebra::order;
use algebra::traits::Semigroup;

fn main() {
    let elems = D4::elements();
    let r = D4::r();
    let s = D4::s();

    println!("The eight symmetries of the square form the group D_4:");
    println!(
        "  {}",
        elems.iter().map(D4::name).collect::<Vec<_>>().join(", ")
    );

    println!("\nThe order of an element is how many times you compose it with");
    println!("itself to get back to the identity e:");
    for g in &elems {
        println!("  order({}) = {}", g.name(), order(g, 8).unwrap());
    }

    println!("\nThe whole group lives in one 8×8 Cayley table; row a and");
    println!("column b meet at a·b:");
    print!("{:>4}", "·");
    for b in &elems {
        print!("{:>4}", b.name());
    }
    println!();
    println!("{}", "-".repeat(4 * (elems.len() + 1)));
    for a in &elems {
        print!("{:>4}", a.name());
        for b in &elems {
            print!("{:>4}", a.op(b).name());
        }
        println!();
    }

    println!("\nThe table is not symmetric across its diagonal:");
    println!("  r·s = {},  s·r = {}", r.op(&s).name(), s.op(&r).name());
    println!("So D_4 is non-abelian.");

    let rotations: Vec<D4> = (0..4).map(D4::rotation).collect();
    println!("\nThe four rotations alone close under composition; they form the");
    println!(
        "cyclic subgroup C_4 = {}.",
        rotations
            .iter()
            .map(D4::name)
            .collect::<Vec<_>>()
            .join(", ")
    );
}

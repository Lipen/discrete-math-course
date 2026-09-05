//! The cyclic monoid `Z4` under addition mod 4 as a one-object category.
//!
//! The morphisms are the four elements `m0` to `m3`, the identity is `m0`, and the composition table of the category is the Cayley table of the monoid.

use categories::FiniteCategory;

fn main() {
    let cat = FiniteCategory::from_monoid(
        "Z4",
        &[&[0, 1, 2, 3], &[1, 2, 3, 0], &[2, 3, 0, 1], &[3, 0, 1, 2]],
    );

    println!("one object: {:?}", cat.objects);
    println!("morphisms: the elements m0..m3, identity m0 = 0");
    println!();
    println!("composition table, entry = g after f:");
    print!("      ");
    for g in &cat.morphisms {
        print!("{:>5}", g.name);
    }
    println!();
    for f in &cat.morphisms {
        print!("{:>5}  ", f.name);
        for g in &cat.morphisms {
            print!("{:>5}", cat.compose(f, g).name);
        }
        println!();
    }
    println!();

    let m1 = cat.morphisms[cat.find_morphism("m1").unwrap()].clone();
    let m2 = cat.morphisms[cat.find_morphism("m2").unwrap()].clone();
    println!(
        "m2 after m1 = {} : 1 + 2 = 3 mod 4",
        cat.compose(&m1, &m2).name
    );
    let id = cat.identity(m1.src);
    println!(
        "id after m1 = {} and m1 after id = {}",
        cat.compose(&id, &m1).name,
        cat.compose(&m1, &id).name
    );
    println!("check_axioms: {}", cat.check_axioms());

    assert!(cat.check_axioms());
    assert_eq!(cat.compose(&m1, &m2).name, "m3");
}

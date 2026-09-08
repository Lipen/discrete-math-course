//! The free category of the graph `A -a-> B -b-> C`: morphisms are paths.
//!
//! The demo lists all six paths, shows how composition glues paths end to end, and checks the category axioms.

use categories::{FiniteCategory, ObjId};

fn main() {
    let cat = FiniteCategory::free_from_graph(&["A", "B", "C"], &[("a", 0, 1), ("b", 1, 2)]);

    let width = 60;
    println!("{}", "=".repeat(width));
    println!("free category of the graph   A --a--> B --b--> C");
    println!("{}", "=".repeat(width));
    println!("  morphisms are paths, composition is gluing");
    println!();
    println!("  name      from    to      length");
    println!("  {}", "-".repeat(34));

    let mut sorted: Vec<_> = cat.morphisms.to_vec();
    sorted.sort_by_key(|m| (m.src.0, m.dst.0, m.name.len(), m.name.clone()));
    for m in &sorted {
        let is_id = m.name.starts_with("id_");
        let length = if is_id { 0 } else { m.name.split('*').count() };
        let note = if is_id { "  (empty path)" } else { "" };
        println!(
            "  {:<10}{:<8}{:<8}{}{}",
            m.name, cat.objects[m.src.0], cat.objects[m.dst.0], length, note
        );
    }

    println!();
    println!("  composition, entry = second after first");
    let a = cat.morphisms[cat.find_morphism("a").unwrap()].clone();
    let b = cat.morphisms[cat.find_morphism("b").unwrap()].clone();
    let ba = cat.morphisms[cat.find_morphism("b*a").unwrap()].clone();
    let id_c = cat.identity(ObjId(2));
    println!(
        "    b  after a      {:<8} walk a to B, then b to C",
        cat.compose(&a, &b).name
    );
    println!(
        "    id_C after b*a  {:<8} identity glues nothing",
        cat.compose(&ba, &id_c).name
    );
    println!("    b  after b      no arrow  b ends at C while b starts at B");

    println!();
    println!(
        "  category axioms (associativity, identities): {}",
        if cat.check_axioms() { "hold" } else { "FAIL" }
    );

    assert_eq!(cat.morphisms.len(), 6);
    assert!(cat.check_axioms());
}

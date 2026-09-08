//! The cyclic monoid `Z4` under addition mod 4 as a one-object category.
//!
//! The morphisms are the four elements `m0` to `m3`, the identity is `m0`, and the composition table of the category is the Cayley table of the monoid.

use categories::FiniteCategory;

fn table(cat: &FiniteCategory) {
    let names: Vec<&str> = cat.morphisms.iter().map(|m| m.name.as_str()).collect();
    let w = names.iter().map(|n| n.len()).max().unwrap_or(2) + 3;

    let mut header = " ".repeat(w + 2);
    for n in &names {
        header.push_str(&format!("{:>width$}", n, width = w));
    }
    println!("{header}");

    let mut rule = " ".repeat(w);
    rule.push_str("-+");
    rule.push_str(&"-".repeat(w * names.len()));
    println!("{rule}");

    for (i, f) in names.iter().enumerate() {
        let mut row = format!("{:>width$} |", f, width = w);
        for g in &names {
            let gf = cat.compose(
                &cat.morphisms[i],
                &cat.morphisms[cat.find_morphism(g).unwrap()],
            );
            row.push_str(&format!("{:>width$}", gf.name, width = w));
        }
        println!("{row}");
    }
}

fn main() {
    let cat = FiniteCategory::zn(4);

    let width = 60;
    println!("{}", "=".repeat(width));
    println!("Z4 as a one-object category");
    println!("{}", "=".repeat(width));
    println!();
    println!("  object        Z4");
    println!("  arrows        m0, m1, m2, m3  (the elements of the monoid)");
    println!("  identity      m0             (the neutral element 0)");
    println!();
    println!("  composition table: rows = first, columns = second");
    println!("  entry = column after row");
    println!();
    table(&cat);
    println!();
    println!("  spot checks");
    let m1 = cat.morphisms[cat.find_morphism("m1").unwrap()].clone();
    let m2 = cat.morphisms[cat.find_morphism("m2").unwrap()].clone();
    let id = cat.identity(m1.src);
    println!(
        "    m2 after m1      {:<12} since 2 + 1 = 3 mod 4",
        cat.compose(&m1, &m2).name
    );
    println!(
        "    id after m1      {:<12} identity leaves arrows alone",
        cat.compose(&id, &m1).name
    );
    println!(
        "    m1 after id      {:<12} on both sides",
        cat.compose(&m1, &id).name
    );
    println!();
    println!(
        "  category axioms (associativity, identities): {}",
        if cat.check_axioms() { "hold" } else { "FAIL" }
    );

    assert!(cat.check_axioms());
    assert_eq!(cat.compose(&m1, &m2).name, "m3");
}

//! The free category on a small graph: morphisms are paths, composition glues paths end to end.
//!
//! The graph `A -a-> B -b-> C` has six paths, and the composite of `a` then `b` is the path named `b*a`.

use categories::FiniteCategory;

fn main() {
    let cat = FiniteCategory::free_from_graph(&["A", "B", "C"], &[("a", 0, 1), ("b", 1, 2)]);

    println!("graph: A -a-> B -b-> C");
    println!(
        "all {} morphisms of the free category:",
        cat.morphisms.len()
    );
    for m in &cat.morphisms {
        println!(
            "  {:>4} : {} -> {}",
            m.name, cat.objects[m.src.0], cat.objects[m.dst.0]
        );
    }
    println!();

    let a = cat.morphisms[cat.find_morphism("a").unwrap()].clone();
    let b = cat.morphisms[cat.find_morphism("b").unwrap()].clone();
    let ab = cat.compose(&a, &b);
    println!("compose(a, b) = {} : first a, then b", ab.name);
    let id_c = cat.identity(ab.dst);
    println!("compose(b*a, id_C) = {}", cat.compose(&ab, &id_c).name);
    println!("check_axioms: {}", cat.check_axioms());

    assert_eq!(ab.name, "b*a");
    assert_eq!(cat.morphisms.len(), 6);
    assert!(cat.check_axioms());
}

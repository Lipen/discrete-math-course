//! Builder axioms, composition, and edge cases for finite categories.

use categories::{FiniteCategory, Morphism, ObjId};

fn z4() -> FiniteCategory {
    FiniteCategory::from_monoid(
        "Z4",
        &[&[0, 1, 2, 3], &[1, 2, 3, 0], &[2, 3, 0, 1], &[3, 0, 1, 2]],
    )
}

fn chain() -> FiniteCategory {
    FiniteCategory::from_poset(&[
        &[true, true, true],
        &[false, true, true],
        &[false, false, true],
    ])
}

fn free_triangle() -> FiniteCategory {
    FiniteCategory::free_from_graph(&["A", "B", "C"], &[("a", 0, 1), ("b", 1, 2)])
}

fn by_name(cat: &FiniteCategory, name: &str) -> Morphism {
    let i = cat.find_morphism(name).unwrap();
    cat.morphisms[i].clone()
}

#[test]
fn monoid_axioms_hold() {
    assert!(z4().check_axioms());
}

#[test]
fn monoid_composition_is_addition_mod_four() {
    let cat = z4();
    let sum = cat.compose(&by_name(&cat, "m1"), &by_name(&cat, "m2"));
    assert_eq!(sum.name, "m3");
    let wrap = cat.compose(&by_name(&cat, "m3"), &by_name(&cat, "m3"));
    assert_eq!(wrap.name, "m2");
}

#[test]
fn monoid_identity_laws() {
    let cat = z4();
    let id = cat.identity(ObjId(0));
    assert_eq!(id.name, "m0");
    for m in &cat.morphisms {
        assert_eq!(cat.compose(&id, m), *m);
        assert_eq!(cat.compose(m, &id), *m);
    }
}

#[test]
fn non_associative_table_fails_axioms() {
    // e*a=a, a*a=b, a*b=a, b*a=b, b*b=b: (a*b)*a = b but a*(b*a) = a.
    let cat = FiniteCategory::from_monoid("bad", &[&[0, 1, 2], &[1, 2, 1], &[2, 2, 2]]);
    assert!(!cat.check_axioms());
}

#[test]
fn poset_axioms_hold_and_composition_is_unique() {
    let cat = chain();
    assert!(cat.check_axioms());
    assert_eq!(cat.objects, vec!["0", "1", "2"]);
    assert_eq!(cat.morphisms.len(), 6);
    let composite = cat.compose(&by_name(&cat, "0->1"), &by_name(&cat, "1->2"));
    assert_eq!(composite.name, "0->2");
}

#[test]
fn non_transitive_relation_fails_axioms() {
    let le = [
        &[true, true, false][..],
        &[false, true, true][..],
        &[false, false, true][..],
    ];
    let cat = FiniteCategory::from_poset(&le);
    assert!(!cat.check_axioms());
}

#[test]
fn free_category_paths_and_axioms() {
    let cat = free_triangle();
    assert!(cat.check_axioms());
    assert_eq!(cat.morphisms.len(), 6);
    let names: Vec<&str> = cat.morphisms.iter().map(|m| m.name.as_str()).collect();
    assert_eq!(names, vec!["id_A", "id_B", "id_C", "a", "b", "b*a"]);
    let composite = cat.compose(&by_name(&cat, "a"), &by_name(&cat, "b"));
    assert_eq!(composite.name, "b*a");
}

#[test]
#[should_panic(expected = "cycle")]
fn cyclic_graph_panics() {
    FiniteCategory::free_from_graph(&["A", "B"], &[("a", 0, 1), ("b", 1, 0)]);
}

#[test]
fn empty_category_is_vacuously_a_category() {
    let cat = FiniteCategory::empty();
    assert!(cat.objects.is_empty());
    assert!(cat.check_axioms());
}

#[test]
fn one_object_one_morphism_category() {
    let cat = FiniteCategory::from_monoid("I", &[&[0]]);
    assert_eq!(cat.objects.len(), 1);
    assert_eq!(cat.morphisms.len(), 1);
    assert!(cat.check_axioms());
    let id = cat.identity(ObjId(0));
    assert_eq!(cat.compose(&id, &id), id);
}

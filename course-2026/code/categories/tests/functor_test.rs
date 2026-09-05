//! Functor laws verified by the checker, on valid and broken examples.

use categories::{FiniteCategory, Functor, Morphism, ObjId};

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
fn doubling_is_a_functor() {
    let cat = z4();
    let f = Functor {
        obj_map: vec![ObjId(0)],
        mor_map: (0..4)
            .map(|i| by_name(&cat, &format!("m{}", 2 * i % 4)))
            .collect(),
    };
    assert!(f.check(&cat, &cat));
}

#[test]
fn shift_is_not_a_functor() {
    // m0 must map to the identity, but the shift sends m0 to m1.
    let cat = z4();
    let f = Functor {
        obj_map: vec![ObjId(0)],
        mor_map: (0..4)
            .map(|i| by_name(&cat, &format!("m{}", (i + 1) % 4)))
            .collect(),
    };
    assert!(!f.check(&cat, &cat));
}

#[test]
fn free_category_collapses_into_the_poset_chain() {
    let free = free_triangle();
    let pos = chain();
    // free morphism order: id_A, id_B, id_C, a, b, b*a.
    let images = ["0->0", "1->1", "2->2", "0->1", "1->2", "0->2"];
    let f = Functor {
        obj_map: vec![ObjId(0), ObjId(1), ObjId(2)],
        mor_map: images.iter().map(|n| by_name(&pos, n)).collect(),
    };
    assert!(f.check(&free, &pos));
}

#[test]
fn wrong_image_homset_fails() {
    // a lands on the morphism 0->2 while B is sent to object 1.
    let free = free_triangle();
    let pos = chain();
    let images = ["0->0", "1->1", "2->2", "0->2", "1->2", "0->2"];
    let f = Functor {
        obj_map: vec![ObjId(0), ObjId(1), ObjId(2)],
        mor_map: images.iter().map(|n| by_name(&pos, n)).collect(),
    };
    assert!(!f.check(&free, &pos));
}

#[test]
fn wrong_arity_fails() {
    let cat = z4();
    let f = Functor {
        obj_map: vec![],
        mor_map: vec![],
    };
    assert!(!f.check(&cat, &cat));
}

#[test]
fn identity_functor_on_the_free_category() {
    let cat = free_triangle();
    let id = Functor {
        obj_map: (0..cat.objects.len()).map(ObjId).collect(),
        mor_map: cat.morphisms.clone(),
    };
    assert!(id.check(&cat, &cat));
}

#[test]
fn embedding_z2_into_z4() {
    let two = FiniteCategory::from_monoid("Z2", &[&[0, 1], &[1, 0]]);
    let four = z4();
    let embed = Functor {
        obj_map: vec![ObjId(0)],
        mor_map: vec![by_name(&four, "m0"), by_name(&four, "m2")],
    };
    assert!(embed.check(&two, &four));
}

#[test]
fn constant_functor_into_the_trivial_category() {
    let trivial = FiniteCategory::from_monoid("1", &[&[0]]);
    let cat = free_triangle();
    let constant = Functor {
        obj_map: vec![ObjId(0); cat.objects.len()],
        mor_map: vec![trivial.morphisms[0].clone(); cat.morphisms.len()],
    };
    assert!(constant.check(&cat, &trivial));
}

#[test]
fn doubling_is_idempotent_on_m1() {
    let cat = z4();
    let double = Functor {
        obj_map: vec![ObjId(0)],
        mor_map: (0..4)
            .map(|i| by_name(&cat, &format!("m{}", 2 * i % 4)))
            .collect(),
    };
    assert!(double.check(&cat, &cat));
    // The image of m1 under doubling is the element of order two.
    let image = &double.mor_map[cat.find_morphism("m1").unwrap()];
    assert_eq!(image.name, "m2");
}

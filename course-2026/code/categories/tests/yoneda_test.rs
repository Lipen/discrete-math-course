//! The Yoneda bijection on three categories, plus the SetFunctor laws.

use categories::{hom_functor, natural_transformations, yoneda, FiniteCategory, ObjId, SetFunctor};

fn z4() -> FiniteCategory {
    FiniteCategory::zn(4)
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

fn parity_functor(cat: &FiniteCategory) -> SetFunctor<'_> {
    SetFunctor {
        cat,
        obj_map: vec![vec!["even".into(), "odd".into()]],
        mor_map: (0..4).map(|i| vec![i & 1, 1 - (i & 1)]).collect(),
    }
}

fn chain_functor<'a>(cat: &'a FiniteCategory) -> SetFunctor<'a> {
    SetFunctor {
        cat,
        obj_map: vec![
            vec!["a".into(), "b".into()],
            vec!["a".into(), "b".into()],
            vec!["a".into(), "b".into(), "c".into()],
        ],
        mor_map: vec![
            vec![0, 1],
            vec![0, 1],
            vec![0, 2],
            vec![0, 1],
            vec![0, 2],
            vec![0, 1, 2],
        ],
    }
}

fn free_functor<'a>(cat: &'a FiniteCategory) -> SetFunctor<'a> {
    SetFunctor {
        cat,
        obj_map: vec![
            vec!["x".into(), "w".into()],
            vec!["x".into(), "y".into()],
            vec!["x".into(), "y".into(), "z".into()],
        ],
        mor_map: vec![
            vec![0, 1],
            vec![0, 1],
            vec![0, 1, 2],
            vec![0, 0],
            vec![0, 2],
            vec![0, 0],
        ],
    }
}

#[test]
fn set_functors_satisfy_the_laws() {
    let c = z4();
    assert!(parity_functor(&c).check());
    let ch = chain();
    assert!(chain_functor(&ch).check());
    let fr = free_triangle();
    assert!(free_functor(&fr).check());
}

#[test]
fn broken_set_functor_fails() {
    let c = z4();
    let mut f = parity_functor(&c);
    f.mor_map[1][0] = 7;
    assert!(!f.check());
}

#[test]
fn yoneda_bijection_on_z4() {
    let c = z4();
    let f = parity_functor(&c);
    let hom = hom_functor(&c, ObjId(0));
    assert_eq!(hom.obj_map[0].len(), 4);
    let nats = natural_transformations(&hom, &f);
    assert_eq!(nats.len(), 2);
    let (nats, ok) = yoneda(&c, ObjId(0), &f);
    assert!(ok);
    assert_eq!(nats.len(), 2);
}

#[test]
fn yoneda_bijection_on_chain() {
    let c = chain();
    let f = chain_functor(&c);
    let (nats, ok) = yoneda(&c, ObjId(0), &f);
    assert!(ok);
    assert_eq!(nats.len(), 2);
}

#[test]
fn yoneda_bijection_on_free() {
    let c = free_triangle();
    let f = free_functor(&c);
    let (nats, ok) = yoneda(&c, ObjId(0), &f);
    assert!(ok);
    assert_eq!(nats.len(), 2);
}

#[test]
fn yoneda_on_the_one_morphism_category() {
    let c = FiniteCategory::from_monoid("I", &[&[0]]);
    let f = SetFunctor {
        cat: &c,
        obj_map: vec![vec!["u".into()]],
        mor_map: vec![vec![0]],
    };
    let (nats, ok) = yoneda(&c, ObjId(0), &f);
    assert!(ok);
    assert_eq!(nats.len(), 1);
}

#[test]
fn hom_functor_of_the_chain_lists_singletons() {
    let c = chain();
    let hom = hom_functor(&c, ObjId(0));
    let sizes: Vec<usize> = hom.obj_map.iter().map(|s| s.len()).collect();
    assert_eq!(sizes, vec![1, 1, 1]);
    assert_eq!(hom.obj_map[2], vec!["0->2".to_string()]);
}

#[test]
#[should_panic(expected = "same category")]
fn transformations_over_different_categories_panic() {
    let c = z4();
    let d = chain();
    let f = parity_functor(&c);
    let g = chain_functor(&d);
    let _ = natural_transformations(&f, &g);
}

#[test]
fn yoneda_holds_for_every_object_of_the_chain() {
    let cat = chain();
    let f = chain_functor(&cat);
    for a in 0..cat.objects.len() {
        let (transformations, bijective) = yoneda(&cat, ObjId(a), &f);
        assert!(bijective, "focus object {a}");
        assert_eq!(transformations.len(), f.obj_map[a].len());
    }
}

#[test]
fn yoneda_holds_for_every_object_of_the_free_category() {
    let cat = free_triangle();
    let f = free_functor(&cat);
    for a in 0..cat.objects.len() {
        let (transformations, bijective) = yoneda(&cat, ObjId(a), &f);
        assert!(bijective, "focus object {a}");
        assert_eq!(transformations.len(), f.obj_map[a].len());
    }
}

#[test]
fn yoneda_on_a_three_element_set_functor() {
    let cat = z4();
    let f = SetFunctor {
        cat: &cat,
        obj_map: vec![vec!["u".into(), "v".into(), "w".into()]],
        // The involution: m1 swaps u and v, w is fixed.
        // Element orders must divide 4, so a 3-cycle would not be an action.
        mor_map: vec![vec![0, 1, 2], vec![1, 0, 2], vec![0, 1, 2], vec![1, 0, 2]],
    };
    assert!(f.check());
    let (transformations, bijective) = yoneda(&cat, ObjId(0), &f);
    assert!(bijective);
    assert_eq!(transformations.len(), 3);
}

#[test]
fn empty_functor_admits_exactly_one_transformation_nowhere() {
    let cat = z4();
    let f = SetFunctor {
        cat: &cat,
        obj_map: vec![vec![]],
        mor_map: vec![vec![]; 4],
    };
    assert!(f.check());
    let (transformations, bijective) = yoneda(&cat, ObjId(0), &f);
    assert!(bijective);
    assert_eq!(transformations.len(), 0);
}

#[test]
fn yoneda_on_a_v_shaped_poset() {
    // 0 <= 1 and 0 <= 2, with 1 and 2 incomparable.
    let v = FiniteCategory::from_poset(&[
        &[true, true, true],
        &[false, true, false],
        &[false, false, true],
    ]);
    let f = SetFunctor {
        cat: &v,
        obj_map: vec![
            vec!["p".into(), "q".into()],
            vec!["p".into()],
            vec!["q".into()],
        ],
        // Morphism order: 0->0, 0->1, 0->2, 1->1, 2->2.
        mor_map: vec![vec![0, 1], vec![0, 0], vec![0, 0], vec![0], vec![0]],
    };
    assert!(f.check());
    let (transformations, bijective) = yoneda(&v, ObjId(0), &f);
    assert!(bijective);
    assert_eq!(transformations.len(), 2);
}

#[test]
fn hom_functor_sizes_match_the_hom_sets() {
    let cat = free_triangle();
    let from_b = hom_functor(&cat, ObjId(1));
    assert_eq!(from_b.obj_map[0].len(), 0); // no arrows from B back to A
    assert_eq!(from_b.obj_map[1].len(), 1); // only id_B
    assert_eq!(from_b.obj_map[2].len(), 1); // only b
}

#[test]
fn naturality_survives_functor_composition_data() {
    // The identity natural transformation of a functor with itself is natural.
    let cat = chain();
    let f = chain_functor(&cat);
    let ids = categories::NaturalTransformation {
        components: f.obj_map.iter().map(|s| (0..s.len()).collect()).collect(),
    };
    let as_family: Vec<Vec<usize>> = ids.components.clone();
    assert!(!as_family.is_empty());
    // Recount via the public search: the identity must appear among the results.
    let all = natural_transformations(&f, &f);
    assert!(all.iter().any(|t| t.components == ids.components));
}

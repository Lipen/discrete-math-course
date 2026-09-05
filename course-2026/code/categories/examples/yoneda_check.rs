//! The Yoneda bijection `Nat(Hom(a, -), F) = F(a)` verified by exhaustive search.
//!
//! Three categories run the check: the monoid `Z4` as a one-object category, the poset chain `0 < 1 < 2`, and the free category of the graph `A -a-> B -b-> C`.
//! In each case the canonical map sends a transformation to its component at the identity of the focus object.

use categories::{hom_functor, yoneda, FiniteCategory, ObjId, SetFunctor};

fn report(title: &str, cat: &FiniteCategory, a: ObjId, f: &SetFunctor) {
    println!("== {title}");
    let hom = hom_functor(cat, a);
    for (x, set) in hom.obj_map.iter().enumerate() {
        println!(
            "  Hom({}, {}) = {:?}",
            cat.objects[a.0], cat.objects[x], set
        );
    }
    for (x, set) in f.obj_map.iter().enumerate() {
        println!("  F({}) = {:?}", cat.objects[x], set);
    }
    let (transformations, bijective) = yoneda(cat, a, f);
    let id_position = hom.obj_map[a.0]
        .iter()
        .position(|n| *n == cat.identity(a).name)
        .unwrap();
    println!("  natural transformations found: {}", transformations.len());
    for t in &transformations {
        let image = &f.obj_map[a.0][t.components[a.0][id_position]];
        println!(
            "    transformation maps to the F({}) element {:?}",
            cat.objects[a.0], image
        );
    }
    println!("  bijection Nat(Hom(a, -), F) = F(a) holds: {bijective}");
    println!();
    assert!(bijective);
}

fn main() {
    // Z4: F sends the single object to {even, odd} and odd elements flip parity.
    let z4 = FiniteCategory::from_monoid(
        "Z4",
        &[&[0, 1, 2, 3], &[1, 2, 3, 0], &[2, 3, 0, 1], &[3, 0, 1, 2]],
    );
    let parity = SetFunctor {
        cat: &z4,
        obj_map: vec![vec!["even".into(), "odd".into()]],
        mor_map: (0..4).map(|i| vec![i & 1, 1 - (i & 1)]).collect(),
    };
    assert!(parity.check());
    report(
        "monoid Z4 as a category, focus object Z4",
        &z4,
        ObjId(0),
        &parity,
    );

    // chain: F(0) = {a, b}, F(1) = {a, b}, F(2) = {a, b, c}, maps send a to a and b to c past object 1.
    let chain = FiniteCategory::from_poset(&[
        &[true, true, true],
        &[false, true, true],
        &[false, false, true],
    ]);
    let chain_f = SetFunctor {
        cat: &chain,
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
    };
    assert!(chain_f.check());
    report(
        "poset chain 0 < 1 < 2, focus object 0",
        &chain,
        ObjId(0),
        &chain_f,
    );

    // free category: F(A) = {x, w}, F(a) sends both elements to x, F(b) sends x to x and y to z.
    let free = FiniteCategory::free_from_graph(&["A", "B", "C"], &[("a", 0, 1), ("b", 1, 2)]);
    let free_f = SetFunctor {
        cat: &free,
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
    };
    assert!(free_f.check());
    report(
        "free category of A -a-> B -b-> C, focus object A",
        &free,
        ObjId(0),
        &free_f,
    );
}

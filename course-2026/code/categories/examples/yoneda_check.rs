//! The Yoneda bijection `Nat(Hom(a, -), F) = F(a)` verified by exhaustive search.
//!
//! Three categories run the check: the monoid `Z4` as a one-object category, the poset chain `0 < 1 < 2`, and the free category of the graph `A -a-> B -b-> C`.
//! For every natural transformation the demo prints its components and the canonical image of the identity arrow.

use categories::{hom_functor, yoneda, FiniteCategory, ObjId, SetFunctor};

fn brace(v: &[String]) -> String {
    format!("{{{}}}", v.join(", "))
}

fn report(title: &str, cat: &FiniteCategory, a: ObjId, f: &SetFunctor) {
    let width = 64;
    println!("{}", "-".repeat(width));
    println!("{title}");
    println!("{}", "-".repeat(width));

    let hom = hom_functor(cat, a);
    let mut left = 0;
    for x in 0..cat.objects.len() {
        left = left.max(format!("Hom({}, {})", cat.objects[a.0], cat.objects[x]).len());
        left = left.max(format!("F({})", cat.objects[x]).len());
    }
    for x in 0..cat.objects.len() {
        println!(
            "  {:<width$}{}",
            format!("Hom({}, {})", cat.objects[a.0], cat.objects[x]),
            brace(&hom.obj_map[x]),
            width = left + 2
        );
    }
    for x in 0..cat.objects.len() {
        println!(
            "  {:<width$}{}",
            format!("F({})", cat.objects[x]),
            brace(&f.obj_map[x]),
            width = left + 2
        );
    }

    let (transformations, bijective) = yoneda(cat, a, f);
    let id_name = cat.identity(a).name;
    let id_position = hom.obj_map[a.0].iter().position(|n| *n == id_name).unwrap();
    println!();
    println!("  natural transformations found: {}", transformations.len());
    for (no, t) in transformations.iter().enumerate() {
        println!("    no. {}", no + 1);
        for x in 0..cat.objects.len() {
            let mut pairs: Vec<String> = Vec::new();
            for (e, h) in hom.obj_map[x].iter().enumerate() {
                let image = &f.obj_map[x][t.components[x][e]];
                pairs.push(format!("{h} |-> {image}"));
            }
            println!(
                "      component at {:<3} {}",
                format!("{},", cat.objects[x]),
                pairs.join(", ")
            );
        }
        let image = &f.obj_map[a.0][t.components[a.0][id_position]];
        println!("      canonical image of {id_name}: {image}");
    }
    println!();
    println!(
        "  bijection Nat(Hom(a, -), F) = F(a): {}",
        if bijective { "holds" } else { "FAILS" }
    );
    println!();
    assert!(bijective);
    assert_eq!(transformations.len(), f.obj_map[a.0].len());
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
        "Z4 as a one-object category, focus object Z4",
        &z4,
        ObjId(0),
        &parity,
    );

    // Chain 0 <= 1 <= 2: F sends a to a and b to c past object 1.
    let chain = FiniteCategory::from_poset(&[
        &[true, true, true],
        &[false, true, true],
        &[false, false, true],
    ]);
    let growing = SetFunctor {
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
    assert!(growing.check());
    report(
        "poset chain 0 <= 1 <= 2, focus object 0",
        &chain,
        ObjId(0),
        &growing,
    );

    // Free category of A -a-> B -b-> C.
    let free = FiniteCategory::free_from_graph(&["A", "B", "C"], &[("a", 0, 1), ("b", 1, 2)]);
    // F(a) sends both elements to x, F(b) sends x to x and y to z.
    let labels = SetFunctor {
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
    assert!(labels.check());
    report(
        "free category of A --a--> B --b--> C, focus object A",
        &free,
        ObjId(0),
        &labels,
    );
}
